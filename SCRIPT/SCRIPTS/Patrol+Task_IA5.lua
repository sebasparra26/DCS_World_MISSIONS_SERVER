-- ========================================
-- PATRULLA USA
-- ========================================
do
    local nombre = "PATRULLA_USA" --ENV.inf
    local templates = { "Patrol_IA_USA_1", "Patrol_IA_USA_2", "Patrol_IA_USA_3", "Patrol_IA_USA_4" }
    local prefijo = "USA air "
    local rangoDeteccion = 60 * 1852
    local rangoEnganche = 50 * 1852
    local debugMensajes = true

    -- =====================================================
    -- CONFIGURAR AQUÍ LOS TIPOS DE UNIDADES QUE SE PUEDEN ENGARCHAR
    -- =====================================================
    local categoriasPermitidas = {
        [Unit.Category.AIRPLANE]   = true,   -- Aviones
        [Unit.Category.HELICOPTER] = false,  -- Helicópteros
        [Unit.Category.GROUND_UNIT] = false  -- Vehículos terrestres
    }

    local grupoClonadoActual = nil
    local altMax = 0
    local monitoreoVelocidad = false
    local grupoYaSeDetuvo = false

    local nombresClonados = {}
    for i = 1, 9999 do
        table.insert(nombresClonados, prefijo .. i)
    end

    local function debug(texto, tiempo)
        if debugMensajes then
            trigger.action.outText("[" .. nombre .. "] " .. texto, tiempo or 5)
        end
    end

    local function detectarYEnganchar()
        local grupo = Group.getByName(grupoClonadoActual)
        if not grupo or not grupo:isExist() then return end

        local unidadIA = grupo:getUnit(1)
        if not unidadIA or not unidadIA:isExist() then return end

        local posIA = unidadIA:getPoint()
        local amenazaCercana = nil
        local grupoEnemigoCercano = nil
        local menorDistancia = rangoDeteccion

        for _, grupoRojo in pairs(coalition.getGroups(1)) do
            if Group.isExist(grupoRojo) then
                local enemigo = grupoRojo:getUnit(1)
                if enemigo and enemigo:isExist() then
                    local tipo = enemigo:getDesc().category
                    if categoriasPermitidas[tipo] then
                        local posEnemigo = enemigo:getPoint()
                        local dx = posIA.x - posEnemigo.x
                        local dz = posIA.z - posEnemigo.z
                        local dist = math.sqrt(dx * dx + dz * dz)

                        if dist < menorDistancia then
                            menorDistancia = dist
                            grupoEnemigoCercano = grupoRojo
                            if dist < rangoEnganche then
                                amenazaCercana = enemigo
                            end
                        end
                    end
                end
            end
        end

        if amenazaCercana and grupoEnemigoCercano then
            debug("Amenaza en rango. Enganchando")
            grupo:getController():pushTask({
                id = "EngageGroup",
                params = { groupId = grupoEnemigoCercano:getID() }
            })
        elseif grupoEnemigoCercano then
            debug("Amenaza detectada pero fuera de rango")
        else
            debug("Zona despejada")
        end

        timer.scheduleFunction(detectarYEnganchar, {}, timer.getTime() + 10)
    end

    local function clonarGrupo()
        if grupoClonadoActual then
            local g = Group.getByName(grupoClonadoActual)
            if g and g:isExist() then
                debug("Ya hay un grupo activo")
                return
            end
        end

        local plantilla = templates[math.random(#templates)]
        mist.cloneGroup(plantilla, true)

        timer.scheduleFunction(function()
            for _, nombre in ipairs(nombresClonados) do
                local g = Group.getByName(nombre)
                if g and g:isExist() then
                    grupoClonadoActual = nombre
                    altMax = 0
                    monitoreoVelocidad = false
                    grupoYaSeDetuvo = false
                    debug("Grupo clonado: " .. grupoClonadoActual)
                    detectarYEnganchar()
                    return
                end
            end
            debug("No se encontró el grupo clonado")
        end, {}, timer.getTime() + 1)
    end

    timer.scheduleFunction(function()
        if not grupoClonadoActual then
            clonarGrupo()
            return timer.getTime() + 10
        end

        local grupo = Group.getByName(grupoClonadoActual)
        if not grupo or not grupo:isExist() then
            debug("Grupo destruido. Clonando...")
            grupoClonadoActual = nil
            clonarGrupo()
            return timer.getTime() + 10
        end

        local unidad = grupo:getUnit(1)
        if unidad and unidad:isExist() then
            local punto = unidad:getPoint()
            local altTerreno = land.getHeight({ x = punto.x, y = punto.z })
            local altAGL = punto.y - altTerreno
            altMax = math.max(altMax, altAGL)

            local v = unidad:getVelocity()
            local speed = math.sqrt(v.x^2 + v.y^2 + v.z^2)

            debug("ALTITUD AGL: " .. math.floor(altAGL) .. " m | VELOCIDAD: " .. string.format("%.1f", speed) .. " m/s", 10)

            if not monitoreoVelocidad and altMax >= 200 then
                monitoreoVelocidad = true
                debug("Monitoreo de altitud activado")
            end

            if monitoreoVelocidad and speed < 2 and not grupoYaSeDetuvo then
                grupoYaSeDetuvo = true
                debug("El avión se detuvo después de volar, será destruido")
            
                local nombreViejo = grupoClonadoActual
                grupoClonadoActual = nil
            
                timer.scheduleFunction(function()
                    local g = Group.getByName(nombreViejo)
                    if g and g:isExist() then
                        g:destroy()
                        debug("Grupo destruido por estar detenido")
                    end
                    clonarGrupo()
                end, {}, timer.getTime() + 2)
            end
        end

        return timer.getTime() + 10
    end, {}, timer.getTime() + 10)

    clonarGrupo()
end