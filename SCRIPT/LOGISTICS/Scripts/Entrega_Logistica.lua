timer.scheduleFunction(function()
    for nombreGrupo, data in pairs(activeDeliveries or {}) do
        if not data.entregado and Group.getByName(nombreGrupo) then
            local unidades = Group.getByName(nombreGrupo):getUnits()
            for _, unidad in ipairs(unidades) do
                if unit and Unit.isExist(unidad) then
                    local vel = unidad:getVelocity()
                    local alt = unidad:getPoint().y
                    if vel.x == 0 and vel.z == 0 and alt < 2 then
                        data.entregado = true
                        aerodromoDestino = data.destino
                        inventarioSeleccionado = "Mosquito"
                        coalicionCompradora = "PuntosAZUL"
                        if avionesData and avionesData[inventarioSeleccionado] then
                            cargarInventarioCompleto(aerodromoDestino, avionesData[inventarioSeleccionado])
                            trigger.action.outText("Suministros entregados en " .. data.destino, 10)
                            env.info("[LOGISTICA] Entrega completada en " .. data.destino)
                        else
                            trigger.action.outText("[ERROR] Inventario no encontrado", 5)
                        end
                        break
                    end
                end
            end
        end
    end
    return timer.getTime() + 5
end, {}, timer.getTime() + 3)
