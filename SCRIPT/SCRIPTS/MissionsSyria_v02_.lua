-- Configuración del spawn
local spawnStart = 9    -- Número de inicio del grupo (por ejemplo, 1 para TGT_01)
local spawnEnd = 20     -- Número de fin del grupo (por ejemplo, 6 para TGT_06)
local groupNamePrefix = "TGT_"  -- Prefijo común de los grupos
local spawnZone = "Zone_Helis_02"  -- Zona donde se realizará el spawn
local debugMode = false  -- Activar/Desactivar mensajes de depuración
local deathMessage = "Grupo destruido."  -- Mensaje que se muestra cuando un grupo muere
local activationMessages = {
    "Los Enemigos se han tomado una instalación médica al norte, elimínalos sin afectar a los civiles. --- Ubicación de la misión en F10",
"Un convoy enemigo fue detectado desplazándose por una autopista costera, intercepta y destruye. --- Ubicación de la misión en F10",
"Tropas hostiles han ocupado una zona residencial en el centro, neutralízalas. --- Ubicación de la misión en F10",
"El enemigo ha instalado un radar móvil en una zona elevada, destrúyelo antes de que entre en operación. --- Ubicación de la misión en F10",
"Se han desplegado unidades antiaéreas en un viejo complejo militar. Destrúyelas. --- Ubicación de la misión en F10",
"Fuerzas hostiles han minado un cruce estratégico, limpia la zona y asegura el paso. --- Ubicación de la misión en F10",
"Los enemigos controlan una torre de comunicaciones clave, recupérala cuanto antes. --- Ubicación de la misión en F10",
"Se reportan lanzacohetes enemigos camuflados en un campo de cultivo. Encuéntralos y elimínalos. --- Ubicación de la misión en F10",
"Un destacamento enemigo ha levantado un puesto de mando temporal. Infiltra y destruye. --- Ubicación de la misión en F10",
"Tropas enemigas han fortificado una estación eléctrica abandonada. Despeja la zona. --- Ubicación de la misión en F10",
"Se detectaron lanzadores móviles de artillería ocultos en una zona desértica. Neutralízalos. --- Ubicación de la misión en F10",
"El enemigo está usando una mezquita como centro logístico. Toma control sin afectar estructuras. --- Ubicación de la misión en F10",
"Unidades blindadas avanzan desde el este, corta su avance antes que lleguen a la línea defensiva. --- Ubicación de la misión en F10",
"Fuerzas hostiles se han ocultado en las ruinas de un antiguo complejo. Elimínalos. --- Ubicación de la misión en F10",
"Se ha reportado presencia enemiga en una zona montañosa. Realiza reconocimiento y ataque preciso. --- Ubicación de la misión en F10",
"Grupos enemigos están fortificando una intersección clave. Ataca antes que cierren el acceso. --- Ubicación de la misión en F10",
"Misiles antibuque fueron detectados en plataforma terrestre improvisada. Destrúyelos. --- Ubicación de la misión en F10",
"El enemigo ha emboscado una caravana civil. Asegura el área y elimina a los atacantes. --- Ubicación de la misión en F10",
"Se reporta actividad enemiga en un complejo petrolero abandonado. Elimínalos antes de que lo operen. --- Ubicación de la misión en F10",
"Tropas hostiles usan un viejo hangar como búnker. Ejecuta un ataque quirúrgico. --- Ubicación de la misión en F10",
"Helicópteros enemigos están operando desde una zona improvisada. Destruye los aparatos en tierra. --- Ubicación de la misión en F10",
"El enemigo instaló un centro de comunicaciones oculto. Ubícalo y elimina la amenaza. --- Ubicación de la misión en F10",
"Fuerzas hostiles están bloqueando el acceso a una ruta de suministro. Rompe el cerco. --- Ubicación de la misión en F10",
"Se ha detectado un centro de inteligencia enemiga operando en un edificio civil. Desactívalo con precisión. --- Ubicación de la misión en F10",
"El enemigo realiza patrullas motorizadas en un perímetro clave. Embosca y elimina. --- Ubicación de la misión en F10",
"Una unidad enemiga ha capturado una emisora de radio. Recupera el control. --- Ubicación de la misión en F10",
"Se avistaron drones enemigos operando desde un punto oculto. Encuentra y destruye la base. --- Ubicación de la misión en F10",
"Vehículos artillados enemigos fueron detectados en tránsito. Intercepta en marcha. --- Ubicación de la misión en F10",
"Se sospecha de actividad enemiga en una zona urbana densamente poblada. Limpia con cautela. --- Ubicación de la misión en F10",
"Un depósito de municiones fue tomado por el enemigo. Destrúyelo antes que lo redistribuyan. --- Ubicación de la misión en F10"

}  -- Mensajes de activación personalizados
local endMessage = "Todos los grupos han muerto. Script finalizado."  -- Mensaje al finalizar
local spawnInterval = 15  -- Intervalo de tiempo entre activaciones (en segundos)
local deathDelay = 10  -- Retardo tras la muerte del grupo antes de activar el siguiente (en segundos)
local activationFlag = 200  -- Número de la bandera de activación
local activationValue = 1  -- Valor de la bandera de activación
local deathFlag = 200  -- Número de la bandera de muerte
local deathValue = 2  -- Valor de la bandera de muerte

local drawRadius = 10000  -- Radio en metros
local drawColor = {225, 0, 0}  -- Color en formato RGB (verde en este caso)
local drawLife = 0  -- Tiempo de vida del marcador (0 significa que no desaparecerá solo)
local drawVisible = true  -- Si el marcador es visible

