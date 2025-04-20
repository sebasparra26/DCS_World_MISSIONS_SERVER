paginasPorAvion = {}
comandosPorSubID = {}

-- Tipos de avión con subclave principal
tiposAvion = {
    ["Mosquito FB Mk VI"] = {
        clave = "MosquitoPayload",
        categoria = "Nacionales UK"
    }
}

subvariantesAvion = {
    ["MosquitoPayload"] = {
        ["Mosquito FB Mk-VI - Standard Unit"] = "Mosquito-FB-Mk-VI-S",
        ["Mosquito FB Mk-VI - Interceptor Squadron"] = "Mosquito-FB-Mk-VI-I",
        ["Mosquito FB Mk-VI - Bombing Wing"] = "Mosquito-FB-Mk-VI-B",
        ["Mosquito FB Mk-VI - Tactical G-Attack"] = "Mosquito-FB-Mk-VI-TA",
        ["Mosquito FB Mk-VI - Mosquito FB Mk-VI - Logistic"] = "Mosquito-FB-Mk-VI-L"
    }
}

local destinosBase = {
    "Friston", "Ford", "Maupertus", "Brucheville", "Carpiquet",
    "Bernay Saint Martin", "Barville", "Evreux", "Orly",
    "Fecamp-Benouville", "Saint-Aubin", "Beauvais-Tille",
    "Amiens-Glisy", "Abbeville Drucat", "Ronai"
}

destinosPorSubvariante = {
    ["Mosquito-FB-Mk-VI-S"] = destinosBase,
    ["Mosquito-FB-Mk-VI-I"] = destinosBase,
    ["Mosquito-FB-Mk-VI-B"] = destinosBase,
    ["Mosquito-FB-Mk-VI-TA"] = destinosBase,
    ["Mosquito-FB-Mk-VI-L"] = destinosBase
}

function crearMenuLogisticoAzul()
    local menuRaiz = missionCommands.addSubMenuForCoalition(2, "Mercado de Pulgas")
    local menuCategorias = {}

    for nombreAvion, datos in pairs(tiposAvion) do
        local categoria = datos.categoria or "Sin Clasificar"
        if not menuCategorias[categoria] then
            menuCategorias[categoria] = missionCommands.addSubMenuForCoalition(2, categoria, menuRaiz)
        end
    end

    for nombreAvion, datos in pairs(tiposAvion) do
        local claveTipo = datos.clave
        local categoria = datos.categoria
        local menuCat = menuCategorias[categoria]
        local menuAvion = missionCommands.addSubMenuForCoalition(2, nombreAvion, menuCat)

        if subvariantesAvion[claveTipo] then
            for nombreSub, claveSub in pairs(subvariantesAvion[claveTipo]) do
                local menuSub = missionCommands.addSubMenuForCoalition(2, nombreSub, menuAvion)
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
            local subID = missionCommands.addSubMenuForCoalition(2, nombreSubmenu, menuAvion)
            paginasPorAvion[claveSubVar][pagina] = subID
        end

        local subID = paginasPorAvion[claveSubVar][pagina]
        local dummy = missionCommands.addCommandForCoalition(2, "_clear", subID, function() end)
        missionCommands.removeItem(dummy)

        for i = 1, porPagina do
            local idx = (pagina - 1) * porPagina + i
            local aeropuerto = entradas[idx]
            if aeropuerto then
                local data = plantillasLogisticaB[aeropuerto]
                if data then
                    local tipo = claveSubVar
                    local costoBase = tipoAviones[tipo] and tipoAviones[tipo].costo or 0
                    local recargo = recargoAeropuertoB[aeropuerto] or 1
                    local costoFinal = math.floor(costoBase * recargo)

                    local function formatearDolaresLegibleB(valor)
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

                    local textoMenu = aeropuerto .. " (" .. formatearDolaresLegibleB(costoFinal) ..
                        ") - Fondos: " .. formatearDolaresLegibleB(puntosCoalicion.PuntosAZUL)

                    local cmd = missionCommands.addCommandForCoalition(2, textoMenu, subID, function()
                        local bandera = trigger.misc.getUserFlag(data.bandera)
                        if bandera == 1 then
                            ejecutarEntregaB(aeropuerto, data, claveSubVar)
                        else
                            trigger.action.outText("Este aeródromo no está disponible en este momento.", 5)
                        end
                    end)
                    comandosPorSubID[subID] = comandosPorSubID[subID] or {}
                    table.insert(comandosPorSubID[subID], cmd)
                end
            end
        end
    end
end

crearMenuLogisticoAzul()

------------------------------------------------------------
-- FUNCIONALIDAD NUEVA: CIERRE AUTOMÁTICO DEL MERCADO
------------------------------------------------------------

duracionMercadoSegundos = 600         -- Duración total del mercado (2h)
intervaloAnuncioMercado = 20          -- Intervalo de mensaje (15min)
tiempoInicioMercado = timer.getTime()  -- Tiempo de inicio real

function actualizarTemporizadorMercado()
    local tiempoActual = timer.getTime()
    local tiempoRestante = math.max(0, (tiempoInicioMercado + duracionMercadoSegundos) - tiempoActual)

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

    trigger.action.outText("El mercado se cerrará en: " .. minutos .. " min " .. segundos .. " seg", 10)
    mist.scheduleFunction(actualizarTemporizadorMercado, {}, timer.getTime() + intervaloAnuncioMercado)
end

-- Iniciar temporizador
mist.scheduleFunction(actualizarTemporizadorMercado, {}, timer.getTime() + intervaloAnuncioMercado)

