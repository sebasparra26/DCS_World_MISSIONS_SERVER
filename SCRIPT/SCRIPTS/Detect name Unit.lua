-- Función para mostrar el mensaje con el nombre del grupo que seleccionó la opción
local function showMessageWithGroup(text, group)
    if group then
        local groupName = group:getName()
        local message = text .. " - Grupo: " .. groupName
        trigger.action.outText(message, 10)
    else
        trigger.action.outText("Grupo no identificado", 10)
    end
end

-- Crear el menú principal
local mainMenu = missionCommands.addSubMenu("Misiones")

-- Crear el submenú de logística y transportes
local logisticsMenu = missionCommands.addSubMenu("Logística y transportes", mainMenu)

-- Función que detecta el grupo del jugador y muestra el mensaje
local function missionHandler(text)
    local group = nil
    local unit = nil
    local units = coalition.getPlayers(2)  -- Obtener todas las unidades de la coalición azul

    for _, u in ipairs(units) do
        if u and u:isActive() then
            unit = u
            break
        end
    end

    if unit then
        group = unit:getGroup()
    end

    showMessageWithGroup(text, group)
end

-- Agregar opciones de misión al submenú
missionCommands.addCommand("Misión 1", logisticsMenu, missionHandler, "Has seleccionado Misión 1")
missionCommands.addCommand("Misión 2", logisticsMenu, missionHandler, "Has seleccionado Misión 2")
missionCommands.addCommand("Misión 3", logisticsMenu, missionHandler, "Has seleccionado Misión 3")

-- Mensaje inicial de confirmación
trigger.action.outText("Menú de radio creado correctamente", 5)
