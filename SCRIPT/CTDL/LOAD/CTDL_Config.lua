----------------------------------------------------------------
-- CTLD_config.lua
-- Configuracion separada para CTLD
-- MIST YA DEBE HABER SIDO CARGADO ANTES
-- CTLD YA DEBE HABER SIDO CARGADO ANTES
----------------------------------------------------------------

if not mist then
    env.error("[CTLD-CONFIG] MIST no esta cargado.")
    trigger.action.outText("[CTLD-CONFIG] ERROR: MIST no esta cargado.", 15)
    return
end

if not ctld then
    env.error("[CTLD-CONFIG] CTLD no esta cargado todavia.")
    trigger.action.outText("[CTLD-CONFIG] ERROR: CTLD no esta cargado todavia.", 15)
    return
end

local function ctldCfgLog(msg)
    env.info("[CTLD-CONFIG] " .. tostring(msg))
end

----------------------------------------------------------------
-- AJUSTES GENERALES
----------------------------------------------------------------
ctld.disableAllSmoke = false
ctld.hoverPickup = true
ctld.loadCrateFromMenu = true
ctld.enableCrates = true
ctld.enableAllCrates = true
ctld.slingLoad = false
ctld.enableSmokeDrop = true

ctld.maxExtractDistance = 125
ctld.maximumDistanceLogistic = 300
ctld.maximumSearchDistance = 10000
ctld.maximumMoveDistance = 10000
ctld.minimumDeployDistance = 1000
ctld.numberOfTroops = 10

ctld.enableFastRopeInsertion = true
ctld.fastRopeMaximumHeight = 18.28

ctld.crateWaitTime = 0
ctld.forceCrateToBeMoved = true

----------------------------------------------------------------
-- BEACONS
----------------------------------------------------------------
ctld.enabledRadioBeaconDrop = true
ctld.radioSound = "beacon.ogg"
ctld.radioSoundFC3 = "beaconsilent.ogg"
ctld.deployedBeaconBattery = 30

----------------------------------------------------------------
-- REGISTRO AUTOMATICO POR TIPO DE AERONAVE
----------------------------------------------------------------
ctld.addPlayerAircraftByType = true

ctld.aircraftTypeTable = {
    "Hercules",
    "UH-60L",
    "UH-60L_DAP",
    "Ka-50_3",
    "Mi-8MT",
    "Mi-24P",
    "SA342L",
    "SA342M",
    "UH-1H",
    "CH-47Fbl1",
    "OH58D",
    "AH-64D_BLK_II",
}

----------------------------------------------------------------
-- FALLBACK POR NOMBRE DE SLOT / PILOTO
-- Esto te sirve si quieres compatibilidad con slots antiguos
----------------------------------------------------------------
ctld.transportPilotNames = {
    "helicargo1",
    "helicargo2",
    "helicargo3",
    "helicargo4",
    "helicargo5",
    "helicargo6",
    "helicargo7",
    "helicargo8",
    "helicargo9",
    "helicargo10",

    "MEDEVAC #1",
    "MEDEVAC #2",
    "MEDEVAC #3",
    "MEDEVAC #4",

    "MEDEVAC RED #1",
    "MEDEVAC RED #2",
    "MEDEVAC RED #3",
    "MEDEVAC RED #4",

    "MEDEVAC BLUE #1",
    "MEDEVAC BLUE #2",
    "MEDEVAC BLUE #3",
    "MEDEVAC BLUE #4",

    "transport1",
    "transport2",
    "transport3",
    "transport4",
    "transport5",
}

----------------------------------------------------------------
-- GRUPOS EXTRAIBLES OPCIONALES
----------------------------------------------------------------
ctld.extractableGroups = {
    "extract1",
    "extract2",
    "extract3",
    "extract4",
    "extract5",
}

----------------------------------------------------------------
-- UNIDADES LOGISTICAS
-- Cuando estas unidades mueren, ya no puedes sacar crates desde ahi
----------------------------------------------------------------
ctld.logisticUnits = {
    "logistic1",
    "logistic2",
    "logistic3",
    "logistic4",
    "logistic5",
    "logistic6",
    "logistic7",
    "logistic8",
}

----------------------------------------------------------------
-- ZONAS DE PICKUP
-- Formato:
-- { "nombreZona", "colorSmoke", limite, "yes/no", side }
-- side: 0 ambos, 1 rojo, 2 azul
----------------------------------------------------------------
ctld.pickupZones = {
    { "pickzone1", "none",  -1, "yes", 2 },
    { "pickzone2", "none",  -1, "yes", 2 },
    { "pickzone3", "none",  -1, "yes", 1 },
    { "pickzone4", "white", -1, "yes", 1 },
    { "pickzone5", "white", -1, "yes", 0 },
}

