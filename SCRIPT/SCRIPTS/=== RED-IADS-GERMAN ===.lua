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
----------------------------------------------------------- Conexiones del SAM SA2 01
do
local nodeSA201 = Unit.getByName('RED-NODE-SAM-SA2-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-1')
        :addConnectionNode(nodeSA201)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 01
do
local defenceSA201 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA2-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-1'):addPointDefence(defenceSA201):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA2 02
do
local nodeSA202 = Unit.getByName('RED-NODE-SAM-SA2-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-2')
        :addConnectionNode(nodeSA202)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 02
do
local defenceSA202 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA2-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-2'):addPointDefence(defenceSA202):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA2 03
do
local nodeSA203 = Unit.getByName('RED-NODE-SAM-SA2-3')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-3')
        :addConnectionNode(nodeSA203)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 03
do
local defenceSA203 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA2-3')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-3'):addPointDefence(defenceSA203):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA2 04
do
local nodeSA204 = Unit.getByName('RED-NODE-SAM-SA2-4')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-4')
        :addConnectionNode(nodeSA204)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 04
do
local defenceSA204 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA2-4')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-4'):addPointDefence(defenceSA204):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA2 05
do
local nodeSA205 = Unit.getByName('RED-NODE-SAM-SA2-5')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-5')
        :addConnectionNode(nodeSA205)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 05
do
local defenceSA205 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA2-5')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-5'):addPointDefence(defenceSA205):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA2 06
do
local nodeSA206 = Unit.getByName('RED-NODE-SAM-SA2-6')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-6')
        :addConnectionNode(nodeSA206)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 06
do
local defenceSA206 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA2-6')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-6'):addPointDefence(defenceSA206):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA2 07
do
local nodeSA207 = Unit.getByName('RED-NODE-SAM-SA2-7')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-7')
        :addConnectionNode(nodeSA207)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 07
do
local defenceSA207 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA2-7')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-7'):addPointDefence(defenceSA207):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA2 08
do
local nodeSA208 = Unit.getByName('RED-NODE-SAM-SA2-8')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-8')
        :addConnectionNode(nodeSA208)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA208 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA2-8')
redIADS:getSAMSiteByGroupName('R-SAM-SA2-8'):addPointDefence(defenceSA208):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 01
do
local nodeSA301 = Unit.getByName('RED-NODE-SAM-SA3-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-1')
        :addConnectionNode(nodeSA301)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA301 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-1')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-1'):addPointDefence(defenceSA301):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 02
do
local nodeSA302 = Unit.getByName('RED-NODE-SAM-SA3-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-2')
        :addConnectionNode(nodeSA302)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA302 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-2')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-2'):addPointDefence(defenceSA302):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 03
do
local nodeSA303 = Unit.getByName('RED-NODE-SAM-SA3-3')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-3')
        :addConnectionNode(nodeSA303)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA303 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-3')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-3'):addPointDefence(defenceSA303):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 04
do
local nodeSA304 = Unit.getByName('RED-NODE-SAM-SA3-4')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-4')
        :addConnectionNode(nodeSA304)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA304 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-4')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-4'):addPointDefence(defenceSA304):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 05
do
local nodeSA305 = Unit.getByName('RED-NODE-SAM-SA3-5')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-5')
        :addConnectionNode(nodeSA305)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA305 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-5')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-5'):addPointDefence(defenceSA305):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 06
do
local nodeSA306 = Unit.getByName('RED-NODE-SAM-SA3-6')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-6')
        :addConnectionNode(nodeSA306)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA306 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-6')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-6'):addPointDefence(defenceSA306):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 06
do
local nodeSA307 = Unit.getByName('RED-NODE-SAM-SA3-7')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-7')
        :addConnectionNode(nodeSA307)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA307 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-7')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-7'):addPointDefence(defenceSA307):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 08
do
local nodeSA308 = Unit.getByName('RED-NODE-SAM-SA3-8')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-8')
        :addConnectionNode(nodeSA308)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA308 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-8')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-8'):addPointDefence(defenceSA308):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 09
do
local nodeSA309 = Unit.getByName('RED-NODE-SAM-SA3-9')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-9')
        :addConnectionNode(nodeSA309)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA309 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-9')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-9'):addPointDefence(defenceSA309):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 09
do
local nodeSA3010 = Unit.getByName('RED-NODE-SAM-SA3-10')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-10')
        :addConnectionNode(nodeSA3010)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA310 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-10')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-10'):addPointDefence(defenceSA310):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 11
do
local nodeSA3011 = Unit.getByName('RED-NODE-SAM-SA3-11')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-11')
        :addConnectionNode(nodeSA3011)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA311 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-11')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-11'):addPointDefence(defenceSA311):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 12
do
local nodeSA3012 = Unit.getByName('RED-NODE-SAM-SA3-12')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-12')
        :addConnectionNode(nodeSA3012)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA312 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-12')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-12'):addPointDefence(defenceSA312):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 13
do
local nodeSA3013 = Unit.getByName('RED-NODE-SAM-SA3-13')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-13')
        :addConnectionNode(nodeSA3013)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA313 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-13')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-13'):addPointDefence(defenceSA313):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 14
do
local nodeSA3014 = Unit.getByName('RED-NODE-SAM-SA3-14')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-14')
        :addConnectionNode(nodeSA3014)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA314 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-14')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-14'):addPointDefence(defenceSA314):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 15
do
local nodeSA3015 = Unit.getByName('RED-NODE-SAM-SA3-15')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-15')
        :addConnectionNode(nodeSA3015)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA315 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-15')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-15'):addPointDefence(defenceSA315):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 16
do
local nodeSA3016 = Unit.getByName('RED-NODE-SAM-SA3-16')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-16')
        :addConnectionNode(nodeSA3016)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA316 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-16')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-16'):addPointDefence(defenceSA316):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 17
do
local nodeSA3017 = Unit.getByName('RED-NODE-SAM-SA3-17')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-17')
        :addConnectionNode(nodeSA3017)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA317 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-17')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-17'):addPointDefence(defenceSA317):setHARMDetectionChance(100)
end
----------------------------------------------------------- Conexiones del SAM SA3 18
do
local nodeSA3018 = Unit.getByName('RED-NODE-SAM-SA3-18')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-17')
        :addConnectionNode(nodeSA3018)
        :setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI) 
        :setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
         :setCanEngageAirWeapons(false)
        :setCanEngageHARM(false)
        :setHARMDetectionChance(100)
        :setActAsEW(true)
end
----------------------------------------------------------- Conexiones del DEFENCE 08
do
local defenceSA318 = redIADS:getSAMSiteByGroupName('R-SAM-DEFENCE-SA3-18')
redIADS:getSAMSiteByGroupName('R-SAM-SA3-18'):addPointDefence(defenceSA318):setHARMDetectionChance(100)
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
