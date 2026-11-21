-- Recorrido de la interfaz real: selección, guía, animaciones y ambos resultados.
local Suite={}
-- Un paso de entrada por iteración para los recorridos generales de historia.
function Suite.drive(screen)
    if screen:busy() then return end
    if screen.enc.finished then screen:keypressed("return");return end
    local stage=screen.tutorial and screen.tutorial.stage
    if stage=="attack_result" or stage=="enemy_result" then screen:keypressed("return");return end
    if stage=="end_turn" then screen:keypressed("e");return end
    if stage=="shield" then screen:keypressed("d");return end
    if require("src.systems.combat").canBreakSeal(screen.enc) then screen:keypressed("b");return end
    local wanted=stage=="attack" and "staff_strike"
    local Combat=require("src.systems.combat")
    if not stage and Combat.canTactic(screen.enc,"coordinate") then screen:tactic("coordinate");return end
    if not stage and Combat.canTactic(screen.enc,"together") then screen:tactic("together");return end
    local best,bestScore
    for i,id in ipairs(screen.enc.hand) do
        local card=Combat.card(id)
        if screen:canPlay(i) and (not wanted or wanted==id) then
            local score=(card.effects.damage or 0)*10+(card.effects.energy or 0)*5+(card.effects.draw or 0)*4+(card.effects.shield or 0)+(card.effects.heal or 0)
            if not bestScore or score>bestScore then best,bestScore=i,score end
        end
    end
    if best then screen:keypressed(tostring(best));screen:keypressed("return") else screen:keypressed("e") end
end

