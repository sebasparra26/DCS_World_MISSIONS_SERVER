tipoAviones = tipoAviones or {}

tipoAviones["armamento"] = {
    costo = 15,

    bombas = {
        ----------------BOMBAS UK------------------------------------------
        ["500 lb GP Mk.I"]       = {ws = {4, 5, 9, 271}, cantidad = 12},
        ["250 lb GP Mk.I"]       = {ws = {4, 5, 9, 268}, cantidad = 8},
        ["500 lb GP Mk.IV"]      = {ws = {4, 5, 9, 272}, cantidad = 10},
        ["250 lb GP Mk.IV"]      = {ws = {4, 5, 9, 269}, cantidad = 8},
        ["500 lb GP Mk.V"]       = {ws = {4, 5, 9, 274}, cantidad = 6},
        ["250 lb GP Mk.V"]       = {ws = {4, 5, 9, 270}, cantidad = 6},
        ["500 lb GP Short tail"] = {ws = {4, 5, 9, 273}, cantidad = 10},
        ["250 lb MC Mk.I"]       = {ws = {4, 5, 9, 275}, cantidad = 6},
        ["500 lb MC Mk.II"]      = {ws = {4, 5, 9, 278}, cantidad = 6},
        ["250 lb MC Mk.II"]      = {ws = {4, 5, 9, 276}, cantidad = 6},
        ["500 lb MC Short tail"] = {ws = {4, 5, 9, 277}, cantidad = 6},
        ["500 lb S.A.P."]        = {ws = {4, 5, 9, 280}, cantidad = 8},
        ["250 lb S.A.P."]        = {ws = {4, 5, 9, 279}, cantidad = 8},
        ["Beer Bomb"]       = {ws = {4, 5, 9, 285}, cantidad = 8},
        ----------------BOMBAS USA------------------------------------------
        ["AN-M30A1 - Bomb"]       = {ws = {4, 5, 9, 281}, cantidad = 2},
        ["AN-M57 - Bomb"]       = {ws = {4, 5, 9, 282}, cantidad = 2},
        ["AN-M64 - Bomb"]       = {ws = {4, 5, 9, 90}, cantidad = 2},
        ["AN-M65 - Bomb"]       = {ws = {4, 5, 9, 283}, cantidad = 2},
        ----------------BOMBAS GERMAN------------------------------------------
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
        ----------------COHETES UK------------------------------------------
        ["RP-3 AP"]  = {ws = {4, 7, 33, 361}, cantidad = 20},
        ["RP-3 HE"]  = {ws = {4, 7, 33, 359}, cantidad = 20},
        ["RP-3 SAP"] = {ws = {4, 7, 33, 360}, cantidad = 20},
        ----------------COHETES USA------------------------------------------
        ["HVAR Ung Rocket"]  = {ws = {4, 7, 33, 159}, cantidad = 20},
        ["4.5 Inch M8 UnGd Rocket"]  = {ws = {4, 7, 33, 258}, cantidad = 20},
        ----------------COHETES GERMAN------------------------------------------
        ["Werfer-Granate 21"]  = {ws = {4, 7, 33, 257}, cantidad = 20},
        ["R4M 3.2kg UnGd air-to-air rocket"]  = {ws = {4, 7, 33, 256}, cantidad = 20},
        ----------------COHETES RUSIA------------------------------------------
        ["RS-82"]  = {ws = {4, 7, 33, 326}, cantidad = 20}
        
    },
    
    tanques = {
        ----------------TANQUES UK------------------------------------------
        ["100 gal. Drop Tank"] = {ws = {1, 3, 43, 783}, cantidad = 10},
        ["50 gal. Drop Tank"]  = {ws = {1, 3, 43, 782}, cantidad = 10},
        ["45 Gal. Slipper Tank"]  = {ws = {1, 3, 43, 274}, cantidad = 10},
        ["45 Gal. Torpedo Tank"]  = {ws = {1, 3, 43, 275}, cantidad = 10},
        ----------------TANQUES USA------------------------------------------
        ["108 US gal. Paper Fuel Tank"] = {ws = {1, 3, 43, 265}, cantidad = 2},
        ["110 US gal. Fuel Tank"] = {ws = {1, 3, 43, 266}, cantidad = 2},
        ["150 US gal. Fuel Tank"] = {ws = {1, 3, 43, 267}, cantidad = 2},
        ["75 us Gal. Tank"]  = {ws = {1, 3, 43, 152}, cantidad = 10},
        ----------------TANQUES GERMAN------------------------------------------
        ["100 gal Drop Tank"] = {ws = {1, 3, 43, 263}, cantidad = 2},
        ["300 Liter Fuel Tank"]  = {ws = {1, 3, 43, 263}, cantidad = 10} ,
        ["300 Liter Fuel Tank Type E2"]  = {ws = {1, 3, 43, 264}, cantidad = 10},
        ----------------TANQUES RUSIA-----------------------------------------
        ["I-16 External fuel Tank"]  = {ws = {1, 3, 43, 589}, cantidad = 10} 
    }
}
