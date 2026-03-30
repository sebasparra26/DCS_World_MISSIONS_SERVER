local WHSYNC = {
    DEBUG = false,

    FILE_PATH = lfs.writedir() .. "Config\\HorizontDev\\SistemWarehousePersistanceSinai.json",

    INJECT_DURATION = 30,
    INJECT_INTERVAL = 1,
    EXPORT_INTERVAL = 10,

    EXACT_SYNC = true,

    -- Si es true, al arrancar solo seguirá los IDs que existan dentro del JSON inicial.
    -- Ideal para tu caso, porque ese JSON ya quedó armado con los 55 IDs del Warehouses-Sinai.
    TRACK_ONLY_JSON_IDS = true,
}

local WHSTATE = {
    started = false,
    injecting = false,
    injectEndsAt = 0,
    lastInject = -9999,
    lastExport = -9999,
    airbasesById = {},
    trackedIds = nil,
}

local LIQUID_NAME_TO_ID = {
    jet_fuel = 0,
    gasoline = 1,
    methanol_mixture = 2,
    diesel = 3,
}

local LIQUID_ID_TO_NAME = {
    [0] = "jet_fuel",
    [1] = "gasoline",
    [2] = "methanol_mixture",
    [3] = "diesel",
}

local function log(msg)
    env.info("[WHSYNC-SINAI] " .. msg)
    if WHSYNC.DEBUG then
        trigger.action.outText("[WHSYNC-SINAI] " .. msg, 8)
    end
end

