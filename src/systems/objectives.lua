local Data=require("src.data.objectives")
local Conditions=require("src.systems.conditions")
local Q={data=Data}
local notices=setmetatable({},{__mode="k"})
local function event(s,id) return (s.events or {})[id]==true end
local function noWives(s,day)
    local report=(s.daily_history or {})[tostring(day)]
    local relationships=day==s.day and s.relationships or report and report.after
    if not relationships then return false end
    for _,id in ipairs({"sylphiette","roxy","eris"}) do
        if relationships[id].marriageState~="separated" then return false end
    end
    return true
end
function Q.dailyUnlocked(s)
    return event(s,"tutorial_completed") and event(s,"combat_tutorial_completed")
end
-- Sólo cuentan cierres efectivos, nunca una reserva o una carta jugada.
function Q.counts(s,day)
    local d=day==s.day and s.daily or (s.daily_history or {})[tostring(day)]
    local visits={sylphiette=0,roxy=0,eris=0};local total=0;local seen={}
    for _,a in ipairs(d and (d.activities_completed or d.activities) or {}) do
        if event(s,a.instance_id) and not seen[a.instance_id] then
            seen[a.instance_id]=true;total=total+1
            local def=require("src.data.activities").byId[a.id]
            local id=def and def.character
            if visits[id] then visits[id]=visits[id]+1 end
        end
    end
    return total,visits
end
function Q.sync(s,silent)
    if not s.events or not s.relationships then return end
    local fresh=not s.objectives
    s.objectives=s.objectives or {version=1,entries={}}
    local book=s.objectives;local entries=book.entries
    for day=1,s.day do
        local total,visits=Q.counts(s,day)
        for _,def in ipairs(Data.byDay[day] or {}) do
            local previous=entries[def.id];local unlocked=not next(def.unlock) or Conditions.evaluate(s,def.unlock)
            for _,id in ipairs(def.dependencies) do unlocked=unlocked and entries[id] and entries[id].status=="completed" end
            local required=def.requiredProgress
            local waived=def.source=="interactions" and total<required and noWives(s,day)
            local eventProgress
            if def.events then
                eventProgress=0
                for _,id in ipairs(def.events) do if event(s,id) then eventProgress=eventProgress+1 end end
            end
            local progress=def.source=="interactions" and total or def.source=="wife" and visits[def.wife]
                or eventProgress or ((def.complete and Conditions.evaluate(s,def.complete) or not def.complete and event(s,def.event)) and 1 or 0)
            local completed=progress>=required or waived
            -- El evento puede llegar antes que el refresco de la pantalla.
            unlocked=unlocked or completed or previous and previous.unlocked
            local failed=def.failEvent and event(s,def.failEvent) and not completed
            local status=completed and "completed" or failed and "failed" or not unlocked and "locked" or progress>0 and "in_progress" or "available"
            entries[def.id]={id=def.id,day=day,status=status,unlocked=unlocked==true,progress=progress,requiredProgress=required,waived=waived==true}
            if not silent and not fresh and previous and previous.status~="completed" and completed and def.source~="wife" then
                notices[s]=notices[s] or {};table.insert(notices[s],def.completedTitle or def.title)
            end
        end
    end
    book.current=nil
    for _,def in ipairs(Data.byDay[s.day] or {}) do
        local o=entries[def.id]
        if def.required and o.unlocked and o.status~="completed" then book.current=def.id;break end
    end
    if s.exploration then s.exploration.objective=book.current end
    return book
end
function Q.list(s,day,includeLocked)
    Q.sync(s);local out={}
    for _,def in ipairs(Data.byDay[day or s.day] or {}) do
        local state=s.objectives.entries[def.id]
        if state and (includeLocked or state.unlocked) then
            local row={};for k,v in pairs(def) do row[k]=v end;for k,v in pairs(state) do row[k]=v end
            if row.status=="completed" then row.title=def.completedTitle or row.title end
            if row.waived then row.description="No quedan esposas disponibles. Puedes cerrar la jornada y dormir solo." end
            out[#out+1]=row
        end
    end
    return out
end
function Q.current(s)
    Q.sync(s)
    for _,row in ipairs(Q.list(s)) do if row.id==s.objectives.current then return row end end
end
function Q.text(s)
    local row=Q.current(s)
    if not row then return "Consulta los recuerdos del día en el diario [J]." end
    return row.title..((row.source or row.requiredProgress>1) and (" ("..row.progress.."/"..row.requiredProgress..")") or "")
end
function Q.pending(s,includeRest)
    local pending={}
    for _,o in ipairs(Q.list(s,s.day,true)) do
        if o.required and (includeRest or o.type~="rest") and o.status~="completed" then pending[#pending+1]=o end
    end
    return pending
end
function Q.requirements(s)
    local pending=Q.pending(s)
    local o=pending[1]
    if o then
        if o.source=="interactions" then
            local n=o.requiredProgress-o.progress
            return false,"Todavía te falta"..(n==1 and " una interacción" or "n "..(({[2]="dos",[3]="tres"})[n] or tostring(n)).." interacciones")..
                " para terminar el día. Interacciones: "..o.progress.."/"..o.requiredProgress..". [J] Diario",pending
        end
        return false,(o.blockedMessage or ("Todavía debes completar: "..o.title)).." [J] Diario",pending
    end
    local d=s.daily
    if d and d.active_activity or s.wifeActivities and s.wifeActivities.review then
        return false,"Termina y cierra la actividad pendiente antes de descansar.",pending
    end
    return true,"Requisitos completados. Puedes descansar.",pending
end
function Q.popNotice(s)
    local queue=notices[s]
    return queue and table.remove(queue,1)
end
-- Migra únicamente hechos demostrados. No entrega premios ni reproduce escenas.
function Q.restore(s,input)
    if s.checkpoint=="day7_return_cards" and require("src.systems.relationships").ending(s.relationships) then
        require("src.systems.events").mark(s,"relationships_resolved")
    end
    if s.prologue then
        local Events=require("src.systems.events")
        if s.prologue.nanahoshi_visited then Events.mark(s,"nanahoshi_conversation_started") end
        if event(s,"combat_reward_day1_tutorial") and event(s,"resolved_day1_tutorial") then Events.mark(s,"combat_tutorial_completed") end
        local chapter=require("src.data.chapters").get(s.checkpoint)
        if not event(s,"day1_complete") and Q.dailyUnlocked(s) and event(s,"resolved_day1_tutorial")
            and event(s,"first_anomaly") and (s.checkpoint=="day1_agenda" or chapter and chapter.day>1) then
            Events.apply(s,"day1_complete",{hidden=true,text="Cierre del prólogo recuperado: tutorial y primera anomalía ya concluidos."})
        end
    end
    -- Conserva desbloqueos irreversibles aunque una condición de afinidad cambie.
    -- Progreso y finalización se reconstruyen desde eventos y actividades validados.
    s.objectives={version=1,entries={}}
    local raw=type(input.objectives)=="table" and input.objectives
    if raw and raw.version==1 and type(raw.entries)=="table" then
        for id,def in pairs(Data.byId) do
            local previous=raw.entries[id]
            if def.day<=s.day and type(previous)=="table" and previous.unlocked==true then s.objectives.entries[id]={unlocked=true} end
        end
    end
    Q.sync(s,true);notices[s]=nil
    return true
end
return Q
