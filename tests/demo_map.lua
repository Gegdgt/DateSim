local Save=require("src.systems.save")
local Exploration=require("src.systems.exploration")
local Maps=require("src.data.maps")
local World=require("src.data.exploration_world")
local Driver=require("tests.exploration_driver")

local Suite={}

function Suite.run()
    local previousWrite,previousHeld=Save.write,love.keyboard.isDown
    local previousIdentity=love.filesystem.getIdentity()
    local held={}
    Save.write=function() error("Una demostración temporal intentó guardar la campaña.") end
    love.keyboard.isDown=function(key) return held[key] or false end
    local checks,captures=0,0
    local function check(value,message)
        assert(value,message)
        checks=checks+1
    end
    local ok,err=xpcall(function()
        local app=assert(love.load({"--demo-map"}))
        app.options.muted=true
        app.options.reducedMotion=false
        app.options.textAnimation=false
        app:applyAudio()
        local function screen() return app.manager.current end
        local function settle()
            for _=1,10 do
                if app.manager.transition==0 then love.draw();return end
                love.update(.1)
            end
            error("No terminó la transición.")
        end
        local function capture(name)
            love.draw()
            local pixels=app.canvas:newImageData()
            local encoded=pixels:encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/demo-map-"..name..".png","wb"))
            assert(file:write(encoded:getString()));file:close()
            encoded:release();pixels:release();captures=captures+1
        end
        local function choose(label)
            for _,button in ipairs(screen().buttons) do
                if button.label==label then
                    assert(not button.disabled,label)
                    love.mousepressed(app.offsetX+(button.x+button.w/2)*app.scale,
                        app.offsetY+(button.y+button.h/2)*app.scale,1)
                    settle()
                    return
                end
            end
            error("Control ausente: "..label)
        end

        settle()
        check(screen().kind=="demo_map" and love.filesystem.getIdentity()=="cartas_del_destino_demo_mapa","Arranque e identidad de mapas.")
        capture("menu")
        choose("Empezar desde el dormitorio de Eris")
        local session=app.session
        local player=session.exploration
        check(screen().kind=="exploration" and player.map==World.start.map
            and player.x==World.start.x and player.y==World.start.y,"Posición real del dormitorio.")
        capture("dormitorio")

        local function portal(target)
            Driver.walk(session,function(point)
                local portal=Exploration.portal({map=player.map,x=point.x,y=point.y})
                return portal and portal.targetMap==target
            end)
            love.update(0)
            check(player.map==target and app.manager.transition>0,"Portal con fundido hacia "..target)
            settle()
            local camera=screen().camera
            check(player.visited[target] and camera.x>=0 and camera.y>=0
                and camera.x+camera.w<=Maps[target].width and camera.y+camera.h<=Maps[target].height,"Registro de visita y cámara en "..target)
        end
        local function interact(id)
            Driver.walk(session,function(point)
                local item=Exploration.nearby({exploration={map=player.map,x=point.x,y=point.y,resources=player.resources,
                    npcLocations=player.npcLocations,absentNpcs=player.absentNpcs}})
                return item and item.id==id
            end)
            love.keypressed("e")
        end

        portal("casa_segundo_piso")
        portal("estudio_rudy")
        local study=screen()
        interact("hitogami_letter")
        local x,y=player.x,player.y
        check(screen().kind=="exploration_letter","La carta abre su escena.")
        settle()
        for _=1,8 do love.update(.1) end
        capture("estudio")
        love.keypressed("escape");settle()
        check(screen()==study and player.map=="estudio_rudy" and player.x==x and player.y==y,"Cerrar la carta devuelve al mismo lugar.")
        portal("casa_segundo_piso")
        portal("casa_planta_baja")
        portal("jardin_casa")
        portal("patio_eris")
        Driver.walk(session,function(point) return point.x==240 and point.y==216 end)
        held={d=true};love.update(.1)
        check(math.abs(player.x-248)<.00001 and screen().walking,"WASD mueve a Rudy a 80 px/s.")
        held={right=true,rshift=true};love.update(.1)
        check(math.abs(player.x-263)<.00001 and screen().running,"Flecha y Shift mueven a Rudy a 150 px/s.")
        held={}
        interact("eris")
        check(screen().greeting and screen().greeting.npc=="eris","Eris está en el patio y responde al saludo.")
        capture("patio")
        love.keypressed("escape")
        portal("jardin_casa")
        portal("camino_sharia")
        check(not Exploration.portal({map="camino_sharia",x=760,y=160}),"El portal físico deshabilitado no activa el viaje.")
        interact("transfer_university")
        check(screen().modal=="travel" and player.map=="camino_sharia","E abre la confirmación del traslado T.")
        capture("traslado")
        love.keypressed("return");settle()
        check(player.map=="universidad_exterior" and player.visited.universidad_exterior,"Enter viaja a la universidad.")
        interact("transfer_sharia")
        love.keypressed("return");settle()
        check(player.map=="camino_sharia","El traslado permite regresar.")
        interact("transfer_university")
        love.keypressed("return");settle()
        portal("biblioteca_ranoa")
        interact("roxy")
        check(screen().greeting and screen().greeting.npc=="roxy","Encuentro con Roxy en la biblioteca.")
        capture("biblioteca")
        love.keypressed("escape");love.keypressed("m");love.draw()
        check(screen().modal=="map" and player.visited.estudio_rudy and player.visited.patio_eris,"Minimapa y lugares visitados.")
        capture("visitados")

        love.keypressed("f9");settle()
        check(screen().kind=="demo_map","F9 vuelve al menú de mapas.")
        choose("Continuar explorando")
        check(app.session==session and player.map=="biblioteca_ranoa","Continuar conserva la sesión y la ubicación.")
        love.keypressed("f5");love.quit()
        love.keypressed("f9");settle()
        choose("Empezar desde el dormitorio de Eris")
        check(app.session~=session and app.session.exploration.map==World.start.map,"Reiniciar vuelve al dormitorio con una sesión nueva.")
    end,debug.traceback)
    Save.write,love.keyboard.isDown=previousWrite,previousHeld
    love.filesystem.setIdentity(previousIdentity)
    assert(ok,err)
    print(string.format("Demo mapas: %d comprobaciones; %d capturas del renderizador real.",checks,captures))
end

return Suite
