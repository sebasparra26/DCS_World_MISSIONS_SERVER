-- Activar o desactivar debug
local debugActivo = false

-- Estado de banderas: (Bandera, Valor)
estadoBanderasAeropuertos = {
    ["Liwa AFB"] = { bandera = 100, valor = nil },
    --["Al Dhafra AFB"] = { bandera = 101, valor = nil },
    ["Al-Bateen"] = { bandera = 102, valor = nil },
    --["Sas Al Nakheel"] = { bandera = 103, valor = nil },
    --["Abu Dhabi Intl"] = { bandera = 104, valor = nil },
    ["Al Ain Intl"] = { bandera = 105, valor = nil },
    ["Al Maktoum Intl"] = { bandera = 106, valor = nil },
    ["Al Minhad AFB"] = { bandera = 107, valor = nil },
    ["Dubai Intl"] = { bandera = 108, valor = nil },
    ["Sharjah Intl"] = { bandera = 109, valor = nil },
    ["Fujairah intl"] = { bandera = 110, valor = nil },
    ["Ras Al Khaimah Intl"] = { bandera = 111, valor = nil },
    ["Khasab"] = { bandera = 112, valor = nil },
    ["Bandar-e-Jask"] = { bandera = 113, valor = nil },
    ["Sir Abu Nuayr"] = { bandera = 114, valor = nil },
    ["Abu Musa Island"] = { bandera = 115, valor = nil },
    ["Sirri Island"] = { bandera = 116, valor = nil },
    ["Tunb Kochak"] = { bandera = 117, valor = nil },
    ["Tunb Island AFB"] = { bandera = 118, valor = nil },
    ["Bandar Lengeh"] = { bandera = 119, valor = nil },
    ["Kish Intl"] = { bandera = 120, valor = nil },
    ["Lavan Island"] = { bandera = 121, valor = nil },
    ["Qeshm Island"] = { bandera = 122, valor = nil },
    --["Havadarya"] = { bandera = 123, valor = nil },
    ["Bandar Abbas Intl"] = { bandera = 124, valor = nil },
    ["Lar"] = { bandera = 125, valor = nil }
    --["Jiroft"] = { bandera = 126, valor = nil },
    --["Shiraz Intl"] = { bandera = 127, valor = nil },
    --["Kerman"] = { bandera = 128, valor = nil }
}

-- Posiciones y radios
local aeropuertos = {
    ["Liwa AFB"] = { position = {x = -275733, y = 0, z = -248186}, radius = 12000 },                            --1-- Metric: X-00275733 Z-00248186    high
    --["Al Dhafra AFB"] = { position = {x = -211657, y = 0, z = -173058}, radius = 12000 },                       --2-- Metric: X-00211657 Z-00173058    High
    ["Al-Bateen"] = { position = {x = -190948, y = 0, z = -181927}, radius = 12000},                             --3-- Metric: X-00190948 Z-00181927    Medium
    --["Sas Al Nakheel"] = { position = {x = -189610, y = 0, z = -175974}, radius = 2000},                        --4-- Metric: X-00189610 Z-00175974    Medium
    --["Abu Dhabi Intl"] = { position = {x = -189658, y = 0, z = -162399}, radius = 12000 },                      --5-- Metric: X-00189658 Z-00162399    high
    ["Al Ain Intl"] = { position = {x = -211063, y = 0, z = -65171}, radius = 12000 },                          --6-- Metric: X-00211063 Z-00065171    high
    ["Al Maktoum Intl"] = { position = {x = -140840, y = 0, z = -109920}, radius = 12000 },                     --7-- Metric: X-00140840 Z-00109920    high
    ["Al Minhad AFB"] = { position = {x = -126104, y = 0, z = -89108}, radius = 12000 },                        --8-- Metric: X-00126104 Z-00089108    high
    ["Dubai Intl"] = { position = {x = -100874, y = 0, z = -88902}, radius = 12000 },                           --9-- Metric: X-00100874 Z-00088902    high
    ["Sharjah Intl"] = { position = {x = -92768, y = 0, z = -73636}, radius = 12000 },                          --10-- Metric: X-00092768 Z-00073636   high
    ["Fujairah intl"] = { position = {x = -117483, y = 0, z = 7840}, radius = 12000 },                         --11-- Metric: X-00117483 Z+00007840   high
    ["Ras Al Khaimah Intl"] = { position = {x = -61632, y = 0, z = -30809}, radius = 12000 },                   --12-- Metric: X-00061632 Z-00030809   high
    ["Khasab"] = { position = {x = -152, y = 0, z = -164}, radius = 5000 },                                     --13-- Metric: X-00000152 Z-00000164   Medium
    ["Bandar-e-Jask"] = { position = {x = -57219, y = 0, z = 156064}, radius = 5000 },                          --14-- Metric: X-00057219 Z+00156064   Medium
    ["Sir Abu Nuayr"] = { position = {x = -103098, y = 0, z = -202998}, radius = 5000 },                        --16-- Metric: X-00103098 Z-00202998   Small
    ["Abu Musa Island"] = { position = {x = -31498, y = 0, z = -121336}, radius = 5000 },                       --17-- Metric: X-00031498 Z-00121336   Small
    ["Sirri Island"] = { position = {x = -26948, y = 0, z = -170744}, radius = 5000 },                          --18-- Metric: X-00026948 Z-00170744   Small
    ["Tunb Kochak"] = { position = {x = 9023, y = 0, z = -109467}, radius = 5000 },                             --19-- Metric: X+00009023 Z-00109467   Small
    ["Tunb Island AFB"] = { position = {x = 10630, y = 0, z = -92388}, radius = 5000 },                         --20-- Metric: X+00010630 Z-00092388   Small
    ["Bandar Lengeh"] = { position = {x = 41538, y = 0, z = -140953}, radius = 8000 },                          --21-- Metric: X+00041538 Z-00140953   Small
    ["Kish Intl"] = { position = {x = 42782, y = 0, z = -225092}, radius = 8000 },                              --22-- Metric: X+00042782 Z-00225092   Medium
    ["Lavan Island"] = { position = {x = 75789, y = 0, z = -286794}, radius = 4200 },                           --23-- X+00075789 Z-00286794   Small
    ["Qeshm Island"] = { position = {x = 64762, y = 0, z = -33452}, radius = 12000 },                           --24- Metric: X+00064762 Z-00033452   high
    --["Havadarya"] = { position = {x = 109336, y = 0, z = -6364}, radius = 5000 },                               --25- Metric: X+00109336 Z-00006364   Small
    ["Bandar Abbas Intl"] = { position = {x = 115847, y = 0, z = 14156}, radius = 12000 },                       --26- Metric: X+00115847 Z+00014156   Medium
    ["Lar"] = { position = {x = 168884, y = 0, z = -182473}, radius = 8000 }                                  --27- Metric: X+00168884 Z-00182473   Medium
    --["Jiroft"] = { position = {x = 282634, y = 0, z = 141649}, radius = 10000 },                                --28- Metric: X+00282634 Z+00141649   Medium
    --["Shiraz Intl"] = { position = {x = 380994, y = 0, z = -351952}, radius = 20000 },                          --29- Metric: X+00380994 Z-00351952   high
    --["Kerman"] = { position = {x = 454327, y = 0, z = 71866}, radius = 20000 }                                  --30- Metric: X+00454327 Z+00071866   high
}

