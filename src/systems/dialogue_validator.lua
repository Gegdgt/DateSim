-- Validador y reporte del contenido escrito; no modifica partidas ni diálogos.
local Cards=require("src.data.cards")
local CombatCards=require("src.data.combat_cards")
local Characters=require("src.data.characters")
local Conditions=require("src.systems.conditions")
local Assets=require("src.data.assets")
local Animation=require("src.systems.animation")
local Affinity=require("src.systems.affinity")
local Validator={}
local function identifier(value) return type(value)=="string" and value:match("^[%w_]+$")~=nil end
local function finite(value) return type(value)=="number" and value==value and math.abs(value)<math.huge end
local function occurrences(text,part)
 local count,start=0,1
 while true do local first,last=text:find(part,start,true); if not first then return count end; count=count+1; start=last+1 end
end
local function merged(base,variant)
 local out={}; for key,value in pairs(base) do out[key]=value end
 for key,value in pairs(variant or {}) do out[key]=value end; return out
end
local function eligible(card,node,kind)
 local condition=card.conditions or {}
 return card.encounterTypes and card.encounterTypes.social and (card.unlockedAt or 1)<=node.day
  and (not condition.character or condition.character==node.character)
  and (not condition.kind or condition.kind==kind)
end
local function sequences(ids,maxTurns,energy)
 local used,counts={},{}
 local function visit(depth,left)
  if depth>=maxTurns then return end
  for _,id in ipairs(ids) do
   local cost=Cards.byId[id].cost
   if not used[id] and cost<=left then
    counts[depth+1]=(counts[depth+1] or 0)+1
    used[id]=true; visit(depth+1,left-cost); used[id]=nil
   end
  end
 end
 visit(0,energy)
 local total=0; for _,count in pairs(counts) do total=total+count end
 return {byLength=counts,total=total,maxTurns=maxTurns,energy=energy}
end

