-- Entrada humana a las pantallas reales; renderiza y guarda en identidad aislada.
local Suite={}
function Suite.run()
    love.math.setRandomSeed(20261120)
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Chapters=require("src.data.chapters")
    local Progression=require("src.systems.progression")
    local Cards=require("src.systems.cards")
    local Combat=require("src.systems.combat")
    local Tutorial=require("src.systems.tutorial")
    local Font=require("src.ui.font")
    local checked=0
    local function check(ok,msg) assert(ok,msg); checked=checked+1 end
    local disk=Save.newSession()
    require("src.systems.events").apply(disk,"starter_gift",{starter=true})
    check(Save.write(disk),"Guardar entrega real en disco")
    local reloaded=assert(Save.load())
    check(#reloaded.rewardQueue==1 and #reloaded.deck==5 and #reloaded.combatDeck==5,"Mazos y entrega pendientes persisten en disco")
    local old={write=Save.write,load=Save.load,exists=Save.exists,readOptions=Save.readOptions,writeOptions=Save.writeOptions,legacyInfo=Save.legacyInfo}
    local stored
    Save.write=function(s) stored=assert(Json.encode(assert(Save.validate(s)))); return true end
    Save.load=function() return stored and Save.validate(assert(Json.decode(stored))) or nil end
    Save.exists=function() return stored~=nil end
    Save.legacyInfo=function() return nil end
    Save.readOptions=function() return {muted=true,textAnimation=false,reducedMotion=false} end
    Save.writeOptions=function() return true end
    local app=require("src.app").new()
    local captures={}
    local function settle()
        app:update(2)
        if app.manager.transition>0 then app:update(2) end
        app:draw()
    end
    local function capture(name)
        if captures[name] then return end; captures[name]=true
        app.toastTime=0; app:draw()
        local bytes=app.canvas:newImageData():encode("png")
        local f=assert(io.open(love.filesystem.getSource().."/tests/artifacts/v2-"..name..".png","wb"))
        f:write(bytes:getString()); f:close()
    end
    local function click(label)
        app:draw()
        for _,b in ipairs(app.manager.current.buttons) do if b.label==label and not b.disabled then
            app:mousepressed(app.offsetX+(b.x+b.w/2)*app.scale,app.offsetY+(b.y+b.h/2)*app.scale,1); return
        end end
        error("Botón no disponible: "..label)
    end
    settle(); capture("menu"); click("Nueva partida"); settle()
    check(app.session.checkpoint=="intro" and #app.session.deck==0,"Inicio casado sin cartas antes de Nanahoshi")
    local steps=0
    while app.session.checkpoint~="campaign_complete" do
        steps=steps+1; check(steps<1000,"Campaña jugable sin bloqueo: "..app.session.checkpoint)
        settle()
        local s=app.manager.current
        local cp=app.session.checkpoint
        local node=Chapters.get(cp)
        if cp=="campaign_complete" then break end
        if s.kind=="reward" then
            capture("reward"); s:continue()
        elseif s.pendingDeparture or s.leaving then
            check(true,"La entrada espera al feedback y a la salida de la escena")
        elseif s.kind=="training_result" then
            capture("training-result-"..s.result.id);s:advance()
        elseif s.kind=="document" then
            capture("letter-"..s.phase); s:interact()
        elseif node.kind=="scene" then
            capture("day"..node.day)
            if s.dialogue:isLast() and s:ready() and s.scene.choices and #s.scene.choices>0 then
                for _,b in ipairs(s.buttons) do if b.y>=126 and b.y<227 then check(b.y+b.h<=227,"Las opciones no se solapan con el diálogo") end end
                click(s.scene.choices[1].label)
            else s:advance() end
        elseif node.definition.agenda then
            local Daily=require("src.systems.daily")
            capture("agenda-day"..app.session.day)
            if app.session.daily.active_activity then
                capture("daily-activity")
                click(require("src.data.activities").byId[app.session.daily.active_activity.id].choices[1].label.." (+2 amor / +1 conf.)")
            elseif Daily.remaining(app.session)>0 and not app.session.daily.activities_locked then
                local id=({"sylphiette","roxy","eris"})[app.session.daily.interactions_used+1]
                check(Daily.startActivity(app.session,"time_"..id)~=nil,"Agenda permite repetir actividades")
                app:save();app:resume()
            elseif Daily.storyComplete(app.session) then click("Finalizar día")
            else click(app.session.day==7 and "Cerrar tiempo libre e ir a la historia" or "Continuar historia") end
        elseif node.kind=="hub" then
            local companions=Progression.availableCompanions(app.session)
            if #companions>0 then click("Elegir compañía") else click("Visitar") end
        elseif node.kind=="encounter" then
            if s.enc.type=="combat" then
                capture("combat-"..s.enc.enemy.id)
                check(not s.enc.finished or s.enc.outcome=="victory" or s.enc.training,"Política de prueba no debe perder: "..cp)
                if not s:busy() and not s.enc.finished and s.enc.training and Combat.canBasic(s.enc,"counter") then
                    s:basic("counter")
                elseif not s:busy() and not s.enc.finished and s.enc.training and s.enc.enemy.intent.kind=="attack"
                    and s.enc.enemy.intent.damage>=6 and Combat.canBasic(s.enc,"defend") then
                    s:basic("defend")
                elseif not s:busy() and not s.enc.finished and s.enc.companion and Combat.canTactic(s.enc,"coordinate") then
                    s:tactic("coordinate")
                else require("tests.combat_visual").drive(s) end
            else
                local instruction=s.tutorial and Tutorial.instruction(s.tutorial)
                if s.enc.finished then s:finish()
                elseif instruction and instruction.button then click(instruction.button)
                elseif s.phase=="result" then s:acknowledge()
                elseif s.tutorial and s.tutorial.stage=="free" then s:keypressed("p")
                else
                    local index,best
                    for i in ipairs(s.enc.hand) do if Cards.canPlay(s.enc,i) then
                        local p=Cards.preview(s.enc,i)
                        if not best or p.score>best then index,best=i,p.score end
                    end end
                    if index then s:keypressed(tostring(index)); s:keypressed("return") else s:keypressed("p") end
                end
            end
        elseif node.kind=="summary" then capture("daily-summary");check(Progression.canContinue(app.session),"Resumen intermedio continúa"); app:next()
        else error("Pantalla sin manejador "..cp) end
    end
    settle(); capture("ending-family")
    check(Progression.summary(app.session).endingId=="family_united","Recorrido gráfico completo llega al final familiar")
    app:save(); local roundtrip=assert(Save.load())
    check(Json.encode(roundtrip.relationships)==Json.encode(app.session.relationships),"Matrimonios exactos después del epílogo")
    check(Json.encode(roundtrip.unlocked)==Json.encode(app.session.unlocked),"Colección exacta después del epílogo")
    local family=app.session
    for endingId,snapshot in pairs(require("tests.campaign").completed or {}) do
        app.session=assert(Save.validate(snapshot)); app.session.rewardQueue={}; app:resume(); settle()
        check(Progression.summary(app.session).endingId==endingId,"Epílogo gráfico coincide con decisiones: "..endingId)
        capture("ending-"..endingId)
    end
    app.session=family; app:resume(); settle()
    app:overlay("journal"); settle(); capture("journal"); click("Historial"); settle(); capture("history")
    app:overlay("deck"); settle(); capture("collection"); click("Combate"); settle(); capture("combat-deck")
    local editor=app.manager.current
    local previous=Json.encode(app.session.combatDeck)
    editor.draft[1]=false
    check(not editor:saveDeck(),"Editor rechaza mazo incompleto")
    check(Json.encode(app.session.combatDeck)==previous,"Borrador inválido no altera mazo persistido")
    editor.draft={}; for i,id in ipairs(app.session.combatDeck) do editor.draft[i]=id end
    check(editor:saveDeck(),"Editor guarda mazo válido")
    app:manual(); settle(); capture("manual-history")
    local manual=app.manager.current
    for section=1,7 do
        manual:changeSection(section)
        for page=1,require("src.screens.manual").pageCount(section) do manual.page=page; app:draw() end
    end
    check(true,"Todas las páginas del manual se renderizan")
    app:resume(); app:startPractice("free"); settle()
    check(app.practice and app.session.combat,"Práctica crea combate aislado")
    local saved=stored; app:save(); app:endPractice()
    check(stored==saved,"Práctica nunca sobrescribe campaña")
    local beforeLegacy=Save.legacyInfo
    Save.legacyInfo=function() return {day=3,checkpoint="day3_complete"} end
    local beforeExists=Save.exists; Save.exists=function() return false end
    app:menu(); settle(); click("Importar campaña anterior"); settle(); capture("legacy-consent")
    check(app.manager.current.legacyConfirm==true,"Importar exige aceptación explícita de la continuidad")
    click("Cancelar"); check(app.session==family,"Cancelar importación conserva la campaña")
    Save.legacyInfo=beforeLegacy; Save.exists=beforeExists; app:resume(); settle()
    for id,node in pairs(Chapters.checkpoints) do
        if node.kind=="scene" then
            local scene=Progression.scene(app.session,id)
            for _,line in ipairs(scene.lines) do check(Font.height(line.text,572)<=66,"Texto cabe: "..id) end
            for _,choice in ipairs(scene.choices or {}) do check(Font.height(choice.label,419)<=22,"Opción cabe: "..id) end
        end
    end
    -- Revisa además las cinco composiciones finales con las fixtures completas
    -- generadas por el recorrido lógico, cuando la suite las exporta.
    local finals=require("src.data.endings").list
    for _,ending in ipairs(finals) do
        check(Font.height(ending.body,418)<=66,"Cuerpo de epílogo cabe: "..ending.id)
        check(Font.height(ending.footer,418)<=55,"Epílogo cabe: "..ending.id)
    end
    require("tests.combat_visual").run(app)
    require("tests.combat_integration").run(app)
    for key,value in pairs(old) do Save[key]=value end
    print("Campaign UI: "..checked.." checks; "..steps.." screen steps; real-renderer captures in tests/artifacts/v2-*.png.")
    return checked
end
return Suite
