local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Characters=require("src.data.characters")
local Progression=require("src.systems.progression")
local Controls=require("src.config.controls")
local Hub={}
function Hub.new(app)
    local s=Screen.new(app)
    s.definition=assert(Progression.hub(app.session))
    function s:draw()
        self:begin()
        local def=self.definition
        app.resources:background(def.background or "courtyard")
        self:header(def.title)
        W.panel(18,47,604,41)
        local companions=Progression.availableCompanions(app.session)
        local ready=#companions>0
        self:text(ready and (def.readyHeading or def.heading) or def.heading,30,58,578,P.gold)
        self:text(ready and (def.readyDescription or def.description) or def.description,30,74,578,P.ink)
        for i,place in ipairs(def.locations) do
            local id=place.character
            local char=Characters.byId[id]
            local x=18+(i-1)*204
            W.panel(x,99,196,231)
            local visited=place.completedEvent and app.session.events[place.completedEvent]
            app.resources:portrait(id,visited and "happy" or "neutral",x+34,108,2)
            self:text(char.shortName,x+10,241,176,P.gold,1,"center")
            if place.scene then
                self:text(place.title,x+10,258,176,P.muted,1,"center")
                local r=app.session.relationships[id]
                self:text("Conf. "..r.trust.."  /  Amor "..r.chemistry,x+10,276,176,P.ink,1,"center")
            else
                self:text(place.description,x+10,258,176,P.muted,1,"center")
            end
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
