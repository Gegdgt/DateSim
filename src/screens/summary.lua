local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Characters=require("src.data.characters")
local Controls=require("src.config.controls")
local Progression=require("src.systems.progression")
local Summary={}
function Summary.new(app)
    local s=Screen.new(app)
    s.definition=assert(Progression.summary(app.session))
    function s:draw()
        self:begin()
        local def=self.definition
        app.resources:background(def.background or "courtyard")
        love.graphics.setColor(.025,.035,.07,.65)
        love.graphics.rectangle("fill",0,0,640,360)
        W.panel(26,23,588,309)
        self:text(def.title,46,44,548,P.gold,2)
        self:text(def.subtitle,46,76,548,P.teal)
        local companion=def.endingId and Characters.byId[def.endingId] and def.endingId or Progression.companion(app.session) or "rudeus"
        app.resources:portrait(companion,"happy",39,110,2)
        self:text(def.body,174,110,418,P.ink)
        if def.epilogue then self:text(def.epilogue,174,181,418,P.teal) end
        for i,id in ipairs(Characters.romanceIds) do
            local r=app.session.relationships[id]
            if def.endingId then
                self:text(Characters.byId[id].shortName.."\nAmor "..r.love.." · Conf. "..r.trust,46+(i-1)*183,251,176,P.gold)
            else self:text(Characters.byId[id].shortName..": confianza "..r.trust.."/100 · amor "..r.love.."/100",174,175+(i-1)*18,418,P.gold) end
        end
        if not def.endingId then self:text(def.pending or "Tu partida está guardada.",174,231,414,P.muted) end
        if Progression.canContinue(app.session) then
            self:button(def.continueLabel or "Continuar",46,286,132,35,function() app:next() end)
            self:button("Diario",184,286,124,35,function() app:overlay("journal") end)
            self:button("Colección",314,286,132,35,function() app:overlay("deck") end)
            self:button("Menú principal",452,286,142,35,function() app:save(); app.session=nil; app:menu() end)
        else
            self:button("Diario",46,290,156,27,function() app:overlay("journal") end)
            self:button("Colección",214,290,170,27,function() app:overlay("deck") end)
            self:button("Menú principal",396,290,198,27,function() app:save(); app.session=nil; app:menu() end)
        end
        self:text(def.footer or "Tu progreso está guardado.",26,345,588,P.ink,1,"center")
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.back,key) then app:overlay("pause") end
    end
    return s
end
return Summary
