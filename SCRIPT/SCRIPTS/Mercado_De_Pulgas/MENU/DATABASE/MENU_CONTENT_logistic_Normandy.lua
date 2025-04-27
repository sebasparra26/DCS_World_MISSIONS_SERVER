-------------------------------SHARED---------------------------------------------------------------
-----------------------------------BLUE & RED-----------------------------------------------------------

tiposAvion = {

-------------------------------------------------------------
-------------------------------------------------------------
                            --UK
-------------------------------------------------------------
-------------------------------------------------------------

    ["Mosquito FB Mk VI"] = {
        clave = "MosquitoPayload",
        categoria = "Nacionales UK"
    },
    ["Spitfire-LF-Mk.IX"] = {
        clave = "SpitfirePayload",
        categoria = "Nacionales UK"
    },
-------------------------------------------------------------
-------------------------------------------------------------
                            --USA
-------------------------------------------------------------
-------------------------------------------------------------

    ["P-47D"] = {
        clave = "P-47D-Payload",
        categoria = "Importados USA"
    },
    ["P-51D"] = {
        clave = "P-51D-Payload",
        categoria = "Importados USA"
    },
-------------------------------------------------------------
-------------------------------------------------------------
                            --German
-------------------------------------------------------------
-------------------------------------------------------------    
    ["German"] = {
        clave = "German-Payload",
        categoria = "Importados Alemania"
    },
-------------------------------------------------------------
-------------------------------------------------------------
                            --URSS
-------------------------------------------------------------
-------------------------------------------------------------    
    ["URSS"] = {
        clave = "URSS-Payload",
        categoria = "Importados URSS"
    }    
    
}

subvariantesAvion = {

-------------------------------------------------------------
-------------------------------------------------------------
                            --UK
-------------------------------------------------------------
-------------------------------------------------------------

    ["MosquitoPayload"] = {
        ["Mosquito FB Mk-VI - Standard Unit"] = "Mosquito-FB-Mk-VI-S",
        ["Mosquito FB Mk-VI - Interceptor Squadron"] = "Mosquito-FB-Mk-VI-I",
        ["Mosquito FB Mk-VI - Bombing Wing"] = "Mosquito-FB-Mk-VI-B",
        ["Mosquito FB Mk-VI - Tactical G-Attack"] = "Mosquito-FB-Mk-VI-TA",
        ["Mosquito FB Mk-VI - Mosquito FB Mk-VI - Logistic"] = "Mosquito-FB-Mk-VI-L"
    },
    ["SpitfirePayload"] = {
        ["Spitfire LF Mk.IX - Standard Unit"] = "Spitfire-LF-Mk.IX-S",
        ["Spitfire LF Mk.IX -   Interceptor Squadron"] = "Spitfire-LF-Mk.IX-I",
        ["Spitfire LF Mk.IX -   Bombing Wing"] = "Spitfire-LF-Mk.IX-B",
        ["Spitfire LF Mk.IX CW - Standard Unit"] = "Spitfire-LF-Mk.IX-CW-S",
        ["Spitfire LF Mk.IX CW -   Interceptor Squadron"] = "Spitfire-LF-Mk.IX-CW-I",
        ["Spitfire LF Mk.IX CW -   Bombing Wing"] = "Spitfire-LF-Mk.IX-CW-B"
    },
    ["P-47D-Payload"] = {
        ["P-47D-30 -   Interceptor Squadron"] = "P-47D-30_I",
        ["P-47D-30 -   Bombing Squadron"] = "P-47D-30_B",
        ["P-47D-30 - Early Interceptor Squadron"] = "P-47D-30_Early_I",
        ["P-47D-30 Early - Bombing Squadron"] = "P-47D-30_Early_B",
        ["P-47D-40 Interceptor Squadron"] = "P-47D-40_I",
        ["P-47D-40 - Bombing Squadron"] = "P-47D-40_B"
    },
    ["P-51D-Payload"] = {
        ["P-51D-25NA - Interceptor Squadron"] = "P-51D-25NA",
        ["P-51D-30NA - Interceptor Squadron"] = "P-51D-30NA"
       
    },
    
-------------------------------------------------------------
-------------------------------------------------------------
                            --German
-------------------------------------------------------------
------------------------------------------------------------- 
    ["German-Payload"] = {
        ["BF-109 k-4 - Caza"] = "BF-109-k-4",
        ["FW-190-A8 - Caza"] = "FW-190-A8",
        ["FW-190-D9 - Caza"] = "FW-190-D9"
       
    },
-------------------------------------------------------------
-------------------------------------------------------------
                            --URSS
-------------------------------------------------------------
-------------------------------------------------------------    
    ["URSS-Payload"] = {
        ["I-16 Caza - Cohetero"] = "I-16"
    
    }
}

