local Save=require("src.systems.save")
local Combat=require("src.systems.combat")
local Activities=require("src.systems.wife_activities")
local Exploration=require("src.systems.exploration")

local Suite={}

function Suite.run()
    local previousWrite,previousHeld=Save.write,love.keyboard.isDown
    local previousIdentity=love.filesystem.getIdentity()
    local held={}
    Save.write=function() error("Una demostración temporal intentó guardar la campaña.") end
    love.keyboard.isDown=function(key) return held[key] or false end
    local checks,captures=0,0
    local function check(value,message)
        assert(value,message)
        checks=checks+1
    end
    local ok,err=xpcall(function()
        local app=assert(love.load({"--demo-ui"}))
        app.options.muted=true
        app.options.reducedMotion=false
        app:applyAudio()
        local function screen() return app.manager.current end
        local function drawWhen(predicate)
            for _=1,120 do
                if app.manager.transition==0 and (not predicate or predicate()) then love.draw();return end
                love.update(.1)
            end
            error("No terminó la transición o animación de UI.")
        end
        local function click(where)
            for _,button in ipairs(screen().buttons) do
                if button.label==where or button.cardIndex==where then
                    assert(not button.disabled,button.label)
                    love.mousepressed(app.offsetX+(button.x+button.w/2)*app.scale,
                        app.offsetY+(button.y+button.h/2)*app.scale,1)
                    return
                end
            end
            error("Control ausente: "..where)
        end
        local function capture(name)
            local pixels=app.canvas:newImageData()
            local encoded=pixels:encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/demo-ui-"..name..".png","wb"))
            assert(file:write(encoded:getString()));file:close()
            encoded:release();pixels:release();captures=captures+1
        end
        local function hudStrip()
            local pixels=app.canvas:newImageData()
            local strip=pixels:getString():sub(1,640*30*4)
            pixels:release()
            return strip
        end
        local function menu()
            love.keypressed("f9")
            drawWhen()
            check(screen().kind=="demo_ui" and app.session==nil,"F9 regresa al menú y descarta la sesión.")
        end

        drawWhen()
        check(screen().kind=="demo_ui" and love.filesystem.getIdentity()=="cartas_del_destino_demo_ui","Arranque e identidad de UI.")
        capture("menu")
        love.keypressed("tab");love.keypressed("return")
        drawWhen()
        local world=screen()
        check(world.kind=="exploration" and app.session.day==1 and app.session.exploration.map=="patio_eris","HUD real del patio, elegido con teclado.")
        local x,strip=world.camera.x,hudStrip()
        held.d=true
        love.update(.1);love.update(.1);love.update(.1)
        held.d=nil
        love.draw()
        check(world.camera.x>x and hudStrip()==strip,"La cámara se mueve con el encabezado fijo.")
        local npc=Exploration.nearby(app.session)
        check(npc and npc.id=="eris","Eris activa el indicador real de interacción.")
        capture("hud")
        love.keypressed("m");love.draw()
        check(world.modal=="map","M abre el minimapa.")
        capture("minimapa")
        love.keypressed("j");love.draw()
        check(world.modal=="journal","J abre el diario.")
        menu()

        click("Conversación con cartas · Sylphie")
        drawWhen()
        check(screen().wife=="sylphiette" and #screen().offers==3,"El clic abre tres actividades reales.")
        love.keypressed("2");love.keypressed("return");drawWhen()
        click("Preparar las cartas")
        drawWhen(function() return screen().mode=="hand" end)
        local activity=Activities.current(app.session)
        check(#activity.hand==3 and activity.dealComplete,"Se reparten tres cartas reales.")
        click(1);love.draw()
        local id=activity.hand[1]
        check(screen().mode=="preview" and screen().selectedCard==id and #Activities.response(app.session,id).rudy>0,"El clic muestra la frase de Rudy.")
        capture("social")
        local energy=activity.energy
        love.keypressed("return")
        check(screen().mode=="playing" and activity.energy==energy-Activities.cost(app.session,id),"Enter inicia la animación y cobra el coste de energía.")
        drawWhen(function() return screen().mode=="reply" end)
        check(screen().bars:feedback() and app.session.events[activity.instance_id.."_card_1"],"La reacción actualiza las barras mediante un evento real.")
        capture("reaccion")
        menu()
        click("Tutorial social · Nanahoshi")
        drawWhen()
        check(screen().tutorial and screen().definition.character=="nanahoshi","También abre la pantalla original del tutorial.")
        menu()

        local function startCombat()
            click("Combate libre · Anomalía");drawWhen()
            assert(screen().enc and screen().enc.type=="combat")
            if screen().briefingOpen then love.keypressed("return");love.draw() end
            return screen()
        end
        local battle=startCombat()
        check(battle.enc.enemy.intent.text and #battle.enc.hand==3,"La batalla muestra mano e intención iniciales.")
        local energyBefore=battle.enc.energy
        love.keypressed("d")
        check(battle.enc.player.shield>0 and battle.enc.energy<energyBefore,"Defensa cambia escudo y acciones.")
        drawWhen(function() return not battle:busy() end)
        click("Terminar turno [E]")
        drawWhen(function() return not battle:busy() end)
        for _=1,30 do
            if battle.enc.finished then break end
            love.keypressed("e");drawWhen(function() return not battle:busy() end)
        end
        check(battle.enc.outcome=="defeat","La anomalía puede causar una derrota real.")
        capture("derrota")
        menu()

        battle=startCombat()
        capture("combate")
        local animatedDamage=false
        for _=1,90 do
            if battle.enc.finished then break end
            local best,damage
            for index,card in ipairs(battle.enc.hand) do
                local value=Combat.card(card,battle.enc).effects.damage or 0
                if battle:canPlay(index) and value>(damage or 0) then best,damage=index,value end
            end
            if best then
                local hp=battle.enc.enemy.hp
                love.keypressed(tostring(best));love.keypressed("return")
                if battle:busy() and battle.enc.enemy.hp<hp then animatedDamage=true end
            else love.keypressed("e") end
            drawWhen(function() return not battle:busy() end)
        end
        check(animatedDamage and battle.enc.outcome=="victory","Ataques con animación y victoria a través de la interfaz.")
        capture("victoria")
        love.keypressed("return");drawWhen()
        check(screen().kind=="demo_ui","Continuar tras la victoria regresa a la demostración.")
        click("HUD de exploración · Patio de Eris");drawWhen()
        love.keypressed("f5")
        love.quit()
        check(app.session~=nil,"F5 y el cierre mantienen el carácter temporal de la sesión.")
    end,debug.traceback)
    Save.write,love.keyboard.isDown=previousWrite,previousHeld
    love.filesystem.setIdentity(previousIdentity)
    assert(ok,err)
    print(string.format("Demo UI: %d comprobaciones; %d capturas del renderizador real.",checks,captures))
end

return Suite
