local Suite={}
function Suite.run()
 local Combat=require("src.systems.combat");local C=require("src.systems.companions")
 local Sim=require("tests.war_balance");local Json=require("src.systems.json");local Save=require("src.systems.save")
 local checks=0;local function check(ok,msg)assert(ok,msg);checks=checks+1 end
 for _,a in ipairs({24.99,25,49,50,79,80,89,90,100,-100})do
  for id,base in pairs({sylphiette=90,eris=150,roxy=110})do
   local r={love=a,trust=a};local expected=math.floor(base*math.max(0,math.min(100,a))/100+.5)
   check(C.damage(base,r)==expected,"Fórmula de daño: "..id.." / "..a)
   local attack=Sim.make(5,3,a,17)
   assert(Combat.support(attack,id,"special",attack.revision))
   check(1000-attack.enemy.hp==expected,"Daño real según afinidad: "..id)
  end
  local e=Sim.make(5,3,a,17);e.player.hp=15
  local expected=a>=90 and 12 or a>=80 and 9 or a>=50 and 6 or a>=25 and 3 or -12
  local p=Combat.supportPreview(e,"sylphiette","heal")
  check((expected<0 and p.risk and p.riskDamage==12)or p.heal==expected,"Umbral de curación: "..a)
  local revision=e.revision
  if expected<0 then check(not Combat.support(e,"sylphiette","heal",revision),"Riesgo exige confirmar")end
  check(Combat.support(e,"sylphiette","heal",revision,true),"Habilidad válida")
  check(e.player.hp==15+expected,"Cambio real de PV")
  check(not Combat.support(e,"sylphiette","heal",revision,true),"No duplicar acción")
 end
 local e,ctx=Sim.make(5,3,90,17);check(Combat.support(e,"eris","special",e.revision),"Especial")
 check(e.energy==3 and not Combat.canSupport(e,"eris","attack"),"Apoyo tiene cupo propio")
 local guard=Sim.make(5,3,90,17)
 assert(Combat.support(guard,"eris","guard"))
 check(guard.player.physicalShield==5 and guard.player.magicShield==0,"Eris protege físicamente")
 Combat.endTurn(guard)
 check(guard.player.shield==0,"La protección expira después del ataque enemigo")
 local restored=Combat.restore(assert(Json.decode(assert(Json.encode(e)))),{},ctx)
 check(restored and restored.enemy.hp==e.enemy.hp,"Replay guarda daño, usos y recarga")
 local cooldown=Sim.make(5,3,100,17)
 for use=1,3 do
  check(Combat.support(cooldown,"eris","special",cooldown.revision),"Uso limitado "..use)
  for wait=1,3 do
   if Combat.canBasic(cooldown,"defend")then Combat.basic(cooldown,"defend")end
   if Combat.canBasic(cooldown,"dodge")then Combat.basic(cooldown,"dodge")end
   Combat.endTurn(cooldown)
   if wait<3 then check(not Combat.canSupport(cooldown,"eris","special"),"Recarga impide repetir especial")end
  end
 end
 check(not Combat.canSupport(cooldown,"eris","special"),"Tres usos no se recargan con los turnos")
 local full=Sim.make(5,1,100,17);full.player.hp=29
 assert(Combat.support(full,"sylphiette","heal",full.revision))
 check(full.player.hp==30,"Curación recortada a la vida máxima")
 check(C.damage(150,{love=100,trust=0})==75,"Promedia amor y confianza, no solo una estadística")
 local shatter=Sim.make(5,3,100,17)
 shatter.enemy.phase="resolve";shatter.enemy.hp=300;shatter.enemy.shield=8
 local predicted=Combat.supportPreview(shatter,"roxy","shatter").hpLost
 assert(Combat.support(shatter,"roxy","shatter"))
 check(300-shatter.enemy.hp==predicted and predicted==10,"La vista previa incluye disolver escudo y exponer antes del daño")
 e=Sim.make(5,1,24.99,17);e.player.hp=10;Combat.support(e,"sylphiette","heal",e.revision,true)
 check(e.outcome=="defeat" and e.player.hp==0,"Interferencia puede derrotar")
 local valid,errors=require("src.systems.narrative_validator").validate(require("src.data.chapters"),{checkFiles=false})
 check(valid,table.concat(errors,"; "))
 check(require("src.data.chapters").get("day7_boss").day==7,"Jefe final en día siete")
 local Progression=require("src.systems.progression")
 local optional=Save.newSession();optional.day=6;optional.checkpoint="day6_orsted_offer"
 check(not Progression.choose(optional,optional.checkpoint,"accept"),"Orsted requiere investigar las runas")
 optional.decisions.observatory_research="tested"
 check(Progression.choose(optional,optional.checkpoint,"accept"),"Investigación habilita prueba opcional")
 check(Progression.next(optional,optional.checkpoint)=="day6_orsted","La decisión conecta con Orsted")
 optional.combat=Sim.make(5,0,50,17,"orsted_trial",6)
 while not optional.combat.finished do Combat.endTurn(optional.combat)end
 local trial=optional.combat;local gold=optional.gold
 check(Progression.finishCombat(optional,trial)=="day6_close","Perder contra Orsted continúa sin bloquear la campaña")
 check(optional.gold==gold and not optional.inventory.antidote,"Derrota opcional no entrega premios ni antídoto")
 local previousHp=0
 for day=1,6 do
  local enemy=require("src.data.enemies").resolve("forest_beast",{day=day})
  check(enemy.maxHp>previousHp,"PV progresivos por día");previousHp=enemy.maxHp
  for seed=1,6 do
   local trial=Sim.solve(Sim.make(math.max(1,day-1),0,50,seed*19,"forest_beast",day))
   check(trial.finished,"Enemigo intermedio sin bloqueos")
   check(trial.outcome=="victory","Intermedio ganable: día "..day.." semilla "..seed)
  end
 end
 e,ctx=Sim.make(5,3,100,17)
 ctx.relationships.eris.marriageState="separated"
 local absent=Combat.new({},ctx,function()return 17 end)
 check(not absent.allies.eris and not Combat.canSupport(absent,"eris","special"),"Separación excluye todo apoyo")
 local phaseSet={}
 while not e.finished do
  phaseSet[e.enemy.phase]=true;assert(Sim.step(e))
 end
 check(phaseSet.endurance and phaseSet.six_arms and phaseSet.resolve and phaseSet.seal and e.enemy.sealBroken,"Las cuatro fases se ejecutan y el sello requiere acción")
 e=Sim.make(10,3,100,17)
 while not e.finished do Combat.endTurn(e) end
 check(e.outcome=="defeat","N10 y tres esposas no vuelven invencible a Rudy")
 local s=Save.newSession();require("src.systems.events").apply(s,"starter_gift",{starter=true});s.rewardQueue={}
 s.day=7;s.checkpoint="day7_boss";require("src.systems.daily").ensure(s);s.decisions.day7_companion="all";s.externalEnergy=30
 local sc=require("src.systems.companions").context(s,require("src.systems.progression").encounter(s,s.checkpoint))
 s.combat=Combat.new(s.deck,{enemyId="badigadi_final",day=7,character="sylphiette",team=sc.team,relationships=s.relationships,combatDeck=s.combatDeck,unlocked=s.unlocked,curse=s.curse,externalEnergy=30,cardLevels=require("src.systems.card_collection").levels(s)},function()return 17 end)
 assert(Combat.support(s.combat,"roxy","special"));check(Save.write(s),"Guardar apoyo real")
 local loaded=assert(Save.load());check(loaded.combat and loaded.combat.supportUsed.roxy and loaded.combat.enemy.hp==s.combat.enemy.hp,"Recarga y daño exactos al cargar")
 local long=Combat.retry(s.combat)
 for turn=1,69 do
  for _,wife in ipairs(C.order)do assert(Combat.support(long,wife,"guard"))end
  assert(Combat.basic(long,"defend"));assert(Combat.basic(long,"dodge"));assert(Combat.endTurn(long))
 end
 s.combat=long
 -- Un historial extenso más 70 turnos supera el antiguo tope de 512 KiB.
 for i=1,600 do s.journal[i]={id="history_"..i,text=string.rep("a",500)}end
 check(Save.write(s),"Guardar batalla larga con muchos apoyos")
 local lengthy=assert(Save.load())
 check(lengthy.combat and lengthy.combat.turn==70 and #lengthy.combat.commands==#long.commands,"Cargar batalla larga sin reiniciar comandos")
 check(#assert(Json.encode(s))>524288 and #lengthy.journal==600,"El límite ampliado admite historial y combate juntos")
 print("War long battle save: "..#assert(Json.encode(s)).." bytes, "..#long.commands.." commands.")
 local broken=assert(Json.decode(assert(Json.encode(s))));broken.combat.allies.roxy.uses.special=0
 check(not assert(Save.validate(broken)).combat,"No acepta usos manipulados sin replay")
 local identity=love.filesystem.getIdentity();love.filesystem.setIdentity("cartas_del_destino_war_v6_migration")
 for _,path in ipairs({Save.filename,Save.backup})do love.filesystem.remove(path)end
 local legacy=Save.newSession();require("src.systems.events").apply(legacy,"starter_gift",{starter=true});legacy.rewardQueue={}
 legacy.version=6;legacy.day=6;legacy.checkpoint="day6_boss";legacy.decisions.day6_companion="roxy";require("src.systems.daily").ensure(legacy)
 local lc={enemyId="badigadi_final",day=6,character="roxy",combatDeck=legacy.combatDeck,unlocked=legacy.unlocked,curse=legacy.curse,externalEnergy=legacy.externalEnergy,tacticalContext={danger=true,companionInjured=true},cardLevels=require("src.systems.card_collection").levels(legacy)}
 legacy.combat=require("src.systems.combat_legacy").new(legacy.deck,lc,function()return 17 end)
 Combat.endTurn(legacy.combat)
 local bytes=assert(Json.encode(legacy));assert(love.filesystem.write("campaign-v6.json",bytes))
 local migrated=assert(Save.load())
 check(migrated.version==8 and migrated.combat and migrated.combat.enemy.maxHp==72 and migrated.combat.turn==2,"Combate v6 continúa con sus reglas originales")
 check(Save.write(migrated) and love.filesystem.read("campaign-v6.json")==bytes,"v7 conserva los bytes de v6")
 love.filesystem.setIdentity(identity)
 print("War rules: "..checks.." checks passed.")
 return checks
end
return Suite
