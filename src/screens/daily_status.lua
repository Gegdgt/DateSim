local Status={}
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
function Status.new(app,tab)
 local s=Screen.new(app);s.kind="daily_status";s.tab=tab;s.page=1
 function s:lines()
  local out={};local session=app.session
  if self.tab=="cards" then
   local ids={};for _,id in ipairs(session.daily.rewards_granted)do ids[id]=true end
   for _,c in ipairs(require("src.systems.card_collection").list)do if ids[c.id]then
    local v=require("src.systems.card_collection").view(session,c.id)
    out[#out+1]=c.name.." · Nivel "..v.level.." · Copias disponibles "..v.copies
   end end
   if #out==0 then out[1]="Todavía no recibiste cartas durante esta jornada."end
  else
   out[1]="Objetivo: "..(session.events.enchanted_cards_returned and "Semana completada; acuerdos familiares registrados." or session.inventory.antidoteUsed and "Hablar con quienes permanecen y devolver las cartas." or session.events.antidote_holder_revealed and "Preparar el desafío de Badigadi y obtener el antídoto." or session.events.emissary_investigation_started and "Seguir el registro y localizar al emisario de la poción." or "Investigar la maldición y cumplir los compromisos familiares.")
   for _,id in ipairs({"sylphiette","roxy","eris"})do
    local r=session.relationships[id];local pending=0
    for _,state in pairs(r.promises)do if state=="pending" or state=="broken" then pending=pending+1 end end
    out[#out+1]=require("src.data.characters").byId[id].shortName..": "..pending.." promesa(s) pendiente(s); "..(r.events.personal_resolution and "misión personal resuelta." or "misión personal por resolver.")
   end
   for _,f in ipairs(session.pending_favors)do if f.status=="pending" then out[#out+1]="Encargo: "..require("src.data.activities").favorsById[f.id].title.." · entrega Día "..f.due_day end end
   out[#out+1]="El historial del diario conserva las decisiones y las misiones completadas."
  end
  return out
 end
 function s:draw()
  self:begin();app.resources:background("library");self:header("DÍA "..app.session.day.." / SEGUIMIENTO",true)
  self:button("Cartas obtenidas",22,49,190,27,function()self.tab="cards";self.page=1 end,false,self.tab=="cards")
  self:button("Misiones",224,49,190,27,function()self.tab="missions";self.page=1 end,false,self.tab=="missions")
  self:button("Colección [M]",426,49,190,27,function()app:overlay("deck")end)
  W.panel(18,85,604,218);local lines=self:lines();local pages=math.max(1,math.ceil(#lines/5))
  for row=1,5 do self:text(lines[(self.page-1)*5+row],30,99+(row-1)*39,576,P.ink)end
  self:button("Anterior",24,317,150,27,function()self.page=self.page-1 end,self.page==1)
  W.panel(185,317,254,27);self:text(self.page.." / "..pages,192,326,200,P.gold)
  self:button("Siguiente",452,317,164,27,function()self.page=self.page+1 end,self.page>=pages)
 end
 function s:keypressed(key)if key=="escape" then app:resume()elseif key=="m" then app:overlay("deck")else self:navigate(key)end end
 return s
end
return Status
