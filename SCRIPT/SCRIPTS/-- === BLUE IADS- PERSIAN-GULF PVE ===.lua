-- === BLUE IADS SIMPLE ===

----------------------------------------------------------- Crear la IADS
local blueIADS = SkynetIADS:create('Blue IADS')

----------------------------------------------------------- Añadir EWR y SAMs por prefijo
blueIADS:addSAMSitesByPrefix('B-SAM-')
blueIADS:addEarlyWarningRadarsByPrefix('B-EWR-')
--COMMAND CENTER
local commandCenter = StaticObject.getByName("BLUE-COMMAND-CENTER")
local comPowerSource = StaticObject.getByName("BLUE-POWER-CENTER-1")
local comNodeSource = StaticObject.getByName("BLUE-NODE-CENTER-1")
blueIADS:addCommandCenter(commandCenter)
        :addPowerSource(comPowerSource)
        :addConnectionNode(comNodeSource)     
----------------------------------------------------------- Conexiones del EWR

do
local powerEWR = StaticObject.getByName('BLUE-POWER-EWR-10')
local nodeEWR = StaticObject.getByName('BLUE-NODE-EWR-10')
blueIADS:getEarlyWarningRadarByUnitName('B-EWR-UNIT-10')
        :addPowerSource(powerEWR)
        :addConnectionNode(nodeEWR)
end

----------------------------------------------------------- Conexiones del SAM PATRIOT
do
local nodePAT01 = Unit.getByName('BLUE-NODE-SAM-PAT-1')
blueIADS:getSAMSiteByGroupName('B-SAM-PAT-1')
        :addConnectionNode(nodePAT01)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence01 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-1')
blueIADS:getSAMSiteByGroupName('B-SAM-PAT-1'):addPointDefence(defence01):setHARMDetectionChance(100)
end

----------------------------------------------------------- Conexiones del SAM PATRIOT
do
local nodeNAS01 = Unit.getByName('BLUE-NODE-SAM-NAS-1')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-1')
        :addConnectionNode(nodeNAS01)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence02 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-2')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-1'):addPointDefence(defence02):setHARMDetectionChance(100)
end

----------------------------------------------------------- Conexiones del SAM PATRIOT
do
local nodeNAS02 = Unit.getByName('BLUE-NODE-SAM-NAS-2')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-2')
        :addConnectionNode(nodeNAS02)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence03 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-3')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-2'):addPointDefence(defence03):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM PATRIOT
do
local nodeNAS03 = Unit.getByName('BLUE-NODE-SAM-NAS-3')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-3')
        :addConnectionNode(nodeNAS03)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence04 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-4')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-3'):addPointDefence(defence04):setHARMDetectionChance(100)
end

----------------------------------------------------------- Conexiones del SAM PATRIOT
do
local nodeNAS04 = Unit.getByName('BLUE-NODE-SAM-NAS-4')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-4')
        :addConnectionNode(nodeNAS04)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence05 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-5')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-4'):addPointDefence(defence05):setHARMDetectionChance(100)
end
-----
----------------------------------------------------------- Debug
local debugBLUE = blueIADS:getDebugSettings()
debugBLUE.IADSStatus = false
debugBLUE.radarWentDark = false
debugBLUE.radarWentLive = false
debugBLUE.contacts = false
debugBLUE.samSiteStatusEnvOutput = false
debugBLUE.earlyWarningRadarStatusEnvOutput = false
debugBLUE.commandCenterStatusEnvOutput = false
debugBLUE.harmDefence = false

-- Activar IADS
--blueIADS:addRadioMenu()
blueIADS:activate()
        

