local Screen=require("src.ui.screen")
local Widgets=require("src.ui.widgets")
local P=require("src.ui.palette")
local Stats=require("src.systems.campaign_stats")
local Names=require("src.data.characters").byId
local Summary={}
local function value(v) if v==nil then return "Sin registro" end;return tostring(v) end
local function yes(v) return v and "Sí" or "No" end
function Summary.new(app)
 local s=Screen.new(app);s.kind="campaign_summary";s.tab=0;s.eventPage=1;s.data=Stats.snapshot(app.session)
 for _,wife in pairs(s.data.wives) do
  wife.eventRows={}
  for _,entry in ipairs(wife.events) do
   local lines=require("src.ui.font").wrap("Día "..entry.day.." · "..entry.text,580,1)
   for start=1,#lines,3 do
    local part={};for i=start,math.min(#lines,start+2) do part[#part+1]=lines[i] end
    wife.eventRows[#wife.eventRows+1]=table.concat(part,"\n")
   end
  end
 end
 if app.audio then app.audio:setContext("ending") end
 function s:select(tab) self.tab=tab;self.eventsOpen=false;self.eventPage=1 end
 function s:row(label,v,x,y,width,valueWidth)
  valueWidth=valueWidth or 85
  self:text(label,x,y,width-valueWidth-8,P.muted);self:text(value(v),x+width-valueWidth,y,valueWidth,P.ink,1,"right")
 end
 function s:draw()
  self:begin();app.resources:background("home")
  love.graphics.setColor(.025,.035,.07,.85);love.graphics.rectangle("fill",0,0,640,360)
  Widgets.panel(12,9,616,341)
  self:text("RESUMEN DE LOS SIETE DÍAS",26,19,588,P.gold,2)
  local g=self.data.general;local ending=g.ending and require("src.data.endings").byId[g.ending]
  self:text(ending and (ending.subtitle.." · "..ending.title) or "Registro de campaña",26,45,588,P.teal)
  for i,label in ipairs({"General","Sylphie","Roxy","Eris"}) do
   self:button(label,26+(i-1)*148,64,140,24,function()self:select(i-1)end,false,self.tab==i-1)
  end
  if self.tab==0 then
   local left={{"Oro conseguido",g.goldEarned},{"Oro gastado",g.goldSpent},{"Oro restante",g.gold},
    {"Cartas desbloqueadas",g.unlocked},{"Copias obtenidas",g.duplicates},{"Niveles mejorados",g.levelsGained},
    {"Cartas al nivel 10",g.maxLevel},{"Hallazgos recogidos",g.hiddenObjects},{"Fragmentos obtenidos",g.manaFragments}}
   local right={{"Enemigos vencidos",g.enemiesDefeated},{"Derrotas sufridas",g.defeats},{"Entrenamientos",g.training},
    {"Derrotas narrativas",g.narrativeDefeats},{"Encargos exitosos",g.commissionsSuccess},{"Encargos fallidos",g.commissionsFailure},
    {"Prueba de Orsted",yes(g.orsted)},{"Antídoto obtenido",yes(g.antidote)},{"Cartas devueltas",yes(app.session.inventory.enchantedCardsReturned)}}
   for i,r in ipairs(left) do self:row(r[1],r[2],28,104+(i-1)*19,275) end
   for i,r in ipairs(right) do self:row(r[1],r[2],332,104+(i-1)*19,278) end
   self:text(g.battleHistoryComplete and "Copias: incluye las gastadas en mejoras. Orsted se cuenta aparte de las derrotas." or
    "Guardado anterior: combates registrados desde esta versión; historial previo no disponible.",28,283,584,P.teal)
  else
   local id=Stats.wives[self.tab];local w=self.data.wives[id]
   if self.eventsOpen then
    local pages=math.max(1,math.ceil(#w.eventRows/3));self.eventPage=math.min(self.eventPage,pages)
    self:text("RECUERDOS · "..Names[id].shortName.." · "..self.eventPage.."/"..pages,28,99,580,P.gold)
    for i=1,3 do local entry=w.eventRows[(self.eventPage-1)*3+i]
     if entry then self:text(entry,28,123+(i-1)*48,580,P.ink) end
    end
    self:button("<",28,274,45,24,function()self.eventPage=self.eventPage-1 end,self.eventPage==1)
    self:button(">",82,274,45,24,function()self.eventPage=self.eventPage+1 end,self.eventPage==pages)
    self:button("Volver a cifras",410,274,200,24,function()self.eventsOpen=false end)
   else
    app.resources:portrait(id,w.state=="separated" and "worried" or "happy",28,105,2,w.state=="separated")
    self:text(w.state=="separated" and "SEPARADA" or "MATRIMONIO VIGENTE",28,243,175,w.state=="separated" and P.muted or P.teal)
    self:text("Días: "..(#w.visitedDays>0 and table.concat(w.visitedDays,", ") or "Ninguno"),28,269,175,P.ink)
    local rows={{"Amor inicial → final",value(w.initialLove).." → "..w.love},
     {"Confianza inicial → final",value(w.initialTrust).." → "..w.trust},{"Días visitada / interacciones",w.daysVisited.." / "..w.interactions},
     {"Noches compartidas",w.nights},{"Promesas cumplidas",w.kept},{"Promesas incumplidas",w.broken},
     {"Combates compartidos",w.combats},{"Conflictos reconciliados",w.reconciliations}}
    for i,r in ipairs(rows) do self:row(r[1],r[2],208,106+(i-1)*21,400,144) end
    self:button("Recuerdos y decisiones",208,280,400,24,function()self.eventsOpen=true end)
   end
  end
  self:button("Ver final",26,316,136,24,function()app:switch(require("src.screens.summary").new(app))end)
  self:button("Diario",174,316,136,24,function()app:overlay("journal")end)
  self:button("Colección",322,316,136,24,function()app:overlay("deck")end)
  self:button("Menú",470,316,140,24,function()app:save();app.session=nil;app:menu()end)
 end
 function s:keypressed(key)
  local n=tonumber(key)
  if n and n>=1 and n<=4 then self:select(n-1)
  elseif key=="escape" then app:overlay("pause") else self:navigate(key) end
 end
 return s
end
return Summary