local function safeReadFile(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local txt = f:read("*a")
    f:close()
    return txt
end

local function safeWriteFile(path, txt)
    local f = io.open(path, "w")
    if not f then
        return false
    end
    f:write(txt or "")
    f:close()
    return true
end

local function decodeJson(txt)
    if not txt or txt == "" then
        return nil, "archivo vacío"
    end
    if not net or not net.json2lua then
        return nil, "net.json2lua no disponible"
    end

    local ok, data = pcall(net.json2lua, txt)
    if not ok then
        return nil, data
    end
    if type(data) ~= "table" then
        return nil, "json no devolvió tabla"
    end
    return data
end

local function loadSyncFile()
    local txt = safeReadFile(WHSYNC.FILE_PATH)
    if not txt then
        return nil, "no existe archivo"
    end
    return decodeJson(txt)
end

local function jsonEscape(str)
    str = tostring(str or "")
    str = str:gsub("\\", "\\\\")
    str = str:gsub("\"", "\\\"")
    str = str:gsub("\r", "\\r")
    str = str:gsub("\n", "\\n")
    str = str:gsub("\t", "\\t")
    return str
end

local function jsonPrimitive(v)
    local tv = type(v)

    if tv == "string" then
        return "\"" .. jsonEscape(v) .. "\""
    elseif tv == "number" then
        return tostring(v)
    elseif tv == "boolean" then
        return v and "true" or "false"
    elseif tv == "nil" then
        return "null"
    else
        return "\"" .. jsonEscape(tostring(v)) .. "\""
    end
end

local function sortedKeysAlpha(tbl)
    local keys = {}
    for k, _ in pairs(tbl or {}) do
        keys[#keys + 1] = tostring(k)
    end
    table.sort(keys, function(a, b)
        return a < b
    end)
    return keys
end

local function sortedKeysNumericString(tbl)
    local keys = {}
    for k, _ in pairs(tbl or {}) do
        keys[#keys + 1] = tostring(k)
    end
    table.sort(keys, function(a, b)
        local na = tonumber(a)
        local nb = tonumber(b)
        if na and nb then
            return na < nb
        end
        return a < b
    end)
    return keys
end

local function writeFlatObject(lines, indent, tbl, orderedKeys, numericSort)
    tbl = tbl or {}
    local done = {}
    local entries = {}

    if orderedKeys then
        for _, key in ipairs(orderedKeys) do
            if tbl[key] ~= nil then
                entries[#entries + 1] = {
                    key = key,
                    value = tbl[key]
                }
                done[key] = true
            end
        end
    end

    local extraKeys = numericSort and sortedKeysNumericString(tbl) or sortedKeysAlpha(tbl)
    for _, key in ipairs(extraKeys) do
        if not done[key] then
            entries[#entries + 1] = {
                key = key,
                value = tbl[key]
            }
        end
    end

    lines[#lines + 1] = indent .. "{"
    for i, entry in ipairs(entries) do
        local comma = (i < #entries) and "," or ""
        lines[#lines + 1] = indent .. "  " .. "\"" .. jsonEscape(entry.key) .. "\": " .. jsonPrimitive(entry.value) .. comma
    end
    lines[#lines + 1] = indent .. "}"
end

local function writeInventoryMap(lines, indent, tbl)
    tbl = tbl or {}
    local keys = sortedKeysAlpha(tbl)

    lines[#lines + 1] = indent .. "{"
    for i, key in ipairs(keys) do
        local comma = (i < #keys) and "," or ""
        lines[#lines + 1] = indent .. "  " .. "\"" .. jsonEscape(key) .. "\": " .. tostring(tonumber(tbl[key]) or 0) .. comma
    end
    lines[#lines + 1] = indent .. "}"
end

local function buildPrettyWarehouseJson(doc)
    local lines = {}

    lines[#lines + 1] = "{"

    lines[#lines + 1] = "  \"control\":"
    writeFlatObject(lines, "  ", doc.control or {}, {
        "injectDuration",
        "injectInterval",
        "exportInterval",
        "exactSync"
    }, false)
    lines[#lines] = lines[#lines] .. ","

    lines[#lines + 1] = "  \"meta\":"
    writeFlatObject(lines, "  ", doc.meta or {}, {
        "mode",
        "missionTime",
        "injectDuration",
        "exportInterval",
        "source",
        "note",
        "theatre"
    }, false)
    lines[#lines] = lines[#lines] .. ","

    lines[#lines + 1] = "  \"airports\": {"

    local airportKeys = sortedKeysNumericString(doc.airports or {})
    for aIndex, aKey in ipairs(airportKeys) do
        local airport = doc.airports[aKey] or {}
        local airportComma = (aIndex < #airportKeys) and "," or ""

        lines[#lines + 1] = "    \"" .. jsonEscape(aKey) .. "\": {"

        local block = {
            { key = "id", value = airport.id },
            { key = "name", value = airport.name },
            { key = "missionTime", value = airport.missionTime },
        }

        for _, item in ipairs(block) do
            lines[#lines + 1] = "      \"" .. item.key .. "\": " .. jsonPrimitive(item.value) .. ","
        end

        if airport.categoryName ~= nil then
            lines[#lines + 1] = "      \"categoryName\": " .. jsonPrimitive(airport.categoryName) .. ","
        end

        lines[#lines + 1] = "      \"liquids\": {"
        local liquidOrder = { "jet_fuel", "gasoline", "methanol_mixture", "diesel" }
        for i, lname in ipairs(liquidOrder) do
            local comma = (i < #liquidOrder) and "," or ""
            local amount = 0
            if airport.liquids and airport.liquids[lname] ~= nil then
                amount = tonumber(airport.liquids[lname]) or 0
            end
            lines[#lines + 1] = "        \"" .. lname .. "\": " .. tostring(amount) .. comma
        end
        lines[#lines + 1] = "      },"

        lines[#lines + 1] = "      \"aircraft\":"
        writeInventoryMap(lines, "      ", airport.aircraft or {})
        lines[#lines] = lines[#lines] .. ","

        lines[#lines + 1] = "      \"weapon\":"
        writeInventoryMap(lines, "      ", airport.weapon or {})

        lines[#lines + 1] = "    }" .. airportComma
    end

    lines[#lines + 1] = "  }"
    lines[#lines + 1] = "}"

    return table.concat(lines, "\n")
end

local function saveSyncFile(tbl)
    local json = buildPrettyWarehouseJson(tbl)
    if not json or json == "" then
        log("No se pudo construir JSON bonito.")
        return false
    end

    if not safeWriteFile(WHSYNC.FILE_PATH, json) then
        log("No se pudo escribir el archivo: " .. WHSYNC.FILE_PATH)
        return false
    end

    return true
end

local function setTrackedIdsFromDoc(doc)
    WHSTATE.trackedIds = nil

    if not WHSYNC.TRACK_ONLY_JSON_IDS then
        return
    end

    if type(doc) ~= "table" or type(doc.airports) ~= "table" then
        return
    end

    WHSTATE.trackedIds = {}
    for idStr, _ in pairs(doc.airports) do
        local id = tonumber(idStr)
        if id then
            WHSTATE.trackedIds[id] = true
        end
    end
end

local function shouldTrackAirbase(id)
    if WHSTATE.trackedIds == nil then
        return true
    end
    return WHSTATE.trackedIds[id] == true
end

local function rebuildAirbaseIndex()
    WHSTATE.airbasesById = {}

    local allAirbases = world.getAirbases() or {}
    for _, ab in ipairs(allAirbases) do
        if ab and ab.getID and ab.getWarehouse then
            local id = ab:getID()
            if id and shouldTrackAirbase(id) then
                WHSTATE.airbasesById[id] = ab
            end
        end
    end
end

local function copyFlatMap(src)
    local out = {}
    if type(src) ~= "table" then
        return out
    end

    for k, v in pairs(src) do
        out[tostring(k)] = tonumber(v) or 0
    end
    return out
end

local function getLiquidSnapshot(wh, inv)
    local liquids = {}

    for i = 0, 3 do
        local lname = LIQUID_ID_TO_NAME[i]
        local amount = 0

        local ok, val = pcall(function()
            return wh:getLiquidAmount(i)
        end)

        if ok and type(val) == "number" then
            amount = val
        elseif inv and inv.liquids then
            amount = inv.liquids[i] or inv.liquids[tostring(i)] or 0
        end

        liquids[lname] = tonumber(amount) or 0
    end

    return liquids
end

local function snapshotAirbase(ab)
    if not ab then return nil end

    local okWh, wh = pcall(function()
        return ab:getWarehouse()
    end)

    if not okWh or not wh then
        return nil
    end

    local okInv, inv = pcall(function()
        return wh:getInventory()
    end)

    if not okInv or type(inv) ~= "table" then
        inv = {}
    end

    local snap = {
        id = ab:getID(),
        name = ab:getName(),
        missionTime = timer.getTime(),
        categoryName = "unknown",
        aircraft = copyFlatMap(inv.aircraft),
        weapon = copyFlatMap(inv.weapon),
        liquids = getLiquidSnapshot(wh, inv),
    }

    local okDesc, desc = pcall(function()
        return Airbase.getDesc(ab)
    end)
    if okDesc and desc and desc.category ~= nil then
        local cat = tonumber(desc.category) or -1
        if cat == 0 then
            snap.categoryName = "airbase"
        else
            snap.categoryName = "units"
        end
    end

    return snap
end

local function zeroAllItems(wh, currentMap)
    if not WHSYNC.EXACT_SYNC then return end
    if type(currentMap) ~= "table" then return end

    for itemName, _ in pairs(currentMap) do
        pcall(function()
            wh:setItem(itemName, 0)
        end)
    end
end

local function setMissingItemsToZero(wh, currentMap, desiredMap)
    if not WHSYNC.EXACT_SYNC then return end
    if type(currentMap) ~= "table" then return end
    if type(desiredMap) ~= "table" then desiredMap = {} end

    for itemName, _ in pairs(currentMap) do
        if desiredMap[itemName] == nil then
            pcall(function()
                wh:setItem(itemName, 0)
            end)
        end
    end
end

local function applyItemMap(wh, desiredMap)
    if type(desiredMap) ~= "table" then return end

    for itemName, count in pairs(desiredMap) do
        local n = tonumber(count) or 0
        pcall(function()
            wh:setItem(itemName, n)
        end)
    end
end

local function applyWeaponWsTypeList(wh, weaponList)
    if type(weaponList) ~= "table" then return end

    for _, entry in ipairs(weaponList) do
        if type(entry) == "table" and type(entry.wsType) == "table" then
            local n = tonumber(entry.amount) or tonumber(entry.initialAmount) or 0
            pcall(function()
                wh:setItem(entry.wsType, n)
            end)
        end
    end
end

local function applyLiquidMap(wh, desiredLiquids)
    if type(desiredLiquids) ~= "table" then return end

    for liquidName, count in pairs(desiredLiquids) do
        local liquidId = LIQUID_NAME_TO_ID[liquidName]
        if liquidId ~= nil then
            local n = tonumber(count) or 0
            pcall(function()
                wh:setLiquidAmount(liquidId, n)
            end)
        end
    end
end

local function applyAirportData(ab, airportData)
    if not ab or type(airportData) ~= "table" then return end

    local okWh, wh = pcall(function()
        return ab:getWarehouse()
    end)

    if not okWh or not wh then
        return
    end

    local okInv, current = pcall(function()
        return wh:getInventory()
    end)

    if not okInv or type(current) ~= "table" then
        current = {}
    end

    if airportData.aircraft then
        setMissingItemsToZero(wh, current.aircraft or {}, airportData.aircraft)
        applyItemMap(wh, airportData.aircraft)
    end

    if airportData.weapon then
        setMissingItemsToZero(wh, current.weapon or {}, airportData.weapon)
        applyItemMap(wh, airportData.weapon)
    elseif airportData.weaponByWsType then
        zeroAllItems(wh, current.weapon or {})
        applyWeaponWsTypeList(wh, airportData.weaponByWsType)
    end

    if airportData.liquids then
        applyLiquidMap(wh, airportData.liquids)
    end
end

local function readControlOverrides(doc)
    if type(doc) ~= "table" or type(doc.control) ~= "table" then
        return
    end

    local c = doc.control

    if tonumber(c.injectDuration) then
        WHSYNC.INJECT_DURATION = tonumber(c.injectDuration)
    end
    if tonumber(c.injectInterval) then
        WHSYNC.INJECT_INTERVAL = tonumber(c.injectInterval)
    end
    if tonumber(c.exportInterval) then
        WHSYNC.EXPORT_INTERVAL = tonumber(c.exportInterval)
    end
    if type(c.exactSync) == "boolean" then
        WHSYNC.EXACT_SYNC = c.exactSync
    end
end

local function injectFromJson()
    local doc, err = loadSyncFile()
    if not doc then
        log("No se pudo leer JSON para inyectar: " .. tostring(err))
        return
    end

    readControlOverrides(doc)

    if type(doc.airports) ~= "table" then
        log("JSON sin bloque airports")
        return
    end

    for idStr, airportData in pairs(doc.airports) do
        local id = tonumber(idStr)
        if not id and type(airportData) == "table" then
            id = tonumber(airportData.id)
        end

        if id and WHSTATE.airbasesById[id] then
            applyAirportData(WHSTATE.airbasesById[id], airportData)
        end
    end
end

local function exportLiveToJson()
    local previous = {}
    local doc = {}

    local prev, _ = loadSyncFile()
    if type(prev) == "table" then
        previous = prev
    end

    doc.control = previous.control or {}
    doc.meta = previous.meta or {}
    doc.airports = {}

    doc.meta.mode = WHSTATE.injecting and "inject" or "live"
    doc.meta.missionTime = timer.getTime()
    doc.meta.injectDuration = WHSYNC.INJECT_DURATION
    doc.meta.exportInterval = WHSYNC.EXPORT_INTERVAL
    doc.meta.source = "DCS Warehouse runtime"
    doc.meta.theatre = "Sinai"

    for id, ab in pairs(WHSTATE.airbasesById) do
        local snap = snapshotAirbase(ab)
        if snap then
            doc.airports[tostring(id)] = snap
        end
    end

    if saveSyncFile(doc) then
        if WHSYNC.DEBUG then
            log("JSON actualizado desde DCS")
        end
    end
end

local function startupProbe()
    local count = 0
    for id, ab in pairs(WHSTATE.airbasesById) do
        local snap = snapshotAirbase(ab)
        if snap then
            count = count + 1
            if count <= 5 then
                log("Base detectada: ID " .. tostring(id) .. " - " .. tostring(snap.name))
            end
        end
    end

    log("Total de bases monitoreadas desde el JSON: " .. tostring(count))
end

local function mainLoop(_, now)
    if not WHSTATE.started then
        return now + 1
    end

    if WHSTATE.injecting then
        if now <= WHSTATE.injectEndsAt then
            if (now - WHSTATE.lastInject) >= WHSYNC.INJECT_INTERVAL then
                WHSTATE.lastInject = now
                injectFromJson()
            end
        else
            WHSTATE.injecting = false
            log("Fin de ventana de inyección. DCS retoma control y JSON pasa a espejo vivo.")
            exportLiveToJson()
            WHSTATE.lastExport = now
        end
    else
        if (now - WHSTATE.lastExport) >= WHSYNC.EXPORT_INTERVAL then
            WHSTATE.lastExport = now
            exportLiveToJson()
        end
    end

    return now + 1
end

local function validateEnvironment()
    if not Airbase or not Airbase.getWarehouse then
        log("Airbase.getWarehouse no disponible. Requiere Warehouse API.")
        return false
    end

    if not net or not net.json2lua then
        log("net.json2lua no disponible en esta misión.")
        return false
    end

    if not io or not lfs then
        log("io/lfs no disponibles. Revisa MissionScripting.lua.")
        return false
    end

    return true
end

local function startWarehouseSync()
    if not validateEnvironment() then
        return
    end

    local initialDoc = nil
    local okDoc, _ = loadSyncFile()
    if type(okDoc) == "table" then
        initialDoc = okDoc
        readControlOverrides(initialDoc)
        setTrackedIdsFromDoc(initialDoc)
    end

    rebuildAirbaseIndex()

    WHSTATE.started = true
    WHSTATE.injecting = (initialDoc ~= nil)
    WHSTATE.injectEndsAt = timer.getTime() + WHSYNC.INJECT_DURATION
    WHSTATE.lastInject = -9999
    WHSTATE.lastExport = -9999

    if initialDoc then
        log("JSON encontrado. Inyección activa por " .. tostring(WHSYNC.INJECT_DURATION) .. " segundos.")
        injectFromJson()
    else
        log("No había JSON previo. Se crea snapshot inicial y DCS queda como fuente desde el inicio.")
        exportLiveToJson()
        WHSTATE.injecting = false
    end

    startupProbe()
    timer.scheduleFunction(mainLoop, nil, timer.getTime() + 1)
end

startWarehouseSync()
