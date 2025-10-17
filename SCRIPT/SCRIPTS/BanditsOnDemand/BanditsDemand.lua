-- Bandit on Demand™ - spawn bandits with your voice, anywhere, any map.
-- By winghunter
-- github https://github.com/fyyyyy/Bandit-on-Demand
-- Discussion thread https://forums.eagle.ru/topic/293643-bandit-on-demand-spawn-bandits-with-your-voice-anywhere-any-map-bfmbvr/
-- Based on the script from seska with <3 <3 <3



-- editor game state flags
StateFlags = {
    numberOfEnemies =   3001,
    enemyType =         3002,
    restart =           3003, -- auto-restart on/off
    totalEnemies =      3004, -- total existing
    sam =               3005, -- SAMs on/off
    missiles =          3006, -- Missiles on/off
}

local ctl = {}
_distance = 5
_angels = -1


function log_table(table)
    mist.log:warn(mist.utils.oneLineSerialize(table))
end


SkillLevels = {
    EXEL = "Excellent",
    HIGH = "High",
    GOOD = "Good",
    AVRG = "Average",
    RAND = "Random",
}

SkillDesc = {
    Excellent = "A+",
    High = "B+",
    Good = "C+",
    Average = "D+",
    Random = "RND", 
}

_skill = SkillLevels.EXEL


EnemyTypes = {

--------------------------------------MODERN------------------------------------------------------------

    F14A = 1,
    F14B = 2,
    F15C = 3,
    F15E = 4,
    F16CM = 5,
    F18C = 6,
    AV8B = 7,
    J11A = 8,
    JF17 = 9,
    MIG31 = 10,
    SU27 = 11,
    SU30 = 12,
    SU33 = 13,
   

--------------------------------------COLD WAR---------------------------------------------------------

    F86F = 14,
    F5E = 15,
    A10C = 16,
    F4E = 17,
    MIG15 = 18,
    MIG21 = 19,
    MIG23 = 20,
    MIG29 = 21,
    M2000C = 22,
    MF1EE = 23,
    AJS37 = 24,
    MIG19 = 25,
    

--------------------------------------WARBIRDS--------------------------------------------------------- 

    F4U = 26,
    P47 = 27,
    P51 = 28,
    SPITFIRE = 29,
    MOSQUITO = 30,
    I16 = 31,
    BF109 = 32,
    FW190A = 33,
    FW190D = 34,
    


    --------------------------------------Helis--------------------------------------------------------- 

    UH1H = 35,
    OH58D = 36,
    AH1W = 37,
    AH64D = 38,
    KA50 = 39,
    MI24P = 40,
    MI28N = 41,
    SA34L = 42,



}

EnemyKeys = {}
-- reverse keys and values for inverse lookup
for i,v in pairs(EnemyTypes) do
    EnemyKeys[v] = i
end


Menus = {
    commandMenu = nil,
    startCmd = nil,
    startRandomCmd = nil,
    autoRestartCmd = nil,
    MissilesCmdOn = nil,
    MissilesCmdOff = nil,
}


