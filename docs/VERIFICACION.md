# Verificación de cartas y economía — Fase 2

Fecha: **21 de noviembre de 2026**. Ejecución real con **LÖVE 11.5 / LuaJIT**, renderizador y audio. Se conservaron los 40 IDs, los mazos y todos los PNG y ASE originales; `git diff --check` no detecta errores de formato.

La validación se realizó en la suite general y en grupos focalizados. La ejecución general completó los módulos de recursos, sistemas, narrativa y **34 campañas**; al encontrar expectativas antiguas de valores fijos en las pruebas de interfaz, se actualizaron y se ejecutó nuevamente el grupo gráfico completo. Los últimos grupos `economy-ui`, `economy-campaign`, `narrative` y `ui` terminaron con **`ALL TESTS PASSED`, salida 0**. Los registros locales están en `tests/artifacts/economy-*.log`.

| Cobertura verificada | Resultado |
| --- | --- |
| Dominio de economía, niveles, migración y persistencia | 398 comprobaciones |
| Interfaz de mejora, sonido, duplicados y pulsaciones rápidas | 25 comprobaciones; 7 capturas |
| Campañas narrativas sin compras obligatorias | 33 031 comprobaciones; 34 recorridos, cinco finales |
| Campaña adicional con compras y mejoras reales | 939 comprobaciones; dos cartas N10 |
| Recorrido gráfico completo | 1 239 comprobaciones; 691 pasos |
| Combate gráfico e integración | 44 + 24 comprobaciones; 22 capturas |
| Narrativa focalizada tras migración | 73 + 2 788 + 277 comprobaciones; 41 capturas de diálogos |
| Combate y equilibrio existentes | 120 + 288 victorias simuladas |

La campaña de especialización obtuvo **2 007 de oro**, mejoró **Bastón y Dar ánimo a nivel 10** y terminó con **1 211 de oro**. No se inyectaron recursos ni relaciones para alcanzar esos niveles. Su estado serializado ocupó **222 567 bytes**, dentro del límite de lectura de guardados. Esta prueba verifica viabilidad económica; el ajuste subjetivo de dificultad y preferencias requiere sesiones con jugadores.

Se verificaron los costes de todas las clases, las 91 copias totales, las curvas monótonas de daño/escudo/curación, el máximo de nivel 10, la conservación del mazo, el gasto único y los requisitos insuficientes. Las pruebas de relaciones incluyen +5 reducido a +3, penalizaciones sin recuperar margen, límites independientes por esposa y reinicio de jornada. Un mazo N10 todavía pierde si ignora al enemigo.

La migración carga un archivo v4 desde disco, continúa una conversación ya iniciada y escribe v5 **sin modificar los bytes de v4**. También se comprueban conversaciones con acciones históricas y nuevas, respuestas pendientes, presupuestos agotados, guardados malformados y replay de combate con niveles. Los formatos v1/v2/v3 mantienen su importación explícita anterior.

Capturas inspeccionadas: [mejora](../tests/artifacts/economy-after.png), [nivel máximo y costes](../tests/artifacts/economy-maximum.png), [tienda](../tests/artifacts/economy-shop.png), [duplicados](../tests/artifacts/economy-duplicate.png) y [encargos](../tests/artifacts/daily-favors.png). Los artefactos de prueba están excluidos de Git. La identidad de pruebas está separada de la del jugador; cada grupo tiene su propia identidad.

## Registro anterior — Fase 1

Fecha: **21 de noviembre de 2026**. Suite completa ejecutada con **LÖVE 11.5 / LuaJIT**, gráficos y audio reales. Resultado: **40 123 comprobaciones en 21 módulos, `ALL TESTS PASSED`, salida 0**, en una única ejecución final.

| Cobertura | Comprobaciones |
| --- | ---: |
| Ciclo diario: 27 distribuciones, reservas, visitas, encargos, cierres y guardado | 1 010 |
| Interfaz de agenda: clics, teclado, carga pendiente y fallo de escritura | 33 |
| 34 campañas completas, cinco finales, combates y carga entre checkpoints | 30 087 |
| Recorrido de interfaz de campaña: 593 pasos | 1 080 |
| Recursos, audio, retratos, combate, diálogos, afinidad, entrenamiento y demás módulos | 7 913 |
| **Total de la ejecución final** | **40 123** |

