# Ampliar la campaña existente

Estos contratos corresponden a LÖVE 11.5, LuaJIT y al guardado v8 con extensiones opcionales de exploración. Mantén los IDs ya publicados: se utilizan en partidas guardadas, recuerdos y recibos. No renombres recursos para añadir contenido.

## Escenas y acontecimientos

1. Añade una escena a `src/data/chapters/dayN.lua`, con ID único, fondo, música, líneas, expresiones y decisiones. Revisa si `war_chapters.lua`, `final_chapters.lua` o `day_cycle.lua` instala una definición sobre ese ID; el registro efectivo se construye en `chapters.lua`.
2. Conecta todas sus salidas en `transitions`. Una condición necesita una alternativa alcanzable. Las escenas principales tienen coste narrativo cero; reserva las interacciones sólo mediante `Daily`.
3. Declara efectos usando `Events.apply(session, id, effects)` o el bloque `effects` de una transición. El ID impide repetir oro, cartas y consecuencias. No escribas premios en `draw`, en la animación de victoria o en el constructor de una pantalla.
4. Usa `delivery="thought"`, `"note"` o `"enchanted"` mientras la voz esté sellada. No reveles la maldición a una esposa antes de la cura. Hitogami sólo actúa físicamente mediante subordinados.
5. Una escena puede presentar a Cliff en el laboratorio sin cambiar `maps.*.npcs`. Al volver de una actividad se conserva `active.origin`; no reintroduzcas a Rudy mediante el spawn inicial.
6. Ejecuta el validador narrativo y añade una ruta de prueba que alcance cada salida. Prueba guardar antes de elegir y después del efecto. Usa `family_routes.lua` para respetar separaciones en escenas matrimoniales.

## Mapas, puertas y objetos

`exploration_assets.lua` declara recursos; `maps.lua`, geometría y placements; `map_connections.lua`, enlaces; `map_collisions.lua`, suelo y sólidos; `map_validation.lua`, comprobaciones. La posición lógica de Rudy se refiere a sus pies. La cámara y el movimiento permanecen en `systems/exploration.lua`.

Para un mapa nuevo, registra tamaño real, imagen, spawn transitable, NPC y objetos. Marca suelo revisado y obstáculos: las áreas desconocidas se consideran bloqueadas. Una puerta necesita trigger alcanzable y llegada libre **en ambos sentidos**. Un viaje sin abertura física debe ser un traslado interactivo explícito, como Sharia–Universidad. Nunca habilites una pared como puerta.

Revisa el PNG visualmente y añade pruebas de ruta con `tests/exploration_driver.lua`. La cuadrícula de QA usa `E.move` y las colisiones reales; no atravieses paredes asignando posiciones para afirmar que la ruta funciona. El minimapa deriva sus accesos del registro: no necesita otra lista manual.

Para un objeto, añade una definición en `data/world_content.lua`. Indica `collectible`, recompensa, restricciones narrativas y un ID de instancia estable. `Content.examine` aplica el evento `world_pickup_ID`. Para hallazgos diarios añade sólo posiciones a `sites` que superen `siteValid`. No mezcles `hitogami_letter` con el botín: delega siempre en `exploration_letter.lua` y `Prologue.readLetter`.

## NPC y conversaciones ambientales

Declara el sprite existente en `exploration_assets.lua` y coloca el NPC en `exploration_world.lua`. Ajusta el punto de pies y sólido de modo que Rudy pueda acercarse sin ocupar muebles. Añade sus reacciones a `ambient_dialogue.lua`, con texto completo y expresión válida; usa los filtros de día/introducción para evitar spoilers.

`Content.greeting` guarda la última variante por personaje. Los saludos no pasan por la reserva de actividad ni conceden relaciones. Antes de la carta Rudy saluda gestualmente. La selección Zenith/Lucy comparte el sprite compuesto; si se usa el sprite independiente de Lucy en una despedida, no dejes otro simultáneamente en la escena. Los NPC ausentes se derivan de `E.syncPresence`, no borrando placements del catálogo.

## Actividades y cartas

