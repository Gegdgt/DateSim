-- Continúa el recorrido real de Fase 1 y vuelve a abrir su guardado de día dos.
local Suite={}
function Suite.run(app)
    local Chapters=require("src.data.chapters")
    local Progression=require("src.systems.progression")
    local Cards=require("src.systems.cards")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local checks,totalSteps=0,0
    local function check(ok,message) assert(ok,message); checks=checks+1 end
    local function encode(value) return assert(Json.encode(value)) end
    local function render(name)
        app:update(1.6)
        if app.manager.transition>0 then app:update(app.manager.transition) end
        app:draw()
        if name then
            local bytes=app.canvas:newImageData():encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/"..name..".png","wb"))
            file:write(bytes:getString()); file:close()
        end
    end
    local function click(label,occurrence)
        render()
        occurrence=occurrence or 1
        for _,button in ipairs(app.manager.current.buttons) do
            if button.label==label then
                occurrence=occurrence-1
                if occurrence==0 then
                    app:mousepressed(app.offsetX+(button.x+button.w/2)*app.scale,
                        app.offsetY+(button.y+button.h/2)*app.scale,1)
                    return
                end
            end
        end
        error("Botón no encontrado: "..label)
    end
    check(app.session.checkpoint=="phase_complete","Recorrido original llega al cierre del día dos")
    local legacy=encode(app.session)
    local originalCompanion=app.session.decisions.companion
    local captureNames={day3_intro="11-day3-intro",day3_forest="13-day3-forest",day3_illusion="14-day3-illusion",
        day3_result="16-day3-result",day3_truth="17-day3-truth",day3_return="18-day3-return"}
    local function playDay(companion,index,reload,onlyPass)
        if reload then
            local old=assert(Save.validate(assert(Json.decode(legacy))))
            assert(Save.write(old))
            app.session=nil; app:menu()
            click("Continuar")
            check(app.session.checkpoint=="phase_complete","Continuar un guardado anterior conserva su checkpoint")
        else app:resume() end
        local relationships=encode(app.session.relationships)
        click("Continuar al Día 3")
        check(app.session.checkpoint=="day3_intro" and app.session.day==3,"Resumen permite iniciar Día 3")
        check(encode(app.session.relationships)==relationships,"Continuar no repite premios del día dos")
        local steps,captured=0,{}
        while app.session.checkpoint~="day3_complete" do
            steps=steps+1
            assert(steps<110,"Bloqueo del recorrido gráfico del día tres")
            render()
            local cp=app.session.checkpoint
            if cp=="day3_complete" then break end -- La última salida animada acaba aquí.
            local node=assert(Chapters.get(cp))
            local screen=app.manager.current
            if node.kind=="scene" then
                screen.elapsed,screen.visible=100,10000
                local speaker=screen.dialogue:current().speaker
                local target=(cp=="day3_intro" or cp=="day3_return") and "nanahoshi"
                    or (cp=="day3_truth" and "rudeus" or companion)
                if captureNames[cp] and speaker==target and not captured[cp] then
                    render(captureNames[cp].."-"..companion); captured[cp]=true
                end
                if screen.dialogue:isLast() and screen.scene.choices then
                    render("13b-day3-choice-"..companion)
                    click(screen.scene.choices[reload and 2 or 1].label)
                else app:keypressed("return") end
            elseif node.kind=="hub" then
                render("12-day3-companion-"..companion)
                click("Elegir compañía",index)
                check(app.session.decisions.day3_companion==companion,"Elegir nueva compañía mediante mouse")
                check(app.session.decisions.companion==originalCompanion,"Mantener compañero histórico del día dos")
                check(app.session.route==nil,"Elegir compañía no fija una ruta romántica")
            elseif node.kind=="encounter" then
                if not captured[cp] then render("15-day3-cards-"..companion); captured[cp]=true end
                if screen.enc.type=="combat" then require("tests.combat_visual").drive(screen)
                elseif screen.enc.finished then app:keypressed("return")
                elseif screen.phase=="result" then
                    app:keypressed("return")
                    check(screen.phase=="hand","Confirmar resultado devuelve el control de la mano")
                else
                    local chosen
                    if not onlyPass then
                        for i in ipairs(screen.enc.hand) do if Cards.canPlay(screen.enc,i) then chosen=i; break end end
                    end
                    local turn=screen.enc.turn
                    if chosen then
                        app:keypressed(tostring(chosen))
                        check(screen.enc.turn==turn and screen.confirmReady,"Tecla numérica consulta sin jugar automáticamente")
                        app:keypressed("return")
                    else app:keypressed("p") end
                    check(screen.enc.turn==turn+1,"Cada confirmación o respiro consume exactamente un turno")
                    local before=encode(app.session.encounter)
                    app:overlay("pause"); render(); click("Volver a la historia"); render()
                    check(encode(app.session.encounter)==before,"Pausa restaura el encuentro del día tres")
                    app:continueGame(); render()
                    check(encode(app.session.encounter)==before,"Carga restaura el encuentro del día tres")
                end
            else error("Pantalla no jugable en recorrido: "..cp) end
        end
        render("19-day3-complete-"..companion)
        check(app.session.events.seal_truth and app.session.events.day3_complete,"Día tres termina con Sello de la Verdad")
        check(not Progression.canContinue(app.session),"Resumen terminal no permite entrar al día cuatro")
        for _,button in ipairs(app.manager.current.buttons) do
            check(not button.label:find("Continuar"),"No existe botón hacia capítulo futuro")
        end
        local completed=encode(app.session)
        app:keypressed("return")
        check(encode(app.session)==completed,"Enter en resumen terminal no mueve ni repite efectos")
        app:continueGame(); render()
        check(encode(app.session)==completed,"Cargar el cierre conserva todas las decisiones y relaciones")
        if onlyPass then check(app.session.decisions.outcome_day3_encounter=="partial","Tres respiros permiten completar el resultado parcial") end
        totalSteps=totalSteps+steps
    end
    playDay("roxy",2,false,true)
    playDay("sylphiette",1,true,false)
    playDay("eris",3,true,false)
    print("Day 3 integration: "..checks.." checks passed; "..totalSteps.." screen steps across three companions.")
    return checks,totalSteps
end
return Suite
