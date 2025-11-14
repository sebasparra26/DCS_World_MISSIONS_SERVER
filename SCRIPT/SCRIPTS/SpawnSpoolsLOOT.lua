--=============================================================
-- Spawn de Cajas (Cargo) por Probabilidades en MÚLTIPLES ZONAS
-- Soporta lados BLUE/RED con templates separados
--=============================================================

local CFG = {
  --================== NUEVO: Selección de categorías ==================
  -- Activa/desactiva categorías que participarán en el sorteo de templates.
  -- Puedes poner true/false por categoría.
  categoriasUsadas = {
    modern   = true,
    coldwar  = true,
    warbirds = true,
    armas    = false,  -- por ahora no hay templates en esta categoría
    fc = true,
  },

  -- ON/OFF exclusivo para la categoría de helicópteros (independiente de arriba)
  helisOn = true,
  --====================================================================

  -- Zonas: puedes pasar solo el nombre ("cajas") o una tabla con más control.
  -- Campos válidos por zona: name (obligatorio), side ("blue"/"red"), cantidad (override).
  zonas = {
    { name = "cajasB", side = "blue", cantidad = 250 },
    --{ name = "cajasR", side = "red",  cantidad = 0   },
    -- "otra_zona",
  },

  -- Cantidad por defecto si la zona no trae "cantidad"
  cantidadCajasDefault   = 0,

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
  -- ================== IMPORTANTE: ahora cada template tiene "cats" ==================
  -- "cats" es una lista de categorías asignadas a ese template.
  -- Categorías válidas: "modern", "coldwar", "warbirds", "armas", "helis"
  templates = {
    blue = {

      -- AVIONES ------------------------------------------------------------------
      -- A-10C (bloque/avión legado estilo Cold War tardío / transición)
      { name = "A10C-Template-01-B",  prob = 0.4, cats = {"coldwar"} },
      { name = "A10C-Template-02-B",  prob = 0.2, cats = {"coldwar"} },
      { name = "A10C-Template-03-B", prob = 0.1, cats = {"coldwar"} },

      -- A-10C II (MODERN)
      { name = "A10II-Template-01-B", prob = 0.4, cats = {"modern"} },
      { name = "A10II-Template-02-B", prob = 0.2, cats = {"modern"} },
      { name = "A10II-Template-03-B", prob = 0.1, cats = {"modern"} },

      -- A-4E-C SKYHAWK (COLD WAR)
      { name = "A4EC-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "A4EC-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "A4EC-Template-03-B", prob = 0.1, cats = {"coldwar"} },

      -- AJS37 VIGGEN (COLD WAR)
      { name = "AJS37-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "AJS37-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "AJS37-Template-03-B", prob = 0.1, cats = {"coldwar"} },

      -- AV-8B HARRIER (MODERN)
      { name = "AV8B-Template-01-B", prob = 0.4, cats = {"modern"} },
      { name = "AV8B-Template-02-B", prob = 0.2, cats = {"modern"} },
      { name = "AV8B-Template-03-B", prob = 0.1, cats = {"modern"} },

      -- F-14A (COLD WAR)
      { name = "F14A-135GR-Template-01-B",  prob = 0.4, cats = {"modern"} },
      { name = "F14A-135GR-Template-02-B",  prob = 0.2, cats = {"modern"} },
      { name = "F14A-135GR-Template-03-B",  prob = 0.1, cats = {"modern"} },

      -- F-14A EARLY (COLD WAR)
      { name = "F14A-135GR-EARLY-Template-01-B", prob = 0.4, cats = {"modern"} },
      { name = "F14A-135GR-EARLY-Template-02-B", prob = 0.2, cats = {"modern"} },
      { name = "F14A-135GR-EARLY-Template-03-B", prob = 0.1, cats = {"modern"} },

      -- F-14B (COLD WAR / transición)
      { name = "F14B-Template-01-B", prob = 0.4, cats = {"modern"} },
      { name = "F14B-Template-02-B", prob = 0.2, cats = {"modern"} },
      { name = "F14B-Template-03-B", prob = 0.1, cats = {"modern"} },

      -- F-15C FC (COLD WAR tardío / 90s)
      { name = "F15C-Template-01-B", prob = 0.4, cats = {"modern","fc"} },
      { name = "F15C-Template-02-B", prob = 0.2, cats = {"modern","fc"} },
      { name = "F15C-Template-03-B", prob = 0.1, cats = {"modern","fc"} },

      -- F-15E EAGLE STRIKE (MODERN)
      { name = "F15E-Template-01-B", prob = 0.4, cats = {"modern"} },
      { name = "F15E-Template-02-B", prob = 0.2, cats = {"modern"} },
      { name = "F15E-Template-03-B", prob = 0.1, cats = {"modern"} },

      -- F-16CM VIPER (MODERN)
      { name = "F16CM-Template-01-B", prob = 0.4, cats = {"modern"} },
      { name = "F16CM-Template-02-B", prob = 0.2, cats = {"modern"} },
      { name = "F16CM-Template-03-B", prob = 0.1, cats = {"modern"} },

      -- F-4E PHANTOM (COLD WAR)
      { name = "F4E-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "F4E-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "F4E-Template-03-B", prob = 0.1, cats = {"coldwar"} },

       -- F5E TIGER 2 (COLD WAR)
      { name = "F5E-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "F5E-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "F5E-Template-03-B", prob = 0.1, cats = {"coldwar"} },

      -- F5E  TIGER 2 FC (COLD WAR)
      { name = "F5E-FC-Template-01-B", prob = 0.4, cats = {"coldwar","fc"} },
      { name = "F5E-FC-Template-02-B", prob = 0.2, cats = {"coldwar","fc"} },
      { name = "F5E-FC-Template-03-B", prob = 0.1, cats = {"coldwar","fc"} },

       -- F86F (COLD WAR)
      { name = "F86F-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "F86F-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "F86F-Template-03-B", prob = 0.1, cats = {"coldwar"} },

      -- F86F FC  TIGER 2 FC (COLD WAR)
      { name = "F86F-FC-Template-01-B", prob = 0.4, cats = {"coldwar","fc"} },
      { name = "F86F-FC-Template-02-B", prob = 0.2, cats = {"coldwar","fc"} },
      { name = "F86F-FC-Template-03-B", prob = 0.1, cats = {"coldwar","fc"} },

      -- F18C HORNET (MODERN)
      { name = "F18C-Template-01-B", prob = 0.4, cats = {"modern"} },
      { name = "F18C-Template-02-B", prob = 0.2, cats = {"modern"} },
      { name = "F18C-Template-03-B", prob = 0.1, cats = {"modern"} },

      -- JF17 THUNDER (MODERN)
      { name = "JF17-Template-01-B", prob = 0.4, cats = {"modern"} },
      { name = "JF17-Template-02-B", prob = 0.2, cats = {"modern"} },
      { name = "JF17-Template-03-B", prob = 0.1, cats = {"modern"} },

        -- J11A  (MODERN)
      { name = "J11A-Template-01-B", prob = 0.4, cats = {"modern","fc"} },
      { name = "J11A-Template-02-B", prob = 0.2, cats = {"modern","fc"} },
      { name = "J11A-Template-03-B", prob = 0.1, cats = {"modern","fc"} },

        -- M2000  (MODERN)
      { name = "M2000-Template-01-B", prob = 0.4, cats = {"modern"} },
      { name = "M2000-Template-02-B", prob = 0.2, cats = {"modern"} },
      { name = "M2000-Template-03-B", prob = 0.1, cats = {"modern"} },

         -- Mig15 (COLD WAR)
      { name = "MIG15-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "MIG15-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "MIG15-Template-03-B", prob = 0.1, cats = {"coldwar"} },

         -- Mig15 FC (COLD WAR)
      { name = "MIG15-FC-Template-01-B", prob = 0.4, cats = {"coldwar","fc"} },
      { name = "MIG15-FC-Template-02-B", prob = 0.2, cats = {"coldwar","fc"} },
      { name = "MIG15-FC-Template-03-B", prob = 0.1, cats = {"coldwar","fc"} },

         -- Mig19 (COLD WAR)
      { name = "MIG19-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "MIG19-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "MIG19-Template-03-B", prob = 0.1, cats = {"coldwar"} },

            -- Mig21 (COLD WAR)
      { name = "MIG21-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "MIG21-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "MIG21-Template-03-B", prob = 0.1, cats = {"coldwar"} },

            -- Mig29A FULCRUM (MODERN)
      { name = "MIG29A-Template-01-B", prob = 0.4, cats = {"modern"} },
      { name = "MIG29A-Template-02-B", prob = 0.2, cats = {"modern"} },
      { name = "MIG29A-Template-03-B", prob = 0.1, cats = {"modern"} },

            -- Mig29A FC (MODERN)
      { name = "MIG29A-FC-Template-01-B", prob = 0.4, cats = {"modern","fc"} },
      { name = "MIG29A-FC-Template-02-B", prob = 0.2, cats = {"modern","fc"} },
      { name = "MIG29A-FC-Template-03-B", prob = 0.1, cats = {"modern","fc"} },

            -- Mig29S FC (MODERN)
      { name = "MIG29S-FC-Template-01-B", prob = 0.4, cats = {"modern","fc"} },
      { name = "MIG29S-FC-Template-02-B", prob = 0.2, cats = {"modern","fc"} },
      { name = "MIG29S-FC-Template-03-B", prob = 0.1, cats = {"modern","fc"} },

            -- F1  (COLD WAR)
      { name = "F1BE-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "F1BE-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "F1BE-Template-03-B", prob = 0.1, cats = {"coldwar"} },

      { name = "F1CE-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "F1CE-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "F1CE-Template-03-B", prob = 0.1, cats = {"coldwar"} },

      { name = "F1EE-Template-01-B", prob = 0.4, cats = {"coldwar"} },
      { name = "F1EE-Template-02-B", prob = 0.2, cats = {"coldwar"} },
      { name = "F1EE-Template-03-B", prob = 0.1, cats = {"coldwar"} },

            -- SU25T FC (MODERN)
      { name = "SU25T-FC-Template-01-B", prob = 0.4, cats = {"modern","fc"} },
      { name = "SU25T-FC-Template-02-B", prob = 0.2, cats = {"modern","fc"} },
      { name = "SU25T-FC-Template-03-B", prob = 0.1, cats = {"modern","fc"} },

             -- SU27 FC (MODERN)
      { name = "SU27-FC-Template-01-B", prob = 0.4, cats = {"modern","fc"} },
      { name = "SU27-FC-Template-02-B", prob = 0.2, cats = {"modern","fc"} },
      { name = "SU27-FC-Template-03-B", prob = 0.1, cats = {"modern","fc"} },

             -- SU33 FC (MODERN)
      { name = "SU33-FC-Template-01-B", prob = 0.4, cats = {"modern","fc"} },
      { name = "SU33-FC-Template-02-B", prob = 0.2, cats = {"modern","fc"} },
      { name = "SU33-FC-Template-03-B", prob = 0.1, cats = {"modern","fc"} },

      -- EJEMPLOS de estructura para helis (si luego agregas):
      -- { name = "UH1H-Template-01-B", prob = 0.4, cats = {"coldwar","helis"} },
      -- { name = "AH64D-Template-01-B", prob = 0.4, cats = {"modern","helis"} },

      -- EJEMPLO para "armas" (por ahora se pide vacío, aquí la forma):
      -- { name = "ARMAS_Caja_1_B", prob = 0.2, cats = {"armas"} },
    },

    red = {
      --{ name = "CajaR_Template_1", prob = 0.40, cats = {"modern"} },
     
      -- Ejemplos de helis rojos si luego sumas:
      -- { name = "Mi8-Template-01-R", prob = 0.4, cats = {"coldwar","helis"} },
      -- { name = "Ka50-Template-01-R", prob = 0.4, cats = {"modern","helis"} },
      -- Armas rojas (vacío por ahora):
      -- { name = "ARMAS_Caja_1_R", prob = 0.2, cats = {"armas"} },
    }
  }
}

