local Suite={}
function Suite.run()
    local Cards=require("src.systems.cards")
    local Data=require("src.data.cards")
    local Json=require("src.systems.json")
    local Tutorial=require("src.systems.tutorial")
    local Collection=require("src.screens.collection")
    local checked=0
    local function check(value,message) assert(value,message); checked=checked+1 end
    local status=require("src.screens.overlays").curseStatus
    check(status({active=true,voiceSealed=true,manaBlocked=true})=="Sin diagnóstico","El diario no revela la maldición antes de leer la carta")
    check(status({active=true,voiceSealed=true,manaBlocked=true,discoveredVoice=true})=="VOZ SELLADA","Descubrir la voz no anticipa el bloqueo mágico")
    check(status({active=true,voiceSealed=true,manaBlocked=true,discoveredVoice=true,discoveredMana=true})=="VOZ SELLADA · MANÁ BLOQUEADO","Diario muestra ambos descubrimientos")
    check(status({active=false,voiceSealed=false,manaBlocked=false,discoveredVoice=true,discoveredMana=true})=="VOZ RECUPERADA · MAGIA RECUPERADA","Diario refleja la cura después del antídoto")
    local icons=require("src.data.assets").cardIcons
    for _,technique in ipairs(require("src.data.combat_cards").list) do
        check(icons[technique.icon] and not technique.icon:match("^procedural"),"Técnica usa PNG existente: "..technique.id)
    end
    check(#Data.starterDeck==5,"Exactamente cinco cartas sociales iniciales")
    local seen,tones={},{}
    for _,card in ipairs(Data.list) do
        check(not seen[card.id] and card.phrases and card.tone and card.unlockRequirements,"Contrato de carta "..card.id)
        seen[card.id]=true; tones[card.tone]=true
    end
    for tone in pairs(Data.tones) do check(tones[tone],"Tono alcanzable "..tone) end
    check(Cards.validateDeck(Data.starterDeck),"Mazo inicial válido")
    check(Collection.validatePlayableDeck(Data.starterDeck),"El primer mazo tiene respuestas útiles para las tres esposas")
    local context={kind="conversation",character="sylphiette",curse={active=true},sceneId="home_test"}
    local enc=Cards.new(Data.starterDeck,context,function(n) return n end)
    for turn=1,3 do
        check(Cards.play(enc,1,turn)~=nil,"Acción real "..turn)
        check(Cards.play(enc,1,turn)==nil,"La misma acción no se duplica")
        local restored=Cards.restore(assert(Json.decode(assert(Json.encode(enc)))),Data.starterDeck,context)
        check(restored and restored.score==enc.score and restored.energy==enc.energy,"Restaurar mano corta sin duplicar")
    end
    check(enc.finished and #enc.hand==2,"Mazo de cinco llega al final sin bloquearse")
    local function preview(id,character)
        return Cards.preview({hand={id},context={kind="conversation",character=character}},1)
    end
    local eris,sylphy=preview("bold_reply","eris"),preview("bold_reply","sylphiette")
    check(eris.chemistry>0 and eris.trust==0 and sylphy.trust<0,"Respuesta audaz mejora solo amor; el contexto inapropiado conserva su penalización")
    check(eris.expression=="happy" and sylphy.expression=="angry","Reacciones coherentes con la decisión")
    check(preview("subtle_flirt","roxy").phrase~=preview("subtle_flirt","eris").phrase,"Frases por interlocutor")
    local nano=preview("subtle_flirt","nanahoshi")
    check(nano.trust==0 and nano.chemistry==0 and nano.expression=="angry","Nanahoshi reacciona sin romance")
    local card=Data.byId.be_honest; card.revealsSecret=true
    check(not Cards.canPlay({hand={card.id},energy=4,context=context},1),"Bloqueo explícito de un secreto prohibido")
    card.revealsSecret=nil
    local practice=Cards.new(Data.starterDeck,{kind="conversation",character="nanahoshi",socialTutorial=true},function(n)return n end)
    local state=Tutorial.restore(nil,practice)
    check(Tutorial.advance(state) and Tutorial.advance(state),"Tutorial avanza hasta elegir")
    check(not Tutorial.canAct(state,1),"Leer el tutorial no ejecuta una carta")
    Tutorial.select(state)
    check(Tutorial.canAct(state,1),"Práctica real habilitada tras seleccionar")
    print("Curse social: "..checked.." checks passed")
end
return Suite
