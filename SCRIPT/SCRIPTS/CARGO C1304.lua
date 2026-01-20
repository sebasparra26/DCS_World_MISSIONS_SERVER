--=============================================================
-- C-130 Cargo Missions (MIST)
-- Misiones dinamicas:
-- - Pickup/Drop zones random
-- - Tipo de carga random
-- - Cantidad de cajas definida por tipo de carga
-- - Entrega solo cuenta si AGL ~ 0 dentro de la zona DROP
-- - Cajas entregadas se destruyen X segundos despues
-- - Soporta multiples misiones simultaneas con limite configurable
--
-- Orden recomendado de carga:
-- 1) MIST
-- 2) PersianGolf DB Aiports.lua (opcional, para deducir aeropuertos)
-- 3) Este script
--=============================================================

local CFG = {
  debug = true,
  menuRootName = "C-130J Carga",

  --===========================================================
  -- LIMITE DE MISIONES SIMULTANEAS
  --===========================================================
  maxActiveMissions = 2,  -- cuantas misiones pueden estar activas al mismo tiempo

  --===========================================================
  -- PULSOS DE BANDERAS (conmutados)
  --===========================================================
  flagPulseStart = 5000,
  flagPulseComplete = 5002,
  flagPulseDuration = 1,
  flagPulseCompleteOffOverride = nil,

  --===========================================================
  -- MISION RANDOM
  --===========================================================
  preventSameZone = true,

  --===========================================================
  -- ENTREGA: CONDICION AGL Y AUTODESTRUCCION
  --===========================================================
  maxAGLForCount = 0.8,              -- metros; cuenta solo si AGL <= esto
  destroyAfterDeliveredSeconds = 10,  -- segundos tras contar una caja entregada

  --===========================================================
  -- ZONAS (backend editable)
  --===========================================================
  -- tipo: "pickup" o "drop"
  zonas = {
    { name = "ZONECARGO1", tipo = "pickup", aeropuerto = "Liwa AFB" },
    { name = "ZONECARGO2", tipo = "pickup", aeropuerto = "Al Dhafra AFB" },

    { name = "ZONEDROP1",  tipo = "drop",   aeropuerto = "Al Ain Intl" },
    { name = "ZONEDROP2",  tipo = "drop",   aeropuerto = "Dubai Intl" },
  },

  --===========================================================
  -- TIPOS DE CARGA (backend editable)
  --===========================================================
  -- Cada tipo define:
  -- template: nombre del Static template en el ME
  -- qty:
  --   mode="fixed", value=N
  --   mode="random", min=A, max=B
  --
  -- Ejemplos:
  -- - Carga grande: solo 1
  -- - Cajas pequenas: 8
  cargoTypes = {
    --{ template = "CARGO_TEMPLATE_01", qty = { mode = "fixed", value = 1 } },
    { template = "CARGO_TEMPLATE_01", qty = { mode = "random", min = 4, max = 10 } },
    { template = "CARGO_TEMPLATE_02", qty = { mode = "random", min = 2, max = 4 }  },
    --{ template = "CARGO_TEMPLATE_03", qty = { mode = "fixed", value = 2 } },
  },

  --===========================================================
  -- SPAWN (cajas dentro de zona pickup)
  --===========================================================
  cargoMinSep = 8,
  cargoMaxIntentosPunto = 60,
  cargoMaxIntentosSpawn = 400,

  --===========================================================
  -- VERIFICACION
  --===========================================================
  verifyInterval = 5, -- segundos
}

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

local function pulseFlag(flagOn, flagOffOverride, duration)
  if not flagOn then return end
  local offFlag = flagOffOverride or flagOn
  local dur = duration or 1

  setFlag(flagOn, true)
  timer.scheduleFunction(function()
    setFlag(offFlag, false)
    return nil
  end, {}, timer.getTime() + dur)
end

--=============================================================
-- Utils geometria / random
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
-- AGL helpers
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
-- Zonas / Backend
--=============================================================
local function getZonaME(name)
  return trigger.misc.getZone(name)
end

local function getZonasByTipo(tipo)
  local out = {}
  for _,z in ipairs(CFG.zonas or {}) do
    if z.tipo == tipo then
      table.insert(out, z)
    end
  end
  return out
