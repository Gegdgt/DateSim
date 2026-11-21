-- Active marriage-continuity suite; previous fixtures remain in legacy_run_v1.lua.
return function()
    io.stdout:setvbuf("no")
    love.filesystem.setIdentity("cartas_del_destino_v4_tests")
    local group=os.getenv("DATESIM_TEST_GROUP")
    if group=="daily" or group=="daily-ui" then
        require("tests.daily").run()
        if group=="daily-ui" then require("tests.daily_ui").run() end
        return
    elseif group=="campaign" then
        require("tests.campaign").run()
        return
    elseif group=="training" or group=="training-ui" then
        require("tests.training").run()
        require("tests.training_integration").run()
        if group=="training-ui" then require("tests.restructure_integration").run() end
        return
    elseif group=="ui" then
        require("tests.restructure_integration").run()
        return
    end
    require("tests.resources").run()
    require("tests.motion").run()
    require("tests.portraits").run()
    require("tests.audio_options").run()
    require("tests.marriages").run()
    require("tests.daily").run()
    require("tests.daily_ui").run()
    require("tests.combat").run()
    require("tests.combat_balance").run()
    require("tests.training").run()
    require("tests.relationship_bars").run()
    require("tests.affinity").run()
    require("tests.training_integration").run()
    require("tests.curse_intro").run()
    require("tests.curse_social").run()
    require("tests.dialogue_branching").run()
    require("tests.dialogue_visual").run()
    require("tests.campaign").run()
    require("tests.restructure_integration").run()
end
