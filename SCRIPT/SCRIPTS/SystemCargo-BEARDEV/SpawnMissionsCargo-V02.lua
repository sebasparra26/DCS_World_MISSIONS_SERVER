--=============================================================
-- C-130 Cargo Missions (MIST)
--
-- Random por AEROPUERTO (pickup y drop nunca son el mismo aeropuerto)
-- Tipo de carga random con label
-- Cantidad por tipo de carga
-- Entrega: solo cuenta si AGL <= umbral dentro de zona DROP
-- Autodestruccion de cajas entregadas
-- Limite de misiones simultaneas
-- Zona MONITOREO: si una caja no entregada desaparece despues de haber estado en MONITOREO => FALLA
--
-- Señalizacion:
-- - Humo por fases:
--   * Inicio: solo humo en PICKUP
--   * Cuando ya no queda ninguna caja en la zona PICKUP (recogidas): humo cambia a DROP
-- - Marks F10: removibles instantaneo al finalizar mision
--
-- Orden recomendado:
-- 1) MIST
-- 2) PersianGolf DB Aiports.lua (opcional)
-- 3) Este script
--=============================================================

local CFG = {
  debug = true,
  menuRootName = "C-130J Carga",


  

  -- Limite de misiones simultaneas
  maxActiveMissions = 2,

  -- Pulsos de banderas
  flagPulseStart = 5000,
  flagPulseComplete = 5002,
  flagPulseDuration = 1,

  -- Entrega: AGL y autodestruccion
  maxAGLForCount = 0.8,              -- metros
  destroyAfterDeliveredSeconds = 10,  -- segundos

  -- Monitoreo de perdida de carga
  monitorZoneName = "MONITOREO",
  failOnLostCargo = true,           -- si una caja desaparece despues de estar en MONITOREO -> FAIL
  cleanupCargoOnFail = true,        -- limpiar cajas si falla

  -- Marks F10
  marksEnabled = true,

  -- Humo (por fases)
  smokeEnabled = true,
  smokeInterval = 120,              -- refresco de humo mientras corresponda
  smokeColorPickup = "ORANGE",
  smokeColorDrop   = "ORANGE",


  --===========================================================
  -- TIPOS DE CARGA
  --===========================================================
  cargoTypes = {
    --{ label = "Carga Pesada",    template = "CARGO_TEMPLATE_01", qty = { mode = "fixed", value = 1 } },
    { label = "Carga Liviana (CDS BARRILES)",    template = "CARGO_TEMPLATE_01", qty = { mode = "random", min = 1, max = 10 }  },
    { label = "Carga Liviana (CDS CAJAS)",  template = "CARGO_TEMPLATE_02", qty = { mode = "random", min = 1, max = 5 } },
    { label = "Carga Pesada (CONTENEDOR LIVIANO)",    template = "CARGO_TEMPLATE_04", qty = { mode = "random", min = 1, max = 3 }  },
    { label = "Carga Pesada (CONTENEDOR PESADO)",    template = "CARGO_TEMPLATE_04", qty = { mode = "fixed", value = 1 } },
    -- { label = "Suministros",  template = "CARGO_TEMPLATE_03", qty = { mode = "random", min = 4, max = 10 } },
  },

  -- Spawn
  cargoMinSep = 8,
  cargoMaxIntentosPunto = 60,
  cargoMaxIntentosSpawn = 400,

  -- Verificacion
  verifyInterval = 5,
}

CFG.zonas = CARGO_ZONES or {}

if not CFG.zonas or #CFG.zonas == 0 then
  env.error("[C130-CARGO] ERROR: CARGO_ZONES no está definido o está vacío.")
end

--=============================================================
-- CARGA DE TIPOS DE CARGA DESDE SCRIPT EXTERNO
--=============================================================
CFG.cargoTypes = CARGO_TYPES or {}

if not CFG.cargoTypes or #CFG.cargoTypes == 0 then
  env.error("[C130-CARGO] ERROR: CARGO_TYPES no está definido o está vacío.")
end
--=============================================================
-- Mensajes / Logs
--=============================================================
local function say(txt, dur)
  trigger.action.outText("[C130-CARGO] " .. tostring(txt), dur or 8)
end

local function info(msg)
  if CFG.debug then env.info("[C130-CARGO] " .. tostring(msg)) end
end

