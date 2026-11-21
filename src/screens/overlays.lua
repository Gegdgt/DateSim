local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Characters=require("src.data.characters")
local Controls=require("src.config.controls")
local Progression=require("src.systems.progression")
local Overlays={}

-- El diario sólo muestra lo que Rudy ya ha descubierto en pantalla.
function Overlays.curseStatus(curse)
    curse=curse or {}
    local status={}
    if curse.discoveredVoice then status[#status+1]=curse.voiceSealed and "VOZ SELLADA" or "VOZ RECUPERADA" end
    if curse.discoveredMana then status[#status+1]=curse.manaBlocked and "MANÁ BLOQUEADO" or "MAGIA RECUPERADA" end
    return #status>0 and table.concat(status," · ") or "Sin diagnóstico"
end

function Overlays.new(app,kind)
    if kind=="deck" then return require("src.screens.collection").new(app) end
    if kind=="options" then return require("src.screens.options").new(app) end
    local s=Screen.new(app)
    s.kind=kind
    s.selected=1
    s.page=1
    function s:draw()
        self:begin()
        app.resources:background("library")
        love.graphics.setColor(.025,.035,.07,.7)
        love.graphics.rectangle("fill",0,0,640,360)
        if kind=="pause" then
            self:header("PARTIDA EN PAUSA",true)
            W.panel(132,67,376,249)
            self:text("UN MOMENTO PARA RESPIRAR",151,88,338,P.gold)
            self:button("Volver a la historia",153,118,334,29,function() app:resume() end)
            self:button("Guardar partida [F5]",153,154,334,29,function() if app:save() then app:notify("Partida guardada.") end end)
            self:button("Opciones",153,190,334,29,function() app:overlay("options") end)
            self:button("Menú principal",153,226,334,29,function() app:save(); app.session=nil; app:menu() end)
            self:button("Salir",153,262,334,29,function() love.event.quit() end)
        elseif kind=="journal" then
            self:header("DIARIO / PERSONAJES Y RECUERDOS",true)
            if app.session.clues and app.session.clues.hitogami_letter then
                self:button("Carta —H",330,12,104,20,function()
                    app:switch(require("src.screens.document").new(app,"hitogami_letter",function() app:switch(self) end))
                end)
            end
            self:button("Historial",440,12,100,20,function() app:switch(require("src.screens.history").new(app,function() app:overlay("journal") end)) end)
            for i,id in ipairs(Characters.romanceIds) do
                local char=Characters.byId[id]
                local r=app.session.relationships[id]
                local x=18+(i-1)*204
                W.panel(x,49,196,215)
                self:text(char.shortName,x+10,61,176,P.gold)
                self:text(char.theme,x+10,79,176,P.muted)
                app.resources:portrait(id,r.marriageState=="separated" and "worried" or "neutral",x+125,105,1,r.marriageState=="separated")
                self:text("Confianza "..r.trust,x+10,113,110,P.ink)
                W.bar(x+10,129,108,7,r.trust+100,200,P.teal)
                self:text("Amor "..r.love,x+10,150,110,P.ink)
                W.bar(x+10,166,108,7,r.love+100,200,P.rose)
                local conflicts,broken=0,0
                for _,value in pairs(r.pendingConflicts or {}) do if value then conflicts=conflicts+1 end end
                for _,value in pairs(r.promises or {}) do if value=="broken" or (type(value)=="table" and value.status=="broken") then broken=broken+1 end end
                local gains=require("src.systems.relationship_budget").ensure(app.session)[id]
                self:text("Hoy: +"..gains.love.." amor / +"..gains.trust.." conf.\nLímite: +10 de cada uno\nConflictos: "..conflicts.." · Promesas: "..broken,x+10,183,176,P.ink)
                local states={married="casados",stable="estable",strained="en tensión",reconciled="reconciliados",separated="separados",committed="comprometidos"}
                self:text("Matrimonio: "..(states[r.marriageState] or "en curso"),x+10,241,176,P.muted)
            end
            W.panel(18,275,604,67)
            local companion=Progression.companion(app.session)
            self:text("Día "..app.session.day.." / 7 · "..Overlays.curseStatus(app.session.curse),30,287,578,P.gold)
            self:text("Compañía: "..(companion and Characters.byId[companion].shortName or "por elegir")..". Los compromisos y conflictos persisten entre días.",30,305,578,P.ink)
            self:text("Un matrimonio necesita confianza, amor y hechos; consulta el historial.",30,328,578,P.muted)
        end
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.back,key) then app:resume() end
    end
    return s
end
return Overlays