end

local function getZonaCfgByName(name)
  for _,z in ipairs(CFG.zonas or {}) do
    if z.name == name then return z end
  end
  return nil
end

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

local function getAirbaseNameForZone(zoneName)
  local zME = getZonaME(zoneName)
  local zCFG = getZonaCfgByName(zoneName)

  if zCFG and zCFG.aeropuerto then
    return zCFG.aeropuerto
  end

  if zME then
    return deducirAeropuertoPorCercania(zME.point) or "DESCONOCIDO"
  end

  return "DESCONOCIDO"
end

local function pickRandomPickupDrop()
  local pickups = getZonasByTipo("pickup")
  local drops   = getZonasByTipo("drop")

  if #pickups == 0 then err("No hay zonas tipo pickup en CFG.zonas."); return nil end
  if #drops == 0 then err("No hay zonas tipo drop en CFG.zonas."); return nil end

  local p = pickups[math.random(1, #pickups)]
  local d = drops[math.random(1, #drops)]

  if CFG.preventSameZone then
    local tries = 0
    while d.name == p.name and tries < 50 do
      d = drops[math.random(1, #drops)]
      tries = tries + 1
    end
  end

  return p.name, d.name
end

--=============================================================
-- Tipos de carga: elegir random + cantidad por tipo
--=============================================================
local function pickRandomCargoType()
  if not CFG.cargoTypes or #CFG.cargoTypes == 0 then
    return nil
  end
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
-- Cargo template (static) -> spawn clones
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
  missions = {},      -- [missionId] = missionData
  nextId = 1,
}

local function countActiveMissions()
  local n = 0
  for _,_ in pairs(STATE.missions) do n = n + 1 end
  return n
end

--=============================================================
-- Destruccion de static por nombre con delay
--=============================================================
local function scheduleDestroyStaticByName(staticName, delaySeconds)
  timer.scheduleFunction(function()
    local so = StaticObject.getByName(staticName)
    if so and so:isExist() then
      so:destroy()
    end
    return nil
  end, {}, timer.getTime() + (delaySeconds or 10))
end

--=============================================================
-- Procesar entregas de una mision:
-- - dentro de zona drop
-- - AGL <= umbral
-- - marcar delivered
-- - programar destruccion
--=============================================================
local function processDeliveredCargo(mission)
  if not mission then return 0 end

  local z = getZonaME(mission.dropZone)
  if not z then return 0 end

  mission.deliveredSet = mission.deliveredSet or {}
  mission.destroyScheduled = mission.destroyScheduled or {}

  for _,name in ipairs(mission.cargoNames or {}) do
    if not mission.deliveredSet[name] then
      local so = StaticObject.getByName(name)
      if so and so:isExist() then
        local p = so:getPoint()

        local d = dist2D({x=p.x,y=p.z}, {x=z.point.x,y=z.point.z})
        if d <= (z.radius or 0) then
          if isOnGroundByAGL(p) then
            mission.deliveredSet[name] = true

            if not mission.destroyScheduled[name] then
              mission.destroyScheduled[name] = true
              scheduleDestroyStaticByName(name, CFG.destroyAfterDeliveredSeconds)
            end
          end
        end
      end
    end
  end

  local deliveredCount = 0
  for _,_ in pairs(mission.deliveredSet or {}) do deliveredCount = deliveredCount + 1 end
  return deliveredCount
end

--=============================================================
-- Loop de verificacion por mision (independiente)
--=============================================================
local function verifyMissionLoop(missionId)
  local M = STATE.missions[missionId]
  if not M then return nil end

  local delivered = processDeliveredCargo(M)

  if delivered >= M.required then
    say(
      "MISION COMPLETADA\n"..
      "ID: "..tostring(M.id).."\n"..
      "Entregaste "..tostring(delivered).."/"..tostring(M.required).." cajas\n"..
      "Drop: "..tostring(M.dropAirbase).." ("..tostring(M.dropZone)..")\n"..
      "Tipo de carga: "..tostring(M.cargoTemplateName),
      12
    )

    pulseFlag(CFG.flagPulseComplete, CFG.flagPulseCompleteOffOverride, CFG.flagPulseDuration)

    STATE.missions[missionId] = nil
    return nil
  end

  return timer.getTime() + CFG.verifyInterval
end

--=============================================================
-- Crear mision aleatoria (respeta limite de misiones activas)
--=============================================================
local function startRandomMission()
  if countActiveMissions() >= (CFG.maxActiveMissions or 1) then
    say("No se puede crear mision. Limite de misiones activas: "..tostring(CFG.maxActiveMissions), 10)
    return
  end

  local pickupZone, dropZone = pickRandomPickupDrop()
  if not pickupZone or not dropZone then
    say("ERROR: No se pudo crear mision random. Revisa CFG.zonas.", 10)
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

  local missionId = STATE.nextId
  STATE.nextId = STATE.nextId + 1

  local cargoNames = spawnCargoEnZona(missionId, pickupZone, required, cargoTemplateName)
  if #cargoNames == 0 then
    say("No se pudo spawnear carga. Revisa templates/zona.", 10)
    return
  end

  local pickAir = getAirbaseNameForZone(pickupZone)
  local dropAir = getAirbaseNameForZone(dropZone)

  local M = {
    id = missionId,
    pickupZone = pickupZone,
    dropZone = dropZone,
    pickupAirbase = pickAir,
    dropAirbase = dropAir,
    required = required,
    cargoTemplateName = cargoTemplateName,
    cargoNames = cargoNames,
    deliveredSet = {},
    destroyScheduled = {}
  }

  STATE.missions[missionId] = M

  pulseFlag(CFG.flagPulseStart, nil, CFG.flagPulseDuration)

  say(
    "MISION DE CARGA INICIADA\n"..
    "ID: "..tostring(M.id).."\n"..
    "Recogida: "..tostring(pickAir).." ("..tostring(pickupZone)..")\n"..
    "Entrega:  "..tostring(dropAir).." ("..tostring(dropZone)..")\n"..
    "Cajas requeridas: "..tostring(required).."\n"..
    "Tipo de carga: "..tostring(cargoTemplateName).."\n"..
    "Regla: Solo cuentan si quedan en el suelo (AGL <= "..tostring(CFG.maxAGLForCount)..") dentro de la zona DROP.\n",
    16
  )

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

  for id,M in pairs(STATE.missions) do
    local delivered = processDeliveredCargo(M)
    lines[#lines+1] =
      "ID "..tostring(id)..
      " | "..tostring(delivered).."/"..tostring(M.required)..
      " | "..tostring(M.cargoTemplateName)..
      " | "..tostring(M.pickupZone).." -> "..tostring(M.dropZone)
  end

  say(table.concat(lines, "\n"), 12)
end

local function cancelAllMissions()
  local active = countActiveMissions()
  if active == 0 then
    say("No hay misiones activas.", 6)
    return
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

  local pCount = #getZonasByTipo("pickup")
  local dCount = #getZonasByTipo("drop")
  lines[#lines+1] = "- Zonas pickup: "..tostring(pCount)
  lines[#lines+1] = "- Zonas drop: "..tostring(dCount)

  lines[#lines+1] = "- cargoTypes: "..tostring((CFG.cargoTypes and #CFG.cargoTypes) or 0)
  if CFG.cargoTypes and #CFG.cargoTypes > 0 then
    for i,ct in ipairs(CFG.cargoTypes) do
      local tname = ct.template
      local qty = getQuantityForCargoType(ct)
      local ex = templateExists(tname)
      lines[#lines+1] = string.format("  %d) %s | qtyEjemplo=%d | existe=%s", i, tostring(tname), qty, tostring(ex))
    end
  end

  for i,z in ipairs(CFG.zonas or {}) do
    lines[#lines+1] = string.format("  Zona %d: %s tipo=%s (ME=%s)", i, tostring(z.name), tostring(z.tipo), tostring(getZonaME(z.name) ~= nil))
  end

  say(table.concat(lines, "\n"), 12)
  info(table.concat(lines, " | "))
end

--=============================================================
-- Start
--=============================================================
timer.scheduleFunction(function()
  diagnostico()
  buildMenu()
end, {}, timer.getTime() + 2)
