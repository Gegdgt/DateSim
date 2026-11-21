local Suite={}
local wives={"sylphiette","roxy","eris"}
local profiles={
 {id="balanced",name="Una visita a cada esposa"},
 {id="eris_only",name="Tres entrenamientos con Eris",dailyWife="eris",activity="eris_physical",choice="practice"},
 {id="roxy_only",name="Tres estudios con Roxy",dailyWife="roxy"},
 {id="sylphiette_only",name="Tres actividades con Sylphiette",dailyWife="sylphiette"},
 {id="gold",name="Priorizar oro",dailyWife="eris",activity="eris_monsters",choice="together",spending="none"},
 {id="upgrades",name="Priorizar dos mejoras",specialize=true,useBooks=true},
 {id="without_orsted",name="Progreso sin Orsted",skipErisTraining=true},
 {id="with_orsted",name="Aprovechar el regalo de Orsted",orstedCards={combat="water_cannon",social="encourage"}},
 {id="lose_one",name="Desatender a Eris",alternate=true},
 {id="lose_two",name="Desatender a Sylphiette y Eris",dailyWife="roxy",dismiss={sylphiette=true,eris=true}},
 {id="lose_three",name="Desatender a las tres",skipActivities=true,dismiss={sylphiette=true,roxy=true,eris=true}},
}
Suite.profiles=profiles
function Suite.run()
 local configs={};local filter=os.getenv("DATESIM_BALANCE_PROFILE")
 local requested=tonumber(os.getenv("DATESIM_BALANCE_SEED"))
 assert(not requested or requested>0 and requested<2147483647 and requested%1==0,"Semilla entera entre 1 y 2147483646")
 for _,p in ipairs(profiles)do if not filter or filter==p.id then for _,seed in ipairs(requested and {requested} or {17,43,97})do
  local c={keep={},preferred=p.dailyWife or "roxy",companion=p.dailyWife or "roxy",favors=true,accelerateFinal=false,id=p.id,seed=seed}
  for k,v in pairs(p)do c[k]=v end
  for _,wife in ipairs(wives)do c.keep[wife]=not (p.dismiss and p.dismiss[wife])end
  if p.alternate then
   c.activityPlan=function(s)local id=({"sylphiette","roxy"})[(s.daily.interactions_used+s.day)%2+1];return "time_"..id,"together"end
  elseif p.activity then c.activityPlan=function()return p.activity,p.choice end end
  configs[#configs+1]=c
 end end end
 local results,checks=require("tests.campaign").run(configs)
 local rows={"strategy,seed,earned,spent,gold,cards,copies,max_level,levels_upgraded,separations,max_card_damage,healing_cards,orsted,boss_win,boss_turns,boss_hp,boss_dpt,boss_healing,boss_shield,ending,sylphiette_love,sylphiette_trust,roxy_love,roxy_trust,eris_love,eris_trust"}
 for _,r in ipairs(results)do
  local level,upgraded=1,0;for _,v in pairs(r.levels)do level=math.max(level,v);if v>1 then upgraded=upgraded+1 end end
  local b=r.metrics.boss or {};local cols={r.strategy,r.seed,r.earned,r.spent,r.gold,r.cards,r.copies,level,upgraded,r.separations,r.maxDamage,r.healingCards,tostring(r.orsted),tostring(b.outcome=="victory"),b.turns or 0,b.hp or 0,string.format("%.2f",b.damagePerTurn or 0),b.healing or 0,b.shield or 0,r.ending}
  for _,id in ipairs(wives)do cols[#cols+1]=r.relations[id].love;cols[#cols+1]=r.relations[id].trust end
  for i,v in ipairs(cols)do cols[i]=tostring(v)end;rows[#rows+1]=table.concat(cols,",")
  assert(r.gold>=0 and level<=10,"Recursos y niveles acotados")
 end
 local suffix=filter and ("-"..filter) or ""
 local root=love.filesystem.getSource().."/tests/artifacts/seven-day-balance"..suffix
 local file=assert(io.open(root..".csv","wb"));file:write(table.concat(rows,"\n"));file:close()
 file=assert(io.open(root..".json","wb"));file:write(assert(require("src.systems.json").encode(results)));file:close()
 print("Seven-day balance: "..checks.." checks; "..#results.." seeded campaigns; metrics in tests/artifacts/seven-day-balance"..suffix..".csv")
 return checks
end
return Suite
