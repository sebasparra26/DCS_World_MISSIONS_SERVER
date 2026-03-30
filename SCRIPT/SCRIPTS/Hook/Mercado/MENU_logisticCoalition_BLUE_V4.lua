-- ============================================================================
-- MENU_logisticCoalition_BLUE_V4.lua
-- Construccion del menu Azul con temporizador de cierre
-- ============================================================================

MercadoSetuptimerB = MercadoSetuptimerB or {
    Total = 500,
    Intervalo = 20
}

assert(HDEV_Marketplace, "Carga primero HDEV_MarketplaceCore.lua")

HDEV_Marketplace.init({ debug = HDEV_MarketplaceGlobalConfig and HDEV_MarketplaceGlobalConfig.debug or false })
HDEV_Marketplace.buildMenu("BLUE")
HDEV_Marketplace.startMarketTimer("BLUE", MercadoSetuptimerB)

env.info("[MENU] Marketplace Azul V4 cargado correctamente.")
