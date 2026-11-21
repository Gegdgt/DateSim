local Catalog=require("src.data.activities")
local Characters=require("src.data.characters")
local Relationships=require("src.systems.relationships")
local Events=require("src.systems.events")
local Family=require("src.systems.family")
local Daily={}
local function copy(value)
    if type(value)~="table" then return value end
    local out={}; for k,v in pairs(value) do out[k]=copy(v) end; return out
end
local function snapshot(session)
    local out={}
    for _,id in ipairs(Characters.romanceIds) do
        local r=session.relationships[id]
        out[id]={love=r.love,trust=r.trust,marriageState=r.marriageState}
    end
    return out
end
function Daily.new(day,session)
    return {day=day,interactions_total=3,interactions_used=0,visits={sylphiette=0,roxy=0,eris=0},
        favor_used=false,activities_completed={},events={},rewards_granted={},ending_processed=false,baseline=snapshot(session)}
end
function Daily.ensure(session)
    if not session.daily or session.daily.day~=session.day then session.daily=Daily.new(session.day,session) end
    session.daily_history=session.daily_history or {}
    session.pending_favors=session.pending_favors or {}
    return session.daily
end
function Daily.key(session,id) return "day"..session.day.."_"..id end
function Daily.remaining(session)
    local d=Daily.ensure(session); return d.interactions_total-d.interactions_used
end
function Daily.config(session) return require("src.data.chapters").byId["day"..session.day].daily end
function Daily.atAgenda(session) return session.checkpoint==Daily.config(session).agenda end
function Daily.storyComplete(session) return session.events[Daily.config(session).completionEvent]==true end
local function available(session)
    local d=Daily.ensure(session)
    if not Daily.atAgenda(session) then return false,"Vuelve a la agenda para elegir una actividad." end
    if d.ending_processed or d.activities_locked then return false,"El tiempo libre de hoy ya terminó." end
    if d.active_activity then return false,"Termina la actividad pendiente." end
    return true
end
function Daily.startActivity(session,id)
    local ok,err=available(session); if not ok then return nil,err end
    local def=Catalog.byId[id]
    if not def or def.cost~=1 then return nil,"Actividad desconocida o coste inválido." end
    if session.relationships[def.character].marriageState=="separated" then return nil,"Este matrimonio ya está separado." end
    if Daily.remaining(session)<1 then return nil,"No quedan interacciones libres hoy." end
    if def.requires and not require("src.systems.conditions").evaluate(session,def.requires) then return nil,"Actividad todavía no disponible." end
    local d=session.daily
    d.interactions_used=d.interactions_used+1
    d.visits[def.character]=d.visits[def.character]+1
    d.active_activity={id=id,instance_id=Daily.key(session,"activity_"..d.interactions_used),visit=d.visits[def.character]}
    d.events[d.active_activity.instance_id.."_started"]=true
    return d.active_activity
end
function Daily.activityEffect(session,effect)
    local out=copy(effect)
    local active=session.daily.active_activity
    local factor=require("src.data.family").repetition[active.visit or 1] or .8
    if out.gold then out.gold=math.max(1,math.floor(out.gold*factor)) end
    for id,n in pairs(out.copies or {}) do out.copies[id]=math.max(1,math.floor(n*factor)) end
    return out
