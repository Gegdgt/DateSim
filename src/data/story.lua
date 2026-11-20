-- Contenido de la Fase 1. Las escenas y elecciones no contienen lógica del motor.
local Story = {}

Story.scenes = {
    intro = {
        title = "Día 1 · Una baraja sin dueño",
        background = "laboratory",
        lines = {
            {speaker="narrator", text="Universidad de Ranoa. Una historia alternativa: Rudy y sus compañeros son adultos. Rudy está soltero. Faltan siete días para el Festival de las Seis Caras."},
            {speaker="rudeus", expression="neutral", text="Nanahoshi, encontré esta baraja entre las cajas del festival. Sus símbolos cambian cuando la toco."},
            {speaker="nanahoshi", expression="worried", text="Pertenece al Espejo de las Posibilidades. El artefacto muestra futuros posibles, pero está dañado. Si recibe el maná del festival, puede desbordarse."},
            {speaker="rudeus", expression="worried", text="Entonces tenemos siete días. ¿Las cartas nos dicen qué ocurrirá?"},
            {speaker="nanahoshi", expression="neutral", text="No. Responden a tus acciones. Elige qué decir y cómo investigar. Ninguna carta puede decidir por otra persona."},
            {speaker="nanahoshi", expression="neutral", text="Tu mazo tiene 10 cartas. Robas 3 al empezar. Hay 3 turnos y 4 puntos de energía para TODO el encuentro. Cada carta jugada se descarta y robas otra."},
            {speaker="nanahoshi", expression="worried", text="¡Una runa acaba de romperse! Juega una carta por turno. Si no puedes pagarla, puedes Tomar aire gratis. La energía no se recupera entre turnos."},
        },
    },
    day1_result = {
        title = "Día 1 · La primera anomalía",
        background = "laboratory",
        lines = {
            {speaker="nanahoshi", expression="neutral", text="La descarga se ha detenido. Las cartas reaccionan de forma distinta en una conversación y ante una anomalía mágica."},
            {speaker="rudeus", expression="worried", text="No basta con usar la carta más cara. Necesito pensar en la situación... y escuchar a quien tengo delante."},
        },
        resultKey = "day1_tutorial",
        resultLines = {
            success = {speaker="nanahoshi", expression="happy", text="Estabilizaste el círculo antes de que cediera. Hemos conservado una lectura clara de las runas."},
            partial = {speaker="nanahoshi", expression="worried", text="Mi cierre de emergencia contuvo la descarga. Se perdieron algunas lecturas, pero ya sabemos cómo seguir. Puedes aprender sin quedar atrapado."},
        },
    },
    day1_close = {
        title = "Día 1 · Tres sellos",
        background = "courtyard",
        lines = {
            {speaker="cliff", expression="neutral", text="He revisado la inscripción. Memoria, Verdad y Voluntad: tres sellos mantienen unido el espejo."},
            {speaker="zanoba", expression="happy", text="¡Una obra extraordinaria! La base indica que el Sello de la Memoria está en las ruinas del jardín antiguo."},
            {speaker="rudeus", expression="neutral", text="Mañana hablaré con Sylphiette, Roxy y Eris. Quiero saber cómo están antes de pedirles ayuda."},
            {speaker="nanahoshi", expression="neutral", text="Descansa. Ya has aprendido a Reírte de ti mismo: esa carta queda en tu colección. Cambiar el mazo llegará en la Fase 2."},
        },
    },
    meet_sylphiette = {
        title = "Día 2 · Entre las hojas",
        background = "garden",
        lines = {
            {speaker="sylphiette", expression="happy", text="¡Rudy! Preparé té mientras cuidaba las plantas del festival. Me alegra que hayas venido sin que haya una emergencia."},
            {speaker="rudeus", expression="worried", text="Me alegra verte, Sylphie. Sí hay un problema con el espejo... pero también quería pasar un rato contigo."},
            {speaker="sylphiette", expression="neutral", text="Puedo ayudar. Aunque a veces temo que solo cuentes conmigo porque siempre digo que sí."},
            {speaker="rudeus", expression="neutral", text="Quiero que puedas hablarme con libertad. También cuando no estemos de acuerdo."},
        },
        choices = {
            {id="listen_first", label="Preguntarle qué necesita ella.", effects={character="sylphiette", trust=1, chemistry=0, decision="sylphiette_priority", value="listen"}},
            {id="share_time", label="Invitarla a compartir el té, sin prisas.", effects={character="sylphiette", trust=0, chemistry=1, decision="sylphiette_priority", value="time"}},
        },
    },
    result_sylphiette = {
        title = "Día 2 · Un lugar a tu lado",
        background = "garden",
        resultKey = "encounter_sylphiette",
        resultLines = {
            success = {speaker="sylphiette", expression="happy", text="Gracias por escucharme. Quiero caminar a tu lado porque lo elijo, no porque esperes que siempre esté disponible."},
            partial = {speaker="sylphiette", expression="neutral", text="Todavía me cuesta explicarlo. Podemos seguir hablando otro día. Gracias por quedarte este rato."},
        },
        lines = {
            {speaker="rudeus", expression="neutral", text="Si vienes a las ruinas, decidiremos juntos. Tu opinión cuenta tanto como la mía."},
            {speaker="sylphiette", expression="happy", text="Entonces cuenta conmigo. Y la próxima vez prepararás tú el té."},
        },
    },
    meet_roxy = {
        title = "Día 2 · Una mesa entre iguales",
        background = "library",
        lines = {
            {speaker="roxy", expression="neutral", text="Rudeus. He encontrado una referencia al espejo entre los registros de Ranoa. Puedes sentarte; no tienes que saludarme como a un tribunal."},
            {speaker="rudeus", expression="happy", text="Es difícil dejar de pensar en usted como mi maestra."},
            {speaker="roxy", expression="worried", text="Lo fui. Pero ahora somos dos adultos estudiando el mismo problema. Si me colocas en un pedestal, no podrás ver cuándo necesito ayuda."},
            {speaker="rudeus", expression="neutral", text="Tienes razón, Roxy. Empecemos de nuevo."},
        },
        choices = {
            {id="compare_notes", label="Contrastar nuestras notas como colegas.", effects={character="roxy", trust=1, chemistry=0, decision="roxy_equality", value="colleagues"}},
            {id="invite_break", label="Proponer un descanso para conocernos mejor.", effects={character="roxy", trust=0, chemistry=1, decision="roxy_equality", value="personal"}},
        },
    },
    result_roxy = {
        title = "Día 2 · Aprender del otro",
        background = "library",
        resultKey = "encounter_roxy",
        resultLines = {
            success = {speaker="roxy", expression="happy", text="Tu interpretación me ha hecho revisar la mía. Así sí podemos trabajar: dos personas que tienen algo que aprender."},
            partial = {speaker="roxy", expression="neutral", text="No hemos aclarado todas las runas. Podemos volver a ellas con calma; prefiero una duda honesta a una respuesta apresurada."},
        },
        lines = {
            {speaker="rudeus", expression="neutral", text="Las ruinas del jardín guardan el primer sello. Me gustaría contar con tu criterio allí."},
            {speaker="roxy", expression="happy", text="Acepto. Siempre que puedas decirme que me equivoco cuando sea necesario."},
        },
    },
    meet_eris = {
        title = "Día 2 · Junto al campo de práctica",
        background = "training",
        lines = {
            {speaker="eris", expression="happy", text="¡Rudeus! Estás justo a tiempo. Sostén este blanco mientras termino la serie."},
            {speaker="rudeus", expression="worried", text="¿Puedo colocarlo detrás de una barrera primero? Me gustaría conservar todos mis dedos."},
            {speaker="eris", expression="happy", text="¡Claro! Tampoco quiero entrenar sola. He oído lo del espejo. Iré contigo si hace falta."},
            {speaker="eris", expression="neutral", text="Pero no decidas por mí qué es demasiado peligroso. Podemos protegernos los dos."},
        },
        choices = {
            {id="mutual_support", label="Acordar cómo cubrirnos el uno al otro.", effects={character="eris", trust=1, chemistry=0, decision="eris_support", value="mutual"}},
            {id="friendly_challenge", label="Aceptar un pequeño reto amistoso.", effects={character="eris", trust=0, chemistry=1, decision="eris_support", value="challenge"}},
        },
    },
    result_eris = {
        title = "Día 2 · Dos formas de ser fuerte",
        background = "training",
        resultKey = "encounter_eris",
        resultLines = {
            success = {speaker="eris", expression="happy", text="¡Así sí! Avisaste antes de mover la barrera y pude adaptarme. Formamos un buen equipo."},
            partial = {speaker="eris", expression="neutral", text="Nos falta práctica. La próxima vez dime qué intentas antes de lanzarte. Yo haré lo mismo."},
        },
        lines = {
            {speaker="rudeus", expression="neutral", text="El primer sello está en las ruinas. No sé qué encontraremos, pero no quiero cargar con todo solo."},
            {speaker="eris", expression="happy", text="Bien. Pedir apoyo también cuenta. Avísame cuando salgas."},
        },
    },
    seal_intro = {
        title = "Día 2 · El Sello de la Memoria",
        background = "ruins",
        lines = {
            {speaker="narrator", text="Rudy y {companion} cruzan el jardín antiguo. Una puerta sin cerradura responde al brillo de la baraja."},
            {speaker="rudeus", expression="worried", text="Las runas muestran recuerdos que no reconozco. El espejo intenta convertirlos en algo que desee creer."},
            {speaker="companion", expression="neutral", text="{companionAdvice}"},
            {speaker="rudeus", expression="neutral", text="No voy a prometer un futuro perfecto. Vamos a recuperar el sello, paso a paso."},
        },
    },
    seal_result = {
        title = "Día 2 · Un recuerdo verdadero",
        background = "ruins",
        resultKey = "seal_encounter",
        resultLines = {
            success = {speaker="companion", expression="happy", text="La barrera cedió sin romperse. ¡El sello está intacto! Mantuvimos el ritmo juntos."},
            partial = {speaker="companion", expression="worried", text="La barrera se cerró otra vez. Esperemos... mira, al dejar de forzarla aparece un paso. Podemos recoger el sello con cuidado."},
        },
        lines = {
            {speaker="rudeus", expression="happy", text="Lo tenemos: el Sello de la Memoria. No muestra una vida ideal. Solo lo que realmente hemos compartido."},
            {speaker="companion", expression="happy", text="{companionMemory}"},
        },
    },
    day2_close = {
        title = "Día 2 · Lo que elegimos recordar",
        background = "laboratory",
        lines = {
            {speaker="nanahoshi", expression="happy", text="El primer sello está a salvo. El espejo sigue inestable, pero ya no absorbe maná de esta sala."},
            {speaker="zanoba", expression="neutral", text="La siguiente inscripción señala unas ruinas en el bosque. Deben de custodiar el Sello de la Verdad."},
            {speaker="cliff", expression="neutral", text="Yo vigilaré el laboratorio esta noche. Todos necesitamos descansar antes de seguir."},
            {speaker="rudeus", expression="neutral", text="Hoy elegí compartir el camino con {companion}. Aún no sé qué futuro quiero. Sí sé que debo construirlo con mis decisiones."},
            {speaker="narrator", text="Fin del contenido jugable de la Fase 1. Tu progreso queda guardado. Los días 3 a 7, las rutas y los finales se desarrollarán en las siguientes fases."},
        },
    },
}

