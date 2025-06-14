-- CONFIGURACIÓN GENERAL
local coalicion = 2
local nombrePuntos = "PuntosAZUL"
local side = coalicion
local defaultCountry = country.id.USA

local USAR_ECONOMIA = true
local AUTO_DELETE_SECONDS = 1800
local INTERVALO_RESUMEN = 300

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

local MAX_AWACS_POR_TIPO = {
  ["E-3A"] = 1
}

local PARAMETROS_AWACS = {
  ["E-3A"] = { alt = 9150, spd = 370 }
}

local COSTOS_AWACS = {
  ["E-3A"] = 200000000
}

local HIDE_ON_MAP, HIDE_ON_PLANNER, HIDE_ON_MFD = true, true, true

local unidadAWACS = {
  ["E-3A"] = { type = "E-3A", cs = {4, 1, 0}, tac = "AWC" }
}

local function MHz(v) return v * 1e6 end
local function randFreq() return MHz(math.random(2410, 2450) / 10) end
local function randChan() return math.random(160, 170) end

puntosCoalicion = puntosCoalicion or {}
puntosCoalicion[nombrePuntos] = puntosCoalicion[nombrePuntos] or 0

local rootMenuAWACS = missionCommands.addSubMenuForCoalition(side, "AWACS")
local activeAwacsBlue = {}

local function eliminarAwacsAzul(gName)
  if Group.getByName(gName) and Group.getByName(gName):isExist() then
    Group.getByName(gName):destroy()
  end
  activeAwacsBlue[gName] = nil
end

local function tipoDisponibleAwacs(tp)
  local max = MAX_AWACS_POR_TIPO[tp] or 1
  local count = 0
  for gName, datos in pairs(activeAwacsBlue) do
    if datos and datos.tipo == tp and Group.getByName(gName) and Group.getByName(gName):isExist() then
      count = count + 1
    end
  end
  return count < max
end

local function spawnAwacsAzul(tp, p1, p2, hdg)
  if not tipoDisponibleAwacs(tp) then
    trigger.action.outTextForCoalition(side, "Ya se alcanzó el máximo de AWACS activos para " .. tp, 10)
    return
  end

  local costo = COSTOS_AWACS[tp] or 0
  if USAR_ECONOMIA and puntosCoalicion[nombrePuntos] < costo then
    trigger.action.outTextForCoalition(side, "Fondos insuficientes: se requieren " .. formatearDolaresLegible(costo), 10)
    return
  end

  local info = unidadAWACS[tp]
  local freqHz = randFreq()
  local chan = randChan()
  local gName = tp:gsub("%s", "") .. "_AWACS_" .. chan
  local alt = PARAMETROS_AWACS[tp].alt
  local spd = PARAMETROS_AWACS[tp].spd
  local tiempoExp = timer.getTime() + AUTO_DELETE_SECONDS

  local puntosRuta = {}
  for i = 1, 50, 2 do
    local wpInicio = {
      x = p1.x, y = p1.y, alt = alt, speed = spd, action = "Turning Point",
      task = {
        id = "ComboTask",
        params = {
          tasks = {
            { id = "AWACS", enabled = true }
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
            { id = "AWACS", enabled = true }
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
    task = { id = "ComboTask", params = { tasks = { { id = "AWACS", enabled = true } } } },
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

  activeAwacsBlue[gName] = {
    freq = freqHz, chan = chan, mode = "X", cs = info.tac,
    tipo = tp, tiempoExpiracion = tiempoExp
  }

  if USAR_ECONOMIA then
    puntosCoalicion[nombrePuntos] = puntosCoalicion[nombrePuntos] - costo
  end

  trigger.action.outTextForCoalition(side,
    string.format("AWACS %s desplegado %.1f MHz AM TACAN %dX", tp, freqHz / 1e6, chan), 12)

  timer.scheduleFunction(function(g)
    if Group.getByName(g) and Group.getByName(g):isExist() then
      eliminarAwacsAzul(g)
    end
  end, gName, tiempoExp)
end

-- HANDLER AZUL
local eventHandlerAwacs = {}
function eventHandlerAwacs:onEvent(e)
  if e.id ~= world.event.S_EVENT_MARK_CHANGE or not e.text or not _G.__SEL_AWACS_AZUL then return end
  local t = string.lower(e.text)
  if t == "awacsh" or t == "awacsv" then
    local hdg = (t == "awacsh") and math.rad(90) or 0
    local p1 = { x = e.pos.x, y = e.pos.z }
    local p2 = { x = p1.x + math.cos(hdg) * 1852 * 50, y = p1.y + math.sin(hdg) * 1852 * 50 }
    spawnAwacsAzul(_G.__SEL_AWACS_AZUL, p1, p2, hdg)
    _G.__SEL_AWACS_AZUL = nil
  end
end
world.addEventHandler(eventHandlerAwacs)

-- MENÚS
for name, _ in pairs(unidadAWACS) do
  local texto = name .. (USAR_ECONOMIA and (" (" .. formatearDolaresLegible(COSTOS_AWACS[name]) .. ")") or "")
  missionCommands.addCommandForCoalition(side, texto, rootMenuAWACS, function()
    _G.__SEL_AWACS_AZUL = name
    trigger.action.outTextForCoalition(side, "Seleccionado: " .. name .. ". Coloca marcador 'AwacsH' (E-W) o 'AwacsV' (N-S).", 10)
  end)
end

missionCommands.addCommandForCoalition(side, "AWACS Activos", rootMenuAWACS, function()
  local msg, now, hay = "AWACS Activos\n", timer.getTime(), false
  for g, d in pairs(activeAwacsBlue) do
    if Group.getByName(g) and Group.getByName(g):isExist() then
      local restante = math.max(0, math.floor(d.tiempoExpiracion - now))
      msg = msg .. string.format("- %s  %.1f MHz AM  TACAN %d%s  [%02d:%02d]\n", g, d.freq/1e6, d.chan, d.mode, math.floor(restante/60), restante%60)
      hay = true
    end
  end
  if not hay then msg = msg .. "(ninguno activo)" end
  trigger.action.outTextForCoalition(side, msg, 10)
end)

local function resumenAutoAwacsAzul()
  local msg, now, hay = "AWACS Activos\n", timer.getTime(), false
  for g, d in pairs(activeAwacsBlue) do
    if Group.getByName(g) and Group.getByName(g):isExist() then
      local restante = math.max(0, math.floor(d.tiempoExpiracion - now))
      msg = msg .. string.format("- %s  %.1f MHz AM  TACAN %d%s  [%02d:%02d]\n", g, d.freq/1e6, d.chan, d.mode, math.floor(restante/60), restante%60)
      hay = true
    end
  end
  if not hay then msg = msg .. "(ninguno activo)" end
  trigger.action.outTextForCoalition(side, msg, 10)
  timer.scheduleFunction(resumenAutoAwacsAzul, {}, timer.getTime() + INTERVALO_RESUMEN)
end

timer.scheduleFunction(resumenAutoAwacsAzul, {}, timer.getTime() + 5)
