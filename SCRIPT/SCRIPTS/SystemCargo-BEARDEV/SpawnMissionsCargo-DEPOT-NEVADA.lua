CARGO_ZONES = {
  { name = "ZONECARGO1", tipo = "pickup", aeropuerto = "Nellis" },
  { name = "ZONEDROP1",  tipo = "drop",   aeropuerto = "Nellis" },

  { name = "ZONECARGO2", tipo = "pickup", aeropuerto = "McCarran International" },
  { name = "ZONEDROP2",  tipo = "drop",   aeropuerto = "McCarran International" },

  { name = "ZONECARGO3", tipo = "pickup", aeropuerto = "North Las vegas" },
  { name = "ZONEDROP3",  tipo = "drop",   aeropuerto = "North Las vegas" },

  { name = "ZONECARGO4", tipo = "pickup", aeropuerto = "Henderson Executive" },
  { name = "ZONEDROP4",  tipo = "drop",   aeropuerto = "Henderson Executive" },

  { name = "ZONECARGO5", tipo = "pickup", aeropuerto = "Boulder City" },
  { name = "ZONEDROP5",  tipo = "drop",   aeropuerto = "Boulder City" },

  { name = "ZONECARGO6", tipo = "pickup", aeropuerto = "Jean" },
  { name = "ZONEDROP6",  tipo = "drop",   aeropuerto = "Jean" },

  { name = "ZONECARGO7", tipo = "pickup", aeropuerto = "Creech" },
  { name = "ZONEDROP7",  tipo = "drop",   aeropuerto = "Creech" },

  { name = "ZONECARGO8", tipo = "pickup", aeropuerto = "Beatty" },
  { name = "ZONEDROP8",  tipo = "drop",   aeropuerto = "Beatty" },

  { name = "ZONECARGO9", tipo = "pickup", aeropuerto = "Pahute Mesa" },
  { name = "ZONEDROP9",  tipo = "drop",   aeropuerto = "Pahute Mesa" },

  { name = "ZONECARGO10", tipo = "pickup", aeropuerto = "Mesquite" },
  { name = "ZONEDROP10",  tipo = "drop",   aeropuerto = "mesquite" },

  { name = "ZONECARGO11", tipo = "pickup", aeropuerto = "Tonopah test Range" },
  { name = "ZONEDROP11",  tipo = "drop",   aeropuerto = "Tonopah test Range" },

  { name = "ZONECARGO12", tipo = "pickup", aeropuerto = "Tonopah" },
  { name = "ZONEDROP12",  tipo = "drop",   aeropuerto = "Tonopah" },
}

--=============================================================
-- TIPOS DE CARGA - MAPA PERSIAN GULF
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