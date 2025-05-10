local debugActivo = false

-- Tabla de colores (formato original 0–255)
local coloresPorCoalicion = {
    [1] = { contorno = {255, 0, 0, 255}, relleno = {255, 0, 0, 100} },    -- ROJO
    [2] = { contorno = {0, 0, 255, 255}, relleno = {0, 0, 255, 100} },    -- AZUL
    [0] = { contorno = {255, 255, 255, 255}, relleno = {255, 255, 255, 100} } -- NEUTRAL
}

coalicionPorBase = coalicionPorBase or {}
controlAeropuertos = controlAeropuertos or {}
local marcadores = {}

-- Convierte un color de 0–255 a 0–1 para MIST
local function normalizarColor(color255)
    return {
        (color255[1] or 255) / 255,
        (color255[2] or 255) / 255,
        (color255[3] or 255) / 255,
        (color255[4] or 255) / 255
    }
end

-- Función principal para crear/actualizar el marcador y bandera
local function actualizarMarcador(nombre, posicion, radio, nuevaCoalicion)
    coalicionPorBase[nombre] = nuevaCoalicion
    controlAeropuertos[nombre] = nuevaCoalicion

    local valor = (nuevaCoalicion == 2 and 1) or (nuevaCoalicion == 0 and 2) or 3
    local info = estadoBanderasAeropuertos[nombre]

    if info and info.valor ~= valor then
        info.valor = valor
        trigger.action.setUserFlag(info.bandera, valor)

        local banderaLeida = trigger.misc.getUserFlag(info.bandera)
        local nombreCoalicion = (valor == 1 and "AZUL") or (valor == 2 and "NEUTRAL") or "ROJO"
        local mensaje = nombre .. " - Bandera: " .. info.bandera .. ", Valor: " .. valor .. " - " .. nombreCoalicion .. " (Leído: " .. banderaLeida .. ")"
        trigger.action.outText(mensaje, 10)
    end

    if marcadores[nombre] then
        mist.marker.remove(marcadores[nombre])
    end

    local puntoSeguro = {
        x = (posicion and type(posicion.x) == "number") and posicion.x or 0,
        y = (posicion and type(posicion.y) == "number") and posicion.y or 0,
        z = (posicion and type(posicion.z) == "number") and posicion.z or 0
    }

    local colorSet = coloresPorCoalicion[nuevaCoalicion] or coloresPorCoalicion[0]
    local color = normalizarColor(colorSet.contorno)
    local fillColor = normalizarColor(colorSet.relleno)

    local radioSeguro = (type(radio) == "number") and radio or 1000

    marcadores[nombre] = mist.marker.add({
        name = "Marker_" .. nombre,
        type = "circle",
        point = puntoSeguro,
        radius = radioSeguro,
        color = color,
        fillColor = fillColor,
        lineType = 0,
        visible = true,
        coalition = 0,
        life = 3600,
        text = nombre
    })
end

-- Verifica el estado de control de cada aeropuerto y actualiza marcador/bandera
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

        if data and type(data.position) == "table" then
            actualizarMarcador(nombre, data.position, data.radius, coalicion)
        else
            trigger.action.outText("ERROR: Aeropuerto mal definido: " .. tostring(nombre), 10)
        end
    end

    if debugActivo then
        trigger.action.outText("Resumen banderas activas:", 10)
        for nombre, info in pairs(estadoBanderasAeropuertos) do
            if info.valor then
                local msg = nombre .. " - Bandera: " .. info.bandera .. ", Valor: " .. info.valor
                trigger.action.outText(msg, 10)
            end
        end
    end
end

-- Ejecutar verificación periódica cada 60 segundos
timer.scheduleFunction(function()
    verificarControlAeropuertos()
    return timer.getTime() + 60
end, {}, timer.getTime() + 1)
