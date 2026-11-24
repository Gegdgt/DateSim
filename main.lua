local App = require("src.app")
local app

function love.load(args)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    love.keyboard.setKeyRepeat(false)
    love.math.setRandomSeed(os.time())
    for _, value in ipairs(args or {}) do
        if value == "--demo-ui" then
            app = require("src.demos.ui").new()
            return app
        end
        if value == "--qa-campaign" then
            app=require("tests.manual_campaign").new(17)
            return
        end
        if value == "--qa-dialogue" then
            app=require("tests.manual_review").new()
            return
        end
        if value == "--test" then
            local ok, err = xpcall(function() require("tests.run")() end, debug.traceback)
            print(ok and "ALL TESTS PASSED" or err)
            love.event.quit(ok and 0 or 1)
            return
        end
    end
    app = App.new()
end

function love.update(dt) if app then app:update(math.min(dt, 0.1)) end end
function love.draw() if app then app:draw() end end
function love.mousepressed(x,y,button)
    if app and app.qaNext and button==2 then app:qaNext(); return end
    if app then app:mousepressed(x,y,button) end
end
function love.keypressed(key,scancode,isrepeat)
    if app and app.qaCapture and key=="f8" and not isrepeat then app:qaCapture();return end
    if app and app.qaNext and key=="f6" and not isrepeat then app:qaNext(); return end
    if app and not isrepeat then app:keypressed(key) end
end
function love.resize() if app then app:resize() end end
function love.wheelmoved(x,y) if app and app.wheelmoved then app:wheelmoved(x,y) end end
function love.quit() if app then app:save() end end
