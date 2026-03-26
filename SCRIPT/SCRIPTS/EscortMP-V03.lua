EscortMP = {}

EscortMP.cfg = {
    debug = false,
    debugCombat = false,

    menuRoot = "Sistema de Escolta",
    menuCreate = "Crear escolta",
    menuRemove = "Quitar escolta",

    rangoEngancheNM = 1,
    rangoPerderObjetivoNM = 3,
    chequeoSegundos = 2,
    chequeoAmenazaSegundos = 2,
    escaneoMenuSegundos = 5,
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
EscortMP.menuOwners = {}
EscortMP.started = false

function EscortMP.log(txt)
    if EscortMP.cfg.debug then
        env.info("[EscortMP] " .. tostring(txt))
    end
end

function EscortMP.logCombat(txt)
    if EscortMP.cfg.debugCombat then
        env.info("[EscortMP][COMBAT] " .. tostring(txt))
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

function EscortMP.get2DDistance(p1, p2)
    if not p1 or not p2 then
        return math.huge
    end

    local dx = p1.x - p2.x
    local dz = p1.z - p2.z
    return math.sqrt(dx * dx + dz * dz)
end

function EscortMP.getEnemyCoalition(coalitionId)
    if coalitionId == coalition.side.BLUE then
        return coalition.side.RED
    elseif coalitionId == coalition.side.RED then
        return coalition.side.BLUE
    end
    return nil
end

function EscortMP.getFirstAliveUnitFromGroup(grp)
    if not grp or not grp:isExist() then
        return nil
    end

    local units = grp:getUnits() or {}
    for _, unit in pairs(units) do
        if unit and unit:isExist() then
            return unit
        end
    end

    return nil
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

    return 0
end

function EscortMP.getSessionByUnitName(unitName)
    for sessionKey, session in pairs(EscortMP.sessions) do
        if session.playerUnitName == unitName or session.escortUnitName == unitName then
            return sessionKey, session
        end
    end
    return nil, nil
end

function EscortMP.getSessionByGroupId(groupId)
    if not groupId then
        return nil, nil
    end

    local playerUnit = EscortMP.getPlayerUnitByGroupId(groupId)
    if playerUnit and playerUnit:isExist() then
        local sessionKey = playerUnit:getName()
        if sessionKey and EscortMP.sessions[sessionKey] then
            return sessionKey, EscortMP.sessions[sessionKey]
        end
    end

    for sessionKey, session in pairs(EscortMP.sessions) do
        if session.currentGroupId == groupId then
            return sessionKey, session
        end
    end

    return nil, nil
end

function EscortMP.getSessionGroupId(session)
    if not session then
        return nil
    end

    local playerUnit = Unit.getByName(session.playerUnitName)
    if playerUnit and playerUnit:isExist() then
        local grp = playerUnit:getGroup()
        if grp and grp:isExist() then
            session.currentGroupId = grp:getID()
            return session.currentGroupId
        end
    end

    return session.currentGroupId
end

function EscortMP.clearMenu(groupId)
    if EscortMP.menus[groupId] then
        missionCommands.removeItemForGroup(groupId, EscortMP.menus[groupId])
        EscortMP.menus[groupId] = nil
    end

    EscortMP.menuOwners[groupId] = nil
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
    local ownerKey = unit:getName()

    if EscortMP.menus[groupId] and EscortMP.menuOwners[groupId] == ownerKey then
        return
    end

    EscortMP.clearMenu(groupId)

    local root = missionCommands.addSubMenuForGroup(groupId, EscortMP.cfg.menuRoot)
    missionCommands.addCommandForGroup(groupId, EscortMP.cfg.menuCreate, root, EscortMP.createEscort, groupId)
    missionCommands.addCommandForGroup(groupId, EscortMP.cfg.menuRemove, root, EscortMP.removeEscortCommand, groupId)

    EscortMP.menus[groupId] = root
    EscortMP.menuOwners[groupId] = ownerKey

    EscortMP.log("Menu creado para " .. tostring(playerName) .. " en groupId " .. tostring(groupId))
end

function EscortMP.cleanupOrphanMenus(activeGroups)
    for groupId, _ in pairs(EscortMP.menus) do
        if not activeGroups[groupId] then
            EscortMP.clearMenu(groupId)
            EscortMP.log("Menu huerfano eliminado en groupId " .. tostring(groupId))
        end
    end
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
            local grupos = coalition.getGroups(lado, categoria) or {}
            for _, grp in pairs(grupos) do
                if grp and grp:isExist() and grp:getID() == groupId then
                    local units = grp:getUnits() or {}
                    for _, unit in pairs(units) do
                        if unit and unit:isExist() then
                            local pname = unit:getPlayerName()
                            if pname and pname ~= "" then
                                return unit, grp
                            end
                        end
                    end
                    return nil, grp
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

function EscortMP.makeFollowTask(playerGroupId)
    return {
        id = "Follow",
        params = {
            groupId = playerGroupId,
            pos = {
                x = EscortMP.cfg.formacion.x,
                y = EscortMP.cfg.formacion.y,
                z = EscortMP.cfg.formacion.z
            },
            lastWptIndexFlag = false
        }
    }
end

function EscortMP.makeAttackGroupTask(targetGroupId)
    return {
        id = "AttackGroup",
        params = {
            groupId = targetGroupId
        }
    }
end

function EscortMP.getSearchCategoriesForSession(session)
    if session and session.escortCategory == "helicopter" then
        return {
            { Group.Category.HELICOPTER, Group.Category.GROUND },
            { Group.Category.AIRPLANE }
        }
    end

    return {
        { Group.Category.AIRPLANE, Group.Category.HELICOPTER },
        { Group.Category.GROUND }
    }
end

function EscortMP.findNearestEnemyGroupInCategories(enemySide, categories, refPoint, maxDistance)
    local mejorGrupo = nil
    local mejorDistancia = maxDistance or math.huge

    for _, categoria in ipairs(categories) do
        local grupos = coalition.getGroups(enemySide, categoria) or {}

        for _, grp in pairs(grupos) do
            if grp and grp:isExist() then
                local unidad = EscortMP.getFirstAliveUnitFromGroup(grp)
                if unidad and unidad:isExist() then
                    local p = unidad:getPoint()
                    local dist = EscortMP.get2DDistance(refPoint, p)

                    if dist <= mejorDistancia then
                        mejorDistancia = dist
                        mejorGrupo = grp
                    end
                end
            end
        end
    end

    return mejorGrupo, mejorDistancia
end

function EscortMP.configureEscortCombat(sessionKey, attackMode)
    local session = EscortMP.sessions[sessionKey]
    if not session then
        return
    end

    local escortGroup = Group.getByName(session.escortGroupName)
    if not escortGroup or not escortGroup:isExist() then
        return
    end

    local ctrl = escortGroup:getController()
    if not ctrl then
        return
    end

    if attackMode then
        ctrl:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.OPEN_FIRE)
    else
        ctrl:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.RETURN_FIRE)
    end

    ctrl:setOption(AI.Option.Air.id.RTB_ON_OUT_OF_AMMO, false)
    ctrl:setOption(AI.Option.Air.id.RTB_ON_BINGO, false)

    EscortMP.logCombat("Opciones de combate aplicadas a " .. tostring(session.escortGroupName) .. " | attackMode=" .. tostring(attackMode))
