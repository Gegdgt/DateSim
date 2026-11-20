local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Data=require("src.data.cards")
local Characters=require("src.data.characters")
local Cards=require("src.systems.cards")
local Progression=require("src.systems.progression")
local Controls=require("src.config.controls")
local Encounter={}

function Encounter.new(app)
    local s=Screen.new(app)
    s.definition=Progression.encounter(app.session,app.session.checkpoint)
    local context={kind=s.definition.kind,character=s.definition.character}
    local restored=Cards.restore(app.session.encounter,app.session.deck,context)
    app.session.encounter=restored or Cards.new(app.session.deck,context)
    s.enc=app.session.encounter
    s.age=0
    s.selected=1
    s.feedback=#s.enc.log>0 and s.enc.log[#s.enc.log].text or "Elige una carta. Cada acción utiliza uno de tus tres turnos."
    app:save()
    function s:update(dt) self.age=self.age+dt end
    function s:act(index)
        if self.age<.18 then return end
        local result,err
        if index then result,err=Cards.play(self.enc,index) else result,err=Cards.pass(self.enc) end
        if not result then app:notify(err); return end
        self.feedback=result.text
        self.age=0
        app:save()
    end
    function s:finish()
        if not self.enc.finished then return end
        local result={score=self.enc.score,trust=0,chemistry=0}
        for _,entry in ipairs(self.enc.log) do
            result.trust=result.trust+entry.trust
            result.chemistry=result.chemistry+entry.chemistry
        end
        app:next(result)
    end
    function s:draw()
        self:begin()
        local enc,def=self.enc,self.definition
        app.resources:background(def.background)
        love.graphics.setColor(.025,.035,.07,.45)
        love.graphics.rectangle("fill",0,38,640,322)
        self:header("DÍA "..app.session.day.." / "..def.title)
        local char=def.character and Characters.byId[def.character]
        app.resources:portrait(def.character or "nanahoshi",enc.finished and "happy" or "neutral",6,52,2)
        W.panel(135,48,487,96)
        self:text(char and char.name or "Nanahoshi · Tutorial",147,60,462,P.gold)
        self:text(def.intro,147,79,462,P.ink)
        self:text("3 turnos · 4 energía TOTAL · Robas después de jugar",147,111,462,P.teal)
        self:text("Los puntos de vínculo se confirman al ver el resultado.",147,128,462,P.muted)
        W.panel(135,151,487,40)
        self:text(self.feedback,147,162,462,P.gold)
        W.panel(18,196,110,128)
        self:text(enc.finished and "COMPLETADO" or "TURNO "..enc.turn.." / 3",28,208,90,P.gold)
        self:text("ENERGÍA",28,229,90,P.muted)
        for i=1,4 do
            love.graphics.setColor(unpack(i<=enc.energy and P.teal or P.border))
            love.graphics.rectangle("fill",28+(i-1)*21,245,15,9)
        end
        self:text("AVANCE "..enc.score.."/"..def.targetScore,28,267,90,P.ink)
        W.bar(28,286,90,6,enc.score,def.targetScore,P.gold)
        self:text("Robo "..#enc.drawPile.."\nDescarte "..#enc.discard,28,301,90,P.muted)
        local mx,my=app:mouse()
        for i,id in ipairs(enc.hand) do
            local x,y=143+(i-1)*94,203+math.floor(math.max(0,.18-self.age)*35)
            local card=Data.byId[id]
            local can=Cards.canPlay(enc,i)
            local hover=mx and mx>=x and mx<x+80 and my>=y and my<y+112
            if hover then self.selected=i; y=y-4 end
            app.resources:cardFrame(x,y,1)
            local categoryColor=({empathy=P.teal,humor=P.gold,sincerity=P.rose,initiative=P.lavender})[card.category]
            love.graphics.setColor(unpack(categoryColor))
            love.graphics.rectangle("fill",x+4,y+4,72,3)
            self:text(card.name,x+7,y+13,66,P.ink)
            app.resources:icon(card.icon,x+28,y+35,1)
            self:text("COSTE "..card.cost,x+6,y+83,68,P.gold,1,"center")
            self:text("["..i.."] "..(can and "JUGAR" or (enc.finished and "FIN" or "NO DISP.")),x+5,y+99,70,can and P.teal or P.muted,1,"center")
            if not can then
                love.graphics.setColor(.025,.035,.07,.42)
                love.graphics.rectangle("fill",x+3,y+9,74,69)
            end
            self.buttons[#self.buttons+1]={x=x,y=y,w=80,h=112,disabled=not can,action=function() self:act(i) end}
        end
        W.panel(429,196,193,128)
        local card=Data.byId[enc.hand[self.selected] or enc.hand[1]]
        if card then
            self:text(Data.categories[card.category],439,207,173,P.teal)
            self:text(card.description,439,225,173,P.ink)
            local preview=Cards.preview(enc,self.selected)
            if preview then self:text("Aquí: +"..preview.score.." avance\n+"..preview.trust.." conf. +"..preview.chemistry.." química",439,292,173,P.gold) end
        end
        self:text("Mazo: 10 cartas · energía sin recarga",18,340,360,P.muted)
        self:button(enc.finished and "Ver resultado >" or "Tomar un respiro [P]",387,331,235,23,function()
            if enc.finished then self:finish() else self:act() end
        end)
    end
    function s:keypressed(key)
        if Controls.matches(Controls.back,key) then app:overlay("pause")
        elseif Controls.matches(Controls.journal,key) then app:overlay("journal")
        elseif Controls.matches(Controls.deck,key) then app:overlay("deck")
        elseif self.enc.finished and Controls.matches(Controls.advance,key) then self:finish()
        elseif Controls.matches(Controls.freeAction,key) then self:act()
        else for i,k in ipairs(Controls.cards) do if key==k then self:act(i); return end end end
    end
    return s
end
return Encounter
