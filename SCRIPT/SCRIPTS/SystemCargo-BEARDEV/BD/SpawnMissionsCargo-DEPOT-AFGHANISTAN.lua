CARGO_ZONES = {
  { name = "ZONECARGO1", tipo = "pickup", aeropuerto = "Camp Bastion" },
  { name = "ZONEDROP1",  tipo = "drop",   aeropuerto = "Camp Bastion" },

  { name = "ZONECARGO2", tipo = "pickup", aeropuerto = "Bost" },
  { name = "ZONEDROP2",  tipo = "drop",   aeropuerto = "Bost" },

  { name = "ZONECARGO3", tipo = "pickup", aeropuerto = "Dwyer" },
  { name = "ZONEDROP3",  tipo = "drop",   aeropuerto = "Dwyer" },

  { name = "ZONECARGO4", tipo = "pickup", aeropuerto = "Kandahar" },
  { name = "ZONEDROP4",  tipo = "drop",   aeropuerto = "Kandahar" },

  { name = "ZONECARGO5", tipo = "pickup", aeropuerto = "Tarinkot" },
  { name = "ZONEDROP5",  tipo = "drop",   aeropuerto = "Tarinkot" },

  { name = "ZONECARGO6", tipo = "pickup", aeropuerto = "Sharana" },
  { name = "ZONEDROP6",  tipo = "drop",   aeropuerto = "Sharana" },

  { name = "ZONECARGO7", tipo = "pickup", aeropuerto = "Khost" },
  { name = "ZONEDROP7",  tipo = "drop",   aeropuerto = "Khost" },

  { name = "ZONECARGO8", tipo = "pickup", aeropuerto = "Gardez" },
  { name = "ZONEDROP8",  tipo = "drop",   aeropuerto = "Gardez" },

  { name = "ZONECARGO9", tipo = "pickup", aeropuerto = "Jalalabad" },
  { name = "ZONEDROP9",  tipo = "drop",   aeropuerto = "Jalalabad" },

  { name = "ZONECARGO10", tipo = "pickup", aeropuerto = "Kabul" },
  { name = "ZONEDROP10",  tipo = "drop",   aeropuerto = "Kabul" },

  { name = "ZONECARGO11", tipo = "pickup", aeropuerto = "Bagram" },
  { name = "ZONEDROP11",  tipo = "drop",   aeropuerto = "Bagram" },


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