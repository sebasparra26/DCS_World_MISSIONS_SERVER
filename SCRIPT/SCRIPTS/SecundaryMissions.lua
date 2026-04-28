----------------------------------------------------------------
-- SecundaryMissions.lua
-- Misiones secundarias con pago economico y panel F10
--
-- REQUIERE:
-- - MIST cargado antes
-- - HDEV_EconomyCore.lua cargado antes
-- - EconomicSystemCoalition_BLUE_V4.lua o el init economico cargado antes
----------------------------------------------------------------

if not mist then
    trigger.action.outText("ERROR: MIST no esta cargado.", 15)
    return
end

----------------------------------------------------------------
-- CONFIGURACION GENERAL
----------------------------------------------------------------
local spawnStart = 1
local spawnEnd = 8
local groupNamePrefix = "TGT_"

local debugMode = false

local spawnInterval = 15
local deathDelay = 10

local activationFlag = 4000
local activationValue = 1

local deathFlag = 4000
local deathValue = 2

local deathMessage = "Grupo destruido."
local endMessage = "Todas las misiones secundarias han sido completadas."

----------------------------------------------------------------
-- ECONOMIA
----------------------------------------------------------------
local useEconomy = true

-- 1 = rojo
-- 2 = azul
-- 0 = ambos
local defaultRewardCoalition = 2

local defaultRewardAmount = 5000000

local payFinalReward = true
local finalRewardCoalition = 2
local finalRewardAmount = 25000000

local showRewardMessage = true
local showBalanceAfterReward = true

----------------------------------------------------------------
-- INFORMACION DE CADA MISION SECUNDARIA
--
-- number = numero final del grupo
-- TGT_01 usa [1]
-- TGT_02 usa [2]
----------------------------------------------------------------
local secondaryMissionInfo = {
    [1] = {
        title = "Ataque al norte de Schwinfurt",
        objective = "Destruir el grupo enemigo desplegado en la zona.",
        reward = 5000000
    },

    [2] = {
        title = "Cruce enemigo detectado",
        objective = "Eliminar las fuerzas enemigas antes de que consoliden la posicion.",
        reward = 5000000
    },

    [3] = {
        title = "Bateria SMERCH",
        objective = "Destruir la bateria de artilleria enemiga.",
        reward = 8000000
    },

    [4] = {
        title = "Helipuerto ocupado",
        objective = "Neutralizar la defensa antiaerea enemiga.",
        reward = 8000000
    },

    [5] = {
        title = "Braunschweig bajo amenaza",
        objective = "Eliminar las tropas enemigas desplegadas en la ciudad.",
        reward = 10000000
    },

    [6] = {
        title = "Estacion de trenes",
        objective = "Destruir el grupo enemigo cerca de la estacion.",
        reward = 10000000
    },

    [7] = {
        title = "Acueductos del norte",
        objective = "Eliminar las fuerzas enemigas en el area del condominio.",
        reward = 12000000
    },

    [8] = {
        title = "Ciudad al occidente de Lubeck",
        objective = "Interceptar y destruir el grupo enemigo.",
        reward = 12000000
    }
}

-- Prioridad por nombre exacto si necesitas sobreescribir una mision concreta
local secondaryMissionInfoByGroupName = {
    -- ["TGT_01"] = {
    --     title = "Titulo personalizado",
    --     objective = "Objetivo personalizado",
    --     reward = 15000000
    -- }
}

----------------------------------------------------------------
-- MENSAJES DE ACTIVACION
----------------------------------------------------------------
local activationMessages = {
    "Mision secundaria: enemigos desplegados al norte de Schwinfurt. Destruyelos. Ubicacion marcada en F10.",
    "Mision secundaria: fuerzas enemigas cruzaron la frontera con equipo belico. Destruyelas antes de que consoliden la zona.",
    "Mision secundaria: bateria de misiles SMERCH detectada. Destruye el grupo.",
    "Mision secundaria: enemigos tomaron el helipuerto y desplegaron defensa antiaerea. Neutraliza la posicion.",
    "Mision secundaria: tropas enemigas desplegadas en Braunschweig. Elimina la amenaza.",
    "Mision secundaria: enemigos desplegados cerca de la estacion de trenes. Limpia la zona.",
    "Mision secundaria: enemigos ocupan un condominio cerca de los acueductos del norte. Destruye el grupo.",
    "Mision secundaria: enemigos se tomaron una ciudad al occidente de Lubeck. Intercepta y destruye.",
}

