local Screen=require("src.ui.screen")
local Panel=require("src.ui.widgets")
local P=require("src.ui.palette")
local W=require("src.systems.wife_activities")
local Daily=require("src.systems.daily")
local Cards=require("src.data.cards")
local Bank=W.bank
local Economy=require("src.systems.economy")
local Bars=require("src.ui.relationship_bars")
local Hand=require("src.ui.social_hand")
local Names={eris="Eris",roxy="Roxy",sylphiette="Sylphie"}
local View={}
function View.new(app,wife)
 local s=Screen.new(app);s.kind="wife_activities";s.clock=0;s.selectedIndex=1
 local session=app.session;local state=W.ensure(session)
 local active=W.current(session);local review=state.review
 s.wife=wife or Bank.byId[(active or review).id].character
 s.mode=active and active.phase or review and "review" or "offers"
 s.world=session.exploration and require("src.screens.exploration").new(app)
 if not active and not review then
  if not W.nearWife(session,s.wife) then s.mode="unavailable"
  else s.offers=W.offers(session,s.wife);app:save() end
 end
 s.bars=Bars.new(session,s.wife,{reducedMotion=app.options.reducedMotion,audio=app.audio})
 if review and review.battleDelta and not review.presented then
  local rel=session.relationships[s.wife]
  s.bars=Bars.new({relationships={[s.wife]={love=rel.love-review.battleDelta.love,trust=rel.trust-review.battleDelta.trust}},events={}},s.wife,app.options)
  s.bars:apply(review.instance.."_duel",session)
  review.presented=true;state.history[review.instance].presented=true;app:save()
 end
 function s:back()
  if W.current(session) then app:notify("Termina la conversación con P. Puedes guardar con F5.");return end
  local reviewing=state.review~=nil
  local night=reviewing and W.closeReview(session)
  app:save()
  if reviewing then app:resume() elseif session.exploration then app:explore() else app:resume() end
  if night then app:notify("La jornada está terminando. Las chicas han regresado a sus habitaciones.") end
 end
 function s:run(ok,err)
  if not ok then self.message=err;return end
  if app:save() then app:resume() end
 end
 function s:inspect(def)
  -- Elegir una respuesta confirma la actividad.
  self:run(W.start(session,def.id,Economy.ensure(session).revision))
 end
 function s:nextPhase()
  local a=W.current(session)
  if a and a.phase=="intro" then a.phase="deal";self.mode="deal";app:save()
  elseif a and a.phase=="reply" then self:run(W.execute(session))
  elseif state.review then self:back() end
 end
 function s:selectCard(id,index)
  local a=W.current(session);if not a or a.phase~="hand" then return end
  self.selectedCard=id;self.selectedIndex=index or self.selectedIndex;self.mode="preview";self.keyboardFocus=nil
  app.audio:effect("card_select")
 end
 function s:confirmCard()
  if self.mode~="preview" then return end
  local a=W.current(session);local ok,err=W.choose(session,self.selectedCard)
  if not ok then self.message=err;return end
  a.playIndex=self.selectedIndex;a.playElapsed=0;self.mode="playing";self.message=nil
  app.audio:effect("card_play");app.audio:effect("enchanted_voice");app:save()
 end
 function s:update(dt)
  self.clock=self.clock+dt;self.bars:update(dt);self.reactionAge=(self.reactionAge or 0)+dt
  local a=W.current(session)
  if a and a.phase=="deal" and Hand.updateDeal(a,dt,app.audio,app.options.reducedMotion) then
   a.phase="hand";self.mode="hand";app:save()
  elseif a and a.phase=="refill" then
   if (a.refillElapsed or 0)==0 then app.audio:effect("card_draw") end
   a.refillElapsed=(a.refillElapsed or 0)+dt*(app.options.reducedMotion and 2 or 1)
   if a.refillElapsed>=.45 then a.phase="hand";self.mode="hand";app:save() end
  elseif a and a.phase=="playing" then
   a.playElapsed=(a.playElapsed or 0)+dt*(app.options.reducedMotion and 2 or 1)
   if a.playElapsed>=1 then
    local response,key=W.react(session)
    if response then
     self.bars:apply(key,session);self.mode="reply";self.reactionAge=0;self.keyboardFocus=nil
     app.audio:effect("card_discard");app:save()
    else self.message=key end
   end
  end
  W.tickChallenge(session,dt)
 end
 function s:drawMenu()
  Panel.panel(10,212,620,140)
  app.resources:portrait(self.wife,"happy",22,218,1)
  self:text(Names[self.wife],102,224,500,P.gold)
  self:text("¡Rudy! ¿Qué quieres hacer hoy?",102,245,500,P.ink)
  for i,def in ipairs(self.offers or {}) do
   self:button(i..". "..def.offer,18+(i-1)*204,282,196,44,function()self:inspect(def)end,false,self.selectedIndex==i)
  end
  if #(self.offers or {})==0 then self:text("No hay actividades disponibles. Revisa los requisitos y equipa cinco cartas sociales compatibles.",102,282,490,P.ink) end
  self:text("1–3 / flechas: elegir · ENTER: confirmar · ESC: despedirse",22,338,590,P.muted)
 end
 function s:draw()
  self:begin();local a=W.current(session);local r=state.review
  local def=a and Bank.byId[a.id] or r and Bank.byId[r.id]
  if self.world then self.world:drawWorld() else app.resources:background(def and def.background or "home") end
  Panel.panel(8,7,624,29)
  local day=app.demoMenu and ("Día "..session.day.." · ") or ""
  self:text(day..Names[self.wife].." · "..Daily.remaining(session).."/3 interacciones disponibles",19,17,606,P.gold)
  if self.mode=="offers" then self:drawMenu();return end
  if self.mode=="unavailable" then
   Panel.panel(20,235,600,104);self:text("Busca a "..Names[self.wife].." para conversar.",35,254,565,P.ink)
   self:button("Volver al mapa",35,290,565,30,function()self:back()end);return
  end
  local response=a and a.choice and W.response(session,a.choice)
  local expression=(self.mode=="reply" and response and response.expression) or r and r.expression or "neutral"
  Panel.panel(18,45,110,275)
  app.resources:portrait(self.wife,expression,40,94,1)
  self.bars:draw({x=40,y=94,w=64,h=64,width=110})
  self:text("ENERGÍA SOCIAL",27,173,94,P.muted)
  self:text(a and ((a.energy or 6).." / "..(a.maxEnergy or 6)) or "Cierre",28,194,90,P.teal)
  self:text(a and ("CARTAS USADAS\n"..#(a.log or {}).." / 3") or "ACTIVIDAD\nCOMPLETADA",28,224,90,P.gold)
  if a then self:text("Mazo "..#(a.drawPile or {}).."\nDescarte "..#(a.discard or {}),28,270,90,P.muted) end
  Panel.panel(135,45,487,82)
  self:text(def.title,147,54,462,P.gold)
  self:text(self.mode=="intro" and def.intro or self.mode=="review" and "ACTIVIDAD COMPLETADA" or W.question(session),147,76,462,P.ink)
  if self.mode=="hand" or self.mode=="preview" then
   Panel.panel(135,138,289,25)
   self:text("MANO · SELECCIONA Y CONFIRMA LA FRASE",143,145,278,P.muted)
   Hand.draw(self,a,{selected=self.selectedIndex,
    cost=function(id)return W.cost(session,id)end,
    canPlay=function(id)return W.canPlay(session,id)end,
    phrase=function(id)return W.response(session,id).rudy end,
    select=function(i,id)self:selectCard(id,i)end})
   self:button("Terminar [P]",18,332,195,23,function()self:run(W.endConversation(session))end)
   if self.mode=="preview" then
    self:button("Cancelar [ESC]",219,332,134,23,function()self.mode="hand"end)
    self:button("Decir la frase [ENTER]",359,332,263,23,function()self:confirmCard()end,not W.canPlay(session,self.selectedCard))
   else self:text("1–3 / flechas: consultar · ENTER: elegir",224,339,394,P.muted) end
  elseif self.mode=="deal" then Hand.drawDeal(self,a,function(id)return W.cost(session,id)end)
  elseif self.mode=="refill" then
   Panel.panel(135,138,289,25)
   self:text("TOMAR UNA CARTA",143,145,278,P.gold)
   Hand.drawRefill(self,a,function(id)return W.cost(session,id)end)
  elseif self.mode=="playing" then
   Hand.drawPlay(self,a.choice,a.playElapsed or 0,a.playIndex,W.cost(session,a.choice))
   Panel.panel(429,138,193,185)
   self:text("Rudy:",439,151,173,P.gold)
   self:text(response.rudy,439,178,173,P.ink)
   self:text("La carta transmite la voz de Rudy...",147,332,462,P.teal)
  elseif self.mode=="intro" then
   Panel.panel(135,138,487,185)
   self:text(Names[self.wife]..": "..def.question,150,157,455,P.ink)
   if #(a.excludedCards or {})>0 then
    local names={};for _,id in ipairs(a.excludedCards) do names[#names+1]=Cards.byId[id].name end
    self:text("Cartas no disponibles aquí: "..table.concat(names,", "),150,209,455,P.muted)
   end
   self:button("Preparar las cartas",150,275,456,34,function()self:nextPhase()end)
  elseif self.mode=="reply" then
   Panel.panel(135,138,487,185)
   self:text("Rudy: "..response.rudy,147,150,462,P.ink)
   self:text(Names[self.wife]..": "..response.reply,147,207,462,P.gold)
   local delta=a.log and a.log[#a.log] and a.log[#a.log].delta or a.delta
   self:text(string.format("%+d AMOR · %+d CONFIANZA",delta.love,delta.trust),147,279,462,P.teal)
   self:button("Continuar [ENTER]",147,332,475,23,function()self:nextPhase()end)
  elseif self.mode=="review" then
   Panel.panel(135,138,487,185)
   self:text(r.reply,147,148,462,P.ink)
   self:text(r.continuation,147,196,462,P.gold)
   local rewards={"Oro recibido: "..r.gold}
   for id,n in pairs(r.items) do rewards[#rewards+1]=require("src.data.economy").items[id].name.." x"..n end
   for id,n in pairs(r.copies) do rewards[#rewards+1]=require("src.systems.card_collection").byId[id].name.." x"..n end
   if r.purchase then rewards[#rewards+1]=r.purchase.title end
   self:text(table.concat(rewards," · "),147,248,462,P.teal)
   self:text(string.format("Total: %+d amor / %+d confianza",r.delta.love,r.delta.trust),147,296,462,P.teal)
   local nextLabel=app.demoMenu and (#session.rewardQueue>0 and "Ver recompensa" or "Volver al menú") or "Volver a explorar"
   self:button(nextLabel,147,332,475,23,function()self:back()end)
  elseif self.mode=="service" or self.mode=="purchase" then
   Panel.panel(135,45,487,285);self:text(def.title,147,55,462,P.gold)
   if def.service=="upgrade" then
    self:text("Elige una carta. Verás el coste exacto en copias y oro antes de mejorarla.",183,104,418,P.ink)
    self:button("Abrir mejoras de cartas",183,190,420,35,function()
     app:switch(require("src.screens.upgrades").new(app,nil,function()app:resume()end))
    end)
   elseif self.mode=="purchase" then
    self:text("CONFIRMAR COMPRA",183,97,418,P.gold)
    self:text(self.book.title.."\n"..self.book.description,183,126,418,P.ink)
    self:text("Precio: "..self.book.price.." oro. Se descontará al confirmar.",183,224,418,P.teal)
    self:button("Pagar y comprar",183,274,252,29,function()
     if self.book.item then self:run(W.purchaseItem(session,self.book.id,self.purchaseRevision))
     else self:run(W.purchaseBook(session,self.book.id,self.purchaseRevision)) end
    end)
    self:button("Cancelar",447,274,156,29,function()self.mode="service"end)
   else
    self:text("Consulta el precio y confirma antes de comprar.",183,91,418,P.ink)
    local row=0
    for _,book in ipairs(require("src.data.books")) do
     if def.service~="rare_books" or book.id~="water_notes" then
      row=row+1
      self:button(book.title.." · "..book.price.." oro",183,126+(row-1)*45,420,37,function()
       self.book=book;self.purchaseRevision=Economy.ensure(session).revision;self.mode="purchase"
      end,require("src.systems.family").ensure(session).books[book.id] or session.gold<book.price)
     end
    end
    local quote=Economy.quote(session,"magic_material")
    self:button("Material mágico · 20 oro",183,261,420,26,function()
     self.book={id="magic_material",title="Material mágico",description="Una muestra para alimentar artefactos; se guarda en el inventario.",price=quote.price,item=true}
     self.purchaseRevision=quote.revision;self.mode="purchase"
    end,not quote or quote.reason~=nil)
   end
   if self.mode=="service" then self:button("Terminar sin comprar ni mejorar",183,297,420,30,function()self:run(W.finish(session,"no_purchase"))end) end
  elseif self.mode=="challenge" then
   Panel.panel(135,45,487,285);self:text(def.title,147,55,462,P.gold)
   self:text("Pulsa ESPACIO cuando la marca esté dentro de la zona verde. Acierta 2 de 3 intentos.",183,100,418,P.ink)
   local x,y,width=194,198,396
   love.graphics.setColor(.16,.2,.25);love.graphics.rectangle("fill",x,y,width,26)
   love.graphics.setColor(.3,.8,.54);love.graphics.rectangle("fill",math.floor(x+width*.38),y,math.floor(width*.24),26)
   love.graphics.setColor(1,.88,.4);love.graphics.rectangle("fill",math.floor(x+(a.challenge.elapsed%1.6)/1.6*width),y-6,3,38)
   self:text("Intento "..a.challenge.step.."/3 · El progreso se guarda.",183,248,418,P.teal)
   self:button("Marcar el ritmo [ESPACIO]",183,297,420,30,function()self:run(W.hit(session))end)
  end
  if self.message then Panel.panel(135,111,487,26);self:text(self.message,143,116,470,P.danger) end
 end
 function s:keypressed(key)
  if self.mode=="deal" or self.mode=="playing" or self.mode=="refill" then return end
  if self.mode=="offers" then
   if key=="escape" then self:back();return end
   local n=tonumber(key)
   if n and self.offers[n] then self.selectedIndex=n
   elseif key=="left" or key=="up" then self.selectedIndex=(self.selectedIndex-2)%math.max(1,#self.offers)+1
   elseif key=="right" or key=="down" or key=="tab" then self.selectedIndex=self.selectedIndex%math.max(1,#self.offers)+1
   elseif key=="return" or key=="kpenter" or key=="space" then
    if self.offers[self.selectedIndex] then self:inspect(self.offers[self.selectedIndex]) end
   end
   return
  end
  if key=="escape" then
   if self.mode=="preview" then self.mode="hand"
   elseif self.mode=="purchase" then self.mode="service"
   else self:back() end
  elseif self.mode=="challenge" and key=="space" then self:run(W.hit(session))
  elseif self.mode=="hand" or self.mode=="preview" then
   local a=W.current(session);local n=tonumber(key)
   if key=="p" then self:run(W.endConversation(session))
   elseif n and a.hand[n] then self:selectCard(a.hand[n],n)
   elseif key=="left" or key=="right" or key=="up" or key=="down" then
    n=(self.selectedIndex-1+((key=="left" or key=="up") and -1 or 1))%math.max(1,#a.hand)+1
    if a.hand[n] then self:selectCard(a.hand[n],n) end
   elseif key=="return" or key=="kpenter" then
    if self.mode=="preview" then self:confirmCard() elseif a.hand[self.selectedIndex] then self:selectCard(a.hand[self.selectedIndex],self.selectedIndex) end
   else self:navigate(key) end
  elseif (key=="return" or key=="kpenter") and (self.mode=="intro" or self.mode=="reply" or self.mode=="review") then self:nextPhase()
  else self:navigate(key) end
 end
 return s
end
return View
