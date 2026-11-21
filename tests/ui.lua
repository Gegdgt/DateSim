-- Ejecutar dentro de LÖVE. Usa las pantallas reales con guardado en memoria.
local Suite={}

function Suite.run()
    local CardView=require("src.ui.card")
    local Font=require("src.ui.font")
    local Data=require("src.data.cards")
    local Cards=require("src.systems.cards")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local checked=0
    local function check(ok,message) assert(ok,message); checked=checked+1 end
    local function overlaps(a,b)
        return a.x<b.x+b.w and a.x+a.w>b.x and a.y<b.y+b.h and a.y+a.h>b.y
    end

    for name,region in pairs(CardView.regions) do
        check(region.x>=6 and region.y>=6 and region.x+region.w<=74 and region.y+region.h<=106,
            "Región dentro del margen del marco: "..name)
        for other,otherRegion in pairs(CardView.regions) do
            if name<other then check(not overlaps(region,otherRegion),"Regiones separadas: "..name.."/"..other) end
        end
    end
    for _,card in ipairs(Data.list) do
        check(CardView.labels(card).name==card.shortName and Font.width(card.shortName)<=CardView.regions.name.w,
            "Etiqueta breve legible sin reducir tipografía: "..card.id)
        for key,label in pairs(CardView.labels(card)) do
            local region=CardView.regions[key]
            check(Font.height(label,region.w)<=region.h,"Texto cabe en carta: "..card.id.."/"..key)
            for _,line in ipairs(Font.wrap(label,region.w)) do
                check(Font.width(line)<=region.w,"Línea respeta margen: "..card.id.."/"..key)
            end
        end
        check(Font.height(card.description,173)<=64,"Descripción cabe en panel del encuentro: "..card.id)
        check(Font.height(Data.categories[card.category],173)<=22,"Categoría completa cabe en detalles: "..card.id)
    end

    -- Observe the actual draw calls, including the individual bitmap glyph
    -- pixels. A clipping rectangle cannot hide an overflowing label here.
    local originalDraw,originalRectangle=Font.draw,love.graphics.rectangle
    local ok,err=xpcall(function()
        for _,card in ipairs(Data.list) do
            local labels=CardView.labels(card)
            local order,bounds={},{}
            local active
            local function record(kind) order[#order+1]=kind end
            local resources={
                cardBase=function(_,x,y,scale)
                    check(x==20 and y==10 and scale==1,"Pergamino en coordenadas enteras")
                    record("base")
                end,
                cardFrame=function(_,category,x,y,scale)
                    check(category==card.category and x==20 and y==10 and scale==1,"Marco corresponde a categoría")
                    record("frame")
                end,
                icon=function(_,id,x,y,scale)
                    check(id==card.id and x==48 and y==75 and scale==1,"Icono propio sin escala fraccionaria")
                    record("icon")
                end,
            }
            Font.draw=function(text,x,y,opts)
                local key
                for candidate,label in pairs(labels) do if text==label then key=candidate end end
                check(key~=nil,"Texto reconocido de la carta")
                local region=CardView.regions[key]
                check(x==20+region.x and y==10+region.y,"Texto colocado en su región")
                active={x=x,y=y,w=region.w,h=region.h,inside=true,pixels=0}
                bounds[key]=active
                record(key)
                local height=originalDraw(text,x,y,opts)
                active=nil
                return height
            end
            love.graphics.rectangle=function(mode,x,y,w,h,...)
                if active then
                    active.pixels=active.pixels+1
                    active.inside=active.inside and x>=active.x and y>=active.y
                        and x+w<=active.x+active.w and y+h<=active.y+active.h
                        and x%1==0 and y%1==0 and w%1==0 and h%1==0
                end
            end
            CardView.draw(resources,card,20.75,10.75)
            for key,box in pairs(bounds) do
                check(box.inside and box.pixels>0,"Píxeles del texto dentro de región: "..card.id.."/"..key)
            end
            local index={}; for i,kind in ipairs(order) do index[kind]=i end
            check(index.base<index.frame and index.frame<index.name and index.name<index.icon and index.icon<index.cost,
                "Capas: pergamino, marco, nombre, icono, coste: "..card.id)
        end
    end,debug.traceback)
    Font.draw,love.graphics.rectangle=originalDraw,originalRectangle
    assert(ok,err)

    local old={write=Save.write,load=Save.load,exists=Save.exists,readOptions=Save.readOptions,writeOptions=Save.writeOptions}
    local volume=love.audio.getVolume()
    local stored
    Save.write=function(session) stored=assert(Json.encode(assert(Save.validate(session)))); return true end
    Save.load=function() return stored and Save.validate(assert(Json.decode(stored))) end
    Save.exists=function() return stored~=nil end
    Save.readOptions=function() return {volume=.6,muted=false} end
    Save.writeOptions=function() return true end
    ok,err=xpcall(function()
        local app=require("src.app").new()
        local mx,my
        app.mouse=function() return mx,my end
        local function render(dt) app:update(dt or 1.6); app:draw() end
        local function click(x,y)
            app:mousepressed(app.offsetX+x*app.scale,app.offsetY+y*app.scale,1)
        end
        render()
        app:keypressed("tab")
        app:keypressed("down")
        check(app.manager.current.buttons[app.manager.current.keyboardFocus].label=="Práctica: social y combate",
            "Teclado del menú salta Continuar deshabilitado")
        app:keypressed("down"); app:keypressed("down")
        app:keypressed("return")
        check(app.manager.current.kind=="options","Enter abre opción enfocada")
        render()
        app:keypressed("escape")
        render()
        app:keypressed("tab")
        app:keypressed("return")
        check(app.session and app.session.checkpoint=="intro","Nueva partida accesible por teclado")
        app:keypressed("return")
        click(100,300)
        check(app.session.dialogueIndex==1 and app.manager.current.visible==0,
            "Entrada repetida durante transición no salta texto nuevo")

        app.session=Save.newSession({love=65,trust=65})
        app.session.day,app.session.checkpoint=2,"encounter_roxy"
        -- Two legal cards costing two leave the third turn with no energy.
        app.session.deck[9]="combined_spell"
        app.session.unlocked.combined_spell=true
        app.session.encounter=Cards.new(app.session.deck,{kind="investigation",character="roxy"},function(n) return n end)
        app:resume()
        mx,my=341,220
        render()
        local screen=app.manager.current
        check(screen.selected==3,"Ratón selecciona tercera carta para ver detalles")
        app:keypressed("left")
        app:draw()
        check(screen.selected==2,"Ratón inmóvil no deshace selección de teclado")
        app:keypressed("left")
        app:keypressed("return")
        check(screen.enc.turn==2 and screen.enc.energy==2 and screen.enc.discard[1]=="earth_barrier",
            "Enter juega carta seleccionada una vez")
        app:keypressed("return")
        click(153,209)
        check(screen.enc.turn==2 and #screen.enc.discard==1,"Doble entrada de teclado/ratón no juega carta recién robada")
        render()
        check(screen.phase=="result" and not screen:busy(),"La animación termina mostrando el resultado antes del próximo turno")
        app:keypressed("return")
        check(screen.phase=="hand" and screen.enc.turn==2,"Confirmar resultado vuelve a la mano sin aplicar otra carta")
        render()
        click(153,209)
        check(screen.enc.turn==2 and screen.confirmReady,"Clic en carta consulta su efecto antes de consumir energía")
        app:draw()
        local playButton
        for _,button in ipairs(screen.buttons) do if button.label=="Jugar carta [Enter]" then playButton=button end end
        check(playButton~=nil,"Confirmación de carta tiene un botón real")
        click(playButton.x+4,playButton.y+4)
        check(screen.enc.turn==3 and screen.enc.energy==0 and screen.enc.discard[2]=="combined_spell",
            "Ratón selecciona y confirma una carta respetando su coste")
        render()
        app:keypressed("return")
        render()
        local textSeen={}
        Font.draw=function(text,...)
            textSeen[text]=true
            return originalDraw(text,...)
        end
        app:draw()
        Font.draw=originalDraw
        check(textSeen["[1] NO DISP."] and textSeen["No hay energía suficiente."],
            "Carta sin energía informa disponibilidad y motivo")
        local before=assert(Json.encode(screen.enc))
        click(153,209)
        app:keypressed("return")
        check(Json.encode(screen.enc)==before,"Carta deshabilitada no consume turno ni cambia pilas")
        app:keypressed("right")
        app:keypressed("right")
        app:keypressed("return")
        check(screen.enc.finished and screen.enc.energy==0 and screen.enc.discard[3]=="admit_error",
            "Carta de coste cero disponible al agotarse energía")
        render()
        app:overlay("deck")
        mx,my=nil,nil
        render()
        screen=app.manager.current
        app:keypressed("tab")
        app:keypressed("down")
        app:keypressed("down")
        app:keypressed("return")
        check(screen.selected==2,"Colección permite inspeccionar cartas con teclado")
        app:draw()
        local lockedRow
        for _,button in ipairs(screen.buttons) do if button.cardIndex==16 then lockedRow=button end end
        check(lockedRow~=nil,"Carta futura presente en el grupo de bloqueadas")
        click(lockedRow.x+4,lockedRow.y+4)
        check(screen.selected==16,"Colección permite inspeccionar una carta futura bloqueada")
        app:draw()
    end,debug.traceback)
    Font.draw=originalDraw
    for key,value in pairs(old) do Save[key]=value end
    love.audio.setVolume(volume)
    assert(ok,err)
    print("OK: "..checked.." comprobaciones de composición de cartas, márgenes e interacción.")
    return checked
end

return Suite
