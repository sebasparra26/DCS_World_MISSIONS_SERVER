-- CONFIGURACIÓN GENERAL
local coalicion = 2
local nombrePuntos = "PuntosAZUL"
local side = coalicion
local defaultCountry = country.id.USA

assert(HDEV_Economy, "Carga primero HDEV_EconomyCore.lua")

local economySettings = HDEV_EconomyGlobalConfig or {
  jsonRelativePath = "Config\\HorizontDev\\money.json",
  importWindowSeconds = 30,
  autosaveInterval = 10,
  minWriteInterval = 5,
  debug = false
}

local Economy = HDEV_Economy.init({
  jsonRelativePath = economySettings.jsonRelativePath or "Config\\HorizontDev\\money.json",
  importWindowSeconds = economySettings.importWindowSeconds or 30,
  autosaveInterval = economySettings.autosaveInterval or 10,
  minWriteInterval = economySettings.minWriteInterval or 5,
  debug = economySettings.debug and true or false
})

local USAR_ECONOMIA = false
local REEMBOLSAR_SI_FALLA_SPAWN = true
local AUTO_DELETE_SECONDS = 3600
local INTERVALO_RESUMEN = 200

local function formatearDolaresLegible(valor)
  if Economy and Economy.formatMoney then
    return Economy.formatMoney(valor)
  end

  if type(valor) ~= "number" then return "$0" end
  local entero = math.floor(valor)
  local partes = {}
  repeat
    table.insert(partes, 1, string.format("%03d", entero % 1000))
    entero = math.floor(entero / 1000)
  until entero == 0
  partes[1] = tostring(tonumber(partes[1]))
  return "$" .. table.concat(partes, ".")
end

local MAX_TANKERS_POR_TIPO = {
  ["KC-135"] = 2,
  ["KC-135 low"] = 2,
  ["KC-135 MPRS"] = 2,
  ["KC130J"] = 2,
  ["S-3B Tanker"] = 2
}

local PARAMETROS_TANKER = {
  ["KC-135"] = { alt = 7620, spd = 222 },
  ["KC-135 low"] = { alt = 4500, spd = 122 },
  ["KC-135 MPRS"] = { alt = 8230, spd = 220 },
  ["KC130J"] = { alt = 5800, spd = 380 },
  ["S-3B Tanker"] = { alt = 5200, spd = 190 }
}

local COSTOS_TANKER = {
  ["KC-135"] = 1000000,
  ["KC-135 low"] = 1000000,
  ["KC-135 MPRS"] = 1000000,
  ["KC130J"] = 800000,
  ["S-3B Tanker"] = 250000
}

local HIDE_ON_MAP, HIDE_ON_PLANNER, HIDE_ON_MFD = false, false, false

local tankerTypes = {
  ["KC-135"] = { type = "KC-135", cs = {1, 1, 0}, tac = "BSL" },
  ["KC-135 low"] = { type = "KC-135", cs = {1, 1, 0}, tac = "LSL" },
  ["KC-135 MPRS"] = { type = "KC135MPRS", cs = {2, 1, 0}, tac = "BAR" },
  ["KC130J"] = { type = "KC130J", cs = {3, 1, 0}, tac = "BEX" },
  ["S-3B Tanker"] = { type = "S-3B Tanker", cs = {3, 1, 0}, tac = "S3B" }
}

local function MHz(v) return v * 1e6 end
local function randFreq() return MHz(math.random(2510, 2590) / 10) end
local function randChan() return math.random(1, 63) end

local rootMenu = missionCommands.addSubMenuForCoalition(side, "Tanqueros")
local activeBlue = {}

local function saldoActual()
  if not Economy then
    return 0
  end
  return Economy.get(side)
end

local function eliminarTankerAzul(gName)
  local grp = Group.getByName(gName)
  if grp and grp:isExist() then
    grp:destroy()
  end
  activeBlue[gName] = nil
end

local function tipoDisponibleAzul(tp)
  local max = MAX_TANKERS_POR_TIPO[tp] or 1
  local count = 0

  for gName, datos in pairs(activeBlue) do
    local grp = Group.getByName(gName)
    if datos and datos.tipo == tp and grp and grp:isExist() then
      count = count + 1
    end
  end

  return count < max
end

