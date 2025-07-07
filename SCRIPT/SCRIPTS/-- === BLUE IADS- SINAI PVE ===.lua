-- === BLUE IADS SIMPLE ===

----------------------------------------------------------- Crear la IADS
local blueIADS = SkynetIADS:create('Blue IADS')

----------------------------------------------------------- Añadir EWR y SAMs por prefijo
blueIADS:addSAMSitesByPrefix('B-SAM-')
blueIADS:addEarlyWarningRadarsByPrefix('B-EWR-')
----------------------------------------------------------- COMMAND CENTER
local commandCenter = StaticObject.getByName("CCB00")
local comPowerSource = StaticObject.getByName("BLUE-POWER-CENTER-00")
local comNodeSource = StaticObject.getByName("BLUE-NODE-CENTER-00")
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
do     
local powerEWR = StaticObject.getByName('BLUE-POWER-EWR-11')
local nodeEWR = StaticObject.getByName('BLUE-NODE-EWR-11')
blueIADS:getEarlyWarningRadarByUnitName('B-EWR-UNIT-11')
        :addPowerSource(powerEWR)
        :addConnectionNode(nodeEWR)
end
----------------------------------------------------------- Conexiones del SAM PATRIOT
do
local nodeS300 = Unit.getByName('BLUE-NODE-SAM-PAT-1')
blueIADS:getSAMSiteByGroupName('B-SAM-PAT-1')
        :addConnectionNode(nodeS300)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-1')
blueIADS:getSAMSiteByGroupName('B-SAM-PAT-1'):addPointDefence(defence):setHARMDetectionChance(100)
end
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
blueIADS:addRadioMenu()
blueIADS:activate()
        

