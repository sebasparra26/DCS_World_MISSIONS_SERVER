paginasPorAvion = {}
comandosPorSubID = {}

-- Tipos de avión con subclave principal
tiposAvion = {
    --USA PLANES
    ["FA-18C-Hornet"] = {
        clave = "FA-18C_PAYLOAD",
        categoria = "Aviones Importados USA"
    },
    ["F-16CM-Viper"] = {
        clave = "F-16CM_PAYLOAD",
        categoria = "Aviones Importados USA"
    },
    ["A-10C-II-Tank-Killer"] = {
        clave = "A-10C_PAYLOAD",
        categoria = "Aviones Importados USA"
    },
    ["F-15E-S4-Eagle-Strike"] = {
        clave = "F-15E_PAYLOAD",
        categoria = "Aviones Importados USA"
    },
    ["F-14A-135-GR-Tomcat"] = {
        clave = "F-14A_PAYLOAD",
        categoria = "Aviones Importados USA"
    },
    ["F-14B-Tomcat"] = {
        clave = "F-14B_PAYLOAD",
        categoria = "Aviones Importados USA"
    },
    ["F-4E-45MC-Phantom"] = {
        clave = "F-4_PAYLOAD",
        categoria = "Aviones Importados USA"
    },
    ["F-5E-3-Tiger"] = {
        clave = "F-5_PAYLOAD",
        categoria = "Aviones Importados USA"
    },
    ["AV-8B-Night-Attack"] = {
        clave = "AV-8B_PAYLOAD",
        categoria = "Aviones Importados USA"
    },
    ["A-4E-C-Skyhawk"] = {
        clave = "A-4E_PAYLOAD",
        categoria = "Aviones Importados USA"
    },
    ["C130-Hercules"] = {
        clave = "C130_PAYLOAD",
        categoria = "Aviones Importados USA"
    },

    --RUSIA PLANES

    ["MIG-29A-FC"] = {
        clave = "MIG-29A_PAYLOAD",
        categoria = "Aviones Importados RUSIA"
    },
    ["MIG-21Bis"] = {
        clave = "MIG-21_PAYLOAD",
        categoria = "Aviones Importados RUSIA"
    },
    ["SU-25T-Frogfoot"] = {
        clave = "SU-25T_PAYLOAD",
        categoria = "Aviones Importados RUSIA"
    },
    ["SU-27-Flanker"] = {
        clave = "SU-27_PAYLOAD",
        categoria = "Aviones Importados RUSIA"
    },
    ["SU-33-Flanker-D"] = {
        clave = "SU-33_PAYLOAD",
        categoria = "Aviones Importados RUSIA"
    },

    --FRANCE PLANES

    ["Mirage-M-2000-C"] = {
        clave = "M-2000_PAYLOAD",
        categoria = "Aviones Importados FRANCIA"
    },
    ["SA342-Gazelle"] = {
        clave = "SA342_PAYLOAD",
        categoria = "Aviones Importados FRANCIA"
    },

     --TEMU PLANES

     ["JF-17-Thunder"] = {
        clave = "JF-17_PAYLOAD",
        categoria = "Aviones Importados TEMU"
    },
    ["AJS-37-Viggen"] = {
        clave = "AJS-37_PAYLOAD",
        categoria = "Aviones Importados TEMU"
    },

    --USA HELIS


    ["AH-64D BLK.II-Apache"] = {
        clave = "AH-64D_PAYLOAD",
        categoria = "Helicopteros Importados USA"
    },
    ["OH-58D(R)-Kiowa Warrior"] = {
        clave = "OH-58D_PAYLOAD",
        categoria = "Helicopteros Importados USA"
    },
    ["CH-47F-Chinook"] = {
        clave = "CH-47F_PAYLOAD",
        categoria = "Helicopteros Importados USA"
    },
    ["UH-1H-Huey"] = {
        clave = "UH-1H_PAYLOAD",
        categoria = "Helicopteros Importados USA"
    },
    ["UH-60L-Blackhawk"] = {
        clave = "UH-60L_PAYLOAD",
        categoria = "Helicopteros Importados USA"
    },

     --RUSIA HELIS


     ["KA-50-III-BlackShark-3"] = {
        clave = "KA-50_PAYLOAD",
        categoria = "Helicopteros Importados RUSIA"
    },
    ["MI-24P-Hind"] = {
        clave = "MI-24P_PAYLOAD",
        categoria = "Helicopteros Importados RUSIA"
    },
    ["MI-8MTV2"] = {
        clave = "MI-8MTV2_PAYLOAD",
        categoria = "Helicopteros Importados RUSIA"
    }
 
}

