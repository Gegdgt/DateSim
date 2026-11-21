-- Pruebas de los contratos de UX: explicaciones obtenidas del cálculo real,
-- acciones idempotentes y guía restaurable sin saltar instrucciones.
local Suite={}

function Suite.run()
    local Cards=require("src.systems.cards")
    local Data=require("src.data.cards")
    local Tutorial=require("src.systems.tutorial")
    local Save=require("src.systems.save")
    local Options=require("src.systems.options")
    local Json=require("src.systems.json")
    local Chapters=require("src.data.chapters")
    local Validator=require("src.systems.narrative_validator")
    local Progression=require("src.systems.progression")
    local checked=0
    local function check(ok,message) assert(ok,message); checked=checked+1 end
    local function encode(value) return assert(Json.encode(value)) end
    local function clone(value)
        if type(value)~="table" then return value end
        local out={}; for key,item in pairs(value) do out[key]=clone(item) end; return out
    end
    local function roundtrip(session)
        return assert(Save.validate(assert(Json.decode(encode(session)))))
    end
    local Relationships=require("src.systems.relationships")
    local relations=Relationships.new()
    relations.roxy.trust=9; relations.roxy.chemistry=0
    local before=encode(relations)
    local projected=Relationships.preview(relations,"roxy",{trust=4,chemistry=-2})
    check(projected.trust==1 and projected.chemistry==0,"La vista de cierre respeta ambos límites de relación")
    check(encode(relations)==before,"Consultar el cambio de vínculo no modifica estadísticas")
    Relationships.apply(relations,"roxy",{trust=4,chemistry=-2})
    check(relations.roxy.trust==9+projected.trust and relations.roxy.chemistry==projected.chemistry,"El cierre aplica exactamente el delta anunciado")
    check(Relationships.preview(relations,"nanahoshi",{trust=5}).trust==0,"No se promete vínculo romántico con Nanahoshi")
    local function deckFor(id)
        local deck=clone(Data.starterDeck)
        local existing
        for i,value in ipairs(deck) do if value==id then existing=i end end
        if existing then deck[existing],deck[10]=deck[10],deck[existing] else deck[10]=id end
        return deck
    end
    local metrics={"score","trust","chemistry"}
    local kinds={"conversation","investigation","magic"}
    local people={"sylphiette","roxy","eris"}
    for _,card in ipairs(Data.list) do
        for _,kind in ipairs(kinds) do
            for _,character in ipairs(people) do
                local deck=deckFor(card.id)
                local enc=Cards.new(deck,{kind=kind,character=character},function(n) return n end)
                local before=encode(enc)
                local result=Cards.preview(enc,1)
                local label=card.id.."/"..kind.."/"..character
                check(result.cardId==card.id and result.cost==card.cost and result.contextKind==kind,"Identidad, contexto y coste: "..label)
                check(encode(enc)==before,"Consultar no juega: "..label)
                for _,metric in ipairs(metrics) do
                    local base=(card.effects or {})[metric] or 0
                    local contextual=(card.contexts[kind] or {})[metric] or 0
                    local affinity=(card.affinities[character] or {})[metric] or 0
                    check(result.base[metric]==base and result.contextBonus[metric]==contextual
                        and result.affinityBonus[metric]==affinity,"Desglose canónico de "..metric..": "..label)
                    check(result[metric]==result.base[metric]+result.contextBonus[metric]
                        +result.affinityBonus[metric]+result.targetAdjustment[metric],"Suma de capas "..metric..": "..label)
                end
                local played=Cards.play(enc,1,1)
                if card.conditions.character and card.conditions.character~=character then
                    check(not played and encode(enc)==before,"Exclusiva incompatible no cambia nada: "..label)
                else
                    check(played and encode(played)==encode(result),"Aplicar coincide con la explicación: "..label)
                    check(enc.energy==4-card.cost and enc.energy>=0,"Pagar exactamente una vez: "..label)
                    local after=encode(enc)
                    check(not Cards.play(enc,1,1) and not Cards.pass(enc,1) and encode(enc)==after,"Token de turno rechaza doble pulsación: "..label)
                end
            end
            local scratch={hand={card.id},context={kind=kind,character="nanahoshi"}}
            local nonRomantic=Cards.preview(scratch,1)
            check(nonRomantic.trust==0 and nonRomantic.chemistry==0,"Nanahoshi no recibe puntos románticos: "..card.id.."/"..kind)
            for _,metric in ipairs(metrics) do
                check(nonRomantic[metric]==nonRomantic.base[metric]+nonRomantic.contextBonus[metric]
                    +nonRomantic.affinityBonus[metric]+nonRomantic.targetAdjustment[metric],"Ajuste sin romance explicado: "..card.id.."/"..metric)
            end
        end
    end

    -- Fixture aislada: no se cambian cartas existentes ni se añade contenido al
    -- catálogo. La entrada temporal se retira incluso si falla una aserción.
    local fixtureId="__ux_negative_fixture"
    check(Data.byId[fixtureId]==nil,"El fixture negativo no es una carta de producción")
    Data.byId[fixtureId]={id=fixtureId,name="Prueba negativa",category="sincerity",cost=2,
        effects={score=2,trust=-2,chemistry=1},contexts={magic={score=-1,trust=1,chemistry=-3}},
        affinities={roxy={score=-2,trust=-2,chemistry=1}},conditions={}}
    local negativeOK,negativeError=xpcall(function()
        local enc={hand={fixtureId},context={kind="magic",character="roxy"},energy=4,finished=false,
            drawPile={},discard={},log={},score=0,turn=1,maxTurns=3}
        local result=assert(Cards.play(enc,1,1))
        check(result.score==-1 and result.trust==-3 and result.chemistry==-1,"Deltas negativos reales")
        check(result.text:find("-1 avance",1,true) and result.text:find("-3 confianza",1,true),"Texto muestra signo negativo")
        check(not result.text:find("+-",1,true),"No presentar un negativo como bonificación")
        check(Cards.describe(result):find("-1 química",1,true),"Panel usa el desglose negativo")
        check(enc.energy==2 and enc.score==-1 and #enc.log==1,"La acción negativa se aplica una sola vez")
    end,debug.traceback)
    Data.byId[fixtureId]=nil
    assert(negativeOK,negativeError)
    check(#Data.list==16 and Data.byId[fixtureId]==nil,"Catálogo original intacto tras fixture")

    local free=Cards.new(Data.starterDeck,{kind="magic"},function(n) return n end)
    free.energy=0
    local beforeFree=encode(free)
    check(not Cards.play(free,1,1) and encode(free)==beforeFree,"Carta de coste dos no gasta con energía cero")
    for turn=1,3 do
        check(Cards.pass(free,turn)~=nil and free.energy==0,"Respiro válido sin energía: "..turn)
        local after=encode(free)
        check(not Cards.pass(free,turn) and encode(free)==after,"Respiro duplicado no consume otro turno: "..turn)
    end
    check(free.finished and #free.log==3 and #free.discard==0,"Tres respiros cierran encuentro sin bloqueo")

    local profile=Options.normalize()
    local session=Save.newSession({love=65,trust=65})
    session.checkpoint="day1_tutorial"
    session.encounter=Cards.new(session.deck,{kind="magic"},function(n) return n end)
    session.tutorial=Tutorial.restore(nil,session.encounter)
    local function checkpoint(expected)
        check(session.tutorial.stage==expected,"Orden tutorial: "..expected)
        check(Tutorial.instruction(session.tutorial)~=nil,"Instrucción visible: "..expected)
        local originalEncounter=encode(session.encounter)
        local originalRelationships=encode(session.relationships)
        session=roundtrip(session)
        check(session.tutorial and session.tutorial.stage==expected,"Restaurar paso: "..expected)
        check(encode(session.encounter)==originalEncounter,"Restaurar cartas y cálculo: "..expected)
        check(encode(session.relationships)==originalRelationships,"Restaurar vínculos: "..expected)
        check(session.encounter.energy>=0 and session.encounter.energy<=4,"Energía válida en paso: "..expected)
    end
    checkpoint("hand")
    check(not Tutorial.skip(session,profile),"No omitir sin haber completado la guía")
    check(not Tutorial.canAct(session.tutorial,1) and not Tutorial.canAct(session.tutorial),"La mano debe explicarse antes de jugar")
    check(not Tutorial.complete(session,profile),"No completar sin las tres acciones")
    check(Tutorial.advance(session.tutorial),"Confirmar explicación de la mano")
    checkpoint("energy")
    check(not Tutorial.canAct(session.tutorial,1),"La energía se explica antes de jugar")
    check(Tutorial.advance(session.tutorial),"Confirmar explicación de energía")
    checkpoint("select")
    check(not Tutorial.advance(session.tutorial),"No completar selección leyendo otro panel")
    check(not Tutorial.canAct(session.tutorial,1),"Hace falta consultar antes de jugar")
    check(Tutorial.select(session.tutorial),"Selección real habilita confirmación")
    checkpoint("ready")
    check(Tutorial.canAct(session.tutorial,1) and not Tutorial.canAct(session.tutorial),"Primera acción requiere una carta")
    check(not Tutorial.advance(session.tutorial),"Confirmar un texto no simula jugar")
    check(Cards.play(session.encounter,1,1)~=nil,"Jugar la carta recomendada")
    Tutorial.action(session.tutorial,session.encounter)
    session.encounterReview=true
    checkpoint("result")
    check(session.encounterReview==true,"La lectura del resultado se restaura")
    check(not Tutorial.canAct(session.tutorial,1),"Leer consecuencias antes de otra carta")
    check(Tutorial.advance(session.tutorial),"Confirmar consecuencias reales")
    checkpoint("draw")
    check(#session.encounter.hand==3 and #session.encounter.drawPile==6 and #session.encounter.discard==1,"Descarte y robo reales explicados")
    check(not Tutorial.canAct(session.tutorial,1),"Leer el robo antes de actuar")
    check(Tutorial.advance(session.tutorial),"Confirmar el robo")
    checkpoint("second")
    check(Tutorial.canAct(session.tutorial,1) and not Tutorial.canAct(session.tutorial),"Segunda acción requiere otra carta")
    check(Cards.play(session.encounter,1,2)~=nil,"Jugar segunda carta")
    Tutorial.action(session.tutorial,session.encounter)
    checkpoint("second_result")
    check(not Tutorial.advance({stage="ready"}),"No saltar acción pendiente con continuar")
    check(Tutorial.advance(session.tutorial),"Pasar de segunda consecuencia a demostración")
    checkpoint("free_demo")
    local energy=session.encounter.energy
    check(Tutorial.advance(session.tutorial),"Probar rechazo real de carta sin energía")
    checkpoint("free")
    check(session.encounter.energy==energy,"Demostración no altera energía real")
    check(Tutorial.canAct(session.tutorial) and not Tutorial.canAct(session.tutorial,1),"El paso gratuito exige usar respiro")
    check(not Tutorial.advance(session.tutorial),"No completar respiro sin ejecutar acción")
    check(Cards.pass(session.encounter,3)~=nil,"Ejecutar respiro gratuito del tercer turno")
    Tutorial.action(session.tutorial,session.encounter)
    checkpoint("summary")
    check(session.encounter.finished and #session.encounter.log==3,"Resumen contiene tres acciones reales")
    check(not Tutorial.canAct(session.tutorial,1) and not Tutorial.canAct(session.tutorial),"Resumen ya no admite acciones")
    check(Tutorial.restore({stage="complete"},session.encounter).stage=="summary","Reparar complete incoherente sin bloquear")
    local beforeCompletion=encode(session.encounter)
    check(Tutorial.complete(session,profile),"Finalizar guía tras las acciones y resumen")
    check(profile.tutorialCompleted and session.events.tutorial_completed,"Registrar completado en perfil y partida")
    check(not Tutorial.complete(session,profile) and encode(session.encounter)==beforeCompletion,"No completar ni recompensar dos veces")
    session=roundtrip(session)
    check(session.events.tutorial_completed and not session.tutorial,"Restaurar completado sin reactivar guía")
    check(Progression.next(session,session.checkpoint,{score=session.encounter.score,trust=0,chemistry=0})=="day1_result","Guía permite continuar historia")
    check(session.encounter==nil and session.encounterReview==nil and session.tutorial==nil,"La transición limpia estado de práctica")
    local nextGame=Save.newSession({love=65,trust=65})
    nextGame.checkpoint="day1_tutorial"
    nextGame.encounter=Cards.new(nextGame.deck,{kind="magic"},function(n) return n end)
    nextGame.tutorial=Tutorial.restore(nil,nextGame.encounter)
    local beforeSkip=encode(nextGame.encounter)
    check(Tutorial.skip(nextGame,profile),"Perfil completado permite omitir guía en nueva partida")
    check(not nextGame.tutorial and nextGame.events.tutorial_completed and encode(nextGame.encounter)==beforeSkip,"Omitir no altera mano, energía ni recompensas")
    local restoredSkip=roundtrip(nextGame)
    check(restoredSkip.events.tutorial_completed and not restoredSkip.tutorial,"Omisión conservada al guardar y cargar")
    for _,invalid in ipairs({"does_not_exist","summary","second_result","free"}) do
        check(Tutorial.restore({stage=invalid},nextGame.encounter).stage=="hand","Reparar paso incompatible con registro vacío: "..invalid)
    end

    local function catalogChange(change)
        local list=clone(Chapters.list)
        change(list[1].scenes.intro)
        return Chapters.build(list)
    end
    local function invalid(change,fragment)
        local ok,errors=Validator.validate(catalogChange(change),{checkFiles=false})
        check(not ok and table.concat(errors,"; "):find(fragment,1,true),"Diagnosticar metadato inválido: "..fragment)
    end
    for _,kind in ipairs({"fade","fade_in","horizontal","new_day","magic","return"}) do
        check(Validator.validate(catalogChange(function(scene) scene.transition={type=kind,duration=.4} end),{checkFiles=false}),"Aceptar transición declarativa "..kind)
    end
    for _,kind in ipairs({"enter_left","enter_right","happy_bounce","shake","expression_change","exit_left","exit_right"}) do
        check(Validator.validate(catalogChange(function(scene) scene.lines[1].animation={type=kind,expression="happy"} end),{checkFiles=false}),"Aceptar animación declarativa "..kind)
    end
    for _,context in ipairs({"menu","university","casual","romantic","mystery","forest","tension","mirror","festival"}) do
        check(Validator.validate(catalogChange(function(scene) scene.music=context end),{checkFiles=false}),"Aceptar contexto musical "..context)
    end
    invalid(function(scene) scene.music="unknown_music" end,"contexto musical desconocido")
    invalid(function(scene) scene.animation="spin_blur" end,"animación desconocida")
    invalid(function(scene) scene.lines[1].animation={type="shake",unknown=true} end,"campo de animación desconocido")
    invalid(function(scene) scene.lines[1].animation={type="expression_change",expression="crying"} end,"expresión de animación desconocida")
    invalid(function(scene) scene.exitAnimation="unknown_exit" end,"salida de personaje desconocida")
    invalid(function(scene) scene.transition="fade" end,"transición visual inválida")
    invalid(function(scene) scene.transition={type="unknown"} end,"tipo de transición visual desconocido")
    for _,duration in ipairs({0,.1,1,math.huge,".4"}) do
        invalid(function(scene) scene.transition={type="fade",duration=duration} end,"duración visual fuera")
    end
    local executed=false
    invalid(function(scene) scene.animation=function() executed=true end end,"código ejecutable")
    check(not executed,"Validar metadatos nunca ejecuta código narrativo")
    print("Experience: "..checked.." checks passed (card breakdowns, action tokens, tutorial restoration and presentation metadata).")
    return checked
end

return Suite
