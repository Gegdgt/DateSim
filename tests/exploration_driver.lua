-- Piloto de QA: calcula rutas con las colisiones reales y mueve cada paso.
-- Nunca cambia el checkpoint ni concede cartas/eventos directamente.
local E=require("src.systems.exploration")
local Maps=require("src.data.maps")
local Data=require("src.data.exploration_world")
local Driver={}
local function walk(session,predicate)
    local e=session.exploration;local map=Maps[e.map]
    local queue={{x=e.x,y=e.y}};local seen={[e.x..":"..e.y]=true};local cursor=1;local target
    while queue[cursor] do
        local a=queue[cursor];cursor=cursor+1
        if predicate(a) then target=a;break end
        for _,d in ipairs({{4,0},{-4,0},{0,4},{0,-4}}) do
            local x,y=a.x+d[1],a.y+d[2];local key=x..":"..y
            if not seen[key] and E.walkable(map,x,y,nil,e.absentNpcs,e) and E.walkable(map,x-d[1]/2,y-d[2]/2,nil,e.absentNpcs,e) then
                seen[key]=true;queue[#queue+1]={x=x,y=y,previous=a}
            end
        end
    end
    assert(target,"QA: sin camino en "..e.map)
    local path={};while target.previous do table.insert(path,1,target);target=target.previous end
    for _,point in ipairs(path) do
        local dx,dy=point.x-e.x,point.y-e.y
        assert(E.move(e,dx,dy,math.sqrt(dx*dx+dy*dy)/E.speed),"QA: paso bloqueado")
    end
end
local function route(from,target)
    local queue={from};local previous={[from]=true};local cursor=1
    while queue[cursor] do
        local id=queue[cursor];cursor=cursor+1
        if id==target then break end
        local edges={}
        for _,p in ipairs(Maps[id].portals) do if p.enabled then edges[#edges+1]=p.targetMap end end
        if Data.transfers[id] then edges[#edges+1]=Data.transfers[id].target end
        for _,nextId in ipairs(edges) do if not previous[nextId] then previous[nextId]=id;queue[#queue+1]=nextId end end
    end
    assert(previous[target],"QA: destino sin conexión")
    while previous[target]~=from do target=previous[target] end
    return target
end
function Driver.step(app)
    local s=app.manager.current;local session=app.session;local e=session.exploration
    if s.kind=="exploration_letter" then s:interact();return end
    local Daily=require("src.systems.daily")
    local bedtime=Daily.atAgenda(session) and Daily.storyComplete(session) and (Daily.remaining(session)==0 or session.daily.activities_locked)
    if Daily.atAgenda(session) and not bedtime then
        if require("src.systems.wife_activities").ready(session) and Daily.remaining(session)>0 and not session.daily.activities_locked then
            local wife=({"sylphiette","roxy","eris"})[session.daily.interactions_used+1]
            if require("src.systems.family").active(session,wife) then
                require("tests.campaign_world_driver").greet(session,wife)
                s:keypressed("e");return
            end
        end
        require("tests.campaign_world_driver").travel(session,"laboratorio_nanahoshi")
        require("tests.campaign_world_driver").near(session,"nanahoshi")
        s:keypressed("e");return
    end
    local target=bedtime and "dormitorio_sylphie" or session.prologue.letter_read and "laboratorio_nanahoshi" or "estudio_rudy"
    if bedtime and not require("src.systems.family").active(session,"sylphiette") then target="casa_segundo_piso" end
    if e.map~=target then
        local nextMap=route(e.map,target)
        local travel=Data.transfers[e.map]
        if travel and travel.target==nextMap then
            walk(session,function(a)
                return E.nearby({exploration={map=e.map,x=a.x,y=a.y,resources={},npcLocations=e.npcLocations,absentNpcs=e.absentNpcs}})==travel
            end)
            s:keypressed("e");s:keypressed("return")
        else
            walk(session,function(a)
                local p=E.portal({map=e.map,x=a.x,y=a.y});return p and p.targetMap==nextMap
            end)
            s:update(0)
        end
    else
        local id=bedtime and require("src.data.rest").beds[target].id or target=="estudio_rudy" and "hitogami_letter" or "nanahoshi"
        walk(session,function(a)
            local item=E.nearby({exploration={map=e.map,x=a.x,y=a.y,resources={},npcLocations=e.npcLocations,absentNpcs=e.absentNpcs}})
            return item and item.id==id
        end)
        s:keypressed("e")
    end
end
Driver.walk=walk
Driver.route=route
return Driver
