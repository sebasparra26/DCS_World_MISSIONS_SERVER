-- ===============================
-- MENU SIMPLE "BILLETERA" CON OPCION DE ROJO
-- ===============================

-- Configuracion
local intervaloMonitoreo = 60              -- Cada cuantos segundos mostrar en pantalla
local mostrarRojo = true                   -- Cambiar a false si solo se muestra Azul
local menuBilleteraGlobal = missionCommands.addSubMenu("Billetera")

-- Inicializa tabla y campos si no existen
puntosCoalicion = puntosCoalicion or {}
puntosCoalicion.PuntosAZUL = puntosCoalicion.PuntosAZUL or 0
puntosCoalicion.PuntosROJO = puntosCoalicion.PuntosROJO or 0

-- Formatear como "1.250.000" sin decimales
local function formatearDolaresLegible(valor)
    if type(valor) ~= "number" then return "$0" end
    local entero = math.floor(valor)
    local partes = {}
    repeat
        table.insert(partes, 1, string.format("%03d", entero % 1000))
        entero = math.floor(entero / 1000)
    until entero == 0
    partes[1] = tostring(tonumber(partes[1]))
    return "$" .. table.concat(partes, ".")
end

-- Mostrar puntos en pantalla
local function mostrarPuntosBilletera()
    local azul = formatearDolaresLegible(puntosCoalicion.PuntosAZUL)
    local mensaje = "[Billetera]\nCoalicion Azul: " .. azul

    if mostrarRojo then
        local rojo = formatearDolaresLegible(puntosCoalicion.PuntosROJO)
        mensaje = mensaje .. "\nCoalicion Roja: " .. rojo
    end

    trigger.action.outText(mensaje, 5)
end

-- Opcion de consulta manual desde el menu de radio
missionCommands.addCommand("Mostrar puntos", menuBilleteraGlobal, mostrarPuntosBilletera)

-- Actualizador automatico cada X segundos
timer.scheduleFunction(function()
    mostrarPuntosBilletera()
    return timer.getTime() + intervaloMonitoreo
end, {}, timer.getTime() + intervaloMonitoreo)

-- Confirmacion de carga del sistema
trigger.action.outText("Sistema de billetera cargado correctamente", 10)
