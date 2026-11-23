local Collection=require("src.systems.card_collection")
local Social=require("src.data.cards")
local Techniques=require("src.data.combat_cards")
local Finale={trainingIds={time_eris=true,eris_physical=true,eris_duel=true,E01=true,E02=true,E15=true}}

function Finale.ensure(s)
 s.eris_training_days=s.eris_training_days or {}
 s.orsted_reward=s.orsted_reward or {choices={},revision=0}
 return s.orsted_reward
end
local function markAt(s,id,day)
 s.events[id]=true;s.events_by_day=s.events_by_day or {}
 local key=tostring(day);s.events_by_day[key]=s.events_by_day[key] or {};s.events_by_day[key][id]=true
 if s.daily and s.daily.day==day then s.daily.events[id]=true end
end
function Finale.trainedEveryDay(s)
 Finale.ensure(s)
 for day=1,5 do if not s.eris_training_days[tostring(day)] then return false end end
 return true
end
function Finale.recordTraining(s,source)
 if not Finale.trainingIds[source] and source~="day5_eris_duel" and source~="day6_eris_rematch" then return false end
 Finale.ensure(s)
 local day=s.day;local key=tostring(day)
 if s.eris_training_days[key] then return false end
 s.eris_training_days[key]=true
 require("src.systems.events").apply(s,"eris_training_day_"..day,{context="training",text="Entrenamiento con Eris completado en el Día "..day..". Fuente: "..source.."."})
 if Finale.trainedEveryDay(s) then markAt(s,"eris_five_training_days",5) end
 return true
end
function Finale.kindMatches(id,kind)
 local card=Collection.byId[id]
 return card and ((kind=="social" and Social.byId[id]~=nil) or (kind=="combat" and (Techniques.byId[id]~=nil or card.combat~=nil))) or false
