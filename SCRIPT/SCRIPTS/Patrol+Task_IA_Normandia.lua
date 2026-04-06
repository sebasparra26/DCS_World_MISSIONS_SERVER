-- ========================================
-- SISTEMA DE PATRULLAS IA
-- Corregido:
-- 0 = NEUTRAL
-- 1 = ROJO
-- 2 = AZUL
-- ========================================

local NM_TO_METERS = 1852
local HEARTBEAT_SECONDS = 10
local CLONE_CONFIRM_DELAY_SECONDS = 1
local ENGAGE_REFRESH_SECONDS = 30
local DEFAULT_ALTITUDE_ARM = 914.4
local DEFAULT_STOP_SPEED = 2
local DEFAULT_DEBUG = false

local CATEGORY_SETS = {
    AIR_ONLY = {
        [Unit.Category.AIRPLANE] = true
    },
    AIR_AND_GROUND = {
        [Unit.Category.AIRPLANE] = true,
        [Unit.Category.GROUND_UNIT] = true
    }
}

local PATROL_DEFINITIONS = {
    {
        name = "PATRULLA_USA",
        templates = { "Patrol_IA_USA_1", "Patrol_IA_USA_2", "Patrol_IA_USA_3", "Patrol_IA_USA_4" },
        clonePrefix = "USA air ",
        activationFlag = nil,
        activationValue = nil,
        ownCoalition = coalition.side.BLUE,
        enemyCoalition = coalition.side.RED,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 30 * NM_TO_METERS,
        engageRange = 20 * NM_TO_METERS,
        altitudeArm = DEFAULT_ALTITUDE_ARM,
        stopSpeed = DEFAULT_STOP_SPEED,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_FRANCE",
        templates = { "Patrol_IA_FRA_1", "Patrol_IA_FRA_2", "Patrol_IA_FRA_3" },
        clonePrefix = "FRANCE air ",
        activationFlag = nil,
        activationValue = nil,
        ownCoalition = coalition.side.BLUE,
        enemyCoalition = coalition.side.RED,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 30 * NM_TO_METERS,
        engageRange = 20 * NM_TO_METERS,
        altitudeArm = DEFAULT_ALTITUDE_ARM,
        stopSpeed = DEFAULT_STOP_SPEED,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_BULGARIA",
        templates = { "Patrol_IA_BULGARIA_01", "Patrol_IA_BULGARIA_02" },
        clonePrefix = "BULGARIA air ",
        activationFlag = 103,
        activationValue = 1, -- 0 = NEUTRAL, 1 = ROJO, 2 = AZUL
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 30 * NM_TO_METERS,
        engageRange = 20 * NM_TO_METERS,
        altitudeArm = DEFAULT_ALTITUDE_ARM,
        stopSpeed = DEFAULT_STOP_SPEED,
        allowedCategories = CATEGORY_SETS.AIR_AND_GROUND,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_CJTF_RED",
        templates = { "Patrol_IA_CJTF_RED_01", "Patrol_IA_CJTF_RED_02" },
        clonePrefix = "CJTF_RED air ",
        activationFlag = 107,
        activationValue = 1, -- 0 = NEUTRAL, 1 = ROJO, 2 = AZUL
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 30 * NM_TO_METERS,
        engageRange = 20 * NM_TO_METERS,
        altitudeArm = DEFAULT_ALTITUDE_ARM,
        stopSpeed = DEFAULT_STOP_SPEED,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_GERMAN",
        templates = { "Patrol_IA_TR_01", "Patrol_IA_TR_02", "Patrol_IA_TR_03" },
        clonePrefix = "THIRDREICH air ",
        activationFlag = 110,
        activationValue = 1, -- 0 = NEUTRAL, 1 = ROJO, 2 = AZUL
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 30 * NM_TO_METERS,
        engageRange = 20 * NM_TO_METERS,
        altitudeArm = DEFAULT_ALTITUDE_ARM,
        stopSpeed = DEFAULT_STOP_SPEED,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_GERMANY-01",
        templates = { "Patrol_IA_GERMANY-1", "Patrol_IA_GERMANY-2"},
        clonePrefix = "GERMANY air ",
        activationFlag = 111,
        activationValue = 1, -- 0 = NEUTRAL, 1 = ROJO, 2 = AZUL
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 30 * NM_TO_METERS,
        engageRange = 20 * NM_TO_METERS,
        altitudeArm = DEFAULT_ALTITUDE_ARM,
        stopSpeed = DEFAULT_STOP_SPEED,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_HUNGARY",
        templates = { "Patrol_IA_HUNGARY-1", "Patrol_IA_HUNGARY-2" },
        clonePrefix = "HUNGARY air ",
        activationFlag = 104,
        activationValue = 1, -- 0 = NEUTRAL, 1 = ROJO, 2 = AZUL
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 30 * NM_TO_METERS,
        engageRange = 20 * NM_TO_METERS,
        altitudeArm = DEFAULT_ALTITUDE_ARM,
        stopSpeed = DEFAULT_STOP_SPEED,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        debug = DEFAULT_DEBUG
    }
}

