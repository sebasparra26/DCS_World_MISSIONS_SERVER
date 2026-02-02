--=============================================================
-- CARGO BEAR - CORE (MIST)
-- Sistema de misiones de carga para multiples aeronaves
--
-- Menú:
--   CARGO BEAR
--     C130-J-30
--     CHINOOK
--     MI-8
--     OTROS
--       HUEY
--       MI-24
--       GAZELLE
--
-- Filtrado de pedidos por aeronave:
-- En CARGO_TYPES cada entrada puede tener:
--   aircraft = { "C130", "CHINOOK", "MI8", "HUEY", "MI24", "GAZELLE" }
-- Si NO tiene aircraft => se asume permitido para todas.
--
-- CARGO_TYPES soporta 2 formatos:
-- 1) SIMPLE:
--   { label="X", aircraft={...}, template="CARGO_TEMPLATE_06", qty={...} }
-- 2) COMPUESTO:
--   { label="X", aircraft={...}, items={ {label,template,qty}, ... } }
--
-- Requiere:
-- - mist.lua cargado
-- - CARGO_ZONES definido (pickup/drop con aeropuerto)
-- - CARGO_TYPES definido (con o sin aircraft)
-- - Zona grande: MONITOREO
--=============================================================

--=============================================================
-- CONFIG
--=============================================================
local CFG = {
  debug = true,

  menuRootName = "CARGO BEAR",

  maxActiveMissions = 2,

  flagPulseStart = 5000,
  flagPulseComplete = 5002,
  flagPulseDuration = 1,

  maxAGLForCount = 0.8,
  destroyAfterDeliveredSeconds = 10,

  monitorZoneName = "MONITOREO",
  failOnLostCargo = true,
  cleanupCargoOnFail = true,

  marksEnabled = true,

  smokeEnabled = true,
  smokeInterval = 120,
  smokeColorPickup = "ORANGE",
  smokeColorDrop   = "ORANGE",

  cargoMinSep = 8,
  cargoMaxIntentosPunto = 60,
  cargoMaxIntentosSpawn = 400,

  verifyInterval = 5,
}

--=============================================================
-- CARGA DE DATOS EXTERNOS
--=============================================================
CFG.zonas = CARGO_ZONES or {}
CFG.cargoTypes = CARGO_TYPES or {}

if not CFG.zonas or #CFG.zonas == 0 then
  env.error("[CARGO BEAR] ERROR: CARGO_ZONES no esta definido o esta vacio.")
end
if not CFG.cargoTypes or #CFG.cargoTypes == 0 then
  env.error("[CARGO BEAR] ERROR: CARGO_TYPES no esta definido o esta vacio.")
end

