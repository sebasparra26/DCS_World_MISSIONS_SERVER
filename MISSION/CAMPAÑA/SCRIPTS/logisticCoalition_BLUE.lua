puntosCoalicion = { PuntosAZUL = 500000, PuntosROJO = 500000 }
menuCooldownsB = menuCooldownsB or {}
activeDeliveriesB = activeDeliveriesB or {}
tipoAviones = tipoAviones or {}
nombresPosiblesB = {}



nombresPosiblesB = {}

for i = 1, 9999 do
    table.insert(nombresPosiblesB, "USA air " .. i)
    table.insert(nombresPosiblesB, "USA hel " .. i)
end

local cooldownTiempo = 10 -- segundos

plantillasLogisticaB = {
    ["Liwa AFB"] = { template = "SuppliesBLUEToliwa", bandera = 100 },
    ["Al Dhafra AFB"] = { template = "SuppliesBLUEToDhafra", bandera = 101 },
    ["Al-Bateen"] = { template = "SuppliesBLUEToBateen", bandera = 102 },
    ["Sas Al Nakheel"] = { template = "SuppliesBLUEToNakheel", bandera = 103 },
    ["Abu Dhabi Intl"] = { template = "SuppliesBLUEToDhabi", bandera = 104 },
    ["Al Ain Intl"] = { template = "SuppliesBLUEToAin", bandera = 105 },
    ["Al Maktoum Intl"] = { template = "SuppliesBLUEToMaktoum", bandera = 106 },
    ["Al Minhad AFB"] = { template = "SuppliesBLUEToMinhad", bandera = 107 },
    ["Dubai Intl"] = { template = "SuppliesBLUEToDubai", bandera = 108 },
    ["Sharjah Intl"] = { template = "SuppliesBLUEToSharjah", bandera = 109 },
    ["Fujairah intl"] = { template = "SuppliesBLUEToFujairah", bandera = 110 },
    ["Ras Al Khaimah Intl"] = { template = "SuppliesBLUEToKhaimah", bandera = 111 },
    ["Khasab"] = { template = "SuppliesBLUEToKhasab", bandera = 112 },
    ["Bandar-e-Jask"] = { template = "SuppliesBLUEToJask", bandera = 113 },
    ["Sir Abu Nauyr"] = { template = "SuppliesBLUEToNauyr", bandera = 114 },
    ["Abu Musa Island"] = { template = "SuppliesBLUEToAbuMusa", bandera = 115 },
    ["Sirri Island"] = { template = "SuppliesBLUEToSirri", bandera = 116 },
    ["Tunb Kochak"] = { template = "SuppliesBLUEToKochak", bandera = 117 },
    ["Tunb Island AFB"] = { template = "SuppliesBLUEToTunbIsland", bandera = 118 },
    ["Bandar Lengeh"] = { template = "SuppliesBLUEToLenge", bandera = 119 },
    ["Kish Intl"] = { template = "SuppliesBLUEToKish", bandera = 120 },
    ["Lavan Island"] = { template = "SuppliesBLUEToLavan", bandera = 121 },
    ["Qeshm Island"] = { template = "SuppliesBLUEToQeshm", bandera = 122},
    ["Havadarya"] = { template = "SuppliesBLUEToHavadarya", bandera = 123 },
    ["Bandar Abbas intl"] = { template = "SuppliesBLUEToAbbas", bandera = 124 },
    ["Lar"] = { template = "SuppliesBLUEToLar", bandera = 125 },
    ["Jiroft"] = { template = "SuppliesBLUEToJiroft", bandera = 126 },
    ["Shiraz Intl"] = { template = "SuppliesBLUEToShiraz", bandera = 127 },
    ["Kerman"] = { template = "SuppliesBLUEToKerman", bandera = 128 }
}

