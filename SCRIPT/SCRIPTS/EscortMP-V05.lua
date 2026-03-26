EscortMP = {}

EscortMP.cfg = {
    debug = true,
    debugToAll = false,
    prefix = "[EscortMP] ",
    debugPrefix = "[EscortMP DEBUG] ",

    menuRoot = "Sistema de Escolta",
    menuCreate = "Desplegar escolta",
    menuStatus = "Estado de escolta",
    menuRemove = "Retirar escolta",

    rangoAvisoNM = 4,
    rangoAtaqueNM = 2,

    chequeoSegundos = 2,
    refrescoAtaqueSeg = 10,
    rejoinDelaySeg = 6,
    cooldownAvisoSeg = 20,

    borrarTrasSalirJugador = 5,
    borrarTrasRTB = 120,
    retardoAplicarFollow = 1,

    minAGLParaCrear = 5,

    spawnDerecha = 80,
    spawnAtras = 120,
    spawnVertical = 20,
    alturaSpawnEnSuelo = 300,

    formacion = {
        x = 120,
        y = 0,
        z = 40
    },

    nombreFormacion = "Echelon Right",

    velocidadMinPlane = 170,
    velocidadMinHeli = 60,

    skillPlane = "High",
    skillHeli = "High",

    mensajes = {
        yaActiva = "Ya tienes una escolta activa.",
        creada = "Escolta desplegada y asignada.",
        quitada = "Escolta eliminada.",
        sinJugador = "No se detecto un jugador valido en este grupo.",
        noCompatible = "La escolta solo funciona con aviones y helicopteros.",
        sinDB = "No se pudo leer la unidad en la base de datos de MIST.",
        destruida = "Tu escolta fue destruida. Ya puedes pedir otra.",
        sinMunicion = "La escolta se queda sin armamento, entra en RTB y sera retirada en 120 segundos.",
        muerteJugador = "La escolta se retira porque el jugador ya no esta disponible.",
        alturaInsuficiente = "No puedes crear la escolta entre 0 y 5 AGL.",
        avisoContacto = "Escolta: contacto detectado a menos de 4 NM.",
        entrandoCombate = "Escolta: objetivo dentro de 2 NM, atacando.",
        rejoin = "Escolta: regresando a formacion con el jugador.",
        sinEscolta = "No tienes una escolta activa.",
        estadoRTB = "La escolta esta en RTB.",
        payloadClonado = "Payload copiado desde MIST.",
        payloadFallback = "No se pudo clonar el payload exacto; se usa fallback por tipo y datos de MIST."
    }
}

EscortMP.sessions = {}
EscortMP.menus = {}

function EscortMP.log(txt)
    if not EscortMP.cfg.debug then
        return
    end

    local msg = EscortMP.cfg.prefix .. tostring(txt)
    env.info(msg)

    if EscortMP.cfg.debugToAll then
        trigger.action.outText(msg, 5)
    end
end

function EscortMP.msg(groupId, txt, duracion)
    if groupId and txt then
        trigger.action.outTextForGroup(groupId, txt, duracion or 5)
    end
end

function EscortMP.debugMsg(groupId, txt, duracion)
    if not EscortMP.cfg.debug then
        return
    end
    EscortMP.msg(groupId, EscortMP.cfg.debugPrefix .. tostring(txt), duracion or 5)
end

function EscortMP.nmToMeters(nm)
    return nm * 1852
end

function EscortMP.safeGroup(groupName)
    if not groupName then
        return nil
    end

    local grp = Group.getByName(groupName)
    if grp and grp:isExist() then
        return grp
    end

    return nil
end

function EscortMP.safeUnit(unitName)
    if not unitName then
        return nil
    end

    local unit = Unit.getByName(unitName)
    if unit and unit:isExist() then
        return unit
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

    local pos = unit:getPosition()
    if not pos then
        return 0
    end

    return math.atan2(pos.x.z, pos.x.x)
end

