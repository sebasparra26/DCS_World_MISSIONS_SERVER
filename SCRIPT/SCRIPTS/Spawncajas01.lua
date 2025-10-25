--=============================================================
-- Spawn de Cajas por Probabilidades en zona "cajas"
-- Final: categoría "Cargo", sin errores de randomseed ni DB
--=============================================================

local CFG = {
  zonaObjetivo          = "cajas",   -- nombre de la zona en el ME
  cantidadCajas         = 250,        -- cuántas cajas crear
  minSeparacion         = 4,         -- metros mínimos entre cajas
  maxIntentosPunto      = 60,
  maxIntentosSpawn      = 500,
  headingAleatorio      = true,
  debug                 = true,
  mostrarEnPantalla     = true,
  segundosPrimerIntento = 4,
  reintentosMIST        = 10,
  intervaloReintento    = 2,
  forceCountryId        = nil,       -- p.ej. country.USA

  -- Probabilidades por template (0..1 o 0..100)
  templates = {
    { name = "CajaTemplate_1", prob = 0.50 },
    { name = "CajaTemplate_2", prob = 0.30 },
    { name = "CajaTemplate_3", prob = 0.20 },
  },

  nombrePrefijo = "CajaSpawn_"
}

--============================================
-- Utilidades
--============================================
local function say(txt, dur) if CFG.mostrarEnPantalla then trigger.action.outText("[Cajas] "..tostring(txt), dur or 7) end end
local function info(msg) if CFG.debug then env.info("[CajasSpawn] "..tostring(msg)) end end
local function warn(msg) env.info("[CajasSpawn][WARN] "..tostring(msg)) end
local function err(msg)  env.info("[CajasSpawn][ERROR] "..tostring(msg)) end

local function mistLoaded() return (mist ~= nil) end
local function mistDBReady()
  return (mist and mist.DBs and mist.DBs.staticsByName) ~= nil
end

--============================================
-- Probabilidades
--============================================
local function normalizeProb(p)
  if type(p) ~= "number" or p < 0 then return 0 end
  if p > 1.0000001 then return p / 100.0 end
  return p
end

