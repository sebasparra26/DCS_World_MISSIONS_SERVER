-- === BLUE IADS SIMPLE ===

-- Crear la IADS
local blueIADS = SkynetIADS:create('Blue IADS')

-- Añadir 1 EWR por nombre exacto
--blueIADS:addEarlyWarningRadar('B-EWR-UNIT-1')
--blueIADS:addEarlyWarningRadar('B-EWR-UNIT-2')


-- Añadir 1 SAM PATRIOT por nombre exacto de grupo
--blueIADS:addSAMSite('BLUE-SAM-PATRIOT-1')
---blueIADS:addSAMSite('BLUE-SAM-NASAMS-1')
--blueIADS:addSAMSite('BLUE-SAM-DEFENCE-1')
--blueIADS:addSAMSite('BLUE-SAM-DEFENCE-4')
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
--.........................................................................
do     
local powerEWR = StaticObject.getByName('BLUE-POWER-EWR-2')
local nodeEWR = StaticObject.getByName('BLUE-NODE-EWR-2')
blueIADS:getEarlyWarningRadarByUnitName('B-EWR-UNIT-2')
        :addPowerSource(powerEWR)
        :addConnectionNode(nodeEWR)
end

-- Conexiones del SAM PATRIOT
--for i = 1, 4 do
    --local node = Unit.getByName('BLUE-NODE-SAM-NASAMS-' .. i)
    --blueIADS:getSAMSiteByGroupName('BLUE-SAM-NASAMS-' .. i):addConnectionNode(node)
--end
--Patriot 01
do
local nodePatriot = Unit.getByName('BLUE-NODE-SAM-PATRIOT-1')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-1')
        :addConnectionNode(nodePatriot)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)  -- El radar del PATRIOT siempre está activo
end
--Patriot 02
do
local nodePatriot = Unit.getByName('BLUE-NODE-SAM-PATRIOT-2')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-2')
        :addConnectionNode(nodePatriot)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)  -- El radar del PATRIOT siempre está activo
end
--Patriot 03
do
local nodePatriot = Unit.getByName('BLUE-NODE-SAM-PATRIOT-3')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-3')
        :addConnectionNode(nodePatriot)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)  -- El radar del PATRIOT siempre está activo
end
--Patriot 04
do
local nodePatriot = Unit.getByName('BLUE-NODE-SAM-PATRIOT-4')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-4')
        :addConnectionNode(nodePatriot)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)  -- El radar del PATRIOT siempre está activo
end
--Patriot 05
do
local nodePatriot = Unit.getByName('BLUE-NODE-SAM-PATRIOT-9')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-5')
        :addConnectionNode(nodePatriot)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)  -- El radar del PATRIOT siempre está activo
end
-- Conexiones del SAM NASAMS--------------------------------------------------------------------------------------------------------
--NASAMS 01
do
local nodeNasams = Unit.getByName('BLUE-NODE-SAM-NASAMS-1')
blueIADS:getSAMSiteByGroupName('B-SAM-NASAMS-1')
        :addConnectionNode(nodeNasams)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)  -- El radar del PATRIOT siempre está activo   
end
--NASAMS 02
do
local nodeNasams = Unit.getByName('BLUE-NODE-SAM-NASAMS-2')
blueIADS:getSAMSiteByGroupName('B-SAM-NASAMS-2')
        :addConnectionNode(nodeNasams)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)  -- El radar del PATRIOT siempre está activo   
end
--NASAMS 03
do
local nodeNasams = Unit.getByName('BLUE-NODE-SAM-NASAMS-3')
blueIADS:getSAMSiteByGroupName('B-SAM-NASAMS-3')
        :addConnectionNode(nodeNasams)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)  -- El radar del PATRIOT siempre está activo   
end
--NASAMS 04
do
local nodeNasams = Unit.getByName('BLUE-NODE-SAM-NASAMS-4')
blueIADS:getSAMSiteByGroupName('B-SAM-NASAMS-4')
        :addConnectionNode(nodeNasams)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)  -- El radar del PATRIOT siempre está activo   
end
--NASAMS 04
do
local nodeNasams = Unit.getByName('BLUE-NODE-SAM-NASAMS-5')
blueIADS:getSAMSiteByGroupName('B-SAM-NASAMS-5')
        :addConnectionNode(nodeNasams)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
        :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)  -- El radar del PATRIOT siempre está activo   
end
    -- Conexiones del DEFENCE SA15 PROGRAM    ----------------------------------------------------------------------------------------
do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-1')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-1'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-2')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-2'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-3')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-3'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-4')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-4'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-9')
blueIADS:getSAMSiteByGroupName('B-SAM-PATRIOT-5'):addPointDefence(defence):setHARMDetectionChance(100)
end
----------------------------------------------------------------------------------------------------------------------------------------

do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-5')
blueIADS:getSAMSiteByGroupName('B-SAM-NASAMS-1'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-6')
blueIADS:getSAMSiteByGroupName('B-SAM-NASAMS-2'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-7')
blueIADS:getSAMSiteByGroupName('B-SAM-NASAMS-3'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-8')
blueIADS:getSAMSiteByGroupName('B-SAM-NASAMS-4'):addPointDefence(defence):setHARMDetectionChance(100)
end
do
local defence = blueIADS:getSAMSiteByGroupName('B-SAM-DEFENCE-10')
blueIADS:getSAMSiteByGroupName('B-SAM-NASAMS-5'):addPointDefence(defence):setHARMDetectionChance(100)
end
---------
----------------------------------------------------------------------------------------------------------------------------------------



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
