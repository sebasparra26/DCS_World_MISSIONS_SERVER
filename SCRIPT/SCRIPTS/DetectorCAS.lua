--------------------------------------------------------
-- CONFIGURACIÓN
--------------------------------------------------------
local CAS = {}

CAS.flagId   = 901        -- bandera a disparar
CAS.zoneName = "MONITOREO"       -- nombre de la zona en el ME

CAS.debugText = false     -- mensajes en pantalla
CAS.debugLog  = false      -- mensajes en dcs.log

--------------------------------------------------------
-- DEBUG
--------------------------------------------------------
local function casDebug(msg, tiempo)
    tiempo = tiempo or 5
    if CAS.debugText then
        trigger.action.outText("[CAS DETECTOR] " .. msg, tiempo)
    end
    if CAS.debugLog then
        env.info("[CAS DETECTOR] " .. msg)
    end
end

--------------------------------------------------------
-- BANDERA: ON -> OFF
--------------------------------------------------------
local function fireFlagOnce()
    trigger.action.setUserFlag(CAS.flagId, 1)
    casDebug("Bandera " .. CAS.flagId .. " -> ON (muerte roja en zona " .. CAS.zoneName .. ")")

    mist.scheduleFunction(
        function()
            trigger.action.setUserFlag(CAS.flagId, 0)
            casDebug("Bandera " .. CAS.flagId .. " -> OFF (reset)")
        end,
        {},
        timer.getTime() + 1
    )
end

--------------------------------------------------------
-- OBTENER INFO SEGURA DE OBJETO
--------------------------------------------------------
local function safeGetName(obj)
    if obj and obj.getName then
        local ok, res = pcall(obj.getName, obj)
        if ok and res then
            return res
        end
    end
    return "SIN_NOMBRE"
end

local function safeGetType(obj)
    if obj and obj.getTypeName then
        local ok, res = pcall(obj.getTypeName, obj)
        if ok and res then
            return res
        end
    end
    return "SIN_TIPO"
end

--------------------------------------------------------
-- MANEJO DE MUERTE DE OBJETO
--------------------------------------------------------
local function handleDeadObject(obj)
    if not obj then
        casDebug("handleDeadObject: obj es nil")
        return
    end

    -- Filtrar: solo objetos categoría UNIT
    if obj.getCategory and obj:getCategory() ~= Object.Category.UNIT then
        -- Si quieres ver qué otros tipos se mueren, descomenta esta línea:
        -- casDebug("Muerte no-UNIT ignorada. Categoria: " .. tostring(obj:getCategory()))
        return
    end

    -- Coalición
    if not obj.getCoalition then
        casDebug("Objeto UNIT sin getCoalition, ignorado")
        return
    end

    local coal = obj:getCoalition()
    if coal ~= coalition.side.RED then
        -- casDebug("Muerte UNIT pero no roja, ignorada")
        return
    end

    -- Posición
    if not obj.getPoint then
        casDebug("Unidad roja sin getPoint, ignorada")
        return
    end

    local pos = obj:getPoint()
    if not pos then
        casDebug("Unidad roja sin posición, ignorada")
        return
    end

    -- Verificar que MIST está cargado
    if not mist or not mist.pointInZone then
        casDebug("ERROR: mist.pointInZone no disponible. ¿Cargaste mist.lua antes?")
        return
    end

    local enZona = mist.pointInZone(pos, CAS.zoneName)

    local name = safeGetName(obj)
    local tipo = safeGetType(obj)

    casDebug(string.format(
        "Muerte roja detectada: %s (%s). En zona %s = %s",
        name, tipo, CAS.zoneName, tostring(enZona)
    ))

    if enZona then
        fireFlagOnce()
    end
end

--------------------------------------------------------
-- EVENT HANDLER
--------------------------------------------------------
local casHandler = {}

function casHandler:onEvent(event)
    if not event or not event.id then
        return
    end

    if event.id ~= world.event.S_EVENT_DEAD then
        return
    end

    -- Debug básico del evento
    casDebug("S_EVENT_DEAD recibido")

    -- Prioridad: initiator. Si no, usamos target.
    local obj = event.initiator or event.target
    if not obj then
        casDebug("S_EVENT_DEAD sin initiator ni target válidos")
        return
    end

    handleDeadObject(obj)
end

world.addEventHandler(casHandler)

casDebug("Detector de muertes ROJAS en zona '" .. CAS.zoneName .. "' inicializado. Bandera " .. CAS.flagId)
