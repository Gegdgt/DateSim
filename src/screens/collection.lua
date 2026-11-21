-- Colección y editor: la consulta no altera el mazo; la edición usa un borrador.
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Data=require("src.data.cards")
local Characters=require("src.data.characters")
local CardView=require("src.ui.card")
local Controls=require("src.config.controls")
local Cards=require("src.systems.cards")
local Collection={}
local contextOrder={"conversation","investigation","magic"}
local contextNames={conversation="conversación",investigation="investigación",magic="magia"}
local stateNames={equipped="EQUIPADA",available="SIN EQUIPAR",locked="BLOQUEADA"}
local groupNames={equipped="EQUIPADAS",available="DESBLOQUEADAS SIN EQUIPAR",locked="BLOQUEADAS"}
local stateColors={equipped=P.teal,available=P.gold,locked=P.muted}
local function signed(n) return (n>=0 and "+" or "")..n end
local function copy(deck) local out={} for i,id in ipairs(deck) do out[i]=id end return out end

function Collection.combatDetail(card)
    if not card.combat then return "Solo encuentros sociales; no se incluye en la mano de combate." end
    local names={damage="daño",shield="escudo",heal="vida",energy="energía"}
    local effects={}
    for _,key in ipairs({"damage","shield","heal","energy"}) do
        local value=(card.combat.effects or {})[key]
        if value and value~=0 then effects[#effects+1]=signed(value).." "..names[key] end
    end
    local e=card.combat.effects or {}
    local rules=require("src.data.combat_cards").rules
    if e.draw then effects[#effects+1]="roba "..e.draw end
    if e.weak then effects[#effects+1]="debilita (-"..rules.weakReduction.." daño en su próximo turno)" end
    if e.vulnerable then effects[#effects+1]="vulnerable (+"..rules.vulnerableBonus.." daño recibido por golpe este turno)" end
    local condition=card.conditions and card.conditions.character
    local companion=condition and (" Requiere a "..Characters.byId[condition].shortName..".") or ""
    return require("src.systems.combat").describe(card)..companion
end

function Collection.canEdit(session)
    if not session then return false,"Inicia o continúa una campaña para editar su mazo." end
    if #session.deck<5 then return false,"Nanahoshi entregará el mazo durante el tutorial." end
    if session.encounter or session.combat then return false,"Termina el encuentro antes de editar el mazo." end
    return true
end

function Collection.replace(deck,slot,id,unlocked)
    if type(slot)~="number" or slot%1~=0 or slot<1 or slot>math.min(10,#deck+1) then return nil,"Elige una posición equipada." end
    if not Data.byId[id] or not unlocked[id] then return nil,"Esta carta está bloqueada." end
    if deck[slot]==id then return nil,"Esa carta ya ocupa la posición seleccionada." end
    for _,equipped in ipairs(deck) do if equipped==id then return nil,"La carta ya está equipada; no se permiten duplicados." end end
    local proposal=copy(deck); proposal[slot]=id
    local ok,err=Cards.validateDeck(proposal,unlocked)
    if not ok then return nil,err end
    return proposal
end

-- La viabilidad se calcula con el mismo motor y sus condiciones/afinidades.
-- No garantiza una mano favorable: comprueba que el mazo contiene una
-- combinación ganadora posible en tres acciones y cuatro puntos de energía.
function Collection.bestSocialScore(deck,context)
    local candidates={}
    for _,id in ipairs(deck) do
        local scratch={finished=false,energy=4,hand={id},context=context}
        if Cards.canPlay(scratch,1) then
            local preview=Cards.preview(scratch,1)
            candidates[#candidates+1]={cost=preview.cost,score=preview.score}
        end
    end
    local best=0
    local function explore(first,actions,energy,score)
        best=math.max(best,score)
        if actions==0 then return end
        for i=first,#candidates do
            local card=candidates[i]
            if card.cost<=energy then explore(i+1,actions-1,energy-card.cost,score+card.score) end
        end
    end
    explore(1,3,4,0)
    return best
end

function Collection.validatePlayableDeck(deck,unlocked,day)
    local valid,err=Cards.validateDeck(deck,unlocked)
    if not valid then return false,err end
    for _,profile in ipairs({
        {character="sylphiette",kind="conversation",sceneId="encounter_sylphiette",name="Sylphiette"},
        {character="roxy",kind="investigation",sceneId="encounter_roxy",name="Roxy"},
        {character="eris",kind="conversation",sceneId="encounter_eris",name="Eris"},
    }) do
        if (day or 2)>=5 then profile.sceneId="day5_mission_"..profile.character end
        local maximum=Collection.bestSocialScore(deck,profile)
        if maximum<5 then
            return false,"Mazo inviable con "..profile.name..": máximo "..maximum.." / meta 5. Añade cartas con avance."
        end
    end
    return true
end

function Collection.groups(session)
    local groups={equipped={},available={},locked={}}
    local equipped={}
    for _,id in ipairs(session.deck or {}) do equipped[id]=true end
    for i,card in ipairs(Data.list) do
        local state=equipped[card.id] and "equipped" or ((session.unlocked or {})[card.id] and "available" or "locked")
        groups[state][#groups[state]+1]={index=i,card=card,state=state}
    end
    return groups
end

-- The panel reads the actual effect records, not a second list of bonuses.
function Collection.details(card,session)
    local state=(session.unlocked or {})[card.id] and "available" or "locked"
    for _,id in ipairs(session.deck or {}) do if id==card.id then state="equipped"; break end end
    local recommended={}
    for _,kind in ipairs(contextOrder) do
        local effects=(card.contexts or {})[kind]
        if effects and ((effects.score or 0)>0 or (effects.trust or 0)>0 or (effects.chemistry or 0)>0) then
            recommended[#recommended+1]=contextNames[kind]
        end
    end
    local affinities={}
    for _,id in ipairs(Characters.romanceIds) do
        if (card.affinities or {})[id] then affinities[#affinities+1]=Characters.byId[id].shortName end
    end
    local condition=card.conditions and card.conditions.character
    local requirement=condition and ("Requiere a "..Characters.byId[condition].shortName..".") or "Sin requisito de compañía."
    local view=require("src.systems.card_collection").view(session,card.id)
    return {
        name=card.name,category=Data.categories[card.category].." · N"..view.level,cost="Energía: "..card.cost,
        state=state,stateLabel=stateNames[state],description=card.description,
        base=signed(view.effect.love).." amor / "..signed(view.effect.trust).." conf.\nCopias: "..view.copies.." · El contexto puede penalizar.",
        contexts=#recommended>0 and table.concat(recommended," / ") or "Cualquier contexto; sin bonificación.",
        affinity=#affinities>0 and ("Modificadores: "..table.concat(affinities,", ")..".") or requirement,
        unlock=card.unlockHint,
    }
end

local function badge(state,x,y)
    love.graphics.setColor(stateColors[state])
    if state=="equipped" then
        love.graphics.rectangle("fill",x,y,7,9)
        love.graphics.setColor(P.panel)
        love.graphics.rectangle("fill",x+2,y+2,3,5)
    elseif state=="available" then
        love.graphics.rectangle("fill",x+3,y,2,9)
        love.graphics.rectangle("fill",x,y+3,8,2)
    else
        love.graphics.rectangle("line",x+1,y,6,6)
        love.graphics.rectangle("fill",x,y+4,9,6)
        love.graphics.setColor(P.panel)
        love.graphics.rectangle("fill",x+4,y+6,1,2)
    end
end

function Collection.new(app)
    local s=Screen.new(app)
    s.kind="deck"
    s.selected=1
    s.groups=Collection.groups(app.session)
    s.order={}
    for _,state in ipairs({"equipped","available","locked"}) do
        for _,entry in ipairs(s.groups[state]) do s.order[#s.order+1]=entry.index end
    end
    function s:select(index)
        if self.selected~=index and app.audio then app.audio:effect("card_select") end
        self.selected=index
    end
    function s:refresh()
        self.groups=Collection.groups(app.session); self.order={}
        for _,state in ipairs({"equipped","available","locked"}) do
            for _,entry in ipairs(self.groups[state]) do self.order[#self.order+1]=entry.index end
        end
    end
    function s:startEditing()
        local ok,reason=Collection.canEdit(app.session)
        if not ok then self.message=reason; return false,reason end
        self.editing=true; self.draft=copy(app.session.deck)
        self.slot=1; self.candidate=1; self.candidatePage=1; self.dirty=false
        self.message="Elige una posición y una carta; después pulsa Sustituir."
        self.keyboardFocus=nil; return true
    end
    function s:selectSlot(index)
        if not self.editing or index<1 or index>math.min(10,#self.draft+1) then return false end
        self.slot=index; self.keyboardFocus=nil; return true
    end
    function s:selectCandidate(index)
        if not self.editing or not Data.list[index] then return false end
        self.candidate=index; self.candidatePage=math.floor((index-1)/8)+1
        self.keyboardFocus=nil
        local card=Data.list[index]
        local _,reason=Collection.replace(self.draft,self.slot,card.id,app.session.unlocked)
        self.message=reason or ("Sustituir "..(Data.byId[self.draft[self.slot]] and Data.byId[self.draft[self.slot]].name or "posición libre").." por "..card.name..".")
        return true
    end
    function s:replaceSelected()
        if not self.editing then return false end
        local ok,reason=Collection.canEdit(app.session)
        if not ok then self.message=reason; return false end
        local proposal,err=Collection.replace(self.draft,self.slot,Data.list[self.candidate].id,app.session.unlocked)
        if not proposal then self.message=err; return false end
        self.draft=proposal; self.dirty=true
        self.message="Borrador actualizado. Pulsa Guardar mazo para conservarlo."
        if app.audio then app.audio:effect("card_select") end
        return true
    end
    function s:saveDeck()
        if not self.editing then return false end
        local ok,reason=Collection.canEdit(app.session)
        if not ok then self.message=reason; return false end
        local valid,err=Collection.validatePlayableDeck(self.draft,app.session.unlocked,app.session.day)
        if not valid then self.message=err; return false end
        local old=app.session.deck
        app.session.deck=copy(self.draft)
        if app.save and app:save()==false then
            app.session.deck=old; self.message="No se pudo guardar. El mazo anterior sigue equipado."; return false
        end
        self.editing=false; self.dirty=false; self.keyboardFocus=nil; self:refresh()
        self.message="Mazo guardado: "..#self.draft.." cartas diferentes."
        return true
    end
    function s:cancelEditing()
        self.editing=false; self.draft=nil; self.dirty=false; self.keyboardFocus=nil
        self.message="El borrador se descartó. El mazo equipado se conserva."
    end
    function s:drawEditor()
        self:begin()
        app.resources:background("library")
        love.graphics.setColor(.025,.035,.07,.90); love.graphics.rectangle("fill",0,0,640,360)
        W.panel(8,7,624,30)
        self:text("EDITOR DE MAZO · 5 A 10 CARTAS SIN DUPLICADOS",18,18,592,P.gold)
        W.panel(14,45,296,216); W.panel(320,45,306,216)
        self:text("1. POSICIÓN EQUIPADA",24,56,276,P.teal)
        self:text("2. CARTA DE LA COLECCIÓN",330,56,286,P.teal)
        for i=1,math.min(10,#self.draft+1) do
            local id=self.draft[i]
            self:button(i..". "..(id and Data.byId[id].name or "+ Añadir carta"),24,73+(i-1)*18,276,17,function() self:selectSlot(i) end,false,self.slot==i)
        end
        local equipped={}; for _,id in ipairs(self.draft) do equipped[id]=true end
        for row=1,8 do
            local index=(self.candidatePage-1)*8+row
            local card=Data.list[index]
            if card then
                local marker=equipped[card.id] and "[E] " or (app.session.unlocked[card.id] and "[+] " or "[X] ")
                self:button(marker..card.name,330,73+(row-1)*18,286,17,function() self:selectCandidate(index) end,false,self.candidate==index)
            end
        end
        self:button("<",330,225,30,24,function() self:selectCandidate(((self.candidatePage-2)%math.ceil(#Data.list/8))*8+1) end)
        self:text("[E] equipada [+] libre [X] bloqueada",367,227,210,P.muted)
        self:button(">",586,225,30,24,function() self:selectCandidate((self.candidatePage%math.ceil(#Data.list/8))*8+1) end)
        local candidate=Data.list[self.candidate]
        local detail=Collection.details(candidate,{deck=self.draft,unlocked=app.session.unlocked})
        self:text(candidate.name.." · social: "..candidate.cost.." energía · "..detail.base,18,268,604,P.ink)
        self:text(Collection.combatDetail(candidate),18,292,604,P.teal)
        local proposal=Collection.replace(self.draft,self.slot,candidate.id,app.session.unlocked)
        self:button("Sustituir",14,318,154,25,function() self:replaceSelected() end,not proposal)
        self:button("Guardar mazo",176,318,154,25,function() self:saveDeck() end,not self.dirty)
        self:button("Cancelar borrador",338,318,174,25,function() self:cancelEditing() end)
        self:button("Quitar",520,318,106,25,function()
            if #self.draft>5 and self.draft[self.slot] then
                table.remove(self.draft,self.slot); self.slot=math.min(self.slot,#self.draft); self.dirty=true
                self.message="Carta retirada del borrador. Conserva al menos cinco."
            end
        end,#self.draft<=5 or not self.draft[self.slot])
        self:text(self.message or "Tab/Enter: botones · Izq/Der: colección · Esc: cancelar",14,348,612,P.muted)
    end
    function s:draw()
        if self.editing then self:drawEditor(); return end
        self:begin()
        app.resources:background("library")
        love.graphics.setColor(.025,.035,.07,.78)
        love.graphics.rectangle("fill",0,0,640,360)
        self:header("COLECCIÓN / "..#app.session.deck.." CARTAS EN EL MAZO",true)
        W.panel(14,46,299,296)
        local position=1
        for i,index in ipairs(self.order) do if index==self.selected then position=i; break end end
        local page=math.floor((position-1)/15)+1
        self:text("[E] equipada · [+] libre · [X] bloqueada",24,57,278,P.teal)
        for row=1,15 do
            local index=self.order[(page-1)*15+row]
            if index then
                local card=Data.list[index]
                local equipped=false; for _,id in ipairs(app.session.deck) do if id==card.id then equipped=true end end
                local marker=equipped and "[E] " or (app.session.unlocked[card.id] and "[+] " or "[X] ")
                self:button(marker..card.name,24,76+(row-1)*14,278,14,function() self:select(index) end,false,self.selected==index)
                self.buttons[#self.buttons].cardIndex=index
            end
        end
        local pages=math.ceil(#self.order/15)
        self:button("<",24,308,42,24,function() self:select(self.order[((page-2)%pages)*15+1]) end)
        self:text("Página "..page.."/"..pages,76,316,160,P.muted,1,"center")
        self:button(">",260,308,42,24,function() self:select(self.order[(page%pages)*15+1]) end)
        W.panel(323,46,303,296)
        local card=Data.list[self.selected]
        local detail=Collection.details(card,app.session)
        self:text(detail.name,337,56,275,P.gold)
        CardView.draw(app.resources,card,337,76)
        self:text(detail.category,429,79,183,P.teal)
        self:text(detail.cost,429,107,183,P.ink)
        badge(detail.state,429,132)
        self:text(detail.stateLabel,444,132,168,stateColors[detail.state])
        self:text(detail.affinity,429,155,183,P.muted)
        self:text(detail.description,337,198,275,P.ink)
        self:text(detail.base,337,234,275,P.teal)
        self:text("RECOMENDADA EN",337,261,275,P.gold)
        self:text(detail.contexts,337,274,275,P.ink)
        self:text("OBTENCIÓN: "..detail.unlock,337,299,275,P.muted)
        self:text("Editar [E]: añadir, quitar o sustituir (5–10).",337,328,275,P.muted)
        self:text("Flechas: inspeccionar · Tab: botones · Enter: seleccionar · Esc: volver",18,347,604,P.muted)
        self:button("Social [E]",345,12,94,20,function() self:startEditing() end)
        self:button("Combate",444,12,94,20,function() app:switch(require("src.screens.combat_deck").new(app)) end)
        self:button("Mejorar",247,12,92,20,function() app:switch(require("src.screens.upgrades").new(app,card.id)) end)
        if self.message then
            W.panel(16,343,608,17)
            self:text(self.message,22,347,596,P.gold)
        end
    end
    function s:keypressed(key)
        if self.editing then
            if key=="escape" then self:cancelEditing(); return end
            if key=="left" or key=="right" then
                self:selectCandidate((self.candidate-1+(key=="right" and 1 or -1))%#Data.list+1); return
            end
            self:navigate(key); return
        end
        if Controls.matches(Controls.back,key) then app:resume(); return end
        if key=="e" then self:startEditing(); return end
        if key=="left" or key=="right" then
            local position=1
            for i,index in ipairs(self.order) do if index==self.selected then position=i; break end end
            self:select(self.order[(position-1+(key=="right" and 1 or -1))%#self.order+1])
            self.keyboardFocus=nil
            return
        end
        self:navigate(key)
    end
    return s
end
return Collection
