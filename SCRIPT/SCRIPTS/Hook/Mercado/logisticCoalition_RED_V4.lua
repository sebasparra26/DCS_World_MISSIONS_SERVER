-- ============================================================================
-- logisticCoalition_RED_V4.lua
-- Registro logistico Rojo usando base de datos existente
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

HDEV_Marketplace.registerCoalition("RED", {
    coalition = 1,
    allowedFlagValue = 1,
    menuName = "MARKETPLACE",
    closeMessage = "El Mercado de Pulgas ha sido cerrado.",
    pageTitlePrefix = "Pagina",
    plantillas = plantillasLogisticaR,
    recargos = recargoAeropuertoR,
    coordinates = coordenadasAerodromosR,
    timeMultipliers = multiplicadorTiempoR,
    defaultOrigin = configuracionEntregaR and configuracionEntregaR.origen or { x = 0, y = 0, z = 0 },
    defaultSpeed = configuracionEntregaR and configuracionEntregaR.velocidad or 42,
    cooldownSeconds = 120,
    monitorInterval = 5,
    deliveryDestroyDelay = 20,
    deliveryMinAlt = 100,
    deliveryStopSpeed = 1,
    routeZoneName = "Rutas",
    searchBirthRadius = 5000
})

HDEV_Marketplace.startMonitor("RED")

env.info("[LOGISTICA] Sistema logistico rojo V4 registrado correctamente.")