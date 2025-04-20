
tipoAviones = tipoAviones or {}

tipoAviones["FW-190-D9"] = { --1250
    costo = 15,
    nombreAvion = "FW-190-D9",
    avion = { ws = {1, 1, 1, 255}, cantidad = 5 },

    bombas = {
        ["FAB-50 - 50kg GP Bomb LD"]       = {ws = {4, 5, 9, 325}, cantidad = 4}, 
        ["SC 500 J"]       = {ws = {4, 5, 9, 258}, cantidad = 4}
     
        
    },

    cohetes = {
        ["Werfer-Granate 21"]  = {ws = {4, 7, 33, 257}, cantidad = 20},
        ["R4M 3.2kg UnGd air-to-air rocket"]  = {ws = {4, 7, 33, 256}, cantidad = 20}

    },

    tanques = {
        ["300 Liter Fuel Tank Type E2"]  = {ws = {1, 3, 43, 264}, cantidad = 10}
    }
}
