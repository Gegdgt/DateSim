# Fase 2: capítulos declarativos y Día 3

> Documento histórico de la continuidad anterior. Sus límites de tres días, siete finales previstos y vínculos de 0–10 ya no describen el juego actual. Consulta [README](../README.md), [reestructuración](REESTRUCTURACION.md) y [capítulos actuales](CAPITULOS.md).

Esta entrega amplía la Fase 1 con **Ecos del pasado**, un día tres completo para Sylphiette, Roxy o Eris. Los días cuatro a siete permanecen registrados como futuros capítulos, sin escenas accesibles. Las reglas de cartas y los recursos gráficos existentes se conservan.

## Arquitectura implementada

| Módulo | Responsabilidad |
| --- | --- |
| `src/data/chapters.lua` | Registro de capítulos; construye el catálogo único de checkpoints, escenas, encuentros, lugares y resúmenes |
| `src/data/chapters/day1.lua` y `day2.lua` | Contenido y transiciones de Fase 1, con los mismos identificadores y claves de eventos |
| `src/data/chapters/day3.lua` | Narrativa completa del tercer día, variantes, elección de compañía, encuentro y recompensas |
| `src/data/story.lua` | Fachada compatible con las API que ya consumían los datos de historia |
| `src/systems/progression.lua` | Interpreta transiciones, requisitos y efectos; resuelve compañía y variantes por capítulo |
| `src/systems/conditions.lua` | Lenguaje limitado a datos: eventos, decisiones, vínculos, ruta y combinaciones lógicas |
| `src/systems/narrative_validator.lua` | Comprueba referencias, condiciones y salidas de la estructura narrativa |
| `src/systems/save.lua` | Valida checkpoints y decisiones contra el registro; conserva el esquema de guardado versión 1 |
| `src/screens/hub.lua`, `summary.lua` | Muestran la preparación y el cierre declarados por el capítulo activo |

La guía [CAPITULOS.md](CAPITULOS.md) contiene los campos y ejemplos para ampliar la historia. Los datos no incluyen funciones para evaluar condiciones; el motor utiliza operadores conocidos y efectos con claves estables.

## Flujo del Día 3

```text
phase_complete: resumen del día dos
  |
  +-- Continuar al Día 3
       |
       v
day3_intro: laboratorio, nueva pista
       |
       v
day3_companion: elegir Sylphiette / Roxy / Eris
       |
       v
day3_forest: conversación y decisión propia del personaje
       |
       v
day3_illusion: el espejo representa su temor
       |
       v
day3_encounter: tres turnos de cartas
       |
       +-- éxito ----+
       +-- parcial --+--> day3_result
                              |
                              v
                         day3_truth: comprender y recuperar el sello
                              |
                              v
                         day3_return: regreso a Nanahoshi
                              |
                              v
                         day3_complete: resumen terminal
                         Día 4 pendiente, sin transición jugable
```

## Escenas y variantes

1. **Una nueva pista:** Nanahoshi explica la inscripción revelada por el Sello de la Memoria; Cliff identifica las ruinas al norte de Sharia. Rudy prepara la expedición.
2. **Elegir acompañante:** el patio permite elegir de nuevo a cualquiera de las tres. La pantalla explica las ventajas narrativas de cada compañía.
3. **Camino al bosque:** Sylphiette habla del miedo a otra separación; Roxy duda de su interpretación del espejo; Eris teme no poder proteger a sus compañeros. Cada variante contiene dos respuestas que conceden +1 confianza o +1 química.
4. **La ilusión del pasado:** Sylphiette ve a Rudy marcharse sin despedirse; Roxy presencia un experimento que parece haber fallado por su culpa; Eris ve una derrota que deja desprotegido al grupo.
5. **Romper el eco:** el encuentro usa conversación con Sylphiette, investigación con Roxy y magia con Eris. Los efectos por contexto y afinidad siguen siendo los del motor existente.
6. **Una grieta en la visión y Sello de la Verdad:** el éxito permite identificar pronto las contradicciones; el resultado parcial exige detenerse y pierde parte de las lecturas. Ambas ramas permiten continuar. El grupo comprende que el espejo mezcla recuerdos, deseos y temores.
7. **Regreso a Ranoa:** Rudy entrega el sello, Nanahoshi y Cliff encuentran un mapa estelar y señalan el observatorio. El resumen anuncia el día cuatro sin intentar abrirlo.

## Reglas, vínculos y recompensas

El encuentro conserva mazo de diez, mano inicial de tres, tres turnos, cuatro puntos de energía total, costes de cero a dos, robo, descarte y acción gratuita. El objetivo base es 5 de avance. Si la confianza del acompañante es al menos 4, un ajuste declarado en el encuentro reduce el objetivo a 4. No cambia energía, número de acciones ni efectos de las cartas.

La elección del tercer día se guarda en `decisions.day3_companion`; la del segundo conserva `decisions.companion`. Ninguna fija una ruta romántica. La respuesta del bosque se registra en `choice_day3_forest` y `day3_support`, y el resultado en `outcome_day3_encounter`.

Al salir de `day3_truth`, el evento único `seal_truth` concede +1 confianza y el evento de relación `truth_seal`. También asegura que `remember` esté desbloqueada: es la carta normal ya obtenida durante el día dos, no una carta nueva ni una segunda copia. La recompensa no se repite al guardar, cargar o volver a la escena. `shared_magic`, `combined_spell`, `sword_magic` y `choose_together` no se desbloquean en este capítulo.

## Compatibilidad de partidas

El formato sigue siendo versión 1. Se conservaron los checkpoints, decisiones y eventos de Fase 1. `phase_complete` continúa siendo el resumen del día dos; al cargar permanece allí y ofrece un botón para avanzar al tercero. La transición a `day3_intro` no vuelve a conceder recompensas del día dos.

El guardado deriva el día del checkpoint registrado, valida las decisiones contra la variante correspondiente y restaura el contexto del encuentro desde el capítulo. Si falta una compañía necesaria, vuelve al selector de ese capítulo sin borrar la elección histórica de otro día. `day3_complete` se conserva como cierre terminal hasta que exista el día cuatro.

## Verificación y pendientes

Se mantienen las suites de Fase 1. `tests/chapters.lua` añade fixtures de partidas anteriores, doce recorridos del tercer día, condiciones, datos inválidos e idempotencia. `tests/phase2_integration.lua` continúa las pantallas de Fase 1 y abre guardados del cierre anterior para las tres compañías, con capturas de las escenas nuevas. Los resultados ejecutados y sus límites se registran únicamente en [VERIFICACION.md](VERIFICACION.md).

El siguiente incremento narrativo es **Día 4: La torre de los caminos**, en el observatorio, con el Sello de la Voluntad. [CAPITULOS.md](CAPITULOS.md) describe cómo registrar el módulo y abrir la continuación de `day3_complete` cuando su destino exista. Siguen pendientes los días cinco a siete, selección de ruta, confesiones, escenas de finales, editor de mazo y distribución autónoma. La actualización de [experiencia](EXPERIENCIA.md) ya incorpora tutorial, animaciones y audio original sintetizado; las pistas definitivas grabadas siguen pendientes.
