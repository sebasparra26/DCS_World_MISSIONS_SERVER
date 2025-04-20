-- Configuración
local zonaDeteccion = 'DETECT'
local velocidadMovimiento = 800
local formacionGrupo = 'diamond'
local debugActivo = true
local tiempoReasignacion = 20
local umbralMovimiento = 40

-- Estado
local grupoRojoActivo = nil
local nombreGrupoRojoActivo = nil
local ultimaPosicionRojo = nil
local grupoRojoSeMovio = false
local asignacionesActuales = {}
local tiemposUltimaAsignacion = {}
local gruposAzulesAsignadosInicial = {}  -- NUEVO: [grupo azul] = true

local function calcularDistancia(p1, p2)
    local dx = p1.x - p2.x
    local dz = p1.z - p2.z
    return math.sqrt(dx * dx + dz * dz)
end

local function reasignarRutas(puntoRojo)
    local azules = mist.getUnitsInZones(mist.makeUnitTable({'[blue]'}), {zonaDeteccion}, 'cylinder')
    local gruposAzules = {}

    for _, unidadAzul in ipairs(azules) do
        if Unit.isExist(unidadAzul) then
            local info = mist.DBs.unitsByName[unidadAzul:getName()]
            if info then
                gruposAzules[info.groupName] = true
            end
        end
    end

    for nombreGrupoAzul, _ in pairs(gruposAzules) do
        mist.groupToPoint(nombreGrupoAzul, puntoRojo, formacionGrupo, velocidadMovimiento)
        tiemposUltimaAsignacion[nombreGrupoAzul] = timer.getTime()
        asignacionesActuales[nombreGrupoAzul] = nombreGrupoRojoActivo
        gruposAzulesAsignadosInicial[nombreGrupoAzul] = true  -- registrar como asignado

        if debugActivo then
            trigger.action.outText("Grupo azul " .. nombreGrupoAzul .. " actualizado tras parada de rojo.", 5)
            env.info("Ruta asignada a " .. nombreGrupoAzul .. " tras parada de rojo.")
        end
    end
end

local function verificarYAsignar()
    local tiempoActual = timer.getTime()

    -- Reset si el grupo rojo muere
    if grupoRojoActivo and not Group.isExist(grupoRojoActivo) then
        grupoRojoActivo = nil
        nombreGrupoRojoActivo = nil
        ultimaPosicionRojo = nil
        grupoRojoSeMovio = false
        asignacionesActuales = {}
        tiemposUltimaAsignacion = {}
        gruposAzulesAsignadosInicial = {}
        if debugActivo then
            trigger.action.outText("Grupo rojo destruido. Esperando nuevo.", 5)
        end
    end

    -- Buscar nuevo grupo rojo
    if not grupoRojoActivo then
        local rojos = mist.getUnitsInZones(mist.makeUnitTable({'[red][vehicle]'}), {zonaDeteccion}, 'cylinder')
        if #rojos > 0 and Unit.isExist(rojos[1]) then
            local unidad = rojos[1]
            grupoRojoActivo = Unit.getGroup(unidad)
            if grupoRojoActivo then
                nombreGrupoRojoActivo = grupoRojoActivo:getName()
                ultimaPosicionRojo = Unit.getPoint(unidad)
                grupoRojoSeMovio = false
                asignacionesActuales = {}
                tiemposUltimaAsignacion = {}
                gruposAzulesAsignadosInicial = {}

                if debugActivo then
                    trigger.action.outText("Nuevo grupo rojo detectado: " .. nombreGrupoRojoActivo, 5)
                end
            end
        end
    end

    -- Si hay grupo rojo activo
    if grupoRojoActivo and Group.isExist(grupoRojoActivo) then
        local unidadesRojo = grupoRojoActivo:getUnits()
        if unidadesRojo and #unidadesRojo > 0 and Unit.isExist(unidadesRojo[1]) then
            local puntoRojo = Unit.getPoint(unidadesRojo[1])
            local distancia = calcularDistancia(ultimaPosicionRojo, puntoRojo)

            -- Detectar si se movió
            if distancia > umbralMovimiento then
                grupoRojoSeMovio = true
                if debugActivo then
                    env.info("Grupo rojo se ha movido.")
                end
            end

            -- Detectar si se detuvo justo ahora
            if grupoRojoSeMovio and distancia < 5 then
                grupoRojoSeMovio = false
                if debugActivo then
                    env.info("Grupo rojo se ha detenido. Se programará actualización en " .. tiempoReasignacion .. "s.")
                end
                mist.scheduleFunction(function()
                    reasignarRutas(puntoRojo)
                end, {}, timer.getTime() + tiempoReasignacion)
            end

            -- Siempre actualizamos la posición
            ultimaPosicionRojo = puntoRojo

            -- NUEVO: asignar ruta inicial si el grupo azul es nuevo y el rojo está quieto
            local azules = mist.getUnitsInZones(mist.makeUnitTable({'[blue]'}), {zonaDeteccion}, 'cylinder')
            for _, unidadAzul in ipairs(azules) do
                if Unit.isExist(unidadAzul) then
                    local info = mist.DBs.unitsByName[unidadAzul:getName()]
                    if info then
                        local nombreGrupoAzul = info.groupName
                        if not gruposAzulesAsignadosInicial[nombreGrupoAzul] then
                            mist.groupToPoint(nombreGrupoAzul, puntoRojo, formacionGrupo, velocidadMovimiento)
                            gruposAzulesAsignadosInicial[nombreGrupoAzul] = true
                            if debugActivo then
                                trigger.action.outText("Ruta inicial asignada a nuevo grupo azul: " .. nombreGrupoAzul, 5)
                                env.info("Ruta inicial asignada a grupo azul nuevo: " .. nombreGrupoAzul)
                            end
                        end
                    end
                end
            end
        end
    end

    mist.scheduleFunction(verificarYAsignar, {}, timer.getTime() + 5)
end

-- Ejecutar loop principal
mist.scheduleFunction(verificarYAsignar, {}, timer.getTime() + 5)

