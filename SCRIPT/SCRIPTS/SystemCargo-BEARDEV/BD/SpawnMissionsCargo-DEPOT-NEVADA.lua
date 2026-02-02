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

  { name = "ZONECARGO13", tipo = "pickup", aeropuerto = "Lincoln County"},
  { name = "ZONEDROP13",  tipo = "drop",   aeropuerto = "Lincoln County" },

  { name = "ZONECARGO14", tipo = "pickup", aeropuerto = "Echo Bay"},
  { name = "ZONEDROP14",  tipo = "drop",   aeropuerto = "Echo Bay" },

   { name = "ZONECARGO15", tipo = "pickup", aeropuerto = "Mina"},
  { name = "ZONEDROP15",  tipo = "drop",   aeropuerto = "Mina" },

   { name = "ZONECARGO16", tipo = "pickup", aeropuerto = "Laughlin"},
  { name = "ZONEDROP16",  tipo = "drop",   aeropuerto = "Laughlin" },
}

--=============================================================
-- TIPOS DE CARGA - MAPA PERSIAN GULF
--=============================================================

CARGO_TYPES = {
  {
    label = "Carga Liviana (CDS BARRILES)",
    aircraft = { "C130" }, -- permitido en estos
    template = "CARGO_TEMPLATE_01",
    qty = { mode = "random", min = 6, max = 12 }
  },
    {
    label = "Carga Liviana (AMMO BOX)",
    aircraft = { "HUEY", "MI24" }, -- permitido en estos
    template = "CARGO_TEMPLATE_14",
    qty = { mode = "fixed", value = 1  }
  },
     {
    label = "Carga Liviana (AMMO BOX)",
    aircraft = { "CHINOOK", "MI8" }, -- permitido en estos
    template = "CARGO_TEMPLATE_14",
    qty = { mode = "random", min = 1, max = 4  }
  },
  {
    label = "Carga Liviana (CDS CAJAS)",
     aircraft = {"C130" }, -- permitido en estos
    template = "CARGO_TEMPLATE_02",
    qty = { mode = "random", min = 6, max = 12 }
  },
  {
    label = "Carga Pesada (CONTENEDOR LIVIANO)",
    aircraft = { "C130" }, -- permitido en estos
    template = "CARGO_TEMPLATE_04",
    qty = { mode = "random", min = 2, max = 4 }
  },
  {
    label = "Carga Pesada (CONTENEDOR PESADO)",
    aircraft = { "C130"}, -- permitido en estos
    template = "CARGO_TEMPLATE_04",
    qty = { mode = "fixed", value = 1 }
  },
  {
    label = "Carga Pesada (GBU 43 MOAB)",
    aircraft = { "C130" }, -- permitido en estos
    template = "CARGO_TEMPLATE_06",
    qty = { mode = "fixed", value = 1 }
  },

  {
  label = "Operación Reabastecimiento",
  aircraft = { "C130"}, -- permitido en estos
  items = {
    { label = "Suministros", template = "CARGO_TEMPLATE_03", qty = { mode = "random", min = 2, max = 3 } },
    { label = "MK 82", template = "CARGO_TEMPLATE_09", qty = { mode = "random", min = 4, max = 8 } },
  }
},

  {
  label = "Operación Construcción",
  aircraft = { "C130"}, -- permitido en estos
  items = {
    { label = "Suministros", template = "CARGO_TEMPLATE_03", qty = { mode = "fixed",  value = 1 } },
    { label = "Tubos Largos", template = "CARGO_TEMPLATE_07", qty = { mode = "fixed",  value = 1 } },
    { label = "Barrera de hormigón", template = "CARGO_TEMPLATE_12", qty = { mode = "fixed",  value = 1 } },
  }
},

  {
  label = "Operación Reabastecimiento 2",
  aircraft = { "C130"}, -- permitido en estos
  items = {
    { label = "L118 Light Artillery", template = "CARGO_TEMPLATE_13", qty = { mode = "fixed",  value = 1 }  },
    { label = "Obus 105mm", template = "CARGO_TEMPLATE_09", qty = { mode = "random", min = 4, max = 8 } },
  }
},

  {
  label = "Operación Construcción 2",
  aircraft = { "C130" }, -- permitido en estos
  items = {
    { label = "Tuberia", template = "CARGO_TEMPLATE_08", qty = { mode = "fixed",  value = 1 } },
    { label = "Tanques de Aceite", template = "CARGO_TEMPLATE_10", qty = { mode = "fixed",  value = 2 } },
    { label = "Barrera de hormigón", template = "CARGO_TEMPLATE_11", qty = { mode = "fixed",  value = 2 } },
  }
},


}