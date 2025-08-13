-- =============================
-- Sistema Económico Rojo V2 (corregido para funcionar con CTLD Hook)
-- =============================

local coalicion = 1  -- 1 = Rojo, 2 = Azul
local nombrePuntos = (coalicion == 1) and "PuntosROJO" or "PuntosAZUL"

-- Asegurar visibilidad global para el hook
puntosCoalicion = puntosCoalicion or { PuntosROJO = 0, PuntosAZUL = 0 }
_G.puntosCoalicion = puntosCoalicion

-- Zona de detección y unidades
local zonaDeteccion = 'EconomicZoneRED'
local unidadesEstaticas = {
    "Factory_RED_1", "Factory_RED_2", "Factory_RED_3", "Factory_RED_4", "Factory_RED_5", 
    "Factory_RED_6", "Factory_RED_7", "Factory_RED_8", "Factory_RED_9", "Factory_RED_10"
}

-- Para imprimir información en el log
local debugInfo = ""

-- Función principal de verificación de fábricas
function verificarPuntos()
    local zona = trigger.misc.getZone(zonaDeteccion)
    if not zona then
        debugInfo = debugInfo .. "\n[DEBUG] Zona no encontrada: " .. zonaDeteccion
        env.info(debugInfo)
        debugInfo = ""
        return
    end

    debugInfo = debugInfo .. "\n[DEBUG] Iniciando verificación en: " .. zonaDeteccion
    debugInfo = debugInfo .. "\n[DEBUG] Puntos actuales (" .. nombrePuntos .. "): " .. puntosCoalicion[nombrePuntos]

    for _, nombreUnidad in ipairs(unidadesEstaticas) do
        local unidad = StaticObject.getByName(nombreUnidad)

        if unidad and unidad:getLife() > 0 and unidad:getCoalition() == coalicion then
            local pos = unidad:getPoint()
            local distancia = ((pos.x - zona.point.x)^2 + (pos.z - zona.point.z)^2)^0.5

            if distancia <= zona.radius then
                puntosCoalicion[nombrePuntos] = puntosCoalicion[nombrePuntos] + 18515 -- 18518 (200M X 3 Horas), 46296 (500M x 3 Horas) ref
                debugInfo = debugInfo .. "\n[DEBUG] " .. nombreUnidad .. " generó puntos. Total: " .. puntosCoalicion[nombrePuntos]
            else
                debugInfo = debugInfo .. "\n[DEBUG] " .. nombreUnidad .. " fuera de la zona"
            end
        else
            debugInfo = debugInfo .. "\n[DEBUG] " .. nombreUnidad .. " no encontrada o destruida"
        end
    end

    env.info(debugInfo)
    debugInfo = ""
end

-- Función global para acceso desde el hook CTLD
function obtenerPuntosCoalicion(coalicion)
    local nombre = (coalicion == 1) and "PuntosROJO" or "PuntosAZUL"
    return puntosCoalicion[nombre]
end
_G.obtenerPuntosCoalicion = obtenerPuntosCoalicion

-- Activar chequeo periódico sin condiciones globales
mist.scheduleFunction(verificarPuntos, {}, timer.getTime() + 10, 10)
env.info("[ECONOMIA] Sistema económico rojo iniciado correctamente.")
