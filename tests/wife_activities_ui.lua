local Suite={}
function Suite.run()
 local Save=require("src.systems.save")
 local Json=require("src.systems.json")
 local P=require("src.systems.prologue")
 local W=require("src.systems.wife_activities")
 local Events=require("src.systems.events")
 local E=require("src.systems.exploration")
 local Maps=require("src.data.maps")
 local Driver=require("tests.exploration_driver")
 local count,captures=0,0
 local oldWrite,oldRead=Save.write,Save.readOptions
 local bytes
 local function check(v,message)assert(v,message);count=count+1;return v end
 Save.write=function(s)
  local valid,err=Save.validate(s);check(valid,err or "Guardado UI válido")
  bytes=assert(Json.encode(valid));return true
 end
 Save.readOptions=function()return {muted=true,textAnimation=false,reducedMotion=false}end
 local ok,err=xpcall(function()
  local app=require("src.app").new()
  local function fresh()
   local s=P.start(Save.newSession());P.wake(s)
   Events.apply(s,"starter_gift",{starter=true});Events.mark(s,"first_anomaly");Events.mark(s,"tutorial_completed");Events.mark(s,"combat_tutorial_completed");Events.mark(s,"nanahoshi_conversation_started")
   Events.apply(s,"hitogami_letter_read",{clue="hitogami_letter"})
   for _,id in ipairs({"letter_read","letter_collected","curse_discovered","nanahoshi_visited","starting_cards_received"}) do s.prologue[id]=true end
   s.checkpoint="day1_agenda";s.rewardQueue={};app.session=s
   return s
  end
  local function settle()
   app.manager:finishTransition();app:update(.1);app:draw()
  end
  local function capture(name)
   settle();app.toastTime=0;app:draw()
   local pixels=app.canvas:newImageData();local encoded=pixels:encode("png")
   local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/wives-"..name..".png","wb"))
   file:write(encoded:getString());file:close();pixels:release();encoded:release();captures=captures+1
  end
  local function click(label)
   settle()
   for _,b in ipairs(app.manager.current.buttons) do if b.label==label then
    check(not b.disabled,"Botón habilitado: "..label);b.action();settle();return
   end end
   error("Botón ausente: "..label)
  end
  local function greet(wife)
   local s=app.session
   E.syncPresence(s)
   require("tests.social_driver").approach(s,wife)
   app:explore();settle();local screen=app.manager.current;screen:keypressed("e")
   while screen.greeting do screen:advanceGreeting() end
   settle()
  end
  local function begin(id)
   local def=W.bank.byId[id]
   greet(def.character);check(app.manager.current.kind=="wife_activities","Saludo abre menú")
   local before=app.session.daily.interactions_used
   app.manager.current:inspect(def);settle()
   check(app.session.daily.interactions_used==before,"La reserva espera el cierre")
   app.manager.current:keypressed("return");settle()
   while app.manager.current.mode=="deal" do app.manager.current:update(.1) end
   app.manager.current:keypressed("1");settle()
   check(app.manager.current.mode=="preview","Vista previa de frase")
  end
  local function confirmAndExecute()
   local screen=app.manager.current
   local id=W.current(app.session).instance_id
   screen:keypressed("return");settle()
   while screen.mode=="playing" do screen:update(.1) end
   check(app.session.events[id.."_card_1"],"Carta hablada queda registrada")
   check(screen.bars:feedback()~=nil,"Barras muestran consecuencia aplicada")
   W.current(app.session).ended=true
   screen:keypressed("return");settle()
  end
  local s=P.start(Save.newSession());P.wake(s);app.session=s
  greet("eris");check(app.manager.current.kind=="exploration" and s.daily.interactions_used==0,"Saludo no abre matrimonio durante prólogo")
  s=fresh();greet("eris");capture("eris-offers")
  check(#app.manager.current.offers==3,"Tres ofertas de conversación")
  s=fresh();begin("S11");capture("sylphie-card-preview")
  confirmAndExecute();capture("sylphie-result")
  check(app.manager.current.mode=="review","Resultado de actividad")
  local x,y,map=s.exploration.x,s.exploration.y,s.exploration.map
  click("Volver a explorar")
  for _=1,20 do
   local screen=app.manager.current
   if screen.kind=="reward" then screen:continue()
   elseif screen.kind=="family_scene" then screen:advance() else break end
   settle()
  end
  check(app.manager.current.kind=="exploration" and s.exploration.map==map and s.exploration.x==x and s.exploration.y==y,"Regresa a la posición sin reiniciar mapa")
  s=fresh();begin("R03");confirmAndExecute()
  click("Fundamentos del flujo de agua · 35 oro");capture("roxy-purchase-confirm")
  local gold=s.gold;click("Cancelar");check(s.gold==gold,"Cancelar compra conserva oro")
  click("Fundamentos del flujo de agua · 35 oro");click("Pagar y comprar")
  check(s.gold==gold-35 and s.family.books.water_notes,"Compra real desde la UI")
  capture("roxy-purchase-result")
  s=fresh();begin("R04");confirmAndExecute();require("src.systems.card_collection").grant(s,"listen",10)
  click("Abrir mejoras de cartas")
  check(app.manager.current.kind=="upgrades","Roxy abre mejoras existentes")
  app.manager.current:improve();app.manager.current:update(.5);app.manager.current:update(.5);settle()
  check(s.collection.listen.level==2,"Mejora ejecutada")
  click("Continuar");check(app.manager.current.mode=="review","Mejora vuelve a la actividad")
  s=fresh();begin("E10");confirmAndExecute();capture("eris-rhythm")
  for _=1,3 do
   W.current(s).challenge.elapsed=0
   for _=1,8 do app.manager.current:update(.1) end
   app.manager.current:keypressed("space");settle()
  end
  check(s.wifeActivities.review.outcome=="success","Desafío real reconoce pulsaciones")
  s=fresh();begin("R15");confirmAndExecute()
  W.closeReview(s);s.family.queue={};s.rewardQueue={}
  for _=1,2 do
   require("tests.social_driver").approach(s,"roxy");assert(W.start(s,"R15",s.economy.revision))
   require("tests.social_driver").play(s);require("tests.social_driver").close(s);W.closeReview(s)
  end
  s.family.queue={};s.rewardQueue={}
  Events.mark(s,"day1_complete")
  local bed=require("src.data.rest").beds.dormitorio_roxy
  require("tests.campaign_world_driver").travel(s,"dormitorio_roxy")
  Driver.walk(s,function(p)return (p.x-bed.x)^2+(p.y-bed.y)^2<16^2 end)
  app:explore();capture("roxy-bedroom-rest")
  app.manager.current:keypressed("e");settle()
  check(app.manager.current.kind=="rest","Cama abre descanso")
  check(app.manager.current.preview,"El descanso ofrece confirmación directa");capture("rest-confirm")
  click("Confirmar descanso")
  for _=1,30 do
   local screen=app.manager.current
   if screen.kind=="family_scene" then screen:advance()
   elseif screen.kind=="reward" then screen:continue() else break end
   settle()
  end
  check(app.manager.current.kind=="day_report","Noche abre resumen")
  capture("night-report")
  click("Comenzar día 2")
  check(app.manager.current.kind=="exploration" and s.exploration.map=="dormitorio_roxy","Despierta en dormitorio elegido")
  capture("roxy-next-morning")
  app.session=assert(Save.validate(assert(Json.decode(bytes))));app:resume();settle()
  check(app.session.day==2 and app.session.exploration.map=="dormitorio_roxy","Carga tras despertar")
  local before=s.exploration.x
  check(E.move(app.session.exploration,1,0,.1),"Recupera movimiento al despertar")
  app.manager.current:keypressed("g");settle()
  check(app.manager.current.kind=="exploration" and app.session.rest.waking and app.session.exploration.map=="dormitorio_roxy","G no abre ninguna agenda")
  s=fresh();require("src.systems.family").depart(s,"roxy","test");s.family.queue={}
  E.syncPresence(s)
  check(s.exploration.absentNpcs.roxy,"Esposa separada deja de aparecer en el dormitorio")
  s.exploration.active=false;app:resume();settle();app.manager.current.tab="roxy";capture("separated-portrait")
  app:switch(require("src.screens.wife_activities").new(app,"roxy",true));settle()
  app.manager.current:inspect(W.bank.byId.R14);capture("separated-requirement")
  check(not W.available(s,"R14",true),"Separación bloquea el inicio")
 end,debug.traceback)
 Save.write=oldWrite;Save.readOptions=oldRead
 if not ok then error(err) end
 print("Wife activities UI: "..count.." checks; "..captures.." real renderer captures; greetings, previews, purchases, upgrades, rhythm, rest and wake.")
 return count
end
return Suite
