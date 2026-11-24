local App=require("src.app")
local Save=require("src.systems.save")
local Prologue=require("src.systems.prologue")
local Events=require("src.systems.events")
local Daily=require("src.systems.daily")
local Objectives=require("src.systems.objectives")
local Exploration=require("src.systems.exploration")
local Activities=require("src.systems.wife_activities")
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")

local Demo={}

local exercises={
    {id="S02",name="Sylphie",map="casa_planta_baja",arrival={x=196,y=192,facing="up"}},
    {id="E06",name="Eris",map="patio_eris",arrival={x=336,y=216,facing="right"}},
}

local function newSession()
    local session=Prologue.start(Save.newSession())
    Prologue.wake(session)
    -- Punto de partida del ejercicio: el primer tiempo libre, con sus mazos iniciales.
    local prologue=session.prologue
    prologue.wake_departed=true
    prologue.letter_found,prologue.letter_collected,prologue.letter_read=true,true,true
    prologue.hitogami_identified,prologue.curse_discovered=true,true
    prologue.nanahoshi_visited,prologue.starting_cards_received=true,true
    session.inventory.hitogami_letter=true
    Events.apply(session,"hitogami_letter_read",{clue="hitogami_letter",discoverVoice=true,discoverMana=true})
    Events.mark(session,"nanahoshi_conversation_started")
    Events.apply(session,"starter_gift",{starter=true,presenter="nanahoshi"})
    Events.mark(session,"tutorial_completed")
    Events.mark(session,"combat_tutorial_completed")
    Events.mark(session,"first_anomaly")
    session.rewardQueue={}
    session.checkpoint=Daily.config(session).agenda
    Objectives.sync(session,true)
    while Objectives.popNotice(session) do
        -- Los avisos del prólogo ya están representados en el estado inicial.
    end
    return session
end

local function start(app,exercise)
    local session=app.session
    Exploration.enter(session.exploration,exercise.map,exercise.arrival)
    Exploration.syncPresence(session)
    local active,err=Activities.start(session,exercise.id,session.economy.revision)
    if not active then app:notify(err);return end
    app.audio:setContext(require("src.data.maps")[exercise.map].music)
    app:save()
    app:resume()
end

local function restart(app)
    local previous=app.session
    app.session=newSession()
    if app:save() then app:menu() else app.session=previous end
end

local function menu(app)
    if not app.session then
        local session,notice=Save.load()
        app.session=session or newSession()
        if session and notice then app:notify(notice) end
    end
    local session=app.session
    local busy=Activities.current(session) or (session.wifeActivities and session.wifeActivities.review)
        or #session.rewardQueue>0 or #session.family.queue>0
    local screen=Screen.new(app)
    screen.kind="demo_progression"
    function screen:draw()
        self:begin()
        app.resources:background("home")
        W.panel(43,18,554,325)
        self:text("CICLO DE PROGRESIÓN",61,35,518,P.gold,2)
        self:text(string.format("Día %d · %d/3 interacciones disponibles · %d oro",
            session.day,Daily.remaining(session),session.gold),61,67,518,P.ink)
        for i,exercise in ipairs(exercises) do
            local definition=Activities.bank.byId[exercise.id]
            local relation=session.relationships[definition.character]
            local y=97+(i-1)*49
            self:button(exercise.name.." · "..definition.title,61,y,318,33,function() start(app,exercise) end,
                busy or not Activities.available(session,exercise.id))
            self:text("Amor "..relation.love.." · Confianza "..relation.trust,390,y+12,188,P.teal)
        end
        if busy then
            self:button("Continuar actividad o recompensa",61,199,518,32,function() app:resume() end)
        else
            self:button("Colección y mejoras",61,199,518,32,function() app:overlay("deck") end)
        end
        self:button("Reiniciar recorrido",61,244,318,31,function() restart(app) end)
        self:button("Salir",390,244,189,31,function() love.event.quit() end)
        self:text("Completa las dos actividades y compara sus resultados.\nF9 abre este menú. F5 guarda en el perfil académico.",61,294,518,P.muted)
    end
    app:switch(screen)
end

function Demo.new()
    love.filesystem.setIdentity("cartas_del_destino_demo_progresion")
    love.window.setTitle("Las Cartas del Destino · Ciclo de progresión")
    return App.new(menu)
end

return Demo
