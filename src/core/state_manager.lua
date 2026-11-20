local Manager = {}
Manager.__index = Manager

function Manager.new(app)
    return setmetatable({app=app,current=nil,transition=0}, Manager)
end

function Manager:switch(screen)
    self.current = screen
    self.transition = 0.18
    if screen.enter then screen:enter(self.app) end
end

function Manager:update(dt)
    self.transition = math.max(0,self.transition-dt)
    if self.current and self.current.update then self.current:update(dt) end
end

function Manager:draw()
    if self.current then self.current:draw() end
    if self.transition > 0 then
        love.graphics.setColor(0.035,0.045,0.09,self.transition/0.18)
        love.graphics.rectangle("fill",0,0,640,360)
    end
end

function Manager:mousepressed(x,y,button)
    if self.transition > 0 then return end
    if self.current and self.current.mousepressed then self.current:mousepressed(x,y,button) end
end

function Manager:keypressed(key)
    if self.transition > 0 then return end
    if self.current and self.current.keypressed then self.current:keypressed(key) end
end

return Manager
