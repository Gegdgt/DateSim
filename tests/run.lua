-- Active marriage-continuity suite; previous fixtures remain in legacy_run_v1.lua.
return function()
    io.stdout:setvbuf("no")
    local group=os.getenv("DATESIM_TEST_GROUP")
    local module=os.getenv("DATESIM_TEST_MODULE")
    if module then assert(module:match("^[a-z_]+$"));love.filesystem.setIdentity("cartas_del_destino_v7_tests_"..module);require("tests."..module).run();return end
    love.filesystem.setIdentity("cartas_del_destino_v7_tests"..(group and ("_"..group:gsub("[^%w]","_")) or ""))
    if group=="war" or group=="war-ui" then require("tests.war").run();require("tests.war_balance").run();if group=="war-ui" then require("tests.war_ui").run() end;return end
    if group=="family" or group=="family-ui" then require("tests.family").run();if group=="family-ui" then require("tests.family_ui").run() end;return end
    if group=="economy" or group=="economy-ui" then require("tests.economy").run();if group=="economy-ui" then require("tests.economy_ui").run() end; return
    elseif group=="narrative" then require("tests.curse_social").run();require("tests.dialogue_branching").run();require("tests.dialogue_visual").run();return
    elseif group=="combat-core" then require("tests.combat").run();require("tests.combat_balance").run();require("tests.training").run();return
    elseif group=="daily" or group=="daily-ui" then
        require("tests.daily").run()
        if group=="daily-ui" then require("tests.daily_ui").run() end
        return
    elseif group=="campaign" or group=="economy-campaign" then
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
    require("tests.economy").run()
    require("tests.economy_ui").run()
    require("tests.family").run()
    require("tests.family_ui").run()
    require("tests.daily").run()
    require("tests.daily_ui").run()
    require("tests.combat").run()
    require("tests.combat_balance").run()
    require("tests.training").run()
    require("tests.war").run()
    require("tests.war_balance").run()
    require("tests.war_ui").run()
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
