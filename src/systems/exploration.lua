local Maps=require("src.data.maps")
local Data=require("src.data.exploration_world")
local V=require("src.systems.map_validation")
-- Píxeles de mapa por segundo; speed conserva la velocidad de caminar.
local E={speed=80,runSpeed=150}
local function overlap(a,b)
    return a.x<b.x+b.w and b.x<a.x+a.w and a.y<b.y+b.h and b.y<a.y+a.h
end
function E.syncPresence(s)
    if s.exploration then
        local e=s.exploration
        local d=s.daily
        local busy=d and d.active_activity or s.wifeActivities and s.wifeActivities.review
        local night=d and d.day==s.day and (d.interactions_used>=3 or d.activities_locked)
        -- Una reserva no termina el día: primero se cierra la conversación.
        local period=night and not busy and "night" or "day"
        if busy and e.periodDay==s.day then period=e.period or "day" end
        local changed=e.periodDay==s.day and e.period~="night" and period=="night"
        e.period=period;e.periodDay=s.day;e.npcLocations={}
        -- El único idle de Zenith incluye a Lucy: cuando Lucy se marcha con
        -- Sylphie, Zenith descansa fuera de la zona familiar (Norn lo explica).
        s.exploration.absentNpcs={zenith=s.relationships and s.relationships.sylphiette.marriageState=="separated" or false}
        for _,id in ipairs({"eris","roxy","sylphiette"}) do
            s.exploration.absentNpcs[id]=s.relationships and s.relationships[id].marriageState=="separated" or false
            local map=Data.wifeLocations[id][period]
            -- Excepción breve del despertar; termina al salir del dormitorio.
            if id=="eris" and s.prologue and not s.prologue.wake_departed and not s.prologue.letter_read and e.map=="dormitorio_eris" then map="dormitorio_eris" end
            if not e.absentNpcs[id] then
                for _,npc in ipairs(Maps[map].npcs.placements) do if npc.id==id then
                    assert(V.isWalkable(Maps[map],npc),"NPC fuera del suelo: "..id)
                    e.npcLocations[id]={map=map,x=npc.x,y=npc.y,facing="down"}
                end end
            end
        end
        return changed
    end
end
function E.npcPresent(e,npc,mapId)
    if e.absentNpcs and e.absentNpcs[npc.id] then return false end
    if not npc.period then return true end
    local location=e.npcLocations and e.npcLocations[npc.id]
    if location then return location.map==(mapId or e.map) and location.x==npc.x and location.y==npc.y end
    return npc.period=="day"
end
function E.nearCharacter(s,id)
    if not s.exploration then return true end -- campañas anteriores al mundo explorable
    local item=E.nearby(s)
    return item and item.kind=="npc" and item.id==id or false
end
function E.face(s,npc)
    local e=s.exploration;local dx,dy=npc.x-e.x,npc.y-e.y
    e.facing=math.abs(dx)>math.abs(dy) and (dx<0 and "left" or "right") or (dy<0 and "up" or "down")
    local location=e.npcLocations and e.npcLocations[npc.id]
    if location then location.facing=({left="right",right="left",up="down",down="up"})[e.facing] end
end
function E.walkable(map,x,y,ignoreNPC,absence,presence)
    if not V.isWalkable(map,{x=x,y=y}) then return false end
    local size=map.collisions.footprint
    local foot={x=x-size.w/2,y=y-size.h,w=size.w,h=size.h}
    if not ignoreNPC then
        for _,npc in ipairs(map.npcs.placements) do
            if npc.solid and E.npcPresent(presence or {absentNpcs=absence,map=map.id},npc,map.id) and overlap(foot,{x=npc.x-5,y=npc.y-6,w=10,h=6}) then return false end
        end
    end
    for _,object in ipairs(map.objects) do
        if object.solid and overlap(foot,object.solid) then return false end
    end
    return true
end
function E.move(e,dx,dy,dt,running)
    local length=math.sqrt(dx*dx+dy*dy)
    if length==0 then return false end
    if math.abs(dx)>math.abs(dy) then e.facing=dx<0 and "left" or "right"
    else e.facing=dy<0 and "up" or "down" end
    local speed=running and E.runSpeed or E.speed
    dx,dy=dx/length*speed*dt,dy/length*speed*dt
    -- <=2 px steps + axis separation: no tunnelling or diagonal corner clipping.
    local steps=math.max(1,math.ceil(math.max(math.abs(dx),math.abs(dy))/2))
    local x,y=e.x,e.y
    for _=1,steps do
        if E.walkable(Maps[e.map],e.x+dx/steps,e.y,nil,e.absentNpcs,e) then e.x=e.x+dx/steps end
        if E.walkable(Maps[e.map],e.x,e.y+dy/steps,nil,e.absentNpcs,e) then e.y=e.y+dy/steps end
    end
    return x~=e.x or y~=e.y
