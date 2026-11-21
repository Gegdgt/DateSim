local Suite={}
function Suite.run()
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Events=require("src.systems.events")
    local Daily=require("src.systems.daily")
    local original={write=Save.write,load=Save.load,exists=Save.exists,readOptions=Save.readOptions,legacyInfo=Save.legacyInfo}
    local stored,failWrite
    Save.write=function(s)
        if failWrite then return false,"fallo simulado" end
        stored=assert(Json.encode(assert(Save.validate(s)))); return true
    end
    Save.load=function() return stored and Save.validate(assert(Json.decode(stored))) end
    Save.exists=function() return stored~=nil end
    Save.legacyInfo=function() return nil end
    Save.readOptions=function() return {muted=true,textAnimation=false,reducedMotion=true} end
    local count=0
    local function check(ok,message) assert(ok,message); count=count+1 end
    local ok,err=xpcall(function()
        local app=require("src.app").new()
        app.session=Save.newSession()
        Events.apply(app.session,"starter_gift",{starter=true})
        app.session.rewardQueue={};app.session.checkpoint="day1_agenda"
        local function settle() app:update(2);app:draw() end
        local function click(label,which)
            settle();local n=0
            for _,button in ipairs(app.manager.current.buttons) do
                if button.label==label then
                    n=n+1
                    if n==(which or 1) then
                        check(not button.disabled,"Botón habilitado: "..label)
                        app:mousepressed(app.offsetX+(button.x+button.w/2)*app.scale,app.offsetY+(button.y+button.h/2)*app.scale,1)
                        return
                    end
                end
            end
            error("Botón ausente: "..label)
        end
        local function capture(name)
            settle();app.toastTime=0;app:draw()
            local bytes=app.canvas:newImageData():encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/"..name..".png","wb"))
            file:write(bytes:getString());file:close()
        end
        app:resume();capture("daily-agenda-start")
        for i=1,3 do
            click("Pasar tiempo",2)
            check(app.session.daily.interactions_used==i,"Un clic reserva exactamente un espacio")
            app:continueGame();settle()
            check(app.session.daily.active_activity~=nil,"Continúa la decisión pendiente")
            capture("daily-activity")
            click("Compartir una lectura (+2 amor / +1 conf.)")
            settle()
            while app.manager.current.kind=="reward" do app.manager.current:continue();settle() end
        end
        check(app.session.daily.visits.roxy==3 and Daily.remaining(app.session)==0,"Tres visitas a Roxy desde la interfaz")
        capture("daily-agenda-spent")
        for _,button in ipairs(app.manager.current.buttons) do
            if button.label=="Pasar tiempo" then check(button.disabled,"Cuarta visita deshabilitada") end
        end
        click("Encargos");capture("daily-favors")
        click("Solicitar",2)
        check(app.session.daily.favor_used and app.session.daily.interactions_used==3,"Encargo desde interfaz independiente")
        Events.apply(app.session,"day1_complete",{})
        app:resume();settle()
        failWrite=true
        click("Finalizar día")
        check(app.manager.current.kind=="agenda" and app.session.daily.ending_processed,"No muestra resumen si falla el guardado")
        local relationships=Json.encode(app.session.relationships);local energy=app.session.externalEnergy
        failWrite=false;check(app:endDay(),"Reintentar guardado de cierre")
        check(Json.encode(app.session.relationships)==relationships and app.session.externalEnergy==energy,"Reintento no repite efectos")
        settle()
        while app.manager.current.kind=="reward" do app.manager.current:continue();settle() end
        check(app.manager.current.kind=="day_report","Muestra resumen persistido")
        capture("daily-summary")
        click("Comenzar día 2")
        check(app.session.day==2 and Daily.remaining(app.session)==3,"Resumen abre siguiente agenda")
        click("Cambios de ayer");capture("daily-previous")
        check(app.manager.current.kind=="day_report","Consulta de ayer accesible")
        click("Volver a la agenda")
        check(app.session.day==2 and Daily.remaining(app.session)==3,"Consultar no avanza ni consume")
        Events.apply(app.session,"day2_complete",{})
        app:resume();settle();click("Finalizar día")
        check(app.session.daily_history["2"].unused==3,"Dormir con tres espacios desde interfaz")
        -- La navegación estándar debe poder activar botones de la agenda.
        app.session=Save.newSession();app.session.checkpoint="day1_agenda";app:resume();settle()
        app:keypressed("tab");check(app.manager.current.keyboardFocus~=nil,"Navegación por teclado")
        app.session.day=7;app.session.checkpoint="day7_agenda";Daily.ensure(app.session)
        app:resume();capture("daily-final-day")
        app.audio:stop()
    end,debug.traceback)
    for key,value in pairs(original) do Save[key]=value end
    assert(ok,err)
    print("Daily UI: "..count.." checks passed; seven real-renderer captures, pending choice reload and failed-save retry.")
end
return Suite
