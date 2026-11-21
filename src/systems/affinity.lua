-- Vínculos no matrimoniales. No escribe en relationships, romanceIds o finales.
local Data=require("src.data.cards")
local Config=require("src.data.relationships.nanahoshi")
local Affinity={config={nanahoshi=Config}}
local function finite(value,default)
 if type(value)~="number" or value~=value or math.abs(value)==math.huge then return default or 0 end
 return value
end
local function clamp(value) return math.max(0,math.min(100,value)) end
local function flags(value)
 local out,count={},0
 for key,item in pairs(type(value)=="table" and value or {}) do
  if type(key)=="string" and #key<=200 and item==true and count<2048 then out[key]=true;count=count+1 end
 end
 return out
end
function Affinity.normalize(value)
 local out={}
 for id,config in pairs(Affinity.config) do
  local entry=type(value)=="table" and value[id]
  entry=type(entry)=="table" and entry or {}
  local current={trust=clamp(finite(entry.trust,config.defaults.trust)),interest=clamp(finite(entry.interest,config.defaults.interest)),
   awarded=flags(entry.awarded),applied=flags(entry.applied),history={}}
  for _,item in ipairs(type(entry.history)=="table" and entry.history or {}) do
   if #current.history>=512 then break end
   if type(item)=="table" and type(item.id)=="string" and #item.id<=200 then
    current.history[#current.history+1]={id=item.id,cardId=type(item.cardId)=="string" and item.cardId or nil,
     conversationId=type(item.conversationId)=="string" and item.conversationId or nil,
     trust=math.max(-100,math.min(100,finite(item.trust))),interest=math.max(-100,math.min(100,finite(item.interest)))}
   end
  end
  out[id]=current
 end
 return out
end
function Affinity.new() return Affinity.normalize() end
function Affinity.get(session,id)
 if not Affinity.config[id] then return nil end
 return Affinity.normalize(session and session.affinities)[id]
end
function Affinity.canInterest(character,cardId)
 local config=Affinity.config[character]
 local card=Data.byId[cardId]
 return config~=nil and card~=nil and card.encounterTypes~=nil and card.encounterTypes.social==true and not card.combat and config.positiveCards[cardId]~=nil
end
function Affinity.sanitize(character,effect)
 effect=type(effect)=="table" and effect or {}; local config=Affinity.config[character]
 local card=Data.byId[effect.cardId]
 if not config or not card or not card.encounterTypes or not card.encounterTypes.social
  or (card.conditions and card.conditions.character and card.conditions.character~=character) then return {trust=0,interest=0,eligible=false} end
 local interest=finite(effect.interest)
 if interest>0 then
  local positive=config.positiveCards[effect.cardId]
  interest=Affinity.canInterest(character,effect.cardId) and math.min(interest,positive.maxInterest) or 0
 end
 return {trust=finite(effect.trust),interest=interest,eligible=true}
end
local function rewardKey(effect)
 local conversation=type(effect.conversationId)=="string" and effect.conversationId or "unscoped"
 return conversation..":"..tostring(effect.cardId)
end
function Affinity.preview(session,id,effect)
 local current=Affinity.get(session,id)
 if not current then return {trust=0,interest=0,eligible=false} end
 effect=type(effect)=="table" and effect or {}
 local requested=Affinity.sanitize(id,effect)
 local key=rewardKey(effect)
 if current.awarded[key] then requested.trust=math.min(0,requested.trust);requested.interest=math.min(0,requested.interest) end
 return {trust=clamp(current.trust+requested.trust)-current.trust,
  interest=clamp(current.interest+requested.interest)-current.interest,eligible=requested.eligible,
  rewardKey=key,alreadyAwarded=current.awarded[key]==true,
  before={trust=current.trust,interest=current.interest},
  after={trust=clamp(current.trust+requested.trust),interest=clamp(current.interest+requested.interest)}}
end
function Affinity.apply(session,id,effect,eventId)
 if not session or not Affinity.config[id] or type(eventId)~="string" or #eventId>200 then return false,{trust=0,interest=0} end
 effect=type(effect)=="table" and effect or {}
 session.affinities=Affinity.normalize(session.affinities)
 local current=session.affinities[id]
 if current.applied[eventId] then return false,{trust=0,interest=0} end
 local delta=Affinity.preview(session,id,effect)
 current.applied[eventId]=true
 current.trust=current.trust+delta.trust;current.interest=current.interest+delta.interest
 local requested=Affinity.sanitize(id,effect)
 if requested.eligible and (requested.trust>0 or requested.interest>0) then current.awarded[delta.rewardKey]=true end
 current.history[#current.history+1]={id=eventId,cardId=effect.cardId,conversationId=effect.conversationId,trust=delta.trust,interest=delta.interest}
 return true,delta
end
return Affinity
