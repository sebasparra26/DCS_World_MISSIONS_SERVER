-- ============================================================================
-- EconomicSystemCoalition_RED_V4.lua
-- Generador economico Rojo usando el nucleo compartido
-- ============================================================================

assert(HDEV_Economy, "Carga primero HDEV_EconomyCore.lua")

local economySettings = HDEV_EconomyGlobalConfig or {
    jsonRelativePath = "Config/HorizontDev/money.json",
    importWindowSeconds = 30,
    autosaveInterval = 10,
    minWriteInterval = 5,
    debug = false
}

local Economy = HDEV_Economy.init({
    jsonRelativePath = economySettings.jsonRelativePath or "Config/HorizontDev/money.json",
    importWindowSeconds = economySettings.importWindowSeconds or 30,
    autosaveInterval = economySettings.autosaveInterval or 10,
    minWriteInterval = economySettings.minWriteInterval or 5,
    debug = economySettings.debug and true or false
})

Economy.registerFactoryGenerator({
    id = "RED_FACTORIES",
    coalition = 1,
    zoneName = "EconomicZoneRED",
    staticNames = {
        "Factory_RED_1", "Factory_RED_2", "Factory_RED_3", "Factory_RED_4", "Factory_RED_5",
        "Factory_RED_6", "Factory_RED_7", "Factory_RED_8", "Factory_RED_9", "Factory_RED_10"
    },
    amountPerTick = 18515,
    interval = 10
})

env.info("[ECONOMIA] Sistema economico rojo V4 iniciado correctamente.")
