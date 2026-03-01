do
    -- =========================================================
    -- MOTOR DE REGLAS AND (multi-flag) -> pulso de salida (one-shot)
    -- =========================================================

    local function flagIsOn(flagId)
        return trigger.misc.getUserFlag(flagId) == 1
    end

    local function allFlagsOn(flags)
        for i = 1, #flags do
            if not flagIsOn(flags[i]) then
                return false
            end
        end
        return true
    end

    local function pulseFlag(flagId, seconds)
        trigger.action.setUserFlag(flagId, 1)
        timer.scheduleFunction(function()
            trigger.action.setUserFlag(flagId, 0)
            return nil
        end, nil, timer.getTime() + seconds)
    end

    -- =========================================================
    -- CONFIG: agrega reglas aquí
    -- =========================================================
    local rules = {
        -- EJEMPLO 1: (3000 AND 3001) -> pulso 3002 durante 5s, one-shot
        {
            name = "01",
            inputs = { 3000, 3001 },
            out = 3002,
            pulse = 5,
            interval = 1,
            oneShot = true,
        },

        -- EJEMPLO 2: (3500 AND 3600 AND 3700) -> pulso 3800 durante 5s
        -- (cambia 3800 por la X bandera que quieras)
        {
            name = "02",
            inputs = { 3003, 3004 },
            out = 3005,
            pulse = 5,
            interval = 1,
            oneShot = true,
        },

        {
            name = "03",
            inputs = { 3006, 3007 },
            out = 3008,
            pulse = 7,
            interval = 1,
            oneShot = true,
        },
         {
            name = "04",
            inputs = { 3013, 3014, 3015 },
            out = 3016,
            pulse = 7,
            interval = 1,
            oneShot = true,
        },
    }

    -- Estado interno de reglas (no toca tus flags de input)
    for i = 1, #rules do
        rules[i]._done = false
    end

    -- =========================================================
    -- Scheduler por regla (cada regla se mata sola al disparar)
    -- =========================================================
    for i = 1, #rules do
        local r = rules[i]

        local function loopRule()
            if r._done then
                return nil -- esta regla ya se completó y muere
            end

            if allFlagsOn(r.inputs) then
                pulseFlag(r.out, r.pulse or 5)

                if r.oneShot ~= false then
                    r._done = true
                    return nil -- MUERE aquí (trigger de un solo disparo)
                end
            end

            return timer.getTime() + (r.interval or 1)
        end

        timer.scheduleFunction(loopRule, nil, timer.getTime() + (r.interval or 1))
    end
end
