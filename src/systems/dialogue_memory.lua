local Relationships=require("src.systems.relationships")
local Events=require("src.systems.events")
local Affinity=require("src.systems.affinity")
local Memory={}
local function copy(value)
    if type(value)~="table" then return value end
    local out={}; for k,v in pairs(value) do out[k]=copy(v) end; return out
end
Memory.copy=copy
local function map(value)
    local out={}
    for key,v in pairs(type(value)=="table" and value or {}) do
        if type(key)=="string" and #key<=150 and (type(v)=="boolean" or type(v)=="string" or (type(v)=="number" and v==v and math.abs(v)<100000)) then out[key]=v end
    end
    return out
end
function Memory.capture(session)
    session=session or {}
    local out={day=session.day or 1,checkpoint=session.checkpoint,relationships=Relationships.new(),affinities=Affinity.normalize(session.affinities),
        events=map(session.events),decisions=map(session.decisions),unlocked=map(session.unlocked),
        curse=copy(session.curse or {}),selectedCompanion=session.selectedCompanion,
        dialogueMemory={used=map(session.dialogueMemory and session.dialogueMemory.used)}}
    for id,r in pairs(out.relationships) do
        local value=(session.relationships or {})[id] or r
        for _,key in ipairs({"love","trust"}) do
            local n=value[key]; if type(n)=="number" and n==n then r[key]=math.max(0,math.min(100,n)) end
        end
        for _,key in ipairs({"events","decisions","criticalDecisions","promises","brokenPromises","sharedMoments","pendingConflicts","reconciliations"}) do r[key]=map(value[key]) end
        r.personalEvents=r.events
        if value.marriageState=="separated" then r.marriageState="separated" end
        Relationships.refresh(r)
    end
    return out
end
function Memory.key(scene,turn) return "social_"..scene.."_"..turn end
function Memory.commit(session,result,scene,turn)
    local key=Memory.key(scene,turn)
    session.events=session.events or {}
    if session.events[key] then return false end
    local effect=copy(result.narrativeEffects or {})
    effect.character=result.character
    effect.love=result.chemistry or 0; effect.trust=result.trust or 0
    local affinity=Affinity.config[result.character]~=nil
    if affinity then effect.love,effect.trust=0,0 end
    effect.decision="dialogue_"..scene; effect.value=result.nextNode or result.responseId or "pause"
    effect.context="social_card"; effect.text=(result.phrase~="" and result.phrase) or "Rudy escucha en silencio."
    -- Las flags de conversación son eventos consultables, no nuevas identidades.
    effect.batch={}
    for _,flag in ipairs(result.flags or {}) do
        effect.batch[#effect.batch+1]={decision=flag,value=true,text=effect.text}
    end
    local delta=affinity and Affinity.preview(session,result.character,result) or Relationships.preview(session.relationships,result.character,effect)
    local applied,err=Events.apply(session,key,effect)
    if not applied then return false,err end
    if affinity then
        local _,actual=Affinity.apply(session,result.character,result,key)
        delta=actual
        result.affinityTarget=result.character
        result.actualInterest=delta.interest or 0
        result.affinityBefore,result.affinityAfter=delta.before,delta.after
    end
    for _,flag in ipairs(result.flags or {}) do session.events[flag]=true end
    session.decisions[key]=result.cardId
    session.dialogueMemory=session.dialogueMemory or {used={}}
    local used=session.dialogueMemory.used
    if result.responseId then used[result.responseId]=(tonumber(used[result.responseId]) or 0)+1 end
    result.actualLove,result.actualTrust=delta.love or 0,delta.trust or 0
    result.applied=true
    return true
end
return Memory
