local Font = require("src.ui.font")
local W = require("src.ui.widgets")
local P = require("src.ui.palette")
local Controls = require("src.config.controls")
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
    W.button(label,x,y,w,h,{hover=hover,disabled=disabled,selected=selected or self.keyboardFocus==#self.buttons+1})
    self.buttons[#self.buttons+1]={label=label,x=x,y=y,w=w,h=h,action=action,disabled=disabled}
    return hover
end

function Screen:click(x,y,button)
    if button ~= 1 then return false end
    self.keyboardFocus=nil
    for _,b in ipairs(self.buttons) do
        if x >= b.x and x < b.x+b.w and y >= b.y and y < b.y+b.h then
            if not b.disabled then b.action() end
            return true
        end
    end
    return false
end

-- Reutiliza las mismas acciones e hitboxes del mouse. Tab y flechas verticales
-- recorren botones habilitados; Enter/Espacio activan únicamente el foco visible.
function Screen:navigate(key)
    local direction=(Controls.matches(Controls.previousButton,key) and -1)
        or (Controls.matches(Controls.nextButton,key) and 1)
    if direction then
        local count=#self.buttons
        if count==0 then return true end
        local current=self.keyboardFocus or (direction==1 and 0 or count+1)
        for _=1,count do
            current=(current-1+direction)%count+1
            local button=self.buttons[current]
            if button.label and not button.disabled then self.keyboardFocus=current; return true end
        end
        return true
    end
    if self.keyboardFocus and Controls.matches(Controls.advance,key) then
        local button=self.buttons[self.keyboardFocus]
        if button and not button.disabled then button.action() end
        return true
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
function Screen:keypressed(key) self:navigate(key) end
return Screen
