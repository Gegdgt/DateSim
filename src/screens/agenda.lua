local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Daily=require("src.systems.daily")
local Catalog=require("src.data.activities")
local Family=require("src.systems.family")
local Budget=require("src.systems.relationship_budget")
local Progression=require("src.systems.progression")
local Agenda={}
function Agenda.new(app)
 local s=Screen.new(app);s.kind="agenda";s.tab="sylphiette";s.page=1;s.provider="cliff"
 local function commit(ok,err)
  if not ok then app:notify(err);return end
  if app:save() then app:resume() end
 end
 function s:draw()
  self:begin();local session=app.session;local d=Daily.ensure(session)
  app.resources:background("home");self:header("DÍA "..session.day.." / AGENDA · ORO "..session.gold)
  if self.confirmHelp then
   W.panel(65,70,510,245)
   self:text("AYUDAR CONSUME UNA INTERACCIÓN",85,91,470,P.gold)
   self:text("El encargo se entregará hoy. Gastarás uno de los tres espacios que podrías dedicar a tus esposas. Ayudar a Cliff o Zanoba no cuenta como visita matrimonial.",85,126,470,P.ink)
   self:text("Sin ninguna visita, cada esposa pierde 20 de amor y 20 de confianza al cerrar el día.",85,190,470,P.danger)
   self:button("Confirmar: gastar 1 espacio",85,257,300,34,function()
    local request=self.confirmHelp;self.confirmHelp=nil
    if request.instance then commit(Daily.accelerateFavor(session,request.instance))
    else commit(Daily.requestFavor(session,request.id,request.provider,true)) end
   end,Daily.remaining(session)<1)
   self:button("Cancelar",400,257,152,34,function()self.confirmHelp=nil end)
   return
  end
  if d.active_activity then
   local active=d.active_activity;local def=Catalog.byId[active.id]
   app.resources:background(def.background);W.panel(18,48,604,282)
   app.resources:portrait(def.character,(active.visit or 1)==3 and "worried" or "happy",42,86,2)
   self:text(def.title,190,65,410,P.gold)
   self:text(def.description,190,91,408,P.ink)
   self:text("Visita "..(active.visit or 1).." de hoy · quedan "..Daily.remaining(session).."/3",190,150,408,P.teal)
   self:text(def.reward,190,175,408,P.gold)
   for i,choice in ipairs(def.choices) do
    local delta=Budget.preview(session,def.character,choice.effects)
    local label=choice.label..(def.battle and "" or " ("..string.format("%+d amor / %+d conf.",delta.love,delta.trust)..")")
    self:button(label,190,205+(i-1)*42,410,34,function()commit(Daily.resolveActivity(session,choice.id))end)
   end
   if def.books then self:button("Entrar a la librería",190,254,410,34,function()app:switch(require("src.screens.books").new(app))end) end
   self:text("El espacio ya está reservado. Guardar conserva la actividad y su resultado pendiente.",24,340,592,P.muted)
   return
  end
  for i,id in ipairs({"sylphiette","roxy","eris","favors"}) do
   self:button(({sylphiette="Sylphiette",roxy="Roxy",eris="Eris",favors="Encargos"})[id],18+(i-1)*120,47,114,27,function()self.tab=id;self.page=1;self.keyboardFocus=nil end,false,self.tab==id)
  end
  self:button("Ayer",498,47,124,27,function()
   app:switch(require("src.screens.day_report").new(app,session.daily_history[tostring(session.day-1)],function()app:resume()end))
  end,not session.daily_history[tostring(session.day-1)])
  W.panel(18,79,604,28)
  self:text("Libres: "..Daily.remaining(session).."/3 · Encargo: "..(d.favor_used and "solicitado" or "disponible"),24,88,412,P.gold)
  local list={}
  if self.tab=="favors" then
   for _,def in ipairs(Catalog.favors) do for _,provider in ipairs(def.providers) do if provider==self.provider then list[#list+1]=def end end end
  else for _,def in ipairs(Catalog.list) do if def.character==self.tab then list[#list+1]=def end end end
  local perPage=self.tab=="favors" and 2 or 3;local pages=math.max(1,math.ceil(#list/perPage))
  self:button("<",450,81,35,25,function()self.page=self.page-1 end,self.page==1)
  self:text(self.page.."/"..pages,492,90,78,P.ink)
  self:button(">",582,81,40,25,function()self.page=self.page+1 end,self.page==pages)
  if self.tab=="favors" then
   self:button("Cliff",18,112,130,24,function()self.provider="cliff";self.page=1 end,false,self.provider=="cliff")
   self:button("Zanoba",156,112,130,24,function()self.provider="zanoba";self.page=1 end,false,self.provider=="zanoba")
   W.panel(294,112,328,24)
   self:text("Mañana al comenzar · Ayudar: 1 espacio",304,120,312,P.muted)
   for row=1,2 do
    local def=list[(self.page-1)*2+row]
    if def then
     local y=143+(row-1)*59;W.panel(18,y,604,54)
     self:text(def.title,28,y+7,400,P.gold);self:text(def.reward,28,y+23,400,P.ink)
     local accelerated=session.day==7
     local ok,err=Daily.favorAvailable(session,def.id,self.provider,accelerated)
     self:button(accelerated and "Pedir y ayudar" or "Solicitar",452,y+8,158,25,function()
      if accelerated then self.confirmHelp={id=def.id,provider=self.provider} else commit(Daily.requestFavor(session,def.id,self.provider)) end
     end,not ok)
     if not ok then self:text(err,28,y+37,580,P.muted) end
    end
   end
   for _,favor in ipairs(session.pending_favors) do if favor.status=="pending" then
    W.panel(18,259,604,25)
    self:text("Pendiente: "..Catalog.favorsById[favor.id].title,24,267,385,P.ink)
    self:button("Ayudar hoy (1 espacio)",410,259,210,25,function()self.confirmHelp={instance=favor.instance_id}end,Daily.remaining(session)<1 or d.activities_locked)
   end end
  else
   for row=1,3 do
    local def=list[(self.page-1)*3+row]
    if def then
     local x=18+(row-1)*204;W.panel(x,114,196,167)
     local separated=not Family.active(session,def.character)
     app.resources:portrait(def.character,separated and "worried" or "neutral",x+10,121,1,separated)
     self:text(def.title,x+80,125,106,P.gold)
     self:text("Visitas: "..d.visits[def.character],x+80,164,106,P.teal)
     self:text(def.reward,x+10,195,176,P.ink)
     self:button(separated and "Separación definitiva" or "Elegir actividad",x+10,246,176,25,function()commit(Daily.startActivity(session,def.id))end,separated or Daily.remaining(session)==0 or d.activities_locked or d.ending_processed)
    end
   end
  end
  W.panel(18,284,604,22)
  self:text("Sin visita: -20 amor y -20 confianza. La historia no sustituye las actividades.",24,291,592,P.ink)
  local finalLock=session.day==7 and not d.activities_locked
  self:button(finalLock and "Cerrar tiempo libre e ir a la historia" or "Continuar historia",18,311,330,27,function()commit(Progression.continueStory(session))end,Daily.storyComplete(session))
  self:button("Finalizar día",358,311,264,27,function()app:endDay()end,not Daily.storyComplete(session))
  W.panel(18,341,604,17)
  self:text("Puedes dormir sin agotar los tres espacios. Los encargos normales tardan un día.",24,346,592,P.muted)
 end
 function s:keypressed(key)
  if self:navigate(key) then return end
  if key=="escape" then if self.confirmHelp then self.confirmHelp=nil else app:overlay("pause") end
  elseif key=="j" then app:overlay("journal") elseif key=="m" then app:overlay("deck") end
 end
 return s
end
return Agenda
