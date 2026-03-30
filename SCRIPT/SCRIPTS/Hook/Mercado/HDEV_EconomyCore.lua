-- ============================================================================
-- HDEV_EconomyCore.lua
-- Nucleo economico compartido para DCS World
-- Lee money.json al inicio, espera 30 segundos y luego DCS toma el control
-- ============================================================================

HDEV_Economy = HDEV_Economy or {}

local Economy = HDEV_Economy

Economy.version = "1.0.0"
Economy.initialized = Economy.initialized or false
Economy.points = Economy.points or { PuntosAZUL = 0, PuntosROJO = 0 }
Economy.generators = Economy.generators or {}
Economy.debug = Economy.debug or false
Economy.writeEnabled = Economy.writeEnabled or false
Economy.lastSavedPayload = Economy.lastSavedPayload or ""
Economy.lastWriteTime = Economy.lastWriteTime or 0
Economy.lastReadTime = Economy.lastReadTime or 0
Economy.dirty = Economy.dirty or false
Economy.syncStarted = Economy.syncStarted or false
Economy.jsonImported = Economy.jsonImported or false
Economy.importWindowEndsAt = Economy.importWindowEndsAt or nil
Economy.config = Economy.config or {
    jsonRelativePath = "Config\\HorizontDev\\money.json",
    importWindowSeconds = 30,
    autosaveInterval = 10,
    minWriteInterval = 5,
    debug = false
}

_G.puntosCoalicion = Economy.points
_G.obtenerPuntosCoalicion = function(coalicion)
    if coalicion == 1 then
        return Economy.points.PuntosROJO or 0
    end
    return Economy.points.PuntosAZUL or 0
end

local function econLog(msg)
    if Economy.debug then
        env.info("[HDEV_ECONOMY] " .. tostring(msg))
    end
end

local function econWarn(msg)
    env.info("[HDEV_ECONOMY] " .. tostring(msg))
end

local function ensureNumber(value)
    value = tonumber(value) or 0
    if value < 0 then
        value = 0
    end
    return math.floor(value)
end

local function mergeConfig(target, source)
    if type(source) ~= "table" then
        return target
    end

    for k, v in pairs(source) do
        target[k] = v
    end

    return target
end

function Economy.getJsonPath()
    if lfs and lfs.writedir then
        return lfs.writedir() .. Economy.config.jsonRelativePath
    end
    return Economy.config.jsonRelativePath
end

