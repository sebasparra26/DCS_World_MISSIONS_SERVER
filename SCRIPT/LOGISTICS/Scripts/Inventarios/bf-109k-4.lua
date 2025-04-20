
tipoAviones = tipoAviones or {}

tipoAviones["BF-109-k-4"] = {
    costo = 15,
    nombreAvion = "BF-109 k-4",
    avion = { ws = {1, 1, 1, 257}, cantidad = 2 },

    bombas = {
        ["SC 250 Type 3 J"]       = {ws = {4, 5, 9, 257}, cantidad = 4}, 
        ["SC 500 J"]       = {ws = {4, 5, 9, 258}, cantidad = 4}
    },
    tanques = {
        ["100 gal. Drop Tank"] = {ws = {1, 3, 43, 263}, cantidad = 2}
    }
}
