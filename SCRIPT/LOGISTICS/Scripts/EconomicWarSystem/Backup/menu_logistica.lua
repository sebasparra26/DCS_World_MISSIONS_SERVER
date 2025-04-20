-- Scripts/menu_logistica.lua

-- DEBUG SWITCHES
local DEBUG_MENU      = true
local DEBUG_LOGISTICA = true

-- ==============================
-- 1) VARIABLES GLOBALES DE LOGÍSTICA
-- ==============================
puntosCoalicion    = puntosCoalicion    or { PuntosAZUL = 500000, PuntosROJO = 0 }
menuCooldownsB     = menuCooldownsB     or {}
activeDeliveriesB  = activeDeliveriesB  or {}
tipoAviones        = tipoAviones        or {}
nombresPosiblesB   = nombresPosiblesB   or {}
for i = 1, 9999 do table.insert(nombresPosiblesB, "USA air " .. i) end

local cooldownTiempo = 10 -- segundos

local plantillasLogisticaB = {
    ["Ford"]               = { template = "Supplies_C-47ToFord",         bandera = 101 },
    ["Friston"]            = { template = "Supplies_MosquitoToFriston",  bandera = 102 },
    ["Maupertus"]          = { template = "Supplies_C-47ToMaupertus",    bandera = 103 },
    ["Brucheville"]        = { template = "Supplies_MosquitoToBrucheville", bandera = 104 },
    ["Carpiquet"]          = { template = "Supplies_MosquitoToCarpiquet",   bandera = 105 },
    ["Ronai"]              = { template = "Supplies_C-47ToRonai",       bandera = 106 },
    ["Bernay Saint Martin"]= { template = "Supplies_C-47ToBernay",      bandera = 107 },
    ["Barville"]           = { template = "Supplies_C-47ToBarville",    bandera = 108 },
    ["Evreux"]             = { template = "Supplies_C-47ToEvreux",      bandera = 109 },
    ["Orly"]               = { template = "Supplies_C-47ToOrly",        bandera = 110 },
    ["Fecamp-Benouville"]  = { template = "Supplies_C-47ToFecamp-Benouville", bandera = 111 },
    ["Saint-Aubin"]        = { template = "Supplies_MosquitoToSaint-Aubin",  bandera = 112 },
    ["Beauvais-Tille"]     = { template = "Supplies_MosquitoToBeauvais-Tille", bandera = 113 },
    ["Amiens-Glisy"]       = { template = "Supplies_MosquitoToAmiens-Glisy",   bandera = 114 },
    ["Abbeville Drucat"]   = { template = "Supplies_MosquitoToAbbeville",     bandera = 115 },
}

local recargoAeropuertoB = {
    ["Ford"] = 1.0, ["Friston"] = 1.1, ["Maupertus"] = 1.2, ["Brucheville"] = 1.3,
    ["Carpiquet"] = 1.4, ["Ronai"] = 1.5, ["Bernay Saint Martin"] = 1.6, ["Barville"] = 1.7,
    ["Evreux"] = 1.8, ["Orly"] = 1.9, ["Fecamp-Benouville"] = 2.0, ["Saint-Aubin"] = 2.1,
    ["Beauvais-Tille"] = 2.2, ["Amiens-Glisy"] = 2.3, ["Abbeville Drucat"] = 2.4
}

local multiplicadorTiempoB = {
    ["Ford"] = 1.1, ["Friston"] = 1.0, ["Maupertus"] = 1.3, ["Brucheville"] = 1.2,
    ["Carpiquet"] = 1.25, ["Ronai"] = 1.4, ["Bernay Saint Martin"] = 1.35,
    ["Barville"] = 1.3, ["Evreux"] = 1.45, ["Orly"] = 1.5, ["Fecamp-Benouville"] = 1.2,
    ["Saint-Aubin"] = 1.15, ["Beauvais-Tille"] = 1.3, ["Amiens-Glisy"] = 1.4,
    ["Abbeville Drucat"] = 1.35
}