end
function Finale.options(s,kind)
 local reward=Finale.ensure(s);local out={}
 for _,card in ipairs(Collection.list) do
  if Finale.kindMatches(card.id,kind) and card.id~=reward.choices.combat and card.id~=reward.choices.social then out[#out+1]=card.id end
 end
 return out
end
function Finale.canChoose(s,kind,id)
 local reward=Finale.ensure(s)
 if s.checkpoint~="day6_orsted_gifts" or not s.events.orsted_collection_gift then return false,"La ayuda de Orsted todavía no está disponible." end
 if reward.pending then return false,"Termina la presentación de la mejora anterior." end
 if reward.choices[kind] or s.events["orsted_max_"..kind] then return false,"Ya elegiste la carta de este tipo." end
 if not Finale.kindMatches(id,kind) or id==reward.choices.combat or id==reward.choices.social then return false,"Elige dos cartas distintas, una de cada tipo." end
 if Collection.level(s,id)==10 then
  for _,other in ipairs(Finale.options(s,kind)) do
   if Collection.level(s,other)<10 then return false,"Esta carta ya está al máximo. Puedes mejorar otra." end
  end
 end
 return true
end
function Finale.choose(s,kind,id,revision)
 local reward=Finale.ensure(s)
 if revision~=nil and revision~=reward.revision then return nil,"Esta elección ya fue procesada." end
 local ok,err=Finale.canChoose(s,kind,id);if not ok then return nil,err end
 local before=Collection.level(s,id)
 -- Una transacción lógica: el nivel cambia aquí; la animación sólo lo presenta.
 Collection.ensure(s)[id].level=10
 reward.choices[kind]=id;reward.revision=reward.revision+1
 reward.pending={kind=kind,id=id,before=before,elapsed=0}
 require("src.systems.events").apply(s,"orsted_max_"..kind,{decision="orsted_max_"..kind,value=id,context="orsted",text="Orsted lleva "..Collection.byId[id].name.." al nivel 10. Sin gastar oro, copias ni recetas."})
 return reward.pending
end
function Finale.acknowledge(s)
 local reward=Finale.ensure(s)
 if not reward.pending then return false end
 reward.pending=nil;return true
end
function Finale.rewardComplete(s)
 local reward=Finale.ensure(s)
 return reward.choices.combat~=nil and reward.choices.social~=nil and not reward.pending
end
function Finale.advance(s,action)
 if action=="orsted_grant" then
  if not s.events.orsted_demonstration_completed then return nil,"Completa la demostración de Orsted." end
  local missing={}
  for _,card in ipairs(Collection.list)do if not s.unlocked[card.id] then missing[#missing+1]=card.id end end
  require("src.systems.events").apply(s,"orsted_collection_gift",{unlock=missing,presenter="orsted",context="orsted",text="Orsted entrega todos los patrones que faltaban. Las restricciones matrimoniales siguen vigentes."})
 elseif action=="orsted_choices" and not Finale.rewardComplete(s) then
  return nil,"Elige una carta de combate y una social y termina sus presentaciones."
 elseif action=="return_cards" then
  if not s.inventory.antidoteUsed then return nil,"Todavía necesitas las cartas para comunicarte." end
  if not require("src.systems.relationships").ending(s.relationships) then return nil,"Resuelve primero los compromisos matrimoniales pendientes." end
  require("src.systems.events").mark(s,"relationships_resolved")
  require("src.systems.events").apply(s,"enchanted_cards_returned",{context="closure",text="Rudy devuelve a Nanahoshi las cartas encantadas. El registro de colección, niveles y duplicados permanece en la galería."})
  s.inventory.enchantedCardsReturned=true
 end
 return true
end
function Finale.restore(s,input)
 Finale.ensure(s)
 s.eris_training_days={}
 for day=1,math.min(7,s.day)do
  if s.events["eris_training_day_"..day] then s.eris_training_days[tostring(day)]=true end
 end
 -- Migración con pruebas concretas: actividades terminadas, nunca visitas reservadas.
 if input.versionBeforeFinale then
  local function recover(day,report)
   if type(day)~="number" or day%1~=0 or day<1 or day>s.day then return end
   local activities=type(report)=="table" and (report.activities_completed or report.activities)
   for _,a in ipairs(type(activities)=="table" and activities or {})do
    if type(a)=="table" and Finale.trainingIds[a.id] then s.eris_training_days[tostring(day)]=true;markAt(s,"eris_training_day_"..day,day) end
   end
  end
  for day=1,7 do recover(day,(s.daily_history or {})[tostring(day)])end
  if s.daily then recover(s.daily.day,s.daily)end
  if s.events.training_result_day5_eris_duel then s.eris_training_days["5"]=true;markAt(s,"eris_training_day_5",5)end
 end
 s.events.eris_five_training_days=nil
 if Finale.trainedEveryDay(s)then markAt(s,"eris_five_training_days",5)end
 local reward={choices={},revision=0}
 for _,kind in ipairs({"combat","social"})do
  local id=s.decisions["orsted_max_"..kind]
  if s.events.orsted_collection_gift and s.events["orsted_max_"..kind] and Finale.kindMatches(id,kind) and id~=reward.choices.combat then
   reward.choices[kind]=id;reward.revision=reward.revision+1;s.collection[id].level=10
  end
 end
 local pending=type(input.orsted_reward)=="table" and input.orsted_reward.pending
 if type(pending)=="table" and reward.choices[pending.kind]==pending.id then
  local before=tonumber(pending.before) or 1;local elapsed=tonumber(pending.elapsed) or 0
  reward.pending={kind=pending.kind,id=pending.id,before=math.max(1,math.min(10,math.floor(before==before and before or 1))),elapsed=math.max(0,math.min(2,elapsed==elapsed and elapsed or 0))}
 end
 s.orsted_reward=reward
 if s.events.enchanted_cards_returned then require("src.systems.events").mark(s,"relationships_resolved") end
 if s.events.enchanted_cards_returned then s.inventory.enchantedCardsReturned=true end
end
return Finale
