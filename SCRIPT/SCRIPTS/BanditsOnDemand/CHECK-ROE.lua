-- ===============================================
--  AI TASK PUSH por bandera (simple y editable)
--  - Cada grupo se ata a UNA flag
--  - Flag=1  → ROE: WEAPON FREE
--  - Flag=0  → ROE: WEAPON HOLD
--  - Fácil de ampliar: añade más pushTasks en los huecos
-- ===============================================

-- ========= CONFIG EDITABLE =========
local CHECK_INTERVAL = 3      -- segundos entre chequeos
local DEBUG = true            -- mensajes breves en pantalla

-- Lista de {nombreDeGrupo, flagControl}
local GRUPOS = {
  {"SA-2", 3005},
  {"Patriot-1", 3005},
  -- {"Otro_Grupo", 3010},
}
-- ===================================

-- Helpers de mensaje
local function dbg(txt)
  if DEBUG then trigger.action.outText("[AI-PUSH] "..txt, 3) end
end

-- Helpers para construir tareas Option:
-- ROE = Option 0 ; 2=WEAPON FREE ; 4=WEAPON HOLD
local function taskROE(value)
  return { id = 'Option', params = { option = 0, value = value } }
end

local function pushIfAlive(ctrl, task)
  if ctrl and task then ctrl:pushTask(task) end
end

-- Loop único: revisa todas las flags y empuja tareas
local function loopAll()
  for i=1, #GRUPOS do
    local name, flag = GRUPOS[i][1], GRUPOS[i][2]
    local grp = Group.getByName(name)

    if grp and grp:isExist() then
      local ctrl = grp:getController()
      local val = trigger.misc.getUserFlag(tostring(flag))

      if val == 1 then
        -- ---- FLAG TRUE → ROE: WEAPON FREE ----
        pushIfAlive(ctrl, taskROE(2))
        -- AÑADE MÁS TASKS AQUÍ (cuando TRUE), por ejemplo:
        -- ctrl:pushTask({ id='Option', params={ option=1, value=2 } }) -- Reaction to threat
        -- ctrl:pushTask({ id='EngageTargets', params={ maxDist=20000, targetTypes={'Air'} } })

        dbg(name..": flag "..flag.."=1 → ROE FREE")

      else
        -- ---- FLAG FALSE → ROE: WEAPON HOLD ----
        pushIfAlive(ctrl, taskROE(4))
        -- AÑADE MÁS TASKS AQUÍ (cuando FALSE), si quieres:
        -- ctrl:pushTask({ id='Option', params={ option=1, value=0 } }) -- Reaction to threat: No reaction

        dbg(name..": flag "..flag.."=0 → ROE HOLD")
      end
    else
      dbg(name..": no existe / destruido (saltando).")
    end
  end

  timer.scheduleFunction(loopAll, {}, timer.getTime() + CHECK_INTERVAL)
end

-- Inicio
dbg("Iniciando AI PUSH por bandera para "..#GRUPOS.." grupos.")
timer.scheduleFunction(loopAll, {}, timer.getTime() + 1)
