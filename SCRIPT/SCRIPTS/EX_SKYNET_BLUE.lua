-- === BLUE IADS SIMPLE ===

-- Crear la IADS
local blueIADS = SkynetIADS:create('Blue IADS')

-- Crear la ByPrefix
blueIADS:addSAMSitesByPrefix('B-SAM-')
blueIADS:addEarlyWarningRadarsByPrefix('B-EWR-')

--COMMAND CENTER
local commandCenter = StaticObject.getByName("BLUE-COMMAND-CENTER")
local comPowerSource = StaticObject.getByName("BLUE-POWER-CENTER-1")
local comNodeSource = StaticObject.getByName("BLUE-NODE-CENTER-1")
blueIADS:addCommandCenter(commandCenter)
        :addPowerSource(comPowerSource)
        :addConnectionNode(comNodeSource)     
      
-- Conexiones del EWR
do
local powerEWR = StaticObject.getByName('BLUE-POWER-EWR-1')
local nodeEWR = StaticObject.getByName('BLUE-NODE-EWR-1')
blueIADS:getEarlyWarningRadarByUnitName('B-EWR-UNIT-1')
        :addPowerSource(powerEWR)
        :addConnectionNode(nodeEWR)
end

--Patriot 01 ---------------------------------------------------------------------------------------------
--do
--local nodePatriot01 = Unit.getByName('BLUE-NODE-SAM-PATRIOT-1')
--blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-1')
        --:addConnectionNode(nodePatriot01)
        --:setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        --:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        -- :setCanEngageAirWeapons(false)
       -- :setCanEngageHARM(false)
       -- :setHARMDetectionChance(100)
       -- :setActAsEW(true)
--end
-- PATRIOT DEFENCE 01
--do
--local defencePAT01 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-1')
--blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-1'):addPointDefence(defencePAT01):setHARMDetectionChance(100)
--end
--Patriot 02 ---------------------------------------------------------------------------------------------
do
local nodePatriot02 = Unit.getByName('BLUE-NODE-SAM-PATRIOT-2')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-2')
        :addConnectionNode(nodePatriot02)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- PATRIOT DEFENCE 02
do
local defencePAT02 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-2')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-2'):addPointDefence(defencePAT02):setHARMDetectionChance(100)
end
--Patriot 03 ---------------------------------------------------------------------------------------------
do
local nodePatriot03 = Unit.getByName('BLUE-NODE-SAM-PATRIOT-3')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-3')
        :addConnectionNode(nodePatriot03)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- PATRIOT DEFENCE 03
do
local defencePAT03 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-3')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-3'):addPointDefence(defencePAT03):setHARMDetectionChance(100)
end
--Patriot 04 ---------------------------------------------------------------------------------------------
do
local nodePatriot04 = Unit.getByName('BLUE-NODE-SAM-PATRIOT-4')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-4')
        :addConnectionNode(nodePatriot04)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- PATRIOT DEFENCE 04
do
local defencePAT04 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-4')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-4'):addPointDefence(defencePAT04):setHARMDetectionChance(100)
end
--Patriot 05 ---------------------------------------------------------------------------------------------
do
local nodePatriot05 = Unit.getByName('BLUE-NODE-SAM-PATRIOT-5')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-5')
        :addConnectionNode(nodePatriot05)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- PATRIOT DEFENCE 05
do
local defencePAT05 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-5')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-5'):addPointDefence(defencePAT05):setHARMDetectionChance(100)
end
--Patriot 06 ---------------------------------------------------------------------------------------------
do
local nodePatriot06 = Unit.getByName('BLUE-NODE-SAM-PATRIOT-6')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-6')
        :addConnectionNode(nodePatriot06)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- PATRIOT DEFENCE 06
do
local defencePAT06 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-6')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-6'):addPointDefence(defencePAT06):setHARMDetectionChance(100)
end
--Patriot 07 ---------------------------------------------------------------------------------------------
do
local nodePatriot07 = Unit.getByName('BLUE-NODE-SAM-PATRIOT-7')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-7')
        :addConnectionNode(nodePatriot07)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- PATRIOT DEFENCE 07
do
local defencePAT07 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-7')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-7'):addPointDefence(defencePAT07):setHARMDetectionChance(100)
end
--Patriot 08 ---------------------------------------------------------------------------------------------
do
local nodePatriot08 = Unit.getByName('BLUE-NODE-SAM-PATRIOT-8')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-8')
        :addConnectionNode(nodePatriot08)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- PATRIOT DEFENCE 08
