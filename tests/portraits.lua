-- Apariencia reconstruida desde datos narrativos y guardados v3 reales.
-- Las capturas se producen con el renderer de LÖVE, sin alterar los PNG.
local Suite={}
function Suite.run()
    local Portraits=require("src.systems.portraits")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Characters=require("src.data.characters")
    local Assets=require("src.data.assets")
    local Progression=require("src.systems.progression")
    local Resources=require("src.systems.resources")
    local Options=require("src.systems.options")
    local checked,captures=0,0
    local function check(value,message) assert(value,message); checked=checked+1 end
    local function encode(value) return assert(Json.encode(value)) end
    local function clone(value) return assert(Json.decode(encode(value))) end
    local function actor(presentation,id)
        for _,entry in ipairs(presentation.cast) do if entry.character==id then return entry end end
    end
    local function appearance(presentation)
        local values={background=presentation.background,cast={}}
        for _,entry in ipairs(presentation.cast) do
            values.cast[#values.cast+1]={character=entry.character,portrait=entry.portrait,
                expression=entry.expression,position=entry.position,visible=entry.visible}
        end
        return encode(values)
    end

    local session=Save.newSession()
    local intro=Progression.scene(session,"intro")
    check(intro.context=="hitogami_dream","El sueño declara el contexto; no se infiere del hablante")
    check(not Characters.byId.rudeus_japones,"La apariencia japonesa no crea una segunda identidad lógica")
    check(not session.relationships.rudeus and not session.relationships.rudeus_japones,"El protagonista no duplica estadísticas matrimoniales")
    local logicalCount=0
    for _,character in ipairs(Characters.list) do if character.id=="rudeus" then logicalCount=logicalCount+1 end end
    check(logicalCount==1,"Existe exactamente una identidad Rudy")
    local before=encode(session)
    local source=encode(intro)
    local expressions={}
    for index,line in ipairs(intro.lines) do
        local resolved=Portraits.resolve(intro,index)
        local rudy=actor(resolved,"rudeus")
        check(resolved.background=="dream","Fondo del sueño en la línea "..index)
        check(rudy and rudy.portrait=="rudeus_japones","Rudy japonés permanece incluso mientras habla otro personaje: "..index)
        expressions[rudy.expression]=true
        for _,entry in ipairs(resolved.cast) do check(Characters.byId[entry.character]~=nil,"Los actores conservan identidades registradas") end
        if line.speaker=="rudeus" and line.expression then
            check(rudy.expression==line.expression,"Expresión declarada de Rudy: "..index)
        end
        session.dialogueIndex=index
        local restored=assert(Save.validate(clone(session)))
        check(appearance(Portraits.resolve(Progression.scene(restored,restored.checkpoint),restored.dialogueIndex))==appearance(resolved),
            "JSON y validación v3 reconstruyen fondo, retratos y expresión: "..index)
    end
    session.dialogueIndex=1
    check(encode(session)==before and encode(intro)==source,"Resolver retratos no modifica la sesión ni los datos narrativos")
    check(expressions.neutral and expressions.worried and expressions.angry,"El sueño presenta neutral, preocupación y enfado")
    local future={context="hitogami_dream",lines={}}
    for _,expression in ipairs({"neutral","happy","worried","angry"}) do
        future.lines[#future.lines+1]={speaker="rudeus",expression=expression,text="Un nuevo encuentro mental."}
        check(actor(Portraits.resolve(future,#future.lines),"rudeus").expression==expression,"Contexto reutilizable conserva expresión "..expression)
    end
    check(Portraits.resolve(future,1).background=="dream" and actor(Portraits.resolve(future,1),"rudeus").portrait=="rudeus_japones",
        "Otro sueño reutiliza contexto, fondo y apariencia sin IDs de escena especiales")
    local explicit={background="home",lines={{speaker="rudeus",portrait="rudeus_japones",expression="happy",text="Apariencia explícita."}}}
    local chosen=actor(Portraits.resolve(explicit,1),"rudeus")
    check(chosen.character=="rudeus" and chosen.portrait=="rudeus_japones" and chosen.expression=="happy","speaker, portrait y expression son independientes")
    local staged={context="hitogami_dream",cast={{character="rudeus",position="left",expression="neutral"},{character="hitogami",position="right",expression="happy"}},
        lines={{speaker="hitogami",text="Escucha.",stage={rudeus={expression="angry",animation="small_shake"}}},
            {speaker="hitogami",text="Recuerda."}}}
    check(actor(Portraits.resolve(staged,1),"rudeus").animation=="small_shake","Una línea puede animar al oyente por datos")
    check(actor(Portraits.resolve(staged,2),"rudeus").expression=="angry","La expresión del oyente se reconstruye al cargar una línea posterior")
    check(actor(Portraits.resolve(staged,2),"rudeus").animation==nil,"Reconstruir una línea posterior no repite la sacudida anterior")
    staged.lines[3]={speaker="hitogami",text="Hasta pronto.",stage={rudeus={visible=false}}}
    staged.lines[4]={speaker="rudeus",text="Todavía estoy aquí.",stage={rudeus={visible=true}}}
    check(not actor(Portraits.resolve(staged,3),"rudeus").visible and actor(Portraits.resolve(staged,4),"rudeus").visible,
        "La visibilidad se reconstruye para salidas y reapariciones declarativas")
    local memory={background="home",lines={{speaker="hitogami",delivery="memory",text="Rudy recuerda a Hitogami."},
        {speaker="rudeus",delivery="thought",text="Hitogami sigue en mis pensamientos."}}}
    check(actor(Portraits.resolve(memory,2),"rudeus").portrait=="rudeus","Mencionar o recordar a Hitogami no activa el sueño")
    check(actor(Portraits.resolve(Progression.scene(session,"day1_signature"),3),"rudeus").portrait=="rudeus",
        "El flashback posterior a la carta conserva el cuerpo físico")
    check(require("src.systems.curse").canSpeak(session,"dream") and not require("src.systems.curse").canSpeak(session),
        "La voz mental sigue permitida y la maldición física continúa")

    local Chapters=require("src.data.chapters")
    local Validator=require("src.systems.narrative_validator")
    local function invalid(change,fragment)
        local list=clone(Chapters.list)
        change(list[1].scenes.intro)
        local valid,errors=Validator.validate(Chapters.build(list),{checkFiles=false})
        check(not valid and table.concat(errors,"; "):find(fragment,1,true),"Diagnóstico de autoría visual: "..fragment)
    end
    check(Validator.validate(nil,{checkFiles=false}),"La campaña acepta el contexto y reparto declarados")
    invalid(function(scene) scene.context="unknown_dream" end,"contexto de apariencia desconocido")
    invalid(function(scene) scene.portraits={rudeus="missing"} end,"retrato desconocido")
    invalid(function(scene) scene.lines[1].portrait="missing" end,"retrato desconocido")
    invalid(function(scene) scene.cast[2].character=scene.cast[1].character end,"identidad duplicada")
    invalid(function(scene) scene.cast[2].position=scene.cast[1].position end,"posición duplicada")
    invalid(function(scene) scene.cast={} end,"requiere uno o dos personajes")
    invalid(function(scene) scene.cast[2].position=false end,"posición visual desconocida")
    invalid(function(scene) scene.cast[1].enterAt=0 end,"línea de entrada visual inválida")
    invalid(function(scene) scene.cast[1].enterAt=#scene.lines+1 end,"línea de entrada visual inválida")
    invalid(function(scene) scene.cast[1].entranceDelay=-1 end,"demora de entrada visual")
    invalid(function(scene) scene.cast[1].entranceDelay=math.huge end,"demora de entrada visual")
    invalid(function(scene) scene.lines[1].stage={roxy={expression="happy"}} end,"personaje ajeno al reparto")
    invalid(function(scene) scene.lines[1].stage={rudeus={visible="yes"}} end,"visibilidad de personaje inválida")
    invalid(function(scene) scene.entranceTransition={type="unknown"} end,"tipo de transición visual desconocido")

    local identity=love.filesystem.getIdentity()
    local originalOptions=Save.readOptions
    local originalInfo=love.filesystem.getInfo
    local originalScene=Progression.scene
    local app
    love.filesystem.setIdentity("cartas_del_destino_portraits_tests")
    Save.readOptions=function() return {muted=true,textAnimation=false,reducedMotion=false} end
    love.graphics.push("all")
    local ok,err=xpcall(function()
        app=require("src.app").new()
        app.mouse=function() return nil,nil end
        local function capture(name)
            app.toastTime=0; app:draw()
            local pixels=app.canvas:newImageData()
            local bytes=pixels:encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/portraits-"..name..".png","wb"))
            file:write(bytes:getString()); file:close(); bytes:release(); pixels:release()
            captures=captures+1
        end
        local function settle()
            if app.manager.transition>0 then app:update(app.manager.transition) end
            app:update(1)
            app:draw()
        end
        local function white(name)
            app:update(app.manager.duration/2)
            capture(name)
            local pixels=app.canvas:newImageData()
            local r,g,b=pixels:getPixel(4,4); pixels:release()
            check(r>.99 and g>.99 and b>.99,"Fundido blanco real: "..name)
        end
        settle(); app:newGame()
        check(app.manager.effect.type=="dream","La introducción comienza con transición blanca")
        white("dream-white-in")
        app:update(app.manager.transition)
        app:update(.14)
        local first=app.manager.current
        check(first.actors.hitogami.value.alpha>0 and first.actors.rudeus.value.alpha==0,"Hitogami aparece antes que Rudy")
        capture("hitogami-entry")
        app:update(.28)
        check(first.actors.rudeus.value.alpha>0,"Rudy aparece después de Hitogami")
        capture("rudy-entry")
        settle()
        local relations=encode(app.session.relationships)
        local curse=encode(app.session.curse)
        for index=1,#intro.lines do
            local screen=app.manager.current
            check(screen.dialogue.index==index and app.session.checkpoint=="intro","Avance real de introducción: "..index)
            local expected=appearance(screen.presentation)
            check(actor(screen.presentation,"rudeus").portrait=="rudeus_japones","Pantalla real usa a Rudy japonés: "..index)
            capture(string.format("intro-%02d",index))
            check(app:save(),"Guardar la línea del sueño en disco: "..index)
            app:continueGame(); settle()
            check(appearance(app.manager.current.presentation)==expected,"Continuar restaura la misma composición: "..index)
            check(encode(app.session.relationships)==relations and encode(app.session.curse)==curse,"Guardar/cargar el sueño no cambia vínculos ni maldición")
            if index<#intro.lines then app:keypressed("return"); settle() end
        end
        app:keypressed("return"); app:update(.3)
        check(app.session.checkpoint=="day1_wake" and app.manager.effect.type=="dream","El sueño termina en blanco y entra en el despertar")
        white("dream-white-out")
        settle()
        local awake=app.manager.current.presentation
        check(awake.background=="home" and actor(awake,"rudeus").portrait=="rudeus","Despertar restaura casa y Rudy rubio")
        capture("wake")
        check(app:save(),"Guardar después del despertar")
        app:continueGame(); settle()
        check(appearance(app.manager.current.presentation)==appearance(awake),"Cargar después del despertar nunca conserva la apariencia japonesa")
        check(encode(app.session.relationships)==relations,"El cambio de apariencia y de escena no altera relaciones")
        check(app.session.portrait==nil and app.session.appearance==nil and Save.version==3,"Sin apariencia global persistida ni migración de formato")

        -- Una entrada explícita de escenas anteriores conserva su dirección.
        app.session.checkpoint="day1_signature"; app.session.dialogueIndex=2
        app:resume()
        local memoryScreen=app.manager.current
        check(memoryScreen.actor.kind=="enter_right" and memoryScreen.actor.value.x>0 and memoryScreen.actor.value.alpha==0,
            "El recuerdo de Hitogami conserva enter_right en una escena sin reparto")
        settle()

        local futureScene={title="Encuentro mental posterior",context="hitogami_dream",
            cast={{character="hitogami",position="right",expression="happy",enterAt=1},
                {character="rudeus",position="left",expression="worried",enterAt=2,entranceDelay=.35}},
            lines={{speaker="hitogami",expression="happy",text="Te estaba esperando."},
                {speaker="hitogami",expression="happy",text="Ahora puedes verme."},
                {speaker="hitogami",expression="neutral",text="Escucha con atención."},
                {speaker="hitogami",expression="happy",text="Hasta la próxima.",stage={rudeus={visible=false}}}}}
        local function futureScreen(saved)
            local fixture={session=saved or Save.newSession(),resources=Resources.new(),audio=app.audio,
                options=Options.normalize({muted=true,textAnimation=false}),mouse=function() return nil,nil end}
            function fixture:save() return Save.write(self.session) end
            Progression.scene=function(s,id)
                if s==fixture.session then return futureScene end
                return originalScene(s,id)
            end
            local screen=require("src.screens.dialogue").new(fixture)
            Progression.scene=originalScene
            return screen,fixture
        end
        local stagedScreen,fixture=futureScreen()
        stagedScreen:update(1)
        check(not actor(stagedScreen.presentation,"rudeus").visible,"Un actor con entrada posterior permanece oculto al comenzar")
        stagedScreen:advance()
        check(stagedScreen.dialogue.index==2 and stagedScreen.actors.rudeus.delay==.35,"La línea de entrada futura inicia su demora declarada")
        stagedScreen:update(.2)
        check(stagedScreen.actors.rudeus.value.alpha==0,"La entrada posterior no aparece antes de vencer la demora")
        check(fixture:save(),"Guardar durante una entrada posterior demorada")
        local restoredStage=futureScreen(assert(Save.load()))
        check(restoredStage.dialogue.index==2 and appearance(restoredStage.presentation)==appearance(stagedScreen.presentation),
            "Cargar una entrada posterior reconstruye retrato, expresión y visibilidad desde la línea")
        check(restoredStage.actors.rudeus.delay==.35 and restoredStage.actors.rudeus.value.alpha==0,
            "Cargar en la línea de aparición reinicia limpiamente su entrada demorada")
        stagedScreen:update(.2)
        check(stagedScreen.actors.rudeus.value.alpha>0,"La entrada futura comienza cuando termina la demora")
        stagedScreen:update(1)
        local listener=stagedScreen.actors.rudeus
        stagedScreen:advance()
        check(stagedScreen.actors.rudeus==listener and listener.done and listener.value.alpha==1,
            "Un oyente sin cambios conserva su actor y no repite la entrada al cambiar de línea")
        stagedScreen:update(1); stagedScreen:advance(); stagedScreen:update(1)
        check(not actor(stagedScreen.presentation,"rudeus").visible and stagedScreen.actors.rudeus.done,
            "La salida declarativa oculta a Rudy al terminar su animación")
        local requested={}
        local portraitLoader=fixture.resources.getPortrait
        fixture.resources.getPortrait=function(self,id)
            requested[id]=(requested[id] or 0)+1
            return portraitLoader(self,id)
        end
        local function drawStage()
            requested={}
            love.graphics.setCanvas(app.canvas); stagedScreen:draw(); love.graphics.setCanvas()
        end
        drawStage()
        check(requested.hitogami and not requested.rudeus_japones,"El renderer deja de solicitar el sprite del actor oculto")
        local departures=0
        stagedScreen:depart(function() departures=departures+1 end)
        drawStage()
        check(not requested.rudeus_japones and departures==0,"Abandonar la escena no resucita al actor oculto")
        stagedScreen:update(.04); drawStage()
        check(not requested.rudeus_japones,"El actor oculto tampoco reaparece durante el fundido de salida")
        stagedScreen:update(1); stagedScreen:update(1)
        check(departures==1,"La salida termina una sola vez aunque existan actores ya ocultos")

        -- La misma pantalla se dibuja con el recurso provisional si falta el PNG.
        love.filesystem.getInfo=function(path,...)
            if path==Assets.characters.rudeus_japones then return nil end
            return originalInfo(path,...)
        end
        app.resources=Resources.new()
        app.session=Save.newSession(); app.session.dialogueIndex=2
        app:resume(); settle(); capture("missing-png")
        check(app.resources.sources[Assets.characters.rudeus_japones].status=="fallback","El sueño se dibuja completo aun sin el PNG japonés")
        check(#app.resources.warnings==1 and app.resources.warnings[1]:find("rudeus_japones",1,true),"Diagnóstico único identifica el PNG ausente")
        love.filesystem.getInfo=originalInfo
        app.resources=Resources.new():preload()

        app.options=Options.normalize({muted=true,textAnimation=false,reducedMotion=true})
        app.session=Save.newSession(); app:resume()
        check(app.manager.effect.type=="dream" and app.manager.duration<=.15,"Movimiento reducido conserva el blanco del sueño con un fundido breve")
        white("reduced-dream-white")
        settle()
        for _,motion in pairs(app.manager.current.actors) do
            check(motion.done and motion.value.x==0 and motion.value.y==0,"Los dos retratos respetan movimiento reducido")
        end
        check(actor(app.manager.current.presentation,"rudeus").portrait=="rudeus_japones","Accesibilidad conserva apariencia y expresión")

        -- Mismo objeto Resources después de visitar el sueño: no filtra su skin al combate.
        app:startPractice("free"); settle()
        local drawn={}
        local normalPortrait=app.resources.portrait
        app.resources.portrait=function(self,id,...)
            drawn[id]=(drawn[id] or 0)+1
            return normalPortrait(self,id,...)
        end
        app:draw()
        app.resources.portrait=normalPortrait
        check(drawn.rudeus and not drawn.rudeus_japones,"El combate físico dibuja Rudy normal incluso después del sueño")
        app:endPractice()
    end,debug.traceback)
    love.filesystem.getInfo=originalInfo
    Progression.scene=originalScene
    Save.readOptions=originalOptions
    if app and app.audio then app.audio:setContext("menu") end
    love.graphics.setCanvas(); love.graphics.pop()
    love.filesystem.setIdentity(identity)
    assert(ok,err)
    print("Contextual portraits: "..checked.." checks passed; "..captures.." real-renderer captures (dream, expressions, save/load, waking, combat, fallback).")
    return checked
end
return Suite
