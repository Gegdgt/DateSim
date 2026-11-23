# Exploración 3: actividades, cartas y dormitorios

Implementación sobre las fases de exploración 1 y 2, con LÖVE 11.5 / LuaJIT. Se conservan el controlador, los 14 mapas, sus conexiones y los recursos PNG/ASE. Las campañas antiguas sin prólogo explorable mantienen su agenda original.

## Contenido

Hay 45 actividades con IDs estables: E01–E15, R01–R15 y S01–S15. Incluyen 165 parejas de frase de Rudy y respuesta de su esposa, con expresión, animación, contexto emocional y consecuencias. Las 21 cartas sociales existentes tienen alguna actividad compatible. El [informe generado de cobertura](COBERTURA_ACTIVIDADES.md) enumera cada actividad, sus cartas y recompensas.

Las actividades se habilitan al completar la lectura de la carta, descubrir la maldición, visitar a Nanahoshi, recibir los mazos y terminar el tutorial. Los saludos permanecen gratuitos y no activan investigación, recompensas ni romance.

Después del saludo aparecen tres ofertas. La selección considera día, relación, oro, cartas equipadas, resultados anteriores y progreso narrativo; rota entre encuentros y pospone la última actividad completada cuando hay alternativas. El catálogo completo permite elegir otras opciones con sus requisitos visibles. E01 permanece en la oferta mientras falte el entrenamiento del día 1–5; R05 tiene prioridad durante la investigación pendiente. E15 requiere un duelo previo, incluidas las escenas de entrenamiento anteriores. S10 no se ofrece el día 7 porque su promesa exige otra jornada.

## Ejecución y recompensas

- Una confirmación reserva una de las tres interacciones diarias compartidas. Consultar, cancelar antes de confirmar, caminar y saludar no consume espacios.
- La mano mezcla hasta tres cartas compatibles del mazo social equipado. Las demás cartas permitidas se ven en el catálogo; si no llevas ninguna compatible, debes editar el mazo antes de reservar.
- Cada frase puede revisarse antes de usar la carta parlante. La elección modifica amor/confianza, registra decisiones y conflictos y anima las barras con los deltas aplicados. Los niveles 1–10 amplifican los efectos positivos; el límite diurno continúa siendo +10/+10 por esposa.
- E01, E02, E03, E04, E08, E09 y E15 usan el combate existente. Los duelos evalúan victoria, derrota honorable, derrota honesta o falta de esfuerzo repetida. Un error menor no provoca una separación. Las expediciones no entregan botín de victoria al retirarse.
- E10 y E13 exigen acertar dos de tres pulsaciones de Espacio en la franja verde. E13 cobra cinco monedas al confirmar.
- R03/R09 abren compras de libros y materiales, con precio y segunda confirmación. R04 reutiliza las mejoras con copias y oro. Terminar la consulta sin comprar no concede artículos. R07 cuesta cinco monedas y tiene un 65% de éxito configurable; el resultado se fija al iniciar y el fracaso no devuelve reactivos.
- Las copias de técnicas narrativas sólo se entregan si ya están desbloqueadas o se cumplieron sus requisitos. E06 enseña Defensa física después de los mazos iniciales. Los hitos de coordinación, investigación y hogar reutilizan las habilidades del sistema familiar.
- S03 cumple el recado familiar; S10 registra su promesa; S12 y S15 permiten hablar de responsabilidades y conflictos. Una disculpa no realiza automáticamente el recado.

La tercera interacción con la misma esposa sigue permitida y produce un comentario propio. El retorno conserva mapa, posición y dirección. Los premios y los recuerdos usan la reserva diaria como identificador; no se entregan dos veces al cargar.