----------------------------------------------------------------
-- DRAW CIRCULO
----------------------------------------------------------------
local drawRadius = 10000
local drawColor = {255, 0, 0}
local drawFillColor = {255, 0, 0, 72}
local drawLife = 0
local drawVisible = true
local drawNamePrefix = "SecondaryMissionCircle_"

----------------------------------------------------------------
-- PANEL F10 AL LADO DE LA MARCA
----------------------------------------------------------------
local panelEnabled = true

-- Posicion del cuadrito respecto al grupo activo
local panelOffsetX = 5000
local panelOffsetZ = 2500

local panelNamePrefix = "SecondaryMissionPanel_"
local panelFontSize = 11
local panelTextColor = "black"
local panelFillColor = {176, 133, 0, 100}
local panelLineType = 1

-- -1 = todos
-- 1 = rojo
-- 2 = azul
local panelCoalition = -1

----------------------------------------------------------------
-- ESTADO INTERNO
----------------------------------------------------------------
local activeGroup = nil
local activeGroupNumber = nil
local scriptActive = true
local spawnPending = false

local markerId = nil
local currentDrawName = nil

local currentPanelName = nil
local currentPanelMarkId = nil

local completedGroups = {}
local paidGroups = {}
local finalRewardPaid = false

----------------------------------------------------------------
-- DEBUG
----------------------------------------------------------------
local function debug(message)
    env.info("[SEC_MISSION] " .. tostring(message))

    if debugMode then
        trigger.action.outText("[SEC_MISSION] " .. tostring(message), 6)
    end
end

----------------------------------------------------------------
-- UTILIDADES
----------------------------------------------------------------
local function getEconomy()
    return HDEV_Economy
end

local function formatMoney(value)
    local econ = getEconomy()

    if econ and econ.formatMoney then
        local ok, result = pcall(function()
            return econ.formatMoney(tonumber(value) or 0)
        end)

        if ok and result then
            return result
        end
    end

    return "$" .. tostring(math.floor(tonumber(value) or 0))
end

local function getBalance(coalitionId)
    local econ = getEconomy()

    if econ and econ.get then
        local ok, result = pcall(function()
            return econ.get(coalitionId)
        end)

        if ok then
            return tonumber(result) or 0
        end
    end

    return 0
end

local function normalizeCoalition(coalitionId)
    local c = tonumber(coalitionId) or defaultRewardCoalition

    if c ~= 0 and c ~= 1 and c ~= 2 then
        c = defaultRewardCoalition
    end

    return c
end

local function coalitionText(coalitionId)
    coalitionId = tonumber(coalitionId) or 0

    if coalitionId == 1 then
        return "ROJO"
    elseif coalitionId == 2 then
        return "AZUL"
    end

    return "AMBOS"
end

local function getGroupNumber(groupName)
    if not groupName then
        return nil
    end

    return tonumber(string.match(groupName, "(%d+)$"))
end

local function getMissionInfo(groupName)
    if secondaryMissionInfoByGroupName[groupName] then
        return secondaryMissionInfoByGroupName[groupName]
    end

    local number = getGroupNumber(groupName)

    if number and secondaryMissionInfo[number] then
        return secondaryMissionInfo[number]
    end

    return {
        title = "Mision secundaria " .. tostring(groupName or ""),
        objective = "Destruir el grupo enemigo asignado.",
        reward = defaultRewardAmount
    }
end

