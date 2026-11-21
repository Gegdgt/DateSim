local Relationships=require("src.systems.relationships")
local Characters=require("src.data.characters")
local CardData=require("src.data.cards")
local Events={}
function Events.mark(session,id)
    session.events=session.events or {}
    session.events[id]=true
    session.events_by_day=session.events_by_day or {}
    local dayKey=tostring(session.day)
    session.events_by_day[dayKey]=session.events_by_day[dayKey] or {}
    session.events_by_day[dayKey][id]=true
    if session.daily and session.daily.day==session.day then session.daily.events[id]=true end
end
local states={pending=true,kept=true,broken=true}
local function knownCard(id)
    return CardData.byId[id] or require("src.data.combat_cards").byId[id]
end
local function validate(effect,depth)
    if type(effect)~="table" or (depth or 0)>4 then return false,"Efecto narrativo inválido." end
    if effect.character and not Characters.byId[effect.character] then return false,"Personaje desconocido." end
    if effect.clue and not require("src.data.documents")[effect.clue] then return false,"Documento desconocido." end
    if effect.promise and (type(effect.promise)~="table" or type(effect.promise.id)~="string"
        or not states[effect.promise.status]) then return false,"Promesa inválida." end
    if effect.critical and (type(effect.critical)~="table" or type(effect.critical.id)~="string"
        or (type(effect.critical.value)~="boolean" and type(effect.critical.value)~="string")) then return false,"Decisión crítica inválida." end
    for _,field in ipairs({"conflict","reconcile","sharedMoment","relationshipEvent"}) do
        if effect[field]~=nil and type(effect[field])~="string" then return false,"Identificador narrativo inválido." end
    end
    for _,id in ipairs(effect.unlock or {}) do if not knownCard(id) then return false,"Carta desconocida: "..tostring(id) end end
    for _,child in ipairs(effect.batch or {}) do
        local ok,err=validate(child,(depth or 0)+1); if not ok then return false,err end
    end
    return true
end

-- A batch is validated before mutation. The parent event is the transaction
-- key; loading, revisiting or retrying cannot grant a reward twice.
function Events.apply(session,id,effects)
    assert(type(id)=="string","El evento necesita identificador")
    if session.events and session.events[id] then return false end
    effects=effects or {}
    local valid,err=validate(effects,0)
    if not valid then return false,err end
    local function permitted(effect)
        if effect.revealSecret and not require("src.systems.curse").canReveal(session,effect.character) then return false end
        if effect.cure and not (session.inventory and session.inventory.antidote) then return false end
        for _,child in ipairs(effect.batch or {}) do if not permitted(child) then return false end end
        return true
    end
    if not permitted(effects) then return false,"La maldición impide esta acción; necesitas el antídoto." end
    session.events=session.events or {}; session.decisions=session.decisions or {}
    session.unlocked=session.unlocked or {}; session.rewardQueue=session.rewardQueue or {}
    session.journal=session.journal or {}; session.rewards=session.rewards or {}
    local newlyUnlocked={}
    local function unlock(cardId)
        if not session.unlocked[cardId] then session.unlocked[cardId]=true; newlyUnlocked[#newlyUnlocked+1]=cardId end
    end
    local function apply(effect,path,inheritedText,inheritedHidden)
        local delta={love=0,trust=0}
        if effect.character and session.relationships[effect.character] then
            delta=Relationships.preview(session.relationships,effect.character,effect)
            Relationships.record(session.relationships,effect.character,effect,path,session.day)
        end
        if effect.decision then session.decisions[effect.decision]=effect.value end
        session.curse=session.curse or require("src.systems.curse").new()
        session.clues=session.clues or {}; session.inventory=session.inventory or {}
        if effect.clue then session.clues[effect.clue]=true end
        if effect.discoverVoice then session.curse.discoveredVoice=true end
        if effect.discoverMana then session.curse.discoveredMana=true end
        if effect.externalEnergy then session.externalEnergy=math.min(30,(session.externalEnergy or 0)+effect.externalEnergy) end
        if effect.antidote then session.inventory.antidote=true end
        if effect.cure then
            session.inventory.antidote=false; session.inventory.antidoteUsed=true
            session.curse.active=false; session.curse.voiceSealed=false; session.curse.manaBlocked=false
        end
        if effect.route and session.day>=5 and session.relationships[effect.route] then session.route=effect.route end
        for _,cardId in ipairs(effect.unlock or {}) do unlock(cardId) end
        if effect.starter or effect.equipStarter then
            if #session.deck==0 then
                for i,cardId in ipairs(CardData.starterDeck) do unlock(cardId); session.deck[i]=cardId end
            end
            session.combatDeck=session.combatDeck or {}
            if #session.combatDeck==0 then
                for i,cardId in ipairs(require("src.data.combat_cards").starterDeck or {}) do unlock(cardId); session.combatDeck[i]=cardId end
            end
        end
        for _,field in ipairs({"mission","enemyDefeated","familyEvent"}) do
            if effect[field] then
                local dest=({mission="missions",enemyDefeated="defeatedEnemies",familyEvent="familyEvents"})[field]
                session[dest]=session[dest] or {}; session[dest][effect[field]]=true
            end
        end
        local text=effect.text or effect.label or inheritedText
        if not text then
            if effect.starter or effect.equipStarter then text="Nanahoshi entrega el mazo inicial."
            elseif effect.character and Characters.byId[effect.character] then text="Decisión compartida con "..Characters.byId[effect.character].shortName
            else text=(id:gsub("_"," ")) end
        end
        local hidden=effect.hidden==true or inheritedHidden==true
        session.journal[#session.journal+1]={id=path,eventId=id,day=session.day,checkpoint=session.checkpoint,
            character=effect.character,context=effect.context or effects.context or "story",text=text,
            decision=effect.decision,value=effect.value,love=delta.love,trust=delta.trust,hidden=hidden,
            conflict=effect.conflict,reconcile=effect.reconcile,promise=effect.promise and effect.promise.id,
            promiseStatus=effect.promise and effect.promise.status,critical=effect.critical and effect.critical.id}
        for i,child in ipairs(effect.batch or {}) do apply(child,path..":"..i,text,hidden) end
    end
    apply(effects,id)
    Events.mark(session,id)
    if #newlyUnlocked>0 then
        if session.daily and session.daily.day==session.day then
            session.daily.rewards_granted=session.daily.rewards_granted or {}
            for _,cardId in ipairs(newlyUnlocked) do session.daily.rewards_granted[#session.daily.rewards_granted+1]=cardId end
        end
        local presenter=effects.presenter or effects.character or "nanahoshi"
        if not Characters.byId[presenter] then presenter="nanahoshi" end
        session.rewardQueue[#session.rewardQueue+1]={id="reward_"..id,eventId=id,cards=newlyUnlocked,presenter=presenter}
        session.rewards[id]=true
    end
    return true
end

return Events
