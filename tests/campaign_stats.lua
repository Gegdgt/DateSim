local Suite={}
function Suite.run()
 local Save=require("src.systems.save");local Stats=require("src.systems.campaign_stats")
 local Events=require("src.systems.events");local Collection=require("src.systems.card_collection")
 local Economy=require("src.systems.economy");local Json=require("src.systems.json")
 local count=0
 local function check(v,m) assert(v,m);count=count+1 end
 local function clone(v) return assert(Json.decode(assert(Json.encode(v)))) end
 local s=Save.newSession()
 local before=Stats.snapshot(s)
 check(before.wives.eris.initialLove==50 and before.general.goldEarned==0,"Initial values are observed, starting gold is not income")
 Events.apply(s,"stats_reward",{gold=30,copies={listen=6},items={mana_fragment=3},character="roxy",promise={id="test",status="kept"}})
 check(not Events.apply(s,"stats_reward",{gold=30}),"Reward idempotent")
 local purchase=assert(Collection.upgrade(s,"listen",s.economy.revision))
 assert(Economy.use(s,"mana_fragment",nil,s.economy.revision))
 local total=Stats.snapshot(s)
 check(total.general.goldEarned==30 and total.general.goldSpent==-purchase.receipt.gold,"Actual receipts close the balance")
 check(total.general.gold==120+30-total.general.goldSpent,"Balance includes initial capital once")
 check(total.general.duplicates==5 and total.general.levelsGained==1,"Consumed copies still counted, unlock excluded")
 check(total.general.manaFragments==3,"Consumed fragments counted via receipts")
 Events.apply(s,"ruins_mission",{clue="mana_fragment",externalEnergy=12})
 check(Stats.snapshot(s).general.manaFragments==4,"Story fragment installed in artifact is also counted once")
 check(total.wives.roxy.kept==1,"Promise has actual memory")
 Events.apply(s,"stats_conflict",{character="roxy",conflict="care"})
 Events.apply(s,"stats_repair",{character="roxy",reconcile="care"})
 Events.apply(s,"stats_repair_again",{character="roxy",reconcile="care"})
 check(Stats.snapshot(s).wives.roxy.reconciliations==1,"Only a resolved conflict counts, not an empty repeated effect")
 local enc={enemy={id="forest_beast"},finished=false,turn=1,allies={eris={}},outcome=nil}
 Stats.beginBattle(s,enc);enc.finished=true;enc.outcome="defeat";enc.turn=3
 check(Stats.finishBattle(s,enc),"Loss recorded before retry")
 check(not Stats.finishBattle(s,enc),"Same result does not duplicate")
 s=assert(Save.validate(clone(s)))
 check(not Stats.finishBattle(s,enc),"Loading result does not duplicate")
 enc.finished=false;enc.outcome=nil;enc.turn=1;Stats.beginBattle(s,enc)
 enc.finished=true;enc.outcome="victory";enc.turn=7;Stats.finishBattle(s,enc)
 total=Stats.snapshot(s)
 check(total.general.defeats==1 and total.general.enemiesDefeated==1 and total.wives.eris.combats==2,"Retry is a separate attempt")
 enc={enemy={id="orsted_demonstration"},finished=true,outcome="defeat",turn=4,narrativeDefeat="orsted_demonstration",allies={}}
 Stats.finishBattle(s,enc);total=Stats.snapshot(s)
 check(total.general.defeats==1 and total.general.narrativeDefeats==1,"Orsted does not invent a real defeat")
 local restored=assert(Save.validate(clone(s)))
 check(Json.encode(Stats.snapshot(restored))==Json.encode(total),"All summary values survive roundtrip")
 local legacy=clone(s);legacy.campaignStats=nil
 restored=assert(Save.validate(legacy))
 check(not Stats.snapshot(restored).general.battleHistoryComplete,"Legacy lacks battle telemetry, explicitly reported")
 check(Stats.snapshot(restored).wives.eris.initialLove==nil,"Unknown initial statistic not invented")
 for _,bad in ipairs({-1,0/0,10001,"1"}) do
  local tampered=clone(s);tampered.campaignStats.sequence=bad
  check(not Save.validate(tampered),"Invalid sequence rejected")
 end
 local invalid=clone(s);invalid.campaignStats.battles["1"].enemy="unknown"
 check(not Save.validate(invalid),"Invalid battle rejected")
 print("Campaign statistics: "..count.." checks passed.")
 return count
end
return Suite