function EscortMP.getSpeed(unit)
    if not unit or not unit:isExist() then
        return 0
    end

    local v = unit:getVelocity()
    if not v then
        return 0
    end

    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

function EscortMP.distance2D(a, b)
    local dx = a.x - b.x
    local dz = a.z - b.z
    return math.sqrt(dx * dx + dz * dz)
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
    missionCommands.addCommandForGroup(groupId, EscortMP.cfg.menuStatus, root, EscortMP.statusEscort, groupId)
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

function EscortMP.getEnemySides(side)
    if side == coalition.side.BLUE then
        return { coalition.side.RED }
    elseif side == coalition.side.RED then
        return { coalition.side.BLUE }
    else
        return { coalition.side.BLUE, coalition.side.RED }
    end
end

function EscortMP.tryGetPayload(playerUnit, playerGroup)
    if not mist then
        return nil, false
    end

    local unitName = playerUnit:getName()
    if mist.getPayload then
        local ok, payload = pcall(mist.getPayload, unitName)
        if ok and type(payload) == "table" and next(payload) ~= nil then
            return payload, true
        end
    end

    if mist.getGroupPayload and playerGroup then
        local ok, payloads = pcall(mist.getGroupPayload, playerGroup:getName())
        if ok and type(payloads) == "table" then
            local unitNumber = playerUnit:getNumber() or 1
            if payloads[unitNumber] and next(payloads[unitNumber]) ~= nil then
                return payloads[unitNumber], true
            end
            if payloads[1] and next(payloads[1]) ~= nil then
                return payloads[1], true
            end
        end
    end

    return nil, false
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

function EscortMP.safeSetOption(ctrl, optionId, optionValue)
    if not ctrl or optionId == nil or optionValue == nil then
        return
    end

    pcall(function()
        ctrl:setOption(optionId, optionValue)
    end)
end

function EscortMP.setAirBehaviorOptions(ctrl)
    if not ctrl then
        return
    end

    if AI and AI.Option and AI.Option.Air and AI.Option.Air.id and AI.Option.Air.val then
        if AI.Option.Air.id.ROE and AI.Option.Air.val.ROE and AI.Option.Air.val.ROE.OPEN_FIRE_WEAPON_FREE then
            EscortMP.safeSetOption(ctrl, AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.OPEN_FIRE_WEAPON_FREE)
        end

        if AI.Option.Air.id.REACTION_ON_THREAT and AI.Option.Air.val.REACTION_ON_THREAT and AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE then
            EscortMP.safeSetOption(ctrl, AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
        end

        if AI.Option.Air.id.PROHIBIT_AA ~= nil then
            EscortMP.safeSetOption(ctrl, AI.Option.Air.id.PROHIBIT_AA, false)
        end

        if AI.Option.Air.id.PROHIBIT_AG ~= nil then
            EscortMP.safeSetOption(ctrl, AI.Option.Air.id.PROHIBIT_AG, false)
        end

        if AI.Option.Air.id.ALLOW_FORMATION_SIDE_SWAP ~= nil then
            EscortMP.safeSetOption(ctrl, AI.Option.Air.id.ALLOW_FORMATION_SIDE_SWAP, false)
        end

        if AI.Option.Air.id.RTB_ON_OUT_OF_AMMO ~= nil and Weapon and Weapon.flag then
            EscortMP.safeSetOption(ctrl, AI.Option.Air.id.RTB_ON_OUT_OF_AMMO, Weapon.flag.AnyWeapon or Weapon.flag.ArmWeapon)
        end
    end
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
            lastWptIndexFlag = false,
            formation = EscortMP.cfg.nombreFormacion
        }
    }
end

function EscortMP.makeAttackTask(targetGroupId)
    local params = {
        groupId = targetGroupId,
        attackQtyLimit = false,
        directionEnabled = false
    }

    if AI and AI.Task and AI.Task.WeaponExpend and AI.Task.WeaponExpend.ALL then
        params.expend = AI.Task.WeaponExpend.ALL
    end

    if Weapon and Weapon.flag and Weapon.flag.AnyWeapon then
        params.weaponType = Weapon.flag.AnyWeapon
    end

    return {
        id = "AttackGroup",
        params = params
    }
