trigger.action.outText("Script de escolta cargado correctamente", 5)

local escoltasActivas = {}
local cooldownEscolta = {}
local tiempoCooldown = 10

local nombresVisiblesEscolta = {
    ["EscortTemplate01"] = "Escuadrón Centinela",
    ["EscortTemplate02"] = "Escuadrón Lobo",
    ["EscortTemplate03"] = "Escuadrón Halcón"
}

local plantillasEscolta = { "EscortTemplate01", "EscortTemplate02", "EscortTemplate03" }

local function debug(mensaje)
    trigger.action.outText("[DEBUG ESCOLTA] " .. mensaje, 10)
end

local function destruirGrupo(nombreGrupo)
    local grupo = Group.getByName(nombreGrupo)
    if grupo and grupo:isExist() then
        grupo:destroy()
    end
end

local function regresarABase(nombreGrupoEscolta)
    local grupo = Group.getByName(nombreGrupoEscolta)
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

        -- Seguir escoltando al jugador
        local followTask = {
            id = 'ControlledTask',
            params = {
                task = {
                    id = 'Follow',
                    params = {
                        groupId = grupoJugador:getID(),
                        pos = { x = -100, y = 0, z = -150 },
                        lastWptIndexFlag = false,
                        followTaskIndex = 1,
                        formation = "Finger Four"
                    }
                }
            }
        }
        grupoEscolta:getController():pushTask(followTask)

    end, {}, timer.getTime() + 5, 10)
end

local function clonarEscoltaCerca(unidadJugador, plantillaSeleccionada)
    local posJugador = unidadJugador:getPoint()
    local matrizJugador = unidadJugador:getPosition()
    local distanciaNM = 1800
    local nuevaPos = {
        x = posJugador.x - (matrizJugador.z.x * distanciaNM),
        y = posJugador.y - (matrizJugador.z.z * distanciaNM),
        z = posJugador.z
    }

    local datosTemplate = mist.getGroupData(plantillaSeleccionada)
    if not datosTemplate then
        debug("Error al obtener plantilla de escolta")
        return nil
    end

    for i, unidad in ipairs(datosTemplate.units) do
        unidad.x = nuevaPos.x + math.random(-10, 10)
        unidad.y = nuevaPos.z + math.random(-10, 10)
        unidad.alt = nuevaPos.y
    end

    datosTemplate.x = nuevaPos.x
    datosTemplate.y = nuevaPos.z
    datosTemplate.alt = nuevaPos.y

    return mist.dynAdd(datosTemplate)
end

local menuRaizEscolta = missionCommands.addSubMenuForCoalition(2, "Solicitar escolta aérea")

missionCommands.addCommandForCoalition(2, "Pedir escolta ahora", menuRaizEscolta, function()
    local unidades = coalition.getPlayers(2)
    for _, u in ipairs(unidades) do
        if u and u:isActive() then
            local grupoJugador = u:getGroup()
            if grupoJugador then
                local nombreGrupoJugador = grupoJugador:getName()
                debug("Grupo identificado: " .. nombreGrupoJugador)
                local ahora = timer.getTime()

                if cooldownEscolta[nombreGrupoJugador] and ahora < cooldownEscolta[nombreGrupoJugador] then
                    trigger.action.outText("Debes esperar unos segundos antes de solicitar otra escolta.", 10)
                    return
                end

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
                local altAGL = punto.y - alturaTerreno
                if altAGL < 30 then
                    trigger.action.outText("Debes estar a más de 30 metros AGL para solicitar escolta.", 10)
                    return
                end

                local indice = math.random(1, #plantillasEscolta)
                local plantillaSeleccionada = plantillasEscolta[indice]
                local grupoClonado = clonarEscoltaCerca(unidadJugador, plantillaSeleccionada)

                if grupoClonado then
                    escoltasActivas[nombreGrupoJugador] = grupoClonado.name
                    trigger.action.outText("Tu escolta ha sido desplegada: " .. (nombresVisiblesEscolta[plantillaSeleccionada] or plantillaSeleccionada), 10)
                    monitorearJugador(nombreGrupoJugador, grupoClonado.name)
                    detectarYEnganchar(grupoClonado.name, nombreGrupoJugador)
                    cooldownEscolta[nombreGrupoJugador] = timer.getTime() + tiempoCooldown
                else
                    trigger.action.outText("Error al clonar la escolta.", 10)
                end
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
                local ahora = timer.getTime()

                if cooldownEscolta[nombreGrupoJugador] and ahora < cooldownEscolta[nombreGrupoJugador] then
                    trigger.action.outText("Debes esperar unos segundos antes de cancelar la escolta.", 10)
                    return
                end

                local nombreGrupoEscolta = escoltasActivas[nombreGrupoJugador]
                if nombreGrupoEscolta then
                    local grupoEscolta = Group.getByName(nombreGrupoEscolta)
                    if grupoEscolta and grupoEscolta:isExist() then
                        grupoEscolta:destroy()
                        trigger.action.outText("Has cancelado tu escolta.", 10)
                    else
                        trigger.action.outText("No se encontró la escolta activa.", 10)
                    end
                    escoltasActivas[nombreGrupoJugador] = nil
                    cooldownEscolta[nombreGrupoJugador] = timer.getTime() + tiempoCooldown
                else
                    trigger.action.outText("No tienes escolta activa para cancelar.", 10)
                end
            end
        end
    end
end)
