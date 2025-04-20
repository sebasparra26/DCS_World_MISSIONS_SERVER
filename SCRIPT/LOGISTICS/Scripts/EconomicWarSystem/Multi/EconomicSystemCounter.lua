if not puntosCoalicion then
    puntosCoalicion = { PuntosAZUL = 0, PuntosROJO = 0 }
end

-- Función para formatear los puntos como dólares con separador de miles y dos decimales
local function formatearDolares(valor)
    local entero, decimal = math.modf(valor)
    local partes = {}
    repeat
        table.insert(partes, 1, string.format("%03d", entero % 1000))
        entero = math.floor(entero / 1000)
    until entero == 0
    partes[1] = tostring(tonumber(partes[1]))  -- quitar ceros iniciales
    local miles = table.concat(partes, ",")
    return string.format("$%s%0.2f", miles, decimal):gsub("%.%d%d", function(dec) return dec end)
end

-- Función que muestra los puntos en pantalla cada 5 segundos
local function mostrarPuntosPeriodicamente()
    local mensaje = string.format(
        "Dollars BLUE: %s | Dollars RED: %s",
        formatearDolares(puntosCoalicion.PuntosAZUL),
        formatearDolares(puntosCoalicion.PuntosROJO)
    )
    trigger.action.outText(mensaje, 5)
    return timer.getTime() + 5
end

timer.scheduleFunction(mostrarPuntosPeriodicamente, {}, timer.getTime() + 1)

-- Menú "Billetera" accesible para todos
local menuBilletera = missionCommands.addSubMenu("Billetera")

missionCommands.addCommand("Ver puntos AZUL", menuBilletera, function()
    trigger.action.outText("Dólares actuales AZUL: " .. formatearDolares(puntosCoalicion.PuntosAZUL), 10)
end)

missionCommands.addCommand("Ver puntos ROJO", menuBilletera, function()
    trigger.action.outText("Dólares actuales ROJO: " .. formatearDolares(puntosCoalicion.PuntosROJO), 10)
end)
