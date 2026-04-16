HDEV_LoaderConfig = HDEV_LoaderConfig or {
    rootRelativePath = "Scripts\\HorizontDev\\SystemCampaingDCS\\", -- Original "rootRelativePath = "Scripts\\HorizontDev\\MarketSystem\\","
    jsonRelativePath = "Config\\HorizontDev\\money.json",

    importWindowSeconds = 30,
    autosaveInterval = 10,
    minWriteInterval = 5,

    debugLoader = false,
    debugEconomy = false,
    debugMarketplace = false,

    walletEnabled = true,
    walletAutoInterval = 0,
    walletShowRed = true,

    marketBlue = {
        Total = 9999999,
        Intervalo = 600
    },
    marketRed = {
        Total = 9999999,
        Intervalo = 600
    },

    -- Si ya cargas MIST aparte en el Mission Editor, deja esto en nil.
    -- Si quieres que el loader cargue MIST solo, pon una ruta relativa valida.
    mistRelativePath = "MIST\\mist_4_5_128.lua"
}

local CFG = HDEV_LoaderConfig

local function log(msg)
    if CFG.debugLoader then
        env.info("[HDEV_LOADER] " .. tostring(msg))
    end
end

local function fail(msg)
    env.info("[HDEV_LOADER][ERROR] " .. tostring(msg))
    error("[HDEV_LOADER] " .. tostring(msg), 0)
end

local function normalizePath(path)
    path = tostring(path or "")
    path = path:gsub("\\", "/")
    path = path:gsub("//+", "/")
    return path
end

local function ensureTrailingSlash(path)
    path = normalizePath(path)
    if path ~= "" and path:sub(-1) ~= "/" then
        path = path .. "/"
    end
    return path
end

local function isAbsolutePath(path)
    path = normalizePath(path)
    return path:match("^%a:/") ~= nil or path:sub(1, 1) == "/"
end

local function buildBasePath()
    local root = ensureTrailingSlash(CFG.rootRelativePath)
    if isAbsolutePath(root) then
        return root
    end
    if lfs and lfs.writedir then
        return ensureTrailingSlash(lfs.writedir() .. root)
    end
    return root
end

local BASE_PATH = buildBasePath()

local function fileExists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

local function execFile(path)
    if dofile then
        return dofile(path)
    end
    if loadfile then
        local chunk, err = loadfile(path)
        if not chunk then
            error(err, 0)
        end
        return chunk()
    end
    fail("Ni dofile ni loadfile estan disponibles en este entorno.")
end

local function run(pathOrName, required)
    local full = pathOrName
    if not isAbsolutePath(full) then
        full = BASE_PATH .. pathOrName
    end
    full = normalizePath(full)

    if not fileExists(full) then
        if required == false then
            log("Archivo opcional no encontrado: " .. full)
            return false
        end
        fail("No se encontro el archivo requerido: " .. full)
    end

    log("Cargando: " .. full)
    local ok, err = pcall(execFile, full)
    if not ok then
        fail("Fallo cargando " .. tostring(pathOrName) .. ": " .. tostring(err))
    end

    return true
end

log("Base path resuelta: " .. tostring(BASE_PATH))

-- Config global compartida
HDEV_EconomyGlobalConfig = {
    jsonRelativePath = CFG.jsonRelativePath or "Config\\HorizontDev\\money.json",
    importWindowSeconds = CFG.importWindowSeconds or 30,
    autosaveInterval = CFG.autosaveInterval or 10,
    minWriteInterval = CFG.minWriteInterval or 5,
    debug = CFG.debugEconomy and true or false
}

HDEV_MarketplaceGlobalConfig = {
    debug = CFG.debugMarketplace and true or false
}

HDEV_WalletSettings = {
    enabled = CFG.walletEnabled ~= false,
    interval = CFG.walletAutoInterval or 0,
    showRed = CFG.walletShowRed ~= false
}