end

function EscortMP.applyFollowTask(sessionKey)
    local session = EscortMP.sessions[sessionKey]
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

    EscortMP.configureEscortCombat(sessionKey, false)
    ctrl:setTask(EscortMP.makeFollowTask(playerGroup:getID()))
    session.mode = "escort"
    session.currentTargetGroupName = nil
    session.currentTargetGroupId = nil

    EscortMP.logCombat("Modo escolta/formacion aplicado a " .. tostring(session.escortGroupName))
end

function EscortMP.applyAttackTask(sessionKey, targetGroup)
    local session = EscortMP.sessions[sessionKey]
    if not session then
        return
    end

    if not targetGroup or not targetGroup:isExist() then
        return
    end

    local escortGroup = Group.getByName(session.escortGroupName)
    if not escortGroup or not escortGroup:isExist() then
        return
    end

    local ctrl = escortGroup:getController()
    if not ctrl then
        return
    end

    EscortMP.configureEscortCombat(sessionKey, true)
    ctrl:setTask(EscortMP.makeAttackGroupTask(targetGroup:getID()))

    session.mode = "attack"
    session.currentTargetGroupName = targetGroup:getName()
    session.currentTargetGroupId = targetGroup:getID()

    EscortMP.logCombat("Atacando grupo enemigo: " .. tostring(session.currentTargetGroupName))