--=============================================================
-- TEXTOS (opcional: CARGO_TEXTS)
-- Placeholders:
-- {ID} {CARGO} {ITEMS} {QTY} {DELIVERED} {REASON}
-- {PICKUP_AIRBASE} {PICKUP_ZONE} {DROP_AIRBASE} {DROP_ZONE}
-- {SMOKE_PICKUP} {SMOKE_DROP}
-- {AIRCRAFT}
--=============================================================
local TXT_DEFAULT = {
  missionStart =
    "MISION DE CARGA INICIADA\n"..
    "ID: {ID}\n"..
    "Aeronave: {AIRCRAFT}\n"..
    "Pedido: {CARGO}\n"..
    "Items: {ITEMS}\n"..
    "Total cajas: {QTY}\n"..
    "Recoger: {PICKUP_AIRBASE} ({PICKUP_ZONE})\n"..
    "Entregar: {DROP_AIRBASE} ({DROP_ZONE})\n"..
    "Indicacion:\n"..
    "1) Sigue humo en PICKUP: {SMOKE_PICKUP}\n"..
    "2) Al recoger la carga, el humo cambiara a DROP: {SMOKE_DROP}\n"..
    "Entrega cuenta solo si la caja queda en el suelo (AGL <= "..tostring(CFG.maxAGLForCount)..") dentro de DROP.\n"..
    "Si una caja desaparece despues de estar en "..tostring(CFG.monitorZoneName).." la mision falla.",

  cargoPicked =
    "MISION {ID} - CARGA RECOGIDA\n"..
    "Ahora sigue humo en DROP: {SMOKE_DROP}\n"..
    "Destino: {DROP_AIRBASE} ({DROP_ZONE})",

  missionComplete =
    "MISION COMPLETADA\n"..
    "ID: {ID}\n"..
    "Entregaste {DELIVERED}/{QTY} cajas\n"..
    "Aeronave: {AIRCRAFT}\n"..
    "Pedido: {CARGO}\n"..
    "Items: {ITEMS}\n"..
    "Destino: {DROP_AIRBASE} ({DROP_ZONE})",

  missionFailed =
    "MISION FALLIDA\n"..
    "ID: {ID}\n"..
    "Motivo: {REASON}\n"..
    "Aeronave: {AIRCRAFT}\n"..
    "Pedido: {CARGO}\n"..
    "Items: {ITEMS}\n"..
    "Recoger: {PICKUP_AIRBASE} ({PICKUP_ZONE})\n"..
    "Entregar: {DROP_AIRBASE} ({DROP_ZONE})",

  markPickup =
    "MISION {ID}\n"..
    "AERONAVE: {AIRCRAFT}\n"..
    "IR A RECOGER: {PICKUP_AIRBASE}\n"..
    "PEDIDO: {CARGO}\n"..
    "{ITEMS}\n"..
    "TOTAL: {QTY}\n"..
    "HUMO: {SMOKE_PICKUP}",

  markDrop =
    "MISION {ID}\n"..
    "AERONAVE: {AIRCRAFT}\n"..
    "IR A ENTREGAR: {DROP_AIRBASE}\n"..
    "PEDIDO: {CARGO}\n"..
    "{ITEMS}\n"..
    "TOTAL: {QTY}\n"..
    "HUMO: {SMOKE_DROP}",
}

local TXT = CARGO_TEXTS or TXT_DEFAULT

--=============================================================
-- Helpers
--=============================================================
local function say(txt, dur)
  trigger.action.outText("[CARGO BEAR] " .. tostring(txt), dur or 8)
end

local function info(msg)
  if CFG.debug then env.info("[CARGO BEAR] " .. tostring(msg)) end
end

local function err(msg)
  env.info("[CARGO BEAR][ERROR] " .. tostring(msg))
end

--=============================================================
-- Flags
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
-- Utils / Zonas
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

local function getZonaME(name)
  return trigger.misc.getZone(name)
end

local function isPointInZone2D(point, zone)
  if not point or not zone or not zone.point or not zone.radius then return false end
  local d = dist2D({x=point.x, y=point.z}, {x=zone.point.x, y=zone.point.z})
  return d <= zone.radius
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
-- Text rendering
--=============================================================
local function renderText(template, vars)
  local s = tostring(template or "")
  for k,v in pairs(vars or {}) do
    s = s:gsub("{"..k.."}", tostring(v))
  end
  return s
end

local function getMissionVars(M, extra)
  local vars = {
    ID = M.id,
    AIRCRAFT = M.aircraftKey or "N/A",
    CARGO = M.cargoLabel,
    ITEMS = M.cargoItemsText or "",
    QTY = M.required,
    PICKUP_AIRBASE = M.pickupAirbase,
    PICKUP_ZONE = M.pickupZone,
    DROP_AIRBASE = M.dropAirbase,
    DROP_ZONE = M.dropZone,
    SMOKE_PICKUP = CFG.smokeColorPickup,
    SMOKE_DROP = CFG.smokeColorDrop,
  }
  if extra then
    for k,v in pairs(extra) do vars[k] = v end
  end
  return vars
end

