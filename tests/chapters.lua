-- Regresión de capítulos y partidas de Fase 1. No escribe partidas ni recursos;
-- los fallos físicos se simulan mediante hooks que siempre se restauran.
local Suite={}

function Suite.run()
    local Chapters=require("src.data.chapters")
    local Progression=require("src.systems.progression")
    local Conditions=require("src.systems.conditions")
    local Validator=require("src.systems.narrative_validator")
    local Save=require("src.systems.save")
    local Cards=require("src.systems.cards")
    local Data=require("src.data.cards")
    local Events=require("src.systems.events")
    local Json=require("src.systems.json")
    local Font=require("src.ui.font")
    local count=0
    local function check(ok,message) assert(ok,message); count=count+1 end
    local function encode(value) return assert(Json.encode(value)) end
    local function copy(value)
        if type(value)~="table" then return value end
        local out={}; for k,v in pairs(value) do out[k]=copy(v) end
        return out
    end
    local function roundtrip(session)
        return assert(Save.validate(assert(Json.decode(encode(session)))))
    end
    local function advance(session,destination,result)
        local nextId,err=Progression.next(session,session.checkpoint,result)
        check(nextId==destination,"Avanzar a "..destination..": "..tostring(err))
        check(session.dialogueIndex==1 and session.encounter==nil,"Transición limpia el estado de pantalla")
        return roundtrip(session)
    end
    local companions={"sylphiette","roxy","eris"}
    local exclusive={"shared_magic","combined_spell","sword_magic","choose_together"}
    local function checkLocked(session)
        for _,id in ipairs(exclusive) do check(not session.unlocked[id],"No adelantar desbloqueo de "..id) end
    end

    -- Fixture del esquema anterior, no generado por Save.newSession ni por el
    -- registro nuevo: debe seguir siendo compatible aunque cambien ambos.
    local function legacy(companion)
        local session={version=1,day=2,checkpoint="phase_complete",dialogueIndex=1,
            relationships={},deck={"listen","encourage","light_joke","change_subject","be_honest",
                "admit_error","share_fear","propose_plan","analyze_runes","earth_barrier"},
            unlocked={remember=true,self_joke=true},
            events={first_anomaly=true,day1_complete=true,all_reunions=true,companion_selected=true,
                seal_memory=true,day2_complete=true,phase1_complete=true},
            decisions={companion=companion,choice_meet_sylphiette="listen_first",sylphiette_priority="listen",
                choice_meet_roxy="compare_notes",roxy_equality="colleagues",
                choice_meet_eris="mutual_support",eris_support="mutual"},
            options={volume=.3,muted=true},selectedCompanion=companion}
        for _,id in ipairs(session.deck) do session.unlocked[id]=true end
        for _,id in ipairs(companions) do
            session.relationships[id]={trust=1,chemistry=0,events={reunion=true},routeState="friend",decisions={}}
            session.events["meeting_"..id]=true
            session.events["choice_meet_"..id]=true
            if id==companion then session.relationships[id].events.memory_seal=true end
        end
        return session
    end

    local ok,errors=Validator.validate(Chapters)
    check(ok,"Registro narrativo válido: "..table.concat(errors or {},"; "))
    for day=1,3 do
        local chapter=Chapters.byId["day"..day]
        check(chapter and chapter.day==day and chapter.implemented~=false,"Capítulo implementado: "..day)
        check(Chapters.get(chapter.initial)~=nil,"Escena inicial registrada: "..day)
    end
    for day=4,7 do
        local chapter=Chapters.byId["day"..day]
        check(chapter and chapter.implemented==false,"Capítulo futuro declarado sin escenas: "..day)
        check(not chapter.initial or not Chapters.get(chapter.initial),"No publicar checkpoint futuro: "..day)
    end
    for _,id in ipairs({"intro","day1_tutorial","hub","meet_sylphiette","meet_roxy","meet_eris",
        "seal_intro","seal_encounter","seal_result","day2_close","phase_complete"}) do
        check(Chapters.get(id)~=nil,"Conservar checkpoint antiguo: "..id)
    end

    for _,oldCompanion in ipairs(companions) do
        local old=legacy(oldCompanion)
        local loaded=roundtrip(old)
        check(loaded.checkpoint=="phase_complete" and loaded.day==2,"Cargar resumen anterior sin saltos implícitos")
        check(encode(loaded.relationships)==encode(old.relationships),"Migrar conserva todos los vínculos")
        check(encode(loaded.decisions)==encode(old.decisions),"Migrar conserva decisiones antiguas")
        check(encode(loaded.deck)==encode(old.deck) and encode(loaded.unlocked)==encode(old.unlocked),
            "Migrar conserva mazo y colección")
        check(loaded.options.volume==.3 and loaded.options.muted,"Migrar conserva preferencias")
        check(Progression.canContinue(loaded),"Resumen de Fase 1 ofrece continuación")
        local before=encode(loaded.relationships)
        loaded=advance(loaded,"day3_intro")
        check(loaded.day==3 and loaded.decisions.companion==oldCompanion,"Avanzar día manteniendo compañía histórica")
        check(encode(loaded.relationships)==before and loaded.events.seal_memory,"Continuar no vuelve a conceder el primer sello")
        check(loaded.route==nil,"Continuar no fija una ruta romántica")
        checkLocked(loaded)
    end

    local variants={}
    local forestTexts,illusionTexts={},{}
    local choicesByCharacter={sylphiette={"agree_messages","stay_present"},
        roxy={"check_together","value_company"},eris={"share_guard","stand_beside"}}
    local successCards={sylphiette={"listen","be_honest","share_fear"},
        roxy={"propose_plan","analyze_runes","admit_error"},
        eris={"earth_barrier","encourage","propose_plan"}}
    local kinds={sylphiette="conversation",roxy="investigation",eris="magic"}
    local function orderedDeck(first)
        local chosen,deck={},{}
        for _,id in ipairs(first) do chosen[id]=true end
        for _,id in ipairs(Data.starterDeck) do if not chosen[id] then deck[#deck+1]=id end end
        for i=#first,1,-1 do deck[#deck+1]=first[i] end
        return deck
    end

    -- Cada acompañante, ambas decisiones y ambos resultados, con cargas
    -- intermedias y acciones reales del motor de cartas.
    for i,companion in ipairs(companions) do
        for choiceIndex=1,2 do
            for _,high in ipairs({false,true}) do
                local oldCompanion=companions[i%3+1]
                local session=roundtrip(legacy(oldCompanion))
                session=advance(session,"day3_intro")
                local intro=Progression.scene(session,"day3_intro")
                local speakers={}
                for _,line in ipairs(intro.lines) do speakers[line.speaker]=true end
                check(speakers.rudeus and speakers.nanahoshi and speakers.cliff,"Nueva pista reúne a Rudy, Nanahoshi y Cliff")
                session=advance(session,"day3_companion")
                check(#Progression.availableCompanions(session)==3,"Tres acompañantes disponibles cada día tres")
                local before=encode(session)
                check(not Progression.selectCompanion(session,"unknown"),"Rechazar compañía desconocida")
                check(encode(session)==before,"Selección inválida no altera estado")
                check(Progression.selectCompanion(session,companion)=="day3_forest","Elegir compañía para el bosque")
                check(session.decisions.day3_companion==companion and session.decisions.companion==oldCompanion,
                    "Compañías de día dos y tres independientes")
                check(session.route==nil,"Elección de expedición no bloquea romance")
                session=roundtrip(session)
                check(Progression.companion(session,"day3_forest")==companion,"Resolver acompañante desde capítulo")
                local forest=Progression.scene(session,"day3_forest")
                forestTexts[companion]=encode(forest.lines)
                check(forest.background=="forest" and #forest.lines>=3,"Conversación completa en el bosque")
                check(#forest.choices==2,"Dos decisiones propias del personaje")
                local found=false
                for _,line in ipairs(forest.lines) do
                    if line.speaker==companion then found=true end
                    check(Font.height(line.text,572)<=66,"Diálogo del bosque cabe sin recorte")
                end
                check(found,"Acompañante habla con voz propia en el bosque")
                check(not Progression.next(session),"No saltar una decisión pendiente del bosque")
                local choice=forest.choices[choiceIndex]
                check(choice.id==choicesByCharacter[companion][choiceIndex],"Decisión específica de "..companion)
                check(Font.height(choice.label,419)<=22,"Elección del bosque cabe en su botón")
                local trust,chemistry=session.relationships[companion].trust,session.relationships[companion].chemistry
                check(Progression.choose(session,"day3_forest",choice.id),"Confirmar decisión del bosque")
                check(session.relationships[companion].trust==trust+(choice.effects.trust or 0)
                    and session.relationships[companion].chemistry==chemistry+(choice.effects.chemistry or 0),
                    "Decisión concede solo sus deltas de relación")
                local afterChoice=encode(session.relationships)
                check(Progression.choose(session,"day3_forest",choice.id),"Repetir decisión confirmada es seguro")
                check(not Progression.choose(session,"day3_forest",forest.choices[3-choiceIndex].id),"No sustituir decisión confirmada")
                session=roundtrip(session)
                check(encode(session.relationships)==afterChoice,"Cargar decisión no duplica vínculos")
                check(Progression.scene(session,"day3_forest").choices==nil,"Escena contestada permite continuar al cargar")
                session=advance(session,"day3_illusion")
                local illusion=Progression.scene(session,"day3_illusion")
                illusionTexts[companion]=encode(illusion.lines)
                check(illusion.background=="ruins" and #illusion.lines>=3,"Ilusión completa en las ruinas")
                for _,line in ipairs(illusion.lines) do check(Font.height(line.text,572)<=66,"Ilusión cabe en cuadro de diálogo") end
                session=advance(session,"day3_encounter")
                session.deck=orderedDeck(successCards[companion])
                check(Cards.validateDeck(session.deck,session.unlocked),"Mazo de diez cartas normales para el encuentro")
                local definition=Progression.encounter(session,session.checkpoint)
                check(definition.character==companion and definition.kind==kinds[companion],"Contexto apropiado para el temor de "..companion)
                session.encounter=Cards.new(session.deck,{kind=definition.kind,character=definition.character},function(n) return n end)
                check(#session.encounter.hand==3 and session.encounter.energy==4 and session.encounter.maxTurns==3,
                    "Día tres conserva las reglas de cartas")
                local relationsBefore=encode(session.relationships)
                local baseTrust,baseChemistry=session.relationships[companion].trust,session.relationships[companion].chemistry
                for turn=1,3 do
                    local result
                    if high then result=Cards.play(session.encounter,1) else result=Cards.pass(session.encounter) end
                    check(result~=nil,"Acción válida del turno "..turn)
                    check(result.cardId==(high and successCards[companion][turn] or "pass"),"Acción esperada, sin sustituir una carta por un pase")
                    check(session.encounter.turn==turn+1 and #session.encounter.log==turn,"Una sola acción por turno")
                    local expected=encode(session.encounter)
                    session=roundtrip(session)
                    check(encode(session.encounter)==expected,"Cargar preserva pilas, energía, turno y registro")
                    check(encode(session.relationships)==relationsBefore,"Acción no confirma vínculos prematuramente")
                end
                check(session.encounter.finished,"Encuentro termina en tres acciones")
                local result={score=session.encounter.score,trust=0,chemistry=0}
                for _,entry in ipairs(session.encounter.log) do
                    result.trust=result.trust+entry.trust
                    result.chemistry=result.chemistry+entry.chemistry
                end
                check((result.score>=definition.targetScore)==high,"Las cartas apropiadas alcanzan éxito y pasar produce parcial")
                session=advance(session,"day3_result",result)
                check(session.decisions.outcome_day3_encounter==(high and "success" or "partial"),"Registrar resultado apropiado")
                check(session.relationships[companion].trust==math.min(10,baseTrust+result.trust)
                    and session.relationships[companion].chemistry==math.min(10,baseChemistry+result.chemistry),
                    "Confirmar exactamente los efectos de las cartas")
                local afterEncounter=encode(session.relationships)
                check(not Progression.next(session,"day3_encounter",result),"Confirmación desde pantalla anterior rechazada")
                check(encode(session.relationships)==afterEncounter,"Resultado repetido no duplica efectos")
                local replay=roundtrip(session)
                replay.checkpoint="day3_encounter"
                check(Progression.next(replay,"day3_encounter",result)=="day3_result","Revisitar encuentro registrado continúa")
                check(encode(replay.relationships)==afterEncounter,"Evento persistido impide duplicar recompensa al revisitar")
                local resultScene=Progression.scene(session,"day3_result")
                variants[companion..tostring(high)]=encode(resultScene.lines)
                check(#resultScene.lines>=2,"Resultado tiene diálogo narrativo")
                session=advance(session,"day3_truth")
                check(not session.events.seal_truth,"Visitar escena del sello no anticipa recompensa")
                local beforeSeal=session.relationships[companion].trust
                session=advance(session,"day3_return")
                check(session.events.seal_truth and session.unlocked.remember,"Recuperar Sello de la Verdad y recompensa normal")
                check(session.relationships[companion].trust==math.min(10,beforeSeal+1),"Sello concede confianza una vez")
                local afterSeal=encode(session.relationships)
                check(not Events.apply(session,"seal_truth",{character=companion,trust=4}),"Sello con clave estable es idempotente")
                session=roundtrip(session)
                check(encode(session.relationships)==afterSeal,"Guardar/cargar sello no modifica vínculos")
                replay=roundtrip(session); replay.checkpoint="day3_truth"
                check(Progression.next(replay)=="day3_return","Volver a escena del sello sigue permitiendo salir")
                check(encode(replay.relationships)==afterSeal,"Revisitar sello no concede premio otra vez")
                checkLocked(session)
                session=advance(session,"day3_complete")
                check(session.day==3 and session.events.day3_complete and session.events.seal_truth,"Cierre claro del día tres")
                check(session.decisions.companion==oldCompanion and session.decisions.day3_companion==companion,
                    "Resumen conserva ambas compañías y decisiones")
                check(session.route==nil and not Progression.canContinue(session),"Resumen no abre una ruta ni un capítulo incompleto")
                local terminal=encode(session)
                local nextId=Progression.next(session)
                check(nextId==nil or nextId=="day3_complete","Terminal no envía a escena inexistente")
                check(encode(session)==terminal,"Intentar continuar terminal no altera guardado")
                check(roundtrip(session).checkpoint=="day3_complete","Resumen final se restaura correctamente")
            end
        end
    end
    for i=1,#companions do
        local id=companions[i]
        check(variants[id.."true"]~=variants[id.."false"],"Éxito y parcial tienen diálogo distinto: "..id)
        for j=i+1,#companions do
            check(forestTexts[id]~=forestTexts[companions[j]],"Bosque distinto entre acompañantes")
            check(illusionTexts[id]~=illusionTexts[companions[j]],"Ilusión distinta entre acompañantes")
        end
    end

    for _,companion in ipairs(companions) do
        local adjusted=legacy("roxy")
        adjusted.day,adjusted.checkpoint=3,"day3_encounter"
        adjusted.decisions.day3_companion=companion
        adjusted.relationships[companion].trust=3
        check(Progression.encounter(adjusted,"day3_encounter").targetScore==5,"Vínculo bajo mantiene dificultad base")
        adjusted.relationships[companion].trust=4
        check(Progression.encounter(adjusted,"day3_encounter").targetScore==4,"Confianza acumulada ayuda sin cambiar reglas de cartas")
        adjusted=roundtrip(adjusted)
        check(Progression.encounter(adjusted,"day3_encounter").targetScore==4,"Carga conserva ajuste por relación")
    end

    local damaged=legacy("roxy")
    damaged.day,damaged.checkpoint=3,"day3_encounter"
    damaged.events.day3_companion_selected=true
    damaged=roundtrip(damaged)
    check(damaged.checkpoint=="day3_companion" and damaged.encounter==nil,"Compañía perdida recupera selector del día correcto")
    check(damaged.decisions.companion=="roxy" and not damaged.events.day3_companion_selected,
        "Recuperación no borra compañero histórico ni impide elegir de nuevo")
    check(Progression.selectCompanion(damaged,"eris")=="day3_forest","Guardado incompleto puede repararse sin reiniciar")
    damaged.decisions.choice_day3_forest="check_together"
    damaged.events.choice_day3_forest=true
    local beforeRepair=encode(damaged.relationships)
    damaged=roundtrip(damaged)
    check(damaged.decisions.choice_day3_forest==nil,"Descartar decisión que pertenece a otra variante")
    check(Progression.choose(damaged,"day3_forest","share_guard"),"Recuperar una decisión perdida o incompatible")
    check(encode(damaged.relationships)==beforeRepair,"Evento previo evita duplicar vínculos al reparar decisión")

    local reward=legacy("roxy")
    reward.day,reward.checkpoint=3,"day3_truth"
    reward.decisions.day3_companion="eris"
    reward.unlocked.remember=nil
    reward=roundtrip(reward)
    local originalDeck=encode(reward.deck)
    check(not reward.unlocked.remember,"Preparar colección antigua sin recompensa normal")
    reward=advance(reward,"day3_return")
    check(reward.unlocked.remember and encode(reward.deck)==originalDeck,"Sello concede carta normal sin editar mazo equipado")
    checkLocked(reward)

    -- Sin energía, una mano de cartas de coste positivo mantiene siempre la
    -- salida gratuita. No se serializa este estado sintético: restore recalcula.
    local exhausted=Cards.new(Data.starterDeck,{kind="magic",character="eris"},function(n) return n end)
    exhausted.energy=0
    for index in ipairs(exhausted.hand) do check(not Cards.canPlay(exhausted,index),"Mano cara deshabilitada sin energía") end
    for _=1,3 do check(Cards.pass(exhausted)~=nil,"Acción gratuita disponible sin energía") end
    check(exhausted.finished and exhausted.energy==0,"Agotar energía no bloquea final del encuentro")

    local conditionSession=legacy("roxy")
    conditionSession.decisions.day3_companion="eris"
    conditionSession.relationships.eris.trust=4
    conditionSession.relationships.eris.chemistry=2
    local context={companion="eris"}
    check(Conditions.evaluate(conditionSession,nil,context),"Sin requisitos permite transición")
    check(Conditions.evaluate(conditionSession,{all={{event="seal_memory"},{decision="day3_companion",equals="eris"}}},context),
        "Combinar requisitos de evento y decisión")
    check(Conditions.evaluate(conditionSession,{any={{event="seal_truth"},{decision="companion",oneOf={"roxy","sylphiette"}}}},context),
        "Alternativas de condición")
    check(Conditions.evaluate(conditionSession,{["not"]={event="seal_truth"}},context),"Negación de evento pendiente")
    check(Conditions.evaluate(conditionSession,{event="seal_truth",equals=false},context),"Condición de evento todavía no completado")
    check(Conditions.evaluate(conditionSession,{relationship="companion",trust=4,chemistry=2},context),"Condición sobre vínculos del acompañante")
    check(not Conditions.evaluate(conditionSession,{relationship="companion",trust=5},context),"Requisito de confianza no cumplido")
    check(not Conditions.evaluate(conditionSession,{route="eris"},context),"Compañía no equivale a ruta")
    conditionSession.route="eris"
    check(Conditions.evaluate(conditionSession,{route="eris"},context),"Condición de ruta explícita")
    check(not Conditions.validate({execute="os.execute('anything')"}),"Rechazar operadores ejecutables")
    local executed=false
    check(not Conditions.validate({predicate=function() executed=true; return true end}),"Rechazar funciones en condiciones")
    check(not executed,"Validación nunca ejecuta código arbitrario")

    -- Preparación de una futura elección de ruta, sin publicar el día cinco.
    -- El mismo evento rechazado antes de tiempo debe poder aplicarse más tarde.
    local futureRoute=Save.newSession()
    local beforeRoute=encode(futureRoute)
    local routeReward={route="roxy",character="roxy",trust=2,unlock={"combined_spell"}}
    check(not Events.apply(futureRoute,"future_route_choice",routeReward),"No fijar ruta antes del día cinco")
    check(encode(futureRoute)==beforeRoute,"Ruta prematura no marca evento, concede puntos ni adelanta cartas")
    futureRoute.day=5
    check(Events.apply(futureRoute,"future_route_choice",routeReward) and futureRoute.route=="roxy"
        and futureRoute.unlocked.combined_spell and futureRoute.relationships.roxy.trust==2,
        "Efecto declarativo prepara elección explícita de ruta futura")
    check(not Events.apply(futureRoute,"future_route_choice",{route="eris",unlock={"sword_magic"}})
        and futureRoute.route=="roxy" and not futureRoute.unlocked.sword_magic,
        "Evento de ruta repetido no sustituye elección confirmada")
    check(not Events.apply(futureRoute,"invalid_route_choice",{route="nanahoshi"}) and not futureRoute.events.invalid_route_choice,
        "Rechazar ruta ajena a personajes románticos")

    -- El intérprete evalúa decisiones previas y utiliza la alternativa declarada
    -- cuando falla un requisito. Restaurar los datos incluso ante un fallo.
    local originalTransitions=Chapters.byId.day3.transitions.day3_intro
    local transitionsOk,transitionsError=xpcall(function()
        Chapters.byId.day3.transitions.day3_intro={
            {to="phase_complete",requires={decision="roxy_equality",equals="personal"}},
            {to="day3_companion"},
        }
        local path=legacy("roxy"); path.day,path.checkpoint=3,"day3_intro"
        check(Progression.next(path)=="day3_companion","Transición usa alternativa cuando no se cumple decisión previa")
        path=legacy("roxy"); path.day,path.checkpoint=3,"day3_intro"
        path.decisions.roxy_equality="personal"
        check(Progression.next(path)=="phase_complete","Transición selecciona rama por decisión previa")
    end,debug.traceback)
    Chapters.byId.day3.transitions.day3_intro=originalTransitions
    assert(transitionsOk,transitionsError)

    local function invalidCase(label,mutate)
        local list=copy(Chapters.list)
        mutate(list)
        local valid,messages=Validator.validate(Chapters.build(list))
        check(not valid and type(messages)=="table" and #messages>0,"Validador detecta "..label)
    end
    invalidCase("checkpoints duplicados",function(list) list[3].scenes.intro=copy(list[1].scenes.intro) end)
    invalidCase("destinos desconocidos",function(list) list[3].transitions.day3_intro[1].to="missing_checkpoint" end)
    invalidCase("personajes desconocidos",function(list) list[3].scenes.day3_intro.lines[1].speaker="missing_character" end)
    invalidCase("fondos desconocidos",function(list) list[3].scenes.day3_intro.background="missing_background" end)
    invalidCase("cartas desconocidas",function(list)
        list[3].transitions.day3_intro[1].effects={{id="invalid_reward",unlock={"missing_card"}}}
    end)
    invalidCase("cartas exclusivas antes del día permitido",function(list)
        list[3].transitions.day3_intro[1].effects={{id="premature_route_reward",unlock={"shared_magic"}}}
    end)
    invalidCase("condiciones inválidas",function(list) list[3].transitions.day3_intro[1].requires={execute="anything"} end)
    invalidCase("requisitos en campos de nodo que el motor no interpreta",function(list)
        list[3].scenes.day3_intro.requires={event="seal_memory"}
    end)
    invalidCase("elección de ruta antes del día cinco",function(list)
        list[3].transitions.day3_intro[1].effects={{id="premature_route",route="roxy"}}
    end)
    invalidCase("escenas sin salida",function(list) list[3].transitions.day3_intro=nil end)
    invalidCase("ciclos que impiden llegar al cierre",function(list) list[3].transitions.day3_return={{to="day3_intro"}} end)
    invalidCase("salidas bloqueadas por eventos imposibles",function(list)
        list[3].transitions.day3_intro[1].requires={event="never_emitted"}
    end)
    invalidCase("salida bloqueada por recompensa que solo se obtiene después",function(list)
        list[3].transitions.day3_intro[1].requires={event="day3_complete"}
    end)
    invalidCase("selector bloqueado por evento de un capítulo posterior",function(list)
        list[2].hubs.hub.companion.requires={event="day3_complete"}
    end)
    check(Validator.validate(Chapters),"Fixtures inválidos no modifican datos canónicos")

    -- Validar autoría puede exigir los archivos físicos; iniciar una partida
    -- permite que Resources diagnostique un PNG ausente y use su reserva.
    local Assets=require("src.data.assets")
    local originalInfo=love.filesystem.getInfo
    local filesOk,filesError=xpcall(function()
        love.filesystem.getInfo=function(path,...)
            if path==Assets.backgrounds.library then return nil end
            return originalInfo(path,...)
        end
        local valid,messages=Validator.validate(Chapters)
        check(not valid and #messages>0,"Validación de autoría detecta fondo físico ausente")
        check(Validator.validate(Chapters,{checkFiles=false}),"Inicio permite reserva visual sin abortar narrativa válida")
        local list=copy(Chapters.list)
        list[3].scenes.day3_intro.background="missing_background"
        check(not Validator.validate(Chapters.build(list),{checkFiles=false}),"Modo de ejecución sigue rechazando IDs de fondo desconocidos")
    end,debug.traceback)
    love.filesystem.getInfo=originalInfo
    assert(filesOk,filesError)

    print("Chapters: "..count.." checks passed (legacy saves, 12 day-three paths, conditions and narrative validation).")
    return count
end

return Suite
