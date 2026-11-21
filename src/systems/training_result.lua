local Training=require("src.systems.training")
local Dialogue=require("src.data.training_dialogue")
local Events=require("src.systems.events")
local Relationships=require("src.systems.relationships")
local Result={}
local function copy(value)
 if type(value)~="table" then return value end
 local out={};for k,v in pairs(value) do out[k]=copy(v) end;return out
end
function Result.key(checkpoint) return "training_result_"..checkpoint end
function Result.current(session,enc)
 if not enc or session.combat~=enc then return nil end
 local node=require("src.data.chapters").get(session.checkpoint)
 if not node or not node.definition.training then return nil end
 return Training.evaluate(enc)
end
function Result.commit(session,enc)
 local result=Result.current(session,enc)
 if not result then return nil,"El entrenamiento todavía no tiene un resultado válido." end
 local cp=session.checkpoint;local key=Result.key(cp)
 session.trainingResults=session.trainingResults or {}
 if session.events[key] then return session.trainingResults[cp],false end
 local before=require("src.systems.relationship_budget").preview(session,"eris",{love=result.love,trust=result.trust})
 local record=copy(result)
 record.actualLove,record.actualTrust=before.love,before.trust
 record.checkpoint=cp
 local effect={character="eris",love=result.love,trust=result.trust,
  gold=require("src.data.economy").rewards.training,copies={staff_strike=3},
  context="training",decision=cp=="day5_eris_duel" and "eris_training_result" or "eris_training_last_result",value=result.id,
  text=Dialogue[result.id].effort..": "..result.reason,
  relationshipEvent=result.eventId,sharedMoment="training_"..cp}
 if result.id=="suspected_throw" then effect.conflict="training_effort" end
 if cp=="day6_eris_rematch" and (result.id=="victory" or result.id=="honorable_defeat")
  and (session.decisions.eris_training_followup=="apologized" or session.events.eris_duel_apology_heard) then
  effect.reconcile="training_effort"
 end
 if not Events.apply(session,key,effect) then return session.trainingResults[cp],false end
 require("src.systems.finale").recordTraining(session,cp)
 -- Ambos resultados quedan en el historial; una revancha no borra el primero.
 Events.mark(session,result.eventId)
 session.decisions.eris_training_last_result=result.id
 if effect.reconcile then Events.mark(session,"eris_training_reconciled") end
 session.trainingResults[cp]=record
 return record,true
end
function Result.normalize(records,events)
 local out={}
 for _,cp in ipairs({"day5_eris_duel","day6_eris_rematch"}) do
  local r=type(records)=="table" and records[cp]
  if type(r)=="table" and events[Result.key(cp)] and Dialogue[r.id] then
   local clean={id=r.id,eventId=Dialogue[r.id].eventId,checkpoint=cp,
    winner=r.id=="victory" and "rudeus" or "eris",nonlethal=true,metrics={}}
   for _,key in ipairs({"love","trust","actualLove","actualTrust"}) do
    local v=r[key];clean[key]=type(v)=="number" and v==v and math.abs(v)<=100 and v or 0
   end
   clean.reason=type(r.reason)=="string" and r.reason:sub(1,800) or "Resultado guardado."
   for k,v in pairs(type(r.metrics)=="table" and r.metrics or {}) do
    if type(k)=="string" and #k<60 and type(v)=="number" and v==v and v>=0 and v<=100000 then clean.metrics[k]=v end
   end
   clean.metrics.winner=clean.winner
   out[cp]=clean
  end
 end
 return out
end
return Result