local function getRewardForGroup(groupName)
    local info = getMissionInfo(groupName)
    return tonumber(info.reward) or defaultRewardAmount
end

local function countCompletedGroups()
    local count = 0

    for i = spawnStart, spawnEnd do
        local groupName = groupNamePrefix .. string.format("%02d", i)

        if completedGroups[groupName] then
            count = count + 1
        end
    end

    return count
end

local function totalGroups()
    return (spawnEnd - spawnStart + 1)
end

local function groupExistsByName(groupName)
    if not groupName or groupName == "" then
        return nil
    end

    local group = Group.getByName(groupName)

    if not group then
        return nil
    end

    return group
end

local function getFirstValidUnit(group)
    if not group then
        return nil
    end

    local okUnits, units = pcall(function()
        return group:getUnits()
    end)

    if okUnits and units and #units > 0 then
        for _, unit in ipairs(units) do
            if unit then
                local okExist, exists = pcall(function()
                    return unit:isExist()
                end)

                if okExist and exists then
                    return unit
                end
            end
        end
    end

    local okUnit1, unit1 = pcall(function()
        return group:getUnit(1)
    end)

    if okUnit1 then
        return unit1
    end

    return nil
end

local function isUnitAlive(unit)
    if not unit then
        return false
    end

    local okExist, exists = pcall(function()
        return unit:isExist()
    end)

    if not okExist or not exists then
        return false
    end

    local okLife, life = pcall(function()
        return unit:getLife()
    end)

    if not okLife then
        return true
    end

    return (tonumber(life) or 0) > 1
end

local function isGroupDead(groupName)
    local group = Group.getByName(groupName)

    if not group then
        return true
    end

    local okExist, exists = pcall(function()
        return group:isExist()
    end)

    if not okExist or not exists then
        return true
    end

    local okUnits, units = pcall(function()
        return group:getUnits()
    end)

    if not okUnits or not units or #units == 0 then
        return true
    end

    for _, unit in ipairs(units) do
        if isUnitAlive(unit) then
            return false
        end
    end

    return true
end

local function normalizeColorName(name)
    local s = tostring(name or "white"):lower()

    if s == "black" then return {0, 0, 0, 255} end
    if s == "white" then return {255, 255, 255, 255} end
    if s == "red" then return {255, 0, 0, 255} end
    if s == "blue" then return {0, 100, 255, 255} end
    if s == "yellow" then return {255, 255, 0, 255} end
    if s == "orange" then return {255, 165, 0, 255} end
    if s == "green" then return {0, 255, 0, 255} end

    return {255, 255, 255, 255}
end

----------------------------------------------------------------
-- ECONOMIA
----------------------------------------------------------------
local economyWarningShown = false

local function paySingleCoalition(coalitionId, amount, reason)
    if not useEconomy then
        debug("Economia desactivada. No se paga: " .. tostring(reason))
        return false
    end

    coalitionId = tonumber(coalitionId) or defaultRewardCoalition
    amount = tonumber(amount) or 0

    if amount <= 0 then
        debug("Monto invalido para pago: " .. tostring(amount))
        return false
    end

    local econ = getEconomy()

    if not econ or not econ.add then
        if not economyWarningShown then
            trigger.action.outText("Sistema economico no disponible. No se pudo pagar recompensa secundaria.", 10)
            economyWarningShown = true
        end

        debug("HDEV_Economy.add no disponible.")
        return false
    end

    local before = getBalance(coalitionId)

    local ok, after = pcall(function()
        return econ.add(coalitionId, amount, reason or "recompensa secundaria")
    end)

    if not ok then
        trigger.action.outText("Error pagando recompensa secundaria. Revisa dcs.log.", 10)
        env.info("[SEC_MISSION_REWARD_ERROR] " .. tostring(after))
        return false
    end

    after = tonumber(after) or getBalance(coalitionId)

    env.info(
        "[SEC_MISSION_REWARD] coalition=" .. tostring(coalitionId) ..
        " amount=" .. tostring(amount) ..
        " reason=" .. tostring(reason or "N/A") ..
        " before=" .. tostring(before) ..
        " after=" .. tostring(after)
    )

    if showRewardMessage then
        local msg =
            "Recompensa de mision secundaria\n" ..
            "Coalicion: " .. coalitionText(coalitionId) .. "\n" ..
            "Concepto: " .. tostring(reason or "recompensa secundaria") .. "\n" ..
            "Valor: " .. formatMoney(amount)

        if showBalanceAfterReward then
            msg = msg .. "\nSaldo actual: " .. formatMoney(after)
        end

        trigger.action.outTextForCoalition(coalitionId, msg, 12)
    end

    return true
