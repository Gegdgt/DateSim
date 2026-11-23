local Data=require("src.data.world_content")
local Ambient=require("src.data.ambient_dialogue")
local W={}
local function copy(v) if type(v)~="table" then return v end;local t={};for k,a in pairs(v) do t[k]=copy(a) end;return t end
W.copy=copy
function W.hash(seed,key)
    local n=seed
    for i=1,#key do n=(n*131+key:byte(i))%2147483647 end
    return math.max(1,n)
end
function W.ready(s) return s.events and (s.events.first_anomaly==true or s.events.day1_complete==true) end
function W.ensure(s)
    if not s.worldContent then
        s.worldContent={version=1,seed=love.math.random(1,2147483646),days={},collected={},examined={},npcMemory={},specialVisits={}}
        if s.inventory.garden_flower then
            local e=require("src.systems.economy").ensure(s)
            e.items.flower=math.max(1,e.items.flower or 0)
        end
    end
    return s.worldContent
end
function W.siteValid(site)
    local map=require("src.data.maps")[site.map]
    if not map or site.map=="cementerio_ranoa" or not require("src.systems.exploration").walkable(map,site.x,site.y) then return false end
    for _,p in ipairs(map.portals) do
        local r=p.trigger
        if r and site.x>=r.x-28 and site.x<=r.x+r.w+28 and site.y>=r.y-28 and site.y<=r.y+r.h+28 then return false end
    end
    for _,npc in ipairs(map.npcs.placements) do if (npc.x-site.x)^2+(npc.y-site.y)^2<28^2 then return false end end
    return true