local function validate(catalog,options)
 catalog=catalog or require("src.data.dialogue"); options=options or {}
 local chapters=options.chapters or require("src.data.chapters")
 local errors,ids,graph,conditionChecks={},{},{},{}
 local report={nodes=0,conversations=0,responses=0,variants=0,fallbacks=0,branches=0,
  classifications={social=0,hybrid=0,combat=0,narrative=0},storyObjects={},coverage={},sequenceCounts={},totalSequences=0}
 local function fail(where,message) errors[#errors+1]=tostring(where)..": "..message end
 local function register(id,where)
  if not identifier(id) then fail(where,"identificador inválido")
  elseif ids[id] then fail(where,"identificador duplicado: "..id)
  else ids[id]=true end
 end
 local function data(value,where,seen)
  if type(value)=="table" then
   if seen[value] then fail(where,"tabla circular"); return false end
   seen[value]=true; local ok=true
   for key,item in pairs(value) do
    if type(key)~="string" and type(key)~="number" then fail(where,"clave no declarativa"); ok=false end
    if not data(item,where.."."..tostring(key),seen) then ok=false end
   end
   seen[value]=nil; return ok
  end
  if type(value)=="function" or type(value)=="userdata" or type(value)=="thread" then fail(where,"contenido ejecutable"); return false end
  return true
 end
 if type(catalog)~="table" or type(catalog.nodes)~="table" or type(catalog.encounters)~="table" then
  return false,{"Catálogo de conversaciones inválido."},report
 end
 if not data(catalog,"conversaciones",{}) then return false,errors,report end
 local affinityCards=0
 for cardId in pairs(Affinity.config.nanahoshi.positiveCards) do
  affinityCards=affinityCards+1
  if not Affinity.canInterest("nanahoshi",cardId) then fail("afinidad/"..cardId,"el interés requiere una carta social real, no híbrida") end
 end
 if affinityCards~=5 then fail("afinidad/nanahoshi","deben existir exactamente cinco cartas con interés positivo") end
 for _,message in ipairs(catalog.buildErrors or {}) do errors[#errors+1]=message end
 local function text(value,where,allowEmpty)
  if type(value)~="string" or (not allowEmpty and not value:find("%S")) then fail(where,"texto escrito vacío o inválido"); return end
  if occurrences(value,"¿")~=occurrences(value,"?") or occurrences(value,"¡")~=occurrences(value,"!") then fail(where,"signos de interrogación o exclamación sin pareja") end
  for _,mark in ipairs({"?.","!.","??","!!","¿¿","¡¡","...."}) do
   if value:find(mark,1,true) then fail(where,"puntuación mal formada: "..mark) end
  end
 end
 local function expression(value,where)
  if type(value)~="string" or Characters.expressions[value]==nil then fail(where,"expresión desconocida") end
 end
 local function character(value,where)
  if type(value)~="string" or not Characters.byId[value] then fail(where,"personaje desconocido") end
 end
 local function animation(value,where)
  if value~=nil and (type(value)~="string" or not Animation.actorNames[value]) then fail(where,"animación desconocida") end
 end
 local knownEvents,knownDecisions,personalEvents={},{},{}
 local function effect(value,implicit)
  if type(value)~="table" then return end
  if identifier(value.id or implicit) then knownEvents[value.id or implicit]=true end
  if identifier(value.decision) then knownDecisions[value.decision]=true end
  if identifier(value.relationshipEvent) then personalEvents[value.relationshipEvent]=true end
  for _,child in ipairs(value.batch or {}) do effect(child,implicit) end
 end
 local function definition(value,sceneId)
  for _,choice in ipairs(value.choices or {}) do effect(choice.effects,"choice_"..sceneId) end
  if value.choices then knownDecisions["choice_"..sceneId]=true; knownEvents["choice_"..sceneId]=true end
  for _,line in ipairs(value.lines or {}) do if type(line)=="table" then effect(line.stateEffect) end end
  for _,variant in pairs(value.variants or {}) do definition(variant,sceneId) end
 end
 for sceneId,node in pairs(chapters.checkpoints or {}) do
  definition(node.definition,sceneId)
  if node.kind=="encounter" then knownEvents["resolved_"..sceneId]=true; knownDecisions["outcome_"..sceneId]=true end
  if node.definition.training then
   for _,id in ipairs({"eris_training_rudy_victory","eris_training_honorable_defeat","eris_training_suspected_throw","eris_training_honest_defeat","eris_training_reconciled"}) do knownEvents[id]=true end
   knownDecisions.eris_training_result=true;knownDecisions.eris_training_last_result=true
  end
 end
 for _,chapter in ipairs(chapters.list or {}) do
  for _,transitions in pairs(chapter.transitions or {}) do for _,transition in ipairs(transitions) do
   for _,entry in ipairs(transition.effects or {}) do effect(entry) end
  end end
  if identifier(chapter.completionEvent) then knownEvents[chapter.completionEvent]=true end
  if chapter.companion then
   knownEvents[chapter.companion.event]=true; knownDecisions[chapter.companion.decisionKey]=true
  end
 end
 local function consequence(value,where)
  if value.flags~=nil and type(value.flags)~="table" then fail(where,"flags debe ser una lista")
  else
   local flags={}
   for key,flag in pairs(value.flags or {}) do
    if type(key)~="number" or key%1~=0 or key<1 or key>#value.flags or not identifier(flag) then fail(where,"flag inválida")
    elseif flags[flag] then fail(where,"flag repetida")
    else flags[flag]=true; knownEvents[flag]=true; knownDecisions[flag]=true end
   end
  end
  if value.promise~=nil then
   local promise=value.promise
   if type(promise)~="table" or not identifier(promise.id) or not ({pending=true,kept=true,broken=true})[promise.status] then fail(where,"promesa inválida") end
  end
  for _,field in ipairs({"conflict","reconcile","sharedMoment","relationshipEvent"}) do
   if value[field]~=nil and not identifier(value[field]) then fail(where,"consecuencia inválida: "..field) end
  end
  if identifier(value.relationshipEvent) then personalEvents[value.relationshipEvent]=true end
  if value.critical~=nil and (type(value.critical)~="table" or not identifier(value.critical.id)
   or (type(value.critical.value)~="boolean" and type(value.critical.value)~="string")) then fail(where,"decisión crítica inválida") end
 end
 local function edge(from,target,where)
  if not identifier(target) or type(catalog.nodes[target])~="table" then fail(where,"continuación inexistente: "..tostring(target)); return end
  graph[from]=graph[from] or {}
  if not graph[from][target] then graph[from][target]=true; report.branches=report.branches+1 end
 end
 local function response(value,nodeId,where,fallback,isVariant,cardId)
  if type(value)~="table" then fail(where,"respuesta inválida"); return end
  register(value.id,where)
  text(value.rudy,where..".rudy",fallback)
  text(value.response,where..".response")
  expression(value.expression,where); animation(value.animation,where)
  if value.effects==nil and fallback then
   -- La pausa es gratuita y no recompensa; el resolver usa cero por defecto.
  elseif type(value.effects)~="table" then fail(where,"efectos ausentes o inválidos")
  else
   for _,field in ipairs({"score","love","trust"}) do
    if not finite(value.effects[field]) or math.abs(value.effects[field])>100 then fail(where,"efecto numérico inválido: "..field) end
    if fallback and value.effects[field]~=0 then fail(where,"la pausa no concede efectos") end
   end
   local interest=value.effects.interest
   if interest~=nil and (not finite(interest) or math.abs(interest)>100) then fail(where,"efecto numérico inválido: interest") end
   local participant=catalog.nodes[nodeId].character
   if Affinity.config[participant] then
    if value.effects.love~=0 then fail(where,"un vínculo no matrimonial no concede amor") end
    if finite(interest) and interest>0 then
     local config=Affinity.config[participant].positiveCards[cardId]
     if not Affinity.canInterest(participant,cardId) or not config or interest>config.maxInterest then fail(where,"carta sin permiso para conceder ese interés") end
    end
   elseif interest~=nil and interest~=0 then fail(where,"interés reservado a afinidad no matrimonial") end
   if fallback and interest~=nil and interest~=0 then fail(where,"la pausa no concede interés") end
   for key in pairs(value.effects) do if key~="score" and key~="love" and key~="trust" and key~="interest" then fail(where,"efecto desconocido: "..tostring(key)) end end
  end
  consequence(value,where)
  if value.next==nil then fail(where,"respuesta sin continuación") else edge(nodeId,value.next,where) end
  if isVariant then
   if value.requires==nil then fail(where,"variante sin condición") end
   local ok,err=Conditions.validate(value.requires)
   if not ok then fail(where,err) else conditionChecks[#conditionChecks+1]={value=value.requires,where=where} end
   if value.priority~=nil and not finite(value.priority) then fail(where,"prioridad no finita") end
  end
 end
 for id,node in pairs(catalog.nodes) do
  report.nodes=report.nodes+1
  if type(node)~="table" then fail(id,"nodo inválido")
  else
   register(node.id,id); if id~=node.id then fail(id,"clave distinta del ID del nodo") end
   character(node.character,id); text(node.text,id..".text")
   if node.cards~=nil then
    report.conversations=report.conversations+1
    if not finite(node.day) or node.day%1~=0 or node.day<1 or node.day>7 then fail(id,"día inválido") end
    if type(node.background)~="string" or not Assets.backgrounds[node.background] then fail(id,"fondo desconocido") end
    if type(node.emotion)~="string" or node.emotion=="" then fail(id,"contexto emocional ausente") end
    if type(node.cards)~="table" then fail(id,"cartas del nodo inválidas")
    else
     local phrases={}
     for cardId,base in pairs(node.cards) do
      local where=id.."/"..tostring(cardId)
      report.responses=report.responses+1
      local card=Cards.byId[cardId]
      if not card then fail(where,"carta social desconocida")
      elseif card.conditions.character and card.conditions.character~=node.character then fail(where,"carta exclusiva de otro personaje") end
      response(base,id,where,false,false,cardId)
      if type(base)=="table" then
       if type(base.rudy)=="string" and phrases[base.rudy] then fail(where,"dos cartas comparten la misma frase inicial") end
       if type(base.rudy)=="string" then phrases[base.rudy]=true end
       if base.variants~=nil and type(base.variants)~="table" then fail(where,"variantes inválidas")
       else for _,variant in ipairs(base.variants or {}) do
        report.variants=report.variants+1
        if type(variant)~="table" then fail(where,"variante inválida")
        else
         if not identifier(variant.id) then fail(where,"variante sin ID propio") end
         response(merged(base,variant),id,where.."/"..tostring(variant.id),false,true,cardId)
        end
       end end
      end
     end
    end
    report.fallbacks=report.fallbacks+1; response(node.fallback,id,id.."/pause",true,false)
   else
    expression(node.expression,id)
    if node.next~=nil then edge(id,node.next,id) end
   end
   if node.lines~=nil and type(node.lines)~="table" then fail(id,"secuencia de líneas inválida")
   else for index,line in ipairs(node.lines or {}) do
    local where=id..".lines."..index
    if type(line)~="table" then fail(where,"línea inválida")
    else
     if line.speaker~="narrator" then character(line.speaker,where) end
     expression(line.expression,where); text(line.text,where); animation(line.animation,where)
     if line.speaker=="rudeus" and not ({enchanted=true,thought=true,note=true,silence=true})[line.delivery] then fail(where,"Rudy necesita un canal de comunicación permitido") end
    end
   end end
  end
 end
 local mapped={}
 for sceneId,nodeId in pairs(catalog.encounters) do
  local node=catalog.nodes[nodeId]
  local checkpoint=(chapters.checkpoints or {})[sceneId=="nanahoshi_test" and "day1_tutorial" or sceneId]
  if not checkpoint or checkpoint.kind~="encounter" then fail(sceneId,"encuentro de campaña desconocido")
  elseif type(node)~="table" or type(node.cards)~="table" then fail(sceneId,"raíz de conversación inexistente")
  else
   mapped[nodeId]=true
   local kind=sceneId=="nanahoshi_test" and "conversation" or checkpoint.definition.kind
   local participant=sceneId=="nanahoshi_test" and "nanahoshi" or checkpoint.definition.character
   if node.character~=participant or node.day~=checkpoint.day then fail(sceneId,"personaje o día no coincide con el encuentro") end
   local row={scene=sceneId,node=nodeId,character=node.character,day=node.day,required={},extra={},missing={},written=0}
   for _,card in ipairs(Cards.list) do
    if eligible(card,node,kind) then
     row.required[#row.required+1]=card.id
     if not node.cards[card.id] then row.missing[#row.missing+1]=card.id; fail(sceneId,"sin respuesta para carta compatible: "..card.id) end
    elseif node.cards[card.id] then row.extra[#row.extra+1]=card.id end
   end
   for _ in pairs(node.cards) do row.written=row.written+1 end
   local maxTurns=math.min(3,math.max(1,tonumber(node.maxTurns) or 3))
   local count=sequences(row.required,maxTurns,4)
   row.sequences=count.total; report.sequenceCounts[sceneId]=count; report.totalSequences=report.totalSequences+count.total
   report.coverage[#report.coverage+1]=row
   knownDecisions["dialogue_"..sceneId]=true
   for turn=1,maxTurns do knownEvents["social_"..sceneId.."_"..turn]=true; knownDecisions["social_"..sceneId.."_"..turn]=true end
  end
 end
 for sceneId,node in pairs(chapters.checkpoints or {}) do
  if node.kind=="encounter" and node.definition.kind~="magic" and not catalog.encounters[sceneId] then fail(sceneId,"encuentro social sin catálogo escrito") end
 end
 local function references(condition,where)
  if not condition then return end
  if condition.event and not knownEvents[condition.event] then fail(where,"evento sin productor: "..condition.event) end
  if condition.decision and not knownDecisions[condition.decision] then fail(where,"decisión sin productor: "..condition.decision) end
  if condition.personalEvent and not personalEvents[condition.personalEvent] then fail(where,"evento personal sin productor: "..condition.personalEvent) end
  for _,child in ipairs(condition.all or condition.any or {}) do references(child,where) end
  if condition['not'] then references(condition['not'],where) end
 end
 for _,check in ipairs(conditionChecks) do references(check.value,check.where) end
 local visited,active,reachable={},{},{}
 local function visit(id)
  if active[id] then fail(id,"ciclo de continuaciones"); return end
  if visited[id] then return end
  active[id]=true
  for target in pairs(graph[id] or {}) do visit(target) end
  active[id]=nil; visited[id]=true
 end
 for id in pairs(catalog.nodes) do visit(id) end
 local function reach(id)
  if reachable[id] then return end; reachable[id]=true
  for target in pairs(graph[id] or {}) do reach(target) end
 end
 for id in pairs(mapped) do reach(id) end
 for id in pairs(catalog.nodes) do if not reachable[id] then fail(id,"nodo sin camino desde un encuentro") end end
 for _,card in ipairs(Cards.list) do
  local kind=card.combat and "hybrid" or "social"
  report.classifications[kind]=report.classifications[kind]+1
 end
 for _,card in ipairs(CombatCards.list) do
  if Cards.byId[card.id] then fail(card.id,"ID duplicado entre inventarios social y de combate") end
  report.classifications.combat=report.classifications.combat+1
 end
 for _ in pairs(require("src.data.documents")) do report.classifications.narrative=report.classifications.narrative+1 end
 for _,id in ipairs({"silence_potion","antidote"}) do
  if Assets.cardIcons[id] and not Cards.byId[id] and not CombatCards.byId[id] then report.storyObjects[#report.storyObjects+1]=id end
 end
 table.sort(report.coverage,function(a,b) return a.day==b.day and a.scene<b.scene or a.day<b.day end)
 return #errors==0,errors,report
end

function Validator.validate(catalog,options)
 local ok,valid,errors,report=pcall(validate,catalog,options)
 if not ok then return false,{"Estructura de conversaciones inválida: "..tostring(valid)},{} end
 return valid,errors,report
end
function Validator.assertValid(catalog,options)
 local ok,errors,report=Validator.validate(catalog,options)
 assert(ok,"Conversaciones inválidas:\n"..table.concat(errors,"\n")); return report
end
function Validator.report(catalog,options)
 catalog=catalog or require("src.data.dialogue")
 local valid,errors,report=Validator.validate(catalog,options)
 if not report.classifications then return "# Cobertura narrativa\n\nValidación fallida:\n\n- "..table.concat(errors,"\n- ").."\n" end
 local c=report.classifications
 local lines={"# Cobertura de conversaciones escritas","",
  string.format("Inventario real: **%d cartas sociales, %d híbridas y %d de combate** (%d cartas jugables). Además hay **%d documentos/pistas narrativos**, que no entran en los mazos.",c.social,c.hybrid,c.combat,c.social+c.hybrid+c.combat,c.narrative),"",
  "La poción del silencio (`silence_potion`) y el antídoto (`antidote`) son objetos de trama con iconos propios, fuera de ambos catálogos de cartas jugables. Tampoco se mezclan ni se roban como cartas sociales o de combate.","",
  string.format("**%d conversaciones de entrada, %d nodos totales, %d respuestas base, %d variantes escritas, %d pausas y %d conexiones distintas entre nodos.**",report.conversations,report.nodes,report.responses,report.variants,report.fallbacks,report.branches),"",
  "Las variantes consultan condiciones declaradas y tienen prioridad; no se construyen frases mezclando fragmentos. Las pausas no conceden puntos ni voz gratis.","",
  "## Cobertura por encuentro","","| Encuentro | Día | Respuestas escritas | Cartas disponibles por día | Extras importables | Secuencias posibles |","| --- | ---: | ---: | ---: | ---: | ---: |"}
 for _,row in ipairs(report.coverage) do lines[#lines+1]=string.format("| `%s` | %d | %d | %d | %d | %d |",row.scene,row.day,row.written,#row.required,#row.extra,row.sequences) end
 lines[#lines+1]=""; lines[#lines+1]="`nanahoshi_test` es la fase social del checkpoint `day1_tutorial`, no una segunda campaña. Los extras tienen texto escrito para colecciones importadas; escribirlos no desbloquea sus cartas."
 lines[#lines+1]=""; lines[#lines+1]="## Matriz de cartas y respuestas"; lines[#lines+1]=""
 local header={"Carta"}; for _,row in ipairs(report.coverage) do header[#header+1]="`"..row.node.."`" end
 lines[#lines+1]="| "..table.concat(header," | ").." |"
 local separators={}; for _=1,#header do separators[#separators+1]="---" end
 lines[#lines+1]="| "..table.concat(separators," | ").." |"
 for _,card in ipairs(Cards.list) do
  local cells={"`"..card.id.."`"}
  for _,row in ipairs(report.coverage) do
   local required=false; for _,id in ipairs(row.required) do if id==card.id then required=true end end
   local written=catalog.nodes[row.node].cards[card.id]~=nil
   cells[#cells+1]=written and (required and "Sí" or "Importada") or (required and "FALTA" or "—")
  end
  lines[#lines+1]="| "..table.concat(cells," | ").." |"
 end
 lines[#lines+1]=""; lines[#lines+1]="Sí = respuesta compatible por día/personaje; Importada = cobertura adicional; — = fuera del conjunto normal de ese día o de esa esposa. Una combinación sin contenido no es jugable."
 lines[#lines+1]=""; lines[#lines+1]="## Alcance del cálculo"; lines[#lines+1]=""
 lines[#lines+1]=string.format("**%d secuencias locales posibles** sumadas entre encuentros: permutaciones de una a tres cartas distintas, coste social total máximo de cuatro, sobre toda la colección compatible disponible por día. No se cuentan pausas, cartas futuras importadas ni multiplicaciones por variantes.",report.totalSequences)
 lines[#lines+1]=""
 lines[#lines+1]="Es un espacio teórico de elecciones entre mazos y repartos posibles: cada partida usa solo su mazo equipado de cinco a diez cartas y su mano real. No son ese número de textos únicos ni una estimación de campañas completas; las condiciones, los costes de energía y el orden robado limitan cada recorrido."
 lines[#lines+1]=""; lines[#lines+1]=valid and "Validación: **correcta**." or "Validación: **fallida**."
 for _,message in ipairs(errors) do lines[#lines+1]="- "..message end
 return table.concat(lines,"\n").."\n"
end
return Validator
