local Characters = require("src.data.characters")
local Relationships = {defaults={love=65,trust=65}, thresholds={maintain=55,united=75}}

local function finite(n, fallback)
    if type(n)~="number" or n~=n or math.abs(n)==math.huge then return fallback or 0 end
    return n
end
local function clamp(n) return math.max(0,math.min(100,finite(n))) end
local function empty(t) return not t or next(t)==nil end

function Relationships.new(config)
    config=config or Relationships.defaults
    local all={}
    for _,id in ipairs(Characters.romanceIds) do
        local personal={}
        all[id]={love=clamp(finite(config.love,65)),trust=clamp(finite(config.trust,65)),
            chemistry=clamp(finite(config.love,65)),events=personal,personalEvents=personal,
            decisions={},criticalDecisions={},promises={},brokenPromises={},sharedMoments={},
            pendingConflicts={},reconciliations={},history={},marriageState="married",routeState="married"}
    end
    return all
end

function Relationships.refresh(r)
    r.chemistry=r.love -- Compatibility with the original social-card renderer.
    if r.marriageState~="separated" then
        r.marriageState=(r.love<55 or r.trust<55 or not empty(r.pendingConflicts)) and "strained" or "married"
    end
    r.routeState=r.marriageState
end

function Relationships.apply(all,id,delta)
    local r=all[id]
    if not r then return end
    delta=delta or {}
    r.love=clamp(r.love+finite(delta.love~=nil and delta.love or delta.chemistry))
    r.trust=clamp(r.trust+finite(delta.trust))
    Relationships.refresh(r)
end

function Relationships.preview(all,id,delta)
    local r=all[id]
    if not r then return {love=0,trust=0,chemistry=0} end
    delta=delta or {}
    local love=clamp(r.love+finite(delta.love~=nil and delta.love or delta.chemistry))-r.love
    return {love=love,chemistry=love,trust=clamp(r.trust+finite(delta.trust))-r.trust}
end

function Relationships.complete(all,id,event)
    if not all[id] or type(event)~="string" then return end
    all[id].events[event]=true
    all[id].personalEvents=all[id].events
end

-- A number alone never separates a couple. Broken commitments remain in the
-- record even after an explicit reconciliation repairs the ongoing conflict.
function Relationships.record(all,id,effect,eventId,day)
    local r=all[id]
    if not r then return end
    local before=Relationships.preview(all,id,effect)
    Relationships.apply(all,id,effect)
    if effect.relationshipEvent then Relationships.complete(all,id,effect.relationshipEvent) end
    if effect.decision then r.decisions[effect.decision]=effect.value end
    if effect.critical then r.criticalDecisions[effect.critical.id]=effect.critical.value end
    for _,flag in ipairs(effect.flags or {}) do r.criticalDecisions[flag]=true end
    if effect.promise then
        local p=effect.promise
        local previous=r.promises[p.id]
        if p.status~="pending" or previous==nil then r.promises[p.id]=p.status end
        if p.status=="broken" then r.brokenPromises[p.id]=true; r.pendingConflicts[p.id]=true end
    end
    if effect.conflict then r.pendingConflicts[effect.conflict]=true end
    if effect.reconcile then
        r.pendingConflicts[effect.reconcile]=nil
        r.reconciliations[effect.reconcile]=true
        if r.promises[effect.reconcile]=="broken" then r.promises[effect.reconcile]="reconciled" end
    end
    if effect.sharedMoment then r.sharedMoments[effect.sharedMoment]=true end
    if effect.marriageState=="separated" then r.marriageState="separated" end
    Relationships.refresh(r)
    r.history[#r.history+1]={id=eventId,day=day,love=before.love,trust=before.trust,
        choice=effect.decision,value=effect.value,context=effect.context or "story",
        conflict=effect.conflict,reconcile=effect.reconcile,promise=effect.promise and effect.promise.id,
        promiseStatus=effect.promise and effect.promise.status,marriageState=r.marriageState}
end

function Relationships.canMaintain(all,id)
    local r=all[id]
    if not r or r.marriageState=="separated" then return false,"separated" end
    if r.love<Relationships.thresholds.maintain or r.trust<Relationships.thresholds.maintain then return false,"distance" end
    if not r.events.personal_resolution then return false,"personal_event" end
    if r.criticalDecisions.commitment~=true then return false,"commitment" end
    if not empty(r.pendingConflicts) then return false,"conflicts" end
    for promise in pairs(r.brokenPromises) do
        if not r.reconciliations[promise] then return false,"broken_promise" end
    end
    return true
end

function Relationships.viable(all)
    local list={}
    for _,id in ipairs(Characters.romanceIds) do
        if Relationships.canMaintain(all,id) then list[#list+1]=id end
    end
    return list
end

function Relationships.canUnite(all)
    for _,id in ipairs(Characters.romanceIds) do
        local r=all[id]
        if not Relationships.canMaintain(all,id) or r.love<Relationships.thresholds.united
            or r.trust<Relationships.thresholds.united then return false end
    end
    return true
end

-- Exactly five principal endings. An unresolved pair is an intermediate
-- conversation, never a sixth ending and never a silent forced separation.
function Relationships.ending(all)
    if Relationships.canUnite(all) then return "family_united" end
    local viable=Relationships.viable(all)
    if #viable==0 then return "solitary" end
    if #viable==1 then return viable[1] end
    return nil,"resolution_required",viable
end

function Relationships.canRomance(all,id) return Relationships.canMaintain(all,id) end
return Relationships
