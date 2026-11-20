-- Small strict JSON codec. Never evaluates Lua from a save file.
local Json = {}
Json.null = {}
local escapes={['"']='\\"',['\\']='\\\\',['\b']='\\b',['\f']='\\f',['\n']='\\n',['\r']='\\r',['\t']='\\t'}
local function quote(s)
    return '"'..s:gsub('[%z\1-\31\\"]',function(c)
        return escapes[c] or string.format('\\u%04x',c:byte())
    end)..'"'
end
local function finite(n) return n==n and n~=math.huge and n~=-math.huge end

function Json.encode(value)
    local seen={}
    local function encode(v,depth)
        if depth>32 then error("JSON demasiado profundo") end
        if v==Json.null or v==nil then return "null" end
        local kind=type(v)
        if kind=="boolean" then return v and "true" or "false" end
        if kind=="number" then
            assert(finite(v),"Número JSON inválido")
            return string.format("%.17g",v)
        end
        if kind=="string" then return quote(v) end
        assert(kind=="table","Tipo JSON no compatible")
        assert(not seen[v],"Ciclo en tabla JSON")
        seen[v]=true
        local count,max=0,0
        local array=true
        for k in pairs(v) do
            count=count+1
            if type(k)~="number" or k%1~=0 or k<1 then array=false
            elseif k>max then max=k end
        end
        array=array and count>0 and count==max
        local parts={}
        if array then
            for i=1,max do parts[#parts+1]=encode(v[i],depth+1) end
        else
            local keys={}
            for k in pairs(v) do assert(type(k)=="string","Clave JSON inválida"); keys[#keys+1]=k end
            table.sort(keys)
            for _,k in ipairs(keys) do parts[#parts+1]=quote(k)..":"..encode(v[k],depth+1) end
        end
        seen[v]=nil
        return (array and "[" or "{")..table.concat(parts,",")..(array and "]" or "}")
    end
    local ok,result=pcall(encode,value,0)
    if not ok then return nil,result end
    return result
end

local function utf8(code)
    if code<=0x7f then return string.char(code) end
    if code<=0x7ff then return string.char(0xc0+math.floor(code/64),0x80+code%64) end
    if code<=0xffff then return string.char(0xe0+math.floor(code/4096),0x80+math.floor(code/64)%64,0x80+code%64) end
    return string.char(0xf0+math.floor(code/262144),0x80+math.floor(code/4096)%64,0x80+math.floor(code/64)%64,0x80+code%64)
end

function Json.decode(source)
    if type(source)~="string" then return nil,"Se esperaba texto JSON" end
    local pos,length=1,#source
    local function fail(message) error(message.." (posición "..pos..")",0) end
    local function skip()
        while pos<=length and source:sub(pos,pos):match("[ \t\n\r]") do pos=pos+1 end
    end
    local function readString()
        pos=pos+1
        local parts={}
        while pos<=length do
            local c=source:sub(pos,pos); pos=pos+1
            if c=='"' then return table.concat(parts) end
            if c=='\\' then
                local e=source:sub(pos,pos); pos=pos+1
                local map={['"']='"',['\\']='\\',['/']='/',b='\b',f='\f',n='\n',r='\r',t='\t'}
                if map[e] then parts[#parts+1]=map[e]
                elseif e=='u' then
                    local hex=source:sub(pos,pos+3)
                    if #hex~=4 or not hex:match('^%x%x%x%x$') then fail("Escape Unicode inválido") end
                    local code=tonumber(hex,16); pos=pos+4
                    if code>=0xd800 and code<=0xdbff then
                        if source:sub(pos,pos+1)~='\\u' then fail("Par Unicode incompleto") end
                        local low=tonumber(source:sub(pos+2,pos+5),16)
                        if not low or low<0xdc00 or low>0xdfff then fail("Par Unicode inválido") end
                        code=0x10000+(code-0xd800)*1024+(low-0xdc00); pos=pos+6
                    elseif code>=0xdc00 and code<=0xdfff then fail("Unicode inválido") end
                    parts[#parts+1]=utf8(code)
                else fail("Escape JSON inválido") end
            else
                if c:byte()<32 then fail("Control dentro de cadena JSON") end
                parts[#parts+1]=c
            end
        end
        fail("Cadena JSON sin cerrar")
    end
    local parse
    parse=function(depth)
        if depth>32 then fail("JSON demasiado profundo") end
        skip()
        local c=source:sub(pos,pos)
        if c=='"' then return readString() end
        if c=='{' or c=='[' then
            local object=c=='{'; local close=object and '}' or ']'
            pos=pos+1; skip()
            local out={}; local count=0
            if source:sub(pos,pos)==close then pos=pos+1; return out end
            while true do
                count=count+1
                if count>4096 then fail("Demasiados elementos JSON") end
                local key=count
                if object then
                    if source:sub(pos,pos)~='"' then fail("Clave JSON inválida") end
                    key=readString(); skip()
                    if out[key]~=nil then fail("Clave JSON repetida") end
                    if source:sub(pos,pos)~=':' then fail("Falta separador JSON") end
                    pos=pos+1
                end
                out[key]=parse(depth+1); skip()
                c=source:sub(pos,pos); pos=pos+1
                if c==close then return out end
                if c~=',' then fail("Falta coma JSON") end
                skip()
            end
        end
        for _,literal in ipairs({"true","false","null"}) do
            if source:sub(pos,pos+#literal-1)==literal then
                pos=pos+#literal
                if literal=="null" then return Json.null end
                return literal=="true"
            end
        end
        local rest=source:sub(pos)
        local token=rest:match('^-?%d+%.?%d*[eE][+-]?%d+') or rest:match('^-?%d+%.%d+') or rest:match('^-?%d+')
        if not token then fail("Valor JSON inválido") end
        if token:match('^-?0%d') or token:match('%.e') or token:match('%.E') then fail("Número JSON inválido") end
        local n=tonumber(token)
        if not n or not finite(n) then fail("Número JSON fuera de rango") end
        pos=pos+#token
        return n
    end
    local ok,result=pcall(parse,0)
    if not ok then return nil,result end
    skip()
    if pos<=length then return nil,"Contenido extra después del JSON" end
    return result
end
return Json
