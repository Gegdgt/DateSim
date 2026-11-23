local Json=require("src.systems.json")
local Cards=require("src.systems.cards")
local CardData=require("src.data.cards")
local Characters=require("src.data.characters")
local Relationships=require("src.systems.relationships")
local Story=require("src.data.story")
local Chapters=require("src.data.chapters")
local Progression=require("src.systems.progression")
local Options=require("src.systems.options")
local Daily=require("src.systems.daily")
local Collection=require("src.systems.card_collection")
local Economy=require("src.systems.economy")
local Save={version=8,maxBytes=2097152,filename="campaign-exploration-v1.json",backup="campaign-exploration-v1.backup.json",optionsFile="options.json",
    legacyFilename="save.json",legacyBackup="save.backup.json"}

local function number(value,default,min,max)
    if type(value)~="number" or value~=value or math.abs(value)==math.huge then return default end
    return math.max(min,math.min(max,value))
end
local function map(value,booleans)
    local out={}
    if type(value)~="table" then return out end
    local count=0
    for key,item in pairs(value) do
        if type(key)=="string" and #key<=150 then
            if booleans then
                if item==true then out[key]=true end
            elseif type(item)=="boolean" or (type(item)=="string" and #item<=1000) then out[key]=item
            elseif type(item)=="number" and item==item and math.abs(item)<=100000 then out[key]=item end
            count=count+1
            if count>=2048 then break end
        end
    end
    return out
end
local function records(value)
    local out={}
    if type(value)~="table" then return out end
    for _,entry in ipairs(value) do
        if #out>=1024 then break end
        if type(entry)=="table" and type(entry.id)=="string" and #entry.id<=150 then out[#out+1]=map(entry,false) end
    end
    return out
end
local function copyList(source)
    local out={}; for i,id in ipairs(source or {}) do out[i]=id end; return out
end

function Save.newSession(config)
    local s={version=Save.version,continuity="rudy_curse",day=Chapters.first.day,checkpoint=Chapters.first.initial,
        dialogueIndex=1,relationships=Relationships.new(config),affinities=require("src.systems.affinity").new(),unlocked={},deck={},combatDeck={},events={},decisions={},
        curse=require("src.systems.curse").new(),clues={},inventory={},externalEnergy=0,
        journal={},rewardQueue={},rewards={},missions={},defeatedEnemies={},familyEvents={},events_by_day={},options=Options.normalize()}
    Daily.ensure(s)
    Collection.ensure(s);Economy.ensure(s)
    require("src.systems.family").ensure(s)
    require("src.systems.finale").ensure(s)
    s.campaignStats=require("src.systems.campaign_stats").new(s,true)
    return s
end

function Save.validate(input)
    if type(input)~="table" or input==Json.null then return nil,"El guardado no contiene una partida." end
    if not next(input) then return nil,"El guardado está vacío." end
    if input.version==1 or input.version==nil then
        return nil,"Esta partida pertenece a la continuidad anterior. Inicia una nueva campaña compatible; el archivo original se conserva."
    end
    if input.version==4 then
        local encoded,err=Json.encode(input)
        if not encoded then return nil,err end
        input=Json.decode(encoded)
        input.version=5;input.collection=nil;input.gold=nil;input.economy=nil
        input.migration=type(input.migration)=="table" and input.migration or {};input.migration.economySource="campaign-v4.json"
        if type(input.daily)=="table" then
            input.daily.relationship_gains={}
            for _,id in ipairs(Characters.romanceIds) do input.daily.relationship_gains[id]={love=0,trust=0} end
            for _,entry in ipairs(type(input.journal)=="table" and input.journal or {}) do
                local gains=type(entry)=="table" and entry.day==input.day and input.daily.relationship_gains[entry.character]
                if gains then for _,field in ipairs({"love","trust"}) do gains[field]=math.min(10,gains[field]+math.max(0,tonumber(entry[field]) or 0)) end end
            end
        end
        local encounter=input.encounter
        if type(encounter)=="table" and type(encounter.initialMemory)=="table" then
            local memory=encounter.initialMemory
            memory.relationship_gains={}
            for _,id in ipairs(Characters.romanceIds) do memory.relationship_gains[id]={love=0,trust=0} end
            for _,entry in ipairs(type(input.journal)=="table" and input.journal or {}) do
                local gains=type(entry)=="table" and entry.day==input.day and memory.relationship_gains[entry.character]
                if gains and type(memory.events)=="table" and memory.events[entry.eventId] then
                    for _,field in ipairs({"love","trust"}) do gains[field]=math.min(10,gains[field]+math.max(0,tonumber(entry[field]) or 0)) end
                end
            end
        end
    end
    if input.version==5 then
        local encoded,err=Json.encode(input);if not encoded then return nil,err end
        input=Json.decode(encoded);input.version=6;input.family=nil
        input.migration=type(input.migration)=="table" and input.migration or {};input.migration.familySource="campaign-v5.json"
        for _,favor in ipairs(type(input.pending_favors)=="table" and input.pending_favors or {}) do
            if type(favor)=="table" then favor.legacyDelivery=true end
        end
    end
    if input.version==6 then
        input=Json.decode(assert(Json.encode(input)));input.version=7
        input.migration=type(input.migration)=="table" and input.migration or {};input.migration.warSource="campaign-v6.json"
    end
    if input.version==7 then
        input=Json.decode(assert(Json.encode(input)));input.version=8;input.versionBeforeFinale=7
        input.migration=type(input.migration)=="table" and input.migration or {};input.migration.finaleSource="campaign-v7.json"
        input.decisions=type(input.decisions)=="table" and input.decisions or {}
        if input.checkpoint=="day6_hitogami" and type(input.combat)=="table" and type(input.combat.enemy)=="table" and input.combat.enemy.id=="hitogami_minion" then input.decisions.legacy_emissary_encounter=true end
    end
    if input.version~=Save.version then return nil,"Versión de guardado no compatible." end
    local s=Save.newSession()
    s.checkpoint=Chapters.get(input.checkpoint) and input.checkpoint or Chapters.first.initial
    s.day=Chapters.get(s.checkpoint).day
    s.dialogueIndex=math.floor(number(input.dialogueIndex,1,1,100))
    s.events=map(input.events,true); s.decisions=map(input.decisions,false)
    s.affinities=require("src.systems.affinity").normalize(input.affinities)
    s.trainingResults=require("src.systems.training_result").normalize(input.trainingResults,s.events)
    s.dialogueMemory={used={}}
    for id,count in pairs(map(type(input.dialogueMemory)=="table" and input.dialogueMemory.used,false)) do
        if type(count)=="number" then s.dialogueMemory.used[id]=math.floor(number(count,0,0,10000)) end
    end
    s.options=Options.normalize(input.options)
    s.clues=map(input.clues,true); s.inventory=map(input.inventory,true)
    s.externalEnergy=number(input.externalEnergy,0,0,30)
    if type(input.curse)=="table" then
        s.curse.discoveredVoice=input.curse.discoveredVoice==true
        s.curse.discoveredMana=input.curse.discoveredMana==true
    end
    if s.inventory.antidoteUsed then
        s.curse.active=false; s.curse.voiceSealed=false; s.curse.manaBlocked=false
        s.curse.chantlessBlocked=false
    end
    if type(input.documentState)=="table" and require("src.data.documents")[input.documentState.id] then
        local phases={resting=true,lifting=true,sealed=true,opening=true,reading=true,signature=true}
        s.documentState={id=input.documentState.id,phase=phases[input.documentState.phase] and input.documentState.phase or "resting",
            page=math.floor(number(input.documentState.page,1,1,100)),elapsed=number(input.documentState.elapsed,0,0,3600)}
    end
    s.journal=records(input.journal)
    for _,field in ipairs({"rewards","missions","defeatedEnemies","familyEvents"}) do s[field]=map(input[field],true) end
    if type(input.migration)=="table" then s.migration=map(input.migration,false) end
    if type(input.relationships)=="table" then
        for _,id in ipairs(Characters.romanceIds) do
            local data=input.relationships[id]
            if type(data)=="table" then
                local r=s.relationships[id]
                local familyConfig=require("src.data.family")
                r.trust=number(data.trust,familyConfig.initial,familyConfig.minimum,familyConfig.maximum)
                r.love=number(data.love,familyConfig.initial,familyConfig.minimum,familyConfig.maximum)
                r.events=map(data.events,true); r.personalEvents=r.events
                r.decisions=map(data.decisions,false); r.criticalDecisions=map(data.criticalDecisions,false)
                for _,field in ipairs({"brokenPromises","sharedMoments","pendingConflicts","reconciliations"}) do r[field]=map(data[field],true) end
                for key,status in pairs(map(data.promises,false)) do
                    if status=="pending" or status=="kept" or status=="broken" or status=="reconciled" then r.promises[key]=status end
                end
                r.history=records(data.history)
                if data.marriageState=="separated" then r.marriageState="separated" end
                Relationships.refresh(r)
            end
        end
    end
    local family=s.family
    if type(input.family)=="table" then
        local saved=input.family
        for _,key in ipairs({"progress","books","seen","departures","warnings","neglect"}) do
            if type(saved[key])~="table" then return nil,"Registro familiar inválido." end
        end
        for _,key in ipairs({"progress","neglect"}) do
            for id,value in pairs(saved[key]) do
                if type(id)~="string" or #id>100 or type(value)~="number" or value%1~=0 or value<0 or value>100000 then return nil,"Contador familiar inválido." end
                family[key][id]=value
            end
        end
        family.books=map(saved.books,true);family.seen=map(saved.seen,true)
        family.discounts=math.floor(number(saved.discounts,0,0,21))
        if saved.commitmentDue~=nil then family.commitmentDue=math.floor(number(saved.commitmentDue,7,1,7)) end
        for _,id in ipairs(Characters.romanceIds) do
            local warning=saved.warnings[id];if type(warning)=="table" then family.warnings[id]={day=math.floor(number(warning.day,1,1,7))} end
            local departure=saved.departures[id]
            if type(departure)=="table" then
                family.departures[id]={day=math.floor(number(departure.day,1,1,7)),reason=type(departure.reason)=="string" and departure.reason or "critical_decision",permanent=true}
                s.relationships[id].marriageState="separated";s.relationships[id].routeState="separated";s.decisions["separated_"..id]=true
            end
        end
        for _,entry in ipairs(type(saved.queue)=="table" and saved.queue or {}) do
            if type(entry)=="table" and s.relationships[entry.character] and type(entry.id)=="string" and (entry.kind=="notice" or entry.kind=="departure") then
                local lines=copyList(type(entry.lines)=="table" and entry.lines or {})
                if entry.kind=="notice" then
                    if #lines<1 or #lines>5 then return nil,"Diálogo familiar inválido." end
                    for _,line in ipairs(lines) do if type(line)~="string" or #line>2000 then return nil,"Línea familiar inválida." end end
                end
                family.queue[#family.queue+1]={id=entry.id,character=entry.character,kind=entry.kind,
                    phase=math.floor(number(entry.phase,1,1,entry.kind=="departure" and 5 or #lines)),elapsed=number(entry.elapsed,0,0,20),expression=type(entry.expression)=="string" and entry.expression or "worried",lines=lines}
            else return nil,"Escena familiar guardada inválida." end
        end
    end
    for _,id in ipairs(Characters.romanceIds) do
        if s.decisions["separated_"..id] or s.relationships[id].marriageState=="separated" then
            s.relationships[id].marriageState="separated";s.relationships[id].routeState="separated"
            family.departures[id]=family.departures[id] or {day=s.day,reason="previous_save",permanent=true}
        end
    end
    local CombatData=require("src.data.combat_cards")
    for id in pairs(map(input.unlocked,true)) do if CardData.byId[id] or CombatData.byId[id] then s.unlocked[id]=true end end
    -- Repair only an earned starter gift. This is not a new reward and never
    -- queues its animation or reapplies the story decision.
    if s.events.starter_gift then
        for _,id in ipairs(CardData.starterDeck) do s.unlocked[id]=true end
        for _,id in ipairs(CombatData.starterDeck or {}) do s.unlocked[id]=true end
    end
    Collection.ensure(s)
    for id,entry in pairs(s.collection) do
        local saved=type(input.collection)=="table" and input.collection[id]
        if type(saved)=="table" then
            if saved.id~=id or type(saved.level)~="number" or saved.level%1~=0 or saved.level<1 or saved.level>10
                or type(saved.copies)~="number" or saved.copies%1~=0 or saved.copies<0 or saved.copies>1000000 then return nil,"Colección de cartas inválida." end
            entry.level,entry.copies=saved.level,saved.copies
            entry.unlocked=s.unlocked[id]==true or saved.unlocked==true
            if entry.unlocked then s.unlocked[id]=true end
        end
    end
    local EconomyData=require("src.data.economy")
    if input.gold~=nil and (type(input.gold)~="number" or input.gold%1~=0 or input.gold<0 or input.gold>EconomyData.maxGold) then return nil,"Saldo de oro inválido." end
    s.gold=input.gold or EconomyData.startingGold
    if type(input.economy)=="table" then
        local e=input.economy
        s.economy.revision=math.floor(number(e.revision,0,0,1000000))
        for key,quantity in pairs(map(e.purchases,false)) do
            if type(quantity)~="number" or quantity%1~=0 or quantity<0 or quantity>30 then return nil,"Existencias de tienda inválidas." end
            s.economy.purchases[key]=quantity
        end
        s.economy.nextBattleShield=e.nextBattleShield==EconomyData.items.battle_preparation.shield and e.nextBattleShield or 0
        for id in pairs(EconomyData.items) do s.economy.items[id]=math.floor(number(type(e.items)=="table" and e.items[id],0,0,10000)) end
        for id,receipt in pairs(type(e.transactions)=="table" and e.transactions or {}) do
            if type(id)=="string" and #id<=150 and type(receipt)=="table" then s.economy.transactions[id]=map(receipt,false) end
        end
    end
    if Cards.validateDeck(input.deck,s.unlocked) then
        s.deck=copyList(input.deck)
    elseif Cards.validateDeck(CardData.starterDeck,s.unlocked) then s.deck=copyList(CardData.starterDeck) end
    local Combat=require("src.systems.combat")
    if Combat.validateDeck and Combat.validateDeck(input.combatDeck,s.unlocked) then
        s.combatDeck=copyList(input.combatDeck)
    elseif CombatData.starterDeck and Combat.validateDeck and Combat.validateDeck(CombatData.starterDeck,s.unlocked) then
        s.combatDeck=copyList(CombatData.starterDeck)
    end
    local queued={}
    for _,reward in ipairs(type(input.rewardQueue)=="table" and input.rewardQueue or {}) do
        if type(reward)=="table" and type(reward.id)=="string" and type(reward.eventId)=="string"
            and s.events[reward.eventId] and not queued[reward.id] and #s.rewardQueue<128 then
            local entry={id=reward.id,eventId=reward.eventId,presenter=Characters.byId[reward.presenter] and reward.presenter or "nanahoshi",cards={},counts={},newCards={}}
            local seen={}
            for _,id in ipairs(type(reward.cards)=="table" and reward.cards or {}) do
                if s.unlocked[id] and not seen[id] then
                    entry.cards[#entry.cards+1]=id; seen[id]=true
                    entry.counts[id]=math.floor(number(type(reward.counts)=="table" and reward.counts[id],1,1,100000))
                    entry.newCards[id]=reward.newCards==nil or (type(reward.newCards)=="table" and reward.newCards[id]==true) or nil
                end
            end
            if #entry.cards>0 then
                local Presentation=require("src.systems.card_rewards")
                local context=type(reward.celebration)=="table" and Presentation.validContext(reward.celebration) and reward.celebration or nil
                entry.celebration=Presentation.context(entry.eventId,entry.presenter,context)
                if reward.presentationPage then entry.presentationPage=math.floor(number(reward.presentationPage,1,1,#entry.cards)) end
                if reward.presentation then Presentation.restore(entry,reward.presentation) end
                s.rewardQueue[#s.rewardQueue+1]=entry; queued[entry.id]=true
            end
        end
    end
    if type(input.route)=="string" and s.relationships[input.route] then s.route=input.route end
    if type(input.selectedCompanion)=="string" and s.relationships[input.selectedCompanion] then s.selectedCompanion=input.selectedCompanion end
    for _,chapter in ipairs(Chapters.list) do
        local companion=chapter.companion
        if companion then
            local key=companion.decisionKey
            if type(s.decisions[key])~="string" or (not s.relationships[s.decisions[key]] and s.decisions[key]~="solo" and not (key=="day7_companion" and s.decisions[key]=="all")) then
                s.decisions[key]=nil; s.events[companion.event]=nil
            end
        end
    end
    for sceneId in pairs(Story.scenes) do
        local key="choice_"..sceneId
        local selected=s.decisions[key]
        local valid=false
        for _,choice in ipairs(Progression.choices(s,sceneId)) do if selected==choice.id then valid=true end end
        if not valid then s.decisions[key]=nil end
    end
    local node=Chapters.get(s.checkpoint)
    local chapter=Chapters.chapterFor(s.checkpoint)
    if node.definition.requiresCompanion and chapter.companion and not s.decisions[chapter.companion.decisionKey] then
        s.checkpoint=chapter.companion.selectionCheckpoint; s.dialogueIndex=1
        s.day=Chapters.get(s.checkpoint).day
    end
    if (Chapters.get(s.checkpoint).kind=="encounter" or s.day>1) and (not Cards.validateDeck(s.deck,s.unlocked) or not Combat.validateDeck(s.combatDeck,s.unlocked)) then
        s.checkpoint=Chapters.get("day1_cards") and "day1_cards" or Chapters.first.initial
        s.day=Chapters.get(s.checkpoint).day; s.dialogueIndex=1
        s.recoveryNotice="El mazo guardado estaba incompleto. Nanahoshi revisará la entrega; las decisiones permanecen registradas."
    end
    -- Restore the daily budget before reconstructing any pending reaction.
    local dailyOk,dailyError=Daily.restore(s,input)
    if not dailyOk then return nil,dailyError end
    if s.daily.relationship_gains~=nil and type(s.daily.relationship_gains)~="table" then return nil,"Presupuesto de relaciones inválido." end
    local gains=require("src.systems.relationship_budget").ensure(s)
    for _,id in ipairs(Characters.romanceIds) do
        if type(gains[id])~="table" then return nil,"Presupuesto de relaciones inválido." end
        for _,field in ipairs({"love","trust"}) do
            local value=gains[id][field]
            if type(value)~="number" or value~=value or value<0 or value>10 then return nil,"Límite diario de relaciones inválido." end
        end
    end
    -- Los eventos recuperados por la migración se añaden al índice diario ya normalizado.
    for day=1,7 do
        s.events_by_day[tostring(day)]=map(type(input.events_by_day)=="table" and input.events_by_day[tostring(day)],true)
    end
    require("src.systems.finale").restore(s,input)
    local definition=Daily.battleDefinition(s) or Progression.encounter(s,s.checkpoint)
    if definition then
        local context=require("src.systems.dialogue_resolver").context(s,definition,s.checkpoint)
        if definition.tutorial and type(input.encounter)=="table" and type(input.encounter.context)=="table"
            and input.encounter.context.socialTutorial then
            context=require("src.systems.dialogue_resolver").context(s,{kind="conversation",character="nanahoshi"},"nanahoshi_test")
            context.socialTutorial=true
        end
        s.encounter=Cards.restore(input.encounter,s.deck,context)
    end
    if s.encounter and #s.encounter.log>0 and input.encounterReview==true then s.encounterReview=true end
    if definition and definition.tutorial and input.tutorial and not s.events.tutorial_completed then
        s.tutorial=require("src.systems.tutorial").restore(input.tutorial,s.encounter)
    end
    if definition and definition.kind=="magic" and not s.encounter then
        if input.combatPreparation==true then s.combatPreparation=true end
        if not s.combatPreparation and type(input.combat)=="table" then
            local support=require("src.systems.companions").context(s,definition)
            s.combat=Combat.restore(input.combat,s.deck,{character=definition.character,tutorial=definition.tutorial,
                relationships=support.relationships,team=support.team,legacyEncounter=definition.legacyEncounter,
                cardLevels=Collection.levels(s),preparationShield=type(input.combat.context)=="table" and input.combat.context.preparationShield,
                enemyId=definition.enemyId,unlocked=s.unlocked,combatDeck=s.combatDeck,tacticalContext=definition.tacticalContext,curse=s.curse,externalEnergy=s.externalEnergy,
                day=s.day,difficulty=definition.difficulty})
        end
    end
    if type(input.lastResult)=="table" then
        local result=input.lastResult
        s.lastResult={score=number(result.score,0,0,100),success=result.success==true,targetScore=number(result.targetScore,3,0,100),
            trust=number(result.trust,0,-100,100),chemistry=number(result.chemistry,0,-100,100),love=number(result.love or result.chemistry,0,-100,100)}
        if type(result.title)=="string" and #result.title<=200 then s.lastResult.title=result.title end
        if Characters.byId[result.character] then s.lastResult.character=result.character end
    end
    if definition and definition.training and not definition.activity and s.combat and s.combat.finished then
        local result=require("src.systems.training").evaluate(s.combat)
        local data=result and require("src.data.training_dialogue")[result.id]
        if data then
            local review=type(input.trainingReview)=="table" and input.trainingReview or {}
            s.trainingReview={line=math.floor(number(review.line,1,1,#data.lines))}
        end
    end
    require("src.systems.prologue").restore(s,input)
    local worldOk,worldError=require("src.systems.world_content").restore(s,input)
    if not worldOk then return nil,worldError end
    local wifeOk,wifeError=require("src.systems.wife_activities").restore(s,input)
    if not wifeOk then return nil,wifeError end
    local restOk,restError=require("src.systems.rest").restore(s,input)
    if not restOk then return nil,restError end
    local statsOk,statsError=require("src.systems.campaign_stats").restore(s,input)
    if not statsOk then return nil,statsError end
    require("src.systems.objectives").restore(s,input)
    return s
end

local function readFile(path)
    local ok,info=pcall(love.filesystem.getInfo,path,"file")
    if not ok or not info then return nil,"No hay guardado disponible." end
    if info.size and info.size>Save.maxBytes then return nil,"El archivo de guardado es demasiado grande." end
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
    local old=readFile(Save.filename)
    local existing=old and Json.decode(old)
    if type(existing)=="table" and existing.version~=Save.version then
        return false,"El archivo de destino contiene una versión incompatible; se conserva sin sobrescribir."
    end
    local data; data,err=Json.encode(clean)
    if not data then return false,err end
    if #data>Save.maxBytes then return false,"El progreso supera el tamaño máximo de guardado." end
    local ok; ok,err=writeFile("campaign-exploration-v1.tmp.json",data)
    if not ok then return false,err end
    if old and decodeSession(old) then
        ok,err=writeFile(Save.backup,old)
        if not ok then return false,err end
    end
    ok,err=writeFile(Save.filename,data)
    if not ok then return false,err end
    pcall(love.filesystem.remove,"campaign-exploration-v1.tmp.json")
    return true
end

function Save.load()
    local raw,err=readFile(Save.filename)
    if raw then
        local session; session,err=decodeSession(raw)
        if session then return session,session.recoveryNotice end
    end
    local backup=readFile(Save.backup)
    if backup then
        local session=decodeSession(backup)
        if session then return session,"Se recuperó la copia anterior del guardado." end
    end
    for _,path in ipairs({"campaign-v8.json","campaign-v8.backup.json","campaign-v7.json","campaign-v7.backup.json","campaign-v6.json","campaign-v6.backup.json","campaign-v5.json","campaign-v5.backup.json","campaign-v4.json","campaign-v4.backup.json"}) do
        local previous=readFile(path)
        local decoded=previous and Json.decode(previous)
        if type(decoded)=="table" and (decoded.version==4 or decoded.version==5 or decoded.version==6 or decoded.version==7 or decoded.version==8) then
            local session=Save.validate(decoded)
            if session then return session,"Campaña recuperada. El original se conserva; se guardará en campaign-exploration-v1.json." end
        end
    end
    return nil,err or "No hay guardado válido disponible."
end
function Save.exists() return Save.load()~=nil end

-- The UI explicitly offers a new continuity. Original files stay untouched.
function Save.legacyInfo()
    for _,path in ipairs({"campaign-v3.json","campaign-v3.backup.json","campaign-v2.json","campaign-v2.backup.json",Save.legacyFilename,Save.legacyBackup}) do
        local raw=readFile(path)
        local input=raw and Json.decode(raw)
        if type(input)=="table" and input~=Json.null and (input.version==3 or input.version==2 or input.version==1 or input.version==nil) and next(input) then
            return {source=path,day=number(input.day,1,1,7),checkpoint=type(input.checkpoint)=="string" and input.checkpoint or "intro",
                unlocked=map(input.unlocked,true),options=Options.normalize(input.options)}
        end
    end
end
function Save.migrateLegacy(accepted)
    if accepted~=true then return nil,"Confirma la nueva continuidad de la maldición antes de importar la colección." end
    local legacy=Save.legacyInfo()
    if not legacy then return nil,"No hay una partida anterior compatible para importar." end
    local s=Save.newSession()
    s.options=legacy.options
    local count=0
    for id in pairs(legacy.unlocked) do if CardData.byId[id] or require("src.data.combat_cards").byId[id] then s.unlocked[id]=true; count=count+1 end end
    s.migration={source=legacy.source,previousDay=legacy.day,previousCheckpoint=legacy.checkpoint,acceptedContinuity=true,importedCards=count}
    return s,"Nueva campaña matrimonial: se conservó la colección compatible y el guardado original."
end
function Save.readOptions()
    local data=readFile(Save.optionsFile)
    if not data then return Options.normalize() end
    return Options.normalize(Json.decode(data))
end
function Save.writeOptions(value)
    local data,err=Json.encode(Options.normalize(value))
    if not data then return false,err end
    return writeFile(Save.optionsFile,data)
end
return Save
