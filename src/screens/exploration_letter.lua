local Font=require("src.ui.font")
local Typewriter=require("src.systems.typewriter")
local Prologue=require("src.systems.prologue")
local Letter={}
function Letter.new(app,world)
    local session=app.session;local p=session.prologue
    assert(p.letter_collected or session.exploration.map=="estudio_rudy","La carta está exclusivamente en el estudio")
    p.letter_found=true
    local doc=require("src.data.documents").hitogami_letter
    local lines=Font.wrap(doc.text,492,1);local pages={}
    for start=1,#lines,14 do
        local page={};for n=start,math.min(#lines,start+13) do page[#page+1]=lines[n] end
        pages[#pages+1]=table.concat(page,"\n")
    end
    local saved=session.documentState
    local s={kind="exploration_letter",world=world,pages=pages,page=1,elapsed=0,reread=p.letter_read}
    s.phase=s.reread and "reading" or p.letter_collected and "sealed" or "lifting"
    if not s.reread and saved and saved.id=="hitogami_letter" then
        s.page=math.max(1,math.min(#pages,saved.page or 1))
        if p.letter_collected and (saved.phase=="reading" or saved.phase=="signature") then s.phase=saved.phase end
    end
    s.writer=Typewriter.new(pages[s.page],app.options)
    function s:persist()
        if self.reread then return end
        session.documentState={id="hitogami_letter",phase=self.phase,page=self.page,elapsed=self.elapsed}
        app:save()
    end
    function s:close()
        self:persist();app:switch(world,{type="fade_in",duration=.25})
    end
    function s:interact()
        if self.phase=="sealed" then
            self.phase="opening";self.elapsed=0;app.audio:effect("envelope_open");self:persist()
        elseif self.phase=="reading" then
            if not self.writer:isComplete() then self.writer:showAll();return end
            if self.page<#pages then
                self.page=self.page+1;self.writer=Typewriter.new(pages[self.page],app.options);app.audio:effect("paper")
            else self.phase="signature";if not self.reread then app.audio:effect("revelation") end end
            self:persist()
        elseif self.phase=="signature" then
            if not self.reread and Prologue.readLetter(session) then app:save();app:resume()
            else session.documentState=nil;app:save();app:switch(world) end
        end
    end
    function s:update(dt)
        self.elapsed=self.elapsed+dt
        if self.phase=="lifting" and self.elapsed>=(app.options.reducedMotion and .01 or .7) then
            p.letter_collected=true;session.inventory.hitogami_letter=true
            Prologue.objective(session)
            self.phase="sealed";self.elapsed=0;self:persist()
        elseif self.phase=="opening" and self.elapsed>=(app.options.reducedMotion and .01 or .35) then
            self.phase="reading";self.elapsed=0;self:persist()
        elseif self.phase=="reading" then self.writer:update(dt) end
    end
    function s:draw()
        world:drawWorld()
        love.graphics.setColor(.025,.035,.065,.72);love.graphics.rectangle("fill",0,0,640,360)
        local function text(value,x,y,w,color,scale) Font.draw(value,x,y,{maxWidth=w,color=color or {.2,.14,.13},scale=scale or 1}) end
        if self.phase=="reading" or self.phase=="signature" then
            love.graphics.setColor(.31,.22,.19);love.graphics.rectangle("fill",48,29,544,304)
            love.graphics.setColor(.92,.84,.66);love.graphics.rectangle("fill",53,34,534,294)
            text("UN SOBRE EN EL ESTUDIO",74,48,490,{.40,.23,.18})
            if self.phase=="signature" then
                text("Con mis mejores deseos,",82,110,476)
                text("—H",268,157,180,{.48,.15,.12},4)
                text(self.reread and "Una firma que no has olvidado." or "Esa letra... La risa del sueño regresa a tu memoria.",82,221,476)
                text(self.reread and "ENTER: cerrar" or "ENTER: terminar de leer",82,287,476,{.4,.18,.12})
            else
                text(self.writer:shown(),74,78,492)
                text("Página "..self.page.." / "..#pages,74,253,280,{.4,.23,.18})
                text("ENTER: "..(self.writer:isComplete() and (self.page<#pages and "siguiente página" or "leer firma") or "mostrar texto"),74,282,492)
                text("ESC: guardar lectura y volver",74,304,492,{.4,.23,.18})
            end
        else
            local camera=require("src.systems.exploration").camera(session.exploration)
            local x,y,scale=272,110,6
            if self.phase=="lifting" then
                local t=math.min(1,self.elapsed/.7);local eased=t*t*(3-2*t)
                x=(176-camera.x)*2-16+(272-((176-camera.x)*2-16))*eased
                y=(64-camera.y)*2+30-32+(110-((64-camera.y)*2+30-32))*eased-math.sin(t*math.pi)*28
                scale=2+math.floor(eased*4)
            end
            love.graphics.setColor(1,1,1)
            love.graphics.draw(assert(app.resources:getExploration("items","15_nota_misteriosa")),math.floor(x),math.floor(y),0,scale,scale)
            if self.phase=="sealed" then
                text("Una carta sin remitente.",184,239,340,{1,.9,.7})
                text("ENTER: abrir · ESC: guardar para después",92,276,490,{1,.9,.7})
            end
        end
    end
    function s:keypressed(key)
        if key=="escape" then self:close()
        elseif key=="return" or key=="kpenter" or key=="e" then self:interact()
        elseif key=="left" and self.phase=="reading" and self.page>1 then
            self.page=self.page-1;self.writer=Typewriter.new(pages[self.page],app.options);self:persist()
        end
    end
    function s:mousepressed(_,_,button) if button==1 then self:interact() end end
    app.audio:effect("paper");s:persist()
    return s
end
return Letter
