-- Resultados de combates legales en la App real y guardado en disco aislado.
local Suite={}
function Suite.run()
    local Save=require("src.systems.save")
    local Events=require("src.systems.events")
    local Combat=require("src.systems.combat")
    local Training=require("src.systems.training")
    local Result=require("src.systems.training_result")
    local Progression=require("src.systems.progression")
    local Dialogue=require("src.data.training_dialogue")
    local Font=require("src.ui.font")
    local Options=require("src.systems.options")
    local Json=require("src.systems.json")
    local Techniques=require("src.data.combat_cards")
    local Solver=require("tests.training")
    local checks,captures=0,0
    local function check(value,message) checks=checks+1;assert(value,message) end
    local function encode(value) return assert(Json.encode(value)) end
    local function clone(value) return assert(Json.decode(encode(value))) end
    local late={"staff_strike","simple_cut","stone_throw","push","coordinated_attack",
        "water_projectile","arcane_guard","heavy_spell","swamp","heal"}
    local identity=love.filesystem.getIdentity()
    local originalOptions,originalFont=Save.readOptions,Font.draw
    local app,drawn
    love.filesystem.setIdentity("cartas_del_destino_training_tests")
    Save.readOptions=function() return {muted=true,textAnimation=false,reducedMotion=false} end
    love.graphics.push("all")
    local ok,err=xpcall(function()
        app=require("src.app").new();app.mouse=function() return nil,nil end
        Font.draw=function(text,x,y,options)
            if drawn then drawn[#drawn+1]={text=tostring(text),x=x,y=y,options=options or {}} end
            return originalFont(text,x,y,options)
        end
        local function draw()
            drawn={};app.toastTime=0;app:draw();return drawn
        end
        local function settle()
            if app.manager.transition>0 then app:update(app.manager.transition) end
            app:update(2);draw()
        end
        local function capture(name)
            draw();local pixels=app.canvas:newImageData();local png=pixels:encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/training-"..name..".png","wb"))
            file:write(png:getString());file:close();pixels:release();png:release();captures=captures+1
        end
        local function click(label)
            draw()
            for _,button in ipairs(app.manager.current.buttons) do
                if button.label==label and not button.disabled then
                    app:mousepressed(app.offsetX+(button.x+button.w/2)*app.scale,app.offsetY+(button.y+button.h/2)*app.scale,1)
                    return
                end
            end
            error("Botón de entrenamiento no disponible: "..label)
        end
        local function layout(screen)
            local calls=draw();local found={}
            for _,entry in ipairs(calls) do
                local height=Font.height(entry.text,entry.options.maxWidth,entry.options.scale)
                if entry.x==24 and entry.y>=65 and entry.y<=178 then
                    check(entry.y+height<=215,"Texto de métricas y evaluación cabe en su panel: "..entry.text)
                end
                if entry.x==24 and entry.y==249 then check(entry.y+height<=306,"La reacción no invade el resultado aplicado") end
                for _,label in ipairs({"Ganador:","Ataques:","Puntos causados:","Bloqueos:","Esquivas efectivas:","Turnos sin actuar:","Aperturas desaprovechadas:"}) do
                    if entry.text:find(label,1,true) then found[label]=true end
                end
            end
            for _,label in ipairs({"Ganador:","Ataques:","Puntos causados:","Bloqueos:","Esquivas efectivas:","Turnos sin actuar:","Aperturas desaprovechadas:"}) do
                check(found[label],"Métrica visible: "..label)
            end
            local bounds=screen.bars.lastBounds
            check(bounds and bounds.y+bounds.h<bounds.portrait.y and bounds.x>=328 and bounds.x+bounds.w<=632,"Barras sobre Eris sin invadir métricas ni retrato")
        end
        local function fixture(mode,deck,prior,checkpoint)
            local session=prior and clone(prior) or Save.newSession({love=65,trust=65})
            if not prior then Events.apply(session,"starter_gift",{starter=true}) end
            Events.apply(session,"training_test_resources_"..(checkpoint or "day5"),{externalEnergy=12,unlock=deck})
            session.checkpoint=checkpoint or "day5_eris_duel"
            session.day=require("src.data.chapters").get(session.checkpoint).day
            session.rewardQueue={};session.events.tutorial_completed=true;session.encounter=nil;session.trainingReview=nil
            session.combatDeck=clone(deck)
            local def=assert(Progression.encounter(session,session.checkpoint))
            session.combat=Combat.new(session.deck,{character=def.character,enemyId=def.enemyId,day=session.day,
                difficulty=def.difficulty,tutorial=def.tutorial,tacticalContext=def.tacticalContext,
                combatDeck=deck,unlocked=session.unlocked,curse=session.curse,externalEnergy=session.externalEnergy},function() return 17 end)
            Solver.solve(session.combat,mode)
            return session
        end
        local function review(session,name,expected,reduced)
            app.options=Options.normalize({muted=true,textAnimation=false,reducedMotion=reduced==true})
            app.session=session
            local before=clone(session.relationships.eris)
            local combatBefore=encode(session.combat)
            local resistanceText=true
            for _,entry in ipairs(session.combat.log) do for _,event in ipairs(entry.events or {}) do
                if event.kind=="damage" and not event.text:find("resistencia perdida",1,true) then resistanceText=false end
            end end
            check(resistanceText,"El historial de entrenamiento describe resistencia, sin heridas letales")
            check(not Progression.finishCombat(session,session.combat),"No se omite la reacción para cobrar o avanzar")
            check(app:save(),"Guardar combate terminado antes de la reacción")
            app:continueGame();settle()
            local screen=app.manager.current
            check(screen.kind=="training_result" and screen.result.id==expected,"La App abre resultado real: "..name)
            check(app.audio.context=="training" and app.audio.current and app.audio.current.source,"Cargar el resultado restaura música de entrenamiento real")
            check(encode(app.session.combat)==combatBefore,"Cargar conserva combate y todas sus métricas")
            check(not app.session.events[Result.key(app.session.checkpoint)] and app.session.relationships.eris.love==before.love,
                "Cargar antes de la reacción no adelanta puntos")
            layout(screen);capture(name.."-before")
            while not screen.line.apply do
                if screen.page%2==1 then click("Escuchar [Enter]") else app:keypressed("return") end
                screen=app.manager.current
                if not screen.line.apply then
                    app:update(.2);check(app:save(),"Guardar una línea intermedia")
                    local page=screen.page;app:continueGame();settle();screen=app.manager.current
                    check(screen.page==page and not app.session.events[Result.key(app.session.checkpoint)],"La página intermedia se restaura sin aplicar")
                end
            end
            local checkpoint=app.session.checkpoint
            local record=assert(app.session.trainingResults[checkpoint])
            local current=app.session.relationships.eris
            local dl,dt=current.love-before.love,current.trust-before.trust
            check(record.actualLove==dl and record.actualTrust==dt,"Deltas aplicados exactos y sujetos al máximo/mínimo")
            check(encode(record.metrics)==encode(Training.evaluate(app.session.combat).metrics),"Registro conserva todas las métricas, incluido ganador")
            local feedback=screen.bars:feedback()
            check(feedback and feedback.deltas.love==dl and feedback.deltas.trust==dt,"Feedback muestra cambios reales, no bonificaciones nominales")
            if reduced then check(screen.bars.value.love==current.love and screen.bars.value.trust==current.trust,"Movimiento reducido actualiza barras inmediatamente")
            else
                check(screen.bars.value.love==before.love,"La barra empieza en el valor anterior")
                app:update(.2)
                check(screen.bars.value.love~=before.love and math.abs(screen.bars.value.love-current.love)>.01,"La barra interpola durante la reacción")
            end
            layout(screen);capture(name.."-applied")
            local relationSnapshot=encode(app.session.relationships)
            local journalSize=#app.session.journal
            local _,applied=Result.commit(app.session,app.session.combat)
            check(applied==false and encode(app.session.relationships)==relationSnapshot and #app.session.journal==journalSize,"Repetir confirmación no duplica puntos ni memoria")
            screen:showLine()
            check(screen.bars.notifications==1,"Redibujar o reabrir la misma línea no repite feedback")
            app:update(1.3)
            check(not screen.bars:feedback() and screen.bars.value.love==current.love,"El texto flotante termina y la barra converge")
            check(app:save(),"Guardar tras la reacción aplicada")
            app:continueGame();settle();screen=app.manager.current
            check(screen.line.apply and screen.bars.notifications==0 and not screen.bars:feedback(),"Cargar la reacción aplicada no reanima ni repite efectos")
            check(encode(app.session.relationships)==relationSnapshot,"Cargar conserva relaciones exactas")
            layout(screen);capture(name.."-restored")
            click("Continuar historia [Enter]");settle()
            check(app.session.checkpoint~=checkpoint and not app.session.combat and not app.session.trainingReview,"Victoria o derrota continúan la historia sin reintento forzado")
            check(not app.session.events["combat_reward_"..checkpoint],"El entrenamiento no entrega premios normales de combate")
            return clone(app.session)
        end

        local cases={
            {mode="win",id="victory",deck=late,love=98,trust=99},
            {mode="honor",id="honorable_defeat",deck=Techniques.starterDeck},
            {mode="idle",id="suspected_throw",deck=Techniques.starterDeck,love=4,trust=3},
            {mode="honest",id="honest_defeat",deck={"quick_study","mana_spark","simple_cut","staff_strike","stone_throw"}},
        }
        local histories={}
        for _,case in ipairs(cases) do
            local s=fixture(case.mode,case.deck)
            if case.love then s.relationships.eris.love=case.love;s.relationships.eris.trust=case.trust;s.relationships.eris.chemistry=case.love end
            histories[case.id]=review(s,case.id,case.id)
            local scene=Progression.scene(histories[case.id],"day5_training_reflection")
            check(scene.lines[1].expression==({victory="happy",honorable_defeat="happy",suspected_throw="angry",honest_defeat="neutral"})[case.id],
                "La conversación posterior recuerda el resultado "..case.id)
        end
        local s=fixture("win",late)
        review(s,"reduced-motion","victory",true)

        -- Una disculpa abre la revancha; el esfuerzo posterior repara el conflicto,
        -- conservando los dos resultados. No se fabrican métricas de ninguno.
        local prior=histories.suspected_throw
        check(prior.relationships.eris.pendingConflicts.training_effort,"El abandono aparente deja un conflicto real")
        check(Progression.choose(prior,"day5_training_reflection","apologize"),"La disculpa es una decisión jugable")
        prior.checkpoint="day6_intro";prior.day=6;prior.dialogueIndex=1
        check(Progression.next(prior)=="day6_eris_rematch_offer","La memoria desbloquea la oferta del día seis")
        check(Progression.choose(prior,prior.checkpoint,"accept") and Progression.next(prior)=="day6_eris_rematch","Aceptar conduce al nuevo duelo")
        local repeated=fixture("win",late,prior,"day6_eris_rematch")
        local repaired=review(repeated,"reconciled","victory")
        check(repaired.events.eris_training_reconciled and not repaired.relationships.eris.pendingConflicts.training_effort,"Esfuerzo tras disculpa reconcilia sin borrar la memoria")
        check(repaired.trainingResults.day5_eris_duel.id=="suspected_throw" and repaired.trainingResults.day6_eris_rematch.id=="victory","Ambas experiencias permanecen guardadas")
        local saved=assert(Save.validate(clone(repaired)))
        check(saved.events.eris_training_reconciled and saved.trainingResults.day5_eris_duel.id=="suspected_throw","Guardar conserva reconciliación y antecedente")
    end,debug.traceback)
    Save.readOptions=originalOptions;Font.draw=originalFont
    if app and app.audio then app.audio:setContext("menu") end
    love.graphics.setCanvas();love.graphics.pop();love.filesystem.setIdentity(identity)
    assert(ok,err)
    print("Training integration: "..checks.." checks; "..captures.." real-renderer captures (four legal outcomes, capped deltas, bars, disk replay, future memory and reconciliation).")
    return checks
end
return Suite
