puntosCoalicion = { PuntosAZUL = 500000, PuntosROJO = 0 }
menuCooldownsB = menuCooldownsB or {}
activeDeliveriesB = activeDeliveriesB or {}
tipoAviones = tipoAviones or {}
nombresPosiblesB = {}



for i = 1, 9999 do table.insert(nombresPosiblesB, "USA air " .. i) end

local cooldownTiempo = 10 -- segundos

plantillasLogisticaB = {
    ["Ford"] = { template = "Supplies_C-47ToFord", bandera = 101 },
    ["Friston"] = { template = "Supplies_MosquitoToFriston", bandera = 102 },
    ["Maupertus"] = { template = "Supplies_C-47ToMaupertus", bandera = 103 },
    ["Brucheville"] = { template = "Supplies_MosquitoToBrucheville", bandera = 104 },
    ["Carpiquet"] = { template = "Supplies_MosquitoToCarpiquet", bandera = 105 },
    ["Ronai"] = { template = "Supplies_C-47ToRonai", bandera = 106 },
    ["Bernay Saint Martin"] = { template = "Supplies_C-47ToBernay", bandera = 107 },
    ["Barville"] = { template = "Supplies_C-47ToBarville", bandera = 108 },
    ["Evreux"] = { template = "Supplies_C-47ToEvreux", bandera = 109 },
    ["Orly"] = { template = "Supplies_C-47ToOrly", bandera = 110 },
    ["Fecamp-Benouville"] = { template = "Supplies_C-47ToFecamp-Benouville", bandera = 111 },
    ["Saint-Aubin"] = { template = "Supplies_MosquitoToSaint-Aubin", bandera = 112 },
    ["Beauvais-Tille"] = { template = "Supplies_MosquitoToBeauvais-Tille", bandera = 113 },
    ["Amiens-Glisy"] = { template = "Supplies_MosquitoToAmiens-Glisy", bandera = 114 },
    ["Abbeville Drucat"] = { template = "Supplies_MosquitoToAbbeville", bandera = 115 }
}

recargoAeropuertoB = {
    ["Ford"] = 1.0, ["Friston"] = 1.1, ["Maupertus"] = 1.2, ["Brucheville"] = 1.3,
    ["Carpiquet"] = 1.4, ["Ronai"] = 1.5, ["Bernay Saint Martin"] = 1.6, ["Barville"] = 1.7,
    ["Evreux"] = 1.8, ["Orly"] = 1.9, ["Fecamp-Benouville"] = 2.0, ["Saint-Aubin"] = 2.1,
    ["Beauvais-Tille"] = 2.2, ["Amiens-Glisy"] = 2.3, ["Abbeville Drucat"] = 2.4
}

multiplicadorTiempoB = {
    ["Ford"] = 1.1, ["Friston"] = 1.0, ["Maupertus"] = 1.3, ["Brucheville"] = 1.2,
    ["Carpiquet"] = 1.25, ["Ronai"] = 1.4, ["Bernay Saint Martin"] = 1.35,
    ["Barville"] = 1.3, ["Evreux"] = 1.45, ["Orly"] = 1.5, ["Fecamp-Benouville"] = 1.2,
    ["Saint-Aubin"] = 1.15, ["Beauvais-Tille"] = 1.3, ["Amiens-Glisy"] = 1.4,
    ["Abbeville Drucat"] = 1.35
}

coordenadasAerodromosB = {
    ["Ford"] = { x = 147466, z = -25753 }, ["Friston"] = { x = 143314, z = 28130 },
    ["Maupertus"] = { x = 16011, z = -84865 }, ["Brucheville"] = { x = -14865, z = -66032 },
    ["Carpiquet"] = { x = -34775, z = -9992 }, ["Ronai"] = { x = -73108, z = 12832 },
    ["Bernay Saint Martin"] = { x = -39530, z = 67036 }, ["Barville"] = { x = -39512, z = 67098 },
    ["Evreux"] = { x = -60606, z = 117326 }, ["Orly"] = { x = -73529, z = 200430 },
    ["Fecamp-Benouville"] = { x = 31004, z = 46274 }, ["Saint-Aubin"] = { x = 48979, z = 97582 },
    ["Beauvais-Tille"] = { x = 6070, z = 175169 }, ["Amiens-Glisy"] = { x = 53411, z = 191760 },
    ["Abbeville Drucat"] = { x = 81026, z = 150752 }
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
    trigger.action.outText(mensaje, 15)
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

function verificarAterrizajes()
    for nombreGrupo, info in pairs(activeDeliveriesB) do
        if not info.entregado then
            local grupo = Group.getByName(nombreGrupo)
            if grupo and Group.isExist(grupo) then
                local unidad = grupo:getUnit(1)
                if unidad then
                    local alt = unidad:getPoint().y
                    info.altMax = math.max(info.altMax or 0, alt)
                    local v = unidad:getVelocity()
                    local speed = math.sqrt(v.x^2 + v.z^2)

                    if info.altMax >= 914.4 and speed < 0.5 then
                        cargarInventarioCompletoB(info.destino, tipoAviones[info.inventario])
                        info.entregado = true
                    end
                end
            end
        end
    end
    timer.scheduleFunction(verificarAterrizajes, {}, timer.getTime() + 5)
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

function mostrarResumenRutas()
    local mensaje = "Rutas activas Logistica:\n"
    local hay = false

    for nombreGrupo, datos in pairs(activeDeliveriesB) do
        if not datos.entregado then
            local grupo = Group.getByName(nombreGrupo)
            if grupo and Group.isExist(grupo) then
                if estaEnZonaRutas(nombreGrupo) then
                    local nombrePedido = nombresSubvariantes[datos.inventario] or datos.inventario
                    mensaje = mensaje .. "Ruta " .. nombreGrupo .. " lleva: " .. nombrePedido .. " hacia " .. datos.destino .. "\n"
                    hay = true
                end
            else
                mensaje = mensaje .. "Ruta " .. nombreGrupo .. " ha sido destruida antes de completar la entrega.\n"
                datos.entregado = true  -- marcar como inactivo
            end
        end
    end

    if not hay then
        mensaje = mensaje .. "\n(No hay rutas activas dentro de la zona en este momento)"
    end

    trigger.action.outTextForCoalition(2, mensaje, 10)
    timer.scheduleFunction(mostrarResumenRutas, {}, timer.getTime() + intervaloResumenRutas)
end



mostrarResumenRutas()

verificarAterrizajes()