local coordenadasAerodromosB = {
    ["Ford"]               = { x = 147466, z = -25753 },
    ["Friston"]            = { x = 143314, z =  28130 },
    ["Maupertus"]          = { x =  16011, z = -84865 },
    ["Brucheville"]        = { x = -14865, z = -66032 },
    ["Carpiquet"]          = { x = -34775, z = -9992  },
    ["Ronai"]              = { x = -73108, z =  12832 },
    ["Bernay Saint Martin"]= { x = -39530, z =  67036 },
    ["Barville"]           = { x = -39512, z =  67098 },
    ["Evreux"]             = { x = -60606, z = 117326 },
    ["Orly"]               = { x = -73529, z = 200430 },
    ["Fecamp-Benouville"]  = { x =  31004, z =  46274 },
    ["Saint-Aubin"]        = { x =  48979, z =  97582 },
    ["Beauvais-Tille"]     = { x =   6070, z = 175169 },
    ["Amiens-Glisy"]       = { x =  53411, z = 191760 },
    ["Abbeville Drucat"]   = { x =  81026, z = 150752 },
}

function cargarInventarioCompletoB(nombreAeropuerto, data)
    local base = Airbase.getByName(nombreAeropuerto)
    if not base then return end
    local warehouse = base:getWarehouse()
    if not warehouse then return end

    local resumen, totalAviones = {}, 0
    if data.avion then
        Warehouse.addItem(warehouse, data.avion.ws, data.avion.cantidad)
        totalAviones = data.avion.cantidad
    end

    local function cargarSeccion(seccion, nombre)
        for tipo, item in pairs(seccion or {}) do
            Warehouse.addItem(warehouse, item.ws, item.cantidad)
            table.insert(resumen, nombre .. ": " .. tipo .. " x" .. item.cantidad)
        end
    end

    cargarSeccion(data.bombas,   "BOMBA")
    cargarSeccion(data.cohetes,  "COHETE")
    cargarSeccion(data.tanques,  "TANQUE")
    cargarSeccion(data.misiles,  "MISIL")
    cargarSeccion(data.misc,     "MISCELANEO")

    local mensaje = "Suministros entregados en " .. nombreAeropuerto .. ":\n\n"
    mensaje = mensaje .. (data.nombreAvion or "Avión") .. " x" .. totalAviones .. "\n"
    mensaje = mensaje .. table.concat(resumen, "\n")
    trigger.action.outText(mensaje, 15)
end

function ejecutarEntregaB(aeropuerto, data, tipoAvion)
    if trigger.misc.getUserFlag(data.bandera) ~= 1 then
        trigger.action.outText("Aeródromo no disponible: " .. aeropuerto, 10)
        return
    end

    local key = tipoAvion .. "_" .. aeropuerto
    if menuCooldownsB[key] and timer.getTime() < menuCooldownsB[key] then
        trigger.action.outText("Ya pediste a " .. aeropuerto .. ", espera el cooldown.", 10)
        return
    end

    local baseCosto = tipoAviones[tipoAvion].costo or 0
    local recargo   = recargoAeropuertoB[aeropuerto] or 1
    local costo     = math.floor(baseCosto * recargo)

    if puntosCoalicion.PuntosAZUL < costo then
        trigger.action.outText("No tienes suficientes dólares. Requiere: " .. formatearDolaresLegibleB(costo), 10)
        return
    end

    local origen  = { x = 202611, z = 7004 }
    local destino = coordenadasAerodromosB[aeropuerto] or { x = 0, z = 0 }
    local dx, dz  = destino.x - origen.x, destino.z - origen.z
    local distancia = math.sqrt(dx*dx + dz*dz)
    local velocidad = 138.88
    local tiempoEst = math.floor((distancia/velocidad) * (multiplicadorTiempoB[aeropuerto] or 1))
    local minutos, segundos = math.floor(tiempoEst/60), tiempoEst%60

    trigger.action.outText("Compra confirmada. Enviando a " .. aeropuerto, 10)
    trigger.action.outText("Llegada estimada: " .. minutos .. " min " .. segundos .. " seg", 10)

    local nombresAntes = {}
    for _, n in ipairs(nombresPosiblesB) do
        if Group.getByName(n) and Group.getByName(n):isExist() then
            nombresAntes[n] = true
        end
    end

    mist.cloneGroup(data.template, true)

    timer.scheduleFunction(function()
        for _, n in ipairs(nombresPosiblesB) do
            if Group.getByName(n) and Group.getByName(n):isExist() and not nombresAntes[n] then
                activeDeliveriesB[n] = {
                    destino   = aeropuerto,
                    plantilla = data.template,
                    entregado = false,
                    inventario= tipoAvion,
                    altMax    = 0
                }
                puntosCoalicion.PuntosAZUL = puntosCoalicion.PuntosAZUL - costo
                menuCooldownsB[key] = timer.getTime() + cooldownTiempo
                break
            end
        end
    end, {}, timer.getTime()+1)
