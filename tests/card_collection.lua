-- Native-size typography and the real collection screen, without app saves.
local Suite={}
function Suite.run()
    local Collection=require("src.screens.collection")
    local Data=require("src.data.cards")
    local Font=require("src.ui.font")
    local Card=require("src.ui.card")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local checks=0
    local function check(value,message) assert(value,message); checks=checks+1 end
    local session=Save.newSession({love=65,trust=65})
    session.unlocked.self_joke,session.unlocked.remember=true,true
    local before=assert(Json.encode(session))
    local groups=Collection.groups(session)
    check(#groups.equipped==10 and #groups.available==2 and #groups.locked==4,"Collection groups the fixed deck, earned cards and future cards")
    local seen={}
    for _,state in ipairs({"equipped","available","locked"}) do
        for _,entry in ipairs(groups[state]) do
            check(not seen[entry.card.id],"A card appears in exactly one collection group")
            seen[entry.card.id]=true
        end
    end
    for _,card in ipairs(Data.list) do
        check(seen[card.id],"Every card remains accessible in the collection")
        check(Font.width(card.shortName)<=Card.regions.name.w,"Native-size short label fits in one line: "..card.id)
        check(Font.height(card.shortName,Card.regions.name.w)==11,"Short card name never shrinks or wraps: "..card.id)
        check(Card.labels(card).name==card.shortName,"The card face uses its declared visual label")
        local details=Collection.details(card,session)
        check(details.name==card.name,"Details retain the full logical card name")
        check(details.category==Data.categories[card.category] and details.cost=="Energía: "..card.cost,"Details show canonical category and cost")
        check(type(details.unlock)=="string" and #details.unlock>0 and not details.unlock:find("Capítulos futuros",1,true),"Every unlock has a specific known requirement")
        check(Font.height(details.description,275)<=33,"Full description fits in the detail panel")
        check(Font.height(details.base,275)<=22,"Base effect values fit in the detail panel")
        check(Font.height("OBTENCIÓN: "..details.unlock,275)<=22,"Unlock method fits in the detail panel")
        check(Font.height(details.affinity,183)<=33 and Font.height(details.contexts,275)<=22,"Affinity and recommended contexts fit")
    end
    local returns,sounds=0,0
    local app={session=session,resources=require("src.systems.resources").new():preload(),
        mouse=function() return nil,nil end,
        resume=function() returns=returns+1 end,
        audio={effect=function(_,name) if name=="card_select" then sounds=sounds+1 end end}}
    local screen=Collection.new(app)
    local originalFontDraw=Font.draw
    local ok,err=xpcall(function()
        -- Actual text calls must stay within their assigned rows at the 640x360
        -- logical resolution. Integer window scaling preserves the same bounds.
        local heights={[56]=11,[79]=22,[107]=11,[132]=11,[155]=33,[198]=33,[234]=22,[261]=11,[274]=22,[299]=22,[328]=11,[347]=11}
        for index,card in ipairs(Data.list) do
            screen.selected=index
            local fullName,cost,unlock=false,false,false
            Font.draw=function(text,x,y,opts)
                local allowed=heights[y]
                if x>=337 and allowed then
                    check(Font.height(text,opts.maxWidth,opts.scale)<=allowed,"Rendered detail text fits its reserved row: "..card.id)
                    check(x+opts.maxWidth<=626 and y+allowed<=342,"Rendered detail text stays inside its panel")
                end
                fullName=fullName or text==card.name
                cost=cost or text=="Energía: "..card.cost
                unlock=unlock or text=="OBTENCIÓN: "..card.unlockHint
                return originalFontDraw(text,x,y,opts)
            end
            screen:draw()
            check(fullName and cost and unlock,"Rendered full name, cost and unlock requirement: "..card.id)
        end
        Font.draw=originalFontDraw
        screen:draw()
        for index=1,#Data.list do
            local row
            for _,button in ipairs(screen.buttons) do if button.cardIndex==index then row=button end end
            check(row~=nil and row.y+row.h<=342,"Every collection row has a visible mouse hitbox")
            screen:mousepressed(row.x+4,row.y+4,1)
            check(screen.selected==index,"Mouse can inspect every card, including locked cards")
        end
        local initial=screen.selected
        local visited={}
        for _=1,#Data.list do screen:keypressed("right"); visited[screen.selected]=true end
        check(screen.selected==initial,"Keyboard inspection wraps through the collection")
        for i=1,#Data.list do check(visited[i],"Keyboard reaches every card") end
        screen.keyboardFocus=nil
        screen:keypressed("tab"); screen:keypressed("down"); screen:keypressed("down"); screen:keypressed("return")
        check(screen.selected==2,"Tab/Enter activate the visible list row")
        screen:keypressed("escape")
        check(returns==1 and sounds>0,"Back returns once and selection produces sound")
        check(Json.encode(session)==before,"Inspecting the collection never edits the deck, unlocks or narrative")
    end,debug.traceback)
    Font.draw=originalFontDraw
    assert(ok,err)
    print("Collection: "..checks.." checks passed (16 readable faces, complete details, grouped states and input).")
    return checks
end
return Suite