Ejemplos a nivel 1, antes de modificadores y límites: una broma en E01 da +2 amor/+1 confianza; bromear mientras Eris expresa sus preocupaciones en E12 da −2/−2. Roxy acepta el coqueteo de R14 (+2/+1). Sylphie expresa su desacuerdo ante la evasión de responsabilidades de S12 (−2/−2). Los hitos de las actividades esperan al evento personal y al día de desbloqueo de las cartas matrimoniales especiales.

| Registro persistente | Uso |
|---|---|
| dayN_activity_I_card | Frase elegida, reacción y consecuencias sociales únicas |
| dayN_activity_I | Actividad terminada, botín y memoria de la experiencia |
| wife_activity_E01…S15 | Última elección de carta por actividad |
| activity_duel_result | Resultado real del duelo utilizado por la revancha |
| eris_training_day_N | Entrenamiento completado; cinco fechas habilitan a Orsted |
| family_errand | Promesa, fecha, cumplimiento o conflicto del recado |
| travelers_choice / household_turn | Decisión moral y responsabilidad doméstica |
| dayN_rest / night_N | Bonificación única de noche y elección de descanso |

## Descanso

Tras completar la historia del día hay que volver físicamente a casa. E junto a una cama abre una conversación breve y una confirmación final. Las camas están en los dormitorios de Eris, Roxy y Sylphie; el estudio no es un dormitorio matrimonial. El segundo piso ofrece un jergón para dormir solo, incluso si todas están separadas.

La ausencia diurna se procesa una vez: −20 amor/−20 confianza para cada esposa sin actividad compartida. El descanso no modifica el contador de visitas. Después se aplica hasta +10/+10 a la esposa elegida, fuera del límite diurno y respetando el máximo de 100. El resumen refleja las cantidades reales y guarda la jornada. Al avanzar, Rudy despierta en el lugar donde descansó. El Día 1 mantiene el despertar narrativo junto a la cama de Eris.

Una separación bloquea actividades, descanso romántico y participación en el equipo final. La despedida reutiliza el anillo PNG y los cuatro cuadros del caballo. Sylphie parte con Lucy; después se oculta el idle compartido de Zenith/Lucy, sin dejar un obstáculo invisible, y Norn explica que Zenith descansa en otra habitación.

## Estados

~~~mermaid
stateDiagram-v2
    Saludo --> Exploracion: prólogo pendiente
    Saludo --> Ofertas: tutorial completo
    Ofertas --> Confirmacion: examinar actividad
    Confirmacion --> Ofertas: cancelar
    Confirmacion --> Introduccion: reservar interacción
    Introduccion --> Mano: cartas del mazo equipado
    Mano --> VistaPrevia: elegir carta
    VistaPrevia --> Mano: cambiar
    VistaPrevia --> Respuesta: confirmar encantamiento
    Respuesta --> Ejecucion: combate / prueba / comercio / escena
    Ejecucion --> Resultado: evento único y recompensa
    Resultado --> Exploracion: conservar posición
    Exploracion --> Cama: historia diaria completa
    Cama --> Exploracion: cancelar
    Cama --> Resumen: confirmar noche una vez
    Resumen --> Despertar: guardar y avanzar
    Despertar --> Exploracion: dormitorio elegido
~~~

## Controles

| Acción | Control |
|---|---|
| Caminar | WASD / flechas |
| Saludar, examinar o descansar | E, cerca del personaje/objeto |
| Seleccionar carta de actividad | 1–3 o ratón |
| Revisar y confirmar | Enter / botones |
| Prueba de ritmo de Eris | Espacio |
| Minimapa / inventario / diario / estado | M / I / J / Tab |
| Catálogo desde el diario | J, después A |
| Agenda / volver al mapa | G |
| Guardar | F5 |
| Cancelar selección o volver | Esc |

## Archivos

Nuevos módulos de contenido: wife_activities.lua, wife_activities_eris.lua, wife_activities_roxy.lua, wife_activities_sylphie.lua y rest.lua en src/data.

Nuevos sistemas: src/systems/wife_activities.lua y src/systems/rest.lua. Nuevas pantallas: src/screens/wife_activities.lua y src/screens/rest.lua.

