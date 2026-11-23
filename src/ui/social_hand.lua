-- Única mano visual social: Nanahoshi, esposas y futuros interlocutores.
-- No sortea: anima los intercambios y el orden persistidos por la lógica.
local Card=require("src.ui.card")
local Data=require("src.data.cards")
local Panel=require("src.ui.widgets")
local P=require("src.ui.palette")
local H={x=143,y=187,spacing=94}
local function lerp(a,b,t)return a+(b-a)*math.max(0,math.min(1,t))end
function H.draw(screen,state,options)
 local app=screen.app;local o=options or {}
 local x,y=o.x or H.x,o.y or H.y
 for i,id in ipairs(state.hand) do
  local cx,cy=x+(i-1)*H.spacing,y+(o.selected==i and -4 or 0)
  local can=o.canPlay(id,i)
  Card.draw(app.resources,Data.byId[id],cx,cy,{selected=o.selected==i,disabled=not can,cost=o.cost(id),
   status=can and ("["..i.."] ELEGIR") or "SIN ENERGÍA"})
  screen.buttons[#screen.buttons+1]={x=cx,y=cy,w=80,h=125,cardIndex=i,
   disabled=o.busy,action=function()o.select(i,id)end}
 end
 Panel.panel(429,138,193,185)
 local id=state.hand[o.selected or 1];if not id then return end
 local card=Data.byId[id];local phrase=o.phrase(id,o.selected or 1)
 screen:text(card.name,439,147,173,P.gold)
 screen:text("Energía "..o.cost(id).." · "..(Data.categories[card.category] or ""),439,178,173,P.teal)
 screen:text("Rudy dirá:",439,211,173,P.gold)
 screen:text(phrase or "Selecciona una carta.",439,228,173,P.ink)
end
function H.duration(state)
 return .55+#(state.shuffleSteps or {})*.12+1.15
end
function H.updateDeal(state,dt,audio,reduced)
 local old=state.dealElapsed or 0
 state.dealElapsed=math.min(H.duration(state),old+dt*(reduced and 2 or 1))
 if old==0 and audio then audio:effect("card_shuffle") end
 local shuffleEnd=.55+#(state.shuffleSteps or {})*.12
 if old<shuffleEnd and state.dealElapsed>=shuffleEnd and audio then audio:effect("card_draw") end
 if state.dealElapsed>=H.duration(state) then state.dealComplete=true;return true end
 return false
end
function H.drawDeal(screen,state,cost)
 local t=state.dealElapsed or 0;local app=screen.app
 Panel.panel(130,135,494,190)
 local steps=state.shuffleSteps or {};local stop=.55+#steps*.12
 screen:text(t<stop and "BARAJAR EL MAZO" or "TOMAR 3 CARTAS",146,145,460,P.gold)
 if t<stop then
  local at=math.max(0,(t-.55)/.12);local step=steps[math.floor(at)+1]
  local source=state.shuffleSource or state.initialOrder or state.hand
  local current={};for i,id in ipairs(source) do current[i]=id end
  for n=1,math.min(#steps,math.floor(at)) do local a=steps[n];current[a.i],current[a.j]=current[a.j],current[a.i] end
  -- Cada reverso conserva la identidad y el índice de su carta real.
  for i,id in ipairs(current) do
   local offset=step and (i==step.i and 1 or i==step.j and -1 or 0) or 0
   local shift=math.sin((at%1)*math.pi)*offset*42
   local x=245+i*5+shift;local y=179-i*2
   app.resources:cardBack(x,y,1)
  end
 else
  for i,id in ipairs(state.hand) do
   local p=math.max(0,math.min(1,(t-stop-(i-1)*.18)/.45))
   local x,y=lerp(36,H.x+(i-1)*H.spacing,p),lerp(207,H.y,p)
   if t-stop>(i-1)*.18+.55 then
    local reveal=math.min(1,(t-stop-(i-1)*.18-.55)/.2)
    love.graphics.push("all");love.graphics.translate(x+40,y);love.graphics.scale(math.max(.04,reveal),1)
    Card.draw(app.resources,Data.byId[id],-40,0,{cost=cost(id)})
    love.graphics.pop()
   else app.resources:cardBack(x,y,1) end
  end
 end
end
function H.drawPlay(screen,id,t,fromIndex,cost)
 if not Data.byId[id] then return end
 local x=lerp(H.x+((fromIndex or 1)-1)*H.spacing,274,t/.45)
 local y=lerp(H.y,145,t/.45)
 if t>.75 then x=lerp(274,36,(t-.75)/.25);y=lerp(145,210,(t-.75)/.25) end
 Card.draw(screen.app.resources,Data.byId[id],x,y,{selected=true,cost=cost})
end
function H.drawRefill(screen,state,cost)
 local i=#state.hand;local id=state.hand[i];if not id then return end
 for index=1,i-1 do
  local kept=state.hand[index]
  Card.draw(screen.app.resources,Data.byId[kept],H.x+(index-1)*H.spacing,H.y,{cost=cost(kept)})
 end
 local t=math.min(1,(state.refillElapsed or 0)/.45)
 local x,y=lerp(36,H.x+(i-1)*H.spacing,t),lerp(210,H.y,t)
 if t<.8 then screen.app.resources:cardBack(x,y,1)
 else Card.draw(screen.app.resources,Data.byId[id],x,y,{cost=cost(id)}) end
end
return H
