local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Data=require("src.data.cards")
local Characters=require("src.data.characters")
local Cards=require("src.systems.cards")
local Progression=require("src.systems.progression")
local Controls=require("src.config.controls")
local CardView=require("src.ui.card")
local Animation=require("src.systems.animation")
local Tutorial=require("src.systems.tutorial")
local Save=require("src.systems.save")
local Relationships=require("src.systems.relationships")
local Presentation=require("src.data.presentation")
local Resolver=require("src.systems.dialogue_resolver")
local Memory=require("src.systems.dialogue_memory")
local RelationshipBars=require("src.ui.relationship_bars")
local Encounter={}
local contexts={conversation="Conversación",investigation="Investigación",magic="Magia"}
local colors={empathy=P.teal,humor=P.gold,sincerity={.35,.65,1,1},initiative={.7,.45,.9,1}}
local function lerp(a,b,t) return math.floor(a+(b-a)*math.max(0,math.min(1,t))) end

function Encounter.new(app)
    local s=Screen.new(app)
    s.definition=Progression.encounter(app.session,app.session.checkpoint)
    local context=Resolver.context(app.session,s.definition)
    if s.definition.tutorial and (not app.session.encounter or (app.session.encounter.context or {}).socialTutorial) then
        s.definition.kind="conversation"; s.definition.character="nanahoshi"
        s.definition.title="Nanahoshi / práctica social"
        s.definition.intro="Nanahoshi: necesito comprobar el encantamiento. ¿Qué propones para que esta prueba sea útil?"
        s.definition.targetScore=4
        context=Resolver.context(app.session,s.definition,"nanahoshi_test"); context.socialTutorial=true
    end
    local restored=Cards.restore(app.session.encounter,app.session.deck,context)
    -- Orden reproducible para la práctica; el mazo y las reglas no cambian.
    local teachingDeck=app.session.deck
    if context.socialTutorial then
        teachingDeck={}; for i,id in ipairs(app.session.deck) do teachingDeck[i]=id end
        -- Escuchar y Hablar con honestidad producen deltas sociales reales.
        for _,id in ipairs({"be_honest","listen"}) do
            for i,value in ipairs(teachingDeck) do if value==id then table.remove(teachingDeck,i); teachingDeck[#teachingDeck+1]=id; break end end
        end
    end
    app.session.encounter=restored or Cards.new(teachingDeck,context,s.definition.tutorial and function(n) return n end or nil)
    s.enc=app.session.encounter
    local conversation=Resolver.node(context)
    if conversation then s.definition.intro=conversation.text end
    if s.definition.tutorial and not app.session.events.tutorial_completed then
        app.session.tutorial=Tutorial.restore(app.session.tutorial,s.enc)
        s.tutorial=app.session.tutorial
    end
    s.phase=(app.session.encounterReview or s.enc.finished) and "result" or "hand"
    if s.tutorial and ({result=true,second_result=true,summary=true})[s.tutorial.stage] then s.phase="result" end
    if s.tutorial and s.enc.finished then s.historyOpen=true end
    s.age,s.selected=0,1
    s.lifts={0,0,0}
    s.feedback=#s.enc.log>0 and s.enc.log[#s.enc.log].text or "Selecciona una carta para consultar su efecto."
    s.relationshipBars=RelationshipBars.new(app.session,s.definition.character,{reducedMotion=app.options.reducedMotion,audio=app.audio})
    s.relationVisual=s.relationshipBars and s.relationshipBars.value or {trust=0,love=0}
    s.portraitExpression=conversation and Characters.expressions[conversation.emotion] and conversation.emotion or "neutral"
    local restoredResult=s.enc.log[#s.enc.log]
    if s.phase=="result" and restoredResult then
        for i=1,s.enc.reactionIndex or 1 do
            local line=restoredResult.sequence and restoredResult.sequence[i]
            if line and line.speaker==s.definition.character then s.portraitExpression=line.expression or "neutral" end
        end
    end
    function s:relationshipTarget()
        return RelationshipBars.read(app.session,self.definition.character) or self.relationVisual
    end
    app:save()
    function s:busy() return self.motion and not self.motion.done end
    function s:update(dt)
        self.age=self.age+dt
        if self.motion then self.motion:update(dt) end
        if self.relationshipBars then
            self.relationshipBars:sync(app.session); self.relationshipBars:update(dt)
            self.relationVisual=self.relationshipBars.value
        end
        local anim=self.animation
        if anim and self.motion and self.motion.value.t>=1.08 and not anim.drawSound and anim.drawId and not self.tutorial and anim.cardId~="pass" then
            anim.drawSound=true
            if app.audio then app.audio:effect("card_draw") end
        end
        if self.actor then self.actor:update(dt) end
        for i=1,3 do
            local target=self.selected==i and (self.confirmReady and -8 or -4) or 0
            if app.options.reducedMotion then target=0 end
            self.liftTweens=self.liftTweens or {}
            local tween=self.liftTweens[i]
            if not tween or tween.to.y~=target then
                tween=Animation.tween({y=self.lifts[i]},{y=target},self.confirmReady and .15 or .12,{reducedMotion=app.options.reducedMotion})
                self.liftTweens[i]=tween
            end
            tween:update(dt); self.lifts[i]=tween.value.y
        end
    end
    function s:select(index)
        if self:busy() or self.phase~="hand" or not self.enc.hand[index] then return false end
        self.selected=index; self.confirmReady=true; self.keyboardFocus=nil; self.armedTurn=self.enc.turn
        if self.tutorial then Tutorial.select(self.tutorial) end
        if app.audio then app.audio:effect("card_select") end
        app:save(); return true
    end
    function s:cancel()
        if self:busy() or self.phase~="hand" or not self.confirmReady then return false end
        self.confirmReady=false; self.armedTurn=nil; self.keyboardFocus=nil
        if self.tutorial and self.tutorial.stage=="ready" then self.tutorial.stage="select" end
        return true
    end
    function s:responseLine()
        local result=self.enc.log[#self.enc.log]
        return result and result.sequence and result.sequence[self.enc.reactionIndex or 1]
    end
    function s:showResponse()
        local result=self.enc.log[#self.enc.log]
        local line=self:responseLine()
        if line then
            -- La interlocutora permanece visible mientras Rudy lee la carta.
            if line.speaker==self.definition.character then
                self.portraitExpression=line.expression or "neutral"
                self.actor=Animation.actor(line.animation or (line.expression=="happy" and "happy_bounce" or line.expression=="angry" and "angry_shake" or "speaking"),{reducedMotion=app.options.reducedMotion})
            end
            if line.apply then
                local applied=Memory.commit(app.session,result,self.enc.context.sceneId,result.actionTurn)
                app:save()
                if applied and self.relationshipBars then
                    self.relationshipBars:apply(Memory.key(self.enc.context.sceneId,result.actionTurn),app.session,
                        {love=result.actualLove,trust=result.actualTrust,interest=result.actualInterest},result.reaction)
                end
            end
        end
    end
    function s:act(index)
        if self:busy() or self.age<.18 or self.phase~="hand" then return false end
        if index and (not self.confirmReady or self.selected~=index) then self:select(index); return false end
        if not Tutorial.canAct(self.tutorial,index) then app:notify("Completa el paso indicado por Nanahoshi."); return false end
        local result,err
        local expected=self.armedTurn or self.enc.turn
        if index then result,err=Cards.play(self.enc,index,expected) else result,err=Cards.pass(self.enc,expected) end
        if not result then
            self.feedback=err; self.actor=Animation.actor("shake",{reducedMotion=app.options.reducedMotion})
            if app.audio then app.audio:effect("negative") end
            app:notify(err); return false
        end
        if not self.enc.narrativeVersion then
            local key="social_"..app.session.checkpoint.."_"..expected
            require("src.systems.events").apply(app.session,key,{decision=key,value=result.cardId,context="social_card",
                text=(result.phrase or "Rudy toma un respiro.").." ["..result.cardId.."] "..Cards.describe(result)})
        end
        self.feedback=result.text; self.phase="result"; app.session.encounterReview=true
        self.keyboardFocus=nil
        self.confirmReady=false; self.armedTurn=nil
        if self.tutorial then Tutorial.action(self.tutorial,self.enc) end
        if self.tutorial and self.enc.finished then self.historyOpen=true end
        self.animation={cardId=result.cardId,fromX=143+((index or 1)-1)*94,fromY=187,result=result,drawId=result.drawnCard}
        self.drawOnly=false
        local duration=index and (result.drawnCard and 1.38 or 1.08) or .5
        self.motion=Animation.tween({t=0},{t=duration},duration,{easing="linear",reducedMotion=app.options.reducedMotion})
        if self.enc.narrativeVersion then self.motion.onComplete=function() self:showResponse() end end
        self.actor=Animation.actor("expression_change",{reducedMotion=app.options.reducedMotion})
        if app.audio then
            app.audio:effect(index and "card_play" or "confirm")
        end
        self.selected=math.min(self.selected,#self.enc.hand); self.age=0
        app:save() -- Guardar antes de animar: restaurar no vuelve a ejecutar la carta.
        return true
    end
    function s:acknowledge()
        if self:busy() then return false end
        local result=self.enc.log[#self.enc.log]
        if self.enc.narrativeVersion and result then
            local at=self.enc.reactionIndex or 1
            if at<#result.sequence then
                self.enc.reactionIndex=at+1; self:showResponse(); app:save(); return true
            end
            Memory.commit(app.session,result,self.enc.context.sceneId,result.actionTurn)
        end
        if self.tutorial then
            local before=self.tutorial.stage
            if not Tutorial.advance(self.tutorial) then return false end
            if before=="result" then
                self.drawOnly=true
                self.animation=self.animation or {cardId=self.enc.log[1].cardId}
                self.motion=Animation.tween({t=0},{t=.3},.3,{easing="linear",reducedMotion=app.options.reducedMotion})
                if app.audio then app.audio:effect("card_draw") end
            end
            self.phase=({result=true,second_result=true,summary=true})[self.tutorial.stage] and "result" or "hand"
        else
            if self.enc.finished then return self:finish() end
            self.phase="hand"
        end
        app.session.encounterReview=nil; self.confirmReady=false; self.armedTurn=nil
        self.keyboardFocus=nil
        app:save(); return true
    end
    function s:finish()
        if self:busy() or not self.enc.finished or self.finishing then return false end
        local last=self.enc.log[#self.enc.log]
        if self.enc.narrativeVersion and last and (self.enc.reactionIndex or 1)<#last.sequence then return self:acknowledge() end
        if self.enc.narrativeVersion then
            for _,entry in ipairs(self.enc.log) do Memory.commit(app.session,entry,self.enc.context.sceneId,entry.actionTurn) end
        end
        if self.tutorial then
            if not Tutorial.complete(app.session,app.options) then return false end
            if not app.practice and not Save.writeOptions(app.options) then app:notify("Práctica guardada en la partida; no se pudieron guardar las preferencias.") end
        end
        self.finishing=true
        if self.enc.context.socialTutorial then
            app.session.encounter,app.session.encounterReview,app.session.tutorial=nil,nil,nil
            app:save(); app:resume(); return true
        end
        local result={score=self.enc.score,trust=0,chemistry=0}
        if not self.enc.narrativeVersion then
            for _,entry in ipairs(self.enc.log) do result.trust=result.trust+entry.trust; result.chemistry=result.chemistry+entry.chemistry end
        end
        app:next(result); return true
    end
    function s:history() self.historyOpen=not self.historyOpen; self.keyboardFocus=nil end
    function s:outcomeResponse()
        local success=self.enc.score>=self.definition.targetScore
        if not self.enc.context.socialTutorial then
            local Chapters=require("src.data.chapters")
            local chapter=Chapters.chapterFor(app.session.checkpoint)
            for _,transition in ipairs(chapter.transitions[app.session.checkpoint] or {}) do
                local node=Chapters.get(transition.to)
                if node and node.kind=="scene" and node.definition.resultKey==app.session.checkpoint then
                    local shadow={}; for k,v in pairs(app.session) do shadow[k]=v end
                    shadow.decisions={}; for k,v in pairs(app.session.decisions) do shadow.decisions[k]=v end
                    shadow.decisions["outcome_"..app.session.checkpoint]=success and "success" or "partial"
                    local scene=Progression.scene(shadow,transition.to)
                    if scene and scene.lines[1] then return scene.lines[1].text end
                end
            end
        end
        return Presentation.reaction(self.definition.character,{score=success and 1 or 0,trust=0,chemistry=0})
    end
    function s:pendingRelationship()
        if self.enc.narrativeVersion then return "Los cambios mostrados ya se aplicaron. Continuar no los repite." end
        local total={trust=0,chemistry=0}
        for _,entry in ipairs(self.enc.log) do total.trust=total.trust+entry.trust; total.chemistry=total.chemistry+entry.chemistry end
        local delta=Relationships.preview(app.session.relationships,self.definition.character,total)
        return (self.enc.context.socialTutorial and "Prueba sin romance: " or "Al cerrar: ")..Cards.signed(delta.trust).." confianza / "..Cards.signed(delta.chemistry).." amor (límite 100)."
    end
    function s:drawHistory()
        W.panel(135,138,487,185)
        self:text(self.enc.finished and (self.enc.score>=self.definition.targetScore and "ENCUENTRO EXITOSO" or "ENCUENTRO DESFAVORABLE")
            or "HISTORIAL / ACCIONES CONFIRMADAS",147,148,462,P.gold)
        if self.enc.finished then self:text("Avance "..self.enc.score.." / objetivo "..self.definition.targetScore.." · La historia continúa.",147,162,462,P.teal) end
        for i,entry in ipairs(self.enc.log) do
            local card=Data.byId[entry.cardId]
            self:text(i..". "..(card and card.name or "Tomar un respiro").." / coste "..(entry.cost or 0),147,180+(i-1)*34,462,P.teal)
            self:text(Cards.describe(entry),147,193+(i-1)*34,462,P.ink)
        end
        if #self.enc.log==0 then self:text("Aún no has usado ninguna acción.",147,177,462,P.muted) end
        self:text(self:pendingRelationship(),147,307,462,P.muted)
    end
    function s:drawResult()
        W.panel(135,138,487,185)
        local result=self.enc.log[#self.enc.log]
        if not result then return end
        local card=Data.byId[result.cardId]
        if self:busy() then
            self:text(card and ("RUDY USA: "..card.name) or "RUDY TOMA UN RESPIRO",147,146,462,P.gold)
            self:text("La acción está confirmada. Su resultado aparecerá al terminar.",147,306,462,P.muted)
            return
        end
        if self.enc.narrativeVersion then
            local line=self:responseLine()
            local identity=line and Characters.byId[line.speaker]
            local label=line and line.speaker=="rudeus" and (line.delivery=="thought" and "Pensamientos de Rudy" or line.delivery=="note" and "Nota de Rudy" or "Rudy · voz encantada") or (identity and identity.shortName or "Narración")
            self:text(label,147,148,462,P.gold)
            self:text(line and line.text or result.reaction,147,169,462,P.ink)
            if result.applied then
                local delta=result.affinityTarget and ("CONFIANZA "..Cards.signed(result.actualTrust or 0).." / INTERÉS "..Cards.signed(result.actualInterest or 0))
                    or ("AMOR "..Cards.signed(result.actualLove or 0).." / CONFIANZA "..Cards.signed(result.actualTrust or 0))
                self:text((Characters.byId[result.character].shortName).." · "..delta,147,263,462,P.teal)
                self:text("Cambio aplicado · "..(self.enc.reactionIndex or 1).." / "..#result.sequence,147,282,462,P.muted)
            else self:text("La reacción se mostrará al continuar.",147,263,462,P.muted) end
            self:text("Energía "..self.enc.energy.." / 4 · Avance "..self.enc.score.." / "..self.definition.targetScore,147,306,462,P.muted)
            return
        end
        if self.enc.finished then
            local success=self.enc.score>=self.definition.targetScore
            self:text(success and "ENCUENTRO EXITOSO" or "ENCUENTRO DESFAVORABLE",147,146,462,success and P.teal or P.gold)
            self:text("Avance conseguido: "..self.enc.score.." / objetivo: "..self.definition.targetScore,147,165,462)
            for i,entry in ipairs(self.enc.log) do
                local used=Data.byId[entry.cardId]
                self:text(i..". "..(used and used.name or "Tomar un respiro").." / "..Cards.describe(entry),147,186+(i-1)*22,462,P.muted)
            end
            self:text(self:pendingRelationship(),147,257,462,P.teal)
            self:text("Respuesta: consulta el panel superior.",147,276,462,P.muted)
            self:text(self.enc.context.socialTutorial and "Nanahoshi no es una relación romántica. Sigue el combate físico."
                or (success and "La respuesta favorable queda registrada. La historia continúa."
                    or "Se registra un resultado desfavorable. La historia continúa."),147,303,462,P.gold)
            return
        end
        self:text(card and card.name or "Tomar un respiro",147,146,462,P.gold)
        self:text("Energía consumida: "..(result.cost or 0).." / restante: "..self.enc.energy,147,162,462,P.ink)
        local rows={{"Base",result.base},{"Contexto",result.contextBonus},{"Afinidad",result.affinityBonus}}
        if result.targetAdjustment and (result.targetAdjustment.trust~=0 or result.targetAdjustment.chemistry~=0) then rows[#rows+1]={"Sin romance",result.targetAdjustment} end
        for i,row in ipairs(rows) do
            self:text(row[1],147,182+(i-1)*16,150,P.muted)
            self:text(Cards.describe(row[2] or {}),267,182+(i-1)*16,342,P.ink)
        end
        local negative=result.score<0 or result.trust<0 or result.chemistry<0
        self:text("Avance: "..(self.enc.score-result.score).." > "..self.enc.score.." / objetivo "..self.definition.targetScore,147,237,462,P.muted)
        self:text((negative and "DESCENSO: " or "TOTAL: ")..Cards.describe(result),147,252,462,negative and P.rose or P.teal)
        local shortfall=math.max(0,self.definition.targetScore-self.enc.score)
        local outcome=self.enc.finished and (shortfall>0 and ("PARCIAL: faltaron "..shortfall.." de avance. La historia continúa.") or "ÉXITO: objetivo alcanzado. Puedes continuar.")
            or (result.score>0 and "Esta acción acerca a Rudy a resolver el encuentro." or "Sin avance esta vez. Puedes continuar con otra acción.")
        self:text(outcome,147,276,462,shortfall>0 and self.enc.finished and P.rose or P.gold)
        self:text(self:pendingRelationship(),147,306,462,P.muted)
    end
    function s:drawDetails()
        W.panel(429,138,193,185)
        local card=Data.byId[self.enc.hand[self.selected]]
        if not card then return end
        self:text(card.name,439,146,173,P.gold)
        self:text(Data.categories[card.category].." / coste "..card.cost,439,173,173,P.teal)
        if self.enc.narrativeVersion then
            local preview=Cards.preview(self.enc,self.selected)
            local can,reason=Cards.canPlay(self.enc,self.selected)
            self:text("Intención: "..(Data.tones[card.tone] or card.name),439,190,173,P.muted)
            self:text("Rudy dirá:",439,211,173,P.gold)
            self:text(preview and preview.phrase or reason,439,225,173,P.ink)
            return
        end
        self:text(card.description,439,207,173,P.ink)
        local preview=Cards.preview(self.enc,self.selected)
        local can,reason=Cards.canPlay(self.enc,self.selected)
        if not can then self:text(reason,439,279,173,P.rose)
        else
            self:text("Base: "..Cards.signed(preview.base.score).." avance",439,266,173,P.muted)
            self:text("Conf. "..Cards.signed(preview.base.trust).." / Amor "..Cards.signed(preview.base.chemistry),439,279,173,P.muted)
            local b=preview.contextBonus
            local suited=b.score>0 or b.trust>0 or b.chemistry>0
            self:text(suited and "+ Favorecida por el contexto" or "Sin bono de contexto",439,297,173,suited and P.teal or P.muted)
        end
    end
    function s:drawAnimation()
        if not self:busy() or not self.animation or app.options.reducedMotion then return end
        local a,t=self.animation,self.motion.value.t
        if a.cardId=="pass" then return end
        local x,y,back
        if self.drawOnly then x,y,back=lerp(28,331,t/.3),lerp(283,187,t/.3),true
        elseif t<.4 then x,y=lerp(a.fromX,260,t/.4),lerp(a.fromY,154,t/.4)
        elseif t<.9 then
            x,y=260,154
            local c=colors[Data.byId[a.cardId].category]
            love.graphics.setColor(c[1],c[2],c[3],.22)
            for i=1,6 do local spread=math.floor((t-.4)*30); love.graphics.rectangle("fill",250+(i%3)*43-spread,148+math.floor(i/3)*116+spread,3,3) end
        elseif t<1.08 then x,y=lerp(260,28,(t-.9)/.18),lerp(154,283,(t-.9)/.18)
        else
            if self.tutorial or not a.drawId then return end
            x,y,back=lerp(28,331,(t-1.08)/.3),lerp(283,187,(t-1.08)/.3),true
        end
        if back then app.resources:cardBack(x,y,1) else CardView.draw(app.resources,Data.byId[a.cardId],x,y) end
    end
    function s:draw()
        self:begin()
        local enc,def=self.enc,self.definition
        app.resources:background(def.background)
        love.graphics.setColor(.025,.035,.07,.58); love.graphics.rectangle("fill",0,38,640,322)
        self:header("DÍA "..app.session.day.." / "..def.title)
        local instruction=self.tutorial and Tutorial.instruction(self.tutorial)
        if instruction and self:busy() and not self.drawOnly and #enc.log==1 then
            instruction={step=4,title="LA CARTA EN ACCIÓN",text="La carta elegida se eleva y responde al contexto. Espera a que termine el efecto para leer el resultado. No se puede jugar otra durante esta animación."}
        end
        local char=def.character and Characters.byId[def.character]
        local actor=self.actor and self.actor.value or {x=0,y=0}
        local latest=enc.log[#enc.log]
        local responseLine=self.phase=="result" and not self:busy() and self:responseLine()
        local portrait=self.tutorial and "nanahoshi" or def.character or "nanahoshi"
        local portraitX,portraitY=40+math.floor(actor.x),94+math.floor(actor.y)
        app.resources:portrait(portrait,self.portraitExpression,portraitX,portraitY,1)
        if self.relationshipBars then self.relationshipBars:draw({x=portraitX,y=portraitY,w=64,h=64,width=116,alpha=actor.alpha or 1}) end
        if responseLine and latest and latest.tone=="flirty" and responseLine.speaker==def.character then
            love.graphics.setColor(1,.5,.65,.65)
            love.graphics.rectangle("fill",portraitX+15,portraitY+34,4,2); love.graphics.rectangle("fill",portraitX+40,portraitY+34,4,2)
        end
        W.panel(135,48,487,80)
        self:text(instruction and ("GUÍA "..instruction.step.."/8 · "..instruction.title) or ((char and char.shortName or "Nanahoshi").." / "..contexts[def.kind]),147,56,462,P.gold)
        local briefing=instruction and instruction.text or (self.phase=="result" and
            Presentation.reaction(def.character,enc.log[#enc.log]) or def.intro)
        if self.enc.narrativeVersion then
            briefing=instruction and instruction.text or (self.enc.notice or def.intro)
            if not instruction and self.phase=="hand" and latest and latest.nextNode then
                briefing=require("src.data.dialogue").nodes[latest.nextNode].text
            end
        elseif self.phase=="result" and latest and latest.phrase and not self:busy() then
            local delivery=app.session.curse and app.session.curse.voiceSealed and "voz encantada" or "voz de Rudy"
            briefing="Rudy ("..delivery.."): «"..latest.phrase.."»\n"..(char and char.shortName or "Nanahoshi")..": "..latest.reaction
        elseif enc.finished and not instruction then briefing=self:outcomeResponse() end
        self:text(briefing,147,74,462,P.ink)
        if not instruction and self.phase~="result" then self:text("Contexto: "..contexts[def.kind].." · H: historial · M: colección",147,111,462,P.teal) end
        W.panel(18,166,110,157)
        self:text(enc.finished and "COMPLETADO" or "TURNO "..enc.turn.." / 3",28,177,90,P.gold)
        self:text("ENERGÍA SOCIAL\n"..enc.energy.."/4",28,198,90,P.ink)
        for i=1,4 do love.graphics.setColor(i<=enc.energy and P.teal or P.border); love.graphics.rectangle("fill",28+(i-1)*21,220,15,8) end
        self:text("AVANCE\n"..enc.score.." / "..def.targetScore,28,237,90,P.ink)
        W.bar(28,265,90,6,enc.score,def.targetScore,P.gold)
        self:text("Robo "..#enc.drawPile.." / D "..#enc.discard,28,281,90,P.muted)
        if def.character=="nanahoshi" then self:text("Vínculo de\ninvestigación",28,299,90,P.muted) end
        if self.historyOpen then self:drawHistory()
        elseif self.phase=="result" then self:drawResult()
        else
            self:text("MANO / CLIC O 1-3 PARA CONSULTAR",143,148,278,P.muted)
            local mx,my=app:mouse()
            local moved=mx~=self.lastMouseX or my~=self.lastMouseY
            self.lastMouseX,self.lastMouseY=mx,my
            for i,id in ipairs(enc.hand) do
                local x,y=143+(i-1)*94,187+math.floor(self.lifts[i])
                local can=Cards.canPlay(enc,i)
                if not self:busy() and mx and moved and mx>=x and mx<x+80 and my>=y and my<y+112 then
                    if self.selected~=i then self.confirmReady=false; self.armedTurn=nil end
                    self.selected=i; self.keyboardFocus=nil
                end
                CardView.draw(app.resources,Data.byId[id],x,y,{selected=self.selected==i,disabled=not can,
                    status="["..i.."] "..(can and (self.selected==i and "ELEGIDA" or "ELEGIR") or "NO DISP.")})
                self.buttons[#self.buttons+1]={x=x,y=y,w=80,h=112,cardIndex=i,action=function() self:select(i) end}
            end
            self:drawDetails()
        end
        self:button(self.historyOpen and "Cerrar historial [H]" or "Historial [H]",18,331,195,23,function() self:history() end)
        if self.tutorial and (app.options.tutorialCompleted or app.session.events.tutorial_completed) then
            self:button("Omitir guía",219,331,134,23,function() if Tutorial.skip(app.session,app.options) then self.tutorial=nil; app:save() end end,self:busy())
        elseif self.phase=="hand" and self.confirmReady then self:button("Cancelar [Esc]",219,331,134,23,function() self:cancel() end,self:busy())
        elseif not self.tutorial and self.phase=="hand" then self:button("Respiro [P]",219,331,134,23,function() self:act() end,self:busy()) end
        local label,action,disabled
        if self:busy() then label="Resolviendo..."; disabled=true
        elseif self.historyOpen and not self.enc.finished then label="Cerrar historial [H]"; action=function() self:history() end
        elseif self.enc.finished then label="Ver resultado >"; action=function() self:finish() end
        elseif instruction and instruction.button then label=instruction.button; action=function() self:acknowledge() end
        elseif self.phase=="result" then label="Continuar [Enter]"; action=function() self:acknowledge() end
        elseif self.tutorial and self.tutorial.stage=="free" then label="Tomar un respiro [P]"; action=function() self:act() end
        else label=self.confirmReady and "Jugar carta [Enter]" or "Consultar carta [Enter]"; action=function() self:act(self.selected) end end
        self:button(label,359,331,263,23,action or function() end,disabled)
        self:drawAnimation()
    end
    function s:keypressed(key)
        if key=="h" then self:history(); return end
        if Controls.matches(Controls.back,key) then if not self:cancel() then app:overlay("pause") end; return end
        if Controls.matches(Controls.journal,key) then app:overlay("journal"); return end
        if Controls.matches(Controls.deck,key) then app:overlay("deck"); return end
        if self:busy() then return end
        if self.historyOpen and Controls.matches(Controls.advance,key) then self.historyOpen=false; return end
        if self:navigate(key) then return end
        if Controls.matches(Controls.previousCard,key) or Controls.matches(Controls.nextCard,key) then
            if #self.enc.hand>0 then self:select((self.selected-1+(Controls.matches(Controls.nextCard,key) and 1 or -1))%#self.enc.hand+1) end
        elseif Controls.matches(Controls.advance,key) then
            local instruction=self.tutorial and Tutorial.instruction(self.tutorial)
            if self.enc.finished then self:finish()
            elseif instruction and instruction.button then self:acknowledge()
            elseif self.phase=="result" then self:acknowledge()
            elseif self.tutorial and self.tutorial.stage=="free" then self:act()
            else self:act(self.selected) end
        elseif Controls.matches(Controls.freeAction,key) then self:act()
        else for i,k in ipairs(Controls.cards) do if key==k then self:select(i); return end end end
    end
    return s
end
return Encounter
