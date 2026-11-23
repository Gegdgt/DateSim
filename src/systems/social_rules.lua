local Data=require("src.data.cards")
local Config=require("src.data.social_rules")
local Rules={energy=Config.energy,maxCards=Config.maxCards}
function Rules.cost(id,target)
    local card=assert(Data.byId[id]);local affinity=(card.target_affinity or {})[target]
    return affinity and affinity.cost or math.max(1,math.min(3,card.cost))
end
function Rules.effects(s,id,target,response,context)
    local card=Data.byId[id];local affinity=(card.target_affinity or {})[target] or {}
    local factor=1+math.floor((require("src.systems.card_collection").level(s,id)-1)/2)
    local out={love=response.love or 0,trust=response.trust or 0}
    -- Una afinidad nunca convierte una respuesta inapropiada en una positiva.
    for _,key in ipairs({"love","trust"}) do
        if out[key]>0 then out[key]=(affinity[key] or out[key])*factor end
    end
    for _,rule in ipairs(response.context_modifiers or {}) do
        local matches=(not rule.emotion or rule.emotion==context.emotion)
            and (not rule.after or rule.after==context.previousCard)
            and (not rule.requires or require("src.systems.conditions").evaluate(s,rule.requires))
        if matches then for _,key in ipairs({"love","trust"}) do out[key]=out[key]+(rule[key] or 0) end end
    end
    return out
end
return Rules
