-- ============================================
-- MENÚ LOGÍSTICO PARA COALICIÓN AZUL (COMPLETO)
-- ============================================

paginasPorAvion = {}

-- Tipos de avión con subclave principal
tiposAvion = {
    ["Mosquito FB Mk VI"] = {
        clave = "MosquitoPayload",
        categoria = "Nacionales UK"
    }
}

-- Subvariantes visibles por avión (clave principal → submenús → subclave)
subvariantesAvion = {
    ["MosquitoPayload"] = {
        ["Mosquito FB Mk-VI - Standard Unit"] = "Mosquito-FB-Mk-VI-S",
        ["Mosquito FB Mk-VI - Interceptor Squadron"] = "Mosquito-FB-Mk-VI-I",
        ["Mosquito FB Mk-VI - Bombing Wing"] = "Mosquito-FB-Mk-VI-B",
        ["Mosquito FB Mk-VI - Tactical G-Attack"] = "Mosquito-FB-Mk-VI-TA",
        ["Mosquito FB Mk-VI - Mosquito FB Mk-VI - Logistic"] = "Mosquito-FB-Mk-VI-L"
    }
}

-- Destinos por subvariante (llenado desde archivo logístico)
destinosPorSubvariante = destinosPorSubvariante or {}

-- ===============================================
-- CREACIÓN GENERAL DEL MENÚ PARA LA COALICIÓN AZUL
-- ===============================================
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

-- ==========================================================
-- ACTUALIZAR OPCIONES DE ENTREGA POR AVIÓN Y SUBCLAVE FINAL
-- ==========================================================
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
                local bandera = data and data.bandera
                local valorBandera = bandera and trigger.misc.getUserFlag(bandera) or 0
                local disponible = (valorBandera == 2 or valorBandera == 3)

                local baseCosto = tipoAviones[claveSubVar] and tipoAviones[claveSubVar].costo or 0
                local recargo = recargoAeropuertoB[aeropuerto] or 1
                local costoTotal = baseCosto * recargo
                local costoTexto = formatearDolaresLegibleB(costoTotal)

                local texto = disponible and ("Enviar a " .. string.upper(aeropuerto) .. " por un costo de " .. costoTexto)
                              or (string.upper(aeropuerto) .. " no disponible")

                missionCommands.addCommandForCoalition(2, texto, subID, function()
                    if not disponible then
                        trigger.action.outText("Este aeródromo no está disponible actualmente.", 5)
                        return
                    end
                    if data then
                        ejecutarEntregaB(aeropuerto, data, claveSubVar)
                    else
                        trigger.action.outText("Error: no se encontró la plantilla para " .. aeropuerto, 5)
                    end
                end)
            end
        end
    end
end

-- =====================
-- INICIO AUTOMÁTICO
-- =====================
crearMenuLogisticoAzul()