----------------------------------------------------------------
-- ZONAS DE DROPOFF
-- Formato:
-- { "nombreZona", "colorSmoke", side }
----------------------------------------------------------------
ctld.dropOffZones = {
    { "dropzone1", "green",  2 },
    { "dropzone2", "blue",   2 },
    { "dropzone3", "orange", 1 },
    { "dropzone4", "none",   1 },
}

----------------------------------------------------------------
-- ZONAS DE WAYPOINT
-- Formato:
-- { "nombreZona", "colorSmoke", "yes/no", side }
----------------------------------------------------------------
ctld.wpZones = {
    { "wpzone1", "none", "yes", 0 },
    { "wpzone2", "none", "yes", 0 },
    { "wpzone3", "none", "yes", 0 },
    { "wpzone4", "none", "yes", 0 },
}

----------------------------------------------------------------
-- UNIDADES CAPACES DE TRANSPORTAR VEHICULOS
----------------------------------------------------------------
ctld.vehicleTransportEnabled = {
    "76MD",
    "Hercules",
}

----------------------------------------------------------------
-- LIMITES DE CARGA DE TROPAS POR TIPO
----------------------------------------------------------------
ctld.unitLoadLimits = {
    ["Hercules"] = 33,
    ["UH-60L"] = 12,
    ["UH-60L_DAP"] = 12,
    ["Ka-50_3"] = 1,
    ["Mi-8MT"] = 16,
    ["Mi-24P"] = 10,
    ["SA342L"] = 4,
    ["SA342M"] = 4,
    ["UH-1H"] = 8,
    ["CH-47Fbl1"] = 33,
    ["OH58D"] = 1,
    ["AH-64D_BLK_II"] = 1,
}

----------------------------------------------------------------
-- CUANTOS CRATES INTERNOS PUEDE LLEVAR CADA UNO
----------------------------------------------------------------
ctld.internalCargoLimits = {
    ["Ka-50_3"] = 1,
    ["Mi-8MT"] = 4,
    ["CH-47Fbl1"] = 8,
    ["UH-1H"] = 1,
    ["Mi-24P"] = 2,
    ["Hercules"] = 20,
    ["SA342L"] = 1,
    ["SA342M"] = 1,
    ["OH58D"] = 1,
    ["UH-60L"] = 4,
    ["UH-60L_DAP"] = 4,
    ["AH-64D_BLK_II"] = 1,
}

----------------------------------------------------------------
-- ACCIONES PERMITIDAS POR TIPO
----------------------------------------------------------------
ctld.unitActions = {
    ["Hercules"] = { crates = true, troops = true },
    ["UH-60L"] = { crates = true, troops = true },
    ["UH-60L_DAP"] = { crates = true, troops = true },
    ["Ka-50_3"] = { crates = true, troops = true },
    ["Mi-8MT"] = { crates = true, troops = true },
    ["Mi-24P"] = { crates = true, troops = true },
    ["SA342L"] = { crates = true, troops = true },
    ["SA342M"] = { crates = true, troops = true },
    ["UH-1H"] = { crates = true, troops = true },
    ["CH-47Fbl1"] = { crates = true, troops = true },
    ["OH58D"] = { crates = true, troops = true },
    ["AH-64D_BLK_II"] = { crates = true, troops = true },
}

----------------------------------------------------------------
-- PESOS BASE DE SOLDADOS / EQUIPO
----------------------------------------------------------------
ctld.SOLDIER_WEIGHT = 80
ctld.KIT_WEIGHT = 20
ctld.RIFLE_WEIGHT = 5
ctld.MANPAD_WEIGHT = 18
ctld.RPG_WEIGHT = 7.6
ctld.MG_WEIGHT = 10
ctld.MORTAR_WEIGHT = 26
ctld.JTAC_WEIGHT = 15

----------------------------------------------------------------
-- GRUPOS CARGABLES
----------------------------------------------------------------
ctld.loadableGroups = {
    { name = "Standard Group x 2", mg = 1, aa = 1 },
    { name = "Standard Group x 1", mg = 1 },
}

ctldCfgLog("Configuracion CTLD aplicada correctamente.")
trigger.action.outText("[CTLD-CONFIG] Configuracion CTLD aplicada.", 8)