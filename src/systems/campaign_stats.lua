-- Monetary/item totals come from receipts and stock, never from estimated rewards.
-- Battles need an explicit ledger: defeatedEnemies alone loses retries and repeats.
local Stats={wives={"sylphiette","roxy","eris"}}
local function count(t) local n=0;for _ in pairs(t or {}) do n=n+1 end;return n end
local function integer(n,lo,hi) return type(n)=="number" and n%1==0 and n>=lo and n<=hi end
function Stats.new(s,complete)
 local initial={}
 if complete then for _,id in ipairs(Stats.wives) do
  local r=s.relationships[id];initial[id]={love=r.love,trust=r.trust}
 end end
 return {version=1,complete=complete==true,initial=initial,sequence=0,battles={}}
end
function Stats.ensure(s)
 s.campaignStats=s.campaignStats or Stats.new(s,false)
 return s.campaignStats
end
local function source(s)
 local activity=s.daily and s.daily.active_activity
 return activity and activity.instance_id or s.checkpoint
end
function Stats.beginBattle(s,enc)
 local ledger=Stats.ensure(s);local active=ledger.active
 if active and active.source==source(s) and active.enemy==enc.enemy.id then
  if not active.outcome or enc.finished then return active end
 end
 ledger.sequence=ledger.sequence+1
 active={id=tostring(ledger.sequence),source=source(s),enemy=enc.enemy.id,day=s.day}
 ledger.active=active
 return active
end
function Stats.finishBattle(s,enc)
 if not enc or not enc.finished or (enc.outcome~="victory" and enc.outcome~="defeat") then return false end
 local ledger=Stats.ensure(s);local record=Stats.beginBattle(s,enc)
 if ledger.battles[record.id] then return false end
 record.outcome=enc.outcome;record.turns=enc.turn;record.training=enc.training~=nil and enc.training~=false
 local activity=s.daily and s.daily.active_activity
 local def=activity and require("src.data.activities").byId[activity.id]
 if enc.enemy.id=="badigadi_training" or (def and def.battle=="practice") then record.training=true end
 record.narrative=enc.narrativeDefeat~=nil and enc.narrativeDefeat~=false;record.allies={}
 for id in pairs(enc.allies or {}) do record.allies[id]=true end
 ledger.battles[record.id]=record
 return true
end
function Stats.restore(s,input)
 local raw=input.campaignStats
 if raw==nil then s.campaignStats=Stats.new(s,false);return true end
 if type(raw)~="table" or raw.version~=1 or type(raw.complete)~="boolean" or not integer(raw.sequence,0,10000)
  or type(raw.initial)~="table" or type(raw.battles)~="table" then return nil,"Registro estadístico inválido." end
 local out=Stats.new(s,false);out.complete=raw.complete;out.sequence=raw.sequence
 for _,id in ipairs(Stats.wives) do
  local r=raw.initial[id]
  if r then
   if type(r)~="table" or not integer(r.love,-100,100) or not integer(r.trust,-100,100) then return nil,"Relación inicial inválida." end
   out.initial[id]={love=r.love,trust=r.trust}
  elseif raw.complete then return nil,"Falta la relación inicial." end
 end
 local function record(v)
  if type(v)~="table" or type(v.id)~="string" or not integer(tonumber(v.id),1,raw.sequence)
   or type(v.source)~="string" or #v.source>150 or not require("src.data.enemies").byId[v.enemy]
   or not integer(v.day,1,s.day) then return nil end
  local r={id=v.id,source=v.source,enemy=v.enemy,day=v.day}
  if v.outcome then
   if not ({victory=true,defeat=true})[v.outcome] or not integer(v.turns,1,10000)
    or type(v.allies)~="table" or type(v.training)~="boolean" or type(v.narrative)~="boolean" then return nil end
   r.outcome=v.outcome;r.turns=v.turns;r.training=v.training;r.narrative=v.narrative;r.allies={}
   for _,id in ipairs(Stats.wives) do if v.allies[id]==true then r.allies[id]=true end end
  end
  return r
 end
 for key,v in pairs(raw.battles) do
  local r=record(v)
  if not r or key~=r.id or not r.outcome then return nil,"Combate estadístico inválido." end
  out.battles[key]=r
 end
 if raw.active then
  local r=record(raw.active)
  if not r or tonumber(r.id)~=raw.sequence or (r.outcome and not out.battles[r.id]) then return nil,"Intento de combate inválido." end
  out.active=out.battles[r.id] or r
 end
 s.campaignStats=out;return true
