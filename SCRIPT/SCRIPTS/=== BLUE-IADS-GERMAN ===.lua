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
local powerEWR = StaticObject.getByName('BLUE-POWER-EWR-1')
local nodeEWR = StaticObject.getByName('BLUE-NODE-EWR-1')
blueIADS:getEarlyWarningRadarByUnitName('B-EWR-UNIT-1')
        :addPowerSource(powerEWR)
        :addConnectionNode(nodeEWR)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP01 = Unit.getByName('BLUE-NODE-SAM-ROLAND-1')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-01')
        :addConnectionNode(nodeRAP01)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence01 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-1')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-01'):addPointDefence(defence01):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP02 = Unit.getByName('BLUE-NODE-SAM-ROLAND-2')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-02')
        :addConnectionNode(nodeRAP02)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence02 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-2')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-02'):addPointDefence(defence02):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP03 = Unit.getByName('BLUE-NODE-SAM-ROLAND-3')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-03')
        :addConnectionNode(nodeRAP03)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence03 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-3')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-03'):addPointDefence(defence03):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP04 = Unit.getByName('BLUE-NODE-SAM-ROLAND-4')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-04')
        :addConnectionNode(nodeRAP04)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence04 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-4')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-04'):addPointDefence(defence04):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP05 = Unit.getByName('BLUE-NODE-SAM-ROLAND-5')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-05')
        :addConnectionNode(nodeRAP05)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence05 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-5')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-05'):addPointDefence(defence05):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP06 = Unit.getByName('BLUE-NODE-SAM-ROLAND-6')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-06')
        :addConnectionNode(nodeRAP06)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence06 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-6')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-06'):addPointDefence(defence06):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP07 = Unit.getByName('BLUE-NODE-SAM-ROLAND-7')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-07')
        :addConnectionNode(nodeRAP07)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence07 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-7')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-07'):addPointDefence(defence07):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP08 = Unit.getByName('BLUE-NODE-SAM-ROLAND-8')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-08')
        :addConnectionNode(nodeRAP08)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence08 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-8')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-08'):addPointDefence(defence08):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP09 = Unit.getByName('BLUE-NODE-SAM-ROLAND-9')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-09')
        :addConnectionNode(nodeRAP09)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence09 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-9')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-09'):addPointDefence(defence09):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP10 = Unit.getByName('BLUE-NODE-SAM-ROLAND-10')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-10')
        :addConnectionNode(nodeRAP10)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence10 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-10')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-10'):addPointDefence(defence10):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP11 = Unit.getByName('BLUE-NODE-SAM-ROLAND-11')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-11')
        :addConnectionNode(nodeRAP11)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence11 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-11')
blueIADS:getSAMSiteByGroupName('B-SAM-ROLAND-11'):addPointDefence(defence11):setHARMDetectionChance(100)
end

----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP12= Unit.getByName('BLUE-NODE-SAM-RAPIER-1')
blueIADS:getSAMSiteByGroupName('B-SAM-RAPIER-1')
        :addConnectionNode(nodeRAP12)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence12 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-R-1')
blueIADS:getSAMSiteByGroupName('B-SAM-RAPIER-1'):addPointDefence(defence12):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP13= Unit.getByName('BLUE-NODE-SAM-RAPIER-2')
blueIADS:getSAMSiteByGroupName('B-SAM-RAPIER-2')
        :addConnectionNode(nodeRAP13)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence13 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-R-2')
blueIADS:getSAMSiteByGroupName('B-SAM-RAPIER-2'):addPointDefence(defence13):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP14= Unit.getByName('BLUE-NODE-SAM-RAPIER-3')
blueIADS:getSAMSiteByGroupName('B-SAM-RAPIER-3')
        :addConnectionNode(nodeRAP14)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence14 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-R-3')
blueIADS:getSAMSiteByGroupName('B-SAM-RAPIER-3'):addPointDefence(defence14):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP15= Unit.getByName('BLUE-NODE-SAM-RAPIER-4')
blueIADS:getSAMSiteByGroupName('B-SAM-RAPIER-4')
        :addConnectionNode(nodeRAP15)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence15 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-R-4')
blueIADS:getSAMSiteByGroupName('B-SAM-RAPIER-4'):addPointDefence(defence15):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM ROLAND
do
local nodeRAP16= Unit.getByName('BLUE-NODE-SAM-RAPIER-5')
blueIADS:getSAMSiteByGroupName('B-SAM-RAPIER-5')
        :addConnectionNode(nodeRAP16)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENDER
do
local defence16 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-R-5')
blueIADS:getSAMSiteByGroupName('B-SAM-RAPIER-5'):addPointDefence(defence16):setHARMDetectionChance(100)
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
        

