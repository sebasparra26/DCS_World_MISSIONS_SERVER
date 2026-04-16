----------------------------------------------------------------
-- DEBUG BOOM POR MARCAS F10
--
-- SINTAXIS:
--   boom 1000 15
--
-- DONDE:
--   boom  = palabra clave
--   1000  = poder de la explosion
--   15    = delay en segundos
--
-- EJEMPLOS:
--   boom 500 0
--   boom 1000 10
--   boom 2500 30
----------------------------------------------------------------

HDEV_BoomDebug = HDEV_BoomDebug or {}
local BOOM = HDEV_BoomDebug

BOOM.CONFIG = {
    DEBUG = true,
    KEYWORD = "boom",
    AUTO_REMOVE_MARK = true,
    DEFAULT_DELAY = 0,
    MESSAGE_TIME = 8,

    MIN_POWER = 1,
    MAX_POWER = 100000
}

BOOM.STATE = {
    processedMarks = {}
}

local function debugMsg(msg, t)
    if BOOM.CONFIG.DEBUG then
        trigger.action.outText("[BOOM DEBUG] " .. tostring(msg), t or BOOM.CONFIG.MESSAGE_TIME)
    end
end

local function trim(s)
    if not s then return "" end
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function normalizeSpaces(s)
    return trim((s or ""):gsub("%s+", " "))
end

local function lower(s)
    return string.lower(tostring(s or ""))
end

local function clamp(v, minV, maxV)
    v = tonumber(v) or 0
    if v < minV then v = minV end
    if v > maxV then v = maxV end
    return v
end

local function resolveMarkPoint(event)
    if event and event.pos then
        local z = event.pos.z or event.pos.y
        return {
            x = event.pos.x,
            y = event.pos.y or 0,
            z = z
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
        local z = p.z or p.y
        return {
            x = p.x,
            y = p.y or 0,
            z = z
        }
    end

    return nil
end

local function pointToGround(point)
    if not point then return nil end

    local x = point.x
    local z = point.z or point.y
    local groundY = 0

    if land and land.getHeight then
        groundY = land.getHeight({ x = x, y = z }) or 0
    end

    return {
        x = x,
        y = groundY,
        z = z
    }
end

local function buildSignature(text, point)
    return table.concat({
        lower(normalizeSpaces(text)),
        tostring(math.floor((point and point.x) or 0)),
        tostring(math.floor((point and (point.z or point.y)) or 0))
    }, "|")
end

local function parseBoomCommand(text)
    local raw = normalizeSpaces(text)
    local rawLower = lower(raw)

    local keyword = BOOM.CONFIG.KEYWORD
    if rawLower == keyword then
        return nil, "Falta la potencia. Ejemplo: boom 1000 15"
    end

    if rawLower:sub(1, #keyword) ~= keyword then
        return nil, nil
    end

    local parts = {}
    for token in string.gmatch(raw, "%S+") do
        parts[#parts + 1] = token
    end

    if #parts < 2 then
        return nil, "Falta la potencia. Ejemplo: boom 1000 15"
    end

    if lower(parts[1]) ~= keyword then
        return nil, nil
    end

    local power = tonumber(parts[2])
    if not power then
        return nil, "La potencia no es valida. Ejemplo: boom 1000 15"
    end

    local delay = BOOM.CONFIG.DEFAULT_DELAY
    if parts[3] ~= nil then
        delay = tonumber(parts[3])
        if delay == nil then
            return nil, "El delay no es valido. Ejemplo: boom 1000 15"
        end
    end

    power = clamp(power, BOOM.CONFIG.MIN_POWER, BOOM.CONFIG.MAX_POWER)
    delay = math.max(0, delay)

    return {
        keyword = keyword,
        power = power,
        delay = delay,
        rawText = raw
    }, nil
end

local function executeExplosion(data)
    if not data or not data.point then
        debugMsg("No se pudo ejecutar la explosion: punto invalido.", 8)
        return
    end

    local groundPoint = pointToGround(data.point)
    if not groundPoint then
        debugMsg("No se pudo ejecutar la explosion: ground point invalido.", 8)
        return
    end

    trigger.action.explosion(groundPoint, data.power)

    debugMsg(
        "Explosion ejecutada | poder=" .. tostring(data.power) ..
        " | x=" .. tostring(math.floor(groundPoint.x)) ..
        " | z=" .. tostring(math.floor(groundPoint.z)),
        8
    )
end

local function scheduleExplosion(cmd, point, markId)
    local payload = {
        power = cmd.power,
        delay = cmd.delay,
        point = point,
        markId = markId
    }

    timer.scheduleFunction(function(args, timeNow)
        executeExplosion(args)
        return nil
    end, payload, timer.getTime() + cmd.delay)

    debugMsg(
        "Explosion programada | poder=" .. tostring(cmd.power) ..
        " | delay=" .. tostring(cmd.delay) .. "s",
        8
    )
end

local markHandler = {}

function markHandler:onEvent(event)
    if not event then
        return
    end

    if event.id == world.event.S_EVENT_MARK_ADDED
        or event.id == world.event.S_EVENT_MARK_CHANGE then

        local text = event.text or ""
        local cmd, err = parseBoomCommand(text)

        if err then
            debugMsg(err, 8)
            return
        end

        if not cmd then
            return
        end

        local point = resolveMarkPoint(event)
        if not point then
            debugMsg("No se pudo leer la posicion de la marca.", 8)
            return
        end

        local signature = buildSignature(text, point)
        if event.idx and BOOM.STATE.processedMarks[event.idx] == signature then
            return
        end

        if event.idx then
            BOOM.STATE.processedMarks[event.idx] = signature
        end

        scheduleExplosion(cmd, point, event.idx)

        if BOOM.CONFIG.AUTO_REMOVE_MARK and event.idx then
            trigger.action.removeMark(event.idx)
            BOOM.STATE.processedMarks[event.idx] = nil
        end

    elseif event.id == world.event.S_EVENT_MARK_REMOVE then
        if event.idx then
            BOOM.STATE.processedMarks[event.idx] = nil
        end
    end
end

world.addEventHandler(markHandler)

trigger.action.outText(
    "Boom Debug cargado.\n" ..
    "Usa una marca F10 con este formato:\n" ..
    "boom 1000 15",
    12
)