end

function EscortMP.applyFollowTask(groupId)
    local session = EscortMP.sessions[groupId]
    if not session then
        return false
    end

    local escortGroup = EscortMP.safeGroup(session.escortGroupName)
    local playerGroup = EscortMP.safeGroup(session.playerGroupName)

    if not escortGroup or not playerGroup then
        return false
    end

    local ctrl = escortGroup:getController()
    if not ctrl then
        return false
    end

    EscortMP.setAirBehaviorOptions(ctrl)
    ctrl:setTask(EscortMP.makeFollowTask(playerGroup:getID()))

    session.state = "ESCORT"
    session.targetGroupName = nil
    session.lastFollowApplied = timer.getTime()

    EscortMP.debugMsg(groupId, "Follow aplicado a " .. tostring(session.escortGroupName), 4)
    return true
end

function EscortMP.pushAttackTask(groupId, targetGroup)
    local session = EscortMP.sessions[groupId]
    if not session then
        return false
    end

    local escortGroup = EscortMP.safeGroup(session.escortGroupName)
    if not escortGroup or not targetGroup or not targetGroup:isExist() then
        return false
    end

    local ctrl = escortGroup:getController()
    if not ctrl then
        return false
    end

    EscortMP.setAirBehaviorOptions(ctrl)
    ctrl:pushTask(EscortMP.makeAttackTask(targetGroup:getID()))

    session.state = "ATTACK"
    session.targetGroupName = targetGroup:getName()
    session.lastAttackPush = timer.getTime()

    EscortMP.debugMsg(groupId, "AttackGroup enviado a " .. tostring(session.targetGroupName), 4)
    return true
end

function EscortMP.getCombatAmmoCount(unit)
    if not unit or not unit:isExist() then
        return 0
    end

    local ammo = unit:getAmmo()
    if not ammo then
        return 0
    end

    local total = 0

    for _, item in pairs(ammo) do
        if item and item.count and item.count > 0 then
            local incluir = true

            if item.desc and item.desc.category ~= nil and Weapon and Weapon.Category then
                local c = item.desc.category
                incluir =
                    (c == Weapon.Category.SHELL) or
                    (c == Weapon.Category.MISSILE) or
                    (c == Weapon.Category.ROCKET) or
                    (c == Weapon.Category.BOMB)
            end

            if incluir then
                total = total + item.count
            end
        end
    end

    return total
end

