local Data=require("src.data.battle_balance")
local C={order={"sylphiette","roxy","eris"}}
function C.affinity(r)
 return ((r and r.love or 50)+(r and r.trust or 50))/2
end
function C.damage(base,r) return math.floor(base*math.max(0,math.min(100,C.affinity(r)))/100+.5) end
function C.healing(r,maxHp)
 local affinity=C.affinity(r)
 local rate=affinity>=90 and .4 or affinity>=80 and .3 or affinity>=50 and .2 or affinity>=25 and .1 or -.4
 return math.floor(maxHp*rate+.5),rate
end
function C.skill(id,skill)
 for _,s in ipairs(Data.skills[id] or {}) do if s.id==skill then return s end end
end
function C.roster(context)
 local out={}
 for _,id in ipairs(C.order) do
  local r=context.relationships and context.relationships[id]
  local selected=context.team and context.team[id] or context.character==id
  if selected and (not r or r.marriageState~="separated") then
   local def=Data.support[id]
   out[id]={id=id,name=def.name,role=def.role,love=r and r.love or 50,trust=r and r.trust or 50,
    hp=20,maxHp=20,shield=0,weak=0,vulnerable=0,cooldowns={},uses={}}
  end
 end
 return out
end
function C.context(session,definition)
 local context={relationships=session.relationships,team={}}
 if definition.enemyId=="badigadi_final" and session.decisions.day7_companion=="all" then
  for _,id in ipairs(C.order) do context.team[id]=true end
 elseif definition.character then context.team[definition.character]=true end
 return context
end
function C.record(session,enc)
 for id,ally in pairs(enc.allies or {})do
  session.decisions["support_previous_"..id]=C.damage(Data.support[id].special,ally)
 end
end
return C