end
local function completeActivity(session,choiceId,effect,text)
    local d=session.daily;local active=d.active_activity;local def=Catalog.byId[active.id]
    effect=Daily.activityEffect(session,effect)
    effect.character=def.character;effect.context="activity";effect.text=text;effect.sharedMoment=active.instance_id
    local delta=require("src.systems.relationship_budget").preview(session,def.character,effect)
    local applied,err=Events.apply(session,active.instance_id,effect)
    if not applied and err then return nil,err end
    d.activities_completed[#d.activities_completed+1]={id=active.id,instance_id=active.instance_id,choice=choiceId,character=def.character}
    local prefix=(active.visit or 1)>1 and ((active.visit==3 and "Antes de despedirse: " or "Al volver a encontrarse: ")) or ""
    Family.notice(session,active.instance_id.."_result",def.character,prefix..text,delta.love<0 and "angry" or "happy",
        "Resultado: "..string.format("%+d amor / %+d confianza",delta.love,delta.trust)..". Oro: "..(effect.gold or 0)..". Recompensas guardadas.")
    Family.activityFinished(session,def,active.instance_id)
    d.active_activity=nil;session.combat=nil
    return text
end
function Daily.resolveActivity(session,choiceId)
    local d=Daily.ensure(session)
    local active=d.active_activity
    if not active or d.ending_processed or not Daily.atAgenda(session) then return nil,"No hay una actividad pendiente." end
    local def=Catalog.byId[active.id]
    for _,choice in ipairs(def.choices) do
        if choice.id==choiceId then
            if active.battle then return nil,"Termina el combate reservado." end
            if def.battle then active.choice=choiceId;active.battle=true;return "Encuentro preparado." end
            return completeActivity(session,choiceId,choice.effects,choice.result)
        end
    end
    return nil,"Elige una de las opciones de la actividad."
end
function Daily.battleDefinition(session)
    local active=Daily.ensure(session).active_activity
    local def=active and Catalog.byId[active.id]
    if not def or not active.battle then return nil end
    return {kind="magic",title=def.title,background=def.background,activity=true,training=def.battle=="duel",
        enemyId=def.battle=="duel" and "eris_training" or def.battle=="monsters" and ((Family.ensure(session).progress.monster_hunts or 0)>=2 and "ruins_guardian" or "forest_beast") or "mana_anomaly",
        character=def.battle=="monsters" and active.choice=="together" and "eris" or nil,
        difficulty=def.battle=="practice" and 1 or session.day,intro=def.description}
end
function Daily.finishBattle(session,enc)
    local def=Daily.battleDefinition(session)
    if not def or session.combat~=enc or not enc.finished then return nil,"El encuentro aún no ha terminado." end
    require("src.systems.companions").record(session,enc)
    local activity=Catalog.byId[session.daily.active_activity.id]
    local won=enc.outcome=="victory"
    local effect,text
    if def.training then
        local result=require("src.systems.training").evaluate(enc)
        effect={love=result.love,trust=result.trust,gold=won and 32 or 16,copies={staff_strike=won and 3 or 1},familyProgress={training=1}}
        effect.decision="activity_duel_result";effect.value=result.id
        if result.id=="suspected_throw" then effect.conflict="training_effort" end
        if result.id=="victory" or result.id=="honorable_defeat" then effect.reconcile="training_effort" end
        text=require("src.data.training_dialogue")[result.id].effort..": "..result.reason
    else
        effect={love=won and 3 or 1,trust=won and 2 or 1,gold=won and (activity.battle=="monsters" and (def.enemyId=="ruins_guardian" and 60 or 40) or 28) or 6,
            copies={staff_strike=won and 3 or 1},familyProgress={}}
        if won or activity.battle~="monsters" then effect.familyProgress[activity.battle=="monsters" and "monster_hunts" or "training"]=1 end
        if won and activity.battle=="monsters" then effect.items={magic_material=def.enemyId=="ruins_guardian" and 2 or 1};effect.copies.simple_cut=1 end
        text=won and "Eris revisa contigo los ataques y bloqueos que funcionaron. El informe abre el camino a desafíos mayores." or "Os retiráis a tiempo. Eris señala un error concreto y acuerda cómo practicarlo la próxima vez."
    end
    return completeActivity(session,session.daily.active_activity.choice,effect,text)
end
function Daily.completeBookVisit(session)
    local active=Daily.ensure(session).active_activity
    if active and active.id=="roxy_books" then return completeActivity(session,"purchase",{love=3,trust=2,familyProgress={research=1}},"Roxy revisa contigo el libro comprado. Elegís una técnica que practicaréis juntos.") end
end
function Daily.favorAvailable(session,id,provider,accelerate)
    local ok,err=available(session); if not ok then return nil,err end
    local d=session.daily
    if d.favor_used then return nil,"Ya solicitaste el encargo de hoy." end
    local def=Catalog.favorsById[id]
    if not def then return nil,"Encargo desconocido." end
    provider=provider or def.character
    local valid=false;for _,p in ipairs(def.providers) do if p==provider then valid=true end end
    if not valid then return nil,"Ese encargado no realiza esta tarea." end
    for _,favor in ipairs(session.pending_favors) do
        if favor.requested_day==session.day-1 and favor.id==id then return nil,"No puedes repetir la tarea de ayer, aunque cambies de encargado." end
    end
    if accelerate and Daily.remaining(session)<1 then return nil,"Ayudar requiere una interacción libre." end
    if session.day==7 and not accelerate then return nil,"En el Día 7 debes solicitar y ayudar para recibirlo hoy." end
    return true
end
function Daily.deliverFavors(session)
    local d=Daily.ensure(session)
    for _,favor in ipairs(session.pending_favors) do
        if favor.status=="pending" and favor.due_day<=session.day then
            local def=Catalog.favorsById[favor.id];local effect=copy(def.effects)
            effect.presenter=favor.provider or def.character;effect.context="favor";effect.text="Entrega de "..def.title..": "..def.reward
            local key=favor.instance_id.."_delivered"
            local applied,err=Events.apply(session,key,effect);if not applied and err then return nil,err end
            session.rewards[key]=true;favor.status="delivered";favor.delivered_day=session.day
            if d.favor_requested and d.favor_requested.instance_id==favor.instance_id then d.favor_requested=copy(favor) end
        end
    end
    return true
end
function Daily.accelerateFavor(session,instance)
    local ok,err=available(session);if not ok then return nil,err end
    if Daily.remaining(session)<1 then return nil,"Ayudar requiere una interacción libre." end
    for _,favor in ipairs(session.pending_favors) do
        if favor.instance_id==instance and favor.requested_day==session.day and favor.status=="pending" and not favor.accelerated then
            local d=session.daily;d.interactions_used=d.interactions_used+1
            local key=Daily.key(session,"activity_"..d.interactions_used)
            Events.apply(session,key,{context="favor_help",text="Ayudaste a "..(favor.provider or Catalog.favorsById[favor.id].character).."; consumiste una interacción libre."})
            d.activities_completed[#d.activities_completed+1]={id="help_favor",instance_id=key,choice=favor.id,favor=instance}
            favor.accelerated=true;favor.due_day=session.day
            return Daily.deliverFavors(session)
        end
    end
    return nil,"Ese encargo no está pendiente."
end
function Daily.requestFavor(session,id,provider,accelerate)
    local ok,err=Daily.favorAvailable(session,id,provider,accelerate);if not ok then return nil,err end
    local d=session.daily;local def=Catalog.favorsById[id]
    local key=Daily.key(session,"favor_"..id)
    Events.apply(session,key,{context="favor",text="Encargo solicitado: "..def.title})
    local favor={id=id,provider=provider or def.character,instance_id=key,requested_day=session.day,due_day=session.day+1,status="pending"}
    session.pending_favors[#session.pending_favors+1]=favor
    d.favor_used=true; d.favor_requested=copy(favor)
    if accelerate then Daily.accelerateFavor(session,key) end
    return favor
end
-- Efectos acotados por día/persona; el abandono nunca separa por una cifra sola.
function Daily.applyAttention(session)
    local d=Daily.ensure(session)
    Family.resolveCommitments(session)
    for _,id in ipairs(Characters.romanceIds) do
        local visited=d.visits[id]>0
        Family.attention(session,id,visited)
    end
end
function Daily.lockActivities(session)
    local d=Daily.ensure(session)
    if d.active_activity then return nil,"Termina la actividad pendiente." end
    Daily.applyAttention(session)
    d.activities_locked=true
    return true
end
function Daily.finish(session)
    local d=Daily.ensure(session)
    if d.ending_processed then return session.daily_history[tostring(session.day)] end
    if not Daily.atAgenda(session) then return nil,"El día se cierra desde la agenda." end
    if not Daily.storyComplete(session) then return nil,"Completa primero la historia obligatoria de hoy." end
    if d.active_activity then return nil,"Termina la actividad pendiente antes de dormir." end
    Events.apply(session,Daily.key(session,"interactions_recorded"),{context="daily",text="Interacciones utilizadas: "..d.interactions_used.." de 3."})
    Daily.applyAttention(session)
    local delivered,deliveryError=Daily.deliverFavors(session);if not delivered then return nil,deliveryError end
    for _,activity in ipairs(d.activities_completed) do
        Events.apply(session,activity.instance_id.."_mission",{mission=activity.instance_id,hidden=true,context="daily"})
    end
    for _,favor in ipairs(session.pending_favors) do
        if favor.status=="delivered" then
            Events.apply(session,favor.instance_id.."_mission",{mission=favor.instance_id,hidden=true,context="daily"})
        end
    end
    -- Las separaciones siguen las decisiones explícitas de las escenas existentes.
    for _,id in ipairs(Characters.romanceIds) do
        if session.decisions["separated_"..id]==true then session.relationships[id].marriageState="separated" end
        Relationships.refresh(session.relationships[id])
    end
    Events.apply(session,Daily.key(session,"ending_processed"),{context="daily",text="Jornada cerrada. Los espacios sin usar no se acumulan."})
    d.ending_processed=true; d.activities_locked=true
    local report={day=session.day,interactions_used=d.interactions_used,unused=3-d.interactions_used,
        visits=copy(d.visits),activities=copy(d.activities_completed),favor=copy(d.favor_requested),
        before=copy(d.baseline),after=snapshot(session),changes={},rewards=copy(d.rewards_granted or {})}
    for _,entry in ipairs(session.journal) do
        if entry.day==session.day and not entry.hidden then report.changes[#report.changes+1]=copy(entry) end
    end
    session.daily_history[tostring(session.day)]=report
    return report
end

-- Valida el registro de reservas: un guardado roto no puede regalar espacios.
function Daily.restore(session,input)
    local d=input.daily
    if type(d)~="table" then return nil,"Falta el estado diario de la partida v4." end
    if type(input.daily_history)~="table" or type(input.pending_favors)~="table" then return nil,"Falta el historial diario o de encargos." end
    if d.day~=session.day then
        -- Solo una jornada vacía permite recuperar un checkpoint antiguo de las
        -- herramientas de diagnóstico; una reserva nunca se borra al cargar.
        if d.interactions_used~=0 or d.favor_used or d.active_activity or d.ending_processed
            or next(input.daily_history or {}) or next(input.pending_favors or {}) then return nil,"Día y agenda inconsistentes." end
        session.daily=Daily.new(session.day,session)
        return true
    end
    if d.interactions_total~=3 or type(d.interactions_used)~="number" or d.interactions_used%1~=0
        or d.interactions_used<0 or d.interactions_used>3 then return nil,"Contador diario inválido." end
    if type(d.visits)~="table" or type(d.activities_completed)~="table" then return nil,"Registro diario inválido." end
    if type(d.events)~="table" or type(d.ending_processed)~="boolean" or type(d.favor_used)~="boolean" then return nil,"Estado diario inválido." end
    if d.active_activity and (not Daily.atAgenda(session) or d.activities_locked) then return nil,"Actividad pendiente fuera de la agenda." end
    local visits={sylphiette=0,roxy=0,eris=0}
    local seen={}
    local function reserve(record,completed)
        if type(record)~="table" or (not Catalog.byId[record.id] and record.id~="help_favor") then return false end
        local index=type(record.instance_id)=="string" and tonumber(record.instance_id:match("^day"..session.day.."_activity_(%d)$"))
        if not index or index<1 or index>d.interactions_used or seen[index] then return false end
        if completed then
            local valid=record.id=="help_favor" and Catalog.favorsById[record.choice]~=nil
                or record.id=="roxy_books" and record.choice=="purchase"
            for _,choice in ipairs(Catalog.byId[record.id] and Catalog.byId[record.id].choices or {}) do if record.choice==choice.id then valid=true end end
            if not valid or not session.events[record.instance_id] then return false end
        end
        seen[index]=true
        if record.id=="help_favor" then return completed end
        local id=Catalog.byId[record.id].character; visits[id]=visits[id]+1
        if record.battle then
            if not Catalog.byId[record.id].battle then return false end
            local valid=false
            for _,choice in ipairs(Catalog.byId[record.id].choices) do if record.choice==choice.id then valid=true end end
            if not valid then return false end
        end
        return true
    end
    for _,record in ipairs(d.activities_completed) do if not reserve(record,true) then return nil,"Actividad guardada inválida." end end
    if d.active_activity and not reserve(d.active_activity,false) then return nil,"Actividad pendiente inválida." end
    for i=1,d.interactions_used do if not seen[i] then return nil,"Falta una reserva de interacción." end end
    for id,n in pairs(visits) do if d.visits[id]~=n then return nil,"Visitas diarias inconsistentes." end end
    if d.ending_processed and (d.active_activity or not Daily.storyComplete(session) or not session.events[Daily.key(session,"ending_processed")]) then return nil,"Cierre diario incompleto." end
    -- JSON contiene solo datos. Copia acotada para historiales y snapshots.
    local function clean(value,depth)
        if type(value)=="string" then return #value<=2000 and value or nil end
        if type(value)=="boolean" then return value end
        if type(value)=="number" then return value==value and math.abs(value)<=100000 and value or nil end
        if type(value)~="table" or depth>7 then return nil end
        local out,count={},0
        for k,v in pairs(value) do
            if (type(k)=="string" and #k<=150) or (type(k)=="number" and k>=1 and k<=1024 and k%1==0) then
                out[k]=clean(v,depth+1); count=count+1; if count>=1024 then break end
            end
        end
        return out
    end
    session.daily=clean(d,0); session.daily.events=session.daily.events or {}
    if session.daily.active_activity then
        session.daily.active_activity.visit=visits[Catalog.byId[session.daily.active_activity.id].character]
    end
    local function validSnapshot(value)
        if type(value)~="table" then return false end
        for _,id in ipairs(Characters.romanceIds) do
            local r=value[id]
            if type(r)~="table" then return false end
            for _,field in ipairs({"love","trust"}) do
                if type(r[field])~="number" or r[field]~=r[field] or r[field]<require("src.data.family").minimum or r[field]>require("src.data.family").maximum then return false end
            end
            if not ({married=true,strained=true,separated=true})[r.marriageState] then return false end
        end
        return true
    end
    if not validSnapshot(session.daily.baseline) then return nil,"Valores iniciales de jornada inválidos." end
    session.daily_history={}
    for day=1,7 do
        local report=type(input.daily_history)=="table" and input.daily_history[tostring(day)]
        if type(report)=="table" and report.day==day then
            if not validSnapshot(report.before) or not validSnapshot(report.after) or type(report.visits)~="table"
                or type(report.interactions_used)~="number" or report.interactions_used<0 or report.interactions_used>3
                or report.unused~=3-report.interactions_used or type(report.changes)~="table" then return nil,"Resumen diario inválido." end
            for _,entry in ipairs(report.changes) do
                if type(entry)~="table" or type(entry.text)~="string" then return nil,"Cambio diario inválido." end
            end
            session.daily_history[tostring(day)]=clean(report,0)
        end
    end
    session.pending_favors={}
    local favors,byInstance={},{}
    for _,favor in ipairs(type(input.pending_favors)=="table" and input.pending_favors or {}) do
        local def=type(favor)=="table" and Catalog.favorsById[favor.id]
        local day=def and favor.requested_day
        if type(day)~="number" or day%1~=0 or day<1 or day>session.day or favors[day]
            or favor.instance_id~="day"..day.."_favor_"..favor.id
            or (favor.due_day~=(favor.accelerated and day or day+1) and not favor.legacyDelivery)
            or type(favor.due_day)~="number" or favor.due_day<day or favor.due_day>7
            or (favor.status~="pending" and favor.status~="delivered")
            or not session.events[favor.instance_id]
            or (favor.status=="delivered" and not session.events[favor.instance_id.."_delivered"]) then return nil,"Encargo guardado inválido." end
        local provider=favor.provider or def.character
        local allowed=false;for _,id in ipairs(def.providers) do if id==provider then allowed=true end end
        if not allowed then return nil,"Encargado guardado inválido." end
        favors[day]=true;byInstance[favor.instance_id]=favor;session.pending_favors[#session.pending_favors+1]=clean(favor,0)
        if day==session.day then session.daily.favor_requested=clean(favor,0) end
    end
    local helped={}
    for _,record in ipairs(d.activities_completed) do
        if record.id=="help_favor" then
            local favor=byInstance[record.favor]
            if not favor or not favor.accelerated or favor.requested_day~=session.day or favor.id~=record.choice or helped[record.favor] then return nil,"Ayuda guardada inconsistente." end
            helped[record.favor]=true
        end
    end
    for id,favor in pairs(byInstance) do
        if favor.requested_day==session.day and favor.accelerated and not helped[id] then return nil,"Falta la interacción de ayuda." end
    end
    if (d.favor_used==true)~=(favors[session.day]==true) then return nil,"Reserva de encargo inconsistente." end
    if not d.favor_used then session.daily.favor_requested=nil end
    if d.ending_processed and not session.daily_history[tostring(session.day)] then return nil,"Falta el resumen diario." end
    return true
end
return Daily
