local Suite={}
function Suite.run()
 local Save=require("src.systems.save")
 local Daily=require("src.systems.daily")
 local Events=require("src.systems.events")
 local Catalog=require("src.data.activities")
 local Budget=require("src.systems.relationship_budget")
 local Economy=require("src.systems.economy")
 local Collection=require("src.systems.card_collection")
 local Combat=require("src.systems.combat")
 local Json=require("src.systems.json")
 local count=0
 local function check(ok,msg)assert(ok,msg);count=count+1 end
 local function clone(s)return assert(Json.decode(assert(Json.encode(s))))end
 local function fresh(day)
  local s=Save.newSession();Events.apply(s,"starter_gift",{starter=true});s.rewardQueue={}
  s.day=day or 1;s.checkpoint="day"..s.day.."_agenda";Daily.ensure(s);return s
 end
 local function round(s)local loaded,err=Save.validate(clone(s));check(loaded~=nil,err or "Carga válida");return loaded end
 local function close(s)Events.mark(s,Daily.config(s).completionEvent);return assert(Daily.finish(s))end
 for id,r in pairs(fresh().relationships)do check(r.love==50 and r.trust==50 and r.marriageState=="married","Inicio 50/50 activo: "..id)end
 local ids={sylphiette=0,roxy=0,eris=0}
 for _,def in ipairs(Catalog.list)do
  ids[def.character]=ids[def.character]+1
  local s=fresh();check(Daily.startActivity(s,def.id),"Reservar "..def.id)
  check(Daily.remaining(s)==2 and s.daily.visits[def.character]==1,"Un espacio por actividad")
  s=round(s);check(Daily.resolveActivity(s,def.choices[1].id),"Elegir "..def.id)
  if def.battle then
   local d=Daily.battleDefinition(s);s.externalEnergy=30
   s.combat=Combat.new(s.deck,{day=s.day,enemyId=d.enemyId,character=d.character,difficulty=d.difficulty,
    combatDeck=s.combatDeck,unlocked=s.unlocked,curse=s.curse,externalEnergy=30,cardLevels=Collection.levels(s)},function()return 17 end)
   for turn=1,40 do if s.combat.finished then break end;Combat.endTurn(s.combat)end
   check(s.combat.finished,"Combate real finito")
   s=round(s);check(s.combat,"Combate de actividad persiste")
   local enc=s.combat;check(Daily.finishBattle(s,enc),"Recompensa de actividad")
   check(not Daily.finishBattle(s,enc),"Recompensa no duplicada")
   if def.battle=="duel" then check(s.decisions.activity_duel_result=="suspected_throw","Duelo reconoce falta real de esfuerzo")end
  end
  check(s.daily.interactions_used==1 and #s.daily.activities_completed==1,"Resolver no gasta segundo espacio")
  local gold=s.gold;check(not Daily.resolveActivity(s,def.choices[1].id) and s.gold==gold,"Actividad no se repite sin reservar")
  round(s)
 end
 check(ids.eris>=4 and ids.sylphiette>=5 and ids.roxy>=4,"Actividades de las tres esposas")
 for _,wife in ipairs({"sylphiette","roxy","eris"})do
  local s=fresh()
  for n=1,3 do check(Daily.startActivity(s,"time_"..wife),"Repetir esposa");check(Daily.resolveActivity(s,"together"),"Resolver repetición")end
  check(s.daily.visits[wife]==3 and not Daily.startActivity(s,"time_"..wife),"Cuarta actividad rechazada")
  check(s.family.seen["day1_third_"..wife],"Diálogo propio de tercera visita")
  local report=close(s);local stable=Json.encode(s)
  check(Daily.finish(s)==report and Json.encode(s)==stable,"Cierre idempotente")
  for id,r in pairs(s.relationships)do
   if id~=wife then check(r.love==30 and r.trust==30,"Abandono -20/-20 por esposa")
   else check(s.daily.relationship_gains[id].love<=10 and s.daily.relationship_gains[id].trust<=10,"Límite positivo diario")end
  end
 end
 local s=fresh();Events.apply(s,"harm",{character="roxy",love=-60,trust=-55})
 check(s.relationships.roxy.love==-10 and s.relationships.roxy.marriageState~="separated","Negativo no separa automáticamente")
 check(Budget.preview(s,"roxy",{love=4,trust=4}).love==2,"Afinidad negativa reduce ganancias")
 check(Daily.startActivity(s,"reconcile_roxy") and Daily.resolveActivity(s,"repair"),"Reconciliación negativa")
 check(s.relationships.roxy.love==-2 and s.relationships.roxy.trust==3,"Recuperación no reducida")
 s=round(s);check(s.relationships.roxy.love==-2,"Persisten valores negativos")
 s=fresh();s.relationships.roxy.love=80;s.relationships.roxy.trust=80
 check(Budget.preview(s,"roxy",{love=2,trust=2}).love==3,"Afinidad alta facilita bonificaciones")
 s=fresh()
 for day=1,4 do
  s.day=day;s.checkpoint="day"..day.."_agenda";Daily.ensure(s);close(s);s=round(s)
  if day<4 then check(s.relationships.roxy.marriageState~="separated","Advertencias previas")end
 end
 check(s.relationships.roxy.love==-30 and s.family.departures.roxy.permanent,"Separación tras abandono reiterado")
 check(not Daily.startActivity(s,"time_roxy"),"Sin actividades tras separación")
 Events.apply(s,"late_reward",{character="roxy",love=100,trust=100,unlock={"combined_spell"}})
 check(not s.unlocked.combined_spell and s.relationships.roxy.love==-30,"Sin exclusivas ni reactivación por puntos")
 s.inventory.antidoteUsed=true;s=round(s);check(s.relationships.roxy.marriageState=="separated","Cura y carga no revierten separación")
 local chapter=require("src.data.chapters").byId.day6
 s.checkpoint=chapter.companion.selectionCheckpoint;s.decisions[chapter.companion.decisionKey]="roxy"
 check(not require("src.systems.progression").companion(s),"Exclusión del combate final")
 s=fresh();Events.apply(s,"break",{character="eris",marriageState="separated"})
 check(s.family.departures.eris and #s.family.queue==1,"Ruptura crítica prepara escena")
 s=fresh(2);check(Daily.requestFavor(s,"gold_search","cliff"),"Solicitar encargo")
 check(Daily.remaining(s)==3 and s.gold==120,"Solicitud independiente")
 close(s);check(s.gold==120,"No entrega al cierre del día solicitado")
 s.day=3;s.checkpoint="day3_agenda";Daily.ensure(s);Daily.deliverFavors(s)
 check(s.gold==185 and s.pending_favors[1].delivered_day==3,"Entrega al comenzar mañana")
 Daily.deliverFavors(s);check(s.gold==185,"Entrega única")
 check(not Daily.requestFavor(s,"gold_search","zanoba"),"Mismo ID prohibido con otro encargado")
 check(Daily.requestFavor(s,"magic_materials","zanoba"),"Otra tarea disponible")
 check(Daily.accelerateFavor(s,s.pending_favors[2].instance_id),"Ayudar acelera")
 check(s.daily.interactions_used==1 and s.daily.visits.roxy==0 and s.economy.items.magic_material==2,"Ayudar consume espacio sin visita")
 check(not Daily.accelerateFavor(s,s.pending_favors[2].instance_id),"Ayuda idempotente");round(s)
 s=fresh(7);check(not Daily.requestFavor(s,"cliff_notes"),"Día 7 sin encargos futuros")
 check(Daily.requestFavor(s,"cliff_notes","cliff",true) and s.daily.interactions_used==1,"Día 7 acelera con espacio");round(s)
 s=fresh();s.gold=300
 check(Economy.buyBook(s,"rune_recipes",s.economy.revision),"Libro cuesta oro")
 check(s.gold==250 and s.unlocked.analyze_runes and s.family.discounts==2,"Libro desbloquea conocimientos")
 check(not Economy.buyBook(s,"rune_recipes",s.economy.revision),"Libro adquirido una vez")
 Collection.grant(s,"listen",2)
 check(Collection.view(s,"listen").goldRequired==4 and Collection.upgrade(s,"listen",s.economy.revision),"Receta reduce coste sin mejorar gratis")
 check(s.family.discounts==1 and s.gold==246,"Descuento consume receta")
 check(Save.write(s),"Guardar en disco")
 local loaded=assert(Save.load());check(loaded.family.books.rune_recipes and loaded.family.discounts==1,"Libros y recetas persisten")
 for _,case in ipairs({{mode="win",result="victory"},{mode="honor",result="honorable_defeat"}}) do
  s=fresh(5)
  local deck=case.mode=="win" and {"staff_strike","simple_cut","stone_throw","push","coordinated_attack","water_projectile","arcane_guard","heavy_spell","swamp","heal"} or require("src.data.combat_cards").starterDeck
  for _,id in ipairs(deck) do if not s.unlocked[id] then Collection.grant(s,id,1) end end
  s.combatDeck=deck;s.externalEnergy=12
  assert(Daily.startActivity(s,"eris_duel"));assert(Daily.resolveActivity(s,"duel"))
  s.combat=Combat.new(s.deck,{enemyId="eris_training",day=5,difficulty=3,combatDeck=deck,unlocked=s.unlocked,curse=s.curse,externalEnergy=12,cardLevels=Collection.levels(s)},function()return 17 end)
  require("tests.training").solve(s.combat,case.mode)
  check(Daily.finishBattle(s,s.combat) and s.decisions.activity_duel_result==case.result,"Actividad evalúa desempeño real: "..case.result)
  round(s)
 end
 s=fresh();assert(Daily.startActivity(s,"eris_monsters"));assert(Daily.resolveActivity(s,"solo"))
 check(Daily.battleDefinition(s).character==nil,"Cacería permite salir solo")
 s.family.progress.monster_hunts=2
 check(Daily.battleDefinition(s).enemyId=="ruins_guardian","Dos victorias abren un desafío mayor")
 s=fresh();assert(Daily.startActivity(s,"sylphiette_talk"));assert(Daily.resolveActivity(s,"promise"))
 check(s.family.commitmentDue==2,"Promesa con plazo verificable")
 close(s);s.day=2;s.checkpoint="day2_agenda";Daily.ensure(s);s=round(s);close(s)
 check(s.relationships.sylphiette.promises.family_errand=="broken","Incumplimiento familiar queda registrado")
 s.day=3;s.checkpoint="day3_agenda";Daily.ensure(s);assert(Daily.startActivity(s,"sylphiette_errands"));assert(Daily.resolveActivity(s,"shopping"))
 check(s.relationships.sylphiette.reconciliations.family_errand,"Cumplir el recado repara el compromiso")
 local malformed=clone(s);malformed.family.progress.research=true
 check(not Save.validate(malformed),"Rechaza contador familiar no numérico")
 malformed=clone(s);malformed.family.queue={{id="bad",character="rudeus",kind="departure",phase=1}}
 check(not Save.validate(malformed),"Rechaza partida de quien no es esposa")
 local identity=love.filesystem.getIdentity();love.filesystem.setIdentity("cartas_del_destino_family_v5_migration_tests")
 for _,file in ipairs({Save.filename,Save.backup,"campaign-v6.tmp.json","campaign-v5.backup.json"}) do love.filesystem.remove(file) end
 local old=fresh();old.version=5;old.family=nil;old.relationships.roxy.love=65
 local bytes=assert(Json.encode(old));assert(love.filesystem.write("campaign-v5.json",bytes))
 local migrated=assert(Save.load());check(migrated.version==6 and migrated.relationships.roxy.love==65,"Migración v5 conserva afinidad histórica")
 check(Save.write(migrated) and love.filesystem.read("campaign-v5.json")==bytes,"Escribir v6 conserva bytes originales v5")
 love.filesystem.setIdentity(identity)
 local oldSocial,definition=require("tests.dialogue_branching").fixture("encounter_eris",{"listen","be_honest","encourage","subtle_flirt","light_joke"})
 oldSocial.relationships.eris.love=2;oldSocial.relationships.eris.trust=1
 local Cards=require("src.systems.cards");local Memory=require("src.systems.dialogue_memory")
 oldSocial.encounter=Cards.new(oldSocial.deck,require("src.systems.dialogue_resolver").context(oldSocial,definition),function(n)return n end)
 oldSocial.encounter.memory.legacyAffinity=true
 local reaction=assert(Cards.play(oldSocial.encounter,1));reaction.familyVersion=nil
 oldSocial.legacyAffinity=true;assert(Memory.commit(oldSocial,reaction,oldSocial.checkpoint,1));oldSocial.legacyAffinity=nil
 oldSocial.version=5;oldSocial.family=nil;oldSocial.encounterReview=true
 local migratedSocial=round(oldSocial)
 check(migratedSocial.encounter and migratedSocial.relationships.eris.love==0 and migratedSocial.encounter.log[1].actualLove==-2,"Replay v5 conserva el antiguo límite cero sin nueva penalización")
 migratedSocial=round(migratedSocial)
 check(migratedSocial.encounter and migratedSocial.encounter.log[1].actualTrust==-1,"Segunda carga no reinterpreta el efecto histórico")
 print("Family phase 3: "..count.." checks passed.")
 return count
end
return Suite