function EscortMP.findNearestThreat(session)
    local escortUnit = EscortMP.safeUnit(session.escortUnitName)
    if not escortUnit then
        return nil
    end

    local escortPos = escortUnit:getPoint()
    local detectRange = EscortMP.nmToMeters(EscortMP.cfg.rangoAvisoNM)

    local categorias = {
        Group.Category.AIRPLANE,
        Group.Category.HELICOPTER,
        Group.Category.GROUND,
        Group.Category.SHIP
    }

    local best = nil

    for _, side in ipairs(session.enemySides) do
        for _, cat in ipairs(categorias) do
            local grupos = coalition.getGroups(side, cat)
            if grupos then
                for _, grp in pairs(grupos) do
                    if grp and grp:isExist() then
                        local units = grp:getUnits()
                        if units then
                            for _, enemyUnit in pairs(units) do
                                if enemyUnit and enemyUnit:isExist() and enemyUnit:getLife() > 1 then
                                    local dist = EscortMP.distance2D(escortPos, enemyUnit:getPoint())
                                    if dist <= detectRange then
                                        if not best or dist < best.dist then
                                            best = {
                                                group = grp,
                                                unit = enemyUnit,
                                                dist = dist
                                            }
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

    return best
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

    local groupCategory = Group.Category.AIRPLANE
    local skill = EscortMP.cfg.skillPlane
    local minSpeed = EscortMP.cfg.velocidadMinPlane
    local mainTask = "CAP"

    if category == "helicopter" then
        groupCategory = Group.Category.HELICOPTER
        skill = EscortMP.cfg.skillHeli
        minSpeed = EscortMP.cfg.velocidadMinHeli
        mainTask = "CAS"
    end

    local spawnX, spawnZ, spawnAlt = EscortMP.makeSpawnPoint(playerUnit)
    local heading = EscortMP.getHeadingFromUnit(playerUnit)
    local finalSpeed = math.max(EscortMP.getSpeed(playerUnit), minSpeed)

    local uniqueId = tostring(groupId) .. "_" .. tostring(math.floor(timer.getTime() * 100))
    local escortGroupName = "ESCORT_MP_" .. uniqueId
    local escortUnitName = escortGroupName .. "_1"

    local newGroupId = (mist and mist.getNextGroupId and mist.getNextGroupId()) or math.random(70000, 90000)
    local newUnitId = (mist and mist.getNextUnitId and mist.getNextUnitId()) or math.random(70000, 90000)

    local payload, payloadClonado = EscortMP.tryGetPayload(playerUnit, playerGroup)

    local unitData = {
        unitId = newUnitId,
        name = escortUnitName,
        type = playerUnit:getTypeName(),
        skill = skill,
        x = spawnX,
        y = spawnZ,
        alt = spawnAlt,
        alt_type = "BARO",
        speed = finalSpeed,
        heading = heading,
        playerCanDrive = false
    }

    if db.livery_id then
        unitData.livery_id = db.livery_id
    end

    if db.AddPropAircraft then
        unitData.AddPropAircraft = db.AddPropAircraft
    end

    if db.onboard_num then
        unitData.onboard_num = db.onboard_num
    end

    if db.hardpoint_racks ~= nil then
        unitData.hardpoint_racks = db.hardpoint_racks
    end

    if db.psi then
        unitData.psi = db.psi
    end

    if db.callsign then
        unitData.callsign = db.callsign
    end

    if payloadClonado and payload then
        unitData.payload = payload
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

    local groupData = {
        groupId = newGroupId,
        visible = false,
        hidden = false,
        lateActivation = false,
        task = mainTask,
        name = escortGroupName,
        route = {
            points = {
                [1] = routePoint
            }
        },
        units = {
            [1] = unitData
        }
    }

    return {
        countryId = db.countryId or playerUnit:getCountry(),
        groupCategory = groupCategory,
        groupData = groupData,
        escortGroupName = escortGroupName,
        escortUnitName = escortUnitName,
        payloadClonado = payloadClonado,
        unitCategory = category
    }, nil
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
    end, {
        groupId = groupId,
        reason = reason
    }, timer.getTime() + (delay or EscortMP.cfg.borrarTrasSalirJugador))
end

function EscortMP.removeEscortNow(groupId, reason, silent)
    local session = EscortMP.sessions[groupId]
    if not session then
        return
    end

    local escortGroup = EscortMP.safeGroup(session.escortGroupName)
    if escortGroup then
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

