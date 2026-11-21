-- Composición compartida por la mano y la colección. Todas las medidas son
-- píxeles lógicos; el texto se mantiene fuera del icono y del borde del PNG.
local Font = require("src.ui.font")
local P = require("src.ui.palette")
local Card = {width=80,height=112}
local ink = {.17,.14,.21,1}
Card.regions = {
    name={x=8,y=11,w=64,h=11},
    icon={x=28,y=65,w=24,h=24},
    cost={x=10,y=95,w=60,h=11},
}

function Card.labels(card)
    return {name=card.shortName or card.name,cost="Energía "..card.cost}
end

function Card.draw(resources,card,x,y,opts)
    opts=opts or {}
    x,y=math.floor(x),math.floor(y)
    if opts.selected then
        love.graphics.setColor(P.gold)
        love.graphics.rectangle("fill",x-2,y-2,84,116)
    end
    resources:cardBase(x,y,1)
    resources:cardFrame(card.category,x,y,1)
    local labels=Card.labels(card)
    local function label(key)
        local box=Card.regions[key]
        Font.draw(labels[key],x+box.x,y+box.y,{maxWidth=box.w,align="center",color=ink})
    end
    label("name")
    if card.icon and card.icon:match("^procedural") then
        love.graphics.setColor(card.element=="water" and {.2,.6,.9,1} or {.5,.35,.2,1})
        love.graphics.polygon("fill",x+40,y+62,x+50,y+77,x+40,y+88,x+30,y+77)
    else resources:icon(card.icon or card.id,x+Card.regions.icon.x,y+Card.regions.icon.y,1) end
    label("cost")
    if opts.status then
        love.graphics.setColor(P.panel)
        love.graphics.rectangle("fill",x,y+112,80,13)
        Font.draw(opts.status,x,y+114,{maxWidth=80,align="center",color=opts.disabled and P.muted or P.gold})
    end
end

return Card
