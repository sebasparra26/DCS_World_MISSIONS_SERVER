-- === RED IADS SIMPLE ===

-- Crear la IADS
local redIADS = SkynetIADS:create('Red IADS')

-- Añadir EWR y SAMs por prefijo
redIADS:addSAMSitesByPrefix('R-SAM-')
redIADS:addEarlyWarningRadarsByPrefix('R-EWR-')

--COMMAND CENTER
local commandCenter = StaticObject.getByName("RED-COMMAND-CENTER")
local comPowerSource = StaticObject.getByName("RED-POWER-CENTER-1")
local comNodeSource = StaticObject.getByName("RED-NODE-CENTER-1")
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
-- SA 5 01 ------------------------------------------------------------------------------------------------
--do
--local nodeSA51 = Unit.getByName('RED-NODE-SAM-SA5-1')
--redIADS:getSAMSiteByGroupName('R-SAM-SA5-1')
       -- :addConnectionNode(nodeSA51)
       -- :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
       -- :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        --:setCanEngageAirWeapons(false)
        --:setCanEngageHARM(false)
        --:setHARMDetectionChance(100)
       -- :setActAsEW(true)
--end
-- SA 5 DEFENCE 01
--do
--local defence01RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA5-1')
--redIADS:getSAMSiteByGroupName('R-SAM-SA5-1'):addPointDefence(defence01RED):setHARMDetectionChance(100)
--end

-- SA 5 02 ------------------------------------------------------------------------------------------------
--do
--local nodeSA52 = Unit.getByName('RED-NODE-SAM-SA5-2')
--redIADS:getSAMSiteByGroupName('R-SAM-SA5-2')
        --:addConnectionNode(nodeSA52)
        --:setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        --:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        --:setCanEngageAirWeapons(false)
        --:setCanEngageHARM(false)
        --:setHARMDetectionChance(100)
        --:setActAsEW(true)
--end
-- SA 5 DEFENCE 02
--do
--local defence02RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA5-2')
--redIADS:getSAMSiteByGroupName('R-SAM-SA5-2'):addPointDefence(defence02RED):setHARMDetectionChance(100)
--end
-- SA 5 03 ------------------------------------------------------------------------------------------------
--do
--local nodeSA53 = Unit.getByName('RED-NODE-SAM-SA5-3')
--redIADS:getSAMSiteByGroupName('R-SAM-SA5-3')
  --      :addConnectionNode(nodeSA53)
    --    :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
      --  :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
        --:setCanEngageAirWeapons(false)
        --:setCanEngageHARM(false)
        --:setHARMDetectionChance(100)
        --:setActAsEW(true)
--end
-- SA 5 DEFENCE 03
--do
--local defence03RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA5-3')
--redIADS:getSAMSiteByGroupName('R-SAM-SA5-3'):addPointDefence(defence03RED):setHARMDetectionChance(100)
--end
-- SA 5 04 ------------------------------------------------------------------------------------------------
--do
--local nodeSA54 = Unit.getByName('RED-NODE-SAM-SA5-4')
--redIADS:getSAMSiteByGroupName('R-SAM-SA5-4')
  --      :addConnectionNode(nodeSA54)
  --      :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
  --      :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
  --      :setCanEngageAirWeapons(false)
  --      :setCanEngageHARM(false)
  --      :setHARMDetectionChance(100)
  --      :setActAsEW(true)
--end
-- SA 5 DEFENCE 04
--do
--local defence04RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA5-4')
--redIADS:getSAMSiteByGroupName('R-SAM-SA5-4'):addPointDefence(defence04RED):setHARMDetectionChance(100)
--end
-- SA 5 05 ------------------------------------------------------------------------------------------------
--do
--local nodeSA52 = Unit.getByName('RED-NODE-SAM-SA5-5')
--redIADS:getSAMSiteByGroupName('R-SAM-SA5-5')
  --      :addConnectionNode(nodeSA55)
  --      :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
  --      :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
  --      :setCanEngageAirWeapons(false)
  --      :setCanEngageHARM(false)
  --      :setHARMDetectionChance(100)
  --      :setActAsEW(true)
--end
-- SA 5 DEFENCE 05
--do
--local defence05RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA5-5')
--redIADS:getSAMSiteByGroupName('R-SAM-SA5-5'):addPointDefence(defence05RED):setHARMDetectionChance(100)
--end
-- SA 10 01 ------------------------------------------------------------------------------------------------
--do
--local nodeSA101 = Unit.getByName('RED-NODE-SAM-SA10-1')
--redIADS:getSAMSiteByGroupName('R-SAM-SA10-1')
      -- :addConnectionNode(nodeSA101)
      --  :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
      --  :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
       -- :setCanEngageAirWeapons(false)
      -- :setCanEngageHARM(false)
       -- :setHARMDetectionChance(100)
        --:setActAsEW(true)
--end
-- SA 10 DEFENCE 01
--do
--local defence06RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA10-1')
--redIADS:getSAMSiteByGroupName('R-SAM-SA10-1'):addPointDefence(defence06RED):setHARMDetectionChance(100)
--end
-- SA 10 02 ------------------------------------------------------------------------------------------------
--do
--local nodeSA102 = Unit.getByName('RED-NODE-SAM-SA10-2')
--redIADS:getSAMSiteByGroupName('R-SAM-SA10-2')
 --       :addConnectionNode(nodeSA102)
  --      :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
   --     :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
    --    :setCanEngageAirWeapons(false)
    --    :setCanEngageHARM(false)
    --    :setHARMDetectionChance(100)
    --    :setActAsEW(true)