--=============================================================
-- Utilidades
--=============================================================
local function say(txt, dur) if CFG.mostrarEnPantalla then trigger.action.outText("[Cajas] "..tostring(txt), dur or 6) end end
local function info(msg) if CFG.debug then env.info("[CajasSpawn] "..tostring(msg)) end end
local function warn(msg) env.info("[CajasSpawn][WARN] "..tostring(msg)) end
local function err(msg)  env.info("[CajasSpawn][ERROR] "..tostring(msg)) end

local function mistLoaded() return (mist ~= nil) end
local function mistDBReady() return (mist and mist.DBs and mist.DBs.staticsByName) ~= nil end

--================== NUEVO: helpers de categorías ==================
local function setFromCategorias()
  local s = {}
  for k,v in pairs(CFG.categoriasUsadas or {}) do if v then s[k] = true end end
  return s
end

local function templatePermitidoPorCategorias(t)
  -- Si no tiene cats definidas, lo dejamos pasar para no romper compatibilidad
  if not t.cats or #t.cats == 0 then return true end

  local act = setFromCategorias()
  -- Si helis está apagado y el template tiene "helis", se bloquea
  for _,c in ipairs(t.cats) do
    if c == "helis" and (CFG.helisOn == false) then
      return false
    end
  end
  -- Pasa si al menos una categoría del template está activa
  for _,c in ipairs(t.cats) do
    if act[c] then return true end
  end
  return false
