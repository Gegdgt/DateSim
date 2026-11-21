-- Validación estática conservadora. Los caminos condicionales necesitan una
-- salida de reserva o cubrir todas las respuestas/resultados del nodo.
local Characters=require("src.data.characters")
local Cards=require("src.data.cards")
local Assets=require("src.data.assets")
local Conditions=require("src.systems.conditions")
local Presentation=require("src.data.presentation")
local Appearances=require("src.data.appearances")
local Audio=require("src.data.audio")
local Validator={}
local function identifier(value) return type(value)=="string" and value:match("^[%w_]+$")~=nil end
local function merged(base,variant)
    local out={}; for key,value in pairs(base) do out[key]=value end
    for key,value in pairs(variant or {}) do out[key]=value end
    return out
end

local function validate(catalog,options)
    catalog=catalog or require("src.data.chapters")
    options=options or {}
    local errors,events,decisions,requirements,graph,terminal={},{},{},{},{},{}
    local producers,guardedSelections={},{}
    local nodes=catalog.checkpoints or {}
    local function fail(where,message) errors[#errors+1]=where..": "..message end
    for _,message in ipairs(catalog.buildErrors or {}) do errors[#errors+1]=message end
    local function pure(value,path,seen)
        local kind=type(value)
        if kind=="function" or kind=="userdata" or kind=="thread" then fail(path,"los datos no pueden contener código ejecutable")
        elseif kind=="table" then
            if seen[value] then fail(path,"referencia circular en datos"); return end
            seen[value]=true
            for key,item in pairs(value) do pure(item,path.."."..tostring(key),seen) end
            seen[value]=nil
        end
    end
    for _,chapter in ipairs(catalog.list or {}) do pure(chapter,tostring(chapter.id),{}) end
    local function character(id,where,optional)
        if id==nil and optional then return end
        if id~="companion" and id~="narrator" and not Characters.byId[id] then fail(where,"personaje desconocido: "..tostring(id)) end
    end
    local function background(id,where)
        local path=Assets.backgrounds[id]
        if not path then fail(where,"fondo desconocido: "..tostring(id))
        elseif options.checkFiles~=false and love and love.filesystem and not love.filesystem.getInfo(path,"file") then fail(where,"PNG de fondo inexistente: "..path) end
    end
    local function animation(value,where)
        if value==nil then return end
        local kind=type(value)=="table" and value.type or value
        if type(kind)~="string" or not Presentation.animations[kind] then fail(where,"animación desconocida") end
        if type(value)=="table" then
            for key in pairs(value) do if key~="type" and key~="expression" then fail(where,"campo de animación desconocido") end end
            if value.expression and not Characters.expressions[value.expression] then fail(where,"expresión de animación desconocida") end
        end
    end
    -- La identidad narrativa y el recurso visual tienen registros distintos.
    -- Un retrato alternativo nunca habilita un nuevo hablante o vínculo.
    local function portrait(value,where)
        if value==nil then return end
        local path=type(value)=="string" and Assets.characters[value]
        if not path then fail(where,"retrato desconocido: "..tostring(value))
        elseif options.checkFiles~=false and love and love.filesystem and not love.filesystem.getInfo(path,"file") then
            fail(where,"PNG de retrato inexistente: "..path)
        end
    end
    local function visualCharacter(id,where)
        if type(id)~="string" or not Characters.byId[id] then
            fail(where,"identidad visual desconocida: "..tostring(id))
            return false
        end
        return true
    end
    local function expression(value,where)
        if value~=nil and (type(value)~="string" or Characters.expressions[value]==nil) then
            fail(where,"expresión visual desconocida")
        end
    end
    local function portraitMap(value,where)
        if value==nil then return end
        if type(value)~="table" then fail(where,"mapa de retratos inválido"); return end
        for id,resource in pairs(value) do
            visualCharacter(id,where)
            portrait(resource,where)
        end
    end
    local function appearanceContext(value,where)
        if value.context==nil then return end
        local context=type(value.context)=="string" and Appearances.contexts[value.context]
        if type(context)~="table" then fail(where,"contexto de apariencia desconocido: "..tostring(value.context)); return end
        if context.background~=nil then background(context.background,where) end
        portraitMap(context.portraits,where)
        return context
    end
    local function sceneBackground(value,where)
        local context=type(value.context)=="string" and Appearances.contexts[value.context]
        background(value.background or (type(context)=="table" and context.background),where)
    end
    local function cast(value,where)
        local seen,positions={},{}
        if value.cast==nil then return seen end
        if type(value.cast)~="table" then fail(where,"reparto visual inválido"); return seen end
        local count=0
        for key,actor in pairs(value.cast) do
            count=count+1
            if type(key)~="number" or key%1~=0 or key<1 or key>#value.cast then fail(where,"reparto visual debe ser una lista continua") end
            if type(actor)~="table" then fail(where,"actor visual inválido")
            else
                if visualCharacter(actor.character,where) then
                    if seen[actor.character] then fail(where,"identidad duplicada en el reparto visual") end
                    seen[actor.character]=true
                end
                local position=actor.position
                if position==nil then position="left" end
                if position~="left" and position~="right" then fail(where,"posición visual desconocida")
                elseif positions[position] then fail(where,"posición duplicada en el reparto visual")
                else positions[position]=true end
                local enterAt=actor.enterAt
                if enterAt~=nil and (type(enterAt)~="number" or enterAt~=enterAt or enterAt%1~=0 or enterAt<1 or enterAt>#(value.lines or {})) then
                    fail(where,"línea de entrada visual inválida")
                end
                local delay=actor.entranceDelay
                if delay~=nil and (type(delay)~="number" or delay~=delay or delay<0 or delay>1) then
                    fail(where,"demora de entrada visual fuera de 0 a 1 segundos")
                end
                expression(actor.expression,where)
                for key in pairs(actor) do
                    if key~="character" and key~="position" and key~="expression" and key~="enterAt" and key~="entranceDelay" then
                        fail(where,"campo de reparto visual desconocido: "..tostring(key))
                    end
                end
            end
        end
        if count<1 or count>2 then fail(where,"el reparto visual requiere uno o dos personajes") end
        return seen
    end
    local function stage(value,where,castIds)
        if value==nil then return end
        if type(value)~="table" then fail(where,"dirección visual inválida"); return end
        for id,change in pairs(value) do
            if not castIds[id] then fail(where,"dirección visual para un personaje ajeno al reparto: "..tostring(id)) end
            if type(change)~="table" then fail(where,"cambio visual inválido")
            else
                portrait(change.portrait,where)
                expression(change.expression,where)
                animation(change.animation,where)
                if change.visible~=nil and type(change.visible)~="boolean" then fail(where,"visibilidad de personaje inválida") end
                for key in pairs(change) do
                    if key~="portrait" and key~="expression" and key~="visible" and key~="animation" then fail(where,"campo de dirección visual desconocido: "..tostring(key)) end
                end
            end
        end
    end
    local function presentation(value,where)
        if value.music~=nil and not Audio.music[value.music] then fail(where,"contexto musical desconocido") end
        animation(value.animation,where)
        if value.exitAnimation and value.exitAnimation~="exit_left" and value.exitAnimation~="exit_right" then fail(where,"salida de personaje desconocida") end
        for _,field in ipairs({"transition","entranceTransition"}) do
            local transition=value[field]
            if transition~=nil then
                if type(transition)~="table" then fail(where,"transición visual inválida ("..field..")")
                else
                    if not Presentation.transitions[transition.type] then fail(where,"tipo de transición visual desconocido ("..field..")") end
                    local duration=transition.duration
                    if duration~=nil and (type(duration)~="number" or duration~=duration or duration<.25 or duration>.6) then fail(where,"duración visual fuera de .25 a .6 segundos ("..field..")") end
                end
            end
        end
    end
    local function condition(value,where)
        local ok,err=Conditions.validate(value)
        if not ok then fail(where,err) elseif value then requirements[#requirements+1]={value=value,where=where} end
    end
    local function produced(id,from,to)
        producers[id]=producers[id] or {}
        producers[id][#producers[id]+1]={from=from,to=to or from}
    end
    local function effect(value,where,day,implicitId,to)
        if type(value)~="table" then fail(where,"efecto inválido"); return end
        local id=implicitId or value.id
        if not identifier(id) then fail(where,"evento sin identificador estable") else events[id]=true; produced(id,where,to) end
        character(value.character,where,true)
        condition(value.requires,where)
        if value.decision then
            if not identifier(value.decision) then fail(where,"decisión inválida") else decisions[value.decision]=true end
        end
        if value.route~=nil then
            local route=Characters.byId[value.route]
            if not route or not route.romance then fail(where,"ruta romántica desconocida")
            elseif day<5 then fail(where,"elección de ruta antes del día cinco") end
        end
        for _,subeffect in ipairs(value.batch or {}) do effect(subeffect,where,day,id,to) end
        for _,field in ipairs({"trust","chemistry","love"}) do
            local amount=value[field]
            if amount~=nil and (type(amount)~="number" or amount~=amount or math.abs(amount)>100) then fail(where,"delta de vínculo inválido") end
        end
        for _,idCard in ipairs(value.unlock or {}) do
            local card=Cards.byId[idCard] or require("src.data.combat_cards").byId[idCard]
            if not card then fail(where,"carta desconocida: "..tostring(idCard))
            elseif (card.unlockedAt or 1)>day then fail(where,"carta desbloqueada antes de su capítulo: "..idCard) end
        end
    end
    local function edge(from,to,where)
        if not nodes[to] then fail(where,"destino inexistente: "..tostring(to)); return end
        graph[from]=graph[from] or {}; graph[from][to]=true
    end
    local function line(value,where,castIds)
        if type(value)~="table" then fail(where,"línea inválida"); return end
        character(value.speaker,where)
        if type(value.text)~="string" or value.text=="" then fail(where,"línea sin texto") end
        if value.expression and Characters.expressions[value.expression]==nil then fail(where,"expresión desconocida") end
        local delivery={dream=true,thought=true,note=true,enchanted=true,silence=true,memory=true}
        if value.delivery and not delivery[value.delivery] then fail(where,"canal de comunicación desconocido") end
        if value.speaker=="rudeus" and nodes[where] and nodes[where].day<7 and not value.delivery then
            fail(where,"Rudy necesita pensamiento, escritura, carta, silencio o voz mental mientras está maldito")
        end
        if value.stateEffect then effect(value.stateEffect,where,nodes[where] and nodes[where].day or 1) end
        animation(value.animation,where)
        portrait(value.portrait,where)
        stage(value.stage,where,castIds or {})
        condition(value.requires,where)
    end
    local function scene(value,id,day)
        appearanceContext(value,id)
        portraitMap(value.portraits,id)
        local castIds=cast(value,id)
        if value.document and not require("src.data.documents")[value.document] then fail(id,"documento desconocido") end
        local unconditionalLine=false
        for _,item in ipairs(value.lines or {}) do line(item,id,castIds); if type(item)=="table" and item.requires==nil then unconditionalLine=true end end
        if value.resultLines then
            if not nodes[value.resultKey] or nodes[value.resultKey].kind~="encounter" then fail(id,"resultado de encuentro desconocido") end
            for _,outcome in ipairs({"success","partial"}) do
                local selected=value.resultLines[outcome]
                if type(selected)~="table" then fail(id,"falta resultado "..outcome)
                elseif selected.speaker then line(selected,id,castIds); unconditionalLine=unconditionalLine or selected.requires==nil
                else
                    if #selected==0 then fail(id,"resultado vacío") end
                    for _,item in ipairs(selected) do line(item,id,castIds); unconditionalLine=unconditionalLine or (type(item)=="table" and item.requires==nil) end
                end
            end
        end
        if not unconditionalLine then fail(id,"escena sin diálogo garantizado") end
        local seen,unconditionalChoice,familyOptions={},false,{}
        for _,choice in ipairs(value.choices or {}) do
            if not identifier(choice.id) or seen[choice.id] then fail(id,"decisión duplicada o inválida") end
            seen[choice.id]=true
            if type(choice.label)~="string" or choice.label=="" then fail(id,"decisión sin etiqueta") end
            condition(choice.requires,id)
            unconditionalChoice=unconditionalChoice or choice.requires==nil
            if choice.requires and type(choice.requires.familyReady)=="boolean" then familyOptions[choice.requires.familyReady]=true end
            effect(choice.effects or {},id,day,"choice_"..id)
            decisions["choice_"..id]=true
        end
        if #(value.choices or {})>0 and not unconditionalChoice and not (familyOptions[true] and familyOptions[false]) then fail(id,"decisiones sin opción de reserva") end
    end
    local function encounter(value,id)
        character(value.character,id,true)
        if not ({conversation=true,investigation=true,magic=true})[value.kind] then fail(id,"contexto de cartas desconocido") end
        if type(value.targetScore)~="number" or value.targetScore~=value.targetScore or value.targetScore<0 or value.targetScore>100 then fail(id,"objetivo de encuentro inválido") end
        for _,adjustment in ipairs(value.adjustments or {}) do
            condition(adjustment.requires,id)
            for key in pairs(adjustment) do if key~="requires" and key~="targetScore" and key~="intro" then fail(id,"ajuste desconocido: "..key) end end
            local score=adjustment.targetScore
            if score~=nil and (type(score)~="number" or score~=score or score<0 or score>100) then fail(id,"objetivo ajustado inválido") end
            if adjustment.intro~=nil and type(adjustment.intro)~="string" then fail(id,"introducción ajustada inválida") end
        end
        events["resolved_"..id]=true; decisions["outcome_"..id]=true
        produced("resolved_"..id,id,id)
        if value.training then
            for _,record in pairs(require("src.data.training_dialogue")) do
                events[record.eventId]=true;produced(record.eventId,id,id)
            end
            events.eris_training_reconciled=true;produced("eris_training_reconciled",id,id)
            decisions.eris_training_result=true;decisions.eris_training_last_result=true
        end
    end
    local function covered(node,transitions)
        local coveredValues={}
        for _,transition in ipairs(transitions) do
            if transition.requires==nil then return true end
            local conditionData=transition.requires
            if type(conditionData)=="table" and conditionData.decision then
                local key=node.kind=="encounter" and "outcome_"..node.id or "choice_"..node.id
                if conditionData.decision==key then
                    for _,value in ipairs(conditionData.oneOf or {conditionData.equals}) do coveredValues[value]=true end
                end
            end
        end
        if node.kind=="encounter" then return coveredValues.success and coveredValues.partial end
        local required={}
        for _,choice in ipairs(node.definition.choices or {}) do required[#required+1]=choice.id end
        for _,variant in pairs(node.definition.variants or {}) do for _,choice in ipairs(variant.choices or {}) do required[#required+1]=choice.id end end
        if #required==0 then return false end
        for _,id in ipairs(required) do if not coveredValues[id] then return false end end
        return true
    end
    local days={}
    for _,chapter in ipairs(catalog.list or {}) do
        local where=tostring(chapter.id)
        if not identifier(chapter.id) then fail(where,"ID de capítulo inválido") end
        if type(chapter.day)~="number" or chapter.day%1~=0 or chapter.day<1 or chapter.day>7 or days[chapter.day] then fail(where,"día inválido o duplicado") end
        days[chapter.day]=true
        if chapter.nextChapter and not catalog.byId[chapter.nextChapter] then fail(where,"siguiente capítulo desconocido") end
        if chapter.implemented~=false then
            for _,runtime in ipairs(chapter.runtimeEvents or {}) do
                if not identifier(runtime.id) or not nodes[runtime.checkpoint] then fail(where,"Productor de evento dinámico inválido")
                else events[runtime.id]=true;produced(runtime.id,runtime.checkpoint,runtime.checkpoint) end
            end
            if not nodes[chapter.initial] or nodes[chapter.initial].chapterId~=chapter.id then fail(where,"entrada de capítulo inexistente") end
            if chapter.companion then
                local selection=nodes[chapter.companion.selectionCheckpoint]
                if not selection or selection.kind~="hub" then fail(where,"selector de compañía desconocido") end
                if not identifier(chapter.companion.decisionKey) then fail(where,"clave de compañía inválida") end
            end
            for from,transitions in pairs(chapter.transitions or {}) do
                if not nodes[from] or nodes[from].chapterId~=chapter.id then fail(where,"origen de transición desconocido: "..tostring(from)) end
                if type(transitions)~="table" then fail(where,"transiciones inválidas")
                else
                    for _,transition in ipairs(transitions) do
                        edge(from,transition.to,from)
                        condition(transition.requires,from)
                        for _,value in ipairs(transition.effects or {}) do effect(value,from,chapter.day,nil,transition.to) end
                    end
                end
            end
        elseif chapter.initial then fail(where,"un capítulo futuro no debe declarar entrada jugable") end
    end
    for id,node in pairs(nodes) do
        local raw=node.definition
        local chapter=catalog.byId[node.chapterId]
        if type(raw)~="table" then fail(id,"nodo inválido")
        else
            if type(raw.title)~="string" or raw.title=="" then fail(id,"nodo sin título") end
            sceneBackground(raw,id)
            if raw.requires~=nil then fail(id,"requires no se interpreta en nodos; usa transition.requires") end
            if raw.requiresCompanion and not chapter.companion then fail(id,"requiere compañía sin selector de capítulo") end
            local definitions={}
            if raw.variants then
                for characterId,variant in pairs(raw.variants) do
                    character(characterId,id)
                    definitions[#definitions+1]=merged(raw,variant)
                end
                for _,characterId in ipairs(Characters.romanceIds) do
                    if not raw.variants[characterId] then definitions[#definitions+1]=raw end
                end
            else definitions[1]=raw end
            for _,value in ipairs(definitions) do
                presentation(value,id)
                if value.requires~=nil then fail(id,"requires no se interpreta en nodos o variantes; usa transition.requires") end
                sceneBackground(value,id)
                if node.kind=="scene" then scene(value,id,node.day)
                elseif node.kind=="encounter" then encounter(value,id) end
            end
            if node.kind=="hub" then
                for _,location in ipairs(raw.locations or chapter.locations or {}) do
                    character(location.character,id); background(location.background,id); condition(location.requires,id)
                    if location.scene then edge(id,location.scene,id) end
                    if location.completedEvent then requirements[#requirements+1]={value={event=location.completedEvent},where=id} end
                end
                local selection=raw.companion
                if selection then
                    condition(selection.requires,id); edge(id,selection.to,id)
                    effect({id=selection.event,decision=selection.decision},id,node.day,nil,selection.to)
                    if selection.requires then guardedSelections[#guardedSelections+1]={from=id,to=selection.to,requires=selection.requires} end
                    if #(selection.options or {})==0 then fail(id,"selector sin opciones") end
                    for _,characterId in ipairs(selection.options or {}) do if characterId~="all" then character(characterId,id) end end
                end
                if not graph[id] or not next(graph[id]) then fail(id,"lugar sin salida") end
            elseif raw.terminal then
                if node.kind~="summary" then fail(id,"solo un resumen puede cerrar el contenido") end
                terminal[id]=true
                if #(chapter.transitions[id] or {})>0 then fail(id,"resumen terminal con transición jugable") end
            else
                local transitions=(chapter.transitions or {})[id] or {}
                if #transitions==0 then fail(id,"escena sin salida válida")
                elseif not covered(node,transitions) then fail(id,"transiciones sin salida segura; añade una reserva incondicional") end
            end
        end
    end
    -- Las decisiones de cartas se producen en el motor declarativo, dentro del
    -- checkpoint del encuentro, y son requisitos válidos de capítulos futuros.
    local dialogue=require("src.data.dialogue")
    for sceneId,nodeId in pairs(dialogue.encounters) do
        local checkpoint=sceneId=="nanahoshi_test" and "day1_tutorial" or sceneId
        decisions["dialogue_"..sceneId]=true
        local function response(record)
            for _,flag in ipairs(record.flags or {}) do events[flag]=true;decisions[flag]=true;produced(flag,checkpoint,checkpoint) end
            for _,variant in ipairs(record.variants or {}) do response(variant) end
        end
        for _,record in pairs(dialogue.nodes[nodeId].cards) do response(record) end
    end
    local function references(value,where)
        if value.event and not events[value.event] then fail(where,"evento requerido sin productor: "..value.event) end
        if value.decision and not decisions[value.decision] then fail(where,"decisión requerida desconocida: "..value.decision) end
        for _,child in ipairs(value.all or value.any or {}) do references(child,where) end
        if value['not'] then references(value['not'],where) end
    end
    for _,requirement in ipairs(requirements) do references(requirement.value,requirement.where) end
    -- Cada punto debe ser alcanzable desde el inicio y poder llegar al cierre.
    local reachable={}
    local function visit(id)
        if reachable[id] or not nodes[id] then return end
        reachable[id]=true
        for target in pairs(graph[id] or {}) do visit(target) end
    end
    local first=catalog.first or (catalog.list or {})[1]
    if first then visit(first.initial) else fail("catálogo","no contiene capítulos") end
    -- Los eventos obligatorios para una expedición deben poder obtenerse sin
    -- cruzar su propia salida: evita pedir el sello futuro para salir a buscarlo.
    local function mandatory(conditionData,negated)
        local out={}
        if type(conditionData)~="table" then return out end
        if conditionData.event then
            local positive=conditionData.equals~=false
            if negated then positive=not positive end
            if positive then out[conditionData.event]=true end
        elseif conditionData['not'] then return mandatory(conditionData['not'],not negated)
        elseif conditionData.all or conditionData.any then
            local children=conditionData.all or conditionData.any
            local union=(conditionData.all~=nil)~=(not not negated)
            for index,child in ipairs(children) do
                local required=mandatory(child,negated)
                if union then for eventId in pairs(required) do out[eventId]=true end
                elseif index==1 then out=required
                else for eventId in pairs(out) do if not required[eventId] then out[eventId]=nil end end end
            end
        end
        return out
    end
    for _,selection in ipairs(guardedSelections) do
        local before={}
        local function beforeSelection(id)
            if before[id] or not nodes[id] then return end
            before[id]=true
            for target in pairs(graph[id] or {}) do
                if id~=selection.from or target~=selection.to then beforeSelection(target) end
            end
        end
        if first then beforeSelection(first.initial) end
        for eventId in pairs(mandatory(selection.requires,false)) do
            local possible=false
            for _,producer in ipairs(producers[eventId] or {}) do
                if before[producer.from] and (producer.from~=selection.from or producer.to~=selection.to) then possible=true end
            end
            if not possible then fail(selection.from,"selección bloqueada por evento posterior o inaccesible: "..eventId) end
        end
    end
    local exits={}; for id in pairs(terminal) do exits[id]=true end
    local changed=true
    while changed do
        changed=false
        for id,targets in pairs(graph) do
            for target in pairs(targets) do
                if exits[target] and not exits[id] then exits[id]=true; changed=true end
            end
        end
    end
    for id in pairs(nodes) do
        if not reachable[id] and not nodes[id].definition.legacyEncounter and not nodes[id].definition.historical then fail(id,"checkpoint inalcanzable desde el inicio") end
        if not exits[id] then fail(id,"ruta bloqueada o ciclo sin un resumen terminal") end
    end
    return #errors==0,errors
end

-- Un error de forma también es un diagnóstico de autoría, no una excepción
-- sin contexto al recorrer una tabla parcialmente escrita.
function Validator.validate(catalog,options)
    local ok,valid,errors=pcall(validate,catalog,options)
    if not ok then return false,{"Estructura narrativa inválida: "..tostring(valid)} end
    return valid,errors
end

function Validator.assertValid(catalog,options)
    local ok,errors=Validator.validate(catalog,options)
    assert(ok,"Narrativa inválida:\n"..table.concat(errors,"\n"))
    return true
end

return Validator
