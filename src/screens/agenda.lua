local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Daily=require("src.systems.daily")
local Catalog=require("src.data.activities")
local Progression=require("src.systems.progression")
local Controls=require("src.config.controls")
local Budget=require("src.systems.relationship_budget")
local Agenda={}
function Agenda.new(app)
    local s=Screen.new(app)
    s.kind="agenda"; s.tab="activities"; s.page=1
    local function commit(ok,err)
        if not ok then app:notify(err); return end
        if app:save() then app:resume() end
    end
    function s:draw()
        self:begin()
        local session=app.session
        local d=Daily.ensure(session)
        app.resources:background("home")
        self:header("DÍA "..session.day.." / AGENDA · ORO "..session.gold)
        local active=d.active_activity
        if active then
            local def=Catalog.byId[active.id]
            W.panel(18,48,604,278)
            app.resources:portrait(def.character,"happy",42,82,2)
            self:text(def.title,190,71,400,P.gold,2)
            self:text(def.description,190,115,400,P.ink)
            self:text("Espacio reservado · quedan "..Daily.remaining(session).." de 3",190,164,400,P.teal)
            for i,choice in ipairs(def.choices) do
                local delta=Budget.preview(session,def.character,choice.effects)
                self:button(choice.label.." (+"..delta.love.." amor / +"..delta.trust.." conf.)",190,197+(i-1)*43,410,34,function()
                    local result,err=Daily.resolveActivity(session,choice.id)
                    commit(result,err)
                    if result then app:notify(result) end
                end)
            end
            self:text("Esta actividad ya reservó un espacio. Guardar conserva la decisión pendiente.",30,335,580,P.ink)
            return
        end
        self:button("Actividades",18,47,190,27,function() self.tab="activities"; self.keyboardFocus=nil end,false,self.tab=="activities")
        self:button("Encargos",218,47,190,27,function() self.tab="favors"; self.keyboardFocus=nil end,false,self.tab=="favors")
        self:button("Cambios de ayer",418,47,204,27,function()
            local report=session.daily_history[tostring(session.day-1)]
            app:switch(require("src.screens.day_report").new(app,report,function() app:resume() end))
        end,not session.daily_history[tostring(session.day-1)])
        W.panel(18,80,604,26)
        self:text("Libres: "..Daily.remaining(session).."/3   ·   Encargo: "..(d.favor_used and "solicitado" or "1 disponible").."   ·   Historia: "..(Daily.storyComplete(session) and "completa" or "pendiente"),28,89,584,P.gold)
        if self.tab=="activities" then
            local pages=math.max(1,math.ceil(#Catalog.list/3))
            if pages>1 then
                self:button("<",548,80,30,26,function() self.page=self.page-1 end,self.page==1)
                self:button(">",586,80,30,26,function() self.page=self.page+1 end,self.page==pages)
            end
            for i=1,math.min(3,#Catalog.list-(self.page-1)*3) do
                local def=Catalog.list[(self.page-1)*3+i]
                local x=18+(i-1)*204
                W.panel(x,113,196,153)
                app.resources:portrait(def.character,"neutral",x+10,122,1)
                self:text(def.title,x+80,126,106,P.gold)
                self:text("Visitas: "..d.visits[def.character],x+80,160,106,P.teal)
                self:text("1 espacio · +12 oro / +1 copia\n+2 amor/+1 conf. o +1/+2",x+10,195,176,P.ink)
                local disabled=Daily.remaining(session)==0 or d.activities_locked or d.ending_processed or session.relationships[def.character].marriageState=="separated"
                self:button("Pasar tiempo",x+10,232,176,24,function() commit(Daily.startActivity(session,def.id)) end,disabled)
            end
        else
            for i,def in ipairs(Catalog.favors) do
                local y=113+(i-1)*59
                W.panel(18,y,604,54)
                self:text(def.title,28,y+8,410,P.gold)
                self:text(def.reward..". "..def.description,28,y+24,406,P.ink)
                self:button("Solicitar",460,y+12,150,29,function() commit(Daily.requestFavor(session,def.id)) end,d.favor_used or d.activities_locked)
            end
            local pending={}
            for _,favor in ipairs(session.pending_favors) do
                if favor.status=="pending" then pending[#pending+1]=Catalog.favorsById[favor.id].character.." (cierre D"..favor.due_day..")" end
            end
            self:text("Pendientes: "..(#pending>0 and table.concat(pending,", ") or "ninguno")..". Las copias repetidas sirven para mejorar.",28,237,584,P.ink)
        end
        local finalLock=session.day==7 and not d.activities_locked
        self:text(finalLock and "Resolver la historia cierra el tiempo libre antes de los acuerdos finales." or "Al dormir: +1 confianza si hubo visita; -1 si no. Los espacios libres se pierden.",24,274,592,P.ink)
        self:button(finalLock and "Cerrar tiempo libre e ir a la historia" or "Continuar historia",18,301,330,29,function() commit(Progression.continueStory(session)) end,Daily.storyComplete(session))
        self:button("Finalizar día",358,301,264,29,function() app:endDay() end,not Daily.storyComplete(session))
        self:text("La historia obligatoria no consume espacios. Puedes dormir sin usar los tres.",24,341,592,P.muted)
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.back,key) then app:overlay("pause")
        elseif Controls.matches(Controls.journal,key) then app:overlay("journal")
        elseif Controls.matches(Controls.deck,key) then app:overlay("deck") end
    end
    return s
end
return Agenda
