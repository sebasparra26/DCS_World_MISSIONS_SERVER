-- =============================
-- SISTEMA DE ESCOLTAS IA – VERSIÓN FINAL FUNCIONAL (con "UK air")
-- =============================

trigger.action.outText("Script de escolta cargado correctamente", 5)
local escoltasActivas = {}
local nombresPosiblesEscolta = {}

-- Nombres que MIST puede asignar: UK air 1, UK air 2, ..., UK air 9999
for i = 1, 9999 do
    table.insert(nombresPosiblesEscolta, "UK air " .. i)
end

-- Función para enviar la escolta de regreso a base
local function regresarABase(nombreGrupoEscolta)
    local grupo = Group.getByName(nombreGrupoEscolta)
    if not grupo then return end

    local destino = { x = 202918, y = 0, z = 6949 }

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

-- Monitorea si el jugador aterriza o muere
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

-- Crear menú de radio y lógica de clonación
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

                -- Capturar nombres activos antes de clonar
                local nombresAntes = {}
                for _, nombre in ipairs(nombresPosiblesEscolta) do
                    if Group.getByName(nombre) and Group.getByName(nombre):isExist() then
                        nombresAntes[nombre] = true
                    end
                end

                mist.cloneGroup("EscortTemplate", true)

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
                            trigger.action.outText("Tu escolta ha sido desplegada", 10)
                            monitorearJugador(nombreGrupoJugador, grupoClonado)
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