local function cobrarTankerAzul(tp)
  local costo = COSTOS_TANKER[tp] or 0

  if not USAR_ECONOMIA then
    return true, saldoActual(), costo
  end

  local ok, saldo = Economy.spend(side, costo, "Despliegue tanker azul: " .. tostring(tp))
  return ok, saldo, costo
end

local function reembolsarTankerAzul(tp, costo)
  if not USAR_ECONOMIA or not REEMBOLSAR_SI_FALLA_SPAWN then
    return
  end

  Economy.add(side, costo or 0, "Reembolso tanker azul fallido: " .. tostring(tp))
end

local function construirNombreGrupoAzul(tp)
  local intento = 0

  while intento < 50 do
    local nombre = tp:gsub("%s", "") .. "_" .. tostring(randChan())
    local grp = Group.getByName(nombre)

    if not grp or not grp:isExist() then
      return nombre
    end

    intento = intento + 1
  end

  return tp:gsub("%s", "") .. "_" .. tostring(math.floor(timer.getTime()))
end

local function spawnTankerAzul(tp, p1, p2, hdg)
  if not tipoDisponibleAzul(tp) then
    trigger.action.outTextForCoalition(side, "Ya se alcanzó el máximo de tanqueros activos para " .. tp, 10)
    return
  end

  local okCobro, saldoDespues, costo = cobrarTankerAzul(tp)
  if not okCobro then
    trigger.action.outTextForCoalition(
      side,
      "Fondos insuficientes para " .. tp ..
      ". Costo: " .. formatearDolaresLegible(costo) ..
      " | Saldo actual: " .. formatearDolaresLegible(saldoActual()),
      10
    )
    return
  end

  local info = tankerTypes[tp]
  local freqHz = randFreq()
  local chan = randChan()
  local gName = construirNombreGrupoAzul(tp)
  local alt = PARAMETROS_TANKER[tp].alt
  local spd = PARAMETROS_TANKER[tp].spd
  local tiempoExp = timer.getTime() + AUTO_DELETE_SECONDS

  local puntosRuta = {}
  for i = 1, 50, 2 do
    local wpInicio = {
      x = p1.x, y = p1.y, alt = alt, speed = spd, action = "Turning Point",
      task = {
        id = "ComboTask",
        params = {
          tasks = {
            { id = "Tanker", enabled = true }
          }
        }
      }
    }

    local wpFinal = {
      x = p2.x, y = p2.y, alt = alt, speed = spd, action = "Turning Point",
      task = {
        id = "ComboTask",
        params = {
          tasks = {
            {
              id = "WrappedAction",
              params = {
                action = {
                  id = "SwitchWaypoint",
                  params = { fromWaypointIndex = i + 1, goToWaypointIndex = i }
                }
              }
            },
            { id = "Tanker", enabled = true }
          }
        }
      }
    }

    table.insert(puntosRuta, wpInicio)
    table.insert(puntosRuta, wpFinal)
  end

  local groupData = {
    category = Group.Category.AIRPLANE,
    country = defaultCountry,
    name = gName,
    hidden = HIDE_ON_MAP,
    hiddenOnPlanner = HIDE_ON_PLANNER,
    hiddenOnMFD = HIDE_ON_MFD,
    groupControl = "gameMaster",
    task = { id = "ComboTask", params = { tasks = { { id = "Tanker", enabled = true } } } },
    units = { {
      type = info.type,
      name = "U" .. math.random(1000, 9999),
      skill = "High",
      x = p1.x,
      y = p1.y,
      alt = alt,
      speed = spd,
      heading = hdg,
      callsign = { info.cs[1], info.cs[2], math.random(11, 99) },
      communication = true
    } },
    route = {
      points = puntosRuta
    }
  }

  local okSpawn, errSpawn = pcall(function()
    coalition.addGroup(defaultCountry, groupData.category, groupData)
  end)

  local grp = Group.getByName(gName)
  if not okSpawn or not grp or not grp:isExist() then
    reembolsarTankerAzul(tp, costo)
    env.info("[TANKER BLUE] Error al crear tanker " .. tostring(tp) .. ": " .. tostring(errSpawn))
    trigger.action.outTextForCoalition(side, "No se pudo desplegar " .. tp .. ". Se revirtió el cobro.", 10)
    return
  end

  local ctl = grp:getController()
  if ctl then
    ctl:setCommand({ id = "SetFrequency", params = { frequency = freqHz, modulation = 0 } })
    ctl:setCommand({
      id = "ActivateBeacon",
      params = {
        type = 4,
        system = 4,
        channel = chan,
        modeChannel = "X",
        callsign = info.tac,
        bearing = true,
        AA = true
      }
    })
    ctl:setOption(8, true)
  end

  activeBlue[gName] = {
    freq = freqHz,
    chan = chan,
    mode = "X",
    cs = info.tac,
    tipo = tp,
    tiempoExpiracion = tiempoExp,
    costo = costo
  }

  local msg = string.format("%s desplegado %.1f MHz AM TACAN %dX", tp, freqHz / 1e6, chan)
  if USAR_ECONOMIA then
    msg = msg ..
      "\nCosto: " .. formatearDolaresLegible(costo) ..
      " | Saldo: " .. formatearDolaresLegible(saldoDespues)
  end

  trigger.action.outTextForCoalition(side, msg, 12)

  timer.scheduleFunction(function(g)
    local grupo = Group.getByName(g)
    if grupo and grupo:isExist() then
      eliminarTankerAzul(g)
    end
  end, gName, tiempoExp)
