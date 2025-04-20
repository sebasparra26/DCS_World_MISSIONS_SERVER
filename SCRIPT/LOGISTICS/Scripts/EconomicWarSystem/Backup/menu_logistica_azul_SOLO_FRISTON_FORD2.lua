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
-- MENÚ LOGÍSTICO AZUL - CREACIÓN UNA SOLA VEZ
-- Y ACTUALIZACIÓN INTERNA SIN CLONACIÓN
-- ============================================

local menuYaCreadoAzul = false
local menuRaizAzul = nil
local menuCategorias = {}
local menuAviones = {}
local menuSubvariantes = {}

-- Limpieza interna de comandos dentro del submenú (no borra el menú, solo su contenido)
local function limpiarComandos(menuID)
    local dummyCommand = missionCommands.addCommandForCoalition(2, "_clean", menuID, function() end)
    missionCommands.removeItem(dummyCommand)
end

-- Crear o actualizar las opciones para un avión o subvariante
-- Crear o actualizar las opciones para un avión o subvariante con menú de aeropuertos dinámicos
paginasPorAvion = paginasPorAvion or {}
-- Opciones por subvariante, con paginación fija y limpieza solo de comandos


function actualizarOpcionesParaAvion(menuAvion, claveSubVar)
    paginasPorAvion[claveSubVar] = paginasPorAvion[claveSubVar] or {}

    local porPagina = 8
    local entradas = {}

    if claveSubVar == "Mosquito-FB-Mk-VI-S" then
        entradas = {
            {nombre = "Friston", data = plantillasLogisticaB["Friston"]},
            {nombre = "Ford", data = plantillasLogisticaB["Ford"]}
        }
    else
        for aeropuerto, data in pairs(plantillasLogisticaB) do
            table.insert(entradas, {nombre = aeropuerto, data = data})
        end
    end

    local totalPaginas = math.ceil(#entradas / porPagina)
    if totalPaginas == 0 then totalPaginas = 1 end

    for pagina = 1, totalPaginas do
        local nombreSubmenu = totalPaginas == 1 and "Opciones" or "Página " .. pagina

        if not paginasPorAvion[claveSubVar][pagina] then
            local subID = missionCommands.addSubMenuForCoalition(2, nombreSubmenu, menuAvion)
            paginasPorAvion[claveSubVar][pagina] = subID
        end

        local subID = paginasPorAvion[claveSubVar][pagina]
        local dummy = missionCommands.addCommandForCoalition(2, "_clear", subID, function() end)
        missionCommands.removeItem(dummy)

        for i = 1, porPagina do
            local idx = (pagina - 1) * porPagina + i
            local entrada = entradas[idx]
            if entrada then
                local aeropuerto = entrada.nombre
                local data = entrada.data
                local baseCosto = tipoAviones[claveSubVar] and tipoAviones[claveSubVar].costo or 0
                local recargo = recargoAeropuertoB[aeropuerto] or 1.0
                local costo = math.floor(baseCosto * recargo)
                local texto = "Enviar a: " .. aeropuerto .. " (USD " .. formatearDolaresLegibleB(costo) .. ")"

                missionCommands.addCommandForCoalition(2, texto, subID, function()
                    if trigger.misc.getUserFlag(data.bandera) == 1 then
                        ejecutarEntregaB(aeropuerto, data, claveSubVar)
                        trigger.action.outText("Enviando a " .. aeropuerto .. " con avión " .. claveSubVar, 10)
                    else
                        trigger.action.outText("El aeropuerto " .. aeropuerto .. " no está disponible actualmente.", 10)
                    end
                end)
            end
        end
    end
end

-- Crear el menú completo UNA VEZ
local function crearMenuLogisticoAzul()
    if menuYaCreadoAzul then return end
    menuYaCreadoAzul = true

    menuRaizAzul = missionCommands.addSubMenuForCoalition(2, "Mercado de Pulgas")
    menuCategorias = {}

    for nombreAvion, datosAvion in pairs(tiposAvion) do
        local categoria = datosAvion.categoria or "Sin Clasificar"
        if not menuCategorias[categoria] then
            menuCategorias[categoria] = missionCommands.addSubMenuForCoalition(2, categoria, menuRaizAzul)
        end
    end

    for nombreAvion, datosAvion in pairs(tiposAvion) do
        local claveTipo = datosAvion.clave
        local categoria = datosAvion.categoria or "Sin Clasificar"
        local menuCat = menuCategorias[categoria]

        local menuAvion = missionCommands.addSubMenuForCoalition(2, nombreAvion, menuCat)
        menuAviones[claveTipo] = menuAvion

        if subvariantesAvion and subvariantesAvion[claveTipo] then
            for nombreSub, claveSub in pairs(subvariantesAvion[claveTipo]) do
                local menuSub = missionCommands.addSubMenuForCoalition(2, nombreSub, menuAvion)
                menuSubvariantes[claveSub] = menuSub
            end
        end
    end
end

-- Refrescar el contenido dinámico CADA 20 segundos sin recrear jerarquía
local function actualizarContenidoAzul()
    for claveTipo, menuAvion in pairs(menuAviones) do
        if subvariantesAvion and subvariantesAvion[claveTipo] then
            for _, claveSub in pairs(subvariantesAvion[claveTipo]) do
                if menuSubvariantes[claveSub] then
                    actualizarOpcionesParaAvion(menuSubvariantes[claveSub], claveSub)
                end
            end
        else
            actualizarOpcionesParaAvion(menuAvion, claveTipo)
        end
    end
end

-- Crear una vez y luego refrescar contenido
mist.scheduleFunction(crearMenuLogisticoAzul, {}, timer.getTime() + 1)
mist.scheduleFunction(actualizarContenidoAzul, {}, timer.getTime() + 5, 20)
