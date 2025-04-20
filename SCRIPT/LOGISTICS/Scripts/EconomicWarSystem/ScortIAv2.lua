trigger.action.outText("Script de escolta cargado correctamente", 5)

local escoltasActivas = {}
local nombresPosiblesEscolta = {}

for i = 1, 9999 do
    table.insert(nombresPosiblesEscolta, "UK air " .. i)
end

local function regresarABase(nombreGrupoEscolta)
    local grupo = Group.getByName(nombreGrupoEscolta)
    if not grupo then return end

    local destino = { x = 200000, y = 0, z = 200000 }

    local task = {
        id = 'Mission',
        params = {
            route = {
                points = {
                    [1] = {
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

-- NUEVA versión: Monitorea distancia y muestra mensaje exclusivo al jugador
local function monitorearDistanciaEscolta(nombreGrupoJugador, nombreGrupoEscolta)
    local estadoAnterior = nil

    mist.scheduleFunction(function()
        local grupoJugador = Group.getByName(nombreGrupoJugador)
        local grupoEscolta = Group.getByName(nombreGrupoEscolta)

        if not grupoJugador or not grupoEscolta then return end

        local unidadJugador = grupoJugador:getUnit(1)
        local unidadEscolta = grupoEscolta:getUnit(1)

        if not unidadJugador or not unidadEscolta then return end

        local posJugador = unidadJugador:getPoint()
        local posEscolta = unidadEscolta:getPoint()

        local dx = posJugador.x - posEscolta.x
        local dz = posJugador.z - posEscolta.z
        local distancia = math.sqrt(dx * dx + dz * dz)

        local grupoID = grupoJugador:getID()
        local metros = math.floor(distancia)

        if distancia <= 1000 then
            if estadoAnterior ~= "cerca" then
                trigger.action.outTextForGroup(grupoID, "La escolta está cerca, volando en formación.", 10)
                estadoAnterior = "cerca"
            end
        elseif distancia > 5000 then
            if estadoAnterior ~= "lejos" then
                estadoAnterior = "lejos"
            end
            trigger.action.outTextForGroup(grupoID, "Distancia actual a la escolta: " .. metros .. " m", 8)
        end

        return timer.getTime() + 10
    end, {}, timer.getTime() + 5)
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

                local plantillasEscolta = { "EscortTemplate01", "EscortTemplate02", "EscortTemplate03" }
                local plantillaSeleccionada = plantillasEscolta[math.random(#plantillasEscolta)]
                mist.cloneGroup(plantillaSeleccionada, true)
                trigger.action.outText("Plantilla seleccionada: " .. plantillaSeleccionada, 5)

                timer.scheduleFunction(function()
                    local grupoClonado = nil
                    for _, nombre in ipairs(nombresPosiblesEscolta) do
                        if Group.getByName(nombre) and Group.getByName(nombre):isExist() and not nombresAntes[nombre] then
                            grupoClonado = nombre
                            break
                        end
                    end

                    if grupoClonado then
                        local grupoIA = Group.getByName(grupoClonado)
                        local controller = grupoIA and grupoIA:getController()

                        if controller then
                            local comboTask = {
                                id = "ComboTask",
                                params = {
                                    tasks = {
                                        {
                                            enabled = true,
                                            auto = false,
                                            id = "Follow",
                                            number = 1,
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
                            }

                            controller:setTask(comboTask)
                            trigger.action.outText("Tu escolta ha sido desplegada", 10)
                            escoltasActivas[nombreGrupoJugador] = grupoClonado
                            monitorearJugador(nombreGrupoJugador, grupoClonado)
                            monitorearDistanciaEscolta(nombreGrupoJugador, grupoClonado)

                            mist.scheduleFunction(function()
                                local grupo = Group.getByName(grupoClonado)
                                if not grupo or not Group.isExist(grupo) then
                                    trigger.action.outText("La escolta ha sido destruida.", 10)
                                    escoltasActivas[nombreGrupoJugador] = nil
                                    return
                                end

                                local todasMuertas = true
                                for i = 1, grupo:getSize() do
                                    local unidad = grupo:getUnit(i)
                                    if unidad and unidad:isExist() and unidad:getLife() > 0 then
                                        todasMuertas = false
                                        break
                                    end
                                end

                                if todasMuertas then
                                    trigger.action.outText("La escolta ha sido destruida.", 10)
                                    escoltasActivas[nombreGrupoJugador] = nil
                                else
                                    return timer.getTime() + 5
                                end
                            end, {}, timer.getTime() + 5)

                        else
                            trigger.action.outText("Error al encontrar controlador de escolta", 10)
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
