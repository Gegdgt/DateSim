-- La colección ya está actualizada. Esta pantalla sólo consume el recibo visual.
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local R=require("src.systems.card_rewards")
local View=require("src.ui.reward_presentation")
local Reward={}
function Reward.new(app,returnTo)
 local s=Screen.new(app);s.kind="reward";s.reward=assert(app.session.rewardQueue[1]);s.cards=s.reward.cards;s.age=0
 s.reward.celebration=s.reward.celebration or R.context(s.reward.eventId,s.reward.presenter)
 s.presentation=R.prepare(s.reward);s.page=s.presentation.index
 function s:isNew()return self.reward.newCards[self.cards[self.presentation.index]]==true end
 s.previousMusic=app.audio and app.audio.context;s.returnTo=returnTo
 function s:save()self.page=self.presentation.index;app:save()end
 function s:choose(mode)
  if self.closing or not R.choose(self.reward,mode) then return end
  self.keyboardFocus=nil;self:save()
 end
 function s:nextReaction()
  self.presentation.line=self.presentation.line%#self.reward.celebration.participants+1;self:save()
 end
 function s:skip()
  if self.closing then return end
  R.skip(self.reward);self.keyboardFocus=nil;self:save()
 end
 function s:changeMode()
  if self.closing or R.total(self.reward)<2 then return end
  self.presentation.phase="choice";self.keyboardFocus=nil;self:save()
 end
 function s:turnPage(delta)
  local p=self.presentation;p.page=math.max(1,math.min(R.pages(self.reward),p.page+delta));p.line=1;self:save()
 end
 function s:update(dt)
  self.age=self.age+dt;local p=self.presentation
  if p.phase=="individual" or p.phase=="group" then
   if not p.appeared then p.appeared=true;if app.audio then app.audio:effect("card_draw") end end
   p.elapsed=math.min(R.duration,p.elapsed+dt*(app.options.reducedMotion and 4 or 1))
   if p.elapsed>=.6 and not p.revealed then
    p.revealed=true
    if app.audio then
     app.audio:effect("card_reveal")
     local new=p.phase=="group" and next(self.reward.newCards)~=nil or self.reward.newCards[self.cards[p.index]]
     app.audio:effect(new and "unlock" or "card_duplicate")
     if self.reward.celebration.important then app.audio:setContext("card_reward") end
    end
   end
   if p.phase=="group" and p.elapsed>=R.duration then p.phase="summary";self:save() end
  end
 end
 function s:continue()
  if self.closing then return end
  if not R.advance(self.reward) then self.keyboardFocus=nil;self:save();return end
  self.closing=true
  if app.session.rewardQueue[1]~=self.reward then return end
  table.remove(app.session.rewardQueue,1);app:save()
  if app.audio and app.audio.context=="card_reward" then app.audio:setContext(self.previousMusic) end
  if #app.session.rewardQueue>0 then app:switch(Reward.new(app,self.returnTo))
  elseif self.returnTo then self.returnTo() else app:resume() end
 end
 function s:draw()
  self:begin();local p=self.presentation;app.resources:background(self.reward.celebration.background)
  love.graphics.setColor(.025,.035,.07,.88);love.graphics.rectangle("fill",0,0,640,360)
  W.panel(6,8,628,342)
  local title=p.phase=="summary" and "RECOMPENSAS RECIBIDAS" or p.phase=="individual" and
   (self:isNew() and "¡NUEVA CARTA DESBLOQUEADA!" or "¡CARTA REPETIDA!") or "¡NUEVAS CARTAS OBTENIDAS!"
  self:text(title,16,20,608,P.gold,2,"center")
  self:text(p.phase=="individual" and ("CARTA "..p.index.." DE "..#self.cards) or (R.total(self.reward).." CARTAS · "..#self.cards.." TIPOS"),108,46,312,P.teal,1,"center")
  if p.phase~="choice" and R.total(self.reward)>1 then self:button("MODO [M]",442,42,94,17,function()self:changeMode()end) end
  View.cast(self,self.reward,self.cards[p.phase=="individual" and p.index or (p.page-1)*R.pageSize+1])
  if p.phase=="choice" then
   app.resources:cardBack(280,80,1)
   self:text("Elige cómo ver esta entrega.",114,210,412,P.ink,1,"center")
   self:button("VER UNA POR UNA [1]",126,247,388,29,function()self:choose("individual")end)
   self:button("RECIBIR TODAS [2]",126,285,388,29,function()self:choose("all")end)
  elseif p.phase=="individual" then
   View.single(self,self.reward)
   self:button(p.index<#self.cards and "SIGUIENTE [ENTER]" or "VER RESUMEN [ENTER]",106,321,207,24,function()self:continue()end)
   self:button("RECIBIR RESTANTES [S]",325,321,209,24,function()self:skip()end)
  else
   View.group(self,self.reward,p.phase=="group")
   self:button("< [IZQ]",104,321,79,24,function()self:turnPage(-1)end,p.phase=="group" or p.page==1)
   self:text(p.page.." / "..R.pages(self.reward),193,330,64,P.teal,1,"center")
   self:button("[DER] >",265,321,79,24,function()self:turnPage(1)end,p.phase=="group" or p.page==R.pages(self.reward))
   self:button("CONTINUAR [ENTER]",356,321,180,24,function()self:continue()end)
  end
 end
 function s:keypressed(key)
  if self.closing then return end
  if key=="m" then self:changeMode()
  elseif key=="r" and self.presentation.phase~="choice" then self:nextReaction()
  elseif key=="s" or key=="escape" then self:skip()
  elseif self.presentation.phase=="choice" and (key=="1" or key=="2") then self:choose(key=="1" and "individual" or "all")
  elseif self.presentation.phase=="summary" and (key=="left" or key=="right") then self:turnPage(key=="left" and -1 or 1)
  elseif self:navigate(key) then return
  elseif key=="return" or key=="space" then self:continue() end
 end
 app:save()
 return s
end
return Reward
