-- ============================================================================
-- HDEV_MarketplaceCore.lua
-- Nucleo compartido del marketplace logistico
-- Mantiene separados Azul y Rojo en configuracion, pero evita duplicar logica
-- ============================================================================

HDEV_Marketplace = HDEV_Marketplace or {}

local Marketplace = HDEV_Marketplace

Marketplace.version = "1.0.0"
Marketplace.initialized = Marketplace.initialized or false
Marketplace.debug = Marketplace.debug or false
Marketplace.coalitions = Marketplace.coalitions or {}
Marketplace.births = Marketplace.births or {}
Marketplace.knownBirths = Marketplace.knownBirths or {}
Marketplace.eventHandlerRegistered = Marketplace.eventHandlerRegistered or false

local function mpLog(msg)
    if Marketplace.debug then
        env.info("[HDEV_MARKET] " .. tostring(msg))
    end
end

local function mpWarn(msg)
    env.info("[HDEV_MARKET] " .. tostring(msg))
end

local function sortKeys(t)
    local keys = {}
    for k in pairs(t or {}) do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)
    return keys
end

local function groupExistsByName(groupName)
    if not groupName then
        return nil
    end

    local grp = Group.getByName(groupName)
    if not grp then
        return nil
    end

    local ok, exists = pcall(function()
        return grp:isExist()
    end)

    if ok and exists then
        return grp
    end

    return nil
end

local function getUnit1(groupName)
    local grp = groupExistsByName(groupName)
    if not grp then
        return nil, nil
    end

    local unit = grp:getUnit(1)
    if not unit then
        return grp, nil
    end

    return grp, unit
end

local function pointDistance2D(a, b)
    if not a or not b then
        return math.huge
    end

    local dx = (a.x or 0) - (b.x or 0)
    local dz = (a.z or a.y or 0) - (b.z or b.y or 0)
    return math.sqrt(dx * dx + dz * dz)
end

local function outCoalition(coalition, msg, seconds)
    trigger.action.outTextForCoalition(coalition, msg, seconds or 10)
end

local function formatMoney(value)
    if HDEV_Economy and HDEV_Economy.formatMoney then
        return HDEV_Economy.formatMoney(value)
    end
    return tostring(value)
end

local function getEconomy()
    return HDEV_Economy
end

local function cleanupBirths(now)
    now = now or timer.getTime()
    for groupName, data in pairs(Marketplace.births) do
        if not data or (now - (data.time or 0)) > 120 then
            Marketplace.births[groupName] = nil
        end
    end
end

function Marketplace.registerEventHandler()
    if Marketplace.eventHandlerRegistered then
        return
    end

    world.addEventHandler({
        onEvent = function(_, event)
            if not event or event.id ~= world.event.S_EVENT_BIRTH then
                return
            end

            local initiator = event.initiator
            if not initiator or not initiator.getGroup then
                return
            end

            local grp = initiator:getGroup()
            if not grp then
                return
            end

            local groupName = grp:getName()
            if not groupName or groupName == "" then
                return
            end

            local point = nil
            if initiator.getPoint then
                point = initiator:getPoint()
            end

            Marketplace.births[groupName] = {
                name = groupName,
                coalition = initiator:getCoalition(),
                time = timer.getTime(),
                point = point
            }
        end
    })

    Marketplace.eventHandlerRegistered = true
    mpWarn("Event handler de nacimientos registrado")
end

function Marketplace.init(config)
    if Marketplace.initialized then
        if type(config) == "table" and config.debug ~= nil then
            Marketplace.debug = config.debug and true or false
        end
        return Marketplace
    end

    Marketplace.initialized = true
    Marketplace.debug = type(config) == "table" and config.debug and true or false
    Marketplace.registerEventHandler()
    return Marketplace
end

local function registerRootCommands(cfg)
    if not cfg or not cfg.menuRoot then
        return
    end

    missionCommands.addCommandForCoalition(cfg.coalition, "Mostrar billetera", cfg.menuRoot, function()
        local econ = getEconomy()
        if not econ then
            outCoalition(cfg.coalition, "Sistema economico no disponible.", 8)
            return
        end

        local msg = "Billetera\n"
        msg = msg .. "Azul: " .. formatMoney(econ.get(2)) .. "\n"
        msg = msg .. "Rojo: " .. formatMoney(econ.get(1))
        outCoalition(cfg.coalition, msg, 10)
    end)

    missionCommands.addCommandForCoalition(cfg.coalition, "Mostrar rutas activas", cfg.menuRoot, function()
        Marketplace.showRoutes(cfg.key)
    end)
