local Story=require("src.data.story")
local Chapters=require("src.data.chapters")
local Characters=require("src.data.characters")
local Events=require("src.systems.events")
local Conditions=require("src.systems.conditions")
local Daily=require("src.systems.daily")
local Progression={}

local function copy(value)
    local out={}; for key,item in pairs(value or {}) do out[key]=item end; return out
end
local function chapterFor(checkpoint)
    local node=Chapters.checkpoints[checkpoint]
    return node and Chapters.byId[node.chapterId]
end
function Progression.companion(session,checkpoint)
    local chapter=chapterFor(checkpoint or session.checkpoint)
    local key=chapter and chapter.companion and chapter.companion.decisionKey
    local id=key and (session.decisions or {})[key]
    if id=="all" then
        for _,wife in ipairs(Characters.romanceIds) do if require("src.systems.family").active(session,wife) then return wife end end
    end
    if id and Characters.byId[id] and Characters.byId[id].romance and require("src.systems.family").active(session,id) then return id end
end
local function context(session,checkpoint) return {companion=Progression.companion(session,checkpoint)} end
local function meets(session,condition,checkpoint) return Conditions.evaluate(session,condition,context(session,checkpoint)) end
local function resolveText(text,session,checkpoint)
    if type(text)~="string" then return text end
    local id=Progression.companion(session,checkpoint) or "solo"
    local replacements={companion=Story.companionNames[id] or "Rudy",
        companionAdvice=Story.companionAdvice[id] or "Debo revisar la ruta antes de avanzar.",
        companionMemory=Story.companionMemory[id] or "Conservo lo que aprendí durante el viaje."}
    return (text:gsub("{(%w+)}",function(key) return replacements[key] or "{"..key.."}" end))
end
local function definition(session,checkpoint)
    local node=Chapters.checkpoints[checkpoint]
    if not node then return nil end
    local raw=copy(node.definition)
    local selected=Progression.companion(session,checkpoint) or "solo"
    for key,value in pairs((raw.variants or {})[selected] or {}) do raw[key]=value end
    return raw
end
function Progression.choices(session,sceneId)
    local scene=definition(session,sceneId)
    return scene and scene.choices or {}
end
local function savedChoice(session,sceneId)
    local selected=(session.decisions or {})["choice_"..sceneId]
    for _,choice in ipairs(Progression.choices(session,sceneId)) do if choice.id==selected then return choice end end
end
local function move(session,checkpoint)
    local routes=require("src.data.family_routes")
    for _=1,20 do
        local route=routes[checkpoint]
        if not route or require("src.systems.family").active(session,route.wife) then break end
        Events.apply(session,"skipped_"..checkpoint,{context="family",text="Se respeta la separación de "..Characters.byId[route.wife].shortName.."; su encuentro matrimonial no se realiza."})
        if route.complete then Events.apply(session,"day5_complete",{text="Preparación familiar concluida respetando las separaciones."}) end
        checkpoint=route.to
    end
    local node=Chapters.checkpoints[checkpoint]
    if not node then return nil,"Destino narrativo desconocido: "..tostring(checkpoint) end
    session.checkpoint,session.day=checkpoint,node.day
    Daily.ensure(session)
    Daily.deliverFavors(session)
    session.dialogueIndex,session.encounter=1,nil
    session.encounterReview,session.tutorial=nil,nil
    session.combat,session.combatPreparation,session.trainingReview=nil,nil,nil
    return checkpoint
end
function Progression.skipUnavailable(session)
    local route=require("src.data.family_routes")[session.checkpoint]
    if route and not require("src.systems.family").active(session,route.wife) then return move(session,session.checkpoint) end
end
local function applyEffect(session,effect,checkpoint)
    if not meets(session,effect.requires,checkpoint) then return false end
    local resolved=copy(effect)
    if resolved.character=="companion" then resolved.character=Progression.companion(session,checkpoint) end
    if resolved.presenter=="companion" then resolved.presenter=Progression.companion(session,checkpoint) end
    return Events.apply(session,effect.id,resolved)
