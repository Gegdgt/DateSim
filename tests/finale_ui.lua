local Suite={}
function Suite.run()
 local Save=require("src.systems.save");local Events=require("src.systems.events");local F=require("src.systems.finale")
 local Collection=require("src.systems.card_collection");local Json=require("src.systems.json")
 local previous=Save.readOptions;Save.readOptions=function()return {muted=true,textAnimation=false,reducedMotion=false}end
 local app=require("src.app").new();app.mouse=function()return nil,nil end
 local checks,captures=0,0;local function check(ok,msg)assert(ok,msg);checks=checks+1 end
 local function settle()app:update(2);if app.manager.transition>0 then app:update(2)end;app:draw()end
 local function capture(name)
  app.toastTime=0;app:draw();local pixels=app.canvas:newImageData();local bytes=pixels:encode("png")
  local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/finale-"..name..".png","wb"));file:write(bytes:getString());file:close();pixels:release();bytes:release();captures=captures+1
 end
 local function click(label)
  app:draw();for _,b in ipairs(app.manager.current.buttons)do if b.label==label and not b.disabled then
   app:mousepressed(app.offsetX+(b.x+b.w/2)*app.scale,app.offsetY+(b.y+b.h/2)*app.scale,1);return
  end end;error("Botón no disponible: "..label)
 end
 local s=Save.newSession();Events.apply(s,"starter_gift",{starter=true});s.rewardQueue={}
 s.day=6;s.checkpoint="day6_orsted_demonstration";require("src.systems.daily").ensure(s)
 app.session=s;app:resume();settle();capture("orsted-preparation")
 local combat=app.manager.current
 check(combat.briefingOpen and combat.enc.enemy.maxHp==120,"La demostración muestra reglas y guardia finita")
 local before=assert(Json.encode(s.relationships))
 click("Comenzar [Enter]")
 while not combat.enc.finished do require("tests.combat_visual").drive(combat);settle()end
 capture("orsted-narrative-defeat")
 check(combat.enc.narrativeDefeat and combat.enc.turn==4,"Orsted termina la secuencia en cuatro turnos")
 check(not combat.enc.outcome or combat.enc.outcome~="victory","La interfaz no anuncia victoria imposible")
 click("Continuar");settle();capture("orsted-discovery")
 check(assert(Json.encode(s.relationships))==before,"La derrota no penaliza matrimonios")
 local guard=0
 while app.manager.current.kind~="orsted_reward" do
  guard=guard+1;assert(guard<140,"Entrega de patrones bloqueada")
  local screen=app.manager.current
  if screen.kind=="reward" then screen:continue()else screen:advance()end
  settle()
 end
 check(s.events.orsted_collection_gift and s.unlocked.water_cannon,"Se presentan los patrones que faltaban")
 local reward=app.manager.current;reward.selected="staff_strike";capture("choose-combat")
 local gold=s.gold;local copies=s.collection.staff_strike.copies
 click("Elegir y maximizar");app:update(.3);capture("maximizing-combat")
 reward:choose();check(s.orsted_reward.revision==1,"Doble clic sólo reclama una mejora")
 app:save();app:continueGame();app:update(.1);app:draw();reward=app.manager.current;s=app.session
 check(reward.kind=="orsted_reward" and s.orsted_reward.pending and s.orsted_reward.pending.id=="staff_strike","Carga durante el destello conserva su presentación")
 settle();capture("combat-maximized");click("Continuar presentación");settle()
 reward=app.manager.current;reward.selected="listen";capture("choose-social")
 click("Elegir y maximizar");settle();capture("social-maximized");click("Continuar presentación");settle()
 check(s.collection.staff_strike.level==10 and s.collection.listen.level==10 and s.gold==gold and s.collection.staff_strike.copies==copies,"Dos mejoras gratuitas, sin gasto")
 check(F.rewardComplete(s),"Ambas presentaciones terminadas")
 click("Continuar historia");settle();check(s.checkpoint=="day6_close","Vuelve a la historia")
 -- Regreso y archivo con una separación permanente y otros matrimonios pendientes.
 for _,r in pairs(s.relationships)do r.marriageState="separated"end
 s.day=7;s.checkpoint="day7_return_cards";Events.apply(s,"antidote_obtained",{antidote=true});Events.apply(s,"test_cure",{cure=true})
 require("src.systems.daily").ensure(s);s.rewardQueue={};app:resume();settle();capture("return-cards")
 local archive=assert(Json.encode(s.collection));guard=0
 while s.checkpoint=="day7_return_cards" do guard=guard+1;assert(guard<20);app.manager.current:advance();settle()end
 check(s.inventory.enchantedCardsReturned and assert(Json.encode(s.collection))==archive,"Devolución conserva registro y niveles")
 capture("epilogue-solitary")
 app:save();local restored=assert(Save.load());check(restored.inventory.enchantedCardsReturned and restored.relationships.eris.marriageState=="separated","Cierre y separaciones sobreviven a la carga")
 -- Cada epílogo usa la escena y los retratos reales, con su estado matrimonial.
 for _,ending in ipairs(require("src.data.endings").list)do
  local route=Save.newSession();Events.apply(route,"starter_gift",{starter=true});route.rewardQueue={}
  route.day=7;route.checkpoint="day7_return_cards";require("src.systems.daily").ensure(route)
  Events.apply(route,"antidote_obtained",{antidote=true});Events.apply(route,"test_cure",{cure=true})
  for id,r in pairs(route.relationships)do
   if ending.id=="family_united" or ending.id==id then
    r.love=80;r.trust=80;r.events.personal_resolution=true;r.criticalDecisions.commitment=true
   else r.marriageState="separated"end
  end
  app.session=route;app:resume();settle();guard=0
  while route.checkpoint=="day7_return_cards" do guard=guard+1;assert(guard<20);app.manager.current:advance();settle()end
  check(route.checkpoint=="day7_epilogue_"..ending.id and route.inventory.enchantedCardsReturned,"Escena específica después de devolver: "..ending.id)
  check(app.manager.current.scene.title=="Epílogo · "..ending.title,"El render muestra el epílogo actual: "..ending.id)
  capture("epilogue-"..ending.id)
 end
 -- El manual mantiene el misterio antes de la revelación.
 app.session=Save.newSession();app:manual();settle();local manual=app.manager.current;manual:changeSection(5)
 for i,rule in ipairs(require("src.data.manual").rules)do if rule.requiresReveal then manual.page=i;break end end
 capture("manual-mystery")
 Save.readOptions=previous
 print("Finale UI: "..checks.." checks; "..captures.." real-renderer captures, narrative defeat, free choices, reload and return.")
 return checks
end
return Suite
