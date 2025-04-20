-- VisMenu (Optimizado)

-- Configuración inicial
local thickness = 2000  -- Grosor predeterminado de la niebla (metros MSL)

-- Función genérica para ajustar visibilidad
function setVisibility(flag, visDistance, fogThickness)
    world.weather.setFogThickness(fogThickness or thickness)  
    world.weather.setFogVisibilityDistance(visDistance)
    trigger.action.setUserFlag(flag, 0)  -- Restablecer flag
end

-- Opciones de visibilidad
function zero_zero() setVisibility("Visibility_0/0", 1) end
function quarter_mile() setVisibility("Visibility_1/4_Mile", 463) end
function half_mile() setVisibility("Visibility_1/2_Mile", 926) end
function three_quarter_mile() setVisibility("Visibility_3/4_Mile", 1389) end
function one_mile() setVisibility("Visibility_1_Mile", 1852) end
function three_miles() setVisibility("Visibility_3_Miles", 5556) end
function five_miles() setVisibility("Visibility_5_Miles", 9260) end
function seven_miles() setVisibility("Visibility_7_Miles", 12964) end
function ten_miles() setVisibility("Visibility_10_Miles", 18520) end
function unlimited_visibility() setVisibility("Visibility_Unlimited", 200000, 2) end

-- Menú de opciones de visibilidad
local M1 = missionCommands.addSubMenu("Visibility Options", nil)
missionCommands.addCommand("Visibility Unlimited", M1, unlimited_visibility)
missionCommands.addCommand("Visibility 10 Miles", M1, ten_miles)
missionCommands.addCommand("Visibility 7 Miles", M1, seven_miles)
missionCommands.addCommand("Visibility 5 Miles", M1, five_miles)
missionCommands.addCommand("Visibility 3 Miles", M1, three_miles)
missionCommands.addCommand("Visibility 1 Mile", M1, one_mile)
missionCommands.addCommand("Visibility 3/4 Mile", M1, three_quarter_mile)
missionCommands.addCommand("Visibility 1/2 Mile", M1, half_mile)
missionCommands.addCommand("Visibility 1/4 Mile", M1, quarter_mile)
missionCommands.addCommand("Visibility 0/0", M1, zero_zero)