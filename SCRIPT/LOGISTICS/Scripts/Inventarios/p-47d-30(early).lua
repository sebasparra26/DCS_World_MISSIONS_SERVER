
tipoAviones = tipoAviones or {}

tipoAviones["P-47D-30-(Early)"] = {
    costo = 15,
    nombreAvion = "P-47D-30 (Early)",
    avion = { ws = {1, 1, 1, 261}, cantidad = 2 },

    bombas = {
        ["AN-M30A1 - Bomb"]       = {ws = {4, 5, 9, 281}, cantidad = 2},
        ["AN-M57 - Bomb"]       = {ws = {4, 5, 9, 282}, cantidad = 2},
        ["AN-M64 - Bomb"]       = {ws = {4, 5, 9, 90}, cantidad = 2},
    },
    tanques = {
        ["108 US gal. Paper Fuel Tank"] = {ws = {1, 3, 43, 265}, cantidad = 2},
        ["110 US gal. Fuel Tank"] = {ws = {1, 3, 43, 266}, cantidad = 2},
        ["150 US gal. Fuel Tank"] = {ws = {1, 3, 43, 267}, cantidad = 2}
    }
}
