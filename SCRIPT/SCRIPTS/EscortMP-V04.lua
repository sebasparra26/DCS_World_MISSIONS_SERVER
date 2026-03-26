EscortMP = EscortMP or {}

do
    if not mist then
        env.error("[EscortMP] MIST no esta cargado. Este script debe ir despues de mist_4_5_128.lua")
        return
    end

    EscortMP.cfg = {
        DEBUG = true,
        DEBUG_TO_ALL = false,

        MENU_ROOT = "Escolta IA",
        MENU_CMD_SPAWN = "Desplegar escolta",
        MENU_CMD_REMOVE = "Eliminar escolta",
        MENU_CMD_STATUS = "Estado de escolta",

        CHECK_INTERVAL = 2,
        RESYNC_INTERVAL = 5,

        ANNOUNCE_RANGE_NM = 4,
        ATTACK_RANGE_NM = 2,
        ANNOUNCE_RANGE_M = 4 * 1852,
        ATTACK_RANGE_M = 2 * 1852,

        MIN_SPAWN_AGL_FEET = 5,
        MIN_SPAWN_AGL_M = 5 * 0.3048,

        RTB_DESPAWN_SECONDS = 120,

        ESCORT_SKILL = "High",

        SPAWN_OFFSET_BACK_M = -120,
        SPAWN_OFFSET_RIGHT_M = 180,
        SPAWN_OFFSET_UP_M = 20,

        FORMATION_FIXEDWING_ECHELON_RIGHT = 262145,
        FORMATION_HELO_ECHELON_RIGHT = 589825,

        TARGET_TYPES = {
            "Air",
            "Ground Units",
            "Ships"
        },

        MIN_SPEED_PLANE_MPS = 140,
        MIN_SPEED_HELO_MPS = 35,

        SECOND_WP_AHEAD_M = 10000,

        MESSAGE_TIME = 6,
        STATUS_TIME = 10,

        -- Si MIST/DCS no logra resolver el payload del slot dinamico,
        -- puedes definir payloads manuales por tipo aqui.
        -- Ejemplo:
        -- ["F-16C_50"] = {
        --     pylons = {
        --         [1] = { CLSID = "{AIM-120C}" },
        --         [2] = { CLSID = "{AIM-9X}" },
        --     },
        --     fuel = 3249,
        --     flare = 60,
        --     chaff = 60,
        --     gun = 100
        -- }
        FALLBACK_PAYLOAD_BY_TYPE = {}
    }

    EscortMP.state = {
        owners = {},                 -- [ownerUnitName] = state
        playerToOwner = {},          -- [playerName] = ownerUnitName
        menus = {},                  -- [groupId] = { root = path }
        ownerByEscortGroup = {},     -- [escortGroupName] = ownerUnitName
        seq = 1
    }

    EscortMP.util = {}
    EscortMP.menu = {}
    EscortMP.ai = {}
    EscortMP.monitor = {}
    EscortMP.events = {}

    local cfg = EscortMP.cfg
    local state = EscortMP.state

    function EscortMP.util.deepcopy(tbl)
        return mist.utils.deepCopy(tbl)
    end

    function EscortMP.util.debug(msg, ownerUnitName)
        if not cfg.DEBUG then
            return
        end

        local text = "[EscortMP] " .. tostring(msg)

        if cfg.DEBUG_TO_ALL then
            trigger.action.outText(text, 5)
            return
        end

        if ownerUnitName then
            local st = state.owners[ownerUnitName]
            if st and st.ownerGroupId then
                trigger.action.outTextForGroup(st.ownerGroupId, text, 5)
                return
            end
        end

        trigger.action.outText(text, 5)
    end

    function EscortMP.util.msgToOwner(ownerUnitName, msg, time)
        local st = state.owners[ownerUnitName]
        if st and st.ownerGroupId then
            trigger.action.outTextForGroup(st.ownerGroupId, msg, time or cfg.MESSAGE_TIME)
        end
    end

    function EscortMP.util.sanitize(str)
        str = tostring(str or "Escort")
        str = string.gsub(str, "[^%w_]", "_")
        str = string.gsub(str, "_+", "_")
        return str
    end

    function EscortMP.util.getUnitGroup(unit)
        if not unit or not unit:isExist() then
            return nil
        end
        return unit:getGroup()
    end

    function EscortMP.util.getGroupId(group)
        if not group or not group:isExist() then
            return nil
        end
        return group:getID()
    end

    function EscortMP.util.getOwnerUnit(ownerUnitName)
        local unit = Unit.getByName(ownerUnitName)
        if unit and unit:isExist() then
            return unit
        end
        return nil
    end

    function EscortMP.util.getPlayerName(unit)
        if not unit or not unit:isExist() then
            return nil
        end
        local name = unit:getPlayerName()
        if name and name ~= "" then
            return name
        end
        return nil
    end

    function EscortMP.util.getAGL(unit)
        if not unit or not unit:isExist() then
            return 0
        end

        local p = unit:getPoint()
        if not p then
            return 0
        end

        local ground = land.getHeight({ x = p.x, y = p.z }) or 0
        return p.y - ground
    end

    function EscortMP.util.isAirUnit(unit)
        if not unit or not unit:isExist() then
            return false
        end

        local desc = unit:getDesc()
        if not desc or not desc.category then
            return false
        end

        return desc.category == Unit.Category.AIRPLANE or desc.category == Unit.Category.HELICOPTER
    end

    function EscortMP.util.getAirCategoryName(unit)
        local desc = unit and unit:getDesc() or nil
        if desc and desc.category == Unit.Category.HELICOPTER then
            return "helicopter"
        end
        return "plane"
    end

    function EscortMP.util.getOppositeCoalition(coa)
        if coa == coalition.side.BLUE then
            return coalition.side.RED
        elseif coa == coalition.side.RED then
            return coalition.side.BLUE
        end
        return nil
    end

    function EscortMP.util.getLiveEscortUnit(escortGroupName)
        local g = Group.getByName(escortGroupName)
        if not g or not g:isExist() then
            return nil, nil
        end

        local units = g:getUnits()
        if not units then
            return g, nil
        end

        for i = 1, #units do
            local u = units[i]
            if u and u:isExist() and u:getLife() and u:getLife() > 0 then
                return g, u
            end
        end

        return g, nil
    end

    function EscortMP.util.groupHasAnyLiveUnit(group)
        if not group or not group:isExist() then
            return false
        end

        local units = group:getUnits()
        if not units then
            return false
        end

        for i = 1, #units do
            local u = units[i]
            if u and u:isExist() and u:getLife() and u:getLife() > 0 then
                return true
            end
        end

        return false
    end

    function EscortMP.util.getClosestEnemyToEscort(st)
        if not st or not st.escortGroupName or not st.ownerCoalition then
            return nil, nil, math.huge
        end

        local escortGroup, escortUnit = EscortMP.util.getLiveEscortUnit(st.escortGroupName)
        if not escortGroup or not escortUnit then
            return nil, nil, math.huge
        end

        local enemyCoalition = EscortMP.util.getOppositeCoalition(st.ownerCoalition)
        if not enemyCoalition then
            return nil, nil, math.huge
        end

        local escortPos = escortUnit:getPoint()
        if not escortPos then
            return nil, nil, math.huge
        end

        local closestGroup = nil
        local closestUnit = nil
        local closestDist = math.huge

        local enemyGroups = coalition.getGroups(enemyCoalition)
        if not enemyGroups then
            return nil, nil, math.huge
        end

        for _, grp in pairs(enemyGroups) do
            if grp and grp:isExist() and EscortMP.util.groupHasAnyLiveUnit(grp) then
                local units = grp:getUnits()
                if units then
                    for i = 1, #units do
                        local u = units[i]
                        if u and u:isExist() and u:getLife() and u:getLife() > 0 then
                            local p = u:getPoint()
                            if p then
                                local dx = escortPos.x - p.x
                                local dz = escortPos.z - p.z
                                local dist = math.sqrt(dx * dx + dz * dz)
                                if dist < closestDist then
                                    closestDist = dist
                                    closestGroup = grp
                                    closestUnit = u
                                end
                            end
                        end
                    end
                end
            end
        end

        return closestGroup, closestUnit, closestDist
    end

    function EscortMP.util.hasAmmo(unit)
        if not unit or not unit:isExist() then
            return false
        end

        local ammo = unit:getAmmo()
        if not ammo then
            return false
        end

        for i = 1, #ammo do
            local entry = ammo[i]
            if entry and entry.count and entry.count > 0 then
                return true
            end
        end

        return false
    end

    function EscortMP.util.destroyGroupByName(groupName)
        if not groupName then
            return
        end

        local g = Group.getByName(groupName)
        if not g or not g:isExist() then
            return
        end

        local ok = pcall(function()
            g:destroy()
        end)

        if not ok then
            pcall(function()
                Group.destroy(g)
            end)
        end
    end

    function EscortMP.util.getOwnerDB(ownerUnitName)
        if mist and mist.DBs and mist.DBs.unitsByName then
            return mist.DBs.unitsByName[ownerUnitName]
        end
        return nil
    end

    function EscortMP.util.resolvePayload(ownerUnitName, ownerTypeName)
        local payload = nil

        if mist and mist.getPayload then
            local ok, res = pcall(function()
                return mist.getPayload(ownerUnitName)
            end)

            if ok and type(res) == "table" and next(res) then
                payload = EscortMP.util.deepcopy(res)
            end
        end

        if not payload and cfg.FALLBACK_PAYLOAD_BY_TYPE[ownerTypeName] then
            payload = EscortMP.util.deepcopy(cfg.FALLBACK_PAYLOAD_BY_TYPE[ownerTypeName])
        end

        return payload
    end

    function EscortMP.util.buildRoute(spawnPos, ownerPos, speed, categoryName)
        local forwardDist = cfg.SECOND_WP_AHEAD_M
        local pos = ownerPos
        local p = pos.p
        local forward = pos.x

        local wp2x = spawnPos.x + forward.x * forwardDist
        local wp2z = spawnPos.z + forward.z * forwardDist
        local wpAlt = spawnPos.y

        local route = {
            points = {
                [1] = {
                    x = spawnPos.x,
                    y = spawnPos.z,
                    alt = wpAlt,
                    alt_type = "BARO",
                    speed = speed,
                    action = "Turning Point",
                    type = "Turning Point",
                    ETA = 0,
                    ETA_locked = false,
                    speed_locked = true,
                    task = {
                        id = "ComboTask",
                        params = {
                            tasks = {}
                        }
                    }
                },
                [2] = {
                    x = wp2x,
                    y = wp2z,
                    alt = wpAlt,
                    alt_type = "BARO",
                    speed = speed,
                    action = "Turning Point",
                    type = "Turning Point",
                    ETA = 0,
                    ETA_locked = false,
                    speed_locked = true,
                    task = {
                        id = "ComboTask",
                        params = {
                            tasks = {}
                        }
                    }
                }
            }
        }

        return route
    end

    function EscortMP.util.getFormationValue(categoryName)
        if categoryName == "helicopter" then
            return cfg.FORMATION_HELO_ECHELON_RIGHT
        end
        return cfg.FORMATION_FIXEDWING_ECHELON_RIGHT
    end

    function EscortMP.util.applyFormationOption(controller, categoryName)
        if not controller or not AI or not AI.Option or not AI.Option.Air then
            return
        end

        local formationValue = EscortMP.util.getFormationValue(categoryName)

        pcall(function()
            controller:setOption(AI.Option.Air.id.FORMATION, formationValue)
        end)
    end

    function EscortMP.util.makeEscortTask(ownerGroupId)
        return {
            id = "Escort",
            params = {
                groupId = ownerGroupId,
                pos = {
                    x = cfg.SPAWN_OFFSET_RIGHT_M,
                    y = 0,
                    z = cfg.SPAWN_OFFSET_BACK_M
                },
                lastWptIndexFlag = false,
                engagementDistMax = cfg.ATTACK_RANGE_M,
                targetTypes = EscortMP.util.deepcopy(cfg.TARGET_TYPES)
            }
        }
    end

    function EscortMP.util.removeMenuForGroup(groupId)
        if not groupId then
            return
        end

        local menuData = state.menus[groupId]
        if menuData and menuData.root then
            pcall(function()
                missionCommands.removeItemForGroup(groupId, menuData.root)
            end)
        end

        state.menus[groupId] = nil
    end

    function EscortMP.menu.buildForOwner(ownerUnitName)
        local st = state.owners[ownerUnitName]
        if not st or not st.ownerGroupId then
            return
        end

        EscortMP.util.removeMenuForGroup(st.ownerGroupId)

        local root = missionCommands.addSubMenuForGroup(st.ownerGroupId, cfg.MENU_ROOT, nil)

        missionCommands.addCommandForGroup(
            st.ownerGroupId,
            cfg.MENU_CMD_SPAWN,
            root,
            EscortMP.menu.onSpawn,
            ownerUnitName
        )

        missionCommands.addCommandForGroup(
            st.ownerGroupId,
            cfg.MENU_CMD_REMOVE,
            root,
            EscortMP.menu.onRemove,
            ownerUnitName
        )

        missionCommands.addCommandForGroup(
            st.ownerGroupId,
            cfg.MENU_CMD_STATUS,
            root,
            EscortMP.menu.onStatus,
            ownerUnitName
        )

        state.menus[st.ownerGroupId] = {
            root = root
        }
    end

    function EscortMP.ai.clearEscortFields(st)
        if not st then
            return
        end

        if st.escortGroupName then
            state.ownerByEscortGroup[st.escortGroupName] = nil
        end

        st.escortGroupName = nil
        st.escortGroupId = nil
        st.escortUnitName = nil
        st.mode = "NONE"
        st.lastAnnounceGroupName = nil
        st.lastAnnounceAt = nil
        st.rtbDespawnAt = nil
    end

    function EscortMP.ai.removeEscort(ownerUnitName, reason, silent)
        local st = state.owners[ownerUnitName]
        if not st then
            return
        end

        if st.escortGroupName then
            EscortMP.util.destroyGroupByName(st.escortGroupName)
        end

        EscortMP.ai.clearEscortFields(st)

        if not silent then
            EscortMP.util.msgToOwner(ownerUnitName, "Escolta eliminada. " .. (reason or ""), cfg.MESSAGE_TIME)
        end

        EscortMP.util.debug("Escolta eliminada para " .. ownerUnitName .. ". Motivo: " .. tostring(reason or "n/a"), ownerUnitName)
    end

    function EscortMP.ai.unregisterOwner(ownerUnitName, reason)
        local st = state.owners[ownerUnitName]
        if not st then
            return
        end

        EscortMP.ai.removeEscort(ownerUnitName, reason or "Owner no disponible", true)

        if st.ownerGroupId then
            EscortMP.util.removeMenuForGroup(st.ownerGroupId)
        end

        if st.playerName and state.playerToOwner[st.playerName] == ownerUnitName then
            state.playerToOwner[st.playerName] = nil
        end

        state.owners[ownerUnitName] = nil
        EscortMP.util.debug("Owner desregistrado: " .. ownerUnitName .. ". Motivo: " .. tostring(reason or "n/a"))
    end

    function EscortMP.ai.applyEscortTask(ownerUnitName)
        local st = state.owners[ownerUnitName]
        if not st or not st.escortGroupName or not st.ownerGroupId then
            return false
        end

        local escortGroup = Group.getByName(st.escortGroupName)
        if not escortGroup or not escortGroup:isExist() then
            return false
        end

        local controller = escortGroup:getController()
        if not controller then
            return false
        end

        local task = EscortMP.util.makeEscortTask(st.ownerGroupId)

        pcall(function()
            controller:resetTask()
        end)

        pcall(function()
            controller:setTask(task)
        end)

        EscortMP.util.applyFormationOption(controller, st.categoryName)

        st.mode = "ESCORT"
        return true
    end

    function EscortMP.ai.beginRTBLogic(ownerUnitName)
        local st = state.owners[ownerUnitName]
        if not st or not st.escortGroupName then
            return
        end

        if st.mode == "RTB" then
            return
        end

        st.mode = "RTB"
        st.rtbDespawnAt = timer.getTime() + cfg.RTB_DESPAWN_SECONDS

        EscortMP.util.msgToOwner(
            ownerUnitName,
            "Escolta sin armamento. RTB logico iniciado. Quedara liberada en " .. tostring(cfg.RTB_DESPAWN_SECONDS) .. " segundos.",
            cfg.STATUS_TIME
        )

        EscortMP.util.debug("RTB logico iniciado para " .. ownerUnitName, ownerUnitName)
    end

    function EscortMP.ai.spawnEscort(ownerUnitName)
        local st = state.owners[ownerUnitName]
        if not st then
            return
        end

        local ownerUnit = EscortMP.util.getOwnerUnit(ownerUnitName)
        if not ownerUnit then
            EscortMP.util.msgToOwner(ownerUnitName, "No se encontro la unidad del cliente.", cfg.MESSAGE_TIME)
            return
        end

        if not EscortMP.util.isAirUnit(ownerUnit) then
            EscortMP.util.msgToOwner(ownerUnitName, "La escolta solo funciona para aviones y helicopteros.", cfg.MESSAGE_TIME)
            return
        end

        local playerName = EscortMP.util.getPlayerName(ownerUnit)
        if not playerName then
            EscortMP.util.msgToOwner(ownerUnitName, "No hay un cliente ocupando esta unidad.", cfg.MESSAGE_TIME)
            return
        end

        if st.escortGroupName then
            EscortMP.util.msgToOwner(ownerUnitName, "Ya tienes una escolta activa.", cfg.MESSAGE_TIME)
            return
        end

        if st.rtbDespawnAt and timer.getTime() < st.rtbDespawnAt then
            local faltan = math.max(1, math.floor(st.rtbDespawnAt - timer.getTime()))
            EscortMP.util.msgToOwner(ownerUnitName, "La escolta anterior esta en RTB logico. Debes esperar " .. tostring(faltan) .. " s.", cfg.MESSAGE_TIME)
            return
        end

        local agl = EscortMP.util.getAGL(ownerUnit)
        if agl <= cfg.MIN_SPAWN_AGL_M then
            EscortMP.util.msgToOwner(ownerUnitName, "No puedes desplegar la escolta entre 0 y 5 AGL.", cfg.MESSAGE_TIME)
            return
        end

        local ownerGroup = EscortMP.util.getUnitGroup(ownerUnit)
        if not ownerGroup or not ownerGroup:isExist() then
            EscortMP.util.msgToOwner(ownerUnitName, "No se encontro el grupo del cliente.", cfg.MESSAGE_TIME)
            return
        end

        local ownerPos = ownerUnit:getPosition()
        local ownerPoint = ownerUnit:getPoint()
        if not ownerPos or not ownerPoint then
            EscortMP.util.msgToOwner(ownerUnitName, "No se pudo leer la posicion del cliente.", cfg.MESSAGE_TIME)
            return
        end

        local ownerType = ownerUnit:getTypeName()
        local categoryName = EscortMP.util.getAirCategoryName(ownerUnit)

        local vel = ownerUnit:getVelocity() or { x = 0, y = 0, z = 0 }
        local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y + vel.z * vel.z)

        if categoryName == "plane" then
            speed = math.max(speed, cfg.MIN_SPEED_PLANE_MPS)
        else
            speed = math.max(speed, cfg.MIN_SPEED_HELO_MPS)
        end

        local spawnX = ownerPos.p.x + ownerPos.x.x * cfg.SPAWN_OFFSET_BACK_M + ownerPos.z.x * cfg.SPAWN_OFFSET_RIGHT_M
        local spawnZ = ownerPos.p.z + ownerPos.x.z * cfg.SPAWN_OFFSET_BACK_M + ownerPos.z.z * cfg.SPAWN_OFFSET_RIGHT_M
        local spawnY = ownerPos.p.y + cfg.SPAWN_OFFSET_UP_M

        local ground = land.getHeight({ x = spawnX, y = spawnZ }) or 0
        if spawnY < ground + 20 then
            spawnY = ground + 20
        end

        local escortBaseName = "EscortMP_" .. EscortMP.util.sanitize(playerName) .. "_" .. tostring(state.seq)
        state.seq = state.seq + 1

        local escortGroupName = escortBaseName
        local escortUnitName = escortBaseName .. "_1"

        local db = EscortMP.util.getOwnerDB(ownerUnitName)
        local payload = EscortMP.util.resolvePayload(ownerUnitName, ownerType)
        local livery = db and db.livery_id or nil
        local addPropAircraft = db and db.AddPropAircraft and EscortMP.util.deepcopy(db.AddPropAircraft) or nil

        local groupData = {
            country = ownerUnit:getCountry(),
            category = categoryName,
            name = escortGroupName,
            task = (categoryName == "helicopter") and "CAS" or "CAP",
            hidden = false,
            visible = false,
            route = EscortMP.util.buildRoute(
                { x = spawnX, y = spawnY, z = spawnZ },
                ownerPos,
                speed,
                categoryName
            ),
            units = {
                [1] = {
                    unitName = ownerUnitName,
                    name = escortUnitName,
                    type = ownerType,
                    skill = cfg.ESCORT_SKILL,
                    x = spawnX,
                    y = spawnZ,
                    alt = spawnY,
                    alt_type = "BARO",
                    speed = speed,
                    heading = mist.getHeading(ownerUnit, true),
                    livery_id = livery,
                    onboard_num = "501"
                }
            }
        }

        if payload then
            groupData.units[1].payload = payload
        end

        if addPropAircraft then
            groupData.units[1].AddPropAircraft = addPropAircraft
        end

        local ok, newGroupData = pcall(function()
            return mist.dynAdd(groupData)
        end)

        if not ok or not newGroupData then
            EscortMP.util.msgToOwner(ownerUnitName, "Error creando la escolta IA.", cfg.MESSAGE_TIME)
            EscortMP.util.debug("Fallo al crear escolta para " .. ownerUnitName)
            return
        end

        st.escortGroupName = newGroupData.name or escortGroupName
        st.escortGroupId = newGroupData.groupId
        st.escortUnitName = escortUnitName
        st.mode = "SPAWNING"
        st.lastAnnounceGroupName = nil
        st.lastAnnounceAt = nil
        st.rtbDespawnAt = nil

        state.ownerByEscortGroup[st.escortGroupName] = ownerUnitName

        EscortMP.util.debug("Escolta creada: " .. tostring(st.escortGroupName) .. " para " .. ownerUnitName, ownerUnitName)

        mist.scheduleFunction(function(ownerName)
            local ownerState = state.owners[ownerName]
            if not ownerState or not ownerState.escortGroupName then
                return
            end

            local applied = EscortMP.ai.applyEscortTask(ownerName)
            if applied then
                EscortMP.util.msgToOwner(ownerName, "Escolta desplegada y asignada al cliente.", cfg.MESSAGE_TIME)
            else
                EscortMP.util.msgToOwner(ownerName, "La escolta fue creada pero no pudo tomar la tarea de escolta.", cfg.MESSAGE_TIME)
            end
        end, { ownerUnitName }, timer.getTime() + 1)
    end

    function EscortMP.menu.onSpawn(ownerUnitName)
        EscortMP.ai.spawnEscort(ownerUnitName)
    end

    function EscortMP.menu.onRemove(ownerUnitName)
        local st = state.owners[ownerUnitName]
        if not st or not st.escortGroupName then
            EscortMP.util.msgToOwner(ownerUnitName, "No tienes una escolta activa.", cfg.MESSAGE_TIME)
            return
        end

        EscortMP.ai.removeEscort(ownerUnitName, "Eliminada por menu.")
    end

    function EscortMP.menu.onStatus(ownerUnitName)
        local st = state.owners[ownerUnitName]
        if not st then
            return
        end

        local msg = "Estado escolta: "

        if not st.escortGroupName then
            if st.rtbDespawnAt and timer.getTime() < st.rtbDespawnAt then
                msg = msg .. "RTB logico. Disponible en " .. tostring(math.max(1, math.floor(st.rtbDespawnAt - timer.getTime()))) .. " s."
            else
                msg = msg .. "Sin escolta activa."
            end
        else
            msg = msg .. tostring(st.mode or "ESCORT")
        end

        EscortMP.util.msgToOwner(ownerUnitName, msg, cfg.STATUS_TIME)
    end

    function EscortMP.ai.registerOwnerUnit(unit)
        if not unit or not unit:isExist() then
            return
        end

        local playerName = EscortMP.util.getPlayerName(unit)
        if not playerName then
            return
        end

        if not EscortMP.util.isAirUnit(unit) then
            return
        end

        local ownerUnitName = unit:getName()
        local ownerGroup = unit:getGroup()
        if not ownerGroup or not ownerGroup:isExist() then
            return
        end

        local ownerGroupId = ownerGroup:getID()
        local existingOwnerForPlayer = state.playerToOwner[playerName]

        if existingOwnerForPlayer and existingOwnerForPlayer ~= ownerUnitName then
            EscortMP.ai.unregisterOwner(existingOwnerForPlayer, "El jugador cambio de slot.")
        end

        local st = state.owners[ownerUnitName]
        if not st then
            st = {
                ownerUnitName = ownerUnitName,
                playerName = playerName,
                ownerGroupName = ownerGroup:getName(),
                ownerGroupId = ownerGroupId,
                ownerCoalition = unit:getCoalition(),
                ownerCountry = unit:getCountry(),
                categoryName = EscortMP.util.getAirCategoryName(unit),
                mode = "NONE"
            }
            state.owners[ownerUnitName] = st
        else
            st.playerName = playerName
            st.ownerGroupName = ownerGroup:getName()
            st.ownerGroupId = ownerGroupId
            st.ownerCoalition = unit:getCoalition()
            st.ownerCountry = unit:getCountry()
            st.categoryName = EscortMP.util.getAirCategoryName(unit)
        end

        state.playerToOwner[playerName] = ownerUnitName

        EscortMP.menu.buildForOwner(ownerUnitName)
        EscortMP.util.debug("Owner registrado: " .. ownerUnitName .. " (" .. playerName .. ")", ownerUnitName)
    end

    function EscortMP.monitor.tick()
        for ownerUnitName, st in pairs(state.owners) do
            local ownerUnit = EscortMP.util.getOwnerUnit(ownerUnitName)
            local playerName = ownerUnit and EscortMP.util.getPlayerName(ownerUnit) or nil

            if not ownerUnit or not playerName then
                EscortMP.ai.unregisterOwner(ownerUnitName, "Cliente ya no esta en la unidad.")
            else
                local ownerGroup = ownerUnit:getGroup()
                if ownerGroup and ownerGroup:isExist() then
                    st.ownerGroupId = ownerGroup:getID()
                    st.ownerGroupName = ownerGroup:getName()
                    st.ownerCoalition = ownerUnit:getCoalition()
                    st.ownerCountry = ownerUnit:getCountry()
                end

                if st.escortGroupName then
                    local escortGroup, escortUnit = EscortMP.util.getLiveEscortUnit(st.escortGroupName)

                    if not escortGroup or not escortUnit then
                        EscortMP.ai.clearEscortFields(st)
                        EscortMP.util.msgToOwner(ownerUnitName, "Tu escolta fue destruida. Ya puedes desplegar otra.", cfg.MESSAGE_TIME)
                        EscortMP.util.debug("Escolta destruida para " .. ownerUnitName, ownerUnitName)
                    else
                        if st.mode ~= "RTB" then
                            if not EscortMP.util.hasAmmo(escortUnit) then
                                EscortMP.ai.beginRTBLogic(ownerUnitName)
                            else
                                local closestGroup, closestUnit, closestDist = EscortMP.util.getClosestEnemyToEscort(st)

                                if closestGroup and closestDist <= cfg.ANNOUNCE_RANGE_M then
                                    local gName = closestGroup:getName()
                                    if st.lastAnnounceGroupName ~= gName then
                                        st.lastAnnounceGroupName = gName
                                        st.lastAnnounceAt = timer.getTime()
                                        EscortMP.util.msgToOwner(ownerUnitName, "Escolta: objetivo detectado, entrando en ventana de combate.", cfg.MESSAGE_TIME)
                                    end
                                else
                                    st.lastAnnounceGroupName = nil
                                end

                                if st.mode ~= "ESCORT" then
                                    EscortMP.ai.applyEscortTask(ownerUnitName)
                                end
                            end
                        else
                            if st.rtbDespawnAt and timer.getTime() >= st.rtbDespawnAt then
                                EscortMP.ai.removeEscort(ownerUnitName, "RTB logico completado.", true)
                                EscortMP.util.msgToOwner(ownerUnitName, "La escolta ya quedo liberada. Puedes desplegar otra.", cfg.MESSAGE_TIME)
                            end
                        end
                    end
                end
            end
        end

        return timer.getTime() + cfg.CHECK_INTERVAL
    end

    function EscortMP.monitor.resyncPlayers()
        for coa = coalition.side.RED, coalition.side.BLUE do
            local groups = coalition.getGroups(coa)
            if groups then
                for _, grp in pairs(groups) do
                    if grp and grp:isExist() then
                        local units = grp:getUnits()
                        if units then
                            for i = 1, #units do
                                local unit = units[i]
                                if unit and unit:isExist() then
                                    local playerName = EscortMP.util.getPlayerName(unit)
                                    if playerName and EscortMP.util.isAirUnit(unit) then
                                        EscortMP.ai.registerOwnerUnit(unit)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        return timer.getTime() + cfg.RESYNC_INTERVAL
    end

    function EscortMP.events.onEvent(event)
        if not event or not event.id then
            return
        end

        if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
            if event.initiator and event.initiator:isExist() then
                EscortMP.ai.registerOwnerUnit(event.initiator)
            end

        elseif event.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
            if event.initiator and event.initiator:isExist() then
                EscortMP.ai.unregisterOwner(event.initiator:getName(), "Jugador salio del slot.")
            end

        elseif event.id == world.event.S_EVENT_DEAD
            or event.id == world.event.S_EVENT_CRASH
            or event.id == world.event.S_EVENT_EJECTION
            or event.id == world.event.S_EVENT_PILOT_DEAD then

            if event.initiator and event.initiator.getName then
                local deadName = event.initiator:getName()

                if state.owners[deadName] then
                    EscortMP.ai.unregisterOwner(deadName, "Owner destruido.")
                    return
                end

                local deadGroup = event.initiator:getGroup()
                if deadGroup and deadGroup:isExist() then
                    local escortOwner = state.ownerByEscortGroup[deadGroup:getName()]
                    if escortOwner and state.owners[escortOwner] then
                        local st = state.owners[escortOwner]
                        EscortMP.ai.clearEscortFields(st)
                        EscortMP.util.msgToOwner(escortOwner, "Tu escolta fue destruida. Ya puedes desplegar otra.", cfg.MESSAGE_TIME)
                    end
                end
            end
        end
    end

    local handler = {}
    function handler:onEvent(event)
        EscortMP.events.onEvent(event)
    end

    world.addEventHandler(handler)

    timer.scheduleFunction(function()
        EscortMP.util.debug("Inicializando sistema de escolta multijugador dedicado")
        EscortMP.monitor.resyncPlayers()
        EscortMP.monitor.tick()
        return nil
    end, {}, timer.getTime() + 1)

    timer.scheduleFunction(function()
        return EscortMP.monitor.resyncPlayers()
    end, {}, timer.getTime() + cfg.RESYNC_INTERVAL)

    timer.scheduleFunction(function()
        return EscortMP.monitor.tick()
    end, {}, timer.getTime() + cfg.CHECK_INTERVAL)

    EscortMP.util.debug("Script cargado correctamente")
end