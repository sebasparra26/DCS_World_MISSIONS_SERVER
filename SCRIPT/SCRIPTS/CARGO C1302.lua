--=============================================================
-- C-130 Cargo Missions (MIST)
-- Mission Spawn + Briefing + Verify Delivery by Zone
--
-- Que hace:
-- 1) Menu F10 para crear misiones de carga.
-- 2) Al activar una mision:
--    - Spawnea X cajas (fijo o aleatorio) en la zona pickup.
--    - Muestra briefing (pickup, drop, cantidad).
--    - Pulso de bandera 5000 (ON y al segundo OFF).
-- 3) Verifica automaticamente:
--    - Cuenta cuantas de esas cajas estan dentro de la zona drop.
--    - Al completar:
--      - Pulso de bandera 5002 (ON y al segundo OFF).
--      - Mision finaliza.
--
-- Importante:
-- - Este script NO hace menu de cargar/descargar.
--   DCS / tu mod del C-130 lo hace.
-- - La verificacion funciona si las cajas existen como objetos
--   en el mundo y terminan dentro de la zona drop.
--
-- Orden recomendado de carga:
-- 1) MIST
-- 2) PersianGolf DB Aiports.lua (opcional pero recomendado)
-- 3) Este script
--=============================================================

local CFG = {
  debug = true,
  menuRootName = "C-130J Carga",

  --===========================================================
  -- PULSOS DE BANDERAS (para eventos conmutados)
  --===========================================================
  flagPulseStart = 5000,          -- al iniciar mision: ON -> OFF
  flagPulseComplete = 5002,       -- al completar: ON -> OFF
  flagPulseDuration = 1,          -- segundos

  -- Si quieres que el OFF de "complete" apague OTRO flag (ej 5003)
  -- ponlo aqui. Si es nil, apaga el mismo flag (5002).
  flagPulseCompleteOffOverride = nil, -- ejemplo: 5003

  --===========================================================
  -- ZONAS (backend editable)
  --===========================================================
  -- Si aeropuerto es nil, se intenta deducir usando tu DB "aeropuertos".
  zonas = {
    { name = "ZONECARGO1", tipo = "pickup", aeropuerto = "Liwa AFB" },
    { name = "ZONEDROP1",  tipo = "drop",   aeropuerto = "Al Ain Intl" },
  },

  --===========================================================
  -- MISIONES (rutas pickup -> drop)
  --===========================================================
  misiones = {
    {
      id = 1,
      nombre = "Ruta 1",
      pickupZone = "ZONECARGO1",
      dropZone   = "ZONEDROP1",

      -- Cantidad:
      -- random=true: elige entre min y max cada vez que creas mision
      -- random=false: usa fixed
      random = true,
      fixed  = 8,
      min    = 4,
      max    = 12,
    },
  },

  --===========================================================
  -- TEMPLATES DE CARGA (Static) - LISTA EDITABLE
  --===========================================================
  -- Agrega/quita nombres de Static templates del Mission Editor.
  -- Deben existir con ese nombre EXACTO.
  cargoTemplates = {
    "CARGO_TEMPLATE_01",
    -- "CARGO_TEMPLATE_02",
    -- "CARGO_TEMPLATE_03",
  },

  --===========================================================
  -- SPAWN (cajas dentro de zona pickup)
  --===========================================================
  cargoMinSep = 8,                -- separacion minima entre cajas (m)
  cargoMaxIntentosPunto = 60,      -- intentos para encontrar punto libre
  cargoMaxIntentosSpawn = 400,     -- limite global intentos spawn

  --===========================================================
  -- VERIFICACION de entrega
  --===========================================================
  verifyInterval = 10,            -- cada cuantos segundos revisa progreso
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
-- Zonas / Backend
--=============================================================
local function getZonaME(name)
  return trigger.misc.getZone(name)
end

local function findZonaCfg(name)
  for _,z in ipairs(CFG.zonas or {}) do
    if z.name == name then return z end
  end
  return nil
end

-- Deduccion por tu DB:
-- Debe existir tabla global: aeropuertos[Nombre].position = {x=, z=}
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

local function getRandomCargoTemplateName()
  if not CFG.cargoTemplates or #CFG.cargoTemplates == 0 then
    return nil
  end
  return CFG.cargoTemplates[math.random(1, #CFG.cargoTemplates)]
end

local function spawnCargoEnZona(missionId, zoneName, cantidad)
  local zone = getZonaME(zoneName)
  if not zone then
    err("Zona no encontrada: "..tostring(zoneName))
    return {}
  end

  if not CFG.cargoTemplates or #CFG.cargoTemplates == 0 then
    err("No hay cargoTemplates configurados.")
    say("ERROR: No hay templates de carga en CFG.cargoTemplates.", 12)
    return {}
  end

  local usados = {}
  local spawned = {}
  local spawnCount = 0
  local intentosGlobal = 0

  while spawnCount < cantidad and intentosGlobal < CFG.cargoMaxIntentosSpawn do
    intentosGlobal = intentosGlobal + 1

    local templateName = getRandomCargoTemplateName()
    if not templateName then
      err("No se pudo elegir template (lista vacia).")
      break
    end

    local tpl = getStaticTemplateData(templateName)
    if tpl then
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
    else
      err("Template static no encontrado o no accesible: "..tostring(templateName))
    end
  end

  info(string.format("Spawn cargo en %s: %d/%d", zoneName, #spawned, cantidad))
  return spawned
end

--=============================================================
-- Estado de mision
--=============================================================
local STATE = {
  active = nil
}

local function elegirCantidad(m)
  if m.random then
    local mn = tonumber(m.min) or 1
    local mx = tonumber(m.max) or mn
    if mx < mn then mx = mn end
    return math.random(mn, mx)
  end
  return tonumber(m.fixed) or 1
end

--=============================================================
-- Verificacion de entrega
--=============================================================
local function countCargoInsideZone(cargoNames, zoneName)
  local z = getZonaME(zoneName)
  if not z then return 0 end

  local count = 0
  for _,name in ipairs(cargoNames or {}) do
    local so = StaticObject.getByName(name)
    if so and so:isExist() then
      local p = so:getPoint()
      local d = dist2D({x=p.x,y=p.z}, {x=z.point.x,y=z.point.z})
      if d <= (z.radius or 0) then
        count = count + 1
      end
    end
  end
  return count
end

local function verifyLoop()
  if not STATE.active then
    return nil
  end

  local M = STATE.active
  local delivered = countCargoInsideZone(M.cargoNames, M.dropZone)

  if delivered >= M.required then
    say("MISION COMPLETADA: Entregaste "..tostring(delivered).."/"..tostring(M.required)..
        " cajas en "..tostring(M.dropAirbase).." ("..tostring(M.dropZone)..").", 12)

    -- Pulso: completada
    pulseFlag(CFG.flagPulseComplete, CFG.flagPulseCompleteOffOverride, CFG.flagPulseDuration)

    STATE.active = nil
    return nil
  end

  return timer.getTime() + CFG.verifyInterval
end

--=============================================================
-- Crear mision
--=============================================================
local function startMission(m)
  if STATE.active then
    say("Ya hay una mision activa. Finalizala antes de crear otra.", 8)
    return
  end

  local zp = getZonaME(m.pickupZone)
  local zd = getZonaME(m.dropZone)
  if not zp then say("ERROR: No existe pickupZone "..tostring(m.pickupZone), 10); return end
  if not zd then say("ERROR: No existe dropZone "..tostring(m.dropZone), 10); return end

  local pickCfg = findZonaCfg(m.pickupZone)
  local dropCfg = findZonaCfg(m.dropZone)

  local pickAir = (pickCfg and pickCfg.aeropuerto) or deducirAeropuertoPorCercania(zp.point) or "DESCONOCIDO"
  local dropAir = (dropCfg and dropCfg.aeropuerto) or deducirAeropuertoPorCercania(zd.point) or "DESCONOCIDO"

  local required = elegirCantidad(m)
  local cargoNames = spawnCargoEnZona(m.id, m.pickupZone, required)
  if #cargoNames == 0 then
    say("No se pudo spawnear carga. Revisa templates/zona.", 10)
    return
  end

  STATE.active = {
    id = m.id,
    nombre = m.nombre,
    pickupZone = m.pickupZone,
    dropZone = m.dropZone,
    pickupAirbase = pickAir,
    dropAirbase = dropAir,
    required = required,
    cargoNames = cargoNames
  }

  -- Pulso: inicio
  pulseFlag(CFG.flagPulseStart, nil, CFG.flagPulseDuration)

  -- Briefing
  say(
    "MISION DE CARGA INICIADA\n"..
    "Recogida: "..tostring(pickAir).." ("..tostring(m.pickupZone)..")\n"..
    "Entrega:  "..tostring(dropAir).." ("..tostring(m.dropZone)..")\n"..
    "Cajas requeridas: "..tostring(required).."\n"..
    "Estado: 0/"..tostring(required).." entregadas.",
    14
  )

  -- Inicia verificacion
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
  local delivered = countCargoInsideZone(M.cargoNames, M.dropZone)
  say(
    "ESTADO MISION\n"..
    M.nombre.."\n"..
    "Entrega: "..tostring(M.dropAirbase).." ("..tostring(M.dropZone)..")\n"..
    "Progreso: "..tostring(delivered).."/"..tostring(M.required).." cajas entregadas.",
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
local MENU = { root=nil, missions=nil }

local function buildMenu()
  MENU.root = missionCommands.addSubMenu(CFG.menuRootName)
  MENU.missions = missionCommands.addSubMenu("Crear Mision", MENU.root)

  for _,m in ipairs(CFG.misiones or {}) do
    missionCommands.addCommand(
      string.format("%s (Pickup %s -> Drop %s)", m.nombre, m.pickupZone, m.dropZone),
      MENU.missions,
      function() startMission(m) end
    )
  end

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
  lines[#lines+1] = "- Templates configurados: "..tostring(CFG.cargoTemplates and #CFG.cargoTemplates or 0)

  if CFG.cargoTemplates and #CFG.cargoTemplates > 0 then
    for i,tname in ipairs(CFG.cargoTemplates) do
      local ex = (StaticObject.getByName(tname) ~= nil)
      lines[#lines+1] = string.format("  Template %d: %s (existe=%s)", i, tostring(tname), tostring(ex))
    end
  end

  for i,z in ipairs(CFG.zonas or {}) do
    lines[#lines+1] = string.format("  Zona %d: %s (ME=%s)", i, tostring(z.name), tostring(getZonaME(z.name) ~= nil))
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