end

local function payCoalition(coalitionId, amount, reason)
    coalitionId = normalizeCoalition(coalitionId)

    if coalitionId == 0 then
        local okRed = paySingleCoalition(1, amount, reason)
        local okBlue = paySingleCoalition(2, amount, reason)
        return okRed or okBlue
    end

    return paySingleCoalition(coalitionId, amount, reason)
end

----------------------------------------------------------------
-- MARCAS, CIRCULO Y PANEL
----------------------------------------------------------------
local function removeMarker()
    if markerId then
        pcall(function()
            trigger.action.removeMark(markerId)
        end)

        debug("Marca eliminada: " .. tostring(markerId))
        markerId = nil
    end
end

local function removeDraw()
    if currentDrawName and mist and mist.marker and mist.marker.remove then
        pcall(function()
            mist.marker.remove(currentDrawName)
        end)

        debug("Draw eliminado: " .. tostring(currentDrawName))
        currentDrawName = nil
    end
end

local function removePanel()
    if currentPanelMarkId then
        if mist and mist.marker and mist.marker.remove then
            local ok = pcall(function()
                mist.marker.remove(currentPanelMarkId)
            end)

            if not ok and currentPanelName then
                pcall(function()
                    mist.marker.remove(currentPanelName)
                end)
            end
        else
            pcall(function()
                trigger.action.removeMark(currentPanelMarkId)
            end)
        end

        debug("Panel eliminado: " .. tostring(currentPanelMarkId))
        currentPanelMarkId = nil
        currentPanelName = nil
        return
    end

    if currentPanelName and mist and mist.marker and mist.marker.remove then
        pcall(function()
            mist.marker.remove(currentPanelName)
        end)

        debug("Panel eliminado por nombre: " .. tostring(currentPanelName))
        currentPanelName = nil
    end
end

local function buildPanelText(groupName)
    local info = getMissionInfo(groupName)
    local reward = getRewardForGroup(groupName)

    return
        "MISION SECUNDARIA\n" ..
        tostring(info.title or groupName) .. "\n\n" ..
        "Objetivo: " .. tostring(info.objective or "Destruir el grupo enemigo.") .. "\n" ..
        "Pago: " .. formatMoney(reward)
end

local function createMarker(text, group)
    if not group then
        return
    end

    local unit = getFirstValidUnit(group)

    if not unit then
        debug("No se pudo crear marca. Grupo sin unidad valida.")
        return
    end

    local pos = unit:getPoint()

    if not pos then
        debug("No se pudo crear marca. Unidad sin posicion.")
        return
    end

    local okId, groupId = pcall(function()
        return group:getID()
    end)

    if not okId or not groupId then
        groupId = math.random(800000, 899999)
    end

    markerId = groupId

    pcall(function()
        trigger.action.markToAll(markerId, text, pos, true)
    end)

    debug("Marca creada para grupo: " .. tostring(group:getName()))
end

