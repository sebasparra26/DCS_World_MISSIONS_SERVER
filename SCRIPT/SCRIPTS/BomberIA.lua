-- ============================================
-- SISTEMA DE CLONADO ILIMITADO DE BOMBARDEROS CON DEBUG OPCIONAL
-- ============================================

-- Activar o desactivar mensajes y marcas de depuración
local debugClonado = false

-- Lista de plantillas a usar
local plantillasBombardero = {}
for i = 1, 4 do
    table.insert(plantillasBombardero, "TR_BOMBER_IA-" .. i)
end

-- Intervalo entre clones en segundos (45 minutos)
local intervaloClonado = 4000

local function obtenerPlantillaAleatoria()
    return plantillasBombardero[math.random(#plantillasBombardero)]
end

local function depurarGrupoClonado(nombreGrupo)
    local grupo = Group.getByName(nombreGrupo)

    if grupo and grupo:isExist() and grupo:getUnit(1) then
        local punto = grupo:getUnit(1):getPoint()

        trigger.action.markToAll(9999, "Grupo clonado aqui: " .. nombreGrupo, punto, true)
        trigger.action.outText("Grupo " .. nombreGrupo .. " aparecio correctamente", 10)
        return
    end

    trigger.action.outText("Error: grupo " .. nombreGrupo .. " no existe en el mundo", 10)
end

-- Función para clonar una plantilla al azar con debug opcional
local function clonarBombardero()
    local plantilla = obtenerPlantillaAleatoria()
    local grupoClonado = mist.cloneGroup(plantilla, true)

    if not grupoClonado or not grupoClonado.name then
        if debugClonado then
            trigger.action.outText("Error al clonar desde plantilla: " .. plantilla, 10)
        end
        return
    end

    if debugClonado then
        trigger.action.outText("Clonado grupo: " .. grupoClonado.name .. " desde plantilla: " .. plantilla, 10)

        -- La verificacion del grupo solo se agenda en modo debug para evitar
        -- una busqueda extra por nombre en cada ciclo normal de clonacion.
        mist.scheduleFunction(depurarGrupoClonado, { grupoClonado.name }, timer.getTime() + 5)
    end
end

-- Primera ejecución inmediata
clonarBombardero()

-- Repetir cada 45 minutos
mist.scheduleFunction(clonarBombardero, {}, timer.getTime() + intervaloClonado, intervaloClonado)