local destinosBase = {
    "Friston", "Ford", "Maupertus", "Brucheville", "Carpiquet",
    "Bernay Saint Martin", "Barville", "Evreux", "Orly",
    "Fecamp-Benouville", "Saint-Aubin", "Beauvais-Tille",
    "Amiens-Glisy", "Abbeville Drucat", "Ronai"
}

destinosPorSubvariante = {
 
-------------------------------------------------------------
-------------------------------------------------------------
                            --UK
-------------------------------------------------------------
-------------------------------------------------------------   

    ["Mosquito-FB-Mk-VI-S"] = destinosBase,
    ["Mosquito-FB-Mk-VI-I"] = destinosBase,
    ["Mosquito-FB-Mk-VI-B"] = destinosBase,
    ["Mosquito-FB-Mk-VI-TA"] = destinosBase,
    ["Mosquito-FB-Mk-VI-L"] = destinosBase,
    ["Spitfire-LF-Mk.IX-S"] = destinosBase,
    ["Spitfire-LF-Mk.IX-I"] = destinosBase,
    ["Spitfire-LF-Mk.IX-B"] = destinosBase,
    ["Spitfire-LF-Mk.IX-CW-S"] = destinosBase,
    ["Spitfire-LF-Mk.IX-CW-I"] = destinosBase,
    ["Spitfire-LF-Mk.IX-CW-B"] = destinosBase,
    -------------------------------------------------------------
-------------------------------------------------------------
                            --USA
-------------------------------------------------------------
------------------------------------------------------------- 
["P-47D-30_I"] = destinosBase,
["P-47D-30_B"] = destinosBase,
["P-47D-30_Early_I"] = destinosBase,
["P-47D-30_Early_B"] = destinosBase,
["P-47D-40_I"] = destinosBase,
["P-47D-40_B"] = destinosBase,
["P-51D-25NA"] = destinosBase,
["P-51D-30NA"] = destinosBase,
-------------------------------------------------------------
-------------------------------------------------------------
                            --German
-------------------------------------------------------------
------------------------------------------------------------- 
["BF-109-k-4"] = destinosBase,
["FW-190-A8"] = destinosBase,
["FW-190-D9"] = destinosBase,
-------------------------------------------------------------
-------------------------------------------------------------
                            --URSS
-------------------------------------------------------------
-------------------------------------------------------------
["I-16"] = destinosBase,



}



nombresSubvariantes = {

-------------------------------------------------------------
-------------------------------------------------------------
                            --UK
-------------------------------------------------------------
-------------------------------------------------------------     

    ["Mosquito-FB-Mk-VI-S"]  = "Mosquito FB Mk-VI - Standard Unit",
    ["Mosquito-FB-Mk-VI-I"]  = "Mosquito FB Mk-VI - Interceptor Squadron",
    ["Mosquito-FB-Mk-VI-B"]  = "Mosquito FB Mk-VI - Bombing Wing",
    ["Mosquito-FB-Mk-VI-TA"] = "Mosquito FB Mk-VI - Tactical G-Attack",
    ["Mosquito-FB-Mk-VI-L"]  = "Mosquito FB Mk-VI - Logistic",
    ["Spitfire-LF-Mk.IX-S"] = "Spitfire LF Mk.IX - Standard Unit",
    ["Spitfire-LF-Mk.IX-I"] = "Spitfire LF Mk.IX -   Interceptor Squadron",
    ["Spitfire-LF-Mk.IX-B"] = "Spitfire LF Mk.IX -   Bombing Wing",
    ["Spitfire-LF-Mk.IX-CW-S"] = "Spitfire LF Mk.IX CW - Standard Unit",
    ["Spitfire-LF-Mk.IX-CW-I"] = "Spitfire LF Mk.IX CW -   Interceptor Squadron",
    ["Spitfire-LF-Mk.IX-CW-B"] = "Spitfire-LF-Mk.IX-CW-B",
 -------------------------------------------------------------
-------------------------------------------------------------
                            --USA
-------------------------------------------------------------
-------------------------------------------------------------     
    ["P-47D-30_I"] = "P-47D-30 -   Interceptor Squadron",
    ["P-47D-30_B"] = "P-47D-30 -   Bombing Squadron",
    ["P-47D-30_Early_I"] = "P-47D-30 - Early Interceptor Squadron",
    ["P-47D-30_Early_B"] = "P-47D-30 Early - Bombing Squadron",
    ["P-47D-40_I"] = "P-47D-40 Interceptor Squadron",
    ["P-47D-40_B"] = "P-47D-40 - Bombing Squadron",
    ["P-51D-25NA"] = "P-51D-25NA - Interceptor Squadron",
    ["P-51D-30NA"] = "P-51D-30NA - Interceptor Squadron",
-------------------------------------------------------------
-------------------------------------------------------------
                            --German
-------------------------------------------------------------
------------------------------------------------------------- 
    ["BF-109-k-4"] = "BF-109 k-4 - Caza",
    ["FW-190-A8"] = "FW-190-A8 - Caza",
    ["FW-190-D9"] = "FW-190-D9 - Caza",
-------------------------------------------------------------
-------------------------------------------------------------
                            --URSS
-------------------------------------------------------------
-------------------------------------------------------------
    ["I-16"] = "I-16 Caza - Cohetero"

}
---------------------------------------------------------------------------------------------------------------------
--------------------------------LOGISTIC FILE---------------------------------------------------------------
-----------------------------------BLUE--------------------------------------------------------------------

