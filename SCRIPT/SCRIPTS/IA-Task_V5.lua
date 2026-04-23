if not mist or not mist.cloneGroup or not mist.getGroupRoute or not mist.goRoute then
    trigger.action.outText("ERROR: MIST no esta cargado o faltan funciones requeridas.", 15)
    return
end

----------------------------------------------------------------
-- AJUSTES GENERALES
----------------------------------------------------------------
local DEBUG = false
local AUTO_REMOVE_MARK = true
local ASSIGN_DELAY = 1
local HEARTBEAT_SECONDS = 5
local MENU_NAME = "Tasking IA"

local STOP_SPEED_THRESHOLD = 1
local DESPAWN_AFTER_STOP_SECONDS = 30
local ARM_STOP_MONITOR_AT_AGL = 10

local RTB_CRUISE_ALT = 9144      -- Angels 30 en metros
local RTB_CRUISE_SPEED = 400     -- m/s
local RTB_CLIMB_OFFSET_NM = 150   -- distancia del waypoint de subida hacia casa

----------------------------------------------------------------
-- PERFILES DE MISION
----------------------------------------------------------------
local TASK_PROFILES = {
    cap = {
        displayName = "CAP",
        mode = "area_engage",
        templates = { "CAP_A", "CAP_B", "CAP_C" },
        maxActive = 1,
        cooldownSeconds = 1 * 60,
        orbitAltitude = 7000,
        orbitSpeed = 300,
        zoneRadius = 35000,
        ingressOffsetNm = 12,
        targetTypes = { "Air" }
    },

    sead = {
        displayName = "SEAD",
        mode = "attack_group_once",
        templates = {"SEAD_E"},
        maxActive = 6,
        cooldownSeconds = 1 * 60,
        ingressAltitude = 10000,
        ingressSpeed = 450,
        zoneRadius = 30000,
        ingressOffsetNm = 50,
        egressOffsetNm = 10,
        targetTypes = { "Air Defence", "SAM related", "AAA", "EWR" },
        expend = "All",
        attackQty = 1,
        attackQtyLimit = true,
        altitudeEnabled = true,
        rtbAfterAttack = true,
        attackTriggerMeters = 12000
    },

    cas = {
        displayName = "CAS",
        mode = "area_engage",
        templates = { "CAS_A", "CAS_B" },
        maxActive = 1,
        cooldownSeconds = 1 * 60,
        orbitAltitude = 9000,
        orbitSpeed = 300,
        zoneRadius = 18000,
        ingressOffsetNm = 8,
        targetTypes = { "Ground Units" },
        rtbAfterTaskSeconds = 10 * 60
    },

    strike = {
        displayName = "STRIKE",
        mode = "bomb_point",
        templates = { "STRIKE_B" },
        maxActive = 4,
        cooldownSeconds = 20 * 60,
        ingressAltitude = 11000,
        ingressSpeed = 500,
        ingressOffsetNm = 50,
        egressOffsetNm = 10,
        attackQty = 1,
        attackQtyLimit = true,
        groupAttack = true,
        expend = "All",
        altitudeEnabled = true,
        rtbAfterAttack = true
    },

    naval = {
        displayName = "NAVAL",
        mode = "area_engage",
        templates = { "NAVAL_A", "NAVAL_B" },
        maxActive = 1,
        cooldownSeconds = 5 * 60,
        orbitAltitude = 7000,
        orbitSpeed = 300,
        zoneRadius = 30000,
        ingressOffsetNm = 10,
        targetTypes = { "Ships" }
    },

    escort = {
        displayName = "ESCORT",
        mode = "escort_group",
        templates = { "ESCORT_A", "ESCORT_B" },
        maxActive = 2,
        cooldownSeconds = 1 * 60,
        engagementDistMax = 15000,
        escortOffset = { x = 200, y = 0, z = -100 },
        targetTypes = { "Air" },
        defaultEscortGroup = nil
    }
}

----------------------------------------------------------------
-- ALIASES
----------------------------------------------------------------
local COMMAND_ALIASES = {
    { alias = "anti ship", key = "naval"  },
    { alias = "antiship",  key = "naval"  },
    { alias = "naval",     key = "naval"  },
    { alias = "escort",    key = "escort" },
    { alias = "strike",    key = "strike" },
    { alias = "sead",      key = "sead"   },
    { alias = "cas",       key = "cas"    },
    { alias = "cap",       key = "cap"    }
}

----------------------------------------------------------------
-- ESTADO
----------------------------------------------------------------
local activeTasks = {}
local processedMarks = {}
local nextTaskId = 1

local categoryState = {}
for key, profile in pairs(TASK_PROFILES) do
    categoryState[key] = {
        activeTaskIds = {},
        nextAvailableAt = 0,
        maxActive = profile.maxActive or 1
    }
end

----------------------------------------------------------------
-- UTILIDADES
----------------------------------------------------------------
local function debugMsg(text, duration)
    if DEBUG then
        trigger.action.outText("[Tasking IA] " .. text, duration or 5)
    end
end

local function trim(s)
    if not s then return "" end
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function normalizeSpaces(s)
    return trim((s or ""):gsub("%s+", " "))
end

local function deepCopy(tbl)
    if mist and mist.utils and mist.utils.deepCopy then
        return mist.utils.deepCopy(tbl)
    end
    if type(tbl) ~= "table" then
        return tbl
    end
    local out = {}
    for k, v in pairs(tbl) do
        out[k] = deepCopy(v)
    end
    return out
end

local function makeVec2(point)
    if not point then return nil end
    if point.z then
        return { x = point.x, y = point.z }
    end
    return { x = point.x, y = point.y }
end

local function nmToMeters(nm)
    return (tonumber(nm) or 0) * 1852
end

local function getAliveLeadUnit(group)
    if not group or not group:isExist() then
        return nil
    end

    local units = group:getUnits() or {}
    for i = 1, #units do
        local unit = units[i]
        if unit and unit:isExist() and unit:getLife() > 1 then
            return unit
        end
    end

    return nil
end

local function get2DDistance(a, b)
    if not a or not b then
        return 999999999
    end

    local ax = a.x
    local ay = a.z or a.y
    local bx = b.x
    local by = b.z or b.y

    local dx = ax - bx
    local dy = ay - by
    return math.sqrt(dx * dx + dy * dy)
