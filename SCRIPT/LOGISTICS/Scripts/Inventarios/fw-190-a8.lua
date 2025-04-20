
tipoAviones = tipoAviones or {}

tipoAviones["FW-190-A8"] = { 
    costo = 15,
    nombreAvion = "FW-190-A8",
    avion = { ws = {1, 1, 1, 256}, cantidad = 5 },

    bombas = {
        ["FAB-50 - 50kg GP Bomb LD"]       = {ws = {4, 5, 9, 325}, cantidad = 4}, 
        ["AB 250-2 SD-10A"]       = {ws = {4, 5, 38, 265}, cantidad = 4}, 
        ["AB 250-2 SD-2"]       = {ws = {4, 5, 38, 263}, cantidad = 4}, 
        ["AB 500-1 SD-10A"]       = {ws = {4, 5, 38, 267}, cantidad = 4}, 
        ["SC 250 Type 1 L2"]       = {ws = {4, 5, 9, 256}, cantidad = 4}, 
        ["SC 250 Type 3 J"]       = {ws = {4, 5, 9, 257}, cantidad = 4}, 
        ["SC 500 J"]       = {ws = {4, 5, 9, 258}, cantidad = 4}, 
        ["SC 500 L2"]       = {ws = {4, 5, 9, 259}, cantidad = 4}, 
        ["SD 250 Stg"]       = {ws = {4, 5, 9, 260}, cantidad = 4}, 
        ["SC 500 A"]       = {ws = {4, 5, 9, 261}, cantidad = 4}
        
    },

    cohetes = {
        ["Werfer-Granate 21"]  = {ws = {4, 7, 33, 257}, cantidad = 20} 
    },

    tanques = {
        ["300 Liter Fuel Tank"]  = {ws = {1, 3, 43, 263}, cantidad = 10} 
    }
}
