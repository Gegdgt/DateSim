local Suite={}
function Suite.run()
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Prologue=require("src.systems.prologue")
    local W=require("src.systems.world_content")
    local Data=require("src.data.world_content")
    local World=require("src.data.exploration_world")
    local Maps=require("src.data.maps")
    local E=require("src.systems.exploration")
    local Daily=require("src.systems.daily")
    local Events=require("src.systems.events")
    local Economy=require("src.systems.economy")
    local Favors=require("src.data.activities").favorsById
    local count,captures=0,0
    local function check(ok,msg)assert(ok,msg);count=count+1 end
    local function encode(v)return assert(Json.encode(v))end
    local function round(s)return assert(Save.validate(assert(Json.decode(encode(s)))))end
    local function fresh(ready,seed)
        local s=Prologue.start(Save.newSession());Prologue.wake(s);W.ensure(s);s.worldContent.seed=seed or 2718
        if ready then
            Events.apply(s,"starter_gift",{starter=true});s.rewardQueue={};Events.mark(s,"first_anomaly");Events.mark(s,"tutorial_completed");Events.mark(s,"combat_tutorial_completed");Events.mark(s,"nanahoshi_conversation_started")
            s.prologue.starting_cards_received=true;s.prologue.letter_read=true;s.prologue.letter_collected=true
            s.prologue.curse_discovered=true;s.prologue.nanahoshi_visited=true
            Events.apply(s,"hitogami_letter_read",{clue="hitogami_letter"})
            s.checkpoint="day1_agenda"
        end
        return s
    end
    local function nextDay(s)
        s.day=s.day+1;s.checkpoint="day"..s.day.."_agenda";Daily.ensure(s);Daily.deliverFavors(s)
    end
    local s=fresh(false)
    local before=encode({s.events,s.daily,s.relationships,s.curse,s.unlocked,s.checkpoint})
    local sprites=require("src.data.exploration_assets")
    for _,id in ipairs({"lilia","aisha","norn","zenith","lucy","eris","roxy","sylphiette","cliff","zanoba","nanahoshi"}) do
        local responses={};local previous
        for _=1,16 do
            local line=W.greeting(s,id)
            check(line.text~=previous,"No repite inmediatamente: "..id);responses[line.text]=true;previous=line.text
        end
        local n=0;for _ in pairs(responses) do n=n+1 end
        check(n>=8,"Ocho respuestas originales: "..id)
        local saved=round(s);local nextA=W.greeting(s,id).text;local nextB=W.greeting(saved,id).text
        check(nextA==nextB,"Memoria de frases conservada: "..id)
    end
    check(before==encode({s.events,s.daily,s.relationships,s.curse,s.unlocked,s.checkpoint}),"Saludos no tocan historia, presupuesto, relaciones, maldición ni cartas")
    for _,id in ipairs({"lilia","aisha","norn","zenith_lucy","lucy"}) do
        local a=sprites.npcIdle[id];check(a and a.frames==2,"Animación definitiva de dos cuadros: "..id)
        local pixels=love.image.newImageData(a.image);local differs=false
        for y=0,a.frameHeight-1 do for x=0,a.frameWidth-1 do
            local r,g,b,alpha=pixels:getPixel(x,y);local rr,gg,bb,aa=pixels:getPixel(x+a.frameWidth,y)
            if r~=rr or g~=gg or b~=bb or alpha~=aa then differs=true end
        end end
        pixels:release();check(differs,"Los cuadros contienen cambios reales: "..id)
    end
    local physical=0;local shared=0
    for _,npc in ipairs(Maps.casa_planta_baja.npcs.placements) do
        if npc.sprite=="lucy" then physical=physical+1 end
        if npc.sprite=="zenith_lucy" then shared=shared+1 end
    end
    check(physical==0 and shared==1,"Lucy aparece una sola vez en brazos de Zenith")
    check(not W.generate(s) and next(s.worldContent.days)==nil,"No genera botín durante el prólogo")
    s.checkpoint="day1_agenda"
    check(not Daily.requestFavor(s,"social_research","cliff"),"No investigación prematura")
    check(not Daily.startActivity(s,"roxy_books") and not Economy.buyBook(s,"water_notes",s.economy.revision),"No comercio principal antes de Nanahoshi")
    check(not Economy.buy(s,"magic_material",s.economy.revision),"Compra de materiales bloqueada antes de introducción")
    local unique=0
    for mapId,map in pairs(Maps) do for _,o in ipairs(map.objects) do
        if o.id=="hitogami_letter" then unique=unique+1;check(mapId=="estudio_rudy","Carta únicamente en estudio") end
    end end
    check(unique==1 and Data.items.hitogami_letter.reserved,"Carta narrativa única y reservada")
    for _,id in ipairs(Data.lootTypes) do check(id~="hitogami_letter" and id~="antidote","Ningún objeto narrativo como botín") end
    check(not Economy.quote(fresh(true),"hitogami_letter"),"Carta narrativa no comerciable")
    for _,site in ipairs(Data.sites) do
        check(W.siteValid(site),"Punto de hallazgo válido: "..site.id)
        local p=fresh(true);E.enter(p.exploration,site.map,Maps[site.map].initialPosition)
        require("tests.exploration_driver").walk(p,function(a)return (a.x-site.x)^2+(a.y-site.y)^2<16 end)
        check(true,"Ruta física completa hasta "..site.id)
    end
    for mapId,objects in pairs(Data.objects) do for _,object in ipairs(objects) do
        local p=fresh(true);p.inventory.antidote=true;E.enter(p.exploration,mapId,Maps[mapId].initialPosition)
        require("tests.exploration_driver").walk(p,function(a)
            return E.nearby({exploration={map=mapId,x=a.x,y=a.y,resources={}},inventory={antidote=true}})==object
        end)
        check(true,"Objeto alcanzable: "..object.id)
    end end
    local kinds={};local counts={}
    for seed=1,48 do
        local a=fresh(true,seed);local b=fresh(true,seed)
        for day=1,7 do
            W.generate(a);W.generate(b)
            local finds=a.worldContent.days[tostring(day)]
            check(#finds>=1 and #finds<=3,"Entre uno y tres hallazgos por día");counts[#finds]=true
            check(encode(finds)==encode(b.worldContent.days[tostring(day)]),"Semilla reproducible")
            local generated=encode(finds);local loaded=round(a);W.generate(loaded)
            check(encode(loaded.worldContent.days[tostring(day)])==generated,"Carga no regenera botín")
            for _,object in ipairs(finds) do
                kinds[object.item]=true;local g=a.gold
                check(W.examine(a,object),"Recogida normal")
                local snapshot=encode({a.gold,a.collection,a.economy.items,a.events})
                W.examine(a,object);check(snapshot==encode({a.gold,a.collection,a.economy.items,a.events}),"No duplica recompensa")
                for _,o in ipairs(W.objects(a,object.map)) do check(o.id~=object.id,"No reaparece al reentrar") end
                check(a.gold>=g and object.map~="cementerio_ranoa","No oro en tumbas ni costes de recogida")
            end
            local r=round(a)
            for id in pairs(require("src.data.economy").items) do check((a.economy.items[id] or 0)==(r.economy.items[id] or 0),"Inventario cuantitativo persistente: "..id) end
            if day<7 then nextDay(a);nextDay(b) end
        end
    end
    for _,id in ipairs(Data.lootTypes) do check(kinds[id],"Cobertura de botín: "..id) end
    check(counts[1] and counts[2] and counts[3],"Variación de cantidad diaria")
    local chest=Data.objects.taller_cliff_zanoba[1]
    s=fresh(false);local g=s.gold;W.examine(s,chest)
    check(not s.worldContent.collected[chest.id] and s.gold==g,"Cofre reservado antes de introducción")
    s=fresh(true);W.examine(s,chest);local items=encode(s.economy.items)
    nextDay(s);W.examine(s,chest);check(items==encode(s.economy.items),"Cofre único no reaparece otro día")
    local successSeed,failureSeed
    for seed=1,100 do
        local p=fresh(true,seed);local q=require("src.systems.commissions").prepare(p,Favors.social_research,"day1_favor_social_research")
        if q.success then successSeed=successSeed or seed else failureSeed=failureSeed or seed end
    end
    check(successSeed and failureSeed,"Hay éxitos y fracasos con probabilidades reales")
    for _,seed in ipairs({successSeed,failureSeed}) do
        s=fresh(true,seed);local initialGold=s.gold
        require("tests.social_driver").approach(s,"cliff");local favor=assert(Daily.requestFavor(s,"social_research","cliff"))
        check(s.gold==initialGold-15 and favor.cost==15 and favor.chance==70,"Coste descontado una vez y probabilidad configurable")
        check(Daily.remaining(s)==3 and not Daily.requestFavor(s,"physical_cards","zanoba"),"Cupo único entre ambos encargados")
        local requested=encode(favor);check(Save.write(s),"Guardar encargo iniciado en disco")
        s=assert(Save.load());check(encode(s.pending_favors[1])==requested,"Disco conserva resultado y recompensa antes de entregar")
        local pending=s.pending_favors[1];local roll=pending.roll
        nextDay(s)
        check(pending.status=="delivered" and pending.roll==roll and pending.due_day==2,"Entrega al iniciar mañana sin nuevo sorteo")
        if seed==failureSeed then check(s.gold==initialGold-15 and not pending.success,"Fracaso pierde inversión") end
        local saved=encode({s.gold,s.economy,s.collection,s.events})
        Daily.deliverFavors(s);check(saved==encode({s.gold,s.economy,s.collection,s.events}),"Entrega idempotente")
        check(not Daily.requestFavor(s,"social_research","cliff"),"No repetir tarea ayer")
        round(s)
    end
    s=fresh(true,99);require("tests.social_driver").approach(s,"cliff");assert(Daily.requestFavor(s,"gather_materials","cliff"));nextDay(s)
    check(not Daily.requestFavor(s,"gather_materials","zanoba"),"Restricción por ID aunque cambie encargado")
    s=fresh(true);s.gold=14;local original=encode(s)
    check(not Daily.requestFavor(s,"social_research","cliff") and encode(s)==original,"Oro insuficiente sin mutación parcial")
    s=fresh(true);require("tests.social_driver").approach(s,"cliff");local favor=assert(Daily.requestFavor(s,"enchantment_research","cliff"));local invested=s.gold;local roll=favor.roll
    check(Daily.accelerateFavor(s,favor.instance_id) and Daily.remaining(s)==2,"Ayudar gasta exactamente una interacción")
    check(favor.roll==roll and favor.due_day==1 and favor.status=="delivered","Ayuda adelanta sin cambiar resultado")
    check(s.gold==invested+(favor.success and (favor.reward.gold or 0) or favor.refund),"Ayuda no cobra de nuevo")
    check(not Daily.accelerateFavor(s,favor.instance_id),"No acelerar dos veces");round(s)
    s=fresh(true);require("tests.social_driver").approach(s,"roxy");for _=1,3 do assert(Daily.startActivity(s,"time_roxy"));assert(Daily.resolveActivity(s,"together")) end
    require("tests.social_driver").approach(s,"cliff");favor=assert(Daily.requestFavor(s,"social_research","cliff"))
    check(not Daily.accelerateFavor(s,favor.instance_id) and favor.status=="pending","Sin espacios no acelera")
    s=fresh(true);s.day=7;s.checkpoint="day7_agenda";Daily.ensure(s)
    check(not Daily.requestFavor(s,"social_research","cliff"),"No encargos que excedan la campaña")
    require("tests.social_driver").approach(s,"cliff")
    check(Daily.requestFavor(s,"social_research","cliff",true) and s.pending_favors[1].due_day==7,"Día siete permite resolución inmediata confirmada");round(s)
    local def=Favors.social_research;local chance=def.chance
    def.chance=0;s=fresh(true);require("tests.social_driver").approach(s,"cliff");favor=assert(Daily.requestFavor(s,def.id,"cliff"));check(not favor.success and favor.chance==0,"Probabilidad proviene del catálogo")
    def.chance=100;local loaded=round(s);check(not loaded.pending_favors[1].success and loaded.pending_favors[1].chance==0,"Cambio de configuración no altera un contrato iniciado")
    def.chance=chance
    s=fresh(true);local budget=Daily.remaining(s);g=s.gold
    for _,o in ipairs(Data.objects.cementerio_ranoa) do check(W.examine(s,o),"Reflexión opcional: "..o.id) end
    check(Daily.remaining(s)==budget and s.gold==g,"Cementerio no gasta interacciones ni da oro")
    s=round(s);check(s.worldContent.specialVisits.paul_grave and s.worldContent.specialVisits.oldeus_rest,"Lugares especiales persistentes")
    s=fresh(true);require("tests.social_driver").approach(s,"roxy");assert(Daily.startActivity(s,"roxy_books"));g=s.gold
    check(Economy.buyBook(s,"water_notes",s.economy.revision) and s.gold==g-35,"Roxy compra real con coste")
    Daily.completeBookVisit(s);check(Daily.remaining(s)==2 and s.family.books.water_notes,"Libro y una sola visita registrados")
    check(not Economy.buyBook(s,"water_notes",s.economy.revision),"Libro único no se compra dos veces");round(s)
    s=fresh(true);require("tests.social_driver").approach(s,"roxy");assert(Daily.startActivity(s,"roxy_supplies"));g=s.gold
    check(Economy.buy(s,"magic_material",s.economy.revision) and s.gold==g-20,"Compra real de materiales")
    Daily.completeTradeVisit(s);check(Daily.remaining(s)==2 and s.economy.items.magic_material==1,"Materiales conservan presupuesto e inventario");round(s)
    -- Capturas del renderer real, con la misma interacción y ventanas de juego.
    local app=require("src.app").new();app.options.textAnimation=false;app.options.reducedMotion=false
    local function show(session,map,x,y)
        app.session=session;E.enter(session.exploration,map,{x=x,y=y,facing="up"});app:explore();app.manager:finishTransition()
        return app.manager.current
    end
    local function capture(name)
        app.manager:finishTransition();app.toastTime=0;app:draw()
        local pixels=app.canvas:newImageData();local bytes=pixels:encode("png")
        local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/world2-"..name..".png","wb"))
        file:write(bytes:getString());file:close();pixels:release();bytes:release();captures=captures+1
    end
    s=fresh(false);local screen=show(s,"casa_planta_baja",432,156);screen:update(.1);capture("lilia-cleaning-1")
    screen:update(.5);capture("lilia-cleaning-2")
    screen=show(s,"casa_planta_baja",520,224);screen:interact()
    check(screen.greeting and screen.greeting.npc=="aisha","Aisha responde mediante E")
    screen:advanceGreeting();screen:advanceGreeting();capture("aisha")
    screen=show(s,"casa_planta_baja",56,284);screen:interact();check(screen.modal=="family_choice","Zenith y Lucy comparten presencia")
    screen:keypressed("2");screen:advanceGreeting();screen:advanceGreeting();capture("zenith-lucy")
    check(screen.greeting.npc=="lucy","Lucy tiene interacción propia sin otro sprite")
    s=fresh(true);W.generate(s);local found=s.worldContent.days["1"][1]
    screen=show(s,found.map,found.x-24,found.y);capture("hidden-find");screen:interact();capture("pickup")
    check(s.worldContent.collected[found.id],"Recogida desde la pantalla real")
    screen=show(s,"cementerio_ranoa",256,176);screen:interact();capture("cemetery-paul")
    screen=show(s,"cementerio_ranoa",304,232);screen:interact();capture("cemetery-oldeus")
    for _,pair in ipairs({{successSeed,"success"},{failureSeed,"failure"}}) do
        s=fresh(true,pair[1]);screen=show(s,"taller_cliff_zanoba",224,204)
        screen:interact();while screen.greeting do screen:advanceGreeting() end
        screen:keypressed("1");app.manager:finishTransition();local task=app.manager.current
        check(task.kind=="commissions","Saludo abre solicitud de ayuda")
        local gold=s.gold;task:keypressed("return");check(s.gold==gold,"Revisar contrato no descuenta oro")
        capture("commission-preview-"..pair[2]);task:keypressed("return")
        task:keypressed("h");local remain=Daily.remaining(s);task:keypressed("escape")
        check(Daily.remaining(s)==remain,"Cancelar ayuda no gasta interacción")
        task:keypressed("h");capture("commission-help-"..pair[2]);task:keypressed("return");capture("commission-"..pair[2])
        check(s.pending_favors[1].success==(pair[2]=="success"),"Resultado real de pantalla "..pair[2])
    end
    print("World content phase 2: "..count.." checks passed; 48 seeds x 7 days, NPC memory, inventory, commissions, cemetery and commerce; "..captures.." captures.")
    return count
end
return Suite
