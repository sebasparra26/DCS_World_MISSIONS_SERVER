local tankerCountry = country.id.USA
local selectedTankerType = nil
local tankerList = {}

-- Menú principal para la coalición azul
local rootMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "Tanker")
local statusMenu

local tankerTypes = {
    ["KC-135"] = { type = "KC-135", callsign = {1, 1, 1} },
    ["KC-135 MPRS"] = { type = "KC135MPRS", callsign = {2, 1, 1} },
    ["KC-130"] = { type = "KC130", callsign = {3, 1, 1} },
    ["KC-130J"] = { type = "KC130J", callsign = {4, 1, 1} },
    ["S-3B Tanker"] = { type = "S-3B", callsign = {5, 1, 1} }
}

-- Función para verificar si el tanquero ya está en la lista
local function isTankerExist(groupName)
    for _, tanker in ipairs(tankerList) do
        if tanker.groupName == groupName then
            return true
        end
    end
    return false
end

-- Selección del tipo de tanquero
local function setTankerType(name)
    if tankerTypes[name] then
        selectedTankerType = name
        trigger.action.outTextForCoalition(coalition.side.BLUE, "Seleccionado: " .. name .. ". Coloca un marcador con texto 'TankerH' (horizontal) o 'TankerV' (vertical).", 10)
    end
end

-- Crear comandos de selección de tanquero
for name, _ in pairs(tankerTypes) do
    missionCommands.addCommandForCoalition(coalition.side.BLUE, name, rootMenu, function() setTankerType(name) end)
end

-- Función para actualizar el submenú de tanqueros activos
local function updateTankerStatusMenu()
    -- Eliminar el submenú anterior de tanqueros activos si existe
    if statusMenu then
        missionCommands.removeItem(statusMenu)
    end

    -- Crear un nuevo submenú "Tanqueros Activos"
    statusMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "Tanqueros Activos", rootMenu)

    local newTankerList = {}

    for _, tanker in ipairs(tankerList) do
        local group = Group.getByName(tanker.groupName)
        if group and group:isExist() then
            table.insert(newTankerList, tanker) -- conservar solo tanqueros vivos

            local name = string.format("%s, %s, %.1fAM, %dX",
                tanker.type, tanker.callsignStr, tanker.frequency, tanker.tacanChannel
            )

            missionCommands.addCommandForCoalition(coalition.side.BLUE, name, statusMenu, function()
                local message = string.format(
                    "Tanquero %s\nCallsign: %s\nFrecuencia: %.1f MHz AM\nTACAN: %dX",
                    tanker.type, tanker.callsignStr, tanker.frequency, tanker.tacanChannel
                )
                trigger.action.outTextForCoalition(coalition.side.BLUE, message, 60)
            end)
        end
    end

    -- Actualizar la lista de tanqueros, eliminando los inactivos
    tankerList = newTankerList
end

-- Función para agregar un nuevo tanquero y actualizar el submenú
local function addNewTanker(groupName, tankerInfo, position, direction)
    -- Verificar si el tanquero ya está en la lista para evitar duplicados
    if isTankerExist(groupName) then
        trigger.action.outTextForCoalition(coalition.side.BLUE, "Este tanquero ya está desplegado.", 10)
        return -- Ya existe, no lo agregamos de nuevo
    end

    -- TACAN par entre 2 y 126
    local tacanChannel = math.random(1, 63) * 2

    -- Frecuencia par entre 225 y 399 MHz
    local rawFreq = math.floor((225 + math.random() * (399 - 225)) * 10) / 10
    local evenFreq = math.floor(rawFreq)
    if evenFreq % 2 ~= 0 then
        evenFreq = evenFreq + 1
    end
    local frequency = evenFreq + 0.0

    local callsignNumber = math.random(111, 999)

    table.insert(tankerList, {
        name = "Unit_" .. math.random(1000,9999),
        type = tankerInfo.type,
        tacanChannel = tacanChannel,
        frequency = frequency,
        groupName = groupName,
        callsignStr = tostring(callsignNumber)
    })

    local groupData = {
        category = Group.Category.AIRPLANE,
        country = tankerCountry,
        name = groupName,
        units = { {
            type = tankerInfo.type,
            name = "Unit_" .. math.random(1000,9999),
            skill = "High",
            x = position.x,
            y = position.y,
            alt = 7620, -- 25,000 ft
            alt_type = "BARO",
            heading = direction.heading,
            speed = 154.4, -- 300 kt en m/s
            payload = {},
            frequency = frequency,
            communication = true,
            callsign = { tankerInfo.callsign[1], tankerInfo.callsign[2], callsignNumber },
            task = {}
        } },
        route = {
            points = {}
        }
    }

    local success, err = pcall(function()
        coalition.addGroup(tankerCountry, groupData.category, groupData)
    end)

    if success then
        trigger.action.outTextForCoalition(coalition.side.BLUE, string.format(
            "Tanquero %s desplegado.\nTACAN: %dX\nFrecuencia: %.1f MHz", 
            tankerInfo.type, tacanChannel, frequency
        ), 60)
        -- Actualizar el submenú de tanqueros activos
        updateTankerStatusMenu()
    else
        trigger.action.outTextForCoalition(coalition.side.BLUE, "Error al crear el tanquero: " .. tostring(err), 10)
    end
end

-- Event handler para colocar marcador
local handler = {}

function handler:onEvent(event)
    if not (event.id == world.event.S_EVENT_MARK_ADDED or event.id == world.event.S_EVENT_MARK_CHANGE) then return end
    if not event.text or not selectedTankerType then return end

    local text = string.lower(event.text)
    if text ~= "tankerh" and text ~= "tankerv" then return end

    local pos = event.pos
    if not pos then
        trigger.action.outTextForCoalition(coalition.side.BLUE, "Error al obtener la posición del marcador.", 10)
        return
    end

    local tankerInfo = tankerTypes[selectedTankerType]
    local altitude = 7620 -- 25,000 ft
    local speed = 154.4 -- 300 kt en m/s
    local halfDistance = 15 * 1852 -- 15 NM

    local point1, point2, direction, heading
    if text == "tankerh" then
        point1 = { x = pos.x, y = pos.z - halfDistance }
        point2 = { x = pos.x, y = pos.z + halfDistance }
        direction = "Este-Oeste"
        heading = 90
    else
        point1 = { x = pos.x - halfDistance, y = pos.z }
        point2 = { x = pos.x + halfDistance, y = pos.z }
        direction = "Sur-Norte"
        heading = 180
    end

    local groupName = "Tanker_" .. selectedTankerType .. "_" .. math.random(1000,9999)
    
    -- Agregar el tanquero y actualizar el menú
    addNewTanker(groupName, tankerInfo, point1, direction)

    selectedTankerType = nil
end

world.addEventHandler(handler)

