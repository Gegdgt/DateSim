local Suite={}
function Suite.solve(enc,mode)
local Combat=require("src.systems.combat")
local Training=require("src.systems.training")
    local safety=0
    while not enc.finished do
        safety=safety+1;assert(safety<100,"Duelo finito")
        if mode=="win" then
            local incoming=enc.enemy.intent.kind=="attack" and enc.enemy.intent.damage*(enc.enemy.intent.hits or 1) or 0
            if incoming>=6 then Combat.basic(enc,"defend") end
            while not enc.finished do
                local chosen,score
                for index,id in ipairs(enc.hand) do if Combat.canPlay(enc,index) then
                    local e=Combat.card(id).effects
                    local value=(e.damage or 0)+math.min(e.heal or 0,enc.player.maxHp-enc.player.hp)+
                        math.min(e.shield or 0,math.max(0,incoming-enc.player.shield))*.5
                    if not score or value>score then chosen,score=index,value end
                end end
                if chosen then Combat.play(enc,chosen) else break end
            end
        elseif mode=="honor" then
            local chosen,value
            for index,id in ipairs(enc.hand) do if Combat.canPlay(enc,index) then
                local c=Combat.card(id)
                if (c.effects.damage or 0)>0 and (not value or c.effects.damage<value) then chosen,value=index,c.effects.damage end
            end end
            if chosen then Combat.play(enc,chosen) end
            if enc.turn%3==0 then Combat.basic(enc,"dodge") end
        elseif mode=="honest" then
            while not enc.finished do
                local chosen,value
                for index,id in ipairs(enc.hand) do if Combat.canPlay(enc,index) then
                    local c=Combat.card(id)
                    if (c.hpCost or 0)>0 and (not value or c.hpCost>value) then chosen,value=index,c.hpCost end
                end end
                if chosen then Combat.play(enc,chosen) else break end
            end
        end
        if not enc.finished then Combat.endTurn(enc) end
    end
    return assert(Training.evaluate(enc))
