--=============================================================
-- CARGO BEAR - TEXTOS (ES)
-- Define:
--   CARGO_TEXTS
--   CARGO_DEBUG_TEXTS
--=============================================================

CARGO_TEXTS = {

  prefix = "[CARGO BEAR COMPANY] ",

  missionStart =
    "MISION DE CARGA INICIADA\n"..
    "ID: {ID}\n"..
    "Aeronave: {AIRCRAFT}\n"..
    "Pedido: {CARGO}\n"..
    "Items: {ITEMS}\n"..
    "Total cajas: {QTY}\n"..
    "Recoger: {PICKUP_AIRBASE}\n"..
    "Entregar: {DROP_AIRBASE}\n"..
     "Indicacion:\n"..
    "1) Ve hasta el aeropuerto:{PICKUP_AIRBASE} para recojer la carga acercate al humo {SMOKE_PICKUP}\n"..
    "2) Al llegar al Aeropuerto de destino: {DROP_AIRBASE} Busca el humo de color {SMOKE_DROP} y acercate para descargar y completar la mision.\n"..
    "3) La Mision solo finalizara al entregar todas las cargas en la zona designada, Humo color {SMOKE_DROP} y Etiqueta en F10 \n",

  cargoPicked =
    "MISION {ID} - CARGA RECOGIDA\n"..
    "Ahora dirigete hacia {DROP_AIRBASE}\n"..
    "Recuerda: la mision solo finalizara al entregar la carga en al zona designada humo: {SMOKE_DROP} Revisa F10, busca la etiqueta para mas información ",

  missionComplete =
    "MISION COMPLETADA\n"..
    "ID: {ID}\n"..
    "Entregaste {DELIVERED}/{QTY} cajas\n"..
    "Aeronave: {AIRCRAFT}\n"..
    "Pedido: {CARGO}\n"..
    "Items: {ITEMS}\n"..
    "Destino: {DROP_AIRBASE}",

  missionFailed =
    "MISION FALLIDA\n"..
    "ID: {ID}\n"..
    "Motivo: {REASON}\n"..
    "Aeronave: {AIRCRAFT}\n"..
    "Pedido: {CARGO}\n"..
    "Items: {ITEMS}\n"..
    "Recoger: {PICKUP_AIRBASE}\n"..
    "Entregar: {DROP_AIRBASE}",

  markPickup =
    "MISION {ID}\n"..
    "AERONAVE: {AIRCRAFT}\n"..
    "IR A RECOGER: {PICKUP_AIRBASE}\n"..
    "PEDIDO: {CARGO}\n"..
    "{ITEMS}\n"..
    "TOTAL: {QTY}\n"..
    "HUMO: {SMOKE_PICKUP}",

  markDrop =
    "MISION {ID}\n"..
    "AERONAVE: {AIRCRAFT}\n"..
    "IR A ENTREGAR: {DROP_AIRBASE}\n"..
    "PEDIDO: {CARGO}\n"..
    "{ITEMS}\n"..
    "TOTAL: {QTY}\n"..
    "HUMO: {SMOKE_DROP}",

  noMissions = "No hay misiones activas.",
  allCancelled = "Todas las misiones fueron canceladas.",
  limitActive = "No se puede crear mision. Limite de misiones activas: {MAX}",
  noJobForAircraft = "No hay pedidos compatibles para aeronave: {AIRCRAFT}",
  cantSpawn = "No se pudo spawnear carga del pedido.",
  zoneErrorPickup = "ERROR: No existe pickupZone {ZONE}",
  zoneErrorDrop = "ERROR: No existe dropZone {ZONE}",
  randomRouteError = "ERROR: No se pudo crear mision random por aeropuerto. Revisa CARGO_ZONES.",
  missingTemplate = "ERROR: Falta template de carga: {TEMPLATE}",

  statusHeader = "MISIONES ACTIVAS: {ACTIVE}/{MAX}",
  statusLine = "ID {ID} | {DELIVERED}/{QTY} | {CARGO} | AIR={AIRCRAFT} | FASE={PHASE}",
  statusItems = "  Items: {ITEMS}",
  statusPickup = "  Recoger: {PICKUP_AIRBASE}",
  statusDrop = "  Entregar: {DROP_AIRBASE}",
}

CARGO_DEBUG_TEXTS = {
  title = "=== DIAGNOSTICO CARGO BEAR ===",
  mistLoaded = "MIST cargado: {VALUE}",
  zonesDefined = "Zonas definidas: {VALUE}",
  jobsDefined = "Pedidos definidos: {VALUE}",
  monitorZoneExists = "Zona MONITOREO existe: {VALUE}",
  separator = "--------------------------------",

  jobHeader = "Pedido {INDEX}: {LABEL} | Aircraft: {AIRCRAFT}",
  jobInvalid = "  ERROR: Pedido invalido (sin items)",
  itemLine = "  Item {INDEX}) {LABEL} | template={TEMPLATE} | existe={EXISTS}",
}