nombresPosiblesB = {}

for i = 1, 9999 do
    table.insert(nombresPosiblesB, "USA air " .. i)
    table.insert(nombresPosiblesB, "USA hel " .. i)
end


plantillasLogisticaB = {
    ["Ford"] = { template = "Supplies_C-47ToFord", bandera = 101 },
    ["Friston"] = { template = "Supplies_MosquitoToFriston", bandera = 102 },
    ["Maupertus"] = { template = "Supplies_C-47ToMaupertus", bandera = 103 },
    ["Brucheville"] = { template = "Supplies_MosquitoToBrucheville", bandera = 104 },
    ["Carpiquet"] = { template = "Supplies_MosquitoToCarpiquet", bandera = 105 },
    ["Ronai"] = { template = "Supplies_C-47ToRonai", bandera = 106 },
    ["Bernay Saint Martin"] = { template = "Supplies_C-47ToBernay", bandera = 107 },
    ["Barville"] = { template = "Supplies_C-47ToBarville", bandera = 108 },
    ["Evreux"] = { template = "Supplies_C-47ToEvreux", bandera = 109 },
    ["Orly"] = { template = "Supplies_C-47ToOrly", bandera = 110 },
    ["Fecamp-Benouville"] = { template = "Supplies_C-47ToFecamp-Benouville", bandera = 111 },
    ["Saint-Aubin"] = { template = "Supplies_MosquitoToSaint-Aubin", bandera = 112 },
    ["Beauvais-Tille"] = { template = "Supplies_MosquitoToBeauvais-Tille", bandera = 113 },
    ["Amiens-Glisy"] = { template = "Supplies_MosquitoToAmiens-Glisy", bandera = 114 },
    ["Abbeville Drucat"] = { template = "Supplies_MosquitoToAbbeville", bandera = 115 }

}

recargoAeropuertoB = {
    ["Ford"] = 1.0, ["Friston"] = 1.1, ["Maupertus"] = 1.2, ["Brucheville"] = 1.3,
    ["Carpiquet"] = 1.4, ["Ronai"] = 1.5, ["Bernay Saint Martin"] = 1.6, ["Barville"] = 1.7,
    ["Evreux"] = 1.8, ["Orly"] = 1.9, ["Fecamp-Benouville"] = 2.0, ["Saint-Aubin"] = 2.1,
    ["Beauvais-Tille"] = 2.2, ["Amiens-Glisy"] = 2.3, ["Abbeville Drucat"] = 2.4
}

multiplicadorTiempoB = {
    ["Ford"] = 1.1, ["Friston"] = 1.0, ["Maupertus"] = 1.3, ["Brucheville"] = 1.2,
    ["Carpiquet"] = 1.25, ["Ronai"] = 1.4, ["Bernay Saint Martin"] = 1.35,
    ["Barville"] = 1.3, ["Evreux"] = 1.45, ["Orly"] = 1.5, ["Fecamp-Benouville"] = 1.2,
    ["Saint-Aubin"] = 1.15, ["Beauvais-Tille"] = 1.3, ["Amiens-Glisy"] = 1.4,
    ["Abbeville Drucat"] = 1.35
}

coordenadasAerodromosB = {
    ["Ford"] = { x = 147466, z = -25753 }, ["Friston"] = { x = 143314, z = 28130 },
    ["Maupertus"] = { x = 16011, z = -84865 }, ["Brucheville"] = { x = -14865, z = -66032 },
    ["Carpiquet"] = { x = -34775, z = -9992 }, ["Ronai"] = { x = -73108, z = 12832 },
    ["Bernay Saint Martin"] = { x = -39530, z = 67036 }, ["Barville"] = { x = -39512, z = 67098 },
    ["Evreux"] = { x = -60606, z = 117326 }, ["Orly"] = { x = -73529, z = 200430 },
    ["Fecamp-Benouville"] = { x = 31004, z = 46274 }, ["Saint-Aubin"] = { x = 48979, z = 97582 },
    ["Beauvais-Tille"] = { x = 6070, z = 175169 }, ["Amiens-Glisy"] = { x = 53411, z = 191760 },
    ["Abbeville Drucat"] = { x = 81026, z = 150752 }

}


