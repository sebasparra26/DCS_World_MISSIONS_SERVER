-- CONFIGURACIÓN GENERAL
local coalicion = 1
local nombrePuntos = "PuntosROJO"
local side = coalicion
local defaultCountry = country.id.RUSSIA

local USAR_ECONOMIA = true
local AUTO_DELETE_SECONDS = 3600
local INTERVALO_RESUMEN = 60

local function formatearDolaresLegible(valor)
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
  ["KC-135 low"] = { alt = 5000, spd = 195 },
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

local HIDE_ON_MAP, HIDE_ON_PLANNER, HIDE_ON_MFD = true, true, true

local tankerTypes = {
  ["KC-135"] = { type = "KC-135", cs = {1, 1, 0}, tac = "RSL" },
  ["KC-135 low"] = { type = "KC-135", cs = {1, 1, 0}, tac = "LSL" },
  ["KC-135 MPRS"] = { type = "KC135MPRS", cs = {2, 1, 0}, tac = "RAR" },
  ["KC130J"] = { type = "KC130J", cs = {3, 1, 0}, tac = "REX" },
  ["S-3B Tanker"] = { type = "S-3B Tanker", cs = {3, 1, 0}, tac = "S3R" }
}

local function MHz(v) return v * 1e6 end
local function randFreq() return MHz(math.random(2610, 2690) / 10) end
local function randChan() return math.random(64, 108) end

puntosCoalicion = puntosCoalicion or {}
puntosCoalicion.PuntosROJO = puntosCoalicion.PuntosROJO or 0

local rootMenu = missionCommands.addSubMenuForCoalition(side, "Tanqueros (ROJO)")
local activeRed = {}

local function eliminarTankerRojo(gName)
  if Group.getByName(gName) and Group.getByName(gName):isExist() then
    Group.getByName(gName):destroy()
  end
  activeRed[gName] = nil
end

local function tipoDisponibleRojo(tp)
  local max = MAX_TANKERS_POR_TIPO[tp] or 1
  local count = 0
  for gName, datos in pairs(activeRed) do
    if datos and datos.tipo == tp and Group.getByName(gName) and Group.getByName(gName):isExist() then
      count = count + 1
    end
  end
  return count < max
end

local function spawnTankerRojo(tp, p1, p2, hdg)
  if not tipoDisponibleRojo(tp) then
    trigger.action.outTextForCoalition(side, "Ya se alcanzó el máximo de tanqueros activos para " .. tp, 10)
    return
  end

  local costo = COSTOS_TANKER[tp] or 0
  if USAR_ECONOMIA and puntosCoalicion[nombrePuntos] < costo then
    trigger.action.outTextForCoalition(side, "Fondos insuficientes: se requieren " .. formatearDolaresLegible(costo), 10)
    return
  end

  local info = tankerTypes[tp]
  local freqHz = randFreq()
  local chan = randChan()
  local gName = tp:gsub("%s", "") .. "_" .. chan .. "_RED"
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
    task = { id = "ComboTask", params = { tasks = { { id = "Tanker", enabled = true } } } },
    units = { {
      type = info.type, name = "U" .. math.random(1000, 9999), skill = "High",
      x = p1.x, y = p1.y, alt = alt, speed = spd, heading = hdg,
      callsign = { info.cs[1], info.cs[2], math.random(11, 99) },
      communication = true
    } },
    route = {
      points = puntosRuta
    }
  }

  coalition.addGroup(defaultCountry, groupData.category, groupData)
  local ctl = Group.getByName(gName):getController()
  ctl:setCommand({ id = "SetFrequency", params = { frequency = freqHz, modulation = 0 } })
  ctl:setCommand({
    id = "ActivateBeacon",
    params = {
      type = 4, system = 4, channel = chan, modeChannel = "X",
      callsign = info.tac, bearing = true, AA = true
    }
  })

  activeRed[gName] = {
    freq = freqHz, chan = chan, mode = "X", cs = info.tac,
    tipo = tp, tiempoExpiracion = tiempoExp
  }

  if USAR_ECONOMIA then
    puntosCoalicion[nombrePuntos] = puntosCoalicion[nombrePuntos] - costo
  end

  trigger.action.outTextForCoalition(side,
    string.format("%s desplegado %.1f MHz AM TACAN %dX", tp, freqHz / 1e6, chan), 12)

  timer.scheduleFunction(function(g)
    if Group.getByName(g) and Group.getByName(g):isExist() then
      eliminarTankerRojo(g)
    end
  end, gName, tiempoExp)
end

-- HANDLER ROJO
local eventHandlerRojo = {}
function eventHandlerRojo:onEvent(e)
  if e.id ~= world.event.S_EVENT_MARK_CHANGE or not e.text or not _G.__SEL_ROJO then return end
  local t = string.lower(e.text)
  if t == "tankerh" or t == "tankerv" then
    local hdg = (t == "tankerh") and math.rad(90) or 0
    local p1 = { x = e.pos.x, y = e.pos.z }
    local p2 = { x = p1.x + math.cos(hdg) * 1852 * 65, y = p1.y + math.sin(hdg) * 1852 * 65 }
    spawnTankerRojo(_G.__SEL_ROJO, p1, p2, hdg)
    _G.__SEL_ROJO = nil
  end
end
world.addEventHandler(eventHandlerRojo)

-- MENÚS
for name, _ in pairs(tankerTypes) do
  local texto = name .. (USAR_ECONOMIA and (" (" .. formatearDolaresLegible(COSTOS_TANKER[name]) .. ")") or "")
  missionCommands.addCommandForCoalition(side, texto, rootMenu, function()
    _G.__SEL_ROJO = name
    trigger.action.outTextForCoalition(side, "Seleccionado: " .. name .. ". Coloca marcador 'TankerH' (E-W) o 'TankerV' (N-S).", 10)
  end)
end

missionCommands.addCommandForCoalition(side, "Tanqueros Activos", rootMenu, function()
  local msg, now, hay = "Tanqueros Activos\n", timer.getTime(), false
  for g, d in pairs(activeRed) do
    if Group.getByName(g) and Group.getByName(g):isExist() then
      local restante = math.max(0, math.floor(d.tiempoExpiracion - now))
      msg = msg .. string.format("- %s  %.1f MHz AM  TACAN %d%s  [%02d:%02d]\n", g, d.freq/1e6, d.chan, d.mode, math.floor(restante/60), restante%60)
      hay = true
    end
  end
  if not hay then msg = msg .. "(ninguno activo)" end
  trigger.action.outTextForCoalition(side, msg, 10)
end)

local function resumenAutoRojo()
  local msg, now, hay = "Tanqueros Activos\n", timer.getTime(), false
  for g, d in pairs(activeRed) do
    if Group.getByName(g) and Group.getByName(g):isExist() then
      local restante = math.max(0, math.floor(d.tiempoExpiracion - now))
      msg = msg .. string.format("- %s  %.1f MHz AM  TACAN %d%s  [%02d:%02d]\n", g, d.freq/1e6, d.chan, d.mode, math.floor(restante/60), restante%60)
      hay = true
    end
  end
  if not hay then msg = msg .. "(ninguno activo)" end
  trigger.action.outTextForCoalition(side, msg, 10)
  timer.scheduleFunction(resumenAutoRojo, {}, timer.getTime() + INTERVALO_RESUMEN)
end

timer.scheduleFunction(resumenAutoRojo, {}, timer.getTime() + 5)