end

function EscortMP.getReferencePointForThreatSearch(session)
    local playerUnit = Unit.getByName(session.playerUnitName)
    if playerUnit and playerUnit:isExist() then
        return playerUnit:getPoint()
    end

    local escortUnit = Unit.getByName(session.escortUnitName)
    if escortUnit and escortUnit:isExist() then
        return escortUnit:getPoint()
    end

    return nil
end

function EscortMP.findNearestEnemyGroup(session)
    if not session then
        return nil, math.huge
    end

    local refPoint = EscortMP.getReferencePointForThreatSearch(session)
    if not refPoint then
        return nil, math.huge
    end

    local enemySide = EscortMP.getEnemyCoalition(session.playerCoalition)
    if not enemySide then
        return nil, math.huge
    end

    local rangoMaximo = EscortMP.nmToMeters(EscortMP.cfg.rangoEngancheNM)
    local gruposPorPrioridad = EscortMP.getSearchCategoriesForSession(session)

    for _, categorias in ipairs(gruposPorPrioridad) do
        local mejorGrupo, mejorDistancia = EscortMP.findNearestEnemyGroupInCategories(
            enemySide,
            categorias,
            refPoint,
            rangoMaximo
        )

        if mejorGrupo then
            return mejorGrupo, mejorDistancia
        end
    end

    return nil, math.huge
end

function EscortMP.isCurrentTargetStillValid(session)
    if not session or not session.currentTargetGroupName then
        return false
    end

    local targetGroup = Group.getByName(session.currentTargetGroupName)
    if not targetGroup or not targetGroup:isExist() then
        return false
    end

    local targetUnit = EscortMP.getFirstAliveUnitFromGroup(targetGroup)
    if not targetUnit or not targetUnit:isExist() then
        return false
    end

    local refPoint = EscortMP.getReferencePointForThreatSearch(session)
    if not refPoint then
        return false
    end

    local dist = EscortMP.get2DDistance(refPoint, targetUnit:getPoint())
    local maxDist = EscortMP.nmToMeters(EscortMP.cfg.rangoPerderObjetivoNM)

    return dist <= maxDist
end

function EscortMP.monitorThreats()
    for sessionKey, session in pairs(EscortMP.sessions) do
        local escortGroup = Group.getByName(session.escortGroupName)
        local escortUnit = Unit.getByName(session.escortUnitName)
        local playerUnit = Unit.getByName(session.playerUnitName)

        if escortGroup and escortGroup:isExist() and escortUnit and escortUnit:isExist() and playerUnit and playerUnit:isExist() then
            if session.mode == "attack" then
                if not EscortMP.isCurrentTargetStillValid(session) then
                    EscortMP.applyFollowTask(sessionKey)
                end
            end

            if session.mode ~= "attack" then
                local enemyGroup, dist = EscortMP.findNearestEnemyGroup(session)
                if enemyGroup and enemyGroup:isExist() then
                    EscortMP.logCombat("Amenaza encontrada a " .. string.format("%.0f", dist) .. " m para " .. tostring(session.escortGroupName))
                    EscortMP.applyAttackTask(sessionKey, enemyGroup)
                end
            else
                local targetGroup = Group.getByName(session.currentTargetGroupName)
                if targetGroup and targetGroup:isExist() then
                    local nearestGroup, dist = EscortMP.findNearestEnemyGroup(session)
                    if nearestGroup and nearestGroup:isExist() and nearestGroup:getName() ~= session.currentTargetGroupName then
                        if dist <= EscortMP.nmToMeters(EscortMP.cfg.rangoEngancheNM) then
                            EscortMP.applyAttackTask(sessionKey, nearestGroup)
                        end
                    end
                end
            end
        end
    end

    return timer.getTime() + EscortMP.cfg.chequeoAmenazaSegundos
end

function EscortMP.removeEscortNow(sessionKey, reason, silent)
    local session = EscortMP.sessions[sessionKey]
    if not session then
        return
    end

    local groupId = EscortMP.getSessionGroupId(session)

    local escortGroup = Group.getByName(session.escortGroupName)
    if escortGroup and escortGroup:isExist() then
        escortGroup:destroy()
    end

    EscortMP.sessions[sessionKey] = nil

    if silent then
        if reason then
            EscortMP.msg(groupId, reason, 5)
        end
    else
        EscortMP.msg(groupId, EscortMP.cfg.mensajes.quitada, 5)
    end

    EscortMP.log("Escolta removida de sessionKey " .. tostring(sessionKey))
