-- Los premios ya se concedieron mediante Events; esta pantalla sólo los presenta.
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local CardView=require("src.ui.card")
local Cards=require("src.data.cards")
local Techniques=require("src.data.combat_cards")
local Characters=require("src.data.characters")
local Reward={}
function Reward.new(app)
    local s=Screen.new(app)
    s.kind="reward"; s.reward=assert(app.session.rewardQueue[1]); s.age=0
    s.cards=s.reward.cards or {}; s.page=math.min(#s.cards,s.reward.presentationPage or 1)
    s.starter=s.reward.eventId=="starter_gift" or s.reward.eventId=="practice_starter"
    if app.audio then app.audio:effect("card_gift") end
    function s:update(dt)
        local before=self.age; self.age=self.age+dt
        if before<.6 and self.age>=.6 and app.audio then app.audio:effect("unlock") end
    end
    function s:continue()
        if self.closing then return end
        if self.age<.7 and not app.options.reducedMotion then self.age=.7; return end
        if self.page<#self.cards then
            self.page=self.page+1; self.age=0; self.reward.presentationPage=self.page
            app:save(); return
        end
        self.closing=true
        table.remove(app.session.rewardQueue,1)
        app:save(); app:resume()
    end
    function s:draw()
        self:begin(); app.resources:background("laboratory")
        love.graphics.setColor(.025,.035,.07,.8); love.graphics.rectangle("fill",0,0,640,360)
        W.panel(16,14,608,332)
        self:text(self.starter and "¡HAS OBTENIDO TU PRIMER MAZO!" or "¡NUEVA CARTA OBTENIDA!",36,30,568,P.gold,2)
        local giver=self.reward.presenter or "nanahoshi"
        local char=Characters.byId[giver]
        app.resources:portrait(giver,"happy",38,105,1)
        app.resources:portrait("rudeus","happy",534,105,1)
        self:text(char and char.shortName or "Recompensa",28,177,100,P.teal,1,"center")
        self:text("Rudy",530,177,74,P.teal,1,"center")
        -- Cofre pixel art y desplazamiento entero; no se deforma la ilustración.
        love.graphics.setColor(.30,.18,.10,1); love.graphics.rectangle("fill",58,220,50,30)
        love.graphics.setColor(.72,.51,.23,1); love.graphics.rectangle("fill",56,215,54,8)
        love.graphics.rectangle("fill",79,220,8,15)
        local id=self.cards[self.page]; local card=Cards.byId[id] or Techniques.byId[id]
        local t=app.options.reducedMotion and 1 or math.min(1,self.age/.6)
        if card then
            local x=math.floor(74+(278-74)*t); local y=math.floor(215+(81-215)*t-18*math.sin(t*math.pi))
            CardView.draw(app.resources,card,x,y)
            local social=Cards.byId[id]~=nil
            self:text((social and "SOCIAL" or "COMBATE").." · "..self.page.." / "..#self.cards,140,64,360,P.teal,1,"center")
            self:text(card.name,138,203,364,P.gold,1,"center")
            self:text(card.description,138,222,364,P.ink)
            local category=Cards.categories[card.category] or "Física"
            local condition=card.conditions and card.conditions.character
            self:text(category.." · Coste: "..(card.cost or 1).." acción/energía"..(condition and (" · Requiere "..condition) or ""),138,263,364,P.teal)
        end
        self:text(self.starter and "Orsted → Nanahoshi → Rudy. Cinco sociales y cinco físicas." or "Guardada en tu colección. Consulta sus efectos en Mazo.",42,287,556,P.muted,1,"center")
        self:button(self.page<#self.cards and "Siguiente carta" or "Continuar",226,309,188,25,function() self:continue() end)
    end
    function s:keypressed(key)
        if key=="return" or key=="space" or key=="escape" then self:continue() else self:navigate(key) end
    end
    return s
end
return Reward
