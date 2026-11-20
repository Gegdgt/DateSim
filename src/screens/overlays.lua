local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Data=require("src.data.cards")
local Characters=require("src.data.characters")
local Save=require("src.systems.save")
local Controls=require("src.config.controls")
local Overlays={}

function Overlays.new(app,kind)
    local s=Screen.new(app)
    s.kind=kind
    s.selected=1
    local function optionChanged()
        app:applyAudio()
        local ok,err=Save.writeOptions(app.options)
        if not ok then app:notify("No se guardaron las opciones: "..tostring(err)) end
        if app.session then app:save() end
    end
    function s:draw()
        self:begin()
        app.resources:background("library")
        love.graphics.setColor(.025,.035,.07,.7)
        love.graphics.rectangle("fill",0,0,640,360)
        if kind=="options" then
            self:header("OPCIONES",true)
            W.panel(70,65,500,246)
            self:text("AUDIO",90,86,460,P.gold,2)
            self:text("Volumen general: "..math.floor(app.options.volume*100+.5).."%",90,124,460,P.ink)
            self:button("-",90,148,60,29,function() app.options.volume=math.max(0,app.options.volume-.1); optionChanged() end)
            W.bar(166,157,250,10,app.options.volume,1,P.teal)
            self:button("+",434,148,60,29,function() app.options.volume=math.min(1,app.options.volume+.1); optionChanged() end)
            self:button(app.options.muted and "Sonido: silenciado" or "Sonido: activado",90,192,404,29,function() app.options.muted=not app.options.muted; optionChanged() end)
            self:text("La Fase 1 no incluye música ni efectos de sonido.\nLa configuración queda preparada y guardada.",90,240,450,P.muted)
            self:text("F11: pantalla completa · Esc: volver",90,282,450,P.teal)
        elseif kind=="pause" then
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
            for i,id in ipairs(Characters.romanceIds) do
                local char=Characters.byId[id]
                local r=app.session.relationships[id]
                local x=18+(i-1)*204
                W.panel(x,49,196,215)
                self:text(char.shortName,x+10,61,176,P.gold)
                self:text(char.theme,x+10,79,176,P.muted)
                self:text("Confianza "..r.trust.." / 10",x+10,113,176,P.ink)
                W.bar(x+10,129,176,7,r.trust,10,P.teal)
                self:text("Química "..r.chemistry.." / 10",x+10,150,176,P.ink)
                W.bar(x+10,166,176,7,r.chemistry,10,P.rose)
                self:text("Reencuentro: "..(r.events.reunion and "sí" or "pendiente").."\nSello: "..(r.events.memory_seal and "compartido" or "pendiente"),x+10,187,176,P.ink)
                local states={unmet="sin conocer",friend="amistad",chosen="elegida",romance="romance",friendship="amistad",active="en curso",locked="sin elegir"}
                self:text("Vínculo: "..(states[r.routeState] or "sin elegir"),x+10,232,176,P.muted)
            end
            W.panel(18,275,604,67)
            local companion=app.session.decisions.companion
            self:text("Día "..app.session.day.." · Sello de la Memoria: "..(app.session.events.seal_memory and "recuperado" or "pendiente"),30,287,578,P.gold)
            self:text("Compañía: "..(companion and Characters.byId[companion].shortName or "por elegir")..". Romance: requiere eventos de ruta y una confesión expresa.",30,305,578,P.ink)
            self:text("Los puntos por sí solos no desbloquean una relación romántica.",30,328,578,P.muted)
        elseif kind=="deck" then
            self:header("MAZO / COLECCIÓN DE CARTAS",true)
            W.panel(18,49,306,293)
            self:text("10 CARTAS EQUIPADAS",30,60,282,P.gold)
            local equipped={}
            for _,id in ipairs(app.session.deck) do equipped[id]=true end
            for i,card in ipairs(Data.list) do
                local unlocked=app.session.unlocked[card.id]
                local label=(equipped[card.id] and "* " or (unlocked and "+ " or "- "))..card.name
                self:button(label,27,79+(i-1)*16,288,15,function() self.selected=i end,false,self.selected==i)
            end
            W.panel(336,49,286,293)
            local card=Data.list[self.selected]
            app.resources:icon(card.icon,354,66,2)
            self:text(card.name,414,70,194,P.gold)
            self:text("Coste "..card.cost.."\n"..Data.categories[card.category],414,100,194,P.teal)
            self:text(card.description,352,139,254,P.ink)
            self:text(app.session.unlocked[card.id] and (equipped[card.id] and "EN EL MAZO" or "DESBLOQUEADA") or "BLOQUEADA · CAPÍTULOS FUTUROS",352,202,254,P.gold)
            self:text("* Equipada   + Desbloqueada   - Bloqueada\n\nEl editor de mazo llegará en la Fase 2. Aquí puedes revisar las 16 cartas y sus costes.",352,235,254,P.muted)
        end
    end
    function s:keypressed(key)
        if Controls.matches(Controls.back,key) then app:resume() end
    end
    return s
end
return Overlays