function EscortMP.statusEscort(groupId)
    local session = EscortMP.sessions[groupId]
    if not session then
        EscortMP.msg(groupId, EscortMP.cfg.mensajes.sinEscolta, 5)
        return
    end

    local escortUnit = EscortMP.safeUnit(session.escortUnitName)
    if not escortUnit then
        EscortMP.msg(groupId, EscortMP.cfg.mensajes.destruida, 5)
        EscortMP.sessions[groupId] = nil
        return
    end

    local ammo = EscortMP.getCombatAmmoCount(escortUnit)
    local txt = "Estado: " .. tostring(session.state) ..
        " | Grupo: " .. tostring(session.escortGroupName) ..
        " | Armamento: " .. tostring(ammo)

    if session.targetGroupName then
        txt = txt .. " | Objetivo: " .. tostring(session.targetGroupName)
    end

    EscortMP.msg(groupId, txt, 8)
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
        local escortGroup = EscortMP.safeGroup(existing.escortGroupName)
        if escortGroup then
            EscortMP.msg(groupId, EscortMP.cfg.mensajes.yaActiva, 5)
            return
        else
            EscortMP.sessions[groupId] = nil
        end
    end

    local spawnInfo, err = EscortMP.makeEscortGroupData(playerUnit, playerGroup, groupId)
    if not spawnInfo then
        EscortMP.msg(groupId, err or EscortMP.cfg.mensajes.sinDB, 5)
        return
    end

    local spawnedGroup = coalition.addGroup(
        spawnInfo.countryId,
        spawnInfo.groupCategory,
        spawnInfo.groupData
    )

    if not spawnedGroup then
        EscortMP.msg(groupId, "No se pudo crear la escolta.", 5)
        return
    end

    EscortMP.sessions[groupId] = {
        groupId = groupId,
        playerName = playerName,
        playerUnitName = playerUnit:getName(),
        playerGroupName = playerGroup:getName(),
        playerCoalition = playerUnit:getCoalition(),
        enemySides = EscortMP.getEnemySides(playerUnit:getCoalition()),

        escortGroupName = spawnInfo.escortGroupName,
        escortUnitName = spawnInfo.escortUnitName,
        escortCategory = spawnInfo.unitCategory,
        payloadClonado = spawnInfo.payloadClonado,

        state = "SPAWN",
        targetGroupName = nil,
        destroyScheduled = false,
        rtbStarted = false,

        lastAttackPush = 0,
        lastFollowApplied = 0,
        lastAviso = 0,
        lastThreatName = nil
    }

    timer.scheduleFunction(function(arg, time)
        EscortMP.applyFollowTask(arg.groupId)
        return nil
    end, { groupId = groupId }, timer.getTime() + EscortMP.cfg.retardoAplicarFollow)

    EscortMP.msg(groupId, EscortMP.cfg.mensajes.creada, 5)

    if spawnInfo.payloadClonado then
        EscortMP.msg(groupId, EscortMP.cfg.mensajes.payloadClonado, 5)
    else
        EscortMP.msg(groupId, EscortMP.cfg.mensajes.payloadFallback, 6)
    end

    EscortMP.log("Escolta creada para " .. tostring(playerName) .. " | " .. tostring(spawnInfo.escortGroupName))
end

function EscortMP.handleThreatLogic(session)
    local escortGroup = EscortMP.safeGroup(session.escortGroupName)
    local escortUnit = EscortMP.safeUnit(session.escortUnitName)

    if not escortGroup or not escortUnit then
        return
    end

    local threat = EscortMP.findNearestThreat(session)
    local now = timer.getTime()

    if threat then
        if (session.lastThreatName ~= threat.group:getName()) or ((now - session.lastAviso) >= EscortMP.cfg.cooldownAvisoSeg) then
            EscortMP.msg(session.groupId, EscortMP.cfg.mensajes.avisoContacto, 5)
            session.lastAviso = now
            session.lastThreatName = threat.group:getName()
        end

        if threat.dist <= EscortMP.nmToMeters(EscortMP.cfg.rangoAtaqueNM) then
            local necesitaAtaque = false

            if session.state ~= "ATTACK" then
                necesitaAtaque = true
            elseif session.targetGroupName ~= threat.group:getName() then
                necesitaAtaque = true
            elseif (now - (session.lastAttackPush or 0)) >= EscortMP.cfg.refrescoAtaqueSeg then
                necesitaAtaque = true
            end

            if necesitaAtaque then
                if EscortMP.pushAttackTask(session.groupId, threat.group) then
                    EscortMP.msg(session.groupId, EscortMP.cfg.mensajes.entrandoCombate, 5)
                end
            end

            return
        else
            if session.state == "ATTACK" and session.targetGroupName == threat.group:getName() then
                return
            end
        end
    end

    if session.state == "ATTACK" then
        if (now - (session.lastAttackPush or 0)) >= EscortMP.cfg.rejoinDelaySeg then
            if EscortMP.applyFollowTask(session.groupId) then
                EscortMP.msg(session.groupId, EscortMP.cfg.mensajes.rejoin, 5)
            end
        end
    elseif session.state == "SPAWN" then
        EscortMP.applyFollowTask(session.groupId)
    end
