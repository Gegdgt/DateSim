-- Contratos de contenido, memoria y mazos; las pantallas se prueban aparte.
local Suite={}
function Suite.fixture(checkpoint,deck)
    local Save=require("src.systems.save")
    local Events=require("src.systems.events")
    local Data=require("src.data.cards")
    local Progression=require("src.systems.progression")
    local s=Save.newSession()
    Events.apply(s,"starter_gift",{starter=true})
    s.rewardQueue={}; s.events.tutorial_completed=true
    s.checkpoint=checkpoint
    s.day=require("src.data.chapters").get(checkpoint).day
    s.deck={}
    for i,id in ipairs(deck or Data.starterDeck) do s.deck[i]=id; s.unlocked[id]=true end
    local def=assert(Progression.encounter(s,checkpoint))
    return s,def,require("src.systems.dialogue_resolver").context(s,def,checkpoint)
end
function Suite.rng(seed)
    local generator=love.math.newRandomGenerator(seed)
    return function(n) return generator:random(n) end
end
function Suite.run()
    local Catalog=require("src.data.dialogue")
    local Data=require("src.data.cards")
    local Characters=require("src.data.characters")
    local Resolver=require("src.systems.dialogue_resolver")
    local Memory=require("src.systems.dialogue_memory")
    local Conditions=require("src.systems.conditions")
    local Cards=require("src.systems.cards")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Events=require("src.systems.events")
    local Progression=require("src.systems.progression")
    local Font=require("src.ui.font")
    local checks,responses,variants,conversations=0,0,0,0
    local function check(value,message) assert(value,message); checks=checks+1 end
    local function encode(value) return assert(Json.encode(value)) end
    local function clone(value) return assert(Json.decode(encode(value))) end
    local function round(s) return assert(Save.validate(clone(s))) end
    local function eligible(card,node)
        return card.encounterTypes.social and card.unlockedAt<=node.day
            and (not card.conditions.character or card.conditions.character==node.character)
    end
    local function destination(id,path)
        check(Catalog.nodes[id]~=nil,"Continuación escrita: "..tostring(id))
        check(not path[id],"Las continuaciones no contienen ciclos: "..id)
        path[id]=true
        local node=Catalog.nodes[id]
        if node.next then destination(node.next,path) end
        path[id]=nil
    end
    local function fits(response,where,base)
        local phrase=response.rudy or (base and base.rudy) or ""
        local reaction=response.response or (base and base.response) or ""
        check(Font.height(phrase,173)<=88,"Frase completa cabe en vista previa: "..where)
        check(Font.height(phrase,462)<=88 and Font.height(reaction,462)<=88,"Intercambio completo cabe en la secuencia: "..where)
    end
    check(#Catalog.buildErrors==0,"El catálogo no registra IDs duplicados")
    for checkpoint,id in pairs(Catalog.encounters) do
        local node=assert(Catalog.nodes[id])
        conversations=conversations+1
        check(node.id==id and Characters.byId[node.character]~=nil,"Conversación con identidad estable: "..id)
        check(type(node.day)=="number" and type(node.background)=="string" and type(node.emotion)=="string","Contexto narrativo completo: "..id)
        local s=Save.newSession(); s.day=node.day
        for _,card in ipairs(Data.list) do s.unlocked[card.id]=true end
        local context=Resolver.context(s,{kind="conversation",character=node.character},checkpoint)
        local phrases={}
        for _,card in ipairs(Data.list) do
            if eligible(card,node) then check(node.cards[card.id]~=nil,"Cobertura de carta equipable: "..id.."/"..card.id) end
        end
        for cardId,base in pairs(node.cards) do
            responses=responses+1
            check(Data.byId[cardId]~=nil,"Respuesta utiliza una carta real: "..cardId)
            check(type(base.rudy)=="string" and #base.rudy>0 and not phrases[base.rudy],"Cada carta tiene una frase inicial distinta: "..id.."/"..cardId)
            phrases[base.rudy]=true
            check(type(base.response)=="string" and #base.response>0 and Characters.expressions[base.expression]~=nil,"Reacción y expresión escritas: "..base.id)
            fits(base,base.id)
            check(Resolver.compatible(Data.byId[cardId],context),"La respuesta escrita es jugable en su contexto: "..base.id)
            destination(base.next,{})
            local result=assert(Resolver.resolve(context,cardId))
            check(result.sequence[1].text==result.phrase and result.sequence[1].delivery=="enchanted","La frase es una línea escrita con voz encantada")
            local applications=0
            for _,line in ipairs(result.sequence) do
                if line.apply then applications=applications+1; check(line.text==result.reaction,"El efecto pertenece a la reacción correcta") end
                check(type(line.text)=="string" and not line.text:find("¿%s*¿") and not line.text:find("%?%s*%?"),"Texto sin envolturas de puntuación duplicadas")
            end
            check(applications==1 and #result.sequence>=3,"Una sola aplicación y una continuación por respuesta")
            for _,variant in ipairs(base.variants or {}) do
                variants=variants+1
                check(type(variant.id)=="string" and Conditions.validate(variant.requires),"Variante con condición válida: "..tostring(variant.id))
                check(type(variant.rudy)=="string" and type(variant.response)=="string","Variante redactada, sin generador de fragmentos")
                fits(variant,variant.id,base)
                destination(variant.next or base.next,{})
            end
        end
        check(node.fallback and Resolver.resolve(context,"pass")~=nil,"Pausa disponible aunque no haya cartas compatibles")
        for _,line in ipairs(Resolver.resolve(context,"pass").sequence) do
            if line.speaker=="rudeus" then
                check(line.delivery=="note" or line.delivery=="thought" or line.delivery=="silence",
                    "La pausa sin carta no regala una voz encantada: "..id)
            end
        end
        fits(node.fallback,id.."/pause")
        check(not Resolver.compatible({id="unwritten_card",conditions={}},context),"Una carta sin diálogo nunca usa una respuesta universal")
        check(not Resolver.compatible(require("src.data.combat_cards").byId.staff_strike,context),"Un ataque físico no entra en la conversación")
    end
    for id,node in pairs(Catalog.nodes) do
        if not node.cards then
            check(Font.height(node.text,462)<=88,"Continuación cabe sin recortar: "..id)
            for _,line in ipairs(node.lines or {}) do check(Font.height(line.text,462)<=88,"Línea extendida cabe sin recortar: "..id) end
        end
    end

    local expected={
        light_joke={love=-5,trust=-2,phrase="¿Quieres que me deje ganar?",expression="angry",flag="eris_disliked_training_joke",next="eris_training_argument"},
        encourage={love=1,trust=1,phrase="¡Claro que sí! Estoy contigo. Entrenemos juntos",expression="happy",flag="eris_training_supported",next="eris_training_together"},
        subtle_flirt={love=1,trust=0,phrase="Iré, pero si gano, quiero un beso",expression="happy",flag="eris_romantic_training",next="eris_training_challenge"},
    }
    local branches={}
    for cardId,wanted in pairs(expected) do
        local s,def,context=Suite.fixture("encounter_eris")
        local result=assert(Resolver.resolve(context,cardId))
        check(result.chemistry==wanted.love and result.trust==wanted.trust and result.phrase==wanted.phrase,"Eris: texto y efectos exactos de "..cardId)
        check(result.expression==wanted.expression and result.nextNode==wanted.next,"Eris: expresión y rama de "..cardId)
        branches[result.nextNode]=true
        local before=encode(s)
        Resolver.resolve(context,cardId)
        check(encode(s)==before,"Consultar la frase no aplica estadísticas ni eventos")
        check(Memory.commit(s,result,s.checkpoint,1),"Aplicar respuesta al aparecer la reacción")
        check(s.relationships.eris.love==65+wanted.love and s.relationships.eris.trust==65+wanted.trust,"Cambios reales exactos de "..cardId)
        check(result.actualLove==wanted.love and result.actualTrust==wanted.trust,"Los deltas mostrables coinciden con los aplicados")
        check(s.events[wanted.flag] and s.decisions["dialogue_encounter_eris"]==wanted.next,"Flag y continuación registrados")
        check(s.decisions[Memory.key(s.checkpoint,1)]==cardId,"La memoria identifica la carta que eligió el jugador")
        s=round(s)
        local persisted=encode({relationships=s.relationships,journal=s.journal,used=s.dialogueMemory.used})
        check(not Memory.commit(s,result,s.checkpoint,1),"Guardar y repetir no duplica la respuesta")
        check(encode({relationships=s.relationships,journal=s.journal,used=s.dialogueMemory.used})==persisted,"La repetición conserva relaciones e historial")
        check(s.events[wanted.flag] and s.dialogueMemory.used[result.responseId]==1,"Eventos y uso de variante sobreviven al guardado")
    end
    local branchCount=0; for _ in pairs(branches) do branchCount=branchCount+1 end
    check(branchCount==3,"Las tres elecciones obligatorias abren tres continuaciones diferentes")
    local romantic,romanticDef=Suite.fixture("encounter_eris")
    local flirt=Resolver.resolve(Resolver.context(romantic,romanticDef),"subtle_flirt")
    Memory.commit(romantic,flirt,romantic.checkpoint,1)
    check(Progression.next(romantic,romantic.checkpoint,{score=flirt.score,trust=0,chemistry=0})=="eris_training_challenge_scene",
        "El coqueteo desbloquea el desafío jugable de entrenamiento")
    local challengeTexts={}
    for _,choice in ipairs({"cover","rush"}) do
        local branch=clone(romantic)
        check(Progression.choose(branch,branch.checkpoint,choice),"El desafío permite elegir "..choice)
        check(Progression.next(branch)=="eris_training_challenge_result","La decisión llega al resultado del desafío")
        branch=round(branch)
        challengeTexts[choice]=encode(Progression.scene(branch,branch.checkpoint).lines)
        check(branch.decisions.eris_challenge_result==(choice=="cover" and "coordinated" or "rushed"),"El resultado del desafío queda guardado")
        branch.checkpoint="day5_mission_eris"; branch.day=5; branch=round(branch)
        local later=Resolver.resolve(Resolver.context(branch,Progression.encounter(branch,branch.checkpoint)),"subtle_flirt")
        check(later.responseId==(choice=="cover" and "eris_d5_flirt_challenge_kept" or "eris_d5_flirt_challenge_rushed"),
            "Día 5 recuerda el resultado real del desafío y no lo presenta como pendiente")
    end
    check(challengeTexts.cover~=challengeTexts.rush,"Ganar la confianza y precipitarse muestran desenlaces diferentes del desafío")
    local pending=clone(romantic); pending.checkpoint="day5_mission_eris"; pending.day=5
    check(Resolver.resolve(Resolver.context(pending,Progression.encounter(pending,pending.checkpoint)),"subtle_flirt").responseId=="eris_d5_flirt_pending_challenge",
        "Solo un reto sin resultado usa la variante pendiente")

    local s,def,context=Suite.fixture("encounter_eris")
    local insult=Resolver.resolve(context,"light_joke"); Memory.commit(s,insult,s.checkpoint,1)
    local apology=Resolver.resolve(Resolver.context(s,def),"admit_error")
    check(apology.responseId=="eris_d2_admit_training_joke","La siguiente carta recuerda la broma anterior")
    Memory.commit(s,apology,s.checkpoint,2)
    s.checkpoint="day5_mission_eris"; s.day=5
    local futureDef=Progression.encounter(s,s.checkpoint)
    local repair=Resolver.resolve(Resolver.context(round(s),futureDef),"sincere_apology")
    check(repair.responseId=="eris_d5_apology_training_respect","Día 5 consulta la broma y su reconocimiento guardados")
    local justStats=Suite.fixture("day5_mission_eris")
    justStats.relationships.eris.love=s.relationships.eris.love; justStats.relationships.eris.trust=s.relationships.eris.trust
    local withoutHistory=Resolver.resolve(Resolver.context(justStats,futureDef),"sincere_apology")
    check(withoutHistory.responseId~=repair.responseId,"Iguales estadísticas no sustituyen la memoria de decisiones")
    local low=Suite.fixture("day5_mission_eris"); low.relationships.eris.trust=20
    local high=Suite.fixture("day5_mission_eris"); high.relationships.eris.trust=90
    check(Resolver.resolve(Resolver.context(low,futureDef),"be_honest").responseId~=Resolver.resolve(Resolver.context(high,futureDef),"be_honest").responseId,
        "Confianza baja y alta seleccionan variantes emocionales distintas")

    for _,case in ipairs({{card="subtle_flirt",love=99,trust=100,actualLove=1,actualTrust=0},{card="light_joke",love=2,trust=1,actualLove=-2,actualTrust=-1}}) do
        local clamped,clampedDef=Suite.fixture("encounter_eris")
        clamped.relationships.eris.love=case.love; clamped.relationships.eris.trust=case.trust
        local enc=Cards.new(clamped.deck,Resolver.context(clamped,clampedDef),Suite.rng(71))
        local index
        for i,id in ipairs(enc.hand) do if id==case.card then index=i end end
        if not index then
            local ordered={}; for _,id in ipairs(clamped.deck) do if id~=case.card then ordered[#ordered+1]=id end end
            ordered[#ordered+1]=case.card; clamped.deck=ordered
            enc=Cards.new(clamped.deck,Resolver.context(clamped,clampedDef),function(n) return n end); index=1
        end
        local preview=Cards.preview(enc,index)
        check(preview.projectedLove==case.actualLove and preview.projectedTrust==case.actualTrust,"Vista previa respeta topes 0/100")
        local result=assert(Cards.play(enc,index,enc.turn))
        check(Memory.commit(clamped,result,clamped.checkpoint,1),"Aplicar efecto limitado por el vínculo")
        check(result.actualLove==case.actualLove and result.actualTrust==case.actualTrust,"La UI recibe el cambio real limitado")
    end

    local deck={"listen","light_joke","be_honest","encourage","subtle_flirt","self_joke","remember","happy_reply","bold_reply","share_fear"}
    s,def,context=Suite.fixture("encounter_eris",deck)
    local hands={}
    for seed=1,24 do
        local enc=Cards.new(s.deck,context,Suite.rng(seed))
        check(#enc.hand==3 and #enc.drawPile==7,"Mazo de diez roba tres y conserva siete")
        hands[table.concat(enc.hand,",")]=true
        local seen={}
        for _,zone in ipairs({enc.hand,enc.drawPile}) do for _,id in ipairs(zone) do
            check(s.unlocked[id] and not seen[id] and Resolver.compatible(Data.byId[id],context),"Reparto solo incluye cartas adquiridas y compatibles, sin duplicarlas")
            seen[id]=true
        end end
    end
    local distinct=0; for _ in pairs(hands) do distinct=distinct+1 end
    check(distinct>6,"Semillas distintas producen manos variadas")
    check(encode(Cards.new(s.deck,context,Suite.rng(45)).initialOrder)==encode(Cards.new(s.deck,context,Suite.rng(45)).initialOrder),"La misma semilla reproduce el orden completo")
    local enc=Cards.new(s.deck,context,Suite.rng(45)); s.encounter=enc
    local visible=encode(enc.hand); local beforeRelations=encode(s.relationships)
    local result=assert(Cards.play(enc,1,enc.turn))
    check(result.phrase==Resolver.resolve(context,result.cardId).phrase,"La carta confirmada pronuncia su vista previa escrita")
    check(encode(s.relationships)==beforeRelations,"Jugar prepara la secuencia; no adelanta los efectos de la reacción")
    check(#enc.discard==1 and enc.discard[1]==result.cardId and #enc.hand==3 and #enc.drawPile==6,"Jugar descarta exactamente una carta y roba una del orden guardado")
    local stale=clone(enc)
    check(not Cards.play(enc,1,1) and encode(enc)==encode(stale),"Una confirmación con turno antiguo no consume otra carta")
    enc.reactionIndex=1; s.encounterReview=true
    local loaded=round(s)
    check(loaded.encounter and not loaded.encounter.log[1].applied,"Cargar antes de la reacción conserva el efecto pendiente")
    local fields={"initialOrder","hand","drawPile","discard","reserve","energy","score","turn","reactionIndex"}
    for _,field in ipairs(fields) do check(encode(loaded.encounter[field])==encode(enc[field]),"Guardar/cargar conserva "..field) end
    Memory.commit(s,result,s.checkpoint,1); enc.reactionIndex=2
    loaded=round(s)
    check(loaded.encounter.log[1].applied and loaded.encounter.reactionIndex==2,"Cargar durante la reacción conserva aplicación y posición")
    local tampered=clone(s)
    tampered.encounter.log[1].actualLove=999; tampered.encounter.log[1].actualTrust=-999
    local repaired=round(tampered).encounter.log[1]
    check(repaired.actualLove==result.projectedLove and repaired.actualTrust==result.projectedTrust,
        "Cargar reconstruye los deltas mostrados y descarta cifras manipuladas del registro")
    local stable=encode(loaded.relationships)
    check(not Memory.commit(loaded,loaded.encounter.log[1],loaded.checkpoint,1) and encode(loaded.relationships)==stable,"El replay de la reacción no concede puntos adicionales")
    local continuedA,continuedB=Cards.play(enc,1),Cards.play(loaded.encounter,1)
    check(continuedA.cardId==continuedB.cardId and continuedA.drawnCard==continuedB.drawnCard and continuedA.responseId==continuedB.responseId,
        "Después de cargar se juega y roba la misma carta con la misma variante")
    local corrupt=clone(enc); corrupt.hand[1]=corrupt.hand[2]
    check(Cards.restore(corrupt,s.deck,Resolver.context(s,def))==nil,"Un guardado no puede duplicar cartas en la mano")
    local locked=clone(s); locked.unlocked[locked.deck[1]]=nil
    check(not pcall(Cards.new,locked.deck,Resolver.context(locked,def),Suite.rng(1)),"Un mazo con una carta bloqueada se rechaza con diagnóstico")
    local sparse={"listen","shared_magic","combined_spell","choose_together","sword_magic"}
    local sparseSession,sparseDef,sparseContext=Suite.fixture("encounter_eris",sparse)
    local sparseEncounter=Cards.new(sparseSession.deck,sparseContext,Suite.rng(1))
    check(#sparseEncounter.hand==1 and sparseEncounter.hand[1]=="listen" and #sparseEncounter.reserve==4 and sparseEncounter.notice,
        "Exclusivas de otra esposa y cartas sin contenido permanecen fuera de la mano")
    local emptyDeck={"shared_magic","combined_spell","choose_together","sword_magic","angry_reply"}
    local emptySession,emptyDef,emptyContext=Suite.fixture("encounter_eris",emptyDeck)
    local empty=Cards.new(emptySession.deck,emptyContext,Suite.rng(2))
    check(#empty.hand==0 and #empty.reserve==5 and empty.notice,"Un mazo sin respuestas compatibles explica por qué no hay cartas")
    check(not Cards.canPlay(empty,1),"No se puede jugar una opción ausente")
    for _=1,3 do check(Cards.pass(empty)~=nil,"Escuchar permite salir del encuentro sin cartas") end
    check(empty.finished and empty.energy==4,"La pausa termina un encuentro sin gastar energía")
    check(Cards.restore(clone(empty),emptySession.deck,emptyContext)~=nil,"También se restaura el encuentro sin cartas compatibles")

    -- Una colección importada podía jugar estas cartas antes del catálogo.
    -- Su historial conserva sus números; no habilita cartas sin texto ahora.
    local imported={"listen","encourage","propose_plan","earth_barrier","analyze_runes"}
    local old=Cards.new(imported,{kind="conversation",character="eris"},function(n) return n end)
    check(not old.narrativeVersion and Cards.play(old,1).cardId=="analyze_runes","Fixture legacy jugó una carta que hoy no tiene respuesta en Eris D2")
    local oldSecond
    for i,id in ipairs(old.hand) do if id=="encourage" then oldSecond=i end end
    check(oldSecond and Cards.play(old,oldSecond).cardId=="encourage","Fixture legacy conserva también una respuesta numérica anterior")
    local oldSession,oldDefinition=Suite.fixture("encounter_eris",imported)
    local oldRelations=encode(oldSession.relationships)
    local restoredOld=Cards.restore(clone(old),imported,Resolver.context(oldSession,oldDefinition))
    check(restoredOld~=nil,"Una acción legacy sin contenido nuevo no invalida el guardado importado")
    for _,field in ipairs({"hand","drawPile","discard","energy","score","turn","finished"}) do
        check(encode(restoredOld[field])==encode(old[field]),"Replay legacy conserva exactamente "..field)
    end
    for i,entry in ipairs(old.log) do
        local restoredEntry=restoredOld.log[i]
        check(restoredEntry.cardId==entry.cardId and restoredEntry.cost==entry.cost and restoredEntry.score==entry.score
            and restoredEntry.trust==entry.trust and restoredEntry.chemistry==entry.chemistry,"Replay conserva deltas legacy, sin recalcularlos como diálogo nuevo")
    end
    check(encode(oldSession.relationships)==oldRelations,"Restaurar historial legacy no aplica ni duplica relaciones")
    local blocked
    for i,id in ipairs(restoredOld.hand) do if not Catalog.nodes.eris_training_invitation.cards[id] then blocked=i; break end end
    check(blocked and not Cards.canPlay(restoredOld,blocked) and Cards.preview(restoredOld,blocked)==nil,"Restaurar no vuelve jugables las cartas futuras sin respuesta escrita")
    local beforeBlocked=encode(restoredOld)
    check(not Cards.play(restoredOld,blocked) and encode(restoredOld)==beforeBlocked,"Intentar jugar una carta legacy incompatible no consume carta ni energía")
    oldSession.encounter=old; oldSession.encounterReview=true
    local loadedOld=round(oldSession)
    check(loadedOld.encounter and loadedOld.encounter.score==old.score and encode(loadedOld.encounter.hand)==encode(old.hand),
        "Validar la partida completa preserva el encuentro legacy en vez de repartir otra mano")

    -- Una promesa se recuerda por su cumplimiento, no solo por el valor del vínculo.
    local sylph,sylphDef=Suite.fixture("encounter_sylphiette")
    local promised=Resolver.resolve(Resolver.context(sylph,sylphDef),"encourage")
    Memory.commit(sylph,promised,sylph.checkpoint,1)
    check(sylph.events.sylphiette_promised_family_time and sylph.relationships.sylphiette.promises.family_time=="pending","Dar ánimo registra la promesa familiar concreta")
    local responsesByOutcome={}
    local recalls={}
    for _,outcome in ipairs({"kept","broken"}) do
        local branch=clone(sylph); branch.checkpoint="day3_family_time"; branch.day=3
        check(Progression.choose(branch,branch.checkpoint,outcome=="kept" and "keep" or "break"),"La promesa tiene una decisión real de cumplimiento")
        check(Progression.next(branch)=="day3_agenda" and branch.events["sylphiette_family_time_"..outcome],"La transición registra el desenlace de la promesa y vuelve a la agenda")
        branch=round(branch)
        recalls[outcome]=encode(Progression.scene(branch,"day4_council").lines)
        branch.checkpoint="day5_mission_sylphiette"; branch.day=5
        branch=round(branch)
        local future=Resolver.context(branch,Progression.encounter(branch,branch.checkpoint))
        responsesByOutcome[outcome]=Resolver.resolve(future,"listen")
    end
    check(responsesByOutcome.kept.responseId~=responsesByOutcome.broken.responseId and responsesByOutcome.kept.reaction~=responsesByOutcome.broken.reaction,
        "Día 5 distingue la promesa cumplida de la incumplida tras guardar y cargar")
    check(recalls.kept~=recalls.broken,"El consejo del Día 4 recuerda el cumplimiento del Día 3")
    Suite.report={checks=checks,conversations=conversations,responses=responses,variants=variants,distinctHands=distinct}
    print("Branching dialogue: "..checks.." checks; "..conversations.." conversations, "..responses.." authored card responses, "..variants.." variants; "..distinct.." different seeded hands.")
    return checks
end
return Suite
