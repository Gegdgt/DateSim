local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local CardView=require("src.ui.card")
local Collection=require("src.systems.card_collection")
local Finale=require("src.systems.finale")
local Effects=require("src.screens.upgrades").effects
local Reward={}
function Reward.new(app)
 local s=Screen.new(app);s.kind="orsted_reward";s.reward=Finale.ensure(app.session)
 s.category=s.reward.pending and s.reward.pending.kind or (s.reward.choices.combat and "social" or "combat")
 s.page=1;s.selected=nil
 function s:refresh()
  self.ids=Finale.options(app.session,self.category)
  self.page=math.max(1,math.min(self.page,math.max(1,math.ceil(#self.ids/7))))
  self.selected=self.ids[(self.page-1)*7+1]
 end
 function s:choose()
  if self.reward.pending then return end
  local result,err=Finale.choose(app.session,self.category,self.selected,self.reward.revision)
  self.message=err
  if result then self.keyboardFocus=nil;app:save() end
 end
 function s:acknowledge()
  local pending=self.reward.pending
  if not pending or pending.elapsed<(app.options.reducedMotion and .2 or 1.2) then return end
  Finale.acknowledge(app.session);app:save()
  self.category=self.reward.choices.combat and "social" or "combat";self.page=1;self:refresh();self.keyboardFocus=nil
 end
 function s:update(dt)
  local pending=self.reward.pending
  if not pending then return end
  local before=pending.elapsed;pending.elapsed=math.min(2,before+dt)
  if before<.45 and pending.elapsed>=.45 then app.audio:effect("upgrade") end
 end
 function s:draw()
  self:begin();app.resources:background("training");W.panel(8,7,624,338)
  self:text("LA AYUDA DE ORSTED",24,20,550,P.gold,2)
  self:text("Dos cartas distintas a nivel 10. Sin oro, copias ni recetas.",24,48,590,P.teal)
  local pending=self.reward.pending
  self:button("Combate"..(self.reward.choices.combat and " [LISTO]" or ""),24,69,190,27,function()self.category="combat";self.page=1;self:refresh()end,pending~=nil,self.category=="combat")
  self:button("Social"..(self.reward.choices.social and " [LISTO]" or ""),224,69,190,27,function()self.category="social";self.page=1;self:refresh()end,pending~=nil,self.category=="social")
  app.resources:portraitSmall("orsted","neutral",558,20)
  for row=1,7 do
   local id=self.ids[(self.page-1)*7+row]
   if id then
    local card=Collection.byId[id]
    self:button("N"..Collection.level(app.session,id).." "..(card.shortName or card.name),24,107+(row-1)*25,190,24,function()self.selected=id;self.message=nil end,pending~=nil,id==self.selected)
   end
  end
  local pages=math.max(1,math.ceil(#self.ids/7))
  self:button("<",24,290,44,24,function()self.page=self.page-1;self:refresh()end,pending~=nil or self.page==1)
  self:text(self.page.." / "..pages,81,298,65,P.ink)
  self:button(">",170,290,44,24,function()self.page=self.page+1;self:refresh()end,pending~=nil or self.page==pages)
  local id=pending and pending.id or self.selected
  if id then
   local card=Collection.byId[id];local age=pending and pending.elapsed or 0
   local from=Collection.view(app.session,id,pending and pending.before or Collection.level(app.session,id))
   local to=Collection.view(app.session,id,10)
   local elevation=pending and (app.options.reducedMotion and 0 or math.floor(12*math.min(1,age/.3))) or 0
   CardView.draw(app.resources,card,232,116-elevation)
   if pending and age>.2 and age<.9 and not app.options.reducedMotion then
    love.graphics.setColor(1,.86,.48,.9)
    for i=0,11 do local x=226+(i%4)*26;local y=104+math.floor(i/4)*56;love.graphics.rectangle("fill",x,y,4,4)end
   end
   self:text(card.name,326,110,281,P.gold)
   self:text("ANTES / NIVEL "..from.level.."\n"..Effects(from),326,137,281,P.ink)
   self:text((pending and age>=.45 and "¡NIVEL 10!" or "DESPUÉS / NIVEL 10").."\n"..Effects(to),326,183,281,P.teal)
   self:text("Copias conservadas: "..to.copies.." · Oro: "..app.session.gold,232,239,376,P.ink)
   local owner=card.conditions and card.conditions.character
   self:text(owner and ("Conserva su requisito: "..owner.." debe estar disponible.") or "Tu carta equipada y el resto de la colección se conservan.",232,260,376,P.muted)
   if pending then
    self:button("Continuar presentación",232,290,376,26,function()self:acknowledge()end,age<(app.options.reducedMotion and .2 or 1.2))
   elseif Finale.rewardComplete(app.session) then
    self:button("Continuar historia",232,290,376,26,function()app:next()end)
   else
    local ok,why=Finale.canChoose(app.session,self.category,id)
    self:button("Elegir y maximizar",232,290,376,26,function()self:choose()end,not ok)
    self:text(self.message or why or "Elige con calma: cada categoría tiene una sola mejora.",24,326,584,P.muted)
   end
  end
 end
 function s:keypressed(key)self:navigate(key)end
 s:refresh()
 return s
end
return Reward
