--=============================================================
-- C130 Cargo Missions CORE (MIST)
--
-- Datos externos (recomendado):
-- - CARGO_ZONES : tabla de zonas por mapa
-- - CARGO_TYPES : tabla de tipos de carga por mapa/campaña
-- - (opcional) CARGO_TEXTS : textos personalizables por mapa/campaña
--
-- Caracteristicas:
-- - Random por aeropuerto (pickup y drop nunca el mismo aeropuerto)
-- - Tipo de carga random con label
-- - Cantidad por tipo (fixed o random)
-- - Entrega cuenta solo si AGL <= umbral dentro del DROP
-- - Cajas entregadas se destruyen tras X segundos
-- - Limite de misiones simultaneas
-- - MONITOREO: si una caja no entregada desaparece tras estar en MONITOREO => falla
-- - Humo por fases (solo pickup, luego solo drop)
-- - Mark por fases (solo una etiqueta a la vez)
--
-- Nota humo:
-- DCS no permite "remover" humo ya creado; solo dejar de refrescarlo.
-- Este core lo refresca mientras mision este activa y segun la fase.
--=============================================================

--=============================================================
-- CONFIG
--=============================================================
local CFG = {
  debug = true,
  menuRootName = "C-130J Carga",

  maxActiveMissions = 2,

  flagPulseStart = 5000,
  flagPulseComplete = 5002,
  flagPulseDuration = 1,

  maxAGLForCount = 0.8,              -- metros
  destroyAfterDeliveredSeconds = 10,  -- segundos

  monitorZoneName = "MONITOREO",
  failOnLostCargo = true,
  cleanupCargoOnFail = true,

  marksEnabled = true,

  smokeEnabled = true,
  smokeInterval = 120,               -- segundos
  smokeColorPickup = "ORANGE",
  smokeColorDrop   = "ORANGE",

  cargoMinSep = 8,
  cargoMaxIntentosPunto = 60,
  cargoMaxIntentosSpawn = 400,

  verifyInterval = 5,
}

--=============================================================
-- CARGA DE DATOS EXTERNOS (ZONAS / TIPOS)
--=============================================================
CFG.zonas = CARGO_ZONES or {}
CFG.cargoTypes = CARGO_TYPES or {}

if not CFG.zonas or #CFG.zonas == 0 then
  env.error("[C130-CARGO] ERROR: CARGO_ZONES no esta definido o esta vacio.")
end
if not CFG.cargoTypes or #CFG.cargoTypes == 0 then
  env.error("[C130-CARGO] ERROR: CARGO_TYPES no esta definido o esta vacio.")
end

--=============================================================
-- TEXTOS (EDITA AQUI O DEFINE CARGO_TEXTS EN OTRO SCRIPT)
-- Placeholders:
-- {ID} {CARGO} {QTY} {DELIVERED} {REASON}
-- {PICKUP_AIRBASE} {PICKUP_ZONE} {DROP_AIRBASE} {DROP_ZONE}
-- {SMOKE_PICKUP} {SMOKE_DROP}
--=============================================================
local TXT_DEFAULT = {
  missionStart =
    "MISION DE CARGA INICIADA\n"..
    "ID: {ID}\n"..
    "Carga: {CARGO}\n"..
    "Cajas requeridas: {QTY}\n"..
    "Recoger en: {PICKUP_AIRBASE}\n"..
    "Entregar en: {DROP_AIRBASE}\n"..
     --"Recoger: {PICKUP_AIRBASE} ({PICKUP_ZONE})\n"..
     --"Entregar: {DROP_AIRBASE} ({DROP_ZONE})\n"..
    "Indicacion:\n"..
    "1) Ve hasta el aeropuerto:{PICKUP_AIRBASE} para recojer la carga acercate al humo {SMOKE_PICKUP}\n"..
    "2) Al llegar al Aeropuerto de destino: {DROP_AIRBASE} Busca el humo de color {SMOKE_DROP} y acercate para descargar y completar la mision.\n"..
    "3) La Mision solo finalizara al entregar todas las cargas en la zona designada, Humo color {SMOKE_DROP} y Etiqueta en F10 \n",
    --"1) Sigue humo en PICKUP: {SMOKE_PICKUP}\n"..
    --"2) Al recoger la carga, el humo cambiara a DROP: {SMOKE_DROP}\n"..
    --"Entrega cuenta solo si la caja queda en el suelo (AGL <= "..tostring(CFG.maxAGLForCount)..") dentro de DROP.\n"..
    --"Si una caja desaparece despues de estar en "..tostring(CFG.monitorZoneName).." la mision falla.",

  cargoPicked =
    "MISION {ID} - CARGA RECOGIDA\n"..
    "Ahora dirigete hacia {DROP_AIRBASE}\n"..
    "Recuerda: la mision solo finalizara al entregar la carga en al zona designada humo: {SMOKE_DROP} Revisa F10, busca la etiqueta para mas información ",

  missionComplete =
    "MISION COMPLETADA\n"..
    "ID: {ID}\n"..
    "Entregaste {DELIVERED}/{QTY} cajas\n"..
    "Carga: {CARGO}\n"..
    "Destino: {DROP_AIRBASE}",

  missionFailed =
    "MISION FALLIDA\n"..
    "ID: {ID}\n"..
    "Motivo: {REASON}\n"..
    "Carga: {CARGO}\n"..
    "Recoger: {PICKUP_AIRBASE}\n"..
    "Entregar: {DROP_AIRBASE}",

  markPickup =
    "MISION {ID}\n"..
    "IR A RECOGER: {PICKUP_AIRBASE}\n"..
    "CARGA: {CARGO}\n"..
    "CAJAS: {QTY}\n"..
    "HUMO: {SMOKE_PICKUP}",

  markDrop =
    "MISION {ID}\n"..
    "IR A ENTREGAR: {DROP_AIRBASE}\n"..
    "CARGA: {CARGO}\n"..
    "CAJAS: {QTY}\n"..
    "HUMO: {SMOKE_DROP}",
}

