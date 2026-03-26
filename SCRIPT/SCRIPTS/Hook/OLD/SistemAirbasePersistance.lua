SistemAirbasePersistance = SistemAirbasePersistance or {}

SistemAirbasePersistance.config = {
    rutaJSON = lfs.writedir() .. "Config\\HorizontDev\\SistemAirbasePersistanceNormandia.json",
    intervalo = 1,

    activarDCSaJSON = true,
    activarJSONaDCS = true,
    jsonADCS_enVivo = true,

    reactivarAutoCaptureDespuesDeAplicar = true,
    retrasoReactivarAutoCapture = 2,
    bloquearSincronizacionDuranteInyeccion = true,
    duracionBloqueoPostInyeccion = 80,

    debugLog = true,
    debugPantalla = true,
    debugDuracion = 8,

    airbases = {
        "Alderney",
        "Maupertus"
    }
}

SistemAirbasePersistance.estado = {
    iniciado = false,
    ultimoEstado = {},
    ultimoContenidoJSON = nil,
    bloqueoHasta = 0
}

function SistemAirbasePersistance.log(msg, enPantalla)
    local texto = "[SistemAirbasePersistance] " .. tostring(msg)

    if SistemAirbasePersistance.config.debugLog and env and env.info then
        env.info(texto)
    end

    if SistemAirbasePersistance.config.debugPantalla and enPantalla then
        trigger.action.outText(texto, SistemAirbasePersistance.config.debugDuracion, false)
    end
end

function SistemAirbasePersistance.copiarTabla(origen)
    local copia = {}
    for k, v in pairs(origen) do
        copia[k] = v
    end
    return copia
end

function SistemAirbasePersistance.asegurarDirectorios()
    local base = lfs.writedir()
    lfs.mkdir(base .. "Config")
    lfs.mkdir(base .. "Config\\SistemAirbasePersistance")
end

function SistemAirbasePersistance.leerArchivo(ruta)
    local f = io.open(ruta, "r")
    if not f then
        return nil
    end

    local contenido = f:read("*a")
    f:close()
    return contenido
end

function SistemAirbasePersistance.escribirArchivo(ruta, contenido)
    SistemAirbasePersistance.asegurarDirectorios()

    local f = io.open(ruta, "w")
    if not f then
        SistemAirbasePersistance.log("No se pudo escribir: " .. tostring(ruta), true)
        return false
    end

    f:write(contenido)
    f:close()
    return true
end

function SistemAirbasePersistance.coalicionJSONValida(v)
    return v == 0 or v == 1 or v == 2
end

function SistemAirbasePersistance.normalizarCoalicionDCS(v)
    if v == 0 or v == 1 or v == 2 then
        return v
    end

    if v == 3 then
        return 0
    end

    return nil
end

function SistemAirbasePersistance.estaBloqueado()
    return timer.getTime() < (SistemAirbasePersistance.estado.bloqueoHasta or 0)
end

function SistemAirbasePersistance.iniciarBloqueo(segundos, motivo)
    local ahora = timer.getTime()
    SistemAirbasePersistance.estado.bloqueoHasta = ahora + segundos
    SistemAirbasePersistance.log("Bloqueo temporal iniciado (" .. tostring(motivo) .. ") por " .. tostring(segundos) .. " s", true)
end

function SistemAirbasePersistance.extraerAirbasesDesdeJSON(json)
    local data = {}

    if not json then
        return data
    end

    for nombre, valor in json:gmatch('"([^"]+)"%s*:%s*(-?%d+)') do
        local coalicion = tonumber(valor)

        if SistemAirbasePersistance.coalicionJSONValida(coalicion) then
            data[nombre] = coalicion
        end
    end

    return data
end

