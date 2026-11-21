local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Combat=require("src.systems.combat")
local Data=require("src.data.combat_cards")
local Social=require("src.data.cards")
local Editor={}
local function copy(a) local b={} for i,v in ipairs(a or {}) do b[i]=v end return b end
function Editor.new(app,returnTo)
    local s=Screen.new(app)
    s.kind="combat_deck"; s.draft=copy(app.session.combatDeck); s.slot=1; s.selected=1; s.page=1
    s.catalog={}
    for _,c in ipairs(Data.list) do s.catalog[#s.catalog+1]=c.id end
    for _,c in ipairs(Social.list) do if c.combat then s.catalog[#s.catalog+1]=c.id end end
    s.returnTo=returnTo or function() app:overlay("deck") end
    function s:replace()
        if app.session.encounter or app.session.combat then self.message="Termina el encuentro para cambiar el mazo."; return false end
        local id=self.catalog[self.selected]
        if not app.session.unlocked[id] then self.message="Carta bloqueada. Consulta su obtención."; return false end
        for i,c in ipairs(self.draft) do if c==id and i~=self.slot then self.message="No se permiten duplicados."; return false end end
        self.draft[math.min(self.slot,#self.draft+1)]=id; self.message="Borrador actualizado. Guarda para equiparlo."; return true
    end
    function s:saveDeck()
        if app.session.encounter or app.session.combat then self.message="No puedes editar durante el encuentro."; return false end
        local valid,err=Combat.validateDeck(self.draft,app.session.unlocked)
        if not valid then self.message=err; return false end
        local old=app.session.combatDeck; app.session.combatDeck=copy(self.draft)
        if app:save()==false then app.session.combatDeck=old; self.message="Error al guardar."; return false end
        self.message="Mazo de combate guardado: entre cinco y diez cartas, con ofensiva viable."; return true
    end
    function s:draw()
        self:begin(); app.resources:background("library")
        love.graphics.setColor(.025,.035,.07,.9); love.graphics.rectangle("fill",0,0,640,360)
        self:text("MAZO DE COMBATE · 5–10 CARTAS",18,18,490,P.gold)
        self:button("Volver",548,10,76,24,self.returnTo)
        W.panel(14,43,290,204); W.panel(314,43,312,204)
        self:text("POSICIÓN / QUITAR Y SUSTITUIR",24,53,270,P.teal)
        for i=1,10 do
            local c=Combat.card(self.draft[i]); self:button(i..". "..(c and c.name or "Vacía"),24,70+(i-1)*17,270,16,function() self.slot=i end,false,self.slot==i)
        end
        self:text("COLECCIÓN · [+] LIBRE · [X] BLOQUEADA",324,53,290,P.teal)
        for row=1,8 do
            local index=(self.page-1)*8+row; local id=self.catalog[index]
            if id then local c=Combat.card(id)
                self:button((app.session.unlocked[id] and "[+] " or "[X] ")..c.name,324,70+(row-1)*17,290,16,function() self.selected=index end,false,self.selected==index)
            end
        end
        local pages=math.ceil(#self.catalog/8)
        self:button("<",324,213,38,24,function() self.page=(self.page-2)%pages+1; self.selected=(self.page-1)*8+1 end)
        self:text("Página "..self.page.."/"..pages,373,221,178,P.muted)
        self:button(">",576,213,38,24,function() self.page=self.page%pages+1; self.selected=(self.page-1)*8+1 end)
        local c=Combat.card(self.catalog[self.selected]); local old=Combat.card(self.draft[self.slot])
        self:text(c.name..": "..Combat.describe(c),18,254,604,P.gold)
        self:text("Actual: "..(old and (old.name.." · "..Combat.describe(old)) or "Vacía"),18,276,604,P.muted)
        local original=Data.byId[c.id] or Social.byId[c.id]
        self:text("Obtención: "..(original.unlockHint or "Entrega de Nanahoshi durante el tutorial."),18,298,604,P.teal)
        self:button("Sustituir",14,319,144,24,function() self:replace() end)
        self:button("Quitar",166,319,108,24,function() table.remove(self.draft,self.slot); self.message="Carta retirada: conserva al menos cinco y dos ataques." end)
        self:button("Guardar mazo",282,319,160,24,function() self:saveDeck() end)
        self:button("Cancelar borrador",450,319,176,24,self.returnTo)
        self:text(self.message or "Las exclusivas requieren su compañera; se adaptan con técnicas adquiridas.",14,349,612,P.muted)
    end
    function s:keypressed(key)
        if key=="escape" then self.returnTo() else self:navigate(key) end
    end
    return s
end
return Editor
