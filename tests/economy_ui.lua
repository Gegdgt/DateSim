local Suite={}
function Suite.run()
    local Save=require("src.systems.save")
    local Events=require("src.systems.events")
    local Collection=require("src.systems.card_collection")
    local Json=require("src.systems.json")
    local Font=require("src.ui.font")
    local saved={write=Save.write,load=Save.load,exists=Save.exists,readOptions=Save.readOptions,legacyInfo=Save.legacyInfo}
    local stored
    Save.write=function(s) stored=assert(Json.encode(assert(Save.validate(s))));return true end
    Save.load=function() return stored and Save.validate(assert(Json.decode(stored))) end
    Save.exists=function() return stored~=nil end
    Save.legacyInfo=function() return nil end
    Save.readOptions=function() return {muted=true,textAnimation=false,reducedMotion=false} end
    local count=0
    local function check(ok,msg) assert(ok,msg);count=count+1 end
    local ok,err=xpcall(function()
        local app=require("src.app").new()
        app.session=Save.newSession({love=65,trust=65});Events.apply(app.session,"starter_gift",{starter=true})
        Events.apply(app.session,"upgrade_fixture",{copies={listen=20,water_cannon=91},gold=10000})
        app.session.rewardQueue={};app.session.checkpoint="day1_agenda"
        local sounds={};local audio=app.audio.effect
        app.audio.effect=function(self,id) sounds[id]=(sounds[id] or 0)+1;return audio(self,id) end
        local function draw() app.toastTime=0;app:draw() end
        local function settle() app:update(2);draw() end
        local function capture(name)
            draw();local pixels=app.canvas:newImageData();local bytes=pixels:encode("png")
            local f=assert(io.open(love.filesystem.getSource().."/tests/artifacts/economy-"..name..".png","wb"));f:write(bytes:getString());f:close();pixels:release();bytes:release()
        end
        local function click(label)
            draw()
            for _,b in ipairs(app.manager.current.buttons) do
                if b.label==label then check(not b.disabled,"Botón activo: "..label);b.action();return end
            end
            error("Botón ausente: "..label)
        end
        app:switch(require("src.screens.upgrades").new(app,"listen"));settle();capture("before")
        local screen=app.manager.current;local gold=app.session.gold;local copies=app.session.collection.listen.copies
        click("Mejorar");screen:improve();screen:update(.25);draw();capture("flash")
        check(app.session.gold==gold and app.session.collection.listen.level==1,"Elevación previa al gasto")
        screen:update(.25);draw();capture("after")
        check(app.session.collection.listen.level==2 and app.session.collection.listen.copies==copies-2 and app.session.gold==gold-5,"Un único gasto al confirmar animación")
        screen:update(3);screen:improve();screen:update(1)
        check(app.session.collection.listen.level==2 and sounds.upgrade==1,"Pulsaciones rápidas no repiten mejora ni sonido")
        local loaded=assert(Save.load());check(loaded.collection.listen.level==2 and loaded.gold==gold-5,"Carga conserva mejora aplicada")
        click("Continuar");click("Mejorar");screen:update(1)
        check(app.session.collection.listen.level==3 and Collection.view(app.session,"listen").effect.trust==2,"Interfaz aplica incremento real del siguiente escalón")
        click("Continuar");click("Tienda");settle();capture("shop")
        click("Comprar 5")
        check(app.session.rewardQueue[1].counts.listen==5,"Tienda genera recompensa de cinco duplicados")
        app:resume();settle();capture("duplicate")
        check(app.manager.current.kind=="reward" and not app.manager.current:isNew(),"Repetida tiene presentación independiente")
        local originalFont=Font.draw;local rendered={}
        Font.draw=function(text,...) rendered[#rendered+1]=tostring(text);return originalFont(text,...) end
        draw();Font.draw=originalFont
        check(table.concat(rendered," "):find("¡CARTA REPETIDA!",1,true),"Aviso visible de repetida")
        while app.manager.current.kind=="reward" do app.manager.current:continue();settle() end
        for _=1,9 do check(Collection.upgrade(app.session,"water_cannon",app.session.economy.revision),"Mejora definitiva financiada por fixture") end
        app:switch(require("src.screens.upgrades").new(app,"water_cannon"));settle();capture("maximum")
        for _,b in ipairs(app.manager.current.buttons) do if b.label=="Nivel máximo" then check(b.disabled,"Nivel máximo deshabilitado") end end
        app.session.gold=0
        app:switch(require("src.screens.upgrades").new(app,"light_joke"));settle();capture("missing")
        for _,b in ipairs(app.manager.current.buttons) do if b.label=="Mejorar" then check(b.disabled,"Requisitos insuficientes deshabilitan mejora") end end
        app.audio:stop()
    end,debug.traceback)
    for key,value in pairs(saved) do Save[key]=value end
    assert(ok,err)
    print("Economy UI: "..count.." checks passed; seven real-renderer captures, animation, duplicates and double-spend prevention.")
end
return Suite