end

-- HANDLER AZUL
local eventHandlerAzul = {}
function eventHandlerAzul:onEvent(e)
  if e.id ~= world.event.S_EVENT_MARK_CHANGE or not e.text or not _G.__SEL_AZUL then
    return
  end

  local t = string.lower(e.text)
  if t == "tankerh" or t == "tankerv" then
    local hdg = (t == "tankerh") and math.rad(90) or 0
    local p1 = { x = e.pos.x, y = e.pos.z }
    local p2 = { x = p1.x + math.cos(hdg) * 1852 * 80, y = p1.y + math.sin(hdg) * 1852 * 80 }
    spawnTankerAzul(_G.__SEL_AZUL, p1, p2, hdg)
    _G.__SEL_AZUL = nil
  end
end
world.addEventHandler(eventHandlerAzul)

-- MENÚS
for name, _ in pairs(tankerTypes) do
  local texto = name .. (USAR_ECONOMIA and (" (" .. formatearDolaresLegible(COSTOS_TANKER[name]) .. ")") or "")
  missionCommands.addCommandForCoalition(side, texto, rootMenu, function()
    _G.__SEL_AZUL = name
    trigger.action.outTextForCoalition(side, "Seleccionado: " .. name .. ". Coloca marcador 'TankerH' (E-W) o 'TankerV' (N-S).", 10)
  end)
end

missionCommands.addCommandForCoalition(side, "Tanqueros Activos", rootMenu, function()
  local msg, now, hay = "Tanqueros Activos\n", timer.getTime(), false

  for g, d in pairs(activeBlue) do
    local grp = Group.getByName(g)
    if grp and grp:isExist() then
      local restante = math.max(0, math.floor(d.tiempoExpiracion - now))
      msg = msg .. string.format(
        "- %s  %.1f MHz AM  TACAN %d%s  [%02d:%02d]\n",
        g, d.freq / 1e6, d.chan, d.mode, math.floor(restante / 60), restante % 60
      )
      hay = true
    end
  end

  if not hay then
    msg = msg .. "(ninguno activo)"
  end

  if USAR_ECONOMIA then
    msg = msg .. "\nSaldo Azul: " .. formatearDolaresLegible(saldoActual())
  end

  trigger.action.outTextForCoalition(side, msg, 10)
end)

local function resumenAutoAzul()
  local msg, now, hay = "Tanqueros Activos\n", timer.getTime(), false

  for g, d in pairs(activeBlue) do
    local grp = Group.getByName(g)
    if grp and grp:isExist() then
      local restante = math.max(0, math.floor(d.tiempoExpiracion - now))
      msg = msg .. string.format(
        "- %s  %.1f MHz AM  TACAN %d%s  [%02d:%02d]\n",
        g, d.freq / 1e6, d.chan, d.mode, math.floor(restante / 60), restante % 60
      )
      hay = true
    end
  end

  if not hay then
    msg = msg .. "(ninguno activo)"
  end

  trigger.action.outTextForCoalition(side, msg, 10)
  timer.scheduleFunction(resumenAutoAzul, {}, timer.getTime() + INTERVALO_RESUMEN)
end

timer.scheduleFunction(resumenAutoAzul, {}, timer.getTime() + 5)