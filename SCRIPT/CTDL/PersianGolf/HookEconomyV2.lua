-- =============================
-- CTLD_EconomiaHook.lua
-- =============================

-- Activar sistema económico
USAR_ECONOMIA_CTLD = true

-- Costos por tipo de crate (usar exactamente el mismo texto que aparece en el menú de CTLD)
COSTOS_CRATE = { ---------------------------Costes x Caja
    ["Abrams M1A2C"] = 1625000, --6.5 Millones / 4
    ["Leopard 2A6M"] = 1250000, --5 Millones / 4
    ["Chieftain MK3"] = 625000,--2.5 Millones / 4
    ["Leclerc"] = 2250000,--9 Millones / 4
    ["Merkava MK4"] = 1125000,--4.5 Millones / 4
    ["T 90"] = 500000,--2 Millones / 4
    ["T 80UD"] = 450000,--1.8 Millones / 4
    ["T 72B3"] = 300000,--1.2 Millones / 4
    ["T 72B"] = 225000,--0.9 Millones / 4
    --------------------------------------
    ["MLRS Himars"] = 1250000,--5 Millones / 4
    ["SpGH DANA"] = 375000,--1.5 Millones / 4
    ["T155 Firtina"] = 550000,--2.2 Millones / 4
    ["Paladin"] = 425000,--1.7 Millones / 4
    ["SPH 2S19 Msta"] = 625000,--2.5 Millones / 4
    ["Smerch 300mm CM"] = 666666,--4 Millones / 6
    ["Smerch 300mm HE"] = 833333,--5 Millones / 6
    ["Uragan BM"] = 750000,--3 Millones / 4
    ["Grad URAL"] = 350000,--0.7 Millones / 2
    ["SAU Akatsia"] = 300000,--1.2 Millones / 4
    ["SAU 2C9"] = 400000,--0.8 Millones / 2
 -------------------------------------------------
    ["Hummer - JTAC - $100,000"] = 100000,--0.1 Mil / 2
    ["M-818 Ammo Truck - $100,000"] = 100000,--0.1 Mil / 2
    ["M-818 Ammo Truck 2"] = 100000,--0.1 Mil / 2
    ["M-818 Ammo Truck 3"] = 100000,--0.1 Mil / 2
    ["M-818 Ammo Truck 4"] = 100000,--0.1 Mil / 2
    ["M-978 Tanker - $100,000"] = 100000,--0.1 Mil / 2
    ["SKP-11 - JTAC - $100,000"] = 100000,--0.1 Mil / 2
    ["Ural-375 Ammo Truck - $100,000"] = 100000,--0.1 Millones / 2
    ["Ural-375 Ammo Truck 2"] = 100000,--0.1 Millones / 2
    ["Ural-375 Ammo Truck 3"] = 100000,--0.1 Millones / 2
    ["Ural-375 Ammo Truck 4"] = 100000,--0.1 Millones / 2
    ["KAMAZ Ammo Truck - $100,000"] = 100000,--0.1 Millones / 2
    ["EWR Radar"] = 1333333,--4 Millones / 3
    ["FOB Crate - Small"] = 333333,--1 Millones / 3
    ["MQ-9 Repear - $ 10,000,000"] = 10000000,--10 Millones / 1
    ["RQ-1A Predator - $ 10,000,000"] = 10000000,--10 Millones / 1
 -------------------------------------------------   
    ["M1097 Avenger"] = 333333,--1 Millones / 3
    ["M48 Chaparral"] = 600000,--1.2 Millones / 2
    ["Roland ADS"] = 1000000,--2 Millones / 2
    ["Roland Radar"] = 1000000,--2 Millones / 2
    ["Gepard AAA"] = 666666,--2 Millones / 3
    ["LPWS C-RAM"] = 1166666,--3.5 Millones / 3
    ["9K33 Osa"] = 500000,--1.5 Millones / 3
    ["9P31 Strela-1"] = 266666,--0.8 Millones / 3
    ["9K35M Strela-10"] = 333333,--1 Millones / 3
    ["9K331 Tor"] = 1166666,--3.5 Millones / 3
    ["2K22 Tunguska"] = 1333333,--4 Millones / 3
     -------------------------------------------------   
    -- puedes agregar más aquí

    ["HAWK Launcher - $ 2,200,000"] = 2200000,--2.2 Millones / 1 
    ["HAWK Search Radar - $ 3,000,000"] = 3000000,--3.0 Millones / 1
    ["HAWK Track Radar - $ 2,500,000"] = 2500000,--2.5 Millones / 1
    ["HAWK PCP - $ 1,500,000"] = 1500000,--1.5 Millones / 1
    ["HAWK CWAR - $ 2,000,000"] = 2000000,--2.0 Millones / 1
    ["HAWK Repair - $ 1,000,000"] = 1000000,--1 Millones / 1

    ["NASAMS Launcher 120C - $ 3,800,000"] = 3800000,--3.8 Millones / 1 15.200.000
    ["NASAMS Search/Track Radar - $ 3,200,000"] = 3200000,--3.2 Millones / 1
    ["NASAMS Command Post - $ 2,200,000"] = 2200000,--2.2 Millones / 1
    ["NASAMS Repair - $ 1,200,000"] = 1200000,--1.2 Millones / 1 

    ["KUB Launcher - $ 1,500,000"] = 1500000,--1.5 Millones / 1 6.000.000
    ["KUB Radar - $ 2,000,000"] = 2000000,--2 Millones / 1 2.000.000
    ["KUB Repair - $ 800,000"] = 800000,--0.8 Millones / 1 800.000

    ["BUK Launcher - $ 2,800,000"] = 2800000,--2.8 Millones / 1 11.200.000
    ["BUK Search Radar - $ 3,500,000"] = 3500000,--3.5 Millones / 1
    ["BUK CC Radar - $ 2,800,000"] = 2800000,--2.8 Millones / 1
    ["BUK Repair - $ 1,200,000"] = 1200000,--1.2 Millones / 1

    ["Patriot Launcher - $ 4,500,000"] = 4500000,--4.5 Millones / 1 9.000.000
    ["Patriot Radar - $ 6,000,000"] = 6000000,--6 Millones / 1
    ["Patriot ECS - $ 3,500,000"] = 3500000,--3.5 Millones / 1
    ["Patriot ICC - $ 3,000,000"] = 3000000,--3.0 Millones / 1
    ["Patriot EPP - $ 2,500,000"] = 2500000,--2.5 Millones / 1
    ["Patriot AMG (optional) - $ 2,000,000"] = 2000000,--2 Millones / 1
    ["Patriot Repair - $ 1,500,000"] = 1500000,--1.5 Millones / 1

    ["S-300 Grumble TEL C - $ 4,200,000"] = 4200000,--4.2 Millones / 1 12600000
    ["S-300 Grumble Flap Lid-A TR - $ 5,500,000"] = 5500000,--5.5 Millones / 1
    ["S-300 Grumble Clam Shell SR - $ 4,000,000"] = 4000000,--4.0 Millones / 1
    ["S-300 Grumble Big Bird SR - $ 6,500,000"] = 6500000,--6.5 Millones / 1
    ["S-300 Grumble C2 - $ 3,500,000"] = 3500000,--3.5 Millones / 1
    ["S-300 Repair - $ 1,800,000"] = 1800000,--1.8 Millones / 1

    
}

