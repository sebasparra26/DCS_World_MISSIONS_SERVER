-- Script: FlareLoop_Unit.lua
-- Función: hace que la unidad "01" lance una bengala roja cada 60 segundos
-- Autor: Sebastián Parra

local nombreUnidad = "GENERAL-1-1"
local intervalo = 10 -- segundos

local function lanzarBengalaUnidad()
    local unidad = Unit.getByName(nombreUnidad)
    if unidad and unidad:isExist() then
        local pos = unidad:getPoint()
        trigger.action.signalFlare(pos, 1, 0) -- 1 = rojo, 0 = norte
        --trigger.action.outText("Unidad "..nombreUnidad.." lanza una bengala roja.", 5)
        timer.scheduleFunction(lanzarBengalaUnidad, {}, timer.getTime() + intervalo)
    else
        trigger.action.outText("La unidad "..nombreUnidad.." ha sido destruida. Fin del script.", 10)
    end
end

-- Iniciar el ciclo
lanzarBengalaUnidad()
