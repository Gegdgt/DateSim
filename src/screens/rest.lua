local Screen=require("src.ui.screen")
local Panel=require("src.ui.widgets")
local P=require("src.ui.palette")
local Rest=require("src.systems.rest")
local Data=require("src.data.rest")
local View={}
function View.new(app,bed)
 local s=Screen.new(app);s.kind="rest";s.preview=true
 local session=app.session;local talk=bed.wife and Data.conversations[bed.wife]
 function s:confirm()
  local ok,err
  if Rest.completed(session) then ok=true else ok,err=Rest.confirm(session,bed,"gesture") end
  if not ok then self.message=err;return end
  if not app:save() then return end
  app:endDay({type="night",duration=.6})
 end
 function s:draw()
  self:begin();if app.worldScreen then app.worldScreen:drawWorld() else app.resources:background("home") end
  Panel.panel(18,24,604,312)
  self:text(bed.wife and "¿Vienes a descansar conmigo?" or "¿Quieres descansar aquí esta noche?",32,39,576,P.gold,2)
  if bed.wife then app.resources:portrait(bed.wife,talk.expression,40,121,2) end
  self:text(talk and talk.intro or "Rudy prepara un jergón en el segundo piso. Dormir solo permite comenzar una nueva jornada.",187,90,413,P.ink)
  local ok,reason=Rest.available(session,bed)
  self:text(reason or (bed.wife and "Hasta +10 amor y +10 confianza fuera del límite diurno.\nDormir juntos no sustituye una visita diurna." or "Sin bonificación romántica. Las ausencias diurnas se aplican igualmente."),187,147,413,P.teal)
  self:text(bed.wife and "Rudy deja las cartas sobre la mesa. Puede quedarse a su lado o continuar explorando."
   or "Rudy prepara la manta junto al jergón.",187,211,413,P.ink)
  self:button(Rest.completed(session) and "Continuar al resumen" or "Confirmar descanso",187,296,245,28,function()self:confirm()end,not ok and not Rest.completed(session))
  self:button("Seguir explorando",442,296,158,28,function()app:explore()end)
  if self.message then self:text(self.message,32,316,560,P.danger) end
 end
 function s:keypressed(key)
  if key=="j" then app:explore();app.manager.current:keypressed("j")
  elseif key=="escape" then app:explore() else self:navigate(key) end
 end
 return s
end
return View
