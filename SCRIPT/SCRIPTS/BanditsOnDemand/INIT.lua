-- ===============================================
--  Script de inicialización para Bandits On Demand
--  Autor: Sebastián Parra
-- ===============================================

-- ==============================
-- CONFIGURACIÓN EDITABLE
-- ==============================
local flagOn = 1               -- Flag que se activa (ON)
local msgDelay = 10            -- Duración del mensaje inicial (segundos)

local flagRandom1 = 3001       -- Flag aleatoria #1
local rand1_min = 1            -- Valor mínimo
local rand1_max = 4            -- Valor máximo

local flagRandom2 = 3002       -- Flag aleatoria #2
local rand2_min = 0            -- Valor mínimo
local rand2_max = 9            -- Valor máximo

-- Flags que se apagan (OFF)
local flagOff_1 = 3003
local flagOff_2 = 3005
local flagOff_3 = 3006

local debugMode = true         -- Mostrar mensajes de debug (true/false)
-- ==============================


-- Mensaje inicial
trigger.action.outText("Loading Bandit On Demand BFM & BVR Training Program. Please wait...", msgDelay)

-- 1. Flag ON
trigger.action.setUserFlag(tostring(flagOn), true)

-- 2. Flag aleatoria #1
local randomValue1 = math.random(rand1_min, rand1_max)
trigger.action.setUserFlag(tostring(flagRandom1), randomValue1)

-- 3. Flag aleatoria #2
local randomValue2 = math.random(rand2_min, rand2_max)
trigger.action.setUserFlag(tostring(flagRandom2), randomValue2)

-- 4. Flags OFF
trigger.action.setUserFlag(tostring(flagOff_1), false)
trigger.action.setUserFlag(tostring(flagOff_2), false)
trigger.action.setUserFlag(tostring(flagOff_3), false)

-- 5. Mensajes de debug opcionales
if debugMode then
    local msg = string.format(
        "[DEBUG] Flags inicializadas:\n" ..
        "Flag %s = ON\n" ..
        "Flag %s = %d\n" ..
        "Flag %s = %d\n" ..
        "Flag %s = OFF\n" ..
        "Flag %s = OFF\n" ..
        "Flag %s = OFF",
        flagOn, flagRandom1, randomValue1, flagRandom2, randomValue2,
        flagOff_1, flagOff_2, flagOff_3
    )
    trigger.action.outText(msg, msgDelay)
end
