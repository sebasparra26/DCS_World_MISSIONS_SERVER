-- WhiskeyTangoFoxtgrot_3 EWRS Script v15.9 - Stable
-- Features: coalition-agnostic, multiple radar units, formatted output, friendly & helo callouts, AGL filter, destroyed unit filter, radio toggle.
-- Requires: No external dependencies (standalone).
-- Enemy EWRS Callouts featuring bearing, range, and altitude when enemy aircraft is within 80nm from EWR source and outside 10nm from player. 
-- EWRS callouts appear with greater frequently once enemy aircraft is closer than 10nm. 
-- EWRS callouts include clock direction and relative altitude once enemy aircraft is withing 5nm. 
-- Radio Menu options allow for Friendly callouts and Enemy Helo callouts on a per request basis. 

-- ===Set Up===
-- Works with air and ground based radars. All radar groups need to have "EWR" set as a prefix.
-- Example: "EWR_AWACS", "EWR_Roland"
-- Does not require MIST or MOOSE to be installed, this is a standalone script that you can use in your missions for EWRS callouts. 
-- Can configure callout information in the configuration section. 

-- === CONFIGURATION ===
local normalScanInterval = 25		-- Frequency of EWR callout information when enemy airgcraft is determined to be outside of close threshhold range. Default is 25 seconds.
local closeScanInterval = 3			-- Frequency of EWR callout information when enemy aircraft is determined to be withing close threshold range (within 5nm of Player).
local normalMessageDuration = 15	-- Length of time that EWR callout information is presented on screen for the Player.
local closeMessageDuration = 2		-- Length of time that EWR callout information in presented on screen when enemy is within 5nm. 
local radarRangeNM = 80				-- Range threshold of radar for radar units.
local closeRangeThresholdNM = 10	-- Range threshold for close ewr callouts.
local closeCueThresholdNM = 5  		-- Range threshold after which clock direction & relative altitude are provided in EWR callouts.
local altitudeFloorFeet = 50		-- Altitude floor under which enemy aircraft are hidden from EWR callouts.
local maxContacts = 5				-- Limit on # of aircraft to be displayed on EWR callouts.
local metersPerNM = 1852			-- Constant used to convert distance to nautical miles.
local ewrsEnabled = false			-- Initial setting of EWR callouts, hidden until player turns them on in radio options.
local playerUnit = nil				-- Initial setting for player value for mission start. 

-- === TRACKING DESTROYED UNITS ===
local deadUnits = {}
world.addEventHandler({
    onEvent = function(event)
        if (event.id == world.event.S_EVENT_KILL or event.id == world.event.S_EVENT_DEAD)
        and event.target then
            local killed = event.target
            if killed:getName() then
                deadUnits[killed:getName()] = true
            end
        end
    end
})

-- === UTILITY FUNCTIONS ===
local function get2DDistance(unit1, unit2)
    local p1 = unit1:getPosition().p
    local p2 = unit2:getPosition().p
    return math.sqrt((p1.x - p2.x)^2 + (p1.z - p2.z)^2)
end

local function getAltitudeFeet(unit)
    return unit:getPoint().y * 3.28084
end

local function getAGLFeet(unit)
    local pos = unit:getPoint()
    local terrain = land.getHeight({x = pos.x, y = pos.z})
    return (pos.y - terrain) * 3.28084
end

local function formatNumberWithCommas(n)
    local s = tostring(math.floor(n))
    local k
    while true do
        s, k = s:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return s
end

local function getBearingToEnemy(player, enemy)
    local pPos = player:getPoint()
    local ePos = enemy:getPoint()
    local angleRad = math.atan2(ePos.z - pPos.z, ePos.x - pPos.x)
    local angleDeg = math.deg(angleRad)
    if angleDeg < 0 then angleDeg = angleDeg + 360 end
    return angleDeg
end

local function getAspect(player, enemy)
    local dx = player:getPoint().x - enemy:getPoint().x
    local dz = player:getPoint().z - enemy:getPoint().z
    local angleToPlayer = math.deg(math.atan2(dz, dx))
    if angleToPlayer < 0 then angleToPlayer = angleToPlayer + 360 end

    local headingRad = enemy:getPosition().heading
    if not headingRad then
        local v = enemy:getVelocity()
        if v then headingRad = math.atan2(v.z, v.x) end
    end
    if not headingRad then return "Unknown" end

    local enemyHeading = math.deg(headingRad)
    if enemyHeading < 0 then enemyHeading = enemyHeading + 360 end

    local delta = (enemyHeading - angleToPlayer + 360) % 360
    if delta <= 45 or delta >= 315 then return "Hot"
    elseif delta >= 135 and delta <= 225 then return "Cold"
    elseif delta > 45 and delta < 135 then return "Flanking Left"
    else return "Flanking Right" end
end

