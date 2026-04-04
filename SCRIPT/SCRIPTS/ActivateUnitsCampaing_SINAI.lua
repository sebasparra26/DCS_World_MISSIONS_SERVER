local debugActivo = true

local grupos = {
    [100] = { rojo = "RU_100_Difarsuwar", azul = "US_100_Difarsuwar" },
    [101] = { rojo = "RU_101_AbuS", azul = "US_101_AbuS" },
    [102] = { rojo = "RU_102_AsS", azul = "US_102_AsS" },
    [103] = { rojo = "RU_103_Ismailiyah", azul = "US_103_Ismailiyah" },
    [104] = { rojo = "RU_104_Melez", azul = "US_104_Melez" },
    [105] = { rojo = "RU_105_Fayed", azul = "US_105_Fayed" },
    [106] = { rojo = "RU_106_Hatzerim", azul = "US_106_Hatzerim" },
    [107] = { rojo = "RU_107_Nevatim", azul = "US_107_Nevatim" },
    [108] = { rojo = "RU_108_Ramon", azul = "US_108_Ramon" },
    [109] = { rojo = "RU_109_Ovda", azul = "US_109_Ovda" },
    [110] = { rojo = "RU_110_Kibrit", azul = "US_110_Kibrit" },
    [111] = { rojo = "RU_111_Kedem", azul = "US_111_Kedem" },
    [112] = { rojo = "RU_112_WadiJ", azul = "US_112_WadiJ" },
    [113] = { rojo = "RU_113_AlM", azul = "US_113_AlM" },
    [114] = { rojo = "RU_114_AzZaqaziq", azul = "US_114_AzZaqaziq" },
    [115] = { rojo = "RU_115_Bilbeis", azul = "US_115_Bilbeis" },
    [116] = { rojo = "RU_116_Cairo", azul = "US_116_Cairo" },
    [117] = { rojo = "RU_117_CairoW", azul = "US_117_CairoW" },
    [118] = { rojo = "RU_118_Inshas", azul = "US_118_Inshas" },
    [119] = { rojo = "RU_119_Hatzor", azul = "US_119_Hatzor" },
    [120] = { rojo = "RU_120_Palmachim", azul = "US_120_Palmachim" },
    [121] = { rojo = "RU_121_SdeD", azul = "US_121_SdeD" },
    [122] = { rojo = "RU_122_TelN", azul = "US_122_TelN" },
    [123] = { rojo = "RU_123_BenG", azul = "US_123_BenG" },
    [124] = { rojo = "RU_124_StC", azul = "US_124_StC" },
    [125] = { rojo = "RU_125_AbuR", azul = "US_125_AbuR" },
    [126] = { rojo = "RU_126_Baluza", azul = "US_126_Baluza" },
    [127] = { rojo = "RU_127_BirH", azul = "US_127_BirH" },
    [128] = { rojo = "RU_128_ElA", azul = "US_128_ElA" },
    [129] = { rojo = "RU_129_ElG", azul = "US_129_ElG" },
    [130] = { rojo = "RU_130_AlK", azul = "US_130_AlK" },
    [131] = { rojo = "RU_131_AlR", azul = "US_131_AlR" },
    [132] = { rojo = "RU_132_Beni", azul = "US_132_Beni" },
    [133] = { rojo = "RU_133_Birma", azul = "US_133_Birma" },
    [134] = { rojo = "RU_134_Borg", azul = "US_134_Borg" },
    [135] = { rojo = "RU_135_ElM", azul = "US_135_ElM" },
    [136] = { rojo = "RU_136_Gebel", azul = "US_136_Gebel" },
    [137] = { rojo = "RU_137_Hurghada", azul = "US_137_Hurghada" },
    [138] = { rojo = "RU_138_Jiyanklis", azul = "US_138_Jiyanklis" },
    [139] = { rojo = "RU_139_Kom", azul = "US_139_Kom" },
    [140] = { rojo = "RU_140_RamonI", azul = "US_140_RamonI" },
    [141] = { rojo = "RU_141_Sharm", azul = "US_141_Sharm" },
    [142] = { rojo = "RU_142_WadiR", azul = "US_142_WadiR" },
    [143] = { rojo = "RU_143_AlB", azul = "US_143_AlB" },
    [144] = { rojo = "RU_144_Quwaysina", azul = "US_144_Quwaysina" },
    [145] = { rojo = "RU_145_Rafic", azul = "US_145_Rafic" },
    [146] = { rojo = "RU_146_Tabuk", azul = "US_146_Tabuk" },
    [147] = { rojo = "RU_147_Damascus", azul = "US_147_Damascus" },
    [148] = { rojo = "RU_148_Mezzeh", azul = "US_148_Mezzeh" },
    [149] = { rojo = "RU_149_Ramat", azul = "US_149_Ramat" },
    [150] = { rojo = "RU_150_Megiddo", azul = "US_150_Megiddo" },
    [151] = { rojo = "RU_151_Ein", azul = "US_151_Ein" },
    [152] = { rojo = "RU_152_Taba", azul = "US_152_Taba" },
    [153] = { rojo = "RU_153_KingF", azul = "US_153_KingF" },
    [154] = { rojo = "RU_154_Khalkhalah", azul = "US_154_Khalkhalah" },
}

local contadores = {}
local estadoPrevio = {}  -- Guarda el último valor leído de cada bandera

local function verificarBanderas()
    for bandera, data in pairs(grupos) do
        local valor = trigger.misc.getUserFlag(bandera)
        local valorPrevio = estadoPrevio[bandera]

        if valor ~= valorPrevio then
            estadoPrevio[bandera] = valor  -- Actualizar nuevo estado

            if valor == 1 then
                local nombreGrupo = data.rojo
                contadores[nombreGrupo] = (contadores[nombreGrupo] or 0) + 1
                local nuevoNombre = nombreGrupo .. "_Clone_" .. contadores[nombreGrupo]

                mist.cloneGroup(nombreGrupo, true, nuevoNombre)

                if debugActivo then
                    trigger.action.outText("Grupo ROJO '" .. nuevoNombre .. "' ACTIVADO (bandera " .. bandera .. ")", 10)
                end
                env.info("Grupo ROJO '" .. nuevoNombre .. "' clonado por bandera " .. bandera .. " = 1")

            elseif valor == 2 then
                local nombreGrupo = data.azul
                contadores[nombreGrupo] = (contadores[nombreGrupo] or 0) + 1
                local nuevoNombre = nombreGrupo .. "_Clone_" .. contadores[nombreGrupo]

                mist.cloneGroup(nombreGrupo, true, nuevoNombre)

                if debugActivo then
                    trigger.action.outText("Grupo AZUL '" .. nuevoNombre .. "' ACTIVADO (bandera " .. bandera .. ")", 10)
                end
                env.info("Grupo AZUL '" .. nuevoNombre .. "' clonado por bandera " .. bandera .. " = 2")
            end
        end
    end

    return timer.getTime() + 2
end

timer.scheduleFunction(verificarBanderas, {}, timer.getTime() + 2)