La campaña incluye recorridos de siete jornadas sin actividades ordinarias, repitiendo únicamente a Roxy y repitiendo únicamente a Eris, con encargos diarios. Todos llegan al epílogo y resuelven sus encargos. Las pruebas de distribución cubren también tres visitas a Sylphiette y las 27 combinaciones de tres espacios. La cuarta actividad y el segundo encargo del día se rechazan. Las escenas narrativas tienen coste explícito cero.

El guardado real conserva reservas de actividades, decisiones, visitas, encargos pendientes, resúmenes y matrimonios. Repetir el cierre o cargar una recompensa entregada no vuelve a sumar cartas, energía ni confianza. Un fallo de escritura mantiene el resumen sin presentar hasta reintentar; el reintento no reaplica efectos. Se verificó la conservación de archivos v3 y el rechazo de un destino que contiene otra versión.

Se inspeccionaron las capturas del renderizador real: [agenda](../tests/artifacts/daily-agenda-start.png), [decisión pendiente](../tests/artifacts/daily-activity.png), [encargos](../tests/artifacts/daily-favors.png), [resumen](../tests/artifacts/daily-summary.png) y [Día 7](../tests/artifacts/daily-final-day.png). Hay siete capturas específicas de agenda, además de las de la campaña. Los PNG y los registros de ejecución son artefactos locales excluidos de Git.

Evidencia completa: [daily-phase-full.log](../tests/artifacts/daily-phase-full.log). Comando final desde la raíz, sin `DATESIM_TEST_GROUP` definido:

```powershell
& 'C:\Program Files\LOVE\lovec.exe' . --test 2>&1 | Tee-Object -FilePath tests/artifacts/daily-phase-full.log
```

La suite usa `cartas_del_destino_v4_tests` y las identidades aisladas de los módulos existentes. No se utilizaron las partidas del jugador. `git diff --check` terminó con salida 0. Los avisos de archivos PNG/audio inválidos o ausentes son fallos inyectados por las pruebas de recursos. No se realizaron pruebas de cortes físicos de energía ni sesiones prolongadas de balance con jugadores.

[Arquitectura y reglas implementadas](FASE_1_ACTIVIDADES.md). El registro que sigue corresponde a la entrega anterior de afinidad y entrenamiento; sus cifras y referencias a v3 son históricas.

---

# Registro anterior: afinidad, entrenamiento y memoria narrativa

Fecha: **21 de noviembre de 2026**. Motor: LÖVE para Windows, con gráficos, audio y LuaJIT reales. Se ejecutó el proyecto existente; no una traducción del juego a otro lenguaje.

## Resultado integrado

**31 757 comprobaciones correctas en los 19 módulos de la suite activa**, contando la última ejecución válida de cada módulo una sola vez. La ejecución general pasó los primeros 16 módulos y se detuvo en una espera incorrecta del arnés de interfaz. Tras corregirlo, la ejecución dirigida final pasó entrenamiento e interfaz con **1 595 comprobaciones, `ALL TESTS PASSED` y salida 0**. No se presenta como una única ejecución general con salida 0.

| Suite activa | Comprobaciones |
| --- | ---: |
| Recursos PNG, cuadros, transparencia, filtros y fallos controlados | 654 |
| Movimiento, texto UTF-8 y transiciones | 172 |
| Retratos contextuales, sueño, guardado/carga y despertar | 181 |
| Audio sintetizado, preferencias y fallos controlados | 101 |
| Matrimonios, guardado v3 e importación explícita | 100 |
| Combate y maldición | 1 620 |
| Balance por día, curación, intenciones y compatibilidad | 919 |
| Entrenamiento de Eris y evaluación del esfuerzo | 84 |
| Barras animadas, límites y feedback único | 138 |
| Afinidad de Nanahoshi, cinco cartas y compatibilidad | 260 |
| Entrenamiento en App, resultados, guardado y reconciliación | 444 |
| Introducción, documentos, secreto y cura | 34 |
| Cartas sociales, descubrimientos e iconos de combate | 73 |
| Diálogo ramificado, cobertura, memoria y manos aleatorias | 2 788 |
| Interfaz de diálogo, confirmación, reacciones y guardado | 277 |
| Campañas completas y finales | 22 845 |
| Presentación de combate | 44 |
| Persistencia e integración de combate | 24 |
| Recorrido por la interfaz real | 999 |
| **Total sin duplicar reejecuciones** | **31 757** |

