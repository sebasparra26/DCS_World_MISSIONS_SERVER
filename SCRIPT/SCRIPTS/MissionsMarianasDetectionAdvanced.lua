-- Configuración
local zonaDeteccion = 'DETECT'
local velocidadMovimiento = 800
local formacionGrupo = 'diamond'
local debugActivo = true

-- Estado
local grupoRojoActivo = nil
local nombreGrupoRojoActivo = nil
local asignacionesActuales = {}  -- [grupo azul] = nombre del grupo rojo que se le asignó

local function verificarYAsignar()
    -- Verificar si el grupo rojo activo aún existe
    if grupoRojoActivo and not Group.isExist(grupoRojoActivo) then
        if debugActivo then
            trigger.action.outText("Grupo rojo destruido. Esperando uno nuevo.", 5)
            env.info("Grupo rojo destruido. Esperando uno nuevo.")
        end
        grupoRojoActivo = nil
        nombreGrupoRojoActivo = nil
        asignacionesActuales = {}
    end

    -- Buscar nuevo grupo rojo si no hay uno activo
    if not grupoRojoActivo then
        local rojosEnZona = mist.getUnitsInZones(mist.makeUnitTable({'[red]'}), {zonaDeteccion}, 'cylinder')
        if #rojosEnZona > 0 then
            local unidadRoja = rojosEnZona[1]
            if unidadRoja and Unit.isExist(unidadRoja) then
                grupoRojoActivo = Unit.getGroup(unidadRoja)
                if grupoRojoActivo then
                    nombreGrupoRojoActivo = grupoRojoActivo:getName()
                    asignacionesActuales = {}  -- Resetear asignaciones para nuevo objetivo

                    if debugActivo then
                        trigger.action.outText("Nuevo grupo rojo detectado: " .. nombreGrupoRojoActivo, 5)
                        env.info("Nuevo grupo rojo detectado: " .. nombreGrupoRojoActivo)
                    end
                end
            end
        end
    end

    -- Si hay grupo rojo activo, verificar nuevos grupos azules
    if grupoRojoActivo and Group.isExist(grupoRojoActivo) then
        local unidadesRojo = grupoRojoActivo:getUnits()
        if unidadesRojo and #unidadesRojo > 0 and Unit.isExist(unidadesRojo[1]) then
            local puntoRojo = Unit.getPoint(unidadesRojo[1])

            local azulesEnZona = mist.getUnitsInZones(mist.makeUnitTable({'[blue]'}), {zonaDeteccion}, 'cylinder')
            local gruposAzules = {}

            for _, unidadAzul in ipairs(azulesEnZona) do
                if unidadAzul and Unit.isExist(unidadAzul) then
                    local unitName = unidadAzul:getName()
                    local infoUnidad = mist.DBs.unitsByName[unitName]
                    if infoUnidad then
                        local nombreGrupoAzul = infoUnidad.groupName
                        gruposAzules[nombreGrupoAzul] = true
                    end
                end
            end

            for nombreGrupoAzul, _ in pairs(gruposAzules) do
                if asignacionesActuales[nombreGrupoAzul] ~= nombreGrupoRojoActivo then
                    mist.groupToPoint(nombreGrupoAzul, puntoRojo, formacionGrupo, velocidadMovimiento)
                    asignacionesActuales[nombreGrupoAzul] = nombreGrupoRojoActivo

                    if debugActivo then
                        trigger.action.outText("Grupo azul " .. nombreGrupoAzul .. " asignado a " .. nombreGrupoRojoActivo, 5)
                        env.info("Grupo azul " .. nombreGrupoAzul .. " se mueve hacia grupo rojo " .. nombreGrupoRojoActivo)
                    end
                end
            end
        else
            -- El grupo rojo ya no tiene unidades
            if debugActivo then
                trigger.action.outText("Grupo rojo sin unidades. Eliminando.", 5)
                env.info("Grupo rojo sin unidades. Eliminando.")
            end
            grupoRojoActivo = nil
            nombreGrupoRojoActivo = nil
            asignacionesActuales = {}
        end
    end

    -- Repetir cada 5 segundos
    mist.scheduleFunction(verificarYAsignar, {}, timer.getTime() + 5)
end

-- Ejecutar la función inicial
mist.scheduleFunction(verificarYAsignar, {}, timer.getTime() + 5)