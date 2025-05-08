local grupoObjetivo = "USSR_CONVOY_01"  -- Cambia esto por el grupo que quieras seguir
local zonaNombre = "DETECT"
local tiempoActualizacion = 20  -- segundos

-- Colores personalizados
local colorSet = {
    contorno = {1, 0, 0, 1}, -- rojo puro
    relleno = {1, 0, 0, 0.2} -- rojo transparente
}

-- Guardamos IDs para eliminar y actualizar
local marcadores = {}
local shapes = {}

-- Función para obtener posición media del grupo
local function getPosGrupo(nombreGrupo)
    local grupo = Group.getByName(nombreGrupo)
    if not grupo or not grupo:isExist() then return nil end
    local unidades = grupo:getUnits()
    if #unidades == 0 then return nil end

    local suma = {x = 0, y = 0, z = 0}
    for _, unidad in ipairs(unidades) do
        local pos = unidad:getPoint()
        suma.x = suma.x + pos.x
        suma.y = suma.y + pos.y
        suma.z = suma.z + pos.z
    end

    return {
        x = suma.x / #unidades,
        y = suma.y / #unidades,
        z = suma.z / #unidades
    }
end

-- Función principal para actualizar marker y shape
local function actualizarMarcador()
    local pos = getPosGrupo(grupoObjetivo)
    if not pos then
        trigger.action.outText("El grupo ya no existe. Deteniendo seguimiento.", 10)
        return
    end

    if not mist.pointInZone(pos, zonaNombre) then
        trigger.action.outText("El grupo salió de la zona. Deteniendo seguimiento.", 10)
        return
    end

    -- Si ya hay un marker previo, lo eliminamos
    if marcadores[grupoObjetivo] then
        mist.marker.remove(marcadores[grupoObjetivo])
    end
    if shapes[grupoObjetivo] then
        trigger.action.removeMark(shapes[grupoObjetivo])
    end

    -- Crear nuevo marker
    local idMarker = mist.marker.add({
        name = "Marker_" .. grupoObjetivo,
        type = "circle",
        point = pos,
        radius = 3000, -- puedes ajustar
        color = colorSet.contorno,
        fillColor = colorSet.relleno,
        lineType = 0,
        visible = true,
        coalition = 0,
        life = tiempoActualizacion + 5,
        text = grupoObjetivo
    })
    marcadores[grupoObjetivo] = idMarker

    -- Crear shape (texto flotante)
    local idShape = math.random(100000, 999999)
    trigger.action.markToAll(idShape, "Destruye el convoy de las SS", pos, true)
    shapes[grupoObjetivo] = idShape

    -- Repetimos después del intervalo
    mist.scheduleFunction(actualizarMarcador, {}, timer.getTime() + tiempoActualizacion)
end

-- Disparar el seguimiento
actualizarMarcador()
