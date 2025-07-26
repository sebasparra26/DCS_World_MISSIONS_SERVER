MercadoSetuptimerR = MercadoSetuptimerR or {
    Total = 138.88,
    Intervalo = 200
}
paginasPorAvion = {}
comandosPorSubID = {}


function crearMenuLogisticoRojo()
    local menuRaiz = missionCommands.addSubMenuForCoalition(1, "MARKETPLACE")
    local menuCategorias = {}

    for nombreAvion, datos in pairs(tiposAvion) do
        local categoria = datos.categoria or "Sin Clasificar"
        if not menuCategorias[categoria] then
            menuCategorias[categoria] = missionCommands.addSubMenuForCoalition(1, categoria, menuRaiz)
        end
    end

    for nombreAvion, datos in pairs(tiposAvion) do
        local claveTipo = datos.clave
        local categoria = datos.categoria
        local menuCat = menuCategorias[categoria]
        local menuAvion = missionCommands.addSubMenuForCoalition(1, nombreAvion, menuCat)

        if subvariantesAvion[claveTipo] then
            for nombreSub, claveSub in pairs(subvariantesAvion[claveTipo]) do
                local menuSub = missionCommands.addSubMenuForCoalition(1, nombreSub, menuAvion)
                actualizarOpcionesParaAvion(menuSub, claveSub)
            end
        end
    end
end

function actualizarOpcionesParaAvion(menuAvion, claveSubVar)
    local porPagina = 8
    local entradas = destinosPorSubvariante[claveSubVar] or {}
    local totalPaginas = math.ceil(#entradas / porPagina)
    if totalPaginas == 0 then totalPaginas = 1 end

    paginasPorAvion[claveSubVar] = paginasPorAvion[claveSubVar] or {}

    for pagina = 1, totalPaginas do
        local nombreSubmenu = totalPaginas == 1 and "Opciones" or "Página " .. pagina

        if not paginasPorAvion[claveSubVar][pagina] then
            local subID = missionCommands.addSubMenuForCoalition(1, nombreSubmenu, menuAvion)
            paginasPorAvion[claveSubVar][pagina] = subID
        end

        local subID = paginasPorAvion[claveSubVar][pagina]
        local dummy = missionCommands.addCommandForCoalition(1, "_clear", subID, function() end)
        missionCommands.removeItem(dummy)

        for i = 1, porPagina do
            local idx = (pagina - 1) * porPagina + i
            local aeropuerto = entradas[idx]
            if aeropuerto then
                local data = plantillasLogisticaR[aeropuerto]
                if data then
                    local tipo = claveSubVar
                    local costoBase = tipoAviones[tipo] and tipoAviones[tipo].costo or 0
                    local recargo = recargoAeropuertoR[aeropuerto] or 1
                    local costoFinal = math.floor(costoBase * recargo)

                    local function formatearDolaresLegibleR(valor)
                        if type(valor) ~= "number" then return "$0" end
                        local entero, decimal = math.modf(valor)
                        local partes = {}
                        repeat
                            table.insert(partes, 1, string.format("%03d", entero % 1000))
                            entero = math.floor(entero / 1000)
                        until entero == 0
                        partes[1] = tostring(tonumber(partes[1]))
                        return "$" .. table.concat(partes, ".")
                    end

                    local textoMenu = "Comprar y Enviar a: " .. aeropuerto .. " (" .. formatearDolaresLegibleR(costoFinal) .. ")"


                    local cmd = missionCommands.addCommandForCoalition(1, textoMenu, subID, function()
                        local bandera = trigger.misc.getUserFlag(data.bandera)
                        if bandera == 3 then
                            ejecutarEntregaR(aeropuerto, data, claveSubVar)
                        else
                            trigger.action.outText("Este aeródromo no está disponible mientras este NEUTRAL. para comprar y enviar, El Aeropuerto debe ser de su COALICIÓN", 5)
                        end
                    end)
                    comandosPorSubID[subID] = comandosPorSubID[subID] or {}
                    table.insert(comandosPorSubID[subID], cmd)
                end
            end
        end
    end
end

crearMenuLogisticoRojo()

------------------------------------------------------------
-- FUNCIONALIDAD NUEVA: CIERRE AUTOMÁTICO DEL MERCADO
------------------------------------------------------------

duracionMercadoSegundosR = MercadoSetuptimerR.Total         -- Duración total del mercado (2h)
intervaloAnuncioMercadoR = MercadoSetuptimerR.Intervalo           -- Intervalo de mensaje (15min)
tiempoInicioMercadoR = timer.getTime()  -- Tiempo de inicio real

function actualizarTemporizadorMercadoR()
    local tiempoActual = timer.getTime()
    local tiempoRestante = math.max(0, (tiempoInicioMercadoR + duracionMercadoSegundosR) - tiempoActual)

    if tiempoRestante <= 0 then
        -- Cerrar todos los submenús
        for _, paginas in pairs(paginasPorAvion) do
            for _, subID in pairs(paginas) do
                if subID then missionCommands.removeItem(subID) end
            end
        end
        trigger.action.outText("El Mercado de Pulgas ha sido cerrado.", 15)
        return -- Detener
    end

    local minutos = math.floor(tiempoRestante / 60)
    local segundos = math.floor(tiempoRestante % 60)

    trigger.action.outTextForCoalition(1, "El mercado se cerrará en: " .. minutos .. " min " .. segundos .. " seg", 10)
    mist.scheduleFunction(actualizarTemporizadorMercadoR, {}, timer.getTime() + intervaloAnuncioMercadoR)
end

-- Iniciar temporizador
mist.scheduleFunction(actualizarTemporizadorMercadoR, {}, timer.getTime() + intervaloAnuncioMercadoR)

