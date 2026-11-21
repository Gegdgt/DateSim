-- Fachada compatible: los contenidos pertenecen a sus capítulos.
local Chapters=require("src.data.chapters")
local Story={scenes=Chapters.scenes,encounters=Chapters.encounters,
    locations=Chapters.byId.day2.locations,hubs=Chapters.hubs,summaries=Chapters.summaries}

Story.companionNames = {sylphiette="Sylphiette", roxy="Roxy", eris="Eris"}
Story.companionAdvice = {
    sylphiette="Mírame, Rudy. Podemos comprobar juntos qué es real. No tienes que resolverlo sin ayuda.",
    roxy="La ilusión repite un patrón. Yo leeré la secuencia; tú comprueba mi hipótesis. Si falla, la revisamos.",
    eris="Yo cubriré el paso. Tú dime cuándo avanzar. Si uno se pierde, el otro lo trae de vuelta.",
}
Story.companionMemory = {
    sylphiette="Me quedaré con el té de esta mañana. Fue un momento pequeño, pero me escuchaste.",
    roxy="Recordaré esta investigación compartida. Tener preguntas a tu lado me resulta más fácil.",
    eris="Yo recordaré que confiamos en el otro. Y que todavía me debes otra ronda de entrenamiento.",
}

return Story
