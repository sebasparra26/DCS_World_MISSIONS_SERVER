
tipoAviones = tipoAviones or {}

--tipoAviones["Mosquito-FB-Mk-VI"] = {
   -- costo = 15,
   -- nombreAvion = "Mosquito FB Mk-VI",
    --avion = { ws = {1, 1, 4, 297}, cantidad = 5 },

   -- bombas = {
       -- ["500 lb GP Mk.I"]       = {ws = {4, 5, 9, 271}, cantidad = 12},
        --["250 lb GP Mk.I"]       = {ws = {4, 5, 9, 268}, cantidad = 8},
       -- ["500 lb GP Mk.IV"]      = {ws = {4, 5, 9, 272}, cantidad = 10},
       -- ["250 lb GP Mk.IV"]      = {ws = {4, 5, 9, 269}, cantidad = 8},
       -- ["500 lb GP Mk.V"]       = {ws = {4, 5, 9, 274}, cantidad = 6},
       -- ["250 lb GP Mk.V"]       = {ws = {4, 5, 9, 270}, cantidad = 6},
       -- ["500 lb GP Short tail"] = {ws = {4, 5, 9, 273}, cantidad = 10},
       -- ["250 lb MC Mk.I"]       = {ws = {4, 5, 9, 275}, cantidad = 6},
       -- ["500 lb MC Mk.II"]      = {ws = {4, 5, 9, 278}, cantidad = 6},
      -- ["250 lb MC Mk.II"]      = {ws = {4, 5, 9, 276}, cantidad = 6},
      --  ["500 lb MC Short tail"] = {ws = {4, 5, 9, 277}, cantidad = 6},
      -- ["500 lb S.A.P."]        = {ws = {4, 5, 9, 280}, cantidad = 8},
      --  ["250 lb S.A.P."]        = {ws = {4, 5, 9, 279}, cantidad = 8}
 --  },

  --  cohetes = {
       -- ["RP-3 AP"]  = {ws = {4, 7, 33, 361}, cantidad = 20},
       -- ["RP-3 HE"]  = {ws = {4, 7, 33, 359}, cantidad = 20},
      --  ["RP-3 SAP"] = {ws = {4, 7, 33, 360}, cantidad = 20}
  -- },

 --  tanques = {
       -- ["100 gal. Drop Tank"] = {ws = {1, 3, 43, 783}, cantidad = 10},
        --["50 gal. Drop Tank"]  = {ws = {1, 3, 43, 782}, cantidad = 10}
    --}
--}
--OPCION 01 / SINGLE 
tipoAviones["Mosquito-FB-Mk-VI-S"] = {
    costo = 32455,
    nombreAvion = "Mosquito FB Mk-VI - Standard Unit",
    avion = { ws = {1, 1, 4, 297}, cantidad = 1 }
}
--OPCION 02 / INTERCEPTOR SQUADRON
tipoAviones["Mosquito-FB-Mk-VI-I"] = {
    costo = 66090,
    nombreAvion = "Mosquito FB Mk-VI - Interceptor Squadron",
    avion = { ws = {1, 1, 4, 297}, cantidad = 2 },

    tanques = {
        ["100 gal. Drop Tank"] = {ws = {1, 3, 43, 783}, cantidad = 4}
         --["50 gal. Drop Tank"]  = {ws = {1, 3, 43, 782}, cantidad = 10}
    }
}
--OPCION 03 / BOMBING WING
tipoAviones["Mosquito-FB-Mk-VI-B"] = {
    costo = 68870,
    nombreAvion = "Mosquito FB Mk-VI - Bombing Wing",
    avion = { ws = {1, 1, 4, 297}, cantidad = 2 },

    bombas = {
        ["500 lb MC Mk.II"]      = {ws = {4, 5, 9, 278}, cantidad = 8}
    }
}
--OPCION 04 / TACTICAL GROUND-ATACK
tipoAviones["Mosquito-FB-Mk-VI-TA"] = {
    costo = 71670,
    nombreAvion = "Mosquito FB Mk-VI - Tactical G-Attack",
    avion = { ws = {1, 1, 4, 297}, cantidad = 2 },

    bombas = {
        ["250 lb S.A.P."]        = {ws = {4, 5, 9, 279}, cantidad = 4}
    },

    cohetes = {
        ["RP-3 AP"]  = {ws = {4, 7, 33, 361}, cantidad = 8},
        ["RP-3 HE"]  = {ws = {4, 7, 33, 359}, cantidad = 8}
    },
    tanques = {
        --["100 gal. Drop Tank"] = {ws = {1, 3, 43, 783}, cantidad = 4}
        ["50 gal. Drop Tank"]  = {ws = {1, 3, 43, 782}, cantidad = 4}
    }
}
--OPCION 05 / TACTICAL LOGISTICS
tipoAviones["Mosquito-FB-Mk-VI-L"] = {
    costo = 65550,
    nombreAvion = "Mosquito FB Mk-VI - Logistic",
    avion = { ws = {1, 1, 4, 297}, cantidad = 2 },

    tanques = {
        --["100 gal. Drop Tank"] = {ws = {1, 3, 43, 783}, cantidad = 4}
         ["50 gal. Drop Tank"]  = {ws = {1, 3, 43, 782}, cantidad = 4}
    }
}--5211630
