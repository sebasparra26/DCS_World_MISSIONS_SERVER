
tipoAviones = tipoAviones or {}

tipoAviones["FA-18C_hornet_AA"] = {
    costo = 20,
    nombreAvion = "FA-18C_hornet x2",
    avion = { ws = {1, 1, 1, 280}, cantidad = 2 },

    --bombas = {
        --["500 lb GP Mk.I"]       = {ws = {4, 5, 9, 271}, cantidad = 12},
    --},

    Misiles = {
        ["AIM-120C"]  = {ws = {4, 4, 7, 106}, cantidad = 12},
        ["AIM-9X Sidewinder IR AAM"]  = {ws = {4, 4, 7, 136}, cantidad = 4}
    },

    --cohetes = {
        --["RP-3 AP"]  = {ws = {4, 7, 33, 361}, cantidad = 20},
        --["RP-3 HE"]  = {ws = {4, 7, 33, 359}, cantidad = 20},
        --["RP-3 SAP"] = {ws = {4, 7, 33, 360}, cantidad = 20}
    --},

    tanques = {
        ["100 gal. Drop Tank"] = {ws = {1, 3, 43, 587}, cantidad = 6}
    }
}
tipoAviones["FA-18C_hornet_AG"] = {
    costo = 20,
    nombreAvion = "FA-18C_hornet x2",
    avion = { ws = {1, 1, 1, 280}, cantidad = 2 },

    bombas = {
        ["JDAM-GBU-31(V)1/B"]       = {ws = {4, 5, 36, 85}, cantidad = 4}
    },

    misiles = {
        ["AIM-120C"]  = {ws = {4, 4, 7, 106}, cantidad = 2},
        ["AIM-9X Sidewinder IR AAM"]  = {ws = {4, 4, 7, 136}, cantidad = 4}
    },

    --cohetes = {
        --["RP-3 AP"]  = {ws = {4, 7, 33, 361}, cantidad = 20},
    --},

    tanques = {
        ["100 gal. Drop Tank"] = {ws = {1, 3, 43, 587}, cantidad = 6}
    },

    misc = {
        ["AN/ASQ-228 ATFLIR - Targeting Pod"] = {ws = {4, 15, 44, 426}, cantidad = 2}
    }
   
}

