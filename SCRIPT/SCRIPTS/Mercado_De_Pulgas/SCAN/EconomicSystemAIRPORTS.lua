-- Activar o desactivar debug
local debugActivo = false

-- Colores para el marcador
local coloresPorCoalicion = {
    [1] = { contorno = {255, 0, 0, 255}, relleno = {255, 0, 0, 60} },
    [2] = { contorno = {0, 0, 255, 255}, relleno = {0, 0, 255, 60} },
    [0] = { contorno = {255, 255, 255, 255}, relleno = {255, 255, 255, 60} }
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
