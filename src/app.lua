local Manager = require("src.core.state_manager")
local Resources = require("src.systems.resources")
local Save = require("src.systems.save")
local Progression = require("src.systems.progression")
local Chapters = require("src.data.chapters")
local Controls = require("src.config.controls")
local Font = require("src.ui.font")
local Options = require("src.systems.options")
local Audio = require("src.systems.audio")
local App = {}
App.__index = App

function App.new()
    -- Los errores de autoría bloquean el inicio; un PNG ausente conserva el
    -- respaldo y diagnóstico del cargador, como en la Fase 1.
    require("src.systems.narrative_validator").assertValid(nil,{checkFiles=false})
    require("src.systems.dialogue_validator").assertValid()
    local self = setmetatable({},App)
    self.canvas=love.graphics.newCanvas(640,360)
    self.canvas:setFilter("nearest","nearest")
    self.resources=Resources.new():preload()
    self.options=Options.normalize(Save.readOptions())
    self.audio=Audio.new(self.options)
    self.manager=Manager.new(self)
    self.toast,self.toastTime="",0
    self:resize()
    self:applyOptions()
    self:menu()
    if #self.resources.warnings>0 then
        self:notify("Aviso: "..#self.resources.warnings.." recursos provisionales. Consulta la consola.")
    end
    return self
end

function App:resize()
    local w,h=love.graphics.getDimensions()
    local fit=math.min(w/640,h/360)
    self.scale=math.max(1,math.floor(fit))
    self.offsetX=math.floor((w-640*self.scale)/2)
    self.offsetY=math.floor((h-360*self.scale)/2)
end

function App:logical(x,y)
    x,y=(x-self.offsetX)/self.scale,(y-self.offsetY)/self.scale
    if x<0 or y<0 or x>=640 or y>=360 then return nil end
    return x,y
end
function App:mouse() return self:logical(love.mouse.getPosition()) end
function App:notify(message) self.toast,self.toastTime=message,3 end
function App:applyAudio()
    love.audio.setVolume(1)
    self.audio:setOptions(self.options)
end
function App:applyOptions()
    self.options=Options.normalize(self.options)
    self:applyAudio()
    if love.window.getFullscreen()~=self.options.fullscreen then
        love.window.setFullscreen(self.options.fullscreen,"desktop")
        self:resize()
    end
end

function App:switch(screen,transition)
    -- Entradas humanas se filtran en Manager. Una carga programática cierra
    -- primero la transición previa y nunca mantiene dos efectos simultáneos.
    if self.manager.transition>0 then self.manager:finishTransition() end
    self.manager:switch(screen,transition)
    if self.audio then self.audio:effect("scene_change") end
end

function App:save()
    if self.practice then return true end
    if not self.session then return true end
    self.session.options=self.options
    local ok,err=Save.write(self.session)
    if not ok then self:notify("No se pudo guardar: "..tostring(err)) end
    return ok
end

function App:newGame(importLegacy)
    self.session=importLegacy and Save.migrateLegacy(true) or Save.newSession()
    if not self.session then self:notify("No se pudo importar el guardado anterior."); return end
    self.session.options=self.options
    self:save()
    self:resume()
end

function App:continueGame()
    local session,err=Save.load()
    if not session then self:notify(err or "No hay una partida válida."); return end
    self.session=session
    -- Las preferencias elegidas en el menú son globales y más recientes que
    -- las incluidas en una partida antigua.
    self.session.options=self.options
    self:applyAudio()
    self:resume()
    if err then self:notify(err) end
end

function App:menu()
    if self.practice then return self:endPractice() end
    self.audio:setContext("menu")
    self:switch(require("src.screens.menu").new(self))
end

function App:resume(transition)
    if not self.session then self:menu(); return end
    Progression.skipUnavailable(self.session)
    require("src.systems.daily").deliverFavors(self.session)
    if #require("src.systems.family").ensure(self.session).queue>0 then
        local phase=self.session.family.queue[1].phase
        self:switch(require("src.screens.family_scene").new(self),{type=phase==4 and "horizontal" or "fade_in",duration=.3});return
    end
    if self.session.rewardQueue and #self.session.rewardQueue>0 and not (self.session.combat and self.session.combat.training) then
        self:switch(require("src.screens.reward").new(self),{type="fade_in",duration=.2})
        return
    end
    local activityBattle=require("src.systems.daily").battleDefinition(self.session)
    if activityBattle then self:switch(require("src.screens.combat").new(self,activityBattle));return end
    local checkpoint=self.session.checkpoint
    local node=Chapters.get(checkpoint)
    if not node then self:notify("Punto de historia desconocido."); return end
    local previous=self.presentedNode
    local resolved=node.kind=="scene" and Progression.scene(self.session,checkpoint)
        or (node.kind=="encounter" and Progression.encounter(self.session,checkpoint))
    if not transition then transition=(resolved or node.definition).entranceTransition end
    if not transition then
        if previous and previous.day~=node.day then transition={type="new_day",duration=.6,day=node.day,title=Chapters.chapterFor(checkpoint).title}
        elseif previous and previous.id~=node.id and node.kind=="encounter" then transition={type="magic",duration=.4}
        elseif previous and previous.kind=="encounter" and previous.id~=node.id then transition={type="return",duration=.35}
        elseif previous and previous.id~=node.id and previous.definition.background~=node.definition.background then transition={type="horizontal",duration=.35}
        else transition={type="fade_in",duration=.3} end
    end
    self.presentedNode=node
    local music=require("src.data.presentation").music(node,resolved)
    self.audio:setContext(music)
    if transition.type=="new_day" then self.audio:effect("new_day") end
    if node.definition.agenda then
        self:switch(require("src.screens.agenda").new(self),transition)
    elseif node and node.kind=="hub" then
        self:switch(require("src.screens.hub").new(self),transition)
    elseif node and node.kind=="summary" then
        local config=require("src.systems.daily").config(self.session)
        if checkpoint==config.summary then
            self:switch(require("src.screens.day_report").new(self,self.session.daily_history[tostring(self.session.day)]),transition)
        else self:switch(require("src.screens.summary").new(self),transition) end
    elseif node and node.kind=="encounter" then
        local socialTutorial=resolved.tutorial and not self.session.events.tutorial_completed
        if resolved.training and self.session.combat and self.session.combat.finished then
            self:switch(require("src.screens.training_result").new(self),transition)
        elseif self.session.combatPreparation then
            self:switch(require("src.screens.combat_safe").new(self),transition)
        elseif resolved.kind=="magic" and not socialTutorial and not self.session.encounter then
            if self.practiceFree then resolved.tutorial=false end
            self:switch(require("src.screens.combat").new(self,resolved),transition)
        else
            self:switch(require("src.screens.encounter").new(self),transition)
        end
    elseif node.definition.document then
        self:switch(require("src.screens.document").new(self,node.definition.document),transition)
    else
        self:switch(require("src.screens.dialogue").new(self),transition)
    end
end

function App:endDay()
    local Daily=require("src.systems.daily")
    if self.session.checkpoint~=Daily.config(self.session).summary then
        local nextId,err=Progression.endDay(self.session)
        if not nextId then self:notify(err); return false end
    end
    -- No se presenta el resumen ni se avanza si el guardado falló.
    if not self:save() then return false end
    self:resume()
    return true
end

function App:next(result)
    local current=Chapters.get(self.session.checkpoint)
    local resolved=current and ((current.kind=="scene" and Progression.scene(self.session,current.id))
        or (current.kind=="encounter" and Progression.encounter(self.session,current.id)))
    local transition=resolved and resolved.transition or (current and current.definition.transition)
    local nextId,err=Progression.next(self.session,self.session.checkpoint,result)
    if not nextId then self:notify(err or "Completa la decisión antes de continuar."); return end
    self:save()
    self:resume(transition)
end

function App:overlay(kind)
    self:save()
    self:switch(require("src.screens.overlays").new(self,kind),{type="fade_in",duration=.25})
end

function App:manual()
    local previous=self.manager.current
    self:switch(require("src.screens.manual").new(self,function() self:switch(previous) end))
end

-- La práctica usa una sesión desechable. Ni F5, salir ni las pantallas escriben
-- una partida mientras está activa; al volver se recupera la referencia original.
function App:startPractice(combatOnly)
    if self.practice then return end
    self.campaignSession=self.session
    self.campaignTutorialCompleted=self.options.tutorialCompleted
    self.practice=true
    self.practiceFree=combatOnly=="free"
    self.session=Save.newSession()
    require("src.systems.events").apply(self.session,"practice_starter",{starter=true,presenter="nanahoshi"})
    self.session.rewardQueue={}
    self.session.checkpoint="day1_tutorial"
    if combatOnly then self.session.events.tutorial_completed=true end
    self.options.tutorialCompleted=false
    self:resume()
end

function App:endPractice()
    if not self.practice then return end
    self.session=self.campaignSession
    self.options.tutorialCompleted=self.campaignTutorialCompleted
    self.campaignSession,self.campaignTutorialCompleted=nil,nil
    self.practice=false
    self.practiceFree=nil
    self.presentedNode=nil
    self:menu()
end

function App:finishCombat(enc)
    if enc~=self.session.combat or not enc.finished or (enc.outcome~="victory" and not enc.training) then return false end
    if self.practice then self:endPractice(); return true end
    local ok,err=Progression.finishCombat(self.session,enc)
    if not ok then self:notify(err); return false end
    self:save(); self:resume(); return true
end

function App:combatSafeExit()
    if self.practice then self:endPractice(); return end
    -- El punto seguro es la preparación, conservando el checkpoint y los
    -- vínculos previos. No entrega premios ni omite el enfrentamiento.
    self.session.combat=nil
    self.session.combatPreparation=true
    self:save()
    self:switch(require("src.screens.combat_safe").new(self))
end

function App:update(dt)
    self.toastTime=math.max(0,self.toastTime-dt)
    self.audio:update(dt)
    self.manager:update(dt)
end

function App:draw()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(.04,.05,.1,1)
    self.manager:draw()
    if self.toastTime>0 then
        love.graphics.setColor(.04,.05,.1,.97)
        love.graphics.rectangle("fill",12,335,616,20)
        Font.draw(self.toast,18,341,{maxWidth=604,color={1,.83,.48}})
    end
    love.graphics.setCanvas()
    love.graphics.clear(.015,.02,.04,1)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.canvas,self.offsetX,self.offsetY,0,self.scale,self.scale)
end

function App:mousepressed(x,y,button)
    x,y=self:logical(x,y)
    if x then self.manager:mousepressed(x,y,button) end
end

function App:keypressed(key)
    if Controls.matches(Controls.fullscreen,key) then
        self.options.fullscreen=not love.window.getFullscreen()
        self:applyOptions()
        Save.writeOptions(self.options)
        return
    end
    if self.manager.transition>0 then return end
    if Controls.matches(Controls.back,key) then self.audio:effect("cancel") end
    if self.session and Controls.matches(Controls.save,key) then
        if self:save() then self:notify("Partida guardada.") end
        return
    end
    self.manager:keypressed(key)
end

return App
