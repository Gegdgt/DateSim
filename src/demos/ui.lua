local App=require("src.app")
local Save=require("src.systems.save")
local Prologue=require("src.systems.prologue")
local Exploration=require("src.systems.exploration")
local Events=require("src.systems.events")
local Maps=require("src.data.maps")
local Activities=require("src.screens.wife_activities")
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")

local Demo={}

local function hud(app)
    local session=Prologue.start(Save.newSession())
    Prologue.wake(session)
    session.prologue.wake_departed=true
    Exploration.enter(session.exploration,"patio_eris",Maps.patio_eris.initialPosition)
    app.session=session
    app:explore()
end

local function conversation(app)
    local session=Save.newSession()
    Events.apply(session,"starter_gift",{starter=true,presenter="nanahoshi"})
    Events.mark(session,"first_anomaly")
    session.rewardQueue={}
    session.checkpoint="day1_agenda"
    app.session=session
    app.audio:setContext("home")
    app:switch(Activities.new(app,"sylphiette"))
end

local function menu(app)
    app.session,app.worldScreen,app.presentedNode=nil,nil,nil
    app.toastTime=0
    local screen=Screen.new(app)
    screen.kind="demo_ui"
    function screen:draw()
        self:begin()
        app.resources:background("courtyard")
        W.panel(65,24,510,312)
        self:text("SISTEMAS DE INTERFAZ",87,45,466,P.gold,2)
        self:text("Cada ejercicio empieza con una sesión temporal.",87,74,466,P.ink)
        self:button("HUD de exploración · Patio de Eris",87,105,466,32,function() hud(app) end)
        self:button("Conversación con cartas · Sylphie",87,143,466,32,function() conversation(app) end)
        self:button("Combate libre · Anomalía",87,181,466,32,function() app:startPractice("free") end)
        self:button("Tutorial social · Nanahoshi",87,232,466,26,function() app:startPractice() end)
        self:button("Salir",87,264,466,26,function() love.event.quit() end)
        self:text("Tab / Enter o clic · F9 vuelve a este menú desde cualquier escena.",87,309,466,P.muted)
    end
    app:switch(screen)
end

function Demo.new()
    love.filesystem.setIdentity("cartas_del_destino_demo_ui")
    love.window.setTitle("Las Cartas del Destino · Sistemas de interfaz")
    return App.new(menu)
end

return Demo