--=============================================================
-- Humo (altura terreno)
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
  local ground = land.getHeight({ x = z.point.x, y = z.point.z }) or 0
  local p = { x = z.point.x, y = ground + 1.0, z = z.point.z }
  trigger.action.smoke(p, getSmokeColorEnum(colorName))
end

local function maybeSmokeMission(M)
  if not CFG.smokeEnabled then return end
  local now = timer.getTime()
  M.nextSmokeTime = M.nextSmokeTime or 0
  if now < M.nextSmokeTime then return end

  if M.smokeStage == "pickup" then
    smokeZoneCenter(M.pickupZone, CFG.smokeColorPickup)
  else
    smokeZoneCenter(M.dropZone, CFG.smokeColorDrop)
  end

  M.nextSmokeTime = now + (CFG.smokeInterval or 120)
end

--=============================================================
-- Marks (una etiqueta por mision, cambia por fase)
--=============================================================
local function addOrUpdateSingleMissionMark(M)
  if not CFG.marksEnabled then return end

  local z, txt
  local markId = 900000 + M.id

  if M.smokeStage == "pickup" then
    z = getZonaME(M.pickupZone)
    if not z then return end
    txt = renderText(TXT.markPickup, getMissionVars(M))
  else
    z = getZonaME(M.dropZone)
    if not z then return end
    txt = renderText(TXT.markDrop, getMissionVars(M))
  end

  trigger.action.removeMark(markId)
  trigger.action.markToAll(markId, txt, z.point, true)
  M.singleMarkId = markId
end

local function removeMissionMarks(M)
  if not M or not M.singleMarkId then return end
  trigger.action.removeMark(M.singleMarkId)
  M.singleMarkId = nil
end

--=============================================================
-- Aeropuertos index
--=============================================================
local airportIndex = {}

local function buildAirportIndex()
  airportIndex = {}
  for _,z in ipairs(CFG.zonas or {}) do
    local zname, tipo, air = z.name, z.tipo, z.aeropuerto
    if tipo ~= "pickup" and tipo ~= "drop" then
      err("Zona con tipo invalido: "..tostring(zname).." tipo="..tostring(tipo))
    else
      if not air or air == "" then
        err("Zona sin aeropuerto definido: "..tostring(zname))
      else
        airportIndex[air] = airportIndex[air] or { pickupZones = {}, dropZones = {} }
        if tipo == "pickup" then
          table.insert(airportIndex[air].pickupZones, zname)
        else
          table.insert(airportIndex[air].dropZones, zname)
        end
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
-- CARGO TYPES MIXTO + FILTRO POR AERONAVE
--=============================================================
local function normalizeCargoJob(job)
  if not job then return nil end

  -- Ya compuesto
  if job.items and #job.items > 0 then
    return job
  end

  -- Simple => convertir
  if job.template then
    return {
      label = job.label or "Pedido",
      aircraft = job.aircraft, -- mantener filtro si existe
      items = {
        {
          label = job.label or job.template,
          template = job.template,
          qty = job.qty
        }
      }
    }
  end

  return nil
end

local function getQuantityForItem(item)
  if not item or not item.qty then return 1 end
  local q = item.qty
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

local function isJobAllowedForAircraft(job, aircraftKey)
  -- si no hay filtro, permitido
  if not job or not job.aircraft or #job.aircraft == 0 then return true end
  if not aircraftKey then return true end
  for _,k in ipairs(job.aircraft) do
    if tostring(k) == tostring(aircraftKey) then
      return true
    end
  end
  return false
end

local function getEligibleJobsForAircraft(aircraftKey)
  local list = {}
  for _,raw in ipairs(CFG.cargoTypes or {}) do
    local job = normalizeCargoJob(raw)
    if job and isJobAllowedForAircraft(job, aircraftKey) then
      table.insert(list, job)
    end
  end
  return list
end

