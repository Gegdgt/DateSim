-- Run with the project's LÖVE test switch, or: lua -e "require('tests.gameplay').run()"
local Suite={}
function Suite.run()
    local Cards=require("src.systems.cards")
    local Data=require("src.data.cards")
    local Relationships=require("src.systems.relationships")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local checked=0
    local function check(condition,message)
        assert(condition,message); checked=checked+1
    end
    check(#Data.list==16,"16 cartas definidas")
    check(Cards.validateDeck(Data.starterDeck),"Mazo inicial válido")
    check(not Cards.validateDeck({"listen"}),"Rechazar longitud incorrecta")
    local duplicate={}; for i,id in ipairs(Data.starterDeck) do duplicate[i]=id end
    duplicate[10]=duplicate[1]
    check(not Cards.validateDeck(duplicate),"Rechazar cartas repetidas")

    local calls={}
    local enc=Cards.new(Data.starterDeck,{kind="magic",character="nanahoshi"},function(n) calls[#calls+1]=n; return n end)
    check(#calls==9 and calls[1]==10 and calls[9]==2,"Fisher-Yates usa rangos descendentes")
    check(#enc.hand==3 and #enc.drawPile==7 and #enc.discard==0,"Repartir 3 de 10")
    check(enc.hand[1]=="earth_barrier","RNG determinista conserva orden")
    local first=Cards.play(enc,1)
    check(first.score==4 and first.trust==0,"Efecto mágico sin relación no romántica")
    check(enc.energy==2 and #enc.hand==3 and #enc.drawPile==6 and #enc.discard==1,"Pagar, descartar y robar")
    check(enc.turn==2 and not enc.finished,"Un turno por acción")
    local restored=Cards.restore(enc,Data.starterDeck,{kind="magic",character="nanahoshi"})
    check(restored and restored.energy==2 and restored.hand[1]==enc.hand[1] and restored.turn==2,"Restaurar turno y mano")
    check(not Cards.play(enc,0) and not Cards.play(enc,99) and not Cards.play(enc,1.1),"Rechazar índices inválidos")
    check(enc.turn==2 and enc.energy==2,"Acción inválida no modifica estado")
    Cards.pass(enc); Cards.pass(enc)
    check(enc.finished and enc.turn==4 and #enc.log==3,"Tres turnos exactos")
    check(not Cards.pass(enc) and not Cards.play(enc,1),"No actuar tras el final")

    local empty=Cards.new(Data.starterDeck,{kind="conversation",character="eris"},function(n) return n end)
    empty.energy=0
    local before=table.concat(empty.hand,",")
    check(not Cards.play(empty,1),"Una carta de coste 2 no se juega sin energía")
    check(empty.turn==1 and table.concat(empty.hand,",")==before,"No gastar turno al rechazar")
    Cards.pass(empty); Cards.pass(empty); Cards.pass(empty)
    check(empty.finished,"Acción gratuita evita bloqueo con mano cara")
    local free={hand={"light_joke"},context={kind="conversation",character="eris"},energy=0,finished=false,
        drawPile={},discard={},score=0,turn=1,maxTurns=3,log={}}
    check(Cards.play(free,1)~=nil and free.energy==0 and #free.hand==0,"Coste cero y pila vacía son seguros")
    local conditional={hand={"shared_magic"},context={kind="magic",character="eris"},energy=4,finished=false}
    check(not Cards.canPlay(conditional,1),"Carta exclusiva exige acompañante correcto")
    conditional.context.character="sylphiette"
    check(Cards.canPlay(conditional,1),"Carta exclusiva disponible con su acompañante")
    local a=Cards.preview({hand={"listen"},context={kind="conversation",character="sylphiette"}},1)
    local b=Cards.preview({hand={"listen"},context={kind="conversation",character="eris"}},1)
    check(a.chemistry>b.chemistry,"Preferencias modifican los efectos")
    local fresh=Cards.new(Data.starterDeck,{kind="magic"},function(n) return n end)
    check(fresh.energy==4 and fresh.turn==1 and #fresh.discard==0,"Cada encuentro reinicia mazo y energía")

    -- Every real card must apply exactly once, and inspecting its effect must
    -- leave the encounter untouched. Exercise all three narrative contexts.
    for _,card in ipairs(Data.list) do
        check(card.cost>=0 and card.cost<=2 and card.cost%1==0,"Coste permitido: "..card.id)
        for _,kind in ipairs({"conversation","investigation","magic"}) do
            local deck={}
            local position
            for i,id in ipairs(Data.starterDeck) do deck[i]=id; if id==card.id then position=i end end
            if position then deck[position],deck[10]=deck[10],deck[position] else deck[10]=card.id end
            local context={kind=kind,character=card.exclusive or "roxy"}
            local action=Cards.new(deck,context,function(n) return n end)
            local beforePreview=assert(Json.encode(action))
            local preview=Cards.preview(action,1)
            check(Json.encode(action)==beforePreview,"Vista previa no aplica efectos: "..card.id.."/"..kind)
            check(Cards.canPlay(action,1),"Carta jugable con su acompañante: "..card.id)
            local result=assert(Cards.play(action,1))
            check(action.score==preview.score and result.trust==preview.trust and result.chemistry==preview.chemistry,
                "Efectos aplicados una vez: "..card.id.."/"..kind)
            check(action.energy==4-card.cost and action.turn==2 and #action.log==1 and action.discard[1]==card.id,
                "Una sola acción y un solo pago: "..card.id)
            local snapshot=assert(Json.encode(action))
            for _=1,3 do action=assert(Cards.restore(action,deck,context)) end
            check(Json.encode(action)==snapshot,"Restaurar no duplica efectos: "..card.id.."/"..kind)
        end
    end

    local resting=Cards.new(Data.starterDeck,{kind="magic"},function(n) return n end)
    for turn=1,3 do
        local hand,pile=table.concat(resting.hand,","),table.concat(resting.drawPile,",")
        Cards.pass(resting)
        local snapshot=assert(Json.encode(resting))
        resting=assert(Cards.restore(resting,Data.starterDeck,{kind="magic"}))
        check(Json.encode(resting)==snapshot,"Acción gratuita conserva incluso su registro al continuar")
        check(resting.energy==4 and resting.turn==turn+1 and #resting.log==turn and #resting.discard==0,
            "Acción gratuita gasta solo un turno")
        check(table.concat(resting.hand,",")==hand and table.concat(resting.drawPile,",")==pile,
            "Acción gratuita no roba ni descarta")
    end
    check(resting.finished and not Cards.pass(resting),"Continuar encuentro gratuito terminado no concede otro turno")

    local all=Relationships.new()
    Relationships.apply(all,"sylphiette",{trust=30,chemistry=-2})
    check(all.sylphiette.trust==10 and all.sylphiette.chemistry==0,"Límites de relación")
    Relationships.apply(all,"sylphiette",{chemistry=10})
    check(Relationships.ending(all,"sylphiette",{confession="sylphiette"})=="friendship_sylphiette","Puntos no bastan para romance")
    Relationships.complete(all,"sylphiette","route_conflict")
    Relationships.complete(all,"sylphiette","mirror_truth")
    check(Relationships.ending(all,"sylphiette",{})=="friendship_sylphiette","Confesión debe ser explícita")
    check(Relationships.ending(all,"sylphiette",{confession="sylphiette"})=="romance_sylphiette","Romance con todos los requisitos")
    check(Relationships.ending(all,nil,{})=="independent","Final independiente")
    for _,id in ipairs({"roxy","eris"}) do
        all[id].trust=6; all[id].chemistry=5; all[id].events.route_conflict=true; all[id].events.mirror_truth=true
        check(Relationships.ending(all,id,{confession=id})=="romance_"..id,"Romance "..id)
        check(Relationships.ending(all,id,{})=="friendship_"..id,"Amistad "..id)
    end

    local input={version=1,checkpoint="encounter_roxy",deck={"bad"},day=99,
        relationships={roxy={trust=99,chemistry=-50}},options={volume=20,muted=true},
        events={reunion=true},decisions={companion="roxy",outcome_day1_tutorial="partial"}}
    local valid=Save.validate(input)
    check(valid.day==2 and valid.relationships.roxy.trust==10 and valid.relationships.roxy.chemistry==0,"Normalizar guardado parcial")
    check(#valid.deck==10 and valid.options.volume==1 and valid.options.muted,"Reparar mazo y opciones")
    check(valid.events.reunion and valid.decisions.companion=="roxy","Preservar decisiones y eventos")
    check(not Save.validate({version=99}) and not Save.validate({}),"Rechazar versión desconocida y vacío")
    local chosen=Save.validate({version=1,checkpoint="meet_roxy",decisions={choice_meet_roxy="compare_notes"}})
    check(chosen.checkpoint=="meet_roxy" and chosen.decisions.choice_meet_roxy=="compare_notes","Conservar elección y punto de diálogo")
    local invalidChoice=Save.validate({version=1,checkpoint="meet_roxy",decisions={choice_meet_roxy=true,companion=true}})
    check(invalidChoice.checkpoint=="meet_roxy" and invalidChoice.decisions.choice_meet_roxy==nil and invalidChoice.decisions.companion==nil,"Eliminar tipos inválidos en elecciones")
    local missingCompanion=Save.validate({version=1,checkpoint="seal_result",events={companion_selected=true}})
    check(missingCompanion.checkpoint=="hub" and not missingCompanion.events.companion_selected,"Acompañante ausente se vuelve a elegir")
    local encoded=assert(Json.encode({message="¡Sí, mañana!\n\"Roxy\"",integer=7,flag=false,array={1,2,3}}))
    local decoded=assert(Json.decode(encoded))
    check(decoded.message=="¡Sí, mañana!\n\"Roxy\"" and decoded.array[3]==3 and decoded.flag==false,"JSON conserva español y escapes")
    check(Json.decode('"\\u00f1\\ud83c\\udf1f"')=="ñ🌟","Decodificar Unicode")
    for _,bad in ipairs({'{','{"a":1,}','{"a":1,"a":2}','[1,]','01','1.','1.e3','1e999','"\\uD800"','os.execute("bad")'}) do
        check(Json.decode(bad)==nil,"Rechazar JSON mal formado: "..bad)
    end
    local s=Save.newSession()
    s.checkpoint="day1_tutorial"; s.encounter=Cards.new(s.deck,{kind="magic",character="nanahoshi"},function(n) return n end)
    Cards.play(s.encounter,1)
    local round=Save.validate(assert(Json.decode(assert(Json.encode(s)))))
    check(round.encounter.energy==2 and round.encounter.turn==2 and round.encounter.discard[1]=="earth_barrier","Guardar estado exacto del encuentro")
    local roxySave=Save.newSession()
    roxySave.checkpoint="encounter_roxy"
    roxySave.encounter=Cards.new(roxySave.deck,{kind="investigation",character="roxy"},function(n) return n end)
    Cards.play(roxySave.encounter,2)
    local roxyRestored=Save.validate(roxySave)
    check(roxyRestored.encounter.context.kind=="investigation" and roxyRestored.encounter.score==3,"Restaurar contexto canónico de Roxy")
    local sealSave=Save.newSession()
    sealSave.checkpoint="seal_encounter"; sealSave.decisions.companion="eris"
    sealSave.encounter=Cards.new(sealSave.deck,{kind="magic",character="eris"},function(n) return n end)
    Cards.play(sealSave.encounter,1)
    local sealRestored=Save.validate(sealSave)
    check(sealRestored.encounter.context.kind=="magic" and sealRestored.encounter.score==4,"Restaurar contexto canónico del sello")
    s.encounter.hand[1]=s.encounter.hand[2]
    check(Save.validate(s).encounter==nil,"Rechazar snapshot con cartas duplicadas")

    -- In-memory filesystem: the test never changes a player's actual save.
    local previousLove=love
    local files={}
    love={filesystem={
        getInfo=function(path) if files[path] then return {size=#files[path]} end end,
        read=function(path) return files[path] end,
        write=function(path,data) files[path]=data; return true end,
        remove=function(path) files[path]=nil; return true end,
    }}
    local ok,errorMessage=pcall(function()
        local session=Save.newSession()
        check(Save.write(session),"Guardar nueva partida")
        check(Save.exists() and Save.load().checkpoint=="intro","Continuar partida")
        session.checkpoint="hub"; session.decisions.companion="eris"
        check(Save.write(session),"Guardar segundo checkpoint")
        check(Save.load().checkpoint=="hub","Cargar checkpoint nuevo")
        files[Save.filename]="truncated{"
        local backup,message=Save.load()
        check(backup and backup.checkpoint=="intro" and message~=nil,"Recuperar backup si archivo está truncado")
        local active=Save.newSession()
        active.checkpoint="encounter_roxy"
        active.decisions.choice_meet_roxy="compare_notes"
        active.decisions.roxy_equality="colleagues"
        active.events.choice_meet_roxy=true
        active.relationships.roxy.trust=1
        active.encounter=Cards.new(active.deck,{kind="investigation",character="roxy"},function(n) return n end)
        Cards.pass(active.encounter)
        Cards.play(active.encounter,2)
        local expectedEncounter=assert(Json.encode(active.encounter))
        check(Save.write(active),"Guardar decisión y encuentro con acción gratuita")
        for _=1,3 do
            active=assert(Save.load())
            check(Json.encode(active.encounter)==expectedEncounter,"Carga mantiene mano, pilas, energía, turnos y registro")
            check(active.events.choice_meet_roxy and active.decisions.choice_meet_roxy=="compare_notes"
                and active.decisions.roxy_equality=="colleagues" and active.relationships.roxy.trust==1,
                "Carga conserva decisiones sin anticipar ni duplicar efectos del encuentro")
            check(Save.write(active),"Volver a guardar encuentro restaurado")
        end
        check(Save.writeOptions({volume=0.2,muted=true}),"Guardar opciones")
        local prefs=Save.readOptions()
        check(prefs.volume==0.2 and prefs.muted,"Cargar opciones")
        files[Save.filename]="truncated{"
        files[Save.backup]=nil
        check(Save.load()==nil and not Save.exists(),"Guardado corrupto no provoca cierre")
        love.filesystem.write=function() return false,"sin espacio" end
        check(not Save.write(session),"Propagar error de escritura")
    end)
    love=previousLove
    assert(ok,errorMessage)
    print("OK: "..checked.." comprobaciones de cartas, relaciones, JSON y guardado.")
    return checked
end
return Suite
