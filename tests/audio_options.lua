local Suite={}

function Suite.run()
    local Audio=require("src.systems.audio")
    local Options=require("src.systems.options")
    local Manifest=require("src.data.audio")
    local Save=require("src.systems.save")
    local checked=0
    local function check(ok,message) assert(ok,message); checked=checked+1 end
    local function near(a,b) return math.abs(a-b)<.00001 end
    local d=Options.normalize()
    check(d.volume==.6 and d.musicVolume==.45 and d.effectsVolume==.55,"Volúmenes iniciales")
    check(d.textSpeed==50 and d.textAnimation and not d.reducedMotion,"Lectura y movimiento iniciales")
    check(not d.tutorialCompleted and not d.fullscreen,"Guía y pantalla iniciales")
    local old=Options.normalize({volume=.2,muted=true})
    check(old.volume==.2 and old.muted and old.musicVolume==.45,"Compatibilidad con opciones antiguas")
    local bad=Options.normalize({volume=-5,musicVolume=9,effectsVolume=0/0,textSpeed=math.huge,
        muted="yes",textAnimation=false,reducedMotion=true,fullscreen=true,tutorialCompleted=true})
    check(bad.volume==0 and bad.musicVolume==1 and bad.effectsVolume==.55,"Normalizar volúmenes corruptos")
    check(bad.textSpeed==50 and not bad.muted and not bad.textAnimation,"Normalizar texto y booleanos")
    check(bad.reducedMotion and bad.fullscreen and bad.tutorialCompleted,"Persistir banderas accesibles")
    check(Options.normalize({textSpeed=1}).textSpeed==15 and Options.normalize({textSpeed=999}).textSpeed==100,"Límites de velocidad")

    local sources,samples={},0
    local function source()
        local s={plays=0,stops=0,volume=0,playing=false}
        function s:setVolume(v) assert(v>=0 and v<=1); self.volume=v end
        function s:setLooping(v) self.looping=v end
        function s:play() self.plays=self.plays+1; self.playing=true end
        function s:stop() self.stops=self.stops+1; self.playing=false end
        function s:clone() return source() end
        sources[#sources+1]=s
        return s
    end
    local fake={
        getInfo=function(path) if path=="broken.ogg" then return {size=3} end end,
        newSource=function(value) if value=="broken.ogg" then error("bad audio") end; return source() end,
        newSoundData=function(count,rate,bits,channels)
            assert(count>0 and rate==22050 and bits==16 and channels==1)
            return {setSample=function(_,i,value) assert(i>=0 and i<count and math.abs(value)<=.2); samples=samples+1 end}
        end,
    }
    local manager=Audio.new({volume=.8,musicVolume=.5,effectsVolume=.25},{backend=fake})
    check(manager:setContext("menu"),"Comenzar contexto musical")
    local first=manager.current.source
    check(first.plays==1 and first.looping and first.volume==0,"Música entra desde silencio y repite")
    manager:update(.225)
    check(near(first.volume,.2),"Fundido de entrada a mitad")
    manager:update(.225)
    check(near(first.volume,.4),"Maestro multiplicado una sola vez")
    check(not manager:setContext("menu") and first.plays==1,"No reiniciar el mismo contexto")
    check(manager:setContext("forest") and manager.outgoing.source==first,"Cambio inicia fundido cruzado intencional")
    local second=manager.current.source
    manager:update(.225)
    check(near(first.volume,.2) and near(second.volume,.2),"Dos pistas solo durante el fundido")
    manager:setContext("mystery")
    check(not first.playing and manager.outgoing.source==second,"Cambios rápidos detienen la salida antigua")
    manager:update(1)
    check(not second.playing and manager.outgoing==nil,"Fundido de salida termina y detiene la fuente")
    manager:setOptions({volume=.8,musicVolume=.5,effectsVolume=.25,muted=true})
    check(manager.current.source.volume==0,"Silencio afecta a música activa")
    check(not manager:effect("confirm"),"No crear efectos silenciados")
    local musicPlays=manager.current.source.plays
    manager:setOptions({volume=.8,musicVolume=.5,effectsVolume=.25})
    check(near(manager.current.source.volume,.4) and manager.current.source.plays==musicPlays,"Restaurar volumen sin reinicio")
    check(manager:effect("menu"),"Reproducir efecto original")
    check(near(manager.effectVoices[1].source.volume,.2),"Volumen independiente de efectos")
    check(not manager:effect("menu") and not manager:effect("card_select"),"Evitar saturación de navegación")
    manager:update(.1)
    check(manager:effect("card_select"),"Navegación disponible tras intervalo")
    for _,id in ipairs({"confirm","cancel","card_draw","card_play","positive","negative","magic","new_day",
        "text_blip","card_discard","scene_change","combat_start","attack","guard","hurt","heal","victory","defeat"}) do
        check(manager:effect(id),"Efecto sintetizado: "..id)
        check(#manager.effectVoices<=4,"Límite de voces: "..id)
    end
    manager:update(1)
    check(#manager.effectVoices==0,"Las voces finalizan")
    local contexts=0
    for id in pairs(Manifest.music) do
        manager:setContext(id); manager:update(1)
        check(manager.current and manager.current.source.playing,"Contexto musical original: "..id)
        contexts=contexts+1
    end
    check(contexts==17 and Manifest.music.training and samples>0,"Diecisiete contextos, incluido entrenamiento, contienen PCM sintetizado")
    manager:setContext("victory")
    check(manager.current.source.looping==false,"La fanfarria de victoria no se repite")
    manager:stop()
    check(not manager.current and not manager.outgoing and #manager.effectVoices==0,"Detener gestor libera voces")

    local missingManifest={music={absent={path="missing.ogg"},broken={path="broken.ogg"},
        fallback={path="missing.ogg",synth={notes={60,64},beat=.1}}},effects={}}
    local silent=Audio.new(nil,{backend=fake,manifest=missingManifest})
    check(silent:setContext("absent") and not silent.current,"Archivo ausente produce silencio seguro")
    check(#silent.warnings==1 and not silent:setContext("absent"),"Diagnóstico no se repite cada frame")
    check(silent:setContext("broken") and not silent.current,"Archivo inválido produce silencio seguro")
    check(silent:setContext("fallback") and silent.current~=nil,"Respaldo sintetizado declarado")
    check(silent:setContext("unknown") and not silent.current,"Contexto desconocido seguro")
    check(not silent:effect("unknown"),"Efecto desconocido seguro")
    silent:update(1); silent:stop()

    -- Comprueba muestras LÖVE reales; no depende de tener altavoces conectados.
    if love and love.sound then
        local pcm=Audio.synthesize(Manifest.effects.positive,false,love.sound.newSoundData)
        check(pcm:getSampleRate()==22050 and pcm:getChannelCount()==1,"Síntesis real mono 22050 Hz")
        check(pcm:getSampleCount()==math.floor(.25*22050),"Duración de efecto real")
        local maximum,nonzero=0,false
        for i=0,pcm:getSampleCount()-1 do
            local value=pcm:getSample(i)
            maximum=math.max(maximum,math.abs(value)); nonzero=nonzero or value~=0
        end
        check(nonzero and maximum<=.17,"Efecto contiene audio discreto sin clipping")
    end

    -- El runner usa identidad aislada; nunca se sobrescriben opciones del jugador.
    if love and love.filesystem and love.filesystem.getIdentity():match("_tests$") then
        local before=Save.readOptions()
        local requested=Options.normalize({volume=.27,musicVolume=.34,effectsVolume=.41,muted=true,
            textSpeed=75,textAnimation=false,reducedMotion=true,fullscreen=true,tutorialCompleted=true})
        check(Save.writeOptions(requested),"Guardar preferencias reales en disco aislado")
        local loaded=Save.readOptions()
        for key,value in pairs(requested) do check(loaded[key]==value,"Restaurar preferencia "..key) end
        check(Save.writeOptions(before),"Restaurar preferencias previas de pruebas")
    end
    print("Audio/options: "..checked.." checks passed (synthesis, fades, missing files and persistent preferences).")
    return checked
end

return Suite
