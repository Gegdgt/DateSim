local Data = require("src.data.cards")
local Cards = {}

local function copy(list)
    local out={}
    for i,v in ipairs(list) do out[i]=v end
    return out
end

function Cards.validateDeck(deck,unlocked)
    if type(deck)~="table" or #deck~=10 then return false,"El mazo debe tener exactamente 10 cartas." end
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
    local result={cardId=card.id,score=0,trust=0,chemistry=0}
    local layers={card.effects,card.contexts[enc.context.kind] or {},card.affinities[enc.context.character] or {}}
    for _,layer in ipairs(layers) do
        for _,key in ipairs({"score","trust","chemistry"}) do result[key]=result[key]+(layer[key] or 0) end
    end
    if not enc.context.character or not require("src.data.characters").byId[enc.context.character]
        or not require("src.data.characters").byId[enc.context.character].romance then
        result.trust=0; result.chemistry=0
    end
    result.text=card.name..": +"..result.score.." avance"
    if enc.context.character and (result.trust~=0 or result.chemistry~=0) then
        result.text=result.text..", +"..result.trust.." confianza, +"..result.chemistry.." química"
    end
    return result
end

local function finishAction(enc,result)
    enc.score=enc.score+result.score
    enc.log[#enc.log+1]=result
    enc.turn=enc.turn+1
    enc.finished=enc.turn>enc.maxTurns
    return result
end

function Cards.play(enc,index)
    local ok,err=Cards.canPlay(enc,index)
    if not ok then return nil,err end
    local result=Cards.preview(enc,index)
    local id=table.remove(enc.hand,index)
    enc.energy=enc.energy-Data.byId[id].cost
    enc.discard[#enc.discard+1]=id
    if #enc.drawPile>0 then enc.hand[#enc.hand+1]=table.remove(enc.drawPile) end
    return finishAction(enc,result)
end

local function freeAction()
    return {cardId="pass",score=0,trust=0,chemistry=0,
        text="Tomar un respiro: Rudy escucha y deja que el maná se calme. Sin coste."}
end

function Cards.pass(enc)
    if enc.finished then return nil,"El encuentro ya terminó." end
    return finishAction(enc,freeAction())
end

-- A saved encounter must conserve the exact cards and action history. Invalid
-- snapshots are rejected rather than granting energy or duplicating cards.
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
    if total~=10 or #enc.hand~=3 or #enc.discard>3 then return nil end
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
            if not Cards.canPlay(scratch,1) then return nil end
            result=Cards.preview(scratch,1)
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

return Cards