local function createDrawForActiveGroup(group)
    if not mist or not mist.marker or not mist.marker.add then
        debug("mist.marker.add no disponible. No se crea draw.")
        return
    end

    if not group then
        return
    end

    local unit = getFirstValidUnit(group)

    if not unit then
        debug("No se pudo crear draw. Grupo sin unidad valida.")
        return
    end

    local pos = unit:getPoint()

    if not pos then
        debug("No se pudo crear draw. Unidad sin posicion.")
        return
    end

    removeDraw()

    local groupName = group:getName()
    currentDrawName = drawNamePrefix .. tostring(groupName)

    mist.marker.add({
        name = currentDrawName,
        type = "circle",
        fillColor = drawFillColor,
        lineType = 4,
        point = { x = pos.x, y = 0, z = pos.z },
        radius = drawRadius,
        color = drawColor,
        life = drawLife,
        visible = drawVisible
    })

    debug("Draw creado para grupo: " .. tostring(groupName))
end

local function createPanelForActiveGroup(group)
    if not panelEnabled then
        return
    end

    if not group then
        return
    end

    local unit = getFirstValidUnit(group)

    if not unit then
        debug("No se pudo crear panel. Grupo sin unidad valida.")
        return
    end

    local pos = unit:getPoint()

    if not pos then
        debug("No se pudo crear panel. Unidad sin posicion.")
        return
    end

    local groupName = group:getName()
    local panelText = buildPanelText(groupName)

    local panelPoint = {
        x = pos.x + panelOffsetX,
        y = 0,
        z = pos.z + panelOffsetZ
    }

    removePanel()

    currentPanelName = panelNamePrefix .. tostring(groupName)

    if mist and mist.marker and mist.marker.add then
        local panelData = mist.marker.add({
            name = currentPanelName,
            mType = 5,
            point = panelPoint,
            text = panelText,
            fontSize = panelFontSize,
            color = normalizeColorName(panelTextColor),
            fillColor = panelFillColor,
            lineType = panelLineType,
            readOnly = true,
            coa = panelCoalition
        })

        if panelData and panelData.markId then
            currentPanelMarkId = panelData.markId
            debug("Panel creado para grupo: " .. tostring(groupName))
            return
        end
    end

    -- Fallback sin caja, pero deja el texto al lado si MIST no devuelve markId
    currentPanelMarkId = math.random(900000, 999999)

    local okPanel = pcall(function()
        trigger.action.markToAll(currentPanelMarkId, panelText, panelPoint, true, "")
    end)

    if not okPanel then
        pcall(function()
            trigger.action.markToAll(currentPanelMarkId, panelText, panelPoint, true)
        end)
    end

    debug("Panel fallback creado para grupo: " .. tostring(groupName))
end

----------------------------------------------------------------
-- COMPLETAR Y PAGAR
----------------------------------------------------------------
local function completeSecondaryGroup(groupName)
    if not groupName or completedGroups[groupName] then
        return
    end

    completedGroups[groupName] = true

    local rewardAmount = getRewardForGroup(groupName)

    if not paidGroups[groupName] then
        local reason = "Mision secundaria completada: " .. tostring(groupName)
        local ok = payCoalition(defaultRewardCoalition, rewardAmount, reason)

        if ok or rewardAmount <= 0 or not useEconomy then
            paidGroups[groupName] = true
        end
    end

    local completed = countCompletedGroups()

    trigger.action.outText(
        deathMessage .. "\n" ..
        "Mision secundaria completada: " .. tostring(groupName) .. "\n" ..
        "Progreso: " .. tostring(completed) .. "/" .. tostring(totalGroups()),
        10
    )

    debug("Grupo completado: " .. tostring(groupName))
end

local function finishAllSecondaryMissions()
    if finalRewardPaid then
        return
    end

    finalRewardPaid = true
    scriptActive = false

    removeMarker()
    removeDraw()
    removePanel()

    if payFinalReward and finalRewardAmount and finalRewardAmount > 0 then
        payCoalition(finalRewardCoalition, finalRewardAmount, "Todas las misiones secundarias completadas")
    end

    trigger.action.outText(endMessage, 15)

    debug("Sistema de misiones secundarias finalizado.")
end

