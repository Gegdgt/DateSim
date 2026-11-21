local Suite={}
function Suite.run()
    local R=require("src.systems.relationships")
    local Events=require("src.systems.events")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Cards=require("src.systems.cards")
    local Combat=require("src.systems.combat")
    local names={"sylphiette","roxy","eris"}
    local checked=0
    local function check(ok,message) assert(ok,message); checked=checked+1 end
    local function round(s) return assert(Save.validate(assert(Json.decode(assert(Json.encode(s)))))) end
    local function fulfilled(s,id)
        check(Events.apply(s,"mission_"..id,{character=id,love=12,trust=12,relationshipEvent="personal_resolution",
            sharedMoment="investigation",critical={id="commitment",value=true},promise={id="return",status="pending"}}),"Misión personal "..id)
        check(Events.apply(s,"promise_"..id,{character=id,love=3,trust=3,promise={id="return",status="kept"}}),"Promesa cumplida "..id)
    end
    local s=Save.newSession()
    check(s.version==5 and s.continuity=="rudy_curse","Versión y continuidad explícitas")
    check(#s.deck==0 and #s.combatDeck==0 and next(s.unlocked)==nil,"Sin cartas antes de Nanahoshi")
    for _,id in ipairs(names) do
        check(s.relationships[id].love==65 and s.relationships[id].trust==65,"Matrimonio comienza positivamente")
        check(s.relationships[id].marriageState=="married","Estado matrimonial inicial")
    end
    check(not R.canUnite(s.relationships),"No se conserva automáticamente la familia sin eventos personales")
    local custom=R.new({love=77,trust=81})
    check(custom.roxy.love==77 and custom.roxy.trust==81,"Valores iniciales configurables")
    R.apply(custom,"roxy",{love=1000,trust=-200})
    check(custom.roxy.love==100 and custom.roxy.trust==0,"Amor y confianza limitados a 0..100")
    local preview=R.preview(custom,"roxy",{love=10,trust=-10})
    check(preview.love==0 and preview.trust==0 and custom.roxy.love==100,"Vista previa respeta límites sin mutar")
    R.apply(custom,"roxy",{love=0/0,trust=math.huge})
    check(custom.roxy.love==100 and custom.roxy.trust==0,"Deltas no finitos ignorados")
    check(Events.apply(s,"starter_test",{starter=true,presenter="nanahoshi"}),"Entrega del mazo inicial")
    check(Cards.validateDeck(s.deck,s.unlocked),"Cinco cartas sociales iniciales desbloqueadas")
    check(Combat.validateDeck(s.combatDeck,s.unlocked),"Diez técnicas iniciales de combate viables")
    check(#s.rewardQueue==1 and #s.rewardQueue[1].cards==10,"Animación recibe todas las nuevas cartas")
    local before=assert(Json.encode(s))
    check(not Events.apply(s,"starter_test",{starter=true}) and Json.encode(s)==before,"Entrega idempotente")
    check(Events.apply(s,"shared_duty",{batch={{character="sylphiette",love=2,trust=3},
        {character="roxy",love=4,trust=2},{character="eris",love=3,trust=4}},familyEvent="shared_duty"}),"Efectos familiares en lote")
    check(s.relationships.sylphiette.love==67 and s.relationships.roxy.trust==67 and s.relationships.eris.love==68,"Cada esposa recibe su cambio contextual")
    before=Json.encode(s)
    for _=1,20 do check(not Events.apply(s,"shared_duty",{character="eris",love=10,trust=10}),"Repetición no acumula amor") end
    check(Json.encode(s)==before,"Ni historial ni estadísticas se duplican")
    local ok=Events.apply(s,"invalid_batch",{batch={{character="roxy",love=5},{unlock={"nonexistent_card"}}}})
    check(not ok and Json.encode(s)==before,"Lote inválido no aplica un efecto parcial")
    s=round(s)
    check(s.relationships.roxy.love==69 and s.familyEvents.shared_duty,"Persistencia del estado familiar")
    check(#s.journal==5 and #s.rewardQueue==1 and #s.relationships.roxy.history==1,"Historial familiar detallado y animación pendiente sobreviven carga")
    check(s.journal[4].character=="roxy" and s.journal[4].love==4 and s.journal[4].trust==2,"Diario registra los efectos de cada esposa en lotes")
    local limited=Save.newSession({love=99,trust=1})
    Events.apply(limited,"secret",{text="Una preocupación reservada",hidden=true,batch={{character="roxy",love=5,trust=-5,decision="private_choice",value="listen"}}})
    check(limited.journal[2].love==1 and limited.journal[2].trust==-1 and limited.journal[2].decision=="private_choice","Diario registra el cambio efectivo, no un delta fuera de límites")
    check(limited.journal[2].hidden and limited.journal[2].text=="Una preocupación reservada","Secreto oculta señal inmediata pero permanece consultable en diario")
    check(not Events.apply(s,"shared_duty",{character="roxy",love=5}),"Carga conserva clave idempotente")
    table.remove(s.rewardQueue,1); s=round(s)
    check(#s.rewardQueue==0 and s.rewards.starter_test,"Cerrar animación no borra recompensa ni reaparece al cargar")
    local promise=Save.newSession()
    fulfilled(promise,"eris")
    Events.apply(promise,"late",{character="eris",love=-12,trust=-12,promise={id="return",status="broken"},critical={id="tactics",value="reckless"}})
    check(not R.canMaintain(promise.relationships,"eris"),"Promesa rota afecta viabilidad aunque los números basten")
    check(promise.relationships.eris.marriageState~="separated","Una equivocación no separa irreversiblemente")
    Events.apply(promise,"apology",{character="eris",love=8,trust=8,reconcile="return",promise={id="return",status="kept"}})
    check(R.canMaintain(promise.relationships,"eris"),"Reconciliación sustantiva permite reparar")
    promise=round(promise)
    check(promise.relationships.eris.brokenPromises["return"]==true and promise.relationships.eris.reconciliations["return"]==true,"El aprendizaje conserva el error y la reparación")
    check(promise.relationships.eris.promises["return"]=="kept" and promise.relationships.eris.criticalDecisions.tactics=="reckless","Promesas y decisiones críticas persisten")
    local family=Save.newSession()
    for _,id in ipairs(names) do fulfilled(family,id) end
    check(R.ending(family.relationships)=="family_united","Final familia requiere los tres eventos y esfuerzos")
    check(R.ending(round(family).relationships)=="family_united","Final familia estable tras cargar")
    for _,survivor in ipairs(names) do
        local single=Save.newSession()
        for _,id in ipairs(names) do
            if id==survivor then fulfilled(single,id)
            else
                Events.apply(single,"neglect1_"..id,{character=id,love=-15,trust=-15,conflict="abandonment"})
                Events.apply(single,"neglect2_"..id,{character=id,love=-15,trust=-15,critical={id="commitment",value=false}})
                Events.apply(single,"farewell_"..id,{character=id,marriageState="separated"})
            end
        end
        check(R.ending(single.relationships)==survivor,"Final individual alcanzable: "..survivor)
        check(R.ending(round(single).relationships)==survivor,"Final individual persiste: "..survivor)
    end
    local solitary=Save.newSession()
    for _,id in ipairs(names) do
        Events.apply(solitary,"neglect_"..id,{character=id,love=-35,trust=-35,conflict="neglect",critical={id="commitment",value=false}})
        Events.apply(solitary,"separation_"..id,{character=id,marriageState="separated"})
    end
    check(R.ending(solitary.relationships)=="solitary","Camino solitario por errores acumulados")
    local pair=Save.newSession()
    fulfilled(pair,"roxy"); fulfilled(pair,"eris")
    Events.apply(pair,"sylphie_distance",{character="sylphiette",love=-30,trust=-30,conflict="absence"})
    local ending,reason,viable=R.ending(pair.relationships)
    check(ending==nil and reason=="resolution_required" and #viable==2,"Dos matrimonios viables requieren escena de resolución")
    Events.apply(pair,"explicit_parting",{character="eris",marriageState="separated",decision="residence",value="roxy"})
    check(R.ending(pair.relationships)=="roxy","Acuerdo explícito resuelve la pareja sin elegir un máximo")
    local low=Save.newSession()
    for _,id in ipairs(names) do Events.apply(low,"personal_"..id,{character=id,relationshipEvent="personal_resolution"}) end
    check(R.ending(low.relationships)~="family_united","Eventos sin compromiso explícito no otorgan automáticamente unión")
    local malformed=Save.newSession()
    malformed.relationships.roxy.love=1000; malformed.relationships.eris.trust=-1
    malformed.relationships.sylphiette.love=0/0
    local sanitized=assert(Save.validate(malformed))
    check(sanitized.relationships.roxy.love==100 and sanitized.relationships.eris.trust==0 and sanitized.relationships.sylphiette.love==65,"Carga sanea estadísticas")
    check(Save.validate({version=1,checkpoint="intro"})==nil,"No convierte vínculos v1 en matrimonios silenciosamente")
    check(Save.validate({version=999})==nil,"Versión futura rechazada")
    local damaged=Save.newSession()
    damaged.checkpoint="day1_tutorial"; damaged.events.starter_gift=true
    damaged=assert(Save.validate(damaged))
    check(#damaged.deck==5 and #damaged.combatDeck==5 and #damaged.rewardQueue==0,"Recupera mazos de una entrega ganada sin duplicar premio")
    local missingGift=Save.newSession()
    missingGift.checkpoint="day1_tutorial"; missingGift.decisions.important="remember"
    missingGift=assert(Save.validate(missingGift))
    check(missingGift.checkpoint~="day1_tutorial" and missingGift.decisions.important=="remember" and next(missingGift.unlocked)==nil,"Corrupción sin entrega vuelve al tutorial conservando decisiones y sin inventar cartas")
    local oldLove=love
    local files={}
    local legacy=assert(Json.encode({version=1,day=3,checkpoint="day3_complete",unlocked={listen=true,remember=true,nonexistent=true},options={volume=.35}}))
    files[Save.legacyFilename]=legacy
    love={filesystem={getInfo=function(path) return files[path] and {size=#files[path]} end,
        read=function(path) return files[path] end,write=function(path,data) files[path]=data; return true end,
        remove=function(path) files[path]=nil; return true end}}
    local tested,err=pcall(function()
        check(Save.legacyInfo().day==3 and not Save.exists(),"Menú distingue guardado legado de campaña nueva")
        check(Save.migrateLegacy(false)==nil,"Cambio de continuidad exige aceptación explícita")
        local imported=assert(Save.migrateLegacy(true))
        check(imported.day==1 and imported.relationships.roxy.love==65 and imported.migration.acceptedContinuity,"Importación comienza nueva historia conocida")
        check(imported.unlocked.remember and not imported.unlocked.nonexistent and imported.options.volume==.35,"Importa colección compatible y configuración")
        check(Save.write(imported),"Escribir migración en archivo separado")
        check(files[Save.legacyFilename]==legacy and files[Save.filename]~=nil,"No sobrescribe el guardado original")
        local loaded=assert(Save.load())
        check(loaded.migration.previousDay==3 and loaded.unlocked.remember,"Metadatos y cartas importados sobreviven")
        check(Save.write(family),"Crear segundo guardado con copia de respaldo")
        files[Save.filename]="{broken"
        local restored,message=Save.load()
        check(restored and restored.migration and message~=nil,"Guardado corrupto recupera respaldo")
        files[Save.backup]=nil
        check(Save.load()==nil,"Corrupción sin respaldo no inventa progreso")
        love.filesystem.write=function() return false,"sin espacio" end
        check(not Save.write(family),"Fallo de escritura se informa")
    end)
    love=oldLove
    assert(tested,err)
    print("Marriages/save v5: "..checked.." checks passed (five endings, decisions, promises, rewards and explicit migration).")
    return checked
end
return Suite
