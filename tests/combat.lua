-- Regression of the preserved pre-phase-4 replay engine. Current balance: tests/war*.lua.
local Suite={}
function Suite.run()
    local Combat=require("src.systems.combat_legacy")
    local Techniques=require("src.data.combat_cards")
    local Data=require("src.data.cards")
    local Enemies=require("src.data.enemies_legacy")
    local Json=require("src.systems.json")
    local checked=0
    local function check(value,message) assert(value,message);checked=checked+1 end
    local function clone(value) return assert(Json.decode(assert(Json.encode(value)))) end
    local unlocked={};for _,c in ipairs(Techniques.list) do unlocked[c.id]=true end
    for _,c in ipairs(Data.list) do unlocked[c.id]=true end
    local cursed={active=true,manaBlocked=true,voiceSealed=true}
    local function context(extra)
        local c={tutorial=true,unlocked=unlocked,combatDeck=Techniques.starterDeck,curse=cursed,externalEnergy=0}
        for k,v in pairs(extra or {}) do c[k]=v end
        return c
    end
    local function new(extra,seed) return Combat.new(Data.starterDeck,context(extra),function() return seed or 7 end) end
    local function play(enc,id)
        for i,v in ipairs(enc.hand) do if v==id then return assert(Combat.play(enc,i,enc.revision)) end end
        error(id.." no está en mano")
    end
    local function hasEvent(result,kind,target)
        for _,e in ipairs(result.events) do if e.kind==kind and (not target or e.target==target) then return e end end
    end
    check(#Techniques.starterDeck==5 and Combat.validateDeck(Techniques.starterDeck,unlocked),"Cinco técnicas físicas adquiridas constituyen el mazo inicial")
    for _,id in ipairs(Techniques.starterDeck) do check(Combat.card(id).manaCost==0,"Carta física sin maná "..id) end
    check(not Combat.validateDeck(Techniques.starterDeck,{}),"No entrar con técnicas bloqueadas")
    local duplicate=clone(Techniques.starterDeck);duplicate[1]=duplicate[2]
    check(not Combat.validateDeck(duplicate,unlocked),"Rechazar duplicadas")
    check(not Combat.validateDeck({"arcane_guard","heal","focus","wind_guard","earth_wall"},unlocked),"Se exigen dos ataques viables")
    local exclusive=clone(Techniques.starterDeck);exclusive[5]="sword_magic"
    local adapted,_,adjustments=Combat.adaptDeck(Data.starterDeck,context({character="roxy",combatDeck=exclusive}))
    check(#adapted==5 and #adjustments==1 and not table.concat(adapted,","):find("sword_magic"),"Exclusiva incompatible se sustituye sólo por adquirida")
    check(Combat.adaptDeck(Data.starterDeck,context({unlocked={}}))==nil,"Sin préstamo de mazo gratuito")
    local enc=new()
    check(enc.player.hp==30 and enc.player.mana==0 and enc.player.externalEnergy==0 and enc.energy==3,"Vida, maná sellado, energía externa y acciones separados")
    check(table.concat(enc.hand,",")=="staff_strike,push,stone_throw","Tutorial físico reproducible")
    local before=Json.encode(enc);local preview=Combat.preview(enc,1)
    check(before==Json.encode(enc) and preview.damage==2 and preview.manaCost==0,"Vista previa pura de nivel 1")
    play(enc,"staff_strike")
    check(enc.enemy.hp==20 and enc.player.mana==0 and enc.player.hp==30 and enc.energy==2,"Bastón funciona sin magia ni coste de vida")
    local unchanged=Json.encode(enc)
    check(not Combat.play(enc,1,0) and unchanged==Json.encode(enc),"Token obsoleto no vuelve a gastar")
    Combat.basic(enc,"defend",enc.revision)
    check(enc.player.shield==5 and enc.player.physicalShield==5 and enc.energy==1,"Defensa sin carta ni maná")
    local incoming=Combat.endTurn(enc)
    check(enc.player.hp==30 and hasEvent(incoming,"damage","player").blocked==4,"Escudo absorbe antes de PV")
    check(enc.player.shield==0 and enc.player.mana==0 and enc.energy==3,"Escudo temporal; maná natural no se regenera estando bloqueado")
    check(Combat.restore(clone(enc),Data.starterDeck,context())~=nil,"Replay restaura ataques y defensa básica")
    for _,key in ipairs({"hp","mana","shield","externalEnergy"}) do
        local forged=clone(enc);forged.player[key]=forged.player[key]+1
        check(not Combat.restore(forged,Data.starterDeck,context()),"Rechazo campo alterado "..key)
    end
    local retry=Combat.retry(enc)
    check(retry.player.hp==30 and retry.player.mana==0 and retry.revision==0 and #retry.relationshipEvents==0,"Reintento conserva la maldición")
    local dodge=new();assert(Combat.basic(dodge,"dodge"));check(dodge.player.shield==3 and not Combat.basic(dodge,"dodge"),"Esquiva disponible y limitada por turno")
    local sword=new();sword.hand={"simple_cut"};play(sword,"simple_cut")
    check(sword.player.hp==29 and sword.player.mana==0 and sword.enemy.hp==19,"Corte cuesta esfuerzo físico explícito")
    local unsafe=new();unsafe.hand={"quick_study"};unsafe.player.hp=4
    check(not Combat.canPlay(unsafe,1),"Esfuerzo no puede dejar menos de un PV")
    unsafe.player.hp=5;play(unsafe,"quick_study")
    check(unsafe.player.hp==1,"Esfuerzo puede dejar exactamente un PV")
    local magic=new({externalEnergy=12});magic.hand={"magic_bolt"};play(magic,"magic_bolt")
    check(magic.enemy.hp==16 and magic.player.externalEnergy==10 and magic.player.mana==0,"Bala usa energía externa sin restaurar magia natural")
    local depleted=new();depleted.hand={"magic_bolt"}
    check(not Combat.canPlay(depleted,1),"Sin fragmentos no lanzar magia de artefacto")
    local natural=new({externalEnergy=12});natural.hand={"heal"};local oldResource=Techniques.byId.heal.resource;Techniques.byId.heal.resource="natural"
    check(not Combat.canPlay(natural,1),"Magia natural bloqueada aunque haya energía externa")
    Techniques.byId.heal.resource=oldResource
    local cured=new({curse={active=false,manaBlocked=false}});cured.hand={"magic_bolt"};play(cured,"magic_bolt")
    check(cured.player.mana==10 and cured.player.externalEnergy==0,"Tras cura vuelve el maná natural")
    local earth=new({externalEnergy=12});earth.hand={"arcane_guard"};play(earth,"arcane_guard")
    check(earth.player.magicShield==5 and earth.player.physicalShield==0,"Escudos mágico y físico diferenciados")
    local weak=new({externalEnergy=12});weak.hand={"swamp"};play(weak,"swamp")
    check(weak.enemy.weak==2 and weak.enemy.intent.damage==2,"Pantano modifica intención visible")
    for _,id in ipairs({"sylphiette","roxy","eris"}) do
        local ally=new({character=id,enemyId="badigadi_final",tutorial=false})
        local result=assert(Combat.tactic(ally,"together",ally.revision))
        check(ally.companion and ally.companion.id==id and hasEvent(result,"companion_action"),id.." actúa realmente sin maná de Rudy")
        check(ally.enemy.hp<72 and ally.player.mana==0,"Compañera actúa durante la maldición")
        check(not Combat.tactic(ally,"assist"),"Una acción de compañera por turno")
        Combat.endTurn(ally);Combat.tactic(ally,"together")
        check(#ally.relationshipEvents==1,"Acciones repetidas no acumulan amor")
        check(Combat.restore(clone(ally),Data.starterDeck,context({character=id,enemyId="badigadi_final",tutorial=false}))~=nil,"Replay de compañera "..id)
    end
    local capable=new({character="eris"});Combat.tactic(capable,"protect")
    check(capable.relationshipEvents[1].trust<0,"Sobreproteger a Eris capaz perjudica confianza")
    local wounded=new({character="eris",tacticalContext={companionInjured=true}});Combat.tactic(wounded,"protect")
    check(wounded.relationshipEvents[1].trust>0 and wounded.companion.shield==6,"Proteger a Eris herida ayuda")
    local victory=new();victory.enemy.hp=1;play(victory,"staff_strike")
    check(victory.finished and victory.outcome=="victory","Victoria normal a cero PV enemigo")
    check(not Combat.endTurn(victory),"No actuar después de victoria")
    local defeat=new();defeat.player.hp=1;Combat.endTurn(defeat)
    check(defeat.finished and defeat.outcome=="defeat","Derrota a cero PV Rudy")
    local waiting=new();while not waiting.finished do Combat.endTurn(waiting) end
    check(waiting.turn<=30 and waiting.outcome=="defeat","Inacción conduce a derrota finita")
    check(Combat.restore(clone(waiting),Data.starterDeck,context())~=nil,"Derrota guardable y reintentable")
    local final=new({enemyId="badigadi_final"});final.enemy.hp=1;play(final,"staff_strike")
    check(not final.finished and final.enemy.phase=="seal" and final.enemy.seal==12,"Cero vida no basta: sello expuesto")
    assert(Combat.breakSeal(final));check(not final.finished and final.enemy.seal==6,"Primer anclaje no da victoria")
    assert(Combat.breakSeal(final));check(final.outcome=="victory" and final.enemy.sealBroken,"Neutralizar ambos anclajes libera antídoto")
    local late=clone(Techniques.starterDeck)
    for _,id in ipairs({"water_projectile","magic_bolt","arcane_guard","heavy_spell","swamp"}) do late[#late+1]=id end
    local wins,total=0,0
    for _,enemy in ipairs(Enemies.list) do
        for _,wife in ipairs({"sylphiette","roxy","eris"}) do
            for seed=1,4 do
                local c=context({character=wife,enemyId=enemy.id,tutorial=false,combatDeck=late,externalEnergy=12})
                local battle=Combat.new(Data.starterDeck,c,function() return seed*4729 end)
                while not battle.finished do
                    if Combat.canBreakSeal(battle) then Combat.breakSeal(battle)
                    else
                        if Combat.canTactic(battle,"coordinate") then Combat.tactic(battle,"coordinate")
                        elseif Combat.canTactic(battle,"together") then Combat.tactic(battle,"together") end
                        local played=true
                        while played and not battle.finished do
                            played=false;local best,bestValue
                            for i,id in ipairs(battle.hand) do
                                if Combat.canPlay(battle,i) then
                                    local e=Combat.card(id).effects
                                    local value=(e.damage or 0)+(e.shield or 0)*.7+math.min(e.heal or 0,battle.player.maxHp-battle.player.hp)
                                    if not bestValue or value>bestValue then best,bestValue=i,value end
                                end
                            end
                            if best then Combat.play(battle,best);played=true end
                        end
                    end
                    if not battle.finished and not Combat.canBreakSeal(battle) then Combat.endTurn(battle) end
                end
                total=total+1;if battle.outcome=="victory" then wins=wins+1 end
                check(battle.outcome=="victory","Mazo desbloqueado viable: "..enemy.id.." / "..wife.." / "..seed)
                check(Combat.restore(clone(battle),Data.starterDeck,c)~=nil,"Victoria legal se restaura "..enemy.id)
                local count,seen=0,{}
                for _,zone in ipairs({"hand","drawPile","discard"}) do
                    for _,id in ipairs(battle[zone]) do count=count+1;check(not seen[id],"Carta no duplicada");seen[id]=true end
                end
                check(count==#late and #battle.relationshipEvents<=1,"Conservación de mazo y límite sentimental")
            end
        end
    end
    print("Combat curse: "..checked.." comprobaciones; "..wins.."/"..total.." victorias simuladas.")
    return checked
end
return Suite
