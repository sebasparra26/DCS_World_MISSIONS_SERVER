puntosCoalicion = { PuntosAZUL = 50, PuntosROJO = 0 }
menuCooldowns = menuCooldowns or {}
activeDeliveries = activeDeliveries or {}
tipoAviones = tipoAviones or {}
menuRoot = nil

nombresPosibles = {}
for i = 1, 9999 do
    table.insert(nombresPosibles, "USA air " .. i)
end

local cooldownTiempo = 600  -- en segundos

local plantillasLogistica = {
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

local recargoAeropuerto = {
    ["Ford"] = 1.0, ["Friston"] = 1.1, ["Maupertus"] = 1.2, ["Brucheville"] = 1.3,
    ["Carpiquet"] = 1.4, ["Ronai"] = 1.5, ["Bernay Saint Martin"] = 1.6, ["Barville"] = 1.7,
    ["Evreux"] = 1.8, ["Orly"] = 1.9, ["Fecamp-Benouville"] = 2.0, ["Saint-Aubin"] = 2.1,
    ["Beauvais-Tille"] = 2.2, ["Amiens-Glisy"] = 2.3, ["Abbeville Drucat"] = 2.4
}

local multiplicadorTiempo = {
    ["Ford"] = 1.1, ["Friston"] = 1.0, ["Maupertus"] = 1.3, ["Brucheville"] = 1.2,
    ["Carpiquet"] = 1.25, ["Ronai"] = 1.4, ["Bernay Saint Martin"] = 1.35,
    ["Barville"] = 1.3, ["Evreux"] = 1.45, ["Orly"] = 1.5, ["Fecamp-Benouville"] = 1.2,
    ["Saint-Aubin"] = 1.15, ["Beauvais-Tille"] = 1.3, ["Amiens-Glisy"] = 1.4,
    ["Abbeville Drucat"] = 1.35
}

local coordenadasAerodromos = {
    ["Ford"] = { x = 147466, z = -25753 }, ["Friston"] = { x = 143314, z = 28130 },
    ["Maupertus"] = { x = 16011, z = -84865 }, ["Brucheville"] = { x = -14865, z = -66032 },
    ["Carpiquet"] = { x = -34775, z = -9992 }, ["Ronai"] = { x = -73108, z = 12832 },
    ["Bernay Saint Martin"] = { x = -39530, z = 67036 }, ["Barville"] = { x = -39512, z = 67098 },
    ["Evreux"] = { x = -60606, z = 117326 }, ["Orly"] = { x = -73529, z = 200430 },
    ["Fecamp-Benouville"] = { x = 31004, z = 46274 }, ["Saint-Aubin"] = { x = 48979, z = 97582 },
    ["Beauvais-Tille"] = { x = 6070, z = 175169 }, ["Amiens-Glisy"] = { x = 53411, z = 191760 },
    ["Abbeville Drucat"] = { x = 81026, z = 150752 }
}

function cargarInventarioCompleto(nombreAeropuerto, data, claveTipo)
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

    local nombreAvion = claveTipo:upper()
    local mensaje = "Suministros entregados en " .. nombreAeropuerto .. ":\n\n"
    mensaje = mensaje .. "Avión " .. nombreAvion .. " x" .. totalAviones .. "\n"
    mensaje = mensaje .. table.concat(resumen, "\n")
    trigger.action.outText(mensaje, 15)
end

function ejecutarEntrega(aeropuerto, data, claveTipo)
    if trigger.misc.getUserFlag(data.bandera) ~= 1 then
        trigger.action.outText("El aeródromo " .. aeropuerto .. " no está disponible", 10)
        return
    end

    local cooldownKey = claveTipo .. "_" .. aeropuerto
    if menuCooldowns[cooldownKey] and timer.getTime() < menuCooldowns[cooldownKey] then
        trigger.action.outText("Ya solicitaste un envío a " .. aeropuerto .. ". Espera antes de volver a pedir.", 10)
        return
    end

    local baseCosto = tipoAviones[claveTipo].costo
    local recargo = recargoAeropuerto[aeropuerto] or 1.0
    local costo = math.floor(baseCosto * recargo)

    if puntosCoalicion["PuntosAZUL"] < costo then
        trigger.action.outText("No tienes suficientes puntos. Requiere: $" .. costo, 10)
        return
    end

    local origen = { x = 202611, z = 7004 }
    local destino = coordenadasAerodromos[aeropuerto] or { x = 0, z = 0 }
    local dx, dz = destino.x - origen.x, destino.z - origen.z
    local distancia = math.sqrt(dx * dx + dz * dz)
    local velocidad = 138.88
    local multTiempo = multiplicadorTiempo[aeropuerto] or 1.0
    local tiempoEst = math.floor((distancia / velocidad) * multTiempo)
    local minutos, segundos = math.floor(tiempoEst / 60), tiempoEst % 60

    trigger.action.outText("Compra confirmada. Enviando suministros a " .. aeropuerto, 10)
    trigger.action.outText(string.format("Tiempo estimado de llegada: %d min %d seg", minutos, segundos), 10)

    local nombresAntes = {}
    for _, nombre in ipairs(nombresPosibles) do
        if Group.getByName(nombre) and Group.getByName(nombre):isExist() then
            nombresAntes[nombre] = true
        end
    end

    mist.cloneGroup(data.template, true)

    timer.scheduleFunction(function()
        local grupoNuevo
        for _, nombre in ipairs(nombresPosibles) do
            if Group.getByName(nombre) and Group.getByName(nombre):isExist() and not nombresAntes[nombre] then
                grupoNuevo = nombre
                break
            end
        end

        if grupoNuevo then
            activeDeliveries[grupoNuevo] = {
                destino = aeropuerto,
                plantilla = data.template,
                entregado = false,
                inventario = claveTipo,
                altMax = 0
            }
            puntosCoalicion["PuntosAZUL"] = puntosCoalicion["PuntosAZUL"] - costo
            menuCooldowns[cooldownKey] = timer.getTime() + cooldownTiempo
            trigger.action.outText("Suministros en camino a " .. aeropuerto .. " (grupo: " .. grupoNuevo .. ")", 10)
        else
            trigger.action.outText("Error: no se detectó el grupo clonado", 10)
        end
    end, {}, timer.getTime() + 1)
end

local function verificarAterrizajes()
    for nombreGrupo, info in pairs(activeDeliveries) do
        if not info.entregado then
            local grupo = Group.getByName(nombreGrupo)
            if grupo and Group.isExist(grupo) then
                local unidad = grupo:getUnit(1)
                if unidad then
                    local alt = unidad:getPoint().y
                    info.altMax = math.max(info.altMax or 0, alt)

                    local v = unidad:getVelocity()
                    local speed = math.sqrt(v.x^2 + v.z^2)

                    if (info.altMax >= 914.4) and (speed < 0.5) then
                        local destino = info.destino
                        local inventario = info.inventario
                        if tipoAviones[inventario] then
                            trigger.action.outText("Avión detenido. Entregando suministros en " .. destino, 10)
                            cargarInventarioCompleto(destino, tipoAviones[inventario], inventario)
                            info.entregado = true
                        else
                            trigger.action.outText("Error: inventario no encontrado", 10)
                        end
                    end
                end
            end
        end
    end
    timer.scheduleFunction(verificarAterrizajes, {}, timer.getTime() + 5)
end

verificarAterrizajes()