local function prepararRuleta(templates)
  local items, suma = {}, 0
  for _, t in ipairs(templates) do
    local p = normalizeProb(t.prob)
    table.insert(items, { name = t.name, p = p })
    suma = suma + p
  end
  if #items == 0 then return nil, "No hay templates definidos." end
  if suma <= 0 then
    local eq = 1 / #items
    for i=1,#items do items[i].p = eq end
  else
    for i=1,#items do items[i].p = items[i].p / suma end
  end
  local ruleta, acum = {}, 0
  for _, it in ipairs(items) do
    acum = acum + it.p
    table.insert(ruleta, { name = it.name, p = acum })
  end
  ruleta[#ruleta].p = 1.0
  return ruleta
end

local function elegirTemplate(ruleta)
  local r = math.random()
  for _, slot in ipairs(ruleta) do
    if r <= slot.p then return slot.name end
  end
  return ruleta[#ruleta].name
end

--============================================
-- Posiciones
--============================================
local function dist2D(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  return math.sqrt(dx*dx + dy*dy)
end

local function getPuntoLibreEnZona(zone, usados, minSep, maxIntentos)
  for _=1, maxIntentos do
    local p
    if mistLoaded() and mist.getRandPointInCircle then
      p = mist.getRandPointInCircle(zone.point, zone.radius)
    else
      local ang = math.random() * 2 * math.pi
      local rad = zone.radius * math.sqrt(math.random())
      p = { x = zone.point.x + rad * math.cos(ang), y = zone.point.y + rad * math.sin(ang) }
    end
    local ok = true
    for _, u in ipairs(usados) do
      if dist2D(p, u) < minSep then ok = false; break end
    end
    if ok then return p end
  end
  return nil
end

--============================================
-- Templates y Spawn
--============================================
local function getStaticTemplateData(staticName)
  if mistDBReady() then
    local data = mist.DBs.staticsByName[staticName]
    if data then
      return (mist.utils and mist.utils.deepCopy) and mist.utils.deepCopy(data) or data
    end
  end
  local so = StaticObject.getByName(staticName)
  if so then
    local desc = so:getDesc() or {}
    local tName = so:getTypeName()
    local ctry  = so:getCountry() or country.USA
    return {
      type       = tName,
      country    = ctry,
      category   = "Cargo",      -- ← ahora siempre se crea como cargo
      canCargo   = true,         -- puede ser cargado por CTLD o logística
      shape_name = desc.shape_name,
      mass       = desc.mass,
      rate       = desc.rate,
      dead       = false,
      heading    = 0
    }
  end
  return nil
end

local function countryIdFromTemplate(tpl)
  if CFG.forceCountryId then return CFG.forceCountryId end
  if tpl and tpl.country and type(tpl.country) == "number" then return tpl.country end
  return country.USA
end

local function nombreUnico(base, idx)
  return string.format("%s%03d_%d", base, idx, timer.getTime())
end

local function buildStaticFromTemplate(tpl, point, newName, headingRandom)
  return {
    name       = newName,
    type       = tpl.type,
    x          = point.x,
    y          = point.y,
    heading    = headingRandom and (math.random() * 2 * math.pi) or (tpl.heading or 0),
    category   = "Cargo",      -- aseguramos categoría cargo
    canCargo   = true,
    shape_name = tpl.shape_name,
    mass       = tpl.mass,
    rate       = tpl.rate,
    dead       = tpl.dead,
  }
end

local function spawnStaticFromTemplateName(templateName, point, idx)
  local tpl = getStaticTemplateData(templateName)
  if not tpl then
    warn("Template no accesible: "..tostring(templateName))
    return false, "template_not_found"
  end
  local newName = nombreUnico(CFG.nombrePrefijo, idx)
  local objTbl  = buildStaticFromTemplate(tpl, point, newName, CFG.headingAleatorio)
  local ctryId  = countryIdFromTemplate(tpl)
  local ok = coalition.addStaticObject(ctryId, objTbl)
  if ok then
    info(string.format("Spawn OK '%s' (type=%s, ctry=%s) en (%.1f, %.1f) usando '%s'",
      newName, tostring(objTbl.type), tostring(ctryId), point.x, point.y, templateName))
    return true, newName
  else
    warn("Falló addStaticObject: "..newName.." (type="..tostring(objTbl.type)..")")
    return false, "add_failed"
  end
end

--============================================
-- Diagnóstico y ejecución
--============================================
local function diagnosticoInicial()
  local msgs = {}
  table.insert(msgs, "Diagnóstico inicial:")
  table.insert(msgs, "- MIST cargado: "..tostring(mistLoaded()))
  table.insert(msgs, "- MIST tabla lista: "..tostring(mistDBReady()))
  local zone = trigger.misc.getZone(CFG.zonaObjetivo)
  if not zone then
    table.insert(msgs, "- Zona '"..CFG.zonaObjetivo.."' NO encontrada.")
  else
    table.insert(msgs, string.format("- Zona '%s' OK (r=%.1f, x=%.1f, y=%.1f).",
      CFG.zonaObjetivo, zone.radius, zone.point.x, zone.point.y))
  end
  table.insert(msgs, "- Templates:")
  for _, t in ipairs(CFG.templates) do
    local estado = "NO ENCONTRADO"
    if mistDBReady() and mist.DBs.staticsByName[t.name] then
      estado = "ENCONTRADO en MIST"
    else
      local so = StaticObject.getByName(t.name)
      if so then estado = "ENCONTRADO como StaticObject" end
    end
    table.insert(msgs, string.format("  * %s : %s (prob=%s)", t.name, estado, tostring(t.prob)))
  end
  local txt = table.concat(msgs, "\n")
  info(txt)
  say(txt, 12)
end

local function spawnCajasEnZona()
  local zone = trigger.misc.getZone(CFG.zonaObjetivo)
  if not zone then
    err("Zona no encontrada: "..tostring(CFG.zonaObjetivo))
    say("ERROR: No existe la zona '"..tostring(CFG.zonaObjetivo).."'.", 10)
    return
  end

  local ruleta, e = prepararRuleta(CFG.templates)
  if not ruleta then say("ERROR: "..tostring(e), 10); err(e); return end

  say(string.format("Spawneando %d cajas en '%s'...", CFG.cantidadCajas, CFG.zonaObjetivo), 6)
  info("Iniciando spawn de cajas: "..CFG.cantidadCajas)

  local usados, spawnCount, intentosGlobal = {}, 0, 0
  while spawnCount < CFG.cantidadCajas and intentosGlobal < CFG.maxIntentosSpawn do
    intentosGlobal = intentosGlobal + 1
    local chosenTemplate = elegirTemplate(ruleta)
    local punto = getPuntoLibreEnZona(zone, usados, CFG.minSeparacion, CFG.maxIntentosPunto)
    if not punto then
      warn("No encontré punto libre (iteración "..intentosGlobal..")")
    else
      local ok = select(1, spawnStaticFromTemplateName(chosenTemplate, punto, spawnCount + 1))
      if ok then
        table.insert(usados, { x = punto.x, y = punto.y })
        spawnCount = spawnCount + 1
      end
    end
  end

  if spawnCount < CFG.cantidadCajas then
    local msg = string.format("Spawn incompleto: %d/%d. Revisa radio de zona o minSeparacion.",
      spawnCount, CFG.cantidadCajas)
    warn(msg); say(msg, 10)
  else
    local msg = string.format("Spawn COMPLETO: %d/%d en zona '%s'.", spawnCount, CFG.cantidadCajas, CFG.zonaObjetivo)
    info(msg); say(msg, 8)
  end
end

local function startWhenReady(attempt)
  attempt = attempt or 1
  diagnosticoInicial()
  spawnCajasEnZona()
end

timer.scheduleFunction(function() startWhenReady(1) end, {}, timer.getTime() + CFG.segundosPrimerIntento)
