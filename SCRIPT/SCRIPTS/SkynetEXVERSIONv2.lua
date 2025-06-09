-- =========================
-- CONFIGURACIÓN SKYNET IADS DOBLE (ROJO Y AZUL) SIN CENTROS DE MANDO
-- =========================

-- === RED IADS ===
local redIADS = SkynetIADS:create('Red IADS')
redIADS:addEarlyWarningRadarsByPrefix('RED-EWR-')
redIADS:addSAMSitesByPrefix('RED-SAM-')

local debugRED = redIADS:getDebugSettings()
debugRED.IADSStatus = false
debugRED.radarWentDark = false
debugRED.radarWentLive = false
debugRED.contacts = false
debugRED.samSiteStatusEnvOutput = false
debugRED.earlyWarningRadarStatusEnvOutput = false
debugRED.commandCenterStatusEnvOutput = false
debugRED.harmDefence = true

-- RED: POWER y NODOS para EWRs
for i = 1, 6 do
    local power = StaticObject.getByName('RED-POWER-EWR-' .. i)
    local node = StaticObject.getByName('RED-NODE-EWR-' .. i)
    redIADS:getEarlyWarningRadarByUnitName('RED-EWR-UNIT-' .. i):addPowerSource(power):addConnectionNode(node)
end

-- RED: NODOS para SA-11
for i = 1, 4 do
    local node = Unit.getByName('RED-NODE-SAM-SA-11-' .. i)
    redIADS:getSAMSiteByGroupName('RED-SAM-SA-11-' .. i):addConnectionNode(node)
end

-- RED: NODOS para SA-5
for i = 1, 2 do
    local node = Unit.getByName('RED-NODE-SAM-SA-5-' .. i)
    redIADS:getSAMSiteByGroupName('RED-SAM-SA-5-' .. i):addConnectionNode(node)
end

-- RED: Configuración especial
redIADS:getSAMSitesByNatoName('SA-10'):setActAsEW(true)

-- RED: Activar IADS
--redIADS:addRadioMenu()
redIADS:activate()

-- === BLUE IADS ===
local blueIADS = SkynetIADS:create('Blue IADS')
blueIADS:addEarlyWarningRadarsByPrefix('BLUE-EWR-')
blueIADS:addSAMSitesByPrefix('BLUE-SAM-')

local debugBLUE = blueIADS:getDebugSettings()
debugBLUE.IADSStatus = false
debugBLUE.radarWentDark = false
debugBLUE.radarWentLive = false
debugBLUE.contacts = false
debugBLUE.samSiteStatusEnvOutput = false
debugBLUE.earlyWarningRadarStatusEnvOutput = false
debugBLUE.commandCenterStatusEnvOutput = false
debugBLUE.harmDefence = false

-- BLUE: POWER y NODOS para EWRs
for i = 1, 4 do
    local power = StaticObject.getByName('BLUE-POWER-EWR-' .. i)
    local node = StaticObject.getByName('BLUE-NODE-EWR-' .. i)
    blueIADS:getEarlyWarningRadarByUnitName('BLUE-EWR-UNIT-' .. i):addPowerSource(power):addConnectionNode(node)
end

-- BLUE: NODOS para NASAMS
for i = 1, 4 do
    local node = Unit.getByName('BLUE-NODE-SAM-NASAMS-' .. i)
    blueIADS:getSAMSiteByGroupName('BLUE-SAM-NASAMS-' .. i):addConnectionNode(node)
end

-- BLUE: NODOS para HAWKS
for i = 1, 4 do
    local node = Unit.getByName('BLUE-NODE-SAM-HAWK-' .. i)
    blueIADS:getSAMSiteByGroupName('BLUE-SAM-HAWK-' .. i):addConnectionNode(node)
end

-- BLUE: Configuración especial
blueIADS:getSAMSitesByNatoName('PATRIOT'):setActAsEW(true)

-- BLUE: Activar IADS
--blueIADS:addRadioMenu()
blueIADS:activate()