MercadoSetuptimerB = CFG.marketBlue or { Total = 7200, Intervalo = 900 }
MercadoSetuptimerR = CFG.marketRed or { Total = 7200, Intervalo = 900 }

-- Carga opcional de MIST
if not mist and CFG.mistRelativePath and CFG.mistRelativePath ~= "" then
    run(CFG.mistRelativePath, true)
end

if not mist then
    fail("MIST no esta cargado. Cargalo antes en el Mission Editor o define mistRelativePath en HDEV_LoaderConfig.")
end

-- ============================================================================
-- LISTA SIMPLE DE CARGA
-- enabled  = lo activa o desactiva
-- required = si falta, rompe; si false, solo lo salta
-- delay    = segundos ANTES de cargar este archivo
-- ============================================================================
HDEV_LoadQueue = HDEV_LoadQueue or {
    -- Persistance System
   { file = "PERSISTANCESYSTEM\\SINAI\\SystemUnitPositionPersistence.lua",              enabled = true,  required = true,  delay = 0 },
   { file = "PERSISTANCESYSTEM\\SINAI\\SistemAirbasePersistanceSinai.lua",              enabled = true,  required = true,  delay = 0 },
   { file = "PERSISTANCESYSTEM\\SINAI\\SystemWarehousesPersistanceSinai.lua",              enabled = true,  required = true,  delay = 0 },
   --{ file = "PERSISTANCESYSTEM\\Debug\\SystemWarehousesPersistanceSinai-RC.lua",              enabled = true,  required = true,  delay = 0 }, --DEBUG
    -- Library System 
   -- { file = "MIST\\mist_4_5_128.lua",              enabled = true,  required = true,  delay = 0 },
    
   
    -- Bases de datos
    
    { file = "SCAN\\DATABASE\\Sinai DB Aiports.lua",              enabled = true,  required = true,  delay = 0 },
    { file = "MARKETPLACE\\DATABASE\\MENU_CONTENT_logistic_Sinai.lua",              enabled = true,  required = true,  delay = 0 },
    { file = "WAREHOUSES\\StockWarehouse_MODERNWARFARE.lua",             enabled = true,  required = true,  delay = 0 },
    { file = "WAREHOUSES\\StockWarehouse_MODERNWARFARE_WEAPONS_AG.lua",  enabled = true,  required = true,  delay = 0 },
    { file = "WAREHOUSES\\StockWarehouse_MODERNWARFARE_WEAPONS_AA.lua",  enabled = true,  required = true,  delay = 0 },
    

    -- Cores
    
    { file = "SCAN\\EconomicSystemAIRPORTS_v3.lua",                         enabled = true,  required = true,  delay = 1 },
    { file = "MECHANICAL\\SINAI\\ActivateUnitsCampaing_SINAI.lua",           enabled = true,  required = true,  delay = 0 },
    { file = "ECONOMICSYSTEM\\HDEV_EconomyCore.lua",                         enabled = true,  required = true,  delay = 1 },
    { file = "MARKETPLACE\\HDEV_MarketplaceCore_1_1.lua",                     enabled = true,  required = true,  delay = 0 },

    { file = "MISSIONS\\DATABASE\\DB_Missions.lua",              enabled = true,  required = true,  delay = 0 },

    -- Economy System

    { file = "ECONOMICSYSTEM\\EconomicSystemCoalition_BLUE_V4.lua",          enabled = true,  required = true,  delay = 0 },
    { file = "ECONOMICSYSTEM\\EconomicSystemCoalition_RED_V4.lua",           enabled = true,  required = true,  delay = 0},
    { file = "ECONOMICSYSTEM\\EconomicSystemCounterWallet_V2.lua",           enabled = true,  required = true,  delay = 0 },

    -- Logística

    { file = "LOGISTIC\\logisticCoalition_BLUE_V4.lua",                enabled = true,  required = true,  delay = 0 },
    { file = "LOGISTIC\\logisticCoalition_RED_V4.lua",                 enabled = true,  required = true,  delay = 0},

    -- Menús y wallet

    { file = "MARKETPLACE\\MENU_logisticCoalition_BLUE_V4.lua",           enabled = true,  required = true,  delay = 0 },
    { file = "MARKETPLACE\\MENU_logisticCoalition_RED_V4.lua",            enabled = true,  required = true,  delay = 0 },
    { file = "CTDL\\HookEconomyV4.lua",            enabled = true,  required = true,  delay = 4 },
      -- Persistance Ships
   
     -- UI

   { file = "UI\\UI.lua",              enabled = true,  required = true,  delay = 5 },

    -- IA TASK 

   { file = "MECHANICAL\\Patrol+Task_IA-SINAI.lua",              enabled = true,  required = true,  delay = 0 },

     -- Missions Core

   { file = "MISSIONS\\SINAI\\HDEV_MissionSystem_Core.lua",              enabled = true,  required = true,  delay = 4 },

     -- Tankers

   { file = "MECHANICAL\\TankersSystemSpawnBLUE_v3.lua",              enabled = true,  required = true,  delay = 0 },
   { file = "MECHANICAL\\TankersSystemSpawnRED_v3.lua",              enabled = true,  required = true,  delay = 0 },

    -- Debug

   { file = "MECHANICAL\\BoomDebug.lua",              enabled = true,  required = true,  delay = 0 },

    -- Extras opcionales
    -- { file = "EconomicSystemAIRPORTS_v3.lua",             enabled = true,  required = false, delay = 2 },
    -- { file = "Sinai DB Aiports.lua",                      enabled = true,  required = false, delay = 0 },
    -- { file = "SistemAirbasePersistance-SINAI.lua",        enabled = false, required = false, delay = 0 },
    -- { file = "SystemWarehousesPersistance_Sinai_v01.lua", enabled = false, required = false, delay = 0 },
    -- { file = "TankersSystemSpawnBLUE_v2.lua",             enabled = false, required = false, delay = 0 },
    -- { file = "TankersSystemSpawnRED_v2.lua",              enabled = false, required = false, delay = 0 },
}

