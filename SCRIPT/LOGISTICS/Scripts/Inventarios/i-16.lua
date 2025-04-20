tipoAviones = tipoAviones or {}

tipoAviones["I-16"] = {
    costo = 15,
    nombreAvion = "I-16",
    avion = { ws = {1, 1, 1, 282}, cantidad = 5 },

    --bombas = {
  --},

    cohetes = {
        ["RS-82"]  = {ws = {4, 7, 33, 326}, cantidad = 20}
    },

    tanques = {
        ["I-16 External fuel Tank"]  = {ws = {1, 3, 43, 589}, cantidad = 10} 
    }
}
