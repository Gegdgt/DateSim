local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Config=require("src.data.family")
local Family=require("src.systems.family")
local Scene={}
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
   local x=75+math.floor(t*300);local y=124
   local frame=app.options.reducedMotion and 0 or math.floor(e.elapsed/.14)%4
   self.horseQuads=self.horseQuads or {}
   self.horseQuads[frame]=self.horseQuads[frame] or love.graphics.newQuad(frame*48,0,48,32,192,32)
   love.graphics.setColor(1,1,1)
   love.graphics.draw(app.resources:getExploration("animations","horseExit"),self.horseQuads[frame],x,y,0,3,3)
   self.riderQuad=self.riderQuad or love.graphics.newQuad(0,64,24,32,96,128)
   love.graphics.draw(app.resources:getExploration("overworld",e.character),self.riderQuad,x+32,y-31,0,2,2)
   if e.character=="sylphiette" then
    self.lucyQuad=self.lucyQuad or love.graphics.newQuad(0,0,16,16,32,16)
    love.graphics.draw(app.resources:getExploration("npcIdle","lucy"),self.lucyQuad,x+62,y-8,0,2,2)
    self:text("Sylphie parte con Lucy.",30,53,570,P.ink)
   end
  else
   app.resources:portrait(e.character,departure and data.expression or e.expression,65,72,2)
   app.resources:portrait("rudeus","worried",450,72,2)
   if departure and e.phase==3 then
    local t=app.options.reducedMotion and 1 or math.min(1,e.elapsed/1.2)
    local x=235+math.floor(t*115);local y=120+math.floor(t*t*85)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(app.resources:getExploration("items","14_anillo_matrimonio"),x,y,0,3,3)
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
