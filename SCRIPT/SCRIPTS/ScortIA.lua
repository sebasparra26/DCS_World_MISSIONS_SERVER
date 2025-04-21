trigger.action.outText("Script de escolta cargado correctamente", 5)

local escoltasActivas = {}
local nombresPosiblesEscolta = {}
local debugEscolta = false

-- Nombres que MIST puede asignar
for i = 1, 9999 do
    table.insert(nombresPosiblesEscolta, "UK air " .. i)
end

-- Opcional: nombres visibles para mostrar por plantilla
local nombresVisiblesEscolta = {
    ["EscortTemplate01"] = "Escuadrón Centinela",
    ["EscortTemplate02"] = "Escuadrón Lobo",
    ["EscortTemplate03"] = "Escuadrón Halcón"
}

local plantillasEscolta = { "EscortTemplate01", "EscortTemplate02", "EscortTemplate03" }

local function log(msg)
    if debugEscolta then env.info("[ESCOLTA] " .. msg) end
end

local function destruirGrupo(nombreGrupo)
    local grupo = Group.getByName(nombreGrupo)
    if grupo and grupo:isExist() then
        grupo:destroy()
        log("Grupo destruido: " .. nombreGrupo)
    end
end

local function regresarABase(nombreGrupoEscolta)
    local grupo = Group.getByName(nombreGrupoEscolta)
    if not grupo then return end

    local destino = { x = 202918, y = 0, z = 6949 }

    local task = {
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
    }

    grupo:getController():setTask(task)
    mist.scheduleFunction(destruirGrupo, { nombreGrupoEscolta }, timer.getTime() + 180)
end

local function monitorearJugador(nombreGrupoJugador, nombreGrupoEscolta)
    mist.scheduleFunction(function()
        local grupoJugador = Group.getByName(nombreGrupoJugador)
        local grupoEscolta = Group.getByName(nombreGrupoEscolta)

        if not grupoJugador or not grupoEscolta then
            escoltasActivas[nombreGrupoJugador] = nil
            return
        end

        local unidad = grupoJugador:getUnit(1)
        if not unidad or not unidad:isExist() or unidad:getLife() < 1 then
            trigger.action.outText("La escolta se retira (jugador destruido)", 10)
            regresarABase(nombreGrupoEscolta)
            escoltasActivas[nombreGrupoJugador] = nil
            return
        end

        local pos = unidad:getPoint()
        local vel = unidad:getVelocity()
        local alt = pos.y
        local velTotal = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)

        if alt < 3 and velTotal < 8 then
            trigger.action.outText("La escolta se retira (jugador aterrizado)", 10)
            regresarABase(nombreGrupoEscolta)
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
        local posEscolta = unidadEscolta and unidadEscolta:getPoint()
        if not posEscolta then return end

        local enemigos = coalition.getGroups(1)
        local amenazaDetectada = nil
        local amenazaCercana = nil
        local rangoDeteccion = 10000
        local rangoEnganche = 5556

        for _, grupoEnemigo in pairs(enemigos) do
            if Group.isExist(grupoEnemigo) then
                local unidadEnemiga = grupoEnemigo:getUnit(1)
                if unidadEnemiga then
                    local posEnemigo = unidadEnemiga:getPoint()
                    local dx = posEscolta.x - posEnemigo.x
                    local dz = posEscolta.z - posEnemigo.z
                    local distancia = math.sqrt(dx * dx + dz * dz)

                    if distancia < rangoDeteccion then
                        amenazaDetectada = unidadEnemiga
                        if distancia < rangoEnganche then
                            amenazaCercana = unidadEnemiga
                        end
                        break
                    end
                end
            end
        end

        if amenazaCercana then
            trigger.action.outText("¡Amenaza en rango! Escolta entrando en combate", 10)
            local task = {
                id = 'EngageUnit',
                params = { unitId = amenazaCercana:getID() }
            }
            grupoEscolta:getController():pushTask(task)

        elseif amenazaDetectada then
            trigger.action.outText("Enemigo detectado cerca. Escolta en alerta...", 10)

        else
            local taskFollow = {
                id = 'ControlledTask',
                params = {
                    task = {
                        id = 'Follow',
                        params = {
                            groupId = grupoJugador:getID(),
                            pos = { x = -100, y = 0, z = -100 },
                            lastWptIndexFlag = false,
                            followTaskIndex = 1,
                            formation = "Diamond"
                        }
                    }
                }
            }
            grupoEscolta:getController():pushTask(taskFollow)
        end
    end, {}, timer.getTime() + 5, 10)
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

                local nombresAntes = {}
                for _, nombre in ipairs(nombresPosiblesEscolta) do
                    if Group.getByName(nombre) and Group.getByName(nombre):isExist() then
                        nombresAntes[nombre] = true
                    end
                end

                local indice = math.random(1, #plantillasEscolta)
                local plantillaSeleccionada = plantillasEscolta[indice]
                mist.cloneGroup(plantillaSeleccionada, true)

                timer.scheduleFunction(function()
                    local grupoClonado = nil
                    for _, nombre in ipairs(nombresPosiblesEscolta) do
                        if Group.getByName(nombre) and Group.getByName(nombre):isExist() and not nombresAntes[nombre] then
                            grupoClonado = nombre
                            break
                        end
                    end

                    if grupoClonado then
                        local followTask = {
                            id = 'ControlledTask',
                            params = {
                                task = {
                                    id = 'Follow',
                                    params = {
                                        groupId = grupoJugador:getID(),
                                        pos = { x = -100, y = 0, z = -100 },
                                        lastWptIndexFlag = false,
                                        followTaskIndex = 1,
                                        formation = "Diamond"
                                    }
                                }
                            }
                        }

                        local grupoIA = Group.getByName(grupoClonado)
                        if grupoIA then
                            grupoIA:getController():pushTask(followTask)
                            escoltasActivas[nombreGrupoJugador] = grupoClonado
                            local nombreVisible = nombresVisiblesEscolta[plantillaSeleccionada] or plantillaSeleccionada
                            trigger.action.outText("Tu escolta ha sido desplegada: " .. nombreVisible, 10)
                            monitorearJugador(nombreGrupoJugador, grupoClonado)
                            detectarYEnganchar(grupoClonado, nombreGrupoJugador)
                        else
                            trigger.action.outText("Error al encontrar grupo clonado", 10)
                        end
                    else
                        trigger.action.outText("No se encontró el grupo clonado", 10)
                    end
                end, {}, timer.getTime() + 1)

                return
            end
        end
    end

    trigger.action.outText("No se pudo detectar tu grupo. ¿Estás en cabina?", 10)
end)
