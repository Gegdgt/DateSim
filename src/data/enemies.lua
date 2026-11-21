local Legacy=require("src.data.enemies_legacy")
local Balance=require("src.data.battle_balance")
local function copy(v)
 if type(v)~="table" then return v end
 local out={};for k,x in pairs(v)do out[k]=copy(x)end;return out
end
local E={list=copy(Legacy.list),byId={},default=Legacy.default,difficulty=Balance.days}
for _,e in ipairs(E.list)do E.byId[e.id]=e end
for _,e in ipairs({
 {id="hitogami_minion",name="Lacayo de Hitogami",portrait="guardian_ruinas",maxHp=120,weakness="earth",shape="guardian",defeatText="El lacayo huye. Hitogami pierde el acceso al camino, no su existencia."},
 {id="orsted_trial",name="Orsted: prueba de control",portrait="orsted",maxHp=120,weakness="water",shape="guardian",nonlethal=true,defeatText="Orsted baja la guardia. La prueba termina; sigue siendo un aliado."},
})do e.narrativeEvent=e.id.."_defeated";e.defeatedEvent=e.narrativeEvent;e.reward={event=e.narrativeEvent};E.list[#E.list+1]=e;E.byId[e.id]=e end
E.byId.protector_emissary=E.byId.emissary_guard;E.byId.mirror_anomaly=E.byId.mana_anomaly
E.byId.badigadi_final.maxHp=Balance.boss.hp
function E.resolve(id,context)
 context=context or {};local e=copy(E.byId[id] or E.byId[E.default])
 local day=context.tutorial and 1 or context.difficulty or context.day or 1
 local p=Balance.days[day] or Balance.days[1]
 e.difficulty={level=day,name=p.name}
 if e.id=="eris_training" or e.id=="badigadi_training" then return Legacy.resolve(id,context) end
 if e.id=="badigadi_final" then e.maxHp=Balance.boss.hp;e.sealMax=Balance.boss.seal;e.actions=copy(Balance.boss.phases.endurance);return e end
 e.maxHp=math.floor(p.hp*(Balance.hpFactors[e.id] or 1)+.5)
 e.actions={{id="strike",name="Ataque anunciado",kind="attack",damage=p.damage}}
 if day>=2 then e.actions[#e.actions+1]={id="guard",name="Defensa preparada",kind="shield",shield=p.shield,maxUses=3} end
 if day>=3 then
  e.actions[#e.actions+1]={id="prepare",name="Preparar golpe",kind="prepare",nextDamage=p.damage+3}
  e.actions[#e.actions+1]={id="charged",name="Golpe preparado",kind="attack",damage=p.damage+3}
 end
 if day>=4 then e.actions[#e.actions+1]={id="weakening",name="Debilitamiento",kind="status",status="weak",duration=1} end
 if day>=5 then
  e.actions[#e.actions+1]={id="interrupt",name="Interrumpir el ritmo",kind="interrupt",actionLoss=1}
  e.actions[#e.actions+1]={id="multiple",name="Ataque multiple",kind="attack",damage=3,hits=2}
 end
 if day==1 then e.actions[#e.actions+1]={id="observe",name="Tomar distancia",kind="prepare",nextDamage=p.damage} end
 return e
end
return E