local TXT = CARGO_TEXTS or TXT_DEFAULT

--=============================================================
-- Helpers: logs / mensajes
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
    CARGO = M.cargoLabel,
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
-- Humo (FIX altura en terreno)
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
-- Marks (una etiqueta a la vez, por fase)
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
-- Aeropuertos: index por aeropuerto
--=============================================================
local airportIndex = {}

local function buildAirportIndex()
  airportIndex = {}

  for _,z in ipairs(CFG.zonas or {}) do
    local zname = z.name
    local tipo = z.tipo
    local air = z.aeropuerto

    if tipo ~= "pickup" and tipo ~= "drop" then
      err("Zona con tipo invalido: "..tostring(zname).." tipo="..tostring(tipo))
    else
      if not air or air == "" then
        err("Zona sin aeropuerto definido (recomendado definirlo): "..tostring(zname))
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
  -- humo no se puede apagar; al terminar la mision deja de refrescarse.
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
-- Cambio de fase (pickup -> drop)
-- Condicion: ya no queda ninguna caja sin entregar dentro de la zona pickup
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
        if isPointInZone2D(p, z) then
          n = n + 1
        end
      end
    end
  end
  return n
end

local function updateStageIfNeeded(M)
  if M.smokeStage ~= "pickup" then return end
  local remainingAtPickup = countCargoExistingInZone(M, M.pickupZone)
  if remainingAtPickup <= 0 then
    M.smokeStage = "drop"
    M.nextSmokeTime = 0
    addOrUpdateSingleMissionMark(M)
    say(renderText(TXT.cargoPicked, getMissionVars(M)), 10)
  end
end

--=============================================================
-- Proceso mision: entrega + monitoreo de perdida
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

        if isPointInZone2D(p, dropZ) then
          if isOnGroundByAGL(p) then
            M.deliveredSet[name] = true
            if not M.destroyScheduled[name] then
              M.destroyScheduled[name] = true
              scheduleDestroyStaticByName(name, CFG.destroyAfterDeliveredSeconds)
            end
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
-- Crear mision random
--=============================================================
local function startRandomMission()
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

  local cargoType = pickRandomCargoType()
  if not cargoType or not cargoType.template then
    say("ERROR: No hay cargoTypes validos en CARGO_TYPES.", 10)
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

    singleMarkId = nil,
  }

  STATE.missions[missionId] = M

  pulseFlag(CFG.flagPulseStart, CFG.flagPulseDuration)

  addOrUpdateSingleMissionMark(M)
  say(renderText(TXT.missionStart, getMissionVars(M)), 20)

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
      " | FASE="..tostring(M.smokeStage)

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
  lines[#lines+1] = "- Zonas (CARGO_ZONES): "..tostring((CFG.zonas and #CFG.zonas) or 0)
  lines[#lines+1] = "- Tipos (CARGO_TYPES): "..tostring((CFG.cargoTypes and #CFG.cargoTypes) or 0)
  lines[#lines+1] = "- maxActiveMissions: "..tostring(CFG.maxActiveMissions)
  lines[#lines+1] = "- AGL para contar: "..tostring(CFG.maxAGLForCount)
  lines[#lines+1] = "- Destruir despues: "..tostring(CFG.destroyAfterDeliveredSeconds).."s"
  lines[#lines+1] = "- MONITOREO: "..tostring(CFG.monitorZoneName).." existe="..tostring(getZonaME(CFG.monitorZoneName) ~= nil)
  lines[#lines+1] = "- Humo: "..tostring(CFG.smokeEnabled).." interval="..tostring(CFG.smokeInterval).." pickup="..tostring(CFG.smokeColorPickup).." drop="..tostring(CFG.smokeColorDrop)
  lines[#lines+1] = "- Marks: "..tostring(CFG.marksEnabled)

  buildAirportIndex()

  if CFG.cargoTypes and #CFG.cargoTypes > 0 then
    for i,ct in ipairs(CFG.cargoTypes) do
      local tname = ct.template
      local label = ct.label or tname
      local ex = templateExists(tname)
      lines[#lines+1] = string.format("  CARGO %d) %s | template=%s | existe=%s", i, tostring(label), tostring(tname), tostring(ex))
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