end
function Stats.snapshot(s)
 local ledger=Stats.ensure(s)
 local g={goldEarned=0,goldSpent=0,gold=s.gold,unlocked=0,duplicates=0,levelsGained=0,maxLevel=0,
  enemiesDefeated=0,defeats=0,training=0,narrativeDefeats=0,commissionsSuccess=0,commissionsFailure=0,
  hiddenObjects=count(s.worldContent and s.worldContent.collected),manaFragments=(s.economy.items.mana_fragment or 0),
  orsted=s.events.orsted_demonstration_completed==true,antidote=s.events.antidote_obtained==true,
  ending=require("src.systems.relationships").ending(s.relationships),battleHistoryComplete=ledger.complete}
 -- The day-three fragment is installed directly in the artifact, not bag stock.
 if s.events.ruins_mission and s.clues.mana_fragment then g.manaFragments=g.manaFragments+1 end
 local result={general=g,wives={}}
 for _,receipt in pairs(s.economy.transactions) do
  g.goldEarned=g.goldEarned+math.max(0,receipt.gold or 0);g.goldSpent=g.goldSpent-math.min(0,receipt.gold or 0)
  if receipt.cardId and receipt.level then g.duplicates=g.duplicates+(receipt.copies or 0) end
  if receipt.kind=="use_mana_fragment" then g.manaFragments=g.manaFragments+1 end
 end
 for _,entry in pairs(s.collection) do if entry.unlocked then
  g.unlocked=g.unlocked+1;g.duplicates=g.duplicates+entry.copies;g.levelsGained=g.levelsGained+entry.level-1
  if entry.level==10 then g.maxLevel=g.maxLevel+1 end
 end end
 for _,favor in ipairs(s.pending_favors or {}) do if favor.status=="delivered" and favor.investment then
  if favor.success then g.commissionsSuccess=g.commissionsSuccess+1 else g.commissionsFailure=g.commissionsFailure+1 end
 end end
 for _,id in ipairs(Stats.wives) do
  local r=s.relationships[id];local initial=ledger.initial[id] or (s.daily_history["1"] and s.daily_history["1"].before[id])
  local w={initialLove=initial and initial.love,initialTrust=initial and initial.trust,love=r.love,trust=r.trust,
   daysVisited=0,interactions=0,nights=0,kept=0,broken=0,combats=0,reconciliations=0,
   state=r.marriageState,events={},visitedDays={}}
  result.wives[id]=w
  for day=1,7 do
   local report=s.daily_history[tostring(day)] or (s.daily.day==day and s.daily)
   local visits=report and report.visits[id] or 0
   if visits>0 then w.daysVisited=w.daysVisited+1;w.interactions=w.interactions+visits;w.visitedDays[#w.visitedDays+1]=day end
   local night=s.rest and s.rest.nights[tostring(day)]
   if night and night.wife==id then w.nights=w.nights+1 end
  end
  local kept,broken,pending={},{},{}
  for _,entry in ipairs(r.history) do
   if entry.promiseStatus=="kept" then kept[entry.promise]=true end
   if entry.promiseStatus=="broken" then broken[entry.promise]=true;pending[entry.promise]=true end
   if entry.conflict then pending[entry.conflict]=true end
   if entry.reconcile and pending[entry.reconcile] then
    pending[entry.reconcile]=nil;w.reconciliations=w.reconciliations+1
   end
  end
  for key,status in pairs(r.promises) do if status=="kept" then kept[key]=true end end
  for key in pairs(r.brokenPromises) do broken[key]=true end
  w.kept=count(kept);w.broken=count(broken)
  for _,entry in ipairs(s.journal) do if entry.character==id and not entry.hidden then
   w.events[#w.events+1]={day=entry.day,text=entry.text}
  end end
 end
 for _,b in pairs(ledger.battles) do
  if b.narrative then g.narrativeDefeats=g.narrativeDefeats+1
  elseif b.training then g.training=g.training+1
  elseif b.outcome=="victory" then g.enemiesDefeated=g.enemiesDefeated+1 end
  if b.outcome=="defeat" and not b.narrative then g.defeats=g.defeats+1 end
  for id in pairs(b.allies) do result.wives[id].combats=result.wives[id].combats+1 end
 end
 return result
end
return Stats