local function err(msg)
  env.info("[C130-CARGO][ERROR] " .. tostring(msg))
end

--=============================================================
-- Flags (pulsos)
--=============================================================
local function setFlag(flagId, value)
  if not flagId then return end
  trigger.action.setUserFlag(flagId, value and 1 or 0)
end

local function pulseFlag(flagOn, duration)
  if not flagOn then return end
  local dur = duration or 1
  setFlag(flagOn, true)
  timer.scheduleFunction(function()
    setFlag(flagOn, false)
    return nil
  end, {}, timer.getTime() + dur)
end

--=============================================================
-- Utils
--=============================================================
local function dist2D(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  return math.sqrt(dx*dx + dy*dy)
end

local function randPointInCircle(center, radius)
  if mist and mist.getRandPointInCircle then
    return mist.getRandPointInCircle(center, radius)
  end
  local ang = math.random() * 2 * math.pi
  local rad = radius * math.sqrt(math.random())
  return { x = center.x + rad * math.cos(ang), y = center.y + rad * math.sin(ang) }
end

local function getPuntoLibreEnZona(zone, usados, minSep, maxIntentos)
  for _=1, maxIntentos do
    local p = randPointInCircle(zone.point, zone.radius)
    local ok = true
    for _, u in ipairs(usados) do
      if dist2D(p, u) < minSep then ok = false; break end
    end
    if ok then return p end
  end
  return nil
end

--=============================================================
-- AGL
--=============================================================
local function getAGL(point)
  if not point then return 999999 end
  local ground = land.getHeight({ x = point.x, y = point.z }) or 0
  return point.y - ground
end

local function isOnGroundByAGL(point)
  return getAGL(point) <= (CFG.maxAGLForCount or 1.0)
end

--=============================================================
-- Zonas ME
--=============================================================
local function getZonaME(name)
  return trigger.misc.getZone(name)
end

local function isPointInZone2D(point, zone)
  if not point or not zone or not zone.point or not zone.radius then return false end
  local d = dist2D({x=point.x, y=point.z}, {x=zone.point.x, y=zone.point.z})
  return d <= zone.radius
end

--=============================================================
-- Humo
--=============================================================
local SMOKE_COLOR = {
  GREEN  = trigger.smokeColor.Green,
  RED    = trigger.smokeColor.Red,
  WHITE  = trigger.smokeColor.White,
  ORANGE = trigger.smokeColor.Orange,
  BLUE   = trigger.smokeColor.Blue,
}

local function getSmokeColorEnum(name)
  if not name then return trigger.smokeColor.Orange end
  local key = tostring(name):upper()
  return SMOKE_COLOR[key] or trigger.smokeColor.Orange
end

local function smokeZoneCenter(zoneName, colorName)
  local z = getZonaME(zoneName)
  if not z or not z.point then return end

  -- FIX: en DCS muchas zonas vienen con y=0; lo ponemos en la altura real del terreno
  local ground = land.getHeight({ x = z.point.x, y = z.point.z }) or 0
  local p = { x = z.point.x, y = ground + 1.0, z = z.point.z } -- +1m para que siempre se vea

  trigger.action.smoke(p, getSmokeColorEnum(colorName))
end

--=============================================================
-- Marks F10
--=============================================================
local function addMissionMarks(mission)
  if not CFG.marksEnabled then return end

  local zp = getZonaME(mission.pickupZone)
  local zd = getZonaME(mission.dropZone)
  if not zp or not zd then return end

  mission.markIds = mission.markIds or {}

  local idPick = 900000 + (mission.id * 10) + 1
  local idDrop = 900000 + (mission.id * 10) + 2

  local txtPick =
    "MISION " .. tostring(mission.id) .. "\n" ..
    "PICKUP: " .. tostring(mission.pickupAirbase) .. "\n" ..
    "CARGA: " .. tostring(mission.cargoLabel) .. "\n" ..
    "CAJAS: " .. tostring(mission.required)

  local txtDrop =
    "MISION " .. tostring(mission.id) .. "\n" ..
    "DROP: " .. tostring(mission.dropAirbase) .. "\n" ..
    "CARGA: " .. tostring(mission.cargoLabel) .. "\n" ..
    "CAJAS: " .. tostring(mission.required)

  trigger.action.markToAll(idPick, txtPick, zp.point, true)
  trigger.action.markToAll(idDrop, txtDrop, zd.point, true)

  mission.markIds.pick = idPick
  mission.markIds.drop = idDrop
end

local function removeMissionMarks(mission)
  if not mission or not mission.markIds then return end
  if mission.markIds.pick then trigger.action.removeMark(mission.markIds.pick) end
  if mission.markIds.drop then trigger.action.removeMark(mission.markIds.drop) end
  mission.markIds = nil
end

--=============================================================
-- Deduccion de aeropuertos (opcional con DB)
-- aeropuertos[Nombre].position = {x=, z=}
--=============================================================
local function deducirAeropuertoPorCercania(zonePoint)
  if type(aeropuertos) ~= "table" then return nil end
  local bestName, bestD = nil, 1e18
  for apName, apData in pairs(aeropuertos) do
    if apData and apData.position then
      local p = { x = apData.position.x, y = apData.position.z }
      local d = dist2D({x=zonePoint.x,y=zonePoint.z}, p)
      if d < bestD then bestD = d; bestName = apName end
    end
  end
  return bestName
end

--=============================================================
-- Index por aeropuerto
--=============================================================
local airportIndex = {}

local function buildAirportIndex()
  airportIndex = {}
  for _,z in ipairs(CFG.zonas or {}) do
    local zname = z.name
    local tipo = z.tipo

    if tipo ~= "pickup" and tipo ~= "drop" then
      err("Zona con tipo invalido: "..tostring(zname).." tipo="..tostring(tipo))
    else
      local air = z.aeropuerto
      if (not air or air == "") then
        local zME = getZonaME(zname)
        if zME then air = deducirAeropuertoPorCercania(zME.point) end
      end

      if air and air ~= "" then
        airportIndex[air] = airportIndex[air] or { pickupZones = {}, dropZones = {} }
        if tipo == "pickup" then
          table.insert(airportIndex[air].pickupZones, zname)
        else
          table.insert(airportIndex[air].dropZones, zname)
        end
      else
        err("No se pudo asignar aeropuerto a zona: "..tostring(zname))
      end
    end
  end
end

local function pickRandomAirportWithPickup()
  local candidates = {}
  for air,data in pairs(airportIndex) do
    if data.pickupZones and #data.pickupZones > 0 then
      table.insert(candidates, air)
    end
  end
  if #candidates == 0 then return nil end
  return candidates[math.random(1, #candidates)]
end

local function pickRandomAirportWithDrop(excludeAirport)
  local candidates = {}
  for air,data in pairs(airportIndex) do
    if air ~= excludeAirport and data.dropZones and #data.dropZones > 0 then
      table.insert(candidates, air)
    end
  end
  if #candidates == 0 then return nil end
  return candidates[math.random(1, #candidates)]
end

local function pickRandomPickupDropByAirport()
  local pickupAir = pickRandomAirportWithPickup()
  if not pickupAir then return nil end

  local dropAir = pickRandomAirportWithDrop(pickupAir)
  if not dropAir then return nil end

  local pList = airportIndex[pickupAir].pickupZones
  local dList = airportIndex[dropAir].dropZones
  if not pList or #pList == 0 then return nil end
  if not dList or #dList == 0 then return nil end

  local pickupZone = pList[math.random(1, #pList)]
  local dropZone   = dList[math.random(1, #dList)]

  return pickupAir, pickupZone, dropAir, dropZone
end

--=============================================================
-- Tipos de carga
--=============================================================
local function pickRandomCargoType()
  if not CFG.cargoTypes or #CFG.cargoTypes == 0 then return nil end
  return CFG.cargoTypes[math.random(1, #CFG.cargoTypes)]
end

local function getQuantityForCargoType(cargoType)
  if not cargoType or not cargoType.qty then return 1 end
  local q = cargoType.qty
  if q.mode == "fixed" then
    return tonumber(q.value) or 1
  end
  if q.mode == "random" then
    local mn = tonumber(q.min) or 1
    local mx = tonumber(q.max) or mn
    if mx < mn then mx = mn end
    return math.random(mn, mx)
  end
  return 1
end

--=============================================================
-- Templates statics -> spawn clones
--=============================================================
local function deepCopy(t)
  if mist and mist.utils and mist.utils.deepCopy then
    return mist.utils.deepCopy(t)
  end
  local out = {}
  for k,v in pairs(t or {}) do out[k] = v end
  return out
end

local function getStaticTemplateData(staticName)
  if mist and mist.DBs and mist.DBs.staticsByName and mist.DBs.staticsByName[staticName] then
    return deepCopy(mist.DBs.staticsByName[staticName])
  end

  local so = StaticObject.getByName(staticName)
  if so then
    local desc  = so:getDesc() or {}
    return {
      type       = so:getTypeName(),
      country    = so:getCountry() or country.USA,
      category   = "Cargo",
      canCargo   = true,
      shape_name = desc.shape_name,
      mass       = desc.mass,
      rate       = desc.rate,
      dead       = false,
      heading    = 0
    }
  end

  return nil
end

local function buildStaticFromTemplate(tpl, point, newName)
  return {
    name       = newName,
    type       = tpl.type,
    x          = point.x,
    y          = point.y,
    heading    = math.random() * 2 * math.pi,
    category   = "Cargo",
    canCargo   = true,
    shape_name = tpl.shape_name,
    mass       = tpl.mass,
    rate       = tpl.rate,
    dead       = tpl.dead,
  }
end

local function nombreUnico(base, missionId, idx)
  return string.format("%s_M%03d_%03d_%d", base, missionId or 0, idx or 0, timer.getTime())
end

local function spawnCargoEnZona(missionId, zoneName, cantidad, templateName)
  local zone = getZonaME(zoneName)
  if not zone then err("Zona no encontrada: "..tostring(zoneName)); return {} end
  if not templateName then err("spawnCargoEnZona: templateName nil."); return {} end

  local tpl = getStaticTemplateData(templateName)
  if not tpl then
    err("Template static no encontrado: "..tostring(templateName))
    say("ERROR: Falta template de carga: "..tostring(templateName), 12)
    return {}
  end

  local usados = {}
  local spawned = {}
  local spawnCount = 0
  local intentosGlobal = 0

  while spawnCount < cantidad and intentosGlobal < CFG.cargoMaxIntentosSpawn do
    intentosGlobal = intentosGlobal + 1
    local p = getPuntoLibreEnZona(zone, usados, CFG.cargoMinSep, CFG.cargoMaxIntentosPunto)
    if p then
      local newName = nombreUnico("CARGO", missionId, spawnCount + 1)
      local objTbl = buildStaticFromTemplate(tpl, p, newName)
      local ctryId = (tpl.country and type(tpl.country)=="number") and tpl.country or country.USA

      local ok = coalition.addStaticObject(ctryId, objTbl)
      if ok then
        table.insert(usados, {x=p.x,y=p.y})
        table.insert(spawned, newName)
        spawnCount = spawnCount + 1
      end
    end
  end

  info(string.format("Spawn cargo en %s: %d/%d | template=%s", zoneName, #spawned, cantidad, tostring(templateName)))
  return spawned
end

--=============================================================
-- Estado global de misiones
--=============================================================
local STATE = {
  missions = {},
  nextId = 1,
}

local function countActiveMissions()
  local n = 0
  for _,_ in pairs(STATE.missions) do n = n + 1 end
  return n
end

local function destroyCargoList(cargoNames)
  for _,name in ipairs(cargoNames or {}) do
    local so = StaticObject.getByName(name)
    if so and so:isExist() then
      so:destroy()
    end
  end
end

local function scheduleDestroyStaticByName(staticName, delaySeconds)
  timer.scheduleFunction(function()
    local so = StaticObject.getByName(staticName)
    if so and so:isExist() then
      so:destroy()
    end
    return nil
  end, {}, timer.getTime() + (delaySeconds or 10))
end

local function endMissionCleanup(M)
  if not M then return end
  removeMissionMarks(M)
  -- Humo no se puede apagar; al finalizar ya no se refresca porque la mision deja de ser verificada
end

local function failMission(missionId, reason)
  local M = STATE.missions[missionId]
  if not M then return end

  say(
    "MISION FALLIDA\n"..
    "ID: "..tostring(M.id).."\n"..
    "Motivo: "..tostring(reason or "Perdida de carga").."\n"..
    "Carga: "..tostring(M.cargoLabel).."\n"..
    "Recoger: "..tostring(M.pickupAirbase).." ("..tostring(M.pickupZone)..")\n"..
    "Entregar: "..tostring(M.dropAirbase).." ("..tostring(M.dropZone)..")",
    12
  )

  if CFG.cleanupCargoOnFail then
    destroyCargoList(M.cargoNames)
  end

  endMissionCleanup(M)
  STATE.missions[missionId] = nil
end

--=============================================================
-- Conteos para cambio de fase del humo (pickup -> drop)
--=============================================================
local function countCargoExistingInZone(mission, zoneName)
  local z = getZonaME(zoneName)
  if not z then return 0 end

  local n = 0
  for _,name in ipairs(mission.cargoNames or {}) do
    if not (mission.deliveredSet and mission.deliveredSet[name]) then
      local so = StaticObject.getByName(name)
      if so and so:isExist() then
        local p = so:getPoint()
        if isPointInZone2D(p, z) then
          n = n + 1
        end
      end
    end
  end
  return n
end

local function updateSmokeStageIfNeeded(mission)
  if not CFG.smokeEnabled then return end
  if mission.smokeStage ~= "pickup" then return end

  local remainingAtPickup = countCargoExistingInZone(mission, mission.pickupZone)

  -- Cambio de fase: cuando ya no queda ninguna caja en la zona pickup
  if remainingAtPickup <= 0 then
    mission.smokeStage = "drop"
    mission.nextSmokeTime = 0
    say(
      "MISION " .. tostring(mission.id) .. " - CARGA RECOGIDA\n" ..
      "Ahora sigue el humo en DROP: " .. tostring(CFG.smokeColorDrop) .. "\n" ..
      "Destino: " .. tostring(mission.dropAirbase) .. " (" .. tostring(mission.dropZone) .. ")",
      10
    )
  end
end

local function maybeSmokeMission(mission)
  if not CFG.smokeEnabled then return end
  local now = timer.getTime()
  mission.nextSmokeTime = mission.nextSmokeTime or 0
  if now < mission.nextSmokeTime then return end

  if mission.smokeStage == "pickup" then
    smokeZoneCenter(mission.pickupZone, CFG.smokeColorPickup)
  else
    smokeZoneCenter(mission.dropZone, CFG.smokeColorDrop)
  end

  mission.nextSmokeTime = now + (CFG.smokeInterval or 120)
end

--=============================================================
-- Proceso mision: entrega + monitoreo de perdida
--=============================================================
local function processMissionCargo(mission)
  if not mission then return 0 end

  local dropZ = getZonaME(mission.dropZone)
  if not dropZ then return 0 end

  local monZ = mission.monitorZone
  mission.deliveredSet = mission.deliveredSet or {}
  mission.destroyScheduled = mission.destroyScheduled or {}
  mission.cargoEverInMonitor = mission.cargoEverInMonitor or {}

  for _,name in ipairs(mission.cargoNames or {}) do
    if not mission.deliveredSet[name] then
      local so = StaticObject.getByName(name)

      if so and so:isExist() then
        local p = so:getPoint()

        -- registrar paso por MONITOREO
        if monZ and isPointInZone2D(p, monZ) then
          mission.cargoEverInMonitor[name] = true
        end

        -- entrega: dentro DROP + AGL <= umbral
        if isPointInZone2D(p, dropZ) then
          if isOnGroundByAGL(p) then
            mission.deliveredSet[name] = true
            if not mission.destroyScheduled[name] then
              mission.destroyScheduled[name] = true
              scheduleDestroyStaticByName(name, CFG.destroyAfterDeliveredSeconds)
            end
          end
        end

      else
        -- caja desaparecio
        if CFG.failOnLostCargo and mission.cargoEverInMonitor[name] then
          return -1
        end
      end
    end
  end

  local deliveredCount = 0
  for _,_ in pairs(mission.deliveredSet or {}) do deliveredCount = deliveredCount + 1 end
  return deliveredCount
end

--=============================================================
-- Loop por mision
--=============================================================
local function verifyMissionLoop(missionId)
  local M = STATE.missions[missionId]
  if not M then return nil end

  -- Cambio de fase humo segun recogida
  updateSmokeStageIfNeeded(M)

  -- Humo (segun fase)
  maybeSmokeMission(M)

  local delivered = processMissionCargo(M)

  if delivered == -1 then
    failMission(missionId, "Carga perdida dentro de zona MONITOREO")
    return nil
  end

  if delivered >= M.required then
    say(
      "MISION COMPLETADA\n"..
      "ID: "..tostring(M.id).."\n"..
      "Entregaste "..tostring(delivered).."/"..tostring(M.required).." cajas\n"..
      "Carga: "..tostring(M.cargoLabel).."\n"..
      "Recoger: "..tostring(M.pickupAirbase).." ("..tostring(M.pickupZone)..")\n"..
      "Entregar: "..tostring(M.dropAirbase).." ("..tostring(M.dropZone)..")",
      12
    )

    pulseFlag(CFG.flagPulseComplete, CFG.flagPulseDuration)

    endMissionCleanup(M)
    STATE.missions[missionId] = nil
    return nil
  end

  return timer.getTime() + CFG.verifyInterval
end

--=============================================================
-- Crear mision aleatoria
--=============================================================
local function startRandomMission()
  if countActiveMissions() >= (CFG.maxActiveMissions or 1) then
    say("No se puede crear mision. Limite de misiones activas: "..tostring(CFG.maxActiveMissions), 10)
    return
  end

  local pickupAir, pickupZone, dropAir, dropZone = pickRandomPickupDropByAirport()
  if not pickupAir or not pickupZone or not dropAir or not dropZone then
    say("ERROR: No se pudo crear mision random por aeropuerto. Revisa CFG.zonas.", 10)
    return
  end

  if not getZonaME(pickupZone) then say("ERROR: No existe pickupZone "..tostring(pickupZone), 10); return end
  if not getZonaME(dropZone) then say("ERROR: No existe dropZone "..tostring(dropZone), 10); return end

  local cargoType = pickRandomCargoType()
  if not cargoType or not cargoType.template then
    say("ERROR: No hay cargoTypes validos en CFG.cargoTypes.", 10)
    return
  end

  local required = getQuantityForCargoType(cargoType)
  if required < 1 then required = 1 end

  local cargoTemplateName = cargoType.template
  local cargoLabel = cargoType.label or cargoTemplateName

  local missionId = STATE.nextId
  STATE.nextId = STATE.nextId + 1

  local cargoNames = spawnCargoEnZona(missionId, pickupZone, required, cargoTemplateName)
  if #cargoNames == 0 then
    say("No se pudo spawnear carga. Revisa templates/zona.", 10)
    return
  end

  local monZ = getZonaME(CFG.monitorZoneName)

  local M = {
    id = missionId,

    pickupZone = pickupZone,
    dropZone = dropZone,

    pickupAirbase = pickupAir,
    dropAirbase = dropAir,

    required = required,

    cargoTemplateName = cargoTemplateName,
    cargoLabel = cargoLabel,

    cargoNames = cargoNames,
    deliveredSet = {},
    destroyScheduled = {},

    monitorZone = monZ,
    cargoEverInMonitor = {},

    smokeStage = "pickup",
    nextSmokeTime = 0,

    markIds = nil,
  }

  STATE.missions[missionId] = M

  pulseFlag(CFG.flagPulseStart, CFG.flagPulseDuration)

  addMissionMarks(M)

  say(
    "MISION DE CARGA INICIADA\n"..
    "ID: "..tostring(M.id).."\n"..
    "Carga: "..tostring(M.cargoLabel).."\n"..
    "Cajas requeridas: "..tostring(M.required).."\n"..
    "Recoger: "..tostring(M.pickupAirbase).." ("..tostring(M.pickupZone)..")\n"..
    "Entregar: "..tostring(M.dropAirbase).." ("..tostring(M.dropZone)..")\n"..
    "Humo:\n"..
    --" - Mientras no recojas la carga: sigue el humo en PICKUP ("..tostring(CFG.smokeColorPickup)..")\n"..
    --" - Cuando ya no queden cajas en PICKUP: el humo cambia a DROP ("..tostring(CFG.smokeColorDrop)..")\n"..
    "Regla entrega: solo cuenta si caja queda en el suelo (AGL <= "..tostring(CFG.maxAGLForCount)..") dentro de DROP.\n"..
    "Regla perdida: si una caja desaparece despues de estar en "..tostring(CFG.monitorZoneName).." => MISION FALLA.",
    20
  )

  -- humo inicial inmediato (pickup)
  maybeSmokeMission(M)

  timer.scheduleFunction(function()
    return verifyMissionLoop(missionId)
  end, {}, timer.getTime() + CFG.verifyInterval)
end

--=============================================================
-- Estado / Cancelar
--=============================================================
local function missionStatus()
  local active = countActiveMissions()
  if active == 0 then
    say("No hay misiones activas.", 6)
    return
  end

  local lines = {}
  lines[#lines+1] = "MISIONES ACTIVAS: "..tostring(active).."/"..tostring(CFG.maxActiveMissions)

  local ids = {}
  for id,_ in pairs(STATE.missions) do table.insert(ids, id) end
  table.sort(ids)

  for _,id in ipairs(ids) do
    local M = STATE.missions[id]
    local delivered = processMissionCargo(M)
    if delivered == -1 then delivered = 0 end

    lines[#lines+1] =
      "ID "..tostring(M.id)..
      " | "..tostring(delivered).."/"..tostring(M.required)..
      " | "..tostring(M.cargoLabel)..
      " | FASE_HUMO="..tostring(M.smokeStage)

    lines[#lines+1] =
      "  Recoger: "..tostring(M.pickupAirbase).." ("..tostring(M.pickupZone)..")"

    lines[#lines+1] =
      "  Entregar: "..tostring(M.dropAirbase).." ("..tostring(M.dropZone)..")"
  end

  say(table.concat(lines, "\n"), 16)
end

local function cancelAllMissions()
  local active = countActiveMissions()
  if active == 0 then
    say("No hay misiones activas.", 6)
    return
  end

  for _,M in pairs(STATE.missions) do
    if CFG.cleanupCargoOnFail then
      destroyCargoList(M.cargoNames)
    end
    endMissionCleanup(M)
  end

  STATE.missions = {}
  say("Todas las misiones fueron canceladas.", 8)
end

--=============================================================
-- Menu F10
--=============================================================
local MENU = { root=nil }

local function buildMenu()
  MENU.root = missionCommands.addSubMenu(CFG.menuRootName)
  missionCommands.addCommand("Crear mision aleatoria", MENU.root, startRandomMission)
  missionCommands.addCommand("Estado de misiones", MENU.root, missionStatus)
  missionCommands.addCommand("Cancelar todas las misiones", MENU.root, cancelAllMissions)
end

--=============================================================
-- Diagnostico
--=============================================================
local function templateExists(templateName)
  local ex = (StaticObject.getByName(templateName) ~= nil)
  if ex then return true end
  if mist and mist.DBs and mist.DBs.staticsByName and mist.DBs.staticsByName[templateName] then
    return true
  end
  return false
end

local function diagnostico()
  local lines = {}
  lines[#lines+1] = "Diagnostico:"
  lines[#lines+1] = "- MIST: "..tostring(mist ~= nil)
  lines[#lines+1] = "- maxActiveMissions: "..tostring(CFG.maxActiveMissions)
  lines[#lines+1] = "- AGL para contar: "..tostring(CFG.maxAGLForCount)
  lines[#lines+1] = "- Destruir despues: "..tostring(CFG.destroyAfterDeliveredSeconds).."s"
  lines[#lines+1] = "- MONITOREO: "..tostring(CFG.monitorZoneName).." existe="..tostring(getZonaME(CFG.monitorZoneName) ~= nil)
  lines[#lines+1] = "- Humo: "..tostring(CFG.smokeEnabled).." interval="..tostring(CFG.smokeInterval).." pickup="..tostring(CFG.smokeColorPickup).." drop="..tostring(CFG.smokeColorDrop)
  lines[#lines+1] = "- Marks: "..tostring(CFG.marksEnabled)

  buildAirportIndex()

  lines[#lines+1] = "- cargoTypes: "..tostring((CFG.cargoTypes and #CFG.cargoTypes) or 0)
  if CFG.cargoTypes and #CFG.cargoTypes > 0 then
    for i,ct in ipairs(CFG.cargoTypes) do
      local tname = ct.template
      local label = ct.label or tname
      local ex = templateExists(tname)
      lines[#lines+1] = string.format("  %d) %s | template=%s | existe=%s", i, tostring(label), tostring(tname), tostring(ex))
    end
  end

  say(table.concat(lines, "\n"), 16)
  info(table.concat(lines, " | "))
end

--=============================================================
-- Start
--=============================================================
timer.scheduleFunction(function()
  buildAirportIndex()
  diagnostico()
  buildMenu()
end, {}, timer.getTime() + 2)
