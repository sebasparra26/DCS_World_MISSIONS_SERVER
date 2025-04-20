-- ============================================
-- MENÚ LOGÍSTICO PARA COALICIÓN AZUL (BLUE)
-- ============================================
-- Este script crea un menú dinámico visible solo para los jugadores de la coalición azul.
-- Agrega las opciones de aeródromos controlados (bandera == 1) según el tipo de avión.
-- Las opciones se actualizan automáticamente cada 30 segundos sin duplicarse.

-- ============================================
-- Tipos de aviones disponibles en el menú
-- clave = nombre mostrado en el menú
-- valor = clave de acceso para tipoAviones[] e inventario
-- ============================================

local tiposAvion = {
    ["Mosquito FB Mk.VI"] = "Mosquito",
    ["P-51D Mustang (25NA)"] = "p51d25na",
    ["P-51D Mustang (30NA)"] = "p51d30na",
    ["TF-51D Trainer"] = "tf51d",
    ["Spitfire LF Mk.IX"] = "spitfire",
    ["Spitfire LF Mk.IX CW"] = "spitfirecw"
}

-- ============================================
-- Estructuras de control para cada grupo de jugador
-- menuRaizPorGrupo: menú principal "Mercado de Pulgas BLUE" por grupo
-- menuAvionPorGrupo: submenús por tipo de avión
-- itemsYaCreados: registro de opciones ya creadas para no repetirlas
-- ============================================

local menuRaizPorGrupo = {}
local menuAvionPorGrupo = {}
local itemsYaCreados = {}

-- ============================================
-- FUNCIÓN PRINCIPAL: crearMenuParaAzules
-- Detecta jugadores azules activos y les crea el menú de entregas.
-- Las opciones de aeropuerto se añaden solo si:
--   - La bandera del aeropuerto es 1 (control azul)
--   - El ítem no fue ya creado
--   - No está en cooldown
-- ============================================

local function crearMenuParaAzules()
    -- Obtener unidades de jugadores azules
    local jugadoresAzules = mist.makeUnitTable({'[blue][player]'})

    for _, unitName in ipairs(jugadoresAzules) do
        local unit = Unit.getByName(unitName)
        if unit then
            local group = unit:getGroup()
            if group then
                local groupID = group:getID()

                -- Crear menú raíz solo una vez por grupo
                if not menuRaizPorGrupo[groupID] then
                    menuRaizPorGrupo[groupID] = missionCommands.addSubMenuForGroup(groupID, "Mercado de Pulgas BLUE")
                    menuAvionPorGrupo[groupID] = {}
                    itemsYaCreados[groupID] = {}
                end

                local menuRoot = menuRaizPorGrupo[groupID]

                -- Crear o actualizar submenús por tipo de avión
                for nombreAvion, claveTipo in pairs(tiposAvion) do
                    -- Crear submenú por avión si no existe
                    if not menuAvionPorGrupo[groupID][claveTipo] then
                        menuAvionPorGrupo[groupID][claveTipo] = missionCommands.addSubMenuForGroup(groupID, nombreAvion, menuRoot)
                        itemsYaCreados[groupID][claveTipo] = {}
                    end

                    local menuAvion = menuAvionPorGrupo[groupID][claveTipo]

                    -- Revisar cada aeropuerto disponible
                    for aeropuerto, data in pairs(plantillasLogisticaB) do
                        local valorBandera = trigger.misc.getUserFlag(data.bandera)

                        local cooldownKey = claveTipo .. "_" .. aeropuerto
                        local cooldownActivo = menuCooldownsB[cooldownKey] and timer.getTime() < menuCooldownsB[cooldownKey]

                        -- Agregar la opción solo si bandera es 1 y no está en cooldown
                        if valorBandera == 1 and not cooldownActivo then
                            local key = aeropuerto

                            -- Verificamos si ya existe la opción
                            if not itemsYaCreados[groupID][claveTipo][key] then
                                -- Calcular costo con recargo individual por aeropuerto
                                local baseCosto = tipoAviones[claveTipo].costo
                                local recargo = recargoAeropuertoB[aeropuerto] or 1.0
                                local costo = math.floor(baseCosto * recargo)
                                local texto = aeropuerto .. " (Costo: $" .. costo .. ")"

                                -- Crear la opción de menú (entrega)
                                missionCommands.addCommandForGroup(groupID, texto, menuAvion, function()
                                    trigger.action.outText("Ejecutando entrega para " .. aeropuerto .. " con avión " .. claveTipo, 10)
                                    if tipoAviones[claveTipo] then
                                        ejecutarEntregaB(aeropuerto, data, claveTipo)
                                    else
                                        trigger.action.outText("Error: tipoAviones[" .. claveTipo .. "] no está definido", 10)
                                    end
                                end)

                                -- Marcar como creado para evitar duplicación futura
                                itemsYaCreados[groupID][claveTipo][key] = true
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ============================================
-- TEMPORIZADOR
-- Ejecuta la función cada 30 segundos
-- para verificar cambios en las banderas y actualizar menú
-- ============================================

timer.scheduleFunction(function()
    crearMenuParaAzules()
    return timer.getTime() + 30
end, {}, timer.getTime() + 2)