local function ensureJsonDirectory()
    if not lfs or not lfs.mkdir then
        return false
    end

    local fullPath = Economy.getJsonPath()
    local separator = fullPath:find("/") and "/" or "\\"
    local parts = {}
    for part in string.gmatch(fullPath, "[^\\/]+") do
        table.insert(parts, part)
    end

    if #parts <= 1 then
        return false
    end

    table.remove(parts, #parts)

    local prefix = ""
    if fullPath:match("^%a:[\\/]") then
        prefix = fullPath:sub(1, 3)
    elseif fullPath:sub(1, 1) == "/" then
        prefix = "/"
    end

    local current = prefix
    for _, part in ipairs(parts) do
        if current == "" or current:sub(-1) == separator then
            current = current .. part
        else
            current = current .. separator .. part
        end
        lfs.mkdir(current)
    end

    return true
end

function Economy.formatMoney(valor)
    if type(valor) ~= "number" then
        return "$0"
    end

    local entero = math.floor(valor)
    local partes = {}

    repeat
        table.insert(partes, 1, string.format("%03d", entero % 1000))
        entero = math.floor(entero / 1000)
    until entero == 0

    partes[1] = tostring(tonumber(partes[1]))
    return "$" .. table.concat(partes, ".")
end

function Economy.get(coalicion)
    if coalicion == 1 then
        return ensureNumber(Economy.points.PuntosROJO)
    end
    return ensureNumber(Economy.points.PuntosAZUL)
end

function Economy.set(coalicion, valor, motivo)
    valor = ensureNumber(valor)

    if coalicion == 1 then
        if Economy.points.PuntosROJO ~= valor then
            Economy.points.PuntosROJO = valor
            Economy.dirty = true
            econLog("Set ROJO = " .. valor .. (motivo and (" | " .. motivo) or ""))
        end
        return Economy.points.PuntosROJO
    end

    if Economy.points.PuntosAZUL ~= valor then
        Economy.points.PuntosAZUL = valor
        Economy.dirty = true
        econLog("Set AZUL = " .. valor .. (motivo and (" | " .. motivo) or ""))
    end
    return Economy.points.PuntosAZUL
end

function Economy.add(coalicion, monto, motivo)
    monto = ensureNumber(monto)
    if monto <= 0 then
        return Economy.get(coalicion)
    end
    return Economy.set(coalicion, Economy.get(coalicion) + monto, motivo or "sumatoria")
end

function Economy.canSpend(coalicion, monto)
    monto = ensureNumber(monto)
    return Economy.get(coalicion) >= monto
end

function Economy.spend(coalicion, monto, motivo)
    monto = ensureNumber(monto)
    if monto <= 0 then
        return true, Economy.get(coalicion)
    end

    local saldoActual = Economy.get(coalicion)
    if saldoActual < monto then
        return false, saldoActual
    end

    local nuevoSaldo = saldoActual - monto
    Economy.set(coalicion, nuevoSaldo, motivo or "gasto")
    return true, nuevoSaldo
end

function Economy.encodeJsonPayload()
    local payload = {
        "{",
        '  "PuntosAZUL": ' .. tostring(ensureNumber(Economy.points.PuntosAZUL)) .. ",",
        '  "PuntosROJO": ' .. tostring(ensureNumber(Economy.points.PuntosROJO)) .. ",",
        '  "updatedBy": "DCS",',
        '  "updatedAt": ' .. tostring(math.floor(timer.getAbsTime() or timer.getTime() or 0)),
        "}"
    }
    return table.concat(payload, "\n")
end

function Economy.readJsonFromDisk()
    local path = Economy.getJsonPath()
    local file, err = io.open(path, "r")
    if not file then
        econWarn("No se pudo abrir money.json para lectura: " .. tostring(err))
        return nil
    end

    local content = file:read("*a")
    file:close()

    if type(content) ~= "string" or content == "" then
        econWarn("money.json esta vacio o ilegible")
        return nil
    end

    local azul = tonumber(content:match('"PuntosAZUL"%s*:%s*(-?[%d%.]+)'))
    local rojo = tonumber(content:match('"PuntosROJO"%s*:%s*(-?[%d%.]+)'))

    if azul == nil and rojo == nil then
        econWarn("money.json no contiene PuntosAZUL/PuntosROJO validos")
        return nil
    end

    Economy.lastReadTime = timer.getTime()
    return {
        PuntosAZUL = ensureNumber(azul or Economy.points.PuntosAZUL),
        PuntosROJO = ensureNumber(rojo or Economy.points.PuntosROJO)
    }
end

function Economy.applyJsonToState(data)
    if type(data) ~= "table" then
        return false
    end

    Economy.points.PuntosAZUL = ensureNumber(data.PuntosAZUL or Economy.points.PuntosAZUL)
    Economy.points.PuntosROJO = ensureNumber(data.PuntosROJO or Economy.points.PuntosROJO)
    Economy.dirty = false
    Economy.jsonImported = true

    econLog("money.json importado | AZUL=" .. Economy.points.PuntosAZUL .. " | ROJO=" .. Economy.points.PuntosROJO)
    return true
end

function Economy.writeJsonToDisk(force)
    if not force then
        if not Economy.writeEnabled then
            return false
        end

        local now = timer.getTime()
        if (now - (Economy.lastWriteTime or 0)) < (Economy.config.minWriteInterval or 5) then
            return false
        end
    end

    local path = Economy.getJsonPath()
    local payload = Economy.encodeJsonPayload()

    ensureJsonDirectory()

    if not force and payload == Economy.lastSavedPayload and not Economy.dirty then
        return false
    end

    local tempPath = path .. ".tmp"
    local tempFile, tempErr = io.open(tempPath, "w")
    if not tempFile then
        econWarn("No se pudo abrir archivo temporal de money.json: " .. tostring(tempErr))
        return false
    end

    tempFile:write(payload)
    tempFile:flush()
    tempFile:close()

    os.remove(path)
    local okRename, renameErr = os.rename(tempPath, path)
    if not okRename then
        econWarn("No se pudo reemplazar money.json: " .. tostring(renameErr))
        return false
    end

    Economy.lastSavedPayload = payload
    Economy.lastWriteTime = timer.getTime()
    Economy.dirty = false
    econLog("money.json actualizado correctamente")
    return true
end

function Economy.syncTick(_, now)
    now = now or timer.getTime()

    if Economy.importWindowEndsAt and now >= Economy.importWindowEndsAt and not Economy.writeEnabled then
        Economy.writeEnabled = true
        Economy.dirty = true
        econLog("Ventana de importacion terminada. DCS toma el control del dinero.")
    end

    if Economy.writeEnabled and Economy.dirty then
        Economy.writeJsonToDisk(false)
    end

    return now + (Economy.config.autosaveInterval or 10)
end

function Economy.startJsonSync()
    if Economy.syncStarted then
        return
    end

    local importedData = Economy.readJsonFromDisk()
    if importedData then
        Economy.applyJsonToState(importedData)
    else
        Economy.dirty = true
    end

    Economy.importWindowEndsAt = timer.getTime() + (Economy.config.importWindowSeconds or 30)
    Economy.writeEnabled = false
    Economy.syncStarted = true

    timer.scheduleFunction(Economy.syncTick, nil, timer.getTime() + (Economy.config.autosaveInterval or 10))
    econWarn("Sync money.json iniciado. Ruta: " .. tostring(Economy.getJsonPath()))
end

local function countFactoriesInsideZone(cfg)
    local zona = trigger.misc.getZone(cfg.zoneName)
    if not zona then
        econWarn("Zona economica no encontrada: " .. tostring(cfg.zoneName))
        return 0
    end

    local activas = 0
    for _, staticName in ipairs(cfg.staticNames or {}) do
        local obj = StaticObject.getByName(staticName)
        if obj and obj:getLife() > 0 and obj:getCoalition() == cfg.coalition then
            local pos = obj:getPoint()
            local dx = pos.x - zona.point.x
            local dz = pos.z - zona.point.z
            local dist = math.sqrt(dx * dx + dz * dz)
            if dist <= zona.radius then
                activas = activas + 1
            end
        end
    end

    return activas
end

function Economy.generatorTick(index, now)
    local cfg = Economy.generators[index]
    if not cfg then
        return nil
    end

    local activas = countFactoriesInsideZone(cfg)
    if activas > 0 then
        local total = activas * (cfg.amountPerTick or 0)
        if total > 0 then
            Economy.add(cfg.coalition, total, "fabricas " .. tostring(cfg.id))
        end
        econLog("Generador " .. tostring(cfg.id) .. " | activas=" .. activas .. " | total=" .. total)
    end

    return now + (cfg.interval or 10)
end

function Economy.registerFactoryGenerator(cfg)
    if type(cfg) ~= "table" or not cfg.id then
        econWarn("Intento de registrar generador economico invalido")
        return false
    end

    for _, existing in ipairs(Economy.generators) do
        if existing.id == cfg.id then
            econLog("Generador ya registrado: " .. tostring(cfg.id))
            return true
        end
    end

    table.insert(Economy.generators, cfg)
    local index = #Economy.generators
    timer.scheduleFunction(function(_, now)
        return Economy.generatorTick(index, now)
    end, nil, timer.getTime() + (cfg.interval or 10))

    econWarn("Generador economico registrado: " .. tostring(cfg.id))
    return true
end

function Economy.init(config)
    if Economy.initialized then
        mergeConfig(Economy.config, config)
        Economy.debug = Economy.config.debug and true or false
        return Economy
    end

    mergeConfig(Economy.config, config)
    Economy.debug = Economy.config.debug and true or false
    Economy.initialized = true

    Economy.startJsonSync()
    econWarn("Nucleo economico inicializado")
    return Economy
end

return HDEV_Economy