end

local function buildCategoryMap(tiposAvion)
    local categorias = {}
    for nombreAvion, datos in pairs(tiposAvion or {}) do
        local categoria = datos.categoria or "Sin Clasificar"
        categorias[categoria] = categorias[categoria] or {}
        table.insert(categorias[categoria], nombreAvion)
    end

    for _, list in pairs(categorias) do
        table.sort(list)
    end

    return categorias
end

local function getVisibleDestinations(cfg, subKey)
    local result = {}
    local entries = destinosPorSubvariante[subKey] or {}

    for _, airport in ipairs(entries) do
        if cfg.plantillas and cfg.plantillas[airport] then
            table.insert(result, airport)
        end
    end

    return result
end

local function getFinalCost(cfg, airport, subKey)
    local base = tipoAviones[subKey] and tipoAviones[subKey].costo or 0
    local recargo = cfg.recargos and cfg.recargos[airport] or 1
    return math.floor(base * recargo)
end

function Marketplace.buildMenu(key)
    local cfg = Marketplace.coalitions[key]
    if not cfg then
        mpWarn("No existe configuracion de marketplace para: " .. tostring(key))
        return false
    end

    if cfg.menuRoot then
        missionCommands.removeItem(cfg.menuRoot)
        cfg.menuRoot = nil
    end

    cfg.menuRoot = missionCommands.addSubMenuForCoalition(cfg.coalition, cfg.menuName or "MARKETPLACE")
    registerRootCommands(cfg)

    local categorias = buildCategoryMap(tiposAvion)
    for _, categoria in ipairs(sortKeys(categorias)) do
        local menuCategoria = missionCommands.addSubMenuForCoalition(cfg.coalition, categoria, cfg.menuRoot)

        for _, nombreAvion in ipairs(categorias[categoria]) do
            local datos = tiposAvion[nombreAvion]
            local claveTipo = datos and datos.clave
            if claveTipo and subvariantesAvion[claveTipo] then
                local menuAvion = missionCommands.addSubMenuForCoalition(cfg.coalition, nombreAvion, menuCategoria)
                local subMap = subvariantesAvion[claveTipo]

                for _, nombreSub in ipairs(sortKeys(subMap)) do
                    local claveSub = subMap[nombreSub]
                    local visibleDestinations = getVisibleDestinations(cfg, claveSub)

                    if #visibleDestinations > 0 then
                        local menuSub = missionCommands.addSubMenuForCoalition(cfg.coalition, nombreSub, menuAvion)
                        local porPagina = cfg.itemsPerPage or 8
                        local totalPaginas = math.max(1, math.ceil(#visibleDestinations / porPagina))

                        for pagina = 1, totalPaginas do
                            local paginaMenu = menuSub
                            if totalPaginas > 1 then
                                local pageName = (cfg.pageTitlePrefix or "Pagina") .. " " .. pagina
                                paginaMenu = missionCommands.addSubMenuForCoalition(cfg.coalition, pageName, menuSub)
                            end

                            local iInicio = ((pagina - 1) * porPagina) + 1
                            local iFin = math.min(#visibleDestinations, pagina * porPagina)

                            for i = iInicio, iFin do
                                local airport = visibleDestinations[i]
                                local cost = getFinalCost(cfg, airport, claveSub)
                                local label = "Comprar y Enviar a: " .. airport .. " (" .. formatMoney(cost) .. ")"
                                missionCommands.addCommandForCoalition(cfg.coalition, label, paginaMenu, function()
                                    Marketplace.requestDelivery(key, airport, claveSub)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end

    mpWarn("Menu construido para " .. tostring(key))
    return true
end

function Marketplace.closeMarket(key)
    local cfg = Marketplace.coalitions[key]
    if not cfg then
        return
    end

    if cfg.menuRoot then
        missionCommands.removeItem(cfg.menuRoot)
        cfg.menuRoot = nil
        outCoalition(cfg.coalition, cfg.closeMessage or "El Mercado de Pulgas ha sido cerrado.", 15)
    end
end

function Marketplace.marketTimerTick(key, now)
    local cfg = Marketplace.coalitions[key]
    if not cfg or not cfg.marketTimer or not cfg.marketStartTime then
        return nil
    end

    local total = cfg.marketTimer.Total or 0
    local intervalo = cfg.marketTimer.Intervalo or 0
    if total <= 0 or intervalo <= 0 then
        return nil
    end

    local restante = math.max(0, (cfg.marketStartTime + total) - now)
    if restante <= 0 then
        Marketplace.closeMarket(key)
        return nil
    end

    local minutos = math.floor(restante / 60)
    local segundos = math.floor(restante % 60)
    outCoalition(cfg.coalition, "El mercado se cerrara en: " .. minutos .. " min " .. segundos .. " seg", 10)

    return now + intervalo
end

function Marketplace.startMarketTimer(key, marketTimer)
    local cfg = Marketplace.coalitions[key]
    if not cfg then
        return false
    end

    cfg.marketTimer = marketTimer
    cfg.marketStartTime = timer.getTime()

    if not marketTimer or not marketTimer.Total or not marketTimer.Intervalo then
        return false
    end

    timer.scheduleFunction(function(_, now)
        return Marketplace.marketTimerTick(key, now)
    end, nil, timer.getTime() + marketTimer.Intervalo)

    return true
end

function Marketplace.registerCoalition(key, cfg)
    if type(cfg) ~= "table" then
        return false
    end

    cfg.key = key
    cfg.state = cfg.state or {}
    cfg.state.cooldowns = cfg.state.cooldowns or {}
    cfg.state.deliveries = cfg.state.deliveries or {}
    cfg.state.pending = cfg.state.pending or {}
    cfg.itemsPerPage = cfg.itemsPerPage or 8
    cfg.deliveryDestroyDelay = cfg.deliveryDestroyDelay or 20
    cfg.monitorInterval = cfg.monitorInterval or 5
    cfg.cooldownSeconds = cfg.cooldownSeconds or 120
    cfg.deliveryMinAlt = cfg.deliveryMinAlt or 100
    cfg.deliveryStopSpeed = cfg.deliveryStopSpeed or 1
    cfg.searchBirthRadius = cfg.searchBirthRadius or 5000
    cfg.menuName = cfg.menuName or "MARKETPLACE"
    cfg.pageTitlePrefix = cfg.pageTitlePrefix or "Pagina"
    cfg.routeZoneName = cfg.routeZoneName or "Rutas"
    cfg.showAutoRoutes = cfg.showAutoRoutes or false

    Marketplace.coalitions[key] = cfg
    mpWarn("Coalicion registrada en marketplace: " .. tostring(key))
    return true
end

local function trackDeliveryGroup(cfg, groupName, airport, subKey, template)
    cfg.state.deliveries[groupName] = {
        destino = airport,
        inventario = subKey,
        plantilla = template,
        entregado = false,
        destruido = false,
        altMax = 0,
        createdAt = timer.getTime()
    }
end

local function getPendingBestMatch(cfg, pending)
    local bestName = nil
    local bestScore = math.huge
    local now = timer.getTime()

    cleanupBirths(now)

    for groupName, birth in pairs(Marketplace.births) do
        if not cfg.state.deliveries[groupName]
        and (birth.coalition == cfg.coalition)
        and (birth.time or 0) >= (pending.startedAt or 0) - 0.5
        and not Marketplace.knownBirths[groupName] then
            local score = pointDistance2D(birth.point, pending.origin)
            if score <= (cfg.searchBirthRadius or 5000) and score < bestScore then
                bestScore = score
                bestName = groupName
            end
        end
    end

    return bestName
end

function Marketplace.resolvePending(key, pendingId)
    local cfg = Marketplace.coalitions[key]
    if not cfg then
        return nil
    end

    local pending = cfg.state.pending[pendingId]
    if not pending then
        return nil
    end

    pending.attempts = (pending.attempts or 0) + 1
    local attempt = pending.attempts
    local bestName = getPendingBestMatch(cfg, pending)
    if bestName then
        Marketplace.knownBirths[bestName] = true
        trackDeliveryGroup(cfg, bestName, pending.airport, pending.subKey, pending.template)
        cfg.state.cooldowns[pending.airport] = timer.getTime() + (cfg.cooldownSeconds or 120)
        cfg.state.pending[pendingId] = nil
        mpLog("Entrega enlazada a grupo: " .. bestName .. " | " .. pending.airport)
        return nil
    end

    if attempt >= 8 then
        local econ = getEconomy()
        if econ then
            econ.add(cfg.coalition, pending.cost, "reembolso fallo clone " .. pending.airport)
        end
        cfg.state.pending[pendingId] = nil
        outCoalition(cfg.coalition, "No se pudo completar la compra hacia " .. pending.airport .. ". El dinero fue reembolsado.", 12)
        mpWarn("No se pudo resolver el grupo clonado para " .. pending.airport)
        return nil
    end

    return timer.getTime() + 0.75
end

function Marketplace.requestDelivery(key, airport, subKey)
    local cfg = Marketplace.coalitions[key]
    if not cfg then
        return false
    end

    local data = cfg.plantillas and cfg.plantillas[airport]
    if not data then
        outCoalition(cfg.coalition, "No existe plantilla logistica para " .. airport, 10)
        return false
    end

    local banderaActual = trigger.misc.getUserFlag(data.bandera)
    if banderaActual ~= cfg.allowedFlagValue then
        outCoalition(cfg.coalition, "Este aerodromo no esta disponible para tu coalicion.", 8)
        return false
    end

    local bloqueo = cfg.state.cooldowns[airport]
    if bloqueo and timer.getTime() < bloqueo then
        local restante = math.max(0, math.floor(bloqueo - timer.getTime()))
        outCoalition(cfg.coalition, "Debes esperar " .. restante .. " segundos antes de volver a comprar en " .. airport, 8)
        return false
    end

    local inventoryData = tipoAviones[subKey]
    if not inventoryData then
        outCoalition(cfg.coalition, "No existe inventario para la clave: " .. tostring(subKey), 8)
        return false
    end

    local econ = getEconomy()
    if not econ then
        outCoalition(cfg.coalition, "Sistema economico no disponible.", 8)
        return false
    end

    local cost = getFinalCost(cfg, airport, subKey)
    local okSpend = econ.spend(cfg.coalition, cost, "compra marketplace " .. airport .. " " .. subKey)
    if not okSpend then
        outCoalition(cfg.coalition, "No tienes suficientes dolares. Requiere: " .. formatMoney(cost), 10)
        return false
    end

    local origin = data.origen or cfg.defaultOrigin or { x = 0, y = 0, z = 0 }
    local destination = cfg.coordinates and cfg.coordinates[airport] or { x = 0, y = 0, z = 0 }
    local dx = (destination.x or 0) - (origin.x or 0)
    local dz = (destination.z or 0) - (origin.z or 0)
    local distance = math.sqrt(dx * dx + dz * dz)
    local speed = data.velocidad or cfg.defaultSpeed or 1
    local timeMultiplier = cfg.timeMultipliers and cfg.timeMultipliers[airport] or 1
    local eta = math.floor((distance / speed) * timeMultiplier)
    local minutos = math.floor(eta / 60)
    local segundos = eta % 60

    outCoalition(cfg.coalition, "Compra confirmada. Enviando a " .. airport, 20)
    outCoalition(cfg.coalition, "Llegada estimada: " .. minutos .. " min " .. segundos .. " seg", 20)

    local pendingId = key .. "_" .. tostring(timer.getTime()) .. "_" .. airport .. "_" .. subKey
    cfg.state.pending[pendingId] = {
        airport = airport,
        subKey = subKey,
        template = data.template,
        cost = cost,
        origin = origin,
        startedAt = timer.getTime()
    }

    local okClone, cloneError = pcall(function()
        mist.cloneGroup(data.template, true)
    end)

    if not okClone then
        cfg.state.pending[pendingId] = nil
        econ.add(cfg.coalition, cost, "reembolso error clone " .. airport)
        outCoalition(cfg.coalition, "Fallo al crear la ruta hacia " .. airport .. ". El dinero fue reembolsado.", 10)
        mpWarn("mist.cloneGroup fallo en " .. airport .. ": " .. tostring(cloneError))
        return false
    end

    timer.scheduleFunction(function()
        return Marketplace.resolvePending(key, pendingId)
    end, nil, timer.getTime() + 0.75)

    return true
end

local function applyInventoryToAirbase(coalition, airport, data)
    local base = Airbase.getByName(airport)
    if not base then
        return false, "Airbase no encontrada: " .. tostring(airport)
    end

    local warehouse = base:getWarehouse()
    if not warehouse then
        return false, "Warehouse no disponible en: " .. tostring(airport)
    end

    local resumen = {}
    local totalAviones = 0

    if data.avion then
        Warehouse.addItem(warehouse, data.avion.ws, data.avion.cantidad)
        totalAviones = data.avion.cantidad
    end

    local function loadSection(section, title)
        for name, item in pairs(section or {}) do
            Warehouse.addItem(warehouse, item.ws, item.cantidad)
            table.insert(resumen, title .. ": " .. name .. " x" .. item.cantidad)
        end
    end

    loadSection(data.bombas, "BOMBA")
    loadSection(data.bombas_guiadas, "BOMBAG")
    loadSection(data.cohetes, "COHETE")
    loadSection(data.tanques, "TANQUE")
    loadSection(data.misiles, "MISIL")
    loadSection(data.misiles_guiados, "MISILG")
    loadSection(data.misc, "MISCELANEO")

    local msg = "Suministros entregados en " .. airport .. ":\n\n"
    msg = msg .. (data.nombreAvion or "Avion") .. " x" .. totalAviones
    if #resumen > 0 then
        msg = msg .. "\n" .. table.concat(resumen, "\n")
    end

    outCoalition(coalition, msg, 30)
    return true, msg
end

function Marketplace.monitorTick(key, now)
    local cfg = Marketplace.coalitions[key]
    if not cfg then
        return nil
    end

    for groupName, info in pairs(cfg.state.deliveries) do
        if not info.entregado and not info.destruido then
            local grp, unit = getUnit1(groupName)
            if grp and unit then
                local point = unit:getPoint()
                local terrain = land.getHeight({ x = point.x, y = point.z })
                local agl = point.y - terrain
                info.altMax = math.max(info.altMax or 0, agl)

                local velocity = unit:getVelocity()
                local speed = math.sqrt((velocity.x or 0)^2 + (velocity.z or 0)^2)

                if (info.altMax or 0) >= (cfg.deliveryMinAlt or 100) and speed < (cfg.deliveryStopSpeed or 1) then
                    local inventoryData = tipoAviones[info.inventario]
                    if inventoryData then
                        applyInventoryToAirbase(cfg.coalition, info.destino, inventoryData)
                    end
                    info.entregado = true

                    timer.scheduleFunction(function()
                        local g = groupExistsByName(groupName)
                        if g then
                            g:destroy()
                        end
                    end, nil, timer.getTime() + (cfg.deliveryDestroyDelay or 20))
                end
            else
                info.destruido = true
            end
        end
    end

    return now + (cfg.monitorInterval or 5)
end

function Marketplace.startMonitor(key)
    local cfg = Marketplace.coalitions[key]
    if not cfg or cfg.monitorStarted then
        return false
    end

    cfg.monitorStarted = true
    timer.scheduleFunction(function(_, now)
        return Marketplace.monitorTick(key, now)
    end, nil, timer.getTime() + (cfg.monitorInterval or 5))

    return true
end

function Marketplace.showRoutes(key)
    local cfg = Marketplace.coalitions[key]
    if not cfg then
        return
    end

    local zone = trigger.misc.getZone(cfg.routeZoneName)
    local msg = "Rutas activas Logistica:\n"
    local hay = false

    for groupName, info in pairs(cfg.state.deliveries) do
        if not info.entregado and not info.destruido then
            local grp, unit = getUnit1(groupName)
            if grp and unit then
                if zone then
                    local point = unit:getPoint()
                    local dist = pointDistance2D(point, { x = zone.point.x, z = zone.point.z })
                    if dist <= zone.radius then
                        local visibleName = nombresSubvariantes and nombresSubvariantes[info.inventario] or info.inventario
                        msg = msg .. "Ruta " .. groupName .. " (" .. tostring(visibleName) .. ") va hacia " .. info.destino .. "\n"
                        hay = true
                    end
                else
                    local visibleName = nombresSubvariantes and nombresSubvariantes[info.inventario] or info.inventario
                    msg = msg .. "Ruta " .. groupName .. " (" .. tostring(visibleName) .. ") va hacia " .. info.destino .. "\n"
                    hay = true
                end
            else
                info.destruido = true
            end
        end
    end

    if not hay then
        msg = msg .. "\n(No hay rutas activas dentro de la zona en este momento)"
    end

    outCoalition(cfg.coalition, msg, 30)
end

return HDEV_Marketplace
