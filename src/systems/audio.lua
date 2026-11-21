local Manifest=require("src.data.audio")
local Options=require("src.systems.options")
local Audio={}
Audio.__index=Audio

local function frequency(note) return 440*2^((note-69)/12) end
local function wave(phase)
    -- Fundamental y armónico suaves: no hay muestras externas ni ruido aleatorio.
    return math.sin(phase)*.82+math.sin(phase*2)*.18
end

-- Se expone para comprobar muestras y exportarlas si se desea. Generación local
-- diferida: una fuente se sintetiza una vez, al usar por primera vez su contexto.
function Audio.synthesize(spec,music,newSoundData)
    local rate=22050
    local notes=spec.notes or {60,64,67,72}
    local beat=spec.beat or .7
    local duration=music and (#notes*beat) or (spec.duration or .12)
    local count=math.floor(duration*rate)
    local data=newSoundData(count,rate,16,1)
    local gain=music and .12 or (spec.gain or .16)
    local noteLength=music and beat or duration/#notes
    for i=0,count-1 do
        local time=i/rate
        local slot=math.min(#notes,math.floor(time/noteLength)+1)
        local elapsed=time-(slot-1)*noteLength
        local envelope=math.min(1,elapsed/.012)*math.max(0,1-elapsed/noteLength)^2
        local fundamental=frequency(notes[slot])
        local sample=wave(2*math.pi*fundamental*elapsed)*envelope
        if music then
            -- Bajo armónico discreto de la misma secuencia, también con envolvente.
            sample=sample*.75+math.sin(2*math.pi*fundamental*.5*elapsed)*envelope*.25
        end
        data:setSample(i,sample*gain)
    end
    return data
end

local function backend()
    return {
        getInfo=function(path) return love.filesystem.getInfo(path,"file") end,
        newSource=function(value,kind) return love.audio.newSource(value,kind) end,
        newSoundData=function(...) return love.sound.newSoundData(...) end,
    }
end

function Audio.new(options,config)
    config=config or {}
    return setmetatable({options=Options.normalize(options),manifest=config.manifest or Manifest,
        backend=config.backend or backend(),musicCache={},effectCache={},warnings={},warned={},
        time=0,lastEffects={},effectVoices={},context=nil,current=nil,outgoing=nil},Audio)
end

function Audio:warn(key,message)
    if self.warned[key] then return end
    self.warned[key]=true
    self.warnings[#self.warnings+1]=message
    print("[audio] "..message)
end

function Audio:volume(kind,gain)
    if self.options.muted then return 0 end
    return self.options.volume*(kind=="music" and self.options.musicVolume or self.options.effectsVolume)*(gain or 1)
end

function Audio:setOptions(options)
    self.options=Options.normalize(options)
    self:applyVolumes()
end

function Audio:applyVolumes()
    for _,voice in pairs({current=self.current,outgoing=self.outgoing}) do
        voice.source:setVolume(self:volume("music",voice.gain))
    end
    for _,voice in ipairs(self.effectVoices) do voice.source:setVolume(self:volume("effects")) end
end

function Audio:source(id,spec,music)
    local cache=music and self.musicCache or self.effectCache
    if cache[id]~=nil then return cache[id] or nil end
    local source
    if type(spec)=="table" and spec.path then
        local ok,info=pcall(self.backend.getInfo,spec.path)
        if ok and info then
            local success,value=pcall(self.backend.newSource,spec.path,music and "stream" or "static")
            if success then source=value else self:warn(id,"Audio inválido: "..spec.path.." ("..tostring(value)..")") end
        else self:warn(id,"No se encontró audio local: "..tostring(spec.path)) end
    end
    local synth=type(spec)=="table" and (music and spec.synth or (not spec.path and spec))
    if not source and synth then
        local ok,value=pcall(function()
            local data=Audio.synthesize(synth,music,self.backend.newSoundData)
            return self.backend.newSource(data,"static")
        end)
        if ok then source=value else self:warn(id,"Síntesis no disponible para "..id..": "..tostring(value)) end
    end
    if not source and not spec then self:warn(id,"Contexto o efecto sin audio: "..tostring(id)) end
    cache[id]=source or false
    return source
end

function Audio:setContext(context)
    if context==self.context then return false end
    self.context=context
    -- Un cambio rápido cancela la salida anterior: jamás hay más de dos pistas.
    if self.outgoing then self.outgoing.source:stop(); self.outgoing=nil end
    if self.current then
        self.outgoing={source=self.current.source,gain=self.current.gain,startGain=self.current.gain,age=0}
        self.current=nil
    end
    local source=context and self:source(context,self.manifest.music[context],true)
    if source then
        source:stop()
        source:setLooping(self.manifest.music[context].loop~=false)
        source:setVolume(0)
        source:play()
        self.current={source=source,gain=0,age=0}
    end
    return true
end

function Audio:effect(id)
    local spec=self.manifest.effects[id]
    if not spec then self:warn("effect:"..tostring(id),"Efecto desconocido: "..tostring(id)); return false end
    if self.options.muted or self:volume("effects")==0 then return false end
    if self.time-(self.lastEffects[id] or -math.huge)<(spec.cooldown or .09) then return false end
    -- El grupo de navegación comparte límite, aunque alterne ratón/teclado.
    if (id=="menu" or id=="card_select") and self.time-(self.lastNavigation or -math.huge)<.085 then return false end
    local prototype=self:source("effect:"..id,spec,false)
    if not prototype then return false end
    local ok,source=pcall(prototype.clone,prototype)
    if not ok or not source then self:warn("clone:"..id,"No se pudo reproducir "..id); return false end
    if #self.effectVoices>=4 then table.remove(self.effectVoices,1).source:stop() end
    source:setVolume(self:volume("effects"))
    source:play()
    self.effectVoices[#self.effectVoices+1]={source=source,remaining=spec.duration or .5}
    self.lastEffects[id]=self.time
    if id=="menu" or id=="card_select" then self.lastNavigation=self.time end
    return true
end

function Audio:update(dt)
    dt=math.max(0,dt or 0)
    self.time=self.time+dt
    local duration=math.max(.01,self.manifest.fadeDuration or .45)
    if self.current then
        self.current.age=self.current.age+dt
        self.current.gain=math.min(1,self.current.age/duration)
    end
    if self.outgoing then
        self.outgoing.age=self.outgoing.age+dt
        self.outgoing.gain=self.outgoing.startGain*math.max(0,1-self.outgoing.age/duration)
        if self.outgoing.age>=duration then self.outgoing.source:stop(); self.outgoing=nil end
    end
    for i=#self.effectVoices,1,-1 do
        local voice=self.effectVoices[i]
        voice.remaining=voice.remaining-dt
        if voice.remaining<=0 then voice.source:stop(); table.remove(self.effectVoices,i) end
    end
    self:applyVolumes()
end

function Audio:stop()
    if self.current then self.current.source:stop() end
    if self.outgoing then self.outgoing.source:stop() end
    for _,voice in ipairs(self.effectVoices) do voice.source:stop() end
    self.current,self.outgoing,self.context=nil,nil,nil
    self.effectVoices={}
end

return Audio
