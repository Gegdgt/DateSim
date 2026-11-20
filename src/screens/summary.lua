local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Characters=require("src.data.characters")
local Controls=require("src.config.controls")
local Summary={}
function Summary.new(app)
    local s=Screen.new(app)
    function s:draw()
        self:begin()
        app.resources:background("courtyard")
        love.graphics.setColor(.025,.035,.07,.65)
        love.graphics.rectangle("fill",0,0,640,360)
        W.panel(26,23,588,309)
        self:text("EL PRIMER SELLO",46,44,548,P.gold,2)
        self:text("FASE 1 COMPLETADA · DÍAS 1 Y 2",46,76,548,P.teal)
        local companion=app.session.decisions.companion or "sylphiette"
        app.resources:portrait(companion,"happy",39,110,2)
        self:text("Recuperaste el Sello de la Memoria junto a "..Characters.byId[companion].shortName..".",174,110,418,P.ink)
        for i,id in ipairs(Characters.romanceIds) do
            local r=app.session.relationships[id]
            self:text(Characters.byId[id].shortName..": confianza "..r.trust.."/10 · química "..r.chemistry.."/10",174,155+(i-1)*22,418,P.gold)
        end
        self:text("Tu partida está guardada. La ruta romántica sigue sin elegir. Los días 3 a 7 y sus siete desenlaces quedan pendientes de las siguientes fases.",174,231,414,P.muted)
        self:button("Diario",46,290,156,27,function() app:overlay("journal") end)
        self:button("Colección",214,290,170,27,function() app:overlay("deck") end)
        self:button("Menú principal",396,290,198,27,function() app:save(); app.session=nil; app:menu() end)
        self:text("Las cartas no deciden por ti. Tú eliges los vínculos que construyes.",26,345,588,P.ink,1,"center")
    end
    function s:keypressed(key)
        if Controls.matches(Controls.back,key) then app:overlay("pause") end
    end
    return s
end
return Summary