local function getRelativeClock(player, enemy)
    local headingRad = player:getPosition().heading
    if not headingRad then
        local vel = player:getVelocity()
        if vel and (vel.x ~= 0 or vel.z ~= 0) then
            headingRad = math.atan2(vel.z, vel.x)
        end
    end
    if not headingRad then return "unknown o'clock" end

    local headingDeg = math.deg(headingRad)
    if headingDeg < 0 then headingDeg = headingDeg + 360 end
    local bearing = getBearingToEnemy(player, enemy)
    local rel = (bearing - headingDeg + 360) % 360
    local clock = math.floor((rel + 15) / 30) % 12
    return (clock == 0 and 12 or clock) .. " o'clock"
end

local function getRelativeAltitude(player, enemy)
    local diff = getAltitudeFeet(enemy) - getAltitudeFeet(player)
    if math.abs(diff) < 500 then return "level"
    elseif diff > 0 then return "high"
    else return "low" end
end

-- === FORMATTING ===
local function formatAltitudeText(alt)
    if alt < 1000 then
        return "Cherubs " .. math.floor(alt / 100 + 0.5)
    else
        return "Angels " .. math.floor(alt / 1000 + 0.5)
    end
end

local function formatContactLine(typeName, bearing, distanceNM, altitudeFeet, aspect, clockCue, altCue)
    local cueString = ""
    if clockCue and altCue then
        cueString = string.format(" (%s, %s)", clockCue, altCue)
    end
    return string.format("%-16s BRAA %03.0f° / %2.0fnm  ALT %-13s  ASPECT %-14s%s",
        typeName,
        bearing,
        distanceNM,
        formatAltitudeText(altitudeFeet),
        aspect,
        cueString
    )
end

-- === PLAYER & RADAR DETECTION ===
local function findPlayerUnit()
    for _, side in ipairs({coalition.side.BLUE, coalition.side.RED}) do
        for _, group in ipairs(coalition.getGroups(side, Group.Category.AIRPLANE)) do
            for _, unit in ipairs(group:getUnits()) do
                if unit and unit:isActive() and unit:getPlayerName() then
                    return unit, side
                end
            end
        end
    end
    return nil, nil
end

local function getActiveAirUnits(side)
    local units = {}
    for _, group in ipairs(coalition.getGroups(side, Group.Category.AIRPLANE)) do
        for _, unit in ipairs(group:getUnits()) do
            if unit and unit:isActive() then table.insert(units, unit) end
        end
    end
    return units
end

local function getAllRadarUnits(side)
    local radars = {}
    local function add(category)
        for _, group in ipairs(coalition.getGroups(side, category)) do
            if group:getName():sub(1, 4) == "EWR_" then
                local unit = group:getUnit(1)
                if unit and unit:isActive() then table.insert(radars, unit) end
            end
        end
    end
    add(Group.Category.AIRPLANE)
    add(Group.Category.GROUND)
    return radars
end