El recorrido lógico completó **31 campañas** y alcanzó **los cinco finales**, guardando y cargando entre checkpoints, con decisiones y combates legales. Las pruebas de combate ganaron **120/120 simulaciones base y 288/288 simulaciones de campaña** con distintos mazos, enemigos, compañeras y semillas. El recorrido de interfaz completó **538 pasos de pantallas** hasta el desenlace familiar, además de renderizar los otros epílogos. Se generaron **41 capturas de diálogo, 22 de combate, 9 de barras y 18 de entrenamiento**, además de las 18 capturas de retratos contextuales.

## Comando y archivos de evidencia

La ejecución general utilizó la ruta absoluta del repositorio, sin `DATESIM_TEST_GROUP` definido:

```powershell
& 'C:\Program Files\LOVE\lovec.exe' 'C:\Users\gegdg\Documents\.UVG\Anio6\SegundoSemestre\GameEngine\DateSim' --test
# Equivalente desde la raíz del repositorio:
./probar.ps1
```

La primera ejecución detectó una expectativa antigua que contaba 16 contextos musicales en vez de los 17 actuales. Se actualizó la prueba para incluir `training`. [affinity-training-attempt1.log](../tests/artifacts/affinity-training-attempt1.log) conserva su stdout íntegro.

La siguiente ejecución general pasó todos los módulos anteriores al recorrido de interfaz, incluida la campaña de 31 rutas. Su arnés intentó pulsar otra vez una elección cuando el botón ya había desaparecido durante `pendingDeparture`/`leaving`. Se corrigió el arnés para esperar esa salida, sin modificar la mecánica del juego. [affinity-training-attempt2.log](../tests/artifacts/affinity-training-attempt2.log) conserva el stdout íntegro y el fallo; su código fue 1.

Después se verificaron de nuevo los módulos afectados y el recorrido completo de pantallas. Esta pasada también comprueba que cargar la valoración restaure la música de entrenamiento y que el historial del duelo diga «resistencia perdida»:

```powershell
$env:DATESIM_TEST_GROUP = 'training-ui'
& 'C:\Program Files\LOVE\lovec.exe' 'C:\Users\gegdg\Documents\.UVG\Anio6\SegundoSemestre\GameEngine\DateSim' --test
Remove-Item Env:DATESIM_TEST_GROUP
```

[affinity-training-final-targeted.log](../tests/artifacts/affinity-training-final-targeted.log) conserva **stdout íntegro**, con 84 comprobaciones de entrenamiento, 444 de integración del duelo, 44 de presentación de combate, 24 de persistencia y 999 de recorrido de interfaz. Salida 0. El selector también admite `training` y `ui`; sin variable se ejecuta la suite completa. Las campañas que ya habían pasado no se repitieron por estos ajustes de texto, música y arnés.

Los registros `dialogue-final-test.log`, `dialogue-redesign-test.log` y `portraits-test.log` corresponden a las intervenciones anteriores. Los artefactos son locales y están excluidos del control de versiones.

La suite usa identidades aisladas, incluidas **cartas_del_destino_v3_tests**, **cartas_del_destino_portraits_tests**, **cartas_del_destino_dialogue_tests** y **cartas_del_destino_training_tests**. La revisión interactiva anterior usa **cartas_del_destino_manual_review**. No se usaron los guardados de la campaña del jugador.

