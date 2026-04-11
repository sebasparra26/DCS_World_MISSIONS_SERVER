local loaderPath = lfs.writedir() .. "Scripts\\HorizontDev\\SinaiCampaignSystem\\CTDL\\CTDL_Load.lua"

local chunk, err = loadfile(loaderPath)
if not chunk then
    env.error("[HDEV-BOOT] No se pudo cargar CTDL_load.lua: " .. tostring(err))
    trigger.action.outText("[HDEV-BOOT] Error cargando CTDL_load.lua. Revisa ruta y nombre del archivo.", 15)
    return
end

local ok, runErr = pcall(chunk)
if not ok then
    env.error("[HDEV-BOOT] Error ejecutando CTDL_load.lua: " .. tostring(runErr))
    trigger.action.outText("[HDEV-BOOT] Error ejecutando CTDL_load.lua. Revisa dcs.log", 15)
end