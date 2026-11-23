local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Daily=require("src.systems.daily")
local Catalog=require("src.data.activities")
local Result=require("src.systems.commissions")
local Commissions={}
function Commissions.new(app,provider,returnTo)
    if require("src.systems.exploration").nearCharacter(app.session,provider) then
        require("src.systems.events").apply(app.session,Daily.key(app.session,"commissions_consulted"),{text="Consultaste los encargos de "..provider..".",context="daily"})
        app:save()
    end
    local s=Screen.new(app);s.kind="commissions";s.provider=provider;s.returnTo=returnTo or function()app:resume()end;s.selected=1
    s.tasks={}
    for _,def in ipairs(Catalog.favors) do
        if def.investment then for _,id in ipairs(def.providers) do if id==provider then s.tasks[#s.tasks+1]=def end end end
    end
    function s:request(help,instance)
        local def=self.tasks[self.selected]
        self.confirm={help=help,instance=instance,id=def.id,revision=app.session.economy.revision,cost=def.cost,chance=def.chance}
    end
    function s:confirmRequest()
        local c=self.confirm;if not c then return end
        local ok,err
        if c.instance then ok,err=Daily.accelerateFavor(app.session,c.instance)
        else ok,err=Daily.requestFavor(app.session,c.id,self.provider,c.help,c.revision) end
        self.confirm=nil;self.message=err
        if ok then app:save();app:presentRewards(function()app:switch(self)end) end
    end
    function s:draw()
        self:begin();app.resources:background("laboratory");W.panel(12,10,616,338)
        self:text("¿EN QUÉ QUIERES QUE TE AYUDE?",25,21,495,P.gold)
        self:button("Volver",515,15,100,26,self.returnTo)
        app.resources:portrait(self.provider,"neutral",27,54,1)
        self:text((self.provider=="cliff" and "Cliff" or "Zanoba").." · Oro "..app.session.gold.." · Espacios "..Daily.remaining(app.session).."/3",112,54,493,P.ink)
        for i,def in ipairs(self.tasks) do
            self:button(i..". "..def.title,112,73+(i-1)*25,498,23,function() self.selected=i;self.message=nil end,false,self.selected==i)
        end
        local def=self.tasks[self.selected]
        self:text("Coste: "..def.cost.." oro · Éxito: "..def.chance.." %",27,156,580,P.gold)
        self:text("Posible recompensa: "..def.reward,27,174,580,P.ink)
        self:text("Duración: 1 día. Ayudar: entrega hoy, misma probabilidad.\nRiesgo: perder "..(def.cost-def.refund).." oro si falla.",27,198,580,P.muted)
        local help=app.session.day==7
        local ok,err=Daily.favorAvailable(app.session,def.id,self.provider,help)
        self:button(help and "Solicitar y ayudar hoy" or "Solicitar para mañana",27,229,282,25,function()self:request(help)end,not ok)
        local pending,last
        for _,favor in ipairs(app.session.pending_favors) do if favor.provider==self.provider and favor.investment then
            last=favor;if favor.status=="pending" then pending=favor end
        end end
        if pending then
            self:button("Ayudar ahora (1 espacio)",322,229,288,25,function()self:request(true,pending.instance_id)end,
                Daily.remaining(app.session)<1 or app.session.daily.activities_locked or app.session.daily.active_activity~=nil)
        end
        self:text(self.message or (last and (Catalog.favorsById[last.id].title.." · "..Result.result(last))) or err or "Un encargo total al día, entre ambos talleres.",27,266,580,last and last.status=="delivered" and (last.success and P.teal or P.danger) or P.ink)
        self:text("1-3: tarea · ENTER: revisar · H: ayudar · ESC: volver",27,328,580,P.muted)
        if self.confirm then
            self.buttons={};W.panel(40,91,560,207)
            self:text(self.confirm.instance and "AYUDAR AL ENCARGO PENDIENTE" or "CONFIRMAR INVERSIÓN",57,103,524,P.gold)
            self:text(self.confirm.instance and "La inversión ya está pagada. No se cobra otra vez." or
                (def.title.."\nCoste: "..self.confirm.cost.." oro · Éxito: "..self.confirm.chance.." %\nPosible: "..def.reward.."\nPérdida si falla: "..(def.cost-def.refund).." oro."),57,125,524,P.ink)
            self:text(self.confirm.help and "Ayudar consumirá una interacción que podrías dedicar a tus esposas. Entrega hoy. No cambia el sorteo." or
                "Entrega al comenzar mañana. Puede fallar y perderse la inversión.",57,199,524,P.danger)
            self:button("Confirmar",57,260,250,26,function()self:confirmRequest()end)
            self:button("Cancelar",325,260,250,26,function()self.confirm=nil end)
        end
    end
    function s:keypressed(key)
        if key=="escape" then if self.confirm then self.confirm=nil else self.returnTo() end;return end
        if self.confirm then if key=="return" then self:confirmRequest() else self:navigate(key) end;return end
        local i=tonumber(key)
        if i and self.tasks[i] then self.selected=i;self.message=nil
        elseif key=="return" then
            local def=self.tasks[self.selected];local help=app.session.day==7
            local ok,err=Daily.favorAvailable(app.session,def.id,self.provider,help)
            if ok then self:request(help) else self.message=err end
        elseif key=="h" then
            for _,favor in ipairs(app.session.pending_favors) do if favor.provider==self.provider and favor.status=="pending" then self:request(true,favor.instance_id);break end end
        else self:navigate(key) end
    end
    return s
end
return Commissions
