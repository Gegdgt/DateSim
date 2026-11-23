local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local CardView=require("src.ui.card")
local Collection=require("src.systems.card_collection")
local Economy=require("src.systems.economy")
local Upgrades={}
function Upgrades.effects(view)
    local parts={}
    if view.effect then parts[#parts+1]="Amor "..string.format("%+d",view.effect.love).." / Conf. "..string.format("%+d",view.effect.trust) end
    for _,key in ipairs({"damage","shield","heal","draw","mana"}) do
        local value=view.combatEffect and view.combatEffect[key]
        if value then parts[#parts+1]=({damage="Daño ",shield="Escudo ",heal="Cura ",draw="Toma ",mana="Recupera maná "})[key]..value end
    end
    return table.concat(parts," · ")
end
function Upgrades.new(app,selected,returnTo)
    local s=Screen.new(app);s.kind="upgrades";s.index=1;s.page=1
    for i,card in ipairs(Collection.list) do if card.id==selected then s.index=i;s.page=math.ceil(i/9) end end
    function s:improve()
        if self.pending then return end
        local id=Collection.list[self.index].id
        local ok,err=Collection.canUpgrade(app.session,id)
        if not ok then self.message=err;return end
        self.pending={id=id,revision=Economy.ensure(app.session).revision,before=Collection.view(app.session,id),age=0}
        self.keyboardFocus=nil
    end
    function s:update(dt)
        local pending=self.pending;if not pending then return end
        pending.age=pending.age+dt
        if pending.age>=.45 and not pending.committed then
            pending.committed=true
            local result,err=Collection.upgrade(app.session,pending.id,pending.revision)
            pending.result=result
            self.message=err or ("¡Mejora completada! -"..result.receipt.copies.." copias / "..result.receipt.gold.." oro.")
            if result then
                require("src.systems.wife_activities").upgraded(app.session,result.receipt)
                app.audio:effect("upgrade");app:save()
            end
        end
    end
    function s:draw()
        self:begin();app.resources:background("library")
        W.panel(8,7,624,30)
        self:text("MEJORAR CARTAS",18,18,205,P.gold)
        self:text("ORO: "..app.session.gold,231,18,170,P.teal)
        self:button("Tienda",424,12,90,20,function() app:switch(require("src.screens.shop").new(app,Collection.list[self.index].id)) end,self.pending~=nil or returnTo~=nil)
        self:button("Volver",524,12,100,20,function() if returnTo then returnTo() else app:overlay("deck") end end,self.pending~=nil)
        W.panel(14,46,192,293);W.panel(216,46,410,293)
        for row=1,9 do
            local index=(self.page-1)*9+row;local card=Collection.list[index]
            if card then
                local view=Collection.view(app.session,card.id)
                self:button((view.unlocked and "N"..view.level.." " or "[X] ")..card.name,22,57+(row-1)*25,176,24,function() self.index=index;self.message=nil end,self.pending~=nil,index==self.index)
            end
        end
        local pages=math.ceil(#Collection.list/9)
        self:button("<",22,295,44,26,function() self.page=self.page-1;self.index=(self.page-1)*9+1 end,self.page==1 or self.pending~=nil)
        self:text(self.page.." / "..pages,76,304,68,P.ink)
        self:button(">",154,295,44,26,function() self.page=self.page+1;self.index=(self.page-1)*9+1 end,self.page==pages or self.pending~=nil)
        local card=Collection.list[self.index];local view=Collection.view(app.session,card.id)
        local nextView=view.level<10 and Collection.view(app.session,card.id,view.level+1)
        self:text(card.name,228,57,386,P.gold)
        local elevation=self.pending and not app.options.reducedMotion and math.floor(12*math.min(1,self.pending.age/.3)) or 0
        CardView.draw(app.resources,card,229,87-elevation)
        if self.pending and self.pending.age>.2 and self.pending.age<.7 and not app.options.reducedMotion then
            love.graphics.setColor(1,.85,.45,.8)
            for i=0,7 do local x=229+(i%4)*23;local y=78+math.floor(i/4)*112;love.graphics.rectangle("fill",x,y,4,4) end
        end
        self:text(view.type.." · "..view.className.."\nNivel "..view.level.." / 10",324,82,286,P.teal)
        local before=self.pending and self.pending.before or view
        local after=self.pending and self.pending.result and self.pending.result.after or nextView
        self:text("ACTUAL"..(self.pending and " (ANTES)" or "").."\n"..Upgrades.effects(before),324,118,286,P.ink)
        self:text(after and ((self.pending and self.pending.result and "DESPUÉS / N" or "SIGUIENTE / N")..after.level.."\n"..Upgrades.effects(after)) or "NIVEL MÁXIMO",324,167,286,P.gold)
        local equipped={}
        for _,deck in ipairs({app.session.deck,app.session.combatDeck})do for _,id in ipairs(deck)do equipped[id]=true end end
        self:text(not view.unlocked and "BLOQUEADA" or equipped[card.id] and "DESBLOQUEADA · EQUIPADA" or "DESBLOQUEADA · SIN EQUIPAR",228,200,386,view.unlocked and P.teal or P.muted)
        self:text("Copias: "..view.copies.." / "..view.copiesRequired.." necesarias · Oro: "..view.goldRequired,228,217,386,P.ink)
        self:text((view.socialCost and ("Social: "..view.socialCost.." energía. ") or "")..(view.combatCost and ("Combate: "..view.combatCost.." A / "..view.manaCost.." M / "..view.hpCost.." PV.") or ""),228,240,386,P.teal)
        if nextView and (nextView.manaCost~=view.manaCost or nextView.hpCost~=view.hpCost) then
            self:text("Siguiente: "..nextView.manaCost.." M / "..nextView.hpCost.." PV · máx. "..nextView.perBattle.." usos",228,262,386,P.gold)
        elseif view.perBattle then self:text("Límite: "..view.perBattle.." uso(s) por combate.",228,262,386,P.gold) end
        local ok,reason=Collection.canUpgrade(app.session,card.id)
        if self.pending then
            self:button("Continuar",228,280,386,27,function()
                local completed=self.pending.result~=nil
                self.pending=nil;self.message=nil;self.keyboardFocus=nil
                if completed and returnTo then returnTo() end
            end,self.pending.age<.9)
        else
            self:button(view.level==10 and "Nivel máximo" or "Mejorar",228,280,182,27,function() self:improve() end,not ok)
            self:button("Usar libro (+3 copias)",418,280,196,27,function()
                local receipt,err=Economy.use(app.session,"study_book",card.id,Economy.ensure(app.session).revision)
                self.message=err or "Libro aplicado: +3 copias."
                if receipt then app:save();app:presentRewards(function()app:switch(self)end) end
            end,not view.effect or not view.unlocked or view.level==10 or (Economy.ensure(app.session).items.study_book or 0)<1)
        end
        self:text(self.message or reason or (view.discount and "Receta activa: ahorro del 20%; se consume al mejorar.") or "Los efectos negativos dependen de la situación.",228,315,386,P.muted)
        W.panel(8,342,624,17)
        self:text("Tab y Enter: botones · Las mejoras no cambian los mazos equipados.",18,347,604,P.ink)
    end
    function s:keypressed(key)
        if key=="escape" and not self.pending then if returnTo then returnTo() else app:overlay("deck") end else self:navigate(key) end
    end
    return s
end
return Upgrades
