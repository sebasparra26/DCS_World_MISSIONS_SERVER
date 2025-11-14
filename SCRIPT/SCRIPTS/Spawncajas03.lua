--=============================================================
-- Spawn de Cajas (Cargo) por Probabilidades en MÚLTIPLES ZONAS
-- Soporta lados BLUE/RED con templates separados
--=============================================================

local CFG = {
  -- Zonas: puedes pasar solo el nombre ("cajas") o una tabla con más control.
  -- Campos válidos por zona: name (obligatorio), side ("blue"/"red"), cantidad (override).
  zonas = {
    { name = "cajasB",      side = "blue", cantidad = 250 },
    { name = "cajasR", side = "red",  cantidad = 0 },
    -- "otra_zona",  -- también vale un string; usa side="blue" y cantidad global
  },

  -- Cantidad por defecto si la zona no trae "cantidad"
  cantidadCajasDefault   = 12,

  -- Separación mínima entre cajas en la MISMA zona
  minSeparacion          = 8,
  maxIntentosPunto       = 60,
  maxIntentosSpawn       = 500,

  headingAleatorio       = true,
  debug                  = true,
  mostrarEnPantalla      = true,

  -- Prefijo base (se le agrega el lado y un índice)
  nombrePrefijo          = "CajaSpawn_",

  -- País forzado opcional por lado (si lo dejas nil, toma el del template/StaticObject)
  forceCountryIdBlue     = nil,          -- p.ej. country.USA
  forceCountryIdRed      = nil,          -- p.ej. country.RUSSIA

  -- Templates por lado, cada uno con su probabilidad (0..1 o 0..100)
  templates = {
    blue = {

      -- AVIONES -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      --A10C Tank Killer - COLD WAR
      { name = "A10-Template-01-B", prob = 0.4 },
      { name = "A10-Template-02-B", prob = 0.2 },
      { name = "A10C-Template-03-B", prob = 0.1 },

      --A10CII Tank Killer - MODERN
      { name = "A10II-Template-01-B", prob = 0.4 },
      { name = "A10II-Template-02-B", prob = 0.2 },
      { name = "A10II-Template-03-B", prob = 0.1 },
      
      --A4EC SKYHAWK
      { name = "A4EC-Template-01-B", prob = 0.4 },
      { name = "A4EC-Template-02-B", prob = 0.2 },
      { name = "A4EC-Template-03-B", prob = 0.1 },

      --ASJ37 VIGGEN
      { name = "AJS37-Template-01-B", prob = 0.4 },
      { name = "AJS37-Template-02-B", prob = 0.2 },
      { name = "AJS37-Template-03-B", prob = 0.1 },

      --AV8B HARRIER
      { name = "AV8B-Template-01-B", prob = 0.4 },
      { name = "AV8B-Template-02-B", prob = 0.2 },
      { name = "AV8B-Template-03-B", prob = 0.1 },

      --F14A-135GR TOMCAT
      { name = "F14A-135GR-Template-01-B", prob = 0.4 },
      { name = "F14A-135GR-Template-02-B", prob = 0.2 },
      { name = "F14A-135GR-Template-03-B", prob = 0.1 },
       --F14A-135GR EARLY TOMCAT
      { name = "F14A-135GR-EARLY-Template-01-B", prob = 0.4 },
      { name = "F14A-135GR-EARLY-Template-02-B", prob = 0.2 },
      { name = "F14A-135GR-EARLY-Template-03-B", prob = 0.1 },
        --F14B TOMCAT
      { name = "F14B-Template-01-B", prob = 0.4 },
      { name = "F14B-Template-02-B", prob = 0.2 },
      { name = "F14B-Template-03-B", prob = 0.1 },

              --F15C FC
      { name = "F15C-Template-01-B", prob = 0.4 },
      { name = "F15C-Template-02-B", prob = 0.2 },
      { name = "F15C-Template-03-B", prob = 0.1 },
    },
    red = {
      { name = "CajaR_Template_1", prob = 0.40 },
      { name = "CajaR_Template_2", prob = 0.35 },
      { name = "CajaR_Template_3", prob = 0.25 },
    }
  }
}

 --red = {
    --  { name = "CajaR_Template_1", prob = 0.40 },
   --   { name = "CajaR_Template_2", prob = 0.35 },
    --  { name = "CajaR_Template_3", prob = 0.25 },
   -- }
