local Characters = require("src.data.characters")
local Relationships = {}
local function clamp(n) return math.max(0,math.min(10,n)) end

function Relationships.new()
    local all = {}
    for _, id in ipairs(Characters.romanceIds) do
        all[id]={trust=0,chemistry=0,events={},routeState="unmet",decisions={}}
    end
    return all
end

function Relationships.apply(all,id,delta)
    local relationship = all[id]
    if not relationship then return end
    relationship.trust=clamp(relationship.trust+(delta.trust or 0))
    relationship.chemistry=clamp(relationship.chemistry+(delta.chemistry or 0))
end

function Relationships.complete(all,id,event)
    if not all[id] then return end
    all[id].events[event]=true
    if all[id].routeState=="unmet" then all[id].routeState="friend" end
end

function Relationships.canRomance(all,id,decisions)
    local r=all[id]
    if not r then return false end
    return r.trust>=6 and r.chemistry>=5 and r.events.route_conflict==true
        and r.events.mirror_truth==true and decisions.confession==id
end

function Relationships.ending(all,route,decisions)
    if not route or not all[route] then return "independent" end
    if Relationships.canRomance(all,route,decisions or {}) then return "romance_"..route end
    return "friendship_"..route
end

return Relationships
