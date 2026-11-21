local Relationships=require("src.systems.relationships")
local Characters=require("src.data.characters")
local Budget={limit=10}
function Budget.ensure(session)
    if session.daily and session.daily.day~=session.day then require("src.systems.daily").ensure(session) end
    local holder=session.daily and session.daily.day==session.day and session.daily or session
    holder.relationship_gains=holder.relationship_gains or {}
    for _,id in ipairs(Characters.romanceIds) do holder.relationship_gains[id]=holder.relationship_gains[id] or {love=0,trust=0} end
    return holder.relationship_gains
end
function Budget.preview(session,id,effect)
    local gains=Budget.ensure(session)[id]
    local allowed={love=effect.love or effect.chemistry or 0,trust=effect.trust or 0}
    if gains and not session.legacyBudget then
        for _,key in ipairs({"love","trust"}) do
            if allowed[key]>0 then allowed[key]=math.min(allowed[key],math.max(0,Budget.limit-gains[key])) end
        end
    end
    return Relationships.preview(session.relationships or {},id,allowed)
end
function Budget.commit(session,id,effect)
    local delta=Budget.preview(session,id,effect)
    local gains=Budget.ensure(session)[id]
    if gains then for _,key in ipairs({"love","trust"}) do gains[key]=math.min(Budget.limit,gains[key]+math.max(0,delta[key])) end end
    return delta
end
return Budget
