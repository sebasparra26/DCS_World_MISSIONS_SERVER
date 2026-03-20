-- ========================================
-- SISTEMA DE PATRULLAS IA - SYRIA
-- ========================================

local NM_TO_METERS = 1852
local HEARTBEAT_SECONDS = 10
local RESPAWN_DELAY_SECONDS = 10
local CLONE_CONFIRM_DELAY_SECONDS = 1
local ENGAGE_REFRESH_SECONDS = 30
local DEFAULT_DEBUG = false

local CATEGORY_SETS = {
    AIR_ONLY = {
        [Unit.Category.AIRPLANE] = true
    },
    AIR_AND_HELI = {
        [Unit.Category.AIRPLANE] = true,
        [Unit.Category.HELICOPTER] = true
    },
    ALL = {
        [Unit.Category.AIRPLANE] = true,
        [Unit.Category.HELICOPTER] = true,
        [Unit.Category.GROUND_UNIT] = true
    }
}

local PATROL_DEFINITIONS = {
    {
        name = "PATRULLA_USA_AIR",
        templates = { "Patrol_IA_USA_1", "Patrol_IA_USA_2", "Patrol_IA_USA_3", "Patrol_IA_USA_4" },
        clonePrefix = "USA air ",
        ownCoalition = coalition.side.BLUE,
        enemyCoalition = coalition.side.RED,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 70 * NM_TO_METERS,
        engageRange = 60 * NM_TO_METERS,
        altitudeArm = 200,
        stopSpeed = 2,
        allowedCategories = CATEGORY_SETS.AIR_AND_HELI,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_CANADA_AIR",
        templates = { "Patrol_IA_CANADA_1", "Patrol_IA_CANADA_2", "Patrol_IA_CANADA_3", "Patrol_IA_CANADA_4" },
        clonePrefix = "CANADA air ",
        ownCoalition = coalition.side.BLUE,
        enemyCoalition = coalition.side.RED,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 70 * NM_TO_METERS,
        engageRange = 60 * NM_TO_METERS,
        altitudeArm = 200,
        stopSpeed = 2,
        allowedCategories = CATEGORY_SETS.AIR_AND_HELI,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_ISRAEL_AIR",
        templates = { "Patrol_IA_ISRAEL_1", "Patrol_IA_ISRAEL_2" },
        clonePrefix = "ISRAEL air ",
        ownCoalition = coalition.side.BLUE,
        enemyCoalition = coalition.side.RED,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 70 * NM_TO_METERS,
        engageRange = 60 * NM_TO_METERS,
        altitudeArm = 200,
        stopSpeed = 2,
        allowedCategories = CATEGORY_SETS.AIR_AND_HELI,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_RUSSIA_AIR 01",
        templates = { "Patrol_IA_RUSSIA_1", "Patrol_IA_RUSSIA_2", "Patrol_IA_RUSSIA_3" },
        clonePrefix = "RUSSIA air ",
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 2,
        enemyUnitIndex = 2,
        monitorUnitIndex = 1,
        detectionRange = 70 * NM_TO_METERS,
        engageRange = 55 * NM_TO_METERS,
        altitudeArm = 200,
        stopSpeed = 2,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_BELARUS_AIR 01",
        templates = { "Patrol_IA_BELARUS_1", "Patrol_IA_BELARUS_2", "Patrol_IA_BELARUS_3", "Patrol_IA_BELARUS_4" },
        clonePrefix = "BELARUS air ",
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 2,
        enemyUnitIndex = 2,
        monitorUnitIndex = 1,
        detectionRange = 70 * NM_TO_METERS,
        engageRange = 55 * NM_TO_METERS,
        altitudeArm = 200,
        stopSpeed = 2,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_SYRIA_AIR 01",
        templates = { "Patrol_IA_SYRIA_1", "Patrol_IA_SYRIA_2", "Patrol_IA_SYRIA_3", "Patrol_IA_SYRIA_4" },
        clonePrefix = "SYRIA air ",
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 2,
        enemyUnitIndex = 2,
        monitorUnitIndex = 1,
        detectionRange = 80 * NM_TO_METERS,
        engageRange = 68 * NM_TO_METERS,
        altitudeArm = 200,
        stopSpeed = 2,
        allowedCategories = CATEGORY_SETS.AIR_ONLY,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_RUSSIA_HELI",
        templates = { "Patrol_IA_RUS_1", "Patrol_IA_RUS_2", "Patrol_IA_RUS_3" },
        clonePrefix = "RUSSIA hel ",
        ownCoalition = coalition.side.RED,
        enemyCoalition = coalition.side.BLUE,
        ownUnitIndex = 2,
        enemyUnitIndex = 2,
        monitorUnitIndex = 1,
        detectionRange = 20 * NM_TO_METERS,
        engageRange = 15 * NM_TO_METERS,
        altitudeArm = 80,
        stopSpeed = 0.01,
        allowedCategories = CATEGORY_SETS.ALL,
        debug = DEFAULT_DEBUG
    },
    {
        name = "PATRULLA_USA_HELIS_AIR",
        templates = { "Patrol_IA_hel_USA_1", "Patrol_IA_hel_USA_2", "Patrol_IA_hel_USA_3", "Patrol_IA_hel_USA_4" },
        clonePrefix = "USA hel ",
        ownCoalition = coalition.side.BLUE,
        enemyCoalition = coalition.side.RED,
        ownUnitIndex = 1,
        enemyUnitIndex = 1,
        monitorUnitIndex = 1,
        detectionRange = 60 * NM_TO_METERS,
        engageRange = 50 * NM_TO_METERS,
        altitudeArm = 20,
        stopSpeed = 0.1,
        allowedCategories = CATEGORY_SETS.ALL,
        debug = DEFAULT_DEBUG
    }
}

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

