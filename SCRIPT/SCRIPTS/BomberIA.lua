-- ============================================
-- SISTEMA DE CLONADO ILIMITADO DE BOMBARDEROS CON DEBUG OPCIONAL
-- ============================================

-- Activar o desactivar mensajes y marcas de depuración
local debugClonado = false

-- Lista de plantillas a usar
local plantillasBombardero = {}
for i = 1, 10 do
    table.insert(plantillasBombardero, "TR_BOMBER_IA-" .. i)
end

-- Intervalo entre clones en segundos (45 minutos)
local intervaloClonado = 4000

-- Función para clonar una plantilla al azar con debug opcional
local function clonarBombardero()
    local plantilla = plantillasBombardero[math.random(#plantillasBombardero)]
    local grupoClonado = mist.cloneGroup(plantilla, true)

    if grupoClonado and grupoClonado.name then
        if debugClonado then
            trigger.action.outText("Clonado grupo: " .. grupoClonado.name .. " desde plantilla: " .. plantilla, 10)
        end

        mist.scheduleFunction(function()
            local grupo = Group.getByName(grupoClonado.name)
            if grupo and grupo:getUnit(1) then
                local punto = grupo:getUnit(1):getPoint()

                if debugClonado then
                    trigger.action.markToAll(9999, "Grupo clonado aquí: " .. grupoClonado.name, punto, true)
                    trigger.action.outText("Grupo " .. grupoClonado.name .. " apareció correctamente", 10)
                end
            else
                if debugClonado then
                    trigger.action.outText("Error: grupo " .. grupoClonado.name .. " no existe en el mundo", 10)
                end
            end
        end, {}, timer.getTime() + 5)
    else
        if debugClonado then
            trigger.action.outText("Error al clonar desde plantilla: " .. plantilla, 10)
        end
    end
end

-- Primera ejecución inmediata
clonarBombardero()

-- Repetir cada 45 minutos
mist.scheduleFunction(clonarBombardero, {}, timer.getTime() + intervaloClonado, intervaloClonado)
