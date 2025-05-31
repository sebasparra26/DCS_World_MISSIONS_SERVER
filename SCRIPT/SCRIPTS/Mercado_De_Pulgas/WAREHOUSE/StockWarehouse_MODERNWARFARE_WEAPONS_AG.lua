---------------------------BAZTIAN---------------------------------------------------------------------------


tipoAviones = tipoAviones or {}

-----------------------------------------------------------------------------------PLANES USA

-- ===============================
-- TANQUES PACK
-- ==============================
tipoAviones["FUEL-TANK-PACK"] = {
    costo = 10374000,

    tanques = {
        ["Fuel Tank Ft600"]  = {ws = {1, 3, 43, 103}, cantidad = 4},
        ["Fuel Tank 300 Gallons"]  = {ws = {1, 3, 43, 2740}, cantidad = 10},
        ["AJS External-tank 1013kg fuel"]  = {ws = {1, 3, 43, 294}, cantidad = 2},
        ["Aero 1D 300 Gallons Fuel Tank"]  = {ws = {1, 3, 43, 1572}, cantidad = 2},
        ["Fuel tank 610 Gal"]  = {ws = {1, 3, 43, 10}, cantidad = 16},
        ["F-5 275Gal Fuel tank"]  = {ws = {1, 3, 43, 36}, cantidad = 8},
        ["FPU-8A Fuel Tank 330 Gallons"]  = {ws = {1, 3, 43, 587}, cantidad = 20},
        ["Fuel Tank 300 Gal"]  = {ws = {1, 3, 43, 485}, cantidad = 20},
        ["Fuel Tank 370 Gal"]  = {ws = {1, 3, 43, 11}, cantidad = 10},
        ["RPL 541 2000 Liters Fuel Tank"]  = {ws = {1, 3, 43, 604}, cantidad = 4},
        ["RPL 522 1300 Liters Fuel Tank"]  = {ws = {1, 3, 43, 605}, cantidad = 4},
        ["Fuel Tank 800 L (21)"]  = {ws = {1, 3, 43, 14}, cantidad = 4},
        ["RPL201 Pylon Fuel Tank (2310 / Usable)"]  = {ws = {1, 3, 43, 1470}, cantidad = 2},
        ["Sargent Fletcher Fuel Tank 600 Gallons"]  = {ws = {1, 3, 43, 2146}, cantidad = 20},
        ["Sargent Fletcher Fuel Tank 370 Gallons"]  = {ws = {1, 3, 43, 2144}, cantidad = 20},
        ["800L Tank"]  = {ws = {1, 3, 43, 465}, cantidad = 6},
        ["Fuel Tank 230 Gal"]  = {ws = {1, 3, 43, 1056}, cantidad = 8},
        ["Fuel tank PTB-450"]  = {ws = {1, 3, 43, 855}, cantidad = 4}
    }
}
tipoAviones["ECM-DATALINK-PACK"] = {
    costo = 11700000,

    misc = {
        ["ALQ-184 Long - ECM Pod"]  = {ws = {4, 15, 45, 968}, cantidad = 2},
        ["BARAX - ECM Pod"]  = {ws = {4, 15, 45, 1762}, cantidad = 1},
        ["ALQ-131 - ECM Pod Rack"]  = {ws = {4, 15, 45, 25}, cantidad = 2},
        ["AWW-13 DATALINK POD"]  = {ws = {4, 15, 44, 424}, cantidad = 1},
        ["AN/AAQ-13 LANTIRN NAV POD"]  = {ws = {4, 15, 44, 1717}, cantidad = 1},
        ["DATALINK POD"]  = {ws = {4, 15, 44, 461}, cantidad = 1},
        ["L-081 Fantasmagoria ELINT pod"]  = {ws = {4, 15, 44, 65}, cantidad = 2},
        ["KG-600"]  = {ws = {4, 15, 45, 462}, cantidad = 1}
    
    }
}
tipoAviones["COUNTERMEASURES"] = {
    costo = 9900000,

    misc = {
        ["Eclair-M 4/2 : 32 flares 36 chaffs"]  = {ws = {4, 15, 48, 1170}, cantidad = 2},
        ["ALE-40 Dispensers (30 Flares + 60 Chaff)"]  = {ws = {4, 15, 44, 2140}, cantidad = 6},
        ["Expanded Chaff Adapter"]  = {ws = {4, 15, 44, 2287}, cantidad = 2},
        ["ASO-2 - countermeasures pod"]  = {ws = {4, 15, 48, 666}, cantidad = 6}
    
    }
}
tipoAviones["TARGETING"] = {
    costo = 31130000,

    misc = {
        ["AN/AAQ-28 LITENING - Targeting Pod"]  = {ws = {4, 15, 44, 425}, cantidad = 4},
        ["AN/AAQ-14 LANTIRN TGT Pod"]  = {ws = {4, 15, 44, 1718}, cantidad = 2},
        ["AN/AVQ-23 Pave Spike - Targeting Pod Rack"]  = {ws = {4, 15, 44, 2148}, cantidad = 1},
        ["AVIC WMD7 FLIR/LDT POD"]  = {ws = {4, 15, 44, 463}, cantidad = 1},
        ["AN/ASQ-213 - HARM Targeting System"]  = {ws = {4, 15, 44, 808}, cantidad = 2},
        ["Mercury LLTV pod"]  = {ws = {4, 15, 44, 19}, cantidad = 2},
        ["Tactial Airborne Recon Pod System"]  = {ws = {4, 15, 44, 2286}, cantidad = 2},
        ["AN/APG-78 FCR/RFI"]  = {ws = {4, 15, 44, 2114}, cantidad = 2}
       
    
    }
}
tipoAviones["MK82"] = {
    costo = 44000,

    bombas = {
        ["Mk-82 - 500lb GP Bomb LD "]  = {ws = {4, 5, 8, 31}, cantidad = 20},
        ["Mk-82 - Snakeeye 500lb GP Bomb HD   "]  = {ws = {4, 5, 8, 79}, cantidad = 10}
       }
}
tipoAviones["GBUL"] = {
    costo = 617000,

    bombas_guiadas = {
        ["GBU-12 - 500lb Laser Guided Bomb"]  = {ws = {4, 5, 36, 38}, cantidad = 20},
        ["GBU-10 - 2000lb Laser Guided Bomb"]  = {ws = {4, 5, 36, 36}, cantidad = 4},
        ["GBU-24A/B Paveway III - 2000lb Laser Guided Bomb"]  = {ws = {4, 5, 36, 41}, cantidad = 1}
       }
}
tipoAviones["GBUJ"] = {
    costo = 1040000,

    bombas_guiadas = {
        ["GBU-31(V)1/B - JDAM, 2000lb GPS Guided Bomb"]  = {ws = {4, 5, 36, 85}, cantidad = 4},
        ["GBU-31(V)3/B - JDAM, 2000lb GPS Guided Penetrator Bomb"]  = {ws = {4, 5, 36, 92}, cantidad = 2},
        ["GBU-38(V)1/B - JDAM, 500lb GPS Guided Bomb"]  = {ws = {4, 5, 36, 86}, cantidad = 20}
       }
}
tipoAviones["JSOW"] = {
    costo = 6400000,

    bombas_guiadas = {
        ["AGM-154A - JSOW CEB (CBU-type)"]  = {ws = {4, 4, 8, 280}, cantidad = 4},
        ["AGM-154C - JSOW Unitary BROACH"]  = {ws = {4, 4, 8, 132}, cantidad = 2}
    }
}
tipoAviones["FAB"] = {
    costo = 260000,

    bombas = {
        ["FAB-250 - 250kg GP Bomb LD"]  = {ws = {4, 5, 9, 6}, cantidad = 20},
        ["FAB-250 - 500kg GP Bomb LD"]  = {ws = {4, 5, 9, 7}, cantidad = 20},
        ["BetAB-500ShP - 500kg Concrete Piercing HD w booster Bomb"]  = {ws = {4, 5, 37, 4}, cantidad = 10}
    }
}
tipoAviones["SAMPB"] = {
    costo = 40000,

    bombas = {
        ["SAMP-250 - 250 kg GP Bomb LD"]  = {ws = {4, 5, 9, 389}, cantidad = 20}
        }
}
tipoAviones["GB-6"] = {
    costo = 2680000,

    bombas_guiadas = {
        ["GB-6"]  = {ws = {4, 4, 8, 295}, cantidad = 20},
        ["GB-6-HE"]  = {ws = {4, 4, 8, 298}, cantidad = 20}
    }
}
tipoAviones["LS6"] = {
    costo = 1800000,

    bombas_guiadas = {
        ["LS-6-250 Bomb"]  = {ws = {4, 4, 8, 433}, cantidad = 20},
        ["LS-6-500 Bomb"]  = {ws = {4, 4, 8, 432}, cantidad = 10}
    }
}
tipoAviones["DURAN"] = {
    costo = 480000,

    bombas = {
        ["Durandal Concrete Piercing"]  = {ws = {4, 5, 7, 62}, cantidad = 40}
       
    }
}
tipoAviones["AGM-84"] = {
    costo = 10500000,

    misiles = {
        ["AGM-84D Harpoon AShM"]  = {ws = {4, 4, 8, 278}, cantidad = 4},
        ["AGM-84H SLAM-ER (Expanded Response)"]  = {ws = {4, 4, 8, 279}, cantidad = 1}
       
    }
}
tipoAviones["KH01"] = {
    costo = 2900000,

    misiles = {
        ["Kh-25 ML (As-10 Karen) - 300kg, ASM, Semi-Act Laser"]  = {ws = {4, 4, 8, 45}, cantidad = 4},
        ["Kh-29T (AS-14 Kedge) - 670kg, ASM, TV Guided"]  = {ws = {4, 4, 8, 75}, cantidad = 2}
       
    }
}
tipoAviones["CM"] = {
    costo = 4500000,

    misiles = {
        ["C-802AK"]  = {ws = {4, 4, 8, 362}, cantidad = 2},
        ["CM802AKG (DIS)"]  = {ws = {4, 4, 8, 304}, cantidad = 2}
       
    }
}
tipoAviones["SEAD01"] = {
    costo = 3500000,

    misiles = {
        ["AGM-88C HARM -  High Speed Anti-Radiation Missile"]  = {ws = {4, 4, 8, 65}, cantidad = 10}
       }
}
tipoAviones["SEAD02"] = {
    costo = 800000,

    misiles = {
        ["AGM-45A Shrike ARM"]  = {ws = {4, 4, 8, 60}, cantidad = 10}
       }
}
tipoAviones["SEAD03"] = {
    costo = 5600000,

    misiles = {
        ["Kh-58U (AS-11 kIIter - 640kg, ARM, IN & Pas Rdr)"]  = {ws = {4, 4, 8, 46}, cantidad = 2},
        ["Kh-25MPU (Updated AS-12 Kegler - 320kg, ARM, IN & Pas Rdr)"]  = {ws = {4, 4, 8, 287}, cantidad = 6}
       }
}
tipoAviones["SEAD04"] = {
    costo = 2400000,

    misiles = {
        ["LD-10"]  = {ws = {4, 4, 8, 305}, cantidad = 4}
       }
}
tipoAviones["ATGM01"] = {
    costo = 2220000,

    misiles_guiados = {
        ["AGM-65D - Maverick D (IIR ASM)"]  = {ws = {4, 4, 8, 77}, cantidad = 6},
        ["AGM-65E - Maverick E (Laser)"]  = {ws = {4, 4, 8, 70}, cantidad = 6}
       }
}
tipoAviones["ATGM02"] = {
    costo = 4250000,

    misiles_guiados = {
        ["AGM-114L Hellfire"]  = {ws = {4, 4, 8, 59}, cantidad = 20},
        ["AGM-114K Hellfire"]  = {ws = {4, 4, 8, 39}, cantidad = 10}
       }
}
tipoAviones["ATGM03"] = {
    costo = 4500000,

    misiles_guiados = {
        ["9M120 Ataka (AT-9 Spíral-2) ATGM. SACLOS, Tandem HEAT"]  = {ws = {4, 4, 8, 353}, cantidad = 10},
        ["9M120F Ataka (AT-9 Spíral-2) AGM, SACLOS. HE"]  = {ws = {4, 4, 8, 354}, cantidad = 10},
        ["9M127 Vikhr - ATGM, LOSBR, Tandem HEAT/Frag"]  = {ws = {4, 4, 8, 58}, cantidad = 20}
       }
}
tipoAviones["ATGM04"] = {
    costo = 1280000,

    misiles_guiados = {
        ["HOT-3 ATGM. SACLOS HEAT"]  = {ws = {4, 4, 8, 407}, cantidad = 16}
       }
}
tipoAviones["COHETES01"] = {
    costo = 4260000,

    misiles_guiados = {
        ["Laser Guided Rkts, 70 mm Hydra 70 M151 HE APKWS"]  = {ws = {4, 4, 8, 292}, cantidad = 60},
        ["Laser Guided Rkts, 70 mm Hydra 70 M282 MPP APKWS"]  = {ws = {4, 4, 8, 293}, cantidad = 60}
       }
}
tipoAviones["COHETES02"] = {
    costo = 900000,

    cohetes = {
        ["UnGd Rkts, 70 mm Hydra 70 M151 HE"]  = {ws = {4, 7, 33, 147}, cantidad = 60},
        ["UnGd Rkts, 70 mm Hydra 70 Mk 5 HEAT"]  = {ws = {4, 7, 33, 145}, cantidad = 60},
        ["UnGd Rkts, 70 mm Hydra 70 Mk1 HE"]  = {ws = {4, 7, 33, 144}, cantidad = 60}
        
       }
}
tipoAviones["COHETES03"] = {
    costo = 1164000,

    cohetes = {
        ["UnGd Rkts, 57 mm S-5M HE"]  = {ws = {4, 7, 33, 442}, cantidad = 60},
        ["UnGd Rkts, 57 mm S-5KP HEAT/Frag"]  = {ws = {4, 7, 33, 441}, cantidad = 60},
        ["UnGd Rkts, 80 mm S-8KOM HEAT/Frag"]  = {ws = {4, 7, 33, 32}, cantidad = 60},
        ["UnGd Rkts, 80 mm S-8OFP2 MPP"]  = {ws = {4, 7, 33, 155}, cantidad = 60}
        
       }
}
tipoAviones["COHETES04"] = {
    costo = 150000,

    cohetes = {
        ["UnGd Rkts, 68 mm SNEB Type 251 F1B HE"]  = {ws = {4, 7, 33, 376}, cantidad = 60}
       }
}
tipoAviones["COHETES05"] = {
    costo = 2100000,

    cohetes = {
        ["BRM-1_90MM"]  = {ws = {4, 4, 8, 298}, cantidad = 60}
       }
}
tipoAviones["SENUELOS"] = {
    costo = 1200000,

    cohetes = {
        ["ADM-141A TALD"]  = {ws = {4, 4, 8, 289}, cantidad = 60}
       }
}