local function isTrackableUnit(unit, allowedCategories)
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
        if isTrackableUnit(preferredUnit, allowedCategories) then
            return preferredUnit
        end
    end

    local units = group:getUnits()
    if not units then
        return nil
    end

    for _, unit in ipairs(units) do
        if isTrackableUnit(unit, allowedCategories) then
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

local function findClosestEnemyGroup(config, ownUnit)
    local ownPoint = ownUnit:getPoint()
    local closestGroup = nil
    local closestDistance = config.detectionRange + 1
    local enemyGroups = coalition.getGroups(config.enemyCoalition) or {}

    for _, enemyGroup in pairs(enemyGroups) do
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

local function resetPatrolState(state)
    state.maxAltitudeAgl = 0
    state.stopMonitoringArmed = false
    state.lastEngagedGroupId = nil
    state.nextEngageRefreshAt = 0
end

local function scheduleCloneConfirmation(config, state)
    local function confirmClone(_, now)
        local clonedName = resolveClonedGroupName(config, state.pendingCloneName)
        state.isCloning = false
        state.pendingCloneName = nil

        if not clonedName then
            state.nextCloneAttemptAt = now + RESPAWN_DELAY_SECONDS
            debugMessage(config, "No se encontro el grupo clonado")
            return
        end

        state.groupName = clonedName
        resetPatrolState(state)
        debugMessage(config, "Grupo clonado: " .. clonedName)
    end

    timer.scheduleFunction(confirmClone, nil, timer.getTime() + CLONE_CONFIRM_DELAY_SECONDS)
end

