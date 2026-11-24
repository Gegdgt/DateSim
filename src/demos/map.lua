local App=require("src.app")
local Save=require("src.systems.save")
local Prologue=require("src.systems.prologue")
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")

local Demo={}

local function start(app)
    app.session=Prologue.start(Save.newSession())
    Prologue.wake(app.session)
    app:explore()
end

local function menu(app)
    app.toastTime=0
    local screen=Screen.new(app)
    screen.kind="demo_map"
    function screen:draw()
        self:begin()
        app.resources:background("courtyard")
        W.panel(64,22,512,316)
        self:text("MAPAS Y EXPLORACIÓN",86,43,468,P.gold,2)
        self:text("Visita el estudio, el patio de Eris y la biblioteca de Ranoa.",86,73,468,P.ink)
        self:button("Empezar desde el dormitorio de Eris",86,101,468,30,function() start(app) end)
        self:button("Continuar explorando",86,138,468,30,function() app:explore() end,not app.session)
        self:button("Salir",86,175,468,26,function() love.event.quit() end)
        self:text("Dormitorio → segundo piso → estudio (cuarta puerta).\nEscaleras → planta baja → jardín → patio (salida oeste).\nJardín → Sharia (sur) → parada T (este) → biblioteca.",86,221,468,P.ink)
        self:text("WASD o flechas · Shift corre · M muestra el minimapa.\nE examina o abre el traslado · Enter confirma · F9 abre este menú.",86,289,468,P.muted)
    end
    app:switch(screen)
end

function Demo.new()
    love.filesystem.setIdentity("cartas_del_destino_demo_mapa")
    love.window.setTitle("Las Cartas del Destino · Sistema de mapas")
    return App.new(menu)
end

return Demo
