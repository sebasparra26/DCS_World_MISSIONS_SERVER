-- Función para formatear como dólares con comas (cientos, miles, millones)
local function formatearDolaresLegibleB(valor)
    if type(valor) ~= "number" then
        return "$0.00"
    end

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

-- Función que muestra los puntos en pantalla (automáticamente cada 60s)
function mostrarPuntos()
    local puntosAzul = obtenerPuntosCoalicion(2)
    env.info("Puntos de la coalición Azul: " .. puntosAzul)
    trigger.action.outText("Dólares de la coalición Azul: " .. formatearDolaresLegibleB(puntosAzul), 3)
end

mist.scheduleFunction(mostrarPuntos, {}, timer.getTime() + 5, 60)


-- Menú de radio para consultar puntos manualmente
local function crearMenuBilletera()
    local jugadoresAzules = mist.makeUnitTable({'[blue][player]'})

    for _, unitName in ipairs(jugadoresAzules) do
        local unit = Unit.getByName(unitName)
        if unit then
            local group = unit:getGroup()
            if group then
                local groupID = group:getID()

                -- Crear submenú "Billetera"
                local menuBilletera = missionCommands.addSubMenuForGroup(groupID, "Billetera")

                -- Opción para mostrar puntos actuales
                missionCommands.addCommandForGroup(groupID, "Consultar fondos", menuBilletera, function()
                    local puntosAzul = obtenerPuntosCoalicion(2)
                    trigger.action.outText("Dólares de la coalición Azul: " .. formatearDolaresLegibleB(puntosAzul), 3)
                end)
            end
        end
    end
end

-- Crear el menú una vez al inicio
timer.scheduleFunction(crearMenuBilletera, {}, timer.getTime() + 3)

-- Mostrar automáticamente los puntos cada 60 segundos
mist.scheduleFunction(mostrarPuntos, {}, timer.getTime() + 5, 60)