end
function W.generate(s)
    local w=W.ensure(s);local key=tostring(s.day)
    if not W.ready(s) or w.days[key] then return false end
    local seed=W.hash(w.seed,"finds:"..key)
    local function nextInt(n) seed=seed*48271%2147483647;return seed%n+1 end
    local sites={};for _,site in ipairs(Data.sites) do if W.siteValid(site) then sites[#sites+1]=site end end
    assert(#sites>=3,"Faltan posiciones válidas de hallazgos")
    local count=nextInt(3);local finds={}
    for i=1,count do
        local site=table.remove(sites,nextInt(#sites));local item=Data.lootTypes[nextInt(#Data.lootTypes)]
        finds[#finds+1]={id="find_"..key.."_"..i,site=site.id,map=site.map,x=site.x,y=site.y,item=item,
            kind="object",collectible=true,daily=true,reward=copy(Data.items[item].reward)}
    end
    w.days[key]=finds;return true
end
function W.objects(s,mapId)
    local out={};local w=s.worldContent
    for _,object in ipairs(Data.objects[mapId] or {}) do
        if not object.requiresAntidote or (s.inventory or {}).antidote then out[#out+1]=object end
    end
    for _,object in ipairs(w and w.days[tostring(s.day)] or {}) do
        if object.map==mapId and not w.collected[object.id] then out[#out+1]=object end
    end
    return out
end
function W.greeting(s,id)
    local list=assert(Ambient[id],"NPC sin conversación: "..id);local w=W.ensure(s)
    local memory=w.npcMemory[id] or {last=0,count=0};local eligible={}
    for i,line in ipairs(list) do
        if type(line)=="string" or ((not line.afterIntro or W.ready(s)) and (not line.minDay or s.day>=line.minDay)) then eligible[#eligible+1]=i end
    end
    local at=(memory.count+s.day-1)%#eligible+1
    if eligible[at]==memory.last and #eligible>1 then at=at%#eligible+1 end
    local index=eligible[at];local line=list[index]
    w.npcMemory[id]={last=index,count=math.min(100000,memory.count+1)}
    if id=="norn" and s.relationships.sylphiette.marriageState=="separated" then
        local reactions={
            "Zenith está descansando en otra habitación. La acompañaré en un rato. Lucy se ha marchado con Sylphie.",
            "Echo de menos a Lucy. Quiero que sepas que sigo pendiente de mamá, aunque hoy necesite descansar dentro.",
        }
        return {text=reactions[memory.count%2+1],expression="worried"}
    end
    return type(line)=="table" and copy(line) or {text=line,expression="happy"}
end
function W.examine(s,object)
    if object.id=="hitogami_letter" then return nil,"prologue" end
    local w=W.ensure(s);w.examined[object.id]=true
    if object.kind=="reflection" then w.specialVisits[object.id]=true;return table.concat(object.lines,"\n\n") end
    if object.requiresIntro and not W.ready(s) then return "El objeto está reservado. Podrás revisarlo después de la introducción con Nanahoshi." end
    if not object.collectible then return object.text or "Rudy observa el objeto y lo deja en su sitio." end
    if w.collected[object.id] then return "Ya recogiste el contenido. No queda otra recompensa." end
    local reward=copy(object.reward or Data.items[object.item].reward)
    reward.context="exploration";reward.text="Hallazgo: "..Data.items[object.item].name
    local place=object.map or (s.exploration and s.exploration.map)
    local map=place and require("src.data.maps")[place]
    local background=({biblioteca_ranoa="library",laboratorio_nanahoshi="laboratory",taller_cliff_zanoba="laboratory",patio_eris="training"})[place]
    reward.celebration={participants={"rudeus"},background=background or (map and map.tileset=="hogar" and "home") or "courtyard"}
    local applied,err=require("src.systems.events").apply(s,"world_pickup_"..object.id,reward)
    if err then return nil,err end
    w.collected[object.id]=true
    local parts={};if reward.gold then parts[#parts+1]=reward.gold.." oro" end
    for id,n in pairs(reward.items or {}) do parts[#parts+1]=n.." "..require("src.data.economy").items[id].name end
    for id,n in pairs(reward.copies or {}) do parts[#parts+1]=n.." copias de "..require("src.systems.card_collection").byId[id].name end
    return applied and ("Recogido: "..table.concat(parts,", ")..".") or "Este hallazgo ya estaba registrado."
end
local function integer(n,min,max) return type(n)=="number" and n%1==0 and n>=min and n<=max end
function W.validReward(effect)
    if type(effect)~="table" then return false end
    for k,v in pairs(effect) do
        if k=="gold" then if not integer(v,0,100) then return false end
        elseif k=="items" or k=="copies" then
            if type(v)~="table" then return false end
            for id,n in pairs(v) do
                local catalog=k=="items" and require("src.data.economy").items or require("src.systems.card_collection").byId
                if not catalog[id] or not integer(n,1,10) then return false end
            end
        else return false end
    end
    return true
end
function W.restore(s,input)
    local value=input.worldContent
    if value==nil then return true end
    if type(value)~="table" or value.version~=1 or not integer(value.seed,1,2147483646) then return nil,"Semilla del mundo inválida." end
    for _,key in ipairs({"days","collected","examined","npcMemory","specialVisits"}) do if type(value[key])~="table" then return nil,"Registro del mundo incompleto." end end
    local w={version=1,seed=value.seed,days={},collected={},examined={},npcMemory={},specialVisits={}}
    local known={garden_flower=true}
    for _,objects in pairs(Data.objects) do for _,o in ipairs(objects) do known[o.id]=true end end
    for day=1,7 do
        local finds=value.days[tostring(day)]
        if finds then
            if type(finds)~="table" or #finds<1 or #finds>3 or day>s.day then return nil,"Hallazgos diarios inválidos." end
            local sites={};w.days[tostring(day)]={}
            for i,f in ipairs(finds) do
                if type(f)~="table" or f.id~="find_"..day.."_"..i or not W.validReward(f.reward) then return nil,"Hallazgo inválido." end
                local site;for _,a in ipairs(Data.sites) do if a.id==f.site then site=a end end
                local allowed=false;for _,id in ipairs(Data.lootTypes) do if f.item==id then allowed=true end end
                if not site or sites[f.site] or not allowed or site.map~=f.map or site.x~=f.x or site.y~=f.y then return nil,"Posición de hallazgo inválida." end
                sites[f.site]=true;known[f.id]=true
                w.days[tostring(day)][i]={id=f.id,site=f.site,map=f.map,x=f.x,y=f.y,item=f.item,kind="object",collectible=true,daily=true,reward=copy(f.reward)}
            end
        end
    end
    for id in pairs(known) do
        if value.collected[id]==true or s.events["world_pickup_"..id] then
            if not s.events["world_pickup_"..id] and not (id=="garden_flower" and s.inventory.garden_flower) then return nil,"Recogida sin recompensa registrada." end
            w.collected[id]=true
        end
        if value.examined[id]==true then w.examined[id]=true end
    end
    for _,id in ipairs({"paul_grave","oldeus_rest"}) do if value.specialVisits[id]==true then w.specialVisits[id]=true end end
    for id,list in pairs(Ambient) do
        local m=value.npcMemory[id]
        if m then
            if type(m)~="table" or not integer(m.last,1,#list) or not integer(m.count,0,100000) then return nil,"Memoria de NPC inválida." end
            w.npcMemory[id]={last=m.last,count=m.count}
        end
    end
    s.worldContent=w;return true
end
return W
