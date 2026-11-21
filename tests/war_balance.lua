local Suite={}
local Combat=require("src.systems.combat")
local C=require("src.systems.companions")
local function incoming(enc) local a=enc.enemy.intent;return a.kind=="attack" and a.damage*(a.hits or 1) or 0 end
function Suite.step(enc,execute)
 local function act(name,...) if execute then return execute(name,...) end;return Combat[name](enc,...) end
 if Combat.canBreakSeal(enc) then return act("breakSeal") end
 for _,wife in ipairs(C.order)do if enc.allies[wife] and not enc.supportUsed[wife] then
  local id="attack"
  local need=math.max(0,incoming(enc)-enc.player.shield)
  if wife=="sylphiette" and C.affinity(enc.allies[wife])>=25 and enc.player.hp<=enc.player.maxHp-6 and Combat.canSupport(enc,wife,"heal") then id="heal"
  elseif wife=="roxy" and enc.enemy.phase=="resolve" and enc.enemy.exposed==0 and Combat.canSupport(enc,wife,"analyze") then id="analyze"
  elseif wife=="eris" and need>=5 and Combat.canSupport(enc,wife,"interrupt") then id="interrupt"
  elseif Combat.canSupport(enc,wife,"special") then id="special"
  elseif wife=="sylphiette" and need>=5 and Combat.canSupport(enc,wife,"guard") then id="guard"
  elseif wife=="eris" and Combat.canSupport(enc,wife,"strong") then id="strong"
  elseif wife=="roxy" and need>=5 and Combat.canSupport(enc,wife,"analyze") then id="analyze"
  end
  if Combat.canSupport(enc,wife,id) then return act("support",wife,id,enc.revision) end
 end end
 local index,basic,best=nil,nil,0
 local needed=math.max(0,incoming(enc)-enc.player.shield)
 for i,id in ipairs(enc.hand)do if Combat.canPlay(enc,i)then
  local card=Combat.card(id,enc);local p=Combat.preview(enc,i);local e=card.effects
  local score=(p.hpLost or 0)+math.min(e.shield or 0,needed)*3.2+math.min(e.heal or 0,enc.player.maxHp-enc.player.hp)*3
  if e.weak and incoming(enc)>0 and enc.enemy.weak<e.weak then score=score+math.min(needed,2*(enc.enemy.intent.hits or 1))*3.2 end
  score=score-(card.hpCost or 0)*2
  score=score/math.max(1,card.cost)
  if score>best then best,index,basic=score,i,nil end
 end end
 for _,id in ipairs({"defend","dodge"})do
  local score=math.min(needed,id=="defend" and 5 or 3)*3.2
  if Combat.canBasic(enc,id) and score>best then best,index,basic=score,nil,id end
 end
 if basic then return act("basic",basic) elseif index then return act("play",index) end
 return act("endTurn")
end
function Suite.solve(enc)
 for _=1,800 do if enc.finished then return enc end;assert(Suite.step(enc))end
 error("Combate bloqueado")
end
Suite.deck={"staff_strike","water_projectile","magic_bolt","arcane_guard","earth_wall","swamp","heal","coordinated_attack","water_cannon","heavy_spell"}
function Suite.make(level,count,affinity,seed,enemy,day,mask)
 local context={enemyId=enemy or "badigadi_final",day=day or 7,combatDeck=Suite.deck,curse={active=true,manaBlocked=true},externalEnergy=30,cardLevels={},team={},relationships={}}
 for _,id in ipairs(Suite.deck)do context.cardLevels[id]=level end
 for i,id in ipairs(C.order)do context.team[id]=mask~=nil and math.floor(mask/2^(i-1))%2==1 or mask==nil and i<=count;context.relationships[id]={love=affinity,trust=affinity,marriageState="married"}end
 return Combat.new({},context,function()return seed end),context
end
function Suite.run()
 local checks=0;local rows={"level,mask,wives,affinity,seeds,wins,mean_turns,mean_hp,mean_damage_per_turn,mean_healing,mean_shield"}
 local function check(ok,msg)assert(ok,msg);checks=checks+1 end
 for _,level in ipairs({1,5,10})do for mask=0,7 do
  local count=0;for i=1,3 do count=count+math.floor(mask/2^(i-1))%2 end
  for _,affinity in ipairs({20,50,90})do
  local wins,turns,hp,damage,healing,shield=0,0,0,0,0,0
  for seed=1,8 do
   local enc=Suite.solve(Suite.make(level,count,affinity,seed*17,nil,nil,mask))
   check(enc.finished and enc.turn<=75,"Encuentro termina dentro del límite")
   check(enc.enemy.maxHp==1000 and enc.player.hp>=0 and enc.player.hp<=30,"PV y jefe invariantes")
   if enc.outcome=="victory" then wins=wins+1 end
   turns=turns+enc.turn;hp=hp+enc.player.hp;damage=damage+(1000-enc.enemy.hp)/enc.turn
   for _,log in ipairs(enc.log)do for _,event in ipairs(log.events or {})do
    if event.kind=="heal" and event.target=="player" then healing=healing+event.amount end
    if event.kind=="shield" and event.target=="player" then shield=shield+event.amount end
   end end
  end
  if level>=5 then check(wins==8,"Estrategia viable con cartas medias/altas para cada composición")end
  rows[#rows+1]=string.format("%d,%d,%d,%d,8,%d,%.2f,%.2f,%.2f,%.2f,%.2f",level,mask,count,affinity,wins,turns/8,hp/8,damage/8,healing/8,shield/8)
  print(rows[#rows])
 end end end
 local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/war-balance.csv","wb"));file:write(table.concat(rows,"\n"));file:close()
 print("War balance: "..checks.." checks; 576 seeded boss simulations, all eight family compositions.")
 return checks
end
return Suite
