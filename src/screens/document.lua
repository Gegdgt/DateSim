-- Animación reutilizable de pistas. Reread usa un callback y nunca concede eventos.
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Font=require("src.ui.font")
local Events=require("src.systems.events")
local Documents=require("src.data.documents")
local Document={}
function Document.new(app,id,returnTo)
 local s=Screen.new(app)
 s.kind="document"; s.document=assert(Documents[id]); s.elapsed=0; s.returnTo=returnTo
 local saved=app.session.documentState
 s.phase=returnTo and "reading" or (saved and saved.id==id and saved.phase or "resting")
 s.elapsed=not returnTo and saved and saved.id==id and saved.elapsed or 0
 s.page=not returnTo and saved and saved.id==id and saved.page or 1; s.lines=Font.wrap(s.document.text,534,1)
 s.pages=math.max(1,math.ceil(#s.lines/20))
 s.page=math.max(1,math.min(s.page,s.pages))
 function s:persist()
  if not self.returnTo then app.session.documentState={id=id,phase=self.phase,elapsed=self.elapsed,page=self.page}; app:save() end
 end
 function s:interact()
  if self.phase=="resting" then
   self.phase="lifting"; self.elapsed=0; app.audio:effect("paper"); self:persist()
  elseif self.phase=="reading" then
   if self.page<self.pages then self.page=self.page+1; app.audio:effect("paper"); self:persist(); return end
   if self.returnTo then self.returnTo(); return end
   self.phase="signature"; self.elapsed=0; app.audio:effect("revelation"); self:persist()
  end
 end
 function s:update(dt)
  self.elapsed=self.elapsed+dt
  if not self.returnTo and app.session.documentState then app.session.documentState.elapsed=self.elapsed end
  local reduced=app.options.reducedMotion
  if self.phase=="lifting" and (reduced or self.elapsed>=.6) then
   self.phase="opening"; self.elapsed=0; app.audio:effect("envelope_open"); self:persist()
  elseif self.phase=="opening" and (reduced or self.elapsed>=.45) then
   self.phase="reading"; self.elapsed=0; self:persist()
  elseif self.phase=="signature" and (reduced or self.elapsed>=.6) then
   self.phase="done"
   Events.apply(app.session,id.."_read",{clue=id,text="Documento leído: "..self.document.title})
   app.session.documentState=nil
   app:next()
  end
 end
 local function envelope(x,y,scale,open)
  love.graphics.push(); love.graphics.translate(math.floor(x),math.floor(y)); love.graphics.scale(scale,scale)
  love.graphics.setColor(.25,.18,.2); love.graphics.rectangle("fill",-1,-1,50,32)
  love.graphics.setColor(.87,.76,.55); love.graphics.rectangle("fill",0,0,48,30)
  love.graphics.setColor(.66,.48,.35)
  love.graphics.polygon("fill",0,0,24,open and -14 or 17,48,0)
  love.graphics.setColor(.8,.67,.45); love.graphics.polygon("fill",0,30,24,13,48,30)
  love.graphics.setColor(.51,.21,.3); love.graphics.rectangle("fill",21,12,7,7)
  love.graphics.pop()
 end
 function s:draw()
  self:begin(); app.resources:background(self.document.background)
  self:header(self.document.title)
  if self.phase=="reading" or self.phase=="signature" then
   W.panel(32,45,576,278)
   for row=1,20 do
    local line=self.lines[(self.page-1)*20+row]
    if line then self:text(line,50,56+(row-1)*11,534,P.ink) end
   end
   if self.page==self.pages then
    self:text(self.document.signature,470,283,110,P.gold,self.phase=="signature" and 3 or 2,"right")
   end
   if self.phase=="reading" then
    if self.page>1 then self:button("< Volver a leer",48,325,172,24,function() self.page=self.page-1; self:persist() end) end
    self:button(self.page<self.pages and "Leer página siguiente" or "Cerrar carta",330,325,268,24,function() self:interact() end)
   else self:text(self.document.signature,80,154,480,P.gold,id=="hitogami_letter" and 3 or 1,"center") end
  else
   local t=math.min(1,self.elapsed/.6); local x,y,scale=394,190,1
   if self.phase=="lifting" then
    x=394+(248-394)*t; y=190+(110-190)*t-math.sin(t*math.pi)*18; scale=1+math.floor(t*2)
   elseif self.phase=="opening" then x,y,scale=248,110,3 end
   envelope(x,y,scale,self.phase=="opening")
   if self.phase=="resting" then
    local pulse=app.options.reducedMotion and .65 or .5+math.sin(self.elapsed*2)*.15
    love.graphics.setColor(1,.85,.48,pulse); love.graphics.rectangle("line",390,186,56,38)
    W.panel(42,265,556,50)
    self:text("El sobre no estaba aquí anoche.",58,278,524,P.ink)
    self:button("Examinar carta",350,233,208,26,function() self:interact() end)
   end
  end
 end
 function s:mousepressed(x,y,b)
  if self:click(x,y,b) then return end
  if b==1 and self.phase=="resting" and x>=388 and x<=450 and y>=180 and y<=228 then self:interact() end
 end
 function s:keypressed(key)
  if self:navigate(key) then return end
  if key=="return" or key=="space" or key=="e" then self:interact()
  elseif key=="escape" then if self.returnTo then self.returnTo() else app:overlay("pause") end
  elseif key=="left" and self.phase=="reading" then self.page=math.max(1,self.page-1); self:persist() end
 end
 return s
end
return Document
