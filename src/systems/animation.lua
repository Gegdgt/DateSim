-- Animaciones finitas. La lógica del juego no depende de posiciones ni fotogramas.
local Animation={}
local Tween={}
Tween.__index=Tween
local easing={
    linear=function(t) return t end,
    outQuad=function(t) return 1-(1-t)*(1-t) end,
    inOut=function(t) return t<.5 and 2*t*t or 1-(-2*t+2)^2/2 end,
}

local function complete(self)
    if self.done then return end
    self.done=true
    if self.onComplete then local callback=self.onComplete; self.onComplete=nil; callback() end
end

function Animation.tween(from,to,duration,options)
    options=options or {}
    local self=setmetatable({from={},to={},value={},elapsed=0,duration=math.max(0,duration or 0),
        done=false,ease=easing[options.easing or "outQuad"] or easing.outQuad,
        onComplete=options.onComplete},Tween)
    for key,value in pairs(from) do self.from[key]=value; self.value[key]=value end
    for key,value in pairs(to) do self.to[key]=value; self.from[key]=self.from[key] or value end
    if options.reducedMotion then self.duration=0 end
    return self
end

function Tween:update(dt)
    if self.done then return self.value,true end
    self.elapsed=math.min(self.duration,self.elapsed+math.max(0,dt or 0))
    local t=self.duration==0 and 1 or self.elapsed/self.duration
    local factor=self.ease(t)
    for key,value in pairs(self.to) do self.value[key]=self.from[key]+(value-self.from[key])*factor end
    if t>=1 then complete(self) end
    return self.value,self.done
end

function Tween:finish() return self:update(self.duration) end

Animation.actorNames={enter_left=true,enter_right=true,happy_bounce=true,shake=true,
    small_shake=true,surprised_jump=true,sad_lower=true,angry_shake=true,
    expression_change=true,exit_left=true,exit_right=true,speaking=true}
local Actor={}
Actor.__index=Actor

function Animation.actor(kind,options)
    options=options or {}
    kind=Animation.actorNames[kind] and kind or "expression_change"
    local self=setmetatable({kind=kind,elapsed=0,duration=options.duration or
        ((kind=="happy_bounce" or kind=="shake") and .32 or .28),
        reducedMotion=options.reducedMotion==true,done=false,value={x=0,y=0,alpha=1},
        onComplete=options.onComplete},Actor)
    self:update(0)
    return self
end

function Actor:update(dt)
    if self.done then return self.value,true end
    self.elapsed=math.min(self.duration,self.elapsed+math.max(0,dt or 0))
    local t=self.duration<=0 and 1 or self.elapsed/self.duration
    if self.reducedMotion then t=1 end
    local value,kind=self.value,self.kind
    value.x,value.y,value.alpha=0,0,1
    if kind=="enter_left" or kind=="enter_right" then
        value.x=(kind=="enter_left" and -48 or 48)*(1-t)^2; value.alpha=t
    elseif kind=="exit_left" or kind=="exit_right" then
        value.x=(kind=="exit_left" and -48 or 48)*t*t; value.alpha=1-t
    elseif kind=="happy_bounce" then value.y=-math.sin(t*math.pi)*6
    elseif kind=="shake" or kind=="small_shake" or kind=="angry_shake" then value.x=math.sin(t*math.pi*6)*(1-t)*(kind=="angry_shake" and 5 or 3)
    elseif kind=="surprised_jump" then value.y=-math.sin(t*math.pi)*10
    elseif kind=="sad_lower" then value.y=math.sin(t*math.pi)*5
    elseif kind=="speaking" then value.y=-math.sin(t*math.pi)*2 end
    if self.reducedMotion then
        value.x,value.y=0,0
        value.alpha=(kind=="exit_left" or kind=="exit_right") and 0 or 1
    end
    if t>=1 then
        value.x,value.y=0,0
        if kind=="exit_left" then value.x=self.reducedMotion and 0 or -48
        elseif kind=="exit_right" then value.x=self.reducedMotion and 0 or 48 end
        complete(self)
    end
    return value,self.done
end

function Actor:finish() return self:update(self.duration) end
return Animation
