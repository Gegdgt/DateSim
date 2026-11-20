local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Story=require("src.data.story")
local Characters=require("src.data.characters")
local Progression=require("src.systems.progression")
local Controls=require("src.config.controls")
local Hub={}
function Hub.new(app)
    local s=Screen.new(app)
    function s:draw()
        self:begin()
        app.resources:background("courtyard")
        self:header("DÍA 2 / REENCUENTROS EN RANOA")
        W.panel(18,47,604,41)
        local companions=Progression.availableCompanions(app.session)
        local ready=#companions==3
        self:text(ready and "EL SELLO DE LA MEMORIA" or "TRES CAMINOS QUE VUELVEN A ENCONTRARSE",30,58,578,P.gold)
        self:text(ready and "Elige quién vendrá a las ruinas. La ruta romántica se decidirá más adelante." or "Visita a las tres. Cada encuentro revela una forma distinta de conectar.",30,74,578,P.ink)
        for i,place in ipairs(Story.locations) do
            local id=place.character
            local char=Characters.byId[id]
            local x=18+(i-1)*204
            W.panel(x,99,196,231)
            app.resources:portrait(id,app.session.events["meeting_"..id] and "happy" or "neutral",x+34,108,2)
            self:text(char.shortName,x+10,241,176,P.gold,1,"center")
            self:text(place.title,x+10,258,176,P.muted,1,"center")
            local r=app.session.relationships[id]
            self:text("Conf. "..r.trust.."  /  Química "..r.chemistry,x+10,276,176,P.ink,1,"center")
            local visited=app.session.events["meeting_"..id]
            self:button(ready and "Elegir compañía" or (visited and "Encuentro completo" or "Visitar"),x+8,297,180,24,function()
                local nextId,err
                if ready then nextId,err=Progression.selectCompanion(app.session,id)
                else nextId,err=Progression.visit(app.session,id) end
                if nextId then app:save(); app:resume() else app:notify(err) end
            end,visited and not ready)
        end
        W.panel(18,336,604,20,{shadow=false})
        self:text("Puedes consultar tus vínculos en el diario. Guardado automático activado.",26,343,588,P.ink)
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.back,key) then app:overlay("pause")
        elseif Controls.matches(Controls.journal,key) then app:overlay("journal")
        elseif Controls.matches(Controls.deck,key) then app:overlay("deck") end
    end
    return s
end
return Hub
