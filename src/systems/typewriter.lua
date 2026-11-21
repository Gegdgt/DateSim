-- Cuenta puntos de código UTF-8, nunca bytes de una tilde o un signo.
local utf8=require("utf8")
local Typewriter={}
Typewriter.__index=Typewriter

function Typewriter.slice(text,count)
    count=math.max(0,math.floor(tonumber(count) or 0))
    local boundary=utf8.offset(text,count+1)
    return boundary and text:sub(1,boundary-1) or text
end

function Typewriter.new(text,options)
    local self=setmetatable({},Typewriter)
    self:setText(text or "",options)
    return self
end

function Typewriter:setText(text,options)
    options=options or {}
    self.text=text
    self.length=assert(utf8.len(text),"El diálogo contiene UTF-8 inválido")
    self.speed=math.max(1,tonumber(options.textSpeed) or 50)
    self.enabled=options.textAnimation~=false
    self.elapsed,self.visible=0,self.enabled and 0 or self.length
end

function Typewriter:update(dt)
    self.elapsed=self.elapsed+math.max(0,dt or 0)
    self.visible=self.enabled and math.min(self.length,math.floor(self.elapsed*self.speed+.000001)) or self.length
    return self:shown()
end

function Typewriter:showAll()
    self.visible=self.length
    self.elapsed=self.length/self.speed
end

function Typewriter:isComplete() return self.visible>=self.length end
function Typewriter:shown() return Typewriter.slice(self.text,self.visible) end
return Typewriter
