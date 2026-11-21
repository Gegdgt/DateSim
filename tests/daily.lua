local Suite={}
function Suite.run()
    local Save=require("src.systems.save")
    local Daily=require("src.systems.daily")
    local Progression=require("src.systems.progression")
    local Chapters=require("src.data.chapters")
    local Events=require("src.systems.events")
    local Json=require("src.systems.json")
    local count=0
    local function check(ok,message) assert(ok,message); count=count+1 end
    local function copy(s) return assert(Json.decode(assert(Json.encode(s)))) end
    local function reload(s) return assert(Save.validate(copy(s))) end
    local function agenda(day)
        local s=Save.newSession()
        Events.apply(s,"starter_gift",{starter=true})
        s.rewardQueue={}
        s.day=day or 1; s.checkpoint="day"..s.day.."_agenda"; Daily.ensure(s)
        return s
    end
    local function complete(s)
        Events.apply(s,Daily.config(s).completionEvent,{})
    end
    local wives={"sylphiette","roxy","eris"}
    for a=1,3 do for b=1,3 do for c=1,3 do
        local s=agenda();local visits={sylphiette=0,roxy=0,eris=0}
        check(Daily.remaining(s)==3,"Exactamente tres espacios al comenzar")
        for _,index in ipairs({a,b,c}) do
            local id=wives[index]
            check(Daily.startActivity(s,"time_"..id),"Cualquier distribución es válida")
            check(not Daily.startActivity(s,"time_roxy"),"Una actividad pendiente no reserva otra")
            s=reload(s)
            check(s.daily.active_activity and Daily.resolveActivity(s,"together"),"Reserva y decisión persisten")
            local before=Json.encode(s.relationships)
            check(not Daily.resolveActivity(s,"together") and Json.encode(s.relationships)==before,"Resolver dos veces no repite consecuencias")
            visits[id]=visits[id]+1
        end
        check(Daily.remaining(s)==0 and not Daily.startActivity(s,"time_eris"),"Cuarta actividad bloqueada")
        for id,n in pairs(visits) do check(s.daily.visits[id]==n,"Visitas exactas: "..id) end
        check(Daily.requestFavor(s,"cliff_notes"),"El encargo no depende de las interacciones restantes")
        check(not Daily.requestFavor(s,"zanoba_artifact"),"Solo un encargo combinado para Cliff/Zanoba")
        check(s.daily.interactions_used==3,"Encargo no consume interacción")
        check(not Progression.endDay(s),"Dormir no omite eventos obligatorios")
        complete(s)
        check(Progression.endDay(s)=="day1_summary","Resumen antes de avanzar")
        s=reload(s)
        local exact=Json.encode(s)
        check(Daily.finish(s) and Json.encode(s)==exact,"Cierre idempotente después de cargar")
        check(Progression.next(s)=="day2_agenda","Siguiente capítulo comienza en agenda")
        check(s.day==2 and s.daily.day==2 and Daily.remaining(s)==3,"Renueva exactamente tres espacios")
        check(s.daily_history["1"].visits[wives[a]]>=1,"Historial de ayer disponible")
        check(s.pending_favors[1].status=="delivered","Encargo se entrega al comenzar el día siguiente")
        complete(s);check(Progression.endDay(s),"Dormir voluntariamente con cero actividades")
        check(s.daily_history["2"].unused==3,"Espacios sin usar registrados")
        check(s.pending_favors[1].status=="delivered" and s.unlocked.heal,"Encargo entregado al cierre debido")
        check(s.missions.day1_favor_cliff_notes,"Entrega actualiza misión")
        s=reload(s); local energy=s.externalEnergy;local rewards=#s.rewardQueue
        Daily.finish(s)
        check(s.externalEnergy==energy and #s.rewardQueue==rewards,"Premios sin duplicar al reabrir resumen")
    end end end
    for used=0,2 do
        local s=agenda()
        for _=1,used do Daily.startActivity(s,"time_roxy"); Daily.resolveActivity(s,"listen") end
        complete(s);check(Progression.endDay(s),"Cierre voluntario con "..used.." actividades")
        check(s.daily_history["1"].unused==3-used,"Registra espacios perdidos")
        Progression.next(s);check(Daily.remaining(s)==3,"No acumula sobrantes")
    end
    local s=agenda()
    check(Daily.requestFavor(s,"zanoba_artifact") and Daily.remaining(s)==3,"Encargo antes de actividades tampoco consume")
    Daily.startActivity(s,"time_roxy");complete(s)
    check(not Progression.endDay(s),"No cierra una decisión incompleta")
    s=reload(s);Daily.resolveActivity(s,"listen")
    check(Save.write(s),"Guardado real con actividad y encargo")
    s=assert(Save.load());check(s.daily.visits.roxy==1 and s.daily.favor_used,"Carga de disco conserva jornada")
    Progression.endDay(s)
    check(not s.unlocked.wind_guard and s.pending_favors[1].status=="pending","Zanoba entrega mañana salvo ayuda explícita")
    check(s.events_by_day["1"].day1_activity_1,"Eventos indexados por día e identificador")
    check(Save.write(s),"Cierre guardado en disco")
    local loaded=assert(Save.load())
    check(loaded.daily.ending_processed and loaded.daily_history["1"].after.roxy.trust==s.relationships.roxy.trust,"Resumen y matrimonios persisten")
    local broken=copy(loaded);broken.daily.interactions_used=4
    check(not Save.validate(broken),"Rechaza cuarta reserva guardada")
    broken=copy(loaded);broken.daily.visits.roxy=3
    check(not Save.validate(broken),"Rechaza visitas inconsistentes")
    broken=copy(loaded);broken.pending_favors[2]=copy(broken.pending_favors[1])
    check(not Save.validate(broken),"Rechaza doble encargo para el mismo día")
    broken=copy(loaded);broken.daily=nil
    check(not Save.validate(broken),"No regala una agenda vacía al perder el estado diario")
    broken=copy(loaded);broken.daily.day=2
    check(not Save.validate(broken),"No repone espacios por día inconsistente")
    local future=copy(loaded);future.version=999
    local futureRaw=assert(Json.encode(future))
    love.filesystem.write(Save.filename,futureRaw)
    check(not Save.write(loaded) and love.filesystem.read(Save.filename)==futureRaw,"Conserva un destino de versión incompatible")
    love.filesystem.remove(Save.filename)
    local legacy=copy(loaded);legacy.version=3
    local raw=assert(Json.encode(legacy))
    love.filesystem.write("campaign-v3.json",raw)
    check(not Save.validate(legacy),"V3 no se interpreta como una jornada v4")
    check(Save.legacyInfo().source=="campaign-v3.json","Detecta campaña anterior")
    check(Save.migrateLegacy(true),"Importa colección a nueva jornada")
    check(Save.write(loaded) and love.filesystem.read("campaign-v3.json")==raw,"Nunca sobrescribe v3")
    love.filesystem.remove("campaign-v3.json")
    local final=agenda(7);final.inventory.antidote=true
    Daily.requestFavor(final,"cliff_notes",nil,true)
    check(final.pending_favors[1].due_day==7,"Encargo final se resuelve antes del epílogo")
    check(Progression.continueStory(final)=="day7_muster","Preparación final sigue accesible con cero actividades")
    check(final.daily.activities_locked and not Daily.startActivity(final,"time_roxy"),"Día siete fija atención antes de resolver matrimonios")
    local trust=final.relationships.roxy.trust
    Daily.applyAttention(final);check(final.relationships.roxy.trust==trust,"Atención final se aplica una sola vez")
    for day=1,7 do
        local c=Chapters.byId["day"..day]
        check(Chapters.get(c.daily.agenda) and Chapters.get(c.daily.summary),"Agenda y resumen en día "..day)
    end
    for _,node in pairs(Chapters.checkpoints) do check(node.definition.interactionRule=="narrative" and node.definition.interactionCost==0,"Escena con coste narrativo explícito") end
    require("src.systems.narrative_validator").assertValid(nil,{checkFiles=false})
    print("Daily cycle: "..count.." checks passed (27 distributions, reservations, favors, summaries, replay, disk persistence and v3 preservation).")
end
return Suite
