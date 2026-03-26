local debugActivo = false

local grupos = {
    [103] = { rojo = "TR_Temp04_Maupertus", azul = "US_Temp04_Maupertus" },
    [104] = { rojo = "TR_Temp05_Brucheville", azul = "US_Temp05_Brucheville" },
    [105] = { rojo = "TR_Temp06_Carpiquet", azul = "US_Temp06_Carpiquet" },
    [106] = { rojo = "TR_Temp07_Ronai", azul = "US_Temp07_Ronai" },
    [107] = { rojo = "TR_Temp08_Bernay", azul = "US_Temp08_Bernay" },
    [108] = { rojo = "TR_Temp09_Barville", azul = "US_Temp09_Barville" },
    [109] = { rojo = "TR_Temp10_Evreux", azul = "US_Temp10_Evreux" },
    [110] = { rojo = "TR_Temp11_Orly", azul = "US_Temp11_Orly" },
    [111] = { rojo = "TR_Temp12_Fecamp", azul = "US_Temp12_Fecamp" },
    [112] = { rojo = "TR_Temp13_Saint", azul = "US_Temp13_Saint" },
    [113] = { rojo = "TR_Temp14_Beauvais", azul = "US_Temp14_Beauvais" },
    [114] = { rojo = "TR_Temp15_Amiens", azul = "US_Temp15_Amiens" },
    [115] = { rojo = "TR_Temp16_Abbeville", azul = "US_Temp16_Abbeville" },
    [116] = { rojo = "TR_Temp01_Alderney", azul = "US_Temp01_Alderney" },
    [117] = { rojo = "TR_Temp02_Guernsey", azul = "US_Temp02_Guernsey" },
    [118] = { rojo = "TR_Temp03_Jersey", azul = "US_Temp03_Jersey" }  
}

local contadores = {}
local estadoPrevio = {}  -- Guarda el último valor leído de cada bandera

local function verificarBanderas()
    for bandera, data in pairs(grupos) do
        local valor = trigger.misc.getUserFlag(bandera)
        local valorPrevio = estadoPrevio[bandera]

        if valor ~= valorPrevio then
            estadoPrevio[bandera] = valor  -- Actualizar nuevo estado

            if valor == 1 then
                local nombreGrupo = data.rojo
                contadores[nombreGrupo] = (contadores[nombreGrupo] or 0) + 1
                local nuevoNombre = nombreGrupo .. "_Clone_" .. contadores[nombreGrupo]

                mist.cloneGroup(nombreGrupo, true, nuevoNombre)

                if debugActivo then
                    trigger.action.outText("Grupo ROJO '" .. nuevoNombre .. "' ACTIVADO (bandera " .. bandera .. ")", 10)
                end
                env.info("Grupo ROJO '" .. nuevoNombre .. "' clonado por bandera " .. bandera .. " = 1")

            elseif valor == 2 then
                local nombreGrupo = data.azul
                contadores[nombreGrupo] = (contadores[nombreGrupo] or 0) + 1
                local nuevoNombre = nombreGrupo .. "_Clone_" .. contadores[nombreGrupo]

                mist.cloneGroup(nombreGrupo, true, nuevoNombre)

                if debugActivo then
                    trigger.action.outText("Grupo AZUL '" .. nuevoNombre .. "' ACTIVADO (bandera " .. bandera .. ")", 10)
                end
                env.info("Grupo AZUL '" .. nuevoNombre .. "' clonado por bandera " .. bandera .. " = 2")
            end
        end
    end

    return timer.getTime() + 2
end

timer.scheduleFunction(verificarBanderas, {}, timer.getTime() + 2)

