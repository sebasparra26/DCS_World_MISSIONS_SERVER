
tipoAviones = tipoAviones or {}

--tipoAviones["Spitfire-LF-Mk.IX"] = {
    --costo = 15,
    --nombreAvion = "Spitfire LF Mk.IX",
    --avion = { ws = {1, 1, 1, 258}, cantidad = 5 },

    --bombas = {
        --["250 lb GP Mk.I"]       = {ws = {4, 5, 9, 268}, cantidad = 8},
        --["Beer Bomb"]       = {ws = {4, 5, 9, 285}, cantidad = 8},
    --},

    --tanques = {
        --["45 Gal. Slipper Tank"]  = {ws = {1, 3, 43, 274}, cantidad = 10},
        --["45 Gal. Torpedo Tank"]  = {ws = {1, 3, 43, 275}, cantidad = 10}
    --}
--}
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

