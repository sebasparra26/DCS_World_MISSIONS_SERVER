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
-- MENÚ LOGÍSTICO AZUL - LIMPIEZA OBLIGADA
-- ============================================

-- Guardamos referencia del menú raíz para eliminación total
local menuRaizAzulID = nil

-- Función para crear todo el menú desde cero
local function crearMenuGlobalAzul()

    -- Eliminar TODO el menú raíz, forzando reconstrucción completa
    if menuRaizAzulID then
        missionCommands.removeItem(menuRaizAzulID)
        menuRaizAzulID = nil
    end

    -- Crear nuevo menú raíz
    menuRaizAzulID = missionCommands.addSubMenuForCoalition(2, "Mercado de Pulgas")

    local menuCategorias = {}

    -- Crear submenús de categoría única
    for nombreAvion, datosAvion in pairs(tiposAvion) do
        local categoria = datosAvion.categoria or "Sin Clasificar"
        if not menuCategorias[categoria] then
            menuCategorias[categoria] = missionCommands.addSubMenuForCoalition(2, categoria, menuRaizAzulID)
        end
    end

    -- Crear submenús por avión y subvariantes
    for nombreAvion, datosAvion in pairs(tiposAvion) do
        local claveTipo = datosAvion.clave
        local categoria = datosAvion.categoria or "Sin Clasificar"
        local menuCategoria = menuCategorias[categoria]

        local submenuAvion = missionCommands.addSubMenuForCoalition(2, nombreAvion, menuCategoria)

        if subvariantesAvion and subvariantesAvion[claveTipo] then
            for nombreSub, claveSub in pairs(subvariantesAvion[claveTipo]) do
                if nombreSub ~= nil and claveSub ~= nil then
                    local subVarianteMenu = missionCommands.addSubMenuForCoalition(2, nombreSub, submenuAvion)
                    crearOpcionesParaAvion(subVarianteMenu, claveSub)
                end
            end
        else
            crearOpcionesParaAvion(submenuAvion, claveTipo)
        end
    end
end

-- Refrescar 100% desde cero cada 20 segundos
mist.scheduleFunction(crearMenuGlobalAzul, {}, timer.getTime() + 5, 20)
