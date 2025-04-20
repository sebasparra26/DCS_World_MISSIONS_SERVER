-- ============================================
-- MENÚ LOGÍSTICO PARA COALICIÓN AZUL (BLUE)
-- ============================================

-- Tipos de aviones disponibles
local tiposAvion = {
    ["Mosquito FB Mk VI"] = {
        clave = "MosquitoPayload",
        categoria = "Nacionales UK"
    },
    ["P-51D Mustang (25NA)"] = {
        clave = "p51d25naPayload",
        categoria = "Importados USA"
    },
    ["P-51D Mustang (30NA)"] = {
        clave = "p51d30na",
        categoria = "Importados USA"
    },
    ["TF-51D Trainer"] = {
        clave = "tf51d",
        categoria = "Importados USA"
    },
    ["Spitfire LF Mk.IX"] = {
        clave = "spitfire",
        categoria = "Nacionales UK"
    },
    ["Spitfire LF Mk.IX CW"] = {
        clave = "spitfirecw",
        categoria = "Nacionales UK"
    },
    ["BF-109 k-4"] = {
        clave = "bf109k4",
        categoria = "Importados Alemania"
    },
    ["P-47D-30"] = {
        clave = "P-47D-30Payload",
        categoria = "Importados USA"
    },
    ["P-47D-30-Early"] = {
        clave = "P-47D-30EPayload",
        categoria = "Importados USA"
    },
    ["P-47D-40"] = {
        clave = "P-47D-40Payload",
        categoria = "Importados USA"
    }
  
}

-- Subvariantes por tipo de avión
local subvariantesAvion = {
  ["MosquitoPayload"] = {
        ["Mosquito FB Mk-VI - Standard Unit"] = "Mosquito-FB-Mk-VI-S",
        ["Mosquito FB Mk-VI - Interceptor Squadron"] = "Mosquito-FB-Mk-VI-I",
        ["osquito FB Mk-VI - Bombing Wing"] = "Mosquito-FB-Mk-VI-B",
        ["Mosquito FB Mk-VI - Tactical G-Attack"] = "Mosquito-FB-Mk-VI-TA",
        ["Mosquito FB Mk-VI - Logistic"] = "Mosquito-FB-Mk-VI-L"
    },
    ["p51d25naPayload"] = {
        ["P-51D (25NA) - Default"] = "p51d25_default",
        ["P-51D (25NA) - Bombas"] = "p51d25_bombas",
        ["P-51D (25NA) - Cohetes"] = "p51d25_cohetes"
    },
    ["p51d30na"] = {
        ["P-51D (30NA) - Default"] = "p51d30_default",
        ["P-51D (30NA) - Bombas"] = "p51d30_bombas",
        ["P-51D (30NA) - Cohetes"] = "p51d30_cohetes"
    },
    ["tf51d"] = {
        ["TF-51D - Default"] = "tf51d_default"
    },
    ["spitfire"] = {
        ["Spitfire - Default"] = "spitfire_default",
        ["Spitfire - Bombas"] = "spitfire_bombas",
        ["Spitfire - Tanques"] = "spitfire_tanques"
    },
    ["spitfirecw"] = {
        ["Spitfire CW - Default"] = "spitfirecw_default",
        ["Spitfire CW - Bombas"] = "spitfirecw_bombas",
        ["Spitfire CW - Tanques"] = "spitfirecw_tanques"
    },
    ["bf109k4"] = {
        ["BF-109 - Default"] = "bf109k4_default",
        ["BF-109 - Bombas"] = "bf109k4_bombas",
        ["BF-109 - Tanques"] = "bf109k4_tanques"
    },
    ["P-47D-30Payload"] = {
        ["BF-109 - Default"] = "bf109k4_default",
        ["BF-109 - Bombas"] = "bf109k4_bombas",
        ["BF-109 - Tanques"] = "bf109k4_tanques"
    },
    ["P-47D-30EPayload"] = {
        ["BF-109 - Default"] = "bf109k4_default",
        ["BF-109 - Bombas"] = "bf109k4_bombas",
        ["BF-109 - Tanques"] = "bf109k4_tanques"
    },
    ["P-47D-40Payload"] = {
        ["BF-109 - Default"] = "bf109k4_default",
        ["BF-109 - Bombas"] = "bf109k4_bombas",
        ["BF-109 - Tanques"] = "bf109k4_tanques"
    }
}

-- ============================================
-- MENÚ LOGÍSTICO PARA COALICIÓN AZUL (ROBUSTO)
-- ============================================

