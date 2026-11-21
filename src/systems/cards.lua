local Data = require("src.data.cards")
local Cards = {}
local metrics={"score","trust","chemistry"}
local function delta(layer)
    local out={}
    for _,key in ipairs(metrics) do out[key]=(layer or {})[key] or 0 end
    return out
end
function Cards.signed(value) return (value>=0 and "+" or "")..tostring(value) end
function Cards.describe(value)
    local trust=value.actualTrust or value.projectedTrust or value.trust or 0
    if value.affinityTarget then
        local interest=value.actualInterest or value.projectedInterest or value.interest or 0
        return Cards.signed(value.score or 0).." avance / "..Cards.signed(trust).." conf. / "..Cards.signed(interest).." interés"
    end
    local love=value.actualLove or value.projectedLove or value.chemistry or 0
    return Cards.signed(value.score or 0).." avance / "..Cards.signed(trust).." conf. / "..Cards.signed(love).." amor"
end

local function copy(list)
    local out={}
    for i,v in ipairs(list) do out[i]=v end
    return out
end

function Cards.validateDeck(deck,unlocked)
    if type(deck)~="table" or #deck<5 or #deck>10 then return false,"El mazo debe tener entre 5 y 10 cartas." end
    local seen={}
    for _,id in ipairs(deck) do
        if not Data.byId[id] then return false,"El mazo contiene una carta desconocida." end
        if seen[id] then return false,"Este mazo no permite cartas repetidas." end
        if unlocked and not unlocked[id] then return false,"El mazo contiene una carta bloqueada." end
        seen[id]=true
    end
    return true
end

