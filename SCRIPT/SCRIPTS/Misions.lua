----------------------------------------------------------------
-- HDEV_MissionSystem.lua
-- Sistema avanzado de misiones secuenciales con persistencia JSON
--
-- CARACTERISTICAS:
-- - Persistencia JSON por mision
-- - Solo 1 mision activa a la vez
-- - Estados por mision:
--      0 = no iniciada
--      1 = activa
--      2 = completada
--      3 = fallida
-- - Validacion por warehouse
-- - Validacion por flags internas de cada mision
-- - Validacion por grupos y unidades
-- - Pagos por objetivo y pago final por mision
-- - Marca F10 por mision
-- - Menu F10 para revisar estado
--
-- REQUISITOS:
-- - io, lfs y net.json2lua habilitados
-- - Si HDEV_Economy esta cargado, se usan pagos reales
--
-- NOTA:
-- - SOLO dejo M01 activa como placeholder real
-- - La estructura de M02 en adelante queda lista para copiar
----------------------------------------------------------------

HDEV_MissionSystem = HDEV_MissionSystem or {}
local MS = HDEV_MissionSystem

----------------------------------------------------------------
-- ESTADOS DE MISION
----------------------------------------------------------------
MS.STATUS = {
    NOT_STARTED = 0,
    ACTIVE = 1,
    COMPLETED = 2,
    FAILED = 3
}

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
MS.CONFIG = MS.CONFIG or {
    DEBUG = true,

    FILE_PATH = (lfs and lfs.writedir and (lfs.writedir() .. "Config\\HorizontDev\\SystemMissionPersistence.json"))
        or "Config\\HorizontDev\\SystemMissionPersistence.json",

    IMPORT_WINDOW_SECONDS = 30,
    AUTOSAVE_INTERVAL = 10,
    MIN_WRITE_INTERVAL = 5,
    MAIN_LOOP_INTERVAL = 1,

    MENU_NAME = "Sistema de Misiones",

    MARKS_ENABLED = true,
    MARK_READONLY = true,
    MARK_ID_START = 950000
}

----------------------------------------------------------------
-- DEFINICION DE MISIONES
-- TODO lo que valida la mision vive dentro de su propio bloque.
----------------------------------------------------------------
MS.MISSIONS = {
    {
        id = "M01",
        order = 1,
        enabled = true,

        name = "Rescate de 4 F-16",
        shortName = "M01",

        briefing =
            "OBJETIVO:\n" ..
            "Extraer 4 F-16 desde la base indicada.\n\n" ..
            "VALIDACION PRINCIPAL:\n" ..
            "El sistema revisa el warehouse de la base y confirma que el item F-16C_50\n" ..
            "disminuyo en 4 unidades respecto al valor inicial detectado.\n\n" ..
            "PAGOS:\n" ..
            "Objetivo opcional: 1.000.000\n" ..
            "Mision completada: 500.000.000\n\n" ..
            "IMPORTANTE:\n" ..
            "Reemplaza BASE_AQUI y ZONA_MISION_01 por tus nombres reales.",

        autoStart = true,

        activationConditions = {
            -- vacio = al ser la primera, puede iniciar cuando la campaña arranca
        },

        map = {
            zoneName = "ZONA_MISION_01",
            title = "M01 - Rescate F-16",
            text =
                "MISION 01\n" ..
                "Rescate de 4 F-16\n\n" ..
                "Consulta F10 > Sistema de Misiones"
        },

        flags = {
            onActivate = {
                { flag = 2100, value = 1 },
            },
            onSuccess = {
                { flag = 2101, value = 1 },
            },
            onFail = {
                { flag = 2102, value = 1 },
            },
        },

        missionFlagRules = {
            -- Estas reglas SOLO viven dentro de esta mision.
            -- Ejemplo:
            -- si 1000 y 1001 son 1, entonces 1002 = 1
            {
                id = "M01_REGLA_01",
                enabled = false,
                conditions = {
                    { flag = 1000, op = "==", value = 1 },
                    { flag = 1001, op = "==", value = 1 },
                },
                onTrue = {
                    { flag = 1002, value = 1 }
                },
                onFalse = {
                    { flag = 1002, value = 0 }
                }
            }
        },

        validators = {
            warehouse = {
                {
                    key = "SALIDA_F16",
                    baseName = "BASE_AQUI",
                    category = "aircraft",
                    itemName = "F-16C_50",
                    removedAtLeast = 4,
                    setFlagOnPass = {
                        flag = 2001,
                        value = 1,
                        elseValue = 0
                    }
                }
            },

            groupChecks = {
                -- ejemplo:
                -- {
                --     key = "GRUPO_ESCOLTA_VIVO",
                --     groupName = "GrupoEscolta_AQUI",
                --     metric = "aliveUnits", -- aliveUnits | totalUnits | lifeSum | lifePercent
                --     op = ">=",
                --     value = 1,
                --     setFlagOnPass = {
                --         flag = 2002,
                --         value = 1,
                --         elseValue = 0
                --     }
                -- }
            },

            unitChecks = {
                -- ejemplo:
                -- {
                --     key = "UNIDAD_LIDER_VIVA",
                --     unitName = "Unidad_AQUI",
                --     metric = "lifePercent", -- alive | life | life0 | lifePercent
                --     op = ">",
                --     value = 0,
                --     setFlagOnPass = {
                --         flag = 2003,
                --         value = 1,
                --         elseValue = 0
                --     }
                -- }
            }
        },

        rewards = {
            enabled = true,
            coalition = 2, -- 1 rojo, 2 azul, 0 ambos

            missionSuccessAmount = 500000000,

            objectives = {
                {
                    id = "OBJ_SACAR_4_F16",
                    enabled = true,
                    coalition = 2,
                    amount = 1000000,
                    conditions = {
                        { flag = 2001, op = "==", value = 1 }
                    }
                }
            }
        },

        successConditions = {
            { flag = 2001, op = "==", value = 1 },
        },

        failConditions = {
            -- ejemplo:
            -- { flag = 2999, op = "==", value = 1 }
        }
    },

    ----------------------------------------------------------------
    -- PLANTILLA DE SIGUIENTE MISION
    ----------------------------------------------------------------
    -- {
    --     id = "M02",
    --     order = 2,
    --     enabled = true,
    --     name = "Nombre M02",
    --     shortName = "M02",
    --     briefing = "Briefing de la mision 02",
    --     autoStart = true,
    --     activationConditions = {
    --         { flag = 2101, op = "==", value = 1 }
    --     },
    --     map = {
    --         zoneName = "ZONA_MISION_02",
    --         title = "M02",
    --         text = "Texto de mapa M02"
    --     },
    --     flags = {
    --         onActivate = {
    --             { flag = 2200, value = 1 },
    --         },
    --         onSuccess = {
    --             { flag = 2201, value = 1 },
    --         },
    --         onFail = {
    --             { flag = 2202, value = 1 },
    --         }
    --     },
    --     missionFlagRules = {
    --     },
    --     validators = {
    --         warehouse = {},
    --         groupChecks = {},
    --         unitChecks = {}
    --     },
    --     rewards = {
    --         enabled = true,
    --         coalition = 2,
    --         missionSuccessAmount = 10000000,
    --         objectives = {}
    --     },
    --     successConditions = {},
    --     failConditions = {}
    -- },
}

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------
MS.STATE = MS.STATE or {
    initialized = false,
    writeEnabled = false,
    importWindowEndsAt = nil,

    dirty = false,
    lastWriteTime = 0,
    lastSavedPayload = "",
    lastAutosaveAt = 0,

    menuRoot = nil,

    currentMissionId = nil,
    managedFlags = {},
    missions = {},

    runtimeMarks = {},
    nextMarkId = nil
}