local menusAzulActivos = {}

-- Elimina todos los menús anteriores antes de regenerar
local function limpiarMenusAzul()
    for _, id in ipairs(menusAzulActivos) do
        missionCommands.removeItem(id)
    end
    menusAzulActivos = {}
end

-- Crea todas las opciones de entrega para una variante de avión
function crearOpcionesParaAvion(menuAvion, claveSubVar)
    local porPagina = 8
    local entradas = {}

    for aeropuerto, data in pairs(plantillasLogisticaB) do
        local valorBandera = trigger.misc.getUserFlag(data.bandera)
        local cooldownKey = claveSubVar .. "_" .. aeropuerto
        local cooldownActivo = menuCooldownsB[cooldownKey] and timer.getTime() < menuCooldownsB[cooldownKey]

        if valorBandera == 1 and not cooldownActivo then
            table.insert(entradas, {nombre = aeropuerto, data = data})
        end
    end

    local totalPaginas = math.ceil(#entradas / porPagina)

    for pagina = 1, totalPaginas do
        local nombreSubmenu = totalPaginas == 1 and "Opciones" or "Página " .. pagina
        local submenuPag = missionCommands.addSubMenuForCoalition(2, nombreSubmenu, menuAvion)
        table.insert(menusAzulActivos, submenuPag)

        for i = 1, porPagina do
            local idx = (pagina - 1) * porPagina + i
            local entrada = entradas[idx]
            if entrada then
                local aeropuerto = entrada.nombre
                local data = entrada.data
                local baseCosto = tipoAviones[claveSubVar] and tipoAviones[claveSubVar].costo or 0
                local recargo = recargoAeropuertoB[aeropuerto] or 1.0
                local costo = math.floor(baseCosto * recargo)
                local texto = "Comprar y Enviar A: " .. aeropuerto .. " (Costo: USD " .. formatearDolaresLegibleB(costo) .. ")"

                local comando = missionCommands.addCommandForCoalition(2, texto, submenuPag, function()
                    trigger.action.outText("Ejecutando entrega para " .. aeropuerto .. " con avión " .. claveSubVar, 10)
                    if tipoAviones[claveSubVar] then
                        ejecutarEntregaB(aeropuerto, data, claveSubVar)
                    else
                        trigger.action.outText("Error: tipoAviones[" .. claveSubVar .. "] no está definido", 10)
                    end
                end)

                table.insert(menusAzulActivos, comando)
            end
        end
    end
end

-- Construye el menú principal y sus categorías
local function crearMenuGlobalAzul()
    limpiarMenusAzul()

    local menuRaizAzul = missionCommands.addSubMenuForCoalition(2, "Mercado de Pulgas")
    table.insert(menusAzulActivos, menuRaizAzul)

    local menuCategorias = {}

    for nombreAvion, datosAvion in pairs(tiposAvion) do
        local categoria = datosAvion.categoria or "Sin Clasificar"

        -- Crear la categoría solo si no ha sido creada
        if not menuCategorias[categoria] then
            local catMenu = missionCommands.addSubMenuForCoalition(2, categoria, menuRaizAzul)
            menuCategorias[categoria] = catMenu
            table.insert(menusAzulActivos, catMenu)
        end
    end

    for nombreAvion, datosAvion in pairs(tiposAvion) do
        local claveTipo = datosAvion.clave
        local categoria = datosAvion.categoria or "Sin Clasificar"
        local menuRoot = menuCategorias[categoria]

        local submenuAvion = missionCommands.addSubMenuForCoalition(2, nombreAvion, menuRoot)
        table.insert(menusAzulActivos, submenuAvion)

        if subvariantesAvion and subvariantesAvion[claveTipo] then
            for nombreSub, claveSub in pairs(subvariantesAvion[claveTipo]) do
                if nombreSub ~= nil and claveSub ~= nil then
                    local subVarianteMenu = missionCommands.addSubMenuForCoalition(2, nombreSub, submenuAvion)
                    table.insert(menusAzulActivos, subVarianteMenu)
                    crearOpcionesParaAvion(subVarianteMenu, claveSub)
                else
                    trigger.action.outText("Subvariante inválida en " .. claveTipo, 5)
                end
            end
        else
            crearOpcionesParaAvion(submenuAvion, claveTipo)
        end
    end
end

-- Refrescar el menú cada 20 segundos
mist.scheduleFunction(crearMenuGlobalAzul, {}, timer.getTime() + 5, 20)
