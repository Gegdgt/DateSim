-- Recorridos completos: decisiones reales, mazos legales, combates ejecutados y
-- carga entre checkpoints. No se inyectan estadísticas para fabricar finales.
local Suite={}
function Suite.run()
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
 local count=0
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
 local function bestSocial(enc)
  if enc.finished then return enc.score,0 end
  local best,index=-math.huge,0
  for i=0,#enc.hand do
   if i==0 or Cards.canPlay(enc,i) then
    local nextState=copy(enc)
    if i==0 then Cards.pass(nextState) else Cards.play(nextState,i) end
    local score=bestSocial(nextState)
    if score>best then best,index=score,i end
   end
  end
  return best,index
 end
 local function social(s,def)
  -- Seed 17 is a legal, reproducible shuffle; retries are not used for rewards.
  local enc=Cards.new(s.deck,require("src.systems.dialogue_resolver").context(s,def),rng(17))
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
  -- Equip only earned techniques. Every route, including failed marriages, can
  -- prepare enough artifact magic without receiving a wife's exclusive card.
  local equipped={}
  for _,id in ipairs({"water_cannon","heavy_spell","magic_bolt","water_projectile","ice_lance","arcane_guard","earth_wall","swamp","staff_strike","coordinated_attack","stone_throw","simple_cut","push"}) do
   if s.unlocked[id] and #equipped<10 then equipped[#equipped+1]=id end
  end
  if #equipped>=5 then s.combatDeck=equipped end
  local enc=Combat.new(s.deck,{character=def.character,enemyId=def.enemyId,day=s.day,difficulty=def.difficulty,tutorial=def.tutorial,tacticalContext=def.tacticalContext,combatDeck=s.combatDeck,unlocked=s.unlocked,curse=s.curse,externalEnergy=s.externalEnergy},rng(37))
  s.combat=enc
  local actionCount=0
  while not enc.finished do
   actionCount=actionCount+1;check(actionCount<200,"Combate finito: "..def.enemyId)
   local chosenTactic=def.tacticalContext and def.tacticalContext.companionInjured and #enc.relationshipEvents==0 and "protect" or "coordinate"
   if Combat.canBreakSeal and Combat.canBreakSeal(enc) then
    check(Combat.breakSeal(enc)~=nil,"El sello exige una acción explícita después de agotar a Badigadi")
   elseif enc.companion and Combat.canTactic(enc,chosenTactic) then
    check(Combat.tactic(enc,chosenTactic)~=nil,"Compañera actúa realmente")
   else
    local best,index=-math.huge,nil
    for i=1,#enc.hand do
     if Combat.canPlay(enc,i) then
      local c=Combat.card(enc.hand[i]);local e=c.effects
      local score=(e.damage or 0)*3+(e.draw or 0)*5+(e.mana or 0)*.4+(e.energy or 0)*6
      if enc.enemy.intent.kind=="attack" then score=score+math.min(e.shield or 0,math.max(0,enc.enemy.intent.damage-enc.player.shield))*1.3 end
      score=score+math.min(e.heal or 0,enc.player.maxHp-enc.player.hp)*1.4-(c.hpCost or 0)*.8
      if score>best then best,index=score,i end
     end
    end
    if index then check(Combat.play(enc,index)~=nil,"Carta de combate legal")
    else check(Combat.endTurn(enc)~=nil,"Turno enemigo ejecutado") end
   end
  end
  check(enc.outcome=="victory","Victoria alcanzable: "..def.enemyId.." / "..tostring(def.character).." / "..tostring(enc.cause))
  check(#enc.relationshipEvents<=1,"Como máximo una interpretación romántica por combate")
  local snapshot=round(s)
  check(snapshot.combat and snapshot.combat.outcome==enc.outcome,"Replay conserva victoria antes de recompensa")
  s=snapshot;enc=s.combat
  if def.training then
   check(require("src.systems.training_result").commit(s,enc)~=nil,"La reacción del entrenamiento aplica su resultado antes de salir")
  end
  check(Progression.finishCombat(s,enc)~=nil,"Victoria continúa la historia")
  return s
 end
 local function run(config)
  local s=Save.newSession();local visited={};local steps=0
  while true do
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
   elseif node.kind=="hub" then
    local available=Progression.availableCompanions(s)
    if #available>0 then check(Progression.selectCompanion(s,config.companion or config.preferred or "roxy")~=nil,"Compañía elegida")
    else
     local selected
     for _,place in ipairs(Progression.hub(s).locations) do if not s.events[place.completedEvent] then selected=place;break end end
     check(selected and Progression.visit(s,selected.character)~=nil,"Visita pendiente accesible")
    end
   elseif node.kind=="encounter" then
    local def=Progression.encounter(s,checkpoint)
    if def.kind=="magic" then s=battle(s,def,config) else social(s,def) end
   else check(Progression.next(s)~=nil,"Continuidad entre capítulos") end
   s=round(s)
  end
  local ending,err=Relationships.ending(s.relationships)
  check(ending~=nil,"No quedan matrimonios ambiguos en el epílogo: "..tostring(err))
  check(Endings.byId[ending]~=nil,"El epílogo pertenece a los cinco desenlaces")
  check(s.events.antidote_obtained and not s.curse.active and s.events.campaign_complete,"Antídoto utilizado y campaña completada")
  check(Relationships.ending(round(s).relationships)==ending,"Final persiste al guardar/cargar")
  Suite.completed[ending]=copy(s)
  return s,ending,visited
 end
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
 Events.apply(boundary,"boundary_history",{character="sylphiette",love=-20,trust=-20,relationshipEvent="personal_resolution",critical={id="commitment",value=true},conflict="mirror_doubt"})
 check(boundary.relationships.sylphiette.love==45 and boundary.relationships.sylphiette.trust==45,"Fixture de frontera: reparación previa y valores45")
 check(Progression.choose(boundary,"day7_sylphiette","reconcile"),"La reparación con antecedentes es elegible en45")
 check(boundary.relationships.sylphiette.love==55 and Relationships.canMaintain(boundary.relationships,"sylphiette"),"La reparación elegible alcanza el umbral real55")
 check(Progression.next(boundary)=="day7_roxy","La reparación no conduce a una separación contradictoria")
 print("Campaign: "..count.." checks passed (31 complete routes, five endings, legal battles, save/load and reconciliations).")
 return count
end
return Suite