end

function EscortMP.scheduleDestroy(sessionKey, delay, reason)
    local session = EscortMP.sessions[sessionKey]
    if not session then
        return
    end

    if session.destroyScheduled then
        return
    end

    session.destroyScheduled = true

    timer.scheduleFunction(function(arg, time)
        EscortMP.removeEscortNow(arg.sessionKey, arg.reason, true)
        return nil
    end, { sessionKey = sessionKey, reason = reason }, timer.getTime() + (delay or EscortMP.cfg.borrarTrasMuerteJugador))
end

function EscortMP.removeEscortCommand(groupId)
    local sessionKey = EscortMP.getSessionByGroupId(groupId)
    if not sessionKey then
        return
    end
    EscortMP.removeEscortNow(sessionKey, EscortMP.cfg.mensajes.quitada, false)
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

    local sessionKey = playerUnit:getName()
    local existing = EscortMP.sessions[sessionKey]
    if existing then
        local g = Group.getByName(existing.escortGroupName)
        if g and g:isExist() then
            EscortMP.msg(groupId, EscortMP.cfg.mensajes.yaActiva, 5)
            return
        else
            EscortMP.sessions[sessionKey] = nil
        end
    end

    local groupData, err = EscortMP.makeEscortGroupData(playerUnit, playerGroup, groupId)
    if not groupData then
        EscortMP.msg(groupId, err or "No se pudo crear la escolta.", 5)
        return
    end

    local newGroup = mist.dynAdd(groupData)
    if not newGroup then
        EscortMP.msg(groupId, "No se pudo spawnear la escolta.", 5)
        return
    end

    EscortMP.sessions[sessionKey] = {
        groupId = groupId,
        currentGroupId = groupId,
        playerUnitName = playerUnit:getName(),
        playerGroupName = playerGroup:getName(),
        playerName = playerName,
        playerCoalition = playerUnit:getCoalition(),
        escortCategory = groupData.category,
        escortGroupName = groupData.groupName,
        escortUnitName = groupData.units[1].unitName,
        playerWasAirborne = playerUnit:inAir(),
        destroyScheduled = false,
        mode = "escort",
        currentTargetGroupName = nil,
        currentTargetGroupId = nil
    }

    timer.scheduleFunction(function(arg, time)
        EscortMP.applyFollowTask(arg.sessionKey)
        return nil
    end, { sessionKey = sessionKey }, timer.getTime() + 0.5)

    timer.scheduleFunction(function(arg, time)
        EscortMP.configureEscortCombat(arg.sessionKey, false)
        EscortMP.applyFollowTask(arg.sessionKey)
        return nil
    end, { sessionKey = sessionKey }, timer.getTime() + 2)

    EscortMP.msg(groupId, EscortMP.cfg.mensajes.creada, 5)
    EscortMP.log("Escolta creada para " .. tostring(playerName) .. " groupId " .. tostring(groupId))
end

function EscortMP.housekeeping()
    for sessionKey, session in pairs(EscortMP.sessions) do
        local playerUnit = Unit.getByName(session.playerUnitName)
        local escortGroup = Group.getByName(session.escortGroupName)
        local escortUnit = Unit.getByName(session.escortUnitName)
        local groupId = EscortMP.getSessionGroupId(session)

        if not escortGroup or not escortGroup:isExist() or not escortUnit or not escortUnit:isExist() then
            EscortMP.sessions[sessionKey] = nil
            EscortMP.msg(groupId, EscortMP.cfg.mensajes.destruida, 5)
        else
            local ammoLeft = EscortMP.getAmmoCount(escortUnit)

            if ammoLeft <= 0 then
                EscortMP.removeEscortNow(sessionKey, EscortMP.cfg.mensajes.sinMunicion, true)
            else
                if playerUnit and playerUnit:isExist() then
                    local pname = playerUnit:getPlayerName()

                    if pname and pname ~= "" then
                        if playerUnit:inAir() then
                            session.playerWasAirborne = true
                        end

                        if session.playerWasAirborne and not playerUnit:inAir() then
                            EscortMP.removeEscortNow(sessionKey, EscortMP.cfg.mensajes.aterrizaje, true)
                        end
                    else
                        EscortMP.scheduleDestroy(sessionKey, EscortMP.cfg.borrarTrasMuerteJugador, EscortMP.cfg.mensajes.muerteJugador)
                    end
                else
                    EscortMP.scheduleDestroy(sessionKey, EscortMP.cfg.borrarTrasMuerteJugador, EscortMP.cfg.mensajes.muerteJugador)
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
            local grupos = coalition.getGroups(lado, categoria) or {}
            for _, grp in pairs(grupos) do
                if grp and grp:isExist() then
                    local units = grp:getUnits() or {}
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

