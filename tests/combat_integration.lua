-- Integración de campaña matrimonial y combate. El runner aporta App real con identidad de pruebas.
local Suite={}
function Suite.run(app)
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Combat=require("src.systems.combat")
    local Chapters=require("src.data.chapters")
    local Progression=require("src.systems.progression")
    local Events=require("src.systems.events")
    local checks=0
    local function check(ok,msg) assert(ok,msg);checks=checks+1 end
    local function encode(v) return assert(Json.encode(v)) end
    local function clone(v) return assert(Json.decode(encode(v))) end
    local function prepare(checkpoint,character)
        local s=Save.newSession({love=65,trust=65})
        assert(Events.apply(s,"nanahoshi_starter",{equipStarter=true,presenter="nanahoshi"}))
        s.rewardQueue={};s.checkpoint=checkpoint or "day1_tutorial";s.day=Chapters.get(s.checkpoint).day
        s.events.tutorial_completed=true
        for _,chapter in ipairs(Chapters.list) do
            if character and chapter.companion then s.decisions[chapter.companion.decisionKey]=character end
        end
        local def=assert(Progression.encounter(s,s.checkpoint))
        local support=require("src.systems.companions").context(s,def)
        local c={relationships=support.relationships,team=support.team,cardLevels=require("src.systems.card_collection").levels(s),character=def.character,tutorial=def.tutorial,enemyId=def.enemyId,day=s.day,difficulty=def.difficulty,tacticalContext=def.tacticalContext,unlocked=s.unlocked,combatDeck=s.combatDeck,curse=s.curse,externalEnergy=s.externalEnergy}
        s.combat=Combat.new(s.deck,c,function() return 17 end)
        return s,c
    end
    local function win(e,useAlly)
        require("tests.war_balance").solve(e)
        check(e.outcome=="victory","La campaña ofrece una estrategia ganadora legal")
    end
    local s,c=prepare()
    Combat.play(s.combat,1,s.combat.revision);s.combat.tutorial={stage="attack_result"}
    local restored=assert(Save.validate(clone(s)))
    check(restored.combat and encode(restored.combat)==encode(s.combat),"Guardar durante animación conserva todo el estado lógico de combate")
    check(restored.encounter==nil,"El combate no reaparece como diálogo social")
    local forged=clone(s);forged.combat.player.mana=999
    local safe=assert(Save.validate(forged))
    check(safe.combat==nil and safe.events.nanahoshi_starter and #safe.combatDeck==5,"Snapshot inválido reinicia sólo batalla y conserva colección")
    local before=encode(s.relationships);win(s.combat,false)
    local stored=assert(Save.validate(clone(s)))
    check(stored.combat.outcome=="victory" and not stored.unlocked.self_joke,"Cargar victoria pendiente no entrega recompensa antes de confirmar")
    local finished=stored.combat;local nextId=assert(Progression.finishCombat(stored,finished))
    check(nextId~= "day1_tutorial" and stored.unlocked.self_joke and stored.events.combat_reward_day1_tutorial,"Confirmar entrega recompensa y avanza")
    check(stored.defeatedEnemies.mana_anomaly and stored.events.combat_tutorial_completed,"Enemigo y tutorial se recuerdan")
    check(encode(stored.relationships)==before,"Atacar repetidamente no da amor ni confianza")
    local once=encode(stored)
    check(not Progression.finishCombat(stored,finished) and once==encode(stored),"Confirmar otra vez no duplica cartas, puntos ni transición")
    local afterLoad=assert(Save.validate(clone(stored)))
    check(afterLoad.unlocked.self_joke and #afterLoad.rewardQueue==#stored.rewardQueue,"Carta y entrega pendiente sobreviven a cargar")
    -- Escenario estable: este módulo verifica persistencia, no selección aleatoria de dificultad.
    local battleId="day3_encounter"
    local companion=prepare(battleId,"eris")
    local prior=encode(companion.relationships)
    win(companion.combat,true)
    check(encode(companion.relationships)==prior,"Decisión táctica espera a la confirmación de resultado")
    local delta=clone(companion.combat.relationshipEvents[1]);local previousLove=companion.relationships.eris.love
    local done=companion.combat;assert(Progression.finishCombat(companion,done))
    check(companion.relationships.eris.love==math.min(100,previousLove+delta.love),"Decisión táctica contextual afecta matrimonio exactamente una vez")
    local relationship=encode(companion.relationships)
    check(not Progression.finishCombat(companion,done) and encode(companion.relationships)==relationship,"No cosechar amor al repetir victoria")
    local defeated=prepare()
    local persistent=encode({defeated.relationships,defeated.unlocked,defeated.events,defeated.journal})
    while not defeated.combat.finished do Combat.endTurn(defeated.combat) end
    check(not Progression.finishCombat(defeated,defeated.combat),"Derrota no entrega recompensa ni avanza")
    local reload=assert(Save.validate(clone(defeated)))
    check(reload.combat and reload.combat.outcome=="defeat","Derrota persiste con botón de reintento")
    reload.combat=Combat.retry(reload.combat)
    check(reload.combat.player.hp==30 and reload.combat.player.mana==0 and reload.combat.revision==0,"Reintento repone vida y maná")
    check(encode({reload.relationships,reload.unlocked,reload.events,reload.journal})==persistent,"Reintento conserva decisiones previas y no duplica premios")
    if app then
        local old={session=app.session,save=app.save,practice=app.practice,options=app.options}
        local ok,err=xpcall(function()
            app.session=prepare();app.practice=false;app.save=function() return true end
            app.options=require("src.systems.options").normalize({muted=true,reducedMotion=true})
            app:resume();app:update(2);app:draw()
            local screen=app.manager.current
            check(screen.enc and screen.enc.type=="combat","Resume abre pantalla de batalla v2")
            screen:select(1)
            check(screen.confirmReady and screen.enc.revision==0,"Inspección de carta sin gasto")
            check(screen:play(),"Confirmación de carta ejecutable")
            local revision=screen.enc.revision
            screen:play();check(screen.enc.revision==revision,"Bloqueo de doble entrada durante animación")
            app:update(1);app:draw()
            check(screen.displayHp.mana==screen.enc.player.mana,"Barra animada converge a maná real")
            app.session.combat=screen.enc
            check(Save.validate(app.session).combat~=nil,"Estado de pantalla acepta replay validado")
        end,debug.traceback)
        app.session,app.save,app.practice,app.options=old.session,old.save,old.practice,old.options
        app:applyOptions();assert(ok,err)
    end
    print("Combat campaign integration: "..checks.." comprobaciones de persistencia, recompensa, compañera y reintentos.")
    return checks
end
return Suite
