local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Economy=require("src.systems.economy")
local Books={}
function Books.new(app,returnTo)
 local s=Screen.new(app);s.kind="books";s.returnTo=returnTo or function()app:resume()end
 function s:draw()
  self:begin();app.resources:background("library");W.panel(12,10,616,336)
  self:text("LIBRERÍA · ORO "..app.session.gold,24,24,460,P.gold,2)
  self:button("Volver",514,20,100,26,self.returnTo)
  require("src.ui.daily_hud").draw(self,app,48,true)
  local family=require("src.systems.family").ensure(app.session)
  for i,book in ipairs(require("src.data.books")) do
   local y=65+(i-1)*82
   W.panel(22,y,594,76);self:text(book.title,33,y+10,420,P.gold)
   self:text(book.description,33,y+28,400,P.ink)
   self:button(family.books[book.id] and "Adquirido" or book.price.." oro",454,y+20,150,32,function()
    local receipt,err=Economy.buyBook(app.session,book.id,app.session.economy.revision)
    self.message=err or "Libro y conocimientos guardados."
    if receipt then
     require("src.systems.daily").completeBookVisit(app.session)
     if app:save() then app:resume() end
    end
   end,family.books[book.id] or app.session.gold<book.price or app.session.combat~=nil or app.session.encounter~=nil)
  end
  self:text(self.message or "Cada título se adquiere una vez. Las recetas se consumen al mejorar.",26,323,582,P.muted)
 end
 function s:keypressed(key) if key=="escape" then self.returnTo() else self:navigate(key) end end
 return s
end
return Books