Se ejecutaron los diecinueve módulos de la suite activa: diecisiete desde `tests/run.lua` y dos invocados por la integración de campaña. Los nueve módulos conservados por `tests/legacy_run_v1.lua` no se ejecutan en la continuidad actual: sus expectativas de 16 cartas, mazo inicial de diez, relaciones de 0–10, carga automática v1 y checkpoints del Espejo corresponden a la campaña archivada. No se cambiaron esas pruebas históricas para aparentar compatibilidad.

## Barras, afinidad y duelo de entrenamiento

Las nuevas suites activas son `tests/relationship_bars.lua`, `tests/affinity.lua`, `tests/training.lua` y `tests/training_integration.lua`. Verifican los veinte requisitos de esta ampliación mediante reglas puras, comandos legales de combate y pantallas reales de la aplicación:

- Barras de las tres esposas y Confianza/Interés de Nanahoshi; valores positivos y negativos, límites, interpolación de 0,6 segundos, movimiento reducido, anclaje al retrato y efectos sonoros únicos.
- Exactamente cinco IDs sociales permitidos para interés. El motor y el validador rechazan una sexta carta, efectos incompatibles y amor matrimonial para Nanahoshi. La repetición del tutorial no concede otra recompensa.
- Guardado antes y después de reaccionar, valor lógico definitivo independiente del tween, snapshots anteriores sin premios retroactivos y continuación rápida sin duplicación.
- Cuatro desenlaces obtenidos con comandos de combate: victoria, derrota exigente, inactividad repetida y derrota rápida honesta. Los umbrales de esfuerzo son configurables y el resultado se reconstruye por replay.
- Pantalla de valoración por ratón y teclado, métricas completas, reacción requerida antes de avanzar, premio una sola vez, persistencia de la evaluación y recuerdo en escenas posteriores.
- Disculpa y revancha del día seis, reconciliación por esfuerzo real y conservación de ambos resultados. Las campañas completas siguen alcanzando exactamente cinco finales.

Se inspeccionaron **9 capturas de barras y 18 capturas de entrenamiento** generadas con LÖVE: los cuatro resultados antes, durante y después de cargar, movimiento reducido y reconciliación. Las placas no invaden rostros ni diálogo; los textos de evaluación caben en sus paneles. Los casos cerca de los límites muestran +2/+1 o −4/−3 reales, aunque la recompensa nominal sea mayor.

Evidencia local: [Nanahoshi](../tests/artifacts/relationship-nanahoshi-listen-reaction.png), [cambio negativo de Eris](../tests/artifacts/relationship-eris-light_joke-reaction.png), [victoria](../tests/artifacts/training-victory-applied.png), [derrota exigente](../tests/artifacts/training-honorable_defeat-applied.png), [falta de esfuerzo](../tests/artifacts/training-suspected_throw-applied.png), [derrota honesta](../tests/artifacts/training-honest_defeat-applied.png), [reconciliación restaurada](../tests/artifacts/training-reconciled-restored.png).

Archivos principales de esta ampliación:

| Grupo | Archivos |
| --- | --- |
| Barras e interfaz | Nuevo `src/ui/relationship_bars.lua`; actualizados `src/screens/dialogue.lua`, `encounter.lua`, `combat.lua`; nueva pantalla `training_result.lua`. |
| Afinidad | Nuevos `src/data/relationships/nanahoshi.lua`, `src/systems/affinity.lua`, `src/data/dialogue/nanahoshi_research.lua`; actualizados catálogo, tutorial, resolver, memoria, condiciones y cartas. |
| Entrenamiento | Nuevos `src/data/training.lua`, `training_dialogue.lua`, `src/systems/training.lua`, `training_result.lua`; actualizados enemigos, combate y diálogos posteriores de Eris. |
| Integración | Actualizados `src/app.lua`, `src/systems/save.lua`, `progression.lua`, validadores, capítulos tres a seis y `src/data/audio.lua`. |
| Pruebas | Cuatro suites nuevas; actualizados `tests/run.lua`, `campaign.lua`, `restructure_integration.lua` y expectativa de contextos musicales en `audio_options.lua`. |
| Documentación | Nueva guía `AFINIDAD_Y_ENTRENAMIENTO.md`; README, manual integrado, manual externo, diálogos, capítulos, combate, guardado, cobertura y este informe actualizados. |

