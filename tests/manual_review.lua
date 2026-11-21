-- Ventana de revisión reproducible. Solo se activa con --qa-dialogue y usa
-- una identidad separada; F6 cambia a otro estado de prueba independiente.
local Review={}
function Review.new()
    love.filesystem.setIdentity("cartas_del_destino_manual_review")
    local App=require("src.app")
    local Fixtures=require("tests.dialogue_branching")
    local Cards=require("src.systems.cards")
    local Resolver=require("src.systems.dialogue_resolver")
    local Options=require("src.systems.options")
    local Events=require("src.systems.events")
    local cases={
        {"encounter_eris","light_joke"},{"encounter_eris","encourage"},{"encounter_eris","subtle_flirt"},
        {"encounter_roxy","listen"},{"encounter_roxy","light_joke"},{"encounter_roxy","be_honest"},
        {"encounter_sylphiette","encourage"},{"day5_mission_sylphiette","listen","kept"},{"day5_mission_sylphiette","listen","broken"},
        {"encounter_eris",nil,nil,13},{"encounter_eris",nil,nil,29},
        {"encounter_eris",nil,nil,51},{"encounter_eris",nil,nil,83},
        {"day1_tutorial",nil},{"day5_battle_sylphiette",nil},
    }
    local app=App.new(); app.qaCase=0
    app.options=Options.normalize({muted=true,textAnimation=false,reducedMotion=false})
    function app:qaNext()
        self.qaCase=self.qaCase%#cases+1
        local case=cases[self.qaCase]
        local session,def=Fixtures.fixture(case[1])
        if case[3] then
            session.decisions.family_time_outcome=case[3]
            session.events.sylphiette_promised_family_time=true
            session.relationships.sylphiette.promises.family_time=case[3]
        end
        if case[4] then
            session.encounter=Cards.new(session.deck,Resolver.context(session,def),Fixtures.rng(case[4]))
        elseif case[2] then
            for i,id in ipairs(session.deck) do if id==case[2] then table.remove(session.deck,i);break end end
            session.deck[#session.deck+1]=case[2]
            session.encounter=Cards.new(session.deck,Resolver.context(session,def),function(n)return n end)
        else
            Events.apply(session,"qa_fragment",{externalEnergy=20,unlock={"heal","water_projectile","earth_wall"}})
            session.combatDeck={"staff_strike","push","coordinated_attack","heal","earth_wall","water_projectile"}
        end
        session.rewardQueue={}; self.session=session
        self:resume(); self:notify("QA "..self.qaCase.."/"..#cases.." · F6 / clic derecho: siguiente caso")
    end
    app:qaNext()
    return app
end
return Review
