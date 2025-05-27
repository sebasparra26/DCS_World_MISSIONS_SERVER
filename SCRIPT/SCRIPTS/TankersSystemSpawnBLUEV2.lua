---------------------------------------------------------------------
--  TANKERS BLUE  |  versión 25-May-2025
--  Spawnea KC-135 y KC-135 MPRS desde un marcador y
--  • Asigna radio UHF (AM) aleatoria 251-259 MHz
--  • Activa TACAN AA canal 1-63 X
--  • Mantiene un menú de estado
--  • Permite eliminar el tanquero desde el menú
--  • Autodestruye el grupo tras X minutos          <<--- NUEVO
---------------------------------------------------------------------

---------------------------  VARIABLES GLOBALES  --------------------
local AUTO_DELETE_MINUTES   = 60       -- <- cámbialo cuando quieras
local ENABLE_AUTO_DELETE    = true     -- false = sin temporizador

---------------------------  CONFIGURACIÓN  -------------------------
local tankerCountry = country.id.USA

local tankerTypes = {
  ["KC-135"]      = { type="KC-135",     cs={1,1,0}, tac="SHL" },
  ["KC-135 MPRS"] = { type="KC135MPRS",  cs={2,1,0}, tac="ARC" }
}

local function MHz(v) return v * 1e6 end          -- convierte a Hz
local function randFreq()  return MHz(math.random(2510,2590)/10) end
local function randChan()  return math.random(1,63) end

---------------------------  MENÚ PRINCIPAL  ------------------------
local rootMenu   = missionCommands.addSubMenuForCoalition(
                      coalition.side.BLUE,"Tanker")
local statusMenu = nil
local active     = {}   -- [groupName] = {freq,chan,mode,cs}

local function refreshStatus()
  if statusMenu then missionCommands.removeItem(statusMenu) end
  statusMenu = missionCommands.addSubMenuForCoalition(
                 coalition.side.BLUE,"Tanqueros Activos",rootMenu)

  for g,data in pairs(active) do
    if Group.getByName(g) and Group.getByName(g):isExist() then
      local info = string.format("%s | %.1f MHz AM | %d%s",
                    g, data.freq/1e6, data.chan, data.mode)
      missionCommands.addCommandForCoalition(coalition.side.BLUE,
        info,statusMenu,
        function()
          trigger.action.outTextForCoalition(coalition.side.BLUE,
            string.format("Grupo: %s\nFreq: %.1f MHz AM\nTACAN: %d%s  (%s)",
              g,data.freq/1e6,data.chan,data.mode,data.cs),15)
        end)

      missionCommands.addCommandForCoalition(coalition.side.BLUE,
        "Eliminar "..g,statusMenu,function() _G.eliminarTanker(g) end)
    else
      active[g]=nil
    end
  end
end

---------------------------  ELIMINACIÓN  ---------------------------
function eliminarTanker(gName)
  local grp = Group.getByName(gName)
  if grp and grp:isExist() then grp:destroy() end
  active[gName]=nil
  trigger.action.outTextForCoalition(coalition.side.BLUE,
    "Tanker "..gName.." eliminado.",8)
  refreshStatus()
end
_G.eliminarTanker = eliminarTanker   -- expón para menú

---------------------------  SPAWN ---------------------------------
local function spawnTanker(tp, p1, p2, hdg)
  local info   = tankerTypes[tp]
  local freqHz = randFreq()
  local chan   = randChan()
  local gName  = tp:gsub("%s","").."_"..chan
  local alt    = 7620           -- 25 000 ft
  local spd    = 154.4          -- 300 kts

  local grpData = {
    category = Group.Category.AIRPLANE,
    country  = tankerCountry,
    name     = gName,
    task     = { id="ComboTask", params={ tasks={
                 { id="Tanker", enabled=true } } } },
    units = { {
      type   = info.type,  name="U"..math.random(1000,9999), skill="High",
      x=p1.x, y=p1.y, alt=alt, speed=spd, heading=hdg,
      callsign = {info.cs[1],info.cs[2],math.random(11,99)},
      communication = true
    } },
    route = { points = {
      {x=p1.x,y=p1.y,alt=alt,speed=spd,action="Turning Point",
        task={id="ComboTask",params={tasks={{id="Tanker",enabled=true}}}}},
      {x=p2.x,y=p2.y,alt=alt,speed=spd,action="Turning Point",
        task={id="ComboTask",params={tasks={
          {id="WrappedAction",params={action={id="SwitchWaypoint",
                params={fromWaypointIndex=2,goToWaypointIndex=1}}}},
          {id="Tanker",enabled=true}
        }}}}
    }}
  }

  coalition.addGroup(tankerCountry, grpData.category, grpData)
  local grp = Group.getByName(gName)
  local ctl = grp and grp:getController()

  if ctl then
    ctl:setCommand({ id="SetFrequency",
       params={frequency=freqHz, modulation=0}})           -- AM
    ctl:setCommand({ id="ActivateBeacon",
       params={ type=4, system=4, channel=chan, modeChannel="X",
                callsign=info.tac, bearing=true, AA=true}})
  end

  active[gName] = {freq=freqHz, chan=chan, mode="X", cs=info.tac}
  refreshStatus()

  trigger.action.outTextForCoalition(coalition.side.BLUE,
    string.format("%s desplegado: %.1f MHz AM  TACAN %dX",
                  tp,freqHz/1e6,chan),12)

  -- AUTODESTRUCCIÓN PROGRAMADA
  if ENABLE_AUTO_DELETE then
    timer.scheduleFunction(function(t,args)
        local g=args[1]
        if Group.getByName(g) and Group.getByName(g):isExist() then
          eliminarTanker(g)
        end
        return nil
      end,{gName},timer.getTime()+AUTO_DELETE_MINUTES*60)
  end
end

---------------------------  MENÚ DE TIPO --------------------------
for name,_ in pairs(tankerTypes) do
  missionCommands.addCommandForCoalition(coalition.side.BLUE,name,rootMenu,
    function()
      _G.__SEL = name
      trigger.action.outTextForCoalition(coalition.side.BLUE,
        "Seleccionado: "..name..". Coloca un marcador\n'TankerH' (E-W) "
        .."o 'TankerV' (N-S).",10)
    end)
end

---------------------------  EVENTO MARCADOR -----------------------
world.addEventHandler({
  onEvent=function(self,e)
    if e.id~=world.event.S_EVENT_MARK_CHANGE or not e.text or not _G.__SEL then return end
    local txt = string.lower(e.text)
    if txt=="tankerh" or txt=="tankerv" then
      local hdg   = (txt=="tankerh") and math.rad(90) or 0
      local p1    = {x=e.pos.x, y=e.pos.z}
      local dist  = 50*1852
      local p2    = { x = p1.x + math.cos(hdg)*dist,
                      y = p1.y + math.sin(hdg)*dist }
      spawnTanker(_G.__SEL,p1,p2,hdg)
      _G.__SEL=nil
    end
  end
})