local function pickRandomCargoJobForAircraft(aircraftKey)
  local eligible = getEligibleJobsForAircraft(aircraftKey)
  if #eligible == 0 then return nil end
  return eligible[math.random(1, #eligible)]
end

--=============================================================
-- Templates statics y spawn
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
-- Estado global
--=============================================================
local STATE = { missions = {}, nextId = 1 }

local function countActiveMissions()
  local n = 0
  for _,_ in pairs(STATE.missions) do n = n + 1 end
  return n
end

local function destroyCargoList(cargoNames)
  for _,name in ipairs(cargoNames or {}) do
    local so = StaticObject.getByName(name)
    if so and so:isExist() then so:destroy() end
  end
end

local function scheduleDestroyStaticByName(staticName, delaySeconds)
  timer.scheduleFunction(function()
    local so = StaticObject.getByName(staticName)
    if so and so:isExist() then so:destroy() end
    return nil
  end, {}, timer.getTime() + (delaySeconds or 10))
end

local function endMissionCleanup(M)
  if not M then return end
  removeMissionMarks(M)
end

local function failMission(missionId, reason)
  local M = STATE.missions[missionId]
  if not M then return end

  say(renderText(TXT.missionFailed, getMissionVars(M, { REASON = reason or "Perdida de carga" })), 12)

  if CFG.cleanupCargoOnFail then
    destroyCargoList(M.cargoNames)
  end

  endMissionCleanup(M)
  STATE.missions[missionId] = nil
end

--=============================================================
-- Fase pickup -> drop cuando ya no queda carga NO entregada en pickup
--=============================================================
local function countCargoExistingInZone(M, zoneName)
  local z = getZonaME(zoneName)
  if not z then return 0 end

  local n = 0
  for _,name in ipairs(M.cargoNames or {}) do
    if not (M.deliveredSet and M.deliveredSet[name]) then
      local so = StaticObject.getByName(name)
      if so and so:isExist() then
        local p = so:getPoint()
        if isPointInZone2D(p, z) then n = n + 1 end
      end
    end
  end
  return n
end

local function updateStageIfNeeded(M)
  if M.smokeStage ~= "pickup" then return end
  if countCargoExistingInZone(M, M.pickupZone) <= 0 then
    M.smokeStage = "drop"
    M.nextSmokeTime = 0
    addOrUpdateSingleMissionMark(M)
    say(renderText(TXT.cargoPicked, getMissionVars(M)), 10)
  end
end

--=============================================================
-- Entrega + monitoreo de perdida
--=============================================================
local function processMissionCargo(M)
  if not M then return 0 end

  local dropZ = getZonaME(M.dropZone)
  if not dropZ then return 0 end

  local monZ = M.monitorZone
  M.deliveredSet = M.deliveredSet or {}
  M.destroyScheduled = M.destroyScheduled or {}
  M.cargoEverInMonitor = M.cargoEverInMonitor or {}

  for _,name in ipairs(M.cargoNames or {}) do
    if not M.deliveredSet[name] then
      local so = StaticObject.getByName(name)

      if so and so:isExist() then
        local p = so:getPoint()

        if monZ and isPointInZone2D(p, monZ) then
          M.cargoEverInMonitor[name] = true
        end

        if isPointInZone2D(p, dropZ) and isOnGroundByAGL(p) then
          M.deliveredSet[name] = true
          if not M.destroyScheduled[name] then
            M.destroyScheduled[name] = true
            scheduleDestroyStaticByName(name, CFG.destroyAfterDeliveredSeconds)
          end
        end

      else
        if CFG.failOnLostCargo and M.cargoEverInMonitor[name] then
          return -1
        end
      end
    end
  end

  local deliveredCount = 0
  for _,_ in pairs(M.deliveredSet or {}) do deliveredCount = deliveredCount + 1 end
  return deliveredCount
end

--=============================================================
-- Loop por mision
--=============================================================
local function verifyMissionLoop(missionId)
  local M = STATE.missions[missionId]
  if not M then return nil end

  updateStageIfNeeded(M)
  maybeSmokeMission(M)

  local delivered = processMissionCargo(M)

  if delivered == -1 then
    failMission(missionId, "Carga perdida dentro de zona MONITOREO")
    return nil
  end

  if delivered >= M.required then
    say(renderText(TXT.missionComplete, getMissionVars(M, { DELIVERED = delivered })), 12)
    pulseFlag(CFG.flagPulseComplete, CFG.flagPulseDuration)
    endMissionCleanup(M)
    STATE.missions[missionId] = nil
    return nil
  end

  return timer.getTime() + CFG.verifyInterval
end

--=============================================================
-- Crear mision random FILTRADA por aeronave
--=============================================================
local function startRandomMissionForAircraft(aircraftKey)
  if countActiveMissions() >= (CFG.maxActiveMissions or 1) then
    say("No se puede crear mision. Limite de misiones activas: "..tostring(CFG.maxActiveMissions), 10)
    return
  end

  local pickupAir, pickupZone, dropAir, dropZone = pickRandomPickupDropByAirport()
  if not pickupAir or not pickupZone or not dropAir or not dropZone then
    say("ERROR: No se pudo crear mision random por aeropuerto. Revisa CARGO_ZONES.", 10)
    return
  end

  if not getZonaME(pickupZone) then say("ERROR: No existe pickupZone "..tostring(pickupZone), 10); return end
  if not getZonaME(dropZone) then say("ERROR: No existe dropZone "..tostring(dropZone), 10); return end

  local job = pickRandomCargoJobForAircraft(aircraftKey)
  if not job or not job.items or #job.items == 0 then
    say("No hay pedidos compatibles para aeronave: "..tostring(aircraftKey), 10)
    return
  end

  local missionId = STATE.nextId
  STATE.nextId = STATE.nextId + 1

  local allCargoNames = {}
  local requiredTotal = 0
  local itemLines = {}

  for _,it in ipairs(job.items) do
    if not it.template then
      say("ERROR: Item sin template en pedido: "..tostring(job.label or "SIN_LABEL"), 10)
      return
    end

    local qty = getQuantityForItem(it)
    if qty < 1 then qty = 1 end

    local spawned = spawnCargoEnZona(missionId, pickupZone, qty, it.template)

    for _,nm in ipairs(spawned) do table.insert(allCargoNames, nm) end
    requiredTotal = requiredTotal + #spawned

    local itLabel = it.label or it.template
    table.insert(itemLines, tostring(itLabel) .. " x" .. tostring(#spawned))
  end

  if #allCargoNames == 0 then
    say("No se pudo spawnear carga del pedido.", 10)
    return
  end

  local monZ = getZonaME(CFG.monitorZoneName)

  local M = {
    id = missionId,

    aircraftKey = aircraftKey,

    pickupZone = pickupZone,
    dropZone = dropZone,

    pickupAirbase = pickupAir,
    dropAirbase = dropAir,

    required = requiredTotal,

    cargoLabel = job.label or "Pedido",
    cargoItemsText = table.concat(itemLines, " | "),

    cargoNames = allCargoNames,
    deliveredSet = {},
    destroyScheduled = {},

    monitorZone = monZ,
    cargoEverInMonitor = {},

    smokeStage = "pickup",
    nextSmokeTime = 0,

    singleMarkId = nil,
  }

  STATE.missions[missionId] = M

  pulseFlag(CFG.flagPulseStart, CFG.flagPulseDuration)

  addOrUpdateSingleMissionMark(M)
  say(renderText(TXT.missionStart, getMissionVars(M)), 20)

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
      " | AIR="..tostring(M.aircraftKey or "N/A")..
      " | FASE="..tostring(M.smokeStage)

    lines[#lines+1] = "  Items: "..tostring(M.cargoItemsText or "")
    lines[#lines+1] = "  Recoger: "..tostring(M.pickupAirbase).." ("..tostring(M.pickupZone)..")"
    lines[#lines+1] = "  Entregar: "..tostring(M.dropAirbase).." ("..tostring(M.dropZone)..")"
  end

  say(table.concat(lines, "\n"), 18)
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
-- Menu F10 - CARGO BEAR
--=============================================================
local MENU = { root=nil, otros=nil }

local function buildMenu()
  MENU.root = missionCommands.addSubMenu(CFG.menuRootName)

  missionCommands.addCommand("C130-J-30 - Crear mision", MENU.root, function()
    startRandomMissionForAircraft("C130")
  end)

  missionCommands.addCommand("CHINOOK - Crear mision", MENU.root, function()
    startRandomMissionForAircraft("CHINOOK")
  end)

  missionCommands.addCommand("MI-8 - Crear mision", MENU.root, function()
    startRandomMissionForAircraft("MI8")
  end)

  MENU.otros = missionCommands.addSubMenu("OTROS", MENU.root)

  missionCommands.addCommand("HUEY - Crear mision", MENU.otros, function()
    startRandomMissionForAircraft("HUEY")
  end)

  missionCommands.addCommand("MI-24 - Crear mision", MENU.otros, function()
    startRandomMissionForAircraft("MI24")
  end)

  missionCommands.addCommand("GAZELLE - Crear mision", MENU.otros, function()
    startRandomMissionForAircraft("GAZELLE")
  end)

  missionCommands.addCommand("Estado de misiones", MENU.root, missionStatus)
  missionCommands.addCommand("Cancelar todas las misiones", MENU.root, cancelAllMissions)
end

--=============================================================
-- Diagnostico rapido (incluye conteo por aeronave)
--=============================================================
local function templateExists(templateName)
  local ex = (StaticObject.getByName(templateName) ~= nil)
  if ex then return true end
  if mist and mist.DBs and mist.DBs.staticsByName and mist.DBs.staticsByName[templateName] then
    return true
  end
  return false
end

local function countEligibleFor(airKey)
  local list = getEligibleJobsForAircraft(airKey)
  return #list
end

local function diagnostico()
  local lines = {}
  lines[#lines+1] = "Diagnostico CARGO BEAR:"
  lines[#lines+1] = "- MIST: "..tostring(mist ~= nil)
  lines[#lines+1] = "- Zonas (CARGO_ZONES): "..tostring((CFG.zonas and #CFG.zonas) or 0)
  lines[#lines+1] = "- Entradas (CARGO_TYPES): "..tostring((CFG.cargoTypes and #CFG.cargoTypes) or 0)
  lines[#lines+1] = "- MONITOREO existe="..tostring(getZonaME(CFG.monitorZoneName) ~= nil)
  lines[#lines+1] = "- Humo enabled="..tostring(CFG.smokeEnabled).." interval="..tostring(CFG.smokeInterval)
  lines[#lines+1] = "- Marks enabled="..tostring(CFG.marksEnabled)
  lines[#lines+1] = "- Elegibles: C130="..tostring(countEligibleFor("C130"))..
                    " CHINOOK="..tostring(countEligibleFor("CHINOOK"))..
                    " MI8="..tostring(countEligibleFor("MI8"))..
                    " HUEY="..tostring(countEligibleFor("HUEY"))..
                    " MI24="..tostring(countEligibleFor("MI24"))..
                    " GAZELLE="..tostring(countEligibleFor("GAZELLE"))

  -- Validar templates declarados
  for i,raw in ipairs(CFG.cargoTypes or {}) do
    local job = normalizeCargoJob(raw)
    if job and job.items and #job.items > 0 then
      for _,it in ipairs(job.items) do
        if it.template and not templateExists(it.template) then
          lines[#lines+1] = "  WARNING: Falta template en ME: "..tostring(it.template).." (en "..tostring(job.label)..")"
        end
      end
    end
  end

  say(table.concat(lines, "\n"), 20)
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
