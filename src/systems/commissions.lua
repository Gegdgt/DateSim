local W=require("src.systems.world_content")
local C={}
function C.prepare(s,def,key)
    local seed=W.ensure(s).seed
    local roll=W.hash(seed,"commission:"..key)%100+1
    local option=W.hash(seed,"reward:"..key)%#def.outcomes+1
    return {cost=def.cost,chance=def.chance,roll=roll,success=roll<=def.chance,
        refund=def.refund,reward=W.copy(def.outcomes[option]),investment=true}
end
function C.effect(favor)
    return favor.success and W.copy(favor.reward) or {gold=favor.refund}
end
function C.result(favor)
    if favor.status=="pending" then return "Pendiente. Entrega el día "..favor.due_day.."." end
    if favor.success then
        local parts={};local e=favor.reward
        if e.gold then parts[#parts+1]=e.gold.." oro" end
        for id,n in pairs(e.items or {}) do parts[#parts+1]=n.." "..require("src.data.economy").items[id].name end
        for id,n in pairs(e.copies or {}) do parts[#parts+1]=n.." copias de "..require("src.systems.card_collection").byId[id].name end
        table.sort(parts)
        return "ÉXITO: "..table.concat(parts,", ")..". Entrega registrada."
    end
    return "FRACASO: la prueba no dio resultado. Invertiste "..favor.cost.." oro; recuperas "..favor.refund..". Pérdida: "..(favor.cost-favor.refund).." oro."
end
function C.validate(s,favor)
    local function int(n,a,b) return type(n)=="number" and n%1==0 and n>=a and n<=b end
    local receipt=s.economy.transactions[favor.receipt_id]
    return favor.investment==true and int(favor.cost,1,100000) and int(favor.chance,0,100) and int(favor.roll,1,100)
        and favor.success==(favor.roll<=favor.chance) and int(favor.refund,0,favor.cost-1)
        and W.validReward(favor.reward) and receipt and receipt.gold==-favor.cost and receipt.day==favor.requested_day
        and receipt.kind=="commission_"..favor.id
end
return C