-- If bandits dont have a missile configuration, just set the same group name for missiles_id and guns_id
EnemyGroups = {

    --------------------------------------MODERN------------------------------------------------------------

    [EnemyKeys[1]] = { --Red-F14A
        description = "Red-F14'A",
        guns_id = "Red-F14A",
        missiles_id = "Red-F14A-M",    
    },
    [EnemyKeys[2]] = { --Red-F14B
        description = "Red-F14'B",
        guns_id = "Red-F14B",
        missiles_id = "Red-F14B-M",    
    },
    [EnemyKeys[3]] = { --Red-F15C
        description = "F-15C's",
        guns_id = "Red-F15C",
        missiles_id = "Red-F15C-M",    
    },
    [EnemyKeys[4]] = { --Red-F15E
        description = "F-15E's",
        guns_id = "Red-F15E",
        missiles_id = "Red-F15E-M",    
    },
    [EnemyKeys[5]] = {  --Red-F16C
        description = "F-16C's",
        guns_id = "Red-F16C",
        missiles_id = "Red-F16C-M",    
    },
    [EnemyKeys[6]] = {  --Red-F18C
        description = "F-18C's",
        guns_id = "Red-F18C",
        missiles_id = "Red-F18C-M",    
    },
    [EnemyKeys[7]] = {  --Red-AV8B
        description = "AV-8B's",
        guns_id = "Red-AV-8B",
        missiles_id = "Red-AV-8B-M",    
    },
    [EnemyKeys[8]] = {  --Red-J-11A
        description = "J-11A's",
        guns_id = "Red-J-11A",
        missiles_id = "Red-J-11A-M",    
    },
    [EnemyKeys[9]] = {  --Red-JF-17
        description = "JF-17's",
        guns_id = "Red-JF-17",
        missiles_id = "Red-JF-17-M",    
    },
    [EnemyKeys[10]] = { --Red-MiG-31
        description = "MiG-31's",
        guns_id = "Red-MiG-31",
        missiles_id = "Red-MiG-31-M",    
    },
    [EnemyKeys[11]] = { --Red-SU-27
        description = "SU-27's",
        guns_id = "Red-SU-27",
        missiles_id = "Red-SU-27-M",    
    },
    [EnemyKeys[12]] = { --Red-SU-30
        description = "SU-30's",
        guns_id = "Red-SU-30",
        missiles_id = "Red-SU-30-M",    
    },
    [EnemyKeys[13]] = { --Red-SU-33
        description = "SU-33's",
        guns_id = "Red-SU-33",
        missiles_id = "Red-SU-33-M",    
    },

  --------------------------------------MODERN------------------------------------------------------------

    [EnemyKeys[14]] = { --Red-F86
        description = "F86-F's",
        guns_id = "Red-F86-F",
        missiles_id = "Red-F86-F-M",    
    },
    [EnemyKeys[15]] = {
        description = "F-5E's",
        guns_id = "Red-F-5E",
        missiles_id = "Red-F-5E-M",    
    },
    [EnemyKeys[16]] = {
        description = "A10C-II's",
        guns_id = "Red-A10C-II",
        missiles_id = "Red-A10C-II-M",    
    },
    [EnemyKeys[17]] = {
        description = "F-4E's",
        guns_id = "Red-F-4E",
        missiles_id = "Red-F-4E-M",    
    },    
    [EnemyKeys[18]] = {
        description = "MIG-15's",
        guns_id = "Red-MIG-15",
        missiles_id = "Red-MIG-15",    
    },    
    [EnemyKeys[19]] = {
        description = "MIG-21's",
        guns_id = "Red-MIG-21",
        missiles_id = "Red-MIG-21-M",    
    },    
    [EnemyKeys[20]] = {
        description = "MIG-23's",
        guns_id = "Red-MIG-23",
        missiles_id = "Red-MIG-23-M",    
    },
      [EnemyKeys[21]] = {
        description = "MIG-29's",
        guns_id = "Red-MIG-29",
        missiles_id = "Red-MIG-29-M",    
    },
      [EnemyKeys[22]] = {
        description = "M2000-C's",
        guns_id = "Red-M2000-C",
        missiles_id = "Red-M2000-C-M",    
    },
       [EnemyKeys[23]] = {
        description = "M-F1's",
        guns_id = "Red-M-F1",
        missiles_id = "Red-M-F1-M",    
    },        
        [EnemyKeys[24]] = {
        description = "AJS-37's",
        guns_id = "Red-AJS-37",
        missiles_id = "Red-AJS-37-M",    
    },
    [EnemyKeys[25]] = {
        description = "MIG-19's",
        guns_id = "Red-MIG-19",
        missiles_id = "Red-MIG-19-M",
    },      
 --------------------------------------WARBIRDS------------------------------------------------------------  

     [EnemyKeys[26]] = {
        description = "F-4U's",
        guns_id = "Red-F-4U",
        missiles_id = "Red-F-4U",
    },  

    [EnemyKeys[27]] = {
        description = "P-47's",
        guns_id = "Red-P-47",
        missiles_id = "Red-P-47",
    },
    [EnemyKeys[28]] = {
        description = "P-51's",
        guns_id = "Red-P-51",
        missiles_id = "Red-P-51",
    },
    [EnemyKeys[29]] = {
        description = "Spitfire's",
        guns_id = "Red-Spitfire",
        missiles_id = "Red-Spitfire",
    },
    [EnemyKeys[30]] = {
        description = "Mosquito's",
        guns_id = "Red-Mosquito",
        missiles_id = "Red-Mosquito",
    },
     [EnemyKeys[31]] = {
        description = "I-16's",
        guns_id = "Red-I-16",
        missiles_id = "Red-I-16",
    },
     [EnemyKeys[32]] = {
        description = "BF-109's",
        guns_id = "Red-BF-109",
        missiles_id = "Red-BF-109",
    },
      [EnemyKeys[33]] = {
        description = "FW-190A's",
        guns_id = "Red-FW-190A",
        missiles_id = "Red-FW-190A",
    },
      [EnemyKeys[34]] = {
        description = "FW-190D's",
        guns_id = "Red-FW-190D",
        missiles_id = "Red-FW-190D",
    },
 --------------------------------------Helis------------------------------------------------------------  

    [EnemyKeys[35]] = {
        description = "UH1H's",
        guns_id = "Red-UH1H",
        missiles_id = "Red-UH1H",
    },
    [EnemyKeys[36]] = {
        description = "OH58D's",
        guns_id = "Red-OH58D",
        missiles_id = "Red-OH58D-M",
    },
    [EnemyKeys[37]] = {
        description = "UH1W's",
        guns_id = "Red-UH1W",
        missiles_id = "Red-UH1W-M",
    },
    [EnemyKeys[38]] = {
        description = "AH64D's",
        guns_id = "Red-AH64D",
        missiles_id = "Red-AH64D-M",
    },
    [EnemyKeys[39]] = {
        description = "KA50's",
        guns_id = "Red-KA50",
        missiles_id = "Red-KA50-M",
    },
    [EnemyKeys[40]] = {
        description = "MI24P's",
        guns_id = "Red-MI24P",
        missiles_id = "Red-MI24P-M",
    },
    [EnemyKeys[41]] = {
        description = "MI28N's",
        guns_id = "Red-MI28N",
        missiles_id = "Red-MI28N-M",
    },
    [EnemyKeys[42]] = {
        description = "SA342L's",
        guns_id = "Red-SA342L",
        missiles_id = "Red-SA342L-M",
    },

}

