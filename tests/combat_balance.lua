-- Balance por datos y comandos legales. No requiere renderer ni modifica campaña.
local Suite={}
function Suite.run()
    local Combat=require("src.systems.combat")
    local Enemies=require("src.data.enemies")
    local Techniques=require("src.data.combat_cards")
    local Chapters=require("src.data.chapters")
    local Json=require("src.systems.json")
    local count,wins=0,0
    local function check(value,message) count=count+1;assert(value,message) end
    local function clone(value) return assert(Json.decode(assert(Json.encode(value)))) end
    local function event(result,kind,target)
        for _,entry in ipairs(result.events) do if entry.kind==kind and (not target or entry.target==target) then return entry end end
    end
    local function context(extra)
        local value={enemyId="mana_anomaly",day=1,combatDeck=Techniques.starterDeck,
            curse={active=true,manaBlocked=true},externalEnergy=12}
        for k,v in pairs(extra or {}) do value[k]=v end
        return value
    end
    local function battle(extra,seed) return Combat.new({},context(extra),function() return seed or 17 end) end

    local source=Json.encode(Enemies.list)
    local early=Enemies.resolve("mana_anomaly",{day=1})
    local late=Enemies.resolve("mana_anomaly",{day=5})
    check(early.maxHp==22 and late.maxHp==40,"El mismo enemigo tiene dificultad de día declarada y acotada")
    check(late.actions[1].damage>early.actions[1].damage and #late.actions>#early.actions,"La dificultad cambia daño y repertorio además de PV")
    check(Enemies.resolve("mana_anomaly",{day=5,tutorial=true}).maxHp==22,"El tutorial conserva dificultad baja")
    check(Enemies.resolve("forest_beast",{day=2,difficulty=5}).maxHp==53,"Un encuentro puede seleccionar dificultad explícita")
    for day=1,7 do
        local boss=Enemies.resolve("badigadi_final",{day=day})
        check(boss.maxHp==72 and boss.sealMax==12 and boss.actions[1].damage==7,"Badigadi no recibe escalado indiscriminado: "..day)
    end
    check(Json.encode(Enemies.list)==source,"Resolver encuentros no muta las definiciones compartidas")

    local guarded=battle({enemyId="ruins_guardian",day=3})
    guarded.enemy.actionIndex=4
    -- Actualiza intención por una acción legítima que no cambia los PV enemigos.
    Combat.basic(guarded,"defend")
    local result=assert(Combat.endTurn(guarded))
    local hit=event(result,"damage","player")
    check(hit.damage==11 and hit.blocked==5 and hit.hpLost==6,"Escudo usado, daño bloqueado y PV perdidos coinciden")
    check(guarded.player.hp==24 and guarded.player.shield==0,"La defensa reduce daño real y caduca")

    local interrupted=battle({day=5})
    Combat.basic(interrupted,"defend");Combat.endTurn(interrupted)
    check(interrupted.enemy.intent.kind=="interrupt" and interrupted.enemy.intent.actionLoss==1,"Interrupción se anuncia antes de elegir")
    local action=interrupted.enemy.intent.id
    local cut=assert(Combat.endTurn(interrupted))
    check(cut.enemyAction==action and event(cut,"interrupt").amount==1 and interrupted.energy==2,"La acción anunciada reduce exactamente una acción")
    check(interrupted.enemy.intent.hits==2 and interrupted.enemy.intent.damage==3,"Ataque múltiple declara cantidad y daño de cada golpe")
    Combat.basic(interrupted,"defend")
    local multiple=assert(Combat.endTurn(interrupted))
    local hits,blocked,lost=0,0,0
    for _,entry in ipairs(multiple.events) do if entry.kind=="damage" and entry.target=="player" then
        hits=hits+1;blocked=blocked+entry.blocked;lost=lost+entry.hpLost
    end end
    check(hits==2 and blocked==5 and lost==1,"Escudo se consume una vez entre los golpes del ataque múltiple")
    check(interrupted.energy==3,"La interrupción dura un solo turno")

    local recovery=battle()
    recovery.enemy.actionIndex=2;recovery.enemy.actionUses.arcane_barrier=3
    local empty=assert(Combat.endTurn(recovery))
    check(event(empty,"recovery_exhausted","enemy") and recovery.enemy.shield==0,"La recuperación enemiga de escudo se agota")
    local healing=battle()
    for use=1,3 do
        healing.hand={"heal"};healing.energy=3;healing.player.externalEnergy=12;healing.player.hp=29
        local heal=assert(Combat.play(healing,1))
        check(healing.player.hp==30 and event(heal,"heal").amount==1,"Curación efectiva no supera la vida máxima")
    end
    healing.hand={"heal"};healing.energy=3;healing.player.hp=20
    check(not Combat.canPlay(healing,1) and Combat.preview(healing,1).usesLeft==0,"Curación básica consume tres cargas como máximo")
    check(Combat.card("shared_magic").perBattle==3,"La curación híbrida también tiene límite")
    local ally=battle({character="sylphiette",enemyId="badigadi_final",day=6})
    for use=1,4 do
        ally.player.hp=20;ally.energy=3;ally.perTurn={}
        local assisted=assert(Combat.tactic(ally,"assist"))
        check(ally.player.hp==(use<=3 and 23 or 20),"Sylphiette tiene tres curaciones efectivas: "..use)
        if use==4 then check(event(assisted,"recovery_exhausted","companion"),"El agotamiento se explica sin bloquear su ataque") end
    end
    check(ally.companionHeals==3,"La recuperación aliada no se renueva por turno")
    local healContext=context({enemyId="badigadi_final",day=6,
        combatDeck={"staff_strike","simple_cut","stone_throw","heal","focus"}})
    local savedHeal=Combat.new({},healContext,function() return 45 end)
    local healed=false
    for _=1,6 do
        for index,id in ipairs(savedHeal.hand) do
            if id=="heal" and Combat.canPlay(savedHeal,index) then Combat.play(savedHeal,index);healed=true;break end
        end
        if healed then break end
        Combat.endTurn(savedHeal)
    end
    check(healed and Combat.restore(clone(savedHeal),{},healContext),"Guardar y cargar conserva una carga gastada con comandos legales")
    local forged=clone(savedHeal);forged.perBattle.heal=0
    check(not Combat.restore(forged,{},healContext),"Cargar no permite recuperar cargas de curación manipuladas")
    forged=clone(savedHeal);forged.companionHeals=2
    check(not Combat.restore(forged,{},healContext),"El replay valida también el presupuesto aliado")

    -- Forma exacta del snapshot previo al balance, sin campos añadidos. La
    -- apertura se reconstruye con la mano guardada; el día de campaña no puede
    -- introducir nuevas estadísticas en mitad de ese combate.
    local legacyContext=context({character="sylphiette"});legacyContext.day=nil
    local old=Combat.new({},legacyContext,function() return 91 end)
    old.balanceVersion=nil;old.perBattle=nil;old.companionHeals=nil
    old.enemy.difficulty=nil;old.enemy.actionUses=nil
    for _,action in ipairs(old.enemy.actions) do action.maxUses=nil end
    old.log[1].text=old.log[1].text:gsub("0 maná","12 maná")
    local newContext=clone(legacyContext);newContext.day=5
    local migrated=Combat.restore(clone(old),{},newContext)
    check(migrated and migrated.balanceVersion==1 and migrated.enemy.maxHp==22,"La batalla anterior conserva reglas y dificultad originales")
    check(Json.encode(migrated.hand)==Json.encode(old.hand) and migrated.randomState==old.randomState,"Migrar no vuelve a sortear la mano ni la semilla")
    assert(Combat.tactic(migrated,"assist"));assert(Combat.endTurn(migrated))
    local prior=clone(migrated)
    prior.balanceVersion=nil;prior.perBattle=nil;prior.companionHeals=nil;prior.enemy.actionUses=nil
    local continuing=Combat.restore(prior,{},newContext)
    check(continuing and continuing.revision==2 and continuing.player.hp==migrated.player.hp,"Un combate antiguo ya avanzado se valida y continúa")
    check(Json.encode(continuing.hand)==Json.encode(prior.hand) and Json.encode(continuing.discard)==Json.encode(prior.discard)
        and Json.encode(continuing.log)==Json.encode(prior.log),"Mano, descarte e historial antiguos se conservan exactamente")
    check(Combat.restore(clone(continuing),{},newContext)~=nil,"El snapshot migrado vuelve a guardar/cargar con su versión de balance")
    local oldRetry=Combat.retry(continuing)
    check(oldRetry.balanceVersion==1 and oldRetry.enemy.maxHp==22 and Json.encode(oldRetry.initial)==Json.encode(old.initial),"Reintento antiguo conserva reglas y orden inicial")
    local tampered=clone(prior);tampered.player.hp=tampered.player.hp+1
    check(not Combat.restore(tampered,{},newContext),"La compatibilidad no acepta vida antigua manipulada")
    local nextBattle=Combat.new({},newContext,function() return 91 end)
    check(nextBattle.balanceVersion==2 and nextBattle.enemy.maxHp==40,"Solo la próxima batalla nueva usa el balance actual")

    -- Estrategia sencilla que lee la intención; no exige una carta concreta.
    local function win(enc)
        local guard=0
        while not enc.finished do
            guard=guard+1;assert(guard<500,"El combate no termina")
            if Combat.canBreakSeal(enc) then Combat.breakSeal(enc)
            else
                if Combat.canTactic(enc,"coordinate") then Combat.tactic(enc,"coordinate")
                elseif Combat.canTactic(enc,"together") then Combat.tactic(enc,"together") end
                while not enc.finished and enc.energy>0 do
                    local incoming=enc.enemy.intent.kind=="attack" and enc.enemy.intent.damage*(enc.enemy.intent.hits or 1) or 0
                    if incoming-enc.player.shield>=5 and Combat.canBasic(enc,"defend") then Combat.basic(enc,"defend")
                    else
                        local best,value
                        for index,id in ipairs(enc.hand) do if Combat.canPlay(enc,index) then
                            local e=Combat.card(id).effects
                            local score=(e.damage or 0)+math.min(e.shield or 0,math.max(0,incoming-enc.player.shield))+
                                math.min(e.heal or 0,enc.player.maxHp-enc.player.hp)+(e.weak or 0)*.5
                            if not value or score>value then best,value=index,score end
                        end end
                        if best then Combat.play(enc,best) else break end
                    end
                end
            end
            if not enc.finished and not Combat.canBreakSeal(enc) then Combat.endTurn(enc) end
        end
    end
    local lateDeck={"staff_strike","simple_cut","stone_throw","push","coordinated_attack","water_projectile","arcane_guard","heal","swamp","earth_wall"}
    local encounters=0
    for id,node in pairs(Chapters.checkpoints) do
        if node.kind=="encounter" and node.definition.kind=="magic" then
            encounters=encounters+1
            check(node.day<=6,"No hay combates en el desenlace del día siete")
            local def=node.definition
            local companions=def.requiresCompanion and {"sylphiette","roxy","eris"} or {def.character or false}
            for _,character in ipairs(companions) do for _,deck in ipairs({Techniques.starterDeck,lateDeck}) do for seed=1,6 do
                local c=context({day=node.day,difficulty=def.difficulty,enemyId=def.enemyId,character=character or nil,
                    tacticalContext=def.tacticalContext,tutorial=def.tutorial,combatDeck=deck,
                    externalEnergy=node.day>=3 and 12 or 0})
                local enc=Combat.new({},c,function() return seed*4729 end)
                win(enc)
                check(enc.outcome=="victory","Batalla viable con cartas disponibles: "..id.." / "..tostring(character).." / "..#deck.." / "..seed)
                wins=wins+1
                check(Combat.restore(clone(enc),{},c)~=nil,"Victoria y recursos se restauran por replay: "..id)
                local retry=Combat.retry(enc)
                check(retry.perBattle.heal==nil and retry.companionHeals==0 and retry.enemy.maxHp==enc.enemy.maxHp,"Reintento restaura cargas y mismo balance")
            end end end
        end
    end
    check(encounters>=8,"Se comprueban los encuentros de toda la campaña")
    print("Combat balance: "..count.." checks; "..wins.."/"..wins.." legal campaign victories (days, shields, healing limits, intentions, replay).")
    return count
end
return Suite
