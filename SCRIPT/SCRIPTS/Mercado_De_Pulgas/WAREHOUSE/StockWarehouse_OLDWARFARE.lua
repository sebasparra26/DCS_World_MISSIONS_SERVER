---------------------------BAZTIAN---------------------------------------------------------------------------


tipoAviones = tipoAviones or {}

-- ===============================
-- Mosquito FB Mk-VI
-- ===============================

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
-- ===============================
-- Spitfire LF Mk.IX
-- ===============================
tipoAviones["Spitfire-LF-Mk.IX-S"] = {
    costo = 51150,
    nombreAvion = "Spitfire LF Mk.IX - Standard Unit",
    avion = { ws = {1, 1, 1, 258}, cantidad = 5 },
    tanques = {
        ["45 Gal. Slipper Tank"]  = {ws = {1, 3, 43, 274}, cantidad = 1}
        --["45 Gal. Torpedo Tank"]  = {ws = {1, 3, 43, 275}, cantidad = 10}
    }
}
tipoAviones["Spitfire-LF-Mk.IX-I"] = {
    costo = 102300,
    nombreAvion = "Spitfire LF Mk.IX -   Interceptor Squadron",
    avion = { ws = {1, 1, 1, 258}, cantidad = 2 },
    tanques = {
        ["45 Gal. Slipper Tank"]  = {ws = {1, 3, 43, 274}, cantidad = 2}
        --["45 Gal. Torpedo Tank"]  = {ws = {1, 3, 43, 275}, cantidad = 10}
    }
}
tipoAviones["Spitfire-LF-Mk.IX-B"] = {
    costo = 102800,
    nombreAvion = "Spitfire LF Mk.IX -   Bombing Wing",
    avion = { ws = {1, 1, 1, 258}, cantidad = 2 },

    bombas = {
        ["250 lb GP Mk.I"]       = {ws = {4, 5, 9, 268}, cantidad = 4},
        --["Beer Bomb"]       = {ws = {4, 5, 9, 285}, cantidad = 8},
    },
    tanques = {
        ["45 Gal. Slipper Tank"]  = {ws = {1, 3, 43, 274}, cantidad = 2}
        --["45 Gal. Torpedo Tank"]  = {ws = {1, 3, 43, 275}, cantidad = 10}
    }
}
-- ===============================
-- Spitfire LF Mk.IX CW
-- ===============================
tipoAviones["Spitfire-LF-Mk.IX-CW-S"] = {
    costo = 52650,
    nombreAvion = "Spitfire LF Mk.IX CW - Standard Unit",
    avion = { ws = {1, 1, 1, 258}, cantidad = 5 },
    tanques = {
        ["45 Gal. Slipper Tank"]  = {ws = {1, 3, 43, 274}, cantidad = 1}
        --["45 Gal. Torpedo Tank"]  = {ws = {1, 3, 43, 275}, cantidad = 10}
    }
}
tipoAviones["Spitfire-LF-Mk.IX-CW-I"] = {
    costo = 105300,
    nombreAvion = "Spitfire LF Mk.IX CW -   Interceptor Squadron",
    avion = { ws = {1, 1, 1, 258}, cantidad = 2 },
    tanques = {
        ["45 Gal. Slipper Tank"]  = {ws = {1, 3, 43, 274}, cantidad = 2}
        --["45 Gal. Torpedo Tank"]  = {ws = {1, 3, 43, 275}, cantidad = 10}
    }
}
tipoAviones["Spitfire-LF-Mk.IX-CW-B"] = {
    costo = 105800,
    nombreAvion = "Spitfire LF Mk.IX CW -   Bombing Wing",
    avion = { ws = {1, 1, 1, 258}, cantidad = 2 },

    bombas = {
        ["250 lb GP Mk.I"]       = {ws = {4, 5, 9, 268}, cantidad = 4},
        --["Beer Bomb"]       = {ws = {4, 5, 9, 285}, cantidad = 8},
    },
    tanques = {
        ["45 Gal. Slipper Tank"]  = {ws = {1, 3, 43, 274}, cantidad = 2}
        --["45 Gal. Torpedo Tank"]  = {ws = {1, 3, 43, 275}, cantidad = 10}
    }
}
