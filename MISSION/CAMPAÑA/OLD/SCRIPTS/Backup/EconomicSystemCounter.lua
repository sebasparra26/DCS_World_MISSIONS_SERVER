-- ===============================
-- MENÚ SIMPLE "BILLETERA" CON OPCIÓN DE ROJO
-- ===============================

-- Configuración
local intervaloMonitoreo = 10              -- Cada cuántos segundos mostrar (pantalla)
local mostrarRojo = true                  -- ← CAMBIA ESTO a true para multi, false para single
local menuBilleteraGlobal = missionCommands.addSubMenu("Billetera")

-- Inicializa tabla y campos si no existen
puntosCoalicion = puntosCoalicion or {}
puntosCoalicion.PuntosAZUL = puntosCoalicion.PuntosAZUL or 0
puntosCoalicion.PuntosROJO = puntosCoalicion.PuntosROJO or 0

-- Formatear como "1.250.000"
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

-- Mostrar puntos según configuración
local function mostrarPuntosBilletera()
    local azul = formatearDolaresLegible(puntosCoalicion.PuntosAZUL)
    local mensaje = "[Billetera]\nCoalición Azul: " .. azul

    if mostrarRojo then
        local rojo = formatearDolaresLegible(puntosCoalicion.PuntosROJO)
        mensaje = mensaje .. "\nCoalición Roja: " .. rojo
    end

    trigger.action.outText(mensaje, 10)
end

-- Opción de consulta manual
missionCommands.addCommand("Mostrar puntos", menuBilleteraGlobal, mostrarPuntosBilletera)

-- Auto actualizador cada X segundos
mist.scheduleFunction(function()
    mostrarPuntosBilletera()
    return timer.getTime() + intervaloMonitoreo
end, {}, timer.getTime() + intervaloMonitoreo)