function ctl.send_message(text, displayTime)
    displayTime = displayTime or 5
    
    local msg = {}
    
    msg.displayTime = displayTime
    msg.msgFor = { coa = {'all'}}
    msg.text = text

    mist.message.add(msg)
end



function ctl.setDistance(distance, silent)
    _distance = distance
    if (not silent) then ctl.updatedSettings() end
end

function ctl.getDistanceMeters()
    return mist.utils.NMToMeters(_distance)
end


function ctl.setAngels(angels, silent)
    _angels = angels
    if (not silent) then ctl.updatedSettings() end
end

function ctl.getAngels()
    if _angels > -1 then
        return _angels .. 'k'
    else
        return "eq"
    end
end


function ctl.setSkillLevel(skill, silent)
    _skill = skill
    if (not silent) then ctl.updatedSettings() end
end

function ctl.getSkillDesc(s)
    return SkillDesc[s or _skill]
end



function ctl.updatedSettings()
    ctl.send_message("Set " .. ctl.getSettings(), 2)
    ctl.updateCommandMenu()
end

function ctl.getSettings( ... )
    return ctl.getNumberOfEnemies() .. "× " .. ctl.getSkillDesc() .. ' ' .. ctl.getEnemyDesc() .. " @ " .. _distance .. "nm alt:" .. ctl.getAngels()
end



function ctl.setNumEnemies(num, silent)
    local total = ctl.getTotalEnemies()
    trigger.action.setUserFlag(StateFlags.numberOfEnemies, num)
    ctl.setTotalEnemies(total + num)
    if (not silent) then ctl.updatedSettings() end
end