Story.encounters = {
    day1_tutorial = {title="La runa desbordada", kind="magic", character=nil, background="laboratory", intro="Contén la anomalía. Magia e iniciativa ayudan; puedes Tomar aire gratis.", targetScore=5},
    encounter_sylphiette = {title="Escucharnos de verdad", kind="conversation", character="sylphiette", background="garden", intro="Sylphie quiere poder contar contigo sin dejar de elegir por sí misma.", targetScore=5},
    encounter_roxy = {title="Entre colegas", kind="investigation", character="roxy", background="library", intro="Investiga junto a Roxy: honestidad, ideas y espacio para las dudas.", targetScore=5},
    encounter_eris = {title="Cubrirnos la espalda", kind="conversation", character="eris", background="training", intro="Eris valora la franqueza y la iniciativa. Acuerden cómo apoyarse.", targetScore=5},
    seal_encounter = {title="La puerta de los recuerdos", kind="magic", character="companion", background="ruins", intro="Recupera el Sello de la Memoria con tu acompañante.", targetScore=5},
}

Story.locations = {
    {character="sylphiette", title="Jardín de Ranoa", description="Sylphiette · Confianza y compañerismo", background="garden"},
    {character="roxy", title="Biblioteca", description="Roxy · Admiración e igualdad", background="library"},
    {character="eris", title="Campo de práctica", description="Eris · Desafío y apoyo mutuo", background="training"},
}

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
