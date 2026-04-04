local debugActivo = true

local grupos = {
    [100] = { rojo = "RU_100_Difarsuwar", azul = "US_100_Difarsuwar" },
    [117] = { rojo = "RU_117_CairoW", azul = "US_117_CairoW" },
    
 
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

