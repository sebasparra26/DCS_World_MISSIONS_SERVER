-- ============================================================================
-- EconomicSystemCoalition_BLUE_V4.lua
-- Generador economico Azul usando el nucleo compartido
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
    id = "BLUE_FACTORIES",
    coalition = 2,
    zoneName = "EconomicZoneBLUE",
    staticNames = {
        "Factory_Blue_1", "Factory_Blue_2", "Factory_Blue_3", "Factory_Blue_4", "Factory_Blue_5",
        "Factory_Blue_6", "Factory_Blue_7", "Factory_Blue_8", "Factory_Blue_9", "Factory_Blue_10"
    },
    amountPerTick = 18515,
    interval = 10
})

env.info("[ECONOMIA] Sistema economico azul V4 iniciado correctamente.")