local patrolStates = {}

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

local function isAllowedUnit(unit, allowedCategories)
    if not unit or not unit:isExist() then
        return false
    end

    if not allowedCategories then
        return true
    end

    local desc = unit:getDesc()
    local category = desc and desc.category
    return allowedCategories[category] == true
end

local function findAliveUnit(group, preferredIndex, allowedCategories)
    if not group or not group:isExist() then
        return nil
    end

    if preferredIndex then
        local preferredUnit = group:getUnit(preferredIndex)
        if isAllowedUnit(preferredUnit, allowedCategories) then
            return preferredUnit
        end
    end

    local units = group:getUnits()
    if not units then
        return nil
    end

    for _, unit in ipairs(units) do
        if isAllowedUnit(unit, allowedCategories) then
            return unit
        end
    end

    return nil
end

local function distance2D(pointA, pointB)
    local dx = pointA.x - pointB.x
    local dz = pointA.z - pointB.z
    return math.sqrt(dx * dx + dz * dz)
end

local function getSpeedMetersPerSecond(unit)
    local velocity = unit:getVelocity()
    if not velocity then
        return 0
    end

    return math.sqrt(
        velocity.x * velocity.x +
        velocity.y * velocity.y +
        velocity.z * velocity.z
    )
end

local function resetPatrolState(state)
    state.maxAltitude = 0
    state.stopMonitoringArmed = false
    state.lastEngagedGroupId = nil
    state.nextEngageRefreshAt = 0
end

local function isPatrolActivationAllowed(config)
    if config.activationFlag == nil or config.activationValue == nil then
        return true
    end

    return trigger.misc.getUserFlag(config.activationFlag) == config.activationValue
end

local function setPatrolEngagementBlocked(group, blocked)
    if not group or not group:isExist() then
        return
    end

    local controller = group:getController()
    if not controller then
        return
    end

    pcall(function()
        controller:setOption(9, blocked)
    end)
end

local function disablePatrolIfNeeded(config, state)
    if isPatrolActivationAllowed(config) then
        return false
    end

    local group = getActiveGroup(state.groupName)
    if group then
        group:destroy()
        debugMessage(
            config,
            "Patrulla desactivada por bandera " .. config.activationFlag .. " distinta de " .. config.activationValue
        )
    end

    state.groupName = nil
    state.isCloning = false
    state.pendingCloneName = nil
    resetPatrolState(state)
    return true
end

local function resolveClonedGroupName(config, preferredName)
    local preferredGroup = getActiveGroup(preferredName)
    if preferredGroup then
        return preferredName
    end

    local ownGroups = coalition.getGroups(config.ownCoalition) or {}
    local prefixLength = string.len(config.clonePrefix)

    for _, group in pairs(ownGroups) do
        if group and group:isExist() then
            local groupName = group:getName()
            if groupName and string.sub(groupName, 1, prefixLength) == config.clonePrefix then
                return groupName
            end
        end
    end

    return nil
end

local function scheduleCloneConfirmation(config, state)
    local function confirmClone(_, now)
        local clonedName = resolveClonedGroupName(config, state.pendingCloneName)

        state.isCloning = false
        state.pendingCloneName = nil

        if not clonedName then
            debugMessage(config, "No se encontro el grupo clonado")
            return
        end

        if not isPatrolActivationAllowed(config) then
            local clonedGroup = getActiveGroup(clonedName)
            if clonedGroup then
                clonedGroup:destroy()
            end
            debugMessage(
                config,
                "Grupo clonado destruido por no cumplir bandera " .. config.activationFlag .. "=" .. config.activationValue
            )
            return
        end

        state.groupName = clonedName
        resetPatrolState(state)

        local clonedGroup = getActiveGroup(clonedName)
        if clonedGroup then
            setPatrolEngagementBlocked(clonedGroup, true)
        end

        debugMessage(config, "Grupo clonado: " .. clonedName)
    end

    timer.scheduleFunction(confirmClone, nil, timer.getTime() + CLONE_CONFIRM_DELAY_SECONDS)
end