## Diálogos escritos y memoria

El inventario validado contiene **9 conversaciones de entrada, 52 nodos, 126 respuestas base, 63 variantes escritas, 9 pausas y 43 conexiones distintas**. La matriz completa está en [COBERTURA_DIALOGOS.md](COBERTURA_DIALOGOS.md). Las **25 682 secuencias locales calculadas** son combinaciones teóricas de cartas compatibles y costes; no representan esa cantidad de textos únicos ni campañas completas.

Se comprueba que toda carta social jugable tenga frase de Rudy, reacción, expresión, efectos y continuación válidos; que no aparezcan cartas bloqueadas o incompatibles; que las variantes consulten decisiones anteriores; y que lectura, confirmación repetida o carga no dupliquen puntos. El conjunto lógico prueba **24 semillas**. La interfaz comprueba cancelación sin gasto, frase pronunciada idéntica a la vista previa, animación, reacción extendida, delta real de relaciones y guardado en disco antes y después de aplicar el resultado.

## Pruebas A–E y revisión visual

Los recorridos automatizados utilizan la `App` y sus pantallas reales. Se inspeccionaron capturas del renderer. La interacción mediante ratón se documenta por separado: no se presenta toda la automatización como una sesión manual.

| Prueba solicitada | Evidencia automatizada | Interacción visual adicional confirmada |
| --- | --- | --- |
| A · Eris | Tres estados independientes: Broma ligera −5/−2 y enfado; Dar ánimo +5/+3 y felicidad; Coqueteo sutil +10/+1 y desafío. Tres continuaciones diferentes, expresión y efectos visibles. | Confirmación por ratón de las tres elecciones; capturas inspeccionadas. |
| B · Roxy | Escuchar, Broma ligera y Hablar con honestidad producen respuestas y continuaciones propias; inspección, cancelación y carga durante la reacción. | Por ratón: Escuchar +3/+4 y Broma ligera −2/−1 confirmadas. Hablar con honestidad se revisó hasta su vista previa; su ejecución completa está validada por `App` y captura. |
| C · Sylphiette | Promesa registrada; cumplimiento e incumplimiento generan respuestas futuras distintas. Guardar/cargar conserva memoria y efectos aplicados. | Por ratón: Dar ánimo confirma la promesa y +3/+2. Las consecuencias futuras se verificaron mediante `App` y capturas, sin afirmar su recorrido manual completo. |
| D · Aleatoriedad | 24 semillas en lógica y cuatro repartos mediante `App`; mano, mazo y descarte permanecen idénticos tras guardar y cargar. | Capturas de los cuatro repartos disponibles para comparar. |
| E · Combate | Todos los encuentros de campaña son viables; `App` recorre tutorial, compañeras, cuatro fases de Badigadi e interrupción del día cinco. Un ataque múltiple muestra 6 daño, 5 bloqueado y 1 PV perdido. | Capturas de combate inspeccionadas; no se afirma una partida manual completa de cada encuentro. |

Capturas de diálogo: [broma de Eris](../tests/artifacts/dialogue-eris-joke-reaction.png), [apoyo a Eris](../tests/artifacts/dialogue-eris-support-reaction.png), [desafío romántico](../tests/artifacts/dialogue-eris-flirt-branch.png), [escuchar a Roxy](../tests/artifacts/dialogue-roxy-listen-reaction.png), [promesa cumplida](../tests/artifacts/dialogue-sylphiette-kept-reaction.png), [promesa incumplida](../tests/artifacts/dialogue-sylphiette-broken-reaction.png), [reparto con semilla](../tests/artifacts/dialogue-seed-13.png). Combate: [interrupción anunciada](../tests/artifacts/combat-day5-interruption.png), [daño múltiple bloqueado](../tests/artifacts/combat-day5-multiple-blocked.png).

La revisión adicional por ratón se detuvo cuando el usuario intervino en la ventana; se volvió a observar el juego en el segundo turno y se le dejó el control. No se afirma haber completado manualmente todas las pruebas A–E.

### Reproducir la revisión interactiva