recargoAeropuertoB = {
    ["Liwa AFB"] = 1.0,
    ["Al Dhafra AFB"] = 1.0,
    ["Al-Bateen"] = 1.0,
    ["Sas Al Nakheel"] = 1.0,
    ["Abu Dhabi Intl"] = 1.0,
    ["Al Ain Intl"] = 1.0,
    ["Al Maktoum Intl"] = 1.0,
    ["Al Minhad AFB"] = 1.0,
    ["Dubai Intl"] = 1.0,
    ["Sharjah Intl"] = 1.0,
    ["Fujairah intl"] = 1.0,
    ["Ras Al Khaimah Intl"] = 1.0,
    ["Khasab"] = 1.0,
    ["Bandar-e-Jask"] = 1.0,
    ["Sir Abu Nauyr"] = 1.0,
    ["Abu Musa Island"] = 1.0,
    ["Sirri Island"] = 1.0,
    ["Tunb Kochak"] = 1.0,
    ["Tunb Island AFB"] = 1.0,
    ["Bandar Lengeh"] = 1.0,
    ["Kish Intl"] = 1.0,
    ["Lavan Island"] = 1.0,
    ["Qeshm Island"] = 1.0,
    ["Havadarya"] = 1.0,
    ["Bandar Abbas intl"] = 1.0,
    ["Lar"] = 1.0,
    ["Jiroft"] = 1.0,
    ["Shiraz Intl"] = 1.0,
    ["Kerman"] = 1.0
}

multiplicadorTiempoB = {
    ["Liwa AFB"] = 1.0,
    ["Al Dhafra AFB"] = 1.0,
    ["Al-Bateen"] = 1.0,
    ["Sas Al Nakheel"] = 1.0,
    ["Abu Dhabi Intl"] = 1.0,
    ["Al Ain Intl"] = 1.0,
    ["Al Maktoum Intl"] = 1.0,
    ["Al Minhad AFB"] = 1.0,
    ["Dubai Intl"] = 1.0,
    ["Sharjah Intl"] = 1.0,
    ["Fujairah intl"] = 1.0,
    ["Ras Al Khaimah Intl"] = 1.0,
    ["Khasab"] = 1.0,
    ["Bandar-e-Jask"] = 1.0,
    ["Sir Abu Nauyr"] = 1.0,
    ["Abu Musa Island"] = 1.0,
    ["Sirri Island"] = 1.0,
    ["Tunb Kochak"] = 1.0,
    ["Tunb Island AFB"] = 1.0,
    ["Bandar Lengeh"] = 1.0,
    ["Kish Intl"] = 1.0,
    ["Lavan Island"] = 1.0,
    ["Qeshm Island"] = 1.0,
    ["Havadarya"] = 1.0,
    ["Bandar Abbas intl"] = 1.0,
    ["Lar"] = 1.0,
    ["Jiroft"] = 1.0,
    ["Shiraz Intl"] = 1.0,
    ["Kerman"] = 1.0
}