--end
-- SA 10 DEFENCE 02
--do
--local defence07RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA10-2')
--redIADS:getSAMSiteByGroupName('R-SAM-SA10-2'):addPointDefence(defence07RED):setHARMDetectionChance(100)
--end
-- SA 10 03 ------------------------------------------------------------------------------------------------
--do
--local nodeSA103 = Unit.getByName('RED-NODE-SAM-SA10-3')
----redIADS:getSAMSiteByGroupName('R-SAM-SA10-3')
        --:addConnectionNode(nodeSA103)
       -- :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
       -- :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
       -- :setCanEngageAirWeapons(false)
       -- :setCanEngageHARM(false)
       -- :setHARMDetectionChance(100)
       -- :setActAsEW(true)
--end
-- SA 10 DEFENCE 03
--do
--local defence08RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA10-3')
--redIADS:getSAMSiteByGroupName('R-SAM-SA10-3'):addPointDefence(defence08RED):setHARMDetectionChance(100)
--end
-- SA 10 04 ------------------------------------------------------------------------------------------------
--do
--local nodeSA104 = Unit.getByName('RED-NODE-SAM-SA10-4')
--redIADS:getSAMSiteByGroupName('R-SAM-SA10-4')
  --      :addConnectionNode(nodeSA104)
  --      :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
  --      :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
  --      :setCanEngageAirWeapons(false)
  --      :setCanEngageHARM(false)
  --      :setHARMDetectionChance(100)
  --      :setActAsEW(true)
--end
-- SA 10 DEFENCE 04
--do
--local defence09RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA10-4')
--redIADS:getSAMSiteByGroupName('R-SAM-SA10-4'):addPointDefence(defence09RED):setHARMDetectionChance(100)
--end
-- SA 10 05 ------------------------------------------------------------------------------------------------
--do
--local nodeSA105 = Unit.getByName('RED-NODE-SAM-SA10-5')
--redIADS:getSAMSiteByGroupName('R-SAM-SA10-5')
  --      :addConnectionNode(nodeSA105)
  --      :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
  --      :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
  --      :setCanEngageAirWeapons(false)
  --      :setCanEngageHARM(false)
  --      :setHARMDetectionChance(100)
  --      :setActAsEW(true)
--end
-- SA 10 DEFENCE 05
--do
--local defence10RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA10-5')
--redIADS:getSAMSiteByGroupName('R-SAM-SA10-5'):addPointDefence(defence10RED):setHARMDetectionChance(100)
--end
-- SA 11 01 ------------------------------------------------------------------------------------------------
--do
--local nodeSA111 = Unit.getByName('RED-NODE-SAM-SA11-1')
--redIADS:getSAMSiteByGroupName('R-SAM-SA11-1')
  --      :addConnectionNode(nodeSA111)
  --      :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
  --      :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
  --      :setCanEngageAirWeapons(false)
  --      :setCanEngageHARM(false)
  --      :setHARMDetectionChance(100)
  --      :setActAsEW(true)
--end
-- SA 11 DEFENCE 01
--do
--local defence11RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA11-1')
--redIADS:getSAMSiteByGroupName('R-SAM-SA11-1'):addPointDefence(defence11RED):setHARMDetectionChance(100)
--end
-- SA 11 02 ------------------------------------------------------------------------------------------------
--do
--local nodeSA112 = Unit.getByName('RED-NODE-SAM-SA11-2')
--redIADS:getSAMSiteByGroupName('R-SAM-SA11-2')
  --      :addConnectionNode(nodeSA112)
  --      :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
  --      :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
  --      :setCanEngageAirWeapons(false)
  --      :setCanEngageHARM(false)
  --      :setHARMDetectionChance(100)
  --      :setActAsEW(true)
--end
-- SA 11 DEFENCE 02
--do
--local defence12RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA11-2')
--redIADS:getSAMSiteByGroupName('R-SAM-SA11-2'):addPointDefence(defence12RED):setHARMDetectionChance(100)
--end
-- SA 11 03 ------------------------------------------------------------------------------------------------
--do
--local nodeSA113 = Unit.getByName('RED-NODE-SAM-SA11-3')
--redIADS:getSAMSiteByGroupName('R-SAM-SA11-3')
  --      :addConnectionNode(nodeSA113)
  --      :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
  --      :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
  --      :setCanEngageAirWeapons(false)
  --      :setCanEngageHARM(false)
  --      :setHARMDetectionChance(100)
  --      :setActAsEW(true)
--end
-- SA 11 DEFENCE 03
--do
--local defence13RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA11-3')
--redIADS:getSAMSiteByGroupName('R-SAM-SA11-3'):addPointDefence(defence13RED):setHARMDetectionChance(100)
--end
-- SA 11 04 ------------------------------------------------------------------------------------------------
--do
--local nodeSA114 = Unit.getByName('RED-NODE-SAM-SA11-4')
--redIADS:getSAMSiteByGroupName('R-SAM-SA11-4')
  --      :addConnectionNode(nodeSA114)
   --     :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
   --     :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
   --     :setCanEngageAirWeapons(false)
   --     :setCanEngageHARM(false)
   --     :setHARMDetectionChance(100)
   --     :setActAsEW(true)
--end
-- SA 11 DEFENCE 04
--do
--local defence14RED = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA11-4')
--redIADS:getSAMSiteByGroupName('R-SAM-SA11-4'):addPointDefence(defence14RED):setHARMDetectionChance(100)
--end
--Debug
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
