-- ============================================================================
-- logisticCoalition_BLUE_V4.lua
-- Registro logistico Azul usando base de datos existente
-- No modifica tus DB, solo las consume
-- ============================================================================

assert(HDEV_Economy, "Carga primero HDEV_EconomyCore.lua")
assert(HDEV_Marketplace, "Carga primero HDEV_MarketplaceCore.lua")

local economySettings = HDEV_EconomyGlobalConfig or {
    jsonRelativePath = "Config\\HorizontDev\\money.json",
    importWindowSeconds = 30,
    autosaveInterval = 10,
    minWriteInterval = 5,
    debug = false
}

HDEV_Economy.init({
    jsonRelativePath = economySettings.jsonRelativePath or "Config\\HorizontDev\\money.json",
    importWindowSeconds = economySettings.importWindowSeconds or 30,
    autosaveInterval = economySettings.autosaveInterval or 10,
    minWriteInterval = economySettings.minWriteInterval or 5,
    debug = economySettings.debug and true or false
})

HDEV_Marketplace.init({ debug = HDEV_MarketplaceGlobalConfig and HDEV_MarketplaceGlobalConfig.debug or false })

HDEV_Marketplace.registerCoalition("BLUE", {
    coalition = 2,
    allowedFlagValue = 2,
    menuName = "MARKETPLACE",
    closeMessage = "El Mercado de Pulgas ha sido cerrado.",
    pageTitlePrefix = "Aeropuerto Pag",
    plantillas = plantillasLogisticaB,
    recargos = recargoAeropuertoB,
    coordinates = coordenadasAerodromosB,
    timeMultipliers = multiplicadorTiempoB,
    defaultOrigin = configuracionEntregaB and configuracionEntregaB.origen or { x = 0, y = 0, z = 0 },
    defaultSpeed = configuracionEntregaB and configuracionEntregaB.velocidad or 42,
    cooldownSeconds = 120,
    monitorInterval = 5,
    deliveryDestroyDelay = 20,
    deliveryMinAlt = 100,
    deliveryStopSpeed = 1,
    routeZoneName = "Rutas",
    searchBirthRadius = 5000
})

HDEV_Marketplace.startMonitor("BLUE")

env.info("[LOGISTICA] Sistema logistico azul V4 registrado correctamente.")