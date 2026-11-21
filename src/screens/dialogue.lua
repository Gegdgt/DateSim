local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Progression=require("src.systems.progression")
local Dialogue=require("src.systems.dialogue")
local Characters=require("src.data.characters")
local Controls=require("src.config.controls")
local Chapters=require("src.data.chapters")
local Typewriter=require("src.systems.typewriter")
local Animation=require("src.systems.animation")
local Portraits=require("src.systems.portraits")
local RelationshipBars=require("src.ui.relationship_bars")
local DialogueScreen={}

function DialogueScreen.new(app)
    local s=Screen.new(app)
    s.scene=Progression.scene(app.session,app.session.checkpoint)
    assert(s.scene,"Escena desconocida: "..tostring(app.session.checkpoint))
    s.dialogue=Dialogue.new(s.scene,app.session.dialogueIndex)
    s.clock=0
    s.quads={}
    s.actors={}
    s.relationshipBars={}
    for _,id in ipairs({"eris","roxy","sylphiette","nanahoshi"}) do
        s.relationshipBars[id]=RelationshipBars.new(app.session,id,{reducedMotion=app.options and app.options.reducedMotion})
    end
    function s:relationshipFeedback(key,explanation)
        local changed,negative=false,false
        for _,bars in pairs(self.relationshipBars) do
            if bars:apply(key,app.session,nil,explanation) then
                changed=true; negative=negative or bars:feedback().negative
            end
        end
        if changed and app.audio then app.audio:effect(negative and "negative" or "positive") end
        return changed
    end
    local function animateLine(first,previous)
        local line=s.dialogue:current()
        s.lineTime=0
        if line.stateEffect then
            local applied=require("src.systems.events").apply(app.session,line.stateEffect.id,line.stateEffect)
            if applied then
                app:save()
                s:relationshipFeedback(line.stateEffect.id,line.text)
            end
        end
        if line.effect=="water_fail" or line.effect=="earth_fail" then app.audio:effect("magic_fail")
        elseif line.effect=="flashback" then app.audio:effect("revelation")
        elseif line.delivery=="note" then app.audio:effect("paper")
        elseif line.delivery=="enchanted" then app.audio:effect("card_play") end
        if line.effect=="cure" then app.audio:effect("heal") end
        local old={}
        for _,entry in ipairs(s.presentation and s.presentation.cast or {}) do old[entry.character]=entry end
        s.presentation=Portraits.resolve(s.scene,s.dialogue.index)
        -- En un diálogo de una sola interlocutora, sus barras siguen visibles
        -- mientras Rudy responde. La etiqueta inferior identifica su voz.
        if not s.scene.cast and line.speaker=="rudeus" then
            for index=s.dialogue.index-1,1,-1 do
                local speaker=s.scene.lines[index].speaker
                if s.relationshipBars[speaker] then
                    local previousCast=Portraits.resolve(s.scene,index).cast
                    for _,entry in ipairs(previousCast) do
                        if entry.character==speaker then entry.animation=nil; s.presentation.cast={entry}; break end
                    end
                    break
                elseif speaker~="rudeus" and speaker~="narrator" then break end
            end
        end
        s.staging=0
        local actors={}
        for _,entry in ipairs(s.presentation.cast) do
            local prior=old[entry.character]
            local entering=entry.visible and (not prior or not prior.visible)
            local leaving=not entry.visible and prior and prior.visible
            local declared=entry.animation or (first and s.scene.animation)
            local kind=type(declared)=="table" and declared.type or declared
            if entering then
                if s.scene.cast or not kind then kind=entry.position=="right" and "enter_right" or "enter_left" end
            elseif leaving then kind=entry.position=="right" and "exit_right" or "exit_left"
            elseif not kind then
                if prior and entry.expression~=prior.expression then
                    kind=({happy="happy_bounce",angry="angry_shake",worried="sad_lower"})[entry.expression] or "expression_change"
                elseif entry.character==line.speaker then kind="speaking" end
            end
            if kind or not s.actors[entry.character] then
                local actor=Animation.actor(kind or "expression_change",{reducedMotion=app.options and app.options.reducedMotion})
                actor.delay=entering and s.dialogue.index==entry.enterAt and entry.entranceDelay or 0
                if app.options and app.options.reducedMotion then actor.delay=0 end
                s.actors[entry.character]=actor
                if entering and s.scene.cast and not actor.done then s.staging=math.max(s.staging,actor.delay+actor.duration) end
            end
            actors[entry.character]=s.actors[entry.character]
        end
        s.actors=actors
        -- Alias conservado para las pantallas/pruebas que inspeccionan al hablante.
        s.actor=s.actors[line.speaker] or s.actors[s.presentation.cast[1].character]
        s.writer=Typewriter.new(line.text,app.options)
        s.elapsed,s.visible=s.writer.elapsed,s.writer.visible
    end
    animateLine(true)
    function s:update(dt)
        self.clock=self.clock+dt
        self.lineTime=self.lineTime+dt
        for _,bars in pairs(self.relationshipBars) do bars:sync(app.session); bars:update(dt) end
        for _,entry in ipairs(self.presentation.cast) do
            local actor=self.actors[entry.character]
            local delay=actor.delay or 0
            actor.delay=math.max(0,delay-dt)
            if actor.delay==0 then actor:update(math.max(0,dt-delay)) end
        end
        if self.leaving then
            local done=true
            for _,actor in pairs(self.actors) do if not actor.done then done=false end end
            if done and self.onDeparture then
                local callback=self.onDeparture; self.onDeparture=nil; callback()
            end
            return
        end
        if self.pendingDeparture then
            self.pendingDeparture=self.pendingDeparture-dt
            if self.pendingDeparture<=0 then self.pendingDeparture=nil; self:depart(function() app:next() end) end
            return
        end
        local staging=self.staging
        self.staging=math.max(0,staging-dt)
        dt=math.max(0,dt-staging)
        self.writer.elapsed=self.elapsed
        local before=self.writer.visible
        self.writer:update(dt)
        if self.dialogue:current().delivery~="silence" and math.floor(self.writer.visible/3)>math.floor(before/3) and app.audio then app.audio:effect("text_blip") end
        self.elapsed,self.visible=self.writer.elapsed,self.writer.visible
    end
    function s:fullText() return self.dialogue:current().text end
    function s:ready() return self.visible>=self.writer.length end
    function s:depart(callback)
        if self.leaving or self.pendingDeparture then return end
        self.leaving=true
        self.onDeparture=callback
        local done=true
        for _,entry in ipairs(self.presentation.cast) do
            local actor=Animation.actor(entry.visible and (self.scene.exitAnimation or (entry.position=="right" and "exit_right" or "exit_left")) or "expression_change",
                {duration=.16,reducedMotion=not entry.visible or (app.options and app.options.reducedMotion)})
            self.actors[entry.character]=actor
            if not actor.done then done=false end
        end
        self.actor=self.actors[self.dialogue:current().speaker] or self.actors[self.presentation.cast[1].character]
        if done then local action=self.onDeparture; self.onDeparture=nil; action() end
    end
    function s:advance()
        if self.leaving or self.pendingDeparture then return end
        if self.staging>0 then
            for _,actor in pairs(self.actors) do actor.delay=0; actor:finish() end
            self.staging=0
        end
        if not self:ready() then
            self.writer:showAll()
            self.elapsed,self.visible=self.writer.elapsed,self.writer.visible
            return
        end
        if self.dialogue:isLast() then
            if self.scene.choices and #self.scene.choices>0 then return end
            self:depart(function() app:next() end)
        else
            local previous=self.dialogue:current()
            self.dialogue:advance()
            app.session.dialogueIndex=self.dialogue.index
            animateLine(false,previous)
            app:save()
        end
    end
    function s:drawPortrait(id,expression,actor,x,bars)
        local frame=Characters.expressions[expression or "neutral"] or 0
        self.quads[frame]=self.quads[frame] or love.graphics.newQuad(frame*64,0,64,64,256,64)
        local pose=(actor or self.actor).value
        love.graphics.setColor(1,1,1,pose.alpha)
        local px,py=math.floor((x or 39)+pose.x),math.floor((bars and 94 or 83)+pose.y)
        love.graphics.draw(app.resources:getPortrait(id),self.quads[frame],px,py,0,2,2)
        if bars then bars:draw({x=px,y=py,w=128,h=128,alpha=pose.alpha}) end
    end
    function s:draw()
        self:begin()
        local line=self.dialogue:current()
        app.resources:background(self.presentation.background)
        self:header(self.scene.title)
        local char=Characters.byId[line.speaker]
        local hasBars=false
        for _,entry in ipairs(self.presentation.cast) do
            local actor=self.actors[entry.character]
            if entry.visible or (not actor.done and (actor.kind=="exit_left" or actor.kind=="exit_right")) then
                local x=entry.position=="right" and 473 or 39
                local bars=self.relationshipBars[entry.character]
                hasBars=hasBars or bars~=nil
                self:drawPortrait(entry.portrait,entry.expression,actor,x,bars)
                if not bars and self.scene.cast and actor.value.alpha>0 then
                    local identity=Characters.byId[entry.character]
                    self:text(identity and identity.shortName or entry.character,x,70,128,
                        entry.character==line.speaker and P.gold or P.muted,1,"center")
                end
            end
        end
        if line.effect=="water_fail" or line.effect=="earth_fail" then
            local t=math.min(1,self.lineTime/1.2)
            if t<1 then
                local water=line.effect=="water_fail"
                love.graphics.setColor(water and .4 or .7,water and .75 or .55,water and 1 or .3,1-t)
                for i=1,8 do
                    local angle=i*math.pi/4; local radius=app.options.reducedMotion and 10 or 8+25*t
                    love.graphics.rectangle("fill",math.floor(146+math.cos(angle)*radius),math.floor(143+math.sin(angle)*radius),3,3)
                end
            end
        elseif line.effect=="cure" and self.lineTime<1.5 then
            love.graphics.setColor(.5,1,.8,1-self.lineTime/1.5)
            for i=1,12 do
                local angle=i*math.pi/6; local radius=app.options.reducedMotion and 50 or 30+self.lineTime*35
                love.graphics.rectangle("fill",math.floor(103+math.cos(angle)*radius),math.floor(147+math.sin(angle)*radius),4,4)
            end
        elseif line.effect=="flashback" and self.lineTime<.35 and not app.options.reducedMotion then
            love.graphics.setColor(1,1,1,(1-self.lineTime/.35)*.35); love.graphics.rectangle("fill",0,36,640,180)
        end
        local infoWidth=self.scene.cast and 278 or 435
        W.panel(172,67,infoWidth,49)
        local chapter=Chapters.chapterFor(app.session.checkpoint)
        self:text(chapter.title,185,79,infoWidth-27,P.gold)
        local curse=app.session.curse or {}
        local status=curse.discoveredVoice and (curse.voiceSealed and "VOZ: SELLADA" or "VOZ: RECUPERADA") or "Las decisiones de Rudy son tuyas."
        if curse.discoveredMana then status=status..(curse.manaBlocked and " · MANÁ: BLOQUEADO" or " · MANÁ: LIBRE") end
        self:text(status,185,97,infoWidth-27,P.muted)
        local deliveryLabels={thought="Pensamientos de Rudy",note="Nota de Rudy",enchanted="Rudy · carta parlante",dream="Rudy · voz en el sueño",silence="Rudy · silencio",memory="Recuerdo de Hitogami"}
        local speakerLabel=deliveryLabels[line.delivery] or (char and char.name or "Narración")
        if line.delivery=="enchanted" then
            app.resources:icon("be_honest",181,133,1)
            self:text("Voz reproducida por el encantamiento",214,141,382,P.teal)
        end
        local choices=self.scene.choices
        if self.dialogue:isLast() and self:ready() and choices and not self.leaving and not self.pendingDeparture then
            for i,choice in ipairs(choices) do
                self:button(choice.label,172,126+(i-1)*33,435,29,function()
                    local before={}
                    for id,r in pairs(app.session.relationships) do before[id]={love=r.love,trust=r.trust} end
                    local ok,err=Progression.choose(app.session,app.session.checkpoint,choice.id)
                    if ok then
                        app:save()
                        local visibleChange=false
                        if not (choice.effects and (choice.effects.secret or choice.effects.hidden)) then
                            local changes={}
                            for _,id in ipairs(Characters.romanceIds) do
                                local r=app.session.relationships[id]; local old=before[id]
                                if old and (r.love~=old.love or r.trust~=old.trust) then
                                    local sign=require("src.systems.cards").signed
                                    changes[#changes+1]=Characters.byId[id].shortName..": "..sign(r.love-old.love).." amor, "..sign(r.trust-old.trust).." confianza"
                                end
                            end
                            if #changes>0 then app:notify(table.concat(changes," · ")) end
                            visibleChange=self:relationshipFeedback("choice_"..app.session.checkpoint,choice.label)
                        end
                        if visibleChange then self.pendingDeparture=.7
                        else self:depart(function() app:next() end) end
                    else app:notify(err) end
                end)
            end
        end
        W.panel(18,227,604,116)
        local plateY=hasBars and 227 or 214
        W.panel(30,plateY,math.max(112,math.min(296,#speakerLabel*6+28)),hasBars and 21 or 24)
        self:text(speakerLabel,42,plateY+8,280,P.gold)
        self:text(Typewriter.slice(self:fullText(),self.staging>0 and 0 or self.visible),34,250,572,P.ink)
        local hint=self:ready() and ((choices and self.dialogue:isLast()) and "Elige una respuesta arriba" or "CLIC / ENTER / ESPACIO  >") or "CLIC para mostrar el texto"
        self:text((self.leaving or self.pendingDeparture) and "Continuando..." or hint,34,325,572,P.muted,1,"right")
        if self:ready() and not self.leaving and not (choices and self.dialogue:isLast()) then
            local shift=(app.options and app.options.reducedMotion) and 0 or math.floor(self.clock*2)%2
            love.graphics.setColor(P.gold)
            love.graphics.rectangle("fill",39,319+shift,2,5)
            love.graphics.rectangle("fill",41,320+shift,2,3)
            love.graphics.rectangle("fill",43,321+shift,2,1)
        end
    end
    function s:mousepressed(x,y,b)
        if self.leaving or self.pendingDeparture then return end
        if self:click(x,y,b) then return end
        if b==1 then self:advance() end
    end
    function s:keypressed(key)
        if self.leaving or self.pendingDeparture then return end
        if self:navigate(key) then return end
        if Controls.matches(Controls.advance,key) then self:advance()
        elseif Controls.matches(Controls.back,key) then app:overlay("pause")
        elseif Controls.matches(Controls.journal,key) then app:overlay("journal")
        elseif Controls.matches(Controls.deck,key) then app:overlay("deck") end
    end
    return s
end
return DialogueScreen
