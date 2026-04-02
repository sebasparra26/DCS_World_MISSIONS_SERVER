-- ========================================
-- SISTEMA DE PATRULLAS IA - MULTI SPAWN
-- Optimizado para bajo consumo
-- 0 = Neutral, 1 = Rojo, 2 = Azul (si usas flags tuyas)
-- ========================================

local NM_TO_METERS = 1852
local HEARTBEAT_SECONDS = 5
local CLONE_CONFIRM_DELAY_SECONDS = 1
local ENGAGE_REFRESH_SECONDS = 15

local CATEGORY_SETS = {
    AIR_ONLY = {
        [Unit.Category.AIRPLANE]   = true,
        [Unit.Category.HELICOPTER] = true
    },
    AIR_AND_GROUND = {
        [Unit.Category.AIRPLANE]   = true,
        [Unit.Category.HELICOPTER] = true,
        [Unit.Category.GROUND_UNIT] = true
    }
}

-- ========================================
-- CONFIGURACION DE PATRULLAS
-- Puedes duplicar bloques para crear mas spawns rojos
-- ========================================
local PATROL_DEFINITIONS = {
    {
        name = "PATRULLA_THIRDREICH_AIR_01",
        templates = { "Patrol_IA_TR_01", "Patrol_IA_TR_02", "Patrol_IA_TR_03" },
        clonePrefix = "THIRDREICH air ", -- solo como respaldo
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 70 * NM_TO_METERS,
        engageRange = 60 * NM_TO_METERS,
        altitudeArmAGL = 200,
        stopSpeed = 2,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        activationFlag = nil,
        activationValue = nil,
        debug = true
    },

    {
        name = "PATRULLA_THIRDREICH_AIR_02",
        templates = { "Patrol_IA_TR_04", "Patrol_IA_TR_05" },
        clonePrefix = "THIRDREICH air ", -- solo como respaldo
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 70 * NM_TO_METERS,
        engageRange = 60 * NM_TO_METERS,
        altitudeArmAGL = 200,
        stopSpeed = 2,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        activationFlag = nil,
        activationValue = nil,
        debug = true
    },

    -- Ejemplo con flag de activacion:
    -- {
    --     name = "PATRULLA_HUNGARY_AIR_01",
    --     templates = { "Patrol_IA_HUNGARY-1", "Patrol_IA_HUNGARY-2" },
    --     clonePrefix = "HUNGARY air ",
    --     ownCoalition = coalition.side.RED,
    --     enemyCoalition = coalition.side.BLUE,
    --     ownUnitIndex = 2,
    --     enemyUnitIndex = 2,
    --     monitorUnitIndex = 2,
    --     detectionRange = 80 * NM_TO_METERS,
    --     engageRange = 70 * NM_TO_METERS,
    --     altitudeArmAGL = 200,
    --     stopSpeed = 2,
    --     allowedCategories = CATEGORY_SETS.AIR_ONLY,
    --     activationFlag = 104,
    --     activationValue = 1, -- tu sistema: 1 = rojo
    --     debug = true
    -- }
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
        if preferredUnit and preferredUnit:isExist() and isAllowedUnit(preferredUnit, allowedCategories) then
            return preferredUnit
        end
    end

    local units = group:getUnits() or {}
    for i = 1, #units do
        local unit = units[i]
        if unit and unit:isExist() and isAllowedUnit(unit, allowedCategories) then
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
    local terrain = land.getHeight({ x = point.x, y = point.z })
    return point.y - terrain
end

local function resetTransientState(state)
    state.maxAltitudeAGL = 0
    state.stopMonitoringArmed = false
    state.lastEngagedGroupId = nil
    state.nextEngageRefreshAt = 0
    state.attackPermissionOpen = nil
    state.lastDetectionState = nil
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

local function setAttackPermission(state, group, allowAttack)
    if state.attackPermissionOpen == allowAttack then
        return
    end

    local controller = group and group:getController()
    if not controller then
        return
    end

    -- Confirmado por tus pruebas:
    -- false = permite enganchar
    -- true  = bloquea enganche automatico
    if allowAttack then
        controller:setOption(9, false)
    else
        controller:setOption(9, true)
    end

    state.attackPermissionOpen = allowAttack
end

local function setDetectionState(state, newState, config)
    if state.lastDetectionState == newState then
        return
    end

    state.lastDetectionState = newState

    if newState == "engaging" then
        debugMessage(config, "Amenaza en rango. Enganchando")
    elseif newState == "detected" then
        debugMessage(config, "Amenaza detectada pero fuera de rango")
    elseif newState == "clear" then
        debugMessage(config, "Zona despejada")
    end
end

local function findClosestEnemy(config, group, coalitionGroupsCache)
    local ownUnit = findAliveUnit(group, config.ownUnitIndex, nil)
    if not ownUnit then
        return nil, nil
    end

    local ownPos = ownUnit:getPoint()
    if not ownPos then
        return nil, nil
    end

    local enemyGroups = coalitionGroupsCache[config.enemyCoalition] or {}
    local closestGroup = nil
    local closestDistance = config.detectionRange

    for _, enemyGroup in pairs(enemyGroups) do
        if enemyGroup and enemyGroup:isExist() then
            local enemyUnit = findAliveUnit(enemyGroup, config.enemyUnitIndex, config.allowedCategories)
            if enemyUnit then
                local enemyPos = enemyUnit:getPoint()
                if enemyPos then
                    local dx = ownPos.x - enemyPos.x
                    local dz = ownPos.z - enemyPos.z
                    local dist = math.sqrt(dx * dx + dz * dz)

                    if dist < closestDistance then
                        closestDistance = dist
                        closestGroup = enemyGroup
                    end
                end
            end
        end
    end

    return closestGroup, closestDistance
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
    resetTransientState(state)
    return true
end

local function scheduleCloneConfirmation(config, state)
    local function confirmClone(_, now)
        local clonedName = resolveClonedGroupName(config, state, state.pendingCloneName)

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
            debugMessage(config, "Grupo clonado destruido por no cumplir la condicion de activacion")
            return
        end

        state.groupName = clonedName
        resetTransientState(state)

        local group = getActiveGroup(clonedName)
        if group then
            setAttackPermission(state, group, false)
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
            debugMessage(config, "MIST no esta disponible. No se puede clonar la patrulla.", 10)
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
        debugMessage(config, "Error clonando plantilla: " .. templateName)
        return
    end

    state.pendingCloneName = clonedData.groupName or clonedData.name
    scheduleCloneConfirmation(config, state)
end

local function engageClosestEnemy(config, state, group, now, coalitionGroupsCache)
    local enemyGroup, distance = findClosestEnemy(config, group, coalitionGroupsCache)

    if not enemyGroup then
        setAttackPermission(state, group, false)
        setDetectionState(state, "clear", config)
        return
    end

    if distance > config.engageRange then
        setAttackPermission(state, group, false)
        setDetectionState(state, "detected", config)
        return
    end

    local controller = group:getController()
    if not controller then
        return
    end

    local enemyGroupId = enemyGroup:getID()

    setAttackPermission(state, group, true)

    if state.lastEngagedGroupId == enemyGroupId and now < state.nextEngageRefreshAt then
        setDetectionState(state, "engaging", config)
        return
    end

    controller:pushTask({
        id = "EngageGroup",
        params = {
            groupId = enemyGroupId
        }
    })

    state.lastEngagedGroupId = enemyGroupId
    state.nextEngageRefreshAt = now + ENGAGE_REFRESH_SECONDS

    setDetectionState(state, "engaging", config)
end

local function monitorStoppedGroup(config, state, group)
    local monitorUnit = findAliveUnit(group, config.monitorUnitIndex, nil)
    if not monitorUnit then
        return false
    end

    local altitudeAGL = getAltitudeAGL(monitorUnit)
    local speed = getSpeedMetersPerSecond(monitorUnit)

    state.maxAltitudeAGL = math.max(state.maxAltitudeAGL, altitudeAGL)

    if not state.stopMonitoringArmed and state.maxAltitudeAGL >= config.altitudeArmAGL then
        state.stopMonitoringArmed = true
        debugMessage(config, "Monitoreo de altitud activado")
    end

    if state.stopMonitoringArmed and speed < config.stopSpeed then
        group:destroy()
        state.groupName = nil
        resetTransientState(state)
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
            resetTransientState(state)
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

    for i = 1, #patrolStates do
        local config = patrolStates[i].config
        local state = patrolStates[i].state

        if coalitionGroupsCache[config.enemyCoalition] == nil then
            coalitionGroupsCache[config.enemyCoalition] = coalition.getGroups(config.enemyCoalition) or {}
        end

        updatePatrol(config, state, now, coalitionGroupsCache)
    end

    return now + HEARTBEAT_SECONDS
end

for i = 1, #PATROL_DEFINITIONS do
    local config = PATROL_DEFINITIONS[i]
    local state = {
        groupName = nil,
        isCloning = false,
        pendingCloneName = nil,
        reportedMissingMist = false,
        maxAltitudeAGL = 0,
        stopMonitoringArmed = false,
        lastEngagedGroupId = nil,
        nextEngageRefreshAt = 0,
        attackPermissionOpen = nil,
        lastDetectionState = nil
    }

    patrolStates[#patrolStates + 1] = {
        config = config,
        state = state
    }

    attemptClone(config, state)
end

timer.scheduleFunction(heartbeat, nil, timer.getTime() + HEARTBEAT_SECONDS)