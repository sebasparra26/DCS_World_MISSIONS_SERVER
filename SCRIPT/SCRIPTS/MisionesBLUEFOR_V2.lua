-- ================================
-- Script de misiones secuenciales
-- ================================

-- Configuración general
local groupNamePrefix = "TGT_"
local debugMode = true
local spawnInterval = 15
local deathDelay = 10
local endMessage = "Todos los grupos han muerto. Script finalizado."
local deathMessage = "Grupo destruido."
local drawName = "BLUEFOR"

-- Coalición que verá los markers y draws (2 = BLUE, 1 = RED)
local coalicionVisible = 2

-- Lista de grupos en orden fijo
local missionSequence = {
    { name = "TGT_01", flag = 101 },
    { name = "TGT_07", flag = 107 },
    { name = "TGT_08", flag = 108 },
    { name = "TGT_03", flag = 103 },
    { name = "TGT_05", flag = 105 }
}

-- Mensajes de activación para cada grupo
local activationMessages = {
    "Misión: OBJETIVO 01 --- Ubicación en F10",
    "Misión: OBJETIVO 07 --- Ubicación en F10",
    "Misión: OBJETIVO 08 --- Ubicación en F10",
    "Misión: OBJETIVO 03 --- Ubicación en F10",
    "Misión: OBJETIVO 05 --- Ubicación en F10"
}

-- Configuración del draw
local drawRadius = 8000
local drawColor = {255, 0, 0}
local drawLife = 0
local drawVisible = true

-- Estado interno
local currentIndex = 1
local activeGroup = nil
local scriptActive = true
local markerId = nil

-- Función de depuración
local function debug(message)
    if debugMode then
        trigger.action.outText("[DEBUG] " .. message, 5)
        env.info("[DEBUG] " .. message)
    end
end

-- Crear marcador solo para una coalición
local function createMarker(text, group)
    if group and group:isExist() then
        local pos = group:getUnit(1):getPoint()
        markerId = group:getID()
        trigger.action.markForCoalition(coalicionVisible, markerId, text, pos, true)
        debug("Marca creada para el grupo " .. group:getName())
    end
end

-- Crear draw solo visible para una coalición
local function createDrawForActiveGroup(group)
    if group and group:isExist() then
        local pos = group:getUnit(1):getPoint()
        mist.marker.add({
            name = drawName,
            coalition = coalicionVisible,
            type = 'circle',
            fillColor = {255, 0, 0, 72},
            lineType = 4,
            point = {x = pos.x, y = 0, z = pos.z},
            radius = drawRadius,
            color = drawColor,
            life = drawLife,
            visible = drawVisible
        })
        debug("Draw creado en la posición del grupo " .. group:getName())
    end
end

-- Eliminar draw
local function removeDraw()
    mist.marker.remove(drawName)
    debug("Draw con nombre " .. drawName .. " eliminado.")
end

-- Eliminar marcador
local function removeMarker()
    if markerId then
        trigger.action.removeMark(markerId)
        debug("Marca con ID " .. markerId .. " eliminada.")
        markerId = nil
    end
end

-- Verificar si el grupo está muerto
local function isGroupDead(groupName)
    local group = Group.getByName(groupName)
    if not group or not group:isExist() then return true end
    for _, unit in ipairs(group:getUnits()) do
        if unit and unit:isExist() then return false end
    end
    return true
end

-- Activar grupo por índice
local function spawnGroupByIndex(index)
    local entry = missionSequence[index]
    if not entry then return end
    local groupName = entry.name
    local flag = entry.flag

    local group = Group.getByName(groupName)
    if group then
        trigger.action.activateGroup(group)
        activeGroup = groupName
        trigger.action.setUserFlag(flag, 2)

        local msg = activationMessages[index] or "Misión activada."
        trigger.action.outText(msg, 20)
        debug("Grupo " .. groupName .. " activado correctamente.")
        createMarker(msg, group)
        createDrawForActiveGroup(group)
    else
        debug("Grupo " .. groupName .. " no encontrado.")
    end
end

-- Comprobar si hay que activar el siguiente grupo
local function checkAndSpawn()
    if not scriptActive then return end

    if activeGroup == nil or isGroupDead(activeGroup) then
        debug("El grupo activo ha muerto o no existe.")
        if activeGroup then
            for _, entry in ipairs(missionSequence) do
                if entry.name == activeGroup then
                    trigger.action.setUserFlag(entry.flag, 0)
                    break
                end
            end
            trigger.action.outText(deathMessage, 10)
            removeMarker()
            removeDraw()
            activeGroup = nil
        end

        currentIndex = currentIndex + 1
        if currentIndex > #missionSequence then
            trigger.action.outText(endMessage, 300)
            scriptActive = false
            return
        end

        timer.scheduleFunction(function()
            spawnGroupByIndex(currentIndex)
        end, {}, timer.getTime() + deathDelay)
    else
        debug("El grupo activo sigue vivo: " .. activeGroup)
    end
end

-- Iniciar el primer grupo
spawnGroupByIndex(currentIndex)

-- Ciclo de verificación periódico
local function scheduledCheck()
    if scriptActive then
        checkAndSpawn()
        return timer.getTime() + spawnInterval
    end
end

timer.scheduleFunction(scheduledCheck, {}, timer.getTime() + 1)
