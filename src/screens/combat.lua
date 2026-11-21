local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Font=require("src.ui.font")
local Combat=require("src.systems.combat")
local Tutorial=require("src.systems.combat_tutorial")
local Progression=require("src.systems.progression")
local CardData=require("src.data.cards")
local CombatScreen={}

local function rect(color,x,y,w,h,alpha)
    love.graphics.setColor(color[1],color[2],color[3],alpha or color[4] or 1)
    love.graphics.rectangle("fill",math.floor(x),math.floor(y),math.floor(w),math.floor(h))
end
local function stateText(actor)
    local parts={}
    if (actor.weak or 0)>0 then parts[#parts+1]="Débil "..actor.weak end
    if (actor.vulnerable or 0)>0 then parts[#parts+1]="Vulnerable "..actor.vulnerable end
    return #parts>0 and table.concat(parts," / ") or "Sin estados"
end
local function sound(app,name) if app.audio then app.audio:effect(name) end end

-- Iconos propios de 24x24; no modifican ni reinterpretan las ilustraciones sociales.
function CombatScreen.icon(id,x,y)
    id=({ice_lance="magic_bolt",mana_spark="magic_bolt",wind_guard="arcane_guard",disrupting_ray="heavy_spell",quick_study="focus"})[id] or id
    local function r(c,a,b,w,h) rect(c,x+a,y+b,w,h) end
    if id=="magic_bolt" then
        r(P.lavender,10,1,8,5);r(P.lavender,6,6,10,5);r(P.white,8,9,10,4)
        r(P.teal,11,13,5,5);r(P.teal,7,18,5,5)
    elseif id=="arcane_guard" then
        r(P.teal,4,3,16,12);r(P.teal,6,15,12,4);r(P.teal,9,19,6,3)
        r(P.panel,7,6,10,8);r(P.white,11,6,2,12)
    elseif id=="heavy_spell" then
        r(P.lavender,5,5,14,14);r(P.rose,2,9,20,6);r(P.gold,9,2,6,20)
        r(P.white,9,9,6,6)
    elseif id=="heal" then
        r(P.green,8,2,8,20);r(P.green,2,8,20,8);r(P.white,10,5,3,14)
    else
        r(P.lavender,3,7,18,10);r(P.panel,6,9,12,6);r(P.gold,10,2,4,20)
        r(P.white,8,10,8,4)
    end
end

-- La Anomalía es una silueta de fragmentos, dibujada sobre una cuadrícula de 2 px.
function CombatScreen.enemySprite(x,y,alpha,impact,shape)
    alpha=alpha or 1
    local function r(c,a,b,w,h) rect(c,x+a,y+b,w,h,alpha) end
    if shape=="beast" then
        r(P.shadow,5,25,52,27);r(P.gold,7,18,45,24);r(P.rose,40,24,7,5)
        r(P.ink,7,46,9,17);r(P.ink,44,46,9,17);r(P.gold,5,9,9,15);r(P.gold,39,9,9,15)
        r(impact and P.white or P.panel,18,23,4,5);r(P.white,44,36,10,3);return
    elseif shape=="guardian" then
        r(P.shadow,10,5,44,58);r(P.muted,17,4,30,15);r(P.lavender,12,24,40,26)
        r(P.teal,24,10,16,4);r(P.muted,0,27,10,26);r(P.muted,54,27,10,26)
        r(P.muted,15,51,12,13);r(P.muted,37,51,12,13);r(impact and P.white or P.gold,29,30,6,12);return
    end
    for row=0,11 do
        local inset=math.abs(5-row)*3
        r(P.shadow,4+inset,7+row*4,56-inset*2,4)
        r(impact and P.ink or P.lavender,8+inset,8+row*4,48-inset*2,2)
    end
    r(P.panel,20,19,24,25);r(P.teal,24,22,16,19)
    r(P.white,28,25,8,8);r(P.panel,31,26,3,8)
    r(P.gold,2,8,6,6);r(P.lavender,55,2,6,8);r(P.teal,56,49,6,6)
    r(P.lavender,8,55,6,5)
end

local function barrier(x,y,alpha)
    for row=0,7 do
        local inset=row>4 and (row-4)*4 or 0
        rect(P.teal,x+inset,y+row*8,3,7,alpha)
        rect(P.teal,x+61-inset,y+row*8,3,7,alpha)
    end
    rect(P.teal,x+2,y-2,60,3,alpha)
end

function CombatScreen.new(app,definition)
    local s=Screen.new(app)
    s.definition=definition or Progression.encounter(app.session,app.session.checkpoint) or {}
    local context={character=s.definition.character,tutorial=s.definition.tutorial,enemyId=s.definition.enemyId,
        cardLevels=require("src.systems.card_collection").levels(app.session),
        preparationShield=app.session.combat and app.session.combat.context.preparationShield or require("src.systems.economy").ensure(app.session).nextBattleShield,
        day=app.session.day,difficulty=s.definition.difficulty,
        tacticalContext=s.definition.tacticalContext,unlocked=not app.practice and app.session.unlocked or nil,
        combatDeck=app.session.combatDeck,curse=app.session.curse,externalEnergy=app.session.externalEnergy}
    s.enc=Combat.restore(app.session.combat,app.session.deck,context)
    if not s.enc then
        s.enc=Combat.new(app.session.deck,context)
        app.session.economy.nextBattleShield=0
    end
    app.session.combat=s.enc
    s.selected,s.confirmReady,s.age,s.historyPage=1,false,0,1
    s.feedback="Selecciona una carta para inspeccionarla. Confirma con Jugar."
    if #(s.enc.deckAdjustments or {})>0 then
        s.actionSummary="Exclusiva sin compañera: sustituida aquí por una técnica inicial adquirida. Tu mazo guardado se conserva."
    end
    s.displayHp={player=s.enc.player.hp,enemy=s.enc.enemy.hp,mana=s.enc.player.mana}
    s.tutorial=s.definition.tutorial and Tutorial.restore(s.enc.tutorial,s.enc) or nil
    s.enc.tutorial=s.tutorial
    if app.audio then app.audio:setContext(s.enc.finished and s.enc.outcome or s.enc.training and "training" or s.enc.enemy.boss and "boss" or "combat") end
    if not s.enc.finished and s.enc.turn==1 and s.enc.revision==0 then sound(app,"combat_start") end
    app:save()

    function s:busy() return self.motion~=nil end
    function s:canPlay(index)
        local ok,err=Combat.canPlay(self.enc,index)
        if not ok then return ok,err end
        return Tutorial.canPlay(self.tutorial,Combat.card(self.enc.hand[index]))
    end
    function s:select(index)
        if self:busy() or self.enc.finished or not self.enc.hand[index] then return false end
        self.selected=index;self.confirmReady=true;self.armedRevision=self.enc.revision;self.keyboardFocus=nil
        local ok,err=self:canPlay(index)
        self.feedback=ok and "Carta seleccionada. Confirma con Jugar [Enter]." or err
        sound(app,"card_select")
        return true
    end
    function s:startMotion(result,enemyAction)
        self.motion={elapsed=0,duration=app.options.reducedMotion and .18 or 1.05,events=result.events or {},enemyAction=enemyAction,
            startPlayer=self.displayHp.player,startEnemy=self.displayHp.enemy,startMana=self.displayHp.mana,
            companionAction=result.companionAction,element=result.element,playedSounds=false}
        self.feedback=result.text or "Acción resuelta."
        self.actionSummary=result.actionName or (result.cardId and Combat.card(result.cardId).name) or "Acción resuelta"
        local totals={damage=0,blocked=0,lost=0,hits=0}
        local target=enemyAction and "player" or "enemy"
        for _,entry in ipairs(result.events or {}) do
            if entry.kind=="damage" and entry.target==target then
                totals.damage=totals.damage+entry.damage;totals.blocked=totals.blocked+entry.blocked
                totals.lost=totals.lost+entry.hpLost;totals.hits=totals.hits+1
            end
        end
        if totals.hits>0 then
            self.actionSummary=self.actionSummary.."\n"..totals.damage.." daño; "..totals.blocked.." bloqueado.\n"..totals.lost..(self.enc.training and " resistencia perdida." or " vida perdida.")
        else
        for _,event in ipairs(result.events or {}) do
            if event.kind=="shield" or event.kind=="heal" or event.kind=="status" or event.kind=="prepare" or event.kind=="interrupt" or event.kind=="recovery_exhausted" then
                self.actionSummary=self.actionSummary.."\n"..event.text
                break
            end
        end
        end
        self.confirmReady=false;self.keyboardFocus=nil;self.selected=math.min(self.selected,math.max(1,#self.enc.hand))
        if self.enc.finished and self.tutorial then self.tutorial.stage="complete" end
        self.enc.tutorial=self.tutorial
        app:save()
    end
    function s:play()
        if self:busy() or self.enc.finished or not self.confirmReady then return false end
        local ok,err=self:canPlay(self.selected)
        if not ok then self.feedback=err;return false end
        local id=self.enc.hand[self.selected]
        local result,message=Combat.play(self.enc,self.selected,self.armedRevision)
        if not result then self.feedback=message;return false end
        Tutorial.played(self.tutorial,id)
        sound(app,"card_discard")
        self:startMotion(result,false)
        return true
    end
    function s:endTurn()
        if self:busy() or self.enc.finished then return false end
        if not Tutorial.canEndTurn(self.tutorial) then self.feedback="Completa el paso que indica Nanahoshi antes de terminar.";return false end
        local result,err=Combat.endTurn(self.enc,self.enc.revision)
        if not result then self.feedback=err;return false end
        Tutorial.endedTurn(self.tutorial)
        self:startMotion(result,true)
        return true
    end
    function s:tactic(id)
        if self:busy() or self.enc.finished then return false end
        local result,err=Combat.tactic(self.enc,id,self.enc.revision)
        if not result then self.feedback=err;return false end
        self.tacticsOpen=false;self:startMotion(result,false);return true
    end
    function s:basic(id)
        if self:busy() or self.enc.finished then return false end
        if self.tutorial and self.tutorial.stage~="free" and not (self.tutorial.stage=="shield" and id=="defend") then return false end
        local result,err=Combat.basic(self.enc,id,self.enc.revision)
        if not result then self.feedback=err;return false end
        Tutorial.played(self.tutorial,id);self:startMotion(result,false);return true
    end
    function s:breakSeal()
        if self:busy() then return false end
        local result,err=Combat.breakSeal(self.enc,self.enc.revision)
        if not result then self.feedback=err;return false end
        self:startMotion(result,false);return true
    end
    function s:advanceGuide()
        if self:busy() then return end
        if Tutorial.advance(self.tutorial) then
            self.confirmReady=false;self.keyboardFocus=nil;self.enc.tutorial=self.tutorial;app:save()
        end
    end
    function s:retry()
        if self:busy() then return end
        if self.enc.training and self.enc.finished then return self:continue() end
        local restored=Combat.retry(self.enc)
        if not restored then return end
        app.session.combat=restored
        app:save()
        app:switch(CombatScreen.new(app,self.definition),{type="magic",duration=.35})
    end
    function s:leave()
        if app.practice then app:endPractice() else app:combatSafeExit() end
    end
    function s:continue()
        if self:busy() then return end
        if self.enc.training and self.enc.finished then app:resume();return end
        if self.enc.outcome~="victory" then return end
        app:finishCombat(self.enc)
    end
    function s:update(dt)
        self.age=self.age+math.max(0,dt)
        local motion=self.motion
        if not motion then return end
        motion.elapsed=math.min(motion.duration,motion.elapsed+math.max(0,dt))
        local progress=motion.elapsed/motion.duration
        local hpProgress=math.max(0,math.min(1,(progress-.2)/.55))
        self.displayHp.player=motion.startPlayer+(self.enc.player.hp-motion.startPlayer)*hpProgress
        self.displayHp.enemy=motion.startEnemy+(self.enc.enemy.hp-motion.startEnemy)*hpProgress
        self.displayHp.mana=motion.startMana+(self.enc.player.mana-motion.startMana)*hpProgress
        if progress>=.2 and not motion.playedSounds then
            motion.playedSounds=true
            local played={}
            if motion.element=="water" or motion.element=="earth" or motion.element=="sword" then sound(app,motion.element) end
            for _,event in ipairs(motion.events) do
                local effect=event.kind=="damage" and (event.target=="player" and "hurt" or "attack")
                    or event.kind=="shield" and "guard" or event.kind=="heal" and "heal"
                if effect and not played[effect] then sound(app,effect);played[effect]=true end
            end
        end
        if progress>=.8 and motion.enemyAction and not motion.drew then sound(app,"card_draw");motion.drew=true end
        if progress>=1 then
            self.motion=nil;self.displayHp.player=self.enc.player.hp;self.displayHp.enemy=self.enc.enemy.hp;self.displayHp.mana=self.enc.player.mana
            if self.enc.finished then
                if app.audio then app.audio:setContext(self.enc.outcome) end
                sound(app,self.enc.outcome);self.resultAge=0
            end
        end
    end
    function s:drawHud()
        W.panel(8,8,226,78)
        self:text("RUDY",18,14,90,P.gold)
        self:text(self.enc.context.curse.manaBlocked and "MANÁ BLOQUEADO" or "MAGIA LIBRE",100,14,125,P.muted)
        self:text((self.enc.training and "RES " or "PV ")..self.enc.player.hp.."/"..self.enc.player.maxHp.."   Escudo "..self.enc.player.shield,18,29,200,P.ink)
        W.bar(18,41,206,6,self.displayHp.player,self.enc.player.maxHp,P.green)
        local blocked=self.enc.context.curse.manaBlocked
        local energy=blocked and self.enc.player.externalEnergy or self.enc.player.mana
        local maximum=blocked and self.enc.player.maxExternalEnergy or self.enc.player.maxMana
        self:text((blocked and "Externa " or "Natural ")..energy.."/"..maximum.." | +4/turno",18,51,200,P.teal)
        W.bar(18,63,206,5,energy,math.max(1,maximum),P.lavender)
        self:text("Escudos F:"..self.enc.player.physicalShield.." M:"..self.enc.player.magicShield.." · "..stateText(self.enc.player),18,73,204,P.muted)
        W.panel(242,8,390,78)
        self:text(self.enc.enemy.name,252,14,194,P.lavender)
        self:text(self.enc.enemy.phase and ({endurance="I · Resistencia",six_arms="II · Seis brazos",seal="III · Sello "..(self.enc.enemy.seal or 0),victory="IV · Victoria"})[self.enc.enemy.phase] or stateText(self.enc.enemy),452,14,170,P.muted,1,"right")
        self:text((self.enc.training and "Resistencia " or "Vida ")..self.enc.enemy.hp.." / "..self.enc.enemy.maxHp,252,29,178,P.ink)
        self:text("Escudo "..self.enc.enemy.shield,438,29,180,P.teal)
        W.bar(252,43,370,8,self.displayHp.enemy,self.enc.enemy.maxHp,P.danger)
        local intent=self.enc.enemy.intent
        self:text("Intención: "..(intent and (intent.text or intent.description or intent.name) or "Resuelta"),252,54,370,P.gold)
    end
    function s:drawActors()
        local motion=self.motion
        local p=motion and motion.elapsed/motion.duration or 0
        local reduced=app.options.reducedMotion
        local playerX,enemyX=64,510
        local enemyHit,playerHit,companionHit,playerShield,enemyShield,heal=false,false,false,false,false,false
        if motion then
            for _,event in ipairs(motion.events) do
                if event.kind=="damage" then
                    if event.target=="enemy" then enemyHit=true elseif event.target=="companion" then companionHit=true else playerHit=true end
                elseif event.kind=="shield" then
                    if event.target=="enemy" then enemyShield=true else playerShield=true end
                elseif event.kind=="heal" and event.target=="player" then heal=true end
            end
        end
        if not reduced and motion then
            if enemyHit then playerX=playerX+math.floor(math.sin(math.min(1,p*2)*math.pi)*16) end
            if enemyHit and p>.2 and p<.6 then enemyX=enemyX+math.floor(math.sin(p*65)*3) end
            if playerHit and p>.2 and p<.6 then playerX=playerX+math.floor(math.sin(p*65)*3) end
            if playerHit then enemyX=enemyX-math.floor(math.sin(math.min(1,p*2)*math.pi)*16) end
        end
        rect(P.shadow,51,157,94,5,.7);rect(P.shadow,495,157,94,5,.7)
        local weakened=self.enc.outcome=="defeat" and (motion and math.floor(p*7) or 7) or 0
        app.resources:portrait("rudeus",(playerHit or self.enc.outcome=="defeat") and "worried" or "neutral",playerX,94+weakened,1)
        if playerHit and motion and p>.22 and p<.35 then rect(P.rose,playerX+12,110,40,40,.25) end
        local alpha=self.enc.outcome=="victory" and (motion and 1-p or 0) or 1
        if self.enc.enemy.portrait then
            app.resources:portrait(self.enc.enemy.portrait,enemyHit and "worried" or self.enc.enemy.phase=="six_arms" and "angry" or "neutral",enemyX,94,1)
            if alpha<1 and not self.enc.training and self.enc.enemy.id~="badigadi_final" then rect(P.shadow,enemyX,94,64,64,1-alpha) end
        elseif self.enc.enemy.shape=="rudy" then
            love.graphics.setColor(.7,.55,1,alpha)
            app.resources:portrait("rudeus",enemyHit and "worried" or "angry",enemyX,94,1)
            if alpha<1 then rect(P.shadow,enemyX,94,64,64,1-alpha) end
        else
            CombatScreen.enemySprite(enemyX,93,alpha,enemyHit and motion and p>.22 and p<.36,self.enc.enemy.shape)
        end
        if self.enc.player.shield>0 or playerShield then barrier(playerX,92,playerShield and .8 or .35) end
        if self.enc.enemy.shield>0 or enemyShield then barrier(enemyX,92,enemyShield and .8 or .35) end
        self:text("Rudy",43,166,110,P.ink,1,"center")
        self:text(self.enc.enemy.training and "Entrenamiento" or "Amenaza",456,166,170,P.muted,1,"center")
        if self.enc.companion then
            local ally=self.enc.companion
            local attack=motion and motion.companionAction and not reduced and math.sin(math.min(1,p*2)*math.pi)*12 or 0
            local injured=ally.hp<=ally.maxHp/2
            local shake=companionHit and motion and p>.2 and p<.6 and not reduced and math.sin(p*65)*3 or 0
            app.resources:portrait(ally.id,(ally.hp<=0 or companionHit) and "worried" or motion and motion.companionAction and "happy" or "neutral",143+math.floor(attack+shake),94,1)
            if ally.shield>0 then barrier(142,92,.35) end
            W.bar(143,159,64,4,ally.hp,ally.maxHp,P.teal)
            self:text(ally.name,137,166,76,injured and P.rose or P.teal,1,"center")
            self:text("PV "..ally.hp.."/20",137,177,76,P.muted,1,"center")
        end
        if motion and p>.15 then
            local targetRows={player=0,enemy=0}
            for _,event in ipairs(motion.events) do
                local target=event.target
                if target=="player" or target=="enemy" then
                    local label,tint
                    if event.kind=="damage" then label="-"..tostring(event.hpLost or 0)..(self.enc.training and " RES" or " VIDA");tint=P.danger
                    elseif event.kind=="shield" then label="+"..tostring(event.amount or 0).." ESCUDO";tint=P.teal
                    elseif event.kind=="heal" then label="+"..tostring(event.amount or 0)..(self.enc.training and " RES" or " VIDA");tint=P.green end
                    if label then
                        local row=targetRows[target];targetRows[target]=row+1
                        local x=target=="player" and 13 or 463
                        local y=102+row*23-(reduced and 0 or math.floor(p*14))
                        W.panel(x,y,158,20,{shadow=false})
                        self:text(label,x+3,y+4,152,tint,1,"center")
                        if event.kind=="damage" and (event.blocked or 0)>0 then
                            self:text("Bloqueo "..event.blocked,x+3,y+22,152,P.teal,1,"center")
                        end
                    end
                end
            end
            if heal or self.enc.outcome=="victory" then
                local center=heal and playerX+32 or enemyX+32
                for i=1,12 do
                    local a=i*math.pi/6;local radius=12+p*34
                    rect(heal and P.green or P.gold,center+math.cos(a)*radius,124+math.sin(a)*radius,3,3,1-p*.7)
                end
            end
        end
        if self.enc.outcome=="defeat" and motion then rect(P.shadow,0,87,640,94,p*.65) end
    end
    function s:drawGuide()
        local title,message,advance=Tutorial.message(self.tutorial,self.enc)
        if not title then
            W.panel(242,96,217,80,{shadow=false})
            self:text(self.enc.companion and self.enc.companion.role or "CARTAS Y ESTRATEGIA",249,101,203,P.lavender)
            self:text(self.actionSummary or (self.enc.training and "Eris desvía 2 puntos de espada. Bloquea o esquiva para abrir Contraataque [C]. Tierra explota su postura."
                or "Defensa [D] y esquiva [V] siempre disponibles. Los artefactos usan energía externa durante la maldición."),249,117,203,P.ink)
            return
        end
        W.panel(176,91,282,88,{shadow=false,border=P.lavender})
        self:text(title,184,96,266,P.gold)
        self:text(message,184,111,266,P.ink)
        if advance then self:button("Entendido [Enter]",228,155,178,20,function() self:advanceGuide() end,self:busy()) end
    end
    function s:drawHand()
        local locked=self:busy()
        W.panel(8,185,624,29,{shadow=false})
        self:text(self.enc.energy.."A · T"..self.enc.turn,18,194,80,P.gold)
        local guideFree=not self.tutorial or self.tutorial.stage=="free"
        self:button("Defensa [D]",99,189,105,21,function() self:basic("defend") end,locked or not Combat.canBasic(self.enc,"defend") or not (guideFree or self.tutorial.stage=="shield"))
        self:button("Esquiva [V]",209,189,105,21,function() self:basic("dodge") end,locked or not Combat.canBasic(self.enc,"dodge") or not guideFree)
        if self.enc.training then
            self:button("Contraataque [C]",319,189,151,21,function() self:basic("counter") end,locked or not Combat.canBasic(self.enc,"counter"))
            self:text("Mazo "..#self.enc.drawPile.." / D "..#self.enc.discard,477,194,145,P.muted)
        elseif self.enc.enemy.phase=="seal" then
            self:button("Romper sello [B]",319,189,193,21,function() self:breakSeal() end,locked or not Combat.canBreakSeal(self.enc))
        else self:text("Mazo "..#self.enc.drawPile.." / Descarte "..#self.enc.discard,324,194,187,P.muted) end
        if self.enc.companion then self:button("Táctica [T]",521,189,103,21,function() self.tacticsOpen=true;self.keyboardFocus=nil end,locked or self.enc.finished) end
        for i=1,3 do
            local x,y=12+(i-1)*89,221
            local card=Combat.card(self.enc.hand[i],self.enc)
            if card then
                local selected=self.selected==i and self.confirmReady
                if selected then rect(P.gold,x-2,y-2,84,116) end
                app.resources:cardBase(x,y,1);app.resources:cardFrame(card.category or "initiative",x,y,1)
                self:text(card.shortName or card.name,x+8,y+11,64,{.17,.14,.21,1},1,"center")
                if require("src.data.assets").cardIcons[card.icon or card.id] then app.resources:icon(card.icon or card.id,x+28,y+65,1)
                elseif CardData.byId[card.id] then app.resources:icon(card.id,x+28,y+65,1) else CombatScreen.icon(card.id,x+28,y+65) end
                self:text(card.cost.."A "..(card.manaCost or 0)..(self.enc.context.curse.manaBlocked and "X " or "M ")..(card.hpCost or 0).."PV",x+4,y+95,72,{.17,.14,.21,1},1,"center")
                local available=self:canPlay(i)
                rect(P.panel,x,y+112,80,14)
                self:text("["..i.."] "..(available and "ELEGIR" or "LIMITADA"),x+1,y+114,78,available and P.gold or P.muted,1,"center")
                self.buttons[#self.buttons+1]={x=x,y=y,w=80,h=126,cardIndex=i,action=function() self:select(i) end,disabled=locked}
            else
                W.panel(x,y,80,112,{shadow=false})
                self:text("SIN CARTA",x+7,y+48,66,P.muted,1,"center")
            end
        end
        W.panel(283,220,349,92,{shadow=false})
        local card=Combat.card(self.enc.hand[self.selected],self.enc)
        if card then
            local preview=Combat.preview(self.enc,self.selected)
            self:text(card.name..(preview and preview.usesLeft and " · "..preview.usesLeft.." usos" or ""),293,226,329,P.gold)
            local description=Combat.describe(card,self.enc)
            if preview and preview.damage then description=description.." Daño real "..preview.damage..(self.enc.training and " / RES -" or " / PV -")..preview.hpLost.."." end
            if preview and preview.trainingSwordReduction then description=description.." Eris desvía "..preview.trainingSwordReduction.." de espada." end
            if card.effects.shield then description=description..". Caduca al iniciar tu turno." end
            self:text(description,293,243,329,P.ink)
            local ok,reason=self:canPlay(self.selected)
            local text=not ok and reason or self.confirmReady and "Inspección: confirma Jugar para aplicar." or "Clic / 1-3 / flechas: inspeccionar carta."
            self:text(text,293,282,329,ok and P.muted or P.rose)
        else
            self:text("Mano agotada. Termina el turno para robar.",293,235,329,P.muted)
        end
        local allowed=self:canPlay(self.selected)
        self:button("Jugar [Enter]",283,318,132,27,function() self:play() end,locked or not self.confirmReady or not allowed)
        self:button("Terminar turno [E]",421,318,132,27,function() self:endTurn() end,locked or not Tutorial.canEndTurn(self.tutorial))
        self:button("Hist. [H]",559,318,73,27,function() self.historyOpen=true;self.historyPage=1;self.keyboardFocus=nil end)
    end
    function s:historyLines()
        local lines={}
        for _,entry in ipairs(self.enc.log) do
            local action=entry.cardId and Combat.card(entry.cardId).name or entry.actionName
            local title="T"..tostring(entry.turn or 1).." · "..tostring(action or entry.text or "Acción")
            for _,line in ipairs(Font.wrap(title,550,1)) do lines[#lines+1]=line end
            for _,event in ipairs(entry.events or {}) do
                if event.text and event.text~=entry.text then
                    for _,line in ipairs(Font.wrap("  "..event.text,550,1)) do lines[#lines+1]=line end
                end
            end
            lines[#lines+1]=""
        end
        return lines
    end
    function s:drawHistory()
        -- Superficie modal: todas las hitboxes anteriores dejan de ser activas.
        self:begin();rect(P.shadow,0,0,640,360,.86);W.panel(26,20,588,320)
        self:text("HISTORIAL DEL COMBATE",43,34,400,P.gold,2)
        local lines=self:historyLines();local pages=math.max(1,math.ceil(#lines/20))
        self.historyPage=math.max(1,math.min(pages,self.historyPage))
        local first=(self.historyPage-1)*20+1
        for row=0,19 do self:text(lines[first+row] or "",44,68+row*11,550,P.ink) end
        self:text("Página "..self.historyPage.." / "..pages,44,311,180,P.muted)
        self:button("<",247,302,44,25,function() self.historyPage=math.max(1,self.historyPage-1) end,self.historyPage==1)
        self:button(">",298,302,44,25,function() self.historyPage=math.min(pages,self.historyPage+1) end,self.historyPage==pages)
        self:button("Cerrar [H / Esc]",400,302,197,25,function() self.historyOpen=false;self.keyboardFocus=nil end)
    end
    function s:rewardText()
        if app.practice then return "Práctica completada. Sin cambios en la campaña." end
        if app.session.checkpoint=="day1_tutorial" then return "Primera anomalía contenida. Nanahoshi registra lo aprendido." end
        local reward=self.enc.enemy.reward
        if type(reward)=="string" then return reward end
        if type(reward)=="table" then return reward.text or reward.description or reward.name or "Anomalía contenida; el camino queda despejado." end
        return "Anomalía contenida; el camino queda despejado."
    end
    function s:drawResult()
        self:begin();rect(P.shadow,0,0,640,360,.85)
        local won=self.enc.outcome=="victory"
        W.panel(69,31,502,296,{border=won and P.gold or P.danger})
        if self.enc.training then
            self:text(won and "¡VICTORIA! — RUDY" or "DERROTA EN ENTRENAMIENTO — ERIS GANA",90,52,460,P.gold,1,"center")
            self:text("El ejercicio se detiene. Ambos están a salvo.",94,99,452,P.ink)
            self:text("Eris valorará cómo competiste. Perder pronto no implica haberse dejado ganar.",94,133,452,P.ink)
            self:text("Turnos: "..self.enc.training.metrics.turns.." · Impactos: "..self.enc.training.metrics.attacksHit,94,179,452,P.teal)
            self:button("Escuchar a Eris [Enter]",138,253,364,28,function() self:continue() end)
            self:button("Historial [H]",447,306,110,18,function() self.historyOpen=true;self.keyboardFocus=nil end)
            return
        end
        self:text(won and "¡VICTORIA!" or "DERROTA",90,48,460,won and P.gold or P.danger,3,"center")
        self:text(self.enc.enemy.name,93,93,454,P.ink,1,"center")
        W.divider(94,115,452)
        if won then
            self:text(self.enc.enemy.defeatText or "Enemigo derrotado. El camino queda despejado.",94,130,452,P.ink)
            self:text("Vida de Rudy: "..self.enc.player.hp.." / "..self.enc.player.maxHp.."     Turnos: "..self.enc.turn,94,164,452,P.green)
            self:text("RECOMPENSAS",94,178,452,P.gold)
            self:text(self:rewardText(),94,195,452,P.ink)
            local unlock=self.enc.enemy.reward and type(self.enc.enemy.reward)=="table" and self.enc.enemy.reward.unlock
            if not app.practice and app.session.checkpoint=="day1_tutorial" and not app.session.unlocked.self_joke then unlock={"self_joke"} end
            if unlock and #unlock>0 then
                local names={};for _,id in ipairs(unlock) do names[#names+1]=(CardData.byId[id] or {}).name or id end
                self:text("Cartas: "..table.concat(names,", "),94,230,452,P.teal)
            end
            self:button("Continuar [Enter]",184,272,273,28,function() self:continue() end)
        else
            self:text("Causa: "..(self.enc.cause or self.enc.defeatReason or (self.enc.player.hp<=0 and "Rudy se quedó sin vida." or "La anomalía agotó el tiempo del combate.")),94,132,452,P.rose)
            self:text("Turnos sobrevividos: "..self.enc.turn,94,176,452,P.ink)
            self:text("Tu partida sigue intacta. Reintentar restaura el estado previo y no duplica recompensas.",94,199,452,P.muted)
            self:button("Reintentar [Enter]",94,262,212,28,function() self:retry() end)
            self:button("Regresar al punto seguro",316,262,232,28,function() self:leave() end)
        end
        self:button("Historial [H]",447,306,110,18,function() self.historyOpen=true;self.keyboardFocus=nil end)
    end
    function s:drawPause()
        self:begin();rect(P.shadow,0,0,640,360,.8);W.panel(145,105,350,147)
        self:text("COMBATE EN PAUSA",161,118,318,P.gold,2,"center")
        self:button("Continuar [Esc]",166,158,308,27,function() self.pauseOpen=false;self.keyboardFocus=nil end)
        self:button(app.practice and "Salir de práctica" or "Guardar y volver al menú",166,196,308,27,function()
            if app.practice then app:endPractice() else app:save();app:menu() end
        end)
    end
    function s:drawTactics()
        self:begin();rect(P.shadow,0,0,640,360,.9);W.panel(40,18,560,324)
        self:text("TÁCTICAS CON "..self.enc.companion.name:upper(),55,30,530,P.gold,2)
        local recoveries=self.enc.companion.id=="sylphiette" and (self.enc.balanceVersion==1 and " Curación: una por turno." or
            (" Curaciones restantes: "..(Combat.rules.companionHealUses-self.enc.companionHeals)..".")) or ""
        self:text("Una acción de compañera por turno. Sus decisiones dependen del peligro y las heridas."..recoveries,55,58,530,P.muted)
        for i,t in ipairs(Combat.tactics) do
            local y=92+(i-1)*35
            local ok,why=Combat.canTactic(self.enc,t.id)
            self:button(t.name,55,y,235,28,function() self:tactic(t.id) end,not ok)
            self:text(ok and t.description or why,301,y+3,278,ok and P.ink or P.rose)
        end
        self:button("Volver [Esc / T]",202,309,235,23,function() self.tacticsOpen=false;self.keyboardFocus=nil end)
    end
    function s:draw()
        self:begin();app.resources:background(self.definition.background or "laboratory")
        rect(P.shadow,0,0,640,360,.28)
        self:drawHud();self:drawActors();self:drawGuide();self:drawHand()
        if self.enc.finished and not self:busy() then self:drawResult() end
        if self.pauseOpen then self:drawPause() end
        if self.tacticsOpen and self.enc.companion then self:drawTactics() end
        if self.historyOpen then self:drawHistory() end
    end
    function s:mousepressed(x,y,button) self:click(x,y,button) end
    function s:keypressed(key)
        if self.tacticsOpen then
            if key=="t" or key=="escape" then self.tacticsOpen=false;self.keyboardFocus=nil else self:navigate(key) end
            return
        end
        if self.historyOpen then
            if key=="h" or key=="escape" then self.historyOpen=false;self.keyboardFocus=nil
            elseif key=="left" then self.historyPage=math.max(1,self.historyPage-1)
            elseif key=="right" then self.historyPage=self.historyPage+1
            else self:navigate(key) end
            return
        end
        if key=="h" then self.historyOpen=true;self.historyPage=1;self.keyboardFocus=nil;return end
        if self.pauseOpen then
            if key=="escape" then self.pauseOpen=false;self.keyboardFocus=nil else self:navigate(key) end
            return
        end
        if key=="escape" and not self:busy() and not self.enc.finished then self.pauseOpen=true;self.keyboardFocus=nil;return end
        if self:busy() then return end
        if self:navigate(key) then return end
        local advance=key=="return" or key=="space" or key=="kpenter"
        if self.enc.finished then
            if advance then if self.enc.outcome=="victory" or self.enc.training then self:continue() else self:retry() end end
            return
        end
        if advance and self.tutorial and (self.tutorial.stage=="attack_result" or self.tutorial.stage=="enemy_result") then self:advanceGuide();return end
        local index=tonumber(key)
        if index and index>=1 and index<=3 then self:select(index)
        elseif key=="left" then self:select((self.selected-2)%math.max(1,#self.enc.hand)+1)
        elseif key=="right" then self:select(self.selected%math.max(1,#self.enc.hand)+1)
        elseif advance then self:play()
        elseif key=="e" then self:endTurn()
        elseif key=="d" then self:basic("defend")
        elseif key=="v" then self:basic("dodge")
        elseif key=="c" and self.enc.training then self:basic("counter")
        elseif key=="b" then self:breakSeal()
        elseif key=="t" and self.enc.companion then self.tacticsOpen=true;self.keyboardFocus=nil end
    end
    return s
end

return CombatScreen
