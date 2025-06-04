trigger.action.outText("Script de escolta cargado correctamente", 5)

local escoltasActivas = {}
local cooldownEscolta = {}
local tiempoCooldown = 10

local function debug(mensaje)
    trigger.action.outText("[DEBUG ESCOLTA] " .. mensaje, 10)
end

local function destruirGrupo(nombreGrupo)
    local grupo = Group.getByName(nombreGrupo)
    if grupo and grupo:isExist() then
        grupo:destroy()
    end
end

local function regresarABase(nombreGrupo)
    local grupo = Group.getByName(nombreGrupo)
    if not grupo then return end

    local destino = { x = 202918, y = 0, z = 6949 }

    grupo:getController():setTask({
        id = 'Mission',
        params = {
            route = {
                points = {
                    {
                        type = "Turning Point",
                        action = "Landing",
                        x = destino.x,
                        y = destino.y,
                        z = destino.z,
                        speed = 200,
                        task = { id = "ComboTask", params = { tasks = {} } }
                    }
                }
            }
        }
    })

    mist.scheduleFunction(destruirGrupo, { nombreGrupo }, timer.getTime() + 180)
end

local function monitorearJugador(nombreGrupoJugador, nombreGrupo1, nombreGrupo2)
    mist.scheduleFunction(function()
        local grupoJugador = Group.getByName(nombreGrupoJugador)
        local grupo1 = Group.getByName(nombreGrupo1)
        local grupo2 = Group.getByName(nombreGrupo2)

        if not grupoJugador or not grupo1 or not grupo2 then
            escoltasActivas[nombreGrupoJugador] = nil
            return
        end

        local unidad = grupoJugador:getUnit(1)
        if not unidad or not unidad:isExist() or unidad:getLife() < 1 then
            trigger.action.outText("La escolta se retira (jugador destruido)", 10)
            regresarABase(nombreGrupo1)
            regresarABase(nombreGrupo2)
            escoltasActivas[nombreGrupoJugador] = nil
            return
        end

        local pos = unidad:getPoint()
        local vel = unidad:getVelocity()
        local alt = pos.y
        local velTotal = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)

        if alt < 3 and velTotal < 8 then
            trigger.action.outText("La escolta se retira (jugador aterrizado)", 10)
            regresarABase(nombreGrupo1)
            regresarABase(nombreGrupo2)
            escoltasActivas[nombreGrupoJugador] = nil
        end
    end, {}, timer.getTime() + 10, 10)
end

local function detectarYEnganchar(nombreGrupoEscolta, nombreGrupoJugador)
    mist.scheduleFunction(function()
        local grupoEscolta = Group.getByName(nombreGrupoEscolta)
        local grupoJugador = Group.getByName(nombreGrupoJugador)
        if not grupoEscolta or not grupoJugador then return end

        local unidadEscolta = grupoEscolta:getUnit(1)
        if not unidadEscolta then return end

        local posEscolta = unidadEscolta:getPoint()
        local enemigos = coalition.getGroups(1)
        local amenazaDetectada, grupoEnemigoDetectado
        local amenazaCercana, grupoEnemigoCercano
        local rangoDeteccion = 12000
        local rangoEnganche = 7000

        for _, grupoEnemigo in ipairs(enemigos) do
            if Group.isExist(grupoEnemigo) then
                local unidadEnemiga = grupoEnemigo:getUnit(1)
                if unidadEnemiga and unidadEnemiga:isExist() then
                    local posEnemigo = unidadEnemiga:getPoint()
                    local dx = posEscolta.x - posEnemigo.x
                    local dz = posEscolta.z - posEnemigo.z
                    local distancia = math.sqrt(dx * dx + dz * dz)

                    if distancia < rangoDeteccion then
                        amenazaDetectada = unidadEnemiga
                        grupoEnemigoDetectado = grupoEnemigo
                        if distancia < rangoEnganche then
                            amenazaCercana = unidadEnemiga
                            grupoEnemigoCercano = grupoEnemigo
                        end
                        break
                    end
                end
            end
        end

        if amenazaCercana and grupoEnemigoCercano then
            debug("¡Amenaza en rango! Escolta entrando en combate")
            grupoEscolta:getController():pushTask({
                id = 'EngageGroup',
                params = { groupId = grupoEnemigoCercano:getID() }
            })
        elseif amenazaDetectada and grupoEnemigoDetectado then
            debug("Enemigo detectado cerca. Escolta en alerta...")
        else
            debug("Zona despejada")
        end

        -- Aplicar offset de formación distinto según el grupo
        local nombre = grupoEscolta:getName()
        local offset = { x = -40, y = 0, z = -100 }
        if nombre:find("Escolta2") then
            offset = { x = -120, y = 0, z = -150 }
        end

        grupoEscolta:getController():pushTask({
            id = 'ControlledTask',
            params = {
                task = {
                    id = 'Follow',
                    params = {
                        groupId = grupoJugador:getID(),
                        pos = offset,
                        lastWptIndexFlag = false,
                        followTaskIndex = 1,
                        formation = "Echelon Left"
                    }
                }
            }
        })
    end, {}, timer.getTime() + 5, 10)
end


