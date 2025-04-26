---------------------------BAZTIAN---------------------------------------------------------------------------


puntosCoalicion = { PuntosAZUL = 2000000000, PuntosROJO = 2000000000 }
configuracionEntregaR = configuracionEntregaR or {
    origen = { x = -189594, y = 0, z = -176119 },
    velocidad = 138.88
}
menuCooldownsR = menuCooldownsR or {}
activeDeliveriesR = activeDeliveriesR or {}
tipoAviones = tipoAviones or {}



local cooldownTiempo = 300 -- segundos

function formatearDolaresR(numero)
    if type(numero) ~= "number" then return "$0" end
    local entero = math.floor(numero)
    local partes = {}
    repeat
        table.insert(partes, 1, string.format("%03d", entero % 1000))
        entero = math.floor(entero / 1000)
    until entero == 0
    partes[1] = tostring(tonumber(partes[1])) -- elimina ceros a la izquierda
    return "$" .. table.concat(partes, ".")
end

function cargarInventarioCompletoR(nombreAeropuerto, data)
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

function ejecutarEntregaR(aeropuerto, data, tipoAvion)
    if trigger.misc.getUserFlag(data.bandera) ~= 3 then
        trigger.action.outTextForCoalition(1, "Aeródromo no disponible: " .. aeropuerto, 10)
        return
    end

    if menuCooldownsR[aeropuerto] and timer.getTime() < menuCooldownsR[aeropuerto] then
        trigger.action.outTextForCoalition(1, "Ya pediste a este " .. aeropuerto .. ", espera 5 Minutos antes de volver a Comprar.", 10)
        return
    end

    local tipo = tipoAvion or "p51d25na"
    local baseCosto = tipoAviones[tipo].costo
    local recargo = recargoAeropuertoR[aeropuerto] or 1
    local costo = math.floor(baseCosto * recargo)

    if puntosCoalicion.PuntosROJO < costo then
        trigger.action.outTextForCoalition(1, "No tienes suficientes dólares. Requiere: " .. formatearDolaresR(costo), 10)
        return
    end

    local origen = { x = configuracionEntregaR.origen.x, y = configuracionEntregaR.origen.y, z = configuracionEntregaR.origen.z }
    local destino = coordenadasAerodromosR[aeropuerto] or { x = 0, z = 0 }
    local dx, dz = destino.x - origen.x, destino.z - origen.z
    local distancia = math.sqrt(dx * dx + dz * dz)
    local velocidad = configuracionEntregaR.velocidad -----------------------EN DO SCRIPT PRECARGADO
    local tiempoEst = math.floor((distancia / velocidad) * (multiplicadorTiempoR[aeropuerto] or 1))
    local minutos, segundos = math.floor(tiempoEst / 60), tiempoEst % 60

    trigger.action.outTextForCoalition(1, "Compra confirmada. Enviando a " .. aeropuerto, 10)
    trigger.action.outTextForCoalition(1, "Llegada estimada: " .. minutos .. " min " .. segundos .. " seg", 20)

    local nombresAntes = {}
    for _, nombre in ipairs(nombresPosiblesR) do
        if Group.getByName(nombre) and Group.getByName(nombre):isExist() then
            nombresAntes[nombre] = true
        end
    end

    mist.cloneGroup(data.template, true)

    timer.scheduleFunction(function()
        local grupoNuevo
        for _, nombre in ipairs(nombresPosiblesR) do
            if Group.getByName(nombre) and Group.getByName(nombre):isExist() and not nombresAntes[nombre] then
                grupoNuevo = nombre
                break
            end
        end

        if grupoNuevo then
            activeDeliveriesR[grupoNuevo] = {
                destino = aeropuerto,
                plantilla = data.template,
                entregado = false,
                inventario = tipo,
                altMax = 0
            }
            puntosCoalicion.PuntosROJO = puntosCoalicion.PuntosROJO - costo
            menuCooldownsR[aeropuerto] = timer.getTime() + cooldownTiempo
        end
    end, {}, timer.getTime() + 1)
end

function cargarInventarioCompletoR(nombreAeropuerto, data)
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
    trigger.action.outTextForCoalition(1, mensaje, 30)
end

function verificarAterrizajesR()
    for nombreGrupo, info in pairs(activeDeliveriesR) do
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

                    --trigger.action.outText("Grupo " .. nombreGrupo .. " AGL: " .. math.floor(altAGL) .. " m", 5)

                    local v = unidad:getVelocity()
                    local speed = math.sqrt(v.x^2 + v.z^2)

                    if info.altMax >= 100 and speed < 0.5 then
                        cargarInventarioCompletoR(info.destino, tipoAviones[info.inventario])
                        info.entregado = true

                        -- Programar destrucción del grupo 30 segundos después
                        timer.scheduleFunction(function()
                            local grupoParaEliminar = Group.getByName(nombreGrupo)
                            if grupoParaEliminar and grupoParaEliminar:isExist() then
                                grupoParaEliminar:destroy()
                            end
                        end, {}, timer.getTime() + 120)
                    end
                end
            end
        end
    end
    timer.scheduleFunction(verificarAterrizajesR, {}, timer.getTime() + 5)
end

-- Intervalo de tiempo entre resúmenes (en segundos)
local intervaloResumenRutas = 120

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
local nombreVisible = nombresSubvariantes[claveSubVar]

function mostrarResumenRutasR()
    local mensaje = "Rutas activas Logistica:\n"
    local hay = false

    for nombreGrupo, datos in pairs(activeDeliveriesR) do
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

    trigger.action.outTextForCoalition(1, mensaje, 30)
    timer.scheduleFunction(mostrarResumenRutasR, {}, timer.getTime() + intervaloResumenRutas)
end



mostrarResumenRutasR()

verificarAterrizajesR()