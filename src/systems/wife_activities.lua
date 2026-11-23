local Bank=require("src.data.wife_activities")
local Daily=require("src.systems.daily")
local Events=require("src.systems.events")
local Family=require("src.systems.family")
local Collection=require("src.systems.card_collection")
local Economy=require("src.systems.economy")
local Social=require("src.systems.social_rules")
local W={bank=Bank}
local function copy(t)
 if type(t)~="table" then return t end
 local out={};for k,v in pairs(t) do out[k]=copy(v) end;return out
end
function W.ready(s)
 if s.prologue then
  local p=s.prologue
  return p.letter_read and p.curse_discovered and p.nanahoshi_visited and p.starting_cards_received
   and require("src.systems.objectives").dailyUnlocked(s) or false
 end
 return s.events.first_anomaly==true or s.events.day1_complete==true
end
function W.ensure(s)
 s.wifeActivities=s.wifeActivities or {version=1,encounters={},history={}}
 return s.wifeActivities
end
function W.handCandidates(s,def,restoring)
 local out,excluded={},{}
 for _,id in ipairs(s.deck) do
  local card=require("src.data.cards").byId[id]
  local conditions=card and card.conditions or {}
  local response=def.responses[id]
  if response and s.unlocked[id] and (not conditions.character or conditions.character==def.character)
   and Collection.level(s,id)>=(response.minLevel or 1)
   and (restoring or not response.requires or require("src.systems.conditions").evaluate(s,response.requires))
   and (not card.revealsSecret or not s.curse.active) then out[#out+1]=id
  elseif card and s.unlocked[id] then excluded[#excluded+1]=id end
 end
 return out,excluded
end
function W.nearWife(s,wife)
 return require("src.systems.exploration").nearCharacter(s,wife)
end
function W.previousDuel(s)
 return s.decisions.activity_duel_result or s.decisions.eris_training_last_result or s.decisions.eris_training_result
end
function W.available(s,id,starting)
 local d=Bank.byId[id]
 if not d then return false,"Actividad desconocida." end
 if not W.ready(s) then return false,"Lee la carta del estudio y completa la introducción con Nanahoshi." end
 if not Family.active(s,d.character) then return false,"Matrimonio separado; actividad no disponible." end
 if Daily.ensure(s).activities_locked or Daily.remaining(s)<1 then return false,"El tiempo libre de hoy terminó." end
 if s.day<(d.minDay or 1) then return false,"Disponible desde el Día "..d.minDay.."." end
 if d.maxDay and s.day>d.maxDay then return false,"Requiere una jornada posterior para cumplir la promesa." end
 if d.minTrust and s.relationships[d.character].trust<d.minTrust then return false,"Requiere "..d.minTrust.." de confianza." end
 if d.requiredEvent and not s.events[d.requiredEvent] then return false,d.requirementLabel or "Requiere recibir las cartas de Orsted." end
 if d.previousDuel and not W.previousDuel(s) then return false,"Completa primero un duelo con Eris." end
 if s.gold<d.goldCost then return false,"Requiere "..d.goldCost.." de oro." end
 if #W.handCandidates(s,d)<5 then return false,"Equipa al menos cinco cartas compatibles. Las cinco cartas sociales iniciales sirven para esta actividad." end
 if starting then
  if not W.nearWife(s,d.character) then return false,"Acércate a ella y salúdala antes de comenzar." end
  if not Daily.atAgenda(s) then return false,"Completa la escena de la jornada y vuelve al tiempo libre." end
  if Daily.ensure(s).activities_locked then return false,"El tiempo libre de hoy terminó." end
  if Daily.remaining(s)<1 then return false,"No quedan interacciones hoy." end
 end
 return true
end
function W.offers(s,wife)
 local state=W.ensure(s);local count=(state.encounters[wife] or 0)+1;state.encounters[wife]=count
 local available,pinned={},{}
 for _,def in ipairs(Bank.byWife[wife] or {}) do
  if W.available(s,def.id) then
   if (def.id=="E01" and s.day<=5 and not (s.eris_training_days or {})[tostring(s.day)])
    or (def.id=="R05" and s.day>=3 and (Family.ensure(s).progress.antidote_research or 0)<1)
    or (def.id=="S03" and ({pending=true,broken=true})[s.relationships.sylphiette.promises.family_errand]) then
    pinned[#pinned+1]=def
   else available[#available+1]=def end
  end
 end
 local result={};for _,def in ipairs(pinned) do result[#result+1]=def end
 -- Rotación sin reemplazo; las actividades de campaña quedan fijadas arriba.
 local start=((count-1)*2+s.day-1)%math.max(1,#available)
 local rotated={};for i=1,#available do rotated[i]=available[(start+i-1)%#available+1] end
 local last
 for _,entry in pairs(state.history) do
  if Bank.byId[entry.id].character==wife and (not last or entry.instance>last.instance) then last=entry end
 end
 if last and #rotated>3 then
  for i,def in ipairs(rotated) do if def.id==last.id then table.remove(rotated,i);rotated[#rotated+1]=def;break end end
 end
 for i=1,math.min(3-#result,#rotated) do result[#result+1]=rotated[i] end
 return result
end
function W.current(s)
 local active=Daily.ensure(s).active_activity
 return active and Bank.byId[active.id] and active or nil
end
function W.start(s,id,revision)
 local ok,err=W.available(s,id,true);if not ok then return nil,err end
 if Daily.ensure(s).active_activity then return nil,"Termina la actividad pendiente." end
 if revision~=Economy.ensure(s).revision then return nil,"Revisa de nuevo el coste antes de confirmar." end
 local def=Bank.byId[id]
 local active,reason=Daily.reserveActivity(s,id);if not active then return nil,reason end
 if def.goldCost>0 then active.receipt=assert(Economy.spend(s,def.goldCost,revision,"wife_activity:"..id)).id end
 local seed=require("src.systems.world_content").ensure(s).seed
 local rng=require("src.systems.world_content").hash(seed,active.instance_id..":"..id)
 local function random(n) rng=(rng*48271)%2147483647;return rng%n+1 end
 local hand,excluded=W.handCandidates(s,def)
 active.handVersion=2;active.excludedCards=excluded
 active.shuffleSource=copy(hand);active.shuffleSteps={}
 for i=#hand,2,-1 do local j=random(i);active.shuffleSteps[#active.shuffleSteps+1]={i=i,j=j};hand[i],hand[j]=hand[j],hand[i] end
 active.initialOrder=copy(hand);active.drawPile=copy(hand);active.discard={};active.log={}
 active.hand={};for i=1,math.min(3,#hand) do active.hand[i]=table.remove(active.drawPile) end
 active.socialVersion=2;active.energy=Social.energy;active.maxEnergy=Social.energy;active.maxCards=Social.maxCards
 active.delta={love=0,trust=0};active.before={love=s.relationships[def.character].love,trust=s.relationships[def.character].trust}
 active.roll=random(100);active.phase="intro"
 if def.successChance then active.chance=def.successChance;active.experimentSuccess=active.roll<=active.chance end
 active.origin=s.exploration and {map=s.exploration.map,x=s.exploration.x,y=s.exploration.y,facing=s.exploration.facing}
 if s.exploration then s.exploration.active=false end
 W.ensure(s)
 return active
end
function W.cost(s,card)
 local active=W.current(s);return Social.cost(card,Bank.byId[active.id].character)
end
function W.response(s,card)
 local a=W.current(s);local def=Bank.byId[a.id]
 if card=="pass" then return {rudy="Rudy baja las cartas y asiente.",reply=def.closing or def.intro,expression="neutral",effects={},love=0,trust=0} end
 local response=copy(def.responses[card])
 local previous=a.log and a.log[#a.log]
 if previous and previous.card==card then previous=a.log[#a.log-1] end
 -- Variantes escritas por carta; el contexto anterior forma parte del registro.
 if previous and response.after and response.after[previous.card] then
  for k,v in pairs(response.after[previous.card]) do response[k]=copy(v) end
 end
 return response
end
function W.question(s)
 local a=W.current(s);local def=Bank.byId[a.id];local n=#(a.log or {})
 if a.phase=="reply" or a.phase=="playing" then n=math.max(0,n-1) end
 local last=a.log and a.log[n]
 if last and last.delta and (last.delta.love<0 or last.delta.trust<0) then
  return def.repairQuestion or ("Volvamos a esto: "..def.question)
 end
 return def.moments and def.moments[n] or def.question
end
function W.canPlay(s,card)
 local a=W.current(s)
 if not a or a.phase~="hand" or #(a.log or {})>=Social.maxCards then return false,"Espera al siguiente momento de la conversación." end
 local present=false;for _,id in ipairs(a.hand) do if id==card then present=true end end
 if not present then return false,"Esa carta no está en tu mano." end
 if (a.energy or Social.energy)<W.cost(s,card) then return false,"No tienes energía social suficiente. Puedes terminar la conversación." end
 return true
end
function W.choose(s,card)
 local ok,err=W.canPlay(s,card);if not ok then return nil,err end
 local a=W.current(s)
 if not a.socialVersion then -- una actividad antigua conserva su resolución única
  a.handVersion=nil
  a.socialVersion=2;a.energy=Social.energy;a.maxEnergy=Social.energy;a.maxCards=Social.maxCards
  a.initialOrder={};for i=#a.hand,1,-1 do a.initialOrder[#a.initialOrder+1]=a.hand[i] end
  a.drawPile={};a.discard={};a.log={};a.delta={love=0,trust=0}
  local r=s.relationships[Bank.byId[a.id].character];a.before={love=r.love,trust=r.trust}
  W.upgradeHand(s,a)
 end
 local response=W.response(s,card)
 local cost=W.cost(s,card);a.energy=a.energy-cost
 for i,id in ipairs(a.hand) do if id==card then table.remove(a.hand,i);break end end
 a.discard[#a.discard+1]=card
 a.log[#a.log+1]={card=card,cost=cost,level=Collection.level(s,card)}
 a.choice=card;a.phase="playing"
 return response
end
function W.react(s)
 local a=W.current(s);if not a or a.phase~="playing" then return nil,"No hay carta por resolver." end
 local def=Bank.byId[a.id];local response=W.response(s,a.choice);local effect=copy(response.effects)
 local previous=a.log[#a.log-1]
 local values=Social.effects(s,a.choice,def.character,response,{emotion=a.emotion or def.emotion,previousCard=previous and previous.card})
 effect.love,effect.trust=values.love,values.trust
 effect.character=def.character;effect.context="activity";effect.text=response.rudy.." / "..response.reply
 local key=a.instance_id.."_card_"..#a.log;effect.sharedMoment=key
 local r=s.relationships[def.character];local before={love=r.love,trust=r.trust}
 local ok,err=Events.apply(s,key,effect);if not ok then return nil,err or "Carta ya aplicada." end
 a.log[#a.log].delta={love=r.love-before.love,trust=r.trust-before.trust}
 a.delta={love=r.love-a.before.love,trust=r.trust-a.before.trust};a.phase="reply";a.emotion=response.expression
 return response,key
end
function W.endConversation(s)
 local a=W.current(s);if not a or a.phase~="hand" then return nil,"Espera a que termine la respuesta." end
 a.choice=a.choice or "pass";a.ended=true;a.phase="reply"
 return W.execute(s)
end
local function gatedRewards(s,effect)
 for id in pairs(effect.copies or {}) do
  local card=Collection.byId[id];local req=card.unlockRequirements
  if not s.unlocked[id] and (not req or not s.events[req.event] or s.day<(req.day or 1)) then effect.copies[id]=nil end
 end
end
function W.finish(s,outcome,override)
 local active=W.current(s);if not active or not active.choice then return nil,"Falta resolver la carta de la actividad." end
 local def=Bank.byId[active.id];local response=W.response(s,active.choice)
 local effect=copy(override or def.effects);gatedRewards(s,effect)
 local outcomeText=def.closing or def.continuation or "La experiencia queda anotada en el diario."
 if outcome=="failure" or outcome=="retreat" then
  effect={familyProgress={attempts=1}}
  outcomeText=outcome=="failure" and "El intento no dio la recompensa material. El coste pagado se conserva en el registro."
   or "La retirada evita una lesión. No se entrega el botín de la victoria."
 elseif outcome=="no_purchase" then
  effect={};outcomeText="Terminaste la consulta sin comprar ni mejorar. No se entregó ningún artículo."
 end
 effect.decision="wife_activity_"..active.id;effect.value=active.choice
 local instance=active.instance_id;local gold=s.gold;local items=copy(Economy.ensure(s).items)
 local copies={};for id,c in pairs(Collection.ensure(s)) do copies[id]=c.copies end
 local review={id=active.id,instance=instance,day=s.day,choice=active.choice,outcome=outcome or "complete",
  reply=response.reply,expression=response.expression,continuation=outcomeText,delta=copy(active.delta),origin=copy(active.origin),
  spent=def.goldCost+(active.purchase and active.purchase.cost or 0),purchase=copy(active.purchase),cards=copy(active.log or {})}
 local ok,err=Daily.completeActivity(s,active.choice,effect,def.title..": "..outcomeText)
 if not ok then return nil,err end
 if active.before then
  local rel=s.relationships[def.character];review.delta={love=rel.love-active.before.love,trust=rel.trust-active.before.trust}
 end
 review.gold=s.gold-gold;review.items={};review.copies={}
 for id,n in pairs(s.economy.items) do if n>(items[id] or 0) then review.items[id]=n-(items[id] or 0) end end
 for id,c in pairs(s.collection) do if c.copies>(copies[id] or 0) then review.copies[id]=c.copies-(copies[id] or 0) end end
 local state=W.ensure(s);state.history[instance]=copy(review);state.review=review
 require("src.systems.objectives").sync(s)
 return review
end
function W.execute(s)
 local active=W.current(s);if not active or active.phase~="reply" then return nil,"Falta confirmar la respuesta." end
 local def=Bank.byId[active.id]
 if active.socialVersion==2 and not active.ended and #active.log<Social.maxCards then
  if #active.drawPile>0 then
   local drawn=table.remove(active.drawPile);active.hand[#active.hand+1]=drawn
   active.log[#active.log].drawn=drawn
  end
  -- Visibilidad y coste son cosas distintas: incluso con energía insuficiente
  -- se muestran las tres cartas y se permite terminar con P.
  active.phase=active.log[#active.log].drawn and "refill" or "hand"
  active.refillElapsed=0
  return true
 end
 if def.battle then active.battle=true;active.phase="battle";return true end
 if def.service then active.phase="service";return true end
 if def.challenge then active.phase="challenge";active.challenge={elapsed=0,hits={},step=1};return true end
 return W.finish(s,def.successChance and (active.experimentSuccess and "success" or "failure") or "complete")
end
function W.battleDefinition(s)
 local active=W.current(s);local d=active and Bank.byId[active.id]
 if not active or not active.battle then return end
 return {kind="magic",activity=true,title=d.title,background=d.background,
  training=d.battle=="duel",enemyId=d.enemyId or (d.battle=="duel" and "eris_training" or d.battle=="monsters" and "forest_beast" or "mana_anomaly"),
  character=d.battle=="monsters" and "eris" or nil,difficulty=d.battle=="practice" and 1 or s.day,intro=d.intro}
end
function W.finishBattle(s,enc)
 local active=W.current(s)
 if not active or not active.battle or s.combat~=enc or not enc.finished then return nil,"Combate incompleto." end
 require("src.systems.campaign_stats").finishBattle(s,enc)
 require("src.systems.companions").record(s,enc)
 local def=Bank.byId[active.id]
 if def.battle=="duel" then
  local result=require("src.systems.training").evaluate(enc)
  local e={character="eris",love=result.love,trust=result.trust,decision="activity_duel_result",value=result.id,context="activity",
   text=require("src.data.training_dialogue")[result.id].effort..": "..result.reason}
  if result.id=="suspected_throw" then e.conflict="training_effort"
  else e.reconcile="training_effort" end
  local beforeDuel={love=s.relationships.eris.love,trust=s.relationships.eris.trust}
  Events.apply(s,active.instance_id.."_duel",e)
  local battleDelta={love=s.relationships.eris.love-beforeDuel.love,trust=s.relationships.eris.trust-beforeDuel.trust}
  active.delta={love=s.relationships.eris.love-active.before.love,trust=s.relationships.eris.trust-active.before.trust}
  local effect=copy(def.effects)
  if enc.outcome~="victory" then effect.gold=8;effect.copies={staff_strike=1} end
  local review=W.finish(s,result.id,effect)
  review.continuation=e.text
  local lines=require("src.data.training_dialogue")[result.id].lines
  review.reply=lines[#lines].text;review.expression=lines[#lines].expression;review.battleDelta=battleDelta
  W.ensure(s).history[review.instance]=copy(review)
  return review
 end
 return W.finish(s,enc.outcome=="victory" and "victory" or "retreat")
end
function W.tickChallenge(s,dt)
 local a=W.current(s);if a and a.phase=="challenge" then a.challenge.elapsed=a.challenge.elapsed+math.max(0,math.min(dt,.1)) end
end
function W.hit(s)
 local active=W.current(s);if not active or active.phase~="challenge" then return nil,"No hay prueba activa." end
 local c=active.challenge;local phase=(c.elapsed%1.6)/1.6
 c.hits[#c.hits+1]=phase>=.38 and phase<=.62;c.step=c.step+1;c.elapsed=0
 if #c.hits==3 then
  local hits=0;for _,ok in ipairs(c.hits) do if ok then hits=hits+1 end end
  return W.finish(s,hits>=2 and "success" or "failure")
 end
 return true
end
function W.purchaseBook(s,id,revision)
 local active=W.current(s);local d=active and Bank.byId[active.id]
 if not d or active.phase~="service" or (d.service~="books" and d.service~="rare_books") then return nil,"No hay una consulta de libros pendiente." end
 if d.service=="rare_books" and id=="water_notes" then return nil,"Este estante contiene los títulos avanzados." end
 local receipt,err=Economy.buyBook(s,id,revision);if not receipt then return nil,err end
 for _,book in ipairs(require("src.data.books")) do if book.id==id then active.purchase={id=id,title=book.title,cost=-receipt.gold} end end
 W.finish(s,"purchase");return receipt
end
function W.purchaseItem(s,id,revision)
 local a=W.current(s);local d=a and Bank.byId[a.id]
 if not d or a.phase~="service" or (d.service~="books" and d.service~="rare_books") or id~="magic_material" then return nil,"Consulta de materiales no disponible." end
 local receipt,err=Economy.buy(s,id,revision);if not receipt then return nil,err end
 a.purchase={id=id,title=require("src.data.economy").items[id].name,cost=-receipt.gold}
 W.finish(s,"purchase");return receipt
end
function W.upgraded(s,receipt)
 local a=W.current(s)
 if a and a.id=="R04" and a.phase=="service" then
  if not receipt or not Collection.byId[receipt.cardId] or not s.economy.transactions[receipt.id]
   or receipt.kind~="upgrade_"..receipt.cardId or receipt.day~=s.day
   or Collection.level(s,receipt.cardId)~=receipt.level then return nil,"Primero confirma y paga una mejora." end
  a.purchase={id=receipt.cardId,title=Collection.byId[receipt.cardId].name.." · Nivel "..receipt.level,cost=-receipt.gold}
  return W.finish(s,"upgrade")
 end
end
function W.closeReview(s)
 local state=W.ensure(s);if not state.review then return end
 local origin=state.review.origin
 state.review=nil
 require("src.systems.objectives").sync(s)
 if s.exploration then
  if origin then for k,v in pairs(origin) do s.exploration[k]=v end end
  s.exploration.active=true
  return require("src.systems.exploration").syncPresence(s)
 end
end
-- Amplía una reserva antigua sin cambiar las cartas ya repartidas, los usos,
-- la energía ni los efectos. Sólo recupera cartas equipadas que fueron filtradas.
function W.upgradeHand(s,a)
 if a.handVersion then return end
 local candidates,excluded=W.handCandidates(s,Bank.byId[a.id],true)
 local seen={};for _,id in ipairs(a.initialOrder) do seen[id]=true end
 local added={};for _,id in ipairs(candidates) do if not seen[id] then added[#added+1]=id end end
 local function prefix(list)
  local out=copy(added);for _,id in ipairs(list) do out[#out+1]=id end;return out
 end
 local n=#added
 if n>0 then
  if a.shuffleSource then
   a.shuffleSource=prefix(a.shuffleSource)
   for _,step in ipairs(a.shuffleSteps) do step.i=step.i+n;step.j=step.j+n end
   for i=n+1,2,-1 do a.shuffleSteps[#a.shuffleSteps+1]={i=i,j=i} end
  end
  a.initialOrder=prefix(a.initialOrder)
  local pile,hand,discard=copy(a.initialOrder),{},{}
  for _=1,math.min(3,#pile) do hand[#hand+1]=table.remove(pile) end
  for i,entry in ipairs(a.log) do
   for j,id in ipairs(hand) do if id==entry.card then table.remove(hand,j);break end end
   discard[#discard+1]=entry.card
   local nextTurn=i<#a.log or a.phase=="hand" or a.phase=="refill"
   if entry.drawn or (nextTurn and i<Social.maxCards and #pile>0) then
    entry.drawn=table.remove(pile);hand[#hand+1]=entry.drawn
   end
  end
  a.drawPile,a.hand,a.discard=pile,hand,discard
 end
 -- Un mazo anterior personalizado con menos de cinco compatibles conserva
 -- su resolución; las nuevas reservas siempre exigen cinco.
 a.handVersion=#a.initialOrder>=5 and 2 or 1;a.excludedCards=excluded
end
function W.restore(s,input)
 local raw=input.wifeActivities;if raw==nil then return true end
 if type(raw)~="table" or raw.version~=1 or type(raw.encounters)~="table" or type(raw.history)~="table" then return nil,"Registro de actividades inválido." end
 local state={version=1,encounters={},history={}}
 for _,id in ipairs({"eris","roxy","sylphiette"}) do
  local n=raw.encounters[id] or 0
  if type(n)~="number" or n%1~=0 or n<0 or n>100000 then return nil,"Contador de encuentros inválido." end
  state.encounters[id]=n
 end
 local function integer(n,low,high)return type(n)=="number" and n%1==0 and n>=low and n<=high end
 local function delta(d)return type(d)=="table" and integer(d.love,-200,200) and integer(d.trust,-200,200) end
 local entries=0
 for key,r in pairs(raw.history) do
  entries=entries+1
  local d=type(r)=="table" and Bank.byId[r.id]
  if entries>21 or type(key)~="string" or not key:match("^day[1-7]_activity_[1-3]$")
   or not d or (r.choice~="pass" and not d.responses[r.choice]) or r.instance~=key or not s.events[key]
   or not integer(r.day,1,s.day) or not integer(r.gold,0,100000) or not integer(r.spent or 0,0,100000)
   or not delta(r.delta) or type(r.continuation)~="string" or #r.continuation>2000
   or not ({complete=true,success=true,failure=true,retreat=true,victory=true,honorable_defeat=true,
    honest_defeat=true,suspected_throw=true,no_purchase=true,purchase=true,upgrade=true})[r.outcome]
   or type(r.items)~="table" or type(r.copies)~="table" then return nil,"Recuerdo de actividad inválido." end
  for id,n in pairs(r.items) do if not require("src.data.economy").items[id] or not integer(n,1,10000) then return nil,"Objeto de actividad inválido." end end
  for id,n in pairs(r.copies) do if not Collection.byId[id] or not integer(n,1,10000) then return nil,"Copia de actividad inválida." end end
  if r.purchase and (type(r.purchase)~="table" or type(r.purchase.title)~="string" or #r.purchase.title>200
   or not integer(r.purchase.cost,0,100000)) then return nil,"Recibo de actividad inválido." end
  state.history[key]=copy(r)
  local response=r.choice~="pass" and d.responses[r.choice]
  local previous=r.cards and r.cards[#r.cards-1]
  local variant=response and response.after and previous and response.after[previous.card]
  state.history[key].reply=r.choice=="pass" and (d.closing or d.intro) or variant and variant.reply or response.reply
  state.history[key].expression=r.choice=="pass" and "neutral" or variant and variant.expression or response.expression
  if d.battle=="duel" and require("src.data.training_dialogue")[r.outcome] then
   local lines=require("src.data.training_dialogue")[r.outcome].lines
   state.history[key].reply=lines[#lines].text;state.history[key].expression=lines[#lines].expression
   if not delta(r.battleDelta) then return nil,"Resultado de duelo sin deltas." end
  end
 end
 if raw.review then
  if not state.history[raw.review.instance] then return nil,"Resultado de actividad sin evento." end
  state.review=copy(state.history[raw.review.instance])
 end
 s.wifeActivities=state
 local active=W.current(s)
 if active then
  local d=Bank.byId[active.id]
  if not ({intro=true,deal=true,hand=true,refill=true,playing=true,reply=true,battle=true,service=true,challenge=true})[active.phase]
   or type(active.hand)~="table" or #active.hand>3 or type(active.roll)~="number"
   or active.roll%1~=0 or active.roll<1 or active.roll>100 then return nil,"Mano o fase de actividad inválida." end
  local seen={}
  for _,id in ipairs(active.hand) do
   local equipped=false;for _,e in ipairs(s.deck) do if e==id then equipped=true end end
   if not d.responses[id] or not equipped or not s.unlocked[id] or seen[id] then return nil,"Carta ajena al mazo de la actividad." end
   seen[id]=true
  end
  if active.socialVersion==2 then
   local ok,err=W.validateSocial(s,active);if not ok then return nil,err end
   W.upgradeHand(s,active)
   ok,err=W.validateSocial(s,active);if not ok then return nil,err end
  elseif active.phase~="intro" and active.phase~="hand" and active.phase~="deal" then
   if not seen[active.choice] or not s.events[active.instance_id.."_card"] or not delta(active.before)
    or not delta(active.delta) then return nil,"Respuesta guardada sin evento." end
  end
  if d.successChance and (type(active.chance)~="number" or active.chance%1~=0 or active.chance<0 or active.chance>100
   or active.experimentSuccess~=(active.roll<=active.chance)) then return nil,"Resultado experimental inconsistente." end
  if active.battle~=(active.phase=="battle" and true or nil) then return nil,"Combate de actividad inconsistente." end
  if d.goldCost>0 then
   local receipt=s.economy.transactions[active.receipt]
   if not receipt or receipt.gold~=-d.goldCost or receipt.kind~="wife_activity:"..d.id then return nil,"Falta el pago de la actividad." end
  end
  if active.phase=="challenge" then
   local c=active.challenge
   if type(c)~="table" or type(c.elapsed)~="number" or c.elapsed<0 or type(c.hits)~="table"
   or c.elapsed~=c.elapsed or c.elapsed>100000 or #c.hits>2 or c.step~=#c.hits+1 then return nil,"Prueba de ritmo inválida." end
   for _,hit in ipairs(c.hits) do if type(hit)~="boolean" then return nil,"Pulsación inválida." end end
  end
 end
 if s.exploration then
  if active or state.review then s.exploration.period="day";s.exploration.periodDay=s.day end
  require("src.systems.exploration").syncPresence(s)
 end
 return true
end
function W.validateSocial(s,a)
 local function fail() return nil,"Mazo, energía o respuesta social inconsistente." end
 local function same(x,y)
  if type(x)~="table" or #x~=#y then return false end
  for i,v in ipairs(y) do if x[i]~=v then return false end end;return true
 end
 if type(a.initialOrder)~="table" or #a.initialOrder<1 or #a.initialOrder>10
  or type(a.log)~="table" or #a.log>Social.maxCards or a.maxEnergy~=Social.energy or a.maxCards~=Social.maxCards
  or type(a.before)~="table" or type(a.delta)~="table" then return fail() end
 if a.handVersion and a.handVersion~=1 and a.handVersion~=2 then return fail() end
 if a.handVersion==2 and #a.initialOrder<5 then return fail() end
 -- Los requisitos de entrada se evaluaron antes de repartir. Una respuesta
 -- puede cambiar un evento requerido sin invalidar el mazo ya guardado.
 local allowed={};for _,id in ipairs(W.handCandidates(s,Bank.byId[a.id],true)) do allowed[id]=true end
 local seen={}
 for _,id in ipairs(a.initialOrder) do if not allowed[id] or seen[id] then return fail() end;seen[id]=true end
 if a.shuffleSource then
  if type(a.shuffleSteps)~="table" or #a.shuffleSteps~=#a.shuffleSource-1 then return fail() end
  local shuffled=copy(a.shuffleSource)
  for n,step in ipairs(a.shuffleSteps) do
   if type(step)~="table" or step.i~=#shuffled-n+1 or type(step.j)~="number" or step.j%1~=0 or step.j<1 or step.j>step.i then return fail() end
   shuffled[step.i],shuffled[step.j]=shuffled[step.j],shuffled[step.i]
  end
  if not same(shuffled,a.initialOrder) then return fail() end
 end
 local pile,hand,discard=copy(a.initialOrder),{},{}
 for i=1,math.min(3,#pile) do hand[i]=table.remove(pile) end
 local energy=Social.energy
 for i,entry in ipairs(a.log) do
  if type(entry)~="table" or not allowed[entry.card] or entry.cost~=Social.cost(entry.card,Bank.byId[a.id].character) then return fail() end
  local index;for j,id in ipairs(hand) do if id==entry.card then index=j end end
  if not index then return fail() end
  table.remove(hand,index);discard[#discard+1]=entry.card;energy=energy-entry.cost
  if energy<0 then return fail() end
  local applied=s.events[a.instance_id.."_card_"..i]==true
  if (a.phase=="playing" and i==#a.log) then if applied then return fail() end
  elseif not applied or type(entry.delta)~="table" then return fail() end
  if entry.drawn then
   if i>=Social.maxCards then return fail() end
   if entry.drawn~=table.remove(pile) then return fail() end
   hand[#hand+1]=entry.drawn
  end
 end
 if a.energy~=energy or not same(a.hand,hand) or not same(a.drawPile,pile) or not same(a.discard,discard) then return fail() end
 if #a.log>0 and a.choice~=a.log[#a.log].card then return fail() end
 if #a.log==0 and a.choice and a.choice~="pass" then return fail() end
 if #a.log>0 and (a.phase=="intro" or a.phase=="deal") then return fail() end
 if a.phase=="hand" and #a.log>=Social.maxCards then return fail() end
 if a.handVersion==2 and (a.phase=="hand" or a.phase=="refill") and #a.hand~=3 then return fail() end
 return true
end
return W