----------------------------------------------------------------
-- SELECCION Y ACTIVACION
----------------------------------------------------------------
local function chooseNextGroupName()
    local candidates = {}

    for i = spawnStart, spawnEnd do
        local groupName = groupNamePrefix .. string.format("%02d", i)

        if not completedGroups[groupName] then
            candidates[#candidates + 1] = groupName
        end
    end

    if #candidates == 0 then
        return nil
    end

    return candidates[math.random(1, #candidates)]
end

local function spawnGroup(groupName)
    if not scriptActive then
        return false
    end

    if not groupName then
        return false
    end

    if completedGroups[groupName] then
        debug("Grupo ya completado. No se activa otra vez: " .. tostring(groupName))
        return false
    end

    trigger.action.setUserFlag(activationFlag, activationValue)
    debug("Bandera de activacion " .. tostring(activationFlag) .. " = " .. tostring(activationValue))

    local group = groupExistsByName(groupName)

    if not group then
        debug("Grupo no encontrado: " .. tostring(groupName))
        completedGroups[groupName] = true
        return false
    end

    local okActivate, err = pcall(function()
        trigger.action.activateGroup(group)
    end)

    if not okActivate then
        debug("Error activando grupo " .. tostring(groupName) .. ": " .. tostring(err))
        return false
    end

    activeGroup = groupName
    activeGroupNumber = getGroupNumber(groupName)

    local activationMessage = activationMessages[activeGroupNumber] or ("Mision secundaria activada: " .. tostring(groupName))

    trigger.action.outText(activationMessage, 20)

    debug("Grupo activado: " .. tostring(groupName))

    createMarker(activationMessage, group)
    createDrawForActiveGroup(group)
    createPanelForActiveGroup(group)

    return true
end

local function scheduleNextSpawn()
    if spawnPending or not scriptActive then
        return
    end

    spawnPending = true

    timer.scheduleFunction(function()
        spawnPending = false

        if not scriptActive then
            return nil
        end

        if countCompletedGroups() >= totalGroups() then
            finishAllSecondaryMissions()
            return nil
        end

        local nextGroup = chooseNextGroupName()

        if not nextGroup then
            finishAllSecondaryMissions()
            return nil
        end

        debug("Activando siguiente grupo: " .. tostring(nextGroup))

        local ok = spawnGroup(nextGroup)

        if not ok then
            if countCompletedGroups() >= totalGroups() then
                finishAllSecondaryMissions()
            else
                scheduleNextSpawn()
            end
        end

        return nil
    end, {}, timer.getTime() + deathDelay)
end

----------------------------------------------------------------
-- LOOP PRINCIPAL
----------------------------------------------------------------
local function checkAndSpawn()
    if not scriptActive then
        return
    end

    if countCompletedGroups() >= totalGroups() then
        finishAllSecondaryMissions()
        return
    end

    if activeGroup == nil then
        scheduleNextSpawn()
        return
    end

    if isGroupDead(activeGroup) then
        local destroyedGroup = activeGroup

        debug("Grupo activo destruido o inexistente: " .. tostring(destroyedGroup))

        trigger.action.setUserFlag(deathFlag, deathValue)
        debug("Bandera de muerte " .. tostring(deathFlag) .. " = " .. tostring(deathValue))

        removeMarker()
        removeDraw()
        removePanel()

        activeGroup = nil
        activeGroupNumber = nil

        completeSecondaryGroup(destroyedGroup)

        if countCompletedGroups() >= totalGroups() then
            finishAllSecondaryMissions()
            return
        end

        scheduleNextSpawn()
    else
        debug("Grupo activo vivo: " .. tostring(activeGroup))
    end
end

local function scheduledCheck()
    if scriptActive then
        checkAndSpawn()
        return timer.getTime() + spawnInterval
    end

    return nil
end

----------------------------------------------------------------
-- START
----------------------------------------------------------------
math.randomseed(math.floor(timer.getTime() * 1000))

debug("Sistema de misiones secundarias iniciado.")
timer.scheduleFunction(scheduledCheck, {}, timer.getTime() + 1)