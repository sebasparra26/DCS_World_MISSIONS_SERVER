-- === RED IADS SIMPLE ===

----------------------------------------------------------- Crear la IADS
local redIADS = SkynetIADS:create('Red IADS')

----------------------------------------------------------- Añadir EWR y SAMs por prefijo
redIADS:addSAMSitesByPrefix('R-SAM-')
redIADS:addEarlyWarningRadarsByPrefix('R-EWR-')
----------------------------------------------------------- COMMAND CENTER
local commandCenter = StaticObject.getByName("CC10")
local comPowerSource = StaticObject.getByName("RED-POWER-CENTER-1000")
local comNodeSource = StaticObject.getByName("RED-NODE-CENTER-111")
redIADS:addCommandCenter(commandCenter)
        :addPowerSource(comPowerSource)
        :addConnectionNode(comNodeSource)     
----------------------------------------------------------- Conexiones del EWR
do
local powerEWR = StaticObject.getByName('R-POWER-EWR')
local nodeEWR = StaticObject.getByName('R-NODE-EWR')
redIADS:getEarlyWarningRadarByUnitName('R-EWR-UNIT')
        :addPowerSource(powerEWR)
        :addConnectionNode(nodeEWR)
end
    


----------------------------------------------------------- Conexiones del SAM S300
do
local nodeS30001 = Unit.getByName('RED-NODE-SAM-S300-1')
redIADS:getSAMSiteByGroupName('R-SAM-S300-1')
        :addConnectionNode(nodeS30001)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end

----------------------------------------------------------- Conexiones de DEFENCE SA15
do
local defence01 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-1')
redIADS:getSAMSiteByGroupName('R-SAM-S300-1'):addPointDefence(defence01):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM S300
do
local nodeS30002 = Unit.getByName('RED-NODE-SAM-S300-2')
redIADS:getSAMSiteByGroupName('R-SAM-S300-2')
        :addConnectionNode(nodeS30002)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end

----------------------------------------------------------- Conexiones de DEFENCE SA15
do
local defence02 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-2')
redIADS:getSAMSiteByGroupName('R-SAM-S300-2'):addPointDefence(defence02):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM S300
do
local nodeS30003 = Unit.getByName('RED-NODE-SAM-S300-3')
redIADS:getSAMSiteByGroupName('R-SAM-S300-3')
        :addConnectionNode(nodeS30003)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end

----------------------------------------------------------- Conexiones de DEFENCE SA15
do
local defence03 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-3')
redIADS:getSAMSiteByGroupName('R-SAM-S300-3'):addPointDefence(defence03):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM S300
do
local nodeS30004 = Unit.getByName('RED-NODE-SAM-S300-4')
redIADS:getSAMSiteByGroupName('R-SAM-S300-4')
        :addConnectionNode(nodeS30004)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end

----------------------------------------------------------- Conexiones de DEFENCE SA15
do
local defence04 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-4')
redIADS:getSAMSiteByGroupName('R-SAM-S300-4'):addPointDefence(defence04):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM S300
do
local nodeS30005 = Unit.getByName('RED-NODE-SAM-S300-5')
redIADS:getSAMSiteByGroupName('R-SAM-S300-5')
        :addConnectionNode(nodeS30005)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end

----------------------------------------------------------- Conexiones de DEFENCE SA15
do
local defence05 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-5')
redIADS:getSAMSiteByGroupName('R-SAM-S300-5'):addPointDefence(defence05):setHARMDetectionChance(100)
end

----------------------------------------------------------- Conexiones del SAM S300
do
local nodeSA501 = Unit.getByName('RED-NODE-SAM-SA5-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-1')
        :addConnectionNode(nodeSA501)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end

----------------------------------------------------------- Conexiones de DEFENCE SA15
do
local defence06 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-6')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-1'):addPointDefence(defence06):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM S300
do
local nodeSA502 = Unit.getByName('RED-NODE-SAM-SA5-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-2')
        :addConnectionNode(nodeSA502)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end

----------------------------------------------------------- Conexiones de DEFENCE SA15
do
local defence07 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-7')
redIADS:getSAMSiteByGroupName('R-SAM-SA5-2'):addPointDefence(defence07):setHARMDetectionChance(100)
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
--redIADS:addRadioMenu()
redIADS:activate()
        