function ctl.setEnemyType(et, silent)
    trigger.action.setUserFlag(StateFlags.enemyType, EnemyTypes[et])
    if (not silent) then ctl.updatedSettings() end
end

function ctl.getEnemyType()
    et = trigger.misc.getUserFlag(StateFlags.enemyType)
    enemyType = EnemyKeys[et]
    if (enemyType) then
        return enemyType
    else
        return "Error: " .. et
    end
end

function ctl.getEnemyDesc()
    local missiles = trigger.misc.getUserFlag(StateFlags.missiles)
    if missiles == 1 then
        txt = " Mis"
    else
        txt = " Gun"
    end

    enemyType = ctl.getEnemyType()
    if (enemyType and EnemyGroups[enemyType]) then
        return EnemyGroups[enemyType].description ..txt
    else
        return "Error: " .. enemyType
    end
end

function ctl.getNumberOfEnemies()
    return trigger.misc.getUserFlag(StateFlags.numberOfEnemies)
end

function ctl.getTotalEnemies()
    return trigger.misc.getUserFlag(StateFlags.totalEnemies)
end

function ctl.setTotalEnemies(num)
    return trigger.action.setUserFlag(StateFlags.totalEnemies, num)
end


function ctl.spawnGroup(rnd)
    if rnd == true then spawnMode = "RANDOM" else spawnMode = "configured" end

    local numberOfEnemies = ctl.getNumberOfEnemies()

    local grp = ctl.getGroupName()
    if (not grp) then return end

    local player = coalition.getPlayers(coalition.side.BLUE)[1]
    local point = Unit.getPoint(player)

    local spawnPoint = mist.projectPoint(point, ctl.getDistanceMeters(), mist.getHeading(player))
    -- direct AI to meet half way between spawnPoint and player aircraft
    local middlePoint = mist.projectPoint(point, ctl.getDistanceMeters() / 2, mist.getHeading(player))

    ctl.send_message(
        "\nSpawning " .. spawnMode .. " Bandits\n" ..
        "---------------\n" ..
        ctl.getSettings(),
        2
    )

    local newData = mist.getGroupData(grp)
    if (not newData) then
        ctl.send_message("Error: group not in editor: " .. grp)
        return
    end

    local unit = newData.units[1]
    unit.skill = _skill
    log_table(newData)
    
    local spawnWaypoint = mist.utils.vecToWP(spawnPoint)
    local middleWaypoint = mist.utils.vecToWP(middlePoint)
    --alternative: direct AI to player position
    --local playerPosition = mist.utils.unitToWP(player)
    
    route = mist.getGroupRoute(grp, 'task')
    firstWaypoint = route[1]
    firstWaypoint.x = spawnWaypoint.x
    firstWaypoint.y = spawnWaypoint.y

    if _angels > -1 then
        local altInMeters = mist.utils.feetToMeters(_angels * 1000)
        spawnPoint.y = altInMeters
        firstWaypoint.alt = altInMeters
        middleWaypoint.alt = altInMeters
        unit.alt = altInMeters
    end

    --playerPosition.task = firstWaypoint.task
    --playerPosition.type = firstWaypoint.type
    middleWaypoint.task = firstWaypoint.task
    middleWaypoint.type = firstWaypoint.type

    newData.route = {
        [1] = firstWaypoint,
        [2] = middleWaypoint
    }

    -- Spawn enemies as individuals rather than inside a group. This improves AI behaviour in a guns/IR missiles dogfight.
    -- The group AI works OK with radar missiles, but not with guns or IR. As only one aircraft in the group will get on your six.
    local spawnAsGroup = false

    if (spawnAsGroup) then
        newData.units = {}
        for i = 1, numberOfEnemies do
            newData.units[i] = mist.utils.deepCopy(unit)
            newData.units[i].unitName = string.sub(grp, 5) .. '@' .. _skill .. '-' .. i
        end
        ctl.teleport(newData, newData.groupName, spawnPoint)
    else -- spawn each aircraft as individual group - improves AI behaviour for dogfights
        newData.units = {[1] = unit}
        point = mist.utils.deepCopy(spawnPoint)
        for i = 1, numberOfEnemies do
            singleUnit = mist.utils.deepCopy(newData)
            singleUnit.units[1].unitName = string.sub(grp, 5) .. '@' .. _skill .. '-' .. i
            ctl.teleport(singleUnit, singleUnit.groupName .. '_' .. i, ctl.disperseUnit(point, i * 50))
        end
    end
