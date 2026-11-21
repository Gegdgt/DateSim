local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Safe={}
function Safe.new(app)
    local s=Screen.new(app)
    app.audio:setContext("university")
    function s:draw()
        self:begin(); app.resources:background("laboratory")
        W.panel(65,52,510,265)
        self:text("PUNTO SEGURO / PREPARACIÓN",86,72,466,P.gold,2)
        self:text("Rudy se ha retirado a un círculo protegido. Tus relaciones, cartas y decisiones siguen intactas. Puedes ajustar el mazo y volver a intentar el enfrentamiento.",86,116,466)
        self:text("Al regresar: 30 PV y 3 acciones. La maldición y los fragmentos se conservan. Equipa entre cinco y diez cartas, con al menos dos ataques; defensa y esquiva no requieren cartas.",86,166,466,P.teal)
        self:button("Volver al enfrentamiento",86,211,466,26,function()
            app.session.combatPreparation=nil; app:save(); app:resume()
        end)
        self:button("Editar mazo",86,246,225,26,function() app:overlay("deck") end)
        self:button("Menú principal",324,246,228,26,function() app:save(); app:menu() end)
        self:button("Manual del aventurero",86,281,466,24,function() app:manual() end)
    end
    return s
end
return Safe
