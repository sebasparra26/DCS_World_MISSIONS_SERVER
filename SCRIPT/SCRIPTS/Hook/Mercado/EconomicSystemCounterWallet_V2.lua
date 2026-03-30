-- ============================================================================
-- EconomicSystemCounterWallet_V2.lua
-- Billetera simple y liviana usando el nucleo economico compartido
-- ============================================================================

assert(HDEV_Economy, "Carga primero HDEV_EconomyCore.lua")

local economySettings = HDEV_EconomyGlobalConfig or {
    jsonRelativePath = "Config/HorizontDev/money.json",
    importWindowSeconds = 30,
    autosaveInterval = 10,
    minWriteInterval = 5,
    debug = false
}

local walletSettings = HDEV_WalletSettings or {
    enabled = true,
    interval = 0,
    showRed = true
}

if not walletSettings.enabled then
    env.info("[BILLETERA] Wallet deshabilitada por configuracion del loader")
    return
end

local Economy = HDEV_Economy.init({
    jsonRelativePath = economySettings.jsonRelativePath or "Config/HorizontDev/money.json",
    importWindowSeconds = economySettings.importWindowSeconds or 30,
    autosaveInterval = economySettings.autosaveInterval or 10,
    minWriteInterval = economySettings.minWriteInterval or 5,
    debug = economySettings.debug and true or false
})

local intervaloMonitoreo = walletSettings.interval or 0
local mostrarRojo = walletSettings.showRed ~= false
local menuBilleteraGlobal = missionCommands.addSubMenu("Billetera")

local function mostrarPuntosBilletera()
    local azul = Economy.formatMoney(Economy.get(2))
    local mensaje = "[Billetera]\nCoalicion Azul: " .. azul

    if mostrarRojo then
        local rojo = Economy.formatMoney(Economy.get(1))
        mensaje = mensaje .. "\nCoalicion Roja: " .. rojo
    end

    trigger.action.outText(mensaje, 6)
end

missionCommands.addCommand("Mostrar puntos", menuBilleteraGlobal, mostrarPuntosBilletera)

if intervaloMonitoreo and intervaloMonitoreo > 0 then
    timer.scheduleFunction(function(_, now)
        mostrarPuntosBilletera()
        return now + intervaloMonitoreo
    end, nil, timer.getTime() + intervaloMonitoreo)
end

trigger.action.outText("Sistema de billetera V2 cargado correctamente", 8)