end
local function applyEffects(session,effects,checkpoint)
    for _,effect in ipairs(effects or {}) do applyEffect(session,effect,checkpoint) end
end

function Progression.hub(session)
    local node=Chapters.checkpoints[session.checkpoint]
    if not node or node.kind~="hub" then return nil end
    local hub=copy(node.definition)
    hub.locations=hub.locations or chapterFor(session.checkpoint).locations or {}
    return hub
end
function Progression.continueStory(session)
    if not Daily.atAgenda(session) or Daily.storyComplete(session) then return nil,"No hay historia pendiente en esta agenda." end
    local d=Daily.ensure(session)
    if d.active_activity or d.ending_processed then return nil,"Termina la actividad pendiente antes de continuar." end
    local config=Daily.config(session)
    if config.lockBeforeStory then
        local ok,err=Daily.lockActivities(session); if not ok then return nil,err end
    end
    return move(session,session.day==7 and session.events.antidote_obtained and "day7_intro" or config.story)
end
function Progression.endDay(session)
    if not Daily.atAgenda(session) then return nil,"Vuelve a la agenda para finalizar el día." end
    local report,err=Daily.finish(session)
    if not report then return nil,err end
    return move(session,Daily.config(session).summary)
end
function Progression.availableCompanions(session)
    local hub=Progression.hub(session)
    local selection=hub and hub.companion
    local available={}
    if selection and meets(session,selection.requires,session.checkpoint) then
        for _,id in ipairs(selection.options or {}) do if id=="all" or require("src.systems.family").active(session,id) then available[#available+1]=id end end
        available[#available+1]="solo"
    end
    return available
end
function Progression.visit(session,character)
    local hub=Progression.hub(session)
    if not hub then return nil,"No estás en un lugar de preparación." end
    for _,location in ipairs(hub.locations) do
        if location.character==character and location.scene then
            if location.completedEvent and session.events[location.completedEvent] then return nil,"Este encuentro ya está completado." end
            if not meets(session,location.requires,session.checkpoint) then return nil,"Esta visita todavía no está disponible." end
            return move(session,location.scene)
        end
    end
    return nil,"Visita desconocida."
end
function Progression.selectCompanion(session,character)
    local hub=Progression.hub(session)
    local selection=hub and hub.companion
    if not selection then return nil,"No puedes elegir compañía en esta pantalla." end
    local available=false
    for _,id in ipairs(Progression.availableCompanions(session)) do if id==character then available=true end end
    if not available then return nil,"Completa los requisitos y elige un acompañante disponible." end
    if not Chapters.checkpoints[selection.to] then return nil,"El destino de la expedición no está disponible." end
    Events.apply(session,selection.event,{decision=selection.decision,value=character})
    -- Recupera una elección perdida de un guardado parcial sin volver a premiar.
    session.decisions[selection.decision]=character
    return move(session,selection.to)
end
function Progression.choose(session,sceneId,choiceId)
    if session.checkpoint~=sceneId then return false,"Esta escena ya no está activa." end
    local node=Chapters.checkpoints[sceneId]
    if not node or node.kind~="scene" then return false,"La escena no contiene decisiones." end
    local previous=savedChoice(session,sceneId)
    if previous then
        if previous.id==choiceId then return true end
        return false,"Esta decisión ya quedó guardada."
    end
    for _,choice in ipairs(Progression.choices(session,sceneId)) do
        if choice.id==choiceId then
            if not meets(session,choice.requires,sceneId) then return false,"Esta respuesta no está disponible." end
            local key="choice_"..sceneId
            local effect=copy(choice.effects)
            effect.id=key
            effect.text=choice.label
            local _,err=applyEffect(session,effect,sceneId)
            if err then return false,err end
            session.decisions[key]=choiceId
            return true
        end
    end
    return false,"Decisión desconocida."
end
function Progression.scene(session,id)
    local node=Chapters.checkpoints[id]
    if not node or node.kind~="scene" then return nil end
    local raw=definition(session,id)
    local scene=copy(raw)
    scene.title=resolveText(raw.title,session,id)
    scene.lines={}
    scene.choices=nil
    if not savedChoice(session,id) and raw.choices then
        scene.choices={}
        for _,choice in ipairs(raw.choices) do
            if meets(session,choice.requires,id) then scene.choices[#scene.choices+1]=choice end
        end
    end
    local function append(line)
        if not meets(session,line.requires,id) then return end
        if session.relationships[line.speaker] and not require("src.systems.family").active(session,line.speaker) then return end
        scene.lines[#scene.lines+1]={
            speaker=line.speaker=="companion" and (Progression.companion(session,id) or "narrator") or line.speaker,
            expression=line.expression or "neutral",animation=line.animation,text=resolveText(line.text,session,id),
            delivery=line.delivery,effect=line.effect,stateEffect=line.stateEffect,
            portrait=line.portrait,stage=line.stage}
        local added=scene.lines[#scene.lines]
        if added.speaker=="rudeus" and not require("src.systems.curse").canSpeak(session,added.delivery) then
            added.delivery=session.events.starter_gift and "enchanted" or "thought"
        end
    end
    if raw.resultLines then
        local outcome=(session.decisions or {})["outcome_"..raw.resultKey] or "partial"
        local selected=raw.resultLines[outcome] or raw.resultLines.partial
        if selected.speaker then append(selected) else for _,line in ipairs(selected) do append(line) end end
    end
    for _,line in ipairs(raw.lines or {}) do append(line) end
    if #scene.lines==0 then scene.lines={{speaker="narrator",text="Rudy respeta la decisión de quienes se marcharon y continúa con las responsabilidades pendientes."}} end
    if id=="day6_intro" and next(require("src.systems.family").ensure(session).departures) then
        scene.lines[1].text="Cliff vigila las lecturas y Zanoba lleva el contenedor. Rudy decidirá si viaja con una esposa disponible o afronta el desafío solo. Quienes se marcharon no están convocadas."
    end
    if id=="day6_close" and session.events.antidote_obtained then
        scene.lines={{speaker="nanahoshi",expression="happy",text="El antídoto que ganaste sigue a salvo. Lo verificaremos al amanecer; no hace falta repetir el desafío."}}
    end
    if id=="day7_voice" and next(require("src.systems.family").ensure(session).departures) then
        for _,line in ipairs(scene.lines) do if line.speaker=="narrator" and line.text:find("las tres",1,true) then line.text="Rudy explica la maldición a quienes siguen a su lado. La recuperación de su voz no revoca ninguna separación." end end
    end
    return scene
end
function Progression.encounter(session,id)
    local node=Chapters.checkpoints[id]
    if not node or node.kind~="encounter" then return nil end
    local encounter=definition(session,id)
    if id=="day6_hitogami" and session.decisions.legacy_emissary_encounter then encounter.enemyId="hitogami_minion" end
    if encounter.character=="companion" then encounter.character=Progression.companion(session,id) end
    for _,adjustment in ipairs(encounter.adjustments or {}) do
        if meets(session,adjustment.requires,id) then
            if adjustment.targetScore~=nil then encounter.targetScore=adjustment.targetScore end
            if adjustment.intro~=nil then encounter.intro=adjustment.intro end
        end
    end
    encounter.title=resolveText(encounter.title,session,id)
    encounter.intro=resolveText(encounter.intro,session,id)
    return encounter
end
function Progression.summary(session)
    local node=Chapters.checkpoints[session.checkpoint]
    if not node or node.kind~="summary" then return nil end
    local summary=copy(node.definition)
    if summary.ending then
        local id,reason=require("src.systems.relationships").ending(session.relationships)
        local ending=id and require("src.data.endings").byId[id]
        if ending then
            for key,value in pairs(ending) do summary[key]=value end
            summary.endingId=id
            summary.epilogue=ending.footer
            summary.footer="Fin de la campaña · El diario conserva tus decisiones."
        else
            summary.body="Falta resolver los acuerdos matrimoniales: "..tostring(reason)
        end
    end
    for key,value in pairs(summary) do if type(value)=="string" then summary[key]=resolveText(value,session,session.checkpoint) end end
    return summary
end
local function transitions(checkpoint)
    local chapter=chapterFor(checkpoint)
    return chapter and chapter.transitions and chapter.transitions[checkpoint] or {}
end
function Progression.canContinue(session)
    local node=Chapters.checkpoints[session.checkpoint]
    if not node or node.kind~="summary" or node.definition.terminal then return false end
    for _,transition in ipairs(transitions(session.checkpoint)) do
        if Chapters.checkpoints[transition.to] and meets(session,transition.requires,session.checkpoint) then return true end
    end
    return false
end
local function finite(value)
    value=tonumber(value)
    return value and value==value and math.abs(value)<math.huge and value or 0
end
local function recordEncounter(session,checkpoint,result)
    local encounter=Progression.encounter(session,checkpoint)
    local score=finite(type(result)=="table" and result.score)
    local success=score>=encounter.targetScore
    local key="resolved_"..checkpoint
    if not session.events[key] then
        local trust=finite(type(result)=="table" and result.trust)
        local chemistry=finite(type(result)=="table" and result.chemistry)
        Events.apply(session,key,{decision="outcome_"..checkpoint,value=success and "success" or "partial",
            character=encounter.character,trust=trust,chemistry=chemistry,
            text=encounter.title..(success and ": objetivo alcanzado." or ": tarea pendiente; la historia continúa.")})
        session.lastResult={score=score,success=success,character=encounter.character,title=encounter.title,
            targetScore=encounter.targetScore,trust=trust,chemistry=chemistry}
    end
end
function Progression.next(session,checkpoint,result)
    checkpoint=checkpoint or session.checkpoint
    if session.checkpoint~=checkpoint then return nil,"La pantalla de origen ya cambió." end
    local node=Chapters.checkpoints[checkpoint]
    if not node then return nil,"Punto de historia desconocido: "..tostring(checkpoint) end
    if node.definition.agenda then
        if Daily.storyComplete(session) then return Progression.endDay(session) end
        return Progression.continueStory(session)
    end
    if node.definition.finaleAction then
        local ok,err=require("src.systems.finale").advance(session,node.definition.finaleAction)
        if not ok then return nil,err end
    end
    if checkpoint==Daily.config(session).summary and not Daily.ensure(session).ending_processed then
        return nil,"Falta procesar el cierre de esta jornada."
    end
    if node.definition.document and not (session.clues and session.clues[node.definition.document]) then
        return nil,"Examina y lee la carta antes de continuar."
    end
    if node.definition.requiresCompanion and not Progression.companion(session,checkpoint) and not session.decisions[chapterFor(checkpoint).companion.decisionKey] then
        return nil,"Elige un acompañante antes de continuar."
    end
    if node.kind=="scene" and #Progression.choices(session,checkpoint)>0 and not savedChoice(session,checkpoint) then
        return nil,"Elige una respuesta antes de continuar."
    end
    if node.kind=="encounter" then
        if node.definition.requiresVictory and not (session.combat and session.combat.finished and session.combat.outcome=="victory") then return nil,"Completa primero el enfrentamiento." end
        if node.definition.scriptedDefeat and not (session.combat and session.combat.finished and session.combat.narrativeDefeat==node.definition.scriptedDefeat) then return nil,"Espera la señal que termina la demostración." end
        if node.definition.training and not session.events[require("src.systems.training_result").key(checkpoint)] then
            return nil,"Lee la valoración de Eris antes de cerrar el entrenamiento."
        end
        recordEncounter(session,checkpoint,result)
    end
    for _,transition in ipairs(transitions(checkpoint)) do
        if meets(session,transition.requires,checkpoint) then
            if not Chapters.checkpoints[transition.to] then return nil,"Destino narrativo no disponible." end
            applyEffects(session,transition.effects,checkpoint)
            return move(session,transition.to)
        end
    end
    if node.kind=="hub" or node.definition.terminal then return checkpoint end
    return nil,"Completa los requisitos antes de continuar."
end

-- Solo una victoria real entrega el premio, con una clave por checkpoint.
-- Los vínculos sociales jamás reciben deltas por infligir daño mágico.
function Progression.finishCombat(session,enc)
    local def=Progression.encounter(session,session.checkpoint)
    if def and def.enemyId=="orsted_demonstration" then
        if session.combat~=enc or not enc.finished or enc.narrativeDefeat~="orsted_demonstration" then return nil,"Orsted todavía no ha terminado la demostración." end
        return Progression.next(session,session.checkpoint,{score=def.targetScore,trust=0,chemistry=0})
    end
    if def and def.enemyId=="orsted_trial" and session.combat==enc and enc.finished and enc.outcome=="defeat" then
        Events.apply(session,"orsted_trial_completed",{text="Orsted detiene la prueba. Rudy conserva lo aprendido y sigue hacia el desafío final."})
        return Progression.next(session,session.checkpoint,{score=0,trust=0,chemistry=0})
    end
    if def and def.training then
        local Result=require("src.systems.training_result")
        if not Result.current(session,enc) then return nil,"El entrenamiento todavía no terminó." end
        if not session.events[Result.key(session.checkpoint)] then return nil,"Falta leer la reacción de Eris." end
        return Progression.next(session,session.checkpoint,{score=enc.outcome=="victory" and def.targetScore or 0,trust=0,chemistry=0})
    end
    if session.combat~=enc or not enc.finished or enc.outcome~="victory" then
        return nil,"El enfrentamiento todavía no tiene una victoria confirmada."
    end
    local checkpoint=session.checkpoint
    def=Progression.encounter(session,checkpoint)
    if not def or def.kind~="magic" then return nil,"No hay una anomalía activa." end
    require("src.systems.companions").record(session,enc)
    local enemy=require("src.data.enemies").byId[enc.enemy.id]
    local key="combat_reward_"..checkpoint
    if not session.events[key] then
        Events.apply(session,key,{gold=require("src.data.economy").rewards.combat[session.day],
            copies={[session.combatDeck[1] or "staff_strike"]=2},text="Recompensa del combate: oro y dos copias de tu primera técnica equipada."})
        Events.mark(session,"mirror_defeated_"..checkpoint)
        if enemy and enemy.narrativeEvent then Events.mark(session,enemy.narrativeEvent) end
        if enemy and enemy.reward and enemy.reward.event then Events.mark(session,enemy.reward.event) end
        session.decisions["combat_turns_"..checkpoint]=enc.turn
        session.defeatedEnemies=session.defeatedEnemies or {}
        session.defeatedEnemies[enc.enemy.id]=true
        for _,effect in ipairs(enc.relationshipEvents or {}) do
            local resolved=copy(effect); resolved.text=effect.reason or "Decisión compartida en combate."
            Events.apply(session,"tactic_"..checkpoint.."_"..effect.id,resolved)
        end
        if checkpoint=="day1_tutorial" then
            Events.apply(session,"first_anomaly",{unlock={"self_joke"}})
            Events.mark(session,"combat_tutorial_completed")
        end
        -- Una recompensa narrativa persiste por encuentro, sin multiplicarse
        -- al reabrir la pantalla de victoria o repetir el botón Continuar.
        session.decisions["combat_reward_text_"..checkpoint]=enemy and enemy.reward and enemy.reward.text or "Anomalía disipada"
    end
    return Progression.next(session,checkpoint,{score=def.targetScore,trust=0,chemistry=0})
end

return Progression
