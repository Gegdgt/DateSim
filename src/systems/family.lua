local Config=require("src.data.family")
local Family={}
function Family.ensure(session)
 session.family=session.family or {progress={},warnings={},neglect={},departures={},queue={},seen={},books={},discounts=0}
 return session.family
end
function Family.active(session,id)
 return session.relationships[id] and session.relationships[id].marriageState~="separated"
end
function Family.notice(session,key,id,text,expression,reply)
 local f=Family.ensure(session)
 if f.seen[key] then return end
 f.seen[key]=true
 f.queue[#f.queue+1]={id=key,character=id,kind="notice",phase=1,elapsed=0,
  expression=expression or "worried",lines={text,reply or "Rudy registra el compromiso. La próxima jornada mostrará si lo cumple."}}
end
function Family.depart(session,id,reason)
 local f=Family.ensure(session)
 if f.departures[id] then return end
 f.departures[id]={day=session.day,reason=reason or "critical_decision",permanent=true}
 session.relationships[id].marriageState="separated";session.relationships[id].routeState="separated"
 session.decisions["separated_"..id]=true
 f.queue[#f.queue+1]={id="departure_"..id,character=id,kind="departure",phase=1,elapsed=0}
end
function Family.applyEffects(session,effect)
 local f=Family.ensure(session)
 for id,value in pairs(effect.familyProgress or {}) do f.progress[id]=(f.progress[id] or 0)+value end
 for id,value in pairs(effect.items or {}) do
  local e=require("src.systems.economy").ensure(session);e.items[id]=(e.items[id] or 0)+value
 end
 if effect.discount then f.discounts=math.min(21,f.discounts+effect.discount) end
 if effect.book then f.books[effect.book]=true end
 if effect.promise and effect.promise.id=="family_errand" then
  if effect.promise.status=="pending" and session.relationships.sylphiette.promises.family_errand==nil then
   f.commitmentDue=math.min(7,session.day+1)
  elseif effect.promise.status~="pending" then f.commitmentDue=nil end
 end
 if effect.marriageState=="separated" and session.relationships[effect.character] then Family.depart(session,effect.character,effect.context or "critical_decision") end
end
function Family.resolveCommitments(session)
 local f=Family.ensure(session)
 if f.commitmentDue and f.commitmentDue<=session.day and Family.active(session,"sylphiette") then
  require("src.systems.events").apply(session,"family_errand_due",{character="sylphiette",love=-3,trust=-5,
   promise={id="family_errand",status="broken"},context="daily",text="El recado prometido quedó pendiente: -3 amor / -5 confianza. Se puede reparar cumpliéndolo."})
  Family.notice(session,"family_errand_warning","sylphiette","Nuestra hija esperaba ese recado. Prefiero que elijas un momento que puedas cumplir; todavía puedes hacerte cargo.","worried")
  f.commitmentDue=nil
 end
end
function Family.attention(session,id,visited)
 local f=Family.ensure(session);local Events=require("src.systems.events")
 local key="day"..session.day.."_attention_"..id
 if session.events[key] or not Family.active(session,id) then return end
 if visited then
  Events.apply(session,key,{character=id,trust=1,context="daily",text="Tiempo compartido durante la jornada."})
 else
  local earlier=f.warnings[id] and f.warnings[id].day<session.day
  f.neglect[id]=(f.neglect[id] or 0)+1
  Events.apply(session,key,{character=id,love=-Config.neglectPenalty,trust=-Config.neglectPenalty,
   conflict="daily_neglect",context="daily",text="Sin interacción: -20 amor y -20 confianza por abandono."})
  local r=session.relationships[id]
  if earlier and f.neglect[id]>=2 and (r.love<=Config.separationAt or r.trust<=Config.separationAt) then
   Events.apply(session,"neglect_separation_"..id,{character=id,marriageState="separated",context="neglect",text="Separación definitiva tras advertencias y ausencias repetidas."})
  else
   f.warnings[id]=f.warnings[id] or {day=session.day}
   Family.notice(session,key.."_warning",id,Config.warnings[id],id=="eris" and "angry" or "worried")
  end
 end
end
function Family.activityFinished(session,def,instance)
 require("src.systems.finale").recordTraining(session,def.id)
 local f=Family.ensure(session);local Events=require("src.systems.events")
 local visits=session.daily.visits[def.character]
 if visits==3 then
  local line=Config.repeated[def.character]
  Family.notice(session,"day"..session.day.."_third_"..def.character,def.character,line.text,line.expression,line.reply)
  Events.apply(session,instance.."_responsibility",{character=def.character,decision="family_reminder_"..def.character,value=session.day,text=line.text,context="activity"})
 end
 if def.id=="sylphiette_errands" then
  Events.apply(session,instance.."_kept",{character="sylphiette",promise={id="family_errand",status="kept"},reconcile="family_errand",context="activity",text="Recado familiar cumplido con hechos."})
 end
 if (f.progress.monster_hunts or 0)>=2 then
  Family.notice(session,"hunt_challenge_unlocked","eris","Ya conoces la ruta y has vencido dos veces. Podemos investigar al guardián de las ruinas; prepara el mazo antes de volver a salir.","happy","Las siguientes cacerías enfrentarán al guardián y entregarán mejores recompensas.")
 end
 local milestones={
  {id="coordination",wife="eris",card="sword_magic",text="Eris reconoce vuestras señales. Habéis construido una técnica de espada y magia juntos."},
  {id="research",wife="roxy",card="combined_spell",text="Roxy coloca ambos nombres en el informe. Ya podéis sostener un conjuro combinado."},
  {id="household",wife="sylphiette",card="shared_magic",text="Sylphiette confía en el reparto que habéis mantenido. La magia compartida también nace de cuidar la casa."},
 }
 for _,m in ipairs(milestones) do
  local r=session.relationships[m.wife]
  if (f.progress[m.id] or 0)>=3 and Family.active(session,m.wife) and r.love>=50 and r.trust>=50 and not session.events["activity_skill_"..m.id] then
   Events.apply(session,"activity_skill_"..m.id,{character=m.wife,unlock={m.card},relationshipEvent="activity_skill",sharedMoment=m.id,context="activity",text=m.text})
   Family.notice(session,"skill_scene_"..m.id,m.wife,m.text,"happy","Rudy repasa el acuerdo. La habilidad seguirá requiriendo que ella pueda acompañarlo.")
  end
 end
end
return Family
