local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Characters=require("src.data.characters")
local History={}
local labels={daily_commitment="compromiso diario",broken_trust="confianza dañada",mirror_doubt="dudas ante el espejo",
    pending="pendiente",kept="cumplida",broken="incumplida",reconciled="reconciliada",
    first_anomaly="Primera anomalía contenida",starter_gift="Nanahoshi entrega los mazos iniciales",
    seal_memory="Sello de la Memoria obtenido",seal_truth="Sello de la Verdad obtenido",seal_will="Sello de la Voluntad obtenido"}
local function label(id) return labels[id] or tostring(id):gsub("_"," ") end
function History.lines(session)
    local lines={}
    for _,e in ipairs(session.history or session.journal or {}) do
        local char=Characters.byId[e.character]
        local delta=e.changes or e.delta or e
        local description=e.text or e.label
        if not description or description==e.id then
            local node=require("src.data.chapters").get(e.checkpoint)
            description=labels[e.id] or (node and node.definition.title) or "Acontecimiento registrado"
        end
        local text="Día "..tostring(e.day or "?").." · "..(char and char.shortName..": " or "")..description
        if (delta.love or 0)~=0 or (delta.trust or 0)~=0 then text=text.." (amor "..tostring(delta.love or 0)..", confianza "..tostring(delta.trust or 0)..")" end
        lines[#lines+1]=text
    end
    for _,id in ipairs(Characters.romanceIds) do
        local r=session.relationships[id]
        local function append(map,prefix)
            local keys={} for key in pairs(map or {}) do keys[#keys+1]=key end; table.sort(keys)
            for _,key in ipairs(keys) do local v=map[key]
                local status=type(v)=="table" and (v.status or "registrado") or v==true and "registrado" or v
                lines[#lines+1]=Characters.byId[id].shortName.." · "..prefix.." "..label(key)..": "..label(status)
            end
        end
        append(r.promises,"promesa"); append(r.pendingConflicts,"conflicto"); append(r.reconciliations,"reconciliación")
    end
    if #lines==0 then lines[1]="Todavía no has tomado decisiones. Los acontecimientos importantes se anotarán aquí." end
    return lines
end
function History.new(app,returnTo)
    local s=Screen.new(app); s.kind="history"; s.page=1; s.lines=History.lines(app.session)
    s.returnTo=returnTo or function() app:resume() end
    function s:draw()
        self:begin(); app.resources:background("library"); W.panel(14,14,612,330)
        self:text("HISTORIAL / DECISIONES Y COMPROMISOS",30,31,572,P.gold)
        for row=1,6 do self:text(self.lines[(self.page-1)*6+row] or "",30,66+(row-1)*36,572,P.ink) end
        local pages=math.max(1,math.ceil(#self.lines/6))
        self:button("< Anterior",30,306,138,24,function() self.page=(self.page-2)%pages+1 end)
        self:text(self.page.." / "..pages,182,314,120,P.gold)
        self:button("Siguiente >",318,306,138,24,function() self.page=self.page%pages+1 end)
        self:button("Volver",470,306,138,24,self.returnTo)
    end
    function s:keypressed(key) if key=="escape" then self.returnTo() else self:navigate(key) end end
    return s
end
return History
