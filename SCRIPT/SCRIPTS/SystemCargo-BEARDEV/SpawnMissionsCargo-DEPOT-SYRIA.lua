CARGO_ZONES = {
  { name = "ZONECARGO1", tipo = "pickup", aeropuerto = "Paphos" },
  { name = "ZONEDROP1",  tipo = "drop",   aeropuerto = "Paphos" },

  { name = "ZONECARGO2", tipo = "pickup", aeropuerto = "Akrotiri" },
  { name = "ZONEDROP2",  tipo = "drop",   aeropuerto = "Akrotiri" },

  { name = "ZONECARGO3", tipo = "pickup", aeropuerto = "Larnaca" },
  { name = "ZONEDROP3",  tipo = "drop",   aeropuerto = "Larnaca" },

  { name = "ZONECARGO4", tipo = "pickup", aeropuerto = "Ercan" },
  { name = "ZONEDROP4",  tipo = "drop",   aeropuerto = "Ercan" },

  { name = "ZONECARGO5", tipo = "pickup", aeropuerto = "Gecitkale" },
  { name = "ZONEDROP5",  tipo = "drop",   aeropuerto = "Gecitkale" },

  { name = "ZONECARGO6", tipo = "pickup", aeropuerto = "Incirlik" },
  { name = "ZONEDROP6",  tipo = "drop",   aeropuerto = "Incirlik" },

  { name = "ZONECARGO7", tipo = "pickup", aeropuerto = "Gazipasa" },
  { name = "ZONEDROP7",  tipo = "drop",   aeropuerto = "Gazipasa" },

  { name = "ZONECARGO8", tipo = "pickup", aeropuerto = "Beirut" },
  { name = "ZONEDROP8",  tipo = "drop",   aeropuerto = "Beirut" },

  { name = "ZONECARGO9", tipo = "pickup", aeropuerto = "Ramat David" },
  { name = "ZONEDROP9",  tipo = "drop",   aeropuerto = "Ramat David" },

}

--=============================================================
-- TIPOS DE CARGA - MAPA SYRIA
--=============================================================

CARGO_TYPES = {
  {
    label = "Carga Liviana (CDS BARRILES)",
    template = "CARGO_TEMPLATE_01",
    qty = { mode = "random", min = 6, max = 12 }
  },
  {
    label = "Carga Liviana (CDS CAJAS)",
    template = "CARGO_TEMPLATE_02",
    qty = { mode = "random", min = 6, max = 12 }
  },
  {
    label = "Carga Pesada (CONTENEDOR LIVIANO)",
    template = "CARGO_TEMPLATE_04",
    qty = { mode = "random", min = 2, max = 4 }
  },
  {
    label = "Carga Pesada (CONTENEDOR PESADO)",
    template = "CARGO_TEMPLATE_04",
    qty = { mode = "fixed", value = 2 }
  },
  {
    label = "Carga Pesada (CONTENEDOR PESADO PEQUEÑO)",
    template = "CARGO_TEMPLATE_05",
    qty = { mode = "fixed", value = 3 }
  },
}