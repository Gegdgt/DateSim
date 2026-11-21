local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Save=require("src.systems.save")
local Options=require("src.systems.options")
local Controls=require("src.config.controls")
local OptionsScreen={}

function OptionsScreen.new(app)
    local s=Screen.new(app)
    s.kind="options"
    app.options=Options.normalize(app.options)
    local function changed()
        app:applyOptions()
        local ok,err=Save.writeOptions(app.options)
        if not ok then app:notify("No se guardaron las opciones: "..tostring(err)) end
        if app.session then app:save() end
    end
    local function volume(key,amount)
        app.options[key]=math.max(0,math.min(1,math.floor((app.options[key]+amount)*100+.5)/100))
        changed()
    end
    function s:draw()
        self:begin()
        app.resources:background("library")
        love.graphics.setColor(.025,.035,.07,.75)
        love.graphics.rectangle("fill",0,0,640,360)
        self:header("OPCIONES / AUDIO Y ACCESIBILIDAD",true)
        W.panel(18,49,300,291)
        W.panel(330,49,292,291)
        self:text("AUDIO",30,60,276,P.gold)
        for i,row in ipairs({{"volume","Volumen maestro"},{"musicVolume","Música"},{"effectsVolume","Efectos"}}) do
            local key,label=row[1],row[2]
            local y=80+(i-1)*55
            self:text(label..": "..math.floor(app.options[key]*100+.5).."%",30,y,276,P.ink)
            self:button("-",30,y+15,32,24,function() volume(key,-.1) end)
            W.bar(74,y+23,180,8,app.options[key],1,P.teal)
            self:button("+",266,y+15,32,24,function() volume(key,.1) end)
        end
        self:button(app.options.muted and "Sonido: silenciado" or "Sonido: activado",30,249,268,27,function()
            app.options.muted=not app.options.muted; changed()
        end)
        self:text("Melodías y efectos originales\nsintetizados por el juego.",30,291,276,P.muted)
        self:text("LECTURA Y MOVIMIENTO",342,60,268,P.gold)
        self:text("Texto: "..math.floor(app.options.textSpeed).." letras / segundo",342,82,268,P.ink)
        self:button("Velocidad: cambiar",342,99,268,27,function()
            local speeds={25,50,75,100}
            local nextSpeed=speeds[1]
            for _,speed in ipairs(speeds) do if speed>app.options.textSpeed then nextSpeed=speed; break end end
            app.options.textSpeed=nextSpeed; changed()
        end)
        self:button("Escritura: "..(app.options.textAnimation and "progresiva" or "instantánea"),342,139,268,27,function()
            app.options.textAnimation=not app.options.textAnimation; changed()
        end)
        self:button("Movimiento reducido: "..(app.options.reducedMotion and "sí" or "no"),342,179,268,27,function()
            app.options.reducedMotion=not app.options.reducedMotion; changed()
        end)
        self:button("Pantalla: "..(app.options.fullscreen and "completa" or "ventana"),342,219,268,27,function()
            app.options.fullscreen=not app.options.fullscreen; changed()
        end)
        self:text("Tab / arriba / abajo: elegir\nEnter: cambiar · Esc: volver\nF11: pantalla completa",342,268,268,P.muted)
        self:text("Los ajustes se guardan al cambiarlos.",342,315,268,P.teal)
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.back,key) then app:resume() end
    end
    return s
end

return OptionsScreen
