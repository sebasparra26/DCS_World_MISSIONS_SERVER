-- Variables principales
local coalicion = 2  -- 1 = Rojo, 2 = Azul (ajustar según necesidad)
local nombrePuntos = (coalicion == 1) and "PuntosROJO" or "PuntosAZUL"
puntosCoalicion = puntosCoalicion or { PuntosROJO = 0, PuntosAZUL = 0 }

local zonaDeteccion = 'EconomicZoneBLUE'

-- Array con los nombres de las unidades estáticas a detectar
local unidadesEstaticas = {
    "Factory_Blue_1", "Factory_Blue_2", "Factory_Blue_3", "Factory_Blue_4", "Factory_Blue_5", 
    "Factory_Blue_6", "Factory_Blue_7", "Factory_Blue_8", "Factory_Blue_9", "Factory_Blue_10"
}

-- Variable para almacenar información de depuración general
local debugInfo = ""

-- Función para verificar si las unidades están dentro de la zona
function verificarPuntos()
    local zona = trigger.misc.getZone(zonaDeteccion)
    if not zona then
        debugInfo = debugInfo .. "\n[DEBUG] La zona de detección no existe: " .. zonaDeteccion
        env.info(debugInfo)
        debugInfo = ""
        return
    end

    debugInfo = debugInfo .. "\n[DEBUG] Comenzando verificación de unidades en la zona: " .. zonaDeteccion
    debugInfo = debugInfo .. "\n[DEBUG] Puntos actuales para " .. nombrePuntos .. ": " .. puntosCoalicion[nombrePuntos]

    for _, nombreUnidad in ipairs(unidadesEstaticas) do
        local unidad = StaticObject.getByName(nombreUnidad)

        if unidad and unidad:getLife() > 0 and unidad:getCoalition() == coalicion then
            local pos = unidad:getPoint()
            local distancia = ((pos.x - zona.point.x)^2 + (pos.z - zona.point.z)^2)^0.5

            if distancia <= zona.radius then
                puntosCoalicion[nombrePuntos] = puntosCoalicion[nombrePuntos] + 15000
                debugInfo = debugInfo .. "\n[DEBUG] Unidad " .. nombreUnidad .. " generó 15000 puntos. Total actual: " .. puntosCoalicion[nombrePuntos]
            else
                debugInfo = debugInfo .. "\n[DEBUG] Unidad " .. nombreUnidad .. " está fuera de la zona"
            end
        else
            debugInfo = debugInfo .. "\n[DEBUG] Unidad " .. nombreUnidad .. " no encontrada o destruida"
        end
    end

    env.info(debugInfo)
    debugInfo = ""
end

-- Solo agendar una vez
if not _G.economiaAzulIniciada then
    _G.economiaAzulIniciada = true
    mist.scheduleFunction(verificarPuntos, {}, timer.getTime() + 10, 10)
    env.info("[ECONOMIA] Sistema económico azul iniciado correctamente.")
end