-------------------------------------------------------------------------------------------------------
--------------------------------LOGISTIC FILE---------------------------------------------------------------
-----------------------------------RED--------------------------------------------------------------------
nombresPosiblesR = {}
for i = 1, 9999 do
    table.insert(nombresPosiblesR, "THIRDREICH air " .. i)
    table.insert(nombresPosiblesR, "THIRDREICH hel " .. i)
end

plantillasLogisticaR = {
    ["Ford"] = { template = "Supplies_JU-88ToFord", bandera = 101 },
    ["Friston"] = { template = "Supplies_JU-88ToFriston", bandera = 102 },
    ["Maupertus"] = { template = "Supplies_JU-88ToMaupertus", bandera = 103 },
    ["Brucheville"] = { template = "Supplies_JU-88ToBrucheville", bandera = 104 },
    ["Carpiquet"] = { template = "Supplies_JU-88ToCarpiquet", bandera = 105 },
    ["Ronai"] = { template = "Supplies_JU-88ToRonai", bandera = 106 },
    ["Bernay Saint Martin"] = { template = "Supplies_JU-88ToBernay", bandera = 107 },
    ["Barville"] = { template = "Supplies_JU-88ToBarville", bandera = 108 },
    ["Evreux"] = { template = "Supplies_JU-88ToEvreux", bandera = 109 },
    ["Orly"] = { template = "Supplies_C-47ToOrly", bandera = 110 },
    ["Fecamp-Benouville"] = { template = "Supplies_JU-88ToFecamp-Benouville", bandera = 111 },
    ["Saint-Aubin"] = { template = "Supplies_JU-88ToSaint-Aubin", bandera = 112 },
    ["Beauvais-Tille"] = { template = "Supplies_JU-88ToToBeauvais-Tille", bandera = 113 },
    ["Amiens-Glisy"] = { template = "Supplies_JU-88ToAmiens-Glisy", bandera = 114 },
    ["Abbeville Drucat"] = { template = "Supplies_JU-88ToAbbeville", bandera = 115 }

}

recargoAeropuertoR = {
    ["Ford"] = 1.0, ["Friston"] = 1.0, ["Maupertus"] = 1.0, ["Brucheville"] = 1.0,
    ["Carpiquet"] = 1.0, ["Ronai"] = 1.0, ["Bernay Saint Martin"] = 1.0, ["Barville"] = 1.0,
    ["Evreux"] = 1.0, ["Orly"] = 1.0, ["Fecamp-Benouville"] = 1.0, ["Saint-Aubin"] = 1.0,
    ["Beauvais-Tille"] = 1.0, ["Amiens-Glisy"] = 1.0, ["Abbeville Drucat"] = 1.0
}

multiplicadorTiempoR = {
    ["Ford"] = 11.0, ["Friston"] = 1.0, ["Maupertus"] = 1.0, ["Brucheville"] = 1.0,
    ["Carpiquet"] = 1.0, ["Ronai"] = 1.0, ["Bernay Saint Martin"] = 1.0,
    ["Barville"] = 1.0, ["Evreux"] = 1.0, ["Orly"] = 1.0, ["Fecamp-Benouville"] = 1.0,
    ["Saint-Aubin"] = 1.0, ["Beauvais-Tille"] = 1.0, ["Amiens-Glisy"] = 1.0,
    ["Abbeville Drucat"] = 1.0
}

coordenadasAerodromosR = {
    ["Ford"] = { x = 147466, z = -25753 }, ["Friston"] = { x = 143314, z = 28130 },
    ["Maupertus"] = { x = 16011, z = -84865 }, ["Brucheville"] = { x = -14865, z = -66032 },
    ["Carpiquet"] = { x = -34775, z = -9992 }, ["Ronai"] = { x = -73108, z = 12832 },
    ["Bernay Saint Martin"] = { x = -39530, z = 67036 }, ["Barville"] = { x = -39512, z = 67098 },
    ["Evreux"] = { x = -60606, z = 117326 }, ["Orly"] = { x = -73529, z = 200430 },
    ["Fecamp-Benouville"] = { x = 31004, z = 46274 }, ["Saint-Aubin"] = { x = 48979, z = 97582 },
    ["Beauvais-Tille"] = { x = 6070, z = 175169 }, ["Amiens-Glisy"] = { x = 53411, z = 191760 },
    ["Abbeville Drucat"] = { x = 81026, z = 150752 }

}



