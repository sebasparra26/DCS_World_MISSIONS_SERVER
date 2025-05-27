trigger.action.outText("Script de tanqueros cargado", 5)

local tankerCountry = country.id.USA
local selectedTankerType = nil
local tankerList = {}

local rootMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "Tanker")
local statusMenu

local tankerTypes = {
    ["KC-135"] = { type = "KC-135", callsign = {1, 1, 1} },
    ["KC-135 MPRS"] = { type = "KC135MPRS", callsign = {2, 1, 1} }
}

local function isTankerExist(groupName)
    for _, tanker in ipairs(tankerList) do
        if tanker.groupName == groupName then
            return true
        end
    end
    return false
end

local function setTankerType(name)
    if tankerTypes[name] then
        selectedTankerType = name
        trigger.action.outTextForCoalition(coalition.side.BLUE, "Seleccionado: " .. name .. ". Coloca un marcador con texto 'TankerH' (horizontal) o 'TankerV' (vertical).", 10)
    end
end

for name, _ in pairs(tankerTypes) do
    missionCommands.addCommandForCoalition(coalition.side.BLUE, name, rootMenu, function() setTankerType(name) end)
end

local function updateTankerStatusMenu()
    if statusMenu then
        missionCommands.removeItem(statusMenu)
    end

    statusMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "Tanqueros Activos", rootMenu)

    local newTankerList = {}

    for _, tanker in ipairs(tankerList) do
        local group = Group.getByName(tanker.groupName)
        if group and group:isExist() then
            table.insert(newTankerList, tanker)
            local name = string.format("%s, %s, %.1fAM, %dX", tanker.type, tanker.callsignStr, tanker.frequency, tanker.tacanChannel)
            missionCommands.addCommandForCoalition(coalition.side.BLUE, name, statusMenu, function()
                local message = string.format(
                    "Tanquero %s\nCallsign: %s\nFrecuencia: %.1f MHz AM\nTACAN: %dX",
                    tanker.type, tanker.callsignStr, tanker.frequency, tanker.tacanChannel
                )
                trigger.action.outTextForCoalition(coalition.side.BLUE, message, 60)
            end)
        end
    end

    tankerList = newTankerList
end

local function addNewTanker(groupName, tankerInfo, point1, point2, heading)
    if isTankerExist(groupName) then
        trigger.action.outTextForCoalition(coalition.side.BLUE, "Este tanquero ya está desplegado.", 10)
        return
    end

    local altitude = 7620
    local speed = 154.4
    local tacanChannel = math.random(1, 63) * 2
    local frequency = math.random(2510, 2590) / 10
    local callsignNumber = math.random(111, 999)

    table.insert(tankerList, {
        name = "Unit_" .. math.random(1000, 9999),
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
        task = {
            id = "ComboTask",
            params = {
                tasks = {
                    {
                        id = "Tanker",
                        enabled = true,
                        auto = false,
                        number = 1,
                        params = {}
                    }
                }
            }
        },
        units = { {
            type = tankerInfo.type,
            name = "Unit_" .. math.random(1000, 9999),
            skill = "High",
            x = point1.x,
            y = point1.y,
            alt = altitude,
            alt_type = "BARO",
            heading = heading,
            speed = speed,
            payload = {},
            frequency = frequency,
            modulation = 0,
            communication = true,
            callsign = { tankerInfo.callsign[1], tankerInfo.callsign[2], callsignNumber }
        }},
        route = {
            points = {
                {
                    type = "Turning Point",
                    action = "Turning Point",
                    x = point1.x,
                    y = point1.y,
                    alt = altitude,
                    alt_type = "BARO",
                    speed = speed,
                    task = {
                        id = "ComboTask",
                        params = {
                            tasks = {
                                {
                                    enabled = true,
                                    id = "Tanker",
                                    number = 1,
                                    auto = false,
                                    params = {}
                                }
                            }
                        }
                    }
                },
                {
                    type = "Turning Point",
                    action = "Turning Point",
                    x = point2.x,
                    y = point2.y,
                    alt = altitude,
                    alt_type = "BARO",
                    speed = speed,
                    task = {
                        id = "ComboTask",
                        params = {
                            tasks = {
                                {
                                    id = "WrappedAction",
                                    params = {
                                        action = {
                                            id = "SwitchWaypoint",
                                            params = {
                                                goToWaypointIndex = 1,
                                                fromWaypointIndex = 2
                                            }
                                        }
                                    }
                                },
                                {
                                    enabled = true,
                                    id = "Tanker",
                                    number = 1,
                                    auto = false,
                                    params = {}
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    local success, err = pcall(function()
        coalition.addGroup(tankerCountry, groupData.category, groupData)
    end)

    if success then
        trigger.action.outTextForCoalition(coalition.side.BLUE,
            string.format("Tanquero %s desplegado.\nTACAN: %dX\nFrecuencia: %.1f MHz",
                tankerInfo.type, tacanChannel, frequency),
            60
        )
        updateTankerStatusMenu()
    else
        trigger.action.outTextForCoalition(coalition.side.BLUE,
            "Error al desplegar tanquero: " .. tostring(err), 10
        )
    end
end

local handler = {}
function handler:onEvent(event)
    if event.id == world.event.S_EVENT_MARK_CHANGE and event.text then
        local markerText = string.lower(event.text)
        if markerText == "tankerh" or markerText == "tankerv" then
            if not selectedTankerType then
                trigger.action.outTextForCoalition(coalition.side.BLUE, "Selecciona un tipo de tanquero primero.", 10)
                return
            end

            local tankerInfo = tankerTypes[selectedTankerType]
            local point1 = { x = event.pos.x, y = event.pos.z }
            local heading = (markerText == "tankerh") and 90 or 0
            local distanceNM = 50
            local distanceM = distanceNM * 1852
            local point2 = {
                x = point1.x + math.cos(math.rad(heading)) * distanceM,
                y = point1.y + math.sin(math.rad(heading)) * distanceM
            }

            local groupName = "Tanker_" .. math.random(1000, 9999)
            addNewTanker(groupName, tankerInfo, point1, point2, math.rad(heading))
        end
    end
end

world.addEventHandler(handler)
