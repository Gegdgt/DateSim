-- Pruebas puras Lua: no leen ni escriben la partida real.
local Suite = {}

function Suite.run()
    local Story = require("src.data.story")
    local Characters = require("src.data.characters")
    local Dialogue = require("src.systems.dialogue")
    local Progression = require("src.systems.progression")
    local Events = require("src.systems.events")
    local Relationships = require("src.systems.relationships")
    local Save = require("src.systems.save")
    local Json = require("src.systems.json")
    local Cards = require("src.systems.cards")
    local checked = 0
    local function check(condition, message)
        assert(condition, message)
        checked = checked + 1
    end
    local function roundtrip(session)
        return assert(Save.validate(assert(Json.decode(assert(Json.encode(session))))))
    end
    local function nextTo(session, expected, result)
        local nextId, err = Progression.next(session, session.checkpoint, result)
        check(nextId == expected, "Avance a " .. expected .. ": " .. tostring(err))
        check(session.dialogueIndex == 1 and session.encounter == nil, "Limpiar estado de pantalla anterior")
        return roundtrip(session)
    end

    local session = Save.newSession()
    local expressions = {neutral=true, happy=true, worried=true, angry=true}
    for id in pairs(Story.scenes) do
        local scene = Progression.scene(session, id)
        check(scene and #scene.lines > 0, "Escena no vacía: " .. id)
        local dialogue = Dialogue.new(scene, 1)
        check(dialogue:current() == scene.lines[1], "Primera línea: " .. id)
        for i = 1, #scene.lines - 1 do
            check(not dialogue:advance() and dialogue.index == i + 1, "Una línea por avance: " .. id)
        end
        check(dialogue:isLast() and dialogue:advance() and dialogue:advance(), "Final estable: " .. id)
        check(Dialogue.new(scene, -200).index == 1, "Limitar índice inferior")
        check(Dialogue.new(scene, 200).index == #scene.lines, "Limitar índice superior")
        for _, line in ipairs(scene.lines) do
            check(line.speaker == "narrator" or Characters.byId[line.speaker], "Personaje conocido: " .. id)
            check(expressions[line.expression], "Expresión conocida: " .. id)
            check(not line.text:find("{"), "Sustituciones resueltas: " .. id)
        end
    end
    check(not pcall(Dialogue.new, {lines={}}), "Rechazar escena vacía")
    check(not Progression.visit(session, "roxy"), "No visitar durante introducción")
    check(not Progression.selectCompanion(session, "roxy"), "No elegir compañero antes de las visitas")

    -- Recorrido independiente para cada compañero y cada tipo de resultado.
    for _, companion in ipairs({"sylphiette", "roxy", "eris"}) do
        for _, score in ipairs({0, 8}) do
            session = Save.newSession()
            session = nextTo(session, "day1_tutorial")
            session = nextTo(session, "day1_result", {score=score, trust=9, chemistry=9})
            check(session.relationships[companion].trust == 0, "Tutorial no afecta relaciones ajenas")
            check(session.decisions.outcome_day1_tutorial == (score >= 5 and "success" or "partial"), "Resultado del tutorial")
            session = nextTo(session, "day1_close")
            check(session.unlocked.self_joke, "Desbloquear Reírse de uno mismo")
            session = nextTo(session, "hub")
            check(session.day == 2 and #Progression.availableCompanions(session) == 0, "Inicio de día dos")
            check(not Progression.selectCompanion(session, companion), "No saltar reencuentros")
            for _, character in ipairs({"eris", "sylphiette", "roxy"}) do
                check(Progression.visit(session, character) == "meet_" .. character, "Visita en orden libre")
                local checkpoint = session.checkpoint
                check(not Progression.next(session), "Requerir elección explícita")
                check(not Progression.choose(session, checkpoint, "missing"), "Rechazar elección desconocida")
                local choices = Story.scenes[checkpoint].choices
                local selected = choices[1]
                check(Progression.choose(session, checkpoint, selected.id), "Aplicar elección")
                check(Progression.choose(session, checkpoint, selected.id), "Repetir misma elección es idempotente")
                check(not Progression.choose(session, checkpoint, choices[2].id), "No sustituir elección confirmada")
                check(session.relationships[character].trust == 1, "Puntos de elección una sola vez")
                session = roundtrip(session)
                check(Progression.scene(session, checkpoint).choices == nil, "Al cargar elección confirmada se permite continuar")
                check(Progression.scene(session, checkpoint).lines[#Story.scenes[checkpoint].lines], "Conservar líneas al ocultar opciones")
                session = nextTo(session, "encounter_" .. character)
                local context = Progression.encounter(session, session.checkpoint)
                session.encounter = Cards.new(session.deck, context, function(n) return n end)
                Cards.pass(session.encounter)
                local saved = roundtrip(session)
                check(saved.encounter and saved.encounter.turn == 2, "Restaurar encuentro a mitad")
                check(saved.encounter.context.kind == context.kind and saved.encounter.context.character == character,
                    "Guardar no cambia contexto del encuentro")
                session = nextTo(session, "result_" .. character, {score=score, trust=3, chemistry=2})
                check(session.relationships[character].trust == 4, "Aplicar deltas al completar encuentro")
                check(session.relationships[character].chemistry == 2, "Aplicar química del encuentro")
                check(not Progression.next(session, "encounter_" .. character, {score=8, trust=3}), "No repetir resultado desde pantalla antigua")
                local resultScene = Progression.scene(session, session.checkpoint)
                check(resultScene.lines[1].text == Story.scenes[session.checkpoint].resultLines[score >= 5 and "success" or "partial"].text,
                    "Diálogo refleja éxito o avance parcial")
                session = nextTo(session, "hub")
                check(session.relationships[character].events.reunion, "Registrar evento del personaje")
                check(not Progression.visit(session, character), "No repetir reencuentro terminado")
            end
            check(session.unlocked.remember and #Progression.availableCompanions(session) == 3, "Desbloquear recuerdo y salida a ruinas")
            check(not Progression.selectCompanion(session, "unknown"), "Rechazar compañero desconocido")
            check(Progression.selectCompanion(session, companion) == "seal_intro", "Elegir compañero explícitamente")
            check(session.decisions.companion == companion and session.route == nil, "Compañero todavía no es ruta romántica")
            session = roundtrip(session)
            local seal = Progression.scene(session, "seal_intro")
            check(seal.lines[3].speaker == companion and seal.lines[3].text == Story.companionAdvice[companion], "Variante del consejo del compañero")
            session = nextTo(session, "seal_encounter")
            local context = Progression.encounter(session, "seal_encounter")
            check(context.character == companion and context.kind == "magic", "Contexto mágico con compañero")
            session.encounter = Cards.new(session.deck, context, function(n) return n end)
            Cards.pass(session.encounter)
            session = roundtrip(session)
            check(session.encounter and session.encounter.context.kind == "magic", "Conservar contexto mágico del sello al guardar")
            session = nextTo(session, "seal_result", {score=score, trust=1, chemistry=0})
            local result = Progression.scene(session, "seal_result")
            check(result.lines[3].speaker == companion and result.lines[3].text == Story.companionMemory[companion], "Variante del recuerdo del compañero")
            session = nextTo(session, "day2_close")
            check(session.events.seal_memory and session.relationships[companion].events.memory_seal, "Obtener sello incluso con cero puntos")
            check(session.relationships[companion].trust == 6, "Puntos totales del compañero")
            check(not Events.apply(session, "seal_memory", {character=companion, trust=8}), "Sello idempotente")
            check(session.relationships[companion].trust == 6, "No duplicar puntos del sello")
            session = nextTo(session, "phase_complete")
            check(session.events.phase1_complete and session.day == 2, "Terminar contenido exactamente en día dos")
            check(Relationships.ending(session.relationships, session.route, session.decisions) == "independent", "No asignar romance al terminar Fase 1")
        end
    end

    local invalid = Save.validate({version=1, checkpoint="missing", dialogueIndex=999})
    check(invalid and invalid.checkpoint == "intro", "Recuperar checkpoint desconocido")
    check(Dialogue.new(Progression.scene(invalid, invalid.checkpoint), invalid.dialogueIndex):current(), "Índice inválido no bloquea diálogo")
    local partial = Save.validate({version=1, checkpoint="seal_encounter", events={companion_selected=true}})
    check(partial and partial.checkpoint == "hub" and not partial.decisions.companion, "Volver al mapa si se perdió el compañero")
    check(not partial.events.companion_selected, "Permitir nueva selección tras guardado incompleto")
    partial.events.meeting_sylphiette, partial.events.meeting_roxy, partial.events.meeting_eris = true, true, true
    check(Progression.selectCompanion(partial, "eris") == "seal_intro" and partial.decisions.companion == "eris", "Reparar elección de compañero")
    local lostChoice = Save.newSession()
    lostChoice.day, lostChoice.checkpoint = 2, "meet_roxy"
    lostChoice.events.choice_meet_roxy = true
    lostChoice.relationships.roxy.trust = 4
    check(Progression.choose(lostChoice, "meet_roxy", "compare_notes"), "Recuperar decisión perdida con evento persistido")
    check(lostChoice.relationships.roxy.trust == 4, "Recuperar decisión sin volver a aplicar puntos")
    check(Progression.next(lostChoice) == "encounter_roxy", "Continuar después de recuperar elección")

    print("OK: " .. checked .. " comprobaciones de narrativa, progresión y carga intermedia.")
    return checked
end

return Suite
