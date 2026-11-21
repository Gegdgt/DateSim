-- Presentación únicamente: lee valores definitivos, nunca modifica la partida.
local Font=require("src.ui.font")
local Animation=require("src.systems.animation")
local Characters=require("src.data.characters")
local P=require("src.ui.palette")
local Bars={height=42,duration=.6}
Bars.__index=Bars
Bars.colors={love={.94,.48,.65,1},trust={.40,.68,.96,1},interest={.91,.74,.37,1}}
local function finite(value)
    return type(value)=="number" and value==value and math.abs(value)<math.huge and value or 0
end
local function clamp(value) return math.max(0,math.min(100,finite(value))) end
local function copy(values)
    local out={}; for key,value in pairs(values or {}) do out[key]=value end; return out
end
local function signed(value) return (value>=0 and "+" or "")..tostring(value) end
function Bars.read(session,character)
    local data=Characters.byId[character]
    if data and data.romance and session and session.relationships and session.relationships[character] then
        local r=session.relationships[character]
        return {love=clamp(r.love),trust=clamp(r.trust)},{{key="love",label="Amor"},{key="trust",label="Confianza"}}
    elseif character=="nanahoshi" then
        local r=require("src.systems.affinity").get(session,character)
        return {trust=clamp(r.trust),interest=clamp(r.interest)},{{key="trust",label="Confianza"},{key="interest",label="Interés"}}
    end
end
function Bars.new(session,character,options)
    local values,fields=Bars.read(session,character)
    if not values then return nil end
    local seen={}
    -- Al cargar, los acontecimientos históricos ya están vistos. No reaparecen
    -- corazones ni sonidos aunque el resultado vuelva a dibujarse.
    for key,value in pairs(session.events or {}) do if value==true then seen[key]=true end end
    return setmetatable({character=character,name=Characters.byId[character].shortName,
        fields=fields,value=copy(values),target=copy(values),options=options or {},seen=seen,
        age=0,feedbackTime=0,notifications=0},Bars)
end
function Bars:_target(values)
    local changed=false
    for key,value in pairs(values) do if value~=self.target[key] then changed=true end end
    if not changed then return end
    self.target=copy(values)
    self.tween=Animation.tween(self.value,self.target,Bars.duration,{easing="inOut",reducedMotion=self.options.reducedMotion})
    if self.options.reducedMotion then self.tween:finish(); self.value=copy(self.tween.value) end
end
function Bars:sync(session)
    local values=Bars.read(session,self.character)
    if values then self:_target(values) end
end
function Bars:apply(eventKey,session,deltas,explanation)
    if type(eventKey)~="string" or self.seen[eventKey] then return false end
    self.seen[eventKey]=true
    local values=Bars.read(session,self.character)
    if not values then return false end
    local actual,positive,negative={},false,false
    for _,field in ipairs(self.fields) do
        -- El estado lógico determina el delta, incluso cerca de 0 o 100.
        local change=values[field.key]-self.target[field.key]
        actual[field.key]=change
        positive=positive or change>0; negative=negative or change<0
    end
    self:_target(values)
    if not positive and not negative then return false end
    self.feedbackData={id=eventKey,deltas=actual,explanation=explanation or "",
        positive=positive,negative=negative,age=0}
    self.feedbackTime=1.2; self.notifications=self.notifications+1
    if self.options.audio then self.options.audio:effect(negative and "negative" or "positive") end
    return true
end
function Bars:update(dt)
    dt=math.max(0,finite(dt)); self.age=self.age+dt
    if self.tween then
        self.tween:update(dt); self.value=copy(self.tween.value)
        if self.tween.done then self.value=copy(self.target); self.tween=nil end
    end
    self.feedbackTime=math.max(0,self.feedbackTime-dt)
    if self.feedbackData then self.feedbackData.age=self.feedbackData.age+dt end
end
function Bars:feedback() return self.feedbackTime>0 and self.feedbackData or nil end
function Bars:layout(anchor)
    local width=math.max(110,math.floor(anchor.width or anchor.w or 128))
    local x=math.floor(anchor.x+(anchor.w or width)/2-width/2)
    local y=math.floor(anchor.y-Bars.height-4)
    return {x=x,y=y,w=width,h=Bars.height,portrait={x=anchor.x,y=anchor.y,w=anchor.w,h=anchor.h},alpha=anchor.alpha or 1}
end
local function color(c,alpha) love.graphics.setColor(c[1],c[2],c[3],(c[4] or 1)*alpha) end
local function rect(c,x,y,w,h,alpha)
    color(c,alpha); love.graphics.rectangle("fill",math.floor(x),math.floor(y),math.floor(w),math.floor(h))
end
local function heart(x,y,alpha)
    for row,bits in ipairs({"0110110","1111111","1111111","0111110","0011100","0001000"}) do
        for col=1,#bits do if bits:sub(col,col)=="1" then rect(Bars.colors.love,x+col-1,y+row-1,1,1,alpha) end end
    end
end
function Bars:draw(anchor)
    local box=self:layout(anchor); self.lastBounds=box
    local alpha=math.max(0,math.min(1,box.alpha)); if alpha<=0 then return box end
    local feedback=self:feedback()
    local reduced=self.options.reducedMotion
    local shake=feedback and feedback.negative and not reduced and feedback.age<.4
        and math.floor(math.sin(feedback.age*45)*(1-feedback.age/.4)*2) or 0
    local x,y=box.x+shake,box.y
    rect(P.border,x,y,box.w,box.h,alpha); rect(P.panel,x+1,y+1,box.w-2,box.h-2,alpha)
    Font.draw(self.name,x+4,y+3,{maxWidth=box.w-8,align="center",color={P.ink[1],P.ink[2],P.ink[3],alpha}})
    for i,field in ipairs(self.fields) do
        local row=y+13+(i-1)*14
        Font.draw(field.label,x+5,row,{maxWidth=58,color={P.muted[1],P.muted[2],P.muted[3],alpha}})
        local value=math.floor(clamp(self.value[field.key])+.5)
        Font.draw(tostring(value),x+box.w-26,row,{maxWidth=21,align="right",color={P.ink[1],P.ink[2],P.ink[3],alpha}})
        rect(P.shadow,x+5,row+9,box.w-10,4,alpha)
        rect(Bars.colors[field.key],x+6,row+10,math.floor((box.w-12)*clamp(self.value[field.key])/100),2,alpha)
        local delta=feedback and feedback.deltas[field.key] or 0
        if delta~=0 then
            local lift=reduced and 0 or math.floor(math.min(1,feedback.age/.8)*4)
            local tint=delta>0 and P.green or P.danger
            Font.draw(signed(delta),x+box.w-51,row-lift,{maxWidth=24,align="right",color={tint[1],tint[2],tint[3],alpha}})
        end
    end
    if feedback and feedback.positive and not feedback.negative then
        if self.character=="nanahoshi" then
            rect(Bars.colors.interest,x+box.w-12,y+4,2,6,alpha); rect(Bars.colors.interest,x+box.w-14,y+6,6,2,alpha)
        else
            local lift=reduced and 0 or math.floor(math.min(1,feedback.age)*3)
            heart(x+box.w-14,y+4-lift,alpha)
        end
    end
    return box
end
return Bars
