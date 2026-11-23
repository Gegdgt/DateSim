-- Validación de datos de autoría; no implementa movimiento ni modifica partidas.
local V={}
local opposite={top="bottom",bottom="top",left="right",right="left"}
local inward={top="down",bottom="up",left="right",right="left"}
local function overlaps(a,b)
    return a.x<b.x+b.w and b.x<a.x+a.w and a.y<b.y+b.h and b.y<a.y+a.h
end
local function contains(a,b)
    return b.x>=a.x and b.y>=a.y and b.x+b.w<=a.x+a.w and b.y+b.h<=a.y+a.h
end
local function bounds(map,r)
    return type(r)=="table" and type(r.x)=="number" and type(r.y)=="number"
        and type(r.w)=="number" and type(r.h)=="number" and r.w>0 and r.h>0
        and contains({x=0,y=0,w=map.width,h=map.height},r)
end
function V.isWalkable(map,point)
    if not point then return false end
    local c=map.collisions
    local foot={x=point.x-c.footprint.w/2,y=point.y-c.footprint.h,w=c.footprint.w,h=c.footprint.h}
    if not bounds(map,foot) then return false end
    for _,kind in ipairs({"walls","furniture","obstacles"}) do
        for _,r in ipairs(c[kind]) do if overlaps(foot,r) then return false end end
    end
    for _,r in ipairs(c.walkable) do if contains(r,foot) then return true end end
    -- A footprint may straddle two adjacent reviewed rectangles. Subtract
    -- their union exactly; accepting only a single rectangle creates seams.
    local uncovered={foot}
    for _,r in ipairs(c.walkable) do
        local rest={}
        for _,a in ipairs(uncovered) do
            if not overlaps(a,r) then rest[#rest+1]=a else
                local x1,y1=math.max(a.x,r.x),math.max(a.y,r.y)
                local x2,y2=math.min(a.x+a.w,r.x+r.w),math.min(a.y+a.h,r.y+r.h)
                local function part(x,y,w,h) if w>0 and h>0 then rest[#rest+1]={x=x,y=y,w=w,h=h} end end
                part(a.x,a.y,a.w,y1-a.y);part(a.x,y2,a.w,a.y+a.h-y2)
                part(a.x,y1,x1-a.x,y2-y1);part(x2,y1,a.x+a.w-x2,y2-y1)
            end
        end
        uncovered=rest
        if #uncovered==0 then return true end
    end
    return #uncovered==0
end
function V.reachable(maps,connections,start,enabledOnly)
    local seen,queue={[start]=true},{start}
    local cursor=1
    while queue[cursor] do
        local id=queue[cursor];cursor=cursor+1
        for _,p in ipairs(connections.portals) do
            if p.sourceMap==id and (not enabledOnly or p.enabled) and maps[p.targetMap] and not seen[p.targetMap] then
                seen[p.targetMap]=true;queue[#queue+1]=p.targetMap
            end
        end
    end
    return seen
end
function V.validate(maps,connections)
    local errors,warnings={},{}
    local stats={maps=0,links=0,portals=0,calibratedLinks=0,pendingLinks=0,calibratedAccesses=0}
    local function check(ok,message) if not ok then errors[#errors+1]=message end end
    local links,portals,pairsSeen,accesses={},{},{},{}
    for _,link in ipairs(connections.links) do
        stats.links=stats.links+1
        check(not links[link.id],"Enlace duplicado: "..link.id);links[link.id]=link
        local key=link.a.map<link.b.map and link.a.map..":"..link.b.map or link.b.map..":"..link.a.map
        check(not pairsSeen[key],"Conexión duplicada: "..key);pairsSeen[key]=true
        check(link.a.map~=link.b.map,"Enlace al mismo mapa: "..link.id)
        check(opposite[link.a.side]==link.b.side,"Lados incompatibles: "..link.id)
        check(link.enabled==(link.a.status=="calibrated" and link.b.status=="calibrated"),"Estado incoherente: "..link.id)
        if link.enabled then stats.calibratedLinks=stats.calibratedLinks+1
        else stats.pendingLinks=stats.pendingLinks+1;warnings[#warnings+1]="Pendiente: "..link.id end
        for _,a in ipairs({link.a,link.b}) do
            local accessKey=a.map.."/"..a.id
            check(not accesses[accessKey],"Acceso duplicado: "..accessKey);accesses[accessKey]=a
            local map=maps[a.map]
            check(map~=nil,"Mapa inexistente: "..a.map)
            if map then
                if a.status=="calibrated" then
                    stats.calibratedAccesses=stats.calibratedAccesses+1
                    check(bounds(map,a.trigger),"Activación fuera del mapa: "..a.map.."/"..a.id)
                    check(a.spawn and V.isWalkable(map,a.spawn),"Llegada no transitable: "..a.map.."/"..a.id)
                    if a.spawn then
                        check(a.spawn.x>=12 and a.spawn.x<=map.width-12 and a.spawn.y>=32 and a.spawn.y<=map.height,
                            "Sprite fuera del mapa: "..a.map.."/"..a.id)
                        check(a.spawn.facing==inward[a.side],"Dirección incorrecta: "..a.map.."/"..a.id)
                    end
                    if a.trigger then
                        local cx,cy=a.trigger.x+a.trigger.w/2,a.trigger.y+a.trigger.h/2
                        check(V.isWalkable(map,{x=cx,y=cy}),"Activación no transitable: "..accessKey)
                        check((a.side=="top" and cy<map.height/2) or (a.side=="bottom" and cy>map.height/2)
                            or (a.side=="left" and cx<map.width/2) or (a.side=="right" and cx>map.width/2),
                            "Acceso en el lado incorrecto: "..a.map.."/"..a.id)
                    end
                else
                    check(a.status=="pending_calibration" and a.trigger==false and a.spawn==false and type(a.evidence)=="string",
                        "Pendiente debe documentarse sin coordenadas: "..a.map.."/"..a.id)
                end
            end
        end
    end
    for _,p in ipairs(connections.portals) do
        stats.portals=stats.portals+1
        check(not portals[p.id],"Portal duplicado: "..p.id);portals[p.id]=p
        check(maps[p.sourceMap] and maps[p.targetMap],"Destino/origen inexistente: "..p.id)
        local link=links[p.connectionId]
        check(link~=nil,"Portal sin enlace: "..p.id)
        if link then
            local a,b=link.a,link.b
            if a.map~=p.sourceMap then a,b=b,a end
            check(a.map==p.sourceMap and b.map==p.targetMap and a.id==p.sourceAccess and b.id==p.targetAccess,
                "Destino incorrecto: "..p.id)
            check(p.trigger==a.trigger and p.arrival==b.spawn and p.initialDirection==b.facing,
                "Posiciones no corresponden al enlace: "..p.id)
            check(p.exitSide==a.side and p.entrySide==b.side and p.enabled==link.enabled and p.transition==link.transition,
                "Metadatos no corresponden al enlace: "..p.id)
        end
        if p.enabled then check(p.trigger and p.arrival,"Portal habilitado sin coordenadas: "..p.id) end
    end
    for i,a in ipairs(connections.portals) do
        for j=i+1,#connections.portals do
            local b=connections.portals[j]
            if a.sourceMap==b.sourceMap and a.trigger and b.trigger then
                check(not overlaps(a.trigger,b.trigger),"Activaciones superpuestas: "..a.id.." / "..b.id)
            end
        end
    end
    for _,p in ipairs(connections.portals) do
        local reverse=portals[p.reverseId]
        check(reverse and reverse.reverseId==p.id and reverse.sourceMap==p.targetMap and reverse.targetMap==p.sourceMap
            and reverse.exitSide==p.entrySide and reverse.entrySide==p.exitSide and reverse.enabled==p.enabled,
            "Regreso incorrecto: "..p.id)
    end
    check(stats.portals==stats.links*2,"Cada enlace debe generar exactamente dos portales")
    local reachable=V.reachable(maps,connections,"casa_planta_baja")
    for id,map in pairs(maps) do
        stats.maps=stats.maps+1
        check(reachable[id],"Mapa no alcanzable en el grafo: "..id)
        check(V.isWalkable(map,map.initialPosition),"Inicio no transitable: "..id)
        for name,point in pairs(map.spawnPoints) do
            check(V.isWalkable(map,point),"Spawn no transitable: "..id.."/"..name)
            for _,p in ipairs(map.portals) do
                if p.trigger then
                    check(not contains(p.trigger,{x=point.x,y=point.y,w=0,h=0}),"Llegada reactiva un portal: "..id.."/"..name)
                end
            end
        end
        for _,kind in ipairs({"walkable","walls","furniture","obstacles"}) do
            for _,r in ipairs(map.collisions[kind]) do check(bounds(map,r),"Colisión fuera del mapa: "..id.."/"..kind) end
        end
    end
    return {ok=#errors==0,errors=errors,warnings=warnings,stats=stats}
end
return V
