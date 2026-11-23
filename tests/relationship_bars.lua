local Suite={}
function Suite.run()
    local Bars=require("src.ui.relationship_bars")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Font=require("src.ui.font")
    local Events=require("src.systems.events")
    local Cards=require("src.systems.cards")
    local Resolver=require("src.systems.dialogue_resolver")
    local Progression=require("src.systems.progression")
    local Fixtures=require("tests.dialogue_branching")
    local checks,captures=0,0
    local function check(value,message) assert(value,message); checks=checks+1 end
    local function encode(value) return assert(Json.encode(value)) end
    local function near(a,b) return math.abs(a-b)<.001 end
    local sounds={}
    local audio={effect=function(_,name) sounds[#sounds+1]=name end}
    local session=Save.newSession({love=65,trust=65})
    session.relationships.eris.love,session.relationships.eris.trust=98,1
    local bars=Bars.new(session,"eris",{audio=audio})
    check(bars and bars.value.love==98 and bars.value.trust==1,"Valores iniciales matrimoniales definitivos")
    check(not Bars.new(session,"rudeus") and not Bars.new(session,"hitogami") and not Bars.new(session,"rudeus_japones"),"Sin barras ni identidad romántica para Rudy o Hitogami")
    Events.apply(session,"bars_bounds",{character="eris",love=5,trust=-5})
    local committed=encode(session)
    check(bars:apply("bars_bounds",session,{love=5,trust=-5},"Una respuesta sincera, pero brusca."),"Un evento confirmado inicia el feedback")
    check(bars.target.love==100 and bars.target.trust==-4 and bars.value.love==98,"El destino lógico queda aplicado antes de animar")
    check(bars:feedback().deltas.love==2 and bars:feedback().deltas.trust==-5,"El feedback usa los deltas reales recortados")
    bars:update(.3)
    check(near(bars.value.love,99) and near(bars.value.trust,-1.5),"La interpolación alcanza el punto medio a 0.3 segundos")
    bars:update(.3)
    check(bars.value.love==100 and bars.value.trust==-4 and bars.tween==nil,"La interpolación termina exactamente a 0.6 segundos")
    check(encode(session)==committed,"La presentación nunca escribe en el estado lógico")
    check(not bars:apply("bars_bounds",session) and #sounds==1 and sounds[1]=="negative","Un evento repetido no repite ni feedback ni sonido")
    local loaded=Bars.new(session,"eris",{audio=audio})
    check(not loaded:apply("bars_bounds",session) and loaded.notifications==0 and not loaded:feedback(),"Cargar un evento histórico no reproduce sus efectos visuales")
    check(not bars:apply("no_change",session) and #sounds==1,"Un delta cero no inventa corazones ni sonidos")
    local original=bars:layout({x=80,y=100,w=64,h=64,width=116,alpha=.5})
    local moved=bars:layout({x=85,y=94,w=64,h=64,width=116,alpha=.5})
    check(moved.x-original.x==5 and moved.y-original.y==-6 and moved.alpha==.5,"Las barras siguen posición y alfa reales del retrato")
    check(original.y+original.h==96 and original.portrait.y==100,"La placa queda por encima del rostro con cuatro píxeles de separación")
    local nana=Bars.new(session,"nanahoshi",{audio=audio,reducedMotion=true})
    check(nana.fields[1].key=="trust" and nana.fields[2].key=="interest" and nana.value.love==nil,"Nanahoshi usa confianza e interés separados del matrimonio")
    local oldNana=nana.target.interest
    session.affinities.nanahoshi.interest=oldNana+3
    nana:apply("nana_bars",session,{interest=3},"La propuesta ayuda a investigar.")
    check(nana.value.interest==oldNana+3 and nana:feedback().deltas.interest==3,"Movimiento reducido muestra el valor definitivo sin desplazamiento")
    local invalid=Save.newSession({love=65,trust=65}); invalid.relationships.eris.love=0/0; invalid.relationships.eris.trust=math.huge
    local sanitized=Bars.new(invalid,"eris")
    check(sanitized.value.love==0 and sanitized.value.trust==0,"Números no finitos nunca deforman las barras")
    for id,node in pairs(require("src.data.dialogue").nodes) do
        if node.text then check(Font.height(node.text,462)<=33,"Briefing y continuación caben junto al retrato: "..id) end
    end
    for id,step in pairs(require("src.systems.tutorial").instructions) do
        check(Font.height(step.text,462)<=44,"La guía cabe en el briefing de ancho462: "..id)
    end

    local identity=love.filesystem.getIdentity()
    local originalOptions,originalFont,originalScene=Save.readOptions,Font.draw,Progression.scene
    love.filesystem.setIdentity("cartas_del_destino_relationship_ui_tests")
    Save.readOptions=function() return {muted=true,textAnimation=false,reducedMotion=false} end
    love.graphics.push("all")
    local ok,err=xpcall(function()
        local app=require("src.app").new()
        app.mouse=function() return nil,nil end
        local rendered={}
        Font.draw=function(value,...)
            rendered[#rendered+1]=tostring(value)
            return originalFont(value,...)
        end
        local function draw()
            app.toastTime=0; rendered={}; app:draw(); return table.concat(rendered,"\n")
        end
        local function capture(name)
            draw(); local pixels=app.canvas:newImageData(); local bytes=pixels:encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/relationship-"..name..".png","wb"))
            file:write(bytes:getString()); file:close(); bytes:release(); pixels:release(); captures=captures+1
        end
        local function settle()
            if app.manager.transition>0 then app:update(app.manager.transition) end
            app:update(2)
            local screen=app.manager.current
            if screen.enc and screen.enc.narrativeVersion then while not screen.enc.dealComplete do app:update(.1) end end
            draw()
        end
        -- Componente dibujado por LÖVE: signos exactos y términos adecuados.
        love.graphics.setCanvas(app.canvas); rendered={}
        bars:draw({x=40,y=94,w=64,h=64,width=116})
        local signed=table.concat(rendered,"\n")
        check(signed:find("+2",1,true) and signed:find("-5",1,true),"El renderer conserva los signos del incremento y descenso reales")
        rendered={}; nana:draw({x=180,y=94,w=64,h=64,width=116})
        local affinityText=table.concat(rendered,"\n")
        check(affinityText:find("Confianza",1,true) and affinityText:find("Interés",1,true) and not affinityText:find("Amor",1,true),"El renderer de Nanahoshi no muestra amor")
        love.graphics.setCanvas()
        local function encounter(card,character)
            local checkpoint=character=="nanahoshi" and "day1_tutorial" or "encounter_eris"
            local current,definition=Fixtures.fixture(checkpoint,{"listen","be_honest","encourage","light_joke","subtle_flirt"})
            for i,id in ipairs(current.deck) do if id==card then table.remove(current.deck,i); break end end
            current.deck[#current.deck+1]=card
            local context
            if character=="nanahoshi" then
                definition.kind,definition.character="conversation","nanahoshi"
                context=Resolver.context(current,definition,"nanahoshi_test"); context.socialTutorial=true
            else context=Resolver.context(current,definition) end
            current.encounter=Cards.new(current.deck,context,function(n) return n end)
            app.session=current; app:resume(); settle()
            local screen=app.manager.current
            check(screen.enc.hand[1]==card and screen.relationshipBars.character==character,"Fixture social y barras de la interlocutora correctas")
            sounds={}; app.audio.effect=audio.effect
            -- audio.effect uses the live sounds upvalue, without playing hardware audio.
            local before=encode(app.session.relationships)
            screen:select(1); screen:act(1); app:update(.3)
            check(screen.relationshipBars.notifications==0 and encode(app.session.relationships)==before,"La carta en vuelo no anuncia ni aplica cambios")
            for _,sound in ipairs(sounds) do check(sound~="positive" and sound~="negative","Sin sonido de resultado durante la carta") end
            app:update(2)
            check(screen:responseLine().speaker=="rudeus" and screen.relationshipBars.notifications==0,"La frase de Rudy mantiene el feedback pendiente")
            local seenPortrait
            local originalPortrait=app.resources.portrait
            app.resources.portrait=function(self,id,...)
                seenPortrait=id; return originalPortrait(self,id,...)
            end
            draw(); app.resources.portrait=originalPortrait
            check(seenPortrait==character,"Durante la frase de Rudy permanece la interlocutora, no sus barras sobre Rudy")
            local box=screen.relationshipBars.lastBounds
            check(box.x>=0 and box.x+box.w<=135 and box.y>=38 and box.y+box.h<box.portrait.y,"La placa cabe entre cabecera, retrato y diálogo")
            capture(character.."-"..card.."-rudy")
            screen:acknowledge()
            local result=screen.enc.log[1]
            check(result.applied and screen.relationshipBars.notifications==1,"La reacción aplica y anuncia una vez el cambio")
            local actual=screen.relationshipBars:feedback().deltas
            check(actual.trust==result.actualTrust and (character=="nanahoshi" and actual.interest==result.actualInterest or character~="nanahoshi" and actual.love==result.actualLove),"Deltas flotantes iguales a los persistidos")
            local effects=0; for _,sound in ipairs(sounds) do if sound=="positive" or sound=="negative" then effects=effects+1 end end
            check(effects==1,"Un único sonido de resultado después de commit")
            screen:showResponse(); screen:history(); screen:history()
            check(screen.relationshipBars.notifications==1,"Reabrir historial o mostrar la reacción no duplica efectos")
            app:update(.2); capture(character.."-"..card.."-reaction")
            local bounds=screen.relationshipBars.lastBounds
            check(bounds.portrait.x==40+math.floor(screen.actor.value.x) and bounds.portrait.y==94+math.floor(screen.actor.value.y),"La barra sigue la sacudida o el salto real del retrato")
            local saved=assert(Save.load())
            check(saved.events[require("src.systems.dialogue_memory").key(screen.enc.context.sceneId,1)],"El cambio ya está guardado durante la animación")
            app:continueGame(); settle(); screen=app.manager.current
            check(screen.relationshipBars.notifications==0 and not screen.relationshipBars:feedback(),"Cargar la reacción muestra valores finales sin repetir feedback")
            local actualValues=Bars.read(app.session,character)
            for key,value in pairs(actualValues) do check(screen.relationshipBars.value[key]==value,"Valor final exacto al cargar: "..key) end
            local logicalBefore=encode({app.session.relationships,app.session.affinities})
            local last=#screen.enc.log[1].sequence
            for _=screen.enc.reactionIndex,last do screen:acknowledge() end
            check(encode({app.session.relationships,app.session.affinities})==logicalBefore and screen.relationshipBars.notifications==0,
                "Continuar rápidamente la secuencia cargada no vuelve a aplicar ni anunciar el cambio")
            return screen
        end
        encounter("light_joke","eris")
        encounter("encourage","eris")
        encounter("listen","nanahoshi")

        local synthetic={title="Conversación de prueba",background="home",lines={
            {speaker="roxy",expression="happy",text="Podemos revisar juntas las notas."},
            {speaker="rudeus",expression="neutral",delivery="enchanted",text="Empecemos por el primer símbolo."},
        }}
        app.session=Save.newSession({love=65,trust=65}); app.session.checkpoint="day1_warning"
        Progression.scene=function() return synthetic end
        local screen=require("src.screens.dialogue").new(app)
        app.manager.current=screen; app.manager.transition=0; screen:update(2); draw()
        local box=screen.relationshipBars.roxy.lastBounds
        check(box and box.y>=38 and box.y+box.h<box.portrait.y and box.portrait.y+box.portrait.h<=227,"Diálogo: barras sobre retrato sin invadir la caja de texto")
        screen:advance(); screen:update(.2); draw()
        check(screen.presentation.cast[1].character=="roxy" and screen.dialogue:current().speaker=="rudeus","Diálogo single conserva la interlocutora durante la respuesta de Rudy")
        capture("dialogue-roxy")
        app.session.dialogueIndex=2
        local loadedScreen=require("src.screens.dialogue").new(app)
        check(loadedScreen.presentation.cast[1].character=="roxy","Cargar en la respuesta reconstruye la interlocutora persistente")
        synthetic.cast={{character="roxy",position="left"},{character="eris",position="right"}}
        app.session.dialogueIndex=1; screen=require("src.screens.dialogue").new(app)
        app.manager.current=screen; screen:update(2); draw()
        check(screen.relationshipBars.roxy.lastBounds.x==39 and screen.relationshipBars.eris.lastBounds.x==473,"Reparto explícito ancla cada barra a su propio retrato")
        capture("dialogue-cast")
        Progression.scene=originalScene
        app.session=Save.newSession({love=65,trust=65}); app:resume(); settle(); draw()
        local dream=app.manager.current
        check(not dream.relationshipBars.roxy.lastBounds and not dream.relationshipBars.eris.lastBounds and not dream.relationshipBars.nanahoshi.lastBounds,"El sueño de Hitogami no muestra barras ajenas")
        capture("dream-no-bars")
    end,debug.traceback)
    Save.readOptions,Font.draw,Progression.scene=originalOptions,originalFont,originalScene
    love.graphics.setCanvas(); love.graphics.pop(); love.filesystem.setIdentity(identity)
    assert(ok,err)
    Suite.report={checks=checks,captures=captures}
    print("Relationship bars: "..checks.." checks; "..captures.." real-renderer captures; anchors, real deltas, one-time feedback and save/restore.")
    return checks
end
return Suite