subvariantesAvion = {
    --USA PLANES
    ["FA-18C_PAYLOAD"] = {
        ["FA-18C_hornet - Pack x 2"] = "FA-18C-1",
        ["FA-18C_hornet - Pack x 4"] = "FA-18C-2"
    },
    ["F-16CM_PAYLOAD"] = {
        ["F-16CM bl.50 - Viper - Pack x 2"] = "F-16CM-1",
        ["F-16CM bl.50 - Viper - Pack x 4"] = "F-16CM-2"
    },
    ["A-10C_PAYLOAD"] = {
        ["A-10C II - Tank Killer - Pack x 2"] = "A-10C-2-1",
        ["A-10C II - Tank Killer - Pack x 4"] = "A-10C-2-2"
    },
    ["F-15E_PAYLOAD"] = {
        ["F-15E S4 - Eagle Strike -  Pack x 2"] = "F-15E-S4-1",
        ["F-15E S4 - Eagle Strike -  Pack x 4"] = "F-15E-S4-2"
    },
    ["F-14A_PAYLOAD"] = {
        ["F-14A-135-GR - Tomcat -  Pack x 2"] = "F-14A-1",
        ["F-14A-135-GR - Tomcat -  Pack x 4"] = "F-14A-2"
    },
    ["F-14B_PAYLOAD"] = {
        ["F-14B - Tomcat -  Pack x 2"] = "F-14B-1",
        ["F-14B - Tomcat -  Pack x 4"] = "F-14B-2"
    },
    ["F-4_PAYLOAD"] = {
        ["F-4E-45MC - Phantom -  Pack x 2"] = "F-4-1",
        ["F-4E-45MC - Phantom -  Pack x 4"] = "F-4-2"
    },
    ["F-5_PAYLOAD"] = {
        ["F-5E-3 - Tiger  -  Pack x 2"] = "F-5-1",
        ["F-5E-3 - Tiger  -  Pack x 4"] = "F-5-2"
    },
    ["A-4E_PAYLOAD"] = {
        ["A-4E-C - Skyhawk - Pack x 2"] = "A-4E-C-1",
        ["A-4E-C - Skyhawk - Pack x 4"] = "A-4E-C-2"
    },
    ["C130_PAYLOAD"] = {
        ["C130 - Hercules - Pack x 1"] = "C130-1",
        ["C130 - Hercules - Pack x 2"] = "C130-2"
    },
    ["AV-8B_PAYLOAD"] = {
        ["AV-8B - Night Attack - Pack x 2"] = "AV-8B-1",
        ["AV-8B - Night Attack - Pack x 4"] = "AV-8B-2"
    },

    --RUSIA PLANES

    ["MIG-29A_PAYLOAD"] = {
        ["MIG-29A - FC - Pack x 2"] = "MIG-29A-1",
        ["MIG-29A - FC - Pack x 4"] = "MIG-29A-2"
    },
    ["MIG-21_PAYLOAD"] = {
        ["MIG-21Bis - Pack x 2"] = "MIG-21-1",
        ["MIG-21Bis - Pack x 4"] = "MIG-21-2"
    },
    ["SU-25T_PAYLOAD"] = {
        ["SU-25T - Frogfoot - Pack x 2"] = "SU-25T-1",
        ["SU-25T - Frogfoot - Pack x 4"] = "SU-25T-2"
    },
    ["SU-27_PAYLOAD"] = {
        ["SU-27 - Flanker - Pack x 2"] = "SU-27-1",
        ["SU-27 - Flanker - Pack x 4"] = "SU-27-2"
    },
    ["SU-33_PAYLOAD"] = {
        ["SU-33 - Flanker D - Pack x 2"] = "SU-33-1",
        ["SU-33 - Flanker D - Pack x 4"] = "SU-33-2"
    },

    --FRANCE PLANES

    ["M-2000_PAYLOAD"] = {
        ["Mirage M-2000 C  - Pack x 2"] = "M-2000-1",
        ["Mirage M-2000 C  - Pack x 4"] = "M-2000-2"
    },
    ["SA342_PAYLOAD"] = {
        ["SA342 - L - Gazelle - Pack x 2"] = "SA342-L-1",
        ["SA342 - M - Gazelle - Pack x 2"] = "SA342-M-1",
        ["SA342 - Minigun - Gazelle - Pack x 2"] = "SA342-Minigun-1"
    },

    --TEMU PLANES

    ["JF-17_PAYLOAD"] = {
        ["JF-17 - Thunder - Pack x 2"] = "JF-17-1",
        ["JF-17 - Thunder - Pack x 4"] = "JF-17-2"
    },
    ["AJS-37_PAYLOAD"] = {
        ["AJS-37 - Viggen - Pack x 2"] = "AJS-37-1",
        ["AJS-37 - Viggen - Pack x 4"] = "AJS-37-2"
    },

    --USA HELIS

    ["AH-64D_PAYLOAD"] = {
        ["AH-64D BLK. II - Apache - Pack x 2"] = "AH-64D-1",
        ["AH-64D BLK. II - Apache - Pack x 4"] = "AH-64D-2"
    },
    ["OH-58D_PAYLOAD"] = {
        ["OH-58D (R) - Kiowa Warrior - Pack x 2"] = "OH-58D-1",
        ["OH-58D (R) - Kiowa Warrior - Pack x 4"] = "OH-58D-2"
    },
    ["CH-47F_PAYLOAD"] = {
        ["CH-47F- Chinook - Pack x 2"] = "CH-47F-1",
        ["CH-47F- Chinook - Pack x 4"] = "CH-47F-2"
    },
    ["UH-1H_PAYLOAD"] = {
        ["UH-1H - Huey - Pack x 2"] = "UH-1H-1",
        ["UH-1H - Huey - Pack x 4"] = "UH-1H-2"
    },
    ["UH-60L_PAYLOAD"] = {
        ["UH-60L - Blackhawk - Pack x 2"] = "UH-60L-1",
        ["UH-60L - Blackhawk - Pack x 4"] = "UH-60L-2"
    },

    --RUSIA HELIS

    ["KA-50_PAYLOAD"] = {
        ["KA-50 III -  Black Shark 3 - Pack x 2"] = "KA-50-1",
        ["KA-50 III -  Black Shark 3 - Pack x 4"] = "KA-50-2"
    },
    ["MI-24P_PAYLOAD"] = {
        ["MI-24P - Hind - Pack x 2"] = "MI-24P-1",
        ["MI-24P - Hind - Pack x 4"] = "MI-24P-2"
    },
    ["MI-8MTV2_PAYLOAD"] = {
        ["MI-8MTV2 - Pack x 2"] = "MI-8MTV2-1",
        ["MI-8MTV2 - Pack x 4"] = "MI-8MTV2-2"
    }
    
}

