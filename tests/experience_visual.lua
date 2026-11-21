-- Screens rendered by the real App. Save functions are isolated in tests/run.
-- The only negative-stat fixture is explicitly labelled QA and restored below.
local Suite={}
function Suite.run(app)
    local Save=require("src.systems.save")
    local Cards=require("src.systems.cards")
    local Data=require("src.data.cards")
    local Json=require("src.systems.json")
    local Font=require("src.ui.font")
    local Progression=require("src.systems.progression")
    local checks,captures=0,0
    local function check(ok,message) assert(ok,message); checks=checks+1 end
    local function encode(value) return assert(Json.encode(value)) end
    local originalSession,originalOptions,originalMouse=app.session,app.options,app.mouse
    local originalDraw=Font.draw
    local originalBonus=Data.byId.analyze_runes.contexts.investigation
    app.mouse=function() return nil,nil end
    local function capture(name)
        app.toastTime=0; app:draw()
        local pixels=app.canvas:newImageData()
        local bytes=pixels:encode("png")
        local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/"..name..".png","wb"))
        file:write(bytes:getString()); file:close(); pixels:release(); bytes:release()
        captures=captures+1
    end
    local function settle()
        app:update(1.6)
        if app.manager.transition>0 then app:update(app.manager.transition) end
        app.toastTime=0; app:draw()
    end
    local function click(label)
        app:draw()
        for _,button in ipairs(app.manager.current.buttons) do
            if button.label==label then
                check(not button.disabled,"La instrucción tiene un control habilitado: "..label)
                app:mousepressed(app.offsetX+(button.x+button.w/2)*app.scale,
                    app.offsetY+(button.y+button.h/2)*app.scale,1)
                return
            end
        end
        error("No se encontró el control visual: "..label)
    end
    local function cardClick(index)
        app:draw()
        for _,button in ipairs(app.manager.current.buttons) do
            if button.cardIndex==index then
                app:mousepressed(app.offsetX+(button.x+4)*app.scale,app.offsetY+(button.y+4)*app.scale,1)
                return
            end
        end
        error("No existe hitbox de la carta "..index)
    end
    local function startEncounter(checkpoint,reduced)
        app.options=require("src.systems.options").normalize({volume=.6,muted=true,
            textSpeed=50,textAnimation=true,reducedMotion=reduced or false,tutorialCompleted=false})
        app:applyOptions()
        app.session=Save.newSession()
        app.session.checkpoint=checkpoint
        app.session.day=checkpoint=="day1_tutorial" and 1 or 2
        local def=Progression.encounter(app.session,checkpoint)
        app.session.encounter=Cards.new(app.session.deck,{kind=def.kind,character=def.character},function(n) return n end)
        app:resume(); settle()
        return app.manager.current
    end
    local function reducedResult(reduced,capturePositive)
        local screen=startEncounter("encounter_roxy",reduced)
        app:keypressed("2")
        check(screen.enc.turn==1 and screen.confirmReady,"Vista previa de runas no consume turno")
        app:keypressed("return")
        settle()
        check(screen.enc.log[1].score==3 and screen.enc.log[1].trust==1,"Resultado positivo real suma base, contexto y afinidad")
        if capturePositive then capture("ux-positive-result") end
        app:keypressed("return")
        app:keypressed("p"); settle(); app:keypressed("return")
        app:keypressed("p"); settle(); app:keypressed("return")
        check(app.session.checkpoint=="result_roxy","Encuentro finaliza también con movimiento reducido")
        return encode({relationships=app.session.relationships,events=app.session.events,
            decisions=app.session.decisions,unlocked=app.session.unlocked})
    end

    local ok,err=xpcall(function()
        local screen=startEncounter("day1_tutorial")
        check(screen.tutorial and screen.tutorial.stage=="hand","La primera práctica comienza en la mano")
        app:keypressed("p")
        check(#screen.enc.log==0 and screen.tutorial.stage=="hand","No se puede omitir la instrucción con un respiro")
        capture("ux-tutorial-initial")
        click("Ver la energía")
        check(screen.tutorial.stage=="energy","Paso mano precede a energía")
        click("Elegir una carta")
        check(screen.tutorial.stage=="select","La guía espera selección real")
        cardClick(1)
        app:update(.15)
        check(screen.confirmReady and screen.tutorial.stage=="ready" and #screen.enc.log==0,"Clic selecciona y eleva antes de jugar")
        capture("ux-card-selected")
        click("Jugar carta [Enter]")
        app:update(.2); capture("ux-card-play")
        local snapshot=encode(screen.enc)
        app:keypressed("return"); app:keypressed("1"); app:keypressed("return")
        check(encode(screen.enc)==snapshot,"Entradas repetidas durante animación no duplican efectos")
        app:update(.4); capture("ux-card-flash")
        check(screen:busy() and screen.phase=="result","El efecto visual mantiene bloqueado el siguiente turno")
        app:keypressed("f5")
        app:continueGame(); settle(); screen=app.manager.current
        check(encode(screen.enc)==snapshot and screen.phase=="result","Guardar/cargar durante animación conserva el resultado sin repetirlo")
        check(screen.tutorial.stage=="result","Carga mantiene la explicación pendiente")
        capture("ux-tutorial-result")
        click("Ver el robo")
        app:update(.15); capture("ux-card-draw")
        check(screen.tutorial.stage=="draw" and #screen.enc.hand==3,"El robo conserva una mano de tres")
        settle(); click("Jugar el segundo turno")
        app:keypressed("1"); app:keypressed("return"); settle()
        check(screen.tutorial.stage=="second_result" and #screen.enc.log==2,"La segunda acción se aprende jugando")
        click("Aprender la acción gratuita")
        capture("ux-tutorial-no-energy")
        local energy=screen.enc.energy
        click("Probar carta con 0 energía")
        check(screen.tutorial.stage=="free" and screen.enc.energy==energy,"La demostración de coste cero no altera la energía real")
        app:keypressed("p"); settle()
        check(screen.tutorial.stage=="summary" and screen.enc.finished and screen.enc.log[3].cardId=="pass","La guía exige realizar el respiro final")
        capture("ux-tutorial-summary")
        check(screen.historyOpen,"El cierre de la guía muestra el historial de las tres acciones")
        capture("ux-tutorial-history")
        app:keypressed("h")
        click("Ver resultado >")
        check(app.session.events.tutorial_completed and app.options.tutorialCompleted,"El resumen registra práctica completada en sesión y perfil")
        local completedEvents=encode(app.session.events)
        app:continueGame(); settle()
        check(encode(app.session.events)==completedEvents,"Carga posterior no repite el evento de la práctica")

        screen=startEncounter("day1_tutorial")
        app.options.tutorialCompleted=true
        app:draw(); click("Omitir guía")
        check(screen.tutorial==nil and #screen.enc.log==0 and screen.enc.energy==4,"Un perfil experto omite la guía sin inventar acciones ni premios")
        for turn=1,3 do
            app:keypressed("p"); settle()
            check(#screen.enc.log==turn,"La práctica omitida conserva sus tres turnos reales")
            if turn<3 then app:keypressed("return") end
        end
        app:keypressed("return")
        check(app.session.checkpoint=="day1_result","Omitir la guía conserva la salida narrativa")

        local normal=reducedResult(false,true)
        local reduced=reducedResult(true,false)
        check(normal==reduced,"Reducir movimiento produce los mismos vínculos, decisiones, cartas y eventos")

        screen=startEncounter("encounter_roxy")
        local originalHand=screen.enc.hand[1]
        for index,card in ipairs(Data.list) do
            screen.enc.hand[1]=card.id; screen.selected=1
            local fullName=false
            local rowHeights={[146]=22,[173]=22,[207]=55,[266]=11,[279]=33,[297]=22}
            Font.draw=function(text,x,y,options)
                if x==439 then
                    local maxHeight=rowHeights[y]
                    check(maxHeight~=nil,"El detalle usa una fila reservada: "..card.id)
                    check(Font.height(text,options.maxWidth,options.scale)<=maxHeight,"El detalle de encuentro cabe: "..card.id)
                    check(x+options.maxWidth<=622 and y+maxHeight<=323,"El texto queda dentro del panel de encuentro")
                    fullName=fullName or text==card.name
                end
                return originalDraw(text,x,y,options)
            end
            app:draw()
            check(fullName,"El panel muestra el nombre completo de la carta "..index)
            if card.id=="be_honest" then capture("ux-long-card") end
        end
        Font.draw=originalDraw; screen.enc.hand[1]=originalHand

        -- No production card currently subtracts stats. This labelled fixture
        -- exercises the real calculator/renderer without changing shipped data.
        Data.byId.analyze_runes.contexts.investigation={score=-3,trust=-2}
        screen.definition.title="QA: MODIFICADOR NEGATIVO"
        app:keypressed("2"); app:keypressed("return"); settle()
        check(screen.enc.log[1].score==-2 and screen.enc.log[1].trust==-1,"El cálculo admite y representa deltas negativos reales de una definición")
        local negativeShown=false
        Font.draw=function(text,...)
            if text:find("DESCENSO:",1,true) and text:find("-2",1,true) then negativeShown=true end
            return originalDraw(text,...)
        end
        capture("ux-negative-fixture")
        Font.draw=originalDraw
        check(negativeShown,"El resultado negativo muestra signo y palabra DESCENSO")
        Data.byId.analyze_runes.contexts.investigation=originalBonus

        screen=startEncounter("encounter_roxy")
        for turn=1,3 do
            app:keypressed("p"); settle()
            if turn<3 then app:keypressed("return") end
        end
        check(screen.enc.finished and screen.enc.score==0 and screen.enc.energy==4,"Tres respiros producen resultado parcial sin bloqueo de energía")
        capture("ux-partial-result")

        app.session=originalSession; app.options=originalOptions; app:applyOptions()
        app:overlay("deck"); settle(); capture("ux-collection")
        cardClick(7); capture("ux-collection-honesty")
        app:overlay("options"); settle(); capture("ux-audio-options")
        local activations=app.manager.activationCount
        app:resume({type="horizontal",duration=.4})
        local checkpoint=app.session.checkpoint
        app:update(.15); capture("ux-scene-transition")
        app:keypressed("return")
        check(app.manager.activationCount==activations+1 and app.session.checkpoint==checkpoint,"El barrido bloquea entrada y activa una sola pantalla")
        settle()
        check(app.manager.transition==0 and app.manager.activationCount==activations+1,"La transición termina sin reactivar la escena")
    end,debug.traceback)
    Font.draw=originalDraw
    Data.byId.analyze_runes.contexts.investigation=originalBonus
    app.session,app.options,app.mouse=originalSession,originalOptions,originalMouse
    if app.audio then app.audio:stop() end
    assert(ok,err)
    print("Experience visuals: "..checks.." checks passed; "..captures.." real-renderer screenshots (one labelled negative QA fixture).")
    return checks,captures
end
return Suite
