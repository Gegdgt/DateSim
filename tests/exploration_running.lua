local Suite={}
function Suite.run()
 local E=require("src.systems.exploration")
 local Maps=require("src.data.maps")
 local Save=require("src.systems.save")
 local Json=require("src.systems.json")
 local Prologue=require("src.systems.prologue")
 local count=0
 local function check(value,message)assert(value,message);count=count+1 end
 local function near(a,b,message)check(math.abs(a-b)<.00001,message)end
 local function walk(running,dx,dy,steps)
  local e={map="patio_eris",x=200,y=272,facing="down",visited={}}
  for _=1,steps or 1 do E.move(e,dx,dy,.4/(steps or 1),running) end
  return math.sqrt((e.x-200)^2+(e.y-272)^2)
 end
 near(walk(false,1,0),32,"Caminar a 80 px/s")
 near(walk(true,1,0),60,"Correr a 150 px/s")
 for _,running in ipairs({false,true}) do
  near(walk(running,1,1),walk(running,1,0),"Diagonal normalizada")
  near(walk(running,1,1,60),walk(running,1,1,1),"Movimiento independiente de FPS")
 end
 for id,map in pairs(Maps) do
  local possible=false
  for _,dir in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
   local e={map=id,x=map.initialPosition.x,y=map.initialPosition.y,visited={}}
   E.move(e,dir[1],dir[2],.05,true)
   local distance=math.sqrt((e.x-map.initialPosition.x)^2+(e.y-map.initialPosition.y)^2)
   if math.abs(distance-7.5)<.00001 then possible=true;break end
  end
  check(possible,"Correr en el mapa "..id)
 end
 local obstacles={
  {map="casa_planta_baja",x=130,y=180,dx=0,dy=-1,axis="y",limit=174,minimum=true,name="mesa"},
  {map="casa_segundo_piso",x=260,y=144,dx=0,dy=-1,axis="y",limit=118,minimum=true,name="pared"},
  {map="dormitorio_eris",x=112,y=80,dx=-1,dy=0,axis="x",limit=101,minimum=true,name="cama"},
  {map="patio_eris",x=300,y=216,dx=1,dy=0,axis="x",limit=350,name="NPC"},
  {map="patio_eris",x=240,y=310,dx=0,dy=1,axis="y",limit=328,name="cerca y borde"},
  {map="jardin_casa",x=232,y=270,dx=-1,dy=0,axis="x",limit=221,minimum=true,name="vegetación sólida"},
 }
 for _,test in ipairs(obstacles) do
  local e={map=test.map,x=test.x,y=test.y,visited={}}
  E.move(e,test.dx,test.dy,2,true) -- 300 px: el destino podría quedar al otro lado del sólido.
  check(test.minimum and e[test.axis]>=test.limit or not test.minimum and e[test.axis]<=test.limit,"Sin atravesar "..test.name.." con dt grande")
  check(E.walkable(Maps[e.map],e.x,e.y),"Pies fuera del sólido: "..test.name)
 end
 for _,route in ipairs({{"casa_planta_baja",65,160},{"casa_planta_baja",478,296},{"camino_sharia",160,169}}) do
  local e={map=route[1],x=route[2],y=route[3],visited={}}
  E.move(e,1,0,.15,true);near(e.x-route[2],22.5,"Se conservan asientos y faroles transitables")
 end
 local oldWrite,oldOptions,oldDown=Save.write,Save.readOptions,love.keyboard.isDown
 Save.write=function(s)assert(Save.validate(s));return true end
 Save.readOptions=function()return {muted=true,textAnimation=false}end
 local held={};love.keyboard.isDown=function(key)return held[key] or false end
 local ok,err=xpcall(function()
  local app=require("src.app").new()
  app.session=Prologue.start(Save.newSession());Prologue.wake(app.session)
  local e=app.session.exploration
  E.enter(e,"patio_eris",{x=240,y=216});app:explore();app.manager:finishTransition()
  check(not app.session.prologue.starting_cards_received,"Correr no requiere cartas ni desbloqueo")
  local resources=Json.encode({app.session.externalEnergy,app.session.curse,app.session.gold,app.session.daily,app.session.relationships})
  local world=app.manager.current
  local function reset()e.x,e.y=240,216;world.walkTime=0;world.walking=false;world.running=false end
  held={d=true};world:update(.16);near(e.x,252.8,"WASD camina")
  near(world.walkTime,.16,"Ritmo normal de animación")
  for _,shift in ipairs({"lshift","rshift"}) do
   reset();held={right=true,[shift]=true};world:update(.16)
   near(e.x,264,"Flechas y "..shift.." corren")
   check(world.running and world.walking,"Estado visual de carrera")
   near(world.walkTime,.3,"La animación acelera con la velocidad")
   local frame
   local originalQuad=world.quad
   world.quad=function(self,group,id,index,row)if id=="rudeus" then frame=index end;return originalQuad(self,group,id,index,row)end
   world:sprite("rudeus",e.x,e.y,e.facing,world.walking)
   check(frame==math.floor(world.walkTime/.1)%4 and frame>1,"Usa fotogramas más rápidos del mismo sprite")
   held={right=true};local x=e.x;world:update(.1)
   near(e.x-x,8,"Soltar "..shift.." vuelve a caminar inmediatamente")
   check(not world.running,"No se mantiene la carrera")
   held={[shift]=true};world:update(.2);world:sprite("rudeus",e.x,e.y,e.facing,world.walking)
   check(not world.walking and not world.running and frame==0,"Reposo al dejar de moverse aunque Shift siga presionado")
   world.quad=originalQuad
  end
  for _,key in ipairs({"m","i","j","tab","escape"}) do
   reset();held={d=true,lshift=true};world:update(.05);world:keypressed(key)
   local x=e.x;world:update(.5)
   near(e.x,x,"Menú bloquea carrera: "..key)
   check(not world.running and not world.walking,"Menú detiene animación")
   world:keypressed("escape")
  end
  reset();held={d=true,lshift=true};world:greet(require("src.data.exploration_world").npcs.patio_eris[1])
  world:update(1);near(e.x,240,"Diálogo bloquea carrera")
  check(not world.running and not world.walking,"Diálogo conserva reposo")
  world:keypressed("escape")
  for _,release in ipairs({false,true}) do
   E.enter(e,"patio_eris",{x=610,y=216});held={d=true,lshift=true}
   app:explore();app.manager:finishTransition();app:update(.1)
   check(e.map=="jardin_casa" and app.manager.transition>0,"Cruzar portal corriendo")
   local arrival=e.x;app:update(.1);near(e.x,arrival,"Transición bloquea movimiento")
   if release then held={d=true} end
   app:update(.35)
   near(e.x-arrival,release and 8 or 15,"Shift actual tras transición")
   check(app.manager.current.running==not release,"Transición no conserva un Shift liberado")
  end
  check(resources==Json.encode({app.session.externalEnergy,app.session.curse,app.session.gold,app.session.daily,app.session.relationships}),"Correr no consume recursos ni interacciones")
  local loaded=assert(Save.validate(assert(Json.decode(assert(Json.encode(app.session))))))
  check(loaded.exploration.running==nil,"La carrera no se guarda como estado persistente")
  app.session=loaded;held={d=true};app:explore();app.manager:finishTransition()
  local x=loaded.exploration.x;app:update(.1);near(loaded.exploration.x-x,8,"Cargar no activa la carrera")
  local image=app.resources:getExploration("overworld","rudeus");local min,mag=image:getFilter()
  check(min=="nearest" and mag=="nearest","Se conserva filtrado nearest")
  app:draw()
  local bytes=app.canvas:newImageData():encode("png")
  local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/exploration-running-controls.png","wb"));file:write(bytes:getString());file:close()
  bytes:release();app.audio:stop()
 end,debug.traceback)
 Save.write,Save.readOptions,love.keyboard.isDown=oldWrite,oldOptions,oldDown
 if not ok then error(err) end
 print("Exploration running: "..count.." checks; 14 maps, both Shift keys, collisions, dt, animation, dialogue and transitions.")
 return count
end
return Suite
