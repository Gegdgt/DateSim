local Font = require("src.ui.font")
local W = require("src.ui.widgets")
local P = require("src.ui.palette")
local Screen = {}
Screen.__index = Screen

function Screen.new(app)
    return setmetatable({app=app,buttons={}},Screen)
end

function Screen:begin()
    self.buttons = {}
end

function Screen:text(text,x,y,width,color,scale,align)
    Font.draw(tostring(text or ""),x,y,{maxWidth=width,color=color or P.ink,scale=scale or 1,align=align or "left"})
end

function Screen:button(label,x,y,w,h,action,disabled,selected)
    local mx,my = self.app:mouse()
    local hover = mx and mx >= x and mx < x+w and my >= y and my < y+h
    W.button(label,x,y,w,h,{hover=hover,disabled=disabled,selected=selected})
    self.buttons[#self.buttons+1]={label=label,x=x,y=y,w=w,h=h,action=action,disabled=disabled}
    return hover
end

function Screen:click(x,y,button)
    if button ~= 1 then return false end
    for _,b in ipairs(self.buttons) do
        if x >= b.x and x < b.x+b.w and y >= b.y and y < b.y+b.h then
            if not b.disabled then b.action() end
            return true
        end
    end
    return false
end

function Screen:header(title,back)
    W.panel(8,7,624,30)
    self:text(title,18,18,340,P.gold)
    if back then
        self:button("Volver",548,12,76,20,function() self.app:resume() end)
    else
        self:button("Diario [J]",350,12,94,20,function() self.app:overlay("journal") end)
        self:button("Mazo [M]",450,12,88,20,function() self.app:overlay("deck") end)
        self:button("Pausa",544,12,80,20,function() self.app:overlay("pause") end)
    end
end

function Screen:mousepressed(x,y,button) self:click(x,y,button) end
return Screen