end

function ctl.disperseUnit( point , offset)
    point.x = point.x + (offset)
    point.z = point.z + (offset)
    point.y = point.y + (offset / 2) -- altitude
    return point
end

function ctl.teleport( group, groupName , spawnPoint)
    vars = {
        point = spawnPoint,
        gpName = groupName,
        groupData = group,
        route = group.route,
        action = 'respawn',
    }
    g = mist.teleportToPoint(vars)
    log_table(g)
end

function ctl.spawnRandomGroup()
    ctl.setNumEnemies(mist.random(1,4), true)
    ctl.setEnemyType(EnemyKeys[mist.random(1, 20)], true)
    ctl.spawnGroup(true)
    ctl.updateCommandMenu()
end

function ctl.doRestart()
    local current_val = trigger.misc.getUserFlag(StateFlags.restart)
    if current_val == 1 then
        trigger.action.setUserFlag(StateFlags.restart, 0)
    else
        trigger.action.setUserFlag(StateFlags.restart, 1)
    end
end

function ctl.toggleSAMs(bool)
    if bool == false then
        ctl.send_message("SAM sites OFF", 2)
        trigger.action.setUserFlag(StateFlags.sam, 0)
    else
        ctl.send_message("SAM sites ON", 2)
        trigger.action.setUserFlag(StateFlags.sam, 1)
    end
    ctl.updateCommandMenu()
end

function ctl.toggleMissiles(bool)
    if bool == false then
        ctl.send_message("Next Spawn: Missiles OFF. Guns only", 2)
        trigger.action.setUserFlag(StateFlags.missiles, 0)
    else
        ctl.send_message("Next Spawn: Missiles ON", 2)
        trigger.action.setUserFlag(StateFlags.missiles, 1)
    end
    ctl.updateCommandMenu()
end

function ctl.getGroupName()
    local missiles = trigger.misc.getUserFlag(StateFlags.missiles)
    local enemyType = ctl.getEnemyType()
    local enemyGroup = EnemyGroups[enemyType]
    if (not enemyGroup) then
        ctl.send_message("Error: enemyGroup not found: " .. enemyGroup)
        return ""
    end

    local groupId =nil
    if missiles == 1 then
        -- unit groups ending with "-M"
        groupId = enemyGroup.missiles_id
    else
        groupId = enemyGroup.guns_id
    end

    if (not groupId) then
        ctl.send_message("Error: groupId not found: " .. groupId)
        return ""
    else
        return groupId
    end
end