--=============================================================
-- Utilidades
--=============================================================
local function say(txt, dur) if CFG.mostrarEnPantalla then trigger.action.outText("[Cajas] "..tostring(txt), dur or 6) end end
local function info(msg) if CFG.debug then env.info("[CajasSpawn] "..tostring(msg)) end end
local function warn(msg) env.info("[CajasSpawn][WARN] "..tostring(msg)) end
local function err(msg)  env.info("[CajasSpawn][ERROR] "..tostring(msg)) end

local function mistLoaded() return (mist ~= nil) end
local function mistDBReady() return (mist and mist.DBs and mist.DBs.staticsByName) ~= nil end

-- Normaliza prob a 0..1 (acepta porcentajes)
local function normalizeProb(p)
  if type(p) ~= "number" or p < 0 then return 0 end
  if p > 1.0000001 then return p / 100.0 end
  return p
end

-- Construye ruleta (acumulada) a partir de lista de templates
local function prepararRuleta(templates)
  local items, suma = {}, 0
  for _, t in ipairs(templates or {}) do
    local p = normalizeProb(t.prob)
    table.insert(items, { name = t.name, p = p })
    suma = suma + p
  end
  if #items == 0 then return nil, "No hay templates definidos para este lado." end
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

-- Distancia 2D (x,y horizontales)
local function dist2D(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  return math.sqrt(dx*dx + dy*dy)
end

-- Punto aleatorio en círculo (usa MIST si está; si no, alternativa propia)
local function randPointInCircle(center, radius)
  if mistLoaded() and mist.getRandPointInCircle then
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
-- Lectura de template (MIST si está; si no, StaticObject)
--=============================================================
local function getStaticTemplateData(staticName)
  if mistDBReady() then
    local data = mist.DBs.staticsByName[staticName]
    if data then
      return (mist.utils and mist.utils.deepCopy) and mist.utils.deepCopy(data) or data
    end
  end
  local so = StaticObject.getByName(staticName)
  if so then
    local desc  = so:getDesc() or {}
    local tName = so:getTypeName()
    local ctry  = so:getCountry() or country.USA
    return {
      type       = tName,
      country    = ctry,
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

-- Country por lado (override > template > fallback)
local function countryIdFromTemplate(tpl, side)
  if side == "red"  and CFG.forceCountryIdRed  then return CFG.forceCountryIdRed  end
  if side == "blue" and CFG.forceCountryIdBlue then return CFG.forceCountryIdBlue end
  if tpl and tpl.country and type(tpl.country) == "number" then return tpl.country end
  return (side == "red") and country.RUSSIA or country.USA
end

-- Nombre único
local function nombreUnico(base, side, zoneName, idx)
  return string.format("%s%s_%s_%03d_%d", base, side or "blue", zoneName or "Z", idx, timer.getTime())
end

-- Tabla final para coalition.addStaticObject
local function buildStaticFromTemplate(tpl, point, newName, headingRandom)
  return {
    name       = newName,
    type       = tpl.type,
    x          = point.x,
    y          = point.y,
    heading    = headingRandom and (math.random() * 2 * math.pi) or (tpl.heading or 0),
    category   = "Cargo",
    canCargo   = true,
    shape_name = tpl.shape_name,
    mass       = tpl.mass,
    rate       = tpl.rate,
    dead       = tpl.dead,
  }
end

--=============================================================
-- Spawn por zona + lado
--=============================================================
local function templatesForSide(side)
  side = (side or "blue"):lower()
  if side ~= "red" then side = "blue" end
  return CFG.templates[side], side
end

local function spawnEnZona(z)
  -- normaliza estructura de zona
  local zoneName, side, cantidad
  if type(z) == "string" then
    zoneName = z
    side     = "blue"
    cantidad = CFG.cantidadCajasDefault
  else
    zoneName = z.name
    side     = (z.side or "blue"):lower()
    if side ~= "red" then side = "blue" end
    cantidad = z.cantidad or CFG.cantidadCajasDefault
  end

  local zone = trigger.misc.getZone(zoneName)
  if not zone then
    err("Zona no encontrada: "..tostring(zoneName))
    say("ERROR: No existe la zona '"..tostring(zoneName).."'.", 8)
    return
  end

  local templates, sideNorm = templatesForSide(side)
  local ruleta, e = prepararRuleta(templates)
  if not ruleta then
    local msg = "ERROR ("..zoneName.."/"..sideNorm.."): "..tostring(e)
    err(msg); say(msg, 8)
    return
  end

  -- Validación de accesibilidad de cada template
  local faltan = {}
  for _, t in ipairs(templates) do
    local okDB = mistDBReady() and mist.DBs.staticsByName[t.name]
    local okSO = StaticObject.getByName(t.name)
    if not okDB and not okSO then table.insert(faltan, t.name) end
  end
  if #faltan > 0 then
    local msg = string.format("ERROR templates (%s/%s):\n- %s", zoneName, sideNorm, table.concat(faltan, "\n- "))
    err(msg); say(msg, 10)
    return
  end

  say(string.format("Spawneando %d cajas %s en '%s'...", cantidad, sideNorm, zoneName), 5)
  info(string.format("Inicio zona '%s' side=%s cantidad=%d", zoneName, sideNorm, cantidad))

  local usados, spawnCount, intentosGlobal = {}, 0, 0
  while spawnCount < cantidad and intentosGlobal < CFG.maxIntentosSpawn do
    intentosGlobal = intentosGlobal + 1

    local chosenTemplate = elegirTemplate(ruleta)
    local p = getPuntoLibreEnZona(zone, usados, CFG.minSeparacion, CFG.maxIntentosPunto)
    if not p then
      warn(string.format("(%s/%s) sin punto libre (intento=%d)", zoneName, sideNorm, intentosGlobal))
    else
      local tpl   = getStaticTemplateData(chosenTemplate)
      if not tpl then
        warn(string.format("(%s/%s) template inaccesible: %s", zoneName, sideNorm, tostring(chosenTemplate)))
      else
        local newName = nombreUnico(CFG.nombrePrefijo, sideNorm, zoneName, spawnCount + 1)
        local objTbl  = buildStaticFromTemplate(tpl, p, newName, CFG.headingAleatorio)
        local ctryId  = countryIdFromTemplate(tpl, sideNorm)

        local ok = coalition.addStaticObject(ctryId, objTbl)
        if ok then
          info(string.format("OK %s '%s' en (%.1f, %.1f) tpl='%s' ctry=%s", sideNorm, newName, p.x, p.y, chosenTemplate, tostring(ctryId)))
          table.insert(usados, { x = p.x, y = p.y })
          spawnCount = spawnCount + 1
        else
          warn(string.format("Fallo addStaticObject %s '%s' (tpl=%s)", sideNorm, newName, chosenTemplate))
        end
      end
    end
  end

  if spawnCount < cantidad then
    local msg = string.format("Spawn incompleto en '%s' (%s): %d/%d", zoneName, sideNorm, spawnCount, cantidad)
    warn(msg); say(msg, 8)
  else
    local msg = string.format("Spawn COMPLETO en '%s' (%s): %d/%d", zoneName, sideNorm, spawnCount, cantidad)
    info(msg); say(msg, 6)
  end
end

--=============================================================
-- Diagnóstico & Arranque
--=============================================================
local function diagnostico()
  local lines = {}
  table.insert(lines, "Diagnóstico:")
  table.insert(lines, "- Zonas configuradas: "..tostring(#CFG.zonas))
  for i, z in ipairs(CFG.zonas) do
    local zn = (type(z)=="string") and z or z.name
    local sd = (type(z)=="string") and "blue" or (z.side or "blue")
    local cz = (type(z)=="string") and CFG.cantidadCajasDefault or (z.cantidad or CFG.cantidadCajasDefault)
    local ex = trigger.misc.getZone(zn) and "OK" or "NO"
    table.insert(lines, string.format("  %d) %s  side=%s  cantidad=%d  zona=%s", i, zn, sd, cz, ex))
  end
  table.insert(lines, "- MIST cargado: "..tostring(mistLoaded()))
  table.insert(lines, "- MIST tabla lista: "..tostring(mistDBReady()))

  local function mk(tlist)
    local s = {}
    for _, t in ipairs(tlist or {}) do table.insert(s, t.name.."("..tostring(t.prob)..")") end
    return table.concat(s, ", ")
  end
  table.insert(lines, "- Templates BLUE: "..mk(CFG.templates.blue))
  table.insert(lines, "- Templates RED : "..mk(CFG.templates.red))

  local txt = table.concat(lines, "\n")
  info(txt); say(txt, 10)
end

local function start()
  diagnostico()
  for _, z in ipairs(CFG.zonas) do
    spawnEnZona(z)
  end
end

-- Arranca después de unos segundos (por si el mapa tarda en levantar objetos)
timer.scheduleFunction(function() start() end, {}, timer.getTime() + 3)