-- Hook que será llamado por CTLD al intentar crear un crate
function CTLD_ECONOMIA_HOOK(_args)
    local peso = tostring(_args[2])
    local crate = ctld.crateLookupTable[peso]
    if not crate then return true end  -- si no encuentra, dejarlo pasar

    local desc = crate.desc
    local costo = COSTOS_CRATE[desc] or 0
    local heli = ctld.getTransportUnit(_args[1])
    if not heli then return true end  -- dejar pasar si no puede identificar

    ---------------new--------------------------------------------------
    if not ctld.inLogisticsZone(heli) then
        ctld.displayMessageToGroup(heli, "Estás fuera de la zona logística para solicitar este crate.", 10)
        return false
    end

    local coalicion = heli:getCoalition()
    local saldo = obtenerPuntosCoalicion(coalicion)
    local flag = (coalicion == 1 and "PuntosROJO" or "PuntosAZUL")

    if USAR_ECONOMIA_CTLD and saldo < costo then
        ctld.displayMessageToGroup(heli, "Fondos insuficientes para crate: " .. desc, 10)
        return false
    end

    -- Descuento
    if USAR_ECONOMIA_CTLD and costo > 0 then
        puntosCoalicion[flag] = puntosCoalicion[flag] - costo
        ctld.displayMessageToGroup(heli, "Crate comprado: " .. desc .. "Nuevo saldo: " .. puntosCoalicion[flag], 10)
    end

    return true
end
