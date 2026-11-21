-- Reglas puras: no audio, gráficos, campaña ni escritura de archivos.
-- El registro de comandos permite restaurar y reintentar sin repetir premios.
local Data=require("src.data.cards")
local Techniques=require("src.data.combat_cards")
local Enemies=require("src.data.enemies")
local Training=require("src.systems.training")
local Collection=require("src.systems.card_collection")
local Companions=require("src.systems.companions")
local Balance=require("src.data.battle_balance")
local Legacy=require("src.systems.combat_legacy")
local Combat={rules=Techniques.rules}
local R=Techniques.rules
local function copy(value)
    if type(value)~="table" then return value end
    local out={}; for k,v in pairs(value) do out[k]=copy(v) end; return out
end
local function integer(value,min,max)
    return type(value)=="number" and value==value and value%1==0 and value>=min and value<=max
end
local function same(a,b)
    if type(a)~=type(b) then return false end
    if type(a)~="table" then return a==b end
    for k,v in pairs(a) do if not same(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end
    return true
end
local function contextFor(context)
    context=context or {}
    return {kind="combat",warVersion=1,allies=context.enemyId=="eris_training" and {} or Companions.roster(context),character=context.character,tutorial=context.tutorial==true,
        progressionVersion=1,cardLevels=Collection.levels(context),preparationShield=context.preparationShield==4 and 4 or 0,
        day=integer(context.day,1,7) and context.day or nil,
        difficulty=integer(context.difficulty,1,7) and context.difficulty or nil,
        enemyId=Enemies.byId[context.enemyId] and Enemies.byId[context.enemyId].id or Enemies.default,
        tacticalContext=copy(context.tacticalContext or {}),
        curse={active=context.curse and context.curse.active==true or false,
            manaBlocked=context.curse and context.curse.manaBlocked==true or false},
        externalEnergy=math.max(0,math.min(30,tonumber(context.externalEnergy) or 0))}
end

local function baseCard(id)
    local base=Techniques.byId[id]
    if base then return copy(base) end
    local original=Data.byId[id]
    if not original or not original.combat then return nil end
    local view=copy(original)
    view.socialCost=original.cost
    view.cost=original.combat.cost
    view.manaCost=original.combat.manaCost or (original.combat.cost*2)
    view.hpCost=original.combat.hpCost or 0
    view.element=original.combat.element or "earth"
    view.resource=original.combat.resource or "artifact"
    view.effects=copy(original.combat.effects)
    view.description=original.combat.description
    view.perTurn=original.combat.perTurn
    view.perBattle=original.combat.perBattle or (view.effects.heal and R.healUses)
    return view
end
function Combat.card(id,state)
    local card=baseCard(id);if not card then return nil end
    if state and state.context and state.context.progressionVersion~=1 then return card end
    local level=Collection.level(state and (state.context or state) or {},id)
    card.effects=Collection.combatEffects(id,level,card.effects)
    local costs=Collection.combatCosts(id,level,card)
    card.cost,card.manaCost,card.hpCost,card.perBattle=costs.cost,costs.manaCost,costs.hpCost,costs.perBattle
    card.level=level
    return card
end

function Combat.describe(card,enc)
    if type(card)=="string" then card=Combat.card(card,enc) end
    if not card then return "Solo encuentros sociales." end
    if card.combat and not card.socialCost then card=Combat.card(card.id,enc) end
    local e=card.effects or {}; local parts={}
    if e.damage then parts[#parts+1]=e.damage.." daño" end
    if e.shield then parts[#parts+1]="+"..e.shield.." escudo" end
    if e.heal then parts[#parts+1]="+"..e.heal.." vida (máx. "..R.playerHp..")" end
    if e.mana then parts[#parts+1]="+"..e.mana.." maná" end
    if e.energy then parts[#parts+1]="+"..e.energy.." energía" end
    if e.draw then parts[#parts+1]="roba "..e.draw end
    if e.weak then parts[#parts+1]="debilita (-2 daño, "..e.weak.." turno(s))" end
    if e.vulnerable then parts[#parts+1]="vulnerable (+2 daño recibido, este turno)" end
    if card.perTurn then parts[#parts+1]="máx. "..card.perTurn.."/turno" end
    if card.perBattle and not (enc and enc.balanceVersion==1) then parts[#parts+1]="máx. "..card.perBattle.."/combate" end
    return table.concat(parts,"; ")..". Coste: "..card.cost.." A / "..(card.manaCost or 0).." M / "..(card.hpCost or 0).." PV."
end

function Combat.validateDeck(deck,unlocked)
    if type(deck)~="table" or #deck<5 or #deck>10 then return false,"El mazo de combate necesita entre cinco y diez cartas." end
    local seen,offense={},0
    for _,id in ipairs(deck) do
        local c=Combat.card(id)
        if not c then return false,"Carta sin uso de combate: "..tostring(id) end
        if seen[id] then return false,"El mazo contiene una carta repetida." end
        if unlocked and unlocked[id]~=true then return false,"Carta bloqueada: "..c.name end
        seen[id]=true
        if (c.effects.damage or 0)>0 then offense=offense+1 end
    end
    if offense<2 then return false,"Equipa al menos dos ataques ofensivos viables." end
    return true
end

function Combat.adaptDeck(deck,context)
    context=context or {}
    local selected=context.combatDeck or Techniques.starterDeck
    local ok,err=Combat.validateDeck(selected,context.unlocked)
    if not ok then return nil,err end
    local adapted,seen,adjustments={},{},{}
    for _,id in ipairs(selected) do
        local c=Combat.card(id)
        if not c.conditions or not c.conditions.character or Companions.roster(context)[c.conditions.character] then
            adapted[#adapted+1]=id;seen[id]=true
        else adjustments[#adjustments+1]=c.name..": sin su compañera, sustituida por una técnica adquirida." end
    end
    for _,id in ipairs(Techniques.starterDeck) do
        if #adapted>=#selected then break end
        if not seen[id] and (not context.unlocked or context.unlocked[id]) then adapted[#adapted+1]=id;seen[id]=true end
    end
    ok,err=Combat.validateDeck(adapted,context.unlocked)
    if not ok then return nil,err end
    return adapted,nil,adjustments
end
Combat.buildDeck=Combat.adaptDeck

local function random(enc,n)
    enc.randomState=(enc.randomState*48271)%2147483647
    return enc.randomState%n+1
end
local function shuffle(enc,pile)
    for i=#pile,2,-1 do local j=random(enc,i); pile[i],pile[j]=pile[j],pile[i] end
end
local function event(result,kind,target,text,fields)
    local value=fields or {}; value.kind=kind; value.target=target; value.text=text
    result.events[#result.events+1]=value
    return value
end
local function label(target) return target=="enemy" and "El enemigo" or target=="companion" and "La compañera" or "Rudy" end
local function damageAmount(attacker,defender,base)
    if base<=0 then return 0 end
    return math.max(0,base-(attacker.weak>0 and R.weakReduction or 0))+(defender.vulnerable>0 and R.vulnerableBonus or 0)
end
local function elementalDamage(enc,card)
    local bonus=card.element and card.element==enc.enemy.weakness and (enc.enemy.id=="badigadi_final" and Balance.boss.weaknessBonus or 2) or 0
    local config=Training.config(enc)
    local reduction=config and card.element=="sword" and config.swordReduction or 0
    local armor=enc.enemy.phase=="resolve" and enc.enemy.exposed<=0 and Balance.boss.armor or 0
    return math.max(0,(card.effects.damage or 0)+bonus-reduction-armor),bonus,reduction
end
local function damage(enc,target,base,result,source)
    local defender=enc[target]
    local attacker=source or (target=="enemy" and enc.player or enc.enemy)
    local attempted=damageAmount(attacker,defender,base)
    local blocked=math.min(defender.shield,attempted)
    local lost=math.min(defender.hp,attempted-blocked)
    local dodged=target=="player" and Training.dodgeAbsorbed(enc,blocked,defender.shield) or nil
    defender.shield=defender.shield-blocked
    if target=="player" then
        local physical=math.min(defender.physicalShield or 0,blocked)
        defender.physicalShield=math.max(0,(defender.physicalShield or 0)-physical)
        defender.magicShield=math.max(0,(defender.magicShield or 0)-(blocked-physical))
    end
    defender.hp=math.max(0,defender.hp-lost)
    event(result,"damage",target,label(target)..": "..attempted.." daño, "..blocked.." bloqueado, "..lost..(enc.training and " resistencia perdida." or " vida perdida."),
        {rawDamage=base,damage=attempted,blocked=blocked,hpLost=lost,amount=lost,dodgeBlocked=dodged})
end
local function draw(enc,count,result)
    local drawn=0
    for _=1,count do
        if #enc.drawPile==0 and #enc.discard>0 then
            enc.drawPile=enc.discard; enc.discard={}; shuffle(enc,enc.drawPile)
            if result then event(result,"shuffle","player","Se baraja el descarte para formar un nuevo mazo.") end
        end
        if #enc.drawPile==0 then break end
        enc.hand[#enc.hand+1]=table.remove(enc.drawPile); drawn=drawn+1
    end
    if result and drawn>0 then event(result,"draw","player","Rudy roba "..drawn.." carta(s).",{amount=drawn}) end
    return drawn
end
local function activeAction(enc)
    if enc.enemy.id=="badigadi_final" and Balance.boss.phases[enc.enemy.phase] then
        local actions=Balance.boss.phases[enc.enemy.phase]
        return actions[(enc.enemy.actionIndex-1)%#actions+1]
    end
    if enc.enemy.phase=="seal" then return {id="seal_pulse",name="Pulso del sello",kind="attack",damage=3} end
    if enc.enemy.phase=="six_arms" then
        if enc.enemy.actionIndex%2==1 then return {id="six_arms",name="Seis brazos",kind="attack",damage=3,hits=3,companionDamage=2} end
        return {id="royal_breath",name="Recobrar postura",kind="prepare",nextDamage=9}
    end
    local action=enc.enemy.actions[enc.enemy.actionIndex]
    if action.maxUses and (enc.enemy.actionUses[action.id] or 0)>=action.maxUses then
        return {id=action.id.."_exhausted",name="Defensa agotada",kind="recover"}
    end
    return action
end
local function intent(enc)
    local action=copy(activeAction(enc))
    if action.kind=="attack" then
        action.baseDamage=action.damage
        action.damage=damageAmount(enc.enemy,enc.player,action.baseDamage)
        action.text=action.name..": "..action.damage.." daño"..(action.hits and " × "..action.hits or "").."."
        if enc.enemy.weak>0 then action.text=action.text.." Debilitado: -2." end
        if enc.player.vulnerable>0 then action.text=action.text.." Rudy vulnerable: +2." end
        if action.companionDamage and enc.companion then action.text=action.text.." Compañera: "..action.companionDamage.." daño." end
    elseif action.kind=="shield" then
        action.text=action.name..": +"..action.shield.." escudo"..(action.maxUses and " ("..(action.maxUses-(enc.enemy.actionUses[action.id] or 0)).." usos)" or "").."."
    elseif action.kind=="prepare" then action.text=action.name..": prepara "..action.nextDamage.." daño para su siguiente acción."
    elseif action.kind=="interrupt" then action.text=action.name..": -"..action.actionLoss.." acción en el próximo turno de Rudy."
    elseif action.kind=="recover" then action.text=action.name..": no recuperará más escudo."
    else action.text=action.name..": Rudy causará 2 menos de daño durante su próximo turno." end
    action.description=action.text
    enc.enemy.intent=action
end
local function updateIntent(enc,result)
    local old=enc.enemy.intent and enc.enemy.intent.text
    intent(enc)
    if old~=enc.enemy.intent.text and result then
        event(result,"intent","enemy","Intención actualizada por el estado activo: "..enc.enemy.intent.text)
    end
end
local function finish(enc,outcome,result,cause)
    if Training.config(enc) and outcome=="defeat" then
        cause="Eris detiene la espada de práctica al agotarse la resistencia de Rudy. El ejercicio termina sin heridas."
    end
    enc.finished=true; enc.outcome=outcome; enc.cause=cause
    if outcome=="victory" then
        event(result,"victory","enemy",enc.enemy.defeatText)
    else event(result,"defeat","player",cause or "La vida de Rudy llegó a cero.") end
end
local function checkOutcome(enc,result)
    if enc.enemy.id=="badigadi_final" and not enc.enemy.sealBroken then
        if enc.enemy.hp<=0 and enc.enemy.phase~="seal" then
            enc.enemy.phase="seal";enc.enemy.shield=0
            event(result,"phase","enemy","Fase 4 · Romper la protección del antídoto. Badigadi cede, pero sigue vivo. Usa Romper sello [B].")
            updateIntent(enc,result)
        elseif enc.enemy.hp<=enc.enemy.maxHp*Balance.boss.thresholds[2] and enc.enemy.phase~="resolve" and enc.enemy.phase~="seal" then
            enc.enemy.phase="resolve";enc.enemy.actionIndex=1
            event(result,"phase","enemy","Fase 3 · Resistencia mejorada: 6 menos de daño por ataque. Agua, análisis y ataques combinados abren su defensa.")
            updateIntent(enc,result)
        elseif enc.enemy.hp<=enc.enemy.maxHp*Balance.boss.thresholds[1] and enc.enemy.phase=="endurance" then
            enc.enemy.phase="six_arms"
            enc.enemy.actionIndex=1
            event(result,"phase","enemy","Fase 2 · Seis brazos. Anuncia tres golpes consecutivos: defiéndete y coordina a tu compañera.")
            updateIntent(enc,result)
        end
    elseif enc.enemy.hp<=0 then finish(enc,"victory",result); return true end
    if enc.player.hp<=0 then finish(enc,"defeat",result,"La vida de Rudy llegó a cero por la acción enemiga."); return true end
    return false
end
local function record(enc,result,command)
    result.turn=result.turn or enc.turn
    if enc.training then
        Training.observe(enc,result,command)
        if not enc.finished and Training.goalReached(enc) then finish(enc,"victory",result) end
        if enc.finished then enc.trainingResult=Training.complete(enc) end
    end
    local text={}
    for _,entry in ipairs(result.events) do text[#text+1]=entry.text end
    result.text=table.concat(text," ")
    enc.log[#enc.log+1]=result
    enc.resultEvents=copy(result.events)
    enc.commands[#enc.commands+1]=command
    enc.revision=enc.revision+1
    return result
end

local function start(deck,context,initial,legacyBalance)
    local enemy=legacyBalance and copy(Enemies.byId[context.enemyId]) or Enemies.resolve(context.enemyId,context)
    enemy.hp=enemy.maxHp; enemy.shield=0; enemy.weak=0; enemy.vulnerable=0; enemy.actionIndex=1
    enemy.actionUses={}
    enemy.exposed=0
    enemy.defeatEvent=enemy.defeatedEvent
    if enemy.id=="badigadi_final" then enemy.phase="endurance";enemy.seal=enemy.sealMax;enemy.sealBroken=false end
    local enc={type="combat",version=2,balanceVersion=3,context=copy(context),deck=copy(deck),initial=copy(initial),
        player={name="Rudy",hp=R.playerHp,maxHp=R.playerHp,mana=context.curse.manaBlocked and 0 or R.playerMana,maxMana=R.playerMana,externalEnergy=context.externalEnergy,maxExternalEnergy=context.externalEnergy,physicalShield=0,magicShield=0,shield=0,weak=0,vulnerable=0},enemy=enemy,
        hand={},drawPile=copy(initial.pile),discard={},energy=R.energy,turn=1,maxTurns=R.maxTurns,
        revision=0,finished=false,perTurn={},perBattle={},companionHeals=0,randomState=initial.seed,commands={},log={},resultEvents={},relationshipEvents={},tacticalDecisions={}}
    enc.training=Training.new(enemy.trainingId)
    enc.allies=enc.training and {} or copy(context.allies)
    enc.supportUsed={}
    if enemy.id=="badigadi_final" then enc.maxTurns=Balance.boss.maxTurns end
    enc.player.shield=context.preparationShield or 0
    enc.player.physicalShield=context.preparationShield or 0
    if enc.training then enc.maxTurns=Training.config(enc).maxTurns end
    enc.companion=enc.allies[context.character]
    if not enc.companion then for _,id in ipairs(Companions.order) do if enc.allies[id] then enc.companion=enc.allies[id];break end end end
    draw(enc,R.handSize)
    intent(enc)
    enc.log[1]={turn=1,text="Comienza el combate. Rudy: "..R.playerHp.." vida, "..(legacyBalance and R.playerMana or enc.player.mana).." maná, 3 acciones. "..enemy.intent.text,events={}}
    return enc
end

function Combat.new(deck,context,rng)
    if context and context.legacyEncounter then return Legacy.new(deck,context,rng) end
    local adapted,err,adjustments=Combat.adaptDeck(deck,context)
    assert(adapted,err)
    context=contextFor(context)
    rng=rng or (love and love.math and love.math.random) or math.random
    local seed=rng(2147483646)
    if not integer(seed,1,2147483646) then seed=1 end
    local scratch={randomState=seed}; local pile=copy(adapted)
    shuffle(scratch,pile)
    if context.tutorial then
        -- Último elemento se roba primero. Primera mano y segundo turno guiados.
        local order,available={},{}
        for _,id in ipairs(adapted) do available[id]=true end
        for _,id in ipairs({"staff_strike","push","stone_throw","simple_cut","coordinated_attack"}) do
            if available[id] then order[#order+1]=id end
        end
        local used={}; for _,id in ipairs(order) do used[id]=true end
        for _,id in ipairs(adapted) do if not used[id] then order[#order+1]=id end end
        pile={}; for i=#order,1,-1 do pile[#pile+1]=order[i] end
    end
    local enc=start(adapted,context,{pile=pile,seed=scratch.randomState})
    enc.deckAdjustments=adjustments
    return enc
end

local function resourceField(enc,card)
    if (card.manaCost or 0)==0 then return "mana" end
    if enc.context.curse.manaBlocked then
        if card.resource=="natural" then return nil end
        return "externalEnergy"
    end
    return "mana"
end
local function resourceName(field) return field=="externalEnergy" and "energía externa" or "maná natural" end
function Combat.canPlay(enc,index)
    if type(enc)~="table" or enc.type~="combat" then return false,"No hay un combate activo." end
    if enc.finished then return false,"El combate ya terminó." end
    if not integer(index,1,#enc.hand) then return false,"Selecciona una carta de la mano." end
    local card=Combat.card(enc.hand[index],enc)
    if not card then return false,"Esta carta solo funciona en encuentros sociales." end
    if card.conditions and card.conditions.character and not enc.allies[card.conditions.character] then
        return false,"Requiere la compañía de "..card.conditions.character.."."
    end
    if card.perTurn and (enc.perTurn[card.id] or 0)>=card.perTurn then return false,"Esta carta ya alcanzó su límite por turno." end
    if enc.balanceVersion~=1 and card.perBattle and (enc.perBattle[card.id] or 0)>=card.perBattle then return false,"Esta carta agotó sus "..card.perBattle.." usos por combate." end
    if enc.balanceVersion~=1 and card.effects.heal and not card.effects.damage and enc.player.hp>=enc.player.maxHp then return false,"Rudy ya tiene la vida máxima." end
    if enc.energy<card.cost then return false,"Necesita "..card.cost.." energía; tienes "..enc.energy.."." end
    local field=resourceField(enc,card)
    if not field then return false,"MANÁ: BLOQUEADO. La magia natural no funciona hasta usar el antídoto." end
    if enc.player[field]<(card.manaCost or 0) then return false,"Necesita "..card.manaCost.." "..resourceName(field).."; tienes "..enc.player[field].."." end
    if enc.player.hp<=(card.hpCost or 0) then return false,"El esfuerzo de espada debe dejar a Rudy al menos 1 PV." end
    return true
end

function Combat.preview(enc,index)
    local card=Combat.card(enc.hand[index],enc); if not card then return nil end
    local preview={cardId=card.id,cost=card.cost,manaCost=card.manaCost or 0,hpCost=card.hpCost or 0,effects=copy(card.effects),text=Combat.describe(card,enc)}
    if card.perBattle and enc.balanceVersion~=1 then
        preview.usesLeft=math.max(0,card.perBattle-(enc.perBattle[card.id] or 0))
        preview.text=preview.text.." Usos restantes: "..preview.usesLeft.."."
    end
    if card.effects.damage then
        local base,bonus,reduction=elementalDamage(enc,card)
        preview.elementBonus=bonus
        if reduction>0 then preview.trainingSwordReduction=reduction end
        preview.damage=damageAmount(enc.player,enc.enemy,base)
        preview.blocked=math.min(enc.enemy.shield,preview.damage)
        preview.hpLost=math.min(enc.enemy.hp,preview.damage-preview.blocked)
        preview.text=preview.text.." Ahora: "..preview.damage.." daño / "..preview.blocked.." bloqueo / "..preview.hpLost.." vida."
    end
    return preview
end

function Combat.play(enc,index,expectedRevision)
    if expectedRevision~=nil and expectedRevision~=enc.revision then return nil,"Esta acción ya fue procesada." end
    local ok,err=Combat.canPlay(enc,index); if not ok then return nil,err end
    local card=Combat.card(enc.hand[index],enc); local e=card.effects
    local result={cardId=card.id,cost=card.cost,manaCost=card.manaCost or 0,hpCost=card.hpCost or 0,element=card.element,events={}}
    enc.energy=enc.energy-card.cost
    local field=resourceField(enc,card)
    enc.player[field]=enc.player[field]-(card.manaCost or 0)
    enc.player.hp=enc.player.hp-(card.hpCost or 0)
    enc.perTurn[card.id]=(enc.perTurn[card.id] or 0)+1
    enc.perBattle[card.id]=(enc.perBattle[card.id] or 0)+1
    table.remove(enc.hand,index); enc.discard[#enc.discard+1]=card.id
    event(result,"play","player",card.name..": paga "..card.cost.." acción, "..(card.manaCost or 0).." "..resourceName(field).." y "..(card.hpCost or 0).." PV de esfuerzo.",{element=card.element})
    if e.damage then
        local base,bonus,reduction=elementalDamage(enc,card)
        if bonus>0 then event(result,"elemental","enemy","Debilidad elemental aprovechada: +"..bonus.." daño antes de escudo.",{amount=bonus,element=card.element}) end
        if reduction>0 then event(result,"training_guard","enemy","Eris reconoce la técnica de espada y desvía "..reduction.." puntos. Busca otra distancia o un recurso táctico.",{amount=reduction}) end
        damage(enc,"enemy",base,result)
    end
    if e.shield then
        enc.player.shield=enc.player.shield+e.shield
        local shieldKind=(card.manaCost or 0)>0 and "magicShield" or "physicalShield"
        enc.player[shieldKind]=enc.player[shieldKind]+e.shield
        event(result,"shield","player","Rudy gana "..e.shield.." escudo.",{amount=e.shield})
    end
    if e.heal then
        local amount=math.min(e.heal,enc.player.maxHp-enc.player.hp)
        enc.player.hp=math.min(enc.player.maxHp,enc.player.hp+amount)
        event(result,"heal","player","Rudy recupera "..amount.." vida.",{amount=amount})
    end
    if e.energy then
        enc.energy=enc.energy+e.energy
        event(result,"energy","player","Rudy gana "..e.energy.." energía.",{amount=e.energy})
    end
    if e.mana then
        local pool=enc.context.curse.manaBlocked and "externalEnergy" or "mana"
        local maximum=pool=="mana" and enc.player.maxMana or enc.player.maxExternalEnergy
        local amount=math.min(e.mana,maximum-enc.player[pool])
        enc.player[pool]=enc.player[pool]+amount
        event(result,"mana","player","El artefacto recupera "..amount.." "..resourceName(pool)..".",{amount=amount})
    end
    if e.weak then
        enc.enemy.weak=math.max(enc.enemy.weak,e.weak)
        event(result,"status","enemy","Enemigo debilitado: -2 daño durante "..e.weak.." turno(s).",{status="weak",amount=e.weak})
    end
    if e.vulnerable then
        enc.enemy.vulnerable=math.max(enc.enemy.vulnerable,e.vulnerable)
        event(result,"status","enemy","Enemigo vulnerable: +2 daño recibido por golpe hasta terminar tu turno.",{status="vulnerable",amount=e.vulnerable})
    end
    if e.draw then draw(enc,e.draw,result) end
    event(result,"discard","player",card.name.." va al descarte.",{amount=1})
    updateIntent(enc,result)
    checkOutcome(enc,result)
    return record(enc,result,{kind="play",cardId=card.id,index=index})
end

Combat.tactics=Legacy.tactics
require("src.systems.support_actions").install(Combat,{event=event,damage=damage,damageAmount=damageAmount,updateIntent=updateIntent,checkOutcome=checkOutcome,record=record})

function Combat.endTurn(enc,expectedRevision)
    if expectedRevision~=nil and expectedRevision~=enc.revision then return nil,"Esta acción ya fue procesada." end
    if enc.finished then return nil,"El combate ya terminó." end
    if enc.training then
        local available=Combat.canBasic(enc,"counter")==true
        for index,id in ipairs(enc.hand) do
            local card=Combat.card(id,enc)
            if card and (card.effects.damage or 0)>0 and Combat.canPlay(enc,index) then available=true;break end
        end
        Training.beforeEndTurn(enc,available)
    end
    local result={events={},turn=enc.turn,enemyAction=enc.enemy.intent.id,actionName=enc.enemy.intent.name}
    local amount=#enc.hand
    for _,id in ipairs(enc.hand) do enc.discard[#enc.discard+1]=id end
    enc.hand={}
    if amount>0 then event(result,"discard","player","Fin de turno: se descartan "..amount.." cartas de la mano.",{amount=amount}) end
    -- Los estados de Rudy duran su turno completo. Los de la anomalía se
    -- consumen durante su propia acción; vulnerabilidad dura el turno de Rudy.
    enc.player.weak=math.max(0,enc.player.weak-1)
    enc.player.vulnerable=math.max(0,enc.player.vulnerable-1)
    enc.enemy.vulnerable=math.max(0,enc.enemy.vulnerable-1)
    if enc.enemy.shield>0 then
        event(result,"shield_expire","enemy","El escudo anterior de la anomalía desaparece.",{amount=enc.enemy.shield})
        enc.enemy.shield=0
    end
    local action=activeAction(enc)
    enc.enemy.actionUses[action.id]=(enc.enemy.actionUses[action.id] or 0)+1
    event(result,"enemy_action","enemy",enc.enemy.name.." utiliza "..action.name..".")
    if action.kind=="attack" then
        for _=1,(action.hits or 1) do if enc.player.hp>0 then damage(enc,"player",action.damage,result) end end
        if enc.companion and enc.companion.hp>0 and action.companionDamage then damage(enc,"companion",action.companionDamage,result) end
    elseif action.kind=="shield" then
        enc.enemy.shield=action.shield
        event(result,"shield","enemy","La anomalía gana "..action.shield.." escudo.",{amount=action.shield})
    elseif action.kind=="prepare" then
        event(result,"prepare","enemy","Acumula maná: su siguiente acción será un ataque de "..action.nextDamage.." daño.",{amount=action.nextDamage})
    elseif action.kind=="status" then
        enc.player[action.status]=action.duration
        event(result,"status","player","Rudy recibe debilitamiento: -2 daño por golpe durante su próximo turno.",{status=action.status,amount=action.duration})
    elseif action.kind=="interrupt" then
        event(result,"interrupt","player","Rudy pierde "..action.actionLoss.." acción en su próximo turno. Puede seguir usando defensa o cartas.",{amount=action.actionLoss})
    elseif action.kind=="recover" then
        event(result,"recovery_exhausted","enemy","El enemigo agotó sus recuperaciones de escudo.")
    end
    enc.enemy.weak=math.max(0,enc.enemy.weak-1)
    if not checkOutcome(enc,result) then
        if enc.turn>=enc.maxTurns then
            enc.player.hp=0
            finish(enc,"defeat",result,"La amenaza te supera tras "..enc.maxTurns.." turnos. Regresa al punto seguro o reintenta.")
        else
            if enc.player.shield>0 then
                event(result,"shield_expire","player","El escudo normal de Rudy desaparece al comenzar su turno.",{amount=enc.player.shield})
            end
            enc.player.shield=0;enc.player.physicalShield=0;enc.player.magicShield=0; enc.turn=enc.turn+1
            enc.energy=math.max(1,R.energy-(action.kind=="interrupt" and action.actionLoss or 0)); enc.perTurn={}
            enc.supportUsed={};enc.enemy.exposed=math.max(0,enc.enemy.exposed-1)
            local pool=enc.context.curse.manaBlocked and "externalEnergy" or "mana"
            local maximum=pool=="mana" and enc.player.maxMana or enc.player.maxExternalEnergy
            local manaGain=math.min(R.manaRegen,maximum-enc.player[pool])
            enc.player[pool]=enc.player[pool]+manaGain
            if enc.companion then enc.companion.shield=0 end
            event(result,"mana","player","Recarga de turno: +"..manaGain.." "..resourceName(pool)..".",{amount=manaGain})
            draw(enc,math.max(0,R.handSize-#enc.hand),result)
            enc.enemy.actionIndex=enc.enemy.actionIndex%#enc.enemy.actions+1
            intent(enc)
            event(result,"intent","enemy","Próxima intención: "..enc.enemy.intent.text)
        end
    end
    return record(enc,result,{kind="endTurn"})
end

function Combat.canBasic(enc,id)
    if not enc or enc.finished then return false,"El combate ya terminó." end
    if id~="defend" and id~="dodge" and id~="counter" then return false,"Acción básica desconocida." end
    if id=="counter" and (not enc.training or not enc.training.counterReady) then
        return false,"Bloquea o esquiva un ataque real para abrir un contraataque en el turno siguiente."
    end
    if enc.energy<1 then return false,"Necesita una acción." end
    if enc.perTurn[id] then return false,"Una vez por turno." end
    return true
end
function Combat.basic(enc,id,expectedRevision)
    if expectedRevision and expectedRevision~=enc.revision then return nil,"Esta acción ya fue procesada." end
    local ok,err=Combat.canBasic(enc,id);if not ok then return nil,err end
    enc.energy=enc.energy-1;enc.perTurn[id]=true
    if id=="counter" then
        enc.training.counterReady=false
        local result={events={},actionName="Contraataque de entrenamiento"}
        event(result,"counter","player","Rudy aprovecha la apertura defensiva con su bastón. Coste: 1 acción, sin maná.")
        damage(enc,"enemy",Training.config(enc).counter.damage,result)
        updateIntent(enc,result);checkOutcome(enc,result)
        return record(enc,result,{kind="basic",id=id})
    end
    local amount=id=="defend" and 5 or 3
    enc.player.shield=enc.player.shield+amount;enc.player.physicalShield=enc.player.physicalShield+amount
    local result={events={},actionName=id=="defend" and "Defensa básica" or "Esquiva"}
    event(result,"shield","player",result.actionName..": +"..amount.." escudo físico sin maná ni carta.",{amount=amount})
    return record(enc,result,{kind="basic",id=id})
end
function Combat.canBreakSeal(enc)
    return enc and not enc.finished and enc.enemy.phase=="seal" and not enc.enemy.sealBroken and enc.energy>=1
end
function Combat.breakSeal(enc,expectedRevision)
    if expectedRevision and expectedRevision~=enc.revision then return nil,"Esta acción ya fue procesada." end
    if not Combat.canBreakSeal(enc) then return nil,"Agota la resistencia de Badigadi y reserva una acción para el sello." end
    enc.energy=enc.energy-1;enc.enemy.seal=math.max(0,enc.enemy.seal-6)
    local result={events={},actionName="Neutralizar el sello"}
    event(result,"seal","enemy","Rudy golpea los anclajes expuestos del sello: "..enc.enemy.seal.." resistencia restante.",{amount=6})
    if enc.enemy.seal==0 then enc.enemy.sealBroken=true;enc.enemy.phase="victory" end
    checkOutcome(enc,result)
    return record(enc,result,{kind="breakSeal"})
end
function Combat.retry(enc)
    return start(enc.deck,enc.context,enc.initial,enc.balanceVersion==1)
end

-- Reproduce el combate desde la apertura y compara todos los campos de reglas.
-- No confía en vida/energía/resultados escritos en JSON, ni aplica recompensas.
function Combat.restore(snapshot,deck,context)
    if type(snapshot)=="table" and (not snapshot.context or snapshot.context.warVersion~=1) then return Legacy.restore(snapshot,deck,context) end
    if type(snapshot)~="table" or snapshot.type~="combat" or snapshot.version~=2 then return nil end
    local adapted,_,adjustments=Combat.adaptDeck(deck,context); if not adapted then return nil end
    context=contextFor(context)
    -- Los combates v3 de campaña anteriores no tenían versión de balance ni
    -- presupuestos. Se reproducen con sus reglas originales hasta finalizarlos;
    -- nunca se sortea otra mano ni se cambia el enemigo a mitad de la batalla.
    local oldSnapshot=snapshot.balanceVersion==nil and snapshot.perBattle==nil and snapshot.companionHeals==nil
        and type(snapshot.enemy)=="table" and snapshot.enemy.actionUses==nil
        and type(snapshot.context)=="table" and snapshot.context.day==nil and snapshot.context.difficulty==nil
    local legacyBalance=oldSnapshot or snapshot.balanceVersion==1
    if snapshot.context and snapshot.context.progressionVersion~=1 then
        context.progressionVersion,context.cardLevels,context.preparationShield=nil,nil,nil
    end
    if snapshot.balanceVersion~=3 then return nil end
    if legacyBalance then context.day=nil;context.difficulty=nil end
    if not same(snapshot.context,context) or not same(snapshot.deck,adapted) then return nil end
    local initial=snapshot.initial
    if type(initial)~="table" or not integer(initial.seed,1,2147483646) or type(initial.pile)~="table" or #initial.pile~=#adapted then return nil end
    local expected={}; for _,id in ipairs(adapted) do expected[id]=true end
    for _,id in ipairs(initial.pile) do if not expected[id] then return nil end; expected[id]=nil end
    if next(expected) then return nil end
    if type(snapshot.commands)~="table" or #snapshot.commands>1000 then return nil end
    local restored=start(adapted,context,initial,legacyBalance)
    for _,command in ipairs(snapshot.commands) do
        if type(command)~="table" or restored.finished then return nil end
        if command.kind=="play" then
            if not integer(command.index,1,#restored.hand) or restored.hand[command.index]~=command.cardId then return nil end
            if not Combat.play(restored,command.index,restored.revision) then return nil end
        elseif command.kind=="endTurn" then
            if not Combat.endTurn(restored,restored.revision) then return nil end
        elseif command.kind=="basic" then
            if not Combat.basic(restored,command.id,restored.revision) then return nil end
        elseif command.kind=="breakSeal" then
            if not Combat.breakSeal(restored,restored.revision) then return nil end
        elseif command.kind=="tactic" then
            if not Combat.tactic(restored,command.id,restored.revision) then return nil end
        elseif command.kind=="support" then
            if not Combat.support(restored,command.wife,command.id,restored.revision,command.confirmRisk) then return nil end
        else return nil end
    end
    for _,key in ipairs({"player","enemy","hand","drawPile","discard","energy","turn","maxTurns","revision",
        "finished","outcome","cause","perTurn","perBattle","companionHeals","randomState","commands","log","resultEvents","companion","allies","supportUsed","relationshipEvents","tacticalDecisions","training","trainingResult"}) do
        local expected=restored[key]
        if oldSnapshot and key=="enemy" then expected=copy(expected);expected.actionUses=nil end
        if not (oldSnapshot and (key=="perBattle" or key=="companionHeals")) and not same(expected,snapshot[key]) then return nil end
    end
    restored.deckAdjustments=adjustments
    if type(snapshot.tutorial)=="table" then
        restored.tutorial={}
        for key,value in pairs(snapshot.tutorial) do
            if type(key)=="string" and #key<64 and (type(value)=="boolean" or (type(value)=="string" and #value<128)
                or integer(value,0,1000)) then restored.tutorial[key]=value end
        end
    end
    return restored
end

-- Los combates ya guardados conservan reglas, comandos y resultados históricos.
for _,name in ipairs({"canPlay","preview","play","canTactic","tactic","endTurn","canBasic","basic","canBreakSeal","breakSeal","retry"}) do
    local current=Combat[name]
    Combat[name]=function(enc,...)
        if enc and enc.context and enc.context.warVersion~=1 then return Legacy[name](enc,...) end
        return current(enc,...)
    end
end
return Combat
