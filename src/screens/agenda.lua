local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Daily=require("src.systems.daily")
local Catalog=require("src.data.activities")
local Family=require("src.systems.family")
local Budget=require("src.systems.relationship_budget")
local Progression=require("src.systems.progression")
local Hud=require("src.ui.daily_hud")
local Bars=require("src.ui.relationship_bars")
local Agenda={}
function Agenda.new(app)
 local s=Screen.new(app);s.kind="agenda";s.tab="sylphiette";s.page=1;s.provider="cliff"
 local pending=Daily.ensure(app.session).active_activity
 if pending and Catalog.byId[pending.id]then s.tab=Catalog.byId[pending.id].character end
 s.relationshipBars={}
 for _,id in ipairs({"sylphiette","roxy","eris"})do s.relationshipBars[id]=Bars.new(app.session,id,{reducedMotion=app.options.reducedMotion})end
 function s:update(dt)for _,b in pairs(self.relationshipBars)do b:sync(app.session);b:update(dt)end end
 local function commit(ok,err)
  if not ok then app:notify(err);return end
  if app:save() then app:resume() end
 end
 function s:draw()
  self:begin();local session=app.session;local d=Daily.ensure(session)
  local active=d.active_activity;local activity=active and Catalog.byId[active.id]
  app.resources:background(activity and not self.inspect and activity.background or "home")
  self:header("DÍA "..session.day.." / AGENDA · ORO "..session.gold)
  Hud.draw(self,app,43)
  for i,id in ipairs({"sylphiette","roxy","eris","favors"})do
   self:button(({sylphiette="Sylphiette",roxy="Roxy",eris="Eris",favors="Encargos"})[id],18+(i-1)*120,72,114,25,function()self.tab=id;self.page=1;self.inspect=active~=nil;self.keyboardFocus=nil end,false,self.tab==id)
  end
  self:button("Ayer",498,72,124,25,function()app:switch(require("src.screens.day_report").new(app,session.daily_history[tostring(session.day-1)],function()app:resume()end))end,not session.daily_history[tostring(session.day-1)])
  local function footer()
   local finalLock=session.day==7 and not d.activities_locked
   self:button(active and "Volver a la actividad" or finalLock and "Cerrar tiempo libre e ir a la historia" or "Continuar historia",18,311,330,27,function()
    if active then self.inspect=nil else commit(Progression.continueStory(session))end
   end,not active and Daily.storyComplete(session))
   self:button("Finalizar día",358,311,264,27,function()app:endDay()end,active~=nil or not Daily.storyComplete(session))
   W.panel(18,341,604,17)
   self:text(active and "Termina la actividad reservada antes de dormir. Puedes consultar los tres personajes." or "Puedes dormir sin agotar los tres espacios. Sin visita: -20 amor y -20 confianza.",24,345,592,P.muted)
  end
  footer()
  if self.confirmHelp then
   self.buttons={}
   W.panel(65,100,510,206)
   self:text("AYUDAR CONSUME UNA INTERACCIÓN",85,110,470,P.gold)
   self:text("El encargo se entregará hoy. Gastarás uno de los tres espacios que podrías dedicar a tus esposas. Ayudar a Cliff o Zanoba no cuenta como visita matrimonial.",85,133,470,P.ink)
   self:text("Sin ninguna visita, cada esposa pierde 20 de amor y 20 de confianza al cerrar el día.",85,195,470,P.danger)
   self:button("Confirmar: gastar 1 espacio",85,257,300,34,function()
    local request=self.confirmHelp;self.confirmHelp=nil
    if request.instance then commit(Daily.accelerateFavor(session,request.instance))
    else commit(Daily.requestFavor(session,request.id,request.provider,true)) end
   end,Daily.remaining(session)<1)
   self:button("Cancelar",400,257,152,34,function()self.confirmHelp=nil end)
   return
  end
  if d.active_activity and not self.inspect then
   local active=d.active_activity;local def=Catalog.byId[active.id]
   W.panel(18,104,604,200)
   app.resources:portrait(def.character,(active.visit or 1)==3 and "worried" or "happy",42,164,2)
   self.relationshipBars[def.character]:draw({x=42,y=164,w=128,h=128})
   self:text(def.title,190,113,410,P.gold)
   self:text(def.description,190,133,408,P.ink)
   self:text("Visita "..(active.visit or 1).." de hoy · quedan "..Daily.remaining(session).."/3",190,167,408,P.teal)
   self:text(Hud.reward(def),190,183,408,P.gold)
   for i,choice in ipairs(def.choices) do
    local delta=Budget.preview(session,def.character,choice.effects)
    local label=choice.label..(def.battle and "" or " ("..string.format("%+d amor / %+d conf.",delta.love,delta.trust)..")")
    self:button(label,190,225+(i-1)*39,410,32,function()commit(Daily.resolveActivity(session,choice.id))end)
   end
   if def.books then self:button("Entrar a la librería",190,264,410,32,function()app:switch(require("src.screens.books").new(app))end) end
   return
  end
  W.panel(18,101,604,23)
  Hud.relationship(self,session,self.tab,24,108,418)
  local list={}
  if self.tab=="favors" then
   for _,def in ipairs(Catalog.favors) do for _,provider in ipairs(def.providers) do if provider==self.provider then list[#list+1]=def end end end
  else for _,def in ipairs(Catalog.list) do if def.character==self.tab then list[#list+1]=def end end end
  local perPage=self.tab=="favors" and 2 or 3;local pages=math.max(1,math.ceil(#list/perPage))
  self:button("<",450,101,35,22,function()self.page=self.page-1 end,self.page==1)
  self:text(self.page.."/"..pages,492,108,78,P.ink)
  self:button(">",582,101,40,22,function()self.page=self.page+1 end,self.page==pages)
  if self.tab=="favors" then
   self:button("Cliff",18,128,130,24,function()self.provider="cliff";self.page=1 end,false,self.provider=="cliff")
   self:button("Zanoba",156,128,130,24,function()self.provider="zanoba";self.page=1 end,false,self.provider=="zanoba")
   W.panel(294,128,328,24)
   self:text("Mañana al comenzar · Ayudar: 1 espacio",304,135,312,P.muted)
   for row=1,2 do
    local def=list[(self.page-1)*2+row]
    if def then
     local y=157+(row-1)*59;W.panel(18,y,604,54)
     self:text(def.title,28,y+7,400,P.gold);self:text(def.reward.." · +"..require("src.data.economy").rewards.mission.." oro al cierre",28,y+23,400,P.ink)
     local accelerated=session.day==7
     local ok,err=Daily.favorAvailable(session,def.id,self.provider,accelerated)
     self:button(accelerated and "Pedir y ayudar" or "Solicitar",452,y+8,158,25,function()
      if accelerated then self.confirmHelp={id=def.id,provider=self.provider} else commit(Daily.requestFavor(session,def.id,self.provider)) end
     end,not ok or active~=nil)
     if not ok then self:text(err,28,y+37,580,P.muted) end
    end
   end
   for _,favor in ipairs(session.pending_favors) do if favor.status=="pending" then
    W.panel(18,279,604,25)
    self:text("Pendiente: "..Catalog.favorsById[favor.id].title,24,287,385,P.ink)
    self:button("Ayudar hoy (1 espacio)",410,279,210,25,function()self.confirmHelp={instance=favor.instance_id}end,Daily.remaining(session)<1 or d.activities_locked or active~=nil)
   end end
  else
   for row=1,3 do
    local def=list[(self.page-1)*3+row]
    if def then
     local x=18+(row-1)*204;W.panel(x,128,196,176)
     local separated=not Family.active(session,def.character)
     app.resources:portrait(def.character,separated and "worried" or "neutral",x+10,135,1,separated)
     self:text(def.title,x+80,137,106,P.gold)
     self:text("Visitas: "..d.visits[def.character],x+80,175,106,P.teal)
     self:text(Hud.reward(def),x+10,207,176,P.ink)
     self:button(separated and "Separación definitiva" or "Elegir actividad",x+10,273,176,25,function()commit(Daily.startActivity(session,def.id))end,separated or Daily.remaining(session)==0 or d.activities_locked or d.ending_processed or active~=nil)
    end
   end
  end

 end
 function s:keypressed(key)
  if self:navigate(key) then return end
  if key=="escape" then if self.confirmHelp then self.confirmHelp=nil else app:overlay("pause") end
  elseif key=="j" then app:overlay("journal") elseif key=="m" then app:overlay("deck") end
 end
 return s
end
return Agenda