----------------------------------------------------------------
-- LOG
----------------------------------------------------------------
local function log(msg)
    env.info("[HDEV_MISSION] " .. tostring(msg))
    if MS.CONFIG.DEBUG then
        trigger.action.outText("[HDEV_MISSION] " .. tostring(msg), 6)
    end
end

local function warn(msg)
    env.info("[HDEV_MISSION] " .. tostring(msg))
end

----------------------------------------------------------------
-- UTILS
----------------------------------------------------------------
local function deepCopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end

    local out = {}
    for k, v in pairs(tbl) do
        out[k] = deepCopy(v)
    end
    return out
end

local function ensureNumber(v)
    local n = tonumber(v) or 0
    return n
end

local function normalizeFlagValue(v)
    if type(v) == "boolean" then
        return v and 1 or 0
    end

    local n = tonumber(v)
    if n ~= nil then
        return n
    end

    local s = tostring(v or ""):lower()
    if s == "true" then
        return 1
    end

    return 0
end

local function compareValues(left, op, right)
    left = ensureNumber(left)
    right = ensureNumber(right)

    if op == "==" then
        return left == right
    elseif op == "~=" then
        return left ~= right
    elseif op == ">" then
        return left > right
    elseif op == "<" then
        return left < right
    elseif op == ">=" then
        return left >= right
    elseif op == "<=" then
        return left <= right
    end

    return false
end

local function sortedKeys(tbl)
    local keys = {}
    for k, _ in pairs(tbl or {}) do
        keys[#keys + 1] = k
    end

    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)

    return keys
end

