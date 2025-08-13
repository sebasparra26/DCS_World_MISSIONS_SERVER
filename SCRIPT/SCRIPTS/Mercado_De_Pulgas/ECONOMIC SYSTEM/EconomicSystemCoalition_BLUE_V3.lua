-- =============================
-- Sistema Económico Azul V2 (corregido para funcionar con CTLD Hook)
-- =============================

local coalicion = 2  -- 1 = Rojo, 2 = Azul
local nombrePuntos = (coalicion == 1) and "PuntosROJO" or "PuntosAZUL"

-- Asegurarse de que la tabla global exista y sea accesible por el hook
puntosCoalicion = puntosCoalicion or { PuntosROJO = 0, PuntosAZUL = 0 }
_G.puntosCoalicion = puntosCoalicion

-- Array con nombres de fábricas estáticas
local zonaDeteccion = 'EconomicZoneBLUE'
local unidadesEstaticas = {
    "Factory_Blue_1", "Factory_Blue_2", "Factory_Blue_3", "Factory_Blue_4", "Factory_Blue_5", 
    "Factory_Blue_6", "Factory_Blue_7", "Factory_Blue_8", "Factory_Blue_9", "Factory_Blue_10"
}

-- Para debug en el log
local debugInfo = ""

-- Verifica si las fábricas están activas dentro de la zona y suman puntos
function verificarPuntos()
    local zona = trigger.misc.getZone(zonaDeteccion)
    if not zona then
        debugInfo = debugInfo .. "\n[DEBUG] La zona de detección no existe: " .. zonaDeteccion
        env.info(debugInfo)
        debugInfo = ""
        return
    end

    debugInfo = debugInfo .. "\n[DEBUG] Comprobando unidades en zona: " .. zonaDeteccion
    debugInfo = debugInfo .. "\n[DEBUG] Puntos actuales (" .. nombrePuntos .. "): " .. puntosCoalicion[nombrePuntos]

    for _, nombreUnidad in ipairs(unidadesEstaticas) do
        local unidad = StaticObject.getByName(nombreUnidad)

        if unidad and unidad:getLife() > 0 and unidad:getCoalition() == coalicion then
            local pos = unidad:getPoint()
            local distancia = ((pos.x - zona.point.x)^2 + (pos.z - zona.point.z)^2)^0.5

            if distancia <= zona.radius then
                puntosCoalicion[nombrePuntos] = puntosCoalicion[nombrePuntos] + 18515       -- 18518 (200M X 3 Horas), 46296 (500M x 3 Horas) ref
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

-- Función global para el Hook
function obtenerPuntosCoalicion(coalicion)
    local nombre = (coalicion == 1) and "PuntosROJO" or "PuntosAZUL"
    return puntosCoalicion[nombre]
end
_G.obtenerPuntosCoalicion = obtenerPuntosCoalicion

-- Iniciar el sistema económico (sin condicionales)
mist.scheduleFunction(verificarPuntos, {}, timer.getTime() + 10, 10)
env.info("[ECONOMIA] Sistema económico azul iniciado correctamente.")