end
--==================================================================

-- Normaliza prob a 0..1 (acepta porcentajes)
local function normalizeProb(p)
  if type(p) ~= "number" or p < 0 then return 0 end
  if p > 1.0000001 then return p / 100.0 end
  return p
end

-- Construye ruleta (acumulada) a partir de lista de templates (YA filtrados)
local function prepararRuleta(templates)
  local items, suma = {}, 0
  for _, t in ipairs(templates or {}) do
    --================== NUEVO: filtro por categorías ==================
    if templatePermitidoPorCategorias(t) then
      local p = normalizeProb(t.prob)
      table.insert(items, { name = t.name, p = p })
      suma = suma + p
    end
  end
  if #items == 0 then return nil, "No hay templates (tras filtrar por categorías) para este lado." end
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

  -- Validación de accesibilidad de cada template (sin filtrar, para avisar si faltan)
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

  --================== NUEVO: construir ruleta con filtrado por categorías ==================
  local ruleta, e = prepararRuleta(templates)
  if not ruleta then
    local msg = "ERROR ("..zoneName.."/"..sideNorm.."): "..tostring(e)
    err(msg); say(msg, 8)
    return
  end
  --========================================================================================

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
    for _, t in ipairs(tlist or {}) do
      local cats = (t.cats and #t.cats>0) and (" ["..table.concat(t.cats, ",").."]") or ""
      table.insert(s, t.name.."("..tostring(t.prob)..")"..cats)
    end
    return table.concat(s, ", ")
  end
  table.insert(lines, "- Categorías activas: modern="..tostring(CFG.categoriasUsadas.modern)
                          .." coldwar="..tostring(CFG.categoriasUsadas.coldwar)
                          .." warbirds="..tostring(CFG.categoriasUsadas.warbirds)
                          .." armas="..tostring(CFG.categoriasUsadas.armas)
                          .." helisOn="..tostring(CFG.helisOn))
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
