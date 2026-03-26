local lfs = require("lfs")

local RUTA_JSON = lfs.writedir() .. "Config\\Flag5000\\flag5000.json"
local INTERVALO = 1
local ultimoChequeo = 0
local ultimoValor = nil
local simulacionActiva = false

local function dbg(msg)
    if log and log.write then
        log.write("Flag5000Hook", log.INFO, tostring(msg))
    elseif net and net.log then
        net.log("[Flag5000Hook] " .. tostring(msg))
    end
end

local function leerArchivo(ruta)
    local f = io.open(ruta, "r")
    if not f then return nil end
    local contenido = f:read("*a")
    f:close()
    return contenido
end

local function extraerValorFlag5000(json)
    if not json then return nil end
    local valor = json:match('"flag5000"%s*:%s*(-?%d+)')
    if valor then
        return tonumber(valor)
    end
    return nil
end

local function enviarCambioAMision(valor)
    local script = string.format([[
        trigger.action.setUserFlag("5000", %d)
        trigger.action.outText("[DEBUG] Flag 5000 = %d", 8, false)
        return "OK"
    ]], valor, valor)

    local ok, res = pcall(function()
        return net.dostring_in("mission", script)
    end)

    if ok then
        dbg("Cambio enviado a mission. Flag 5000 = " .. tostring(valor))
    else
        dbg("Error enviando cambio a mission: " .. tostring(res))
    end
end

local function revisarJSON()
    local contenido = leerArchivo(RUTA_JSON)
    if not contenido then
        return
    end

    local valor = extraerValorFlag5000(contenido)
    if valor == nil then
        dbg("No se pudo leer flag5000 del JSON.")
        return
    end

    if ultimoValor == nil or valor ~= ultimoValor then
        ultimoValor = valor
        enviarCambioAMision(valor)
    end
end

local callbacks = {}

function callbacks.onSimulationStart()
    simulacionActiva = true
    ultimoChequeo = 0
    ultimoValor = nil
    dbg("Simulación iniciada.")
end

function callbacks.onSimulationStop()
    simulacionActiva = false
    dbg("Simulación detenida.")
end

function callbacks.onSimulationFrame()
    if not simulacionActiva then return end

    local ahora = DCS.getRealTime()
    if (ahora - ultimoChequeo) < INTERVALO then
        return
    end

    ultimoChequeo = ahora
    revisarJSON()
end

DCS.setUserCallbacks(callbacks)
dbg("Hook cargado. JSON: " .. RUTA_JSON)