local function sortedMissionDefs()
    local defs = {}
    for _, def in ipairs(MS.MISSIONS or {}) do
        if def.enabled ~= false then
            defs[#defs + 1] = def
        end
    end

    table.sort(defs, function(a, b)
        local oa = tonumber(a.order) or 999999
        local ob = tonumber(b.order) or 999999
        if oa == ob then
            return tostring(a.id) < tostring(b.id)
        end
        return oa < ob
    end)

    return defs
end

local function getMissionDefById(id)
    for _, def in ipairs(MS.MISSIONS or {}) do
        if def.id == id then
            return def
        end
    end
    return nil
end

local function statusToText(status)
    if status == MS.STATUS.NOT_STARTED then
        return "NO_INICIADA"
    elseif status == MS.STATUS.ACTIVE then
        return "ACTIVA"
    elseif status == MS.STATUS.COMPLETED then
        return "COMPLETADA"
    elseif status == MS.STATUS.FAILED then
        return "FALLIDA"
    end
    return "DESCONOCIDO"
end

local function getFlagValue(flag)
    return normalizeFlagValue(trigger.misc.getUserFlag(flag))
end

local function setManagedFlag(flag, value)
    local n = normalizeFlagValue(value)
    trigger.action.setUserFlag(flag, n)
    MS.STATE.managedFlags[tostring(flag)] = n
    MS.STATE.dirty = true
end

local function applyManagedFlagsFromState()
    for flag, value in pairs(MS.STATE.managedFlags or {}) do
        trigger.action.setUserFlag(flag, normalizeFlagValue(value))
    end
end

local function allFlagConditionsTrue(conditions)
    for _, cond in ipairs(conditions or {}) do
        local current = getFlagValue(cond.flag)
        local op = cond.op or "=="
        local expected = cond.value or 1
        if not compareValues(current, op, expected) then
            return false
        end
    end
    return true
end

local function groupExistsByName(groupName)
    if not groupName then
        return nil
    end

    local grp = Group.getByName(groupName)
    if not grp then
        return nil
    end

    local ok, exists = pcall(function()
        return grp:isExist()
    end)

    if ok and exists then
        return grp
    end

    return nil
end

----------------------------------------------------------------
-- ECONOMIA
----------------------------------------------------------------
local function getEconomy()
    return HDEV_Economy
end

local function formatMoney(value)
    local econ = getEconomy()
    if econ and econ.formatMoney then
        return econ.formatMoney(tonumber(value) or 0)
    end
    return "$" .. tostring(math.floor(tonumber(value) or 0))
end

local function paySingleCoalition(coalition, amount, reason, missionId, rewardId)
    local econ = getEconomy()
    amount = tonumber(amount) or 0

    if amount <= 0 then
        return false
    end

    if not econ or not econ.add then
        warn("No hay sistema economico disponible para pagar recompensa.")
        return false
    end

    local before = econ.get and econ.get(coalition) or 0
    local after = econ.add(coalition, amount, reason or "recompensa")

    env.info(
        "[HDEV_MISSION_REWARD] coalicion=" .. tostring(coalition) ..
        " monto=" .. tostring(amount) ..
        " missionId=" .. tostring(missionId) ..
        " rewardId=" .. tostring(rewardId) ..
        " saldoAntes=" .. tostring(before) ..
        " saldoDespues=" .. tostring(after)
    )

    trigger.action.outTextForCoalition(
        coalition,
        "Recompensa recibida\n" ..
        "Mision: " .. tostring(missionId or "N/A") .. "\n" ..
        "Concepto: " .. tostring(rewardId or reason or "recompensa") .. "\n" ..
        "Valor: " .. formatMoney(amount),
        12
    )

    return true
end

local function payCoalition(coalition, amount, reason, missionId, rewardId)
    coalition = tonumber(coalition) or 2

    if coalition == 0 then
        local ok1 = paySingleCoalition(1, amount, reason, missionId, rewardId)
        local ok2 = paySingleCoalition(2, amount, reason, missionId, rewardId)
        return ok1 or ok2
    end

    if coalition ~= 1 and coalition ~= 2 then
        coalition = 2
    end

    return paySingleCoalition(coalition, amount, reason, missionId, rewardId)
end

----------------------------------------------------------------
-- FILE / JSON
----------------------------------------------------------------
local function safeReadFile(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end

    local txt = f:read("*a")
    f:close()
    return txt
end

local function ensureDirectoryForFile(path)
    if not lfs or not lfs.mkdir or not path or path == "" then
        return false
    end

    local separator = path:find("/") and "/" or "\\"
    local parts = {}

    for part in string.gmatch(path, "[^\\/]+") do
        parts[#parts + 1] = part
    end

    if #parts <= 1 then
        return false
    end

    table.remove(parts, #parts)

    local prefix = ""
    if path:match("^%a:[\\/]") then
        prefix = path:sub(1, 3)
    elseif path:sub(1, 1) == "/" then
        prefix = "/"
    end

    local current = prefix
    for _, part in ipairs(parts) do
        if current == "" or current:sub(-1) == separator then
            current = current .. part
        else
            current = current .. separator .. part
        end
        lfs.mkdir(current)
    end

    return true
end

local function safeWriteFile(path, txt)
    ensureDirectoryForFile(path)
    local f = io.open(path, "w")
    if not f then
        return false
    end

    f:write(txt or "")
    if f.flush then
        f:flush()
    end
    f:close()
    return true
end

local function decodeJson(txt)
    if not txt or txt == "" then
        return nil, "archivo vacio"
    end

    if not net or not net.json2lua then
        return nil, "net.json2lua no disponible"
    end

    local ok, data = pcall(net.json2lua, txt)
    if not ok then
        return nil, data
    end

    if type(data) ~= "table" then
        return nil, "json no devolvio tabla"
    end

    return data
end

local function jsonEscape(str)
    str = tostring(str or "")
    str = str:gsub("\\", "\\\\")
    str = str:gsub("\"", "\\\"")
    str = str:gsub("\r", "\\r")
    str = str:gsub("\n", "\\n")
    str = str:gsub("\t", "\\t")
    return str
end

local function isArray(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    local count = 0
    local maxIndex = 0
    for k, _ in pairs(tbl) do
        if type(k) ~= "number" then
            return false
        end
        count = count + 1
        if k > maxIndex then
            maxIndex = k
        end
    end

    return count == maxIndex
end

local function encodeJsonValue(value, indent)
    indent = indent or 0
    local pad = string.rep(" ", indent)
    local t = type(value)

    if t == "nil" then
        return "null"
    elseif t == "boolean" then
        return value and "true" or "false"
    elseif t == "number" then
        return tostring(value)
    elseif t == "string" then
        return "\"" .. jsonEscape(value) .. "\""
    elseif t ~= "table" then
        return "\"" .. jsonEscape(tostring(value)) .. "\""
    end

    if next(value) == nil then
        return isArray(value) and "[]" or "{}"
    end

    if isArray(value) then
        local lines = {"["}
        for i = 1, #value do
            local comma = (i < #value) and "," or ""
            lines[#lines + 1] = string.rep(" ", indent + 2) .. encodeJsonValue(value[i], indent + 2) .. comma
        end
        lines[#lines + 1] = pad .. "]"
        return table.concat(lines, "\n")
    end

    local keys = sortedKeys(value)
    local lines = {"{"}
    for i, key in ipairs(keys) do
        local comma = (i < #keys) and "," or ""
        lines[#lines + 1] =
            string.rep(" ", indent + 2) ..
            "\"" .. jsonEscape(tostring(key)) .. "\": " ..
            encodeJsonValue(value[key], indent + 2) ..
            comma
    end
    lines[#lines + 1] = pad .. "}"
    return table.concat(lines, "\n")
end

local function loadStateFromDisk()
    local txt = safeReadFile(MS.CONFIG.FILE_PATH)
    if not txt then
        return nil, "no existe archivo"
    end
    return decodeJson(txt)
end

----------------------------------------------------------------
-- STATE HELPERS
----------------------------------------------------------------
local function ensureMissionState(def)
    if not MS.STATE.missions[def.id] then
        MS.STATE.missions[def.id] = {
            id = def.id,
            order = def.order or 999999,
            status = MS.STATUS.NOT_STARTED,
            activatedAt = nil,
            completedAt = nil,
            failedAt = nil,

            validatorMemory = {},

            rewardsPaid = {
                objectives = {},
                missionSuccess = false
            }
        }
    end

    return MS.STATE.missions[def.id]
end

local function ensureRewardState(mState)
    mState.rewardsPaid = mState.rewardsPaid or {
        objectives = {},
        missionSuccess = false
    }
    return mState.rewardsPaid
end

local function initializeMissionStates()
    MS.STATE.missions = {}
    for _, def in ipairs(sortedMissionDefs()) do
        ensureMissionState(def)
    end
end

local function getPreviousMissionState(def)
    local defs = sortedMissionDefs()
    local prevDef = nil

    for _, other in ipairs(defs) do
        if other.id == def.id then
            break
        end
        prevDef = other
    end

    if not prevDef then
        return nil
    end

    return MS.STATE.missions[prevDef.id]
end

local function getActiveMissionDef()
    if not MS.STATE.currentMissionId then
        return nil
    end
    return getMissionDefById(MS.STATE.currentMissionId)
end

local function getActiveMissionState()
    local def = getActiveMissionDef()
    if not def then
        return nil
    end
    return ensureMissionState(def)
end

----------------------------------------------------------------
-- JSON SAVE / RESTORE
----------------------------------------------------------------
local function buildSaveDocument()
    local doc = {
        control = {
            importWindowSeconds = MS.CONFIG.IMPORT_WINDOW_SECONDS,
            autosaveInterval = MS.CONFIG.AUTOSAVE_INTERVAL,
            minWriteInterval = MS.CONFIG.MIN_WRITE_INTERVAL,
            mainLoopInterval = MS.CONFIG.MAIN_LOOP_INTERVAL
        },
        meta = {
            updatedAt = timer.getTime(),
            source = "HDEV_MissionSystem",
            currentMissionId = MS.STATE.currentMissionId,
            nextMarkId = MS.STATE.nextMarkId
        },
        managedFlags = deepCopy(MS.STATE.managedFlags or {}),
        missions = {}
    }

    for _, def in ipairs(sortedMissionDefs()) do
        local mState = ensureMissionState(def)
        doc.missions[def.id] = {
            id = def.id,
            order = def.order,
            name = def.name,
            shortName = def.shortName,
            status = mState.status,
            activatedAt = mState.activatedAt,
            completedAt = mState.completedAt,
            failedAt = mState.failedAt,
            validatorMemory = deepCopy(mState.validatorMemory or {}),
            rewardsPaid = deepCopy(mState.rewardsPaid or {
                objectives = {},
                missionSuccess = false
            })
        }
    end

    return doc
end

local function writeJsonToDisk(force)
    if not force then
        if not MS.STATE.writeEnabled then
            return false
        end

        local now = timer.getTime()
        if (now - (MS.STATE.lastWriteTime or 0)) < (MS.CONFIG.MIN_WRITE_INTERVAL or 5) then
            return false
        end
    end

    local payload = encodeJsonValue(buildSaveDocument(), 0)

    if not force and payload == MS.STATE.lastSavedPayload and not MS.STATE.dirty then
        return false
    end

    local ok = safeWriteFile(MS.CONFIG.FILE_PATH, payload)
    if not ok then
        warn("No se pudo escribir el JSON de misiones: " .. tostring(MS.CONFIG.FILE_PATH))
        return false
    end

    MS.STATE.lastSavedPayload = payload
    MS.STATE.lastWriteTime = timer.getTime()
    MS.STATE.dirty = false
    return true
end

local function restoreStateFromDoc(doc)
    if type(doc) ~= "table" then
        return
    end

    MS.STATE.managedFlags = deepCopy(doc.managedFlags or {})
    applyManagedFlagsFromState()

    if type(doc.missions) == "table" then
        for missionId, saved in pairs(doc.missions) do
            local def = getMissionDefById(missionId)
            if def then
                local mState = ensureMissionState(def)
                mState.status = tonumber(saved.status) or mState.status
                mState.activatedAt = saved.activatedAt
                mState.completedAt = saved.completedAt
                mState.failedAt = saved.failedAt
                mState.validatorMemory = deepCopy(saved.validatorMemory or {})
                mState.rewardsPaid = deepCopy(saved.rewardsPaid or {
                    objectives = {},
                    missionSuccess = false
                })
            end
        end
    end

    MS.STATE.currentMissionId = doc.meta and doc.meta.currentMissionId or nil
    MS.STATE.nextMarkId = tonumber(doc.meta and doc.meta.nextMarkId) or MS.CONFIG.MARK_ID_START
end

----------------------------------------------------------------
-- METRICAS UNIDADES / GRUPOS
----------------------------------------------------------------
local function getUnitMetrics(unitName)
    local out = {
        exists = false,
        alive = 0,
        life = 0,
        life0 = 0,
        lifePercent = 0
    }

    local unit = Unit.getByName(unitName)
    if not unit or not unit:isExist() then
        return out
    end

    local life = ensureNumber(unit:getLife())
    local life0 = ensureNumber(unit:getLife0())

    out.exists = true
    out.alive = (life > 0) and 1 or 0
    out.life = life
    out.life0 = life0

    if life0 > 0 then
        out.lifePercent = (life / life0) * 100
    elseif life > 0 then
        out.lifePercent = 100
    end

    return out
end

local function getGroupMetrics(groupName)
    local out = {
        exists = false,
        totalUnits = 0,
        aliveUnits = 0,
        lifeSum = 0,
        life0Sum = 0,
        lifePercent = 0
    }

    local grp = groupExistsByName(groupName)
    if not grp then
        return out
    end

    out.exists = true

    local units = grp:getUnits() or {}
    out.totalUnits = #units

    for i = 1, #units do
        local unit = units[i]
        if unit and unit:isExist() then
            local life = ensureNumber(unit:getLife())
            local life0 = ensureNumber(unit:getLife0())

            if life > 0 then
                out.aliveUnits = out.aliveUnits + 1
            end

            out.lifeSum = out.lifeSum + life
            out.life0Sum = out.life0Sum + life0
        end
    end

    if out.life0Sum > 0 then
        out.lifePercent = (out.lifeSum / out.life0Sum) * 100
    elseif out.lifeSum > 0 then
        out.lifePercent = 100
    end

    return out
end

----------------------------------------------------------------
-- WAREHOUSE HELPERS
----------------------------------------------------------------
local function getWarehouseInventory(baseName)
    local base = Airbase.getByName(baseName)
    if not base then
        return nil, "airbase no encontrada: " .. tostring(baseName)
    end

    local okWh, wh = pcall(function()
        return base:getWarehouse()
    end)
    if not okWh or not wh then
        return nil, "warehouse no disponible: " .. tostring(baseName)
    end

    local okInv, inv = pcall(function()
        return wh:getInventory()
    end)
    if not okInv or type(inv) ~= "table" then
        return nil, "getInventory fallo en: " .. tostring(baseName)
    end

    return inv, nil
end

local function getWarehouseItemCount(baseName, category, itemName)
    local inv, err = getWarehouseInventory(baseName)
    if not inv then
        return 0, err
    end

    local section = inv[category] or {}
    local value = section[itemName]
    if value == nil then
        value = section[tostring(itemName)]
    end

    return ensureNumber(value), nil
end

----------------------------------------------------------------
-- MARKERS
----------------------------------------------------------------
local function getNextMarkId()
    if not MS.STATE.nextMarkId then
        MS.STATE.nextMarkId = tonumber(MS.CONFIG.MARK_ID_START) or 950000
    end

    MS.STATE.nextMarkId = MS.STATE.nextMarkId + 1
    return MS.STATE.nextMarkId
end

local function removeMissionMark(missionId)
    local markId = MS.STATE.runtimeMarks[missionId]
    if markId then
        trigger.action.removeMark(markId)
        MS.STATE.runtimeMarks[missionId] = nil
    end
end

local function resolveMissionMarkPoint(def)
    local map = def.map or {}

    if map.zoneName then
        local zone = trigger.misc.getZone(map.zoneName)
        if zone then
            if zone.point then
                return {
                    x = zone.point.x,
                    y = zone.point.y or 0,
                    z = zone.point.z or zone.point.y
                }
            else
                return {
                    x = zone.x,
                    y = 0,
                    z = zone.y
                }
            end
        end
    end

    if map.point then
        return {
            x = map.point.x,
            y = map.point.y or 0,
            z = map.point.z or map.point.y
        }
    end

    return nil
end

local function createMissionMark(def)
    if not MS.CONFIG.MARKS_ENABLED then
        return
    end

    removeMissionMark(def.id)

    local point = resolveMissionMarkPoint(def)
    if not point then
        return
    end

    local map = def.map or {}
    local text =
        tostring(map.title or def.name or def.id) ..
        "\n\n" ..
        tostring(map.text or "") ..
        "\n\n" ..
        tostring(def.briefing or "")

    local markId = getNextMarkId()
    local ok = pcall(function()
        trigger.action.markToAll(markId, text, point, MS.CONFIG.MARK_READONLY, "")
    end)

    if not ok then
        pcall(function()
            trigger.action.markToAll(markId, text, point, MS.CONFIG.MARK_READONLY)
        end)
    end

    MS.STATE.runtimeMarks[def.id] = markId
end

----------------------------------------------------------------
-- VALIDADORES
----------------------------------------------------------------
local function runWarehouseValidator(mState, check)
    local memory = mState.validatorMemory[check.key] or {}
    mState.validatorMemory[check.key] = memory

    local currentCount, err = getWarehouseItemCount(
        check.baseName,
        check.category,
        check.itemName
    )

    if err then
        memory.error = err
        memory.currentCount = 0
        memory.removedCount = 0

        if check.setFlagOnPass and check.setFlagOnPass.elseValue ~= nil then
            setManagedFlag(check.setFlagOnPass.flag, check.setFlagOnPass.elseValue)
        end
        return
    end

    if memory.initialCount == nil then
        memory.initialCount = currentCount
    end

    memory.baseName = check.baseName
    memory.category = check.category
    memory.itemName = check.itemName
    memory.currentCount = currentCount
    memory.removedCount = math.max(0, ensureNumber(memory.initialCount) - ensureNumber(currentCount))
    memory.targetRemoved = tonumber(check.removedAtLeast) or 0

    local pass = memory.removedCount >= memory.targetRemoved

    if check.setFlagOnPass then
        if pass then
            setManagedFlag(check.setFlagOnPass.flag, check.setFlagOnPass.value)
        elseif check.setFlagOnPass.elseValue ~= nil then
            setManagedFlag(check.setFlagOnPass.flag, check.setFlagOnPass.elseValue)
        end
    end
end

local function runGroupValidator(mState, check)
    local memory = mState.validatorMemory[check.key] or {}
    mState.validatorMemory[check.key] = memory

    local data = getGroupMetrics(check.groupName)
    local metricName = check.metric or "aliveUnits"
    local metricValue = ensureNumber(data[metricName])

    memory.groupName = check.groupName
    memory.metricName = metricName
    memory.currentValue = metricValue
    memory.snapshot = deepCopy(data)

    local pass = compareValues(metricValue, check.op or ">=", check.value or 1)

    if check.setFlagOnPass then
        if pass then
            setManagedFlag(check.setFlagOnPass.flag, check.setFlagOnPass.value)
        elseif check.setFlagOnPass.elseValue ~= nil then
            setManagedFlag(check.setFlagOnPass.flag, check.setFlagOnPass.elseValue)
        end
    end
end

local function runUnitValidator(mState, check)
    local memory = mState.validatorMemory[check.key] or {}
    mState.validatorMemory[check.key] = memory

    local data = getUnitMetrics(check.unitName)
    local metricName = check.metric or "lifePercent"
    local metricValue = ensureNumber(data[metricName])

    memory.unitName = check.unitName
    memory.metricName = metricName
    memory.currentValue = metricValue
    memory.snapshot = deepCopy(data)

    local pass = compareValues(metricValue, check.op or ">", check.value or 0)

    if check.setFlagOnPass then
        if pass then
            setManagedFlag(check.setFlagOnPass.flag, check.setFlagOnPass.value)
        elseif check.setFlagOnPass.elseValue ~= nil then
            setManagedFlag(check.setFlagOnPass.flag, check.setFlagOnPass.elseValue)
        end
    end
end

local function runMissionValidators(def, mState)
    for _, check in ipairs(def.validators and def.validators.warehouse or {}) do
        runWarehouseValidator(mState, check)
    end

    for _, check in ipairs(def.validators and def.validators.groupChecks or {}) do
        runGroupValidator(mState, check)
    end

    for _, check in ipairs(def.validators and def.validators.unitChecks or {}) do
        runUnitValidator(mState, check)
    end
end

----------------------------------------------------------------
-- REGLAS DE FLAGS POR MISION
----------------------------------------------------------------
local function applyFlagActions(actionList)
    for _, entry in ipairs(actionList or {}) do
        if entry.flag ~= nil and entry.value ~= nil then
            setManagedFlag(entry.flag, entry.value)
        end
    end
end

local function runMissionFlagRules(def)
    for _, rule in ipairs(def.missionFlagRules or {}) do
        if rule.enabled ~= false then
            local pass = allFlagConditionsTrue(rule.conditions or {})
            if pass then
                applyFlagActions(rule.onTrue or {})
            else
                applyFlagActions(rule.onFalse or {})
            end
        end
    end
end

----------------------------------------------------------------
-- RECOMPENSAS
----------------------------------------------------------------
local function processMissionObjectiveRewards(def, mState)
    local rewards = def.rewards or {}
    if rewards.enabled == false then
        return
    end

    local rewardState = ensureRewardState(mState)

    for index, rewardDef in ipairs(rewards.objectives or {}) do
        if rewardDef.enabled ~= false then
            local rewardId = tostring(rewardDef.id or ("OBJ_REWARD_" .. tostring(index)))
            local alreadyPaid = rewardState.objectives[rewardId] == true

            if not alreadyPaid then
                local pass = allFlagConditionsTrue(rewardDef.conditions or {})
                if pass then
                    local coalition = tonumber(rewardDef.coalition)
                    if coalition == nil then
                        coalition = tonumber(rewards.coalition) or 2
                    end

                    local amount = tonumber(rewardDef.amount) or 0

                    if amount > 0 then
                        local ok = payCoalition(
                            coalition,
                            amount,
                            "objetivo " .. rewardId .. " " .. tostring(def.id),
                            def.id,
                            rewardId
                        )

                        if ok then
                            rewardState.objectives[rewardId] = true
                            MS.STATE.dirty = true
                        end
                    else
                        rewardState.objectives[rewardId] = true
                        MS.STATE.dirty = true
                    end
                end
            end
        end
    end
end

local function processMissionCompletionReward(def, mState)
    local rewards = def.rewards or {}
    if rewards.enabled == false then
        return
    end

    local rewardState = ensureRewardState(mState)

    if rewardState.missionSuccess == true then
        return
    end

    local amount = tonumber(rewards.missionSuccessAmount) or 0
    local coalition = tonumber(rewards.coalition) or 2

    if amount <= 0 then
        rewardState.missionSuccess = true
        MS.STATE.dirty = true
        return
    end

    local ok = payCoalition(
        coalition,
        amount,
        "completada " .. tostring(def.id),
        def.id,
        "MISSION_SUCCESS"
    )

    if ok then
        rewardState.missionSuccess = true
        MS.STATE.dirty = true
    end
end

----------------------------------------------------------------
-- FLUJO DE MISIONES
----------------------------------------------------------------
local function getCurrentOrNextMission()
    local defs = sortedMissionDefs()

    for _, def in ipairs(defs) do
        local st = ensureMissionState(def).status
        if st == MS.STATUS.ACTIVE then
            return def, "ACTIVE"
        end
    end

    for i, def in ipairs(defs) do
        local st = ensureMissionState(def).status

        if st == MS.STATUS.NOT_STARTED then
            local prevOk = true

            if i > 1 then
                local prevDef = defs[i - 1]
                local prevState = ensureMissionState(prevDef)
                prevOk = prevState.status == MS.STATUS.COMPLETED
            end

            if prevOk and allFlagConditionsTrue(def.activationConditions or {}) then
                return def, "NEXT"
            end
        end
    end

    return nil, "NONE"
end

local function activateMission(def, mState, manual)
    if MS.STATE.currentMissionId and MS.STATE.currentMissionId ~= def.id then
        return false
    end

    if mState.status == MS.STATUS.COMPLETED then
        return false
    end

    if mState.status == MS.STATUS.FAILED then
        return false
    end

    if mState.status == MS.STATUS.ACTIVE then
        return true
    end

    mState.status = MS.STATUS.ACTIVE
    mState.activatedAt = timer.getTime()
    MS.STATE.currentMissionId = def.id

    applyFlagActions(def.flags and def.flags.onActivate or {})
    createMissionMark(def)

    local modeText = manual and "manual" or "automatica"

    trigger.action.outText(
        "Mision activada (" .. modeText .. ")\n\n" ..
        tostring(def.name) .. "\n\n" ..
        tostring(def.briefing or ""),
        20
    )

    MS.STATE.dirty = true
    return true
end

local function completeMission(def, mState)
    if mState.status == MS.STATUS.COMPLETED then
        return
    end

    processMissionCompletionReward(def, mState)

    mState.status = MS.STATUS.COMPLETED
    mState.completedAt = timer.getTime()

    if MS.STATE.currentMissionId == def.id then
        MS.STATE.currentMissionId = nil
    end

    applyFlagActions(def.flags and def.flags.onSuccess or {})
    removeMissionMark(def.id)

    trigger.action.outText(
        "Mision completada\n" ..
        tostring(def.name),
        15
    )

    MS.STATE.dirty = true
end

local function failMission(def, mState)
    if mState.status == MS.STATUS.FAILED then
        return
    end

    mState.status = MS.STATUS.FAILED
    mState.failedAt = timer.getTime()

    if MS.STATE.currentMissionId == def.id then
        MS.STATE.currentMissionId = nil
    end

    applyFlagActions(def.flags and def.flags.onFail or {})
    removeMissionMark(def.id)

    trigger.action.outText(
        "Mision fallida\n" ..
        tostring(def.name),
        15
    )

    MS.STATE.dirty = true
end

local function evaluateMissionResult(def, mState)
    if #(def.failConditions or {}) > 0 and allFlagConditionsTrue(def.failConditions) then
        failMission(def, mState)
        return
    end

    if #(def.successConditions or {}) > 0 and allFlagConditionsTrue(def.successConditions) then
        completeMission(def, mState)
        return
    end
end

local function tryAutoStartNextMission()
    local def, mode = getCurrentOrNextMission()
    if not def then
        return
    end

    if mode == "NEXT" and def.autoStart then
        activateMission(def, ensureMissionState(def), false)
    end
end

local function manuallyActivateNextMission()
    local def, mode = getCurrentOrNextMission()

    if not def then
        trigger.action.outText("No hay una mision disponible para activar.", 8)
        return
    end

    if mode == "ACTIVE" then
        trigger.action.outText("Ya existe una mision activa: " .. tostring(def.name), 8)
        return
    end

    activateMission(def, ensureMissionState(def), true)
end

----------------------------------------------------------------
-- MENU F10
----------------------------------------------------------------
local function buildMissionSummaryLine(def, mState)
    local line =
        "[" .. tostring(def.order or "?") .. "] " ..
        tostring(def.shortName or def.id) .. " - " ..
        tostring(def.name) ..
        " | status=" .. tostring(mState.status) ..
        " (" .. statusToText(mState.status) .. ")"

    local whChecks = def.validators and def.validators.warehouse or {}
    if #whChecks > 0 then
        local check = whChecks[1]
        local memory = mState.validatorMemory and mState.validatorMemory[check.key]
        if memory and memory.targetRemoved then
            line = line ..
                " | warehouse=" ..
                tostring(memory.removedCount or 0) .. "/" ..
                tostring(memory.targetRemoved or 0)
        end
    end

    return line
end

local function showMissionStates()
    local lines = {}
    lines[#lines + 1] = "ESTADO DE MISIONES"

    for _, def in ipairs(sortedMissionDefs()) do
        local mState = ensureMissionState(def)
        lines[#lines + 1] = buildMissionSummaryLine(def, mState)
    end

    trigger.action.outText(table.concat(lines, "\n"), 20)
end

local function showActiveMission()
    local def = getActiveMissionDef()
    if not def then
        trigger.action.outText("No hay una mision activa en este momento.", 10)
        return
    end

    local mState = ensureMissionState(def)

    local msg =
        "MISION ACTIVA\n\n" ..
        tostring(def.name) .. "\n\n" ..
        tostring(def.briefing or "") .. "\n\n" ..
        "Estado: " .. tostring(mState.status) .. " (" .. statusToText(mState.status) .. ")"

    local whChecks = def.validators and def.validators.warehouse or {}
    if #whChecks > 0 then
        local check = whChecks[1]
        local memory = mState.validatorMemory and mState.validatorMemory[check.key]
        if memory then
            msg = msg ..
                "\n\nWarehouse:\n" ..
                "Base: " .. tostring(memory.baseName or check.baseName) .. "\n" ..
                "Categoria: " .. tostring(memory.category or check.category) .. "\n" ..
                "Item: " .. tostring(memory.itemName or check.itemName) .. "\n" ..
                "Inicial: " .. tostring(memory.initialCount or 0) .. "\n" ..
                "Actual: " .. tostring(memory.currentCount or 0) .. "\n" ..
                "Sacados: " .. tostring(memory.removedCount or 0) .. "/" .. tostring(memory.targetRemoved or 0)
        end
    end

    local rewardState = ensureRewardState(mState)
    local paidObjectives = 0
    for _, paid in pairs(rewardState.objectives or {}) do
        if paid == true then
            paidObjectives = paidObjectives + 1
        end
    end

    msg = msg ..
        "\n\nRecompensas:\n" ..
        "Objetivos pagados: " .. tostring(paidObjectives) .. "\n" ..
        "Pago final de mision: " .. tostring(rewardState.missionSuccess == true and "SI" or "NO")

    trigger.action.outText(msg, 25)
end

local function showWallet()
    local econ = getEconomy()
    if not econ or not econ.get then
        trigger.action.outText("Sistema economico no disponible.", 8)
        return
    end

    local msg =
        "BILLETERA\n" ..
        "Azul: " .. formatMoney(econ.get(2)) .. "\n" ..
        "Rojo: " .. formatMoney(econ.get(1))

    trigger.action.outText(msg, 12)
end

local function forceSaveNow()
    local ok = writeJsonToDisk(true)
    if ok then
        trigger.action.outText("JSON de misiones guardado.", 8)
    else
        trigger.action.outText("No se pudo guardar el JSON de misiones.", 8)
    end
end

local function rebuildMenu()
    if MS.STATE.menuRoot then
        missionCommands.removeItem(MS.STATE.menuRoot)
        MS.STATE.menuRoot = nil
    end

    MS.STATE.menuRoot = missionCommands.addSubMenu(MS.CONFIG.MENU_NAME)
    missionCommands.addCommand("Ver estado de misiones", MS.STATE.menuRoot, showMissionStates)
    missionCommands.addCommand("Ver mision activa", MS.STATE.menuRoot, showActiveMission)
    missionCommands.addCommand("Activar siguiente disponible", MS.STATE.menuRoot, manuallyActivateNextMission)
    missionCommands.addCommand("Ver billetera", MS.STATE.menuRoot, showWallet)
    missionCommands.addCommand("Guardar JSON ahora", MS.STATE.menuRoot, forceSaveNow)
end

----------------------------------------------------------------
-- MAIN LOOP
----------------------------------------------------------------
local function mainLoop(_, now)
    now = now or timer.getTime()

    if MS.STATE.importWindowEndsAt and now >= MS.STATE.importWindowEndsAt and not MS.STATE.writeEnabled then
        MS.STATE.writeEnabled = true
        MS.STATE.dirty = true
        log("Ventana de importacion terminada. DCS toma control del JSON de misiones.")
    end

    local activeDef = getActiveMissionDef()
    if activeDef then
        local activeState = ensureMissionState(activeDef)

        if activeState.status == MS.STATUS.ACTIVE then
            runMissionFlagRules(activeDef)
            runMissionValidators(activeDef, activeState)
            processMissionObjectiveRewards(activeDef, activeState)
            evaluateMissionResult(activeDef, activeState)
        end
    else
        tryAutoStartNextMission()
    end

    if MS.STATE.writeEnabled then
        if (now - (MS.STATE.lastAutosaveAt or 0)) >= (MS.CONFIG.AUTOSAVE_INTERVAL or 10) then
            MS.STATE.lastAutosaveAt = now
            writeJsonToDisk(false)
        end
    end

    return now + (MS.CONFIG.MAIN_LOOP_INTERVAL or 1)
end

----------------------------------------------------------------
-- VALIDACION / START
----------------------------------------------------------------
local function validateEnvironment()
    if not io or not lfs then
        warn("io/lfs no disponibles. Revisa MissionScripting.lua.")
        return false
    end

    if not net or not net.json2lua then
        warn("net.json2lua no disponible.")
        return false
    end

    return true
end

local function start()
    if MS.STATE.initialized then
        return
    end

    if not validateEnvironment() then
        return
    end

    initializeMissionStates()
    MS.STATE.nextMarkId = tonumber(MS.CONFIG.MARK_ID_START) or 950000

    local doc, err = loadStateFromDisk()
    if doc then
        restoreStateFromDoc(doc)
        log("Estado de misiones restaurado desde JSON.")
    else
        log("No habia JSON previo. Se inicia limpio. Motivo: " .. tostring(err))
    end

    if MS.STATE.currentMissionId then
        local def = getMissionDefById(MS.STATE.currentMissionId)
        local mState = def and ensureMissionState(def) or nil

        if def and mState and mState.status == MS.STATUS.ACTIVE then
            createMissionMark(def)
        else
            MS.STATE.currentMissionId = nil
        end
    end

    rebuildMenu()

    MS.STATE.importWindowEndsAt = timer.getTime() + (MS.CONFIG.IMPORT_WINDOW_SECONDS or 30)
    MS.STATE.writeEnabled = false
    MS.STATE.initialized = true

    timer.scheduleFunction(mainLoop, nil, timer.getTime() + 1)

    trigger.action.outText(
        "Sistema de Misiones cargado.\n" ..
        "Menu F10: " .. tostring(MS.CONFIG.MENU_NAME),
        12
    )

    log("Ruta JSON: " .. tostring(MS.CONFIG.FILE_PATH))
end

start()