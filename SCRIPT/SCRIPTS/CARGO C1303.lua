--=============================================================
-- C-130 Cargo Missions (MIST)
-- Misiones dinamicas: pickup/drop random + tipo de carga random por mision
-- + Contar entrega solo si AGL ~ 0
-- + Auto eliminar cajas entregadas despues de X segundos
--
-- Requiere cargar en este orden:
-- 1) MIST
-- 2) PersianGolf DB Aiports.lua (opcional, para deducir aeropuertos)
-- 3) Este script
--=============================================================

local CFG = {
  debug = true,
  menuRootName = "C-130J Carga",

  --===========================================================
  -- PULSOS DE BANDERAS
  --===========================================================
  flagPulseStart = 5000,
  flagPulseComplete = 5002,
  flagPulseDuration = 1,
  flagPulseCompleteOffOverride = nil,

  --===========================================================
  -- MISION RANDOM
  --===========================================================
  randomMission = true,
  preventSameZone = true,

  --===========================================================
  -- CANTIDAD DE CAJAS POR MISION
  --===========================================================
  quantityRandom = true,
  quantityFixed  = 4,
  quantityMin    = 4,
  quantityMax    = 6,

  --===========================================================
  -- ENTREGA: CONDICION AGL Y AUTODESTRUCCION
  --===========================================================
  -- Solo cuenta si AGL <= este valor (metros). Recomendado 0.5 a 1.0
  maxAGLForCount = 0.8,

  -- Luego de contar una caja como entregada, se destruye tras X segundos
  destroyAfterDeliveredSeconds = 10,

  --===========================================================
  -- ZONAS
  --===========================================================
  zonas = {
    { name = "ZONECARGO1", tipo = "pickup", aeropuerto = "ZONA 02" },
    { name = "ZONECARGO2", tipo = "pickup", aeropuerto = "ZONA 02" },

    { name = "ZONEDROP1",  tipo = "drop",   aeropuerto = "ZONA DROP 02" },
    { name = "ZONEDROP2",  tipo = "drop",   aeropuerto = "ZONA DROP 02" },
  },

  --===========================================================
  -- TEMPLATES DE CARGA (Static)
  --===========================================================
  cargoTemplates = {
    "CARGO_TEMPLATE_01",
    "CARGO_TEMPLATE_02",
    "CARGO_TEMPLATE_03",
  },

  --===========================================================
  -- SPAWN
  --===========================================================
  cargoMinSep = 8,
  cargoMaxIntentosPunto = 60,
  cargoMaxIntentosSpawn = 400,

  --===========================================================
  -- VERIFICACION
  --===========================================================
  verifyInterval = 5,
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
-- Banderas (pulsos)
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
  -- point.y es MSL (altura sobre el nivel del mar)
  -- land.getHeight() devuelve altura del terreno (MSL) en esa coordenada
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
  return string.format("%s_M%02d_%03d_%d", base, missionId or 0, idx or 0, timer.getTime())
end

local function pickRandomCargoTemplateName()
  if not CFG.cargoTemplates or #CFG.cargoTemplates == 0 then
    return nil
  end
  return CFG.cargoTemplates[math.random(1, #CFG.cargoTemplates)]
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
-- Estado de mision
--=============================================================
local STATE = {
  active = nil
  -- active = {
  --   pickupZone, dropZone,
  --   pickupAirbase, dropAirbase,
  --   required,
  --   cargoTemplateName,
  --   cargoNames = {},
  --   deliveredSet = { [cargoName]=true, ... }
  --   destroyScheduled = { [cargoName]=true, ... }
  -- }
}

local function pickMissionQuantity()
  if CFG.quantityRandom then
    local mn = tonumber(CFG.quantityMin) or 1
    local mx = tonumber(CFG.quantityMax) or mn
    if mx < mn then mx = mn end
    return math.random(mn, mx)
  end
  return tonumber(CFG.quantityFixed) or 1
end

--=============================================================
-- ENTREGA: contar solo si AGL ~ 0 + destruir despues de X segundos
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

local function processDeliveredCargo()
  -- Devuelve cuantas cajas entregadas validas hay (con AGL <= umbral)
  if not STATE.active then return 0 end
  local M = STATE.active

  local z = getZonaME(M.dropZone)
  if not z then return 0 end

  M.deliveredSet = M.deliveredSet or {}
  M.destroyScheduled = M.destroyScheduled or {}

  for _,name in ipairs(M.cargoNames or {}) do
    if not M.deliveredSet[name] then
      local so = StaticObject.getByName(name)
      if so and so:isExist() then
        local p = so:getPoint()

        -- 1) Debe estar dentro de la zona DROP
        local d = dist2D({x=p.x,y=p.z}, {x=z.point.x,y=z.point.z})
        if d <= (z.radius or 0) then
          -- 2) Debe estar en el suelo (AGL ~ 0)
          if isOnGroundByAGL(p) then
            -- Cuenta como entregada
            M.deliveredSet[name] = true

            -- Programa destruccion despues de X segundos (una sola vez)
            if not M.destroyScheduled[name] then
              M.destroyScheduled[name] = true
              scheduleDestroyStaticByName(name, CFG.destroyAfterDeliveredSeconds)
            end
          end
        end
      end
    end
  end

  -- Contar entregadas
  local deliveredCount = 0
  for _,_ in pairs(M.deliveredSet or {}) do
    deliveredCount = deliveredCount + 1
  end
  return deliveredCount
end

--=============================================================
-- Verificacion principal
--=============================================================
local function verifyLoop()
  if not STATE.active then return nil end

  local M = STATE.active
  local delivered = processDeliveredCargo()

  if delivered >= M.required then
    say(
      "MISION COMPLETADA\n"..
      "Entregaste "..tostring(delivered).."/"..tostring(M.required).." cajas\n"..
      "Drop: "..tostring(M.dropAirbase).." ("..tostring(M.dropZone)..")\n"..
      "Tipo de carga: "..tostring(M.cargoTemplateName),
      12
    )

    pulseFlag(CFG.flagPulseComplete, CFG.flagPulseCompleteOffOverride, CFG.flagPulseDuration)

    STATE.active = nil
    return nil
  end

  return timer.getTime() + CFG.verifyInterval
end

--=============================================================
-- Crear mision aleatoria
--=============================================================
local function startRandomMission()
  if STATE.active then
    say("Ya hay una mision activa. Finalizala antes de crear otra.", 8)
    return
  end

  local pickupZone, dropZone = pickRandomPickupDrop()
  if not pickupZone or not dropZone then
    say("ERROR: No se pudo crear mision random. Revisa CFG.zonas.", 10)
    return
  end

  if not getZonaME(pickupZone) then say("ERROR: No existe pickupZone "..tostring(pickupZone), 10); return end
  if not getZonaME(dropZone) then say("ERROR: No existe dropZone "..tostring(dropZone), 10); return end

  local cargoTemplateName = pickRandomCargoTemplateName()
  if not cargoTemplateName then
    say("ERROR: No hay templates en CFG.cargoTemplates.", 10)
    return
  end

  local required = pickMissionQuantity()
  local cargoNames = spawnCargoEnZona(1, pickupZone, required, cargoTemplateName)
  if #cargoNames == 0 then
    say("No se pudo spawnear carga. Revisa templates/zona.", 10)
    return
  end

  local pickAir = getAirbaseNameForZone(pickupZone)
  local dropAir = getAirbaseNameForZone(dropZone)

  STATE.active = {
    id = 1,
    nombre = "Mision Random",
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

  pulseFlag(CFG.flagPulseStart, nil, CFG.flagPulseDuration)

  say(
    "MISION DE CARGA INICIADA\n"..
    "Recogida: "..tostring(pickAir).." ("..tostring(pickupZone)..")\n"..
    "Entrega:  "..tostring(dropAir).." ("..tostring(dropZone)..")\n"..
    "Cajas requeridas: "..tostring(required).."\n"..
    "Tipo de carga: "..tostring(cargoTemplateName).."\n"..
    "Nota: Solo cuentan si quedan en el suelo (AGL ~ 0) dentro de la zona DROP.\n",
    16
  )

  timer.scheduleFunction(function()
    return verifyLoop()
  end, {}, timer.getTime() + CFG.verifyInterval)
end

--=============================================================
-- Estado / Cancelar
--=============================================================
local function missionStatus()
  if not STATE.active then
    say("No hay mision activa.", 6)
    return
  end

  local M = STATE.active
  local delivered = processDeliveredCargo()

  say(
    "ESTADO MISION\n"..
    M.nombre.."\n"..
    "Pickup: "..tostring(M.pickupAirbase).." ("..tostring(M.pickupZone)..")\n"..
    "Drop:   "..tostring(M.dropAirbase).." ("..tostring(M.dropZone)..")\n"..
    "Tipo:   "..tostring(M.cargoTemplateName).."\n"..
    "Progreso: "..tostring(delivered).."/"..tostring(M.required).."\n"..
    "Condicion: cuenta solo si AGL <= "..tostring(CFG.maxAGLForCount),
    10
  )
end

local function cancelMission()
  if not STATE.active then
    say("No hay mision activa.", 6)
    return
  end
  say("Mision cancelada: "..tostring(STATE.active.nombre), 6)
  STATE.active = nil
end

--=============================================================
-- Menu F10
--=============================================================
local MENU = { root=nil }

local function buildMenu()
  MENU.root = missionCommands.addSubMenu(CFG.menuRootName)

  missionCommands.addCommand("Crear mision aleatoria", MENU.root, startRandomMission)
  missionCommands.addCommand("Estado de la mision", MENU.root, missionStatus)
  missionCommands.addCommand("Cancelar mision", MENU.root, cancelMission)
end

--=============================================================
-- Diagnostico
--=============================================================
local function diagnostico()
  local lines = {}
  lines[#lines+1] = "Diagnostico:"
  lines[#lines+1] = "- MIST: "..tostring(mist ~= nil)

  local pCount = #getZonasByTipo("pickup")
  local dCount = #getZonasByTipo("drop")
  lines[#lines+1] = "- Zonas pickup: "..tostring(pCount)
  lines[#lines+1] = "- Zonas drop: "..tostring(dCount)

  local tCount = (CFG.cargoTemplates and #CFG.cargoTemplates) or 0
  lines[#lines+1] = "- Templates: "..tostring(tCount)
  if CFG.cargoTemplates and #CFG.cargoTemplates > 0 then
    for i,tname in ipairs(CFG.cargoTemplates) do
      local ex = (StaticObject.getByName(tname) ~= nil) or ((mist and mist.DBs and mist.DBs.staticsByName and mist.DBs.staticsByName[tname]) ~= nil)
      lines[#lines+1] = string.format("  Template %d: %s (existe=%s)", i, tostring(tname), tostring(ex))
    end
  end

  for i,z in ipairs(CFG.zonas or {}) do
    lines[#lines+1] = string.format("  Zona %d: %s tipo=%s (ME=%s)", i, tostring(z.name), tostring(z.tipo), tostring(getZonaME(z.name) ~= nil))
  end

  lines[#lines+1] = "- AGL para contar: "..tostring(CFG.maxAGLForCount)
  lines[#lines+1] = "- Destruir despues: "..tostring(CFG.destroyAfterDeliveredSeconds).."s"

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
