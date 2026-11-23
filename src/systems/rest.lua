local Data=require("src.data.rest")
local Daily=require("src.systems.daily")
local Events=require("src.systems.events")
local Family=require("src.systems.family")
local Rest={}
function Rest.ensure(s) s.rest=s.rest or {version=1,nights={}};return s.rest end
function Rest.completed(s) return s.events[Daily.key(s,"rest")]==true end
function Rest.bed(s)
 return s.exploration and Data.beds[s.exploration.map]
end
function Rest.available(s,bed)
 local ready,reason=require("src.systems.objectives").requirements(s)
 if not ready then return false,reason end
 if not bed or bed~=Rest.bed(s) then return false,"Acércate a una cama en su dormitorio o al jergón del segundo piso." end
 local e=s.exploration
 if (e.x-bed.x)^2+(e.y-bed.y)^2>=30^2 and not (bed.wife and require("src.systems.exploration").nearCharacter(s,bed.wife)) then return false,"Acércate al lugar de descanso." end
 if Rest.completed(s) or s.daily.ending_processed then return false,"Ya descansaste esta noche." end
 if bed.wife then
  if not Family.active(s,bed.wife) then return false,"Este dormitorio no permite descanso romántico tras la separación." end
 end
 return true
end
function Rest.options(s,bed)
 local list={}
 local dialogue=bed.wife and Data.conversations[bed.wife]
 if dialogue then
  for _,id in ipairs(s.deck) do
   if s.unlocked[id] and dialogue.cards[id] then list[#list+1]={id=id,rudy=dialogue.cards[id][1],reply=dialogue.cards[id][2]} end
  end
 end
 if #list==0 then list[1]={id="gesture",rudy="Rudy asiente y deja las cartas sobre la mesa.",reply="La casa queda en silencio. Es hora de descansar."} end
 return list
end
function Rest.confirm(s,bed,card)
 local ok,err=Rest.available(s,bed);if not ok then return nil,err end
 local chosen=card=="gesture" and {rudy="Rudy asiente y prepara el descanso."} or nil
 for _,c in ipairs(Rest.options(s,bed)) do if c.id==card then chosen=c end end
 if not chosen then return nil,"Elige una respuesta disponible antes de confirmar." end
 -- La visita nocturna nunca modifica daily.visits; ausencia y noche son hechos distintos.
 Daily.applyAttention(s)
 local wife=bed.wife
 if wife and not Family.active(s,wife) then wife=nil end
 local before=wife and {love=s.relationships[wife].love,trust=s.relationships[wife].trust}
 local delta=wife and require("src.systems.relationship_budget").preview(s,wife,{love=10,trust=10,nightRest=true,recovery=true})
 local text=wife and ("Descanso compartido: "..string.format("%+d amor y %+d confianza",delta.love,delta.trust)..", fuera del límite diurno.")
  or "Rudy descansa solo. La noche no sustituye las visitas del día."
 local applied,reason=Events.apply(s,Daily.key(s,"rest"),{character=wife,love=wife and 10 or 0,trust=wife and 10 or 0,
  nightRest=true,recovery=true,context="night",decision="night_"..s.day,value=wife or "solo",
  sharedMoment="night_"..s.day,text=text.." "..chosen.rudy})
 if not applied then return nil,reason or "Descanso ya registrado." end
 local record={day=s.day,wife=wife or "solo",map=s.exploration.map,card=card,
  x=bed.wake.x,y=bed.wake.y,facing=bed.wake.facing,love=wife and s.relationships[wife].love-before.love or 0,
  trust=wife and s.relationships[wife].trust-before.trust or 0}
 Rest.ensure(s).nights[tostring(s.day)]=record
 require("src.systems.objectives").sync(s)
 s.exploration.active=false
 return record
end
function Rest.wake(s,previousDay)
 local rest=s.rest;local night=rest and rest.nights[tostring(previousDay)]
 if not night or s.day==previousDay or s.day>7 then return end
 local e=s.exploration
 e.map,e.x,e.y,e.facing=night.map,night.x,night.y,night.facing
 e.visited[e.map]=true;e.active=true;rest.waking=true
end
function Rest.restore(s,input)
 local raw=input.rest;if raw==nil then return true end
 if type(raw)~="table" or raw.version~=1 or type(raw.nights)~="table" or not s.prologue then return nil,"Registro de descanso inválido." end
 local out={version=1,nights={},waking=raw.waking==true}
 for key,n in pairs(raw.nights) do
  local day=tonumber(key);local bed=type(n)=="table" and Data.beds[n.map]
  if not day or day%1~=0 or day<1 or day>s.day or not bed or not s.events["day"..day.."_rest"]
   or n.day~=day or (n.wife~="solo" and n.wife~=bed.wife) then return nil,"Noche sin dormitorio o evento válido." end
  out.nights[key]={day=day,wife=n.wife,map=n.map,card=n.card,x=bed.wake.x,y=bed.wake.y,facing=bed.wake.facing,
   love=math.max(0,math.min(10,tonumber(n.love) or 0)),trust=math.max(0,math.min(10,tonumber(n.trust) or 0))}
 end
 if out.waking and not out.nights[tostring(s.day-1)] then return nil,"Despertar sin descanso anterior." end
 s.rest=out
 return true
end
return Rest
