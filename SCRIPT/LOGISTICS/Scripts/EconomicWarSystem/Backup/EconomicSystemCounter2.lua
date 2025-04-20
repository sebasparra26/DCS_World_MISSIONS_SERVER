-- ========================
-- SISTEMA ECONÓMICO - Watchdog y Menú Autoregenerable
-- ========================

-- Utilidades de formateo de puntos
local function formatearDolaresLegible(valor)
    if type(valor) ~= "number" then return "$0.00" end
    local entero, decimal = math.modf(valor)
    local partes = {}
    repeat
        table.insert(partes, 1, string.format("%03d", entero % 1000))
        entero = math.floor(entero / 1000)
    until entero == 0
    partes[1] = tostring(tonumber(partes[1])) -- elimina ceros iniciales
    local miles = table.concat(partes, ",")
    return string.format("$%s%0.2f", miles, decimal):gsub("(%.%d%d)", "%1")
end

-- Mostrar puntos cada 60 segundos
local function mostrarPuntos()
    local puntos = obtenerPuntosCoalicion(2)
    env.info("Puntos de la coalición Azul: " .. puntos)
    trigger.action.outText("Dólares de la coalición Azul: " .. formatearDolaresLegible(puntos), 3)
end
mist.scheduleFunction(mostrarPuntos, {}, timer.getTime() + 5, 60)

-- Guardar los menús creados por grupo
local menuBilleteraPorGrupo = {}
local sufijoUnico = "_BILLETERA_" .. tostring(math.random(10000, 99999))

-- Crear el menú de radio personalizado
function crearMenuBilletera()
    local jugadores = mist.makeUnitTable({ '[blue][player]' })

    for _, unitName in ipairs(jugadores) do
        local unit = Unit.getByName(unitName)
        if unit then
            local group = unit:getGroup()
            if group then
                local groupID = group:getID()

                -- Si ya existe, eliminarlo
                if menuBilleteraPorGrupo[groupID] then
                    missionCommands.removeItem(menuBilleteraPorGrupo[groupID])
                end

                -- Crear nuevo menú
                local menuRaiz = missionCommands.addSubMenuForGroup(groupID, "Billetera" .. sufijoUnico)
                menuBilleteraPorGrupo[groupID] = menuRaiz

                missionCommands.addCommandForGroup(groupID, "Consultar fondos", menuRaiz, function()
                    local puntos = obtenerPuntosCoalicion(2)
                    trigger.action.outText("Dólares de la coalición Azul: " .. formatearDolaresLegible(puntos), 3)
                end)
            end
        end
    end
end

-- Ejecutar inicialmente tras breve delay
timer.scheduleFunction(crearMenuBilletera, {}, timer.getTime() + 3)

-- Watchdog: revisar y reconstruir si hace falta
local function watchdogMenu()
    for groupID, menu in pairs(menuBilleteraPorGrupo) do
        -- Si el menú no es válido (posible pérdida tras savegame), lo re-creamos
        if not menu then
            crearMenuBilletera()
            break
        end
    end
    timer.scheduleFunction(watchdogMenu, {}, timer.getTime() + 10)
end
timer.scheduleFunction(watchdogMenu, {}, timer.getTime() + 10)
