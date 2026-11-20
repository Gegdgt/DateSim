local Story = require("src.data.story")
local Events = require("src.systems.events")
local Progression = {}
local characters = {"sylphiette", "roxy", "eris"}

local function containsCharacter(id)
    return Story.companionNames[id] ~= nil
end

local function savedChoice(session, sceneId)
    local scene = Story.scenes[sceneId]
    if not scene or not scene.choices then return nil end
    local selected = session.decisions["choice_" .. sceneId]
    for _, choice in ipairs(scene.choices) do
        if choice.id == selected then return choice end
    end
end

local function move(session, checkpoint)
    session.checkpoint = checkpoint
    session.dialogueIndex = 1
    session.encounter = nil
    return checkpoint
end

local function allMeetings(session)
    for _, id in ipairs(characters) do
        if not session.events["meeting_" .. id] then return false end
    end
    return true
end

function Progression.availableCompanions(session)
    local available = {}
    if allMeetings(session) then
        for _, id in ipairs(characters) do available[#available+1] = id end
    end
    return available
end

function Progression.visit(session, character)
    if session.checkpoint ~= "hub" or session.day ~= 2 then return nil, "No estás en el mapa del día 2." end
    if not containsCharacter(character) then return nil, "Acompañante desconocido." end
    if session.events["meeting_" .. character] then return nil, "Este encuentro ya está completado." end
    return move(session, "meet_" .. character)
end

function Progression.selectCompanion(session, character)
    if session.checkpoint ~= "hub" or not allMeetings(session) then
        return nil, "Visita a los tres personajes antes de salir hacia las ruinas."
    end
    if not containsCharacter(character) then return nil, "Acompañante desconocido." end
    Events.apply(session, "companion_selected", {decision="companion", value=character})
    -- Un guardado parcial puede conservar el evento y perder su decisión.
    -- Elegir desde el mapa siempre restablece el acompañante explícitamente.
    session.decisions.companion = character
    return move(session, "seal_intro")
end

function Progression.choose(session, sceneId, choiceId)
    if session.checkpoint ~= sceneId then return false, "Esta escena ya no está activa." end
    local scene = Story.scenes[sceneId]
    if not scene or not scene.choices then return false, "La escena no contiene decisiones." end
    local key = "choice_" .. sceneId
    local previous = savedChoice(session, sceneId)
    if previous then
        if previous.id == choiceId then return true end
        return false, "Esta decisión ya quedó guardada."
    end
    for _, choice in ipairs(scene.choices) do
        if choice.id == choiceId then
            Events.apply(session, key, choice.effects)
            session.decisions[key] = choiceId
            return true
        end
    end
    return false, "Decisión desconocida."
end

local function resolveText(text, session)
    local id = session.decisions.companion or "sylphiette"
    local replacements = {
        companion=Story.companionNames[id] or "tu acompañante",
        companionAdvice=Story.companionAdvice[id] or "Lo resolveremos juntos.",
        companionMemory=Story.companionMemory[id] or "Compartimos un recuerdo verdadero.",
    }
    return (text:gsub("{(%w+)}", function(key) return replacements[key] or "{" .. key .. "}" end))
end

-- Copia resuelta: nunca se modifica el contenido estático compartido.
function Progression.scene(session, id)
    local original = Story.scenes[id]
    if not original then return nil end
    local scene = {title=original.title, background=original.background, lines={}}
    if not savedChoice(session, id) then scene.choices = original.choices end
    local function append(line)
        scene.lines[#scene.lines+1] = {
            speaker=line.speaker == "companion" and (session.decisions.companion or "sylphiette") or line.speaker,
            expression=line.expression or "neutral", text=resolveText(line.text, session),
        }
    end
    if original.resultLines then
        local outcome = session.decisions["outcome_" .. original.resultKey] or "partial"
        append(original.resultLines[outcome] or original.resultLines.partial)
    end
    for _, line in ipairs(original.lines) do append(line) end
    return scene
end

function Progression.encounter(session, id)
    local original = Story.encounters[id]
    if not original then return nil end
    local encounter = {}
    for key, value in pairs(original) do encounter[key] = value end
    if encounter.character == "companion" then encounter.character = session.decisions.companion end
    return encounter
end

local function recordEncounter(session, checkpoint, result)
    local definition = Progression.encounter(session, checkpoint)
    local score = type(result) == "table" and tonumber(result.score) or 0
    score = score or 0
    local success = score >= definition.targetScore
    local key = "resolved_" .. checkpoint
    if not session.events[key] then
        local trust = type(result) == "table" and tonumber(result.trust) or 0
        local chemistry = type(result) == "table" and tonumber(result.chemistry) or 0
        Events.apply(session, key, {
            decision="outcome_" .. checkpoint, value=success and "success" or "partial",
            character=definition.character, trust=trust or 0, chemistry=chemistry or 0,
        })
        session.lastResult = {
            score=score, success=success, character=definition.character, title=definition.title,
            trust=trust or 0, chemistry=chemistry or 0,
        }
    end
end

function Progression.next(session, checkpoint, result)
    checkpoint = checkpoint or session.checkpoint
    if session.checkpoint ~= checkpoint then return nil, "La pantalla de origen ya cambió." end
    local scene = Story.scenes[checkpoint]
    if scene and scene.choices and not savedChoice(session, checkpoint) then
        return nil, "Elige una respuesta antes de continuar."
    end
    if Story.encounters[checkpoint] then recordEncounter(session, checkpoint, result) end
    if checkpoint == "intro" then return move(session, "day1_tutorial") end
    if checkpoint == "day1_tutorial" then return move(session, "day1_result") end
    if checkpoint == "day1_result" then
        Events.apply(session, "first_anomaly", {unlock={"self_joke"}})
        return move(session, "day1_close")
    end
    if checkpoint == "day1_close" then
        Events.apply(session, "day1_complete")
        session.day = 2
        return move(session, "hub")
    end
    for _, character in ipairs(characters) do
        if checkpoint == "meet_" .. character then return move(session, "encounter_" .. character) end
        if checkpoint == "encounter_" .. character then return move(session, "result_" .. character) end
        if checkpoint == "result_" .. character then
            Events.apply(session, "meeting_" .. character, {character=character, relationshipEvent="reunion"})
            if allMeetings(session) then Events.apply(session, "all_reunions", {unlock={"remember"}}) end
            return move(session, "hub")
        end
    end
    if checkpoint == "seal_intro" then return move(session, "seal_encounter") end
    if checkpoint == "seal_encounter" then return move(session, "seal_result") end
    if checkpoint == "seal_result" then
        Events.apply(session, "seal_memory", {
            character=session.decisions.companion, relationshipEvent="memory_seal", trust=1,
        })
        return move(session, "day2_close")
    end
    if checkpoint == "day2_close" then
        Events.apply(session, "day2_complete")
        Events.apply(session, "phase1_complete")
        return move(session, "phase_complete")
    end
    if checkpoint == "phase_complete" or checkpoint == "hub" then return checkpoint end
    return nil, "Punto de historia desconocido: " .. tostring(checkpoint)
end

return Progression
