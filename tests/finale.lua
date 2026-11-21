local Suite={}
function Suite.run()
 local Save=require("src.systems.save");local F=require("src.systems.finale");local Daily=require("src.systems.daily")
 local Events=require("src.systems.events");local Collection=require("src.systems.card_collection");local Combat=require("src.systems.combat")
 local Progression=require("src.systems.progression");local Chapters=require("src.data.chapters");local Sim=require("tests.war_balance")
 local Json=require("src.systems.json");local checks=0
 local function check(ok,msg)assert(ok,msg);checks=checks+1 end
 local function encode(v)return assert(Json.encode(v))end
 local function round(s)return assert(Save.validate(assert(Json.decode(encode(s)))))end
 local function fresh(day,cp)
  local s=Save.newSession();Events.apply(s,"starter_gift",{starter=true});s.rewardQueue={}
  s.day=day or 1;s.checkpoint=cp or ("day"..s.day.."_agenda");Daily.ensure(s);return s
 end
 local function train(s,day)
  s.day=day;s.checkpoint="day"..day.."_agenda";Daily.ensure(s)
  assert(Daily.startActivity(s,"time_eris"));assert(Daily.resolveActivity(s,"together"));s.rewardQueue={};s.family.queue={}
 end
 for mask=0,31 do
  local s=fresh()
  for day=1,5 do if math.floor(mask/2^(day-1))%2==1 then train(s,day)end end
  s.day=6;s.checkpoint="day6_emissary_confession";Daily.ensure(s)
  check(F.trainedEveryDay(s)==(mask==31),"Cinco fechas distintas, máscara "..mask)
  local nextId=assert(Progression.next(s))
  check(nextId==(mask==31 and "day6_orsted_arrival" or "day6_close"),"Orsted sólo aparece con cinco días")
 end
 local s=fresh();assert(Daily.startActivity(s,"time_eris"))
 check(not F.trainedEveryDay(s) and not s.eris_training_days["1"],"Reservar no registra entrenamiento")
 assert(Daily.resolveActivity(s,"together"));train(s,1);train(s,1)
 check(s.daily.visits.eris==3 and s.eris_training_days["1"] and not s.events.eris_five_training_days,"Tres repeticiones no sustituyen cinco días")
 check(not Daily.startActivity(s,"time_eris"),"Se conserva el límite diario")
 check(round(s).eris_training_days["1"],"Fecha persiste al cargar")
 for day=2,5 do train(s,day)end
 check(F.trainedEveryDay(round(s)),"Cinco días persisten")
 local valid,errors=require("src.systems.narrative_validator").validate(Chapters,{checkFiles=false})
 check(valid,table.concat(errors,"; "))
 for day=1,5 do
  local chapter=Chapters.byId["day"..day]
  for id,scene in pairs(chapter.scenes)do
   for _,line in ipairs(scene.lines or {})do
    local text=line.text
    check(not (text:find("Badigadi") and (text:find("antídoto") or text:find("frasco"))),"Misterio previo: "..id)
   end
  end
 end
 check(not require("src.data.documents").potion_origin.text:find("Badigadi"),"La pista temprana no revela al guardián")
 local function battle(s,id)
  for _,card in ipairs(Collection.list)do s.unlocked[card.id]=true;s.collection[card.id].unlocked=true;s.collection[card.id].level=5 end
  s.combatDeck=Sim.deck;s.externalEnergy=30
  local def=Progression.encounter(s,s.checkpoint);local support=require("src.systems.companions").context(s,def)
  s.combat=Combat.new(s.deck,{enemyId=id or def.enemyId,day=s.day,character=def.character,relationships=support.relationships,team=support.team,
   combatDeck=s.combatDeck,unlocked=s.unlocked,cardLevels=Collection.levels(s),curse=s.curse,externalEnergy=s.externalEnergy},function()return 17 end)
  return s.combat
 end
 local mystery=fresh(6,"day6_hitogami")
 check(not Progression.next(mystery) and not mystery.events.antidote_holder_revealed,"No omitir al emisario para revelar al jefe")
 Sim.solve(battle(mystery));assert(Progression.finishCombat(mystery,mystery.combat))
 check(mystery.checkpoint=="day6_emissary_confession" and not mystery.events.antidote_holder_revealed,"La derrota abre la confesión")
 assert(Progression.next(mystery))
 check(mystery.events.antidote_holder_revealed and mystery.clues.antidote_location and mystery.missions.emissary_investigation,"Revelación y misión tras leer la confesión")
 check(mystery.checkpoint=="day6_close","La historia sigue sin Orsted")
 for _,level in ipairs({1,5,10})do for seed=1,8 do
  local e=Sim.make(level,3,100,seed*17,"orsted_demonstration",6)
  check(next(e.allies)==nil,"Rudy afronta solo la demostración")
  Sim.solve(e)
  check(e.outcome=="defeat" and e.narrativeDefeat=="orsted_demonstration" and e.turn<=4,"Derrota narrativa, incluso con cartas N10")
  check(e.enemy.hp>=1 and e.enemy.maxHp==120,"Guardia finita, Orsted no muere")
 end end
 local orsted=fresh(6,"day6_orsted_demonstration")
 local e=battle(orsted);local relations=encode(orsted.relationships);local gold=orsted.gold
 check(not Progression.next(orsted),"No omitir la demostración")
 for turn=1,4 do
  if not e.finished then assert(Combat.basic(e,"defend"));assert(Combat.basic(e,"dodge"));assert(Combat.endTurn(e))end
 end
 check(e.turn==4 and e.narrativeDefeat and e.player.hp>0,"Defender permite sobrevivir cuatro turnos; Orsted termina")
 orsted=round(orsted);e=orsted.combat
 check(e and e.narrativeDefeat and e.turn==4,"Derrota narrativa se restaura por comandos")
 assert(Progression.finishCombat(orsted,e))
 check(encode(orsted.relationships)==relations and orsted.gold==gold,"Derrota de Orsted sin penalizaciones ni premio ordinario")
 check(orsted.checkpoint=="day6_orsted_discovery","Evaluación y reconocimiento después del duelo")
 -- Regalo real: dos cartas faltantes y el resto de niveles/cantidades intactos.
 orsted.unlocked.listen=nil;orsted.collection.listen.unlocked=false;orsted.unlocked.heal=nil;orsted.collection.heal.unlocked=false
 orsted.collection.staff_strike.copies=23;orsted.family.discounts=2
 assert(Progression.next(orsted));check(orsted.checkpoint=="day6_orsted_gifts","La ayuda abre la selección")
 for _,card in ipairs(Collection.list)do check(orsted.unlocked[card.id],"Desbloquea "..card.id)end
 local collection=encode(orsted.collection);local rewards=#orsted.rewardQueue
 assert(F.advance(orsted,"orsted_grant"))
 check(encode(orsted.collection)==collection and #orsted.rewardQueue==rewards,"Regalo no duplica copias ni presentaciones")
 check(not Progression.next(orsted),"No avanzar sin las dos elecciones")
 check(not F.choose(orsted,"social","staff_strike",0),"Valida el tipo social")
 local selected=assert(F.choose(orsted,"combat","staff_strike",0))
 check(orsted.collection.staff_strike.level==10 and orsted.collection.staff_strike.copies==23 and orsted.gold==gold and orsted.family.discounts==2,"Mejora gratuita conserva copias, oro y recetas")
 check(not F.choose(orsted,"combat","water_cannon",0) and not F.choose(orsted,"social","listen",1),"Revisión y presentación impiden dobles elecciones")
 selected.elapsed=.6;orsted=round(orsted)
 check(orsted.orsted_reward.pending.elapsed==.6 and orsted.collection.staff_strike.level==10,"Guardar durante animación no repite la mejora")
 F.acknowledge(orsted);assert(F.choose(orsted,"social","listen",1));F.acknowledge(orsted)
 check(F.rewardComplete(orsted) and orsted.orsted_reward.revision==2,"Exactamente una elección por categoría")
 local maxed=0;for _,entry in pairs(orsted.collection)do if entry.level==10 then maxed=maxed+1 end end
 check(maxed==2,"Exactamente dos cartas maximizadas")
 local before=encode(orsted);check(not F.choose(orsted,"social","encourage",2) and encode(orsted)==before,"No hay tercera mejora")
 assert(Progression.next(orsted));check(orsted.checkpoint=="day6_close","Continúa tras las dos mejoras")
 -- Híbridas cuentan para ambos tipos, pero no pueden reclamar ambos premios.
 local hybrid=fresh(6,"day6_orsted_gifts");hybrid.events.orsted_demonstration_completed=true;F.advance(hybrid,"orsted_grant")
 assert(F.choose(hybrid,"combat","shared_magic",0));F.acknowledge(hybrid)
 check(not F.choose(hybrid,"social","shared_magic",1),"Dos elecciones deben ser distintas")
 hybrid.relationships.sylphiette.marriageState="separated"
 local support=require("src.systems.companions").roster({team={sylphiette=true},relationships=hybrid.relationships})
 check(not support.sylphiette and hybrid.unlocked.shared_magic,"Colección completa no restaura matrimonio ni apoyo")
 local finish=fresh(7,"day7_intro");local beforeRelations=encode(finish.relationships)
 Events.apply(finish,"antidote_obtained",{antidote=true});assert(Progression.choose(finish,finish.checkpoint,"use_antidote"))
 check(require("src.systems.curse").canSpeak(finish) and require("src.systems.curse").canUseChantlessMagic(finish),"Antídoto restaura voz, maná y magia sin conjuro")
 check(encode(finish.relationships)==beforeRelations,"La cura no cambia amor ni confianza")
 for _,r in pairs(finish.relationships)do r.marriageState="separated"end
 finish.checkpoint="day7_return_cards";local archive=encode(finish.collection)
 assert(Progression.next(finish));check(finish.checkpoint=="day7_epilogue_solitary" and finish.inventory.enchantedCardsReturned,"Devuelve cartas antes del epílogo")
 check(encode(finish.collection)==archive and #require("src.data.endings").list==5,"Conserva colección y exactamente cinco finales")
 check(round(finish).inventory.enchantedCardsReturned,"La devolución persiste")
 -- Importación v7: fechas demostradas por actividades; original conservado.
 local identity=love.filesystem.getIdentity();love.filesystem.setIdentity("cartas_del_destino_finale_v7_migration")
 for _,path in ipairs({Save.filename,Save.backup})do love.filesystem.remove(path)end
 local old=fresh()
 for day=1,5 do
  train(old,day);Events.apply(old,Daily.config(old).completionEvent,{});assert(Daily.finish(old))
 end
 -- El archivo v7 contiene resúmenes reales, pero todavía no los eventos de Fase 5.
 old.version=7;old.eris_training_days=nil;old.events.eris_five_training_days=nil
 for day=1,5 do
  old.events["eris_training_day_"..day]=nil
  old.events_by_day[tostring(day)]["eris_training_day_"..day]=nil
 end
 old.events_by_day["5"].eris_five_training_days=nil
 old.day=6;old.checkpoint="day6_hitogami";Daily.ensure(old);old.rewardQueue={};old.family.queue={}
 old.combat=Combat.new(old.deck,{enemyId="hitogami_minion",day=6,combatDeck=old.combatDeck,unlocked=old.unlocked,cardLevels=Collection.levels(old),curse=old.curse,externalEnergy=0},function()return 17 end)
 Combat.basic(old.combat,"defend")
 local bytes=encode(old);assert(love.filesystem.write("campaign-v7.json",bytes))
 local migrated=assert(Save.load())
 check(migrated.version==8 and F.trainedEveryDay(migrated),"Migra cinco fechas verificables de v7")
 for day=1,5 do check(migrated.events_by_day[tostring(day)]["eris_training_day_"..day],"La migración conserva el índice diario: "..day)end
 check(migrated.events_by_day["5"].eris_five_training_days,"La condición migrada tiene fecha estable")
 local migratedAgain=round(migrated)
 check(migratedAgain.events_by_day["5"].eris_five_training_days and F.trainedEveryDay(migratedAgain),"La segunda carga conserva el calendario reconstruido")
 check(migrated.combat and migrated.combat.revision==1 and migrated.combat.enemy.id=="hitogami_minion","Conserva batalla v7 iniciada antes del emisario nuevo")
 check(Save.write(migrated) and love.filesystem.read("campaign-v7.json")==bytes,"v8 no sobrescribe v7")
 love.filesystem.setIdentity(identity)
 print("Finale phase 5: "..checks.." checks; 32 calendars, 24 controlled Orsted battles, choices, mystery, cure, return and migration.")
 return checks
end
return Suite
