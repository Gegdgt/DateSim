local Hud={}
local Daily=require("src.systems.daily")
local P=require("src.ui.palette")
local W=require("src.ui.widgets")
function Hud.snapshot(s)
 local cards,missions,today=0,0,{}
 for _,v in pairs(s.unlocked)do if v then cards=cards+1 end end
 for _,v in pairs(s.missions)do if v then missions=missions+1 end end
 for _,id in ipairs(Daily.ensure(s).rewards_granted)do today[id]=true end
 local received=0;for _ in pairs(today)do received=received+1 end
 return {day=s.day,remaining=Daily.remaining(s),favor=s.daily.favor_used and "ocupado" or "libre",gold=s.gold,cards=cards,today=received,missions=missions}
end
function Hud.draw(screen,app,y,compact)
 local v=Hud.snapshot(app.session);W.panel(18,y,604,compact and 13 or 23)
 if compact then
  screen:text("D"..v.day.." · Libres "..v.remaining.."/3 · Encargo "..v.favor.." · Oro "..v.gold.." · Cartas "..v.cards.." (+"..v.today..") · Misiones "..v.missions,24,y+3,592,P.gold)
 else
  screen:text("Libres "..v.remaining.."/3 · Encargo "..v.favor,25,y+8,287,P.gold)
  screen:button("Cartas "..v.cards.." (+"..v.today.." hoy)",313,y+2,175,19,function()app:switch(require("src.screens.daily_status").new(app,"cards"))end)
  screen:button("Misiones "..v.missions,494,y+2,121,19,function()app:switch(require("src.screens.daily_status").new(app,"missions"))end)
 end
end
function Hud.relationship(screen,s,id,x,y,width)
 local r=s.relationships[id];if not r then return end
 local conflict=r.love<0 or r.trust<0
 screen:text("Amor "..r.love.." · Conf. "..r.trust..(r.marriageState=="separated" and " · Separada" or conflict and " · CONFLICTO" or ""),x,y,width,conflict and P.danger or P.teal)
end
function Hud.reward(def)
 return "1 interacción · "..def.reward..". +"..require("src.data.economy").rewards.mission.." oro al cerrar."
end
return Hud
