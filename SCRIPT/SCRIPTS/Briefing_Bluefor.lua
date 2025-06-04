-- ================================
-- MENU_briefingMissions.lua
-- ================================

local grupoCoalicion = 2          -- 2 = Blue, 1 = Red
local spawnStart = 1
local spawnEnd = 10
local debugMode = false           -- ← Activa o desactiva todos los mensajes

-- Función de salida debug
local function debug(texto)
    if debugMode then
        trigger.action.outTextForCoalition(2, "[DEBUG] " .. texto, 5)
    end
end

-- Submenú de Briefings
local submenuBriefing = missionCommands.addSubMenuForCoalition(grupoCoalicion, "BRIEFINGS")

-- Variables de control
local currentIndex = spawnStart
local menuActualID = nil
local grupoActual = nil

-- Función para verificar si el grupo está muerto
local function isGroupDead(groupName)
    local group = Group.getByName(groupName)
    if not group or not group:isExist() then return true end
    for _, unit in ipairs(group:getUnits()) do
        if unit and unit:isExist() then return false end
    end
    return true
end

-- Crear briefing (botón de menú) para un grupo
local function crearBriefing(nombreGrupo)
    local numeroMision = tonumber(string.sub(nombreGrupo, 5, 6))
    if not numeroMision then return end

    local banderaSecundaria = 200 + numeroMision
    local nombreMenu = "Briefing Misión " .. string.format("%02d", numeroMision)

    -- Eliminar briefing anterior si existe
    if menuActualID then
        missionCommands.removeItem(menuActualID)
        menuActualID = nil
    end

    -- Crear nuevo comando de menú
    menuActualID = missionCommands.addCommandForCoalition(grupoCoalicion, nombreMenu, submenuBriefing, function()
        -- Setear bandera con valor 2
        trigger.action.setUserFlag(banderaSecundaria, 2)
        debug("Bandera " .. banderaSecundaria .. " seteada a 2 (Briefing activado)")

        -- Reset a 0 luego de 1 segundo
        timer.scheduleFunction(function()
            trigger.action.setUserFlag(banderaSecundaria, 0)
            debug("Bandera " .. banderaSecundaria .. " reseteada a 0")
        end, {}, timer.getTime() + 1)
    end)
end

-- Ciclo de monitoreo para mostrar el briefing correcto
local function cicloBriefing()
    if currentIndex > spawnEnd then
        if menuActualID then
            missionCommands.removeItem(menuActualID)
            menuActualID = nil
        end
        debug("Se alcanzó el final de las misiones (TGT_" .. string.format("%02d", currentIndex - 1) .. ")")
        return
    end

    local nombreGrupo = "TGT_" .. string.format("%02d", currentIndex)

    if isGroupDead(nombreGrupo) then
        debug("Grupo " .. nombreGrupo .. " está muerto. Avanzando al siguiente.")
        currentIndex = currentIndex + 1
        grupoActual = nil
    else
        if grupoActual ~= nombreGrupo then
            debug("Grupo activo detectado: " .. nombreGrupo .. ". Mostrando briefing.")
            grupoActual = nombreGrupo
            crearBriefing(nombreGrupo)
        end
    end

    timer.scheduleFunction(cicloBriefing, {}, timer.getTime() + 5)
end

-- Iniciar ciclo
cicloBriefing()
