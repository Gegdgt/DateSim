local P = require("src.ui.palette")
local Font = require("src.ui.font")
local W = {}
local function rect(color,x,y,w,h)
    love.graphics.setColor(color); love.graphics.rectangle("fill",math.floor(x),math.floor(y),w,h)
end
function W.panel(x,y,w,h,opts)
    opts = opts or {}
    if opts.shadow ~= false then rect(P.shadow,x+3,y+3,w,h) end
    rect(opts.border or P.border,x+1,y,w-2,h)
    rect(opts.border or P.border,x,y+1,w,h-2)
    rect(opts.fill or P.panel,x+1,y+1,w-2,h-2)
    if opts.accent then rect(opts.accent,x+1,y+1,2,h-2) end
end
function W.button(label,x,y,w,h,opts)
    opts = opts or {}
    local active = (opts.hover or opts.selected) and not opts.disabled
    W.panel(x,y,w,h,{border=active and P.gold or P.border,fill=active and P.panelLight or P.panel,shadow=opts.shadow})
    if active then rect(P.gold,x+2,y+2,2,h-4) end
    local scale = opts.scale or 1
    local height = Font.height(label,w-12,scale)
    Font.draw(label,x+6,y+math.floor((h-height)/2),{maxWidth=w-12,align=opts.align or "center",scale=scale,color=opts.disabled and P.border or (active and P.gold or P.ink)})
end
function W.bar(x,y,w,h,value,maximum,color)
    rect(P.shadow,x,y,w,h)
    local ratio = math.max(0,math.min(1,(tonumber(value) or 0)/math.max(1,maximum or 10)))
    local available = w-2
    rect(color or P.teal,x+1,y+1,math.floor(available*ratio),h-2)
    local divisions=math.min(10,maximum or 10)
    for i=1,divisions-1 do rect(P.panel,x+math.floor(available*i/divisions),y+1,1,h-2) end
end
function W.label(text,x,y,opts) return Font.draw(text,x,y,opts) end
function W.divider(x,y,w,color) rect(color or P.border,x,y,w,1) end
return W
