

-- ========================================
-- CONFIGURACION
-- ========================================
local PATROL_DEFINITIONS = {
    {
        name = "PATRULLA_THIRDREICH_AIR_01",
        templates = { "Patrol_IA_TR_01", "Patrol_IA_TR_02", "Patrol_IA_TR_03" },
        clonePrefix = "THIRDREICH air ",
        ownCoalition = coalition.side.RED,

        monitorUnitIndex = 1,
        altitudeArmAGL = 200,
        stopSpeed = 2,

        activationFlag = 110,
        activationValue = 1,

        debug = false
    },
    {
        name = "PATRULLA_THIRDREICH_AIR_02",
        templates = { "Patrol_IA_TR_04", "Patrol_IA_TR_05" },
        clonePrefix = "THIRDREICH air ",
        ownCoalition = coalition.side.RED,

        monitorUnitIndex = 1,
        altitudeArmAGL = 200,
        stopSpeed = 2,

        activationFlag = 103,
        activationValue = 1,

        debug = false
    },
    {
        name = "PATRULLA_THIRDREICH_AIR_03",
        templates = { "Patrol_IA_TR_06", "Patrol_IA_TR_07" },
        clonePrefix = "THIRDREICH air ",
        ownCoalition = coalition.side.RED,

        monitorUnitIndex = 1,
        altitudeArmAGL = 200,
        stopSpeed = 2,

        activationFlag = 111,
        activationValue = 1,

        debug = false
    },
    {
        name = "PATRULLA_THIRDREICH_AIR_04",
        templates = { "Patrol_IA_TR_08", "Patrol_IA_TR_09" },
        clonePrefix = "THIRDREICH air ",
        ownCoalition = coalition.side.RED,

        monitorUnitIndex = 1,
        altitudeArmAGL = 200,
        stopSpeed = 2,

        activationFlag = 104,
        activationValue = 1,

        debug = false
    },
    {
        name = "PATRULLA_THIRDREICH_AIR_05",
        templates = { "Patrol_IA_TR_10", "Patrol_IA_TR_11" },
        clonePrefix = "THIRDREICH air ",
        ownCoalition = coalition.side.RED,

        monitorUnitIndex = 1,
        altitudeArmAGL = 200,
        stopSpeed = 2,

        activationFlag = 107,
        activationValue = 1,

        debug = false
    },
    {
        name = "PATRULLA_THIRDREICH_AIR_06",
        templates = { "Patrol_IA_TR_12", "Patrol_IA_TR_13" },
        clonePrefix = "THIRDREICH air ",
        ownCoalition = coalition.side.RED,

        monitorUnitIndex = 1,
        altitudeArmAGL = 200,
        stopSpeed = 2,

        activationFlag = 115,
        activationValue = 1,

        debug = false
    }

    -- Ejemplo:
    -- ,
    -- {
    --     name = "PATRULLA_HUNGARY_AIR_01",
    --     templates = { "Patrol_IA_HUNGARY-1", "Patrol_IA_HUNGARY-2" },
    --     clonePrefix = "HUNGARY air ",
    --     ownCoalition = coalition.side.RED,
    --
    --     monitorUnitIndex = 1,
    --     altitudeArmAGL = 200,
    --     stopSpeed = 2,
    --
    --     activationFlag = 104,
    --     activationValue = 1,
    --
    --     debug = true
    -- }
}

local patrolStates = {}

-- ========================================
-- UTILS
-- ========================================
local function debugMessage(config, text, duration)
    if config.debug then
        trigger.action.outText("[" .. config.name .. "] " .. text, duration or 5)
    end
end

local function getActiveGroup(groupName)
    if not groupName then
        return nil
    end

    local group = Group.getByName(groupName)
    if group and group:isExist() then
        return group
    end

    return nil
end

local function findAliveUnit(group, preferredIndex)
    if not group or not group:isExist() then
        return nil
    end

    if preferredIndex then
        local preferredUnit = group:getUnit(preferredIndex)
        if preferredUnit and preferredUnit:isExist() then
            return preferredUnit
        end
    end

    local units = group:getUnits() or {}
    for i = 1, #units do
        local unit = units[i]
        if unit and unit:isExist() then
            return unit
        end
    end

    return nil
end

local function getSpeedMetersPerSecond(unit)
    local v = unit:getVelocity()
    if not v then
        return 0
    end
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

local function getAltitudeAGL(unit)
    local point = unit:getPoint()
    if not point then
        return 0
    end

    local terrainHeight = land.getHeight({ x = point.x, y = point.z })
    return point.y - terrainHeight
end

local function resetTransientState(state)
    state.maxAltitudeAGL = 0
    state.stopMonitoringArmed = false
end

local function isPatrolActivationAllowed(config)
    if config.activationFlag == nil or config.activationValue == nil then
        return true
    end

    return tonumber(trigger.misc.getUserFlag(config.activationFlag)) == tonumber(config.activationValue)
end

local function isGroupClaimed(groupName, ownerState)
    for i = 1, #patrolStates do
        local otherState = patrolStates[i].state
        if otherState ~= ownerState and otherState.groupName == groupName then
            return true
        end
    end
    return false
end

