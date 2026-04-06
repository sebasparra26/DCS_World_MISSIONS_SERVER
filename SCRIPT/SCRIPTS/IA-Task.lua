----------------------------------------------------------------
-- SISTEMA DE TAREAS F10
-- VERSION: conservar despegue/ruta base del editor y reemplazar
-- el primer waypoint operativo por la marca F10.
--
-- REQUIERE:
--   1) MIST cargado antes que este script
--   2) Las plantillas deben existir en el editor
--   3) Las plantillas deben tener al menos:
--        WP1 = despegue desde tierra
--        WP2 = primer waypoint operativo
--
-- SINTAXIS DE MARCAS:
--   cap
--   sead
--   cas
--   strike
--   ataque a tierra
--   escort NombreExactoDelGrupo
--   escolta NombreExactoDelGrupo
----------------------------------------------------------------

if not mist or not mist.cloneGroup or not mist.getGroupRoute or not mist.goRoute then
    trigger.action.outText("ERROR: MIST no esta cargado o faltan funciones requeridas.", 15)
    return
end

----------------------------------------------------------------
-- AJUSTES GENERALES
----------------------------------------------------------------
local DEBUG = true
local AUTO_REMOVE_MARK = true
local ASSIGN_DELAY = 1
local HEARTBEAT_SECONDS = 5
local MENU_NAME = "Tasking IA"