end

function EscortMP.housekeeping(_, time)
    for groupId, session in pairs(EscortMP.sessions) do
        local playerUnit = EscortMP.safeUnit(session.playerUnitName)
        local escortGroup = EscortMP.safeGroup(session.escortGroupName)
        local escortUnit = EscortMP.safeUnit(session.escortUnitName)

        if not escortGroup or not escortUnit then
            EscortMP.sessions[groupId] = nil
            EscortMP.msg(groupId, EscortMP.cfg.mensajes.destruida, 5)
        else
            if not playerUnit then
                EscortMP.scheduleDestroy(groupId, EscortMP.cfg.borrarTrasSalirJugador, EscortMP.cfg.mensajes.muerteJugador)
            else
                local pname = playerUnit:getPlayerName()
                if not pname or pname == "" then
                    EscortMP.scheduleDestroy(groupId, EscortMP.cfg.borrarTrasSalirJugador, EscortMP.cfg.mensajes.muerteJugador)
                else
                    local combatAmmo = EscortMP.getCombatAmmoCount(escortUnit)

                    if combatAmmo <= 0 then
                        if not session.rtbStarted then
                            session.rtbStarted = true
                            session.state = "RTB"
                            session.targetGroupName = nil
                            EscortMP.msg(groupId, EscortMP.cfg.mensajes.sinMunicion, 8)
                            EscortMP.scheduleDestroy(groupId, EscortMP.cfg.borrarTrasRTB, EscortMP.cfg.mensajes.quitada)
                        end
                    else
                        if session.state ~= "RTB" then
                            EscortMP.handleThreatLogic(session)
                        end
                    end
                end
            end
        end
    end

    return time + EscortMP.cfg.chequeoSegundos
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
            EscortMP.scheduleDestroy(groupId, EscortMP.cfg.borrarTrasSalirJugador, EscortMP.cfg.mensajes.muerteJugador)
        end
        return
    end

    local groupId, session = EscortMP.getSessionByUnitName(unitName)
    if not session then
        return
    end

    if event.id == world.event.S_EVENT_DEAD or event.id == world.event.S_EVENT_CRASH or event.id == world.event.S_EVENT_EJECTION then
        if unitName == session.playerUnitName then
            EscortMP.scheduleDestroy(groupId, EscortMP.cfg.borrarTrasSalirJugador, EscortMP.cfg.mensajes.muerteJugador)
        elseif unitName == session.escortUnitName then
            EscortMP.sessions[groupId] = nil
            EscortMP.msg(groupId, EscortMP.cfg.mensajes.destruida, 5)
        end
        return
    end

    if world.event.S_EVENT_PILOT_DEAD and event.id == world.event.S_EVENT_PILOT_DEAD then
        if unitName == session.playerUnitName then
            EscortMP.scheduleDestroy(groupId, EscortMP.cfg.borrarTrasSalirJugador, EscortMP.cfg.mensajes.muerteJugador)
        elseif unitName == session.escortUnitName then
            EscortMP.sessions[groupId] = nil
            EscortMP.msg(groupId, EscortMP.cfg.mensajes.destruida, 5)
        end
        return
    end
end

world.addEventHandler(EscortMP.eventHandler)

timer.scheduleFunction(function(_, t)
    EscortMP.bootstrapMenus()
    return nil
end, nil, timer.getTime() + 1)

timer.scheduleFunction(EscortMP.housekeeping, nil, timer.getTime() + EscortMP.cfg.chequeoSegundos)

EscortMP.log("Script cargado correctamente")