local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Collection=require("src.systems.card_collection")
local Economy=require("src.systems.economy")
local Data=require("src.data.economy")
local Shop={}
function Shop.new(app,cardId,returnTo)
    local s=Screen.new(app);s.kind="shop";s.cardId=cardId or "listen"
    s.returnTo=returnTo or function() app:switch(require("src.screens.upgrades").new(app,s.cardId)) end
    function s:purchase(id,revision,quantity)
        local receipt,err=Economy.buy(app.session,id,revision,quantity)
        self.message=err or (Collection.byId[id] and "¡CARTA REPETIDA! +"..(quantity or 1).." copias a la colección." or "Compra guardada en el inventario.")
        if receipt then
            local completed=require("src.systems.daily").completeTradeVisit(app.session)
            app:save()
            if completed then app:resume()
            else app:presentRewards(function()app:switch(self)end) end
        end
    end
    function s:draw()
        self:begin();app.resources:background("library");W.panel(12,12,616,336)
        self:text("TIENDA · ORO: "..app.session.gold,26,25,438,P.gold,2)
        self:button("Volver",516,21,98,26,self.returnTo)
        self:button("Libros",406,21,100,26,function() app:switch(require("src.screens.books").new(app,function()app:switch(self)end)) end)
        local quote,err=Economy.quote(app.session,self.cardId)
        self:text("COPIAS: "..Collection.byId[self.cardId].name,26,67,580,P.teal)
        self:text(quote and (quote.price.." oro/copia · Existencias de hoy: "..quote.stock) or err,26,87,580,P.ink)
        self:button("Comprar 1",26,110,174,28,function() self:purchase(self.cardId,quote.revision,1) end,not quote or quote.reason~=nil)
        self:button("Comprar 5",210,110,174,28,function() self:purchase(self.cardId,quote.revision,5) end,not quote or quote.reason~=nil or quote.stock<5 or app.session.gold<quote.price*5)
        self:button("Comprar 10",394,110,220,28,function() self:purchase(self.cardId,quote.revision,10) end,not quote or quote.reason~=nil or quote.stock<10 or app.session.gold<quote.price*10)
        for i,id in ipairs(Data.itemOrder) do
            local item=Data.items[id];local q=Economy.quote(app.session,id);local y=150+(i-1)*45
            self:text(item.name.." · "..item.price.." oro",26,y,418,P.gold)
            self:text(item.description,26,y+14,418,P.ink)
            self:button("Comprar",468,y,146,29,function() self:purchase(id,q.revision) end,not q or q.reason~=nil)
        end
        self:button("Usar material (+4 energía)",26,289,280,27,function()
            local receipt,reason=Economy.use(app.session,"magic_material",nil,Economy.ensure(app.session).revision)
            self.message=reason or "Material usado.";if receipt then app:save() end
        end,(Economy.ensure(app.session).items.magic_material or 0)<1 or app.session.externalEnergy>=30)
        self:text("Libros: "..(app.session.economy.items.study_book or 0).." · Materiales: "..(app.session.economy.items.magic_material or 0),320,298,292,P.teal)
        self:text(self.message or (quote and quote.reason) or "Los libros se usan sobre la carta elegida en Mejorar cartas.",26,328,588,P.ink)
    end
    function s:keypressed(key)
        if key=="escape" then self.returnTo() else self:navigate(key) end
    end
    return s
end
return Shop
