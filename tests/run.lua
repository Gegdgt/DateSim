-- Se ejecuta dentro de LÖVE: lovec.exe . --test
-- Las pruebas de disco usan otra identidad; nunca pisan una partida real.
return function()
    love.filesystem.setIdentity("cartas_del_destino_tests")
    require("tests.gameplay").run()
    require("tests.story").run()
    require("tests.resources").run()
    require("tests.ui").run()
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Story=require("src.data.story")
    local Cards=require("src.systems.cards")
    local Controls=require("src.config.controls")
    local Font=require("src.ui.font")
    local Progression=require("src.systems.progression")
    local diskChecks=0
    local function diskCheck(ok,message) assert(ok,message); diskChecks=diskChecks+1 end
    local diskSession=Save.newSession()
    diskSession.day,diskSession.checkpoint=2,"meet_roxy"
    assert(Progression.choose(diskSession,"meet_roxy","compare_notes"))
    assert(Progression.next(diskSession)=="encounter_roxy")
    diskSession.encounter=Cards.new(diskSession.deck,{kind="investigation",character="roxy"})
    Cards.pass(diskSession.encounter)
    diskCheck(Save.write(diskSession),"Escritura real de love.filesystem")
    local diskLoaded=assert(Save.load())
    diskCheck(diskLoaded.encounter.turn==2 and diskLoaded.encounter.energy==4,"Roundtrip real de guardado")
    diskCheck(Json.encode(diskLoaded.decisions)==Json.encode(diskSession.decisions),"Decisiones reales conservadas en disco")
    diskCheck(Json.encode(diskLoaded.encounter)==Json.encode(diskSession.encounter),"Encuentro exacto conservado en disco")
    diskCheck(Save.writeOptions({volume=.3,muted=true}),"Escribir opciones reales")
    diskCheck(Save.readOptions().muted==true and Save.readOptions().volume==.3,"Opciones reales en disco")
    print("Filesystem: "..diskChecks.." checks passed in isolated test identity.")
    local old={write=Save.write,load=Save.load,exists=Save.exists,readOptions=Save.readOptions,writeOptions=Save.writeOptions}
    local stored
    Save.write=function(session) stored=assert(Json.encode(assert(Save.validate(session)))); return true end
    Save.load=function() return stored and Save.validate(assert(Json.decode(stored))) or nil end
    Save.exists=function() return stored~=nil end
    Save.readOptions=function() return {volume=.6,muted=false} end
    Save.writeOptions=function() return true end
    local App=require("src.app")
    local app=App.new()
    local count=0
    local function check(ok,msg) count=count+1; assert(ok,msg) end
    local function render(name)
        app:update(1)
        app:draw()
        if name then
            local data=app.canvas:newImageData():encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/"..name..".png","wb"))
            file:write(data:getString()); file:close()
        end
    end
    local function captureCanvas(target,name)
        local data=target:newImageData():encode("png")
        local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/"..name..".png","wb"))
        file:write(data:getString()); file:close()
    end
    local function clickLabel(label)
        render()
        for _,b in ipairs(app.manager.current.buttons) do
            if b.label==label then
                app:mousepressed(app.offsetX+(b.x+b.w/2)*app.scale,app.offsetY+(b.y+b.h/2)*app.scale,1)
                return
            end
        end
        error("No se encontró el botón "..label)
    end
    render("01-menu")
    clickLabel("Nueva partida")
    check(app.session.checkpoint=="intro","Nueva partida desde menú")
    render("02-dialogue")
    local s=app.manager.current
    s.visible=0; s.elapsed=0
    app:keypressed(Controls.advance[1])
    check(s.dialogue.index==1,"Primera pulsación revela sin saltar")
    app:keypressed(Controls.advance[1])
    check(s.dialogue.index==2,"Segunda pulsación avanza una línea")
    local steps=0
    local captured={}
    while app.session.checkpoint~="phase_complete" do
        steps=steps+1
        assert(steps<250,"Posible bloqueo de progresión")
        render()
        s=app.manager.current
        local cp=app.session.checkpoint
        if Story.scenes[cp] then
            s.elapsed=100; s.visible=10000
            if s.dialogue:isLast() and s.scene.choices then
                render()
                clickLabel(s.scene.choices[1].label)
            else s:advance() end
        elseif Story.encounters[cp] then
            if not captured[cp] then
                render(cp=="day1_tutorial" and "03-cards" or nil)
                captured[cp]=true
            end
            if not s.enc.finished then
                local idx
                for i in ipairs(s.enc.hand) do if Cards.canPlay(s.enc,i) then idx=i; break end end
                -- Incluir la acción gratuita en pausa/carga sobre pantallas reales.
                if cp=="day1_tutorial" and s.enc.turn==1 then s:act() else s:act(idx) end
                local before=assert(Json.encode(s.enc))
                app:overlay("journal"); render()
                app:resume(); render()
                check(Json.encode(app.session.encounter)==before,"Pausa conserva mano, energía y descarte exactos")
                -- La carga normaliza el contexto según la definición narrativa.
                app:continueGame(); render()
                check(Json.encode(app.session.encounter)==before,"Continuar conserva encuentro exacto")
            else s:finish() end
        elseif cp=="hub" then
            if not captured.hub then render("04-hub"); captured.hub=true end
            local all=true
            for _,place in ipairs(Story.locations) do
                if not app.session.events["meeting_"..place.character] then all=false; break end
            end
            clickLabel(all and "Elegir compañía" or "Visitar")
        else error("Pantalla sin manejador: "..cp) end
    end
    check(app.session.events.seal_memory,"Recorrido completo recupera sello")
    check(app.session.route==nil,"No hay romance automático")
    render("05-complete")
    app:overlay("journal"); render("06-journal")
    app:overlay("deck"); render("07-deck")
    app:overlay("options"); render("08-options")
    app:overlay("pause"); render()
    local dimensions=love.graphics.getDimensions
    love.graphics.getDimensions=function() return 1600,900 end
    app:resize()
    check(app.scale==2 and app.offsetX==160 and app.offsetY==90,"Escala entera centrada sin deformar")
    check(app:logical(159,90)==nil and app:logical(1440,90)==nil,"Bandas rechazan clics")
    local lx,ly=app:logical(360,290)
    check(lx==100 and ly==100,"Ratón usa la transformación inversa")
    love.graphics.getDimensions=dimensions
    app:resize()
    -- Comprobar también la ventana real, además de la transformación aislada.
    local originalWidth,originalHeight,originalFlags=love.window.getMode()
    for _,size in ipairs({{640,360},{960,540},{1280,720}}) do
        check(love.window.setMode(size[1],size[2],{resizable=true,minwidth=640,minheight=360}),"Cambiar resolución real")
        app:resize()
        local w,h=love.graphics.getDimensions()
        check(app.scale==math.max(1,math.floor(math.min(w/640,h/360))),"Escala entera en ventana real")
        local x,y=app:logical(app.offsetX+320*app.scale,app.offsetY+180*app.scale)
        check(x==320 and y==180,"Mouse centrado en ventana real")
        render()
    end
    app:keypressed("f11")
    check(love.window.getFullscreen(),"F11 activa pantalla completa real")
    check(app.scale>=1 and app.scale%1==0,"Pantalla completa conserva escala entera")
    render()
    app:keypressed("f11")
    check(not love.window.getFullscreen(),"F11 vuelve a ventana")
    check(love.window.setMode(originalWidth,originalHeight,originalFlags),"Restaurar ventana tras pruebas")
    app:resize()
    for id,scene in pairs(Story.scenes) do
        local resolved=require("src.systems.progression").scene(app.session,id)
        for _,line in ipairs(resolved.lines) do
            check(Font.height(line.text,572,1)<=66,"Diálogo cabe en caja: "..id)
        end
        if scene.choices then
            for _,choice in ipairs(scene.choices) do check(Font.height(choice.label,419,1)<=22,"Elección cabe: "..id) end
        end
    end
    -- Galerías de QA: todas las expresiones y cartas, incluidos capítulos futuros.
    love.graphics.push("all")
    local gallery=love.graphics.newCanvas(640,360)
    love.graphics.setCanvas(gallery); love.graphics.origin(); love.graphics.clear(.1,.15,.23,1)
    local Characters=require("src.data.characters")
    for i,character in ipairs(Characters.list) do
        local x=14+(i-1)*89
        Font.draw(character.shortName,x,10,{maxWidth=84,align="center"})
        for j,expression in ipairs({"neutral","happy","worried","angry"}) do
            app.resources:portrait(character.id,expression,x+10,32+(j-1)*80,1)
            Font.draw(expression,x,96+(j-1)*80,{maxWidth=84,align="center"})
        end
    end
    love.graphics.setCanvas(); captureCanvas(gallery,"09-characters")
    gallery=love.graphics.newCanvas(716,290)
    love.graphics.setCanvas(gallery); love.graphics.origin(); love.graphics.clear(.1,.15,.23,1)
    for i,card in ipairs(require("src.data.cards").list) do
        require("src.ui.card").draw(app.resources,card,10+((i-1)%8)*88,12+math.floor((i-1)/8)*140)
    end
    love.graphics.setCanvas(); captureCanvas(gallery,"10-all-cards")
    love.graphics.pop()
    for key,value in pairs(old) do Save[key]=value end
    print("Integration: "..count.." checks passed; "..steps.." screen steps.")
end