function EscortMP.scanActivePlayers()
    local lados = {
        coalition.side.BLUE,
        coalition.side.RED,
        coalition.side.NEUTRAL
    }

    local categorias = {
        Group.Category.AIRPLANE,
        Group.Category.HELICOPTER
    }

    local activeGroups = {}

    for _, lado in ipairs(lados) do
        for _, categoria in ipairs(categorias) do
            local grupos = coalition.getGroups(lado, categoria) or {}

            for _, grp in pairs(grupos) do
                if grp and grp:isExist() then
                    local units = grp:getUnits() or {}

                    for _, unit in pairs(units) do
                        if unit and unit:isExist() then
                            local pname = unit:getPlayerName()
                            if pname and pname ~= "" then
                                local gid = grp:getID()
                                activeGroups[gid] = true
                                EscortMP.buildMenuForUnit(unit)
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    EscortMP.cleanupOrphanMenus(activeGroups)

    return timer.getTime() + EscortMP.cfg.escaneoMenuSegundos
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
            local sessionKey = EscortMP.getSessionByGroupId(groupId)
            EscortMP.clearMenu(groupId)
            if sessionKey then
                EscortMP.scheduleDestroy(sessionKey, EscortMP.cfg.borrarTrasMuerteJugador, EscortMP.cfg.mensajes.muerteJugador)
            end
        end
        return
    end

    local sessionKey, session = EscortMP.getSessionByUnitName(unitName)
    if not session then
        return
    end

    local groupId = EscortMP.getSessionGroupId(session)

    if event.id == world.event.S_EVENT_LAND then
        if unitName == session.playerUnitName then
            EscortMP.removeEscortNow(sessionKey, EscortMP.cfg.mensajes.aterrizaje, true)
        end
        return
    end

    if event.id == world.event.S_EVENT_DEAD
    or event.id == world.event.S_EVENT_CRASH
    or event.id == world.event.S_EVENT_EJECTION
    or (world.event.S_EVENT_PILOT_DEAD and event.id == world.event.S_EVENT_PILOT_DEAD) then

        if unitName == session.playerUnitName then
            EscortMP.scheduleDestroy(sessionKey, EscortMP.cfg.borrarTrasMuerteJugador, EscortMP.cfg.mensajes.muerteJugador)
        elseif unitName == session.escortUnitName then
            EscortMP.sessions[sessionKey] = nil
            EscortMP.msg(groupId, EscortMP.cfg.mensajes.destruida, 5)
        elseif session.currentTargetGroupName and Group.getByName(session.currentTargetGroupName) == nil then
            EscortMP.applyFollowTask(sessionKey)
        end
    end
end

function EscortMP.start()
    if EscortMP.started then
        return
    end

    if not mist then
        env.info("[EscortMP] MIST aun no esta cargado. Reintentando...")
        timer.scheduleFunction(function()
            EscortMP.start()
            return nil
        end, {}, timer.getTime() + 1)
        return
    end

    EscortMP.started = true
    env.info("[EscortMP] Inicio correcto")

    world.addEventHandler(EscortMP.eventHandler)

    timer.scheduleFunction(function()
        EscortMP.bootstrapMenus()
        return nil
    end, {}, timer.getTime() + 1)

    timer.scheduleFunction(function()
        return EscortMP.scanActivePlayers()
    end, {}, timer.getTime() + 2)

    timer.scheduleFunction(function()
        return EscortMP.housekeeping()
    end, {}, timer.getTime() + EscortMP.cfg.chequeoSegundos)

    timer.scheduleFunction(function()
        return EscortMP.monitorThreats()
    end, {}, timer.getTime() + EscortMP.cfg.chequeoAmenazaSegundos)
end

EscortMP.start()
