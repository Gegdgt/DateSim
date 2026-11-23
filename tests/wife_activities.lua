local Suite={}
function Suite.run()
 local Save=require("src.systems.save")
 local Json=require("src.systems.json")
 local Prologue=require("src.systems.prologue")
 local Events=require("src.systems.events")
 local Daily=require("src.systems.daily")
 local W=require("src.systems.wife_activities")
 local Rest=require("src.systems.rest")
 local Bank=W.bank
 local World=require("src.systems.exploration")
 local Maps=require("src.data.maps")
 local Collection=require("src.systems.card_collection")
 local count=0
 local function check(v,m) assert(v,m);count=count+1;return v end
 local function encoded(v)return assert(Json.encode(v))end
 local function clone(v)return assert(Json.decode(encoded(v)))end
 local function round(s)
  local out,err=Save.validate(clone(s));return check(out,err or "Carga de actividad válida")
 end
 local function fresh(day,seed,locked)
  local s=Prologue.start(Save.newSession());Prologue.wake(s)
  require("src.systems.world_content").ensure(s).seed=seed or 273
  if not locked then
   Events.apply(s,"starter_gift",{starter=true});Events.mark(s,"first_anomaly");Events.mark(s,"tutorial_completed");Events.mark(s,"combat_tutorial_completed");Events.mark(s,"nanahoshi_conversation_started")
   Events.apply(s,"hitogami_letter_read",{clue="hitogami_letter"})
   for _,id in ipairs({"letter_read","letter_collected","curse_discovered","nanahoshi_visited","starting_cards_received"}) do s.prologue[id]=true end
   s.day=day or 1;s.checkpoint="day"..s.day.."_agenda";Daily.ensure(s)
   s.rewardQueue={};s.exploration.active=true
  end
  return s
 end
 local function approach(s,wife)
  require("tests.social_driver").approach(s,wife)
 end
 local function prepare(s,def)
  s.day=math.max(s.day,def.minDay or 1);s.checkpoint="day"..s.day.."_agenda";Daily.ensure(s)
  if def.requiredEvent then Events.mark(s,def.requiredEvent) end
  if def.previousDuel then s.decisions.activity_duel_result="honorable_defeat" end
  approach(s,def.character)
 end
 local function start(s,id)
  local d=Bank.byId[id];prepare(s,d)
  local a,err=W.start(s,id,s.economy.revision)
  return check(a,err or ("Iniciar "..id))
 end
 local function choose(s,card)
  local a=W.current(s);a.phase="hand";card=card or a.hand[1]
  check(W.choose(s,card),"Carta de actividad "..a.id)
  check(W.react(s),"Reacción aplicada");a.ended=true
  return true
 end
 local function finish(s)
  local a=W.current(s);local d=Bank.byId[a.id]
  check(W.execute(s),"Ejecutar "..a.id)
  if d.battle then
   local Combat=require("src.systems.combat");local def=Daily.battleDefinition(s)
   local support=require("src.systems.companions").context(s,def)
   s.combat=Combat.new(s.deck,{day=s.day,enemyId=def.enemyId,character=def.character,difficulty=def.difficulty,
    relationships=support.relationships,team=support.team,
    combatDeck=s.combatDeck,unlocked=s.unlocked,curse=s.curse,externalEnergy=s.externalEnergy,cardLevels=Collection.levels(s)},function()return 17 end)
   for _=1,40 do if s.combat.finished then break end;Combat.endTurn(s.combat) end
   check(s.combat.finished,"El combate real finaliza")
   s=round(s);check(s.combat,"Combate pendiente restaurado "..d.id)
   local enc=s.combat;check(Daily.finishBattle(s,enc),"Resolver combate")
   check(not Daily.finishBattle(s,enc),"Combate sin premio duplicado")
  elseif d.challenge then
   for _=1,3 do
    for _=1,8 do W.tickChallenge(s,.1) end
    check(W.hit(s),"Pulsación de ritmo")
   end
  elseif d.service then check(W.finish(s,"no_purchase"),"Cerrar consulta sin compra") end
  return s
 end
 local locked=fresh(nil,nil,true)
 for _,def in ipairs(Bank.list) do check(not W.start(locked,def.id,locked.economy.revision),"Bloqueo antes de carta "..def.id) end
 local before=encoded({locked.daily,locked.events,locked.relationships,locked.curse})
 for _,id in ipairs({"eris","roxy","sylphiette"}) do check(require("src.systems.world_content").greeting(locked,id),"Saludo previo "..id) end
 Daily.applyAttention(locked)
 check(before==encoded({locked.daily,locked.events,locked.relationships,locked.curse}),"Prólogo: sin historia, amor, ausencia ni consumo")
 local lettersOnly=fresh();lettersOnly.prologue.starting_cards_received=false
 check(not W.available(lettersOnly,"S01"),"Leer carta sin mazos no abre actividades")
 lettersOnly.prologue.starting_cards_received=true;lettersOnly.events.combat_tutorial_completed=nil
 check(not W.available(lettersOnly,"S01"),"Mazos sin tutorial completo no abren actividades")
 check(W.ready(fresh()),"Después del tutorial sí se habilitan")
 check(#Bank.list==45,"45 actividades exactas")
 for _,id in ipairs({"eris","roxy","sylphiette"}) do check(#Bank.byWife[id]==15,"Quince actividades por esposa") end
 local responses,used,phrases=0,{},{}
 local report={"# Cobertura de diálogos de actividades","","Generado por tests/wife_activities.lua a partir del catálogo ejecutado.","",
  "| ID | Actividad | Cartas con frase y respuesta propia | Recompensa |","|---|---|---|---|"}
 for _,def in ipairs(Bank.list) do
  check(def.intro and def.question and def.emotion and def.reward and def.effects,"Contenido completo "..def.id)
  check(#def.choices>=3,"Al menos tres cartas contextuales "..def.id)
  local compatible={}
  for _,r in ipairs(def.choices) do
   responses=responses+1;used[r.id]=true
   check(require("src.data.cards").byId[r.id] and r.rudy and r.reply and r.expression and r.animation,"Respuesta íntegra "..def.id.."/"..r.id)
   check(not phrases[r.rudy],"Frase inicial no universal "..def.id.."/"..r.id);phrases[r.rudy]=true
   compatible[#compatible+1]=r.id
   local s,a,inHand
   for seed=1,30 do
    s=fresh(def.maxDay or 7,seed);prepare(s,def);Collection.grant(s,r.id,1)
    s.deck={r.id}
    for _,base in ipairs(require("src.data.cards").starterDeck) do if base~=r.id and #s.deck<5 then s.deck[#s.deck+1]=base end end
    a=assert(W.start(s,def.id,s.economy.revision))
    for _,id in ipairs(a.hand) do if id==r.id then inHand=true end end
    if inHand then break end
   end
   check(inHand,"La carta compatible puede aparecer en la mano")
   choose(s,r.id)
   check(s.events[a.instance_id.."_card_1"],"Memoria de carta persistente")
   local rel=s.relationships[def.character]
   check(rel.love-a.before.love==a.delta.love and rel.trust-a.before.trust==a.delta.trust,"Deltas mostrados coinciden con lógica")
   if r.love<0 then check(a.delta.love<0,"Respuesta negativa reduce amor") end
   if r.trust<0 then check(a.delta.trust<0,"Respuesta negativa reduce confianza") end
   s=round(s);check(W.current(s).choice==r.id,"Respuesta guardada "..def.id)
  end
  report[#report+1]="| "..def.id.." | "..def.title.." | "..table.concat(compatible,", ").." | "..def.reward.." |"
  local s=fresh();start(s,def.id);s=round(s)
  local position=encoded({s.exploration.map,s.exploration.x,s.exploration.y,s.exploration.facing})
  choose(s);s=finish(s)
  check(s.daily.interactions_used==1 and #s.daily.activities_completed==1,"Un solo consumo "..def.id)
  check(W.ensure(s).review and s.decisions["wife_activity_"..def.id],"Recuerdo y decisión "..def.id)
  local gold=s.gold;check(not W.finish(s,"complete") and s.gold==gold,"Sin recompensa duplicada")
  check(position==encoded({s.exploration.map,s.exploration.x,s.exploration.y,s.exploration.facing}),"Regreso conserva posición "..def.id)
  s=round(s);W.closeReview(s);check(s.exploration.active,"Retorna al mundo")
 end
 for _,card in ipairs(require("src.data.cards").list) do check(used[card.id],"Toda carta social tiene actividad compatible: "..card.id) end
 local s=fresh();local first=W.offers(s,"eris");local second=W.offers(s,"eris")
 check(#first==3 and #second==3 and first[2].id~=second[2].id,"Tres ofertas varían entre encuentros")
 check(first[1].id=="E01" and second[1].id=="E01","Entrenamiento diario permanece accesible")
 local orders={}
 for seed=1,24 do
  local game=fresh(1,seed);local a=start(game,"S01");orders[table.concat(a.hand,",")]=true
  local loaded=round(game);check(encoded(a.hand)==encoded(W.current(loaded).hand),"Cargar conserva la mano")
 end
 local permutations=0;for _ in pairs(orders) do permutations=permutations+1 end
 check(permutations>1,"Mezcla real de cartas")
 for wife,id in pairs({eris="E11",roxy="R15",sylphiette="S11"}) do
  s=fresh()
  for _,base in ipairs(require("src.data.cards").starterDeck) do s.collection[base].level=10 end
  for _=1,3 do start(s,id);choose(s);s=finish(s);W.closeReview(s) end
  check(s.daily.visits[wife]==3 and Daily.remaining(s)==0,"Tres con la misma esposa permitidas")
  check(s.family.seen["day1_third_"..wife],"Comentario de tercera interacción "..wife)
  check(s.daily.relationship_gains[wife].love<=10 and s.daily.relationship_gains[wife].trust<=10,"Límite diurno real")
 end
 s=fresh();approach(s,"sylphiette");local gold=s.gold
 check(W.available(s,"S09",true) and s.gold==gold,"Ver disponibilidad no compra")
 start(s,"S09");check(s.gold==gold-12,"Provisiones descuentan 12")
 choose(s);s=finish(s);round(s)
 local outcomes={}
 for seed=1,50 do
  local game=fresh(1,seed);start(game,"R07");choose(game);local loaded=round(game)
  W.execute(game);W.execute(loaded)
  check(W.ensure(game).review.outcome==W.ensure(loaded).review.outcome,"Experimento no cambia al cargar")
  outcomes[W.ensure(game).review.outcome]=true
 end
 check(outcomes.success and outcomes.failure,"Experimentos pueden tener ambos resultados")
 s=fresh()
 for _=1,3 do start(s,"R12");choose(s);s=finish(s);W.closeReview(s) end
 check(s.family.progress.research>=3 and not s.unlocked.combined_spell,"El hito de actividad no adelanta la carta personal de Roxy")
 s.day=5;s.checkpoint="day5_agenda";Daily.ensure(s);Events.mark(s,"wife_card_roxy")
 start(s,"R12");choose(s);s=finish(s)
 check(s.unlocked.combined_spell and s.events.activity_skill_research,"Hito habilitado tras el evento narrativo")
 local Combat=require("src.systems.combat")
 local starter=require("src.data.combat_cards").starterDeck
 local late={"staff_strike","simple_cut","stone_throw","push","coordinated_attack","water_projectile","arcane_guard","heavy_spell","swamp","heal"}
 for _,case in ipairs({
  {mode="win",want="victory",deck=late},{mode="honor",want="honorable_defeat",deck=starter},
  {mode="idle",want="suspected_throw",deck=starter},{mode="honest",want="honest_defeat",deck={"quick_study","mana_spark","simple_cut","staff_strike","stone_throw"}},
 }) do
  s=fresh(5)
  for _,id in ipairs(case.deck) do Collection.grant(s,id,1) end
  s.combatDeck=clone(case.deck);s.externalEnergy=12
  start(s,"E02");choose(s,"be_honest");W.execute(s)
  local def=Daily.battleDefinition(s);local support=require("src.systems.companions").context(s,def)
  s.combat=Combat.new(s.deck,{enemyId=def.enemyId,day=s.day,difficulty=def.difficulty,character=def.character,
   relationships=support.relationships,team=support.team,combatDeck=s.combatDeck,unlocked=s.unlocked,curse=s.curse,
   externalEnergy=s.externalEnergy,cardLevels=Collection.levels(s)},function()return 17 end)
  check(require("tests.training").solve(s.combat,case.mode).id==case.want,"Resultado real de duelo "..case.want)
  s=round(s);check(Daily.finishBattle(s,s.combat),"E02 aplica valoración")
  check(s.decisions.activity_duel_result==case.want,"Revancha conserva resultado anterior")
  check(s.wifeActivities.review.outcome==case.want and s.wifeActivities.review.battleDelta,"Resultado con deltas reales")
  round(s)
 end
 s=fresh();start(s,"R03");choose(s);W.execute(s);gold=s.gold
 check(W.purchaseBook(s,"water_notes",s.economy.revision),"Compra de grimorio")
 check(s.gold==gold-35 and s.family.books.water_notes,"Precio y libro reales")
 check(not W.purchaseBook(s,"water_notes",s.economy.revision),"Compra única")
 s=round(s);check(s.family.books.water_notes,"Libro guardado")
 s=fresh();start(s,"R04");choose(s);W.execute(s);Collection.grant(s,"listen",30)
 check(not W.upgraded(s),"R04 no concluye sin una mejora pagada")
 local upgrade=check(Collection.upgrade(s,"listen",s.economy.revision),"Mejora real")
 check(upgrade.receipt.gold<0 and upgrade.receipt.copies>0,"Mejorar consume oro y copias")
 check(W.upgraded(s,upgrade.receipt) and s.collection.listen.level==2,"Roxy completa la mejora")
 s=fresh();start(s,"R03");choose(s);W.execute(s);gold=s.gold
 local materialBefore=s.economy.items.magic_material or 0
 check(W.purchaseItem(s,"magic_material",s.economy.revision),"Roxy vende materiales reales")
 check(s.gold==gold-20 and s.economy.items.magic_material==materialBefore+1,"Material pagado una sola vez")
 check(not W.purchaseItem(s,"magic_material",s.economy.revision),"No duplica compra de materiales")
 s=fresh();s.gold=4;approach(s,"sylphiette")
 check(not W.start(s,"S09",s.economy.revision) and s.gold==4 and Daily.remaining(s)==3,"Oro insuficiente no reserva ni cobra")
 s=fresh();start(s,"E10");choose(s);W.execute(s)
 for _=1,8 do W.tickChallenge(s,.1) end
 W.hit(s);s=round(s)
 check(W.current(s).challenge.step==2 and W.current(s).challenge.hits[1],"Prueba parcial conserva pulsación")
 for _=1,2 do for _=1,8 do W.tickChallenge(s,.1) end;W.hit(s) end
 check(s.wifeActivities.review.outcome=="success","Continuar prueba no la reinicia")
 s=fresh();start(s,"R07")
 local damaged=clone(s);damaged.daily.active_activity.experimentSuccess=not damaged.daily.active_activity.experimentSuccess
 check(not Save.validate(damaged),"Carga rechaza resultado incompatible con tirada")
 damaged=clone(s);damaged.daily.active_activity.hand[1]="choose_together"
 check(not Save.validate(damaged),"Carga rechaza carta ajena a mano y mazo")
 for map,bed in pairs(require("src.data.rest").beds) do
  s=fresh();Events.mark(s,Daily.config(s).completionEvent)
  for _=1,3 do start(s,"E11");choose(s);s=finish(s);W.closeReview(s) end
  World.enter(s.exploration,"laboratorio_nanahoshi",Maps.laboratorio_nanahoshi.initialPosition)
  check(not Rest.available(s,bed),"No se descansa desde otro mapa o lejos")
  World.enter(s.exploration,map,Maps[map].initialPosition)
  require("tests.exploration_driver").walk(s,function(p)return (p.x-bed.x)^2+(p.y-bed.y)^2<18^2 end)
  check(Rest.available(s,bed),"Cama físicamente accesible "..map)
  check(not Daily.finish(s),"El resumen no salta la confirmación nocturna")
  local beforeLove=bed.wife and s.relationships[bed.wife].love
  local beforeVisits=bed.wife and s.daily.visits[bed.wife]
  check(Rest.confirm(s,bed,Rest.options(s,bed)[1].id),"Descanso confirmado")
  if bed.wife then
   check(s.relationships[bed.wife].love==beforeLove-(s.daily.visits[bed.wife]==0 and 20 or 0)+10,"Dormir conserva ausencia y bonus +10")
   check(s.daily.visits[bed.wife]==beforeVisits,"Descanso no crea visita diurna")
  end
  local unchanged=encoded(s.relationships)
  check(not Rest.confirm(s,bed,Rest.options(s,bed)[1].id) and unchanged==encoded(s.relationships),"Noche idempotente")
  s=round(s);check(Daily.finish(s),"Cierra jornada con descanso")
  check(s.daily_history["1"].after.roxy and #s.daily_history["1"].changes>0,"Resumen de ausencias y noche")
  local Progression=require("src.systems.progression")
  check(Progression.endDay(s),"Abre resumen")
  check(Progression.next(s),"Siguiente día")
  check(s.day==2 and s.exploration.map==map and s.exploration.x==bed.wake.x and s.rest.waking,"Despierta donde durmió")
  check(Prologue.shouldExplore(s),"Despertar entrega movimiento")
  s=round(s);check(s.rest.waking,"Despertar guardado")
 end
 s=fresh();start(s,"S11");choose(s);s=finish(s);W.closeReview(s)
 local bed=require("src.data.rest").beds.dormitorio_sylphie
 Events.mark(s,Daily.config(s).completionEvent)
 for _=1,2 do start(s,"S11");choose(s);s=finish(s);W.closeReview(s) end
 World.enter(s.exploration,"dormitorio_sylphie",{x=bed.x,y=bed.y})
 Events.apply(s,"cap_test",{character="sylphiette",love=50,trust=50})
 check(s.daily.relationship_gains.sylphiette.love==10,"Agota límite diurno")
 local loveBeforeNight=s.relationships.sylphiette.love
 Rest.confirm(s,bed,Rest.options(s,bed)[1].id)
 check(s.relationships.sylphiette.love==loveBeforeNight+10,"Bonus nocturno separado del límite")
 s=fresh();require("src.systems.family").depart(s,"roxy","test")
 check(not W.available(s,"R15"),"Separada sin actividades")
 World.enter(s.exploration,"dormitorio_roxy",{x=88,y=104,facing="down"});Events.mark(s,Daily.config(s).completionEvent)
 check(not Rest.available(s,Rest.bed(s)),"Separada sin descanso romántico")
 s=round(s);check(not require("src.systems.family").active(s,"roxy"),"Separación persistente")
 check(not require("src.data.rest").beds.estudio_rudy,"El estudio no es dormitorio matrimonial")
 s=fresh();require("src.systems.family").depart(s,"sylphiette","test");World.syncPresence(s)
 check(s.exploration.absentNpcs.zenith,"Lucy no permanece en brazos de Zenith tras partir")
 s=round(s);check(s.exploration.absentNpcs.zenith,"Ausencia visual derivada se restaura")
 check(s.exploration.absentNpcs.sylphiette,"La esposa que partió tampoco permanece en el mundo")
 local variants={};for _=1,4 do variants[require("src.systems.world_content").greeting(s,"norn").text]=true end
 local n=0;for _ in pairs(variants) do n=n+1 end;check(n==2,"Norn explica el descanso de Zenith y ausencia de Lucy")
 s=fresh()
 for _,wife in ipairs({"sylphiette","roxy","eris"}) do require("src.systems.family").depart(s,wife,"test") end
 Events.mark(s,"day1_complete")
 World.enter(s.exploration,"casa_segundo_piso",{x=432,y=208,facing="left"})
 check(Rest.confirm(s,Rest.bed(s),"gesture") and Daily.finish(s),"Tres separaciones no bloquean el descanso solo")
 s=round(s);check(s.rest.nights["1"].wife=="solo","Descanso solo persistente")
 -- Five real practice battles + a visit to each wife and a physical bed each
 -- day demonstrate that the stable option reaches the existing Orsted gate.
 s=fresh()
 for day=1,5 do
  check(s.day==day,"Calendario del entrenamiento")
  check(W.offers(s,"eris")[1].id=="E01","E01 accesible en Día "..day)
  for _,id in ipairs({"E01","R15","S11"}) do
   start(s,id);choose(s);s=finish(s);W.closeReview(s);s.family.queue={};s.rewardQueue={}
  end
  check(s.eris_training_days[tostring(day)],"Entrenamiento completado queda fechado")
  Events.mark(s,Daily.config(s).completionEvent)
  local chosenBed=require("src.data.rest").beds.dormitorio_sylphie
  require("tests.campaign_world_driver").travel(s,"dormitorio_sylphie")
  require("tests.exploration_driver").walk(s,function(p)return (p.x-chosenBed.x)^2+(p.y-chosenBed.y)^2<16^2 end)
  check(Rest.confirm(s,chosenBed,Rest.options(s,chosenBed)[1].id),"Descanso tras entrenamiento")
  local Progression=require("src.systems.progression")
  check(Progression.endDay(s) and Progression.next(s),"Avance después del descanso")
  s=round(s);s.rest.waking=false
 end
 check(s.day==6 and require("src.systems.finale").trainedEveryDay(s) and s.events.eris_five_training_days,"45 actividades conservan acceso a Orsted")
 report[#report+1]="";report[#report+1]="Total: **45 actividades**, **"..responses.." respuestas contextuales**. Las 21 cartas sociales tienen al menos una actividad compatible."
 report[#report+1]="";report[#report+1]="Cada actividad admite las cinco cartas iniciales y exige al menos cinco compatibles del mazo equipado: tres opciones antes de cada una de las tres respuestas, con seis de energía y sin reciclar el descarte. E01 permanece entre las ofertas mientras falta el entrenamiento diario de los días 1–5; R05 fija la investigación pendiente desde el día 3 y S03 conserva acceso a los compromisos pendientes. Las actividades se proponen al hablar físicamente con cada esposa."
 local file=assert(io.open(love.filesystem.getSource().."/docs/COBERTURA_ACTIVIDADES.md","wb"));file:write(table.concat(report,"\n").."\n");file:close()
 print("Wife activities phase 3: "..count.." checks; 45 activities, "..responses.." contextual responses; cards, real battles, commerce, night and persistence.")
 return count
end
return Suite
