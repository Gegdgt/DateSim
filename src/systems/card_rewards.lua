-- Estado de presentación puro. La concesión pertenece a Events/Collection.
local Data=require("src.data.reward_celebrations")
local Characters=require("src.data.characters")
local Cards=require("src.data.cards")
local Collection=require("src.systems.card_collection")
local R={pageSize=4,duration=1.05}
local function int(n,default,lo,hi)
 return type(n)=="number" and n==n and n~=math.huge and math.max(lo,math.min(hi,math.floor(n))) or default
end
function R.validContext(c)
 if type(c)~="table" or type(c.participants)~="table" or #c.participants<1 or #c.participants>4 then return false end
 local seen={};for _,id in ipairs(c.participants) do if not Characters.byId[id] or seen[id] then return false end;seen[id]=true end
 return seen.rudeus and (not c.background or require("src.data.assets").backgrounds[c.background])~=nil
end
function R.context(eventId,presenter,explicit)
 local c=explicit or Data.events[eventId] or {participants=presenter and presenter~="rudeus" and {"rudeus",presenter} or {"rudeus"}}
 assert(R.validContext(c),"Participantes de recompensa inválidos")
 local result={participants={},background=c.background or Data.backgrounds[presenter] or "home",important=c.important==true,unknownEffect=c.unknownEffect==true}
 for i,id in ipairs(c.participants) do result.participants[i]=id end
 return result
end
function R.total(reward)
 local count=0;for _,id in ipairs(reward.cards) do count=count+(reward.counts[id] or 1) end;return count
end
function R.pages(reward)return math.max(1,math.ceil(#reward.cards/R.pageSize))end
function R.prepare(reward)
 if reward.presentation then return reward.presentation end
 local old=reward.presentationPage
 reward.presentation={version=1,phase=old and "individual" or R.total(reward)>1 and "choice" or "individual",
  mode=old and "individual" or R.total(reward)==1 and "individual" or nil,index=old or 1,page=1,elapsed=0,line=1,appeared=false,revealed=false}
 return reward.presentation
end
function R.restore(reward,raw)
 if type(raw)~="table" or raw.version~=1 then return R.prepare(reward) end
 local phases={choice=true,individual=true,group=true,summary=true}
 local phase=phases[raw.phase] and raw.phase or "choice"
 if R.total(reward)==1 and phase=="choice" then phase="individual" end
 reward.presentation={version=1,phase=phase,mode=raw.mode=="all" and "all" or raw.mode=="individual" and "individual" or nil,
  index=int(raw.index,1,1,#reward.cards),page=int(raw.page,1,1,R.pages(reward)),elapsed=type(raw.elapsed)=="number" and raw.elapsed==raw.elapsed and math.max(0,math.min(3,raw.elapsed)) or 0,
  line=int(raw.line,1,1,#reward.celebration.participants),appeared=raw.appeared==true,revealed=raw.revealed==true}
 return reward.presentation
end
function R.choose(reward,mode)
 local p=R.prepare(reward);if p.phase~="choice" then return false end
 if mode~="all" and mode~="individual" then return false end
 p.mode=mode;p.phase=mode=="all" and "group" or "individual";p.elapsed=0;p.line=1;p.page=1
 p.appeared=false;p.revealed=false;return true
end
function R.skip(reward)
 local p=R.prepare(reward);p.phase="summary";p.page=1;p.elapsed=R.duration;p.revealed=true
end
function R.advance(reward)
 local p=R.prepare(reward)
 if p.phase=="choice" then R.choose(reward,"individual");return false end
 if p.phase=="summary" then return true end
 if p.elapsed<R.duration then p.elapsed=R.duration;return false end
 if p.phase=="individual" and p.index<#reward.cards then
  p.index=p.index+1;p.elapsed=0;p.line=1;p.appeared=false;p.revealed=false
 else R.skip(reward) end
 return false
end
function R.category(id)
 local card=Collection.byId[id]
 return Cards.byId[id] and "social" or (card.manaCost or 0)>0 and "magic" or "combat"
end
function R.view(session,reward,id)
 local v=assert(Collection.view(session,id));local count=reward.counts[id] or 1
 local card=Collection.byId[id];local description=card.description
 if not Cards.byId[id] then
  local parts={}
  for _,item in ipairs({{"damage","Daño"},{"shield","Escudo"},{"heal","Curación"},{"mana","Maná"},{"weak","Debilidad"}}) do
   if v.combatEffect[item[1]] then parts[#parts+1]=item[2]..": "..v.combatEffect[item[1]] end
  end
  description=table.concat(parts," · ")..". Coste: "..v.combatCost.." acción; "..v.manaCost.." energía mágica; "..v.hpCost.." PV."
  if v.perBattle then description=description.." Máximo "..v.perBattle.." usos por combate." end
 end
 return {card=Collection.byId[id],category=R.category(id),level=v.level,copies=v.copies,count=count,
  new=reward.newCards[id]==true,duplicates=count-(reward.newCards[id] and 1 or 0),description=description}
end
function R.reaction(session,reward,id,actor)
 local category=R.category(id);local bank=Data.lines[actor] or Data.lines.rudeus
 local pool=actor=="nanahoshi" and reward.celebration.unknownEffect and bank.unknown or bank[category]
 local hash=0;for c in (reward.eventId..id..actor):gmatch(".") do hash=(hash*31+c:byte())%65521 end
 local expression=actor=="nanahoshi" and reward.celebration.unknownEffect and "worried" or "happy"
 local class=Collection.class(id)
 if (actor=="cliff" and category~="magic") or (actor=="rudeus" and (class=="advanced" or class=="ultimate")) then expression="worried" end
 return {speaker=actor,text=pool[hash%#pool+1],expression=expression,
  delivery=actor=="rudeus" and session.curse and session.curse.voiceSealed and "thought" or "speech"}
end
return R