-- Colores para el marcador
local coloresPorCoalicion = {
    [1] = { contorno = {255, 0, 0, 255}, relleno = {255, 0, 0, 60} },
    [2] = { contorno = {0, 0, 255, 255}, relleno = {0, 0, 255, 60} },
    [0] = { contorno = {255, 255, 255, 255}, relleno = {255, 255, 255, 60} }
}

coalicionPorBase = coalicionPorBase or {}
controlAeropuertos = controlAeropuertos or {}  -- << Variable global accesible
local marcadores = {}

-- Función para actualizar marcador y bandera
local function actualizarMarcador(nombre, posicion, radio, nuevaCoalicion)
    coalicionPorBase[nombre] = nuevaCoalicion
    controlAeropuertos[nombre] = nuevaCoalicion  -- << Actualiza variable global

    local valor = (nuevaCoalicion == 2 and 1) or (nuevaCoalicion == 0 and 2) or 3
    local info = estadoBanderasAeropuertos[nombre]

    if info and info.valor ~= valor then
        info.valor = valor
        trigger.action.setUserFlag(info.bandera, valor)

        local banderaLeida = trigger.misc.getUserFlag(info.bandera)
        local nombreCoalicion = (valor == 1 and "AZUL") or (valor == 2 and "NEUTRAL") or "ROJO"
        local mensaje = nombre .. " → (Bandera: " .. info.bandera .. ", Valor: " .. valor .. ") - " .. nombreCoalicion .. " | Leído: " .. banderaLeida

        trigger.action.outText(mensaje, 10)
        env.info("[DEBUG BANDERA] " .. mensaje)
    end

    if marcadores[nombre] then
        mist.marker.remove(marcadores[nombre])
    end

    local colorSet = coloresPorCoalicion[nuevaCoalicion] or coloresPorCoalicion[0]

    marcadores[nombre] = mist.marker.add({
        name = "Marker_" .. nombre,
        type = "circle",
        point = posicion,
        radius = radio,
        color = colorSet.contorno,
        fillColor = colorSet.relleno,
        lineType = 2,
        visible = true,
        coalition = 0,
        life = 99999,
        message = nombre,
        fontSize = 14
    })
end

-- Función de verificación global
local function verificarControlAeropuertos()
    local basesAzules = coalition.getAirbases(2)
    local basesRojas  = coalition.getAirbases(1)

    for nombre, data in pairs(aeropuertos) do
        local estaAzul, estaRojo = false, false

        for _, base in ipairs(basesAzules) do
            if base:getName() == nombre then estaAzul = true break end
        end
        for _, base in ipairs(basesRojas) do
            if base:getName() == nombre then estaRojo = true break end
        end

        local coalicion = 0
        if estaAzul then coalicion = 2
        elseif estaRojo then coalicion = 1 end

        actualizarMarcador(nombre, data.position, data.radius, coalicion)
    end

    if debugActivo then
        trigger.action.outText("Resumen banderas activas:", 10)
        for nombre, info in pairs(estadoBanderasAeropuertos) do
            if info.valor then
                local msg = nombre .. " → (Bandera: " .. info.bandera .. ", Valor: " .. info.valor .. ")"
                trigger.action.outText(msg, 10)
                env.info(msg)
            end
        end
    end
end

-- Iniciar verificación cíclica
timer.scheduleFunction(function()
    verificarControlAeropuertos()
    return timer.getTime() + 10
end, {}, timer.getTime() + 1)