end

local function verificarAterrizajes()
    for nombreGrupo, info in pairs(activeDeliveriesB) do
        if not info.entregado then
            local grupo = Group.getByName(nombreGrupo)
            if grupo and Group.isExist(grupo) then
                local unidad = grupo:getUnit(1)
                if unidad then
                    local alt = unidad:getPoint().y
                    info.altMax = math.max(info.altMax, alt)
                    local v = unidad:getVelocity()
                    local speed = math.sqrt(v.x^2 + v.z^2)
                    if info.altMax >= 914.4 and speed < 0.5 then
                        cargarInventarioCompletoB(info.destino, tipoAviones[info.inventario])
                        info.entregado = true
                    end
                end
            end
        end
    end
    timer.scheduleFunction(verificarAterrizajes, {}, timer.getTime()+5)
end

-- ==============================
-- 2) CÓDIGO DEL MENÚ “Mercado de Pulgas BLUE”
-- ==============================
local tiposAvion = {
    ["Mosquito FB Mk VI"]        = { clave = "MosquitoPayload",    categoria = "Nacionales UK" },
    ["P-51D Mustang (25NA)"]     = { clave = "p51d25naPayload",    categoria = "Importados USA" },
    ["P-51D Mustang (30NA)"]     = { clave = "p51d30na",           categoria = "Importados USA" },
    ["TF-51D Trainer"]           = { clave = "tf51d",              categoria = "Importados USA" },
    ["Spitfire LF Mk.IX"]        = { clave = "spitfire",           categoria = "Nacionales UK" },
    ["Spitfire LF Mk.IX CW"]     = { clave = "spitfirecw",         categoria = "Nacionales UK" },
    ["BF-109 k-4"]               = { clave = "bf109k4",            categoria = "Importados Alemania" },
    ["P-47D-30"]                 = { clave = "P-47D-30Payload",    categoria = "Importados USA" },
    ["P-47D-30-Early"]           = { clave = "P-47D-30EPayload",  categoria = "Importados USA" },
    ["P-47D-40"]                 = { clave = "P-47D-40Payload",    categoria = "Importados USA" },
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

local menuRaizPorGrupo   = {}
local menuAvionPorGrupo  = {}
local itemsYaCreados     = {}

local function formatearDolaresLegibleB(valor)
    if type(valor) ~= "number" then return "$0,00" end
    local entero  = math.floor(valor)
    local decimal = valor - entero
    local partes  = {}
    repeat
        table.insert(partes, 1, string.format("%03d", entero % 1000))
        entero = math.floor(entero / 1000)
    until entero == 0
    partes[1] = tostring(tonumber(partes[1]))
    local numStr = table.concat(partes, ".")
    local decStr = string.format(",%02d", math.floor(decimal*100+0.5))
    return "$"..numStr..decStr
end

local function crearMenuParaAzules()
    if DEBUG_MENU then env.info('[menu] refrescando Mercado de Pulgas BLUE') end
    local azules = mist.makeUnitTable({'[blue][player]'})
    for _, unitName in ipairs(azules) do
        local unit  = Unit.getByName(unitName)
        if unit then
            local grp   = unit:getGroup()
            local gid   = grp and grp:getID()
            if gid then
                -- crear menú raíz por grupo si hace falta
                if not menuRaizPorGrupo[gid] then
                    local raiz = missionCommands.addSubMenuForGroup(gid, "Mercado de Pulgas BLUE")
                    -- categorías
                    local cats = {}
                    for _, d in pairs(tiposAvion) do cats[d.categoria or "Sin Clasificar"] = true end
                    local menuCats = {}
                    for c in pairs(cats) do
                        menuCats[c] = missionCommands.addSubMenuForGroup(gid, c, raiz)
                    end
                    menuRaizPorGrupo[gid]  = menuCats
                    menuAvionPorGrupo[gid] = {}
                    itemsYaCreados[gid]    = {}
                end

                local menuCats = menuRaizPorGrupo[gid]
                -- para cada tipo y subvariante
                for nombreAv, datos in pairs(tiposAvion) do
                    local clave  = datos.clave
                    local categoria = datos.categoria or "Sin Clasificar"
                    -- inicializar submenus si hace falta…
                    menuAvionPorGrupo[gid][clave] = menuAvionPorGrupo[gid][clave] or {}
                    itemsYaCreados[gid]._paginas = itemsYaCreados[gid]._paginas or {}
                    itemsYaCreados[gid]._paginas[clave] = itemsYaCreados[gid]._paginas[clave] or {}

                    -- eliminar páginas previas
                    for _, sub in ipairs(itemsYaCreados[gid]._paginas[clave]) do
                        missionCommands.removeItemForGroup(gid, sub)
                    end
                    itemsYaCreados[gid]._paginas[clave] = {}

                    -- construir entradas
                    local entradas = {}
                    for aero, dat in pairs(plantillasLogisticaB) do
                        if trigger.misc.getUserFlag(dat.bandera)==1 then
                            local key = clave.."_"..aero
                            if not menuCooldownsB[key] or timer.getTime()>=menuCooldownsB[key] then
                                table.insert(entradas, { aeropuerto=aero, data=dat })
                            end
                        end
                    end

                    local porPag = 8
                    local totPag = math.ceil(#entradas/porPag)
                    for p=1,totPag do
                        local title = (totPag==1) and "Opciones" or ("Página "..p)
                        local subPag = missionCommands.addSubMenuForGroup(gid, title, menuCats[categoria])
                        table.insert(itemsYaCreados[gid]._paginas[clave], subPag)

                        for i=1,porPag do
                            local idx = (p-1)*porPag + i
                            local ent = entradas[idx]
                            if ent then
                                local aero = ent.aeropuerto
                                local dat  = ent.data
                                local baseC = tipoAviones[clave] and tipoAviones[clave].costo or 0
                                local rec   = recargoAeropuertoB[aero] or 1
                                local cost  = math.floor(baseC*rec)
                                local txt   = "Enviar a "..aero.." (Costo: "..formatearDolaresLegibleB(cost)..")"
                                missionCommands.addCommandForGroup(
                                    gid, txt, subPag,
                                    function()
                                        if DEBUG_MENU then env.info("[menu] click enviar "..aero.." con "..clave) end
                                        ejecutarEntregaB(aero, dat, clave)
                                    end
                                )
                            end
                        end
                    end
                end
            end
        end
    end
end

-- refresca cada 30s
local function scheduleMenu()
    crearMenuParaAzules()
    return timer.getTime()+30
end

-- ==============================
-- 3) HANDLER DE INICIO DE MISIÓN
-- ==============================
local function onMissionStart(event)
    if event.id == world.event.S_EVENT_MISSION_START then
        if DEBUG_LOGISTICA then env.info('[log] MISSION_START, inicio logística') end
        if DEBUG_MENU      then env.info('[menu] MISSION_START, inicio menú')      end

        -- inicia verificadores
        mist.scheduleFunction(verificarAterrizajes, {}, timer.getTime()+2, 5)
        mist.scheduleFunction(scheduleMenu,        {}, timer.getTime()+2, 30)
    end
end

world.addEventHandler({ onEvent = onMissionStart })
