local Catalog=require("src.data.dialogue")
local Conditions=require("src.systems.conditions")
local Memory=require("src.systems.dialogue_memory")
local Data=require("src.data.cards")
local Affinity=require("src.systems.affinity")
local Resolver={}
function Resolver.node(context)
    local id=context and Catalog.encounters[context.sceneId]
    return id and Catalog.nodes[id]
end
function Resolver.compatible(card,context)
    local node=Resolver.node(context)
    if not node then return false,"Esta escena no tiene una conversación escrita." end
    if not card or not node.cards[card.id] then return false,"Esta carta no tiene una respuesta escrita para esta conversación." end
    if context.unlocked and not context.unlocked[card.id] then return false,"La carta todavía está bloqueada." end
    local c=card.conditions or {}
    if c.character and c.character~=node.character then return false,"Esta carta necesita a otra compañera." end
    if c.kind and c.kind~=context.kind then return false,"La intención no es compatible con este encuentro." end
    return true
end
local function chosen(base,state)
    local best,priority,uses=nil,-math.huge,math.huge
    for _,variant in ipairs(base.variants or {}) do
        if Conditions.evaluate(state,variant.requires,{companion=state.selectedCompanion}) then
            local p=variant.priority or 0
            local n=tonumber(((state.dialogueMemory or {}).used or {})[variant.id]) or 0
            if p>priority or (p==priority and n<uses) then best,priority,uses=variant,p,n end
        end
    end
    local out=Memory.copy(base)
    for key,value in pairs(best or {}) do if key~="requires" and key~="priority" then out[key]=Memory.copy(value) end end
    return out
end
function Resolver.resolve(context,cardId,state)
    local node=Resolver.node(context)
    if not node then return nil end
    local base=cardId=="pass" and node.fallback or node.cards[cardId]
    if not base then return nil end
    state=state or context.memory or Memory.capture()
    local response=chosen(base,state)
    local effect=response.effects or {}
    -- La afinidad de investigación de Nanahoshi conserva sus reglas propias.
    if not context.legacyProgression and Data.byId[cardId] and not Affinity.config[node.character] then effect=require("src.systems.card_collection").socialEffects(cardId,
        require("src.systems.card_collection").level(state,cardId),effect) end
    local result={cardId=cardId,character=node.character,conversationId=node.id,responseId=response.id,
        phrase=response.rudy,reaction=response.response,expression=response.expression or "neutral",animation=response.animation,
        score=effect.score or 0,trust=effect.trust or 0,chemistry=effect.love or 0,interest=effect.interest or 0,
        nextNode=response.next,flags=Memory.copy(response.flags or {}),narrativeEffects={},sequence={},tone=Data.byId[cardId] and Data.byId[cardId].tone}
    if Affinity.config[node.character] then
        local sanitized=Affinity.sanitize(node.character,result)
        result.trust,result.interest,result.chemistry=sanitized.trust,sanitized.interest,0
        if context.affinityDisabled then result.trust,result.interest=0,0; result.affinitySuppressed=true end
        result.affinityTarget=node.character
    else result.interest=0 end
    for _,key in ipairs({"promise","conflict","reconcile","sharedMoment","critical","relationshipEvent"}) do result.narrativeEffects[key]=Memory.copy(response[key]) end
    if response.rudy and response.rudy~="" then
        result.sequence[#result.sequence+1]={speaker="rudeus",delivery=cardId=="pass" and "note" or "enchanted",expression="neutral",text=response.rudy}
    end
    result.sequence[#result.sequence+1]={speaker=node.character,expression=result.expression,animation=result.animation,text=response.response,apply=true}
    local visited={}; local nextId=response.next
    while nextId do
        assert(not visited[nextId],"Ciclo de continuación: "..nextId); visited[nextId]=true
        local nextNode=assert(Catalog.nodes[nextId],"Continuación desconocida: "..nextId)
        result.sequence[#result.sequence+1]={speaker=nextNode.character,expression=nextNode.expression or "neutral",text=nextNode.text}
        for _,line in ipairs(nextNode.lines or {}) do result.sequence[#result.sequence+1]=Memory.copy(line) end
        nextId=nextNode.next
    end
    return result
end
function Resolver.context(session,definition,sceneId)
    return {kind=definition.kind,character=definition.character,sceneId=sceneId or session.checkpoint,
        curse=Memory.copy(session.curse),unlocked=Memory.copy(session.unlocked),memory=Memory.capture(session)}
end
return Resolver
