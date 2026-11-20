function love.conf(t)
    t.identity = "cartas_del_destino"
    t.version = "11.5"
    t.console = false
    t.window.title = "Mushoku Tensei: Las Cartas del Destino"
    t.window.width, t.window.height = 1280, 720
    t.window.minwidth, t.window.minheight = 640, 360
    t.window.resizable = true
    t.window.vsync = 1
    t.modules.physics = false
    t.modules.joystick = false
end