function Cards.new(deck,context,rng)
    local ok,err=Cards.validateDeck(deck)
    assert(ok,err)
    local pile=copy(deck)
    rng=rng or (love and love.math and love.math.random) or math.random
    -- Fisher-Yates, each permutation equally likely with a uniform RNG.
    for i=#pile,2,-1 do
        local j=rng(i)
        pile[i],pile[j]=pile[j],pile[i]
    end
    local encounter={hand={},drawPile=pile,discard={},energy=4,turn=1,maxTurns=3,
                     score=0,finished=false,log={},context=context or {kind="conversation"}}
    for _=1,3 do encounter.hand[#encounter.hand+1]=table.remove(pile) end
    return encounter
end

function Cards.canPlay(enc,index)
    if enc.finished then return false,"El encuentro ya terminó." end
    if type(index)~="number" or index%1~=0 then return false,"Selecciona una carta de la mano." end
    local card=Data.byId[enc.hand[index]]
    if not card then return false,"Selecciona una carta de la mano." end
    if enc.energy<card.cost then return false,"No hay energía suficiente." end
    if card.revealsSecret and enc.context.curse and enc.context.curse.active
        and require("src.data.characters").byId[enc.context.character]
        and require("src.data.characters").byId[enc.context.character].romance then
        return false,"El encantamiento bloquea revelar deliberadamente el secreto mientras siga la maldición."
    end
    local conditions=card.conditions or {}
    if conditions.character and enc.context.character~=conditions.character then
        return false,"Esta carta necesita a "..conditions.character.." como acompañante."
    end
    if conditions.kind and enc.context.kind~=conditions.kind then
        return false,"Esta carta no se puede usar en este contexto."
    end
    return true
end

function Cards.preview(enc,index)
    local card=Data.byId[enc.hand[index]]
    if not card then return nil end
    local result={cardId=card.id,cost=card.cost,contextKind=enc.context.kind,score=0,trust=0,chemistry=0,
        base=delta(card.effects),contextBonus=delta(card.contexts[enc.context.kind]),
        affinityBonus=delta(card.affinities[enc.context.character]),targetAdjustment=delta()}
    local layers={result.base,result.contextBonus,result.affinityBonus}
    for _,layer in ipairs(layers) do
        for _,key in ipairs({"score","trust","chemistry"}) do result[key]=result[key]+(layer[key] or 0) end
    end
    local Collection=require("src.systems.card_collection")
    if not enc.context.legacyProgression then
        local scaled=Collection.socialEffects(card.id,Collection.level(enc.context.memory or enc.context,card.id),{love=result.chemistry,trust=result.trust})
        result.chemistry,result.trust=scaled.love,scaled.trust
    end
    result.phrase=Cards.phrase(card,enc.context)
    result.tone=card.tone
    result.expression=(result.trust<0 or result.chemistry<0) and "angry"
        or ((result.score>0 or result.chemistry>0) and "happy" or "worried")
    local reactions={
        roxy={happy="Gracias por tomar mi opinión en serio. Comparemos las ideas.",angry="Preferiría que atendieras a lo que intento explicarte.",worried="Todavía no has respondido a mi duda. Pensemos un momento."},
        sylphiette={happy="Así siento que compartimos la responsabilidad, Rudy.",angry="No quiero quedarme sola con lo que habíamos acordado.",worried="Me preocupa lo que estás dejando de lado. Necesito un acuerdo claro."},
        eris={happy="¡Eso quería oír! Cuenta conmigo y respeta mi parte.",angry="¡No decidas por mí! Puedo elegir cómo ayudarte.",worried="Dímelo con claridad. No quiero tener que adivinarlo."},
    }
    local response=reactions[enc.context.character]
    result.reaction=response and response[result.expression] or "La respuesta queda registrada. Sigamos con la prueba."
    if enc.context.character=="nanahoshi" then
        result.reaction=card.id=="subtle_flirt" and "Concéntrate, Rudeus. Estamos probando un artefacto, no en una cita."
            or "La voz se reproduce. El coste y la intención son correctos; recuerda que el contexto cambia la respuesta."
    end
    if not enc.context.character or not require("src.data.characters").byId[enc.context.character]
        or not require("src.data.characters").byId[enc.context.character].romance then
        result.targetAdjustment.trust=-result.trust; result.targetAdjustment.chemistry=-result.chemistry
        result.trust=0; result.chemistry=0
    end
    result.text=card.name..": "..Cards.signed(result.score).." avance"
    if enc.context.character and (result.trust~=0 or result.chemistry~=0) then
        result.text=result.text..", "..Cards.signed(result.trust).." confianza, "..Cards.signed(result.chemistry).." amor"
    end
    return result
end

function Cards.phrase(card,context)
    local phrases=card.phrases or {}
    return phrases[context.sceneId] or phrases[(context.character or "").."_"..(context.kind or "")]
        or phrases[context.character] or phrases[context.kind] or phrases.default or "Estoy aquí para escucharte."
end

local function finishAction(enc,result)
    enc.score=enc.score+result.score
    enc.log[#enc.log+1]=result
    enc.turn=enc.turn+1
    enc.finished=enc.turn>enc.maxTurns
    return result
end

function Cards.play(enc,index,expectedTurn)
    if expectedTurn and expectedTurn~=enc.turn then return nil,"Esta acción ya fue procesada." end
    local ok,err=Cards.canPlay(enc,index)
    if not ok then return nil,err end
    local result=Cards.preview(enc,index)
    local id=table.remove(enc.hand,index)
    enc.energy=enc.energy-Data.byId[id].cost
    enc.discard[#enc.discard+1]=id
    if #enc.drawPile>0 then result.drawnCard=table.remove(enc.drawPile); enc.hand[#enc.hand+1]=result.drawnCard end
    return finishAction(enc,result)
end

local function freeAction()
    return {cardId="pass",cost=0,score=0,trust=0,chemistry=0,
        text="Tomar un respiro: Rudy escucha sin interrumpir. Sin coste."}
end

function Cards.pass(enc,expectedTurn)
    if expectedTurn and expectedTurn~=enc.turn then return nil,"Esta acción ya fue procesada." end
    if enc.finished then return nil,"El encuentro ya terminó." end
    return finishAction(enc,freeAction())
end

-- A saved encounter must conserve the exact cards and action history. Invalid
-- snapshots are rejected rather than granting energy or duplicating cards.
-- El registro anterior se reproduce con las reglas que aceptaron sus cartas.
-- Capturarlas aquí evita que el filtro narrativo posterior invalide una acción
-- ya jugada; las acciones nuevas siguen pasando por Cards.canPlay/preview.
local replayLegacyCanPlay,replayLegacyPreview=Cards.canPlay,Cards.preview
function Cards.restore(snapshot,deck,context)
    if type(snapshot)~="table" then return nil end
    if not Cards.validateDeck(deck) then return nil end
    local counts={}
    for _,id in ipairs(deck) do counts[id]=1 end
    local enc={context=context or snapshot.context,hand={},drawPile={},discard={},log={}}
    if type(enc.context)~="table" then return nil end
    local total=0
    for _,zone in ipairs({"hand","drawPile","discard"}) do
        if type(snapshot[zone])~="table" then return nil end
        for _,id in ipairs(snapshot[zone]) do
            if counts[id]~=1 then return nil end
            counts[id]=0; total=total+1; enc[zone][#enc[zone]+1]=id
        end
    end
    if total~=#deck or #enc.hand<2 or #enc.hand>3 or #enc.discard>3 then return nil end
    if #enc.hand~=math.min(3,#deck-#enc.discard) then return nil end
    if type(snapshot.log)~="table" or #snapshot.log>3 then return nil end
    local energy,score,played=4,0,0
    for _,entry in ipairs(snapshot.log) do
        if type(entry)~="table" then return nil end
        local result
        if entry.cardId=="pass" then
            result=freeAction()
        else
            played=played+1
            if enc.discard[played]~=entry.cardId then return nil end
            local card=Data.byId[entry.cardId]
            if not card or energy<card.cost then return nil end
            local scratch={hand={entry.cardId},context=enc.context,finished=false,energy=energy}
            if not replayLegacyCanPlay(scratch,1) then return nil end
            result=replayLegacyPreview(scratch,1)
            energy=energy-card.cost
        end
        score=score+result.score
        enc.log[#enc.log+1]=result
    end
    if played~=#enc.discard then return nil end
    enc.energy=energy; enc.score=score; enc.turn=#enc.log+1
    enc.maxTurns=3; enc.finished=enc.turn>3
    return enc
end

-- La compatibilidad numérica anterior se conserva para herramientas y snapshots
-- v3 previos. Todos los encuentros jugables están cubiertos por el catálogo.
local legacyNew,legacyPreview,legacyCanPlay=Cards.new,Cards.preview,Cards.canPlay
local legacyPlay,legacyPass,legacyRestore=Cards.play,Cards.pass,Cards.restore
local Resolver=require("src.systems.dialogue_resolver")
local Memory=require("src.systems.dialogue_memory")
local Relationships=require("src.systems.relationships")
local Affinity=require("src.systems.affinity")
local function filtered(deck,context)
    local allowed,reserve={},{}
    for _,id in ipairs(deck) do
        local target=Resolver.compatible(Data.byId[id],context) and allowed or reserve
        target[#target+1]=id
    end
    return allowed,reserve
end
local function fromOrder(deck,context,order)
    local allowed,reserve=filtered(deck,context)
    local present={}; for _,id in ipairs(allowed) do present[id]=true end
    if #allowed~=#order then return nil end
    for _,id in ipairs(order) do if not present[id] then return nil end; present[id]=nil end
    local enc={narrativeVersion=1,affinityVersion=context.affinityDisabled and 0 or 1,context=context,initialMemory=Memory.capture(context.memory),
        memory=Memory.capture(context.memory),initialOrder=copy(order),reserve=reserve,
        hand={},drawPile=copy(order),discard={},energy=4,turn=1,maxTurns=3,score=0,finished=false,log={},reactionIndex=1}
    for _=1,math.min(3,#enc.drawPile) do enc.hand[#enc.hand+1]=table.remove(enc.drawPile) end
    enc.notice=#allowed<3 and "Tu mazo tiene menos de tres respuestas compatibles. Puedes escuchar sin gastar energía; prepara el mazo antes de otra conversación." or nil
    return enc
end
function Cards.new(deck,context,rng)
    if not Resolver.node(context) then return legacyNew(deck,context,rng) end
    local valid,err=Cards.validateDeck(deck,context.unlocked); assert(valid,err)
    local order=filtered(deck,context)
    rng=rng or (love and love.math and love.math.random) or math.random
    for i=#order,2,-1 do local j=rng(i); order[i],order[j]=order[j],order[i] end
    return assert(fromOrder(deck,context,order))
end
function Cards.canPlay(enc,index)
    if Resolver.node(enc.context) then
        local valid,reason=Resolver.compatible(Data.byId[enc.hand[index]],enc.context)
        if not valid then return false,reason end
    end
    return legacyCanPlay(enc,index)
end
function Cards.preview(enc,index)
    if not Resolver.node(enc.context) then return legacyPreview(enc,index) end
    local card=Data.byId[enc.hand[index]]
    if not card then return nil end
    local result=Resolver.resolve(enc.context,card.id,enc.memory)
    if not result then return nil end
    result.progressionVersion=enc.context.legacyProgression and 0 or 1
    result.familyVersion=enc.memory and enc.memory.legacyAffinity and 0 or 1
    if enc.context.legacyEffects then
        local previous=legacyPreview(enc,index)
        previous.phrase,previous.reaction,previous.expression=result.phrase,result.reaction,result.expression
        return previous
    end
    result.cost=card.cost; result.contextKind=enc.context.kind
    result.base={score=result.score,trust=result.trust,chemistry=result.chemistry}
    result.contextBonus=delta(); result.affinityBonus=delta(); result.targetAdjustment=delta()
    local state=enc.memory or enc.context.memory or {}
    local actual=result.affinityTarget and Affinity.preview(state,result.character,result)
        or require("src.systems.relationship_budget").preview(state,result.character,result)
    result.projectedLove,result.projectedTrust=actual.love or 0,actual.trust
    result.projectedInterest=actual.interest or 0
    if result.affinityTarget then result.affinityBefore,result.affinityAfter=actual.before,actual.after end
    result.text=card.name..": "..Cards.describe(result)
    return result
end
function Cards.play(enc,index,expectedTurn)
    local turn=enc.turn
    local result,err=legacyPlay(enc,index,expectedTurn)
    if result and enc.narrativeVersion then
        result.actionTurn=turn; result.applied=false
        Memory.commit(enc.memory,Memory.copy(result),enc.context.sceneId,turn)
        enc.reactionIndex=1
    end
    return result,err
end
function Cards.pass(enc,expectedTurn)
    if not enc.narrativeVersion then return legacyPass(enc,expectedTurn) end
    if expectedTurn and expectedTurn~=enc.turn then return nil,"Esta acción ya fue procesada." end
    if enc.finished then return nil,"El encuentro ya terminó." end
    local result=assert(Resolver.resolve(enc.context,"pass",enc.memory))
    result.progressionVersion=enc.context.legacyProgression and 0 or 1
    result.familyVersion=enc.memory and enc.memory.legacyAffinity and 0 or 1
    result.cost=0; result.actionTurn=enc.turn; result.applied=false
    local actual=result.affinityTarget and Affinity.preview(enc.memory,result.character,result)
        or require("src.systems.relationship_budget").preview(enc.memory,result.character,result)
    result.projectedLove,result.projectedTrust=actual.love or 0,actual.trust
    result.projectedInterest=actual.interest or 0
    if result.affinityTarget then result.affinityBefore,result.affinityAfter=actual.before,actual.after end
    result.text="Escuchar en silencio: "..result.reaction
    Memory.commit(enc.memory,Memory.copy(result),enc.context.sceneId,enc.turn)
    enc.reactionIndex=1
    return finishAction(enc,result)
end
local function sameList(a,b)
    if type(a)~="table" or #a~=#b then return false end
    for i,id in ipairs(b) do if a[i]~=id then return false end end
    return true
end
function Cards.restore(snapshot,deck,context)
    if type(snapshot)~="table" then return nil end
    if not snapshot.narrativeVersion then
        -- Replay histórico con sus deltas originales. Las nuevas frases se
        -- mostrarán al siguiente encuentro; no se conceden premios retroactivos.
        local compatible=Memory.copy(context or snapshot.context)
        if Resolver.node(compatible) then compatible.legacyEffects=true end
        return legacyRestore(snapshot,deck,compatible)
    end
    if snapshot.narrativeVersion~=1 or not Cards.validateDeck(deck,context and context.unlocked) or not Resolver.node(context) then return nil end
    if type(snapshot.initialOrder)~="table" or type(snapshot.initialMemory)~="table" or type(snapshot.log)~="table" or #snapshot.log>3 then return nil end
    local replayContext=Memory.copy(context)
    -- Los snapshots anteriores a la afinidad conservan sus deltas originales.
    -- La siguiente conversación nueva sí usa el sistema de confianza e interés.
    if snapshot.affinityVersion~=1 then replayContext.affinityDisabled=true end
    replayContext.memory=Memory.capture(snapshot.initialMemory)
    local enc=fromOrder(deck,replayContext,snapshot.initialOrder)
    if not enc then return nil end
    local migrated=false
    for turn,entry in ipairs(snapshot.log) do
        if type(entry)~="table" then return nil end
        enc.context.legacyProgression=entry.progressionVersion~=1
        enc.memory.legacyBudget=enc.context.legacyProgression
        enc.memory.legacyAffinity=entry.familyVersion~=1
        migrated=migrated or enc.context.legacyProgression or enc.memory.legacyAffinity
        local result
        if entry.cardId=="pass" then result=Cards.pass(enc)
        else
            local index; for i,id in ipairs(enc.hand) do if id==entry.cardId then index=i;break end end
            if not index or not Cards.canPlay(enc,index) then return nil end
            result=Cards.play(enc,index)
        end
        if not result or result.responseId~=entry.responseId then return nil end
        local applied=(context.memory.events or {})[Memory.key(context.sceneId,turn)]==true
        result.applied=applied
        if applied then
            -- El replay local conserva los deltas efectivos, incluso en 0/100.
            result.actualLove=result.projectedLove or 0
            result.actualTrust=result.projectedTrust or 0
            result.actualInterest=result.projectedInterest or 0
        end
    end
    enc.context.legacyProgression=nil;enc.memory.legacyBudget=nil;enc.memory.legacyAffinity=nil
    if migrated then
        -- Preserve historical responses, then use today's levels and budget for
        -- every new action. Pending reactions are still committed only once.
        enc.memory=Memory.capture(context.memory)
        for turn,result in ipairs(enc.log) do
            if not result.applied then
                result.familyVersion=1
                local actual=result.affinityTarget and Affinity.preview(enc.memory,result.character,result)
                    or require("src.systems.relationship_budget").preview(enc.memory,result.character,result)
                result.projectedLove,result.projectedTrust=actual.love or 0,actual.trust
                Memory.commit(enc.memory,Memory.copy(result),context.sceneId,turn)
            end
        end
    end
    for _,zone in ipairs({"hand","drawPile","discard","reserve"}) do if not sameList(snapshot[zone],enc[zone]) then return nil end end
    if snapshot.energy~=enc.energy or snapshot.score~=enc.score or snapshot.turn~=enc.turn then return nil end
    local sequence=enc.log[#enc.log] and enc.log[#enc.log].sequence or {}
    local index=tonumber(snapshot.reactionIndex) or 1
    enc.reactionIndex=math.max(1,math.min(math.max(1,#sequence),math.floor(index)))
    return enc
end
return Cards
