local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Font=require("src.ui.font")
local Guide=require("src.data.manual")
local Characters=require("src.data.characters")
local Cards=require("src.data.cards")
local Collection=require("src.screens.collection")
local CardView=require("src.ui.card")
local Save=require("src.systems.save")
local Manual={}

function Manual.pageCount(section)
    return ({#Characters.list,#Cards.list+#require("src.data.combat_cards").list,#Guide.categories,#Guide.scenarios,#Guide.rules,1,1})[section] or 1
end

function Manual.new(app,returnTo)
    local s=Screen.new(app)
    s.kind="manual"; s.section=6; s.page=1
    s.session=app.session or Save.load() or Save.newSession()
    s.returnTo=returnTo or function() if app.session then app:resume() else app:menu() end end
    function s:changeSection(index)
        self.section=math.max(1,math.min(#Guide.sections,index)); self.page=1; self.keyboardFocus=nil
    end
    function s:changePage(delta)
        local pages=self.section==7 and math.max(1,math.ceil(#require("src.screens.history").lines(self.session)/5)) or Manual.pageCount(self.section)
        self.page=(self.page-1+delta)%pages+1; self.keyboardFocus=nil
    end
    function s:draw()
        self:begin()
        app.resources:background("library")
        love.graphics.setColor(.025,.035,.07,.85); love.graphics.rectangle("fill",0,0,640,360)
        W.panel(8,7,624,30)
        self:text("MANUAL DEL AVENTURERO",18,18,492,P.gold)
        self:button("Volver",548,12,76,20,self.returnTo)
        for i,label in ipairs(Guide.sections) do
            self:button(label,14+(i-1)*88,45,85,24,function() self:changeSection(i) end,false,self.section==i)
        end
        W.panel(14,77,612,232)
        if self.section==1 then
            local char=Characters.list[self.page]
            local extra=Guide.characters[char.id]
            app.resources:portrait(char.id,"neutral",34,103,2)
            self:text(char.name,182,91,426,P.gold)
            self:text(char.description,182,118,426,P.ink)
            self:text("PERSONALIDAD",182,161,426,P.teal)
            self:text(extra.personality,182,178,426,P.ink)
            self:text("ROL EN LA HISTORIA",182,222,426,P.teal)
            self:text(extra.role,182,239,426,P.ink)
        elseif self.section==2 then
            local card=Cards.list[self.page]
            if not card then
                card=require("src.data.combat_cards").list[self.page-#Cards.list]
                CardView.draw(app.resources,card,34,110)
                self:text(card.name,132,91,474,P.gold)
                self:text(s.session.unlocked[card.id] and "ADQUIRIDA" or "BLOQUEADA",132,113,474,P.teal)
                self:text("TÉCNICA DE COMBATE",132,144,474,P.gold)
                self:text(require("src.systems.combat").describe(card),132,169,474,P.ink)
                self:text(card.description,132,211,474,P.ink)
                self:text("OBTENCIÓN: "..(card.unlockHint or "Entrega de Nanahoshi."),34,269,572,P.muted)
            else
            local detail=Collection.details(card,s.session)
            CardView.draw(app.resources,card,34,110)
            self:text(card.name,132,91,474,P.gold)
            self:text(detail.category.." · "..detail.stateLabel,132,109,474,P.teal)
            self:text("SOCIAL · "..detail.cost,132,132,474,P.gold)
            self:text(detail.base,132,148,474,P.ink)
            self:text("Bonos: "..detail.contexts.." "..detail.affinity,132,167,474,P.muted)
            self:text("COMBATE MÁGICO",132,201,474,P.gold)
            self:text(Collection.combatDetail(card),132,217,474,P.ink)
            self:text("OBTENCIÓN: "..detail.unlock,34,269,572,P.muted)
            end
        elseif self.section==3 then
            local category=Guide.categories[self.page]
            app.resources:categoryIcon(category.id,43,114,3)
            love.graphics.setColor(category.color); love.graphics.rectangle("fill",34,205,90,9)
            self:text(category.name,148,104,454,category.color)
            self:text(category.text,148,141,454,P.ink)
            self:text("La categoría clasifica el tema de la carta. No es un elemento de daño. Lee sus efectos y contextos para saber dónde funciona.",148,219,454,P.gold)
        elseif self.section==4 then
            local scene=Guide.scenarios[self.page]
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(app.resources:getBackground(scene.id),24,104)
            self:text(scene.name,24,87,582,P.gold)
            self:text(scene.description,360,119,246,P.ink)
            self:text("Escenario "..self.page.." / "..#Guide.scenarios.."\nPNG original · 320 x 180",360,248,246,P.muted)
        elseif self.section==5 then
            local rule=Guide.rules[self.page]
            self:text(rule.title,30,92,578,P.gold)
            self:text(rule.text,30,121,578,P.ink)
        elseif self.section==6 then
            self:text(Guide.history.title,30,92,578,P.gold)
            self:text(Guide.history.text,30,121,578,P.ink)
        elseif self.section==7 then
            local lines=require("src.screens.history").lines(self.session)
            for row=1,5 do self:text(lines[(self.page-1)*5+row] or "",30,93+(row-1)*40,578,P.ink) end
        end
        self:button("< Anterior",14,318,144,25,function() self:changePage(-1) end)
        local pageCount=self.section==7 and math.max(1,math.ceil(#require("src.screens.history").lines(self.session)/5)) or Manual.pageCount(self.section)
        self:text(Guide.sections[self.section].." · "..self.page.." / "..pageCount,168,325,304,P.gold,1,"center")
        self:button("Siguiente >",482,318,144,25,function() self:changePage(1) end)
        self:text("1-7: sección · Izq/Der: página · Tab/Enter: botones · Esc: volver",14,348,612,P.muted)
    end
    function s:keypressed(key)
        if key=="escape" then self.returnTo(); return end
        local section=tonumber(key)
        if section and section>=1 and section<=7 then self:changeSection(section); return end
        if key=="left" or key=="pageup" then self:changePage(-1); return end
        if key=="right" or key=="pagedown" then self:changePage(1); return end
        self:navigate(key)
    end
    return s
end
return Manual