```powershell
& 'C:\Program Files\LOVE\lovec.exe' 'C:\Users\gegdg\Documents\.UVG\Anio6\SegundoSemestre\GameEngine\DateSim' --qa-dialogue
```

`--qa-dialogue` abre **15 estados independientes** en la identidad `cartas_del_destino_manual_review`: tres elecciones de Eris, tres de Roxy, la promesa y dos consecuencias de Sylphiette, cuatro semillas y dos combates de días distintos. **F6 o clic derecho** cambia al siguiente caso; el clic izquierdo conserva los controles normales de selección y confirmación. La opción se activa explícitamente y no altera la campaña del jugador.

## Archivos del rediseño previo de diálogos

La tabla distingue los módulos creados ahora de los archivos existentes modificados durante este rediseño; no atribuye a esta tarea todos los cambios previos del árbol de trabajo.

| Grupo | Nuevos o modificados | Responsabilidad |
| --- | --- | --- |
| Datos narrativos | Nuevos: `src/data/dialogue/init.lua`, `eris.lua`, `roxy.lua`, `sylphiette.lua`, `nanahoshi.lua` | Conversaciones, respuestas por carta, variantes y continuaciones escritas. |
| Motor narrativo | Nuevos: `src/systems/dialogue_resolver.lua`, `dialogue_memory.lua`, `dialogue_validator.lua`; modificado: `src/systems/narrative_validator.lua` | Resolución contextual, memoria persistente y cobertura/referencias válidas. |
| Cartas e interfaz | Modificados: `src/systems/cards.lua`, `src/screens/encounter.lua`, `src/screens/collection.lua`, `src/data/cards.lua`, `src/ui/font.lua` | Mano compatible aleatoria, colección, previsualización, confirmación/cancelación, reacciones y texto español. |
| Campaña y persistencia | Modificados: `src/app.lua`, `src/systems/save.lua`, `src/data/chapters/day2.lua`, `day3.lua`, `day4.lua`, `day5.lua` | Eventos y decisiones, promesas, desafío de Eris, cura desbloqueada y restauración coherente. |
| Combate | Modificados: `src/data/enemies.lua`, `src/data/combat_cards.lua`, `src/systems/combat.lua`, `src/screens/combat.lua` | Perfiles por día, intenciones, curación limitada, resultados completos y replay compatible. |
| Pruebas y QA | Nuevos: `tests/dialogue_branching.lua`, `tests/dialogue_visual.lua`, `tests/combat_balance.lua`, `tests/manual_review.lua`; modificados: `main.lua`, `tests/run.lua`, `tests/campaign.lua`, `tests/combat_visual.lua`, `tests/combat_integration.lua` | Cobertura, campañas, pruebas A–E, capturas y revisión interactiva aislada. |
| Documentación | Nuevos: `docs/DIALOGOS.md`, `docs/COBERTURA_DIALOGOS.md`; actualizados: `README.md`, `docs/COMBATE.md`, `docs/GUARDADO.md`, `src/data/manual.lua`, este informe | Uso, manual integrado, autoría, inventario real, balance y resultados verificables. |

## Integración de Rudy japonés

Las 181 comprobaciones nuevas verifican identidad única, contexto explícito, sustitución por línea, reparto persistente, expresiones, entradas demoradas, voz mental, ausencia de cambios matrimoniales, restauración en cada una de las 11 líneas del sueño y después de despertar, reutilización en otro sueño, recuerdo de Hitogami en el mundo físico, combate con Rudy normal, PNG ausente y movimiento reducido. Incluyen regresiones para entradas explícitas por la derecha, oyentes que no vuelven a entrar, personajes ocultos que no reaparecen al salir y callback de salida único.

El cargador compara cada píxel de las cuatro celdas japonesas y su alfa, valida `nearest`, escala entera uniforme y carga independiente de `rudeus`. Los casos de recurso ausente, corrupto o de tamaño incorrecto usan inyección en memoria; no borran ni cambian los PNG.

