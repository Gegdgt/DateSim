local Metrics={}
local Collection=require("src.systems.card_collection")
local Json=require("src.systems.json")
local function copy(v)return assert(Json.decode(assert(Json.encode(v))))end
function Metrics.day(s,m)
 m.days[#m.days+1]={day=s.day,gold=s.gold,visits=copy(s.daily.visits),relations=copy(s.relationships)}
end
function Metrics.battle(s,e,m)
 local entry={day=s.day,id=e.enemy.id,turns=e.turn,outcome=e.outcome,hp=e.player.hp,maxHp=e.enemy.maxHp,healing=0,shield=0,maxHit=0,damage=0,team={}}
 for id in pairs(e.allies)do entry.team[#entry.team+1]=id end;table.sort(entry.team)
 for _,log in ipairs(e.log)do for _,v in ipairs(log.events or {})do
  if v.kind=="damage" and v.target=="enemy" then entry.maxHit=math.max(entry.maxHit,v.hpLost or 0);entry.damage=entry.damage+(v.hpLost or 0)end
  if v.kind=="heal" and v.target=="player" then entry.healing=entry.healing+(v.amount or 0)end
  if v.kind=="shield" and v.target=="player" then entry.shield=entry.shield+(v.amount or 0)end
 end end
 entry.damagePerTurn=entry.damage/e.turn;m.battles[#m.battles+1]=entry
 if e.enemy.id=="badigadi_final" then m.boss=entry end
end
function Metrics.finish(s,ending,visited,config)
 local result={strategy=config.id,seed=config.seed,ending=ending or "defeat",gold=s.gold,earned=0,spent=0,cards=0,copies=0,levels={},relations={},separations=0,maxDamage=0,healingCards=0,
  orsted=visited.day6_orsted_arrival==true,metrics=config.metrics}
 for _,receipt in pairs(s.economy.transactions)do if receipt.gold>0 then result.earned=result.earned+receipt.gold else result.spent=result.spent-receipt.gold end end
 for _,card in ipairs(Collection.list)do
  local v=Collection.view(s,card.id)
  if v.unlocked then
   result.cards=result.cards+1;result.copies=result.copies+v.copies;result.levels[card.id]=v.level
   local owner=card.conditions and card.conditions.character
   if not owner or s.relationships[owner].marriageState~="separated" then
    result.maxDamage=math.max(result.maxDamage,v.combatEffect and v.combatEffect.damage or 0)
    if v.combatEffect and v.combatEffect.heal then result.healingCards=result.healingCards+1 end
   end
  end
 end
 for _,id in ipairs({"sylphiette","roxy","eris"})do
  local r=s.relationships[id];result.relations[id]={love=r.love,trust=r.trust,state=r.marriageState}
  if r.marriageState=="separated" then result.separations=result.separations+1 end
 end
 assert(s.gold==require("src.data.economy").startingGold+result.earned-result.spent,"El balance contable debe cerrar")
 return result
end
return Metrics
