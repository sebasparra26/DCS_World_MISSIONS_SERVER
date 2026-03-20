EscortMP = {}

EscortMP.cfg = {
    debug = false,

    menuRoot = "Sistema de Escolta",
    menuCreate = "Crear escolta",
    menuRemove = "Quitar escolta",

    rangoEngancheNM = 2,
    chequeoSegundos = 2,
    borrarTrasMuerteJugador = 5,

    minAGLParaCrear = 5,

    spawnDerecha = 80,
    spawnAtras = 120,
    spawnVertical = 20,
    alturaSpawnEnSuelo = 300,

    formacion = {
        x = -120,
        y = 0,
        z = 80
    },

    velocidadMinPlane = 170,
    velocidadMinHeli = 60,

    skillPlane = "High",
    skillHeli = "High",

    mensajes = {
        yaActiva = "Ya tienes una escolta activa.",
        creada = "Escolta creada.",
        quitada = "Escolta eliminada.",
        sinJugador = "No se detecto un jugador valido en este grupo.",
        noCompatible = "La escolta solo funciona con aviones y helicopteros.",
        sinDB = "No se pudo leer la unidad en la base de datos de MIST.",
        destruida = "Tu escolta fue destruida. Ya puedes pedir otra.",
        sinMunicion = "La escolta se retiro por falta total de municion.",
        aterrizaje = "La escolta se retiro porque el jugador aterrizo.",
        muerteJugador = "La escolta se retirara por perdida del jugador.",
        alturaInsuficiente = "No puedes crear la escolta entre 0 y 5 AGL."
    }
}

EscortMP.sessions = {}
EscortMP.menus = {}

function EscortMP.log(txt)
    if EscortMP.cfg.debug then
        env.info("[EscortMP] " .. tostring(txt))
    end
end

function EscortMP.msg(groupId, txt, duracion)
    if groupId then
        trigger.action.outTextForGroup(groupId, txt, duracion or 5)
    end
end

function EscortMP.nmToMeters(nm)
    return nm * 1852
end

function EscortMP.groupExists(groupName)
    local g = Group.getByName(groupName)
    return g and g:isExist()
end

function EscortMP.unitExists(unitName)
    local u = Unit.getByName(unitName)
    return u and u:isExist()
end

function EscortMP.getUnitAGL(unit)
    if not unit or not unit:isExist() then
        return 0
    end

    local p = unit:getPoint()
    if not p then
        return 0
    end

    local terreno = land.getHeight({ x = p.x, y = p.z }) or 0
    local agl = p.y - terreno

    if agl < 0 then
        agl = 0
    end

    return agl
end

function EscortMP.getHeadingFromUnit(unit)
    if not unit or not unit:isExist() then
        return 0
    end

    if mist and mist.getHeading then
        local h = mist.getHeading(unit, true)
        if h then
            return h
        end
    end

    local pos = unit:getPosition()
    if not pos then
        return 0
    end

    return math.atan2(pos.x.z, pos.x.x)
end

function EscortMP.getSessionByUnitName(unitName)
    for groupId, session in pairs(EscortMP.sessions) do
        if session.playerUnitName == unitName or session.escortUnitName == unitName then
            return groupId, session
        end
    end
    return nil, nil
end

function EscortMP.clearMenu(groupId)
    if EscortMP.menus[groupId] then
        missionCommands.removeItemForGroup(groupId, EscortMP.menus[groupId])
        EscortMP.menus[groupId] = nil
    end
end

function EscortMP.buildMenuForUnit(unit)
    if not unit or not unit:isExist() then
        return
    end

    local playerName = unit:getPlayerName()
    if not playerName or playerName == "" then
        return
    end

    local grp = unit:getGroup()
    if not grp or not grp:isExist() then
        return
    end

    local groupId = grp:getID()

    EscortMP.clearMenu(groupId)

    local root = missionCommands.addSubMenuForGroup(groupId, EscortMP.cfg.menuRoot)
    missionCommands.addCommandForGroup(groupId, EscortMP.cfg.menuCreate, root, EscortMP.createEscort, groupId)
    missionCommands.addCommandForGroup(groupId, EscortMP.cfg.menuRemove, root, EscortMP.removeEscortCommand, groupId)

    EscortMP.menus[groupId] = root
    EscortMP.log("Menu creado para " .. tostring(playerName) .. " en groupId " .. tostring(groupId))
end

