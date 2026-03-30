-- ============================================================================
-- MENU_logisticCoalition_RED_V4.lua
-- Construccion del menu Rojo con temporizador de cierre
-- ============================================================================

MercadoSetuptimerR = MercadoSetuptimerR or {
    Total = 138.88,
    Intervalo = 200
}

assert(HDEV_Marketplace, "Carga primero HDEV_MarketplaceCore.lua")

HDEV_Marketplace.init({ debug = HDEV_MarketplaceGlobalConfig and HDEV_MarketplaceGlobalConfig.debug or false })
HDEV_Marketplace.buildMenu("RED")
HDEV_Marketplace.startMarketTimer("RED", MercadoSetuptimerR)

env.info("[MENU] Marketplace Rojo V4 cargado correctamente.")
