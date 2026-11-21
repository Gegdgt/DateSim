local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Bars=require("src.ui.relationship_bars")
local Animation=require("src.systems.animation")
local Result=require("src.systems.training_result")
local Dialogue=require("src.data.training_dialogue")
local TrainingScreen={}
local function signed(n) return (n>=0 and "+" or "")..tostring(n) end
function TrainingScreen.new(app)
 local s=Screen.new(app);s.kind="training_result";s.enc=app.session.combat
 app.audio:setContext("training")
 s.result=assert(Result.current(app.session,s.enc),"Resultado de entrenamiento inválido")
 s.data=Dialogue[s.result.id]
 app.session.trainingReview=app.session.trainingReview or {line=1}
 s.page=math.max(1,math.min(#s.data.lines,app.session.trainingReview.line or 1))
 s.bars=Bars.new(app.session,"eris",{reducedMotion=app.options.reducedMotion,audio=app.audio})
 function s:showLine()
  self.line=self.data.lines[self.page]
  self.actor=Animation.actor(self.line.animation or "speaking",{reducedMotion=app.options.reducedMotion})
  if self.line.apply then
   local record,applied=Result.commit(app.session,self.enc)
   if record and applied then
    self.bars:apply(Result.key(app.session.checkpoint),app.session,{love=record.actualLove,trust=record.actualTrust},self.result.reason)
   end
  end
  app.session.trainingReview.line=self.page
  app:save()
 end
 function s:advance()
  if app.session.combat~=self.enc then return false end
  if self.page<#self.data.lines then self.page=self.page+1;self:showLine();return true end
  return app:finishCombat(self.enc)
 end
 function s:update(dt)
  self.bars:update(dt);if self.actor then self.actor:update(dt) end
 end
 function s:draw()
  self:begin();app.resources:background("training")
  love.graphics.setColor(.04,.05,.10,.6);love.graphics.rectangle("fill",0,0,640,360)
  W.panel(8,7,624,39)
  self:text(self.data.title,18,18,604,self.result.winner=="rudeus" and P.gold or P.ink,1,"center")
  W.panel(14,55,314,160)
  local m=self.result.metrics
  local rows={"Ganador: "..(self.result.winner=="rudeus" and "Rudy" or "Eris").." · Turnos: "..m.turns,
   "Ataques: "..m.attacksHit.." acertados / "..m.attacksAttempted.." intentados",
   "Puntos causados: "..m.damageDealt.." · Recibidos: "..m.damageReceived,
   "Bloqueos: "..m.blockedAttacks.." · Puntos evitados: "..(m.blockedDamage or 0),
   "Esquivas efectivas: "..m.successfulDodges.." · Tácticas: "..m.tacticalActions,
   "Turnos sin actuar: "..m.idleTurns,
   "Aperturas desaprovechadas: "..m.missedOpportunities}
  for i,text in ipairs(rows) do self:text(text,24,65+(i-1)*16,294,P.ink) end
  self:text(self.result.reason,24,178,294,P.muted)
  local pose=self.actor and self.actor.value or {x=0,y=0,alpha=1,scale=1}
  local erisActive=self.line.speaker=="eris"
  local ex,ey=470+(erisActive and math.floor(pose.x or 0) or 0),112+(erisActive and math.floor(pose.y or 0) or 0)
  local erisExpression=erisActive and self.line.expression or (self.result.winner=="rudeus" and "worried" or "happy")
  app.resources:portrait("eris",erisExpression,ex,ey,1)
  app.resources:portrait("rudeus",self.line.speaker=="rudeus" and self.line.expression or "neutral",365,112,1)
  self.bars:draw({x=ex,y=ey,w=64,h=64,width=148})
  self:text("Rudy",366,180,62,P.ink,1,"center")
  self:text(self.data.effort.."\nSin heridas letales",346,188,270,P.muted,1,"center")
  W.panel(14,223,612,101)
  self:text(self.line.speaker=="rudeus" and "Pensamientos de Rudy" or "Eris",24,232,580,P.gold)
  self:text(self.line.text,24,249,580,P.ink)
  local record=(app.session.trainingResults or {})[app.session.checkpoint]
  self:text(record and ("Aplicado: "..signed(record.actualLove).." AMOR / "..signed(record.actualTrust).." CONFIANZA")
   or "La relación se actualizará al terminar la reacción de Eris.",24,306,580,record and P.teal or P.muted)
  self:button("Guardar y menú",14,331,161,23,function() app:save();app:menu() end)
  self:text(self.page.." / "..#self.data.lines,194,338,110,P.muted)
  self:button(self.page<#self.data.lines and "Escuchar [Enter]" or "Continuar historia [Enter]",360,331,266,23,function() self:advance() end)
 end
 function s:keypressed(key)
  if self:navigate(key) then return end
  if key=="return" or key=="space" or key=="kpenter" then self:advance()
  elseif key=="escape" then app:overlay("pause") end
 end
 s:showLine()
 return s
end
return TrainingScreen