local function attemptClone(config, state)
    if state.isCloning or getActiveGroup(state.groupName) then
        return
    end

    if not isPatrolActivationAllowed(config) then
        return
    end

    if not mist or not mist.cloneGroup then
        if not state.reportedMissingMist then
            state.reportedMissingMist = true
            trigger.action.outText("[" .. config.name .. "] MIST no esta disponible. No se puede clonar la patrulla.", 10)
        end
        return
    end

    state.reportedMissingMist = false
    state.isCloning = true

    local templateName = config.templates[math.random(#config.templates)]
    local ok, clonedData = pcall(mist.cloneGroup, templateName, true)

    if not ok then
        state.isCloning = false
        state.pendingCloneName = nil
        debugMessage(config, "Error clonando plantilla: " .. templateName)
        return
    end

    if type(clonedData) == "table" then
        state.pendingCloneName = clonedData.name
    elseif type(clonedData) == "string" then
        state.pendingCloneName = clonedData
    else
        state.pendingCloneName = nil
    end

    scheduleCloneConfirmation(config, state)
end

local function findClosestEnemyGroup(config, ownUnit, enemyGroups)
    local ownPoint = ownUnit:getPoint()
    local closestGroup = nil
    local closestDistance = config.detectionRange + 1

    for _, enemyGroup in pairs(enemyGroups or {}) do
        if enemyGroup and enemyGroup:isExist() then
            local enemyUnit = findAliveUnit(enemyGroup, config.enemyUnitIndex, config.allowedCategories)
            if enemyUnit then
                local distance = distance2D(ownPoint, enemyUnit:getPoint())
                if distance <= config.detectionRange and distance < closestDistance then
                    closestGroup = enemyGroup
                    closestDistance = distance
                end
            end
        end
    end

    return closestGroup, closestDistance
end

local function engageClosestEnemy(config, state, group, now, coalitionGroupsCache)
    local ownUnit = findAliveUnit(group, config.ownUnitIndex)
    if not ownUnit then
        return
    end

    local controller = group:getController()
    if not controller then
        return
    end

    local enemyGroups = coalitionGroupsCache[config.enemyCoalition] or {}
    local enemyGroup, distance = findClosestEnemyGroup(config, ownUnit, enemyGroups)

    if not enemyGroup then
        state.lastEngagedGroupId = nil
        state.nextEngageRefreshAt = 0
        setPatrolEngagementBlocked(group, true)
        debugMessage(config, "Zona despejada")
        return
    end

    if distance > config.engageRange then
        state.lastEngagedGroupId = nil
        state.nextEngageRefreshAt = 0
        setPatrolEngagementBlocked(group, true)
        debugMessage(config, "Amenaza detectada pero fuera de rango")
        return
    end

    local enemyGroupId = enemyGroup:getID()
    if state.lastEngagedGroupId == enemyGroupId and now < state.nextEngageRefreshAt then
        return
    end

    setPatrolEngagementBlocked(group, false)

    controller:pushTask({
        id = "EngageGroup",
        params = { groupId = enemyGroupId }
    })

    state.lastEngagedGroupId = enemyGroupId
    state.nextEngageRefreshAt = now + ENGAGE_REFRESH_SECONDS
    debugMessage(config, "Amenaza en rango. Enganchando")
end

local function monitorStoppedGroup(config, state, group)
    local monitorUnit = findAliveUnit(group, config.monitorUnitIndex)
    if not monitorUnit then
        return false
    end

    local altitude = monitorUnit:getPoint().y
    local speed = getSpeedMetersPerSecond(monitorUnit)

    state.maxAltitude = math.max(state.maxAltitude, altitude)

    debugMessage(
        config,
        "ALTITUD: " .. math.floor(altitude) .. " m | VELOCIDAD: " .. string.format("%.1f", speed) .. " m/s",
        10
    )

    if not state.stopMonitoringArmed and state.maxAltitude >= config.altitudeArm then
        state.stopMonitoringArmed = true
        debugMessage(config, "Monitoreo de altitud activado")
    end

    if state.stopMonitoringArmed and speed < config.stopSpeed then
        group:destroy()
        state.groupName = nil
        resetPatrolState(state)
        debugMessage(config, "Grupo destruido por estar detenido")
        return true
    end

    return false
end

local function updatePatrol(config, state, now, coalitionGroupsCache)
    if disablePatrolIfNeeded(config, state) then
        return
    end

    local group = getActiveGroup(state.groupName)

    if not group then
        if state.groupName then
            debugMessage(config, "Grupo destruido. Clonando...")
            state.groupName = nil
            resetPatrolState(state)
        end

        attemptClone(config, state)
        return
    end

    engageClosestEnemy(config, state, group, now, coalitionGroupsCache)

    if monitorStoppedGroup(config, state, group) then
        attemptClone(config, state)
    end
end

local function heartbeat(_, now)
    local coalitionGroupsCache = {}

    for _, stateData in ipairs(patrolStates) do
        local config = stateData.config
        if coalitionGroupsCache[config.enemyCoalition] == nil then
            coalitionGroupsCache[config.enemyCoalition] = coalition.getGroups(config.enemyCoalition) or {}
        end

        updatePatrol(config, stateData.state, now, coalitionGroupsCache)
    end

    return now + HEARTBEAT_SECONDS
end

for _, config in ipairs(PATROL_DEFINITIONS) do
    local state = {
        groupName = nil,
        isCloning = false,
        pendingCloneName = nil,
        reportedMissingMist = false,
        maxAltitude = 0,
        stopMonitoringArmed = false,
        lastEngagedGroupId = nil,
        nextEngageRefreshAt = 0
    }

    patrolStates[#patrolStates + 1] = {
        config = config,
        state = state
    }

    attemptClone(config, state)
end

timer.scheduleFunction(heartbeat, nil, timer.getTime() + HEARTBEAT_SECONDS)