local function crearGrupoSimple(nombreGrupo, pos, heading, tipoUnidad)
    local pais = country.id.UK

    local unidad = {
        type = tipoUnidad,
        name = nombreGrupo .. "_1",
        x = pos.x,
        y = pos.z,
        alt = pos.y,
        speed = 250,
        heading = heading,
        skill = "High",
        callsign = {1, 1, math.random(10,99)},
        unitId = math.random(10000,99999),
        playerCanDrive = false
    }

    local datosGrupo = {
        visible = false,
        lateActivation = false,
        hidden = false,
        task = "CAS",
        route = {
            points = {
                {
                    x = pos.x,
                    y = pos.z,
                    alt = pos.y,
                    speed = 250,
                    type = "Turning Point",
                    action = "Turning Point",
                    task = { id = "ComboTask", params = { tasks = {} } }
                }
            }
        },
        units = { unidad },
        name = nombreGrupo
    }

    coalition.addGroup(pais, Group.Category.AIRPLANE, datosGrupo)
end

local function clonarEscoltaCerca(unidadJugador)
    local tipoUnidad = unidadJugador:getTypeName()
    local posJugador = unidadJugador:getPoint()
    local orientJugador = unidadJugador:getPosition().x
    local heading = math.atan2(orientJugador.x, orientJugador.z)

    local offsetX = -orientJugador.x * 1852
    local offsetZ = -orientJugador.z * 1852

    local base = {
        x = posJugador.x + offsetX,
        z = posJugador.z + offsetZ,
        y = posJugador.y
    }

    local nombre1 = "Escolta1_" .. math.random(1000,9999)
    local nombre2 = "Escolta2_" .. math.random(1000,9999)

    crearGrupoSimple(nombre1, base, heading, tipoUnidad)

    local base2 = {
        x = base.x - 80,
        z = base.z - 50,
        y = base.y
    }

    crearGrupoSimple(nombre2, base2, heading, tipoUnidad)

    mist.scheduleFunction(function()
        local g1 = Group.getByName(nombre1)
        local g2 = Group.getByName(nombre2)
        local jugador = unidadJugador:getGroup()

        if g1 and g1:isExist() then
            g1:getController():setTask({
                id = 'ControlledTask',
                params = {
                    task = {
                        id = 'Follow',
                        params = {
                            groupId = jugador:getID(),
                            pos = { x = -40, y = 0, z = -100 },
                            lastWptIndexFlag = false,
                            followTaskIndex = 1,
                            formation = "Echelon Left"
                        }
                    }
                }
            })
        end

        if g2 and g2:isExist() then
            g2:getController():setTask({
                id = 'ControlledTask',
                params = {
                    task = {
                        id = 'Follow',
                        params = {
                            groupId = jugador:getID(),
                            pos = { x = -120, y = 0, z = -150 },
                            lastWptIndexFlag = false,
                            followTaskIndex = 1,
                            formation = "Echelon Left"
                        }
                    }
                }
            })
        end
    end, {}, timer.getTime() + 2)

    return { name1 = nombre1, name2 = nombre2 }
end

local menuRaizEscolta = missionCommands.addSubMenuForCoalition(2, "Solicitar escolta aérea")

missionCommands.addCommandForCoalition(2, "Pedir escolta ahora", menuRaizEscolta, function()
    local unidades = coalition.getPlayers(2)
    for _, u in ipairs(unidades) do
        if u and u:isActive() then
            local grupoJugador = u:getGroup()
            if grupoJugador then
                local nombreGrupoJugador = grupoJugador:getName()
                if escoltasActivas[nombreGrupoJugador] then
                    trigger.action.outText("Ya tienes una escolta activa.", 10)
                    return
                end

                local unidadJugador = grupoJugador:getUnit(1)
                if not unidadJugador then
                    trigger.action.outText("No se pudo encontrar tu unidad.", 10)
                    return
                end

                local punto = unidadJugador:getPoint()
                local alturaTerreno = land.getHeight({ x = punto.x, y = punto.z })
                if punto.y - alturaTerreno < 30 then
                    trigger.action.outText("Debes estar a más de 30 metros AGL para solicitar escolta.", 10)
                    return
                end

                local nombres = clonarEscoltaCerca(unidadJugador)
                escoltasActivas[nombreGrupoJugador] = { nombres.name1, nombres.name2 }
                monitorearJugador(nombreGrupoJugador, nombres.name1, nombres.name2)
                detectarYEnganchar(nombres.name1, nombreGrupoJugador)
                detectarYEnganchar(nombres.name2, nombreGrupoJugador)
                trigger.action.outText("Tu escolta ha sido desplegada (2 unidades del mismo tipo).", 10)
            end
        end
    end
end)

missionCommands.addCommandForCoalition(2, "Cancelar escolta activa", menuRaizEscolta, function()
    local unidades = coalition.getPlayers(2)
    for _, u in ipairs(unidades) do
        if u and u:isActive() then
            local grupoJugador = u:getGroup()
            if grupoJugador then
                local nombreGrupoJugador = grupoJugador:getName()
                local nombres = escoltasActivas[nombreGrupoJugador]
                if nombres then
                    for _, gName in ipairs(nombres) do
                        local g = Group.getByName(gName)
                        if g and g:isExist() then g:destroy() end
                    end
                    escoltasActivas[nombreGrupoJugador] = nil
                    trigger.action.outText("Has cancelado tu escolta.", 10)
                else
                    trigger.action.outText("No tienes escolta activa para cancelar.", 10)
                end
            end
        end
    end
end)
