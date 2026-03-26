SistemFlagPersistance = SistemFlagPersistance or {}

SistemFlagPersistance.config = {
    rutaJSON = lfs.writedir() .. "Config\\SistemFlagPersistance\\SistemFlagPersistance.json",
    intervalo = 1,
    flagMin = 100,
    flagMax = 200,

    aplicarJSONalInicio = true,      -- lee el JSON al arrancar
    aplicarSoloNoCero = true,        -- si la flag en JSON es 0, no toca nada al inicio

    activarDCSaJSON = true,          -- durante la misión, DCS escribe al JSON
    activarJSONaDCSenVivo = false,   -- apagado: no queremos que el JSON mande mientras corre la misión

    debugLog = true,
    debugPantalla = true,
    debugDuracion = 8
}

SistemFlagPersistance.estado = {
    ultimoEstadoFlags = {},
    ultimoContenidoJSON = nil,
    iniciado = false
}

function SistemFlagPersistance.log(msg, enPantalla)
    local texto = "[SistemFlagPersistance] " .. tostring(msg)

    if SistemFlagPersistance.config.debugLog and env and env.info then
        env.info(texto)
    end

    if SistemFlagPersistance.config.debugPantalla and enPantalla then
        trigger.action.outText(texto, SistemFlagPersistance.config.debugDuracion, false)
    end
end

function SistemFlagPersistance.copiarTabla(tablaOrigen)
    local copia = {}
    for k, v in pairs(tablaOrigen) do
        copia[k] = v
    end
    return copia
end

function SistemFlagPersistance.leerArchivo(ruta)
    local f = io.open(ruta, "r")
    if not f then
        return nil
    end

    local contenido = f:read("*a")
    f:close()
    return contenido
end

function SistemFlagPersistance.escribirArchivo(ruta, contenido)
    local f = io.open(ruta, "w")
    if not f then
        SistemFlagPersistance.log("No se pudo escribir el archivo: " .. tostring(ruta), true)
        return false
    end

    f:write(contenido)
    f:close()
    return true
end

function SistemFlagPersistance.extraerFlagsDesdeJSON(json)
    local flags = {}

    if not json then
        return flags
    end

    for clave, valor in json:gmatch('"(%d+)"%s*:%s*(-?%d+)') do
        local numFlag = tonumber(clave)
        local numValor = tonumber(valor)

        if numFlag and numValor then
            if numFlag >= SistemFlagPersistance.config.flagMin and numFlag <= SistemFlagPersistance.config.flagMax then
                flags[numFlag] = numValor
            end
        end
    end

    return flags
end