Las actividades nuevas se declaran en `wife_activities_eris.lua`, `_roxy.lua` o `_sylphie.lua` mediante el constructor de `wife_activities.lua`. Cada registro necesita ID estable, introducción, pregunta, emoción, requisitos, recompensa y respuestas contextuales completas. Cada respuesta incluye la frase de Rudy, contestación, expresión, animación, deltas y efectos de memoria.

No uses una frase universal concatenada con el título. Una carta sólo puede entrar en la mano si está adquirida, equipada y tiene respuesta en la actividad. `Wife.start` reserva un único espacio y fija mano/tirada; `choose` registra la decisión; `execute` abre servicio, combate, desafío o resultado; `finish` aplica el premio una vez. Las compras requieren recibo y confirmación separados. Las tareas necesarias para progresar deben permanecer accesibles en `offers` y en el catálogo completo.

Para añadir una carta, declara ID y reglas en `cards.lua` o `combat_cards.lua` y progresión en `card_progression.lua`. Define el evento de desbloqueo y sus requisitos; concede mediante `Events`/`Collection`, no activando directamente el mazo inicial. Una técnica exclusiva debe respetar la presencia de su compañera. Añade pruebas de costes, límite de nivel, copias gastadas y restauración.

Actualiza `tests/wife_activities.lua` y vuelve a generar `docs/COBERTURA_ACTIVIDADES.md` al cambiar contenido. El recuento de 45 actividades es intencional para esta campaña; una ampliación futura debe actualizarlo explícitamente junto con su cobertura.

## Economía, relaciones y descanso

Costes y probabilidades viven en datos, no en botones. `Economy.spend` requiere la revisión del saldo y devuelve un recibo. Los encargos fijan tirada y recompensa al solicitar, incluso si se acelera después. Nunca vuelvas a sortear en `restore` ni al mostrar el resultado.

Los efectos afectivos pasan por `RelationshipBudget` y `Relationships.record`; muestra el delta realmente aplicado. Los +10 nocturnos usan `nightRest=true`, fuera del límite diurno, después de contabilizar la ausencia. Las camas están en `data/rest.lua`; el estudio no se añade a esa lista. Una separación requiere los mecanismos narrativos de `Family`, y el jergón mantiene el avance cuando no hay esposa disponible.

## Combate, resumen y persistencia

El combate es un motor puro con replay. Una pantalla o controlador de campaña llama a `CampaignStats.beginBattle` al iniciar y a `finishBattle` al concluir; cargar o continuar no duplica el intento. No llames estos métodos para la práctica. Un reintento se registra como otro combate. Las recompensas siguen pasando por `Progression` o `Daily`, independientemente del registro estadístico.

Si añades una nueva forma de consumir un recurso que aparece en el resumen, emite un recibo identificable y actualiza `Stats.snapshot`: el stock final no equivale a la cantidad obtenida. Si un dato histórico no existe en un guardado antiguo, indícalo como incompleto; no lo reconstruyas con promedios ni recompensas teóricas.

Cada extensión persistente necesita un `restore` con límites, IDs válidos y coherencia con eventos/recibos. `Save.validate` se ejecuta antes de escribir. No cambies los nombres de los guardados anteriores ni los sobrescribas durante pruebas: las suites usan identidades LÖVE separadas.

## Ejecutar las comprobaciones

```powershell
$env:DATESIM_TEST_MODULE = 'wife_activities' # O campaign_stats, exploration, world_content...
& 'C:\Program Files\LOVE\lovec.exe' . --test

$env:DATESIM_TEST_MODULE = 'campaign_integration'
$env:DATESIM_CAMPAIGN_CASE = 'A' # A–I; quitar para todas
& 'C:\Program Files\LOVE\lovec.exe' . --test

$env:DATESIM_TEST_MODULE = $null
$env:DATESIM_CAMPAIGN_CASE = $null
$env:DATESIM_TEST_GROUP = $null
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

Los artefactos reales se escriben en `tests/artifacts/`: PNG del canvas, registros y sesiones de las simulaciones. No añadas imágenes generadas como sustituto de capturas del juego.
