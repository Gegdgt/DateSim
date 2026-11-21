local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Characters=require("src.data.characters")
local Catalog=require("src.data.activities")
local Font=require("src.ui.font")
local Report={}
function Report.new(app,report,back)
    local s=Screen.new(app)
    s.kind="day_report"; s.page=1
    report=report or {day=app.session.day,changes={},visits={},before={},after={},interactions_used=0,unused=3}
    local pages={{}}
    local used=0
    local function entry(text)
        local height=Font.height(text,576)+8
        if used+height>108 and #pages[#pages]>0 then pages[#pages+1]={}; used=0 end
        pages[#pages][#pages[#pages]+1]={text=text,y=180+used}
        used=used+height
    end
    if #(report.rewards or {})>0 then
        local names={}
        for _,id in ipairs(report.rewards) do
            local card=require("src.data.cards").byId[id] or require("src.data.combat_cards").byId[id]
            names[#names+1]=card and card.name or id
        end
        entry("Cartas recibidas: "..table.concat(names,", ")..".")
    end
    for _,change in ipairs(report.changes or {}) do entry(change.text) end
    s.bars={}
    for _,id in ipairs(Characters.romanceIds)do
        local old=(report.before or {})[id] or app.session.relationships[id]
        local after=(report.after or {})[id] or app.session.relationships[id]
        local bars=require("src.ui.relationship_bars").new({relationships={[id]=old},events={}},id,{reducedMotion=app.options.reducedMotion})
        bars:apply("daily_report",{relationships={[id]=after}});s.bars[id]=bars
    end
    function s:update(dt)for _,b in pairs(self.bars)do b:update(dt)end end
    function s:draw()
        self:begin()
        app.resources:background("home")
        W.panel(18,12,604,336)
        self:text("RESUMEN / DÍA "..report.day,32,25,576,P.gold,2)
        self:text("Interacciones: "..report.interactions_used.."/3 · Sin usar: "..report.unused.." · Encargo: "..(report.favor and Catalog.favorsById[report.favor.id].character or "ninguno"),32,55,576,P.teal)
        for i,id in ipairs(Characters.romanceIds) do
            local before=(report.before or {})[id] or app.session.relationships[id]
            local after=(report.after or {})[id] or app.session.relationships[id]
            local state=({married="casados",strained="en tensión",separated="separados"})[after.marriageState] or after.marriageState
            local x=32+(i-1)*193
            self.bars[id]:draw({x=x,y=121,w=184,h=1})
            self:text("Visitas "..(report.visits[id] or 0).." · "..state,x,124,184,P.ink)
            self:text("Día: "..string.format("%+d amor / %+d conf.",after.love-before.love,after.trust-before.trust),x,140,184,P.teal)
        end
        self:text("DECISIONES Y RECOMPENSAS · "..self.page.."/"..#pages,32,164,576,P.gold)
        for _,item in ipairs(pages[self.page]) do self:text(item.text,32,item.y,576,P.ink) end
        self:button("Anterior",32,298,120,29,function() self.page=self.page-1 end,self.page==1)
        self:button("Siguiente",160,298,120,29,function() self.page=self.page+1 end,self.page==#pages)
        self:button(back and "Volver a la agenda" or (report.day==7 and "Ver epílogo" or "Comenzar día "..(report.day+1)),300,298,308,29,function()
            if back then back() else app:next() end
        end)
    end
    return s
end
return Report
