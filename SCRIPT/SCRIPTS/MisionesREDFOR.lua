local spawnStart = 11
local spawnEnd = 20
local groupNamePrefix = "TGT_"
local debugMode = false

local activationMessages = {
    "Mision: 1 OPERACION VOLTA-12 --- Ubicacion de la mision en F10",
    "Mision: 2 OPERACION LEVIATAN --- Ubicacion de la mision en F10",
    "Mision: 3 OPERACION CAZA TITANES --- Ubicacion de la mision en F10",
    "Mision: 4 OPERACION CAZA DEL LOBO --- Ubicacion de la mision en F10",
    "Mision: 5 OPERACION GUARDIANES DEL CAOS --- Ubicacion de la mision en F10",
    "Mision: 6 OPERACION FANTASMAS DE PRIEDRA --- Ubicacion de la mision en F10",
    "Mision: 7 OPERACION BLACK GOLD --- Ubicacion de la mision en F10",
    "Mision: 8 OPERACION IRON TRASH --- Ubicacion de la mision en F10",
    "Mision: 9 OPERACION ARMAS --- Ubicacion de la mision en F10",
    "Mision: 10 OPERACION TAKE THE CONTROL --- Ubicacion de la mision en F10",
    "Mision: 1 OPERACION VOLTA-12 --- Ubicacion de la mision en F10",
    "Mision: 2 OPERACION LEVIATAN --- Ubicacion de la mision en F10",
    "Mision: 3 OPERACION CAZA TITANES --- Ubicacion de la mision en F10",
    "Mision: 4 OPERACION CAZA DEL LOBO --- Ubicacion de la mision en F10",
    "Mision: 5 OPERACION GUARDIANES DEL CAOS --- Ubicacion de la mision en F10",
    "Mision: 6 OPERACION FANTASMAS DE PRIEDRA --- Ubicacion de la mision en F10",
    "Mision: 7 OPERACION BLACK GOLD --- Ubicacion de la mision en F10",
    "Mision: 8 OPERACION IRON TRASH --- Ubicacion de la mision en F10",
    "Mision: 9 OPERACION ARMAS --- Ubicacion de la mision en F10",
    "Mision: 10 OPERACION TAKE THE CONTROL --- Ubicacion de la mision en F10"
}

local groupFlags = {
    ["TGT_11"] = 301,
    ["TGT_12"] = 302,
    ["TGT_13"] = 303,
    ["TGT_14"] = 304,
    ["TGT_15"] = 105,
    ["TGT_16"] = 306,
    ["TGT_17"] = 307,
    ["TGT_18"] = 308,
    ["TGT_19"] = 109,
    ["TGT_20"] = 310
}

local endMessage = "Todos los grupos han sido destruidos. Script finalizado."
local deathMessage = "Grupo destruido. Avanzando a la siguiente mision."

local activationFlag = 601
local activationValue = 1
local deathFlag = 601
local deathValue = 2

local drawName = "REDFOR"
local drawRadius = 0
--local drawColor = {0, 0, 0}
local drawLife = 0
--local drawVisible = true

local spawnInterval = 15
local deathDelay = 10

local currentIndex = spawnStart
local activeGroup = nil
local markerId = nil
local scriptActive = true

local function debug(msg)
    if debugMode then
        trigger.action.outTextForCoalition(1, "[DEBUG] " .. msg, 5)
        env.info("[DEBUG] " .. msg)
    end
end

local function isGroupDead(groupName)
    local group = Group.getByName(groupName)
    if not group or not group:isExist() then return true end
    local units = group:getUnits()
    if not units or #units == 0 then return true end
    for _, unit in ipairs(units) do
        if unit and unit:isExist() and unit:getLife() > 1 then
            return false
        end
    end
    return true
end

local function removeMarker()
    if markerId then
        trigger.action.removeMark(markerId)
        markerId = nil
    end
end

local function removeDraw()
    mist.marker.remove(drawName)
end

local function createDrawForGroup(group)
    if not group or not group:isExist() then return end
    local pos = group:getUnit(1):getPoint()
    mist.marker.add({
        name = drawName,
        type = "circle",
        fillColor = {255, 0, 0, 0},
        --lineType = 4,
        point = {x = pos.x, y = 0, z = pos.z},
        radius = drawRadius,
        color = drawColor,
        life = drawLife,
        visible = { blue = true, red = false, neutrals = false }
    })
end

local function createMarker(text, group)
    if not group or not group:isExist() then return end
    local pos = group:getUnit(1):getPoint()
    markerId = group:getID()
    trigger.action.markToCoalition(markerId, text, pos, 1, true)
end

local function spawnNextGroup()
    if currentIndex > spawnEnd then
    trigger.action.outTextForCoalition(1, endMessage, 30)
    debug("Script finalizado.")
    trigger.action.setUserFlag(900, 2)
    scriptActive = false
    return
end


    local groupName = groupNamePrefix .. string.format("%02d", currentIndex)
    local group = Group.getByName(groupName)
    if group then
        trigger.action.activateGroup(group)
        activeGroup = groupName

        -- BANDERAS
        trigger.action.setUserFlag(activationFlag, 0)
timer.scheduleFunction(function()
    trigger.action.setUserFlag(activationFlag, activationValue)
end, {}, timer.getTime() + 0.1)
        local groupFlag = groupFlags[groupName]
        if groupFlag then
            trigger.action.setUserFlag(groupFlag, 2)
        end
        trigger.action.setUserFlag(600, currentIndex)

        local mensaje = activationMessages[currentIndex] or "Mision activada."
        trigger.action.outTextForCoalition(1, mensaje, 20)
        debug("Grupo activado: " .. groupName)
        createMarker(mensaje, group)
        createDrawForGroup(group)
    else
        debug("Grupo " .. groupName .. " no encontrado.")
        currentIndex = currentIndex + 1
        spawnNextGroup()
    end
end

local function checkAndAdvance()
    if not scriptActive then return end

    if activeGroup and isGroupDead(activeGroup) then
        trigger.action.outTextForCoalition(1, deathMessage, 10)
        debug("Grupo muerto: " .. activeGroup)

        -- BANDERAS
        trigger.action.setUserFlag(deathFlag, deathValue)
        local flagID = groupFlags[activeGroup]
        if flagID then
            trigger.action.setUserFlag(flagID, 1)
        end

        removeMarker()
        removeDraw()
        activeGroup = nil
        currentIndex = currentIndex + 1

        timer.scheduleFunction(function()
            spawnNextGroup()
        end, {}, timer.getTime() + deathDelay)
    end

    return timer.getTime() + spawnInterval
end

-- Inicia el primero
spawnNextGroup()

-- Comienza el ciclo
timer.scheduleFunction(checkAndAdvance, {}, timer.getTime() + spawnInterval)
