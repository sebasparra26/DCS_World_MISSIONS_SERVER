local tankerCountryRed = country.id.RUSSIA
local selectedTankerTypeRed = nil
local tankerListRed = {}

-- Menú principal para la coalición roja
local rootMenuRed = missionCommands.addSubMenuForCoalition(coalition.side.RED, "Tanker")
local statusMenuRed

local tankerTypesRed = {
    ["KC-135"] = { type = "KC-135", callsign = {1, 1, 1} },
    ["KC-135 MPRS"] = { type = "KC135MPRS", callsign = {2, 1, 1} },
    ["IL-78"] = { type = "IL-78M", callsign = {3, 1, 1} }
}

local function isTankerExistRed(groupName)
    for _, tanker in ipairs(tankerListRed) do
        if tanker.groupName == groupName then
            return true
        end
    end
    return false
end

local function setTankerTypeRed(name)
    if tankerTypesRed[name] then
        selectedTankerTypeRed = name
        trigger.action.outTextForCoalition(coalition.side.RED, "Seleccionado: " .. name .. ". Coloca un marcador con texto 'TankerH' (horizontal) o 'TankerV' (vertical).", 10)
    end
end

for name, _ in pairs(tankerTypesRed) do
    missionCommands.addCommandForCoalition(coalition.side.RED, name, rootMenuRed, function() setTankerTypeRed(name) end)
end

-- Función de actualización del submenú de tanqueros activos
local function updateTankerStatusMenuRed()
    if statusMenuRed then
        missionCommands.removeItem(statusMenuRed)
    end

    statusMenuRed = missionCommands.addSubMenuForCoalition(coalition.side.RED, "Tanqueros Activos", rootMenuRed)

    local newTankerList = {}

    for _, tanker in ipairs(tankerListRed) do
        local group = Group.getByName(tanker.groupName)
        if group and group:isExist() then
            table.insert(newTankerList, tanker)

            local name = string.format("%s, %s, %.1fAM, %dX",
                tanker.type, tanker.callsignStr, tanker.frequency, tanker.tacanChannel
            )

            missionCommands.addCommandForCoalition(coalition.side.RED, name, statusMenuRed, function()
                updateTankerStatusMenuRed() -- Refresca también al consultar
                local message = string.format(
                    "Tanquero %s\nCallsign: %s\nFrecuencia: %.1f MHz AM\nTACAN: %dX",
                    tanker.type, tanker.callsignStr, tanker.frequency, tanker.tacanChannel
                )
                trigger.action.outTextForCoalition(coalition.side.RED, message, 60)
            end)
        end
    end

    tankerListRed = newTankerList
end

-- Temporizador para actualizar automáticamente el submenú cada 5 minutos
timer.scheduleFunction(function()
    updateTankerStatusMenuRed()
    return timer.getTime() + 300 -- 300 segundos = 5 minutos
end, {}, timer.getTime() + 300)

-- Crear tanquero nuevo
local function addNewTankerRed(groupName, tankerInfo, position, direction)
    if isTankerExistRed(groupName) then
        trigger.action.outTextForCoalition(coalition.side.RED, "Este tanquero ya está desplegado.", 10)
        return
    end

    local function randomOdd(min, max)
        local r = math.random(math.ceil(min / 2), math.floor(max / 2))
        return r * 2 - 1
    end

    local tacanChannel = randomOdd(1, 126)
    local frequency = math.floor((randomOdd(225, 399)) * 10) / 10
    local callsignNumber = math.random(111, 999)

    table.insert(tankerListRed, {
        name = "Unit_" .. math.random(1000,9999),
        type = tankerInfo.type,
        tacanChannel = tacanChannel,
        frequency = frequency,
        groupName = groupName,
        callsignStr = tostring(callsignNumber)
    })

    local groupData = {
        category = Group.Category.AIRPLANE,
        country = tankerCountryRed,
        name = groupName,
        units = { {
            type = tankerInfo.type,
            name = "Unit_" .. math.random(1000,9999),
            skill = "High",
            x = position.x,
            y = position.y,
            alt = 7620,
            alt_type = "BARO",
            heading = direction.heading,
            speed = 154.4,
            payload = {},
            frequency = frequency,
            communication = true,
            callsign = { tankerInfo.callsign[1], tankerInfo.callsign[2], callsignNumber },
            task = {}
        } },
        route = { points = {} }
    }

    local success, err = pcall(function()
        coalition.addGroup(tankerCountryRed, groupData.category, groupData)
    end)

    if success then
        trigger.action.outTextForCoalition(coalition.side.RED, string.format(
            "Tanquero %s desplegado.\nTACAN: %dX\nFrecuencia: %.1f MHz", 
            tankerInfo.type, tacanChannel, frequency
        ), 60)
        updateTankerStatusMenuRed()
    else
        trigger.action.outTextForCoalition(coalition.side.RED, "Error al crear el tanquero: " .. tostring(err), 10)
    end
end

-- Manejo del marcador
local handlerRed = {}

function handlerRed:onEvent(event)
    if not (event.id == world.event.S_EVENT_MARK_ADDED or event.id == world.event.S_EVENT_MARK_CHANGE) then return end
    if not event.text or not selectedTankerTypeRed then return end

    local text = string.lower(event.text)
    if text ~= "tankerh" and text ~= "tankerv" then return end

    local pos = event.pos
    if not pos then
        trigger.action.outTextForCoalition(coalition.side.RED, "Error al obtener la posición del marcador.", 10)
        return
    end

    local tankerInfo = tankerTypesRed[selectedTankerTypeRed]
    local halfDistance = 15 * 1852

    local point1, direction, heading
    if text == "tankerh" then
        point1 = { x = pos.x, y = pos.z - halfDistance }
        direction = { heading = 90 }
    else
        point1 = { x = pos.x - halfDistance, y = pos.z }
        direction = { heading = 180 }
    end

    local groupName = "Tanker_" .. selectedTankerTypeRed .. "_" .. math.random(1000,9999)
    
    addNewTankerRed(groupName, tankerInfo, point1, direction)

    selectedTankerTypeRed = nil
end

world.addEventHandler(handlerRed)