function SistemAirbasePersistance.construirJSON(data)
    local lineas = {}
    lineas[#lineas + 1] = "{"

    for i = 1, #SistemAirbasePersistance.config.airbases do
        local nombre = SistemAirbasePersistance.config.airbases[i]
        local valor = tonumber(data[nombre]) or 0
        local coma = ","

        if i == #SistemAirbasePersistance.config.airbases then
            coma = ""
        end

        lineas[#lineas + 1] = string.format('  "%s": %d%s', nombre, valor, coma)
    end

    lineas[#lineas + 1] = "}"

    return table.concat(lineas, "\n")
end

function SistemAirbasePersistance.reactivarAutoCaptureDespues(nombre)
    if not SistemAirbasePersistance.config.reactivarAutoCaptureDespuesDeAplicar then
        return
    end

    timer.scheduleFunction(function()
        local ab = Airbase.getByName(nombre)
        if ab and ab.autoCapture then
            ab:autoCapture(true)
            SistemAirbasePersistance.log("autoCapture reactivado: " .. nombre, true)
        end
    end, {}, timer.getTime() + SistemAirbasePersistance.config.retrasoReactivarAutoCapture)
end

function SistemAirbasePersistance.capturarEstadoDCS()
    local data = {}

    for i = 1, #SistemAirbasePersistance.config.airbases do
        local nombre = SistemAirbasePersistance.config.airbases[i]
        local ab = Airbase.getByName(nombre)

        if ab then
            local coaBruta = ab:getCoalition()
            local coa = SistemAirbasePersistance.normalizarCoalicionDCS(coaBruta)

            if coa ~= nil then
                data[nombre] = coa
            else
                data[nombre] = tonumber(SistemAirbasePersistance.estado.ultimoEstado[nombre]) or 0
                SistemAirbasePersistance.log("Coalicion invalida en " .. nombre .. ": " .. tostring(coaBruta), true)
            end
        else
            data[nombre] = tonumber(SistemAirbasePersistance.estado.ultimoEstado[nombre]) or 0
            SistemAirbasePersistance.log("Base no encontrada: " .. tostring(nombre), true)
        end
    end

    return data
end

function SistemAirbasePersistance.aplicarJSONaDCS(data, origen)
    local cambios = {}
    local errores = {}

    if SistemAirbasePersistance.config.bloquearSincronizacionDuranteInyeccion then
        SistemAirbasePersistance.iniciarBloqueo(SistemAirbasePersistance.config.duracionBloqueoPostInyeccion, origen)
    end

    for i = 1, #SistemAirbasePersistance.config.airbases do
        local nombre = SistemAirbasePersistance.config.airbases[i]
        local coaJSON = data[nombre]

        if coaJSON ~= nil and SistemAirbasePersistance.coalicionJSONValida(coaJSON) then
            local ab = Airbase.getByName(nombre)

            if not ab then
                errores[#errores + 1] = "No encontrada: " .. nombre
            else
                local coaActual = SistemAirbasePersistance.normalizarCoalicionDCS(ab:getCoalition()) or 0

                if coaActual ~= coaJSON then
                    if ab.autoCapture then
                        ab:autoCapture(false)
                    end

                    if ab.setCoalition then
                        ab:setCoalition(coaJSON)
                        SistemAirbasePersistance.reactivarAutoCaptureDespues(nombre)
                        cambios[#cambios + 1] = nombre .. " = " .. tostring(coaJSON)
                    else
                        errores[#errores + 1] = "setCoalition no disponible en: " .. nombre
                    end
                end
            end
        end
    end

    if #cambios > 0 then
        SistemAirbasePersistance.log(origen .. " aplicó:\n" .. table.concat(cambios, "\n"), true)
    else
        SistemAirbasePersistance.log(origen .. " no aplicó cambios.", true)
    end

    if #errores > 0 then
        SistemAirbasePersistance.log("Errores:\n" .. table.concat(errores, "\n"), true)
    end

    SistemAirbasePersistance.estado.ultimoEstado = SistemAirbasePersistance.capturarEstadoDCS()
end

function SistemAirbasePersistance.guardarDCSaJSON(origen)
    local data = SistemAirbasePersistance.capturarEstadoDCS()
    local contenido = SistemAirbasePersistance.construirJSON(data)

    if SistemAirbasePersistance.escribirArchivo(SistemAirbasePersistance.config.rutaJSON, contenido) then
        SistemAirbasePersistance.estado.ultimoEstado = SistemAirbasePersistance.copiarTabla(data)
        SistemAirbasePersistance.estado.ultimoContenidoJSON = contenido
        SistemAirbasePersistance.log("DCS -> JSON actualizado (" .. tostring(origen) .. ")", true)
    end
end

function SistemAirbasePersistance.hayCambiosDCS()
    for i = 1, #SistemAirbasePersistance.config.airbases do
        local nombre = SistemAirbasePersistance.config.airbases[i]
        local ab = Airbase.getByName(nombre)

        if ab then
            local actual = SistemAirbasePersistance.normalizarCoalicionDCS(ab:getCoalition())
            local previo = tonumber(SistemAirbasePersistance.estado.ultimoEstado[nombre]) or 0

            if actual ~= nil and actual ~= previo then
                SistemAirbasePersistance.log("Cambio detectado en DCS: " .. nombre .. " -> " .. tostring(actual), true)
                return true
            end
        end
    end

    return false
end

function SistemAirbasePersistance.cargarJSONInicial()
    local contenido = SistemAirbasePersistance.leerArchivo(SistemAirbasePersistance.config.rutaJSON)

    if not contenido or contenido == "" then
        SistemAirbasePersistance.log("No existe JSON inicial. Se creará con el estado actual de DCS.", true)
        SistemAirbasePersistance.estado.ultimoEstado = SistemAirbasePersistance.capturarEstadoDCS()
        SistemAirbasePersistance.guardarDCSaJSON("inicio_sin_archivo")
        return
    end

    SistemAirbasePersistance.estado.ultimoContenidoJSON = contenido

    if SistemAirbasePersistance.config.activarJSONaDCS then
        local data = SistemAirbasePersistance.extraerAirbasesDesdeJSON(contenido)
        SistemAirbasePersistance.aplicarJSONaDCS(data, "JSON inicial")
    else
        SistemAirbasePersistance.estado.ultimoEstado = SistemAirbasePersistance.capturarEstadoDCS()
    end
end

function SistemAirbasePersistance.revisarDCSenVivo()
    if not SistemAirbasePersistance.config.activarDCSaJSON then
        return
    end

    if SistemAirbasePersistance.estaBloqueado() then
        return
    end

    if SistemAirbasePersistance.hayCambiosDCS() then
        SistemAirbasePersistance.guardarDCSaJSON("cambio_en_dcs")
    end
end

function SistemAirbasePersistance.revisarJSONenVivo()
    if not SistemAirbasePersistance.config.activarJSONaDCS then
        return
    end

    if not SistemAirbasePersistance.config.jsonADCS_enVivo then
        return
    end

    if SistemAirbasePersistance.estaBloqueado() then
        return
    end

    local contenido = SistemAirbasePersistance.leerArchivo(SistemAirbasePersistance.config.rutaJSON)

    if not contenido or contenido == "" then
        return
    end

    if contenido ~= SistemAirbasePersistance.estado.ultimoContenidoJSON then
        SistemAirbasePersistance.estado.ultimoContenidoJSON = contenido
        SistemAirbasePersistance.log("Cambio detectado en JSON.", true)

        local data = SistemAirbasePersistance.extraerAirbasesDesdeJSON(contenido)
        SistemAirbasePersistance.aplicarJSONaDCS(data, "JSON en vivo")
    end
end

function SistemAirbasePersistance.debugInicial()
    local lineas = {}
    lineas[#lineas + 1] = "Chequeo inicial"

    for i = 1, #SistemAirbasePersistance.config.airbases do
        local nombre = SistemAirbasePersistance.config.airbases[i]
        local ab = Airbase.getByName(nombre)

        if ab then
            local coaBruta = ab:getCoalition()
            local coa = SistemAirbasePersistance.normalizarCoalicionDCS(coaBruta)
            lineas[#lineas + 1] = nombre .. " OK bruta=" .. tostring(coaBruta) .. " normalizada=" .. tostring(coa)
        else
            lineas[#lineas + 1] = nombre .. " NO_ENCONTRADA"
        end
    end

    SistemAirbasePersistance.log(table.concat(lineas, "\n"), true)
end

function SistemAirbasePersistance.main()
    if not SistemAirbasePersistance.estado.iniciado then
        SistemAirbasePersistance.estado.iniciado = true
        SistemAirbasePersistance.log("Script cargado. Ruta JSON: " .. tostring(SistemAirbasePersistance.config.rutaJSON), true)
        SistemAirbasePersistance.debugInicial()
        SistemAirbasePersistance.cargarJSONInicial()
    else
        SistemAirbasePersistance.revisarDCSenVivo()
        SistemAirbasePersistance.revisarJSONenVivo()
    end

    return timer.getTime() + SistemAirbasePersistance.config.intervalo
end

timer.scheduleFunction(function()
    return SistemAirbasePersistance.main()
end, {}, timer.getTime() + 1)