local Suite={}
function Suite.run()
    local Save=require("src.systems.save")
    local Collection=require("src.systems.card_collection")
    local Economy=require("src.systems.economy")
    local Events=require("src.systems.events")
    local Budget=require("src.systems.relationship_budget")
    local Combat=require("src.systems.combat")
    local Config=require("src.data.card_progression")
    local Json=require("src.systems.json")
    local count=0
    local function check(ok,msg) assert(ok,msg);count=count+1 end
    local function clone(s) return assert(Json.decode(assert(Json.encode(s)))) end
    local s=Save.newSession()
    Events.apply(s,"starter_gift",{starter=true})
    check(#Collection.list==40,"Se conservan las cuarenta cartas")
    check(s.collection.listen.level==1 and s.collection.listen.copies==0,"Primera copia desbloquea nivel 1")
    check(Events.apply(s,"multi",{copies={listen=90,light_joke=3},gold=10000}),"Evento admite lotes de copias y oro")
    check(s.collection.listen.copies==90 and s.collection.light_joke.copies==3,"Duplicados suman inventario")
    local before=s.gold
    check(not Events.apply(s,"multi",{copies={listen=90},gold=10000}) and s.gold==before,"Recompensa idempotente")
    local deck=Json.encode(s.deck);local total=1;local spent=0
    for level=1,9 do
        local view=Collection.view(s,"listen")
        check(view.copiesRequired==2*level,"Coste de copias "..level)
        local revision=s.economy.revision
        local gold=s.gold;local copies=s.collection.listen.copies
        check(Collection.upgrade(s,"listen",revision),"Mejora legal al nivel "..(level+1))
        check(s.gold==gold-view.goldRequired and s.collection.listen.copies==copies-2*level,"Descuento exacto")
        check(not Collection.upgrade(s,"listen",revision),"Pulsación duplicada con revisión antigua se rechaza")
        total=total+2*level;spent=spent+view.goldRequired
        local effect=Collection.view(s,"listen").effect
        check(effect.love==0 and effect.trust==1+math.floor(level/2),"Solo escala la confianza de Escuchar")
    end
    check(total==91 and s.collection.listen.copies==0,"91 copias totales para nivel 10")
    check(spent==225,"Coste total de oro de una carta básica: 225")
    for index,class in ipairs({"basic","intermediate","advanced","special","ultimate"}) do
        for level=1,9 do check(Config.goldRequired(level,class)==5*level*index,"Coste configurable de oro por clase y nivel") end
    end
    for id,spec in pairs(Config.combat) do
        local previous=Collection.view(s,id,1).combatEffect
        for level=2,10 do
            local effect=Collection.view(s,id,level).combatEffect
            for _,stat in ipairs({"damage","shield","heal"}) do
                if spec[stat] then check(effect[stat]>=previous[stat] and effect[stat]<=spec[stat][2],"Progresión monótona y acotada: "..id.."/"..stat);end
            end
            previous=effect
        end
    end
    check(Collection.view(s,"listen").copiesRequired==0 and not Collection.upgrade(s,"listen",s.economy.revision),"Nivel 10 no pide más copias")
    check(Json.encode(s.deck)==deck,"Mejorar no destruye ni sustituye carta equipada")
    local penalty=Collection.socialEffects("light_joke",10,{love=-2,trust=-3})
    check(penalty.love==-2 and penalty.trust==-3,"Penalización contextual no se multiplica")
    for _,id in ipairs({"staff_strike","simple_cut","stone_throw","push","coordinated_attack"}) do
        local view=Collection.view(s,id)
        check(view.combatEffect.damage>=1 and view.combatEffect.damage<=3,"Daño físico inicial pequeño")
    end
    check(Collection.view(s,"water_cannon",10).combatEffect.damage==250,"Definitiva llega a 250")
    check(Collection.view(s,"staff_strike",10).combatEffect.damage<30,"Básica tiene otra curva")
    check(Collection.view(s,"heal",10).combatEffect.heal==10 and Collection.view(s,"earth_wall",10).combatEffect.shield==18,"Curación y defensa acotadas")
    check(Collection.view(s,"focus",10).combatEffect.mana==Collection.view(s,"focus",1).combatEffect.mana,"Recuperación de recursos no escala")
    local noFunds=Save.newSession();Collection.grant(noFunds,"listen",3);noFunds.gold=0
    check(not Collection.upgrade(noFunds,"listen",0) and noFunds.collection.listen.copies==2,"Oro insuficiente no gasta copias")
    local r=Save.newSession()
    Events.apply(r,"one",{character="roxy",love=7,trust=8})
    Events.apply(r,"two",{character="roxy",love=5,trust=5})
    check(r.relationships.roxy.love==75 and r.relationships.roxy.trust==75,"Suma de todas las fuentes limitada a +10")
    local last=r.journal[#r.journal]
    check(last.love==3 and last.trust==2,"Se registra el valor realmente aplicado")
    Events.apply(r,"penalty",{character="roxy",love=-5,trust=-3})
    Events.apply(r,"more",{character="roxy",love=9,trust=9})
    check(r.relationships.roxy.love==70 and r.relationships.roxy.trust==72,"Penalizaciones no restauran presupuesto")
    Events.apply(r,"wife",{character="eris",love=3,trust=4})
    check(Budget.ensure(r).eris.love==3,"Cada esposa tiene su propio límite")
    r.day=2;require("src.systems.daily").ensure(r)
    check(Budget.preview(r,"roxy",{love=5}).love==5,"Límite se reinicia al día siguiente")
    local shop=Save.newSession();Events.apply(shop,"starter_gift",{starter=true});shop.rewardQueue={}
    local rev=shop.economy.revision
    check(Economy.buy(shop,"listen",rev,5),"Compra de cinco copias")
    check(shop.collection.listen.copies==5 and shop.gold==110,"Precio y cantidad exactos")
    check(not Economy.buy(shop,"listen",rev,5),"Compra repetida bloqueada")
    check(not shop.rewardQueue[1].newCards.listen and shop.rewardQueue[1].counts.listen==5,"Presentación de duplicados sin falso desbloqueo")
    check(not Economy.buy(shop,"water_cannon",shop.economy.revision),"No vende cartas bloqueadas")
    check(Economy.buy(shop,"study_book",shop.economy.revision),"Comprar libro")
    check(Economy.use(shop,"study_book","listen",shop.economy.revision) and shop.collection.listen.copies==8,"Libro entrega tres copias y se consume")
    check(not Economy.use(shop,"study_book","listen",shop.economy.revision),"Libro no reutilizable")
    check(Economy.buy(shop,"magic_material",shop.economy.revision),"Comprar material")
    check(Economy.use(shop,"magic_material",nil,shop.economy.revision) and shop.externalEnergy==4,"Material mejora reserva finita")
    check(Economy.buy(shop,"battle_preparation",shop.economy.revision),"Preparar enfrentamiento")
    check(not Economy.buy(shop,"battle_preparation",shop.economy.revision),"Preparación no acumulable")
    s.rewardQueue={};s.checkpoint="day1_agenda"
    local restored=assert(Save.validate(clone(s)))
    check(restored.collection.listen.level==10 and restored.gold==s.gold and restored.economy.revision==s.economy.revision,"Colección y economía persisten")
    check(Save.write(s),"Guardar progresión en disco")
    check(assert(Save.load()).collection.listen.level==10,"Cargar nivel 10 desde disco")
    local bad=clone(s);bad.gold=-1;check(not Save.validate(bad),"Rechaza saldo negativo")
    bad=clone(s);bad.collection.listen.level=11;check(not Save.validate(bad),"Rechaza nivel 11")
    bad=clone(s);bad.economy.purchases.day1_listen=true;check(not Save.validate(bad),"Rechaza existencias no numéricas")
    bad=clone(s);bad.daily.relationship_gains="invalid";check(not Save.validate(bad),"Rechaza presupuesto diario malformado sin abortar")
    check(not Economy.grant(s,0/0,"invalid"),"Rechaza oro no finito sin mutar el saldo")
    local v4=clone(shop);v4.version=4;v4.collection=nil;v4.economy=nil;v4.gold=nil
    local migrated=assert(Save.validate(v4))
    check(migrated.version==5 and migrated.collection.listen.level==1 and migrated.checkpoint==shop.checkpoint,"Migra v4 sin reiniciar la historia")
    bad=clone(v4);bad.daily="invalid";check(not Save.validate(bad),"Rechaza estado diario v4 inválido durante migración")
    local c=Save.newSession();Events.apply(c,"starter_gift",{starter=true})
    c.checkpoint="day1_tutorial";c.events.tutorial_completed=true
    Collection.grant(c,"staff_strike",6);c.gold=1000
    Collection.upgrade(c,"staff_strike",c.economy.revision);Collection.upgrade(c,"staff_strike",c.economy.revision)
    local context={enemyId="mana_anomaly",tutorial=true,day=1,combatDeck=c.combatDeck,unlocked=c.unlocked,curse=c.curse,externalEnergy=0,cardLevels=Collection.levels(c)}
    c.combat=Combat.new(c.deck,context,function() return 11 end)
    check(Combat.card("staff_strike",c.combat).effects.damage>Combat.card("staff_strike").effects.damage,"Nivel aumenta daño real del combate")
    check(Combat.play(c.combat,1),"Ataque mejorado ejecutable")
    local loaded=assert(Save.validate(clone(c)))
    check(loaded.combat and loaded.combat.enemy.hp==c.combat.enemy.hp,"Replay de combate conserva niveles y daño")
    check(not Collection.upgrade(c,"staff_strike",c.economy.revision),"No altera estadísticas durante un combate")
    local Cards=require("src.systems.cards")
    local Memory=require("src.systems.dialogue_memory")
    local Resolver=require("src.systems.dialogue_resolver")
    local social,definition=require("tests.dialogue_branching").fixture("encounter_eris")
    Collection.ensure(social).encourage.level=9
    Events.apply(social,"prior_attention",{character="eris",love=7,trust=8})
    social.encounter=Cards.new(social.deck,Resolver.context(social,definition),function(n)return n end)
    local function indexOf(enc,id) for i,value in ipairs(enc.hand) do if value==id then return i end end end
    local action=assert(Cards.play(social.encounter,assert(indexOf(social.encounter,"encourage"))))
    check(action.chemistry==5 and action.trust==5 and action.projectedLove==3 and action.projectedTrust==2,"Carta mejorada respeta el presupuesto compartido con actividades")
    social.encounterReview=true
    local pending=assert(Save.validate(clone(social)))
    check(pending.encounter and pending.encounter.log[1].projectedLove==3,"Carga de reacción pendiente conserva nivel y límite")
    local reaction=pending.encounter.log[1]
    check(Memory.commit(pending,reaction,pending.checkpoint,1) and reaction.actualLove==3 and reaction.actualTrust==2,"Reacción concede el valor realmente disponible")
    local afterReaction=assert(Save.validate(clone(pending)))
    check(afterReaction.encounter and not Memory.commit(afterReaction,afterReaction.encounter.log[1],afterReaction.checkpoint,1),"Cargar reacción ya vista no vuelve a premiar")
    -- Emulate a real v4 action using its original authored deltas, then load it
    -- with the v5 code. Original source files are never rewritten.
    local old,oldDef=require("tests.dialogue_branching").fixture("encounter_eris")
    Events.apply(old,"old_prior_attention",{character="eris",love=7,trust=8})
    local oldContext=Resolver.context(old,oldDef);oldContext.legacyProgression=true
    old.encounter=Cards.new(old.deck,oldContext,function(n)return n end)
    old.encounter.memory.legacyBudget=true
    local oldResult=assert(Cards.play(old.encounter,assert(indexOf(old.encounter,"encourage"))))
    oldResult.progressionVersion=nil
    check(oldResult.chemistry==5 and oldResult.trust==3,"Fixture usa deltas históricos de v4")
    old.legacyBudget=true;Memory.commit(old,oldResult,old.checkpoint,1);old.legacyBudget=nil
    old.version=4;old.collection=nil;old.gold=nil;old.economy=nil;old.encounterReview=true
    local original=assert(Json.encode(old));local migration=assert(Save.validate(clone(old)))
    check(migration.encounter and migration.encounter.log[1].actualLove==5 and migration.relationships.eris.love==77,"v4 conserva reacción y relación histórica")
    check(migration.daily.relationship_gains.eris.love==10 and not migration.encounter.context.legacyProgression,"Nuevas acciones usan presupuesto y reglas v5")
    local again=assert(Save.validate(clone(migration)))
    check(again.encounter and again.encounter.log[1].actualLove==5,"Segunda carga no reinterpreta una respuesta histórica")
    local newResult=assert(Cards.play(again.encounter,assert(indexOf(again.encounter,"be_honest"))))
    check(newResult.progressionVersion==1 and newResult.projectedTrust==0,"La acción nueva respeta ganancias históricas mayores a diez")
    Memory.commit(again,newResult,again.checkpoint,2)
    local mixed=assert(Save.validate(clone(again)))
    check(mixed.encounter and mixed.encounter.log[2].actualTrust==0,"Replay mixto v4/v5 conserva el presupuesto y los deltas nuevos")
    local identity=love.filesystem.getIdentity()
    love.filesystem.setIdentity("cartas_del_destino_v5_migration_tests")
    love.filesystem.remove(Save.filename);love.filesystem.remove(Save.backup)
    assert(love.filesystem.write("campaign-v4.json",original))
    local disk=assert(Save.load());check(disk.version==5 and disk.encounter,"Continuar encuentra y migra v4 desde disco")
    check(Save.write(disk) and love.filesystem.read("campaign-v4.json")==original,"Escribir v5 conserva exactamente el archivo v4")
    love.filesystem.setIdentity(identity)
    local costs=Collection.view(s,"water_cannon",10)
    check(costs.manaCost==12 and costs.hpCost==6 and costs.perBattle==1,"Definitiva potente tiene coste y uso único")
    local powerful=Combat.new(c.deck,{enemyId="mana_anomaly",tutorial=true,day=1,combatDeck=c.combatDeck,
        unlocked=c.unlocked,curse=c.curse,cardLevels={staff_strike=10,simple_cut=10,push=10,stone_throw=10,coordinated_attack=10}},function()return 11 end)
    for _=1,30 do if powerful.finished then break end;Combat.endTurn(powerful) end
    check(powerful.outcome=="defeat","Un mazo de nivel 10 todavía puede perder si ignora al enemigo")
    print("Economy/levels: "..count.." checks passed (91 copies, ten levels, costs, caps, shop, replay and persistence).")
    return count
end
return Suite