local function attemptClone(config, state)
    if state.isCloning or getActiveGroup(state.groupName) then
        return
    end

    if timer.getTime() < state.nextCloneAttemptAt then
        return
    end

    if not mist or not mist.cloneGroup then
        if not state.reportedMissingMist then
            state.reportedMissingMist = true
            trigger.action.outText("[" .. config.name .. "] MIST no esta disponible. No se puede clonar la patrulla.", 10)
        end

        state.nextCloneAttemptAt = timer.getTime() + RESPAWN_DELAY_SECONDS
        return
    end

    state.reportedMissingMist = false
    state.isCloning = true

    local templateName = config.templates[math.random(#config.templates)]
    local ok, clonedData = pcall(mist.cloneGroup, templateName, true)

    if not ok then
        state.isCloning = false
        state.pendingCloneName = nil
        state.nextCloneAttemptAt = timer.getTime() + RESPAWN_DELAY_SECONDS
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

local function engageClosestEnemy(config, state, group, now)
    local ownUnit = findAliveUnit(group, config.ownUnitIndex)
    if not ownUnit then
        return
    end

    local enemyGroup, distance = findClosestEnemyGroup(config, ownUnit)
    if not enemyGroup then
        state.lastEngagedGroupId = nil
        state.nextEngageRefreshAt = 0
        debugMessage(config, "Zona despejada")
        return
    end

    if distance > config.engageRange then
        state.lastEngagedGroupId = nil
        state.nextEngageRefreshAt = 0
        debugMessage(config, "Amenaza detectada pero fuera de rango")
        return
    end

    local enemyGroupId = enemyGroup:getID()
    if state.lastEngagedGroupId == enemyGroupId and now < state.nextEngageRefreshAt then
        return
    end

    local controller = group:getController()
    if not controller then
        return
    end

    controller:pushTask({
        id = "EngageGroup",
        params = { groupId = enemyGroupId }
    })

    state.lastEngagedGroupId = enemyGroupId
    state.nextEngageRefreshAt = now + ENGAGE_REFRESH_SECONDS
    debugMessage(config, "Amenaza en rango. Enganchando")
end

local function monitorStoppedGroup(config, state, group, now)
    local monitorUnit = findAliveUnit(group, config.monitorUnitIndex)
    if not monitorUnit then
        return false
    end

    local point = monitorUnit:getPoint()
    local groundHeight = land.getHeight({ x = point.x, y = point.z })
    local altitudeAgl = point.y - groundHeight
    local speed = getSpeedMetersPerSecond(monitorUnit)

    state.maxAltitudeAgl = math.max(state.maxAltitudeAgl, altitudeAgl)

    debugMessage(
        config,
        "ALTITUD AGL: " .. math.floor(altitudeAgl) .. " m | VELOCIDAD: " .. string.format("%.1f", speed) .. " m/s",
        10
    )

    if not state.stopMonitoringArmed and state.maxAltitudeAgl >= config.altitudeArm then
        state.stopMonitoringArmed = true
        debugMessage(config, "Monitoreo de altitud activado")
    end

    if state.stopMonitoringArmed and speed < config.stopSpeed then
        local staleGroupName = state.groupName

        state.groupName = nil
        state.nextCloneAttemptAt = now + RESPAWN_DELAY_SECONDS
        resetPatrolState(state)

        local staleGroup = getActiveGroup(staleGroupName)
        if staleGroup then
            staleGroup:destroy()
        end

        debugMessage(config, "Grupo destruido por estar detenido")
        return true
    end

    return false
end

local function startPatrolManager(config)
    local state = {
        groupName = nil,
        isCloning = false,
        pendingCloneName = nil,
        nextCloneAttemptAt = 0,
        reportedMissingMist = false,
        maxAltitudeAgl = 0,
        stopMonitoringArmed = false,
        lastEngagedGroupId = nil,
        nextEngageRefreshAt = 0
    }

    local function heartbeat(_, now)
        local group = getActiveGroup(state.groupName)

        if not group then
            if state.groupName then
                debugMessage(config, "Grupo destruido. Reprogramando clon")
                state.groupName = nil
                state.nextCloneAttemptAt = now + RESPAWN_DELAY_SECONDS
                resetPatrolState(state)
            end

            attemptClone(config, state)
            return now + HEARTBEAT_SECONDS
        end

        engageClosestEnemy(config, state, group, now)
        monitorStoppedGroup(config, state, group, now)

        return now + HEARTBEAT_SECONDS
    end

    attemptClone(config, state)
    timer.scheduleFunction(heartbeat, nil, timer.getTime() + HEARTBEAT_SECONDS)
end

for _, config in ipairs(PATROL_DEFINITIONS) do
    startPatrolManager(config)
end
Exist() then
            local punto = unidad:getPoint()
            local altTerreno = land.getHeight({ x = punto.x, y = punto.z })
            local altAGL = punto.y - altTerreno
            altMax = math.max(altMax, altAGL)

            local v = unidad:getVelocity()
            local speed = math.sqrt(v.x^2 + v.y^2 + v.z^2)

            debug("ALTITUD AGL: " .. math.floor(altAGL) .. " m | VELOCIDAD: " .. string.format("%.1f", speed) .. " m/s", 10)

            if not monitoreoVelocidad and altMax >= 20 then
                monitoreoVelocidad = true
                debug("Monitoreo de altitud activado")
            end

            if monitoreoVelocidad and speed < 0.1 and not grupoYaSeDetuvo then
                grupoYaSeDetuvo = true
                debug("El avión se detuvo después de volar, será destruido")

                local nombreViejo = grupoClonadoActual
                grupoClonadoActual = nil

                timer.scheduleFunction(function()
                    local g = Group.getByName(nombreViejo)
                    if g and g:isExist() then
                        g:destroy()
                        debug("Grupo destruido por estar detenido")
                    end
                    clonarGrupo()
                end, {}, timer.getTime() + 10)
            end
        end

        return timer.getTime() + 10
    end, {}, timer.getTime() + 10)

    clonarGrupo()
end