coordenadasAerodromosB = {
    ["Liwa AFB"] = {x = -275733, y = 0, z = -248186},                            --1-- Metric: X-00275733 Z-00248186    high
    ["Al Dhafra AFB"] = {x = -211657, y = 0, z = -173058},                      --2-- Metric: X-00211657 Z-00173058    High
    ["Al-Bateen"] = {x = -190948, y = 0, z = -181927},                            --3-- Metric: X-00190948 Z-00181927    Medium
    ["Sas Al Nakheel"] = {x = -189610, y = 0, z = -175974},                       --4-- Metric: X-00189610 Z-00175974    Medium
    ["Abu Dhabi Intl"] = {x = -189658, y = 0, z = -162399},                    --5-- Metric: X-00189658 Z-00162399    high
    ["Al Ain Intl"] = {x = -211063, y = 0, z = -65171},                          --6-- Metric: X-00211063 Z-00065171    high
    ["Al Maktoum Intl"] = {x = -140840, y = 0, z = -109920},                    --7-- Metric: X-00140840 Z-00109920    high
    ["Al Minhad AFB"] = {x = -126104, y = 0, z = -89108},                      --8-- Metric: X-00126104 Z-00089108    high
    ["Dubai Intl"] = {x = -100874, y = 0, z = -88902},                        --9-- Metric: X-00100874 Z-00088902    high
    ["Sharjah Intl"] = {x = -92768, y = 0, z = -73636},                          --10-- Metric: X-00092768 Z-00073636   high
    ["Fujairah intl"] = {x = -117483, y = 0, z = 7840},                        --11-- Metric: X-00117483 Z+00007840   high
    ["Ras Al Khaimah Intl"] = {x = -61632, y = 0, z = -30809},                   --12-- Metric: X-00061632 Z-00030809   high
    ["Khasab"] = {x = -152, y = 0, z = -164},                                --13-- Metric: X-00000152 Z-00000164   Medium
    ["Bandar-e-Jask"] = {x = -57219, y = 0, z = 156064},                    --14-- Metric: X-00057219 Z+00156064   Medium
    ["Sir Abu Nauyr"] = {x = -103098, y = 0, z = -202998},                        --16-- Metric: X-00103098 Z-00202998   Small
    ["Abu Musa Island"] = {x = -31498, y = 0, z = -121336},                      --17-- Metric: X-00031498 Z-00121336   Small
    ["Sirri Island"] = {x = -26948, y = 0, z = -170744},                         --18-- Metric: X-00026948 Z-00170744   Small
    ["Tunb Kochak"] = {x = 9023, y = 0, z = -109467},                           --19-- Metric: X+00009023 Z-00109467   Small
    ["Tunb Island AFB"] = {x = 10630, y = 0, z = -92388},                       --20-- Metric: X+00010630 Z-00092388   Small
    ["Bandar Lengeh"] = {x = 41538, y = 0, z = -140953},                        --21-- Metric: X+00041538 Z-00140953   Small
    ["Kish Intl"] = {x = 42782, y = 0, z = -225092},                         --22-- Metric: X+00042782 Z-00225092   Medium
    ["Lavan Island"] = {x = 75789, y = 0, z = -286794},                          --23-- X+00075789 Z-00286794   Small
    ["Qeshm Island"] = {x = 64762, y = 0, z = -33452},                         --24- Metric: X+00064762 Z-00033452   high
    ["Havadarya"] = {x = 109336, y = 0, z = -6364},                          --25- Metric: X+00109336 Z-00006364   Small
    ["Bandar Abbas intl"] = {x = 115847, y = 0, z = 14156},                      --26- Metric: X+00115847 Z+00014156   Medium
    ["Lar"] = {x = 168884, y = 0, z = -182473},                              --27- Metric: X+00168884 Z-00182473   Medium
    ["Jiroft"] = {x = 282634, y = 0, z = 141649},                            --28- Metric: X+00282634 Z+00141649   Medium
    ["Shiraz Intl"] = {x = 380994, y = 0, z = -351952},                         --29- Metric: X+00380994 Z-00351952   high
    ["Kerman"] = {x = 454327, y = 0, z = 71866}   
}

function cargarInventarioCompletoB(nombreAeropuerto, data)
    local base = Airbase.getByName(nombreAeropuerto)
    if not base then return end
    local warehouse = base:getWarehouse()
    if not warehouse then return end

    local resumen, totalAviones = {}, 0
    if data.avion then
        Warehouse.addItem(warehouse, data.avion.ws, data.avion.cantidad)
        totalAviones = data.avion.cantidad
    end

    local function cargarSeccion(seccion, nombre)
        for tipo, item in pairs(seccion or {}) do
            Warehouse.addItem(warehouse, item.ws, item.cantidad)
            table.insert(resumen, nombre .. ": " .. tipo .. " x" .. item.cantidad)
        end
    end

    cargarSeccion(data.bombas, "BOMBA")
    cargarSeccion(data.cohetes, "COHETE")
    cargarSeccion(data.tanques, "TANQUE")
    cargarSeccion(data.misiles, "MISIL")
    cargarSeccion(data.misc, "MISCELANEO")

    local mensaje = "Suministros entregados en " .. nombreAeropuerto .. ":\n\n"
    mensaje = mensaje .. (data.nombreAvion or "Avión") .. " x" .. totalAviones .. "\n"
    mensaje = mensaje .. table.concat(resumen, "\n")
    trigger.action.outText(mensaje, 30)
