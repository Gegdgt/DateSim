local Suite={}
function Suite.run()
 local Save=require("src.systems.save")
 local Events=require("src.systems.events")
 local R=require("src.systems.card_rewards")
 local Collection=require("src.systems.card_collection")
 local Json=require("src.systems.json")
 local Font=require("src.ui.font")
 local count,captures=0,0
 local function check(v,m)assert(v,m);count=count+1;return v end
 local function encode(v)return assert(Json.encode(v))end
 local party={"rudeus","nanahoshi","cliff","zanoba"}
 local function fixture(ids,participants)
  local s=Save.newSession();s.checkpoint="day1_agenda"
  assert(Events.apply(s,"reward_fixture",{unlock=ids or {"listen","magic_bolt","staff_strike","encourage","subtle_flirt"},
   celebration={participants=participants or party,background="laboratory",important=true}}))
  return s,s.rewardQueue[1]
 end
 local function stock(s)return encode({s.collection,s.unlocked,s.externalEnergy,s.curse,s.deck,s.combatDeck})end
 local s,reward=fixture({"listen"})
 check(R.prepare(reward).phase=="individual","Una carta inicia directamente la revelación")
 local granted=stock(s)
 check(not Events.apply(s,"reward_fixture",{unlock={"listen"}}) and stock(s)==granted,"Evento idempotente")
 check(not Events.queueCards(s,"reward_fixture",{{cardId="listen",count=1,new=true}},"nanahoshi") and #s.rewardQueue==1,"No duplicar la cola del mismo evento")
 local bad=Save.newSession();local untouched=stock(bad)
 check(not Events.apply(bad,"bad_party",{unlock={"listen"},celebration={participants={"rudeus","missing"}}}) and untouched==stock(bad),"Validación antes de conceder una recompensa")
 local outcomes={}
 for _,mode in ipairs({"individual","all"}) do
  s,reward=fixture();local before=stock(s);local p=R.prepare(reward)
  check(p.phase=="choice" and #reward.cards==5,"Lote permite elegir")
  check(R.choose(reward,mode),"Modalidad "..mode)
  if mode=="individual" then
   for i=1,5 do
    check(p.index==i and p.phase=="individual","Todas las cartas individuales")
    p.elapsed=R.duration;check(not R.advance(reward),"Resumen obligatorio antes de cerrar")
   end
  else p.elapsed=R.duration;R.advance(reward) end
  check(p.phase=="summary" and R.pages(reward)==2,"Resumen completo paginado")
  check(stock(s)==before and R.advance(reward),"La presentación no modifica recompensas")
  outcomes[mode]=stock(s)
 end
 check(outcomes.individual==outcomes.all,"Ambas modalidades entregan exactamente lo mismo")
 s,reward=fixture();granted=stock(s);R.choose(reward,"individual");R.skip(reward)
 check(R.prepare(reward).phase=="summary" and stock(s)==granted,"Omitir conserva todas las cartas")
 s.collection.magic_bolt.level=2;s.collection.magic_bolt.copies=2;s.rewardQueue={}
 assert(Events.apply(s,"duplicate_fixture",{copies={magic_bolt=3},presenter="roxy"}))
 reward=s.rewardQueue[1];local v=R.view(s,reward,"magic_bolt")
 check(not v.new and v.duplicates==3 and v.level==2 and v.copies==5,"Duplicado: +3 copias, nivel 2, total real 5")
 check(R.prepare(reward).phase=="choice","Varias copias también permiten elegir")
 for _,actor in ipairs({"nanahoshi","cliff","zanoba","eris","roxy","sylphiette","orsted"}) do
  local state=Save.newSession();assert(Events.apply(state,"source_"..actor,{unlock={"listen"},presenter=actor}))
  check(encode(state.rewardQueue[1].celebration.participants)==encode({"rudeus",actor}),"Participantes de "..actor)
 end
 local research=require("src.data.chapters.day4").transitions.day4_encounter[1].effects[1]
 check(encode(research.celebration.participants)==encode(party),"Investigación real declara a los cuatro")
 local starter=Save.newSession();assert(Events.apply(starter,"starter_gift",{starter=true}))
 check(#starter.rewardQueue[1].cards==10 and #starter.rewardQueue[1].celebration.participants==2,"Nanahoshi conserva diez cartas y su escena privada")
 -- Ninguna reacción mueve actores, gasta recursos o levanta el bloqueo mágico.
 s,reward=fixture();local unchanged=stock(s)
 for _,actor in ipairs(party) do
  for _,id in ipairs({"listen","magic_bolt","staff_strike"}) do
   local line=R.reaction(s,reward,id,actor)
   check(require("src.data.characters").expressions[line.expression]~=nil,"Sólo cuadros de expresión existentes")
   check(actor~="rudeus" or line.delivery=="thought","Rudy sellado sólo piensa")
  end
 end
 check(stock(s)==unchanged,"Reacciones sin efectos lógicos")
 s.curse.voiceSealed=false
 check(R.reaction(s,reward,"listen","rudeus").delivery=="speech","Voz recuperada permite hablar")
 reward.celebration.unknownEffect=true
 check(R.reaction(s,reward,"magic_bolt","nanahoshi").expression=="worried","Efecto desconocido preocupa a Nanahoshi")
 for actor,bank in pairs(require("src.data.reward_celebrations").lines) do
  for category,lines in pairs(bank) do
   check(#lines>=2,"Variantes por personaje/categoría: "..actor..category)
   local seen={};for _,line in ipairs(lines) do
    check(not seen[line],"Frases distintas");seen[line]=true
    check(Font.height(line,410,1)<=36,"Reacción cabe sin superponer controles: "..actor)
   end
  end
 end
 for _,card in ipairs(Collection.list) do
  check(Font.height(card.name,94,1)<=36,"Nombre completo en grupo: "..card.id)
 end
 -- Guardado real en disco y migración desde la presentación antigua.
 local identity=love.filesystem.getIdentity();love.filesystem.setIdentity("cartas_del_destino_v8_tests_rewards_disk")
 local diskOK,diskError=xpcall(function()
  for _,phase in ipairs({"choice","individual","group","summary"}) do
   local game,r=fixture();local p=R.prepare(r);p.phase=phase;p.mode=phase=="group" and "all" or "individual"
   p.index=3;p.page=2;p.elapsed=.637;p.line=3;p.appeared=true;p.revealed=true
   local before=stock(game);local state=encode(r)
   check(Save.write(game),"Guardar durante "..phase)
   local loaded,notice=Save.load()
   check(loaded and not notice and stock(loaded)==before,"Carga principal conserva concesión")
   check(encode(loaded.rewardQueue[1])==state,"Carga conserva participantes, página, modo y animación")
   check(not Events.apply(loaded,"reward_fixture",{unlock={"listen"}}),"Carga no reentrega")
  end
  local game,r=fixture();r.celebration=nil;r.presenter="nanahoshi";r.presentationPage=3
  assert(Save.write(game));local loaded=assert(Save.load());local p=R.prepare(loaded.rewardQueue[1])
  check(p.index==3 and p.phase=="individual","Guardado antiguo reanuda la carta pendiente")
 end,debug.traceback)
 love.filesystem.setIdentity(identity);assert(diskOK,diskError)
 local oldWrite,oldOptions=Save.write,Save.readOptions
 Save.write=function(game)assert(Save.validate(game));return true end
 Save.readOptions=function()return {muted=true,textAnimation=false,reducedMotion=false}end
 local ok,err=xpcall(function()
  local app=require("src.app").new();local exited=0
  local function show(game)
   app.session=game;app:presentRewards(function()exited=exited+1 end);app.manager:finishTransition();app:draw()
   return app.manager.current
  end
  local function capture(name)
   app.toastTime=0;app:draw();local pixels=app.canvas:newImageData();local data=pixels:encode("png")
   local f=assert(io.open(love.filesystem.getSource().."/tests/artifacts/reward-"..name..".png","wb"));f:write(data:getString());f:close()
   data:release();pixels:release();captures=captures+1
  end
  local screen=show(fixture());capture("choice-party")
  local unchanged=stock(app.session);local portrait=app.resources.portrait;local actors={}
  app.resources.portrait=function(resources,id,...)actors[#actors+1]=id;return portrait(resources,id,...)end
  app:draw();app.resources.portrait=portrait
  check(encode(actors)==encode(party),"Renderer usa los cuatro retratos reales declarados")
  screen:keypressed("1");screen:update(.1);capture("individual-back")
  local seen={}
  for i=1,5 do
   screen:update(1.1);app:draw();seen[screen.cards[screen.presentation.index]]=true
   if i==1 then capture("individual-social") end
   if i==2 then screen:nextReaction();capture("individual-magic") end
   screen:continue()
  end
  check(screen.presentation.phase=="summary" and stock(app.session)==unchanged,"UI individual sin nueva concesión")
  local n=0;for _ in pairs(seen) do n=n+1 end;check(n==5,"UI presenta todas las cartas una a una")
  capture("summary-page-1");screen:keypressed("right");capture("summary-page-2")
  screen:continue();screen:continue()
  check(exited==1 and #app.session.rewardQueue==0,"Cerrar repetidamente no duplica ni pierde recibos")
  screen=show(fixture());app:draw()
  local target;for _,b in ipairs(screen.buttons) do if b.label=="RECIBIR TODAS [2]" then target=b end end
  screen:mousepressed(target.x+5,target.y+5,1);screen:update(.1);capture("group-backs")
  screen:update(1.1);check(screen.presentation.phase=="summary","Modo grupal revela y llega al resumen")
  capture("group-revealed");screen:keypressed("right");check(screen.presentation.page==2,"Paginación accesible por teclado")
  screen:keypressed("r");check(screen.presentation.line==2,"Reacciones accesibles por teclado")
  screen:continue()
  local duplicate=fixture({"magic_bolt"},{"rudeus","roxy"});duplicate.collection.magic_bolt.level=2;duplicate.collection.magic_bolt.copies=2;duplicate.rewardQueue={}
  assert(Events.apply(duplicate,"three_copies",{copies={magic_bolt=3},presenter="roxy"}))
  screen=show(duplicate);screen:choose("individual");screen:update(2);capture("duplicate-roxy")
  check(screen.reward.counts.magic_bolt==3 and not screen:isNew(),"UI de repetida usa el recibo real")
  screen=show(fixture({"staff_strike"},{"rudeus","eris"}));screen:update(2);capture("training-eris")
  check(screen.presentation.phase=="individual","Una carta no ofrece selección innecesaria")
  screen=show(fixture());screen:choose("individual");screen:keypressed("s")
  check(screen.presentation.phase=="summary" and #screen.cards==5,"Recibir restantes muestra el resumen completo")
  local same=stock(app.session);screen:keypressed("m");screen:keypressed("2");screen:update(2)
  check(stock(app.session)==same and screen.presentation.phase=="summary","Cambiar de modalidad no cambia ni duplica las recompensas")
  app.options.reducedMotion=true;screen=show(fixture());screen:choose("all");screen:update(.3);capture("reduced-motion")
  check(screen.presentation.phase=="summary","Movimiento reducido acorta la entrega")
  check(app.canvas:getFilter()=="nearest","Canvas mantiene nearest")
  app.options.reducedMotion=false
  local D=require("tests.social_driver");local Wife=require("src.systems.wife_activities")
  local game=D.fresh();D.approach(game,"roxy");local activity=assert(Wife.start(game,"R03",game.economy.revision))
  activity.phase="hand";assert(Wife.endConversation(game))
  assert(require("src.systems.economy").buyBook(game,"water_notes",game.economy.revision))
  local positions=encode(game.exploration.npcLocations)
  screen=show(game);screen:update(.2)
  check(encode(screen.reward.celebration.participants)==encode({"rudeus","roxy"}),"Compra real en actividad conserva a Roxy como participante")
  app.session=assert(Save.validate(assert(Json.decode(encode(game)))));app:resume();app.manager:finishTransition()
  check(app.manager.current.kind=="reward" and app.manager.current.presentation.elapsed==.2,"Cargar durante una compra reanuda la entrega antes del servicio")
  screen=app.manager.current;screen:skip();screen:continue();app.manager:finishTransition()
  check(app.manager.current.kind=="wife_activities" and Wife.current(app.session).phase=="service","Cierre de entrega cargada vuelve al servicio pendiente")
  check(encode(app.session.exploration.npcLocations)==positions,"Celebración no cambia las posiciones de NPC")
  local World=require("src.systems.world_content");local found
  for seed=1,40 do
   game=D.fresh(1,seed);World.generate(game)
   for _,object in ipairs(game.worldContent.days["1"]) do
    if object.reward.copies then found=object;break end
   end
   if found then break end
  end
  assert(found);assert(World.examine(game,found));local original=stock(game)
  screen=show(game);screen:update(2);capture("found-card-solo")
  check(encode(screen.reward.celebration.participants)==encode({"rudeus"}),"Hallazgo real no añade testigos inexistentes")
  World.examine(game,found);check(original==stock(game),"Revisitar el hallazgo no duplica cartas")
  screen:skip();screen:continue()
  local shop=require("src.screens.shop").new(app,"listen");app:switch(shop)
  shop:purchase("listen",app.session.economy.revision,2);app.manager:finishTransition()
  check(app.manager.current.kind=="reward" and app.manager.current.reward.counts.listen==2,"Compra de copias abre el componente compartido")
  app.manager.current:skip();app.manager.current:continue();app.manager:finishTransition()
  check(app.manager.current==shop,"Entrega de tienda vuelve a la misma tienda")
  app.audio:stop()
 end,debug.traceback)
 Save.write,Save.readOptions=oldWrite,oldOptions;assert(ok,err)
 print("Card rewards: "..count.." checks; individual/group/skip, contextual cast, duplicate inventory, disk persistence; "..captures.." renderer captures.")
 return count
end
return Suite
