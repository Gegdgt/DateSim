-- Full-route driver uses the same movement, letter UI, activities and beds as play.
local D={}
local E=require("src.systems.exploration")
local Maps=require("src.data.maps")
local World=require("src.data.exploration_world")
local Walk=require("tests.exploration_driver")
local Content=require("src.systems.world_content")
local Wife=require("src.systems.wife_activities")
local Daily=require("src.systems.daily")
local Rest=require("src.systems.rest")
local function probe(s,a)
 return {exploration={map=s.exploration.map,x=a.x,y=a.y,resources={},absentNpcs=s.exploration.absentNpcs,npcLocations=s.exploration.npcLocations}}
end
function D.travel(s,target)
 E.syncPresence(s)
 while s.exploration.map~=target do
  local e=s.exploration;local nextMap=Walk.route(e.map,target)
  local transfer=World.transfers[e.map]
  if transfer and transfer.target==nextMap then
   Walk.walk(s,function(a)return E.nearby(probe(s,a))==transfer end)
   E.enter(e,transfer.target,transfer.arrival)
  else
   Walk.walk(s,function(a)local p=E.portal({map=e.map,x=a.x,y=a.y});return p and p.targetMap==nextMap end)
   local p=assert(E.portal(e));E.enter(e,p.targetMap,p.arrival)
  end
 end
end
function D.near(s,id)
 Walk.walk(s,function(a)local item=E.nearby(probe(s,a));return item and item.id==id end)
end
function D.greet(s,id)
 E.syncPresence(s)
 for mapId,map in pairs(Maps) do for _,npc in ipairs(map.npcs.placements) do if npc.id==id and E.npcPresent(s.exploration,npc,mapId) then
  D.travel(s,mapId);D.near(s,id)
  local used=s.daily.interactions_used;local gold=s.gold
  local response=Content.greeting(s,id)
  assert(response.text and used==s.daily.interactions_used and gold==s.gold,"Saludo gratuito")
  return
 end end end
 error("NPC no encontrado: "..id)
end
function D.initialize(s,config)
 require("src.systems.prologue").start(s);Content.ensure(s).seed=config.seed
end
function D.prologue(s)
 if s.checkpoint=="day1_wake" then
  assert(s.exploration.map=="dormitorio_eris")
  for _,id in ipairs({"lilia","aisha","norn","zenith","sylphiette"}) do D.greet(s,id) end
  assert(not Wife.available(s,"S01"),"Actividades bloqueadas antes de leer")
  D.travel(s,"estudio_rudy");D.near(s,"hitogami_letter")
  assert(not s.prologue.letter_read and not s.prologue.letter_collected,"Entrar no descubre la carta")
  local app={session=s,options={reducedMotion=true,textAnimation=false},audio={effect=function()end},
   save=function(self)assert(require("src.systems.save").validate(self.session));return true end,
   switch=function()end,resume=function()end}
  local Letter=require("src.screens.exploration_letter")
  local letter=Letter.new(app,{});letter:update(1);letter:close()
  assert(s.prologue.letter_collected and not s.prologue.letter_read,"Cerrar antes de leer no avanza")
  D.travel(s,"casa_segundo_piso");D.travel(s,"estudio_rudy");D.near(s,"hitogami_letter")
  letter=Letter.new(app,{})
  for _=1,30 do if s.prologue.letter_read then break end;letter:update(1);letter:interact() end
  assert(s.prologue.letter_read,"Firma leída mediante la secuencia real")
  return true
 elseif s.checkpoint=="day1_warning" and not s.prologue.nanahoshi_visited then
  D.travel(s,"laboratorio_nanahoshi");D.near(s,"nanahoshi")
  assert(require("src.systems.prologue").visitNanahoshi(s));return true
 end
end
function D.activities(s,config,round,battle)
 if s.rest then s.rest.waking=false end
 Content.generate(s)
 -- Walk to each seeded find, using its actual reach position; no injected loot.
 for _,find in ipairs(Content.ensure(s).days[tostring(s.day)] or {}) do if not s.worldContent.collected[find.id] then
  D.travel(s,find.map)
  Walk.walk(s,function(a)return (a.x-find.x)^2+(a.y-find.y)^2<24^2 end)
  assert(Content.examine(s,find));s=round(s)
 end end
 while not config.skipActivities and Daily.remaining(s)>0 and not s.daily.activities_locked do
  local wife=config.dailyWife or ({"sylphiette","roxy","eris"})[s.daily.interactions_used+1]
  if not require("src.systems.family").active(s,wife) then
   wife=nil
   for _,id in ipairs({"sylphiette","roxy","eris"}) do if require("src.systems.family").active(s,id) then wife=id;break end end
   if not wife then break end
  end
  D.greet(s,wife)
  local activity=wife=="eris" and (config.skipErisTraining and "E11" or "E01")
   or wife=="roxy" and (s.day%2==0 and "R02" or "R01") or (s.day%2==0 and "S04" or "S01")
  assert(Wife.start(s,activity,s.economy.revision));s=round(s)
  local active=Wife.current(s);active.phase="hand"
  local selected,best=nil,-math.huge
  for _,id in ipairs(active.hand) do
   local r=Wife.bank.byId[activity].responses[id]
   if r.love+r.trust>best then selected,best=id,r.love+r.trust end
  end
  assert(Wife.choose(s,selected));s=round(s);assert(Wife.react(s));s=round(s)
  Wife.current(s).ended=true;assert(Wife.execute(s)) -- el piloto decide cerrar tras una respuesta
  if Daily.battleDefinition(s) then s=battle(s,Daily.battleDefinition(s),config) end
  assert(Wife.ensure(s).review);Wife.closeReview(s);s=round(s)
 end
 if not s.daily.favor_used and s.day<7 and not s.daily.activities_locked then
  D.greet(s,"cliff")
  local id=s.day%2==1 and "social_research" or "gather_materials"
  if Daily.favorAvailable(s,id,"cliff",false) then assert(Daily.requestFavor(s,id,"cliff",false)) end
 end
 return s
end
function D.rest(s,config)
 local chosen=config.dailyWife
 if not chosen then chosen=({"sylphiette","roxy","eris"})[(s.day-1)%3+1] end
 local map=({sylphiette="dormitorio_sylphie",roxy="dormitorio_roxy",eris="dormitorio_eris"})[chosen]
 local r=s.relationships[chosen]
 E.syncPresence(s)
 if r.marriageState=="separated" or s.exploration.period~="night" then map="casa_segundo_piso" end
 D.travel(s,map);local bed=require("src.data.rest").beds[map];D.near(s,bed.id)
 assert(Rest.confirm(s,bed,Rest.options(s,bed)[1].id))
 assert(not Rest.confirm(s,bed,Rest.options(s,bed)[1].id),"Sin segunda recompensa nocturna")
end
return D