end

function ejecutarEntregaB(aeropuerto, data, tipoAvion)
    if trigger.misc.getUserFlag(data.bandera) ~= 1 then
        trigger.action.outTextForCoalition(2, "Aeródromo no disponible: " .. aeropuerto, 10)
        return
    end

    if menuCooldownsB[aeropuerto] and timer.getTime() < menuCooldownsB[aeropuerto] then
        trigger.action.outTextForCoalition(2, "Ya pediste a " .. aeropuerto .. ", espera el cooldown.", 10)
        return
    end

    local tipo = tipoAvion or "p51d25na"
    local baseCosto = tipoAviones[tipo].costo
    local recargo = recargoAeropuertoB[aeropuerto] or 1
    local costo = math.floor(baseCosto * recargo)

    if puntosCoalicion.PuntosAZUL < costo then
        trigger.action.outTextForCoalition(2, "No tienes suficientes dólares. Requiere: " .. formatearDolares(costo), 10)
        return
    end

    local origen = { x = 202611, z = 7004 }
    local destino = coordenadasAerodromosB[aeropuerto] or { x = 0, z = 0 }
    local dx, dz = destino.x - origen.x, destino.z - origen.z
    local distancia = math.sqrt(dx * dx + dz * dz)
    local velocidad = 138.88
    local tiempoEst = math.floor((distancia / velocidad) * (multiplicadorTiempoB[aeropuerto] or 1))
    local minutos, segundos = math.floor(tiempoEst / 60), tiempoEst % 60

    trigger.action.outTextForCoalition(2, "Compra confirmada. Enviando a " .. aeropuerto, 10)
    trigger.action.outTextForCoalition(2, "Llegada estimada: " .. minutos .. " min " .. segundos .. " seg", 10)

    local nombresAntes = {}
    for _, nombre in ipairs(nombresPosiblesB) do
        if Group.getByName(nombre) and Group.getByName(nombre):isExist() then
            nombresAntes[nombre] = true
        end
    end

    mist.cloneGroup(data.template, true)

    timer.scheduleFunction(function()
        local grupoNuevo
        for _, nombre in ipairs(nombresPosiblesB) do
            if Group.getByName(nombre) and Group.getByName(nombre):isExist() and not nombresAntes[nombre] then
                grupoNuevo = nombre
                break
            end
        end

        if grupoNuevo then
            activeDeliveriesB[grupoNuevo] = {
                destino = aeropuerto,
                plantilla = data.template,
                entregado = false,
                inventario = tipo,
                altMax = 0
            }
            puntosCoalicion.PuntosAZUL = puntosCoalicion.PuntosAZUL - costo
            menuCooldownsB[aeropuerto] = timer.getTime() + cooldownTiempo
        end
    end, {}, timer.getTime() + 1)
end

function cargarInventarioCompletoB(nombreAeropuerto, data)
    local base = Airbase.getByName(nombreAeropuerto)
    if not base then return end
    local warehouse = base:getWarehouse()
    if not warehouse then return end

    local resumen, totalAviones = {}, 0
    if data.avion then
        Warehouse.addItem(warehouse, data.avion.ws, data.avion.cantidad)
        totalAviones = data.avion.cantidad
    end

    local function cargarSeccion(seccion, nombre)
        for tipo, item in pairs(seccion or {}) do
            Warehouse.addItem(warehouse, item.ws, item.cantidad)
            table.insert(resumen, nombre .. ": " .. tipo .. " x" .. item.cantidad)
        end
    end

    cargarSeccion(data.bombas, "BOMBA")
    cargarSeccion(data.cohetes, "COHETE")
    cargarSeccion(data.tanques, "TANQUE")
    cargarSeccion(data.misiles, "MISIL")
    cargarSeccion(data.misc, "MISCELANEO")

    local mensaje = "Suministros entregados en " .. nombreAeropuerto .. ":\n\n"
    mensaje = mensaje .. (data.nombreAvion or "Avión") .. " x" .. totalAviones .. "\n"
    mensaje = mensaje .. table.concat(resumen, "\n")
    trigger.action.outTextForCoalition(2, mensaje, 15)
