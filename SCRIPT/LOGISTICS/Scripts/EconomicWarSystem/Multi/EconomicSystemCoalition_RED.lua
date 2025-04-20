-- Variables principales
-- Variables principales
local coalicion = 1  -- 1 = Rojo, 2 = Azul (ajustar según necesidad)

-- Nombre de la variable de puntos que se actualizará según coalición
local nombrePuntos = (coalicion == 1) and "PuntosROJO" or "PuntosAZUL"

-- Tabla global de puntos de coalición
puntosCoalicion = { PuntosROJO = 0, PuntosAZUL = 0 }

-- Nombre de la zona de detección (definida en el Mission Editor)
local zonaDeteccion = 'EconomicZoneGERMAN'

-- Lista de nombres de unidades estáticas que se verificarán
  -- 1 = Rojo, 2 = Azul (ajustar según necesidad)
local nombrePuntos = (coalicion == 1) and "PuntosROJO" or "PuntosAZUL"  -- Nombre de la variable de puntos dinámico
puntosCoalicion = { PuntosROJO = 0, PuntosAZUL = 0 }  -- Tabla para manejar puntos por coalición
local zonaDeteccion = 'EconomicZoneGERMAN'  -- Nombre de la zona de detección en el ME

-- Array con los nombres de las unidades estáticas a detectar
local unidadesEstaticas = {
    "Factory_RED_1", "Factory_RED_2", "Factory_RED_3", "Factory_RED_4", "Factory_RED_5", 
    "Factory_RED_6", "Factory_RED_7", "Factory_RED_8", "Factory_RED_9", "Factory_RED_10"
}

-- Variable para almacenar información de depuración general
local debugInfo = ""

-- Función para verificar si las unidades están dentro de la zona
function verificarPuntos()
    -- Obtener la zona de detección
    local zona = trigger.misc.getZone(zonaDeteccion)
    
    -- Comprobar si la zona no existe
    if not zona then
        debugInfo = debugInfo .. "\n[DEBUG] La zona de detección no existe: " .. zonaDeteccion
        env.info(debugInfo)
        debugInfo = ""
        return
    end

    debugInfo = debugInfo .. "\n[DEBUG] Comenzando verificación de unidades en la zona: " .. zonaDeteccion
    debugInfo = debugInfo .. "\n[DEBUG] Puntos actuales para " .. nombrePuntos .. ": " .. puntosCoalicion[nombrePuntos]
    
    -- Iterar sobre las unidades estáticas
    for _, nombreUnidad in ipairs(unidadesEstaticas) do
        local unidad = Unit.getByName(nombreUnidad)
        
        -- Si no es una unidad móvil, buscar una unidad estática
        if not unidad then
            unidad = StaticObject.getByName(nombreUnidad)
        end

        -- Si la unidad fue encontrada
        if unidad then
            local posicion = unidad:getPoint()
            -- Calcular la distancia desde la unidad hasta el centro de la zona
            local distancia = ((posicion.x - zona.point.x)^2 + (posicion.z - zona.point.z)^2)^0.5

            -- Verificar si la unidad está dentro de la zona
            if distancia <= zona.radius and (unidad:getCoalition() == coalicion) then
                puntosCoalicion[nombrePuntos] = puntosCoalicion[nombrePuntos] + 5000  -- Sumar 10 puntos por unidad detectada dentro de la zona
                debugInfo = debugInfo .. "\n[DEBUG] Unidad " .. nombreUnidad .. " detectada. Puntos actuales: " .. puntosCoalicion[nombrePuntos]
            end
        else
            debugInfo = debugInfo .. "\n[DEBUG] Unidad no encontrada: " .. nombreUnidad
        end
    end

    -- Mostrar la información de depuración
    env.info(debugInfo)
    debugInfo = "" -- Limpiar debugInfo después de cada ciclo
end

-- Función global para obtener los puntos de una coalición
function obtenerPuntosCoalicion(coalicion)
    local nombrePuntos = (coalicion == 1) and "PuntosROJO" or "PuntosAZUL"
    return puntosCoalicion[nombrePuntos]
end



-- Llamar a la función de verificación cada 10 segundos
mist.scheduleFunction(verificarPuntos, {}, timer.getTime() + 10, 300)