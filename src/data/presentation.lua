-- Defaults centrales para tablas antiguas. Una escena puede sobreescribir music,
-- transition={type,duration}, entrance y cada línea animation/expression.
local Presentation={
    reactions={
        nanahoshi={positive="El pulso de la runa se estabiliza. Esa acción nos ha dado una lectura útil.",neutral="El pulso no ha cambiado. Podemos tomar aire y probar otra respuesta.",negative="La runa se ha vuelto más inestable. Revisemos qué ha fallado antes de seguir."},
        sylphiette={positive="Así me resulta más fácil hablar contigo, Rudy. Podemos seguir juntos.",neutral="Gracias por darme un momento. Todavía necesito ordenar lo que siento.",negative="Eso me ha dolido un poco. Prefiero que hablemos con calma."},
        roxy={positive="Buena observación, Rudy. Ya tenemos algo concreto con lo que trabajar.",neutral="No hemos aclarado esa parte. Detengámonos un momento y comparemos las pistas.",negative="Ese intento nos ha confundido más. Revisemos la idea antes de insistir."},
        eris={positive="Bien. Si actuamos juntos, podemos abrirnos camino.",neutral="Puedo esperar un momento. Pero sigamos atentos a lo que tenemos delante.",negative="¡Eso no ha funcionado! Respiremos y probemos otra cosa."},
    },
    backgrounds={laboratory="mystery",courtyard="university",library="casual",garden="casual",
        training="casual",forest="forest",ruins="mystery",observatory="mystery",
        mirror_dimension="mirror",festival="festival"},
    animations={enter_left=true,enter_right=true,happy_bounce=true,shake=true,
        small_shake=true,surprised_jump=true,sad_lower=true,angry_shake=true,
        expression_change=true,exit_left=true,exit_right=true,speaking=true},
    transitions={dream=true,fade=true,fade_in=true,horizontal=true,new_day=true,magic=true,["return"]=true},
}
function Presentation.music(node,definition)
    local def=definition or node.definition
    if def.ending then return "ending" end
    if node.id=="intro" then return "dream" end
    return def.music or (node.kind=="encounter" and "tension") or Presentation.backgrounds[def.background] or "casual"
end
function Presentation.reaction(character,result)
    local variant=Presentation.reactions[character] or Presentation.reactions.nanahoshi
    if not result then return variant.neutral end
    if result.score<0 or result.trust<0 or result.chemistry<0 then return variant.negative end
    return (result.score>0 or result.trust>0 or result.chemistry>0) and variant.positive or variant.neutral
end
return Presentation
