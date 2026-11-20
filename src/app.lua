local Manager = require("src.core.state_manager")
local Resources = require("src.systems.resources")
local Save = require("src.systems.save")
local Progression = require("src.systems.progression")
local Story = require("src.data.story")
local Controls = require("src.config.controls")
local Font = require("src.ui.font")
local App = {}
App.__index = App

function App.new()
    local self = setmetatable({},App)
    self.canvas=love.graphics.newCanvas(640,360)
    self.canvas:setFilter("nearest","nearest")
    self.resources=Resources.new()
    self.options=Save.readOptions and Save.readOptions() or {volume=.6,muted=false}
    self.manager=Manager.new(self)
    self.toast,self.toastTime="",0
    self:resize()
    self:applyAudio()
    self:menu()
    return self
end

function App:resize()
    local w,h=love.graphics.getDimensions()
    local fit=math.min(w/640,h/360)
    self.scale=fit>=1 and math.floor(fit) or fit
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
function App:applyAudio() love.audio.setVolume(self.options.muted and 0 or self.options.volume) end

function App:save()
    if not self.session then return true end
    self.session.options=self.options
    local ok,err=Save.write(self.session)
    if not ok then self:notify("No se pudo guardar: "..tostring(err)) end
    return ok
end

function App:newGame()
    self.session=Save.newSession()
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
    self.manager:switch(require("src.screens.menu").new(self))
end

function App:resume()
    if not self.session then self:menu(); return end
    local checkpoint=self.session.checkpoint
    if checkpoint=="hub" then
        self.manager:switch(require("src.screens.hub").new(self))
    elseif checkpoint=="phase_complete" then
        self.manager:switch(require("src.screens.summary").new(self))
    elseif Story.encounters[checkpoint] then
        self.manager:switch(require("src.screens.encounter").new(self))
    else
        self.manager:switch(require("src.screens.dialogue").new(self))
    end
end

function App:next(result)
    local nextId,err=Progression.next(self.session,self.session.checkpoint,result)
    if not nextId then self:notify(err or "Completa la decisión antes de continuar."); return end
    self:save()
    self:resume()
end

function App:overlay(kind)
    self:save()
    self.manager:switch(require("src.screens.overlays").new(self,kind))
end

function App:update(dt)
    self.toastTime=math.max(0,self.toastTime-dt)
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
        love.window.setFullscreen(not love.window.getFullscreen(),"desktop")
        self:resize()
        return
    end
    if self.manager.transition>0 then return end
    if self.session and Controls.matches(Controls.save,key) then
        if self:save() then self:notify("Partida guardada.") end
        return
    end
    self.manager:keypressed(key)
end

return App
