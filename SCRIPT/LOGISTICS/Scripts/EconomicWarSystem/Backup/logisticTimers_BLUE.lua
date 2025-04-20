
-- Reejecutar programaciones clave para logística y menú tras cargar misión guardada

-- Mostrar puntos automáticamente cada 60s
if mostrarPuntos then
    mist.scheduleFunction(mostrarPuntos, {}, timer.getTime() + 5, 60)
else
    env.info("[logisticTimers] mostrarPuntos no está definido aún.")
end

-- Crear menú billetera si está definido
if crearMenuBilletera then
    timer.scheduleFunction(crearMenuBilletera, {}, timer.getTime() + 3)
else
    env.info("[logisticTimers] crearMenuBilletera no está definido aún.")
end

-- Crear menú logístico si está definido
if crearMenuParaAzules then
    timer.scheduleFunction(crearMenuParaAzules, {}, timer.getTime() + 5)
else
    env.info("[logisticTimers] crearMenuParaAzules no está definido aún.")
end