Se generaron **18 capturas adicionales con LÖVE real** y se inspeccionaron visualmente: las 11 líneas completas, ambas entradas, ambos fundidos blancos, el despertar, el respaldo y el blanco con movimiento reducido. El texto cabe en su panel, ambos retratos permanecen separados y el cuerpo japonés contrasta claramente con el Rudy rubio al despertar. La revisión fue de capturas del renderer y avances automatizados por las pantallas reales; no una sesión manual prolongada.

Evidencia: [Hitogami entra](../tests/artifacts/portraits-hitogami-entry.png), [Rudy entra](../tests/artifacts/portraits-rudy-entry.png), [neutral](../tests/artifacts/portraits-intro-04.png), [preocupado](../tests/artifacts/portraits-intro-05.png), [enojado](../tests/artifacts/portraits-intro-09.png), [despedida](../tests/artifacts/portraits-intro-10.png), [despertar](../tests/artifacts/portraits-wake.png), [respaldo](../tests/artifacts/portraits-missing-png.png). Las expresiones feliz, neutral, preocupada y enojada se comprobaron también sobre la hoja original sin modificarla.

## Cobertura de la nueva historia

Se comprobó el inicio en el sueño, estados aún desconocidos, prohibición de saltar el sobre, elevación y apertura, texto y firma, lectura guardada, relectura sin duplicación, carga durante la animación y documentos de varias páginas con IDs independientes.

Los descubrimientos se producen después de la carta. El diario no adelanta el diagnóstico. La prueba verifica silencio, bloqueo de magia natural, comunicación mental o escrita, restricción del secreto y entrega exacta de cinco cartas sociales y cinco físicas.

La campaña prueba investigación, fragmentos, desbloqueos, misiones con compañeras, Badigadi y la neutralización expresa del sello. El antídoto es obligatorio, se consume una vez, restaura voz y magia y no altera automáticamente las relaciones. También se prueban derrota, reintento, edición de mazo, premios únicos, carga y práctica aislada.

La validación narrativa rechaza expresiones o movimientos desconocidos, documentos inexistentes y líneas de Rudy sin un canal permitido antes de la cura. Se mantienen las pruebas anteriores compatibles; las expectativas descartadas de veinte cartas iniciales y narrativa del Espejo se actualizaron.

## Inspección visual y recursos

Se inspeccionaron las capturas del sueño de Hitogami, sobre en el hogar, carta completa, firma, estados sellados, primera entrega de cartas, día siete y fase del sello de Badigadi. Los retratos e iconos reales se dibujan con proporciones uniformes y filtro nearest. Las pruebas comparan píxeles de las cuatro expresiones, incluyendo Sylphiette.

Capturas destacadas: [sueño](../tests/artifacts/v2-day1.png), [sobre](../tests/artifacts/curse-envelope.png), [carta completa](../tests/artifacts/curse-letter.png), [voz y maná](../tests/artifacts/curse-sealed.png), [primer mazo](../tests/artifacts/v2-reward.png), [sello de Badigadi](../tests/artifacts/combat-badigadi-seal.png). El prefijo histórico `v2-` de algunas capturas identifica nombres del arnés reutilizado; sus imágenes fueron regeneradas con esta campaña v3.

La verificación anterior inspeccionó las cabeceras de 73 ASE. En esta integración se comprobó además `rudeus_japones.ase`: cuatro fotogramas de 64 × 64, 32 bits. El inventario actual es **74 ASE y 77 PNG**, incluidos los tres atlas/vista previa auxiliares. El PNG japonés es RGBA8 de 256 × 64 y su alfa comprende 0–255. No se modificaron recursos binarios.

Los avisos de PNG o audio inexistentes emitidos durante las pruebas corresponden a errores inyectados deliberadamente para verificar los recursos provisionales; se conservan en los registros íntegros de esta ampliación. La precarga normal exige cero sustituciones.

## Límites

No se realizó una sesión prolongada con jugadores ni una mezcla de audio evaluada subjetivamente. La música y los efectos son síntesis original. Las frases de las cartas se presentan como texto encantado y sonido de activación, sin doblaje grabado. No se probaron cortes físicos de energía, todas las resoluciones de monitor o una importación con cada guardado histórico real del usuario. No se afirma haber realizado esas verificaciones.
