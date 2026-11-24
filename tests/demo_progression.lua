local Save=require("src.systems.save")
local Activities=require("src.systems.wife_activities")
local Events=require("src.systems.events")
local Daily=require("src.systems.daily")
local Cards=require("src.systems.card_collection")
local Social=require("src.systems.social_rules")

local Suite={}

function Suite.run()
    local setIdentity=love.filesystem.setIdentity
    local campaign=love.filesystem.getIdentity()
    local academic=campaign.."_academic"
    -- Ambas identidades pertenecen al módulo de pruebas; se usa guardado en disco real.
    setIdentity(academic)
    for _,file in ipairs({Save.filename,Save.backup,Save.optionsFile}) do
        if love.filesystem.getInfo(file) then assert(love.filesystem.remove(file)) end
    end
    setIdentity(campaign)
    assert(Save.write(Save.newSession()))
    local campaignBytes=assert(love.filesystem.read(Save.filename))
    love.filesystem.setIdentity=function(identity)
        assert(identity=="cartas_del_destino_demo_progresion","Perfil académico incorrecto.")
        return setIdentity(academic)
    end

    local checks,captures=0,0
    local function check(value,message)
        assert(value,message)
        checks=checks+1
    end
    local ok,err=xpcall(function()
        local app
        local function screen() return app.manager.current end
        local function drawWhen(predicate)
            for _=1,120 do
                if app.manager.transition==0 and (not predicate or predicate()) then love.draw();return end
                love.update(.1)
            end
            error("No terminó la transición o animación de progresión.")
        end
        local function load()
            app=assert(love.load({"--demo-progression"}))
            app.options.muted=true
            app:applyAudio()
            drawWhen()
            assert(screen().kind=="demo_progression")
            return app.session
        end
        local function click(label)
            for _,button in ipairs(screen().buttons) do
                if button.label and button.label:find(label,1,true) then
                    assert(not button.disabled,label)
                    love.mousepressed(app.offsetX+(button.x+button.w/2)*app.scale,
                        app.offsetY+(button.y+button.h/2)*app.scale,1)
                    drawWhen()
                    return
                end
            end
            error("Control ausente: "..label)
        end
        local function capture(name)
            local pixels=app.canvas:newImageData()
            local encoded=pixels:encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/demo-progression-"..name..".png","wb"))
            assert(file:write(encoded:getString()));file:close()
            encoded:release();pixels:release();captures=captures+1
        end
        local function complete(label,id)
            local session=app.session
            local remaining=Daily.remaining(session)
            local definition=Activities.bank.byId[id]
            local relation=session.relationships[definition.character]
            local loveBefore,trustBefore=relation.love,relation.trust
            click(label)
            local active=Activities.current(session)
            check(active and active.id==id and Daily.remaining(session)==remaining,"Selección real sin consumo anticipado.")
            love.keypressed("return");drawWhen(function() return screen().mode=="hand" end)
            local best,score
            for index,card in ipairs(active.hand) do
                local values=Social.effects(session,card,definition.character,Activities.response(session,card),{emotion=definition.emotion})
                local value=values.love+values.trust
                if Activities.canPlay(session,card) and value>(score or -math.huge) then best,score=index,value end
            end
            love.keypressed(tostring(assert(best)));love.keypressed("return")
            drawWhen(function() return screen().mode=="reply" end)
            check(relation.love~=loveBefore or relation.trust~=trustBefore,"La respuesta se refleja en la relación.")
            love.keypressed("return");drawWhen(function() return screen().mode=="hand" end)
            love.keypressed("p");drawWhen()
            local result=session.wifeActivities.review
            check(screen().mode=="review" and result.id==id and #result.continuation>0
                and Daily.remaining(session)==remaining-1 and session.events[result.instance],"Resultado, evento único y consumo de una interacción.")
            check(result.delta.love==relation.love-loveBefore and result.delta.trust==relation.trust-trustBefore,"El recibo coincide con los cambios reales de amor y confianza.")
            capture(id.."-resultado")
            love.keypressed("return");drawWhen()
            check(screen().kind=="reward" and screen().reward.eventId==result.instance,"La actividad abre la adquisición asociada al evento.")
            return result
        end
        local function finishReward(name)
            for _=1,12 do love.update(.1) end
            love.draw();capture(name)
            click("VER RESUMEN")
            click("CONTINUAR")
            check(screen().kind=="demo_progression" and #app.session.rewardQueue==0,"La presentación se consume y vuelve al menú.")
        end

        local session=load()
        check(love.filesystem.getIdentity()==academic and session.day==1 and Daily.remaining(session)==3,
            "Arranque en el perfil académico con una jornada nueva.")
        capture("menu")
        local gold,copies=session.gold,session.collection.listen.copies
        local result=complete("Limpiar la casa","S02")
        check(result.gold==12 and session.gold==gold+12 and result.copies.listen==1
            and session.collection.listen.copies==copies+1 and not screen():isNew(),"Sylphie otorga 12 oro y una copia de Escuchar.")
        local instance=result.instance
        love.keypressed("f5");love.quit()
        session=load()
        check(session.day==1 and session.gold==gold+12 and session.collection.listen.copies==copies+1
            and session.unlocked.listen and session.events[instance] and Daily.remaining(session)==2,"Se restauran día, oro, copias, desbloqueo e interacciones.")
        click("Continuar actividad o recompensa")
        check(screen().kind=="reward" and screen().reward.eventId==instance,"La adquisición pendiente se restaura.")
        check(not Events.apply(session,instance,{copies={listen=1},gold=12})
            and session.collection.listen.copies==copies+1 and session.gold==gold+12,"El ID aplicado rechaza una segunda concesión.")
        finishReward("copia-social")

        check(not session.unlocked.wind_guard,"Defensa física comienza bloqueada.")
        local sylphie=session.relationships.sylphiette
        local sylphieLove,sylphieTrust=sylphie.love,sylphie.trust
        result=complete("Entrenar con escudo","E06")
        check(result.gold==0 and result.items.magic_material==1 and screen().reward.counts.wind_guard==1
            and session.unlocked.wind_guard and screen():isNew(),"Eris desbloquea Defensa física y concede el material de la actividad.")
        check(sylphie.love==sylphieLove and sylphie.trust==sylphieTrust,"La segunda actividad conserva la relación anterior.")
        finishReward("carta-fisica")

        click("Colección y mejoras")
        check(screen().kind=="deck" and Cards.view(session,"listen").copies==copies+1,"La colección refleja la copia adquirida.")
        capture("coleccion")
        click("Combate");click(">");click("Defensa física")
        check(screen().catalog[screen().selected]=="wind_guard","La carta física se puede inspeccionar en el mazo de combate.")
        capture("detalle-fisico")
        click("Mejorar")
        check(screen().kind=="upgrades" and Cards.list[screen().index].id=="wind_guard","La carta seleccionada abre su pantalla de mejoras.")
        capture("mejoras")
        love.keypressed("f9");drawWhen()
        love.quit()
        local beforeLoad=session
        session=load()
        check(session.relationships.eris.love==beforeLoad.relationships.eris.love
            and session.relationships.eris.trust==beforeLoad.relationships.eris.trust
            and session.unlocked.wind_guard and session.collection.wind_guard.copies==beforeLoad.collection.wind_guard.copies
            and session.economy.items.magic_material==beforeLoad.economy.items.magic_material
            and #session.rewardQueue==0 and Daily.remaining(session)==1,"Las dos decisiones y sus recursos sobreviven a otro arranque.")
        setIdentity(campaign)
        check(love.filesystem.read(Save.filename)==campaignBytes,"El guardado de control de la campaña queda intacto.")
    end,debug.traceback)
    love.filesystem.setIdentity=setIdentity
    setIdentity(academic)
    assert(ok,err)
    print(string.format("Demo progresión: %d comprobaciones; %d capturas del renderizador real.",checks,captures))
end

return Suite
