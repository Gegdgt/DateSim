local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local C=require("src.systems.companions")
local Combat=require("src.systems.combat")
local Data=require("src.data.battle_balance")
local Panel={}
function Panel.draw(s,app)
 s:begin();W.panel(12,12,616,336)
 if s.riskSkill then
  s:text("RIESGO DE INTERFERENCIA",30,35,570,P.danger,2)
  s:text("Afinidad menor de 25: la maldición distorsiona la sincronización. No es pérdida de capacidad profesional de Sylphiette.",30,90,570,P.ink)
  local p=Combat.supportPreview(s.enc,s.supportWife,s.riskSkill)
  s:text("Rudy perderá "..p.riskDamage.." PV (40% de su máximo), incluso si causa una derrota. La curación no se aplicará.",30,150,570,P.danger)
  s:button("Confirmar el riesgo",30,260,280,36,function()s:support(s.riskSkill,true)end)
  s:button("Cancelar",324,260,280,36,function()s.riskSkill=nil end)
  return
 end
 local index=0
 for _,id in ipairs(C.order)do if s.enc.allies[id] then
  index=index+1;s:button(Data.support[id].name,25+(index-1)*195,24,185,26,function()s.supportWife=id;s.keyboardFocus=nil end,false,s.supportWife==id)
 end end
 local wife=s.supportWife;local ally=s.enc.allies[wife]
 if not ally then return end
 s:text("Afinidad "..C.affinity(ally).." · 1 apoyo propio/turno · Rudy conserva sus acciones",25,61,590,P.teal)
 for i,skill in ipairs(Data.skills[wife])do
  local y=83+(i-1)*35;local p=Combat.supportPreview(s.enc,wife,skill.id);local ok,why=Combat.canSupport(s.enc,wife,skill.id)
  s:button(skill.name,25,y,200,28,function()s:support(skill.id)end,s.briefingOpen or not ok)
  local effect=skill.heal and (p.risk and "RIESGO: -"..p.riskDamage.." PV" or "+"..p.heal.." PV reales") or skill.power and (p.damage.." daño / "..p.hpLost.." PV ahora") or (skill.shield and "+"..skill.shield.." escudo" or "Debilita y expone")
  s:text(effect.." · "..p.mana.." M"..(p.uses and " · usos "..p.uses or ""),235,y+2,367,p.risk and P.danger or P.ink)
  local detail=skill.shatter and "Quita hasta 12 escudo; expone 3 turnos." or skill.expose and "Expone y debilita 2 turnos." or skill.weak and "Debilita: -2 daño por golpe." or skill.shield and "Caduca al volver a Rudy." or "Actúa antes del turno enemigo."
  s:text(not ok and why or ((skill.cooldown and "Recarga "..skill.cooldown..". " or "")..detail),235,y+14,367,P.muted)
 end
 s:button("Volver [Esc / T]",190,311,260,25,function()s.tacticsOpen=false;s.riskSkill=nil end)
end
function Panel.briefing(s,app)
 s:begin();W.panel(12,12,616,336)
 s:text("PREPARAR EL ENFRENTAMIENTO",28,28,584,P.gold,2)
 s:text(s.enc.enemy.name.." · "..s.enc.enemy.maxHp.." PV",28,57,584,P.ink)
 s:text("Rudy: 3 acciones. Cada compañera: 1 apoyo. Terminar turno ejecuta la intención enemiga; después caducan tus escudos y se recuperan 4 de energía externa.",28,79,584,P.muted)
 local row=0
 for _,id in ipairs(C.order)do local a=s.enc.allies[id];if a then
  local y=127+row*44;row=row+1
  app.resources:portraitSmall(id,"neutral",28,y)
  s:text(a.name.." · afinidad "..C.affinity(a).." · normal "..C.damage(Data.support[id].normal,a).." / especial "..C.damage(Data.support[id].special,a),70,y+2,535,P.teal)
  local previous=app.session.decisions["support_previous_"..id]
  local change=previous and (" · Especial "..string.format("%+d",C.damage(Data.support[id].special,a)-previous).." desde el último combate") or ""
  s:text(id=="sylphiette" and C.affinity(a)<25 and "RIESGO: interferencia de la maldición, -40% PV máximos." or Data.support[id].role..change,70,y+17,535,id=="sylphiette" and C.affinity(a)<25 and P.danger or P.muted)
 end end
 if row==0 then s:text("Rudy viaja solo. Usa cartas mejoradas, debilidades y defensa. Badigadi conserva sus 1000 PV; Orsted no es obligatorio.",28,140,584,P.ink)end
 s:text("Los especiales tienen recarga y usos limitados. T permite revisar todos los costes antes de actuar.",28,267,584,P.muted)
 s:button("Comenzar [Enter]",28,307,200,27,function()s.briefingOpen=false end)
 s:button("Habilidades [T]",238,307,180,27,function()s.tacticsOpen=true end,not s.enc.companion)
 s:button("Preparar mazo [M]",428,307,184,27,function()app:combatSafeExit()end)
end
return Panel
