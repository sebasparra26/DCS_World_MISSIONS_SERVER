

HDEV_LoaderConfig = HDEV_LoaderConfig or {
    rootRelativePath = "Scripts\\HorizontDev\\MarketSystem\\",
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
        Total = 7200,
        Intervalo = 900
    },
    marketRed = {
        Total = 7200,
        Intervalo = 900
    },

    -- Si ya cargas MIST aparte en el Mission Editor, deja esto en nil.
    -- Si quieres que el loader cargue MIST solo, pon una ruta relativa valida.
    -- Ejemplo: "mist.lua" si lo copias dentro de esta misma carpeta.
    mistRelativePath = nil
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

-- Configuracion global consumida por los wrappers V4
HDEV_EconomyGlobalConfig = {
    jsonRelativePath = CFG.jsonRelativePath or "Config/HorizontDev/money.json",
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

if not mist and CFG.mistRelativePath and CFG.mistRelativePath ~= "" then
    run(CFG.mistRelativePath, true)
end

if not mist then
    fail("MIST no esta cargado. Cargalo antes en el Mission Editor o define mistRelativePath en HDEV_LoaderConfig.")
end

-- Bases de datos fuente (sin modificarlas)
run("MENU_CONTENT_logistic_Sinai.lua", true)
run("StockWarehouse_MODERNWARFARE.lua", true)
run("StockWarehouse_MODERNWARFARE_WEAPONS_AG.lua", true)
run("StockWarehouse_MODERNWARFARE_WEAPONS_AA.lua", true)

-- Nucleos
run("HDEV_EconomyCore.lua", true)
run("HDEV_MarketplaceCore.lua", true)

-- Economia y logistica
run("EconomicSystemCoalition_BLUE_V4.lua", true)
run("EconomicSystemCoalition_RED_V4.lua", true)
run("logisticCoalition_BLUE_V4.lua", true)
run("logisticCoalition_RED_V4.lua", true)

-- Menus y billetera
run("MENU_logisticCoalition_BLUE_V4.lua", true)
run("MENU_logisticCoalition_RED_V4.lua", true)
run("EconomicSystemCounterWallet_V2.lua", true)

env.info("[HDEV_LOADER] Sistema HDEV cargado completamente.")