end

function verificarAterrizajesB()
    for nombreGrupo, info in pairs(activeDeliveriesB) do
        if not info.entregado then
            local grupo = Group.getByName(nombreGrupo)
            if grupo and Group.isExist(grupo) then
                local unidad = grupo:getUnit(1)
                if unidad then
                    local punto = unidad:getPoint()
                    local alturaTerreno = land.getHeight({ x = punto.x, y = punto.z })
                    local altAGL = punto.y - alturaTerreno
                    info.altMax = math.max(info.altMax or 0, altAGL)

                    -- Mostrar AGL en pantalla cada 5 segundos
                    trigger.action.outText("Grupo " .. nombreGrupo .. " AGL: " .. math.floor(altAGL) .. " m", 5)

                    local v = unidad:getVelocity()
                    local speed = math.sqrt(v.x^2 + v.z^2)

                    if info.altMax >= 100 and speed < 0.5 then
                        cargarInventarioCompletoB(info.destino, tipoAviones[info.inventario])
                        info.entregado = true

                        -- Programar destrucción del grupo 30 segundos después
                        timer.scheduleFunction(function()
                            local grupoParaEliminar = Group.getByName(nombreGrupo)
                            if grupoParaEliminar and grupoParaEliminar:isExist() then
                                grupoParaEliminar:destroy()
                            end
                        end, {}, timer.getTime() + 30)
                    end
                end
            end
        end
    end
    timer.scheduleFunction(verificarAterrizajesB, {}, timer.getTime() + 5)
end


-- Intervalo de tiempo entre resúmenes (en segundos)
local intervaloResumenRutas = 30

-- Tabla inversa para traducir clave de subvariante al nombre legible
local nombresSubvariantes = {}
for _, subtabla in pairs(subvariantesAvion or {}) do
    for nombreVisible, claveInterna in pairs(subtabla) do
        nombresSubvariantes[claveInterna] = nombreVisible
    end
end

-- Función para verificar si un grupo está dentro de la zona "Rutas"
local function estaEnZonaRutas(nombreGrupo)
    local zona = trigger.misc.getZone("Rutas")
    if not zona then return false end

    local grupo = Group.getByName(nombreGrupo)
    if not grupo or not Group.isExist(grupo) then return false end

    local unidad = grupo:getUnit(1)
    if not unidad then return false end

    local pos = unidad:getPoint()
    local dx = pos.x - zona.point.x
    local dz = pos.z - zona.point.z

    return math.sqrt(dx * dx + dz * dz) <= zona.radius
end

-- Tabla local para obtener nombres legibles de subvariantes
local nombresSubvariantes = {

    --FA-18C_hornet--
    ["FA-18C_hornet_AA"] = "FA-18C_hornet_AA",
    ["FA-18C_hornet_AG"] = "FA-18C_hornet_AG"
}

function mostrarResumenRutasB()
    local mensaje = "Rutas activas Logistica:\n"
    local hay = false

    for nombreGrupo, datos in pairs(activeDeliveriesB) do
        if not datos.entregado then
            local grupo = Group.getByName(nombreGrupo)
            if grupo and Group.isExist(grupo) then
                if estaEnZonaRutas(nombreGrupo) then
                    local nombreVisible = nombresSubvariantes[datos.inventario] or datos.inventario
                    mensaje = mensaje .. "Ruta " .. nombreGrupo .. " (" .. nombreVisible .. ") va hacia " .. datos.destino .. "\n"
                    hay = true
                end
            else
                mensaje = mensaje .. "Ruta " .. nombreGrupo .. " ha sido destruida antes de completar la entrega.\n"
                datos.entregado = true
            end
        end
    end

    if not hay then
        mensaje = mensaje .. "\n(No hay rutas activas dentro de la zona en este momento)"
    end

    trigger.action.outTextForCoalition(2, mensaje, 10)
    timer.scheduleFunction(mostrarResumenRutasB, {}, timer.getTime() + intervaloResumenRutas)
end



mostrarResumenRutasB()

verificarAterrizajesB()