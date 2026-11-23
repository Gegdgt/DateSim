local Q=require("src.systems.objectives")
local Font=require("src.ui.font")
local Chapters=require("src.data.chapters")
local J={}
local ink={.94,.91,.81};local gold={1,.8,.39};local muted={.65,.74,.77};local green={.48,.92,.62}
local labels={available="PENDIENTE",in_progress="EN PROGRESO",completed="HECHO",locked="BLOQUEADO",failed="FALLIDO"}
function J.rows(s,day)
    local sections={{"HISTORIA PRINCIPAL",{}},{"INTERACCIONES DEL DÍA",{}},{"ACTIVIDADES OPCIONALES",{}},{"OBJETIVOS COMPLETADOS",{}}}
    for _,o in ipairs(Q.list(s,day)) do
        local section=o.type=="daily" and 2 or o.status=="completed" and 4 or not o.required and 3 or 1
        table.insert(sections[section][2],o)
    end
    local rows={}
    local function add(text,color) rows[#rows+1]={text=text,color=color} end
    for _,section in ipairs(sections) do if #section[2]>0 then
        add(section[1],gold)
        for _,o in ipairs(section[2]) do
            local progress=(o.source or o.requiredProgress>1) and (" "..o.progress.."/"..o.requiredProgress) or ""
            local prefix=o.status=="completed" and "[X] HECHO " or "[ ] "..labels[o.status].." "
            local title=o.title
            if o.source=="wife" then prefix=o.status=="completed" and "[X] " or "[ ] ";title=title.." (recomendada)" end
            if o.source=="interactions" and o.status=="completed" then title="Interacciones completadas:" end
            if o.waived then title="Interacciones dispensadas: no hay esposas disponibles.";progress="" end
            add(prefix..title..progress,o.status=="completed" and green or ink)
            if o.destination then add("  Lugar: "..o.destination.label,muted) end
            if o.status~="completed" and o.description~="" and o.source~="wife" then add("  "..o.description,muted) end
        end
    end end
    if day==s.day then
        local ok,reason,pending=Q.requirements(s)
        add(s.day==7 and "REQUISITOS DEL DESENLACE" or "REQUISITOS PARA DESCANSAR",gold)
        add(s.day==7 and ok and "Desenlace completado. Continúa al resumen de la semana." or reason,ink)
        -- Sólo listar objetivos ya revelados; el primer requisito guía el desbloqueo.
        for i,o in ipairs(pending) do if i>1 and o.unlocked then add("[ ] "..o.title..((o.source or o.requiredProgress>1) and (" "..o.progress.."/"..o.requiredProgress) or ""),muted) end end
    end
    return rows
end
function J.draw(screen,s)
    local day=math.min(screen.journalDay or s.day,s.day);screen.journalDay=day
    local function text(t,x,y,w,c) Font.draw(t,x,y,{maxWidth=w,color=c or ink}) end
    love.graphics.setColor(.035,.055,.09,.98);love.graphics.rectangle("fill",16,38,608,288)
    love.graphics.setColor(.42,.48,.54);love.graphics.rectangle("line",16.5,38.5,607,287)
    text("DIARIO DE RUDY · OBJETIVOS DEL DÍA",30,48,578,gold)
    text("DÍA "..day.." / "..Chapters.byId["day"..day].title,30,65,578,ink)
    text("< >: días anteriores   ARRIBA/ABAJO o rueda: desplazar",30,81,578,muted)
    local rows=J.rows(s,day);local total=0
    for _,row in ipairs(rows) do row.height=Font.height(row.text,554,1)+6;total=total+row.height end
    screen.journalMax=math.max(0,total-184)
    screen.journalScroll=math.max(0,math.min(screen.journalScroll or 0,screen.journalMax))
    love.graphics.push("all");love.graphics.setScissor(28,101,578,184)
    local y=102-screen.journalScroll
    for _,row in ipairs(rows) do text(row.text,32,y,554,row.color);y=y+row.height end
    love.graphics.pop()
    if screen.journalMax>0 then
        love.graphics.setColor(.35,.45,.5);love.graphics.rectangle("fill",609,102,3,181)
        love.graphics.setColor(gold);love.graphics.rectangle("fill",609,102+screen.journalScroll/screen.journalMax*160,3,21)
    end
    text(s.prologue.letter_found and "ENTER: consultar carta —H   H: recuerdos y decisiones" or "La carta misteriosa te espera en el estudio.",30,296,578,muted)
    text("J / ESC: volver",30,312,578,gold)
end
function J.key(screen,s,key)
    if key=="up" or key=="pageup" then screen.journalScroll=math.max(0,(screen.journalScroll or 0)-(key=="pageup" and 160 or 24));return true end
    if key=="down" or key=="pagedown" then screen.journalScroll=math.min(screen.journalMax or 0,(screen.journalScroll or 0)+(key=="pagedown" and 160 or 24));return true end
    if key=="home" then screen.journalScroll=0;return true end
    if key=="end" then screen.journalScroll=screen.journalMax or 0;return true end
    if key=="left" or key=="right" then
        screen.journalDay=math.max(1,math.min(s.day,(screen.journalDay or s.day)+(key=="left" and -1 or 1)))
        screen.journalScroll=0;return true
    end
end
return J