end
function E.enter(e,id,arrival)
    local map=assert(Maps[id]);assert(E.walkable(map,arrival.x,arrival.y,true),"Llegada bloqueada: "..id)
    e.map=id;e.x=arrival.x;e.y=arrival.y;e.facing=arrival.facing or "down";e.visited[id]=true
end
function E.portal(e)
    for _,portal in ipairs(Maps[e.map].portals) do
        local r=portal.trigger
        if portal.enabled and r and e.x>=r.x and e.x<=r.x+r.w and e.y>=r.y and e.y<=r.y+r.h then return portal end
    end
end
function E.nearby(s)
    local e=s.exploration
    local nearest,best=nil,30
    local function consider(item)
        local x,y=item.reachX or item.x,item.reachY or item.y
        local d=math.sqrt((x-e.x)^2+(y-e.y)^2)
        if d<best then
            -- Reach cannot cross a wall. A letter's authored reach point lies
            -- in front of the desk; solid NPC endpoints are excluded.
            local clear=true
            for t=.15,.85,.15 do
                if not V.isWalkable(Maps[e.map],{x=e.x+(x-e.x)*t,y=e.y+(y-e.y)*t}) then clear=false;break end
            end
            if clear then nearest,best=item,d end
        end
    end
    for _,npc in ipairs(Maps[e.map].npcs.placements) do if E.npcPresent(e,npc) then consider(npc) end end
    for _,object in ipairs(Maps[e.map].objects) do if object.kind=="letter" or not e.resources[object.id] then consider(object) end end
    for _,object in ipairs(require("src.systems.world_content").objects(s,e.map)) do consider(object) end
    if Data.transfers[e.map] then consider(Data.transfers[e.map]) end
    local bed=require("src.systems.rest").bed(s)
    if bed then consider(bed) end
    return nearest
end
function E.camera(e,vw,vh)
    local map=Maps[e.map]
    -- World viewport is 320x152, rendered at 2x into the 640x360 canvas.
    vw,vh=vw or 320,vh or 152
    return {x=math.floor(math.max(0,math.min(map.width-vw,e.x-vw/2))),
        y=math.floor(math.max(0,math.min(map.height-vh,e.y-vh/2))),w=vw,h=vh}
end
function E.markers(s)
    local e=s.exploration;local map=Maps[e.map];local out={}
    for _,p in ipairs(map.portals) do
        if p.enabled then out[#out+1]={kind=p.sourceAccess=="escaleras" and "stairs" or "door",x=p.trigger.x+p.trigger.w/2,y=p.trigger.y+p.trigger.h/2,target=p.targetMap} end
    end
    for _,npc in ipairs(map.npcs.placements) do if E.npcPresent(e,npc) then out[#out+1]={kind="npc",x=npc.x,y=npc.y,id=npc.id} end end
    local travel=Data.transfers[e.map]
    if travel then out[#out+1]={kind="travel",x=travel.x,y=travel.y,target=travel.target} end
    local objective=require("src.systems.objectives").current(s)
    local destination=objective and objective.destination
    local target=destination and destination.map
    local resting=objective and objective.type=="rest"
    local bed=resting and require("src.systems.rest").bed(s)
    if resting then target=bed and map.id or "casa_segundo_piso" end
    if target then
        if map.id==target then
            local point=destination or {}
            out[#out+1]={kind="objective",x=bed and bed.x or point.x or map.initialPosition.x,y=bed and bed.y or point.y or map.initialPosition.y}
        else
            -- Trace the next real access toward the objective, including the
            -- explicitly labelled transfer and excluding disabled portals.
            local queue={map.id};local first={[map.id]=false};local seen={[map.id]=true};local cursor=1
            while queue[cursor] do
                local id=queue[cursor];cursor=cursor+1
                if id==target then break end
                local edges={}
                for _,p in ipairs(Maps[id].portals) do
                    if p.enabled then edges[#edges+1]={target=p.targetMap,x=p.trigger.x+p.trigger.w/2,y=p.trigger.y+p.trigger.h/2} end
                end
                if Data.transfers[id] then edges[#edges+1]=Data.transfers[id] end
                for _,edge in ipairs(edges) do
                    if not seen[edge.target] then
                        seen[edge.target]=true;first[edge.target]=first[id] or edge;queue[#queue+1]=edge.target
                    end
                end
            end
            if first[target] then out[#out+1]={kind="objective",x=first[target].x,y=first[target].y} end
        end
    end
    out[#out+1]={kind="player",x=e.x,y=e.y}
    return out
end
return E