function SistemFlagPersistance.construirJSONDesdeFlags(flags)
    local lineas = {}
    lineas[#lineas + 1] = "{"

    for flag = SistemFlagPersistance.config.flagMin, SistemFlagPersistance.config.flagMax do
        local valor = tonumber(flags[flag]) or 0
        local coma = ","

        if flag == SistemFlagPersistance.config.flagMax then
            coma = ""
        end

        lineas[#lineas + 1] = string.format('  "%d": %d%s', flag, valor, coma)
    end

    lineas[#lineas + 1] = "}"

    return table.concat(lineas, "\n")
end

function SistemFlagPersistance.capturarFlagsDesdeDCS()
    local flags = {}

    for flag = SistemFlagPersistance.config.flagMin, SistemFlagPersistance.config.flagMax do
        flags[flag] = tonumber(trigger.misc.getUserFlag(tostring(flag))) or 0
    end

    return flags
end

function SistemFlagPersistance.aplicarFlagsJSONalInicio(flagsJSON)
    local cambios = {}

    for flag = SistemFlagPersistance.config.flagMin, SistemFlagPersistance.config.flagMax do
        local valorJSON = flagsJSON[flag]

        if valorJSON ~= nil then
            if SistemFlagPersistance.config.aplicarSoloNoCero and valorJSON == 0 then
                -- no hace nada; deja la misión como venga
            else
                local valorActual = tonumber(trigger.misc.getUserFlag(tostring(flag))) or 0

                if valorActual ~= valorJSON then
                    trigger.action.setUserFlag(tostring(flag), valorJSON)
                    cambios[#cambios + 1] = "Flag " .. tostring(flag) .. " = " .. tostring(valorJSON)
                end
            end
        end
    end

    if #cambios > 0 then
        SistemFlagPersistance.log("JSON inicial aplicó:\n" .. table.concat(cambios, "\n"), true)
    else
        SistemFlagPersistance.log("JSON inicial no aplicó cambios.", true)
    end
end

function SistemFlagPersistance.guardarDCSaJSON(origen)
    local flagsActuales = SistemFlagPersistance.capturarFlagsDesdeDCS()
    local contenidoNuevo = SistemFlagPersistance.construirJSONDesdeFlags(flagsActuales)

    local ok = SistemFlagPersistance.escribirArchivo(SistemFlagPersistance.config.rutaJSON, contenidoNuevo)
    if ok then
        SistemFlagPersistance.estado.ultimoEstadoFlags = SistemFlagPersistance.copiarTabla(flagsActuales)
        SistemFlagPersistance.estado.ultimoContenidoJSON = contenidoNuevo
        SistemFlagPersistance.log("JSON actualizado desde DCS (" .. tostring(origen) .. ")", false)
    end
end

function SistemFlagPersistance.hayCambiosDCS()
    for flag = SistemFlagPersistance.config.flagMin, SistemFlagPersistance.config.flagMax do
        local valorActual = tonumber(trigger.misc.getUserFlag(tostring(flag))) or 0
        local valorPrevio = tonumber(SistemFlagPersistance.estado.ultimoEstadoFlags[flag]) or 0

        if valorActual ~= valorPrevio then
            return true
        end
    end

    return false
end

function SistemFlagPersistance.cargarJSONInicial()
    local contenido = SistemFlagPersistance.leerArchivo(SistemFlagPersistance.config.rutaJSON)

    if not contenido or contenido == "" then
        SistemFlagPersistance.log("No existe JSON inicial. Se creará con el estado actual de DCS.", true)
        SistemFlagPersistance.estado.ultimoEstadoFlags = SistemFlagPersistance.capturarFlagsDesdeDCS()
        SistemFlagPersistance.guardarDCSaJSON("inicio_sin_archivo")
        return
    end

    SistemFlagPersistance.estado.ultimoContenidoJSON = contenido

    if SistemFlagPersistance.config.aplicarJSONalInicio then
        local flagsJSON = SistemFlagPersistance.extraerFlagsDesdeJSON(contenido)
        SistemFlagPersistance.aplicarFlagsJSONalInicio(flagsJSON)
    end

    SistemFlagPersistance.estado.ultimoEstadoFlags = SistemFlagPersistance.capturarFlagsDesdeDCS()

    if SistemFlagPersistance.config.activarDCSaJSON then
        SistemFlagPersistance.guardarDCSaJSON("sincronizacion_inicial")
    end
end

function SistemFlagPersistance.revisarJSONenVivo()
    if not SistemFlagPersistance.config.activarJSONaDCSenVivo then
        return
    end

    local contenido = SistemFlagPersistance.leerArchivo(SistemFlagPersistance.config.rutaJSON)
    if not contenido or contenido == "" then
        return
    end

    if contenido ~= SistemFlagPersistance.estado.ultimoContenidoJSON then
        SistemFlagPersistance.estado.ultimoContenidoJSON = contenido
        local flagsJSON = SistemFlagPersistance.extraerFlagsDesdeJSON(contenido)

        local cambios = {}
        for flag = SistemFlagPersistance.config.flagMin, SistemFlagPersistance.config.flagMax do
            local valorJSON = flagsJSON[flag]
            if valorJSON ~= nil then
                local valorActual = tonumber(trigger.misc.getUserFlag(tostring(flag))) or 0
                if valorActual ~= valorJSON then
                    trigger.action.setUserFlag(tostring(flag), valorJSON)
                    cambios[#cambios + 1] = "Flag " .. tostring(flag) .. " = " .. tostring(valorJSON)
                end
            end
        end

        if #cambios > 0 then
            SistemFlagPersistance.log("JSON en vivo aplicó:\n" .. table.concat(cambios, "\n"), true)
        end

        SistemFlagPersistance.estado.ultimoEstadoFlags = SistemFlagPersistance.capturarFlagsDesdeDCS()
    end
end

function SistemFlagPersistance.revisarDCSenVivo()
    if not SistemFlagPersistance.config.activarDCSaJSON then
        return
    end

    if SistemFlagPersistance.hayCambiosDCS() then
        SistemFlagPersistance.guardarDCSaJSON("cambio_en_dcs")
    end
end

function SistemFlagPersistance.main()
    if not SistemFlagPersistance.estado.iniciado then
        SistemFlagPersistance.estado.iniciado = true
        SistemFlagPersistance.log("Script cargado. Ruta JSON: " .. tostring(SistemFlagPersistance.config.rutaJSON), true)
        SistemFlagPersistance.cargarJSONInicial()
    else
        SistemFlagPersistance.revisarJSONenVivo()
        SistemFlagPersistance.revisarDCSenVivo()
    end

    return timer.getTime() + SistemFlagPersistance.config.intervalo
end

timer.scheduleFunction(function()
    return SistemFlagPersistance.main()
end, {}, timer.getTime() + 1)