local function resolveClonedGroupName(config, state, preferredName)
    local preferredGroup = getActiveGroup(preferredName)
    if preferredGroup and not isGroupClaimed(preferredName, state) then
        return preferredName
    end

    if not config.clonePrefix then
        return nil
    end

    local ownGroups = coalition.getGroups(config.ownCoalition) or {}
    local prefixLength = string.len(config.clonePrefix)

    for _, group in pairs(ownGroups) do
        if group and group:isExist() then
            local groupName = group:getName()
            if groupName
                and string.sub(groupName, 1, prefixLength) == config.clonePrefix
                and not isGroupClaimed(groupName, state)
            then
                return groupName
            end
        end
    end

    return nil
end

-- ========================================
-- CLONADO
-- ========================================
local function scheduleCloneConfirmation(config, state)
    local function confirmClone()
        local clonedName = resolveClonedGroupName(config, state, state.pendingCloneName)

        state.isCloning = false
        state.pendingCloneName = nil

        if not clonedName then
            debugMessage(config, "No se encontro el grupo clonado", 10)
            return
        end

        if not isPatrolActivationAllowed(config) then
            local clonedGroup = getActiveGroup(clonedName)
            if clonedGroup then
                clonedGroup:destroy()
            end
            debugMessage(config, "Grupo clonado destruido por no cumplir activacion", 10)
            return
        end

        state.groupName = clonedName
        resetTransientState(state)

        debugMessage(config, "Grupo clonado: " .. clonedName)
    end

    timer.scheduleFunction(confirmClone, nil, timer.getTime() + CLONE_CONFIRM_DELAY_SECONDS)
end

local function attemptClone(config, state)
    if state.isCloning then
        return
    end

    if getActiveGroup(state.groupName) then
        return
    end

    if not isPatrolActivationAllowed(config) then
        return
    end

    if not mist or not mist.cloneGroup then
        if not state.reportedMissingMist then
            state.reportedMissingMist = true
            debugMessage(config, "MIST no esta disponible. No se puede clonar.", 10)
        end
        return
    end

    state.reportedMissingMist = false
    state.isCloning = true

    local templateName = config.templates[math.random(#config.templates)]
    local ok, clonedData = pcall(mist.cloneGroup, templateName, true)

    if not ok or not clonedData then
        state.isCloning = false
        state.pendingCloneName = nil
        debugMessage(config, "Error clonando plantilla: " .. tostring(templateName), 10)
        return
    end

    state.pendingCloneName = clonedData.groupName or clonedData.name
    scheduleCloneConfirmation(config, state)
end

-- ========================================
-- CONTROL DE VIDA / DESACTIVACION / STOP
-- ========================================
local function disablePatrolIfNeeded(config, state)
    if isPatrolActivationAllowed(config) then
        return false
    end

    local group = getActiveGroup(state.groupName)
    if group then
        group:destroy()
        debugMessage(
            config,
            "Patrulla desactivada por bandera " .. tostring(config.activationFlag) .. " distinta de " .. tostring(config.activationValue),
            10
        )
    end

    state.groupName = nil
    state.isCloning = false
    state.pendingCloneName = nil
    resetTransientState(state)

    return true
end

local function monitorStoppedGroup(config, state, group)
    local monitorUnit = findAliveUnit(group, config.monitorUnitIndex)
    if not monitorUnit then
        return false
    end

    local altitudeAGL = getAltitudeAGL(monitorUnit)
    local speed = getSpeedMetersPerSecond(monitorUnit)

    if altitudeAGL > state.maxAltitudeAGL then
        state.maxAltitudeAGL = altitudeAGL
    end

    if not state.stopMonitoringArmed and state.maxAltitudeAGL >= config.altitudeArmAGL then
        state.stopMonitoringArmed = true
        debugMessage(config, "Monitoreo de altitud activado")
    end

    if state.stopMonitoringArmed and speed < config.stopSpeed then
        state.groupName = nil
        resetTransientState(state)
        group:destroy()
        debugMessage(config, "Grupo destruido por estar detenido")
        return true
    end

    return false
end

local function updatePatrol(config, state)
    if disablePatrolIfNeeded(config, state) then
        return
    end

    local group = getActiveGroup(state.groupName)

    if not group then
        if state.groupName then
            debugMessage(config, "Grupo destruido o desaparecido. Reapareciendo...")
            state.groupName = nil
            resetTransientState(state)
        end

        attemptClone(config, state)
        return
    end

    local aliveUnit = findAliveUnit(group, config.monitorUnitIndex)
    if not aliveUnit then
        debugMessage(config, "Grupo sin unidades vivas. Reapareciendo...")
        state.groupName = nil
        resetTransientState(state)
        attemptClone(config, state)
        return
    end

    if monitorStoppedGroup(config, state, group) then
        return
    end
end

-- ========================================
-- HEARTBEAT
-- ========================================
local function heartbeat(_, now)
    for i = 1, #patrolStates do
        local config = patrolStates[i].config
        local state = patrolStates[i].state
        updatePatrol(config, state)
    end

    return now + HEARTBEAT_SECONDS
end

-- ========================================
-- INIT
-- ========================================
for i = 1, #PATROL_DEFINITIONS do
    local config = PATROL_DEFINITIONS[i]

    local state = {
        groupName = nil,
        isCloning = false,
        pendingCloneName = nil,
        reportedMissingMist = false,
        maxAltitudeAGL = 0,
        stopMonitoringArmed = false
    }

    patrolStates[#patrolStates + 1] = {
        config = config,
        state = state
    }

    attemptClone(config, state)
end

timer.scheduleFunction(heartbeat, nil, timer.getTime() + HEARTBEAT_SECONDS)