-- Configuración del spawn
local spawnStart = 1    -- Número de inicio del grupo (por ejemplo, 1 para TGT_01)
local spawnEnd = 10     -- Número de fin del grupo (por ejemplo, 6 para TGT_06)
-- Tabla de banderas por grupo (TGT_01 a TGT_10)
local groupFlags = {
    ["TGT_01"] = 101,
    ["TGT_02"] = 102,
    ["TGT_03"] = 103,
    ["TGT_04"] = 104,
    ["TGT_05"] = 105,
    ["TGT_06"] = 106,
    ["TGT_07"] = 107,
    ["TGT_08"] = 108,
    ["TGT_09"] = 109,
    ["TGT_10"] = 110,
}
local groupNamePrefix = "TGT_"  -- Prefijo común de los grupos
local spawnZone = "BLUEFOR"  -- Zona donde se realizará el spawn
local debugMode = false  -- Activar/Desactivar mensajes de depuración
local deathMessage = "Grupo destruido."  -- Mensaje que se muestra cuando un grupo muere
local activationMessages = {
     --------------------------------DESDE ACA SON LAS MISIONES DE BLUEFOR
    "Misión: 1 --- Ubicación de la mision en F10",
    "Misión: 2 --- Ubicación de la mision en F10",
    "Misión: 3 --- Ubicación de la mision en F10",
    "Misión: 4 --- Ubicación de la mision en F10",
    "Misión: 5 --- Ubicación de la mision en F10",
    "Misión: 6 --- Ubicación de la mision en F10",
    "Misión: 7 --- Ubicación de la mision en F10",
    "Misión: 8 --- Ubicación de la mision en F10",
    "Misión: 9 --- Ubicación de la mision en F10",
    "Misión: 10 --- Ubicación de la mision en F10",
    --------------------------------DESDE ACA SON LAS MISIONES DE REDFOR
    "Misión: DESCRIPCION --- Ubicación de la mision en F10",
    "Misión: DESCRIPCION --- Ubicación de la mision en F10",
    "Misión: DESCRIPCION --- Ubicación de la mision en F10",
    "Misión: DESCRIPCION --- Ubicación de la mision en F10",
    "Misión: DESCRIPCION --- Ubicación de la mision en F10",
    "Misión: DESCRIPCION --- Ubicación de la mision en F10",
    "Misión: DESCRIPCION --- Ubicación de la mision en F10",
    "Misión: DESCRIPCION --- Ubicación de la mision en F10",
    "Misión: DESCRIPCION --- Ubicación de la mision en F10",
    "Misión: DESCRIPCION --- Ubicación de la mision en F10"
}  -- Mensajes de activación personalizados2
local endMessage = "Todos los grupos han muerto. Script finalizado."  -- Mensaje al finalizar
local spawnInterval = 15  -- Intervalo de tiempo entre activaciones (en segundos)
local deathDelay = 10  -- Retardo tras la muerte del grupo antes de activar el siguiente (en segundos)
local activationFlag = 100  -- Número de la bandera de activación
local activationValue = 1  -- Valor de la bandera de activación22222223
local deathFlag = 100  -- Número de la bandera de muerte
local deathValue = 2  -- Valor de la bandera de muerte

-- Parámetros de configuración para los Draws
local drawRadius = 8000  -- Radio en metros
local drawColor = {255, 0, 0}  -- Color en formato RGB (verde en este caso)
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
local drawName = "BLUEFOR"  -- Nombre para el draw
local markerId = nil  -- ID del marcador

-- Función para crear una marca en el mapa
local function createMarker(text, group)
    if group and group:isExist() then
        local pos = group:getUnit(1):getPoint()
        markerId = group:getID()
        trigger.action.markToCoalition(markerId, text, pos, 2, true)
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
            fillColor = {255, 0, 0, 72},
            lineType = 4,
            point = {x = pos.x, y = 0, z = pos.z},  -- Coordenadas del grupo (X, Z)
            radius = drawRadius,  -- Radio en metros
            color = drawColor,  -- Color del marcador
            life = drawLife,  -- Tiempo de vida del marcador
            visible = drawVisible,  -- Visibilidad del marcador
            coalition = 2  -- Solo visible para BLUEFOR
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
    local flagID = groupFlags[groupName]
if flagID then
    trigger.action.setUserFlag(flagID, 2)
    debug("Bandera " .. flagID .. " del grupo " .. groupName .. " seteada en 2 (activo).")
end
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
            trigger.action.setUserFlag(deathFlag, deathValue)
            -- Cambiar bandera del grupo a 1 (muerto)
local flagID = groupFlags[activeGroup]
if flagID then
    trigger.action.setUserFlag(flagID, 1)
    debug("Bandera " .. flagID .. " del grupo " .. activeGroup .. " seteada en 1 (muerto).")
end
  -- Establecer la bandera de muerte
            debug("Bandera de muerte " .. deathFlag .. " establecida en " .. deathValue)
            removeMarker()
            removeDraw()  -- Eliminar el draw cuando el grupo muere
            deadGroupsCount = deadGroupsCount + 1
            activeGroup = nil
        end

        -- Verificar si todos los grupos están muertos para finalizar el script
        if deadGroupsCount >= (spawnEnd - spawnStart + 1) then
            trigger.action.outText(endMessage, 300)
            debug("Todos los grupos han muerto. Script finalizado.")
            scriptActive = false
            return
        end

        -- Retraso antes de activar el siguiente grupo
        -- Retraso antes de activar el siguiente grupo (secuencial)
timer.scheduleFunction(function()
    local nextGroupNumber = spawnStart + deadGroupsCount
    local groupName = groupNamePrefix .. string.format("%02d", nextGroupNumber)
    debug("Activando el siguiente grupo después del retardo: " .. groupName)
    trigger.action.setUserFlag(activationFlag, activationValue)
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
