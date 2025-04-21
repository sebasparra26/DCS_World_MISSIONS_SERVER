-- Activar o desactivar debug
local debugActivo = false

-- Estado de banderas: (Bandera, Valor)
estadoBanderasAeropuertos = {
    ["Kenley"] = { bandera = 100, valor = nil },
    ["Ford"] = { bandera = 101, valor = nil },
    ["Friston"] = { bandera = 102, valor = nil },
    ["Maupertus"] = { bandera = 103, valor = nil },
    ["Brucheville"] = { bandera = 104, valor = nil },
    ["Carpiquet"] = { bandera = 105, valor = nil },
    ["Ronai"] = { bandera = 106, valor = nil },
    ["Bernay Saint Martin"] = { bandera = 107, valor = nil },
    ["Barville"] = { bandera = 108, valor = nil },
    ["Evreux"] = { bandera = 109, valor = nil },
    ["Orly"] = { bandera = 110, valor = nil },
    ["Fecamp-Benouville"] = { bandera = 111, valor = nil },
    ["Saint-Aubin"] = { bandera = 112, valor = nil },
    ["Beauvais-Tille"] = { bandera = 113, valor = nil },
    ["Amiens-Glisy"] = { bandera = 114, valor = nil },
    ["Abbeville Drucat"] = { bandera = 115, valor = nil }
}

-- Posiciones y radios
local aeropuertos = {
    ["Kenley"] = { position = {x = 202873, y = 0, z = 6965}, radius = 6000 },
    ["Ford"] = { position = {x = 147466, y = 0, z = -25753}, radius = 5000 },
    ["Friston"] = { position = {x = 143314, y = 0, z = 28130}, radius = 5000 },
    ["Maupertus"] = { position = {x = 16011, y = 0, z = -84865}, radius = 6000 },
    ["Brucheville"] = { position = {x = -14865, y = 0, z = -66032}, radius = 5000 },
    ["Carpiquet"] = { position = {x = -34775, y = 0, z = -9992}, radius = 6000 },
    ["Ronai"] = { position = {x = -73108, y = 0, z = 12832}, radius = 5000 },
    ["Bernay Saint Martin"] = { position = {x = -39530, y = 0, z = 67036}, radius = 5000 },
    ["Barville"] = { position = {x = -109836, y = 0, z = 49213}, radius = 4000 },
    ["Evreux"] = { position = {x = -45924, y = 0, z = 112428}, radius = 4000 },
    ["Orly"] = { position = {x = -73529, y = 0, z = 200430}, radius = 12000 },
    ["Fecamp-Benouville"] = { position = {x = 31004, y = 0, z = 46274}, radius = 4000 },
    ["Saint-Aubin"] = { position = {x = 48979, y = 0, z = 97582}, radius = 4000 },
    ["Beauvais-Tille"] = { position = {x = 6070, y = 0, z = 175169}, radius = 5000 },
    ["Amiens-Glisy"] = { position = {x = 53411, y = 0, z = 191760}, radius = 5000 },
    ["Abbeville Drucat"] = { position = {x = 81026, y = 0, z = 150752}, radius = 5000 }
}

-- Colores para el marcador
local coloresPorCoalicion = {
    [1] = { contorno = {255, 0, 0, 255}, relleno = {255, 0, 0, 100} },
    [2] = { contorno = {0, 0, 255, 255}, relleno = {0, 0, 255, 100} },
    [0] = { contorno = {255, 255, 255, 255}, relleno = {255, 255, 255, 100} }
}

coalicionPorBase = coalicionPorBase or {}
controlAeropuertos = controlAeropuertos or {}  -- << Variable global accesible
local marcadores = {}

-- Función para actualizar marcador y bandera
local function actualizarMarcador(nombre, posicion, radio, nuevaCoalicion)
    coalicionPorBase[nombre] = nuevaCoalicion
    controlAeropuertos[nombre] = nuevaCoalicion  -- << Actualiza variable global

    local valor = (nuevaCoalicion == 2 and 1) or (nuevaCoalicion == 0 and 2) or 3
    local info = estadoBanderasAeropuertos[nombre]

    if info and info.valor ~= valor then
        info.valor = valor
        trigger.action.setUserFlag(info.bandera, valor)

        local banderaLeida = trigger.misc.getUserFlag(info.bandera)
        local nombreCoalicion = (valor == 1 and "AZUL") or (valor == 2 and "NEUTRAL") or "ROJO"
        local mensaje = nombre .. " → (Bandera: " .. info.bandera .. ", Valor: " .. valor .. ") - " .. nombreCoalicion .. " | Leído: " .. banderaLeida

        trigger.action.outText(mensaje, 10)
        env.info("[DEBUG BANDERA] " .. mensaje)
    end

    if marcadores[nombre] then
        mist.marker.remove(marcadores[nombre])
    end

    local colorSet = coloresPorCoalicion[nuevaCoalicion] or coloresPorCoalicion[0]

    marcadores[nombre] = mist.marker.add({
        name = "Marker_" .. nombre,
        type = "circle",
        point = posicion,
        radius = radio,
        color = colorSet.contorno,
        fillColor = colorSet.relleno,
        lineType = 0,
        visible = true,
        coalition = 0,
        life = 3600,
        text = nombre
    })
end

-- Función de verificación global
local function verificarControlAeropuertos()
    local basesAzules = coalition.getAirbases(2)
    local basesRojas  = coalition.getAirbases(1)

    for nombre, data in pairs(aeropuertos) do
        local estaAzul, estaRojo = false, false

        for _, base in ipairs(basesAzules) do
            if base:getName() == nombre then estaAzul = true break end
        end
        for _, base in ipairs(basesRojas) do
            if base:getName() == nombre then estaRojo = true break end
        end

        local coalicion = 0
        if estaAzul then coalicion = 2
        elseif estaRojo then coalicion = 1 end

        actualizarMarcador(nombre, data.position, data.radius, coalicion)
    end

    if debugActivo then
        trigger.action.outText("Resumen banderas activas:", 10)
        for nombre, info in pairs(estadoBanderasAeropuertos) do
            if info.valor then
                local msg = nombre .. " → (Bandera: " .. info.bandera .. ", Valor: " .. info.valor .. ")"
                trigger.action.outText(msg, 10)
                env.info(msg)
            end
        end
    end
end

-- Iniciar verificación cíclica
timer.scheduleFunction(function()
    verificarControlAeropuertos()
    return timer.getTime() + 60
end, {}, timer.getTime() + 1)
