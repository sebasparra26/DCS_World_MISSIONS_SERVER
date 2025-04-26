-----------------------------------------------BY BAZTIAN - HORIZON DEBELOPERS------------------------------------------------------------------------------------------------------------


--DETECTOR DE UNIDADES - NOMBRES TENICOS Y NOSMBRES DE UI m(ONLY DEV)  USE LOAD CONTINUOS TRIGGER

local nombresDeUnidades = {
    "InfUSA_01",
    "InfUSA_02",
    "InfUSA_03",
    "InfUSA_04",
    "InfUSA_05",
    "InfUSA_06",
    "InfUSA_07",
    "InfUSA_08",
    "InfUSA_09",
    "InfUSA_10"
}

for _, nombre in ipairs(nombresDeUnidades) do
    local unidad = Unit.getByName(nombre)
    if unidad then
        local tipo = unidad:getTypeName()
        local mensaje = "Unidad '" .. nombre .. "' tiene TypeName: " .. tipo
        trigger.action.outText(mensaje, 60)
        env.info(mensaje)
    else
        local mensaje = "Unidad '" .. nombre .. "' no fue encontrada o no está activa."
        trigger.action.outText(mensaje, 60)
        env.info(mensaje)
    end
end


--MOOSE. ESTRUCTURAS DE NOMBRES PARA SEGUIMIENTO PROCEDURAL (ONLY DEV) -MOOSE LOAD IS NECESARY - USE LOAD 1 ONCE

for i = 1, 15 do
    local nombreTR = string.format("TR%02d", i)
    local nombreUS = string.format("US%02d", i)
  
    -- Validación debug para TR
    if Group.getByName(nombreTR) then
      _G["TR_"..i] = SPAWN
        :New(nombreTR)
        :InitLimit(3, 200)
        :SpawnScheduled(5, 0.5)
      env.info("SPAWN creado correctamente para: " .. nombreTR)
    else
      env.info("ERROR: No se encontró el grupo " .. nombreTR .. " en el ME")
    end
  
    -- Validación debug para US
    if Group.getByName(nombreUS) then
      _G["US_"..i] = SPAWN
        :New(nombreUS)
        :InitLimit(4, 200)
        :SpawnScheduled(5, 0.5)
      env.info("SPAWN creado correctamente para: " .. nombreUS)
    else
      env.info("ERROR: No se encontró el grupo " .. nombreUS .. " en el ME")
    end
  end

--DEBUG SYSTEM AIRPORTS_COALLITION CAPTURE TRACE - USE LOAD 1 ONCE
  
  -- Manejador de eventos para capturas de base aérea
local baseCaptureHandler = {}

function baseCaptureHandler:onEvent(event)
    if event.id == 10 then  -- ID 10 es "base captured"
        local capturedBy = event.initiator -- unidad que inició la captura
        local capturedBase = event.place -- base capturada

        if capturedBy and Unit.isExist(capturedBy) then
            local group = capturedBy:getGroup()
            local groupName = group:getName()
            local coalition = group:getCoalition()
            local baseName = capturedBase:getName()

            trigger.action.outText("La base '" .. baseName .. "' fue capturada por el grupo: " .. groupName, 15)

            -- También puedes hacer lógica adicional aquí:
            -- Por ejemplo: dar puntos, activar triggers, cambiar banderas, etc.
        end
    end
end

-- Registrar el manejador en DCS
world.addEventHandler(baseCaptureHandler)
