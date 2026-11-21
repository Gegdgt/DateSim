local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Save=require("src.systems.save")
local Chapters=require("src.data.chapters")
local Menu={}
function Menu.new(app)
    local s=Screen.new(app)
    s.confirm=false
    s.hasSave=Save.exists()
    s.legacy=Save.legacyInfo()
    function s:draw()
        self:begin()
        app.resources:background("courtyard")
        love.graphics.setColor(.035,.045,.09,.48)
        love.graphics.rectangle("fill",0,0,640,360)
        W.panel(26,16,364,329)
        self:text("UNA HISTORIA ALTERNATIVA",44,42,330,P.teal)
        self:text("MUSHOKU TENSEI",44,65,330,P.gold,2)
        self:text("LAS CARTAS\nDEL DESTINO",44,94,330,P.ink,2)
        self:text("Siete días. Una voz sellada.\nUna familia que necesita escucharte.",44,146,310,P.muted)
        if self.legacyConfirm then
            self:text("Nueva campaña con agenda diaria.\nSe reinicia la historia y se conserva\nla colección compatible. El original queda\nintacto; se crea campaign-v4.json.",44,186,310,P.gold)
            self:button("Aceptar e importar",44,250,310,25,function() app:newGame(true) end)
            self:button("Cancelar",44,282,310,25,function() self.legacyConfirm=false end)
        elseif self.confirm then
            self:text("Nueva partida reemplazará el guardado.\n¿Comenzar de nuevo?",44,195,320,P.gold)
            self:button("Comenzar",44,239,150,28,function() app:newGame() end)
            self:button("Cancelar",205,239,150,28,function() self.confirm=false end)
        else
            self:button("Nueva partida",44,184,310,24,function()
                if self.hasSave then self.confirm=true else app:newGame() end
            end)
            self:button("Continuar",44,212,310,24,function() app:continueGame() end,not self.hasSave)
            self:button("Práctica: social y combate",44,240,310,24,function() app:startPractice() end)
            self:button("Manual del aventurero",44,268,310,24,function() app:manual() end)
            self:button("Opciones",44,296,150,24,function() app:overlay("options") end)
            self:button("Salir",204,296,150,24,function() love.event.quit() end)
        end
        self:text("HISTORIA DISPONIBLE / DÍAS 1 A "..Chapters.last.day,44,330,320,P.muted)
        app.resources:portrait("sylphiette","happy",417,131,1)
        app.resources:portrait("roxy","neutral",523,131,1)
        app.resources:portrait("eris","neutral",476,217,1)
        self:button("Combate libre",414,293,186,25,function() app:startPractice("free") end)
        if self.legacy and not self.hasSave and not self.legacyConfirm then
            self:button("Importar campaña anterior",403,258,222,26,function() self.legacyConfirm=true end)
        end
        self:text("FAN GAME · PERSONAJES ADULTOS",400,333,229,P.ink)
    end
    return s
end
return Menu
