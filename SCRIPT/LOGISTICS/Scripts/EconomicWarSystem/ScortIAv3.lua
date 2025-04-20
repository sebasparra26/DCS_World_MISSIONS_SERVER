trigger.action.outText("Script de escolta cargado correctamente", 5)

-- =============================
-- CONFIGURACIÓN DE ATAQUE DE ESCOLTA
-- =============================

opcionesAtaqueEscolta = {
    atacarAviones = true,
    atacarHelicopteros = false,
    atacarVehiculos = false,
    distanciaEnganche = 5556 -- en metros (3 NM)
}

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
        local metros = math.floor(distancia)
        local grupoID = grupoJugador:getID()

        if distancia <= 1000 then
            if estadoAnterior ~= "cerca" then
                trigger.action.outTextForGroup(grupoID, "La escolta está cerca, volando en formación.", 10)
                estadoAnterior = "cerca"
            end
        elseif distancia >= 1200 then
            local millas = distancia / 1852
            local texto = string.format("Distancia actual a la escolta: %.2f millas náuticas", millas)
            trigger.action.outTextForGroup(grupoID, texto, 8)
            estadoAnterior = "lejos"
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
            if not grupoJugador then
                trigger.action.outText("No se pudo detectar tu grupo. ¿Estás en cabina?", 10)
                return
            end

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

                if not grupoClonado then
                    trigger.action.outText("Error: no se encontró el grupo clonado", 10)
                    return
                end

                local grupoIA = Group.getByName(grupoClonado)
                local controller = grupoIA and grupoIA:getController()
                if not controller then
                    trigger.action.outText("Error: controlador de escolta no encontrado", 10)
                    return
                end

                controller:setTask({
                    id = "ComboTask",
                    params = {
                        tasks = {
                            {
                                id = "Follow",
                                auto = false,
                                enabled = true,
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
                })

                escoltasActivas[nombreGrupoJugador] = grupoClonado
                trigger.action.outText("Tu escolta ha sido desplegada", 10)
                monitorearJugador(nombreGrupoJugador, grupoClonado)
                monitorearDistanciaEscolta(nombreGrupoJugador, grupoClonado)

                local estadoEscolta = "follow"
                local unidadEnemiga = nil

                mist.scheduleFunction(function()
                    local grupo = Group.getByName(grupoClonado)
                    local grupoJugadorLocal = Group.getByName(nombreGrupoJugador)
                    if not grupo or not grupoJugadorLocal then return end

                    local unidadIA = grupo:getUnit(1)
                    if not unidadIA or not unidadIA:isExist() then return end
                    local controller = grupo:getController()
                    if not controller then return end

                    if estadoEscolta == "engage" and unidadEnemiga then
                        if not unidadEnemiga:isExist() or unidadEnemiga:getLife() < 1 then
                            controller:setTask({
                                id = "ComboTask",
                                params = {
                                    tasks = {
                                        {
                                            id = "Follow",
                                            auto = false,
                                            enabled = true,
                                            number = 1,
                                            params = {
                                                groupId = grupoJugadorLocal:getID(),
                                                pos = { x = -100, y = 0, z = -100 },
                                                lastWptIndexFlag = false,
                                                followTaskIndex = 1,
                                                formation = "Diamond"
                                            }
                                        }
                                    }
                                }
                            })
                            estadoEscolta = "follow"
                            unidadEnemiga = nil
                            trigger.action.outText("Amenaza destruida. Escolta vuelve a formación.", 10)
                        end
                        return timer.getTime() + 5
                    end

                    if estadoEscolta == "follow" then
                        local posIA = unidadIA:getPoint()
                        local enemigos = coalition.getGroups(1)
                        for _, g in ipairs(enemigos) do
                            for _, u in ipairs(g:getUnits()) do
                                if u and u:isExist() then
                                    local tipo = u:getDesc().category
                                    local puedeAtacar = (
                                        (tipo == Unit.Category.AIRPLANE and opcionesAtaqueEscolta.atacarAviones) or
                                        (tipo == Unit.Category.HELICOPTER and opcionesAtaqueEscolta.atacarHelicopteros) or
                                        (tipo == Unit.Category.GROUND_UNIT and opcionesAtaqueEscolta.atacarVehiculos)
                                    )
                                    if puedeAtacar then
                                        local posE = u:getPoint()
                                        local dx = posE.x - posIA.x
                                        local dz = posE.z - posIA.z
                                        local distancia = math.sqrt(dx * dx + dz * dz)
                                        if distancia <= opcionesAtaqueEscolta.distanciaEnganche then
                                            controller:setTask({
                                                id = "ComboTask",
                                                params = {
                                                    tasks = {
                                                        {
                                                            id = "EngageUnit",
                                                            auto = false,
                                                            enabled = true,
                                                            number = 1,
                                                            params = { unit = u }
                                                        }
                                                    }
                                                }
                                            })
                                            estadoEscolta = "engage"
                                            unidadEnemiga = u
                                            trigger.action.outText("La escolta entra en combate. Enemigo a " .. math.floor(distancia) .. " m", 10)
                                            return timer.getTime() + 5
                                        end
                                    end
                                end
                            end
                        end
                    end

                    return timer.getTime() + 5
                end, {}, timer.getTime() + 10)
            end, {}, timer.getTime() + 1)
        end
    end
end)
