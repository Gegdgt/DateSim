local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Progression=require("src.systems.progression")
local Dialogue=require("src.systems.dialogue")
local Characters=require("src.data.characters")
local Controls=require("src.config.controls")
local utf8=require("utf8")
local DialogueScreen={}

function DialogueScreen.new(app)
    local s=Screen.new(app)
    s.scene=Progression.scene(app.session,app.session.checkpoint)
    assert(s.scene,"Escena desconocida: "..tostring(app.session.checkpoint))
    s.dialogue=Dialogue.new(s.scene,app.session.dialogueIndex)
    s.elapsed=0
    s.visible=0
    function s:update(dt)
        self.elapsed=self.elapsed+dt
        self.visible=math.floor(self.elapsed*50)
    end
    function s:fullText() return self.dialogue:current().text end
    function s:ready() return self.visible >= utf8.len(self:fullText()) end
    function s:advance()
        if not self:ready() then
            self.elapsed=utf8.len(self:fullText())/50+.1
            self.visible=utf8.len(self:fullText())
            return
        end
        if self.dialogue:isLast() then
            if self.scene.choices and #self.scene.choices>0 then return end
            app:next()
        else
            self.dialogue:advance()
            app.session.dialogueIndex=self.dialogue.index
            self.elapsed,self.visible=0,0
            app:save()
        end
    end
    function s:draw()
        self:begin()
        local line=self.dialogue:current()
        app.resources:background(self.scene.background or "courtyard")
        self:header(self.scene.title)
        local char=Characters.byId[line.speaker]
        local portrait=char and line.speaker or "rudeus"
        app.resources:portrait(portrait,line.expression or "neutral",39,83,2)
        W.panel(172,67,435,49)
        self:text("RANOA · FESTIVAL DE LAS SEIS CARAS",185,79,408,P.gold)
        self:text("Las decisiones de Rudy son tuyas.",185,97,408,P.muted)
        local choices=self.scene.choices
        if self.dialogue:isLast() and self:ready() and choices then
            for i,choice in ipairs(choices) do
                self:button(choice.label,172,126+(i-1)*39,435,34,function()
                    local ok,err=Progression.choose(app.session,app.session.checkpoint,choice.id)
                    if ok then app:next() else app:notify(err) end
                end)
            end
        end
        W.panel(18,227,604,116)
        W.panel(30,214,math.max(112,math.min(272,#(char and char.name or "Narración")*6+28)),24)
        self:text(char and char.name or "Narración",42,222,260,P.gold)
        local full=self:fullText()
        local boundary=utf8.offset(full,self.visible+1)
        local shown=boundary and full:sub(1,boundary-1) or full
        self:text(shown,34,250,572,P.ink)
        local hint=self:ready() and ((choices and self.dialogue:isLast()) and "Elige una respuesta arriba" or "CLIC / ENTER / ESPACIO  >") or "CLIC para mostrar el texto"
        self:text(hint,34,325,572,P.muted,1,"right")
    end
    function s:mousepressed(x,y,b)
        if self:click(x,y,b) then return end
        if b==1 then self:advance() end
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.advance,key) then self:advance()
        elseif Controls.matches(Controls.back,key) then app:overlay("pause")
        elseif Controls.matches(Controls.journal,key) then app:overlay("journal")
        elseif Controls.matches(Controls.deck,key) then app:overlay("deck") end
    end
    return s
end
return DialogueScreen
