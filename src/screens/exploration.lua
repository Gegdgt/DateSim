local Screen=require("src.ui.screen")
local Font=require("src.ui.font")
local Maps=require("src.data.maps")
local Data=require("src.data.exploration_world")
local Catalog=require("src.data.exploration_assets")
local E=require("src.systems.exploration")
local Prologue=require("src.systems.prologue")
local Writer=require("src.systems.typewriter")
local Controls=require("src.config.controls")
local Content=require("src.systems.world_content")
local Objects=require("src.data.world_content")
local Exploration={}
local ink={.94,.91,.81};local gold={1,.8,.39};local muted={.65,.74,.77}
local rows={down=0,left=1,right=2,up=3}
local function panel(x,y,w,h)
    love.graphics.setColor(.035,.055,.09,.97);love.graphics.rectangle("fill",x,y,w,h)
    love.graphics.setColor(.42,.48,.54);love.graphics.rectangle("line",x+.5,y+.5,w-1,h-1)
end
local function text(value,x,y,width,color,scale)
    Font.draw(value,x,y,{maxWidth=width,color=color or ink,scale=scale or 1})
end
function Exploration.new(app)
    local s=Screen.new(app);s.kind="exploration";s.clock=0;s.walkTime=0;s.quads={};s.walking=false;s.running=false
    local session=app.session;local e=session.exploration
    function s:quad(group,id,frame,row)
        local a=Catalog[group][id];local key=group..id..":"..frame..":"..(row or 0)
        if not self.quads[key] then self.quads[key]=love.graphics.newQuad(frame*a.frameWidth,(row or 0)*a.frameHeight,
            a.frameWidth,a.frameHeight,a.width,a.height) end
        return self.quads[key]
    end
    function s:sprite(id,x,y,facing,walking)
        local group=Catalog.overworld[id] and "overworld" or "npcIdle"
        local a=Catalog[group][id];local image=assert(app.resources:getExploration(group,id))
        local frame,row=0,0
        if group=="npcIdle" then frame=math.floor(self.clock/.5)%2
        else row=rows[facing or "down"];frame=walking and math.floor(self.walkTime/.1)%4 or 0 end
        love.graphics.setColor(0,0,0,.25);love.graphics.ellipse("fill",math.floor(x),math.floor(y)-2,7,3)
        love.graphics.setColor(1,1,1);love.graphics.draw(image,self:quad(group,id,frame,row),math.floor(x-a.frameWidth/2),math.floor(y-a.frameHeight))
    end
    function s:drawWorld()
        local map=Maps[e.map];self.camera=E.camera(e)
        love.graphics.setColor(.025,.035,.05);love.graphics.rectangle("fill",0,0,640,360)
        love.graphics.push("all");love.graphics.setScissor(0,30,640,304)
        love.graphics.translate(0,30);love.graphics.scale(2,2);love.graphics.translate(-self.camera.x,-self.camera.y)
        love.graphics.setColor(1,1,1);love.graphics.draw(assert(app.resources:getExploration("maps",e.map)))
        for _,object in ipairs(map.objects) do
            if object.kind=="letter" or not e.resources[object.id] then
                local reading=app.manager and app.manager.current and app.manager.current.kind=="exploration_letter"
                if not (object.kind=="letter" and reading) then
                    love.graphics.setColor(1,1,1);love.graphics.draw(assert(app.resources:getExploration("items",object.sprite)),object.x-8,object.y-16)
                    if object.kind=="letter" then
                        love.graphics.setColor(1,.85,.4,.65);love.graphics.rectangle("fill",object.x+9,object.y-17,2,2)
                    end
                end
            end
        end
        for _,object in ipairs(Content.objects(session,e.map)) do
            local item=Objects.items[object.item]
            if item then
                local taken=session.worldContent and session.worldContent.collected[object.id]
                local sprite=taken and item.openedSprite or item.sprite
                if not taken or item.openedSprite then
                    love.graphics.setColor(1,1,1)
                    love.graphics.draw(assert(app.resources:getExploration("items",sprite)),object.x-8,object.y-16)
                end
            end
        end
        local nearby=E.nearby(session)
        if nearby and not self.modal and not self.greeting then
            local px,py=nearby.reachX or nearby.x,nearby.reachY or nearby.y
            love.graphics.setColor(1,1,1)
            love.graphics.draw(assert(app.resources:getExploration("items","16_indicador_interaccion")),math.floor(px-8),math.floor(py-46))
        end
        local travel=Data.transfers[e.map]
        if travel then
            love.graphics.setColor(.15,.22,.32);love.graphics.rectangle("fill",travel.x-9,travel.y-21,18,16)
            love.graphics.setColor(.52,.87,.94);love.graphics.rectangle("line",travel.x-9.5,travel.y-21.5,19,17)
            text("T",travel.x-3,travel.y-20,10,{.8,.96,1})
        end
        local actors={{id="rudeus",x=e.x,y=e.y,facing=e.facing,walking=self.walking}}
        for _,npc in ipairs(map.npcs.placements) do if E.npcPresent(e,npc) then
            local location=e.npcLocations and e.npcLocations[npc.id]
            actors[#actors+1]={id=npc.sprite,x=npc.x,y=npc.y,facing=location and location.facing}
        end end
        table.sort(actors,function(a,b) return a.y<b.y end)
        for _,actor in ipairs(actors) do self:sprite(actor.id,actor.x,actor.y,actor.facing,actor.walking) end
        love.graphics.pop()
    end
    function s:changeMap(id,arrival)
        if e.map=="dormitorio_eris" and id~=e.map then session.prologue.wake_departed=true end
        if session.rest then session.rest.waking=false end
        E.enter(e,id,arrival);self.walking=false;self.running=false;self.walkTime=0
        app:save();app:explore({type="fade",duration=.35})
    end
    function s:update(dt)
        self.clock=self.clock+dt
        if self.greeting or self.modal or app.manager.transition>0 then
            self.walking=false;self.running=false;self.walkTime=0
            if self.greeting then self.greeting.writer:update(dt) end
            return
        end
        -- También al volver directamente del taller al mismo mapa/pantalla.
        if E.syncPresence(session) then
            app:save();app:notify("Interacciones completadas: 3/3. Las esposas han regresado a sus dormitorios.")
        end
        local function held(keys) for _,key in ipairs(keys) do if love.keyboard.isDown(key) then return 1 end end;return 0 end
        local c=Controls.movement
        -- Consultar el teclado actual evita retener Shift al cambiar de mapa.
        local running=held(Controls.run)==1
        self.walking=E.move(e,held(c.right)-held(c.left),held(c.down)-held(c.up),dt,running)
        self.running=self.walking and running
        if self.walking then self.walkTime=self.walkTime+dt*(self.running and E.runSpeed/E.speed or 1)
        else self.walkTime=0 end
        local portal=E.portal(e)
        if portal then self:changeMap(portal.targetMap,portal.arrival) end
    end
    function s:greet(npc)
        self.walking=false;self.running=false;self.walkTime=0
        local name=npc.id=="zenith" and "mamá" or npc.name
        local response=Content.greeting(session,npc.id)
        local lines={
            {speaker="Rudy (pensamiento)",portrait="rudeus",text="Buenos días, "..name.."."},
            {speaker="Un saludo en silencio",portrait="rudeus",text="Rudy levanta ligeramente la mano e inclina la cabeza."},
            {speaker=npc.name,portrait=npc.id,text=response.text,expression=response.expression or "happy"},
        }
        self.greeting={lines=lines,index=1,npc=npc.id,writer=Writer.new(lines[1].text,app.options)}
        app:save()
    end
    function s:advanceGreeting()
        local g=self.greeting
        if not g.writer:isComplete() then g.writer:showAll();return end
        g.index=g.index+1
        if not g.lines[g.index] then
            self.greeting=nil
            if Content.ready(session) and require("src.systems.daily").atAgenda(session) then
                if g.npc=="cliff" or g.npc=="zanoba" then self.modal="npc_services";self.serviceNPC=g.npc
                elseif require("src.data.wife_activities").byWife[g.npc] and require("src.systems.wife_activities").ready(session) then
                    if require("src.systems.daily").remaining(session)>0 then app:switch(require("src.screens.wife_activities").new(app,g.npc)) end
                end
            end
            return
        end
        g.writer=Writer.new(g.lines[g.index].text,app.options)
    end
    function s:interact()
        if self.modal or self.greeting then return end
        local item=E.nearby(session)
        if not item then return end
        self.walking=false;self.running=false;self.walkTime=0
        if item.kind=="npc" then E.face(session,item) end
        if item.kind=="letter" then self:openLetter()
        elseif item.kind=="bed" then
            local ok,err=require("src.systems.rest").available(session,item)
            if ok then app:switch(require("src.screens.rest").new(app,item)) else app:notify(err) end
        elseif item.kind=="object" or item.kind=="reflection" then
            local result,err=Content.examine(session,item)
            if not result then app:notify(err);return end
            self.inspected={object=item,text=result,start=self.clock};self.modal="object"
            app.audio:effect("paper");app:save()
        elseif item.kind=="travel" then self.modal="travel";self.travel=item
        elseif item.kind=="resource" then
            if not e.resources[item.id] then
                local object={id=item.id,item="flower",kind="object",collectible=true}
                local result,err=Content.examine(session,object)
                if not result then app:notify(err);return end
                e.resources[item.id]=true;session.inventory[item.id]=true;app.audio:effect("paper")
                self.inspected={object=object,text=result,start=self.clock};self.modal="object";app:save()
            end
        elseif item.id=="zenith" then self.modal="family_choice"
        elseif item.id=="nanahoshi" and Prologue.visitNanahoshi(session) then app:save();app:resume()
        elseif item.id=="nanahoshi" and require("src.systems.wife_activities").ready(session)
            and require("src.systems.daily").atAgenda(session) and not require("src.systems.daily").storyComplete(session) then
            local ok,err=require("src.systems.progression").continueStory(session)
            if ok then e.active=false;app:save();app:resume() else app:notify(err) end
        elseif require("src.data.wife_activities").byWife[item.id] and require("src.systems.wife_activities").ready(session) then
            if e.period=="night" then
                local bed=require("src.systems.rest").bed(session)
                local ok,err=require("src.systems.rest").available(session,bed)
                if ok then app:switch(require("src.screens.rest").new(app,bed)) else app:notify(err) end
            elseif require("src.systems.daily").remaining(session)>0 and require("src.systems.daily").atAgenda(session) then
                app:switch(require("src.screens.wife_activities").new(app,item.id))
            else self:greet(item) end
        else self:greet(item) end
    end
    function s:openLetter()
        if not session.prologue.letter_collected and e.map~="estudio_rudy" then return end
        app:switch(require("src.screens.exploration_letter").new(app,self))
    end
    function s:drawMinimap()
        panel(16,44,608,278)
        text("MAPA · "..Maps[e.map].name,30,54,575,gold)
        local map=Maps[e.map];local cell=6;local ox,oy=38,82
        local V=require("src.systems.map_validation")
        for y=0,map.height/16-1 do for x=0,map.width/16-1 do
            local pass=V.isWalkable(map,{x=x*16+8,y=y*16+12})
            love.graphics.setColor(pass and .26 or .10,pass and .32 or .14,pass and .36 or .19)
            love.graphics.rectangle("fill",ox+x*cell,oy+y*cell,cell-1,cell-1)
        end end
        local colors={door={1,.83,.45},stairs={1,.83,.45},npc={.4,.78,1},objective={1,.43,.64},player={.5,1,.65},travel={.8,.65,1}}
        for _,m in ipairs(E.markers(session)) do
            local x,y=math.floor(ox+m.x/16*cell)-2,math.floor(oy+m.y/16*cell)-2
            love.graphics.setColor(colors[m.kind]);love.graphics.rectangle("fill",x,y,5,5)
            if m.kind=="stairs" then love.graphics.setColor(.1,.14,.19);love.graphics.rectangle("fill",x,y+2,3,1) end
        end
        text("VERDE: RUDY  AZUL: NPC\nORO: PUERTA / ESCALERA\nROSA: INTERÉS  LILA: TRASLADO",38,234,290,muted)
        text("LUGARES VISITADOS",348,80,250,gold)
        local ids={};for id in pairs(Maps) do ids[#ids+1]=id end;table.sort(ids)
        for i,id in ipairs(ids) do
            local name=Maps[id].name:gsub("Casa Greyrat %- ",""):gsub("Universidad de Ranoa %- ","Universidad: ")
            text((e.visited[id] and "+ " or "- ")..name,348,98+(i-1)*13,254,e.visited[id] and ink or muted)
        end
        text(Prologue.objective(session),38,280,290,gold)
        text("M / ESC: volver",348,302,245,muted)
    end
    function s:drawGreeting()
        local g=self.greeting;local line=g.lines[g.index]
        panel(18,226,604,100)
        if Catalog.portraits[line.portrait] then
            local img=assert(app.resources:getExploration("portraits",line.portrait))
            local frame=({neutral=0,happy=1,worried=2,angry=3})[line.expression or "neutral"]
            love.graphics.setColor(1,1,1);love.graphics.draw(img,self:quad("portraits",line.portrait,frame),30,243)
        else app.resources:portrait(line.portrait,line.expression or "neutral",30,243,1,
            session.relationships[line.portrait] and not require("src.systems.family").active(session,line.portrait)) end
        text(line.speaker,108,238,480,gold)
        text(g.writer:shown(),108,257,486,ink)
        text("ENTER: continuar · ESC: cerrar",108,306,484,muted)
    end
    function s:drawModal()
        local mode=self.modal
        if mode=="map" then self:drawMinimap();return end
        if mode=="journal" then require("src.ui.objective_journal").draw(self,session);return end
        panel(60,68,520,242)
        if mode=="object" then
            local o=self.inspected.object;local item=Objects.items[o.item]
            text(o.name or item.name,82,85,476,gold,2)
            if item then
                local rise=app.options.reducedMotion and 0 or math.floor(math.max(0,1-(self.clock-self.inspected.start)/.45)*15)
                love.graphics.setColor(1,1,1)
                love.graphics.draw(assert(app.resources:getExploration("items",item.sprite)),86,126+rise,0,3,3)
            end
            text(self.inspected.text,item and 150 or 82,126,item and 398 or 476,ink)
            text("ENTER / ESC: volver",82,279,470,gold)
        elseif mode=="family_choice" then
            text("ZENITH Y LUCY",82,86,470,gold,2)
            text("Lucy descansa en brazos de Zenith.\n\n1: Acercarse a Zenith\n2: Saludar a Lucy\n\nESC: dejarlas descansar",82,130,470)
        elseif mode=="npc_services" then
            text("¿NECESITAS AYUDA?",82,86,470,gold,2)
            text("1: Solicitar ayuda o revisar un encargo\n\nPodrás revisar coste, riesgo y duración\nantes de confirmar.\n\nESC: despedirse",82,130,470)
        elseif mode=="travel" then
            text("PUNTO DE TRASLADO",82,86,476,gold,2)
            text(self.travel.label,82,126,476)
            text("El viaje continúa por una ruta exterior.\nRudy llegará a la parada del otro lado.\nPuedes utilizarla también para regresar.",82,158,470,muted)
            text("ENTER: viajar · ESC: cancelar",82,273,476,gold)
        elseif mode=="pause" then
            text("PAUSA",82,86,470,gold,2)
            text("ENTER / ESC: volver\nF5: guardar partida\nO: opciones\nQ: guardar y volver al menú",82,130,470)
        elseif mode=="inventory" then
            text("INVENTARIO",82,86,470,gold,2)
            text(session.prologue.letter_collected and "Carta de Hitogami · ENTER para abrir" or "Aún no has recogido ningún documento.",82,126,470)
            local items=session.economy.items
            text("Oro: "..session.gold.." · Libros: "..(items.study_book or 0).."\nMateriales: "..(items.magic_material or 0).." · Fragmentos: "..(items.mana_fragment or 0).."\nFlores: "..(items.flower or 0),82,157,470,muted)
            text("Cartas sociales: "..#session.deck.." · Físicas: "..#session.combatDeck,82,201,470)
            text(session.prologue.starting_cards_received and "C: colección · F: fragmento (+2 energía)" or "Todavía no dispones de cartas parlantes.",82,230,470,muted)
            text("I / ESC: volver",82,279,470,gold)
        elseif mode=="status" then
            text("DÍA "..session.day.." · FAMILIA",82,86,470,gold,2)
            local Daily=require("src.systems.daily")
            text(require("src.systems.wife_activities").ready(session) and ("Interacciones disponibles: "..Daily.remaining(session)) or "Tiempo libre: se habilita después del tutorial.",82,126,470)
            text("Los saludos no consumen interacciones.",82,150,470,muted)
            for i,id in ipairs({"eris","roxy","sylphiette"}) do
                local r=session.relationships[id]
                text(require("src.data.characters").byId[id].shortName.." · Amor "..r.love.." · Confianza "..r.trust,82,181+(i-1)*24,470)
            end
            text("TAB / ESC: volver",82,279,470,gold)
        end
    end
    function s:draw()
        self:begin();self:drawWorld()
        panel(0,0,640,30);text(Maps[e.map].name,12,9,430,gold)
        text("DÍA "..session.day,550,9,80,ink)
        panel(0,334,640,26)
        text("WASD/FLECHAS: MOVER | SHIFT: CORRER | E: USAR | M: MAPA | I: BOLSA | J: DIARIO | TAB: ESTADO",10,342,625,muted)
        if self.modal then self:drawModal()
        elseif self.greeting then self:drawGreeting()
        else
            local objective="Objetivo: "..Prologue.objective(session)
            local height=Font.height(objective,600,1)+12
            panel(12,36,616,height);text(objective,20,42,600,gold)
            local item=E.nearby(session)
            if item then
                local label=item.kind=="npc" and ("Hablar con "..item.name) or item.label or "Examinar"
                if item.kind=="letter" then label=session.prologue.letter_read and "Volver a leer la carta" or "Examinar carta misteriosa" end
                if item.kind=="npc" and e.period=="night" and Data.wifeLocations[item.id] then label="Descansar con "..item.name end
                if item.id=="nanahoshi" and session.prologue.curse_discovered and not session.prologue.nanahoshi_visited then label="Pedir ayuda a Nanahoshi" end
                panel(92,299,456,27);text("E — "..label,108,307,426,gold)
            end
        end
    end
    function s:keypressed(key)
        if key=="j" then
            if self.modal=="journal" then self.modal=nil else self.modal="journal" end
            self.journalDay=session.day;self.journalScroll=0;self.walking=false;self.running=false
            return
        end
        if self.modal=="journal" then
            if require("src.ui.objective_journal").key(self,session,key) then return end
            if key=="escape" then self.modal=nil
            elseif (key=="return" or key=="kpenter") and session.prologue.letter_collected then self.modal=nil;self:openLetter()
            elseif key=="h" then app:switch(require("src.screens.history").new(app,function()app:switch(self)end)) end
            return
        end
        if self.greeting then
            if key=="escape" then self.greeting=nil
            elseif key=="return" or key=="kpenter" or key=="e" or key=="space" then self:advanceGreeting() end
            return
        end
        if self.modal then
            local mode=self.modal
            if key=="escape" or (mode=="map" and key=="m") or (mode=="inventory" and key=="i") or (mode=="journal" and key=="j") or (mode=="status" and key=="tab") then
                self.modal=nil;if mode=="object" then app:presentRewards(function()app:switch(self)end) end;return
            end
            if key=="return" or key=="kpenter" then
                if mode=="object" then self.modal=nil;app:presentRewards(function()app:switch(self)end)
                elseif mode=="travel" then self:changeMap(self.travel.target,self.travel.arrival)
                elseif mode=="pause" then self.modal=nil
                elseif (mode=="inventory" or mode=="journal") and session.prologue.letter_collected then self.modal=nil;self:openLetter() end
            elseif mode=="family_choice" and (key=="1" or key=="2") then
                self.modal=nil;self:greet({id=key=="1" and "zenith" or "lucy",name=key=="1" and "Zenith" or "Lucy"})
            elseif mode=="npc_services" and key=="1" then
                self.modal=nil;app:switch(require("src.screens.commissions").new(app,self.serviceNPC,function()app:switch(self)end))
            elseif mode=="inventory" and key=="f" then
                local ok,err=require("src.systems.economy").use(session,"mana_fragment",nil,session.economy.revision)
                if ok then app:save();app:notify("Fragmento usado: +2 energía externa.") else app:notify(err) end
            elseif mode=="pause" and key=="q" then if app:save() then app.session=nil;app:menu() end
            elseif mode=="pause" and key=="o" then app:overlay("options")
            elseif mode=="inventory" and key=="c" and session.prologue.starting_cards_received then app:overlay("deck") end
            return
        end
        self.walking=false;self.running=false;self.walkTime=0
        if key=="e" then self:interact()
        elseif key=="escape" then self.modal="pause"
        elseif key=="m" then self.modal="map"
        elseif key=="i" then self.modal="inventory"
        elseif key=="j" then self.modal="journal"
        elseif key=="tab" then self.modal="status"
        end
    end
    function s:mousepressed() end
    function s:wheelmoved(_,y)
        if self.modal=="journal" then self.journalScroll=math.max(0,math.min(self.journalMax or 0,(self.journalScroll or 0)-y*30)) end
    end
    return s
end
return Exploration
