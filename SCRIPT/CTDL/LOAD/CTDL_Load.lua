HDEV_LOADER = HDEV_LOADER or {}

HDEV_LOADER.debug = true
HDEV_LOADER.rootRelativePath = "Scripts\\HorizontDev\\SinaiCampaignSystem\\CTDL\\"

HDEV_LOADER.modules = {
    { name = "CTLD-i18n",   relPath = "CTLD-i18n.lua",   delay = 1, required = false },
    { name = "CTLD",        relPath = "CTLD.lua",        delay = 2, required = true  },
    { name = "CTLD Config", relPath = "CTLD_config.lua", delay = 3, required = true  },
}

function HDEV_LOADER.log(msg)
    env.info("[HDEV-LOADER] " .. tostring(msg))
    if HDEV_LOADER.debug then
        trigger.action.outText("[HDEV-LOADER] " .. tostring(msg), 8)
    end
end

function HDEV_LOADER.buildAbsPath(relPath)
    return lfs.writedir() .. HDEV_LOADER.rootRelativePath .. relPath
end

function HDEV_LOADER.runFile(mod)
    local absPath = HDEV_LOADER.buildAbsPath(mod.relPath)

    local chunk, err = loadfile(absPath)
    if not chunk then
        HDEV_LOADER.log("ERROR cargando " .. mod.name .. ": " .. tostring(err))
        return false
    end

    local ok, runErr = pcall(chunk)
    if not ok then
        HDEV_LOADER.log("ERROR ejecutando " .. mod.name .. ": " .. tostring(runErr))
        return false
    end

    HDEV_LOADER.log("OK -> " .. mod.name)
    return true
end

function HDEV_LOADER.scheduleModule(mod)
    timer.scheduleFunction(function()
        local ok = HDEV_LOADER.runFile(mod)

        if (not ok) and mod.required then
            HDEV_LOADER.log("MODULO REQUERIDO FALLÓ -> " .. mod.name)
        end

        return nil
    end, {}, timer.getTime() + (mod.delay or 1))
end

function HDEV_LOADER.start()
    HDEV_LOADER.log("Iniciando secuencia de carga CTLD...")
    for _, mod in ipairs(HDEV_LOADER.modules) do
        HDEV_LOADER.scheduleModule(mod)
    end
end

HDEV_LOADER.start()