function EscortMP.getPlayerUnitByGroupId(groupId)
    local lados = {
        coalition.side.BLUE,
        coalition.side.RED,
        coalition.side.NEUTRAL
    }

    local categorias = {
        Group.Category.AIRPLANE,
        Group.Category.HELICOPTER
    }

    for _, lado in ipairs(lados) do
        for _, categoria in ipairs(categorias) do
            local grupos = coalition.getGroups(lado, categoria)
            if grupos then
                for _, grp in pairs(grupos) do
                    if grp and grp:isExist() and grp:getID() == groupId then
                        local units = grp:getUnits()
                        if units then
                            for _, unit in pairs(units) do
                                if unit and unit:isExist() then
                                    local pname = unit:getPlayerName()
                                    if pname and pname ~= "" then
                                        return unit, grp
                                    end
                                end
                            end
                        end
                        return nil, grp
                    end
                end
            end
        end
    end

    return nil, nil
end

function EscortMP.getDbForUnit(unitName)
    if mist and mist.DBs then
        if mist.DBs.unitsByName and mist.DBs.unitsByName[unitName] then
            return mist.DBs.unitsByName[unitName]
        end
        if mist.DBs.humansByName and mist.DBs.humansByName[unitName] then
            return mist.DBs.humansByName[unitName]
        end
    end
    return nil
end

function EscortMP.getAmmoCount(unit)
    if not unit or not unit:isExist() then
        return 0
    end

    local ammo = unit:getAmmo()
    if not ammo then
        return 0
    end

    local total = 0
    for i = 1, #ammo do
        if ammo[i] and ammo[i].count then
            total = total + ammo[i].count
        end
    end

    return total
end

function EscortMP.makeSpawnPoint(playerUnit)
    local pos = playerUnit:getPosition()
    local p = playerUnit:getPoint()

    local spawnX = pos.p.x + (pos.z.x * EscortMP.cfg.spawnDerecha) + (pos.x.x * (-EscortMP.cfg.spawnAtras))
    local spawnZ = pos.p.z + (pos.z.z * EscortMP.cfg.spawnDerecha) + (pos.x.z * (-EscortMP.cfg.spawnAtras))
    local spawnAlt = p.y + EscortMP.cfg.spawnVertical

    if not playerUnit:inAir() then
        local ground = land.getHeight({ x = spawnX, y = spawnZ }) or 0
        spawnAlt = ground + EscortMP.cfg.alturaSpawnEnSuelo
    end

    return spawnX, spawnZ, spawnAlt
end

function EscortMP.makeEscortGroupData(playerUnit, playerGroup, groupId)
    local playerUnitName = playerUnit:getName()
    local db = EscortMP.getDbForUnit(playerUnitName)

    if not db then
        return nil, EscortMP.cfg.mensajes.sinDB
    end

    local category = db.category
    if category ~= "plane" and category ~= "helicopter" then
        return nil, EscortMP.cfg.mensajes.noCompatible
    end

    local speedVec = playerUnit:getVelocity()
    local currentSpeed = math.sqrt(
        (speedVec.x * speedVec.x) +
        (speedVec.y * speedVec.y) +
        (speedVec.z * speedVec.z)
    )

    local defaultSpeed = EscortMP.cfg.velocidadMinPlane
    local skill = EscortMP.cfg.skillPlane

    if category == "helicopter" then
        defaultSpeed = EscortMP.cfg.velocidadMinHeli
        skill = EscortMP.cfg.skillHeli
    end

    local spawnX, spawnZ, spawnAlt = EscortMP.makeSpawnPoint(playerUnit)
    local finalSpeed = math.max(currentSpeed, defaultSpeed)

    local uniqueId = tostring(groupId) .. "_" .. tostring(math.floor(timer.getTime() * 100))
    local groupName = "ESCORT_" .. uniqueId
    local unitName = groupName .. "_1"

    local payload = {}
    if mist and mist.getPayload then
        payload = mist.getPayload(playerUnitName) or {}
    end

    local routePoint = {
        x = spawnX,
        y = spawnZ,
        alt = spawnAlt,
        alt_type = "BARO",
        speed = finalSpeed,
        action = "Turning Point",
        type = "Turning Point",
        ETA = 0,
        ETA_locked = true,
        speed_locked = true,
        task = {
            id = "ComboTask",
            params = {
                tasks = {}
            }
        }
    }

    local newGroup = {
        visible = false,
        hidden = false,
        lateActivation = false,
        task = "Nothing",
        route = {
            points = {
                [1] = routePoint
            }
        },
        groupName = groupName,
        country = db.countryId or playerUnit:getCountry(),
        category = category,
        units = {
            [1] = {
                unitName = unitName,
                type = playerUnit:getTypeName(),
                skill = skill,
                x = spawnX,
                y = spawnZ,
                alt = spawnAlt,
                alt_type = "BARO",
                speed = finalSpeed,
                heading = EscortMP.getHeadingFromUnit(playerUnit),
                payload = payload,
                livery_id = db.livery_id,
                AddPropAircraft = db.AddPropAircraft
            }
        }
    }

    return newGroup, nil