Integración: app, activities, daily, family, finale, progression, prologue, relationship_budget, save, exploration, agenda, upgrades, family_scene, state_manager y manual. Pruebas nuevas: tests/wife_activities.lua y tests/wife_activities_ui.lua; el recorrido de campaña existente ahora camina hasta la cama.

## Persistencia y comprobaciones

El guardado añade wifeActivities (encuentros, recuerdos y resultado pendiente), datos de mano/fase/compra/prueba en daily.active_activity y rest (noches, cama y despertar). Se validan reservas, pagos, cartas equipadas, resultados y eventos. Los combates siguen utilizando replay de comandos. Se conserva la semilla del mundo; no se regenera la mano ni el experimento al cargar.

Las pruebas ejecutan todas las respuestas, todos los tipos de actividad, los cuatro resultados de duelo, compras reales, mejora, límite diario, repetición, ausencias, camas físicamente accesibles, despertar y separación. Las pantallas se verifican con el renderizador real de LÖVE. Los resultados finales están en [VERIFICACION.md](VERIFICACION.md).

Capturas en tests/artifacts/wives-*.png: ofertas de Eris, catálogo, frase de Sylphie, confirmación de compra de Roxy, prueba de ritmo, dormitorio, confirmación de descanso, resumen y despertar.

| Evidencia visual | Archivo |
|---|---|
| Tres actividades de Eris | [Ofertas](../tests/artifacts/wives-eris-offers.png) |
| Catálogo completo | [Catálogo](../tests/artifacts/wives-catalog.png) |
| Frase contextual de Sylphie | [Vista previa](../tests/artifacts/wives-sylphie-card-preview.png) |
| Compra real con Roxy | [Confirmación](../tests/artifacts/wives-roxy-purchase-confirm.png) |
| Minidesafío de Eris | [Ritmo](../tests/artifacts/wives-eris-rhythm.png) |
| Acceso al descanso | [Dormitorio](../tests/artifacts/wives-roxy-bedroom-rest.png) |
| Conversación nocturna | [Confirmación de descanso](../tests/artifacts/wives-rest-confirm.png) |
| Ausencias y noche | [Resumen](../tests/artifacts/wives-night-report.png) |
| Despertar del día 2 | [Dormitorio de Roxy](../tests/artifacts/wives-roxy-next-morning.png) |
| Separación persistente | [Retrato gris](../tests/artifacts/wives-separated-portrait.png) |
| Caballo original y Lucy | [Despedida](../tests/artifacts/family-horse-sylphiette.png) |

| Requisitos de prueba del encargo | Comprobación |
|---|---|
| 1–3: prólogo y desbloqueo | Flags combinados; saludos sin historia, romance ni presupuesto |
| 4–9: catálogo y diálogos | 45 IDs, 15 por esposa, rotación, entrenamiento estable, 165 respuestas ejecutables |
| 10–13: cartas y relaciones | Decisiones guardadas, manos mezcladas, deltas reales, niveles y límite diurno |
| 14–16: ausencias y repetición | −20/−20 una vez, tres visitas permitidas y comentario propio |
| 17–18: comercio y combate | Recibos, cancelación, oro/copias, cuatro resultados de duelo y retorno al mapa |
| 19–24: descanso y persistencia | Caminos hasta camas, bonus separado, evento único, despertar, separación y carga |

## Pendiente heredado

El PNG del acceso Sharia–Universidad sigue mostrando un muro. Se mantiene el traslado interactivo bidireccional documentado en la fase 1; el portal físico continúa desactivado. Las expediciones de actividad usan los escenarios de combate existentes y regresan al mapa de origen. No se añaden nuevos mapas.

El verificador de recursos sigue informando de 18 avisos preexistentes en las cabeceras de capas ASE. Se conservan los archivos originales sin modificación.