local destinosBase = {
"Liwa AFB",
--"Al Dhafra AFB",
"Al-Bateen",
--"Sas Al Nakheel",
--"Abu Dhabi Intl",
"Al Ain Intl",
"Al Maktoum Intl",
"Al Minhad AFB",
"Dubai Intl",
"Sharjah Intl",
"Fujairah intl",
"Ras Al Khaimah Intl",
"Khasab",
"Bandar-e-Jask",
"Sir Abu Nauyr",
"Abu Musa Island",
"Sirri Island",
"Tunb Kochak",
"Tunb Island AFB",
"Bandar Lengeh",
"Kish Intl",
"Lavan Island",
"Qeshm Island",
--"Havadarya",
"Bandar Abbas intl",
"Lar"
--"Jiroft",
--"Shiraz Intl",
--"Kerman"
}

destinosPorSubvariante = {
    --USA PLANES
    ["FA-18C-1"] = destinosBase,
    ["FA-18C-2"] = destinosBase,
    ["F-16CM-1"] = destinosBase,
    ["F-16CM-2"] = destinosBase,
    ["A-10C-2-1"] = destinosBase,
    ["A-10C-2-2"] = destinosBase,
    ["F-15E-S4-1"] = destinosBase,
    ["F-15E-S4-2"] = destinosBase,
    ["F-14A-1"] = destinosBase,
    ["F-14A-2"] = destinosBase,
    ["F-14B-1"] = destinosBase,
    ["F-14B-2"] = destinosBase,
    ["F-4-1"] = destinosBase,
    ["F-4-2"] = destinosBase,
    ["F-5-1"] = destinosBase,
    ["F-5-2"] = destinosBase,
    ["A-4E-C-1"] = destinosBase,
    ["A-4E-C-2"] = destinosBase,
    ["C130-1"] = destinosBase,
    ["C130-2"] = destinosBase,
    ["AV-8B-1"] = destinosBase,
    ["AV-8B-2"] = destinosBase,

    --RUSIA PLANES

    ["MIG-29A-1"] = destinosBase,
    ["MIG-29A-2"] = destinosBase,
    ["MIG-21-1"] = destinosBase,
    ["MIG-21-2"] = destinosBase,
    ["SU-25T-1"] = destinosBase,
    ["SU-25T-2"] = destinosBase,
    ["SU-27-1"] = destinosBase,
    ["SU-27-2"] = destinosBase,
    ["SU-33-1"] = destinosBase,
    ["SU-33-2"] = destinosBase,

    --FRANCIA PLANES

    ["M-2000-1"] = destinosBase,
    ["M-2000-2"] = destinosBase,
    ["SA342-L-1"] = destinosBase,
    ["SA342-M-1"] = destinosBase,
    ["SA342-Minigun-1"] = destinosBase,

    --TEMU PLANES

    ["JF-17-1"] = destinosBase,
    ["JF-17-2"] = destinosBase,
    ["AJS-37-1"] = destinosBase,
    ["AJS-37-2"] = destinosBase,
    
  

    --USA HELIS

    ["AH-64D-1"] = destinosBase,
    ["AH-64D-2"] = destinosBase,
    ["OH-58D-1"] = destinosBase,
    ["OH-58D-2"] = destinosBase,
    ["CH-47F-1"] = destinosBase,
    ["CH-47F-2"] = destinosBase,
    ["UH-1H-1"] = destinosBase,
    ["UH-1H-2"] = destinosBase,
    ["UH-60L-1"] = destinosBase,
    ["UH-60L-2"] = destinosBase,



    --RUSIA HELIS

    ["KA-50-1"] = destinosBase,
    ["KA-50-2"] = destinosBase,
    ["MI-24P-1"] = destinosBase,
    ["MI-24P-2"] = destinosBase,
    ["MI-8MTV2-1"] = destinosBase,
    ["MI-8MTV2-2"] = destinosBase
    


    
}

function crearMenuLogisticoAzul()
    local menuRaiz = missionCommands.addSubMenuForCoalition(2, "Mercado de Pulgas AZUL")
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

duracionMercadoSegundosB = 9000         -- Duración total del mercado (2h)
intervaloAnuncioMercadoB = 60          -- Intervalo de mensaje (15min)
tiempoInicioMercadoB = timer.getTime()  -- Tiempo de inicio real

function actualizarTemporizadorMercadoB()
    local tiempoActual = timer.getTime()
    local tiempoRestante = math.max(0, (tiempoInicioMercadoB + duracionMercadoSegundosB) - tiempoActual)

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

    trigger.action.outTextForCoalition(2, "El mercado se cerrará en: " .. minutos .. " min " .. segundos .. " seg", 10)
    mist.scheduleFunction(actualizarTemporizadorMercadoB, {}, timer.getTime() + intervaloAnuncioMercadoB)
end

-- Iniciar temporizador
mist.scheduleFunction(actualizarTemporizadorMercadoB, {}, timer.getTime() + intervaloAnuncioMercadoB)