local LoaderState = {
    index = 1,
    started = false,
    completed = false
}

local function getEntryInfo(entry)
    if type(entry) == "string" then
        return {
            file = entry,
            enabled = true,
            required = true,
            delay = 0
        }
    end

    if type(entry) == "table" then
        return {
            file = entry.file,
            enabled = entry.enabled ~= false,
            required = entry.required ~= false,
            delay = tonumber(entry.delay) or 0
        }
    end

    return nil
end

local function processQueue(_, now)
    if LoaderState.completed then
        return nil
    end

    local entry = HDEV_LoadQueue[LoaderState.index]
    if not entry then
        LoaderState.completed = true
        env.info("[HDEV_LOADER] Sistema HDEV cargado completamente.")
        return nil
    end

    local info = getEntryInfo(entry)
    LoaderState.index = LoaderState.index + 1

    if not info or not info.file or info.file == "" then
        log("Entrada invalida en HDEV_LoadQueue, se omite.")
        return now + 0.01
    end

    if not info.enabled then
        log("Saltado: " .. tostring(info.file))
        return now + 0.01
    end

    if info.delay > 0 then
        log("Esperando " .. tostring(info.delay) .. " s antes de cargar: " .. tostring(info.file))
        timer.scheduleFunction(function()
            run(info.file, info.required)
        end, nil, timer.getTime() + info.delay)

        return now + info.delay + 0.01
    else
        run(info.file, info.required)
        return now + 0.01
    end
end

local function startQueue()
    if LoaderState.started then
        return
    end
    LoaderState.started = true
    timer.scheduleFunction(processQueue, nil, timer.getTime() + 0.01)
end

startQueue()