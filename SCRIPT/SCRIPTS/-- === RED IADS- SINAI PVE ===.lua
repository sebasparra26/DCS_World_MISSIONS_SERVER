-- === RED IADS SIMPLE ===

----------------------------------------------------------- Crear la IADS
local redIADS = SkynetIADS:create('Red IADS')

----------------------------------------------------------- Añadir EWR y SAMs por prefijo
redIADS:addSAMSitesByPrefix('R-SAM-')
redIADS:addEarlyWarningRadarsByPrefix('R-EWR-')
----------------------------------------------------------- COMMAND CENTER
local commandCenter = StaticObject.getByName("CC")
local comPowerSource = StaticObject.getByName("RED-POWER-CENTER-100")
local comNodeSource = StaticObject.getByName("RED-NODE-CENTER-11")
redIADS:addCommandCenter(commandCenter)
        :addPowerSource(comPowerSource)
        :addConnectionNode(comNodeSource)     
----------------------------------------------------------- Conexiones del EWR
do
local powerEWR = StaticObject.getByName('RED-POWER-EWR-1')
local nodeEWR = StaticObject.getByName('RED-NODE-EWR-1')
redIADS:getEarlyWarningRadarByUnitName('R-EWR-UNIT-1')
        :addPowerSource(powerEWR)
        :addConnectionNode(nodeEWR)
end

----------------------------------------------------------- Conexiones del SAM S300
do
local nodeS30001 = Unit.getByName('RED-NODE-SAM-S300-1')
redIADS:getSAMSiteByGroupName('R-SAM-S300-1')
        :addConnectionNode(nodeS30001)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
do
local nodeS30002 = Unit.getByName('RED-NODE-SAM-S300-2')
redIADS:getSAMSiteByGroupName('R-SAM-S300-2')
        :addConnectionNode(nodeS30002)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del SAM SA5
do
local nodeS30003 = Unit.getByName('RED-NODE-SAM-SA5-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-1')
        :addConnectionNode(nodeS30003)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
do
local nodeS30004 = Unit.getByName('RED-NODE-SAM-SA5-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-2')
        :addConnectionNode(nodeS30004)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
do
local nodeS30005 = Unit.getByName('RED-NODE-SAM-SA5-3')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-3')
        :addConnectionNode(nodeS30005)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del SAM SA3
do
local nodeS30006 = Unit.getByName('RED-NODE-SAM-SA3-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-1')
        :addConnectionNode(nodeS30006)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(true)
        :setCanEngageHARM(true)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end

do
local nodeS30007 = Unit.getByName('RED-NODE-SAM-SA3-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-2')
        :addConnectionNode(nodeS30007)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(true)
        :setCanEngageHARM(true)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del SAM SA2
do
local nodeS30008 = Unit.getByName('RED-NODE-SAM-SA2-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-1')
        :addConnectionNode(nodeS30008)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(true)
        :setCanEngageHARM(true)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
do
local nodeS30009 = Unit.getByName('RED-NODE-SAM-SA2-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-2')
        :addConnectionNode(nodeS30009)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(true)
        :setCanEngageHARM(true)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del SAM SA6
do
local nodeS30010 = Unit.getByName('RED-NODE-SAM-SA6-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA6-1')
        :addConnectionNode(nodeS30010)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(true)
        :setCanEngageHARM(true)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end

----------------------------------------------------------- Conexiones de DEFENCE SA15
do
local defence01 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-1')
redIADS:getSAMSiteByGroupName('R-SAM-S300-1'):addPointDefence(defence01):setHARMDetectionChance(100)
end
do
local defence02 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-2')
redIADS:getSAMSiteByGroupName('R-SAM-S300-2'):addPointDefence(defence02):setHARMDetectionChance(100)
end
do
local defence03 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-3')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-1'):addPointDefence(defence03):setHARMDetectionChance(100)
end
do
local defence04 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-4')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-2'):addPointDefence(defence04):setHARMDetectionChance(100)
end
do
local defence05 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-6')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-3'):addPointDefence(defence05):setHARMDetectionChance(100)
end

----------------------------------------------------------- Debug
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
redIADS:addRadioMenu()
redIADS:activate()
        