end

function EscortMP.makeEscortTask(playerGroupId)
    return {
        id = "Escort",
        params = {
            groupId = playerGroupId,
            pos = {
                x = EscortMP.cfg.formacion.x,
                y = EscortMP.cfg.formacion.y,
                z = EscortMP.cfg.formacion.z
            },
            lastWptIndexFlag = false,
            engagementDistMax = EscortMP.nmToMeters(EscortMP.cfg.rangoEngancheNM),
            targetTypes = { "Air", "Ground Units" }
        }
    }
end

function EscortMP.applyEscortTask(groupId)
    local session = EscortMP.sessions[groupId]
    if not session then
        return
    end

    local escortGroup = Group.getByName(session.escortGroupName)
    local playerGroup = Group.getByName(session.playerGroupName)

    if not escortGroup or not escortGroup:isExist() then
        return
    end

    if not playerGroup or not playerGroup:isExist() then
        return
    end

    local ctrl = escortGroup:getController()
    if not ctrl then
        return
    end

    ctrl:setTask(EscortMP.makeEscortTask(playerGroup:getID()))
    EscortMP.log("Escort task aplicada a " .. tostring(session.escortGroupName))
end

function EscortMP.scheduleDestroy(groupId, delay, reason)
    local session = EscortMP.sessions[groupId]
    if not session then
        return
    end

    if session.destroyScheduled then
        return
    end

    session.destroyScheduled = true

    timer.scheduleFunction(function(arg, time)
        EscortMP.removeEscortNow(arg.groupId, arg.reason, true)
        return nil
    end, { groupId = groupId, reason = reason }, timer.getTime() + (delay or EscortMP.cfg.borrarTrasMuerteJugador))
end

function EscortMP.removeEscortNow(groupId, reason, silent)
    local session = EscortMP.sessions[groupId]
    if not session then
        return
    end

    local escortGroup = Group.getByName(session.escortGroupName)
    if escortGroup and escortGroup:isExist() then
        escortGroup:destroy()
    end

    EscortMP.sessions[groupId] = nil

    if silent then
        if reason then
            EscortMP.msg(groupId, reason, 5)
        end
    else
        EscortMP.msg(groupId, EscortMP.cfg.mensajes.quitada, 5)
    end

    EscortMP.log("Escolta removida de groupId " .. tostring(groupId))
end

function EscortMP.removeEscortCommand(groupId)
    EscortMP.removeEscortNow(groupId, EscortMP.cfg.mensajes.quitada, false)
end

function EscortMP.createEscort(groupId)
    local playerUnit, playerGroup = EscortMP.getPlayerUnitByGroupId(groupId)

    if not playerUnit or not playerGroup then
        EscortMP.msg(groupId, EscortMP.cfg.mensajes.sinJugador, 5)
        return
    end

    local playerName = playerUnit:getPlayerName()
    if not playerName or playerName == "" then
        EscortMP.msg(groupId, EscortMP.cfg.mensajes.sinJugador, 5)
        return
    end

    local aglJugador = EscortMP.getUnitAGL(playerUnit)
    if aglJugador <= EscortMP.cfg.minAGLParaCrear then
        EscortMP.msg(groupId, EscortMP.cfg.mensajes.alturaInsuficiente, 5)
        return
    end

    local existing = EscortMP.sessions[groupId]
    if existing then
        local g = Group.getByName(existing.escortGroupName)
        if g and g:isExist() then
            EscortMP.msg(groupId, EscortMP.cfg.mensajes.yaActiva, 5)
            return
        else
            EscortMP.sessions[groupId] = nil
        end
    end

    local groupData, err = EscortMP.makeEscortGroupData(playerUnit, playerGroup, groupId)
    if not groupData then
        EscortMP.msg(groupId, err or "No se pudo crear la escolta.", 5)
        return
    end

    mist.dynAdd(groupData)

    timer.scheduleFunction(function(arg, time)
        EscortMP.applyEscortTask(arg.groupId)
        return nil
    end, { groupId = groupId }, timer.getTime() + 0.5)

    EscortMP.sessions[groupId] = {
        groupId = groupId,
        playerUnitName = playerUnit:getName(),
        playerGroupName = playerGroup:getName(),
        playerName = playerName,
        escortGroupName = groupData.groupName,
        escortUnitName = groupData.units[1].unitName,
        playerWasAirborne = playerUnit:inAir(),
        destroyScheduled = false
    }

    EscortMP.msg(groupId, EscortMP.cfg.mensajes.creada, 5)
    EscortMP.log("Escolta creada para " .. tostring(playerName) .. " groupId " .. tostring(groupId))
