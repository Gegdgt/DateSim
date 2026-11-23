local Social=require("src.data.cards")
local Combat=require("src.data.combat_cards")
local Config=require("src.data.card_progression")
local Collection={list={},byId={}}
local function copy(t) local out={}; for k,v in pairs(t or {}) do out[k]=v end; return out end
for _,catalog in ipairs({Social.list,Combat.list}) do
    for _,card in ipairs(catalog) do Collection.list[#Collection.list+1]=card;Collection.byId[card.id]=card end
end
function Collection.ensure(session)
    session.collection=session.collection or {};session.unlocked=session.unlocked or {}
    for _,card in ipairs(Collection.list) do
        local entry=session.collection[card.id]
        if not entry then entry={id=card.id,level=1,copies=0,unlocked=session.unlocked[card.id]==true};session.collection[card.id]=entry end
        if session.unlocked[card.id] then entry.unlocked=true end
        if entry.unlocked then session.unlocked[card.id]=true end
    end
    return session.collection
end
function Collection.level(session,id)
    local entry=session and session.collection and session.collection[id]
    local level=entry and entry.level or (session and session.cardLevels and session.cardLevels[id]) or 1
    return math.max(1,math.min(10,math.floor(tonumber(level) or 1)))
end
function Collection.levels(session)
    local levels={}
    for _,card in ipairs(Collection.list) do levels[card.id]=Collection.level(session,card.id) end
    return levels
end
function Collection.class(id) return Config.combat[id] and Config.combat[id].class or "basic" end
function Collection.socialEffects(id,level,contextEffect)
    local base=Config.social[id] or {love=0,trust=0}
    local effect=copy(contextEffect or base)
    local factor=1+math.floor((level-1)/2)
    for _,key in ipairs({"love","trust"}) do
        if (effect[key] or 0)>0 then effect[key]=math.max(0,base[key] or 0)*factor end
    end
    return effect
end
function Collection.combatEffects(id,level,base)
    local out=copy(base)
    local spec=Config.combat[id]
    if not spec then return out end
    for _,key in ipairs({"damage","shield","heal"}) do
        if spec[key] then
            local range=spec[key]
            out[key]=math.floor(range[1]+(range[2]-range[1])*((level-1)/9)^Config.classes[spec.class].exponent+.5)
        end
    end
    -- Robos, maná, energía, estados y número de usos NO escalan.
    return out
end
function Collection.combatCosts(id,level,base)
    local class=Collection.class(id)
    local out={cost=base.cost,manaCost=base.manaCost or 0,hpCost=base.hpCost or 0,
        perBattle=base.perBattle or (base.effects and base.effects.heal and Combat.rules.healUses)}
    local rules=Config.costRules
    if level>=rules.fromLevel and class=="ultimate" then
        out.manaCost=rules.ultimate.mana;out.hpCost=rules.ultimate.hp;out.perBattle=rules.ultimate.uses
    elseif level>=rules.fromLevel and (class=="advanced" or class=="special") then
        out.manaCost=math.min(rules.advanced.maxMana,out.manaCost+rules.advanced.extraMana);out.perBattle=rules.advanced.uses
    end
    return out
end
function Collection.view(session,id,overrideLevel)
    local card=Collection.byId[id];if not card then return nil end
    local entry=Collection.ensure(session)[id]
    local level=overrideLevel or entry.level
    local combat=Combat.byId[id] or card.combat
    local class=Collection.class(id)
    local costs=combat and Collection.combatCosts(id,level,combat)
    local gold=Config.goldRequired(level,class)
    local discount=session.family and session.family.discounts>0 and level<10
    if discount then gold=math.max(1,math.floor(gold*(1-require("src.data.family").discountPercent/100))) end
    return {id=id,name=card.name,level=level,copies=entry.copies,unlocked=entry.unlocked,maxLevel=10,
        type=Social.byId[id] and (combat and "Híbrida" or "Social") or "Combate",class=class,className=Config.classes[class].name,
        baseEffect=Social.byId[id] and Collection.socialEffects(id,1),effect=Social.byId[id] and Collection.socialEffects(id,level),
        baseCombatEffect=combat and Collection.combatEffects(id,1,combat.effects),combatEffect=combat and Collection.combatEffects(id,level,combat.effects),
        copiesRequired=Config.copiesRequired(level),goldRequired=gold,discount=discount,
        socialCost=Social.byId[id] and card.cost,combatCost=costs and costs.cost,manaCost=costs and costs.manaCost,hpCost=costs and costs.hpCost,perBattle=costs and costs.perBattle}
end
function Collection.grant(session,id,count)
    if not Collection.byId[id] or type(count)~="number" or count%1~=0 or count<1 or count>10000 then return nil,"Recompensa de copias inválida." end
    local entry=Collection.ensure(session)[id]
    local new=not entry.unlocked
    if new then entry.unlocked=true;entry.level=1;session.unlocked[id]=true end
    entry.copies=entry.copies+count-(new and 1 or 0)
    return {cardId=id,count=count,new=new,duplicates=count-(new and 1 or 0)}
end
function Collection.canUpgrade(session,id)
    local view=Collection.view(session,id)
    if not view or not view.unlocked then return false,"Primero adquiere la carta." end
    if view.level==10 then return false,"Nivel máximo." end
    if session.combat or session.encounter then return false,"Termina el encuentro antes de mejorar." end
    local activity=session.daily and session.daily.active_activity
    if activity and activity.socialVersion and activity.phase~="service" then return false,"Termina la conversación antes de mejorar." end
    if view.copies<view.copiesRequired then return false,"Faltan "..(view.copiesRequired-view.copies).." copias." end
    if (session.gold or 0)<view.goldRequired then return false,"Faltan "..(view.goldRequired-(session.gold or 0)).." de oro." end
    return true
end
function Collection.upgrade(session,id,revision)
    local ok,err=Collection.canUpgrade(session,id);if not ok then return nil,err end
    local before=Collection.view(session,id)
    local receipt;receipt,err=require("src.systems.economy").spend(session,before.goldRequired,revision,"upgrade_"..id)
    if not receipt then return nil,err end
    local entry=session.collection[id]
    entry.copies=entry.copies-before.copiesRequired;entry.level=entry.level+1
    if before.discount then session.family.discounts=session.family.discounts-1 end
    receipt.cardId=id;receipt.level=entry.level;receipt.copies=before.copiesRequired
    return {before=before,after=Collection.view(session,id),receipt=receipt}
end
return Collection
