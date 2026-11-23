local R=require("src.systems.card_rewards")
local Card=require("src.ui.card")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Characters=require("src.data.characters")
local View={}
local spots={{18,72},{558,72},{18,190},{558,190}}
local labels={social="SOCIAL",magic="MAGIA",combat="COMBATE"}
function View.card(screen,id,x,y,progress)
 local resources=screen.app.resources
 progress=math.max(0,math.min(1,progress))
 if progress<.45 then resources:cardBack(x,y+math.floor((1-progress/.45)*12),1)
 elseif progress<1 then
  -- Recorte entero: conserva los píxeles del PNG sin estirar la ilustración.
  local width=math.max(2,2*math.floor(40*(progress-.45)/.55))
  love.graphics.push("all");love.graphics.setScissor(x+40-width/2,y,width,112)
  Card.draw(resources,require("src.systems.card_collection").byId[id],x,y);love.graphics.pop()
 else Card.draw(resources,require("src.systems.card_collection").byId[id],x,y) end
end
function View.cast(screen,reward,id)
 local p=reward.presentation;local settled=p.phase=="summary" or (p.phase~="choice" and p.elapsed>=.6)
 for i,actor in ipairs(reward.celebration.participants) do
  local x,y=unpack(spots[i]);local reaction=R.reaction(screen.app.session,reward,id,actor)
  local expression=settled and reaction.expression or "neutral"
  local hop=settled and not screen.app.options.reducedMotion and math.floor(math.max(0,math.sin((screen.age or 0)*5+i))*3) or 0
  if settled and p.line==i then W.panel(x-4,y-5,72,77) end
  screen.app.resources:portrait(actor,expression,x,y-hop,1)
  screen:text(Characters.byId[actor].shortName,x-10,y+70,84,P.teal,1,"center")
  if settled and not screen.app.options.reducedMotion then
   love.graphics.setColor(P.gold);local offset=math.floor((screen.age or 0)*9+i*3)%20
   love.graphics.rectangle("fill",x+3,y+7+offset,2,2);love.graphics.rectangle("fill",x+58,y+24-offset,2,2)
  end
 end
end
function View.reaction(screen,reward,id)
 local p=reward.presentation;W.panel(104,249,432,63)
 local actor=reward.celebration.participants[p.line or 1]
 local line=R.reaction(screen.app.session,reward,id,actor)
 screen:text(Characters.byId[actor].shortName..(line.delivery=="thought" and " · PENSAMIENTO" or ""),114,258,312,P.gold)
 screen:text(line.text,114,273,410,P.ink)
 screen:button("R >",482,253,46,16,function()screen:nextReaction()end)
end
function View.single(screen,reward)
 local p=reward.presentation;local id=reward.cards[p.index];local v=R.view(screen.app.session,reward,id)
 View.card(screen,id,116,72,screen.app.options.reducedMotion and 1 or p.elapsed/.8)
 if p.elapsed<.6 and not screen.app.options.reducedMotion then return end
 screen:text(v.card.name,212,66,316,P.gold)
 screen:text(v.new and "¡NUEVA CARTA DESBLOQUEADA!" or "¡CARTA REPETIDA!",212,93,316,P.teal)
 screen:text(labels[v.category].." · "..(require("src.data.cards").categories[v.card.category] or "Técnica"),212,111,316,P.muted)
 screen:text("Nivel actual: "..v.level.." · Recibidas: "..v.count,212,129,316,P.ink)
 screen:text("+"..v.duplicates.." copias · Disponibles para mejorar: "..v.copies,212,145,316,P.teal)
 screen:text(v.description,212,165,316,P.ink)
 if v.category=="magic" and screen.app.session.curse.manaBlocked then screen:text("Maná natural bloqueado: usa energía externa.",108,228,424,P.gold) end
 if p.elapsed>=.6 or screen.app.options.reducedMotion then View.reaction(screen,reward,id) end
end
function View.group(screen,reward,animated)
 local p=reward.presentation;local start=(p.page-1)*R.pageSize+1
 for i=start,math.min(#reward.cards,start+R.pageSize-1) do
  local slot=i-start;local id=reward.cards[i];local v=R.view(screen.app.session,reward,id);local x=112+slot*104
  View.card(screen,id,x,64,animated and not screen.app.options.reducedMotion and (p.elapsed-slot*.09)/.7 or 1)
  if not animated or p.elapsed>=.95 or screen.app.options.reducedMotion then
   screen:text(v.new and "NUEVA" or "REPETIDA",x-7,178,94,P.teal,1,"center")
   screen:text(v.card.name,x-7,190,94,P.gold,1,"center")
   screen:text("x"..v.count.." · NIV "..v.level,x-7,230,94,P.ink,1,"center")
  end
 end
 if not animated or p.elapsed>=.95 or screen.app.options.reducedMotion then View.reaction(screen,reward,reward.cards[start]) end
end
return View
