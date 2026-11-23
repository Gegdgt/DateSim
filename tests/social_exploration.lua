local Suite={}
function Suite.run()
 local D=require("tests.social_driver")
 local W=require("src.systems.wife_activities")
 local E=require("src.systems.exploration")
 local V=require("src.systems.map_validation")
 local Maps=require("src.data.maps")
 local Daily=require("src.systems.daily")
 local Rest=require("src.systems.rest")
 local Save=require("src.systems.save")
 local Json=require("src.systems.json")
 local Rules=require("src.systems.social_rules")
 local count,captures=0,0
 local function check(v,m)assert(v,m);count=count+1;return v end
 local function encode(v)return assert(Json.encode(v))end
 local function clone(s)return assert(Json.decode(encode(s)))end
 local function snapshot(s)return encode({s.gold,s.collection,s.relationships,s.daily,s.events})end
 local function present(s,id)
  local n=0
  for mapId,map in pairs(Maps) do for _,npc in ipairs(map.npcs.placements) do
   if npc.id==id and E.npcPresent(s.exploration,npc,mapId) then n=n+1 end
  end end
  return n
 end
 local Font=require("src.ui.font")
 for _,def in ipairs(W.bank.list) do
  check(Font.height("3. "..def.offer,184,1)<=38,"Propuesta legible sin recorte: "..def.id)
  check(Font.height(def.closing,462,1)<=44,"Cierre legible: "..def.id)
  for id,response in pairs(def.responses) do
   check(Font.height(response.rudy,173,1)<=88,"Frase dentro del detalle: "..def.id.."/"..id)
   check(Font.height(response.reply,462,1)<=44,"Reacción dentro del panel: "..def.id.."/"..id)
   for _,variant in pairs(response.after or {}) do
    check(Font.height(variant.rudy or response.rudy,173,1)<=88,"Variante legible")
    check(Font.height(variant.reply or response.reply,462,1)<=44,"Reacción contextual legible")
   end
  end
 end
 for _,point in ipairs({{80,160,"sillón"},{114,124,"sofá"},{490,296,"silla"},{526,161,"silla de cocina"},{178,169,"brazo de farol"},{549,171,"lámpara"}}) do
  local map=point[1]>170 and point[2]==169 or point[2]==171
  check(V.isWalkable(map and Maps.camino_sharia or Maps.casa_planta_baja,{x=point[1],y=point[2]}),"Transitable: "..point[3])
 end
 check(not V.isWalkable(Maps.casa_planta_baja,{x=130,y=158}),"Mesa sólida")
 check(not V.isWalkable(Maps.casa_planta_baja,{x=238,y=120}),"Pared sólida")
 check(not V.isWalkable(Maps.casa_planta_baja,{x=2,y=200}),"Límite del mapa")
 check(require("src.systems.map_validation").validate(Maps,require("src.data.map_connections")).ok,"Accesos y geometría válidos")
 for _,route in ipairs({{"casa_planta_baja",65,160,1,0},{"casa_planta_baja",478,296,1,0},{"camino_sharia",160,169,1,0}}) do
  local e={map=route[1],x=route[2],y=route[3]}
  E.move(e,route[4],route[5],.3)
  check(e.x>route[2]+20,"Movimiento real por asientos y junto al farol")
 end
 local s=D.fresh()
 for id,map in pairs({eris="patio_eris",roxy="biblioteca_ranoa",sylphiette="casa_planta_baja"}) do
  check(s.exploration.npcLocations[id].map==map,"Ubicación diurna "..id)
  check(present(s,id)==1,"NPC único "..id)
  D.approach(s,id);check(E.nearCharacter(s,id),"Ruta accesible "..id)
  check(D.round(s).exploration.npcLocations[id].map==map,"Ubicación al cargar "..id)
 end
 D.approach(s,"sylphiette")
 local before=snapshot(s)
 check(not W.start(s,"E11",s.economy.revision),"No se inicia Eris desde Sylphie")
 check(before==snapshot(s),"Inicio inválido sin consumo")
 check(Rules.cost("listen","sylphiette")==3 and Rules.cost("listen","roxy")==1 and Rules.cost("listen","eris")==2,"Costes diferenciados 3/1/2")
 for wife,id in pairs({eris="E11",roxy="R15",sylphiette="S11"}) do
  s=D.fresh();D.approach(s,wife);local a=check(W.start(s,id,s.economy.revision),"Iniciar "..id)
  check(s.daily.interactions_used==0,"Reserva no consume antes del cierre")
  local original=encode({a.initialOrder,a.hand,a.drawPile,a.shuffleSteps})
  s=D.round(s);a=W.current(s)
  check(original==encode({a.initialOrder,a.hand,a.drawPile,a.shuffleSteps}),"Reparto persistente "..wife)
  check(#a.hand==3,"Toma tres cartas "..wife)
  local plays=0
  while W.current(s) and a.phase~="battle" do
   a.phase="hand"
   local chosen
   for _,card in ipairs(a.hand) do if W.canPlay(s,card) and (not chosen or W.cost(s,card)<W.cost(s,chosen)) then chosen=card end end
   if not chosen then W.endConversation(s);break end
   local energy=a.energy;local cost=W.cost(s,chosen)
   local rel=encode(s.relationships)
   check(W.choose(s,chosen),"Confirmar carta")
   check(not W.choose(s,chosen),"Doble confirmación bloqueada")
   check(rel==encode(s.relationships),"Reacción aún no presentada")
   s=D.round(s);a=W.current(s)
   check(a.energy==energy-cost,"Descuento persistente")
   check(W.react(s),"Reacción aplicada")
   check(not W.react(s),"Reacción no duplicada")
   check(a.log[#a.log].delta~=nil,"Deltas efectivos guardados")
   s=D.round(s);a=W.current(s);plays=plays+1
   check(W.execute(s),"Continuación contextual")
   if s.wifeActivities.review then break end
  end
  check(plays<=3 and plays>=2,"Hasta tres cartas según energía")
  if wife=="eris" then check(plays==3,"Recorrido A utiliza tres cartas") end
  check(s.daily.interactions_used==1,"Una interacción para la actividad completa")
  local stable=snapshot(s);check(not W.finish(s,"complete") and snapshot(s)==stable,"Sin premios duplicados")
  s=D.round(s);check(s.wifeActivities.review~=nil,"Recibo persistente")
  W.closeReview(s);check(s.exploration.period=="day","Primera actividad mantiene ubicaciones")
 end
 local a;s,a=D.startWithHand("S11",{"listen"})
 a.phase="hand";local has=false;for _,id in ipairs(a.hand) do if id=="listen" then has=true end end
 check(has,"Escuchar procede del mazo equipado")
 local initialLove=s.relationships.sylphiette.love
 D.play(s,"listen");check(s.relationships.sylphiette.love-initialLove==5 and a.energy==3,"Escuchar con Sylphie +5, coste 3")
 local damaged=clone(s);damaged.daily.active_activity.energy=6
 check(not Save.validate(damaged),"Rechaza energía fabricada")
 damaged=clone(s);damaged.daily.active_activity.initialOrder[1]="angry_reply"
 check(not Save.validate(damaged),"Rechaza mazo fabricado")
 s,a=D.startWithHand("R15",{"listen"});initialLove=s.relationships.roxy.love
 D.play(s,"listen");check(s.relationships.roxy.love-initialLove==1 and a.energy==5,"Escuchar con Roxy +1, coste 1")
 s,a=D.startWithHand("S15",{"light_joke","listen"})
 D.play(s,"light_joke");assert(W.execute(s));local beforeContext=s.relationships.sylphiette.love
 D.play(s,"listen");check(s.relationships.sylphiette.love==beforeContext-1,"Afinidad no anula un contexto negativo")
 D.close(s);local contextual=s.wifeActivities.review.reply
 check(D.round(s).wifeActivities.review.reply==contextual,"Carga conserva la reacción contextual del cierre")
 s=D.fresh();s.relationships.sylphiette.promises.family_errand="pending"
 check(W.offers(s,"sylphiette")[1].id=="S03","Compromiso pendiente conserva acceso garantizado")
 -- Las manos anteriores a esta ampliación conservan sus cartas y su reserva.
 s=D.fresh();D.approach(s,"eris");a=assert(W.start(s,"E11",s.economy.revision))
 a.socialVersion=nil;a.phase="hand";a.pendingReservation=nil
 s.daily.interactions_used=1;s.daily.visits.eris=1
 for _,field in ipairs({"handVersion","initialOrder","shuffleSource","shuffleSteps","energy","maxEnergy","maxCards","log","drawPile","discard"}) do a[field]=nil end
 s=D.round(s);local legacyHand=encode(W.current(s).hand)
 D.play(s);check(#W.current(s).log==1 and #W.current(s).hand==2,"Continúa una mano social anterior")
 check(legacyHand~=encode(W.current(s).hand),"La migración usa la carta que ya estaba en mano")
 s=D.round(s);D.close(s);check(s.daily.interactions_used==1,"Reserva antigua no se cobra dos veces")
 for _,distribution in ipairs({{"eris","roxy","sylphiette"},{"eris","eris","roxy"},{"sylphiette","sylphiette","sylphiette"}}) do
  s=D.fresh()
  for _,wife in ipairs(distribution) do
   D.approach(s,wife);assert(W.start(s,({eris="E11",roxy="R15",sylphiette="S11"})[wife],s.economy.revision))
   D.play(s);D.close(s);W.closeReview(s)
  end
  check(s.exploration.period=="night","Tres interacciones totales con cualquier distribución")
 end
 for i=1,3 do
  if i==1 then s=D.fresh() end
  D.approach(s,"eris");a=assert(W.start(s,"E11",s.economy.revision));D.play(s);D.close(s)
  check(s.exploration.npcLocations.eris.map=="patio_eris","No trasladar durante recibo")
  W.closeReview(s);s=D.round(s)
  check(s.exploration.period==(i==3 and "night" or "day"),"Horario tras "..i.." actividades")
 end
 for _,wife in ipairs({"eris","roxy","sylphiette"}) do
  check(s.exploration.npcLocations[wife].map:match("^dormitorio_"),"Dormitorio "..wife)
  check(present(s,wife)==1,"Sin duplicados nocturnos "..wife)
 end
 local nightSession=D.round(s)
 check(not W.start(s,"E11",s.economy.revision),"Cuarta actividad bloqueada")
 require("src.systems.events").mark(s,Daily.config(s).completionEvent)
 D.approach(s,"roxy");local bed=Rest.bed(s)
 local ready,reason=Rest.available(s,bed);check(ready,"Descanso desde esposa presente: "..tostring(reason))
 local prior=s.relationships.roxy.love
 check(Rest.confirm(s,bed,Rest.options(s,bed)[1].id),"Noche confirmada")
 check(s.relationships.roxy.love==prior-20+10,"Ausencia y bonus nocturno independientes")
 check(not Rest.confirm(s,bed,Rest.options(s,bed)[1].id),"Noche única")
 check(require("src.systems.progression").endDay(s),"Resumen")
 check(require("src.systems.progression").next(s),"Nueva jornada")
 E.syncPresence(s);check(s.exploration.period=="day" and s.exploration.npcLocations.roxy.map=="biblioteca_ranoa","Horario del siguiente día")
 s=D.fresh();check(not Daily.requestFavor(s,"social_research","cliff",false),"Sin encargos remotos")
 D.approach(s,"cliff");check(Daily.requestFavor(s,"social_research","cliff",false),"Encargo físico")
 D.approach(s,"eris");check(not Daily.accelerateFavor(s,s.pending_favors[1].instance_id),"Sin ayuda remota")
 s=D.round(s);check(#s.pending_favors==1,"Encargo persistente")
 local oldWrite,oldRead=Save.write,Save.readOptions
 Save.write=function(game)check(Save.validate(clone(game)),"Guardado válido desde UI");return true end
 Save.readOptions=function()return {muted=true,textAnimation=false,reducedMotion=false}end
 local ok,err=xpcall(function()
  local app=require("src.app").new()
  local function settle()app.manager:finishTransition();app:draw()end
  local function capture(name)
   settle();app.toastTime=0;app:draw()
   local pixels=app.canvas:newImageData();local data=pixels:encode("png")
   local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/social-"..name..".png","wb"))
   file:write(data:getString());file:close();pixels:release();data:release();captures=captures+1
  end
  for wife,id in pairs({eris="E11",roxy="R15",sylphiette="S11"}) do
   app.session=D.fresh();D.approach(app.session,wife);app:explore();settle()
   capture(wife.."-world")
   local world=app.manager.current;world:keypressed("g");check(app.manager.current==world,"G no hace nada")
   world:keypressed("e");settle()
   local screen=app.manager.current;check(screen.kind=="wife_activities" and #screen.offers==3,"Tres actividades físicas")
   capture(wife.."-offers")
   local y
   for _,button in ipairs(screen.buttons) do
    check(not button.label:find("oro") and not button.label:find("esposa"),"Sin premios ni navegación global")
    y=y or button.y;check(y==button.y,"Opciones horizontales")
   end
   screen:keypressed("right");check(screen.selectedIndex==2,"Flecha selecciona oferta")
   screen:keypressed("left");check(screen.selectedIndex==1 and not W.current(app.session),"Elegir no inicia sin confirmar")
   -- Encontrar la oferta por los encuentros reales, sin abrir actividades ocultas.
   local offered
   for attempt=1,10 do
    for index,def in ipairs(screen.offers) do if def.id==id then offered=index end end
    if offered then break end
    screen:keypressed("escape");settle();app.manager.current:keypressed("e");settle();screen=app.manager.current
   end
   check(offered,"Actividad disponible en las tres respuestas físicas")
   if wife=="roxy" then
    local button=screen.buttons[offered];screen:mousepressed(button.x+5,button.y+5,1)
   else screen:keypressed(tostring(offered));check(not W.current(app.session),"Número sólo selecciona oferta");screen:keypressed("return") end
   settle();screen=app.manager.current
   screen:keypressed("return");screen:update(.7);capture(wife.."-shuffle")
   while screen.mode=="deal" do screen:update(.1) end
   local current=W.current(app.session);local i=1
   for index,card in ipairs(current.hand) do if card=="listen" then i=index end end
   screen:keypressed(tostring(i));capture(wife.."-hand")
   check(screen.mode=="preview","Previsualización de frase")
   screen:keypressed("return");screen:update(.4);capture(wife.."-play")
   screen:keypressed("return");check(#current.log==1,"UI bloquea doble entrada")
   while screen.mode=="playing" do screen:update(.1) end
   capture(wife.."-reaction")
   local capturedRefill=false
   while W.current(app.session) do
    screen=app.manager.current
    if screen.mode=="reply" then screen:nextPhase()
    elseif screen.mode=="hand" then
     local chosen
     for j,card in ipairs(W.current(app.session).hand) do if W.canPlay(app.session,card) then chosen=j;break end end
     if chosen then screen:keypressed(tostring(chosen));screen:keypressed("return")
     else screen:keypressed("p") end
    elseif screen.mode=="playing" or screen.mode=="refill" then
     if screen.mode=="refill" and not capturedRefill then screen:update(.2);capture(wife.."-refill");capturedRefill=true end
     screen:update(.1)
    else error("Fase inesperada: "..screen.mode) end
    settle()
   end
   capture(wife.."-receipt")
   check(app.session.daily.interactions_used==1,"UI consume una actividad")
  end
  app.session=D.fresh();D.approach(app.session,"eris");app:explore();settle()
  app.manager.current:keypressed("e");settle();app.manager.current:keypressed("return");settle()
  local refillScreen=app.manager.current;refillScreen:keypressed("return")
  while refillScreen.mode=="deal" do refillScreen:update(.1) end
  local refillActivity=W.current(app.session);local cheap=1
  for i,id in ipairs(refillActivity.hand) do if W.cost(app.session,id)<W.cost(app.session,refillActivity.hand[cheap]) then cheap=i end end
  refillScreen:keypressed(tostring(cheap));refillScreen:keypressed("return")
  while refillScreen.mode=="playing" do refillScreen:update(.1) end
  refillScreen:nextPhase();settle();refillScreen=app.manager.current
  check(refillScreen.mode=="refill","Reposición animada desde el mazo real")
  refillScreen:update(.2);capture("eris-refill")
  check(D.round(app.session).daily.active_activity.phase=="refill","Guardar durante reposición conserva la carta")
  app.session=D.fresh();D.approach(app.session,"cliff");app:explore();settle()
  app.manager.current:keypressed("e")
  while app.manager.current.greeting do app.manager.current:advanceGreeting() end
  app.manager.current:keypressed("1");capture("cliff-commission")
  check(app.manager.current.kind=="commissions","Cliff abre encargos propios")
  app.session=D.round(nightSession)
  for _,wife in ipairs({"eris","roxy","sylphiette"}) do
   D.approach(app.session,wife);app:explore();capture(wife.."-night")
  end
  require("src.systems.events").mark(app.session,Daily.config(app.session).completionEvent)
  app.manager.current:keypressed("e");capture("rest-question")
  check(app.manager.current.kind=="rest","La esposa nocturna propone descanso")
  app.session=D.fresh();E.enter(app.session.exploration,"camino_sharia",{x=178,y=169});app:explore();capture("lamp-passage")
 end,debug.traceback)
 Save.write,Save.readOptions=oldWrite,oldRead
 if not ok then error(err) end
 print("Social exploration: "..count.." checks; "..captures.." renderer captures; physical routes, 3 cards, energy, schedules, save/reload and commissions.")
 return count
end
return Suite
