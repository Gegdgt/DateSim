local Suite={}
function Suite.run()
 local D=require("tests.social_driver")
 local W=require("src.systems.wife_activities")
 local Data=require("src.data.cards")
 local Save=require("src.systems.save")
 local Json=require("src.systems.json")
 local Collection=require("src.systems.card_collection")
 local count,captures=0,0
 local function check(v,m)assert(v,m);count=count+1;return v end
 local function encode(v)return assert(Json.encode(v))end
 local function contains(t,id)for _,v in ipairs(t) do if v==id then return true end end;return false end
 local function cheap(s)
  local chosen
  for i,id in ipairs(W.current(s).hand) do
   if W.canPlay(s,id) and (not chosen or W.cost(s,id)<W.cost(s,W.current(s).hand[chosen])) then chosen=i end
  end
  return chosen
 end
 local starter={"listen","light_joke","be_honest","encourage","subtle_flirt"}
 local fresh=D.fresh()
 check(encode(Data.starterDeck)==encode(starter) and encode(fresh.deck)==encode(starter),"Nanahoshi entrega y equipa las cinco cartas iniciales")
 for _,id in ipairs(starter) do check(fresh.unlocked[id] and fresh.collection[id].unlocked and Collection.level(fresh,id)==1,"Colección inicial: "..id) end
 for _,def in ipairs(W.bank.list) do
  check(#W.handCandidates(fresh,def)==5,"Las cinco iniciales tienen respuesta: "..def.id)
  for _,id in ipairs(starter) do check(def.responses[id].rudy~=def.responses[id].reply,"Rudy y esposa tienen frases propias: "..def.id.."/"..id) end
 end
 local orders={};local traces={}
 for wife,id in pairs({eris="E11",roxy="R15",sylphiette="S11"}) do
  for seed=1,12 do
   local s=D.fresh(1,seed);D.approach(s,wife);local a=assert(W.start(s,id,s.economy.revision))
   local collection=encode({s.collection,s.unlocked,s.deck});orders[encode(a.initialOrder)]=true
   check(#a.hand==3 and #a.drawPile==2 and #a.discard==0,"Inicio 3/2/0")
   local used={};local trace={{turn=1,hand=#a.hand,deck=#a.drawPile,discard=#a.discard}}
   for turn=1,3 do
    a.phase="hand";s=D.round(s);a=W.current(s)
    check(#a.hand==3,"Tres cartas antes del turno "..turn)
    for _,card in ipairs(a.hand) do check(not used[card],"No reaparece una carta utilizada") end
    local index=assert(cheap(s));local card=a.hand[index];local cost=W.cost(s,card);local energy=a.energy
    local before=encode(s.relationships)
    local state=encode({a.hand,a.drawPile,a.discard,a.energy,a.log})
    check(W.response(s,card).rudy and state==encode({a.hand,a.drawPile,a.discard,a.energy,a.log}),"Consultar no consume ni repone")
    check(W.choose(s,card) and not W.choose(s,card),"Confirmación única")
    check(#a.discard==turn and not contains(a.hand,card) and a.energy==energy-cost,"Descarte y coste correctos")
    check(before==encode(s.relationships),"El efecto espera a la reacción")
    local stored=encode(a);s=D.round(s);a=W.current(s);check(stored==encode(a),"Carga conserva la carta en animación")
    check(W.react(s) and not W.react(s),"Efecto único")
    used[card]=true;local reply=encode(a);s=D.round(s);a=W.current(s);check(reply==encode(a),"Carga conserva la reacción")
    check(W.execute(s),"Continúa el encuentro")
    if turn<3 then
     check(a.phase=="refill" and #a.hand==3 and #a.drawPile==2-turn and #a.discard==turn,"Reposición automática 3/"..(2-turn).."/"..turn)
     local storedRefill=encode(a);s=D.round(s);a=W.current(s);check(storedRefill==encode(a),"Carga no vuelve a tomar la carta")
     trace[#trace+1]={turn=turn+1,hand=#a.hand,deck=#a.drawPile,discard=#a.discard}
    else
     check(not W.current(s) and s.wifeActivities.review and #a.discard==3 and #a.hand==2,"Tercer uso termina sin reposición")
    end
    check(collection==encode({s.collection,s.unlocked,s.deck}),"El encuentro no consume la colección ni el mazo equipado")
   end
   check(s.daily.interactions_used==1,"Tres respuestas consumen una actividad")
   s=D.round(s);W.closeReview(s);D.approach(s,wife)
   local next=assert(W.start(s,id,s.economy.revision))
   check(#next.initialOrder==5 and #next.hand==3 and #next.drawPile==2 and #next.discard==0,"El siguiente encuentro recupera las cinco cartas")
   check(not W.start(s,id,s.economy.revision),"Reabrir no duplica la reserva")
   if seed==1 then traces[wife]=trace end
  end
 end
 local variants=0;for _ in pairs(orders) do variants=variants+1 end;check(variants>6,"Órdenes distintos con semillas reproducibles")
 -- Mazo ampliado: todas las cartas compatibles equipadas participan.
 local s=D.fresh();D.approach(s,"eris")
 Collection.grant(s,"remember",1);s.deck[#s.deck+1]="remember"
 local a=assert(W.start(s,"E11",s.economy.revision))
 check(#a.initialOrder==6 and #a.drawPile==3 and contains(a.initialOrder,"remember"),"Mazo ampliado de seis cartas")
 for turn=1,3 do a.phase="hand";D.play(s,a.hand[assert(cheap(s))]);assert(W.execute(s)) end
 check(#a.discard==3 and #a.drawPile==1,"No se repone después del tercer uso con mazo ampliado")
 s=D.fresh();s.unlocked.subtle_flirt=false
 check(not W.available(s,"E11"),"No iniciar otra mano reducida por falta de cartas")
 -- Guardados anteriores al arreglo: recuperar sólo cartas equipadas omitidas.
 for _,played in ipairs({0,1,2}) do
  s=D.fresh();D.approach(s,"eris");a=assert(W.start(s,"E11",s.economy.revision))
  a.handVersion=nil;a.initialOrder={"listen","light_joke","be_honest"};a.shuffleSource={"listen","light_joke","be_honest"}
  a.shuffleSteps={{i=3,j=3},{i=2,j=2}};a.hand={"be_honest","light_joke","listen"};a.drawPile={};a.phase="hand"
  for _=1,played do D.play(s,a.hand[1]);assert(W.execute(s));a.phase="hand" end
  local before=encode({s.relationships,a.energy,a.discard});local previous={};for _,card in ipairs(a.hand) do previous[#previous+1]=card end
  s=D.round(s);a=W.current(s)
  check(#a.initialOrder==5 and #a.hand==3 and #a.drawPile==2-played,"Ampliación compatible tras "..played.." cartas")
  check(before==encode({s.relationships,a.energy,a.discard}),"La migración no cambia efectos, costes ni descarte")
  for _,card in ipairs(previous) do check(contains(a.hand,card),"Conserva cada carta ya recibida") end
  check(encode(a)==encode(W.current(D.round(s))),"Migración idempotente sin nuevo sorteo")
 end
 -- Persistencia real: guardar en disco durante cada fase, con identidad aislada.
 local previousIdentity=love.filesystem.getIdentity()
 love.filesystem.setIdentity("cartas_del_destino_v8_tests_hand_disk")
 local diskOk,diskError=xpcall(function()
  local function snapshot(game)
   return encode({active=W.current(game),relationships=game.relationships,events=game.events,
    collection=game.collection,deck=game.deck,history=game.wifeActivities.history,review=game.wifeActivities.review})
  end
  local function diskRound(game)
   local before=snapshot(game)
   check(Save.write(game),"Escritura real de la partida")
   local loaded,notice=Save.load()
   check(loaded and not notice,"Carga del archivo principal sin recurrir a una copia")
   check(snapshot(loaded)==before,"Disco conserva mano, mazo, descarte, energía y efectos")
   return loaded
  end
  for wife,id in pairs({eris="E11",roxy="R15",sylphiette="S11"}) do
   local game=D.round(D.fresh());D.approach(game,wife);assert(W.start(game,id,game.economy.revision))
   game=diskRound(game)
   for turn=1,3 do
    local active=W.current(game);active.phase="hand"
    assert(W.choose(game,active.hand[assert(cheap(game))]));game=diskRound(game)
    assert(W.react(game));game=diskRound(game)
    assert(W.execute(game));game=diskRound(game)
   end
  end
 end,debug.traceback)
 love.filesystem.setIdentity(previousIdentity)
 if not diskOk then error(diskError) end
 local oldWrite,oldOptions=Save.write,Save.readOptions
 Save.write=function(game)assert(Save.validate(game));return true end
 Save.readOptions=function()return {muted=true,textAnimation=false,reducedMotion=false}end
 local ok,err=xpcall(function()
  local app=require("src.app").new()
  local function settle()app.manager:finishTransition();app:draw()end
  local function capture(name)
   settle();local pixels=app.canvas:newImageData();local data=pixels:encode("png")
   local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/hand-cycle-"..name..".png","wb"));file:write(data:getString());file:close()
   data:release();pixels:release();captures=captures+1
  end
  for wife,id in pairs({eris="E11",roxy="R15",sylphiette="S11"}) do
   app.session=D.startWithHand(id,{});app:resume();settle();local screen=app.manager.current
   screen:keypressed("return");while screen.mode=="deal" do screen:update(.1) end
   for turn=1,3 do
    settle();a=W.current(app.session);screen=app.manager.current
    local visible=0;for _,button in ipairs(screen.buttons) do if button.cardIndex then visible=visible+1 end end
    check(visible==3,"Tres cartas reales en UI "..wife.." turno "..turn)
    local index=assert(cheap(app.session));local unchanged=encode(a)
    screen:keypressed(tostring(index));screen:keypressed("escape")
    check(unchanged==encode(a),"Inspeccionar y cancelar no altera ninguna pila ni energía")
    screen:keypressed(tostring(index));capture(wife.."-turn-"..turn)
    screen:keypressed("return");screen:keypressed("return")
    while screen.mode=="playing" do screen:update(.1) end
    check(#a.log==turn,"UI no duplica efecto por doble Enter")
    screen:keypressed("return");settle();screen=app.manager.current
    if turn<3 then
     check(screen.mode=="refill","Animación de reposición")
     if wife=="eris" and turn==1 then screen:update(.2);capture("refill") end
     while screen.mode=="refill" do screen:update(.1) end
    else check(screen.mode=="review","El tercer uso llega al cierre") end
   end
  end
  app.session=D.startWithHand("E11",{"encourage","subtle_flirt"})
  a=W.current(app.session)
  for _,card in ipairs({"encourage","subtle_flirt"}) do
   a.phase="hand";D.play(app.session,card);assert(W.execute(app.session));a.phase="hand"
  end
  check(a.energy==0 and #a.hand==3,"Tres visibles aunque no se puedan pagar")
  app.session=D.round(app.session);app:resume();settle();local screen=app.manager.current
  for _,card in ipairs(W.current(app.session).hand) do check(not W.canPlay(app.session,card),"Sin energía no puede jugarse") end
  local rendered={};local Card=require("src.ui.card");local draw=Card.draw
  Card.draw=function(resources,card,x,y,opts)rendered[#rendered+1]=opts;return draw(resources,card,x,y,opts)end
  local drawn,why=pcall(function()app:draw()end);Card.draw=draw;assert(drawn,why)
  check(#rendered==3,"Las tres cartas conservan el renderer de iconos y marcos")
  for _,opts in ipairs(rendered) do check(opts.disabled and opts.status:find("SIN ENERGÍA"),"Indicación visible de coste impagable") end
  screen:keypressed("1");settle();capture("no-energy")
  local disabled=false;for _,b in ipairs(screen.buttons) do if b.label=="Decir la frase [ENTER]" then disabled=b.disabled end end
  check(disabled,"Confirmar deshabilitado sin energía")
  screen:keypressed("return");check(#W.current(app.session).log==2,"Carta impagable no se consume")
  screen:keypressed("p");check(app.session.wifeActivities.review,"Terminar evita bloqueo")
  app.audio:stop()
 end,debug.traceback)
 Save.write,Save.readOptions=oldWrite,oldOptions
 if not ok then error(err) end
 local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/hand-cycle-traces.json","wb"));file:write(encode(traces));file:close()
 print("Social hand cycle: "..count.." checks; 45 activities, 36 seeded encounters, 3 disk encounters, "..captures.." renderer captures, migration and exact save/load.")
 return count
end
return Suite
