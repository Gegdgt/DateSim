local Font=require("src.ui.font")
local Manager={}
Manager.__index=Manager
Manager.transitionTypes={dream=true,fade=true,fade_in=true,horizontal=true,new_day=true,night=true,magic=true,["return"]=true}

function Manager.new(app)
    return setmetatable({app=app,current=nil,transition=0,activationCount=0},Manager)
end

-- A screen activates once. Snapshot the outgoing canvas instead of drawing an
-- old screen that could read the new session/checkpoint during the transition.
function Manager:switch(screen,options)
    if self.transition>0 or screen==self.current then return false end
    options=options or {}
    if type(options)=="string" then options={type=options} end
    local kind=Manager.transitionTypes[options.type] and options.type or "fade"
    local duration=math.max(.25,math.min(.6,tonumber(options.duration) or .3))
    local reduced=self.app.options and self.app.options.reducedMotion
    if reduced then
        if kind~="dream" then kind="fade" end
        duration=.12
    end
    if self.current and kind~="fade_in" and self.app.canvas and love.graphics then
        local ok,frame=pcall(function()
            local pixels=self.app.canvas:newImageData()
            local image=love.graphics.newImage(pixels)
            pixels:release(); image:setFilter("nearest","nearest")
            return image
        end)
        if ok then self.outgoingFrame=frame end
    end
    self.current=screen
    self.activationCount=self.activationCount+1
    self.transition,self.duration=duration,duration
    self.effect={type=kind,title=options.title,day=options.day,reducedMotion=reduced}
    if screen.enter then screen:enter(self.app) end
    return true
end

function Manager:finishTransition()
    self.transition=0
    if self.outgoingFrame then self.outgoingFrame:release(); self.outgoingFrame=nil end
end

function Manager:update(dt)
    local before=self.transition
    self.transition=math.max(0,self.transition-math.max(0,dt))
    if before>0 and self.transition==0 then self:finishTransition() end
    -- Start the incoming text clock after the curtain has cleared.
    local available=math.max(0,dt-before)
    if self.transition==0 and self.current and self.current.update then self.current:update(available) end
end

function Manager:draw()
    local t=self.transition>0 and 1-self.transition/self.duration or 1
    if self.outgoingFrame and t<.5 then
        love.graphics.setColor(1,1,1,1); love.graphics.draw(self.outgoingFrame,0,0)
    elseif self.current then self.current:draw() end
    if self.transition<=0 then return end
    local effect=self.effect
    local alpha=self.outgoingFrame and (t<.5 and t*2 or (1-t)*2) or 1-t
    if effect.type=="horizontal" then
        love.graphics.setColor(.025,.035,.065,1)
        local width=math.floor(640*alpha)
        love.graphics.rectangle("fill",t<.5 and 0 or 640-width,0,width,360)
    else
        if effect.type=="dream" then love.graphics.setColor(1,1,1,alpha) else love.graphics.setColor(.025,.035,.065,alpha) end
        love.graphics.rectangle("fill",0,0,640,360)
        if effect.type=="new_day" then
            Font.draw("DÍA "..tostring(effect.day or ""),0,148,{maxWidth=640,align="center",scale=2,color={1,.83,.48,alpha}})
            Font.draw(effect.title or "Un nuevo camino",60,187,{maxWidth=520,align="center",color={.9,.88,.82,alpha}})
        elseif effect.type=="night" then
            Font.draw("LA CASA DESCANSA",0,174,{maxWidth=640,align="center",scale=2,color={.86,.88,1,alpha}})
        elseif effect.type=="magic" then
            love.graphics.setColor(.55,.68,.72,.28*alpha)
            for i=1,8 do
                local angle=i*math.pi/4; local radius=24+t*70
                love.graphics.rectangle("fill",math.floor(320+math.cos(angle)*radius),math.floor(180+math.sin(angle)*radius),4,4)
            end
        end
    end
end

function Manager:mousepressed(x,y,button)
    if self.transition>0 then return end
    if self.current and self.current.mousepressed then self.current:mousepressed(x,y,button) end
end

function Manager:keypressed(key)
    if self.transition>0 then return end
    if self.current and self.current.keypressed then self.current:keypressed(key) end
end
return Manager
