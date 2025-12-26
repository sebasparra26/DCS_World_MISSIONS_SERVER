-- === RED IADS SIMPLE ===

-- Crear la IADS
local redIADS = SkynetIADS:create('Red IADS')

-- Añadir EWR y SAMs por prefijo
redIADS:addSAMSitesByPrefix('R-SAM-')
redIADS:addEarlyWarningRadarsByPrefix('R-EWR-')

--COMMAND CENTER
local commandCenter = StaticObject.getByName("RED-COMMAND-CENTER")
local comPowerSource = StaticObject.getByName("RED-POWER-CENTER")
local comNodeSource = StaticObject.getByName("RED-NODE-CENTER")
redIADS:addCommandCenter(commandCenter)
        :addPowerSource(comPowerSource)
        :addConnectionNode(comNodeSource)   
-- Conexiones del EWR  
do
local powerEWR = StaticObject.getByName('RED-POWER-EWR-1')
local nodeEWR = StaticObject.getByName('RED-NODE-EWR-1')
redIADS:getEarlyWarningRadarByUnitName('R-EWR-UNIT-1')
        :addPowerSource(powerEWR)
        :addConnectionNode(nodeEWR)
end
-- SA 3 01 ------------------------------------------------------------------------------------------------
do
local nodeSA31 = Unit.getByName('RED-NODE-SAM-SA3-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-1')
        :addConnectionNode(nodeSA31)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK) --"AUTONOMOUS_STATE_DARK"
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE) --"GO_LIVE_WHEN_IN_SEARCH_RANGE", "GO_LIVE_WHEN_IN_KILL_ZONE"
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(false)
end
-- SA 3 DEFENCE 01
do
local defence01RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-1')
        :addPointDefence(defence01RED)
        :setHARMDetectionChance(100)
end

-- SA 3 01 ------------------------------------------------------------------------------------------------
do
local nodeSA32 = Unit.getByName('RED-NODE-SAM-SA3-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-2')
        :addConnectionNode(nodeSA32)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK) --"AUTONOMOUS_STATE_DARK"
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE) --"GO_LIVE_WHEN_IN_SEARCH_RANGE", "GO_LIVE_WHEN_IN_KILL_ZONE"
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(false)
end
-- SA 3 DEFENCE 01
do
local defence02RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-2')
        :addPointDefence(defence02RED)
        :setHARMDetectionChance(100)
end

-- Debug
local debugRED = redIADS:getDebugSettings()
debugRED.IADSStatus = false
debugRED.radarWentDark = false
debugRED.radarWentLive = false
debugRED.contacts = false
debugRED.samSiteStatusEnvOutput = false
debugRED.earlyWarningRadarStatusEnvOutput = false
debugRED.commandCenterStatusEnvOutput = false
debugRED.harmDefence = false

-- Activar IADS
--redIADS:addRadioMenu()
redIADS:activate()