do
local defencePAT08 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-8')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-8'):addPointDefence(defencePAT08):setHARMDetectionChance(100)
end
--Patriot 09 ---------------------------------------------------------------------------------------------
do
local nodePatriot09 = Unit.getByName('BLUE-NODE-SAM-PATRIOT-9')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-9')
        :addConnectionNode(nodePatriot09)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- PATRIOT DEFENCE 09
do
local defencePAT09 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-9')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-9'):addPointDefence(defencePAT09):setHARMDetectionChance(100)
end
--NASSAM 01 ---------------------------------------------------------------------------------------------
do
local nodeNAS01 = Unit.getByName('BLUE-NODE-SAM-NAS-1')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-1')
        :addConnectionNode(nodeNAS01)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- NASSAM DEFENCE 01
do
local defenceNAS01 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-NAS-1')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-1'):addPointDefence(defenceNAS01):setHARMDetectionChance(100)
end
--NASSAM 02 ---------------------------------------------------------------------------------------------
do
local nodeNAS02 = Unit.getByName('BLUE-NODE-SAM-NAS-2')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-2')
        :addConnectionNode(nodeNAS02)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- NASSAM DEFENCE 02
do
local defenceNAS02 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-NAS-2')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-2'):addPointDefence(defenceNAS02):setHARMDetectionChance(100)
end
--NASSAM 03 ---------------------------------------------------------------------------------------------
do
local nodeNAS03 = Unit.getByName('BLUE-NODE-SAM-NAS-3')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-3')
        :addConnectionNode(nodeNAS03)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- NASSAM DEFENCE 03
do
local defenceNAS03 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-NAS-3')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-3'):addPointDefence(defenceNAS03):setHARMDetectionChance(100)
end
--NASSAM 04 ---------------------------------------------------------------------------------------------
do
local nodeNAS04 = Unit.getByName('BLUE-NODE-SAM-NAS-4')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-4')
        :addConnectionNode(nodeNAS04)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- NASSAM DEFENCE 04
do
local defenceNAS04 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-NAS-4')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-4'):addPointDefence(defenceNAS04):setHARMDetectionChance(100)
end
--NASSAM 05 ---------------------------------------------------------------------------------------------
do
local nodeNAS05 = Unit.getByName('BLUE-NODE-SAM-NAS-5')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-5')
        :addConnectionNode(nodeNAS05)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- NASSAM DEFENCE 05
do
local defenceNAS05 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-NAS-5')
blueIADS:getSAMSiteByGroupName('B-SAM-NAS-5'):addPointDefence(defenceNAS05):setHARMDetectionChance(100)
end
--NASSAM 06 ---------------------------------------------------------------------------------------------
--do
--local nodeNAS06 = Unit.getByName('BLUE-NODE-SAM-NAS-6')
--blueIADS:getSAMSiteByGroupName('B-SAM-NAS-6')
       -- :addConnectionNode(nodeNAS06)
        --:setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        --:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        -- :setCanEngageAirWeapons(false)
        ----:setCanEngageHARM(false)
       -- :setHARMDetectionChance(100)
        --:setActAsEW(true)
--end
-- NASSAM DEFENCE 06
--do
--local defenceNAS06 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-NAS-6')
--blueIADS:getSAMSiteByGroupName('B-SAM-NAS-6'):addPointDefence(defenceNAS06):setHARMDetectionChance(100)
--end
--HAWK 01 ---------------------------------------------------------------------------------------------
do
local nodeHAWK01 = Unit.getByName('BLUE-NODE-SAM-HAWK-1')
blueIADS:getSAMSiteByGroupName('B-SAM-HAWK-1')
        :addConnectionNode(nodeHAWK01)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- HAWK DEFENCE 01
do
local defenceHAW01 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-HAWK-1')
blueIADS:getSAMSiteByGroupName('B-SAM-HAWK-1'):addPointDefence(defenceHAW01):setHARMDetectionChance(100)
end
--HAWK 02 ---------------------------------------------------------------------------------------------
do
local nodeHAWK02 = Unit.getByName('BLUE-NODE-SAM-HAWK-2')
blueIADS:getSAMSiteByGroupName('B-SAM-HAWK-2')
        :addConnectionNode(nodeHAWK02)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
-- HAWK DEFENCE 02
do
local defenceHAW02 = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-HAWK-2')
blueIADS:getSAMSiteByGroupName('B-SAM-HAWK-2'):addPointDefence(defenceHAW02):setHARMDetectionChance(100)
end

-- Configuración de depuración (debug)
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