function ctl.initializeF10Menu()
    -- Raíz: F10 / Other / Bandits on Demand
    local mainMenu = missionCommands.addSubMenu("Bandits on Demand", nil)

    -- Enemy Count
    local countMenu = missionCommands.addSubMenu("Enemy Count", mainMenu)
    missionCommands.addCommand("1x bandit",  countMenu, ctl.setNumEnemies, 1)
    missionCommands.addCommand("2x bandits", countMenu, ctl.setNumEnemies, 2)
    missionCommands.addCommand("3x bandits", countMenu, ctl.setNumEnemies, 3)
    missionCommands.addCommand("4x bandits", countMenu, ctl.setNumEnemies, 4)
    missionCommands.addCommand("5x bandits", countMenu, ctl.setNumEnemies, 5)
    missionCommands.addCommand("6x bandits", countMenu, ctl.setNumEnemies, 6)
    missionCommands.addCommand("7x bandits", countMenu, ctl.setNumEnemies, 7)
    missionCommands.addCommand("8x bandits", countMenu, ctl.setNumEnemies, 8)

    -- Enemy Type (-> Modern / Coldwar / Warbirds / Helicopters)
    local enemiesMenu = missionCommands.addSubMenu("Enemy Type", mainMenu)

    local modernMenu = missionCommands.addSubMenu("Modern", enemiesMenu)
    missionCommands.addCommand("F-14A Tomcat",       modernMenu, ctl.setEnemyType, "F14A")
    missionCommands.addCommand("F-14B Tomcat",       modernMenu, ctl.setEnemyType, "F14B")
    missionCommands.addCommand("F-15C Eagle",        modernMenu, ctl.setEnemyType, "F15C")
    missionCommands.addCommand("F-15E Strike Eagle", modernMenu, ctl.setEnemyType, "F15E")
    missionCommands.addCommand("F-16C Viper",        modernMenu, ctl.setEnemyType, "F16CM")
    missionCommands.addCommand("F/A-18C Hornet",     modernMenu, ctl.setEnemyType, "F18C")
    missionCommands.addCommand("AV-8B Harrier",      modernMenu, ctl.setEnemyType, "AV8B")
    missionCommands.addCommand("J-11A",              modernMenu, ctl.setEnemyType, "J11A")
    missionCommands.addCommand("JF-17 Thunder",      modernMenu, ctl.setEnemyType, "JF17")
    missionCommands.addCommand("MiG-31 Foxhound",    modernMenu, ctl.setEnemyType, "MIG31")
    missionCommands.addCommand("Su-27 Flanker",      modernMenu, ctl.setEnemyType, "SU27")
    missionCommands.addCommand("Su-30 Flanker C",    modernMenu, ctl.setEnemyType, "SU30")
    missionCommands.addCommand("Su-33 Flanker D",    modernMenu, ctl.setEnemyType, "SU33")

    local coldwarMenu = missionCommands.addSubMenu("Coldwar", enemiesMenu)
    missionCommands.addCommand("F-86F Sabre",           coldwarMenu, ctl.setEnemyType, "F86F")
    missionCommands.addCommand("F-5E Tiger II",         coldwarMenu, ctl.setEnemyType, "F5E")
    missionCommands.addCommand("A-10C II Tank Killer",  coldwarMenu, ctl.setEnemyType, "A10C")
    missionCommands.addCommand("F-4E Phantom II",       coldwarMenu, ctl.setEnemyType, "F4E")
    missionCommands.addCommand("MiG-15bis",             coldwarMenu, ctl.setEnemyType, "MIG15")
    missionCommands.addCommand("MiG-19P Farmer",        coldwarMenu, ctl.setEnemyType, "MIG19")
    missionCommands.addCommand("MiG-21bis Fishbed",     coldwarMenu, ctl.setEnemyType, "MIG21")
    missionCommands.addCommand("MiG-23MLA Flogger",     coldwarMenu, ctl.setEnemyType, "MIG23")
    missionCommands.addCommand("MiG-29 Fulcrum",        coldwarMenu, ctl.setEnemyType, "MIG29")
    missionCommands.addCommand("Mirage 2000C",          coldwarMenu, ctl.setEnemyType, "M2000C")
    missionCommands.addCommand("Mirage F1EE",           coldwarMenu, ctl.setEnemyType, "MF1EE")
    missionCommands.addCommand("AJS-37 Viggen",         coldwarMenu, ctl.setEnemyType, "AJS37")

    local warbirdsMenu = missionCommands.addSubMenu("Warbirds", enemiesMenu)
    missionCommands.addCommand("F4U Corsair",           warbirdsMenu, ctl.setEnemyType, "F4U")
    missionCommands.addCommand("P-47 Thunderbolt",      warbirdsMenu, ctl.setEnemyType, "P47")
    missionCommands.addCommand("P-51 Mustang",          warbirdsMenu, ctl.setEnemyType, "P51")
    missionCommands.addCommand("Spitfire LF Mk.IX",     warbirdsMenu, ctl.setEnemyType, "SPITFIRE")
    missionCommands.addCommand("Mosquito FB Mk.VI",     warbirdsMenu, ctl.setEnemyType, "MOSQUITO")
    missionCommands.addCommand("I-16",                  warbirdsMenu, ctl.setEnemyType, "I16")
    missionCommands.addCommand("Bf 109 K-4",            warbirdsMenu, ctl.setEnemyType, "BF109")
    missionCommands.addCommand("Fw 190 A-8",            warbirdsMenu, ctl.setEnemyType, "FW190A")
    missionCommands.addCommand("Fw 190 D-9",            warbirdsMenu, ctl.setEnemyType, "FW190D")

    local helisMenu = missionCommands.addSubMenu("Helicopters", enemiesMenu)
    missionCommands.addCommand("UH-1H Huey",        helisMenu, ctl.setEnemyType, "UH1H")
    missionCommands.addCommand("OH-58D Kiowa",      helisMenu, ctl.setEnemyType, "OH58D")
    missionCommands.addCommand("AH-1W Super Cobra", helisMenu, ctl.setEnemyType, "AH1W")
    missionCommands.addCommand("AH-64D Apache",     helisMenu, ctl.setEnemyType, "AH64D")
    missionCommands.addCommand("Ka-50 Black Shark", helisMenu, ctl.setEnemyType, "KA50")
    missionCommands.addCommand("Mi-24P Hind",       helisMenu, ctl.setEnemyType, "MI24P")
    missionCommands.addCommand("Mi-28N Havoc",      helisMenu, ctl.setEnemyType, "MI28N")
    missionCommands.addCommand("SA342L Gazelle",    helisMenu, ctl.setEnemyType, "SA34L")

    -- Spawn Distance
    local distanceMenu = missionCommands.addSubMenu("Spawn Distance", mainMenu)
    missionCommands.addCommand("behind me", distanceMenu, ctl.setDistance, -1)
    missionCommands.addCommand("1 mile",    distanceMenu, ctl.setDistance, 1)
    missionCommands.addCommand("5 miles",   distanceMenu, ctl.setDistance, 5)
    missionCommands.addCommand("10 miles",  distanceMenu, ctl.setDistance, 10)
    missionCommands.addCommand("25 miles",  distanceMenu, ctl.setDistance, 25)
    missionCommands.addCommand("50 miles",  distanceMenu, ctl.setDistance, 50)
    missionCommands.addCommand("75 miles",  distanceMenu, ctl.setDistance, 75)
    missionCommands.addCommand("100 miles", distanceMenu, ctl.setDistance, 100)
    missionCommands.addCommand("150 miles", distanceMenu, ctl.setDistance, 150)

    -- Altitude
    local angelsMenu = missionCommands.addSubMenu("Altitude", mainMenu)
    missionCommands.addCommand("my altitude", angelsMenu, ctl.setAngels, -1)
    missionCommands.addCommand("1,000 feet",  angelsMenu, ctl.setAngels, 1)
    missionCommands.addCommand("5,000 feet",  angelsMenu, ctl.setAngels, 5)
    missionCommands.addCommand("10k feet",    angelsMenu, ctl.setAngels, 10)
    missionCommands.addCommand("15k feet",    angelsMenu, ctl.setAngels, 15)
    missionCommands.addCommand("20k feet",    angelsMenu, ctl.setAngels, 20)
    missionCommands.addCommand("25k feet",    angelsMenu, ctl.setAngels, 25)
    missionCommands.addCommand("30k feet",    angelsMenu, ctl.setAngels, 30)
    missionCommands.addCommand("40k feet",    angelsMenu, ctl.setAngels, 40)
    missionCommands.addCommand("50k feet",    angelsMenu, ctl.setAngels, 50)

    -- Enemy Skill
    local skillMenu = missionCommands.addSubMenu("Enemy Skill", mainMenu)
    missionCommands.addCommand(SkillLevels.AVRG .. " (" .. ctl.getSkillDesc(SkillLevels.AVRG) .. ")", skillMenu, ctl.setSkillLevel, SkillLevels.AVRG)
    missionCommands.addCommand(SkillLevels.GOOD .. " (" .. ctl.getSkillDesc(SkillLevels.GOOD) .. ")", skillMenu, ctl.setSkillLevel, SkillLevels.GOOD)
    missionCommands.addCommand(SkillLevels.HIGH .. " (" .. ctl.getSkillDesc(SkillLevels.HIGH) .. ")", skillMenu, ctl.setSkillLevel, SkillLevels.HIGH)
    missionCommands.addCommand(SkillLevels.EXEL .. " (" .. ctl.getSkillDesc(SkillLevels.EXEL) .. ")", skillMenu, ctl.setSkillLevel, SkillLevels.EXEL)
    missionCommands.addCommand(SkillLevels.RAND .. " (" .. ctl.getSkillDesc(SkillLevels.RAND) .. ")", skillMenu, ctl.setSkillLevel, SkillLevels.RAND)

    -- Commands (todo dentro de mainMenu)
    commandMenu = missionCommands.addSubMenu("Commands", mainMenu)
    ctl.updateCommandMenu()

    ctl.send_message("Bandits on Demand listo en F10 -> Other -> Bandits on Demand", 5)
      ctl.send_message(
        "Use F10 Menu or VoiceAttack\n" ..
        "=======================\n" ..
        "1. Select number of bandits\n" ..
        "2. Select bandit aircraft type\n" ..
        "3. Select spawn distance\n" ..
        "4. Use Command menu to 'Spawn Bandits'\n" ..
        "    Default Bandits: " .. ctl.getSettings() .. "\n" ..
        "    Default SAM sites: OFF\n" ..
        "    Default Missiles: OFF\n" ..
        "=======================\n",
        5
    )
