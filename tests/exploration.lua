local Suite={}
function Suite.run()
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local P=require("src.systems.prologue")
    local E=require("src.systems.exploration")
    local Maps=require("src.data.maps")
    local Data=require("src.data.exploration_world")
    local Progression=require("src.systems.progression")
    local count,captures=0,0
    local function check(ok,message) assert(ok,message);count=count+1 end
    local function round(s) return assert(Save.validate(assert(Json.decode(assert(Json.encode(s)))))) end
    local function capture(app,name)
        app.manager:finishTransition();app.toastTime=0;app:draw()
        local pixels=app.canvas:newImageData();local bytes=pixels:encode("png")
        local f=assert(io.open(love.filesystem.getSource().."/tests/artifacts/play-"..name..".png","wb"))
        f:write(bytes:getString());f:close();bytes:release();pixels:release()
        captures=captures+1
    end
    -- Flood the actual foot collision geometry at 4 px, including NPC solids.
    -- Every enabled access and interaction must share the start component.
    local function flood(map,start)
        local queue={{x=start.x,y=start.y}};local seen={[start.x..":"..start.y]=queue[1]};local i=1
        while queue[i] do
            local a=queue[i];i=i+1
            for _,d in ipairs({{4,0},{-4,0},{0,4},{0,-4}}) do
                local x,y=a.x+d[1],a.y+d[2];local key=x..":"..y
                if not seen[key] and E.walkable(map,x,y,nil,start.absentNpcs,start) and E.walkable(map,x-d[1]/2,y-d[2]/2,nil,start.absentNpcs,start) then
                    local node={x=x,y=y,previous=a};seen[key]=node;queue[#queue+1]=node
                end
            end
        end
        return queue
    end
    local floods={}
    for id,map in pairs(Maps) do
        check(E.walkable(map,map.initialPosition.x,map.initialPosition.y),"Inicio libre de NPC: "..id)
        local points=flood(map,map.initialPosition);floods[id]=points
        for _,portal in ipairs(map.portals) do if portal.enabled then
            local hit=false;local r=portal.trigger
            for _,a in ipairs(points) do if a.x>=r.x and a.x<=r.x+r.w and a.y>=r.y and a.y<=r.y+r.h then hit=true;break end end
            check(hit,"Ruta física al portal "..portal.id)
            check(E.walkable(Maps[portal.targetMap],portal.arrival.x,portal.arrival.y),"Llegada sin NPC "..portal.id)
        end end
        local temp=P.start(Save.newSession());temp.exploration.map=id
        for _,objects in ipairs({map.npcs.placements,map.objects,Data.transfers[id] and {Data.transfers[id]} or {}}) do
            for _,object in ipairs(objects) do
                temp.exploration.npcLocations=object.period and {[object.id]={map=id,x=object.x,y=object.y}} or nil
                local found=false
                for _,a in ipairs(points) do
                    temp.exploration.x,temp.exploration.y=a.x,a.y
                    if E.nearby(temp)==object then found=true;break end
                end
                check(found,"Interacción alcanzable: "..id.."/"..object.id)
            end
        end
    end
    local seen={dormitorio_eris=true};local queue={"dormitorio_eris"};local i=1
    while queue[i] do
        local id=queue[i];i=i+1;local dest={}
        for _,portal in ipairs(Maps[id].portals) do if portal.enabled then dest[#dest+1]=portal.targetMap end end
        if Data.transfers[id] then dest[#dest+1]=Data.transfers[id].target end
        for _,target in ipairs(dest) do if not seen[target] then seen[target]=true;queue[#queue+1]=target end end
    end
    check(#queue==14,"Catorce mapas alcanzables contando el traslado")
    local app=require("src.app").new();app.options.textAnimation=false;app.options.reducedMotion=false
    app:newGame();app.manager:finishTransition()
    local session=app.session
    check(session.checkpoint=="intro" and app.manager.current.scene.context=="hitogami_dream","Nueva campaña empieza en sueño")
    local cast=require("src.systems.portraits").resolve(app.manager.current.scene,1).cast
    check(cast[2].portrait=="rudeus_japones","Retrato japonés exclusivo del sueño")
    app.manager.current:update(1) -- Capturar tras la entrada de ambos retratos.
    capture(app,"dream")
    local function finishDialogue()
        local screen=app.manager.current
        check(screen.dialogue~=nil,"Escena narrativa presente")
        local limit=0
        while app.manager.current==screen do
            if session.checkpoint=="day1_silence" and screen.dialogue.index==6 then capture(app,"mana-sealed") end
            screen:advance();screen:update(1);limit=limit+1;assert(limit<120,"Diálogo bloqueado")
        end
        app.manager:finishTransition()
    end
    finishDialogue()
    check(app.manager.current.kind=="exploration" and session.exploration.map=="dormitorio_eris","Despierta en dormitorio de Eris")
    check(session.prologue.dream_completed and not session.inventory.hitogami_letter,"Sueño completo; carta ausente")
    check(session.exploration.x==112 and session.exploration.y==112,"Inicio transitable junto a la cama")
    check(require("src.data.exploration_assets").overworld.rudeus.image:match("Rudeus_walk"),"Sprite rubio normal de 24x32")
    capture(app,"eris-bedroom")
    check(app:save(),"Guardar el despertar real")
    app.toast="";app:continueGame();app.manager:finishTransition();session=app.session
    check(app.toast=="" and app.manager.current.kind=="exploration","Continuar no repite el mensaje del nuevo día")
    check(not Progression.next(session),"No se salta la exploración por Progression.next")
    local originalDaily=Json.encode(session.daily);local originalRelations=Json.encode(session.relationships)
    local world=app.manager.current
    world:greet(Data.npcs.dormitorio_eris[1]);world:advanceGreeting();world:advanceGreeting()
    capture(app,"family-greeting");world:keypressed("escape")
    for _,npcs in pairs(Data.npcs) do for _,npc in ipairs(npcs) do
        world:greet(npc)
        for _=1,6 do if world.greeting then world:advanceGreeting() end end
    end end
    check(Json.encode(session.daily)==originalDaily,"Todos los saludos son gratuitos")
    check(Json.encode(session.relationships)==originalRelations,"Saludos no premian romances")
    local isDown=love.keyboard.isDown
    love.keyboard.isDown=function(key) return key=="s" end
    local startY=session.exploration.y;world:update(.05)
    check(session.exploration.y>startY,"La entrada WASD mueve a Rudy")
    world:keypressed("m");local pausedY=session.exploration.y;world:update(.5)
    check(session.exploration.y==pausedY,"El minimapa pausa el movimiento")
    world:keypressed("escape");love.keyboard.isDown=isDown
    session.exploration.y=startY
    local function locate(id,predicate)
        for _,point in ipairs(floods[id]) do if predicate(point) then return point end end
        error("Destino no encontrado: "..id)
    end
    local function walkTo(predicate)
        local e=session.exploration
        local points=flood(Maps[e.map],e);local target
        for _,point in ipairs(points) do if predicate(point) then target=point;break end end
        assert(target,"No hay camino real desde Rudy")
        local path={};while target.previous do table.insert(path,1,target);target=target.previous end
        for _,point in ipairs(path) do
            local dx,dy=point.x-e.x,point.y-e.y
            check(E.move(e,dx,dy,math.sqrt(dx*dx+dy*dy)/E.speed),"Paso de movimiento válido")
        end
    end
    local function portalTo(target)
        walkTo(function(a)
            local probe={map=session.exploration.map,x=a.x,y=a.y};local portal=E.portal(probe)
            return portal and portal.targetMap==target
        end)
        world=app.manager.current;world:update(0);app.manager:finishTransition()
        check(session.exploration.map==target,"Portal de ida/regreso: "..target)
        world=app.manager.current
    end
    portalTo("casa_segundo_piso");capture(app,"second-floor")
    portalTo("estudio_rudy")
    check(not session.prologue.letter_found and not session.prologue.letter_read,"Entrar al estudio no descubre la carta")
    local before=round(session)
    check(before.exploration.map=="estudio_rudy" and not before.prologue.letter_read,"Guardado antes de encontrar la carta")
    walkTo(function(a)
        local probe={exploration={map="estudio_rudy",x=a.x,y=a.y,resources={}}}
        local obj=E.nearby(probe);return obj and obj.id=="hitogami_letter"
    end)
    capture(app,"study-letter")
    local x,y=session.exploration.x,session.exploration.y
    world:interact();app.manager:finishTransition()
    local letter=app.manager.current
    check(letter.kind=="exploration_letter" and session.prologue.letter_found and not session.prologue.letter_collected,"Examinar inicia el vuelo")
    letter:update(.8)
    check(session.prologue.letter_collected and session.inventory.hitogami_letter and not session.prologue.letter_read,"Recoger no equivale a leer")
    check(session.exploration.objective=="day1_letter","El objetivo recogido recuerda terminar la lectura")
    capture(app,"letter-envelope")
    letter:keypressed("escape");app.manager:finishTransition()
    check(session.exploration.x==x and session.exploration.y==y,"Cerrar restaura exactamente la posición")
    portalTo("casa_segundo_piso");portalTo("estudio_rudy")
    check(not session.prologue.letter_read and not Progression.next(session),"Salir sin leer mantiene la misión pendiente")
    world=app.manager.current;world:keypressed("i");world:keypressed("return");app.manager:finishTransition()
    letter=app.manager.current;letter:interact();letter:update(.4);letter:update(2)
    check(letter.phase=="reading","Se abre el sobre recogido desde inventario")
    letter:interact();letter:update(2)
    check(not session.prologue.letter_read,"Leer solo la primera página no avanza")
    local page=letter.page;letter:close();app.manager:finishTransition();app:save()
    local loaded=assert(Save.load())
    check(loaded.documentState.page==page and loaded.prologue.letter_collected and not loaded.prologue.letter_read,"Disco conserva lectura incompleta")
    app.session=loaded;session=loaded;app.worldScreen=nil;app:resume();app.manager:finishTransition();world=app.manager.current
    world:openLetter();app.manager:finishTransition();letter=app.manager.current
    check(letter.page==page,"Reabrir después de cargar conserva página")
    letter:update(5);capture(app,"letter-reading")
    while letter.phase=="reading" do letter:update(5);letter:interact() end
    check(letter.phase=="signature" and not session.prologue.letter_read,"Firma requiere confirmación explícita")
    check(require("src.data.documents").hitogami_letter.signature=="—H","Firma exacta UTF-8")
    capture(app,"letter-signature");letter:interact();app.manager:finishTransition()
    check(session.prologue.letter_read and session.clues.hitogami_letter and session.checkpoint=="day1_signature","Lectura activa recuerdo")
    finishDialogue();finishDialogue()
    check(session.curse.discoveredVoice and session.curse.discoveredMana and session.prologue.curse_discovered,"Descubre voz y maná tras lectura")
    check(session.exploration.map=="estudio_rudy" and app.manager.current.kind=="exploration","No transporta al laboratorio")
    check(session.exploration.objective=="day1_nanahoshi" and not session.prologue.nanahoshi_visited,"Objetivo Nanahoshi pendiente")
    check(not Progression.next(session),"No puede omitir la visita a Nanahoshi")
    app:save();local after=assert(Save.load())
    check(after.prologue.letter_read and after.prologue.curse_discovered and P.shouldExplore(after),"Disco no repite el descubrimiento")
    local eventCount=#session.journal
    check(not P.readLetter(session) and #session.journal==eventCount,"No duplica lectura ni recompensa")
    world=app.manager.current;world:openLetter();app.manager:finishTransition();letter=app.manager.current
    letter:interact();letter:update(.4)
    while letter.phase=="reading" do letter:update(10);letter:interact() end
    letter:interact();app.manager:finishTransition()
    check(#session.journal==eventCount and session.checkpoint=="day1_warning","Relectura conserva eventos y checkpoint")
    portalTo("casa_segundo_piso");portalTo("casa_planta_baja");capture(app,"house")
    portalTo("jardin_casa");portalTo("patio_eris");portalTo("jardin_casa");portalTo("camino_sharia")
    local function transfer(target)
        walkTo(function(a)
            local item=E.nearby({exploration={map=session.exploration.map,x=a.x,y=a.y,resources={}}})
            return item and item.kind=="travel"
        end)
        world=app.manager.current;world:interact();check(world.modal=="travel","Traslado identificado y confirmado")
        world:keypressed("return");app.manager:finishTransition()
        check(session.exploration.map==target,"Traslado llega a "..target)
    end
    transfer("universidad_exterior");capture(app,"university")
    transfer("camino_sharia");transfer("universidad_exterior")
    portalTo("laboratorio_nanahoshi")
    world=app.manager.current;world:keypressed("m");capture(app,"minimap");world:keypressed("m")
    walkTo(function(a)
        local item=E.nearby({exploration={map=session.exploration.map,x=a.x,y=a.y,resources={}}})
        return item and item.id=="nanahoshi"
    end)
    world:interact();app.manager:finishTransition()
    check(session.prologue.nanahoshi_visited and session.checkpoint=="day1_warning" and app.manager.current.dialogue,"Nanahoshi solo avanza al interactuar")
    finishDialogue();finishDialogue()
    check(session.prologue.starting_cards_received and session.events.starter_gift and #session.deck==5 and #session.combatDeck==5,"Entrega anterior de diez cartas integrada")
    check(not P.visitNanahoshi(session),"Visita no se repite")
    local blocks={{map="dormitorio_eris",x=112,y=80,facing="left",visited={}},
        {map="casa_segundo_piso",x=260,y=144,facing="up",visited={}}}
    E.move(blocks[1],-1,0,1);check(blocks[1].x>=102,"No atraviesa cama con dt grande")
    E.move(blocks[2],0,-1,1);check(blocks[2].y>=118,"Los pies no atraviesan la pared")
    local function movement(dx,dy,steps)
        local e={map="patio_eris",x=240,y=216,facing="down",visited={}}
        for _=1,steps do E.move(e,dx,dy,.5/steps) end
        return math.sqrt((e.x-240)^2+(e.y-216)^2),e
    end
    local straight=movement(1,0,30);local diagonal=movement(1,1,30)
    check(math.abs(straight-diagonal)<.001,"Diagonal normalizada")
    local a=movement(1,1,15);local b=movement(1,1,72)
    check(math.abs(a-b)<.001,"Velocidad independiente de FPS")
    for id,map in pairs(Maps) do
        local camera=E.camera({map=id,x=map.width,y=map.height})
        check(camera.x%1==0 and camera.y%1==0 and camera.x+camera.w<=map.width and camera.y+camera.h<=map.height,"Cámara entera limitada "..id)
    end
    local probe=P.start(Save.newSession());probe.exploration.map="camino_sharia"
    for _,m in ipairs(E.markers(probe)) do check(m.kind~="door" or m.target~="universidad_exterior","Minimapa no anuncia portal cerrado") end
    probe.exploration.x=0/0;probe.exploration.facing="evil";probe.exploration.resources.garden_flower=true
    local clean=assert(Save.validate(probe))
    check(clean.exploration.x==Maps.camino_sharia.initialPosition.x and clean.exploration.facing=="down","Carga repara coordenadas y dirección inválidas")
    check(clean.exploration.resources.garden_flower,"Recursos recogidos persisten")
    local legacy=Save.newSession();legacy.checkpoint="day1_wake"
    local legacyBytes=assert(Json.encode(legacy));assert(love.filesystem.write("campaign-v8.json",legacyBytes))
    check(Save.write(session) and love.filesystem.read("campaign-v8.json")==legacyBytes,"Guardar no sobrescribe la campaña v8")
    love.filesystem.remove("campaign-v8.json")
    check(not round(legacy).prologue,"Campañas anteriores mantienen flujo sin migración forzada")
    print("Exploration: "..count.." checks passed; 14 physical maps, round trips, letter, save/load, greetings and Nanahoshi. "..captures.." gameplay captures.")
    return count
end
return Suite