function Suite.run(app)
    local Save=require("src.systems.save")
    local Combat=require("src.systems.combat")
    local Screen=require("src.screens.combat")
    local Json=require("src.systems.json")
    local checks,captures=0,0
    local function check(ok,message) assert(ok,message);checks=checks+1 end
    local old={session=app.session,options=app.options,save=app.save,mouse=app.mouse,practice=app.practice}
    local function settle() app:update(2);app:draw() end
    local function capture(name)
        app.toastTime=0;app:draw()
        local pixels=app.canvas:newImageData();local bytes=pixels:encode("png")
        local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/"..name..".png","wb"))
        file:write(bytes:getString());file:close();pixels:release();bytes:release();captures=captures+1
    end
    local function clickCard(screen,index)
        app:draw()
        for _,button in ipairs(screen.buttons) do
            if button.cardIndex==index then
                screen:mousepressed(button.x+6,button.y+6,1);return
            end
        end
        error("La carta no tiene hitbox: "..index)
    end
    local function indexOf(enc,id)
        for i,value in ipairs(enc.hand) do if value==id then return i end end
    end
    local function open(tutorial)
        app.session=Save.newSession({love=65,trust=65});app.session.checkpoint="day1_tutorial";app.practice=true
        app.session.combatDeck={};for i,id in ipairs(require("src.data.combat_cards").starterDeck) do app.session.combatDeck[i]=id end
        app.options=require("src.systems.options").normalize({muted=true})
        app:applyOptions()
        local screen=Screen.new(app,{tutorial=tutorial,background="laboratory"})
        app:switch(screen);settle();return screen
    end
    local ok,err=xpcall(function()
        app.save=function() return true end;app.mouse=function() return nil,nil end
        local screen=open(true)
        check(screen.tutorial.stage=="attack","La guía inicia en un ataque real")
        check(screen.enc.player.hp==30 and screen.enc.enemy.hp==22 and screen.enc.player.mana==0 and screen.enc.energy==3,"Vida, maná y acciones comienzan en sus valores de diseño")
        capture("combat-01-tutorial")
        screen:keypressed("e")
        check(screen.enc.turn==1,"La guía impide saltarse el ataque")
        local before=Json.encode(screen.enc)
        clickCard(screen,1)
        check(Json.encode(screen.enc)==before and screen.confirmReady,"Seleccionar con mouse inspecciona sin jugar")
        capture("combat-02-selected")
        screen:keypressed("return")
        check(screen.enc.enemy.hp==20 and screen.enc.energy==2 and screen.enc.player.mana==0,"Confirmar aplica dos de daño de nivel 1 y costes una sola vez")
        local revision=screen.enc.revision
        screen:keypressed("return");screen:keypressed("2");screen:keypressed("e")
        check(screen.enc.revision==revision,"Animación bloquea entradas repetidas")
        app:update(.35);capture("combat-03-impact")
        settle()
        check(screen.tutorial.stage=="attack_result","La guía muestra el antes/después")
        screen:keypressed("return")
        check(screen.tutorial.stage=="shield","Entendido habilita la defensa")
        screen:keypressed("d");settle()
        check(screen.enc.player.shield==5 and screen.tutorial.stage=="end_turn","Defensa básica concede cinco de escudo")
        capture("combat-04-shield")
        screen:keypressed("e");app:update(.35);capture("combat-05-enemy-attack")
        settle()
        check(screen.enc.player.hp==30 and screen.enc.energy==3 and screen.enc.player.shield==0 and screen.enc.player.mana==0,"Ataque cuatro bloqueado y recarga de maná")
        check(screen.tutorial.stage=="enemy_result","La guía espera revisar el daño enemigo")
        screen:keypressed("h");capture("combat-06-history")
        local historyRevision=screen.enc.revision
        screen:keypressed("e")
        check(screen.enc.revision==historyRevision,"Historial modal no permite jugar por debajo")
        screen:keypressed("h");screen:keypressed("return")
        check(screen.tutorial.stage=="free","La guía libera el combate después de explicar el enemigo")
        local safety=0
        while not screen.enc.finished and safety<100 do
            safety=safety+1
            local best
            for i,id in ipairs(screen.enc.hand) do
                local card=Combat.card(id)
                if screen:canPlay(i) and (card.effects.damage or card.effects.energy or card.effects.draw) then best=i;break end
            end
            if best then screen:keypressed(tostring(best));screen:keypressed("return") else screen:keypressed("e") end
            settle()
        end
        check(screen.enc.outcome=="victory" and screen.enc.enemy.hp==0,"El tutorial completo culmina en una victoria")
        check(screen.tutorial.stage=="complete" and not screen:busy(),"La animación final termina y completa la guía")
        capture("combat-07-victory")
        screen=open(false)
        local initial=Json.encode(screen.enc.initial)
        while not screen.enc.finished do screen:keypressed("e");settle() end
        check(screen.enc.outcome=="defeat" and screen.enc.player.hp==0,"Pasar turnos permite observar una derrota real")
        capture("combat-08-defeat")
        screen:keypressed("return");settle();screen=app.manager.current
        check(not screen.enc.finished and screen.enc.player.hp==30 and screen.enc.enemy.hp==22,"Reintentar restaura vida, enemigo y turno")
        check(Json.encode(screen.enc.initial)==initial,"Reintentar conserva el mismo reparto inicial")
        screen:keypressed("escape");capture("combat-09-pause")
        check(screen.pauseOpen,"Escape abre controles de pausa")
        screen:keypressed("escape");check(not screen.pauseOpen,"Escape vuelve al combate")
        app.options.reducedMotion=true
        local playable
        for i in ipairs(screen.enc.hand) do if screen:canPlay(i) then playable=i;break end end
        screen:select(playable);screen:play();app:update(.2)
        check(not screen:busy(),"Movimiento reducido conserva una transición finita")
        -- Roles y movimiento de los retratos originales, no acompañantes decorativas.
        app.options.reducedMotion=false
        for _,wife in ipairs({"sylphiette","roxy","eris"}) do
            app.session.combat=nil;app.session.externalEnergy=12
            screen=Screen.new(app,{character=wife,enemyId="mirror_manifestation",background="mirror_dimension",tacticalContext={danger=true}})
            app:switch(screen);settle()
            check(screen.enc.companion.id==wife,"Retrato y rol de "..wife.." presentes en batalla")
            capture("combat-companion-"..wife)
            screen:keypressed("t");app:draw()
            check(screen.tacticsOpen,"Menú de tácticas accesible por teclado")
            if wife=="sylphiette" then capture("combat-tactics") end
            local chosen
            for _,button in ipairs(screen.buttons) do
                if button.label=="Coordinar magia y espada" then screen:mousepressed(button.x+4,button.y+4,1);chosen=true;break end
            end
            check(chosen and not screen.tacticsOpen and screen:busy(),"Táctica de compañera ejecutada desde botón real")
            app:update(.35);capture("combat-action-"..wife);settle()
            check(#screen.enc.relationshipEvents==1 and screen.enc.enemy.hp<68,"Acción visible produce daño y consecuencia contextual")
            check(screen.displayHp.mana==screen.enc.player.mana,"Maná se actualiza tras coordinación")
        end
        app.session.combat=nil;app.session.externalEnergy=12
        app.session.combatDeck={"staff_strike","simple_cut","stone_throw","push","coordinated_attack","water_projectile","magic_bolt","arcane_guard","heavy_spell","swamp"}
        screen=Screen.new(app,{character="roxy",enemyId="badigadi_final",background="arena"})
        app:switch(screen);settle();capture("combat-badigadi-endurance")
        check(screen.enc.enemy.portrait=="badigadi","Badigadi utiliza su PNG real")
        local phases={endurance=true};local steps=0
        while not screen.enc.finished do
            steps=steps+1;assert(steps<250,"El combate visual con Badigadi debe concluir")
            Suite.drive(screen);settle()
            local phase=screen.enc.enemy.phase
            if not phases[phase] then
                phases[phase]=true;capture("combat-badigadi-"..phase)
                if phase=="seal" then check(not screen.enc.finished and screen.enc.enemy.hp==0,"Sello requiere acción expresa después de vencer su resistencia") end
            end
        end
        check(phases.six_arms and phases.seal and phases.victory,"Interfaz recorre las cuatro fases de Badigadi")
        check(screen.enc.outcome=="victory" and screen.enc.enemy.sealBroken,"Botón/tecla B resuelve sello y victoria real")
        app.session.combat=nil;app.session.day=5
        screen=Screen.new(app,{enemyId="mana_anomaly",background="laboratory"})
        app:switch(screen);settle()
        check(screen.enc.enemy.maxHp==40,"La pantalla usa dificultad del día de campaña")
        screen:basic("defend");settle();screen:endTurn();settle()
        check(screen.enc.enemy.intent.kind=="interrupt","La interrupción se anuncia en la pantalla")
        capture("combat-day5-interruption")
        screen:endTurn();settle()
        check(screen.enc.energy==2,"La interfaz muestra dos acciones tras la interrupción")
        screen:basic("defend");settle();screen:endTurn();app:update(.35)
        check(screen.actionSummary:find("6 daño; 5 bloqueado",1,true) and screen.actionSummary:find("1 vida perdida",1,true),
            "El resumen suma ambos golpes y muestra el escudo consumido real")
        capture("combat-day5-multiple-blocked");settle()
    end,debug.traceback)
    app.session,app.options,app.save,app.mouse,app.practice=old.session,old.options,old.save,old.mouse,old.practice
    app:applyOptions()
    assert(ok,err)
    print("Combat visuals: "..checks.." checks passed; "..captures.." real-renderer screenshots.")
    return checks,captures
end
return Suite