end

    
  


function ctl.updateCommandMenu()
    -- Remove previous commands
    if (Menus.startCmd) then missionCommands.removeItem(Menus.startCmd) end
    if (Menus.startRandomCmd) then missionCommands.removeItem(Menus.startRandomCmd) end
    if (Menus.autoRestartCmd) then missionCommands.removeItem(Menus.autoRestartCmd) end
    if (Menus.SAMsCmdOn) then missionCommands.removeItem(Menus.SAMsCmdOn) end
    if (Menus.SAMsCmdOff) then missionCommands.removeItem(Menus.SAMsCmdOff) end
    if (Menus.MissilesCmdOff) then missionCommands.removeItem(Menus.MissilesCmdOff) end
    if (Menus.MissilesCmdOn) then missionCommands.removeItem(Menus.MissilesCmdOn) end

    -- Add new commands
    Menus.startCmd = missionCommands.addCommand("Spawn " .. ctl.getSettings(), commandMenu, ctl.spawnGroup, {})
    Menus.startRandomCmd = missionCommands.addCommand("Spawn Random Bandits", commandMenu, ctl.spawnRandomGroup, {})
    
    -- missiles ON/OFF
    local missiles = trigger.misc.getUserFlag(StateFlags.missiles)
    txt1 = ""
    txt2 = ""
    if missiles == 0 then txt1 = "◀" else txt2 = "◀" end
    Menus.MissilesCmdOff = missionCommands.addCommand("Turn MISSILES OFF" .. txt1, commandMenu, ctl.toggleMissiles, false)
    Menus.MissilesCmdOn = missionCommands.addCommand("Turn MISSILES ON" .. txt2, commandMenu, ctl.toggleMissiles, true)

    -- Sam ON / OFF
    txt1 = ""
    txt2 = ""
    local sam = trigger.misc.getUserFlag(StateFlags.sam)
    if sam == 0 then txt1 = "◀" else txt2 = "◀" end
    Menus.SAMsCmdOff = missionCommands.addCommand("Turn SAM OFF" .. txt1, commandMenu, ctl.toggleSAMs, false)
    Menus.SAMsCmdOn = missionCommands.addCommand("Turn SAM ON" .. txt2, commandMenu, ctl.toggleSAMs, true)
end

-- set defaults
ctl.setNumEnemies(2, true)
ctl.setEnemyType("F4E", true)
ctl.setDistance(10, true)

-- setup menu items in F10
ctl.initializeF10Menu()








--- Utils ------------------------------------------------------------------------------------------

function ctl.msg_table(table)
    ctl.send_message(
        mist.utils.oneLineSerialize(table)
    )
end

