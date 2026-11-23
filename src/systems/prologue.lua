local World=require("src.data.exploration_world")
local P={}
local flags={"dream_completed","letter_found","letter_collected","letter_read","hitogami_identified",
    "curse_discovered","nanahoshi_visited","starting_cards_received","wake_departed","document_available"}
function P.start(s)
    s.prologue={}
    for _,key in ipairs(flags) do s.prologue[key]=false end
    s.prologue.document_available=true
    local a=World.start
    s.exploration={version=1,map=a.map,x=a.x,y=a.y,facing=a.facing,active=false,visited={},resources={}}
    P.objective(s)
    return s
end
function P.objective(s)
    if not s.prologue then return end
    return require("src.systems.objectives").text(s)
end
function P.wake(s)
    local p=s.prologue
    p.dream_completed=true
    s.checkpoint="day1_wake";s.dialogueIndex=1
    s.exploration.active=true;s.exploration.visited[s.exploration.map]=true
end
function P.shouldExplore(s)
    if not s.prologue then return false end
    if s.rest and s.rest.waking then return true end
    if s.checkpoint=="day1_wake" or s.checkpoint=="day1_letter" then return true end
    if s.checkpoint=="day1_warning" and not s.prologue.nanahoshi_visited then return true end
    local node=require("src.data.chapters").get(s.checkpoint)
    return node and (node.definition.agenda or s.exploration.active and node.kind=="hub") or false
end
function P.readLetter(s)
    local p=s.prologue
    local reading=s.documentState
    if not p or not p.letter_collected or p.letter_read or not reading
        or reading.id~="hitogami_letter" or reading.phase~="signature" then return false end
    p.letter_read=true;p.hitogami_identified=true
    require("src.systems.events").apply(s,"hitogami_letter_read",{clue="hitogami_letter",text="Leí la carta del estudio. La firma es —H."})
    s.documentState=nil;s.checkpoint="day1_signature";s.dialogueIndex=1;s.exploration.active=false
    P.objective(s)
    return true
end
function P.visitNanahoshi(s)
    local p=s.prologue
    if not p or not p.curse_discovered or p.nanahoshi_visited or s.exploration.map~="laboratorio_nanahoshi"
        or not require("src.systems.exploration").nearCharacter(s,"nanahoshi") then return false end
    p.nanahoshi_visited=true;s.exploration.active=false
    s.checkpoint="day1_warning";s.dialogueIndex=1
    require("src.systems.events").apply(s,"nanahoshi_conversation_started",{text="Rudy pide ayuda a Nanahoshi en su laboratorio."})
    return true
end
-- Solo se restaura el modo nuevo si fue guardado explícitamente. Las campañas
-- anteriores conservan su checkpoint y nunca reciben objetos retrospectivos.
function P.restore(s,input)
    local p,e=input.prologue,input.exploration
    if type(p)~="table" or type(e)~="table" or e.version~=1 then return end
    P.start(s)
    for _,key in ipairs(flags) do s.prologue[key]=p[key]==true end
    s.prologue.document_available=true
    local out=s.exploration
    local Maps=require("src.data.maps")
    out.map=Maps[e.map] and e.map or World.start.map
    require("src.systems.exploration").syncPresence(s)
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<100000 end
    if finite(e.x) and finite(e.y) and require("src.systems.exploration").walkable(Maps[out.map],e.x,e.y,true) then
        out.x,out.y=e.x,e.y
    else
        local spawn=Maps[out.map].initialPosition;out.x,out.y=spawn.x,spawn.y
    end
    local directions={down=true,left=true,right=true,up=true}
    out.facing=directions[e.facing] and e.facing or "down"
    out.active=e.active==true
    if type(e.npcLocations)=="table" then
        for id,location in pairs(out.npcLocations or {}) do
            local previous=e.npcLocations[id]
            if type(previous)=="table" and previous.map==location.map and directions[previous.facing] then location.facing=previous.facing end
        end
    end
    for id in pairs(Maps) do if type(e.visited)=="table" and e.visited[id]==true then out.visited[id]=true end end
    for _,objects in pairs(World.objects) do
        for _,object in ipairs(objects) do
            if object.kind=="resource" and type(e.resources)=="table" and e.resources[object.id]==true then out.resources[object.id]=true end
        end
    end
    if s.prologue.letter_read then s.prologue.letter_collected=true end
    if s.prologue.letter_collected then s.prologue.letter_found=true;s.inventory.hitogami_letter=true end
    -- Read flags must agree with the idempotent narrative event.
    if not s.events.hitogami_letter_read then s.prologue.letter_read=false;s.prologue.hitogami_identified=false end
    s.prologue.starting_cards_received=s.events.starter_gift==true
    P.objective(s)
end
return P
