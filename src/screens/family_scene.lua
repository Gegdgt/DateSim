local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Config=require("src.data.family")
local Family=require("src.systems.family")
local Scene={}
local function pixel(x,y,w,h,color)
 love.graphics.setColor(color);love.graphics.rectangle("fill",math.floor(x),math.floor(y),w,h)
end
function Scene.new(app)
 local s=Screen.new(app);s.kind="family_scene";s.entry=assert(Family.ensure(app.session).queue[1])
 if s.entry.kind=="departure" then
  app.audio:setContext("separation")
  if s.entry.phase==1 and s.entry.elapsed==0 then app.audio:effect("separation")end
 end
 function s:update(dt) self.entry.elapsed=math.min(20,self.entry.elapsed+dt) end
 function s:advance()
  if self.finished then if app:save() then app:resume() end;return end
  local entry=self.entry;local count=entry.kind=="departure" and 5 or #entry.lines
  if entry.kind=="departure" and (entry.phase==3 or entry.phase==4) and entry.elapsed<1.2 and not app.options.reducedMotion then return end
  if entry.phase<count then entry.phase=entry.phase+1;entry.elapsed=0
  else
   require("src.systems.events").mark(app.session,entry.id.."_presented")
   table.remove(app.session.family.queue,1)
   self.finished=true
  end
  if app:save() then app:resume() end
 end
 function s:draw()
  self:begin();local e=self.entry;local departure=e.kind=="departure";local data=Config.departures[e.character]
  app.resources:background(departure and e.phase>=4 and "forest" or "home")
  W.panel(8,7,624,30);self:text(departure and "UNA DECISIÓN DEFINITIVA" or "VIDA FAMILIAR",18,18,480,P.gold)
  self:text("F5: guardar",530,18,94,P.muted)
  if departure and e.phase==4 then
   local t=app.options.reducedMotion and 1 or math.min(1,e.elapsed/2.5)
   local x=75+math.floor(t*300);local y=160;local brown={.32,.18,.12,1}
   -- Silueta montada dibujada en píxeles; retratos y fondo originales.
   pixel(x,y,95,30,brown);pixel(x+80,y-24,18,45,brown);pixel(x+91,y-26,22,15,brown)
   pixel(x+85,y-34,6,12,brown);pixel(x+5,y+24,9,35,brown);pixel(x+72,y+24,9,35,brown)
   pixel(x-15,y+2,20,7,brown);pixel(x+34,y-5,34,12,{.55,.25,.16,1})
   pixel(x+79,y-23,6,35,{.16,.10,.08,1});pixel(x+100,y-22,3,3,{.05,.04,.03,1})
   pixel(x+18,y+27,7,27,{.24,.13,.09,1});pixel(x+85,y+27,7,27,{.24,.13,.09,1})
   pixel(x+32,y+5,38,7,{.67,.4,.22,1});pixel(x+65,y-6,34,2,{.12,.09,.07,1})
   app.resources:portrait(e.character,"worried",x+24,y-64,1)
   if e.character=="sylphiette" then
    pixel(x+59,y-18,12,17,{.45,.65,.45,1});pixel(x+60,y-27,10,10,{.94,.79,.62,1})
    self:text("Sylphiette parte con su hija.",30,53,570,P.ink)
   end
  else
   app.resources:portrait(e.character,departure and data.expression or e.expression,65,72,2)
   app.resources:portrait("rudeus","worried",450,72,2)
   if departure and e.phase==3 then
    local t=app.options.reducedMotion and 1 or math.min(1,e.elapsed/1.2)
    local x=235+math.floor(t*115);local y=120+math.floor(t*t*85)
    for row=0,7 do for col=0,7 do
     if (row==0 or row==7 or col==0 or col==7) and not ((row==0 or row==7) and (col==0 or col==7)) then pixel(x+col*3,y+row*3,3,3,P.gold) end
    end end
   end
  end
  W.panel(18,224,604,121)
  local text=departure and (data.lines[e.phase] or (e.phase==3 and "El anillo queda frente a Rudy. La decisión no se deshace al recuperar la voz.") or (e.phase==4 and data.exit) or "Separación definitiva registrada. Su retrato permanece en gris; ya no participará como esposa ni compañera de combate.") or e.lines[e.phase]
  self:text(require("src.data.characters").byId[e.character].shortName,30,236,570,P.gold)
  self:text(text,30,257,570,P.ink)
  self:button("Continuar",430,310,178,25,function() self:advance() end,departure and (e.phase==3 or e.phase==4) and e.elapsed<1.2 and not app.options.reducedMotion)
  if require("src.systems.daily").atAgenda(app.session)then require("src.ui.daily_hud").draw(self,app,347,true)end
 end
 function s:keypressed(key) if key=="return" or key=="space" then self:advance() elseif key=="f5" then app:save() else self:navigate(key) end end
 return s
end
return Scene
