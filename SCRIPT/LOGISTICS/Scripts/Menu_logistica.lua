local tiposAvion = {
    ["Mosquito FB Mk.VI"] = "Mosquito",
    ["P-51D Mustang (25NA)"] = "p51d25na",
    ["P-51D Mustang (30NA)"] = "p51d30na",
    ["TF-51D Trainer"] = "tf51d",
    ["Spitfire LF Mk.IX"] = "spitfire",
    ["Spitfire LF Mk.IX CW"] = "spitfirecw"
}

function crearMenu()
    if menuRoot then
        missionCommands.removeItem(menuRoot)
    end

    menuRoot = missionCommands.addSubMenu("Mercado de Pulgas")

    for nombreAvion, claveTipo in pairs(tiposAvion) do
        local menuAvion = missionCommands.addSubMenu(nombreAvion, menuRoot)
        local itemsPorPagina = 8
        local itemsActivos = {}

        for aeropuerto, data in pairs(plantillasLogistica) do
            local valorBandera = trigger.misc.getUserFlag(data.bandera)
            local cooldownKey = claveTipo .. "_" .. aeropuerto
            local cooldownActivo = menuCooldowns[cooldownKey] and timer.getTime() < menuCooldowns[cooldownKey]

            if valorBandera == 1 and not cooldownActivo then
                table.insert(itemsActivos, {
                    aeropuerto = aeropuerto,
                    data = data
                })
            end
        end

        local totalPaginas = math.ceil(#itemsActivos / itemsPorPagina)

        for pagina = 1, totalPaginas do
            local subMenuPagina = missionCommands.addSubMenu("Page " .. pagina, menuAvion)
            for i = 1, itemsPorPagina do
                local index = (pagina - 1) * itemsPorPagina + i
                local item = itemsActivos[index]
                if item then
                    local baseCosto = tipoAviones[claveTipo].costo
                    local recargo = recargoAeropuerto[item.aeropuerto] or 1.0
                    local costo = math.floor(baseCosto * recargo)
                    local texto = item.aeropuerto .. " (Costo: $" .. costo .. ")"

                    missionCommands.addCommand(texto, subMenuPagina, function()
                        ejecutarEntrega(item.aeropuerto, item.data, claveTipo)
                    end)
                end
            end
        end
    end
end

-- Actualizar menú cada 20 segundos
timer.scheduleFunction(function()
    crearMenu()
    return timer.getTime() + 20
end, {}, timer.getTime() + 1)
