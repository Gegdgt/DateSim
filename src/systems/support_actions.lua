local C=require("src.systems.companions")
local Data=require("src.data.battle_balance")
local Support={}
function Support.install(Combat,api)
 function Combat.supportPreview(enc,wife,id)
  local ally=enc.allies and enc.allies[wife];local skill=C.skill(wife,id)
  if not ally or not skill then return nil end
  local raw=C.damage(skill.power or 0,ally)
  local armor=enc.enemy.phase=="resolve" and enc.enemy.exposed<=0 and not skill.expose and id~="special" and Data.boss.armor or 0
  local hit=api.damageAmount(ally,enc.enemy,math.max(0,raw-armor))
  local shield=math.max(0,enc.enemy.shield-(skill.shatter or 0))
  local hp=math.min(enc.enemy.hp,math.max(0,hit-shield))
  local healing,rate=C.healing(ally,enc.player.maxHp)
  return {skill=skill,affinity=C.affinity(ally),damage=raw,hpLost=hp,shield=skill.shield or 0,
   heal=skill.heal and math.min(math.max(0,healing),enc.player.maxHp-enc.player.hp) or 0,
   risk=skill.heal and rate<0,riskDamage=math.abs(healing),mana=skill.mana or 0,
   cooldown=math.max(0,(ally.cooldowns[id] or 0)-enc.turn),uses=skill.uses and skill.uses-(ally.uses[id] or 0)}
 end
 function Combat.canSupport(enc,wife,id)
  if not enc or enc.finished then return false,"El combate ya terminó." end
  local p=Combat.supportPreview(enc,wife,id)
  if not p or enc.allies[wife].hp<=0 then return false,"Esta compañera no puede participar." end
  if enc.supportUsed[wife] then return false,"Ya actuó este turno." end
  if p.cooldown>0 then return false,"Disponible en "..p.cooldown.." turno(s)." end
  if p.uses and p.uses<=0 then return false,"Usos de combate agotados." end
  local pool=enc.context.curse.manaBlocked and "externalEnergy" or "mana"
  if enc.player[pool]<p.mana then return false,"Necesita "..p.mana.." de energía mágica." end
  if p.skill.heal and not p.risk and p.heal==0 then return false,"Rudy ya tiene todos sus PV." end
  return true
 end
 function Combat.support(enc,wife,id,revision,confirmRisk)
  if revision~=nil and revision~=enc.revision then return nil,"Esta acción ya fue procesada." end
  local ok,err=Combat.canSupport(enc,wife,id);if not ok then return nil,err end
  local p=Combat.supportPreview(enc,wife,id)
  if p.risk and not confirmRisk then return nil,"RIESGO: la maldición distorsiona la sincronización. Rudy perderá 40% de sus PV máximos. Confirma antes de usarla." end
  local ally=enc.allies[wife];local skill=p.skill
  local pool=enc.context.curse.manaBlocked and "externalEnergy" or "mana"
  enc.player[pool]=enc.player[pool]-p.mana;enc.supportUsed[wife]=true
  ally.cooldowns[id]=enc.turn+(skill.cooldown or 1);ally.uses[id]=(ally.uses[id] or 0)+1
  local result={events={},actionName=skill.name,companionAction=id,companionId=wife,element=wife=="eris" and "sword" or "water"}
  api.event(result,"companion_action","companion",ally.name..": "..skill.name..". Afinidad "..p.affinity.."; "..p.damage.." daño base; "..p.mana.." energía. Consume su acción de apoyo.")
  if skill.shatter then
   local removed=math.min(enc.enemy.shield,skill.shatter);enc.enemy.shield=enc.enemy.shield-removed
   api.event(result,"shatter","enemy","Roxy disuelve "..removed.." escudo.",{amount=removed})
  end
  if skill.expose then enc.enemy.exposed=math.max(enc.enemy.exposed,skill.expose);api.event(result,"status","enemy","Roxy identifica la debilidad y anula la resistencia especial durante "..skill.expose.." turnos.") end
  if skill.power then
   local armor=enc.enemy.phase=="resolve" and enc.enemy.exposed<=0 and id~="special" and Data.boss.armor or 0
   api.damage(enc,"enemy",math.max(0,p.damage-armor),result,ally)
  end
  if skill.weak then enc.enemy.weak=math.max(enc.enemy.weak,skill.weak);api.event(result,"status","enemy","El siguiente ataque pierde 2 de daño por golpe.",{status="weak",amount=skill.weak}) end
  if skill.shield then
   local kind=wife=="eris" and "physicalShield" or "magicShield"
   enc.player.shield=enc.player.shield+skill.shield;enc.player[kind]=enc.player[kind]+skill.shield
   api.event(result,"shield","player",ally.name.." protege a Rudy: +"..skill.shield.." escudo hasta su próximo turno.",{amount=skill.shield})
  end
  if skill.heal then
   if p.risk then
    local lost=math.min(enc.player.hp,p.riskDamage);enc.player.hp=enc.player.hp-lost
    api.event(result,"damage","player","La maldición rompe la sincronización, no la capacidad de Sylphiette: Rudy pierde "..lost.." PV.",{rawDamage=p.riskDamage,damage=p.riskDamage,blocked=0,hpLost=lost,amount=lost})
   else
    enc.player.hp=enc.player.hp+p.heal;enc.companionHeals=enc.companionHeals+1
    api.event(result,"heal","player","Sylphiette recupera "..p.heal.." PV de Rudy.",{amount=p.heal})
   end
  end
  local recorded=false
  for _,e in ipairs(enc.relationshipEvents)do if e.character==wife then recorded=true end end
  if not recorded then enc.relationshipEvents[#enc.relationshipEvents+1]={id="combat_tactic_"..enc.enemy.id.."_"..wife,character=wife,love=1,trust=2,choice=id,reason="Coordinación acordada durante el combate.",context="combat",sharedMoment="battle_"..enc.enemy.id} end
  api.updateIntent(enc,result);api.checkOutcome(enc,result)
  return api.record(enc,result,{kind="support",wife=wife,id=id,confirmRisk=confirmRisk==true})
 end
 local aliases={together="attack",assist="attack",coordinate="special",protect="guard",group="guard",retreat="guard"}
 function Combat.canTactic(enc,id) return Combat.canSupport(enc,enc.companion and enc.companion.id,aliases[id] or id) end
 function Combat.tactic(enc,id,revision) return Combat.support(enc,enc.companion and enc.companion.id,aliases[id] or id,revision) end
end
return Support