----------------------------------------------------------------
-- PERFILES DE MISION
----------------------------------------------------------------
local TASK_PROFILES = {
    cap = {
        displayName = "CAP",
        mode = "area_engage",
        templates = { "CAP_A", "CAP_B", "CAP_C" },
        maxActive = 4,
        cooldownSeconds = 20 * 60,
        orbitAltitude = 7000,   -- metros
        orbitSpeed = 220,       -- m/s
        zoneRadius = 35000,     -- metros
        targetTypes = { "Air" }
    },

    sead = {
        displayName = "SEAD",
        mode = "area_engage",
        templates = { "SEAD_D", "SEAD_E", "SEAD_F" },
        maxActive = 1,
        cooldownSeconds = 20 * 60,
        orbitAltitude = 6500,
        orbitSpeed = 220,
        zoneRadius = 30000,
        targetTypes = { "Air Defence", "SAM related", "AAA", "EWR" }
    },

    cas = {
        displayName = "CAS",
        mode = "area_engage",
        templates = { "CAS_A", "CAS_B", "CAS_C" },
        maxActive = 2,
        cooldownSeconds = 20 * 60,
        orbitAltitude = 1000,
        orbitSpeed = 170,
        zoneRadius = 18000,
        targetTypes = { "Ground Units" }
    },

    strike = {
        displayName = "STRIKE",
        mode = "bomb_point",
        templates = { "STRIKE_A", "STRIKE_B", "STRIKE_C" },
        maxActive = 1,
        cooldownSeconds = 20 * 60,
        ingressAltitude = 5000,
        ingressSpeed = 170,
        attackQty = 30,
        groupAttack = true
    },

    escort = {
        displayName = "ESCORT",
        mode = "escort_group",
        templates = { "ESCORT_A", "ESCORT_B" },
        maxActive = 2,
        cooldownSeconds = 20 * 60,
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
  --  { alias = "ataque a tierra",   key = "strike" },
   -- { alias = "ataque de tierra",  key = "strike" },
   -- { alias = "close air support", key = "cas"    },
   -- { alias = "ataque terrestre",  key = "strike" },
    --{ alias = "escolta",           key = "escort" },
    { alias = "escort",            key = "escort" },
    { alias = "strike",            key = "strike" },
    { alias = "sead",              key = "sead"   },
    { alias = "cas",               key = "cas"    },
    { alias = "cap",               key = "cap"    }
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
    return tbl
end

local function makeVec2(point)
    if not point then return nil end
    if point.z then
        return { x = point.x, y = point.z }
    end
    return { x = point.x, y = point.y }
end

local function getAliveLeadUnit(group)
    if not group or not group:isExist() then return nil end
    local units = group:getUnits() or {}
    for i = 1, #units do
        if units[i] and units[i]:isExist() then
            return units[i]
        end
    end
    return nil
end

local function get2DDistance(a, b)
    if not a or not b then return 999999999 end
    local ax = a.x
    local ay = a.z or a.y
    local bx = b.x
    local by = b.z or b.y
    local dx = ax - bx
    local dy = ay - by
    return math.sqrt(dx * dx + dy * dy)
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
        return { x = event.pos.x, y = event.pos.y, z = event.pos.z }
    end

    if mist and mist.DBs and mist.DBs.markList and event and event.idx and mist.DBs.markList[event.idx] and mist.DBs.markList[event.idx].pos then
        local p = mist.DBs.markList[event.idx].pos
        return { x = p.x, y = p.y or 0, z = p.z or p.y }
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

local function formatMeters(v)
    if not v then return "N/D" end
    return tostring(math.floor(v))
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
        local g = rec and Group.getByName(rec.cloneGroupName) or nil
        if rec and g and g:isExist() and not rec.finished then
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
    return { id = "ComboTask", params = { tasks = {} } }
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
                        attackQty = profile.attackQty or 1,
                        groupAttack = (profile.groupAttack ~= false)
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

local function buildWaypointTaskForProfile(profile, pointVec2)
    if profile.mode == "area_engage" then
        return buildAreaComboTask(profile, pointVec2)
    elseif profile.mode == "bomb_point" then
        return buildBombPointComboTask(profile, pointVec2)
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
    local wp2 = deepCopy(templateRoute[2])

    local pointVec2 = makeVec2(markPoint)

    wp2.x = markPoint.x
    wp2.y = markPoint.z
    wp2.name = profile.displayName
    wp2.alt = profile.orbitAltitude or profile.ingressAltitude or wp2.alt or 2000
    wp2.alt_type = wp2.alt_type or wp1.alt_type or "BARO"
    wp2.speed = profile.orbitSpeed or profile.ingressSpeed or wp2.speed or 180
    wp2.speed_locked = true
    wp2.ETA_locked = false
    wp2.task = buildWaypointTaskForProfile(profile, pointVec2)

    return { wp1, wp2 }
end

----------------------------------------------------------------
-- CREACION Y ASIGNACION
----------------------------------------------------------------
local function assignTaskToClone(taskId)
    local rec = activeTasks[taskId]
    if not rec then return end

    local group = Group.getByName(rec.cloneGroupName)
    if not group or not group:isExist() then
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

        local targetGroup = Group.getByName(targetName)
        if not targetGroup or not targetGroup:isExist() then
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

    local route, err = buildRouteFromTemplate(rec.templateName, profile, rec.point)
    if not route then
        rec.state = "ERROR: " .. (err or "no se pudo crear la ruta")
        rec.finished = true
        releaseCategoryIfTaskFinished(rec.keyword, rec.id)
        trigger.action.outText(rec.state, 10)
        return
    end

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
        "WP operativo: etiqueta F10",
        10
    )
end

local function createTask(keyword, arg, point, markId, originalText)
    local profile = TASK_PROFILES[keyword]
    if not profile then return false end

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
        targetGroupName = nil
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
            local g = Group.getByName(rec.cloneGroupName)
            if (not g or not g:isExist()) or rec.finished then
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
        keys[#keys + 1] = key .. " -> " .. profile.displayName .. " (" .. #profile.templates .. " plantillas, max=" .. tostring(profile.maxActive or 1) .. ")"
    end
    table.sort(keys)
    trigger.action.outText("PERFILES DISPONIBLES\n" .. table.concat(keys, "\n"), 18)
end

local function showCategoryStatus()
    local keys = {}
    for key, _ in pairs(TASK_PROFILES) do keys[#keys + 1] = key end
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

        lines[#lines + 1] = key .. " | activas=" .. tostring(countActive) .. "/" .. tostring(maxActive) .. " | cooldown=" .. cooldownText
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
        "ataque a tierra\n" ..
        "escort NombreDelGrupo\n" ..
        "escolta NombreDelGrupo\n\n" ..
        "Notas:\n" ..
        "- La plantilla debe tener WP1 despegue + WP2 operativo en el editor\n" ..
        "- El script reemplaza ese WP2 por la etiqueta F10\n" ..
        "- maxActive por categoria\n" ..
        "- cooldown por categoria"

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
            local group = Group.getByName(rec.cloneGroupName)

            if not group or not group:isExist() then
                rec.state = "DESTRUIDA"
                rec.finished = true
                releaseCategoryIfTaskFinished(rec.keyword, rec.id)
            else
                local lead = getAliveLeadUnit(group)
                if lead and rec.point then
                    local dist = get2DDistance(lead:getPoint(), rec.point)
                    rec.lastDistance = dist

                    if rec.profile.mode == "area_engage" then
                        if dist <= (rec.profile.zoneRadius or 0) then
                            rec.state = "ACTIVA - EN ZONA"
                        else
                            rec.state = "ACTIVA - EN RUTA"
                        end
                    elseif rec.profile.mode == "bomb_point" then
                        rec.state = "ACTIVA - STRIKE"
                    elseif rec.profile.mode == "escort_group" then
                        if rec.targetGroupName then
                            local targetGroup = Group.getByName(rec.targetGroupName)
                            if not targetGroup or not targetGroup:isExist() then
                                rec.state = "ESCORT SIN OBJETIVO"
                            else
                                rec.state = "ACTIVA - ESCORT"
                            end
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

    if event.id == world.event.S_EVENT_MARK_ADDED or event.id == world.event.S_EVENT_MARK_CHANGE then
        local text = event.text or ""
        local keyword, arg = parseCommand(text)
        if not keyword then return end

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
    "La plantilla debe tener WP1 despegue + WP2 operativo en el editor.\n" ..
    "El WP2 se reemplaza por la etiqueta F10.",
    12
)