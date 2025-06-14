-- === RED IADS SIMPLE ===

----------------------------------------------------------- Crear la IADS
local redIADS = SkynetIADS:create('Red IADS')

----------------------------------------------------------- Añadir EWR y SAMs por prefijo
redIADS:addSAMSitesByPrefix('R-SAM-')
redIADS:addEarlyWarningRadarsByPrefix('R-EWR-')
----------------------------------------------------------- COMMAND CENTER
local commandCenter = StaticObject.getByName("CCRED")
local comPowerSource = StaticObject.getByName("RED-POWER-CENTER")
local comNodeSource = StaticObject.getByName("RED-NODE-CENTER-1")
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
do     
local powerEWR = StaticObject.getByName('RED-POWER-EWR-2')
local nodeEWR = StaticObject.getByName('RED-NODE-EWR-2')
redIADS:getEarlyWarningRadarByUnitName('R-EWR-UNIT-2')
        :addPowerSource(powerEWR)
        :addConnectionNode(nodeEWR)
end      

----------------------------------------------------------- Conexiones del SAM S300
do
local nodeS300 = Unit.getByName('RED-NODE-SAM-S300-1')
redIADS:getSAMSiteByGroupName('R-SAM-S300-1')
        :addConnectionNode(nodeS300)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
do
local nodeS300 = Unit.getByName('RED-NODE-SAM-S300-2')
redIADS:getSAMSiteByGroupName('R-SAM-S300-2')
        :addConnectionNode(nodeS300)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del SAM SA5
do
local nodeS300 = Unit.getByName('RED-NODE-SAM-SA5-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-1')
        :addConnectionNode(nodeS300)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
do
local nodeS300 = Unit.getByName('RED-NODE-SAM-SA5-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-2')
        :addConnectionNode(nodeS300)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end

----------------------------------------------------------- Conexiones del SAM SA3
do
local nodeS300 = Unit.getByName('RED-NODE-SAM-SA3-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-1')
        :addConnectionNode(nodeS300)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones de DEFENCE SA15
do
local defence = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-1')
redIADS:getSAMSiteByGroupName('R-SAM-S300-1'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-2')
redIADS:getSAMSiteByGroupName('R-SAM-S300-2'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-3')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-1'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-4')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-2'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-5')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-1'):addPointDefence(defence):setHARMDetectionChance(100)
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
        

