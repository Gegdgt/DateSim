local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Save=require("src.systems.save")
local Menu={}
function Menu.new(app)
    local s=Screen.new(app)
    s.confirm=false
    s.hasSave=Save.exists()
    function s:draw()
        self:begin()
        app.resources:background("courtyard")
        love.graphics.setColor(.035,.045,.09,.48)
        love.graphics.rectangle("fill",0,0,640,360)
        W.panel(26,24,364,302)
        self:text("UNA HISTORIA ALTERNATIVA",44,42,330,P.teal)
        self:text("MUSHOKU TENSEI",44,65,330,P.gold,2)
        self:text("LAS CARTAS\nDEL DESTINO",44,94,330,P.ink,2)
        self:text("Siete días. Un espejo roto.\nUn futuro que se construye contigo.",44,146,310,P.muted)
        if self.confirm then
            self:text("Nueva partida reemplazará el guardado.\n¿Comenzar de nuevo?",44,195,320,P.gold)
            self:button("Comenzar",44,239,150,28,function() app:newGame() end)
            self:button("Cancelar",205,239,150,28,function() self.confirm=false end)
        else
            self:button("Nueva partida",44,190,310,27,function()
                if self.hasSave then self.confirm=true else app:newGame() end
            end)
            self:button("Continuar",44,223,310,27,function() app:continueGame() end,not self.hasSave)
            self:button("Opciones",44,256,150,27,function() app:overlay("options") end)
            self:button("Salir",204,256,150,27,function() love.event.quit() end)
        end
        self:text("FASE 1  /  DÍAS 1 Y 2",44,303,320,P.muted)
        app.resources:portrait("sylphiette","happy",417,131,1)
        app.resources:portrait("roxy","neutral",523,131,1)
        app.resources:portrait("eris","neutral",476,217,1)
        self:text("FAN GAME · PERSONAJES ADULTOS",400,333,229,P.ink)
    end
    return s
end
return Menu
