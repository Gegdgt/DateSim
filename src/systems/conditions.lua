-- Lenguaje cerrado de requisitos narrativos: solo tablas y valores, nunca código.
local Characters=require("src.data.characters")
local Conditions={}
local function scalar(value)
    local kind=type(value)
    return kind=="string" or kind=="boolean" or (kind=="number" and value==value and math.abs(value)<math.huge)
end
local function identifier(value) return type(value)=="string" and value:match("^[%w_]+$")~=nil end
local function list(value)
    if type(value)~="table" or #value==0 then return false end
    for key in pairs(value) do if type(key)~="number" or key%1~=0 or key<1 or key>#value then return false end end
    return true
end

function Conditions.validate(condition)
    local seen={}
    local function validate(node,depth)
        if node==nil then return true end
        if type(node)~="table" or depth>24 or seen[node] then return false,"Condición inválida o demasiado profunda." end
        seen[node]=true
        local kind,allowed
        for _,candidate in ipairs({"all","any","not","event","decision","relationship","affinity","route","marriage","familyReady"}) do
            if node[candidate]~=nil then
                if kind then return false,"Una condición debe declarar un solo operador." end
                kind=candidate
            end
        end
        if not kind then return false,"Operador de condición desconocido." end
        if kind=="all" or kind=="any" then
            allowed={[kind]=true}
            if not list(node[kind]) then return false,"all/any requiere una lista no vacía." end
            for _,child in ipairs(node[kind]) do
                local ok,err=validate(child,depth+1)
                if not ok then return false,err end
            end
        elseif kind=="not" then
            allowed={['not']=true}
            local ok,err=validate(node['not'],depth+1)
            if not ok then return false,err end
        elseif kind=="event" then
            allowed={event=true,equals=true}
            if not identifier(node.event) or (node.equals~=nil and type(node.equals)~="boolean") then
                return false,"Evento o comparación de evento inválidos."
            end
        elseif kind=="decision" then
            allowed={decision=true,equals=true,oneOf=true}
            if not identifier(node.decision) or (node.equals~=nil)==(node.oneOf~=nil) then
                return false,"Una decisión requiere equals o oneOf."
            end
            if node.oneOf~=nil then
                if not list(node.oneOf) then return false,"oneOf requiere una lista no vacía." end
                for _,value in ipairs(node.oneOf) do if not scalar(value) then return false,"Valor inválido en oneOf." end end
            elseif not scalar(node.equals) then return false,"Valor inválido en equals." end
        elseif kind=="relationship" then
            allowed={relationship=true,trust=true,chemistry=true,love=true,personalEvent=true,commitment=true}
            local character=Characters.byId[node.relationship]
            if node.relationship~="companion" and not (character and character.romance) then return false,"Relación desconocida." end
            if node.trust==nil and node.chemistry==nil and node.love==nil and node.personalEvent==nil and node.commitment==nil then return false,"La relación necesita un umbral." end
            if node.personalEvent~=nil and not identifier(node.personalEvent) then return false,"Evento personal inválido." end
            if node.commitment~=nil and type(node.commitment)~="boolean" then return false,"Compromiso inválido." end
            for _,field in ipairs({"trust","chemistry","love"}) do
                local value=node[field]
                if value~=nil and (type(value)~="number" or value~=value or value<0 or value>100) then
                    return false,"Umbral de relación fuera de 0 a 100."
                end
            end
        elseif kind=="affinity" then
            allowed={affinity=true,trust=true,interest=true}
            if type(node.affinity)~="string" or not require("src.systems.affinity").config[node.affinity] then return false,"Afinidad desconocida." end
            if node.trust==nil and node.interest==nil then return false,"La afinidad necesita un umbral." end
            for _,field in ipairs({"trust","interest"}) do
                local value=node[field]
                if value~=nil and (type(value)~="number" or value~=value or value<0 or value>100) then return false,"Umbral de afinidad fuera de 0 a 100." end
            end
        elseif kind=="marriage" then
            allowed={marriage=true,viable=true}
            if not (Characters.byId[node.marriage] and Characters.byId[node.marriage].romance) or type(node.viable)~="boolean" then return false,"Estado matrimonial inválido." end
        elseif kind=="familyReady" then
            allowed={familyReady=true}
            if type(node.familyReady)~="boolean" then return false,"Estado familiar inválido." end
        elseif kind=="route" then
            allowed={route=true}
            if not (Characters.byId[node.route] and Characters.byId[node.route].romance) then return false,"Ruta desconocida." end
        end
        for key in pairs(node) do if not allowed[key] then return false,"Campo de condición desconocido: "..tostring(key) end end
        seen[node]=nil
        return true
    end
    return validate(condition,1)
end

function Conditions.evaluate(session,condition,context)
    if not Conditions.validate(condition) then return false end
    session,context=session or {},context or {}
    local function evaluate(node)
        if node==nil then return true end
        if node.all then
            for _,child in ipairs(node.all) do if not evaluate(child) then return false end end
            return true
        elseif node.any then
            for _,child in ipairs(node.any) do if evaluate(child) then return true end end
            return false
        elseif node['not'] then return not evaluate(node['not'])
        elseif node.event then
            local expected=node.equals~=false
            return ((session.events or {})[node.event]==true)==expected
        elseif node.decision then
            local value=(session.decisions or {})[node.decision]
            if node.oneOf then
                for _,candidate in ipairs(node.oneOf) do if value==candidate then return true end end
                return false
            end
            return value==node.equals
        elseif node.relationship then
            local character=node.relationship=="companion" and context.companion or node.relationship
            local value=(session.relationships or {})[character]
            return value~=nil and (value.trust or 0)>=(node.trust or 0) and (value.chemistry or value.love or 0)>=(node.chemistry or 0)
                and (value.love or value.chemistry or 0)>=(node.love or 0)
                and (not node.personalEvent or (value.events or {})[node.personalEvent]==true)
                and (node.commitment==nil or ((value.criticalDecisions or {}).commitment==true)==node.commitment)
        elseif node.affinity then
            local value=require("src.systems.affinity").get(session,node.affinity)
            return value~=nil and value.trust>=(node.trust or 0) and value.interest>=(node.interest or 0)
        elseif node.marriage then return (require("src.systems.relationships").canMaintain(session.relationships,node.marriage)==true)==node.viable
        elseif node.familyReady~=nil then return (require("src.systems.relationships").canUnite(session.relationships)==true)==node.familyReady
        elseif node.route then return session.route==node.route end
        return false
    end
    return evaluate(condition)
end

return Conditions