-- === MAIN EWRS SCAN ===
local function performEWRScan()
    if not ewrsEnabled then return timer.getTime() + normalScanInterval end
    local found, side = findPlayerUnit()
    if not found then return timer.getTime() + 5 end
    playerUnit = found
    local enemySide = (side == coalition.side.BLUE) and coalition.side.RED or coalition.side.BLUE
    local radars = getAllRadarUnits(side)
    local enemies = getActiveAirUnits(enemySide)

    local seen = {}
    local contacts = {}
    local threatClose = false

    for _, radar in ipairs(radars) do
        for _, enemy in ipairs(enemies) do
            local name = enemy:getName()
            local agl = getAGLFeet(enemy)
            if not seen[name] and not deadUnits[name] and enemy:getLife() > 1 and agl > altitudeFloorFeet then
                local distMeters = get2DDistance(radar, enemy)
                if distMeters <= radarRangeNM * metersPerNM then
                    seen[name] = true
                    local distPlayer = get2DDistance(playerUnit, enemy)
                    local distNM = distPlayer / metersPerNM
                    if distNM <= closeRangeThresholdNM then threatClose = true end

                    local bearing = getBearingToEnemy(playerUnit, enemy)
                    local alt = getAltitudeFeet(enemy)
                    local aspect = getAspect(playerUnit, enemy)
                    local clockCue, altCue = nil, nil
                    if distNM <= closeCueThresholdNM then
                        clockCue = getRelativeClock(playerUnit, enemy)
                        altCue = getRelativeAltitude(playerUnit, enemy)
                    end

                    table.insert(contacts, {
                        sortDistance = distPlayer,
                        line = formatContactLine(enemy:getTypeName(), bearing, distNM, alt, aspect, clockCue, altCue)
                    })
                end
            end
        end
    end

    if #contacts == 0 then return timer.getTime() + normalScanInterval end
    table.sort(contacts, function(a, b) return a.sortDistance < b.sortDistance end)

    local report = "EWRS Report\n\n"
    for i = 1, math.min(#contacts, maxContacts) do
        report = report .. contacts[i].line .. "\n"
    end

    local duration = threatClose and closeMessageDuration or normalMessageDuration
    local interval = threatClose and closeScanInterval or normalScanInterval
    trigger.action.outTextForGroup(playerUnit:getGroup():getID(), report, duration)
    return timer.getTime() + interval
end

-- === RADIO COMMANDS ===
local function reportFriendlyPicture()
    local found, side = findPlayerUnit()
    if not found then return end
    playerUnit = found
    local radars = getAllRadarUnits(side)
    local units = getActiveAirUnits(side)
    local seen, contacts = {}, {}

    for _, radar in ipairs(radars) do
        for _, unit in ipairs(units) do
            if unit ~= playerUnit and not seen[unit:getName()] then
                local dist = get2DDistance(radar, unit)
                if dist <= radarRangeNM * metersPerNM then
                    seen[unit:getName()] = true
                    local distPlayer = get2DDistance(playerUnit, unit)
                    local bearing = getBearingToEnemy(playerUnit, unit)
                    local alt = getAltitudeFeet(unit)
                    local aspect = getAspect(playerUnit, unit)
                    table.insert(contacts, {
                        sortDistance = distPlayer,
                        line = formatContactLine(unit:getTypeName(), bearing, distPlayer / metersPerNM, alt, aspect)
                    })
                end
            end
        end
    end

    if #contacts == 0 then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(), "No friendly aircraft detected.", 5)
        return
    end

    table.sort(contacts, function(a, b) return a.sortDistance < b.sortDistance end)
    local report = "FRIENDLY PICTURE\n\n"
    for i = 1, math.min(#contacts, maxContacts) do
        report = report .. contacts[i].line .. "\n"
    end
    trigger.action.outTextForGroup(playerUnit:getGroup():getID(), report, normalMessageDuration)
end

local function reportEnemyHelos()
    local found, side = findPlayerUnit()
    if not found then return end
    playerUnit = found
    local enemySide = (side == coalition.side.BLUE) and coalition.side.RED or coalition.side.BLUE
    local radars = getAllRadarUnits(side)
    local helos = coalition.getGroups(enemySide, Group.Category.HELICOPTER)
    local seen, contacts = {}, {}

    for _, radar in ipairs(radars) do
        for _, group in ipairs(helos) do
            for _, unit in ipairs(group:getUnits()) do
                local name = unit:getName()
                if unit and unit:isActive() and unit:getLife() > 1 and not seen[name] and not deadUnits[name] and getAGLFeet(unit) > altitudeFloorFeet then
                    seen[name] = true
                    local dist = get2DDistance(playerUnit, unit)
                    local bearing = getBearingToEnemy(playerUnit, unit)
                    local alt = getAltitudeFeet(unit)
                    local aspect = getAspect(playerUnit, unit)
                    table.insert(contacts, {
                        sortDistance = dist,
                        line = formatContactLine(unit:getTypeName(), bearing, dist / metersPerNM, alt, aspect)
                    })
                end
            end
        end
    end

    if #contacts == 0 then
        trigger.action.outTextForGroup(playerUnit:getGroup():getID(), "No enemy helicopters detected.", 5)
        return
    end

    table.sort(contacts, function(a, b) return a.sortDistance < b.sortDistance end)
    local report = "ENEMY HELICOPTERS\n\n"
    for i = 1, math.min(#contacts, maxContacts) do
        report = report .. contacts[i].line .. "\n"
    end
    trigger.action.outTextForGroup(playerUnit:getGroup():getID(), report, normalMessageDuration)
end

-- === RADIO MENU INIT ===
local function addRadioMenuIfReady()
    local found = findPlayerUnit()
    if not found then return timer.getTime() + 5 end
    playerUnit = found
    local groupID = playerUnit:getGroup():getID()
    missionCommands.addCommandForGroup(groupID, "Toggle EWRS Callouts", nil, function()
        ewrsEnabled = not ewrsEnabled
        trigger.action.outTextForGroup(groupID, "EWRS is now " .. (ewrsEnabled and "enabled" or "disabled"), 5)
    end)
    missionCommands.addCommandForGroup(groupID, "Request Friendly Picture", nil, reportFriendlyPicture)
    missionCommands.addCommandForGroup(groupID, "Request Enemy Helicopter Picture", nil, reportEnemyHelos)
    trigger.action.outTextForGroup(groupID, "EWRS radio menu added.", 5)
end

-- === INITIALIZATION ===
trigger.action.outText("WhiskeyTangoFoxtgrot_3 EWRS script initialized.\n See Options in Radio Menu to activate.", 5)
timer.scheduleFunction(addRadioMenuIfReady, {}, timer.getTime() + 1)
timer.scheduleFunction(function() return performEWRScan() end, {}, timer.getTime() + 2)
