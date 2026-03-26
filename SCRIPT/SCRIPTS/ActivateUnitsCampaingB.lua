local debugActivo = true

local grupos = {
    [103] = { rojo = "TR_Temp01_Maupertus", azul = "US_Temp01_Maupertus" },
    [104] = { rojo = "TR_Temp02_Maupertus", azul = "US_Temp02_Maupertus" },
    [105] = { rojo = "TR_Temp03_Maupertus", azul = "US_Temp03_Maupertus" },
    [106] = { rojo = "TR_Temp04_Maupertus", azul = "US_Temp04_Maupertus" },
    [107] = { rojo = "TR_Temp05_Maupertus", azul = "US_Temp05_Maupertus" },
    [108] = { rojo = "TR_Temp06_Maupertus", azul = "US_Temp06_Maupertus" },
    [109] = { rojo = "TR_Temp07_Maupertus", azul = "US_Temp07_Maupertus" },
    [110] = { rojo = "TR_Temp08_Maupertus", azul = "US_Temp08_Maupertus" },
    [111] = { rojo = "TR_Temp09_Maupertus", azul = "US_Temp09_Maupertus" },
    [112] = { rojo = "TR_Temp10_Maupertus", azul = "US_Temp10_Maupertus" },
    [113] = { rojo = "TR_Temp11_Maupertus", azul = "US_Temp11_Maupertus" },
    [114] = { rojo = "TR_Temp12_Maupertus", azul = "US_Temp12_Maupertus" },
    [115] = { rojo = "TR_Temp13_Maupertus", azul = "US_Temp13_Maupertus" },
    [116] = { rojo = "TR_Temp14_Maupertus", azul = "US_Temp14_Maupertus" }
}

local contadores = {}
local estadoPrevio = {}  -- Guarda el último valor leído de cada bandera

local function verificarBanderas()
    for bandera, data in pairs(grupos) do
        local valor = trigger.misc.getUserFlag(bandera)
        local valorPrevio = estadoPrevio[bandera]

        if valor ~= valorPrevio then
            estadoPrevio[bandera] = valor  -- Actualizar nuevo estado

            if valor == 3 then
                local nombreGrupo = data.rojo
                contadores[nombreGrupo] = (contadores[nombreGrupo] or 0) + 1
                local nuevoNombre = nombreGrupo .. "_Clone_" .. contadores[nombreGrupo]

                mist.cloneGroup(nombreGrupo, true, nuevoNombre)

                if debugActivo then
                    trigger.action.outText("Grupo ROJO '" .. nuevoNombre .. "' ACTIVADO (bandera " .. bandera .. ")", 10)
                end
                env.info("Grupo ROJO '" .. nuevoNombre .. "' clonado por bandera " .. bandera .. " = 3")

            elseif valor == 1 then
                local nombreGrupo = data.azul
                contadores[nombreGrupo] = (contadores[nombreGrupo] or 0) + 1
                local nuevoNombre = nombreGrupo .. "_Clone_" .. contadores[nombreGrupo]

                mist.cloneGroup(nombreGrupo, true, nuevoNombre)

                if debugActivo then
                    trigger.action.outText("Grupo AZUL '" .. nuevoNombre .. "' ACTIVADO (bandera " .. bandera .. ")", 10)
                end
                env.info("Grupo AZUL '" .. nuevoNombre .. "' clonado por bandera " .. bandera .. " = 1")
            end
        end
    end

    return timer.getTime() + 2
end

timer.scheduleFunction(verificarBanderas, {}, timer.getTime() + 2)

