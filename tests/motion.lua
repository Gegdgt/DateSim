local Suite={}
function Suite.run()
    local Animation=require("src.systems.animation")
    local Typewriter=require("src.systems.typewriter")
    local Manager=require("src.core.state_manager")
    local Save=require("src.systems.save")
    local DialogueScreen=require("src.screens.dialogue")
    local utf8=require("utf8")
    local checks=0
    local function check(ok,message) assert(ok,message); checks=checks+1 end
    local function near(a,b) return math.abs(a-b)<.000001 end

    local calls=0
    local tween=Animation.tween({x=3,y=20},{x=100,y=4},.4,{easing="linear",onComplete=function() calls=calls+1 end})
    tween:update(.2)
    check(near(tween.value.x,51.5) and near(tween.value.y,12),"Tween interpola ambas coordenadas")
    check(not tween.done and calls==0,"Tween no termina antes de tiempo")
    tween:update(10)
    check(tween.done and tween.value.x==100 and tween.value.y==4,"Tween termina con valores exactos tras dt grande")
    tween:update(10); tween:finish()
    check(calls==1,"Callback de animación ocurre una sola vez")
    local reduced=Animation.tween({x=0},{x=8},.4,{reducedMotion=true})
    reduced:update(0)
    check(reduced.done and reduced.value.x==8,"Movimiento reducido omite desplazamiento de cartas")
    for name in pairs(Animation.actorNames) do
        local actor=Animation.actor(name)
        actor:update(.1)
        check(actor.value.alpha>=0 and actor.value.alpha<=1,"Alfa de personaje acotada: "..name)
        actor:update(10)
        check(actor.done,"Animación de personaje finita: "..name)
        local x,y,alpha=actor.value.x,actor.value.y,actor.value.alpha
        actor:update(.1)
        check(x==actor.value.x and y==actor.value.y and alpha==actor.value.alpha,"Personaje quieto tras terminar: "..name)
        local still=Animation.actor(name,{reducedMotion=true})
        check(still.done and still.value.x==0 and still.value.y==0,"Personaje sin movimiento por accesibilidad: "..name)
    end

    local text="¡Sí, Rudy! Química, corazón, pingüino y ñ."
    local writer=Typewriter.new(text,{textSpeed=10})
    for i=0,utf8.len(text) do
        local slice=Typewriter.slice(text,i)
        check(utf8.len(slice)==i,"El texto progresivo no corta un punto UTF-8: "..i)
        check(text:sub(1,#slice)==slice,"El fragmento preserva tildes: "..i)
    end
    writer:update(.35)
    check(writer.visible==3 and writer:shown()=="¡Sí","Velocidad configurable cuenta caracteres")
    writer:showAll()
    check(writer:isComplete() and writer:shown()==text,"Primera pulsación puede revelar toda la línea")
    writer:update(0)
    check(writer:shown()==text,"Revelar no se revierte en la siguiente actualización")
    writer:setText("Otra línea",{textAnimation=false,textSpeed=1})
    check(writer:isComplete() and writer:shown()=="Otra línea","Texto sin animación disponible desde el inicio")

    local app={options={}}
    local manager=Manager.new(app)
    local entered,presses,updates=0,0,0
    local first={enter=function() entered=entered+1 end,keypressed=function() presses=presses+1 end,
        mousepressed=function() presses=presses+1 end,update=function(_,dt) updates=updates+dt end}
    local second={enter=function() entered=entered+1 end}
    check(manager:switch(first,{type="fade",duration=.4}),"Solicitar transición acepta escena inicial")
    check(manager.current==first and entered==1,"Escena activa exactamente una vez")
    check(not manager:switch(second),"No permite transiciones simultáneas")
    manager:keypressed("return"); manager:mousepressed(1,1,1)
    check(presses==0,"Entrada bloqueada durante transición")
    manager:update(.2)
    check(updates==0,"No consume texto mientras se oculta por el fundido")
    manager:update(.3)
    check(manager.transition==0 and near(updates,.1),"Transición finaliza y entrega el tiempo restante")
    manager:keypressed("return"); manager:mousepressed(1,1,1)
    check(presses==2 and entered==1,"Entrada restaurada sin reactivar escena")
    for kind in pairs(Manager.transitionTypes) do
        check(manager:switch({enter=function() entered=entered+1 end},{type=kind,duration=.3}),"Transición declarativa: "..kind)
        manager:update(1)
        check(manager.transition==0,"Transición declarativa finita: "..kind)
    end
    app.options.reducedMotion=true
    manager:switch(second,{type="horizontal",duration=.6})
    check(manager.effect.type=="fade" and manager.duration<=.15,"Movimiento reducido reemplaza barrido por fundido corto")
    manager:finishTransition()
    check(not manager:switch(second),"No reactiva la misma instancia de escena")

    local saved,advanced=0,0
    local dialogApp={session=Save.newSession(),options={textSpeed=20,textAnimation=true},
        save=function() saved=saved+1 end,next=function() advanced=advanced+1 end}
    local screen=DialogueScreen.new(dialogApp)
    screen:advance()
    check(screen.dialogue.index==1 and screen:ready(),"Primera pulsación solo revela texto")
    screen:advance()
    check(screen.dialogue.index==2 and not screen:ready() and saved==1,"Segunda pulsación avanza una sola línea")
    local pose=screen.actor.value
    check(pose.alpha==1 and screen.actor.kind=="sad_lower","Rudy ya está en escena y reacciona con preocupación")
    screen:update(1)
    check(screen.actor.done and screen.actor.value.alpha==1,"Entrada de personaje termina")
    screen.dialogue.index=#screen.scene.lines
    screen.writer=Typewriter.new(screen:fullText(),{textAnimation=false})
    screen.visible=screen.writer.length
    screen:advance(); screen:advance()
    check(screen.leaving and advanced==0,"Salida del personaje bloquea la doble pulsación")
    screen:update(.2); screen:update(.2)
    check(advanced==1,"Salida activa el siguiente checkpoint una sola vez")
    print("Motion: "..checks.." checks passed (finite animation, UTF-8, transitions and reduced motion).")
    return checks
end
return Suite
