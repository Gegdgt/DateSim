local D={}
local W=require("src.systems.wife_activities")
function D.fresh(day,seed)
 local s=require("src.systems.prologue").start(require("src.systems.save").newSession())
 require("src.systems.prologue").wake(s)
 local Events=require("src.systems.events")
 Events.apply(s,"starter_gift",{starter=true});Events.mark(s,"first_anomaly");Events.mark(s,"tutorial_completed");Events.mark(s,"combat_tutorial_completed");Events.mark(s,"nanahoshi_conversation_started")
 Events.apply(s,"hitogami_letter_read",{clue="hitogami_letter"})
 for _,id in ipairs({"letter_read","letter_collected","curse_discovered","nanahoshi_visited","starting_cards_received","wake_departed"}) do s.prologue[id]=true end
 s.day=day or 1;s.checkpoint="day"..s.day.."_agenda";s.rewardQueue={}
 require("src.systems.daily").ensure(s)
 require("src.systems.world_content").ensure(s).seed=seed or 273
 require("src.systems.exploration").syncPresence(s)
 return s
end
function D.approach(s,id)
 require("tests.campaign_world_driver").greet(s,id)
 return s.exploration.npcLocations[id]
end
function D.startWithHand(id,wanted)
 for seed=1,100 do
  local s=D.fresh(1,seed);D.approach(s,W.bank.byId[id].character)
  local a=assert(W.start(s,id,s.economy.revision));local found={}
  for _,card in ipairs(a.hand) do found[card]=true end
  local ready=true;for _,card in ipairs(wanted or {}) do if not found[card] then ready=false end end
  if ready then return s,a end
 end
 error("No apareció la mano de prueba para "..id)
end
function D.play(s,id)
 local a=W.current(s);a.phase="hand"
 assert(W.choose(s,id or a.hand[1]));assert(W.react(s))
 return a
end
function D.close(s)
 local a=W.current(s)
 a.ended=true
 assert(W.execute(s))
 return W.ensure(s).review
end
function D.round(s)
 local Json=require("src.systems.json")
 return assert(require("src.systems.save").validate(assert(Json.decode(assert(Json.encode(s))))))
end
return D
