local Suite={}
function Suite.run()
 local Save=require("src.systems.save");local Events=require("src.systems.events")
 local Combat=require("src.systems.combat");local Sim=require("tests.war_balance")
 local checks,captures=0,0;local function check(ok,msg)assert(ok,msg);checks=checks+1 end
 local previousOptions=Save.readOptions;Save.readOptions=function()return {muted=true,textAnimation=false,reducedMotion=false}end
 local app=require("src.app").new();app.mouse=function()return nil,nil end
 local function settle()app:update(2);app:draw()end
 local function capture(name)
  app.toastTime=0;app:draw();local pixels=app.canvas:newImageData();local bytes=pixels:encode("png")
  local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/war-"..name..".png","wb"));file:write(bytes:getString());file:close();pixels:release();bytes:release();captures=captures+1
 end
 local function click(label)
  app:draw()
  for _,b in ipairs(app.manager.current.buttons)do if b.label==label and not b.disabled then
   app:mousepressed(app.offsetX+(b.x+b.w/2)*app.scale,app.offsetY+(b.y+b.h/2)*app.scale,1);return
  end end
  error("Botón no disponible: "..label)
 end
 local function open(affinity)
  local s=Save.newSession();Events.apply(s,"starter_gift",{starter=true})
  for _,id in ipairs(Sim.deck)do if not s.unlocked[id] then Events.apply(s,"fixture_"..id,{unlock={id}})end;s.collection[id].level=5 end
  s.combatDeck=Sim.deck;s.rewardQueue={};s.day=7;s.checkpoint="day7_boss";s.decisions.day7_companion="all";s.externalEnergy=30
  for _,r in pairs(s.relationships)do r.love=affinity;r.trust=affinity end
  require("src.systems.daily").ensure(s);app.session=s;app:resume();settle();return app.manager.current
 end
 local screen=open(90)
 check(screen.briefingOpen and screen.enc.enemy.maxHp==1000,"Preparación real antes del jefe")
 capture("preparation");click("Habilidades [T]");settle();click("Roxy");capture("roxy-skills")
 local before=screen.enc.revision;screen:support("special")
 -- Las acciones en la interfaz están deshabilitadas hasta cerrar preparación.
 if screen.enc.revision~=before then error("La preparación permite ejecutar una habilidad")end
 click("Volver [Esc / T]");click("Comenzar [Enter]");screen:keypressed("t");settle();click("Roxy")
 local expected=Combat.supportPreview(screen.enc,"roxy","special").hpLost
 click("Conjuro combinado");local revision=screen.enc.revision
 screen:support("special");check(screen.enc.revision==revision,"Pulsaciones rápidas no duplican apoyo")
 settle();check(screen.enc.enemy.hp==1000-expected and screen.displayHp.enemy==screen.enc.enemy.hp,"PV y barra muestran daño real")
 capture("combined-impact")
 local loaded=assert(Save.load());check(loaded.combat and loaded.combat.supportUsed.roxy,"Apoyo consumido persiste")
 app:continueGame();settle();screen=app.manager.current
 check(not Combat.canSupport(screen.enc,"roxy","special"),"Cargar no recupera acción ni recarga")
 local phases={}
 while not screen.enc.finished do
  local phase=screen.enc.enemy.phase
  if not phases[phase] then phases[phase]=true;capture("phase-"..phase)end
  require("tests.combat_visual").drive(screen);settle()
 end
 check(phases.six_arms and phases.resolve and phases.seal,"Cuatro fases visibles en la pantalla real")
 capture("boss-victory");screen:continue();settle()
 check(app.session.inventory.antidote and app.session.curse.active,"Victoria entrega antídoto sin curar automáticamente")
 local gold=app.session.gold;screen:continue();check(app.session.gold==gold,"Recompensa final única")
 screen=open(24.99);capture("low-affinity-preparation");click("Comenzar [Enter]")
 while screen.enc.player.hp>10 do Combat.endTurn(screen.enc)end
 app:save();app:resume();settle();screen=app.manager.current;screen:keypressed("t");settle();click("Sylphiette")
 capture("healing-warning");click("Curar a Rudy");capture("risk-confirmation")
 local hp=screen.enc.player.hp;local rev=screen.enc.revision
 click("Cancelar");check(screen.enc.player.hp==hp and screen.enc.revision==rev,"Cancelar no gasta ni causa daño")
 click("Curar a Rudy");click("Confirmar el riesgo");settle()
 check(screen.enc.outcome=="defeat" and screen.enc.player.hp==0 and screen.displayHp.player==0,"Interferencia puede derrotar y muestra cero real")
 capture("interference-defeat")
 Save.readOptions=previousOptions
 print("War UI: "..checks.." checks; "..captures.." real-renderer captures.")
 return checks
end
return Suite
