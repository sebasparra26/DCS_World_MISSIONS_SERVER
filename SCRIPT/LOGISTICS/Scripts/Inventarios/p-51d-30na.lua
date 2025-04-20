
tipoAviones = tipoAviones or {}

tipoAviones["P-51D-30NA"] = {
    costo = 15,
    nombreAvion = "P-51D-30NA",
    avion = { ws = {1, 1, 1, 64}, cantidad = 5 },

    bombas = {
        ["AN-M64"]       = {ws = {4, 5, 9, 90}, cantidad = 4}
    },

    cohetes = {
        ["HVAR Ung Rocket"]  = {ws = {4, 7, 33, 159}, cantidad = 20}
    },

    tanques = {
        ["75 us Gal. Tank"]  = {ws = {1, 3, 43, 152}, cantidad = 10}
    }
}
