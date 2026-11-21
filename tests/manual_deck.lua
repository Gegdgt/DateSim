local Suite={}
function Suite.run()
    local Collection=require("src.screens.collection")
    local Manual=require("src.screens.manual")
    local Guide=require("src.data.manual")
    local Data=require("src.data.cards")
    local Assets=require("src.data.assets")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Font=require("src.ui.font")
    local checks=0
    local function check(ok,message) assert(ok,message); checks=checks+1 end
    local session=Save.newSession({love=65,trust=65})
    session.unlocked.self_joke=true; session.unlocked.remember=true
    local original=assert(Json.encode(session))
    check(Collection.canEdit(session),"Deck is editable at a safe checkpoint")
    local draft=assert(Collection.replace(session.deck,1,"remember",session.unlocked))
    check(#draft==10 and draft[1]=="remember" and session.deck[1]=="listen","Replacement produces a ten-card draft without changing campaign")
    check(not Collection.replace(draft,2,"remember",session.unlocked),"Duplicate equip is rejected")
    check(not Collection.replace(draft,2,"combined_spell",session.unlocked),"Locked route card is rejected")
    check(not Collection.replace(draft,0,"self_joke",session.unlocked),"Invalid slot is rejected")
    check(not Collection.replace(draft,1.5,"self_joke",session.unlocked),"Fractional slot is rejected")
    check(Collection.validatePlayableDeck(session.deck,session.unlocked),"Starter deck can reach all implemented social goals")
    check(Collection.validatePlayableDeck(draft,session.unlocked),"Earned-card replacement remains socially viable")
    local allUnlocked={}; for _,card in ipairs(Data.list) do allUnlocked[card.id]=true end
    local unsuitable={"listen","encourage","remember","light_joke","change_subject","self_joke","share_fear","earth_barrier","shared_magic","sword_magic"}
    local valid,reason=Collection.validatePlayableDeck(unsuitable,allUnlocked)
    check(not valid and reason:find("Roxy",1,true),"Reject structurally valid deck unable to meet Roxy's goal")
    check(Collection.bestSocialScore(unsuitable,{kind="investigation",character="roxy"})==3,"Maximum respects route requirements and actual investigation bonuses")
    local repaired=assert(Collection.replace(unsuitable,10,"analyze_runes",allUnlocked))
    check(Collection.validatePlayableDeck(repaired,allUnlocked),"Adding an investigation card repairs the otherwise impossible deck")
    local writes,returns=0,0
    local app={session=session,resources=require("src.systems.resources").new():preload(),
        mouse=function() return nil,nil end,audio={effect=function() end},
        save=function() writes=writes+1; return true end,
        resume=function() returns=returns+1 end}
    local screen=Collection.new(app)
    screen:draw(); screen:keypressed("e")
    check(screen.editing,"Keyboard opens real deck editor")
    check(screen:selectSlot(1) and screen:selectCandidate(3),"Choose equipped slot and unlocked replacement")
    check(screen:replaceSelected() and screen.draft[1]=="remember","Replacement updates draft")
    check(Json.encode(session)==original and writes==0,"Draft does not save or modify campaign")
    screen:keypressed("escape")
    check(not screen.editing and session.deck[1]=="listen","Cancel keeps original deck")
    screen:startEditing(); screen:selectCandidate(3); screen:replaceSelected()
    check(screen:saveDeck() and writes==1 and session.deck[1]=="remember","Explicit save applies replacement once")
    check(not screen:saveDeck() and writes==1,"Repeated save activation cannot save twice")
    local validated=assert(Save.validate(session))
    check(validated.deck[1]=="remember" and #validated.deck==10,"Custom deck survives validated save migration")
    screen:startEditing(); screen:selectCandidate(1); screen:replaceSelected()
    app.save=function() return false end
    check(not screen:saveDeck() and session.deck[1]=="remember","Failed storage preserves equipped deck")
    screen:cancelEditing()
    local previousUnlocks=session.unlocked
    session.unlocked=allUnlocked
    screen:startEditing(); screen.draft=unsuitable
    local beforeRefusal=Json.encode(session.deck)
    check(not screen:saveDeck() and Json.encode(session.deck)==beforeRefusal,"Saving an impossible deck preserves the equipped deck")
    check(screen.message:find("Roxy",1,true),"Editor explains which social encounter is not viable")
    screen:cancelEditing(); session.unlocked=previousUnlocks
    session.encounter={finished=false}
    local ok,reason=screen:startEditing()
    check(not ok and reason:find("Termina",1,true),"Social encounter prevents mid-hand deck changes")
    session.encounter=nil; session.combat={finished=false}
    check(not screen:startEditing(),"Combat prevents mid-hand deck changes")
    session.combat=nil
    screen:startEditing(); screen:draw()
    for _,button in ipairs(screen.buttons) do
        check(button.x>=0 and button.y>=0 and button.x+button.w<=640 and button.y+button.h<=360,"Editor buttons are inside the logical canvas")
    end
    local candidate=screen.candidate
    screen:keypressed("right")
    check(screen.candidate~=candidate,"Keyboard reaches replacement cards")
    screen:draw()
    local candidateButton=screen.buttons[12]
    screen:mousepressed(candidateButton.x+2,candidateButton.y+2,1)
    check(screen.candidate==2,"Mouse selects a replacement card without applying it")
    screen:keypressed("escape")
    local manual=Manual.new(app,function() returns=returns+1 end)
    check(#Guide.scenarios==8 and Manual.pageCount(1)==7 and Manual.pageCount(2)==16,"Manual contains seven characters, sixteen cards and eight unique scenarios")
    local seen={}
    for _,scene in ipairs(Guide.scenarios) do
        local path=Assets.backgrounds[scene.id]
        check(path and not seen[path],"Each scenario uses a different existing PNG")
        seen[path]=true
    end
    local savedSession=assert(Json.encode(session))
    local originalDraw=Font.draw
    local success,err=xpcall(function()
        Font.draw=function(text,x,y,opts)
            opts=opts or {}
            check(y+Font.height(text,opts.maxWidth,opts.scale)<=360,"Manual/editor text stays vertically inside the canvas")
            if opts.maxWidth then check(x+opts.maxWidth<=640,"Manual/editor text stays horizontally inside the canvas") end
            return originalDraw(text,x,y,opts)
        end
        for section=1,5 do
            manual:changeSection(section)
            for page=1,Manual.pageCount(section) do
                manual.page=page; manual:draw()
                check(#manual.buttons==8,"All manual pages retain section and page navigation")
            end
        end
        screen:startEditing()
        for i=1,#Data.list do screen:selectCandidate(i); screen:draw() end
        screen:cancelEditing()
    end,debug.traceback)
    Font.draw=originalDraw
    assert(success,err)
    manual:keypressed("2"); check(manual.section==2 and manual.page==1,"Number key opens card catalogue")
    manual:keypressed("left"); check(manual.page==16,"Catalogue navigation wraps")
    manual:keypressed("right"); check(manual.page==1,"Catalogue navigation returns")
    manual:draw()
    local categories=manual.buttons[4]
    manual:mousepressed(categories.x+2,categories.y+2,1)
    check(manual.section==3,"Mouse selects manual categories")
    manual:keypressed("escape")
    check(returns==1 and Json.encode(session)==savedSession,"Manual exits through callback without modifying campaign")
    print("Manual/deck: "..checks.." checks passed (catalogue, editing, persistence, keyboard and mouse).")
    return checks
end
return Suite