-- Función de depuración
local function debug(message)
    if debugMode then
        trigger.action.outText("[DEBUG] " .. message, 5)
        env.info("[DEBUG] " .. message)
    end
end

-- Variables internas
local activeGroup = nil  -- Grupo actualmente activo
local deadGroupsCount = 0  -- Contador de grupos muertos
local scriptActive = true  -- Bandera para controlar el ciclo
local drawName = "TestCircle2"  -- Nombre para el draw
local markerId = nil  -- ID del marcador

-- Función para crear una marca en el mapa
local function createMarker(text, group)
    if group and group:isExist() then
        local pos = group:getUnit(1):getPoint()
        markerId = group:getID()
        trigger.action.markToAll(markerId, text, pos, true)
        debug("Marca creada para el grupo " .. group:getName())
    end
end

-- Función para crear el draw en el mapa en función de la posición del grupo activo
local function createDrawForActiveGroup(group)
    if group and group:isExist() then
        local pos = group:getUnit(1):getPoint()  -- Obtener la posición del primer vehículo del grupo
        -- Crear el marcador en la posición del grupo
        mist.marker.add({
            name = drawName,
            type = 'circle',  -- Tipo de marcador: puede ser 'circle', 'ellipse', etc.
            fillColor = {225, 0, 0, 72},
            lineType = 4,
            point = {x = pos.x, y = 0, z = pos.z},  -- Coordenadas del grupo (X, Z)
            radius = drawRadius,  -- Radio en metros
            color = drawColor,  -- Color del marcador
            life = drawLife,  -- Tiempo de vida del marcador
            visible = drawVisible  -- Visibilidad del marcador
        })
        debug("Draw creado en la posición del grupo " .. group:getName())
    end
end

-- Función para eliminar el draw
local function removeDraw()
    -- Eliminar el draw por nombre
    mist.marker.remove(drawName)  -- Eliminar el draw con el nombre especificado
    debug("Draw con nombre " .. drawName .. " eliminado.")
end

-- Función para eliminar una marca existente
local function removeMarker()
    if markerId then
        trigger.action.removeMark(markerId)
        debug("Marca con ID " .. markerId .. " eliminada.")
        markerId = nil
    end
end

-- Función para comprobar si un grupo está muerto o inactivo
local function isGroupDead(groupName)
    local group = Group.getByName(groupName)
    if not group or not group:isExist() then
        return true
    end
    local units = group:getUnits()
    if units and #units > 0 then
        for _, unit in ipairs(units) do
            if unit and unit:isExist() then
                return false
            end
        end
    end
    return true
end

-- Función para generar un grupo específico
local function spawnGroup(groupName)
    trigger.action.setUserFlag(activationFlag, activationValue)  -- Establecer la bandera de activación
    debug("Bandera de activación " .. activationFlag .. " establecida en " .. activationValue)
    local group = Group.getByName(groupName)
    if group then
        trigger.action.activateGroup(group)
        activeGroup = groupName
        local missionNumber = tonumber(string.sub(groupName, 5, 6))
        local activationMessage = activationMessages[missionNumber] or "Misión activada."
        trigger.action.outText(activationMessage, 20)
        debug("Grupo " .. groupName .. " activado correctamente.")
        createMarker(activationMessage, group)
        createDrawForActiveGroup(group)  -- Crear el draw cuando el grupo se active
    else
        debug("Grupo " .. groupName .. " no encontrado.")
    end
end

-- Verificar si el grupo activo está muerto y activar uno nuevo si es necesario
local function checkAndSpawn()
    if not scriptActive then return end

    if activeGroup == nil or isGroupDead(activeGroup) then
        debug("El grupo activo ha muerto o no existe.")
        if activeGroup then
            trigger.action.outText(deathMessage, 10)
            debug("Grupo " .. activeGroup .. " destruido.")
            trigger.action.setUserFlag(deathFlag, deathValue)  -- Establecer la bandera de muerte
            debug("Bandera de muerte " .. deathFlag .. " establecida en " .. deathValue)
            removeMarker()
            removeDraw()  -- Eliminar el draw cuando el grupo muere
            deadGroupsCount = deadGroupsCount + 1
            activeGroup = nil
        end

        -- Verificar si todos los grupos están muertos para finalizar el script
        if deadGroupsCount >= (spawnEnd - spawnStart + 1) then
            trigger.action.outText(endMessage, 10)
            debug("Todos los grupos han muerto. Script finalizado.")
            scriptActive = false
            return
        end

        -- Retraso antes de activar el siguiente grupo
        timer.scheduleFunction(function()
            local groupNumber = math.random(spawnStart, spawnEnd)
            local groupName = groupNamePrefix .. string.format("%02d", groupNumber)
            debug("Activando el siguiente grupo después del retardo: " .. groupName)
            trigger.action.setUserFlag(activationFlag, activationValue)  -- Reafirma la bandera antes de activar
            spawnGroup(groupName)
        end, {}, timer.getTime() + deathDelay)
    else
        debug("El grupo activo sigue vivo: " .. activeGroup)
    end
end

-- Llamada periódica para verificar el estado
local function scheduledCheck()
    if scriptActive then
        checkAndSpawn()
        return timer.getTime() + spawnInterval
    end
end

timer.scheduleFunction(scheduledCheck, {}, timer.getTime() + 1)