end
function Suite.run()
    local Combat=require("src.systems.combat")
    local Training=require("src.systems.training")
    local Config=require("src.data.training")
    local Techniques=require("src.data.combat_cards")
    local Json=require("src.systems.json")
    local checks=0
    local function check(value,message) checks=checks+1;assert(value,message) end
    local function encoded(value) return assert(Json.encode(value)) end
    local function clone(value) return assert(Json.decode(encoded(value))) end
    local late={"staff_strike","simple_cut","stone_throw","push","coordinated_attack",
        "water_projectile","arcane_guard","heavy_spell","swamp","heal"}
    local function context(deck,extra)
        local c={enemyId="eris_training",day=5,combatDeck=deck or late,
            curse={active=true,manaBlocked=true},externalEnergy=12}
        for key,value in pairs(extra or {}) do c[key]=value end
        return c
    end
    local function create(deck,seed,extra)
        local c=context(deck,extra)
        return Combat.new({},c,function() return seed or 17 end),c
    end
    local function verify(enc,c,label)
        local restored=Combat.restore(clone(enc),{},c)
        check(restored and encoded(restored.training)==encoded(enc.training),"Replay de métricas: "..label)
        check(restored and encoded(restored.hand)==encoded(enc.hand) and restored.randomState==enc.randomState,"Mano y azar del duelo: "..label)
    end
    local finish=Suite.solve

    local base,c=create(nil,17,{character="eris"})
    check(base.enemy.training and base.enemy.nonlethal and base.enemy.character=="eris" and base.enemy.portrait=="eris","Eris es el oponente y usa su identidad/retrato existentes")
    check(not base.companion and Training.evaluate(base)==nil,"No aparece una segunda Eris aliada ni se evalúa antes de terminar")
    check(base.enemy.maxHp==42 and base.maxTurns==18,"Resistencia y límite declarados, sin escalado automático")
    verify(base,c,"apertura")
    check(not Combat.canBasic(base,"counter"),"No hay contraataque sin una apertura defensiva real")
    assert(Combat.basic(base,"dodge"));assert(Combat.endTurn(base))
    check(base.training.metrics.successfulDodges==1 and base.training.metrics.dodgedDamage==3,"Una esquiva efectiva registra solo el daño evitado")
    check(base.training.metrics.blockedAttacks==1 and base.training.metrics.blockedDamage==3 and base.training.metrics.damageReceived==3,"Bloqueos, resistencia perdida e intenciones coinciden")
    verify(base,c,"esquiva")
    check(Combat.canBasic(base,"counter"),"La esquiva efectiva habilita contraataque en el turno siguiente")
    local enemyBefore=base.enemy.hp
    assert(Combat.basic(base,"counter"))
    check(base.enemy.hp==enemyBefore-5 and base.training.metrics.attacksAttempted==1 and base.training.metrics.tacticalActions==2,
        "El contraataque cuesta una acción y cuenta como ataque táctico de bastón")
    check(not Combat.canBasic(base,"counter"),"La apertura no concede dos contraataques")
    verify(base,c,"contraataque")
    local altered=clone(base);altered.training.metrics.damageDealt=999
    check(not Combat.restore(altered,{},c),"Las métricas guardadas no se aceptan sin replay")
    local covered,coveredContext=create(Techniques.starterDeck,17,{tutorial=true})
    for index,id in ipairs(covered.hand) do if id=="push" then assert(Combat.play(covered,index));break end end
    assert(Combat.basic(covered,"defend"));assert(Combat.basic(covered,"dodge"));assert(Combat.endTurn(covered))
    check(covered.training.metrics.blockedDamage==6 and covered.training.metrics.successfulDodges==0,
        "Esquivar sin necesitar el escudo adicional no fabrica una esquiva efectiva")
    verify(covered,coveredContext,"esquiva redundante")

    local outcomes={}
    for _,case in ipairs({
        {mode="win",want="victory",deck=late,love=8,trust=6},
        {mode="honor",want="honorable_defeat",deck=Techniques.starterDeck,love=4,trust=3},
        {mode="idle",want="suspected_throw",deck=Techniques.starterDeck,love=-10,trust=-8},
        {mode="honest",want="honest_defeat",deck={"quick_study","mana_spark","simple_cut","staff_strike","stone_throw"},love=1,trust=1},
    }) do
        local enc,ctx=create(case.deck,17)
        local result=finish(enc,case.mode)
        check(result.id==case.want,"Resultado legal "..case.mode..": esperado "..case.want..", recibido "..result.id)
        check(result.love==case.love and result.trust==case.trust,"Efectos configurados: "..case.want)
        check(result.nonlethal and result.metrics.winner==result.winner,"Todos los resultados son ejercicios no letales")
        check(#enc.relationshipEvents==0,"El motor no aplica relaciones ni duplica recompensas")
        check(encoded(result)==encoded(enc.trainingResult),"La evaluación y el resultado almacenado coinciden")
        verify(enc,ctx,case.want)
        local retry=Combat.retry(enc)
        check(retry.training.metrics.attacksAttempted==0 and retry.trainingResult==nil and encoded(retry.initial)==encoded(enc.initial),"Reintento limpio y mismo reparto: "..case.want)
        if enc.outcome=="defeat" then check(enc.cause:find("sin heridas",1,true),"La derrota no mata a Rudy") end
        outcomes[case.want]=result
    end
    check(outcomes.honest_defeat.metrics.turns<5 and outcomes.honest_defeat.metrics.attacksAttempted>0,"Una derrota rápida con intentos reales no se acusa de abandono")
    check(outcomes.suspected_throw.metrics.avoidableEmptyTurns>=3 and outcomes.suspected_throw.metrics.missedOpportunities>=3,"La sospecha necesita varias señales repetidas, no solamente daño bajo")
    local dry,dryContext=create({"magic_bolt","water_projectile","heal","arcane_guard","focus"},91,{externalEnergy=0})
    local noResources=finish(dry,"idle")
    check(noResources.id=="honest_defeat" and noResources.metrics.missedOpportunities==0,"Una mano sin ataques pagables no se considera dejarse ganar")
    verify(dry,dryContext,"sin energía")

    for seed=1,8 do
        local enc,ctx=create(late,seed*4729)
        check(finish(enc,"win").id=="victory","Rudy puede ganar legalmente mediante estrategia, semilla "..seed)
        verify(enc,ctx,"victoria "..seed)
    end
    -- Objetivo alternativo de tres impactos: configurable sin otra pantalla.
    local previous=Config.eris.victory.kind
    Config.eris.victory.kind="hits"
    local ok,err=xpcall(function()
        local enc=create(late,31)
        local result=finish(enc,"win")
        check(result.id=="victory" and result.metrics.validHits>=3,"El objetivo alternativo acepta tres impactos válidos")
    end,debug.traceback)
    Config.eris.victory.kind=previous
    assert(ok,err)
    print("Eris training: "..checks.." checks; four legal outcomes, nonlethal resistance, measured effort, seeded victories and replay.")
    return checks
end
return Suite
