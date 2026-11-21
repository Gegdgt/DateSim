-- Pruebas A-D mediante la App real: teclado, previsualización, cancelación,
-- reacción en varias líneas, guardado en disco y capturas de LÖVE.
local Suite={}
function Suite.run()
    local Fixtures=require("tests.dialogue_branching")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Cards=require("src.systems.cards")
    local Resolver=require("src.systems.dialogue_resolver")
    local Events=require("src.systems.events")
    local Progression=require("src.systems.progression")
    local Characters=require("src.data.characters")
    local Data=require("src.data.cards")
    local Chapters=require("src.data.chapters")
    local Font=require("src.ui.font")
    local checks,captures=0,0
    local function check(value,message) assert(value,message); checks=checks+1 end
    local function encode(value) return assert(Json.encode(value)) end
    local function clone(value) return assert(Json.decode(encode(value))) end
    local identity=love.filesystem.getIdentity()
    local originalOptions,originalFont=Save.readOptions,Font.draw
    local app
    love.filesystem.setIdentity("cartas_del_destino_dialogue_tests")
    Save.readOptions=function() return {muted=true,textAnimation=false,reducedMotion=false} end
    love.graphics.push("all")
    local ok,err=xpcall(function()
        app=require("src.app").new()
        app.mouse=function() return nil,nil end
        local rendered={}
        Font.draw=function(text,...)
            rendered[#rendered+1]=tostring(text)
            return originalFont(text,...)
        end
        local function draw()
            app.toastTime=0; rendered={}; app:draw()
            return table.concat(rendered,"\n")
        end
        local function capture(name)
            draw()
            local pixels=app.canvas:newImageData(); local bytes=pixels:encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/dialogue-"..name..".png","wb"))
            file:write(bytes:getString()); file:close(); bytes:release(); pixels:release()
            captures=captures+1
        end
        local function settle()
            if app.manager.transition>0 then app:update(app.manager.transition) end
            app:update(2); draw()
        end
        local function prepare(checkpoint,cardId,prior,seed)
            local session=prior and clone(prior) or Fixtures.fixture(checkpoint)
            session.checkpoint=checkpoint; session.day=Chapters.get(checkpoint).day
            session.encounter=nil; session.encounterReview=nil; session.tutorial=nil
            session.rewardQueue={}; session.events.tutorial_completed=true
            local deck={}
            for _,id in ipairs(session.deck) do if id~=cardId then deck[#deck+1]=id end end
            if cardId then
                if #deck>=10 then table.remove(deck,1) end
                deck[#deck+1]=cardId; session.unlocked[cardId]=true
            end
            session.deck=deck
            local definition=assert(Progression.encounter(session,checkpoint))
            session.encounter=Cards.new(session.deck,Resolver.context(session,definition),seed and Fixtures.rng(seed) or function(n) return n end)
            app.session=session; app:resume(); settle()
            check(app.manager.current.enc.narrativeVersion==1,"La pantalla usa el motor narrativo: "..checkpoint)
            if cardId then check(app.manager.current.enc.hand[1]==cardId,"Fixture independiente presenta la carta solicitada") end
            return app.manager.current
        end
        local function state(screen)
            return encode({hand=screen.enc.hand,drawPile=screen.enc.drawPile,discard=screen.enc.discard,
                energy=screen.enc.energy,turn=screen.enc.turn,relationships=app.session.relationships,events=app.session.events})
        end
        local function playCase(checkpoint,cardId,name,expected,prior)
            local screen=prepare(checkpoint,cardId,prior)
            local character=screen.definition.character
            local previous=clone(app.session.relationships[character])
            local unchanged=state(screen)
            app:keypressed("1"); app:update(.2)
            local preview=Cards.preview(screen.enc,1)
            check(screen.confirmReady and state(screen)==unchanged,"Seleccionar consulta sin gastar ni aplicar: "..name)
            local text=draw()
            check(text:find("Rudy dirá:",1,true) and text:find(preview.phrase,1,true),"Vista previa muestra la frase contextual completa: "..name)
            check(Font.height(preview.phrase,173)<=88,"La frase cabe en el panel de confirmación: "..name)
            capture(name.."-preview")
            app:keypressed("escape")
            check(app.manager.current==screen and not screen.confirmReady and state(screen)==unchanged,"Cancelar devuelve a la mano sin mutaciones: "..name)
            app:keypressed("1"); app:keypressed("return")
            check(#screen.enc.log==1 and screen:busy(),"Confirmar inicia una sola animación: "..name)
            local result=screen.enc.log[1]
            check(result.phrase==preview.phrase,"La carta dice exactamente lo previsualizado: "..name)
            app:keypressed("return"); app:keypressed("1")
            check(#screen.enc.log==1,"Pulsaciones durante la animación no vuelven a jugar la carta")
            app:update(.45); capture(name.."-card")
            app:update(2)
            check(screen:responseLine().speaker=="rudeus" and screen:responseLine().text==preview.phrase,"Primero aparece la frase de Rudy")
            check(not result.applied and app.session.relationships[character].love==previous.love
                and app.session.relationships[character].trust==previous.trust,"La reacción todavía no concede puntos")
            check(draw():find(preview.phrase,1,true),"El renderer muestra la frase pronunciada")
            check(app:save(),"Guardar entre la frase de Rudy y la reacción")
            app:continueGame(); settle(); screen=app.manager.current; result=screen.enc.log[1]
            check(screen.enc.reactionIndex==1 and not result.applied,"Continuar conserva la reacción pendiente")
            app:keypressed("return"); app:update(.2)
            check(screen:responseLine().apply and result.applied,"Leer la reacción aplica el resultado")
            local wantedLove=expected and expected.love or preview.projectedLove
            local wantedTrust=expected and expected.trust or preview.projectedTrust
            check(app.session.relationships[character].love==previous.love+wantedLove
                and app.session.relationships[character].trust==previous.trust+wantedTrust,"Efectos reales en "..name)
            check(result.actualLove==wantedLove and result.actualTrust==wantedTrust,"La reacción informa el delta realmente aplicado")
            if expected then
                check(result.expression==expected.expression and result.nextNode==expected.next,"Expresión y rama esperadas: "..name)
                if expected.flag then check(app.session.events[expected.flag],"Consecuencia persistente de "..name) end
            end
            local displayed=draw()
            local label=Characters.byId[character].shortName.." · AMOR "..Cards.signed(wantedLove).." / CONFIANZA "..Cards.signed(wantedTrust)
            check(displayed:find(label,1,true) and displayed:find(result.reaction,1,true),"Reacción y cambios exactos visibles en pantalla")
            local originalPortrait=app.resources.portrait
            local seenExpression
            app.resources.portrait=function(self,id,expression,...)
                if id==character then seenExpression=expression end
                return originalPortrait(self,id,expression,...)
            end
            draw(); app.resources.portrait=originalPortrait
            check(seenExpression==result.expression,"El retrato renderizado cambia a la emoción de la reacción")
            capture(name.."-reaction")
            local applied=encode(app.session.relationships)
            check(app:save(),"Guardar tras aplicar la reacción")
            app:continueGame(); settle(); screen=app.manager.current; result=screen.enc.log[1]
            check(result.applied and screen.enc.reactionIndex==2 and encode(app.session.relationships)==applied,"Continuar no duplica el efecto ya leído")
            check(math.abs(screen.relationVisual.love-app.session.relationships[character].love)<.01
                and math.abs(screen.relationVisual.trust-app.session.relationships[character].trust)<.01,"Barras animadas terminan en los valores reales")
            app:keypressed("return"); app:update(.3)
            check(screen:responseLine().text==require("src.data.dialogue").nodes[result.nextNode].text,"La elección abre su continuación escrita")
            capture(name.."-branch")
            local steps=0
            while screen.phase=="result" do
                steps=steps+1; check(steps<12,"La secuencia extendida termina")
                app:keypressed("return"); app:update(.3)
            end
            check(encode(app.session.relationships)==applied,"Leer todas las líneas no vuelve a sumar puntos")
            check(screen.phase=="hand" and #screen.enc.log==1,"La siguiente decisión espera una nueva elección humana")
            return clone(app.session),result
        end

        local eris={
            {card="light_joke",name="eris-joke",love=-5,trust=-2,expression="angry",next="eris_training_argument",flag="eris_disliked_training_joke"},
            {card="encourage",name="eris-support",love=1,trust=1,expression="happy",next="eris_training_together",flag="eris_training_supported"},
            {card="subtle_flirt",name="eris-flirt",love=1,trust=0,expression="happy",next="eris_training_challenge",flag="eris_romantic_training"},
        }
        local distinct={}
        for _,case in ipairs(eris) do
            local _,result=playCase("encounter_eris",case.card,case.name,case)
            distinct[result.nextNode]=true
        end
        local count=0; for _ in pairs(distinct) do count=count+1 end
        check(count==3,"Prueba A: tres fixtures independientes, tres consecuencias y tres ramas")
        for _,case in ipairs({
            {card="listen",name="roxy-listen",love=0,trust=1,expression="happy",next="roxy_formula_check"},
            {card="light_joke",name="roxy-joke",love=-2,trust=-1,expression="worried",next="roxy_formula_boundaries"},
            {card="be_honest",name="roxy-honest",love=1,trust=1,expression="happy",next="roxy_formula_equals"},
        }) do playCase("encounter_roxy",case.card,case.name,case) end

        local promised=playCase("encounter_sylphiette","encourage","sylphiette-promise")
        check(promised.events.sylphiette_promised_family_time and promised.relationships.sylphiette.promises.family_time=="pending",
            "Prueba C: la promesa de tiempo familiar queda pendiente")
        local futureResponses={}
        for _,outcome in ipairs({"kept","broken"}) do
            local prior=clone(promised)
            Events.apply(prior,"family_time_outcome",{character="sylphiette",decision="family_time_outcome",value=outcome,promise={id="family_time",status=outcome}})
            prior.events["sylphiette_family_time_"..outcome]=true
            local _,result=playCase("day5_mission_sylphiette","listen","sylphiette-"..outcome,nil,prior)
            futureResponses[outcome]=result.responseId
        end
        check(futureResponses.kept~=futureResponses.broken,"Prueba C: el cumplimiento cambia la conversación futura visible")

        local seedHands={}
        for _,seed in ipairs({13,29,51,83}) do
            local screen=prepare("encounter_eris",nil,nil,seed)
            seedHands[table.concat(screen.enc.hand,",")]=true
            capture("seed-"..seed)
            local order=encode({screen.enc.hand,screen.enc.drawPile,screen.enc.discard})
            app:save(); app:continueGame(); settle()
            local restored=app.manager.current.enc
            check(order==encode({restored.hand,restored.drawPile,restored.discard}),"Prueba D: continuar conserva exactamente la mano y el orden")
        end
        local varied=0; for _ in pairs(seedHands) do varied=varied+1 end
        check(varied>1,"Prueba D: distintos inicios muestran manos diferentes")

        local empty=Fixtures.fixture("encounter_eris",{"shared_magic","combined_spell","sword_magic","choose_together","angry_reply"})
        local screen=prepare("encounter_eris",nil,empty,7)
        check(#screen.enc.hand==0 and draw():find(screen.enc.notice,1,true),"La UI explica el mazo sin cartas compatibles")
        capture("no-compatible-cards")
        local steps=0
        while app.session.checkpoint=="encounter_eris" do
            steps=steps+1; check(steps<30,"La respuesta básica permite terminar sin bloqueo")
            screen=app.manager.current
            if screen.phase=="hand" then app:keypressed("p") else app:keypressed("return") end
            app:update(2)
            if app.manager.transition>0 then app:update(app.manager.transition) end
        end
        check(app.session.checkpoint=="result_eris","El encuentro sin cartas sigue una salida narrativa válida")
    end,debug.traceback)
    Save.readOptions=originalOptions; Font.draw=originalFont
    love.graphics.setCanvas(); love.graphics.pop()
    love.filesystem.setIdentity(identity)
    assert(ok,err)
    Suite.report={checks=checks,captures=captures}
    print("Dialogue UI: "..checks.." checks; "..captures.." real-renderer captures; Eris A, Roxy B, Sylphiette C, seeded hands D, cancellation and disk save/restore.")
    return checks
end
return Suite