end

function EscortMP.housekeeping()
    for groupId, session in pairs(EscortMP.sessions) do
        local playerUnit = Unit.getByName(session.playerUnitName)
        local escortGroup = Group.getByName(session.escortGroupName)
        local escortUnit = Unit.getByName(session.escortUnitName)

        if not escortGroup or not escortGroup:isExist() or not escortUnit or not escortUnit:isExist() then
            EscortMP.sessions[groupId] = nil
            EscortMP.msg(groupId, EscortMP.cfg.mensajes.destruida, 5)
        else
            local ammoLeft = EscortMP.getAmmoCount(escortUnit)
            if ammoLeft <= 0 then
                EscortMP.removeEscortNow(groupId, EscortMP.cfg.mensajes.sinMunicion, true)
            else
                if playerUnit and playerUnit:isExist() then
                    local pname = playerUnit:getPlayerName()

                    if pname and pname ~= "" then
                        if playerUnit:inAir() then
                            session.playerWasAirborne = true
                        end

                        if session.playerWasAirborne and not playerUnit:inAir() then
                            EscortMP.removeEscortNow(groupId, EscortMP.cfg.mensajes.aterrizaje, true)
                        end
                    else
                        EscortMP.scheduleDestroy(groupId, EscortMP.cfg.borrarTrasMuerteJugador, EscortMP.cfg.mensajes.muerteJugador)
                    end
                else
                    EscortMP.scheduleDestroy(groupId, EscortMP.cfg.borrarTrasMuerteJugador, EscortMP.cfg.mensajes.muerteJugador)
                end
            end
        end
    end

    return timer.getTime() + EscortMP.cfg.chequeoSegundos
end

function EscortMP.bootstrapMenus()
    local lados = {
        coalition.side.BLUE,
        coalition.side.RED,
        coalition.side.NEUTRAL
    }

    local categorias = {
        Group.Category.AIRPLANE,
        Group.Category.HELICOPTER
    }

    for _, lado in ipairs(lados) do
        for _, categoria in ipairs(categorias) do
            local grupos = coalition.getGroups(lado, categoria)
            if grupos then
                for _, grp in pairs(grupos) do
                    if grp and grp:isExist() then
                        local units = grp:getUnits()
                        if units then
                            for _, unit in pairs(units) do
                                if unit and unit:isExist() then
                                    local pname = unit:getPlayerName()
                                    if pname and pname ~= "" then
                                        EscortMP.buildMenuForUnit(unit)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

EscortMP.eventHandler = {}

function EscortMP.eventHandler:onEvent(event)
    if not event or not event.id or not event.initiator then
        return
    end

    local initiator = event.initiator
    if not initiator.getName then
        return
    end

    local unitName = initiator:getName()

    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        if initiator:getPlayerName() then
            EscortMP.buildMenuForUnit(initiator)
        end
        return
    end

    if world.event.S_EVENT_PLAYER_LEAVE_UNIT and event.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
        local grp = initiator:getGroup()
        if grp and grp:isExist() then
            local groupId = grp:getID()
            EscortMP.clearMenu(groupId)
            EscortMP.scheduleDestroy(groupId, EscortMP.cfg.borrarTrasMuerteJugador, EscortMP.cfg.mensajes.muerteJugador)
        end
        return
    end

    local groupId, session = EscortMP.getSessionByUnitName(unitName)
    if not session then
        return
    end

    if event.id == world.event.S_EVENT_LAND then
        if unitName == session.playerUnitName then
            EscortMP.removeEscortNow(groupId, EscortMP.cfg.mensajes.aterrizaje, true)
        end
        return
    end

    if event.id == world.event.S_EVENT_DEAD
    or event.id == world.event.S_EVENT_CRASH
    or event.id == world.event.S_EVENT_EJECTION
    or (world.event.S_EVENT_PILOT_DEAD and event.id == world.event.S_EVENT_PILOT_DEAD) then

        if unitName == session.playerUnitName then
            EscortMP.scheduleDestroy(groupId, EscortMP.cfg.borrarTrasMuerteJugador, EscortMP.cfg.mensajes.muerteJugador)
        elseif unitName == session.escortUnitName then
            EscortMP.sessions[groupId] = nil
            EscortMP.msg(groupId, EscortMP.cfg.mensajes.destruida, 5)
        end
    end
end

world.addEventHandler(EscortMP.eventHandler)

timer.scheduleFunction(function()
    EscortMP.bootstrapMenus()
    return nil
end, {}, timer.getTime() + 1)

timer.scheduleFunction(function()
    return EscortMP.housekeeping()
end, {}, timer.getTime() + EscortMP.cfg.chequeoSegundos)