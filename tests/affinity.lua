local Suite={}
function Suite.run()
 local Affinity=require("src.systems.affinity")
 local Cards=require("src.systems.cards")
 local Data=require("src.data.cards")
 local Catalog=require("src.data.dialogue")
 local Resolver=require("src.systems.dialogue_resolver")
 local Memory=require("src.systems.dialogue_memory")
 local Conditions=require("src.systems.conditions")
 local Save=require("src.systems.save")
 local Events=require("src.systems.events")
 local Json=require("src.systems.json")
 local Validator=require("src.systems.dialogue_validator")
 local Font=require("src.ui.font")
 local count=0
 local function check(value,message) assert(value,message);count=count+1 end
 local function encoded(value) return assert(Json.encode(value)) end
 local function clone(value) return assert(Json.decode(encoded(value))) end
 local function round(value) return assert(Save.validate(clone(value))) end
 local function fixture(scene)
  local s=Save.newSession({love=65,trust=65});Events.apply(s,"starter_gift",{starter=true});s.rewardQueue={}
  scene=scene or "nanahoshi_test"
  s.checkpoint=scene=="nanahoshi_test" and "day1_tutorial" or scene
  s.day=require("src.data.chapters").get(s.checkpoint).day
  for _,card in ipairs(Data.list) do s.unlocked[card.id]=true end
  local context=Resolver.context(s,{character="nanahoshi",kind=scene=="nanahoshi_test" and "conversation" or "investigation"},scene)
  if scene=="nanahoshi_test" then context.socialTutorial=true end
  return s,context
 end
 local empty={}; local defaults=Affinity.get(empty,"nanahoshi")
 check(defaults.trust==35 and defaults.interest==0 and empty.affinities==nil,"Consultar afinidad anterior al cambio no modifica el guardado")
 check(Affinity.get(empty,"rudeus")==nil,"El protagonista no obtiene una identidad de afinidad")
 local allowed={listen=true,be_honest=true,encourage=true,light_joke=true,subtle_flirt=true}
 local configured=0;for id in pairs(Affinity.config.nanahoshi.positiveCards) do configured=configured+1;check(allowed[id],"La lista central contiene solo las cinco intenciones elegidas") end
 check(configured==5,"Exactamente cinco cartas sociales favorables")
 local positive,inventory=0,{}
 for _,list in ipairs({Data.list,require("src.data.combat_cards").list}) do for _,card in ipairs(list) do inventory[#inventory+1]=card end end
 check(#inventory==40,"La restricción se comprueba contra las cuarenta cartas reales")
 for _,card in ipairs(inventory) do
  local value=Affinity.sanitize("nanahoshi",{cardId=card.id,trust=3,interest=99})
  check((value.interest>0)==(allowed[card.id]==true),"No hay una sexta carta por datos ni por efecto inyectado: "..card.id)
  if value.interest>0 then positive=positive+1;check(not card.combat and card.encounterTypes.social,"El interés positivo solo procede de cartas puramente sociales") end
 end
 check(positive==5,"Solo cinco de cuarenta cartas conceden interés")
 for _,id in ipairs({"unknown_card","pass","combined_spell","sword_magic","shared_magic","staff_strike"}) do
  local delta=Affinity.preview({},"nanahoshi",{cardId=id,trust=20,interest=20})
  check(delta.trust==0 and delta.interest==0,"Una carta incompatible o inexistente no concede puntos: "..id)
 end
 local normalized=Affinity.normalize({nanahoshi={trust=999,interest=-9,awarded={valid=true,bad=1}},eris={trust=60}})
 check(normalized.nanahoshi.trust==100 and normalized.nanahoshi.interest==0 and normalized.eris==nil,"Normalización acota las barras y no duplica esposas")
 check(normalized.nanahoshi.awarded.valid and not normalized.nanahoshi.awarded.bad,"Solo se restauran identificadores de recompensa válidos")
 local invalid=Affinity.normalize({nanahoshi={trust=0/0,interest=math.huge}})
 check(invalid.nanahoshi.trust==35 and invalid.nanahoshi.interest==0,"NaN e infinito recuperan valores iniciales seguros")
 check(Conditions.validate({affinity="nanahoshi",trust=40,interest=4}),"Condición declarativa de afinidad")
 check(not Conditions.validate({affinity="nanahoshi",interest=101}),"Umbral fuera de rango rechazado")
 check(not Conditions.validate({affinity="eris",interest=4}),"Las esposas no se duplican como afinidad")
 local s,context=fixture()
 local initial=encoded(s);local wives=encoded(s.relationships)
 local result=Resolver.resolve(context,"subtle_flirt")
 check(result.interest==4 and result.trust==1 and result.chemistry==0 and result.expression=="happy","Halago específico genera curiosidad discreta, no amor")
 check(result.affinityTarget=="nanahoshi" and result.responseId=="nano_flirt","Respuesta mantiene identidad y ID del tutorial")
 check(encoded(s)==initial,"La vista previa y el resolver no aplican afinidad")
 check(Memory.commit(s,result,"nanahoshi_test",1),"Afinidad se confirma en la reacción")
 check(result.actualInterest==4 and result.actualTrust==1 and result.actualLove==0,"Deltas reales devueltos a las barras")
 check(result.affinityBefore.trust==35 and result.affinityAfter.trust==36 and result.affinityAfter.interest==4,"Antes y después son los valores reales")
 check(s.affinities.nanahoshi.interest==4 and s.affinities.nanahoshi.trust==36,"Persistencia independiente de afinidad")
 check(encoded(s.relationships)==wives and s.relationships.nanahoshi==nil,"Hablar con Nanahoshi no modifica ningún matrimonio")
 check(not Memory.commit(s,result,"nanahoshi_test",1),"La misma reacción no se vuelve a aplicar")
 local replay=Resolver.resolve(Resolver.context(s,{character="nanahoshi",kind="conversation"},"nanahoshi_test"),"subtle_flirt")
 check(Memory.commit(s,replay,"nanahoshi_test",2) and replay.actualInterest==0 and replay.actualTrust==0,"Repetir la misma carta en el tutorial no permite farmear con otro turno")
 local loaded=round(s)
 check(loaded.affinities.nanahoshi.trust==36 and loaded.affinities.nanahoshi.interest==4,"Guardar y cargar conserva ambos valores")
 local repeatAfterLoad=Resolver.resolve(context,"subtle_flirt")
 check(Memory.commit(loaded,repeatAfterLoad,"nanahoshi_test",3) and repeatAfterLoad.actualInterest==0,"El registro anti repetición sobrevive al guardado")
 check(loaded.events.nano_compliment_noticed and loaded.decisions[Memory.key("nanahoshi_test",1)]=="subtle_flirt","Se conservan la decisión y el reconocimiento de Nanahoshi")
 local old=Save.newSession({love=65,trust=65});old.affinities=nil;local restoredOld=round(old)
 check(restoredOld.affinities.nanahoshi.trust==35 and restoredOld.affinities.nanahoshi.interest==0,"Guardado v3 sin afinidad recibe valores predeterminados")
 check(encoded(restoredOld.relationships)==encoded(old.relationships),"Migrar afinidad no cambia relaciones antiguas")
 local unknown=Affinity.sanitize("nanahoshi",{cardId="remember",trust=2,interest=100})
 check(unknown.trust==2 and unknown.interest==0,"Una carta social ajena a las cinco puede mejorar confianza, jamás interés")
 local capped={affinities=Affinity.new()};capped.affinities.nanahoshi.trust=99;capped.affinities.nanahoshi.interest=99
 local applied,delta=Affinity.apply(capped,"nanahoshi",{cardId="subtle_flirt",trust=3,interest=9,conversationId="cap"},"cap")
 check(applied and delta.trust==1 and delta.interest==1,"La barra devuelve solo el aumento efectivo hasta cien")
 local lower={affinities=Affinity.new()};lower.affinities.nanahoshi.trust=1;lower.affinities.nanahoshi.interest=1
 local _,down=Affinity.apply(lower,"nanahoshi",{cardId="angry_reply",trust=-5,interest=-2,conversationId="boundary"},"boundary")
 check(down.trust==-1 and down.interest==-1 and lower.affinities.nanahoshi.interest==0,"Las pérdidas se acotan en cero")
 check(not Affinity.apply(lower,"nanahoshi",{},"boundary"),"La transacción de afinidad es idempotente por sí misma")

 local roots,bases,variants=0,0,0
 for scene,nodeId in pairs(Catalog.encounters) do
  local node=Catalog.nodes[nodeId]
  if node.character=="nanahoshi" then
   roots=roots+1;local seen={};local friendly=0
   for cardId,base in pairs(node.cards) do
    bases=bases+1
    check(not seen[base.response],"Reacción contextual distinta por intención: "..base.id);seen[base.response]=true
    check(base.effects.love==0,"Nanahoshi nunca entrega amor: "..base.id)
    if (base.effects.interest or 0)>0 then friendly=friendly+1;check(allowed[cardId],"Contenido respeta la lista central: "..base.id) end
    check(Font.height(base.rudy,173)<=88 and Font.height(base.response,462)<=88,"Frase y reacción caben completas: "..base.id)
    for _,variant in ipairs(base.variants or {}) do
     variants=variants+1
     check((variant.effects.interest or 0)<=0 or allowed[cardId],"Las variantes no habilitan una sexta carta: "..variant.id)
     check(Font.height(variant.rudy,173)<=88 and Font.height(variant.response,462)<=88,"Variante cabe completa: "..variant.id)
    end
   end
   check(friendly==5,"Cada conversación tiene las cinco respuestas favorables explícitas: "..scene)
  end
 end
 check(roots==3 and bases==37 and variants==11,"Tutorial y dos investigaciones tienen contenido escrito completo")
 local nextContext=Resolver.context(s,{character="nanahoshi",kind="investigation"},"day3_nanahoshi_research")
 local nextReply=Resolver.resolve(nextContext,"subtle_flirt")
 check(nextReply.responseId=="nano_d3_flirt_curious","Interés guardado selecciona una variante posterior")
 check(Memory.commit(s,nextReply,"day3_nanahoshi_research",1) and nextReply.actualInterest==4,"Una investigación nueva admite un avance distinto del tutorial")
 local attentive=fixture();attentive.events.nano_method_noticed=true
 local method=Resolver.resolve(Resolver.context(attentive,{character="nanahoshi",kind="investigation"},"day3_nanahoshi_research"),"listen")
 check(method.responseId=="nano_d3_listen_method","La investigación recuerda la decisión concreta del tutorial")
 local boundary,boundaryContext=fixture("day4_nanahoshi_research")
 local angry=Resolver.resolve(boundaryContext,"angry_reply");Memory.commit(boundary,angry,boundary.checkpoint,1)
 local apology=Resolver.resolve(Resolver.context(boundary,{character="nanahoshi",kind="investigation"}),"sincere_apology")
 check(apology.responseId=="nano_d4_apology_boundary" and apology.interest==0,"La disculpa contextual reconoce el límite sin convertirlo en recompensa romántica")
 check(require("src.data.characters").byId.nanahoshi.romance==false and #require("src.data.endings").list==5,"Se mantienen los cinco finales y el vínculo no matrimonial")
 for _,id in ipairs(require("src.data.characters").romanceIds) do check(id~="nanahoshi","Nanahoshi no forma parte de las esposas") end

 local pending,pendingContext=fixture()
 local enc=Cards.new(pending.deck,pendingContext,function(n)return n end)
 local preview=Cards.preview(enc,1)
 check(preview.cardId=="subtle_flirt" and preview.projectedInterest==4 and preview.projectedTrust==1,"La vista previa calcula ambos deltas sin consumir")
 local pendingResult=Cards.play(enc,1);pending.encounter=enc;pending.encounterReview=true
 check(pending.affinities.nanahoshi.interest==0 and enc.memory.affinities.nanahoshi.interest==4,"Jugar actualiza memoria local; la partida espera a la reacción")
 local pendingLoad=round(pending);local savedResult=pendingLoad.encounter.log[1]
 check(pendingLoad.affinities.nanahoshi.interest==0 and not savedResult.applied,"Guardar antes de reaccionar no aplica premios")
 check(Memory.commit(pendingLoad,savedResult,"nanahoshi_test",1) and savedResult.actualInterest==4,"La reacción pendiente se aplica una sola vez después de cargar")
 local afterLoad=round(pendingLoad);local afterResult=afterLoad.encounter.log[1]
 check(afterResult.applied and afterResult.actualInterest==4 and afterResult.actualTrust==1,"Restaurar una reacción aplicada conserva sus deltas reales")
 check(afterResult.affinityBefore.interest==0 and afterResult.affinityAfter.interest==4,"Restaurar conserva extremos para la animación de barras")
 check(not Memory.commit(afterLoad,afterResult,"nanahoshi_test",1) and afterLoad.affinities.nanahoshi.interest==4,"Revisar otra vez no recompensa")
 local historical=clone(pending)
 historical.affinities=nil;historical.encounter.affinityVersion=nil
 historical.encounter.initialMemory.affinities=nil;historical.encounter.memory.affinities=nil
 local migrated=round(historical);local migrationResult=migrated.encounter.log[1]
 check(migrationResult.affinitySuppressed and migrationResult.trust==0 and migrationResult.interest==0,"Snapshot social anterior conserva sus efectos originales sin premio retroactivo")
 check(Memory.commit(migrated,migrationResult,"nanahoshi_test",1) and migrated.affinities.nanahoshi.interest==0,"Completar una reacción histórica no aumenta afinidad nueva")
 local modern=Resolver.resolve(Resolver.context(migrated,{character="nanahoshi",kind="investigation"},"day3_nanahoshi_research"),"subtle_flirt")
 check(modern.interest==4 and not modern.affinitySuppressed,"La compatibilidad histórica no bloquea investigaciones nuevas")

 local malformed=Memory.copy(Catalog)
 malformed.nodes.nanahoshi_voice_test.cards.self_joke.effects.interest=4
 check(not Validator.validate(malformed),"El validador rechaza interés en una sexta carta por contenido")
 malformed=Memory.copy(Catalog)
 malformed.nodes.nano_seal_review.cards.sincere_apology.variants[1].effects.interest=1
 check(not Validator.validate(malformed),"El validador comprueba también efectos heredados por variantes")
 malformed=Memory.copy(Catalog)
 malformed.nodes.nanahoshi_voice_test.cards.listen.effects.love=1
 check(not Validator.validate(malformed),"El contenido no matrimonial no puede conceder amor")
 check(Validator.validate(),"El catálogo completo conserva cobertura y referencias válidas")
 print("Affinity: "..count.." checks passed")
end
return Suite
