-- Métricas y evaluación pura de duelos. La campaña aplica después los eventos.
local Config=require("src.data.training")
local Training={}
local function copy(value)
    if type(value)~="table" then return value end
    local out={};for key,item in pairs(value) do out[key]=copy(item) end;return out
end
function Training.config(enc)
    return enc and enc.enemy and Config[enc.enemy.trainingId]
end
function Training.new(id)
    if not Config[id] then return nil end
    return {id=id,version=1,counterReady=false,metrics={turns=1,completedTurns=0,actionsTaken=0,
        attacksAttempted=0,attacksHit=0,validHits=0,damageDealt=0,damageReceived=0,
        blockedAttacks=0,blockedDamage=0,successfulDodges=0,dodgedDamage=0,
        tacticalActions=0,defensiveActions=0,idleTurns=0,avoidableEmptyTurns=0,
        missedOpportunities=0,offensiveOpportunityTurns=0},
        turn={actions=0,attacks=0,dodgeShield=0}}
end
function Training.beforeEndTurn(enc,canAttack)
    if not enc.training then return end
    local turn=enc.training.turn
    enc.training.pendingEnd={canAttack=canAttack,actions=turn.actions,attacks=turn.attacks}
end
-- Una esquiva cuenta solo si su escudo adicional evita daño que los demás
-- escudos no cubrían; pulsar Esquiva sin amenaza no fabrica una buena métrica.
function Training.dodgeAbsorbed(enc,blocked,totalShield)
    if not enc.training then return nil end
    local turn=enc.training.turn
    local other=math.max(0,totalShield-turn.dodgeShield)
    local used=math.min(turn.dodgeShield,math.max(0,blocked-other))
    turn.dodgeShield=math.max(0,turn.dodgeShield-used)
    return used
end
function Training.observe(enc,result,command)
    local state=enc.training;if not state then return end
    local m,turn=state.metrics,state.turn
    local config=Training.config(enc)
    m.turns=math.max(m.turns,result.turn or enc.turn)
    local damaging,tactical,defensive=false,false,false
    for _,entry in ipairs(result.events or {}) do
        if entry.kind=="damage" and entry.target=="enemy" then
            damaging=true
            m.damageDealt=m.damageDealt+entry.hpLost
            if entry.hpLost>0 then m.attacksHit=m.attacksHit+1 end
            if entry.hpLost>=config.victory.minHitDamage then m.validHits=m.validHits+1 end
        elseif entry.kind=="damage" and entry.target=="player" then
            m.damageReceived=m.damageReceived+entry.hpLost
            m.blockedDamage=m.blockedDamage+entry.blocked
            if entry.blocked>0 then m.blockedAttacks=m.blockedAttacks+1 end
            if (entry.dodgeBlocked or 0)>0 then
                m.successfulDodges=m.successfulDodges+1;m.dodgedDamage=m.dodgedDamage+entry.dodgeBlocked
            end
        elseif entry.kind=="shield" or entry.kind=="heal" or entry.kind=="status" or entry.kind=="mana" then
            if command.kind~="endTurn" then tactical=true end
            if entry.target=="player" and (entry.kind=="shield" or entry.kind=="heal") then defensive=true end
        end
    end
    if command.kind~="endTurn" then
        m.actionsTaken=m.actionsTaken+1;turn.actions=turn.actions+1
        if damaging then m.attacksAttempted=m.attacksAttempted+1;turn.attacks=turn.attacks+1 end
        if tactical or command.kind=="tactic" or (command.kind=="basic" and command.id=="counter") then m.tacticalActions=m.tacticalActions+1 end
        if defensive then m.defensiveActions=m.defensiveActions+1 end
        if command.kind=="basic" and command.id=="dodge" then turn.dodgeShield=turn.dodgeShield+3 end
    else
        state.counterReady=false
        for _,entry in ipairs(result.events or {}) do
            if entry.kind=="damage" and entry.target=="player" and entry.blocked>0 then state.counterReady=true end
        end
        local pending=state.pendingEnd or {actions=turn.actions,attacks=turn.attacks}
        m.completedTurns=m.completedTurns+1
        if pending.actions==0 then m.idleTurns=m.idleTurns+1 end
        if pending.canAttack then
            m.offensiveOpportunityTurns=m.offensiveOpportunityTurns+1
            if pending.attacks==0 then m.missedOpportunities=m.missedOpportunities+1 end
            if pending.actions==0 then m.avoidableEmptyTurns=m.avoidableEmptyTurns+1 end
        end
        state.pendingEnd=nil;state.turn={actions=0,attacks=0,dodgeShield=0}
    end
end
function Training.goalReached(enc)
    local config=Training.config(enc)
    return enc.training and config and config.victory.kind=="hits" and
        enc.training.metrics.validHits>=config.victory.targetHits
end
function Training.evaluate(enc)
    local config=Training.config(enc)
    if not config or not enc.training or not enc.finished then return nil end
    local m=enc.training.metrics
    local ratio=m.damageDealt/math.max(1,enc.enemy.maxHp)
    local id="honest_defeat"
    if enc.outcome=="victory" then id="victory"
    else
        local s=config.suspected
        -- Rapidez, pocos puntos o una mala elección nunca bastan. Deben
        -- repetirse al menos tres oportunidades legales y turnos evitables.
        local suspected=m.turns>=s.minTurns and m.missedOpportunities>=s.minRepeatedMisses and
            m.avoidableEmptyTurns>=s.minAvoidableEmptyTurns and m.attacksAttempted<=s.maxAttempts and
            ratio<=s.maxDamageRatio and m.tacticalActions<=s.maxTacticalActions
        if suspected then id="suspected_throw"
        elseif m.attacksAttempted>0 then
            local h=config.honorable
            local activity=1-m.idleTurns/math.max(1,m.completedTurns)
            local signals=0
            for _,passed in ipairs({m.turns>=h.minTurns,m.attacksAttempted>=h.minAttempts,
                m.attacksHit>=h.minHits,ratio>=h.minDamageRatio,
                m.defensiveActions>=h.minDefensiveActions or m.successfulDodges>0,
                activity>=h.minActivityRatio}) do if passed then signals=signals+1 end end
            local sustained=m.turns>=h.minTurns or (ratio>=h.minDamageRatio and (m.blockedAttacks>0 or m.successfulDodges>0))
            if signals>=h.minSignals and sustained then id="honorable_defeat" end
        end
    end
    local result=copy(config.results[id]);result.id=id;result.winner=enc.outcome=="victory" and "rudeus" or "eris"
    result.nonlethal=true;result.metrics=copy(m);result.metrics.winner=result.winner
    return result
end
function Training.complete(enc)
    if not enc.training or not enc.finished then return nil end
    enc.training.metrics.winner=enc.outcome=="victory" and "rudeus" or "eris"
    return Training.evaluate(enc)
end
return Training
