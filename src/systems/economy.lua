local Data=require("src.data.economy")
local Collection=require("src.systems.card_collection")
local Power=require("src.data.card_progression")
local Economy={}
function Economy.ensure(session)
    session.gold=session.gold or Data.startingGold
    session.economy=session.economy or {revision=0,transactions={},purchases={},items={},nextBattleShield=0}
    return session.economy
end
function Economy.grant(session,amount,id)
    if type(amount)~="number" or amount%1~=0 or amount<0 or amount>Data.maxGold or type(id)~="string" then return nil,"Recompensa de oro inválida." end
    local e=Economy.ensure(session)
    if e.transactions[id] then return 0 end
    local actual=math.min(Data.maxGold-session.gold,math.max(0,amount))
    session.gold=session.gold+actual;e.revision=e.revision+1
    e.transactions[id]={id=id,day=session.day,gold=actual,kind="reward"}
    return actual
end
function Economy.spend(session,amount,revision,kind)
    local e=Economy.ensure(session)
    if revision~=e.revision then return nil,"La operación ya cambió. Revisa de nuevo los costes." end
    if type(amount)~="number" or amount%1~=0 or amount<0 or amount>session.gold then return nil,"Oro insuficiente." end
    local receipt={id="purchase_"..(e.revision+1),day=session.day,gold=-amount,kind=kind}
    session.gold=session.gold-amount;e.revision=e.revision+1;e.transactions[receipt.id]=receipt
    return receipt
end
function Economy.rewardFor(id,effect)
    if effect.gold~=nil then return effect.gold end
    if effect.mission then return Data.rewards.mission end
    if id:match("^day%d_complete$") or id=="campaign_complete" then return Data.rewards.chapter end
    return 0
end
function Economy.quote(session,id)
    local e=Economy.ensure(session)
    local item=Data.items[id]
    local card=Collection.byId[id]
    if not item and not card then return nil,"Artículo desconocido." end
    if card then
        local entry=Collection.ensure(session)[id]
        if not entry.unlocked then return nil,"Solo se venden copias de cartas adquiridas." end
        if entry.level==10 then return nil,"Nivel máximo: no necesitas más copias." end
    end
    local key="day"..session.day.."_"..id
    local stock=(item and item.stock or Data.copyStock)-(e.purchases[key] or 0)
    local price=item and item.price or Power.classes[Collection.class(id)].copyPrice
    local reason
    if session.combat or session.encounter then reason="Termina el encuentro antes de comprar."
    elseif stock<=0 then reason="Existencias de hoy agotadas."
    elseif session.gold<price then reason="Oro insuficiente."
    elseif id=="battle_preparation" and e.nextBattleShield>0 then reason="Ya preparaste el próximo combate." end
    return {id=id,price=price,stock=stock,revision=e.revision,key=key,reason=reason}
end
function Economy.buy(session,id,revision,quantity)
    local quote,err=Economy.quote(session,id)
    if not quote or quote.reason then return nil,err or quote.reason end
    quantity=quantity or 1
    if type(quantity)~="number" or quantity%1~=0 or quantity<1 or quantity>10 or quantity>quote.stock or (Data.items[id] and quantity~=1) then return nil,"Cantidad no disponible." end
    local receipt;receipt,err=Economy.spend(session,quote.price*quantity,revision,"buy_"..id)
    if not receipt then return nil,err end
    local e=session.economy;e.purchases[quote.key]=(e.purchases[quote.key] or 0)+quantity
    if Collection.byId[id] then
        local grant=Collection.grant(session,id,quantity)
        require("src.systems.events").queueCards(session,receipt.id,{grant},"nanahoshi")
    elseif id=="battle_preparation" then e.nextBattleShield=Data.items[id].shield
    else e.items[id]=(e.items[id] or 0)+1 end
    return receipt
end
function Economy.use(session,itemId,cardId,revision)
    local e=Economy.ensure(session);local item=Data.items[itemId]
    if not item or itemId=="battle_preparation" or (e.items[itemId] or 0)<1 then return nil,"No tienes ese objeto." end
    if session.combat or session.encounter then return nil,"Usa los objetos fuera de los encuentros." end
    if itemId=="study_book" then
        local view=Collection.view(session,cardId)
        if not view or not view.unlocked or not view.effect or view.level==10 then return nil,"Elige una carta social adquirida de nivel menor a 10." end
    elseif itemId=="magic_material" and (session.externalEnergy or 0)>=30 then return nil,"La energía externa ya está al máximo." end
    local receipt,err=Economy.spend(session,0,revision,"use_"..itemId)
    if not receipt then return nil,err end
    e.items[itemId]=e.items[itemId]-1
    if itemId=="study_book" then
        local grant=Collection.grant(session,cardId,item.copies)
        require("src.systems.events").queueCards(session,receipt.id,{grant},"nanahoshi")
    elseif itemId=="magic_material" then session.externalEnergy=math.min(30,(session.externalEnergy or 0)+item.energy) end
    return receipt
end
function Economy.buyBook(session,id,revision)
    if session.combat or session.encounter then return nil,"Termina el encuentro antes de comprar." end
    local family=require("src.systems.family").ensure(session)
    if family.books[id] then return nil,"Ya adquiriste ese libro." end
    for _,book in ipairs(require("src.data.books")) do
        if book.id==id then
            local receipt,err=Economy.spend(session,book.price,revision,"book_"..id);if not receipt then return nil,err end
            local effect={};for key,value in pairs(book.effects) do effect[key]=value end
            effect.book=id;effect.text="Libro adquirido: "..book.title
            require("src.systems.events").apply(session,"book_"..id,effect)
            return receipt
        end
    end
    return nil,"Libro desconocido."
end
return Economy