end

local function getSpeedMps(unit)
    if not unit or not unit:isExist() then
        return 0
    end

    local v = unit:getVelocity()
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

local function getAGL(unit)
    if not unit or not unit:isExist() then
        return 0
    end

    local p = unit:getPoint()
    local ground = land.getHeight({ x = p.x, y = p.z })
    return p.y - ground
end

local function extractCloneName(clonedData)
    if type(clonedData) == "string" then
        return clonedData
    elseif type(clonedData) == "table" then
        return clonedData.groupName or clonedData.name
    end
    return nil
end

local function resolveMarkPoint(event)
    if event and event.pos then
        return {
            x = event.pos.x,
            y = event.pos.y,
            z = event.pos.z
        }
    end

    if mist
        and mist.DBs
        and mist.DBs.markList
        and event
        and event.idx
        and mist.DBs.markList[event.idx]
        and mist.DBs.markList[event.idx].pos then

        local p = mist.DBs.markList[event.idx].pos
        return {
            x = p.x,
            y = p.y or 0,
            z = p.z or p.y
        }
    end

    return nil
end

local function parseCommand(text)
    local raw = normalizeSpaces(text)
    local rawLower = string.lower(raw)

    for i = 1, #COMMAND_ALIASES do
        local alias = COMMAND_ALIASES[i].alias
        local key = COMMAND_ALIASES[i].key

        if rawLower == alias then
            return key, ""
        end

        if rawLower:sub(1, #alias + 1) == alias .. " " then
            return key, trim(raw:sub(#alias + 2))
        end
    end

    return nil, nil
end

local function getTaskIdsSorted()
    local ids = {}
    for id, _ in pairs(activeTasks) do
        ids[#ids + 1] = id
    end
    table.sort(ids)
    return ids
end

local function getRandomTemplate(profile)
    if not profile.templates or #profile.templates == 0 then
        return nil
    end
    return profile.templates[math.random(1, #profile.templates)]
end

local function getSecondsRemaining(targetTime)
    local now = timer.getAbsTime()
    local remaining = math.floor((targetTime or 0) - now)
    if remaining < 0 then remaining = 0 end
    return remaining
end

local function formatTimeMMSS(totalSeconds)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

local function buildSignature(keyword, point, arg)
    return table.concat({
        keyword or "",
        tostring(math.floor(point.x or 0)),
        tostring(math.floor(point.z or point.y or 0)),
        arg or ""
    }, "|")
end

local function unitHasAnyAttribute(unit, attrs)
    if not unit or not unit:isExist() or not attrs then
        return false
    end

    for i = 1, #attrs do
        local attr = attrs[i]
        local ok, has = pcall(function()
            return unit:hasAttribute(attr)
        end)
        if ok and has then
            return true
        end
    end

    return false
end

local function groupExistsByName(groupName)
    if not groupName or groupName == "" then
        return nil
    end

    local grp = Group.getByName(groupName)
    if not grp then
        return nil
    end

    local ok, exists = pcall(function()
        return grp:isExist()
    end)

    if ok and exists then
        return grp
    end
    return nil
end

----------------------------------------------------------------
-- CONTROL DE CATEGORIAS
----------------------------------------------------------------
local function removeDeadTaskIdsFromCategory(categoryKey)
    local cat = categoryState[categoryKey]
    if not cat then return end

    local stillAlive = {}
    for i = 1, #cat.activeTaskIds do
        local taskId = cat.activeTaskIds[i]
        local rec = activeTasks[taskId]
        local g = rec and groupExistsByName(rec.cloneGroupName) or nil

        if rec and g and not rec.finished then
            stillAlive[#stillAlive + 1] = taskId
        end
    end

    cat.activeTaskIds = stillAlive
end

local function canUseCategory(categoryKey)
    local cat = categoryState[categoryKey]
    local profile = TASK_PROFILES[categoryKey]

    if not cat or not profile then
        return false, "Categoria no registrada."
    end

    removeDeadTaskIdsFromCategory(categoryKey)

    local activeCount = #cat.activeTaskIds
    local maxActive = profile.maxActive or 1

    if activeCount >= maxActive then
        return false, "La categoria '" .. categoryKey .. "' ya alcanzo su limite activo (" .. tostring(maxActive) .. ")."
    end

    if activeCount == 0 then
        local now = timer.getAbsTime()
        if now < (cat.nextAvailableAt or 0) then
            local remaining = getSecondsRemaining(cat.nextAvailableAt)
            return false, "La categoria '" .. categoryKey .. "' esta en cooldown. Falta: " .. formatTimeMMSS(remaining)
        end
    end

    return true, nil
end

local function lockCategoryOnLaunch(categoryKey, taskId)
    local cat = categoryState[categoryKey]
    local profile = TASK_PROFILES[categoryKey]
    if not cat or not profile then return end

    cat.activeTaskIds[#cat.activeTaskIds + 1] = taskId
    cat.nextAvailableAt = timer.getAbsTime() + (profile.cooldownSeconds or 20 * 60)
end

local function releaseCategoryIfTaskFinished(categoryKey, taskId)
    local cat = categoryState[categoryKey]
    if not cat then return end

    local newList = {}
    for i = 1, #cat.activeTaskIds do
        if cat.activeTaskIds[i] ~= taskId then
            newList[#newList + 1] = cat.activeTaskIds[i]
        end
    end
    cat.activeTaskIds = newList
end

----------------------------------------------------------------
-- TAREAS
----------------------------------------------------------------
local function buildEmptyComboTask()
    return {
        id = "ComboTask",
        params = {
            tasks = {}
        }
    }
end

local function buildControlledTask(taskToRun, durationSeconds)
    return {
        id = "ControlledTask",
        params = {
            task = taskToRun,
            stopCondition = {
                duration = durationSeconds
            }
        }
    }
end

local function buildLandWaypointFromStart(wpStart)
    local wpLand = {
        type = "Land",
        action = "Landing",
        x = wpStart.x,
        y = wpStart.y,
        alt = wpStart.alt or 0,
        alt_type = wpStart.alt_type or "BARO",
        speed = wpStart.speed or 140,
        speed_locked = true,
        ETA = 0,
        ETA_locked = false,
        name = "RTB",
        task = buildEmptyComboTask()
    }

    if wpStart.airdromeId then
        wpLand.airdromeId = wpStart.airdromeId
    end

    if wpStart.helipadId then
        wpLand.helipadId = wpStart.helipadId
    end

    if wpStart.linkUnit then
        wpLand.linkUnit = wpStart.linkUnit
    end

    return wpLand
end

local function buildPointTowardHome(fromPoint, homeWp, offsetNm)
    local fx = fromPoint.x
    local fy = fromPoint.z

    local hx = homeWp.x
    local hy = homeWp.y

    local dx = hx - fx
    local dy = hy - fy
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < 1 then
        return hx, hy
    end

    local offsetMeters = nmToMeters(offsetNm or 0)
    if offsetMeters <= 0 then
        offsetMeters = nmToMeters(25)
    end

    if offsetMeters > dist * 0.8 then
        offsetMeters = dist * 0.8
    end

    local nx = dx / dist
    local ny = dy / dist

    return fx + (nx * offsetMeters), fy + (ny * offsetMeters)
end

local function buildRTBClimbWaypoint(fromPoint, wpStart)
    local cx, cy = buildPointTowardHome(fromPoint, wpStart, RTB_CLIMB_OFFSET_NM)

    return {
        type = "Turning Point",
        action = "Turning Point",
        x = cx,
        y = cy,
        alt = RTB_CRUISE_ALT,
        alt_type = "BARO",
        speed = RTB_CRUISE_SPEED,
        speed_locked = true,
        ETA = 0,
        ETA_locked = false,
        name = "RTB CLIMB",
        task = buildEmptyComboTask()
    }
end

local function buildAreaComboTask(profile, pointVec2)
    return {
        id = "ComboTask",
        params = {
            tasks = {
                [1] = {
                    id = "Orbit",
                    params = {
                        pattern = "Circle",
                        point = pointVec2,
                        speed = profile.orbitSpeed,
                        altitude = profile.orbitAltitude
                    }
                },
                [2] = {
                    id = "EngageTargetsInZone",
                    params = {
                        point = pointVec2,
                        zoneRadius = profile.zoneRadius,
                        targetTypes = deepCopy(profile.targetTypes),
                        priority = 0
                    }
                }
            }
        }
    }
end

local function buildBombPointComboTask(profile, pointVec2)
    return {
        id = "ComboTask",
        params = {
            tasks = {
                [1] = {
                    id = "Bombing",
                    params = {
                        point = pointVec2,
                        expend = profile.expend or "All",
                        attackQty = profile.attackQty or 1,
                        attackQtyLimit = (profile.attackQtyLimit ~= false),
                        groupAttack = (profile.groupAttack ~= false),
                        altitudeEnabled = (profile.altitudeEnabled == true),
                        altitude = profile.ingressAltitude or profile.orbitAltitude or 2000
                    }
                }
            }
        }
    }
end

local function buildEscortTask(profile, targetGroup)
    return {
        id = "Escort",
        params = {
            groupId = targetGroup:getID(),
            pos = deepCopy(profile.escortOffset or { x = 200, y = 0, z = -100 }),
            lastWptIndexFlag = false,
            engagementDistMax = profile.engagementDistMax or 15000,
            targetTypes = deepCopy(profile.targetTypes or { "Air" })
        }
    }
end

local function buildAttackGroupTask(targetGroup, profile)
    return {
        id = "AttackGroup",
        params = {
            groupId = targetGroup:getID(),
            expend = profile and profile.expend or nil,
            attackQtyLimit = profile and profile.attackQtyLimit or false,
            attackQty = profile and profile.attackQty or nil,
            altitudeEnabled = profile and profile.altitudeEnabled or false,
            altitude = profile and (profile.ingressAltitude or profile.orbitAltitude) or nil
        }
    }
end

local function buildIngressPoint(startWp, targetPoint, offsetNm)
    local sx = startWp.x
    local sy = startWp.y
    local tx = targetPoint.x
    local ty = targetPoint.z

    local dx = tx - sx
    local dy = ty - sy
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < 1 then
        return tx, ty
    end

    local offsetMeters = nmToMeters(offsetNm or 0)
    if offsetMeters <= 0 then
        return tx, ty
    end

    if offsetMeters > dist * 0.6 then
        offsetMeters = dist * 0.6
    end

    local nx = dx / dist
    local ny = dy / dist

    return tx - (nx * offsetMeters), ty - (ny * offsetMeters)
end

local function buildSignedEgressPoint(ipX, ipY, targetPoint, offsetNm)
    local tx = targetPoint.x
    local ty = targetPoint.z

    local dx = tx - ipX
    local dy = ty - ipY
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < 1 then
        return tx, ty
    end

    local offsetMeters = nmToMeters(offsetNm or 0)
    local nx = dx / dist
    local ny = dy / dist

    return tx + (nx * offsetMeters), ty + (ny * offsetMeters)
end

local function buildWaypointTaskForProfile(profile, pointVec2)
    local baseTask

    if profile.mode == "area_engage" then
        baseTask = buildAreaComboTask(profile, pointVec2)

        if profile.rtbAfterTaskSeconds and profile.rtbAfterTaskSeconds > 0 then
            return buildControlledTask(baseTask, profile.rtbAfterTaskSeconds)
        end

        return baseTask
    end

    return buildEmptyComboTask()
end

local function buildRouteFromTemplate(templateName, profile, markPoint)
    local templateRoute = mist.getGroupRoute(templateName, true)
    if not templateRoute or not templateRoute[1] then
        return nil, "La plantilla no tiene ruta definida en el editor: " .. templateName
    end

    if not templateRoute[2] then
        return nil, "La plantilla necesita al menos WP1 despegue + WP2 operativo: " .. templateName
    end

    local wp1 = deepCopy(templateRoute[1])
    local wpBase = deepCopy(templateRoute[2])

    local pointVec2 = makeVec2(markPoint)

    local ipX, ipY = buildIngressPoint(wp1, markPoint, profile.ingressOffsetNm or 0)
    local egX, egY = buildSignedEgressPoint(ipX, ipY, markPoint, profile.egressOffsetNm or 0)

    local wpIP = deepCopy(wpBase)
    wpIP.x = ipX
    wpIP.y = ipY
    wpIP.name = "IP - " .. profile.displayName
    wpIP.alt = profile.ingressAltitude or profile.orbitAltitude or wpIP.alt or 2000
    wpIP.alt_type = wpIP.alt_type or wp1.alt_type or "BARO"
    wpIP.speed = profile.ingressSpeed or profile.orbitSpeed or wpIP.speed or 180
    wpIP.speed_locked = true
    wpIP.ETA_locked = false
    wpIP.task = buildEmptyComboTask()

    local wpTarget = deepCopy(wpBase)
    wpTarget.x = markPoint.x
    wpTarget.y = markPoint.z
    wpTarget.name = profile.displayName
    wpTarget.alt = profile.orbitAltitude or profile.ingressAltitude or wpTarget.alt or 2000
    wpTarget.alt_type = wpTarget.alt_type or wp1.alt_type or "BARO"
    wpTarget.speed = profile.orbitSpeed or profile.ingressSpeed or wpTarget.speed or 180
    wpTarget.speed_locked = true
    wpTarget.ETA_locked = false
    wpTarget.task = buildEmptyComboTask()

    local wpEgress = deepCopy(wpBase)
    wpEgress.x = egX
    wpEgress.y = egY
    wpEgress.name = "EGRESS - " .. profile.displayName
    wpEgress.alt = profile.ingressAltitude or profile.orbitAltitude or wpEgress.alt or 2000
    wpEgress.alt_type = wpEgress.alt_type or wp1.alt_type or "BARO"
    wpEgress.speed = profile.ingressSpeed or profile.orbitSpeed or wpEgress.speed or 180
    wpEgress.speed_locked = true
    wpEgress.ETA_locked = false
    wpEgress.task = buildEmptyComboTask()

    local route = {
        [1] = wp1
    }

    if profile.mode == "bomb_point" then
        wpIP.task = buildBombPointComboTask(profile, pointVec2)

        route[2] = wpIP
        route[3] = wpEgress

        if profile.rtbAfterAttack then
            if not wp1.airdromeId and not wp1.helipadId and not wp1.linkUnit then
                return nil, "La plantilla no tiene referencia valida para regresar a casa (airdromeId/helipadId/linkUnit): " .. templateName
            end

            route[4] = buildRTBClimbWaypoint({ x = egX, z = egY }, wp1)
            route[5] = buildLandWaypointFromStart(wp1)
        end

    elseif profile.mode == "attack_group_once" then
        route[2] = wpIP
        route[3] = wpTarget
        route[4] = wpEgress

        if profile.rtbAfterAttack then
            if not wp1.airdromeId and not wp1.helipadId and not wp1.linkUnit then
                return nil, "La plantilla no tiene referencia valida para regresar a casa (airdromeId/helipadId/linkUnit): " .. templateName
            end

            route[5] = buildRTBClimbWaypoint({ x = egX, z = egY }, wp1)
            route[6] = buildLandWaypointFromStart(wp1)
        end

    elseif profile.mode == "area_engage" then
        wpTarget.task = buildWaypointTaskForProfile(profile, pointVec2)

        route[2] = wpIP
        route[3] = wpTarget

        if profile.rtbAfterTaskSeconds and profile.rtbAfterTaskSeconds > 0 then
            if not wp1.airdromeId and not wp1.helipadId and not wp1.linkUnit then
                return nil, "La plantilla no tiene referencia valida para regresar a casa (airdromeId/helipadId/linkUnit): " .. templateName
            end

            route[4] = buildRTBClimbWaypoint({ x = markPoint.x, z = markPoint.z }, wp1)
            route[5] = buildLandWaypointFromStart(wp1)
        end
    end

    return route, {
        ipPoint = { x = ipX, z = ipY },
        targetPoint = { x = markPoint.x, z = markPoint.z },
        egressPoint = { x = egX, z = egY }
    }
end

local function getEnemyCoalitionId(groupObject)
    if not groupObject or not groupObject:isExist() then
        return nil
    end

    local ownCoalition = groupObject:getCoalition()

    if ownCoalition == coalition.side.BLUE then
        return coalition.side.RED
    elseif ownCoalition == coalition.side.RED then
        return coalition.side.BLUE
    end

    return nil
end

local function getNearestEnemyGroundGroupInRadius(fromGroup, centerPoint, radius)
    local enemyCoalition = getEnemyCoalitionId(fromGroup)
    if not enemyCoalition then
        return nil, nil
    end

    local enemyGroups = coalition.getGroups(enemyCoalition, Group.Category.GROUND) or {}
    local nearestGroup = nil
    local nearestDist = nil

    for i = 1, #enemyGroups do
        local g = enemyGroups[i]
        if g and g:isExist() and g:getSize() > 0 then
            local u = getAliveLeadUnit(g)
            if u then
                local p = u:getPoint()
                local dx = p.x - centerPoint.x
                local dz = p.z - centerPoint.z
                local dist = math.sqrt(dx * dx + dz * dz)

                if dist <= radius then
                    if not nearestDist or dist < nearestDist then
                        nearestDist = dist
                        nearestGroup = g
                    end
                end
            end
        end
    end

    return nearestGroup, nearestDist
end

local function getNearestEnemyAirGroupInRadius(fromGroup, centerPoint, radius)
    local enemyCoalition = getEnemyCoalitionId(fromGroup)
    if not enemyCoalition then
        return nil, nil
    end

    local nearestGroup = nil
    local nearestDist = nil

    local function scanCategory(cat)
        local enemyGroups = coalition.getGroups(enemyCoalition, cat) or {}
        for i = 1, #enemyGroups do
            local g = enemyGroups[i]
            if g and g:isExist() and g:getSize() > 0 then
                local u = getAliveLeadUnit(g)
                if u then
                    local p = u:getPoint()
                    local dx = p.x - centerPoint.x
                    local dz = p.z - centerPoint.z
                    local dist = math.sqrt(dx * dx + dz * dz)

                    if dist <= radius then
                        if not nearestDist or dist < nearestDist then
                            nearestDist = dist
                            nearestGroup = g
                        end
                    end
                end
            end
        end
    end

    scanCategory(Group.Category.AIRPLANE)
    scanCategory(Group.Category.HELICOPTER)

    return nearestGroup, nearestDist
end

local function getNearestEnemyGroundGroupByAttributesInRadius(fromGroup, centerPoint, radius, attrs)
    local enemyCoalition = getEnemyCoalitionId(fromGroup)
    if not enemyCoalition then
        return nil, nil
    end

    local enemyGroups = coalition.getGroups(enemyCoalition, Group.Category.GROUND) or {}
    local nearestGroup = nil
    local nearestDist = nil

    for i = 1, #enemyGroups do
        local g = enemyGroups[i]
        if g and g:isExist() and g:getSize() > 0 then
            local u = getAliveLeadUnit(g)
            if u and unitHasAnyAttribute(u, attrs) then
                local p = u:getPoint()
                local dx = p.x - centerPoint.x
                local dz = p.z - centerPoint.z
                local dist = math.sqrt(dx * dx + dz * dz)

                if dist <= radius then
                    if not nearestDist or dist < nearestDist then
                        nearestDist = dist
                        nearestGroup = g
                    end
                end
            end
        end
    end

    return nearestGroup, nearestDist
end

local function getNearestEnemyShipGroupInRadius(fromGroup, centerPoint, radius, attrs)
    local enemyCoalition = getEnemyCoalitionId(fromGroup)
    if not enemyCoalition then
        return nil, nil
    end

    local shipCategory = Group.Category.SHIP or 3
    local enemyGroups = coalition.getGroups(enemyCoalition, shipCategory) or {}
    local nearestGroup = nil
    local nearestDist = nil

    for i = 1, #enemyGroups do
        local g = enemyGroups[i]
        if g and g:isExist() and g:getSize() > 0 then
            local u = getAliveLeadUnit(g)
            if u and unitHasAnyAttribute(u, attrs) then
                local p = u:getPoint()
                local dx = p.x - centerPoint.x
                local dz = p.z - centerPoint.z
                local dist = math.sqrt(dx * dx + dz * dz)

                if dist <= radius then
                    if not nearestDist or dist < nearestDist then
                        nearestDist = dist
                        nearestGroup = g
                    end
                end
            end
        end
    end

    return nearestGroup, nearestDist
end

----------------------------------------------------------------
-- CREACION Y ASIGNACION
----------------------------------------------------------------
local function assignTaskToClone(taskId)
    local rec = activeTasks[taskId]
    if not rec then return end

    local group = groupExistsByName(rec.cloneGroupName)
    if not group then
        rec.state = "ERROR: grupo clonado no existe"
        rec.finished = true
        releaseCategoryIfTaskFinished(rec.keyword, rec.id)
        return
    end

    local controller = group:getController()
    if not controller then
        rec.state = "ERROR: sin controller"
        rec.finished = true
        releaseCategoryIfTaskFinished(rec.keyword, rec.id)
        return
    end

    local profile = rec.profile

    if profile.mode == "escort_group" then
        local targetName = rec.argument
        if targetName == "" or not targetName then
            targetName = profile.defaultEscortGroup
        end

        if not targetName then
            rec.state = "ERROR: escort sin grupo objetivo"
            rec.finished = true
            releaseCategoryIfTaskFinished(rec.keyword, rec.id)
            trigger.action.outText("La tarea escort requiere un grupo objetivo. Ej: escort Ford11", 10)
            return
        end

        local targetGroup = groupExistsByName(targetName)
        if not targetGroup then
            rec.state = "ERROR: grupo a escoltar no existe"
            rec.finished = true
            releaseCategoryIfTaskFinished(rec.keyword, rec.id)
            trigger.action.outText("No existe el grupo a escoltar: " .. targetName, 10)
            return
        end

        controller:resetTask()
        controller:setTask(buildEscortTask(profile, targetGroup))

        rec.state = "ACTIVA - ESCORT"
        rec.targetGroupName = targetName
        rec.assignedAt = timer.getAbsTime()

        trigger.action.outText(
            "Tarea asignada\n" ..
            "ID: " .. rec.id .. "\n" ..
            "Tipo: " .. rec.profile.displayName .. "\n" ..
            "Plantilla: " .. rec.templateName .. "\n" ..
            "Grupo clonado: " .. rec.cloneGroupName .. "\n" ..
            "Objetivo escort: " .. rec.targetGroupName,
            10
        )
        return
    end

    local route, metaOrErr = buildRouteFromTemplate(rec.templateName, profile, rec.point)
    if not route then
        rec.state = "ERROR: " .. tostring(metaOrErr or "no se pudo crear la ruta")
        rec.finished = true
        releaseCategoryIfTaskFinished(rec.keyword, rec.id)
        trigger.action.outText(rec.state, 10)
        return
    end

    rec.ipPoint = metaOrErr and metaOrErr.ipPoint or nil
    rec.targetPoint = metaOrErr and metaOrErr.targetPoint or nil
    rec.egressPoint = metaOrErr and metaOrErr.egressPoint or nil

    local ok = mist.goRoute(rec.cloneGroupName, route)
    if not ok then
        rec.state = "ERROR: mist.goRoute fallo"
        rec.finished = true
        releaseCategoryIfTaskFinished(rec.keyword, rec.id)
        trigger.action.outText(rec.state, 10)
        return
    end

    rec.state = "ACTIVA - EN RUTA"
    rec.assignedAt = timer.getAbsTime()

    trigger.action.outText(
        "Tarea asignada\n" ..
        "ID: " .. rec.id .. "\n" ..
        "Tipo: " .. rec.profile.displayName .. "\n" ..
        "Plantilla: " .. rec.templateName .. "\n" ..
        "Grupo clonado: " .. rec.cloneGroupName .. "\n" ..
        "SEAD usa egress firmado; RTB sube a Angels 30",
        10
    )
end

local function createTask(keyword, arg, point, markId, originalText)
    local profile = TASK_PROFILES[keyword]
    if not profile then
        return false
    end

    local allowed, reason = canUseCategory(keyword)
    if not allowed then
        trigger.action.outText(reason, 10)
        return false
    end

    local templateName = getRandomTemplate(profile)
    if not templateName then
        debugMsg("No hay plantillas configuradas para " .. keyword, 10)
        return false
    end

    local ok, clonedData = pcall(mist.cloneGroup, templateName, true)
    if not ok or not clonedData then
        debugMsg("Error clonando plantilla: " .. templateName, 10)
        return false
    end

    local cloneName = extractCloneName(clonedData)
    if not cloneName then
        debugMsg("No se pudo resolver el nombre del clon de " .. templateName, 10)
        return false
    end

    local id = nextTaskId
    nextTaskId = nextTaskId + 1

    activeTasks[id] = {
        id = id,
        keyword = keyword,
        profile = profile,
        argument = arg,
        originalText = originalText,
        markId = markId,
        point = { x = point.x, y = point.y, z = point.z },
        templateName = templateName,
        cloneGroupName = cloneName,
        createdAt = timer.getAbsTime(),
        assignedAt = nil,
        state = "PENDIENTE",
        finished = false,
        lastDistance = nil,
        targetGroupName = nil,

        casTargetGroupName = nil,
        casAttackAssigned = false,

        capTargetGroupName = nil,
        capAttackAssigned = false,

        seadTargetGroupName = nil,
        seadAttackAssigned = false,

        navalTargetGroupName = nil,
        navalAttackAssigned = false,

        ipPoint = nil,
        targetPoint = nil,
        egressPoint = nil,

        hasBeenAbove10AGL = false,
        stopSince = nil
    }

    lockCategoryOnLaunch(keyword, id)
    mist.scheduleFunction(assignTaskToClone, { id }, timer.getTime() + ASSIGN_DELAY)

    debugMsg(
        "Marca procesada: " .. keyword ..
        " | plantilla: " .. templateName ..
        " | clon: " .. cloneName,
        8
    )

    return true
end

----------------------------------------------------------------
-- MENU F10
----------------------------------------------------------------
local function showAssignedTasks()
    local ids = getTaskIdsSorted()
    if #ids == 0 then
        trigger.action.outText("No hay tareas registradas.", 10)
        return
    end

    local lines = { "TAREAS REGISTRADAS" }

    for _, id in ipairs(ids) do
        local rec = activeTasks[id]
        if rec then
            local extra = ""
            if rec.targetGroupName then
                extra = " | escolta=" .. rec.targetGroupName
            elseif rec.casTargetGroupName then
                extra = " | casTarget=" .. rec.casTargetGroupName
            elseif rec.capTargetGroupName then
                extra = " | capTarget=" .. rec.capTargetGroupName
            elseif rec.seadTargetGroupName then
                extra = " | seadTarget=" .. rec.seadTargetGroupName
            elseif rec.navalTargetGroupName then
                extra = " | navalTarget=" .. rec.navalTargetGroupName
            end

            lines[#lines + 1] =
                "[" .. rec.id .. "] " ..
                rec.profile.displayName ..
                " | grupo=" .. rec.cloneGroupName ..
                " | plantilla=" .. rec.templateName ..
                " | estado=" .. rec.state ..
                extra
        end
    end

    trigger.action.outText(table.concat(lines, "\n"), 20)
end

local function cleanDestroyedTasks()
    local removed = 0
    local ids = getTaskIdsSorted()

    for _, id in ipairs(ids) do
        local rec = activeTasks[id]
        if rec then
            local g = groupExistsByName(rec.cloneGroupName)
            if (not g) or rec.finished then
                releaseCategoryIfTaskFinished(rec.keyword, rec.id)
                activeTasks[id] = nil
                removed = removed + 1
            end
        end
    end

    trigger.action.outText("Tareas eliminadas del registro: " .. removed, 8)
end

local function showProfiles()
    local keys = {}
    for key, profile in pairs(TASK_PROFILES) do
        keys[#keys + 1] =
            key .. " -> " .. profile.displayName ..
            " (" .. #profile.templates .. " plantillas, max=" .. tostring(profile.maxActive or 1) .. ")"
    end
    table.sort(keys)

    trigger.action.outText("PERFILES DISPONIBLES\n" .. table.concat(keys, "\n"), 18)
end

local function showCategoryStatus()
    local keys = {}
    for key, _ in pairs(TASK_PROFILES) do
        keys[#keys + 1] = key
    end
    table.sort(keys)

    local lines = { "ESTADO DE CATEGORIAS" }

    for _, key in ipairs(keys) do
        removeDeadTaskIdsFromCategory(key)

        local cat = categoryState[key]
        local profile = TASK_PROFILES[key]
        local countActive = #cat.activeTaskIds
        local maxActive = profile.maxActive or 1

        local cooldownText = "lista"
        if countActive == 0 and timer.getAbsTime() < (cat.nextAvailableAt or 0) then
            cooldownText = formatTimeMMSS(getSecondsRemaining(cat.nextAvailableAt))
        end

        lines[#lines + 1] =
            key ..
            " | activas=" .. tostring(countActive) .. "/" .. tostring(maxActive) ..
            " | cooldown=" .. cooldownText
    end

    trigger.action.outText(table.concat(lines, "\n"), 20)
end

local function showHelp()
    local text =
        "SINTAXIS DE MARCAS F10\n" ..
        "cap\n" ..
        "sead\n" ..
        "cas\n" ..
        "strike\n" ..
        "naval\n" ..
        "antiship\n" ..
        "escort NombreDelGrupo\n\n" ..
        "Notas:\n" ..
        "- SEAD permite egress positivo o negativo\n" ..
        "- egressOffsetNm = -10 deja el egress antes del objetivo\n" ..
        "- STRIKE usa IP + marca exacta + EGRESS + RTB\n" ..
        "- El RTB primero sube a Angels 30\n" ..
        "- CAS vuelve a casa despues de su tiempo de tarea\n" ..
        "- Si el clon ya volo y luego se queda quieto 30 s, desaparece"

    trigger.action.outText(text, 20)
end

local menuRoot = missionCommands.addSubMenu(MENU_NAME)
missionCommands.addCommand("Ver tareas asignadas", menuRoot, showAssignedTasks)
missionCommands.addCommand("Limpiar tareas destruidas", menuRoot, cleanDestroyedTasks)
missionCommands.addCommand("Ver perfiles disponibles", menuRoot, showProfiles)
missionCommands.addCommand("Ver estado por categoria", menuRoot, showCategoryStatus)
missionCommands.addCommand("Ayuda sintaxis", menuRoot, showHelp)

----------------------------------------------------------------
-- HEARTBEAT
----------------------------------------------------------------
local function heartbeat(_, now)
    for _, id in ipairs(getTaskIdsSorted()) do
        local rec = activeTasks[id]
        if rec then
            local group = groupExistsByName(rec.cloneGroupName)

            if not group then
                rec.state = "DESTRUIDA"
                rec.finished = true
                releaseCategoryIfTaskFinished(rec.keyword, rec.id)
            else
                local lead = getAliveLeadUnit(group)

                if lead then
                    ----------------------------------------------------------------
                    -- MONITOREO DE DESAPARICION POR PARADA
                    ----------------------------------------------------------------
                    local agl = getAGL(lead)
                    local speed = getSpeedMps(lead)

                    if agl >= ARM_STOP_MONITOR_AT_AGL then
                        rec.hasBeenAbove10AGL = true
                    end

                    if rec.hasBeenAbove10AGL then
                        if speed <= STOP_SPEED_THRESHOLD then
                            if not rec.stopSince then
                                rec.stopSince = timer.getAbsTime()
                            elseif (timer.getAbsTime() - rec.stopSince) >= DESPAWN_AFTER_STOP_SECONDS then
                                debugMsg("Grupo detenido despues de volar. Desapareciendo: " .. rec.cloneGroupName, 8)

                                rec.state = "DESAPARECIDO POR PARADA"
                                rec.finished = true
                                releaseCategoryIfTaskFinished(rec.keyword, rec.id)

                                if group and group:isExist() then
                                    group:destroy()
                                end
                            end
                        else
                            rec.stopSince = nil
                        end
                    end

                    ----------------------------------------------------------------
                    -- LOGICA DE TAREAS
                    ----------------------------------------------------------------
                    if rec.point then
                        local distToTarget = get2DDistance(lead:getPoint(), rec.point)
                        rec.lastDistance = distToTarget

                        if rec.keyword == "cap" then
                            if distToTarget <= (rec.profile.zoneRadius or 0) then
                                local currentTarget = nil

                                if rec.capTargetGroupName then
                                    currentTarget = groupExistsByName(rec.capTargetGroupName)
                                    if not currentTarget or currentTarget:getSize() <= 0 then
                                        currentTarget = nil
                                        rec.capTargetGroupName = nil
                                        rec.capAttackAssigned = false
                                    else
                                        local targetLead = getAliveLeadUnit(currentTarget)
                                        if not targetLead then
                                            currentTarget = nil
                                            rec.capTargetGroupName = nil
                                            rec.capAttackAssigned = false
                                        end
                                    end
                                end

                                if not currentTarget then
                                    local targetGroup, targetDist = getNearestEnemyAirGroupInRadius(
                                        group,
                                        rec.point,
                                        rec.profile.zoneRadius or 0
                                    )

                                    if targetGroup then
                                        local controller = group:getController()
                                        if controller then
                                            controller:pushTask(buildAttackGroupTask(targetGroup, rec.profile))
                                            rec.capTargetGroupName = targetGroup:getName()
                                            rec.capAttackAssigned = true
                                            rec.state = "ACTIVA - CAP ATACANDO"

                                            if DEBUG then
                                                trigger.action.outText(
                                                    "[Tasking IA] CAP atacando grupo: " ..
                                                    rec.capTargetGroupName ..
                                                    " | Distancia objetivo: " ..
                                                    math.floor(targetDist or 0) .. " m",
                                                    6
                                                )
                                            end
                                        else
                                            rec.state = "ACTIVA - CAP SIN CONTROLLER"
                                        end
                                    else
                                        rec.state = "ACTIVA - CAP SIN BLANCO"
                                    end
                                else
                                    rec.state = "ACTIVA - CAP ATACANDO"
                                end
                            else
                                rec.state = "ACTIVA - EN RUTA"
                            end

                        elseif rec.keyword == "sead" then
                            local distToIP = rec.ipPoint and get2DDistance(lead:getPoint(), rec.ipPoint) or math.huge
                            local triggerMeters = rec.profile.attackTriggerMeters or 12000

                            if not rec.seadAttackAssigned then
                                if distToIP <= triggerMeters or distToTarget <= (rec.profile.zoneRadius or 0) then
                                    local targetGroup, targetDist = getNearestEnemyGroundGroupByAttributesInRadius(
                                        group,
                                        rec.point,
                                        rec.profile.zoneRadius or 0,
                                        rec.profile.targetTypes
                                    )

                                    if targetGroup then
                                        local controller = group:getController()
                                        if controller then
                                            controller:pushTask(buildAttackGroupTask(targetGroup, rec.profile))
                                            rec.seadTargetGroupName = targetGroup:getName()
                                            rec.seadAttackAssigned = true
                                            rec.state = "ACTIVA - SEAD ATAQUE UNICO"

                                            if DEBUG then
                                                trigger.action.outText(
                                                    "[Tasking IA] SEAD atacando grupo: " ..
                                                    rec.seadTargetGroupName ..
                                                    " | Distancia objetivo: " ..
                                                    math.floor(targetDist or 0) .. " m",
                                                    6
                                                )
                                            end
                                        else
                                            rec.state = "ACTIVA - SEAD SIN CONTROLLER"
                                        end
                                    else
                                        rec.state = "ACTIVA - SEAD SIN BLANCO"
                                    end
                                else
                                    rec.state = "ACTIVA - EN RUTA"
                                end
                            else
                                rec.state = "ACTIVA - SEAD / RTB"
                            end

                        elseif rec.keyword == "cas" then
                            if distToTarget <= (rec.profile.zoneRadius or 0) then
                                local currentTarget = nil

                                if rec.casTargetGroupName then
                                    currentTarget = groupExistsByName(rec.casTargetGroupName)
                                    if not currentTarget or currentTarget:getSize() <= 0 then
                                        currentTarget = nil
                                        rec.casTargetGroupName = nil
                                        rec.casAttackAssigned = false
                                    else
                                        local targetLead = getAliveLeadUnit(currentTarget)
                                        if not targetLead then
                                            currentTarget = nil
                                            rec.casTargetGroupName = nil
                                            rec.casAttackAssigned = false
                                        else
                                            local targetPoint = targetLead:getPoint()
                                            local targetDistFromZone = get2DDistance(targetPoint, rec.point)
                                            if targetDistFromZone > (rec.profile.zoneRadius or 0) then
                                                currentTarget = nil
                                                rec.casTargetGroupName = nil
                                                rec.casAttackAssigned = false
                                            end
                                        end
                                    end
                                end

                                if not currentTarget then
                                    local targetGroup, targetDist = getNearestEnemyGroundGroupInRadius(
                                        group,
                                        rec.point,
                                        rec.profile.zoneRadius or 0
                                    )

                                    if targetGroup then
                                        local controller = group:getController()
                                        if controller then
                                            controller:pushTask(buildAttackGroupTask(targetGroup, rec.profile))
                                            rec.casTargetGroupName = targetGroup:getName()
                                            rec.casAttackAssigned = true
                                            rec.state = "ACTIVA - CAS ATACANDO"

                                            if DEBUG then
                                                trigger.action.outText(
                                                    "[Tasking IA] CAS atacando grupo: " ..
                                                    rec.casTargetGroupName ..
                                                    " | Distancia objetivo: " ..
                                                    math.floor(targetDist or 0) .. " m",
                                                    6
                                                )
                                            end
                                        else
                                            rec.state = "ACTIVA - CAS SIN CONTROLLER"
                                        end
                                    else
                                        rec.state = "ACTIVA - CAS SIN BLANCO"
                                    end
                                else
                                    rec.state = "ACTIVA - CAS ATACANDO"
                                end
                            else
                                rec.state = "ACTIVA - EN RUTA"
                            end

                        elseif rec.keyword == "naval" then
                            if distToTarget <= (rec.profile.zoneRadius or 0) then
                                local currentTarget = nil

                                if rec.navalTargetGroupName then
                                    currentTarget = groupExistsByName(rec.navalTargetGroupName)
                                    if not currentTarget or currentTarget:getSize() <= 0 then
                                        currentTarget = nil
                                        rec.navalTargetGroupName = nil
                                        rec.navalAttackAssigned = false
                                    else
                                        local targetLead = getAliveLeadUnit(currentTarget)
                                        if not targetLead then
                                            currentTarget = nil
                                            rec.navalTargetGroupName = nil
                                            rec.navalAttackAssigned = false
                                        end
                                    end
                                end

                                if not currentTarget then
                                    local targetGroup, targetDist = getNearestEnemyShipGroupInRadius(
                                        group,
                                        rec.point,
                                        rec.profile.zoneRadius or 0,
                                        rec.profile.targetTypes
                                    )

                                    if targetGroup then
                                        local controller = group:getController()
                                        if controller then
                                            controller:pushTask(buildAttackGroupTask(targetGroup, rec.profile))
                                            rec.navalTargetGroupName = targetGroup:getName()
                                            rec.navalAttackAssigned = true
                                            rec.state = "ACTIVA - NAVAL ATACANDO"

                                            if DEBUG then
                                                trigger.action.outText(
                                                    "[Tasking IA] NAVAL atacando grupo: " ..
                                                    rec.navalTargetGroupName ..
                                                    " | Distancia objetivo: " ..
                                                    math.floor(targetDist or 0) .. " m",
                                                    6
                                                )
                                            end
                                        else
                                            rec.state = "ACTIVA - NAVAL SIN CONTROLLER"
                                        end
                                    else
                                        rec.state = "ACTIVA - NAVAL SIN BLANCO"
                                    end
                                else
                                    rec.state = "ACTIVA - NAVAL ATACANDO"
                                end
                            else
                                rec.state = "ACTIVA - EN RUTA"
                            end

                        elseif rec.keyword == "strike" then
                            local distToIP = rec.ipPoint and get2DDistance(lead:getPoint(), rec.ipPoint) or math.huge
                            local distToEgress = rec.egressPoint and get2DDistance(lead:getPoint(), rec.egressPoint) or math.huge

                            if distToIP <= 5000 and distToTarget > 4000 then
                                rec.state = "ACTIVA - STRIKE EN PASADA"
                            elseif distToTarget <= 4000 then
                                rec.state = "ACTIVA - STRIKE SOBRE OBJETIVO"
                            elseif distToEgress <= 6000 then
                                rec.state = "ACTIVA - STRIKE EGRESS / RTB"
                            else
                                rec.state = "ACTIVA - EN RUTA"
                            end

                        elseif rec.profile.mode == "escort_group" then
                            if rec.targetGroupName then
                                local targetGroup = groupExistsByName(rec.targetGroupName)
                                if not targetGroup then
                                    rec.state = "ESCORT SIN OBJETIVO"
                                else
                                    rec.state = "ACTIVA - ESCORT"
                                end
                            end

                        else
                            rec.state = "ACTIVA - EN RUTA"
                        end
                    end
                end
            end
        end
    end

    return now + HEARTBEAT_SECONDS
end

timer.scheduleFunction(heartbeat, nil, timer.getTime() + HEARTBEAT_SECONDS)

----------------------------------------------------------------
-- EVENT HANDLER DE MARCAS
----------------------------------------------------------------
local markHandler = {}

function markHandler:onEvent(event)
    if not event then return end

    if event.id == world.event.S_EVENT_MARK_ADDED
        or event.id == world.event.S_EVENT_MARK_CHANGE then

        local text = event.text or ""
        local keyword, arg = parseCommand(text)
        if not keyword then
            return
        end

        local point = resolveMarkPoint(event)
        if not point then
            debugMsg("No se pudo leer la posicion de la marca.", 8)
            return
        end

        local signature = buildSignature(keyword, point, arg)
        if processedMarks[event.idx] == signature then
            return
        end
        processedMarks[event.idx] = signature

        local success = createTask(keyword, arg, point, event.idx, text)

        if success and AUTO_REMOVE_MARK and event.idx then
            trigger.action.removeMark(event.idx)
            processedMarks[event.idx] = nil
        end

    elseif event.id == world.event.S_EVENT_MARK_REMOVE then
        if event.idx then
            processedMarks[event.idx] = nil
        end
    end
end

world.addEventHandler(markHandler)

trigger.action.outText(
    "Tasking IA cargado.\n" ..
    "SEAD ya permite egress negativo y el RTB sube a Angels 30.",
    12
)