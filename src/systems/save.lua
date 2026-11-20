local Json=require("src.systems.json")
local Cards=require("src.systems.cards")
local CardData=require("src.data.cards")
local Characters=require("src.data.characters")
local Relationships=require("src.systems.relationships")
local Story=require("src.data.story")
local Save={filename="save.json",backup="save.backup.json",optionsFile="options.json"}
local checkpoints={intro=1,day1_tutorial=1,day1_result=1,day1_close=1,hub=2,
    meet_sylphiette=2,meet_roxy=2,meet_eris=2,encounter_sylphiette=2,encounter_roxy=2,encounter_eris=2,
    result_sylphiette=2,result_roxy=2,result_eris=2,seal_intro=2,seal_encounter=2,seal_result=2,day2_close=2,phase_complete=2}
local function number(value,default,min,max)
    if type(value)~="number" or value~=value or value==math.huge or value==-math.huge then return default end
    return math.max(min,math.min(max,value))
end
local function map(value,booleans)
    local out={}
    if type(value)~="table" then return out end
    local count=0
    for key,item in pairs(value) do
        if type(key)=="string" and #key<=100 then
            if booleans then
                if item==true then out[key]=true end
            elseif type(item)=="boolean" or (type(item)=="string" and #item<=1000) then out[key]=item
            elseif type(item)=="number" and item==item and math.abs(item)<=100000 then out[key]=item end
            count=count+1
            if count>=256 then break end
        end
    end
    return out
end
local function options(value)
    value=type(value)=="table" and value or {}
    return {volume=number(value.volume,0.6,0,1),muted=value.muted==true}
end
local function starter()
    local deck,unlocked={},{}
    for i,id in ipairs(CardData.starterDeck) do deck[i]=id; unlocked[id]=true end
    return deck,unlocked
end

function Save.newSession()
    local deck,unlocked=starter()
    return {version=1,day=1,checkpoint="intro",dialogueIndex=1,relationships=Relationships.new(),
        unlocked=unlocked,deck=deck,events={},decisions={},options=options()}
end

function Save.validate(input)
    if type(input)~="table" or input==Json.null then return nil,"El guardado no contiene una partida." end
    if input.version~=nil and input.version~=1 then return nil,"Versión de guardado no compatible." end
    if not next(input) then return nil,"El guardado está vacío." end
    local s=Save.newSession()
    s.checkpoint=checkpoints[input.checkpoint] and input.checkpoint or "intro"
    s.day=checkpoints[s.checkpoint]
    s.dialogueIndex=math.floor(number(input.dialogueIndex,1,1,100))
    s.events=map(input.events,true); s.decisions=map(input.decisions,false)
    s.options=options(input.options)
    if type(input.relationships)=="table" then
        for _,id in ipairs(Characters.romanceIds) do
            local data=input.relationships[id]
            if type(data)=="table" then
                local r=s.relationships[id]
                r.trust=number(data.trust,0,0,10); r.chemistry=number(data.chemistry,0,0,10)
                r.events=map(data.events,true); r.decisions=map(data.decisions,false)
                local states={unmet=true,friend=true,chosen=true,romance=true,friendship=true,active=true}
                if states[data.routeState] then r.routeState=data.routeState end
            end
        end
    end
    for id in pairs(map(input.unlocked,true)) do if CardData.byId[id] then s.unlocked[id]=true end end
    if Cards.validateDeck(input.deck,s.unlocked) then
        s.deck={}; for i,id in ipairs(input.deck) do s.deck[i]=id end
    end
    if type(input.route)=="string" and s.relationships[input.route] then s.route=input.route end
    if type(input.selectedCompanion)=="string" and s.relationships[input.selectedCompanion] then s.selectedCompanion=input.selectedCompanion end
    if type(s.decisions.companion)~="string" or not s.relationships[s.decisions.companion] then
        s.decisions.companion=nil
        s.events.companion_selected=nil
    end
    -- Keep only known choice IDs. Progression.scene hides already answered
    -- choices while preserving the saved dialogue position.
    for _,id in ipairs(Characters.romanceIds) do
        local sceneId="meet_"..id
        local key="choice_"..sceneId
        local selected=s.decisions[key]
        local valid=false
        for _,choice in ipairs(Story.scenes[sceneId].choices) do
            if selected==choice.id then valid=true end
        end
        if not valid then s.decisions[key]=nil end
    end
    local needsCompanion=s.checkpoint:match("^seal_") or s.checkpoint=="day2_close" or s.checkpoint=="phase_complete"
    if needsCompanion and not s.decisions.companion then
        s.checkpoint="hub"; s.dialogueIndex=1
    end
    local context
    local definition=Story.encounters[s.checkpoint]
    if definition then
        context={kind=definition.kind,character=definition.character}
        if context.character=="companion" then context.character=s.decisions.companion end
    end
    if context then s.encounter=Cards.restore(input.encounter,s.deck,context) end
    if type(input.lastResult)=="table" then
        s.lastResult={score=number(input.lastResult.score,0,0,100),success=input.lastResult.success==true,
            targetScore=number(input.lastResult.targetScore,3,0,100),
            trust=number(input.lastResult.trust,0,-30,30),chemistry=number(input.lastResult.chemistry,0,-30,30)}
        if type(input.lastResult.title)=="string" and #input.lastResult.title<=200 then s.lastResult.title=input.lastResult.title end
        if Characters.byId[input.lastResult.character] then s.lastResult.character=input.lastResult.character end
    end
    return s
end

local function readFile(path)
    local ok,info=pcall(love.filesystem.getInfo,path,"file")
    if not ok or not info then return nil,"No hay guardado disponible." end
    if info.size and info.size>524288 then return nil,"El archivo de guardado es demasiado grande." end
    local readOk,data,err=pcall(love.filesystem.read,path)
    if not readOk or not data then return nil,err or "No se pudo leer el archivo." end
    return data
end
local function writeFile(path,data)
    local ok,written,err=pcall(love.filesystem.write,path,data)
    if not ok or not written then return false,err or "No se pudo escribir el archivo." end
    return true
end
local function decodeSession(data)
    local decoded,err=Json.decode(data)
    if not decoded then return nil,err end
    return Save.validate(decoded)
end

function Save.write(session)
    local clean,err=Save.validate(session)
    if not clean then return false,err end
    local data; data,err=Json.encode(clean)
    if not data then return false,err end
    local ok; ok,err=writeFile("save.tmp.json",data)
    if not ok then return false,err end
    local old=readFile(Save.filename)
    if old and decodeSession(old) then
        ok,err=writeFile(Save.backup,old)
        if not ok then return false,err end
    end
    ok,err=writeFile(Save.filename,data)
    if not ok then return false,err end
    pcall(love.filesystem.remove,"save.tmp.json")
    return true
end

function Save.load()
    local raw,err=readFile(Save.filename)
    if raw then
        local session; session,err=decodeSession(raw)
        if session then return session end
    end
    local backup=readFile(Save.backup)
    if backup then
        local session=decodeSession(backup)
        if session then return session,"Se recuperó la copia anterior del guardado." end
    end
    return nil,err or "No hay guardado válido disponible."
end

function Save.exists() return Save.load()~=nil end
function Save.readOptions()
    local data=readFile(Save.optionsFile)
    if not data then return options() end
    local parsed=Json.decode(data)
    return options(parsed)
end
function Save.writeOptions(value)
    local data,err=Json.encode(options(value))
    if not data then return false,err end
    return writeFile(Save.optionsFile,data)
end

return Save
