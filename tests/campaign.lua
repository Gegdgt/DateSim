-- Recorridos completos: decisiones reales, mazos legales, combates ejecutados y
-- carga entre checkpoints. No se inyectan estadísticas para fabricar finales.
local Suite={}
function Suite.run(simulations)
 Suite.completed={}
 local Chapters=require("src.data.chapters")
 local Progression=require("src.systems.progression")
 local Conditions=require("src.systems.conditions")
 local Relationships=require("src.systems.relationships")
 local Save=require("src.systems.save")
 local Json=require("src.systems.json")
 local Cards=require("src.systems.cards")
 local Combat=require("src.systems.combat")
 local Endings=require("src.data.endings")
 local Events=require("src.systems.events")
 local Collection=require("src.systems.card_collection")
 local Economy=require("src.systems.economy")
 local count,routesRun=0,0
 local function check(ok,message) assert(ok,message);count=count+1 end
 local function copy(value) return assert(Json.decode(assert(Json.encode(value)))) end
 local function round(s)
  local loaded,err=Save.validate(copy(s));check(loaded~=nil,"Carga de "..s.checkpoint..": "..tostring(err))
  check(loaded.checkpoint==s.checkpoint,"La carga conserva checkpoint")
  return loaded
 end
 local valid,errors=require("src.systems.narrative_validator").validate(Chapters,{checkFiles=false})
 check(valid,"Narrativa válida: "..table.concat(errors,"; "))
 check(#Endings.list==5,"Exactamente cinco finales principales")
 for day=1,7 do check(Chapters.byId["day"..day].implemented~=false,"Día jugable "..day) end
 local wives={"sylphiette","roxy","eris"}
 local positive={sylphiette="listen_first",roxy="compare_notes",eris="mutual_support"}
 local negative={sylphiette="leave_tasks",roxy="pedestal",eris="overprotect"}
 local function rng(seed)
  return function(n) seed=(seed*48271)%2147483647;return seed%n+1 end
 end
 local function clone(value)
  if type(value)~="table" then return value end
  local out={};for k,v in pairs(value)do out[k]=clone(v)end;return out
 end
 local function bestSocial(enc)
  if enc.finished then return enc.score,0 end
  local best,index=-math.huge,0
  for i=0,#enc.hand do
   if i==0 or Cards.canPlay(enc,i) then
    local nextState=clone(enc)
    if i==0 then Cards.pass(nextState) else Cards.play(nextState,i) end
    local score=bestSocial(nextState)
    if score>best then best,index=score,i end
   end
  end
  return best,index
 end
 local function social(s,def,config)
  -- Seed 17 is a legal, reproducible shuffle; retries are not used for rewards.
  local enc=Cards.new(s.deck,require("src.systems.dialogue_resolver").context(s,def),rng(config.seed or 17))
  s.encounter=enc
  while not enc.finished do
   local _,index=bestSocial(enc)
   local entry=index==0 and Cards.pass(enc) or Cards.play(enc,index)
   check(entry~=nil,"Acción social legal")
   require("src.systems.dialogue_memory").commit(s,entry,s.checkpoint,entry.actionTurn)
  end
  local result={score=enc.score,trust=0,chemistry=0}
  -- Los vínculos ya se aplicaron al leer cada reacción; cerrar no los repite.
  check(Progression.next(s,s.checkpoint,result)~=nil,"Salida social incluso con resultado parcial")
 end
 local function battle(s,def,config)
  -- Preparation uses earned gold and ordinary shop stock, including solo routes.
  if not config.specialize and config.spending~="none" then
   for _,id in ipairs({"staff_strike","water_projectile","arcane_guard","simple_cut"}) do
    local v=Collection.view(s,id)
    while v and v.unlocked and v.level<math.min(6,s.day+1) do
     local missing=math.max(0,v.copiesRequired-v.copies)
     local quote=Economy.quote(s,id)
     if missing>0 then
      if not quote or quote.reason or missing>quote.stock or s.gold<quote.price*missing+v.goldRequired then break end
      if not Economy.buy(s,id,quote.revision,missing) then break end
     end
     if not Collection.upgrade(s,id,s.economy.revision) then break end
     v=Collection.view(s,id)
    end
   end
  end
  -- Equip only earned techniques. Every route, including failed marriages, can
  -- prepare enough artifact magic without receiving a wife's exclusive card.
  local equipped={}
  for _,id in ipairs({"water_cannon","heavy_spell","magic_bolt","water_projectile","ice_lance","arcane_guard","earth_wall","swamp","staff_strike","coordinated_attack","stone_throw","simple_cut","push"}) do
   if s.unlocked[id] and #equipped<10 then equipped[#equipped+1]=id end
  end
  if #equipped>=5 then s.combatDeck=equipped end
  local support=require("src.systems.companions").context(s,def)
  local enc=Combat.new(s.deck,{relationships=s.relationships,team=support.team,character=def.character,enemyId=def.enemyId,day=s.day,difficulty=def.difficulty,tutorial=def.tutorial,tacticalContext=def.tacticalContext,combatDeck=s.combatDeck,unlocked=s.unlocked,curse=s.curse,externalEnergy=s.externalEnergy,cardLevels=Collection.levels(s)},rng(config.seed or 37))
  s.combat=enc
  require("tests.war_balance").solve(enc)
  if config.metrics then
   require("tests.campaign_metrics").battle(s,enc,config.metrics)
   if enc.outcome~="victory" and not enc.narrativeDefeat and not def.training and not def.activity then
    config.metrics.blockedAt=s.checkpoint;return s,false
   end
  end
  check(def.activity or def.training or enc.outcome=="victory" or enc.narrativeDefeat=="orsted_demonstration","Resultado previsto: "..def.enemyId.." / "..tostring(def.character).." / "..tostring(enc.cause))
  check(#enc.relationshipEvents<=3,"Como máximo una interpretación romántica por combate")
  local snapshot=round(s)
  check(snapshot.combat and snapshot.combat.outcome==enc.outcome,"Replay conserva victoria antes de recompensa")
  s=snapshot;enc=s.combat
  if def.activity then
   check(require("src.systems.daily").finishBattle(s,enc),"Actividad de combate completada")
   return s,true
  end
  if def.training then
   check(require("src.systems.training_result").commit(s,enc)~=nil,"La reacción del entrenamiento aplica su resultado antes de salir")
  end
  check(Progression.finishCombat(s,enc)~=nil,"Victoria continúa la historia")
  return s,true
 end
 local function run(config)
  local s=Save.newSession();local visited={};local steps=0
  local metrics=config.metrics
  while true do
   Progression.skipUnavailable(s)
   -- Pure campaign driver acknowledges presentation-only family scenes.
   s.family.queue={}
   steps=steps+1;check(steps<200,"Campaña sin bloqueo permanente")
   local checkpoint=s.checkpoint;visited[checkpoint]=true
   local node=assert(Chapters.get(checkpoint))
   if node.kind=="summary" and node.definition.terminal then break end
   if node.kind=="scene" then
    local scene=Progression.scene(s,checkpoint)
    if scene.document then
     check(not Progression.next(s),"El diario narrativo exige interacción antes de avanzar")
     check(Events.apply(s,"hitogami_letter_read",{clue="hitogami_letter"}),"La carta se registra como pista")
     check(not Events.apply(s,"hitogami_letter_read",{clue="hitogami_letter"}),"La pista no se concede dos veces")
    end
    if checkpoint=="day7_intro" then
     check(s.inventory.antidote and s.curse.active and s.curse.manaBlocked,"El antídoto no cura antes de usarlo")
    elseif checkpoint=="day7_voice" then
     check(not s.curse.active and not s.curse.voiceSealed and not s.curse.manaBlocked,"Recuperación real tras beber el antídoto")
    end
    if scene.choices then
     local desired
     local wife=checkpoint:match("^meet_(.+)$")
     if wife then desired=(config.keep[wife] and config.mistake~=wife) and positive[wife] or negative[wife] end
     wife=checkpoint:match("^day5_resolution_(.+)$")
     if wife then desired=(config.keep[wife] and config.mistakeDay5~=wife) and "repair" or "dismiss" end
     wife=checkpoint:match("^day7_plan_(.+)$")
     if wife then desired=wife==config.preferred and "commit" or "release" end
     if checkpoint=="seal_intro" then desired=config.detour and "detour" or "explore" end
     if checkpoint=="day4_badigadi" then desired=config.detour and "rest" or "train" end
     if config.badGlobal then
      desired=({day1_close="hide_dream",day3_return="blame_mirror",day4_council="secret_plan",day6_truth="chase_voice"})[checkpoint] or desired
     end
     local chosen
     for _,choice in ipairs(scene.choices) do
      if Conditions.evaluate(s,choice.requires,{companion=Progression.companion(s)}) and (choice.id==desired or not chosen) then
       chosen=choice
       if choice.id==desired then break end
      end
     end
     check(chosen~=nil,"Toda escena tiene una opción alcanzable: "..checkpoint)
     check(Progression.choose(s,checkpoint,chosen.id),"Elección válida: "..checkpoint.."/"..chosen.id)
     local before=assert(Json.encode(s))
     check(Progression.choose(s,checkpoint,chosen.id) and Json.encode(s)==before,"Una elección no se aplica dos veces")
    end
    local nextId,err=Progression.next(s)
    check(nextId~=nil,"Salida de "..checkpoint..": "..tostring(err))
   elseif node.definition.agenda then
    local Daily=require("src.systems.daily")
    if config.specialize then
     for _,id in ipairs({"staff_strike","encourage"}) do
      local entry=Collection.ensure(s)[id]
      if config.useBooks and id=="encourage" then
       for _=1,4 do
        if entry.level==10 or entry.copies>=90-entry.level*(entry.level-1) then break end
        local book=Economy.quote(s,"study_book")
        if not book or book.reason or s.gold<book.price+25 then break end
        assert(Economy.buy(s,"study_book",book.revision))
        assert(Economy.use(s,"study_book",id,s.economy.revision))
       end
      end
      local quote=Economy.quote(s,id)
      while entry.level<10 and quote and not quote.reason and s.gold>quote.price+25 and entry.copies<90-entry.level*(entry.level-1) do
       local quantity=math.min(10,quote.stock,math.floor((s.gold-25)/quote.price),90-entry.level*(entry.level-1)-entry.copies)
       check(Economy.buy(s,id,quote.revision,quantity),"Compra financiada por recompensas reales")
       quote=Economy.quote(s,id)
      end
      while Collection.canUpgrade(s,id) do check(Collection.upgrade(s,id,s.economy.revision),"Especialización financiada durante la campaña") end
     end
    end
    while not config.skipActivities and Daily.remaining(s)>0 and not s.daily.activities_locked do
     local id=config.dailyWife or wives[s.daily.interactions_used+1]
     if not id or s.relationships[id].marriageState=="separated" then break end
     if config.favors and config.accelerateFinal~=false and s.day==7 and Daily.remaining(s)==1 and not s.daily.favor_used then break end
     local recovery=config.skipErisTraining and id=="eris"
     local activity,decision=recovery and "reconcile_eris" or "time_"..id,recovery and "repair" or "together"
     if config.activityPlan then activity,decision=config.activityPlan(s) end
     if not activity then break end
     check(Daily.startActivity(s,activity)~=nil,"Actividad libre con "..id)
     s=round(s)
     check(Daily.resolveActivity(s,decision)~=nil,"Decisión de actividad guardada")
     local activityBattle=Daily.battleDefinition(s)
     if activityBattle then s=battle(s,activityBattle,config)end
    end
    if config.favors and (s.day<7 or config.accelerateFinal~=false) and not s.daily.favor_used and not s.daily.activities_locked then
     check(Daily.requestFavor(s,s.day%2==1 and "cliff_notes" or "zanoba_artifact",nil,s.day==7)~=nil,"Encargo alternado; último día acelerado")
    end
    if Daily.storyComplete(s) then
     check(Progression.endDay(s)~=nil,"Cierre diario explícito")
     if metrics then require("tests.campaign_metrics").day(s,metrics)end
    else check(Progression.continueStory(s)~=nil,"Historia obligatoria accesible") end
   elseif node.definition.orstedReward then
    local Finale=require("src.systems.finale")
    for _,kind in ipairs({"combat","social"})do
     local options=Finale.options(s,kind)
     local preferred=config.orstedCards and config.orstedCards[kind]
     if preferred then table.insert(options,1,preferred)end
     for _,id in ipairs(options)do if Finale.canChoose(s,kind,id) then
      assert(Finale.choose(s,kind,id,s.orsted_reward.revision));s=round(s);Finale.acknowledge(s);break
     end end
    end
    check(Progression.next(s)~=nil,"Dos mejoras gratuitas concluyen la ayuda de Orsted")
   elseif node.kind=="hub" then
    local available=Progression.availableCompanions(s)
    if #available>0 then
     local preferred=config.companion or config.preferred or "roxy"
     if s.relationships[preferred].marriageState=="separated" then preferred=available[1] end
     check(Progression.selectCompanion(s,preferred)~=nil,"Compañía disponible elegida")
    else
     local selected
     for _,place in ipairs(Progression.hub(s).locations) do if not s.events[place.completedEvent] then selected=place;break end end
     check(selected and Progression.visit(s,selected.character)~=nil,"Visita pendiente accesible")
    end
   elseif node.kind=="encounter" then
    local def=Progression.encounter(s,checkpoint)
    if def.kind=="magic" then
     local ok;s,ok=battle(s,def,config)
     if ok==false then return s,nil,visited end
    else social(s,def,config) end
   else check(Progression.next(s)~=nil,"Continuidad entre capítulos") end
   s=round(s)
  end
  local ending,err=Relationships.ending(s.relationships)
  check(ending~=nil,"No quedan matrimonios ambiguos en el epílogo: "..tostring(err))
  check(Endings.byId[ending]~=nil,"El epílogo pertenece a los cinco desenlaces")
  check(s.events.antidote_obtained and not s.curse.active and s.events.campaign_complete,"Antídoto utilizado y campaña completada")
  check(s.inventory.enchantedCardsReturned and visited.day7_return_cards and visited["day7_epilogue_"..ending],"Devolución y epílogo específico antes del final")
  if config.skipErisTraining then check(not visited.day6_orsted_arrival and not s.events.orsted_collection_gift,"Campaña completa sin recompensa de Orsted") end
  check(Relationships.ending(round(s).relationships)==ending,"Final persiste al guardar/cargar")
  Suite.completed[ending]=copy(s)
  if config.specialize then
   check(s.collection.staff_strike.level==10 and s.collection.encourage.level==10,"Los ingresos reales permiten especializar dos cartas en siete días")
   local income=120;for _,receipt in pairs(s.economy.transactions) do income=income+math.max(0,receipt.gold or 0) end
   check(s.gold>=0 and income<40*(225+180),"La economía permite especializarse, no maximizar cuarenta cartas")
   local maxBytes=#assert(Json.encode(s));check(maxBytes<524288,"Campaña con tienda cabe en el límite de guardado")
   print("Specialization: staff_strike N10, encourage N10; income "..income..", remaining "..s.gold..", save "..maxBytes.." bytes.")
  end
  routesRun=routesRun+1;print("Campaign route "..routesRun..": "..ending.."; Orsted="..tostring(visited.day6_orsted_arrival==true))
  return s,ending,visited
 end
 if simulations then
  local results={}
  for _,config in ipairs(simulations)do
   config.metrics={days={},battles={}};local s,ending,visited=run(config)
   results[#results+1]=require("tests.campaign_metrics").finish(s,ending,visited,config)
   print("Simulation: "..config.id.." seed "..config.seed.." => "..tostring(ending or config.metrics.blockedAt))
  end
  return results,count
 end
 local function specialize()
  return run({keep={sylphiette=true,roxy=true,eris=true},preferred="roxy",companion="roxy",favors=true,specialize=true,skipErisTraining=true})
 end
 if os.getenv("DATESIM_TEST_GROUP")=="economy-campaign" then specialize();print("Economy campaign: "..count.." checks passed.");return count end
 local reached={}
 for mask=0,7 do
  local keep,preferred={},nil
  for index,id in ipairs(wives) do keep[id]=math.floor(mask/2^(index-1))%2==1;if keep[id] then preferred=id end end
  for _,companion in ipairs(wives) do
   local s,ending,visited=run({keep=keep,preferred=preferred,companion=companion,detour=mask%2==0})
   local expected=mask==7 and "family_united" or preferred or "solitary"
   check(ending==expected,"Ruta real alcanza "..expected.." con "..companion)
   reached[ending]=true
   if mask~=7 and mask~=0 then check(visited.day7_plans,"Las relaciones restantes se resuelven en escena") end
   if mask==3 or mask==5 or mask==6 then
    check(s.decisions.final_commitment==preferred,"Dos viables exigen compromiso narrativo explícito")
    for _,id in ipairs(wives) do if id~=preferred then check(s.relationships[id].marriageState=="separated","La separación se registra, no se infiere del puntaje") end end
   end
   if mask==7 then
    for _,id in ipairs(wives) do check(s.relationships[id].events.personal_resolution,"Familia unida requiere evento personal de "..id) end
    for _,id in ipairs({"shared_magic","combined_spell","sword_magic"}) do check(s.unlocked[id],"La misión de confianza permite adquirir "..id) end
   end
   if mask%2==0 then check(not visited.seal_encounter and not visited.day4_training,"Los encuentros opcionales permiten descansar o tomar el desvío")
   else check(visited.day4_training_end and s.missions.friendly_duel,"Badigadi concluye vivo el entrenamiento opcional") end
  end
 end
 for _,ending in ipairs(Endings.list) do check(reached[ending.id],"Final realmente alcanzado: "..ending.id) end
 for _,id in ipairs(wives) do
  local s,ending=run({keep={sylphiette=true,roxy=true,eris=true},preferred="roxy",companion="roxy",mistake=id})
  check(ending=="family_united","Una equivocación reparada no provoca una separación irreversible: "..id)
  check(s.relationships[id].brokenPromises.daily_commitment and s.relationships[id].reconciliations.daily_commitment,"Se conservan error y reparación")
  local late,lateEnding=run({keep={sylphiette=true,roxy=true,eris=true},preferred="roxy",companion="roxy",mistakeDay5=id})
  check(lateEnding=="family_united","Una equivocación del día cinco permite reparación con antecedentes: "..id)
  check(late.decisions["choice_day7_"..id]=="repair_late" and late.relationships[id].sharedMoments.late_accountability,"La reparación tardía exige misión previa y queda registrada")
 end
 local _,ending=run({keep={},badGlobal=true,companion="sylphiette",detour=true})
 check(ending=="solitary","Negligencia acumulada conduce al camino solitario sin bloquear la aventura")
 local boundary=Save.newSession()
 boundary.day=7;boundary.checkpoint="day7_sylphiette"
 boundary.relationships.sylphiette.love=65;boundary.relationships.sylphiette.trust=65
 Events.apply(boundary,"boundary_history",{character="sylphiette",love=-20,trust=-20,relationshipEvent="personal_resolution",critical={id="commitment",value=true},conflict="mirror_doubt"})
 check(boundary.relationships.sylphiette.love==45 and boundary.relationships.sylphiette.trust==45,"Fixture de frontera: reparación previa y valores45")
 check(Progression.choose(boundary,"day7_sylphiette","reconcile"),"La reparación con antecedentes es elegible en45")
 check(boundary.relationships.sylphiette.love==55 and Relationships.canMaintain(boundary.relationships,"sylphiette"),"La reparación elegible alcanza el umbral real55")
 check(Progression.next(boundary)=="day7_roxy","La reparación no conduce a una separación contradictoria")
 for _,mode in ipairs({"none","roxy","eris"}) do
  local dailyRun=run({keep={sylphiette=true,roxy=true,eris=true},preferred="roxy",companion="roxy",skipActivities=mode=="none",dailyWife=mode~="none" and mode or nil,favors=true})
  for day=1,7 do
   local report=dailyRun.daily_history[tostring(day)]
   check(report and report.interactions_used==(mode=="none" and (day==7 and 1 or 0) or 3),"Siete cierres con distribución "..mode)
   if mode~="none" then check(report.visits[mode]==(day==7 and 2 or 3),"Repetición libre y ayuda final") end
  end
  for _,favor in ipairs(dailyRun.pending_favors) do check(favor.status=="delivered","Ningún encargo pendiente tras el epílogo") end
 end
 specialize()
 for _,ending in ipairs(Endings.list)do
  local keep={};for _,id in ipairs(wives)do keep[id]=ending.id=="family_united" or ending.id==id end
  local _,actual=run({keep=keep,preferred=ending.id,companion="roxy",skipErisTraining=true})
  check(actual==ending.id,"Cada final se alcanza sin el regalo de Orsted")
 end
 print("Campaign: "..count.." checks passed ("..routesRun.." complete routes, five endings with ordinary progression, Orsted, specialization and save/load).")
 return count
end
return Suite
