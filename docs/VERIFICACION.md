# Verificación de integración y balance — Fase 6

Fecha: **21 de noviembre de 2026**. Ejecutado con **LÖVE 11.5 / LuaJIT** y guardados aislados. La suite general terminó en una ejecución completa: **44 545 comprobaciones**, `ALL TESTS PASSED`, salida 0. Después se verificó una ampliación de la prueba visual del manual: **323 comprobaciones focalizadas**, sin sumar de nuevo las 322 que ya estaban en la suite.

| Ejecución | Resultado |
| --- | --- |
| Suite general | 44 545 comprobaciones; 40 campañas completas y cinco finales con/sin Orsted |
| Recorrido gráfico, incluido en la suite | 1462 comprobaciones; 825 pasos de pantalla |
| Matriz de Badigadi, incluida en la suite | 1200 comprobaciones; 576 batallas, ocho equipos; 570 victorias y seis derrotas reales a N1 |
| Audio/opciones, incluido en la suite | 116 comprobaciones; 20 contextos musicales |
| Integración de Fase 6, última ejecución focalizada | 323 comprobaciones; nueve capturas; HUD, relaciones negativas, persistencia, Orsted, libro y PCM real |
| Balance adicional de siete días | 23 382 comprobaciones; 11 perfiles × tres semillas = 33 campañas; todas llegan a epílogo |
| Reproducción adicional | `balanced`, semilla 17: métricas JSON idénticas a la campaña principal; 737 comprobaciones, excluidas del total de campañas distintas |

Las filas de recorrido gráfico, matriz y audio desglosan la suite; **no se suman de nuevo**. El código de juego de la suite general coincide con el entregado salvo una corrección textual posterior del rango de relaciones en el manual. La ejecución focalizada posterior comprueba su fórmula visible y añade una captura. No se modificó después la lógica de economía, familia o combate.

Los resultados y su método están en el [informe de Fase 6](FASE_6_INFORME.md); los recursos, niveles, relaciones, daño, curación, escudo y finales constan en el [CSV de 33 campañas](BALANCE_FASE_6.csv). Las semillas son 17, 43 y 97. Las campañas usan comandos legales y guardado/carga; no equiparan la actuación del agente de prueba a la de un jugador humano.

Registros locales: `tests/artifacts/phase6-full.log`, `phase6-balance-final.log`, `phase6-reproducibility.log`, `phase6-integration.log`. Las capturas reales de agenda, actividades, relaciones, colección, separaciones, combate, victoria y desenlaces se inspeccionaron visualmente. **No se completó una partida manual continua ni una revisión auditiva humana**; la herramienta de control de ventanas requerida no estaba disponible. `./revisar.ps1` prepara esa revisión pendiente en una identidad independiente, con captura F8.

Se conservan los PNG/ASE originales. La corrección del libro elimina una compra dominada; el regalo de Orsted ahora completa la colección incluso con separaciones sin devolver habilidades. Las pruebas de guardado, doble gasto y doble recompensa siguen pasando. Los avisos de recursos ausentes en la suite pertenecen a fixtures deliberadas de fallos, no a nuevas referencias de producción sin archivo.

## Registro anterior — Fase 5

Fecha: **21 de noviembre de 2026**. Ejecutado con **LÖVE 11.5 / LuaJIT**, renderizador real y guardados aislados: **44 192 comprobaciones**, sumando una ejecución válida de cada módulo y sin contar repeticiones. Los grupos `regression` y `campaign` finalizaron con **`ALL TESTS PASSED`, salida 0**. La verificación se realizó en esos dos grupos; no se presenta como una sola ejecución monolítica.

| Cobertura | Resultado |
| --- | --- |
| Campañas completas | 28 848 comprobaciones; 40 recorridos de siete días |
| Regresión de sistemas e interfaces | 15 344 comprobaciones, incluyendo los módulos detallados abajo |
| Reglas de Fase 5 | 384 comprobaciones; los 32 calendarios posibles y 24 demostraciones de Orsted con niveles 1/5/10 |
| Interfaz de Fase 5 | 22 comprobaciones; 16 capturas, elección de ambas mejoras, recarga durante el destello, devolución y los cinco epílogos |
| Campaña gráfica | 1 457 comprobaciones; 825 pasos de pantalla |
| Combate gráfico e integración | 44 + 24 comprobaciones |
| Balance del jefe y reglas de apoyo | 1 200 + 217 comprobaciones; 576 simulaciones del jefe, ocho composiciones familiares |
| Interfaz de apoyo y fases | 10 comprobaciones; 12 capturas |
| Compatibilidad de combate | 1 620 + 956 comprobaciones; 120 + 300 victorias con fixtures históricas |
| Entrenamiento e integración | 84 + 444 comprobaciones |
| Familia e interfaz | 228 + 2 400 comprobaciones |
| Agenda e interfaz | 1 028 + 36 comprobaciones |
| Niveles, economía e interfaz | 398 + 25 comprobaciones |
| Diálogos e interfaz | 73 + 2 788 + 277 comprobaciones |
| Barras, afinidad e introducción | 138 + 260 + 34 comprobaciones |
| Recursos, movimiento, retratos, audio y matrimonios | 654 + 172 + 181 + 90 + 100 comprobaciones |

Las primeras dos filas suman el total; las demás desglosan la regresión y no deben sumarse otra vez.

## Rutas y recompensas

Los 40 recorridos incluyen **32 con Orsted y ocho sin su ayuda**. Los cinco finales se alcanzaron en ambos casos. Cada recorrido usa actividades, cartas adquiridas, comandos legales de combate y guardado/carga entre checkpoints. Se comprueba la devolución a Nanahoshi y la visita al epílogo que corresponde al estado matrimonial.

La especialización sin Orsted alcanza Bastón y Dar ánimo a N10 mediante compras y mejoras ordinarias: **1 839 oro de ingreso, 1 037 de saldo y 241 922 bytes** al terminar. Su resultado matrimonial es Roxy; el recorrido específico de familia unida sin Orsted también pasa. La ayuda extraordinaria no sustituye los compromisos familiares ni es necesaria para conseguir el mejor final.

Los 32 calendarios prueban que sólo entrenar en cada día 1–5 abre la aparición. Reservar una actividad no cuenta; tres repeticiones no cubren las otras fechas. Las demostraciones contra Orsted terminan como derrota narrativa incluso con N10, conservan guardia finita y no castigan relaciones. Se prueba que el emisario debe ser vencido antes de su confesión y que la información sobre el antídoto permanece oculta antes de ese punto.

Se verifican los patrones faltantes, dos IDs distintos, una elección por categoría, conservación de oro/copias/descuentos, bloqueo del doble clic y del tercer premio, persistencia de la presentación y restricciones de las esposas separadas. La cura restaura voz y magia sin conjuro sin modificar afinidad; devolver las cartas conserva la colección.

## Persistencia y revisión visual

La migración **v7→v8** usa cinco resúmenes diarios generados por actividades reales. Conserva las fechas y su índice de eventos después de una segunda carga, reanuda un combate v7 iniciado contra el lacayo y verifica que los bytes originales de v7 permanecen intactos. Durante la revisión se corrigió el orden de reconstrucción del índice diario; las pruebas específicas y la regresión final pasan con esa corrección. Las migraciones anteriores siguen cubiertas. El ensayo extenso de combate conserva 414 comandos y 600 entradas de historial, con 582 655 bytes dentro del límite de 2 MiB.

Se inspeccionaron capturas reales de la [derrota narrativa](../tests/artifacts/finale-orsted-narrative-defeat.png), [mejora de combate](../tests/artifacts/finale-maximizing-combat.png), [selección social](../tests/artifacts/finale-choose-social.png), [manual sin revelación](../tests/artifacts/finale-manual-mystery.png) y los cinco epílogos: [familia](../tests/artifacts/finale-epilogue-family_united.png), [Roxy](../tests/artifacts/finale-epilogue-roxy.png), [Eris](../tests/artifacts/finale-epilogue-eris.png), [Sylphiette](../tests/artifacts/finale-epilogue-sylphiette.png) y [Rudy solo](../tests/artifacts/finale-epilogue-solitary.png). No se modificaron PNG ni ASE del juego.

Registros locales finales: `tests/artifacts/finale-regression-final.log`, `finale-campaign.log` y `finale-migration-final.log`. Logs y capturas están excluidos de Git. Los avisos de imágenes y sonidos ausentes proceden de fixtures que prueban los recursos provisionales; no indican archivos originales eliminados. Las pruebas son automatizadas en LÖVE y la inspección es visual: no equivalen a una partida manual completa ni sustituyen sesiones de balance con jugadores. [Arquitectura y comandos](FASE_5_CIERRE.md).

## Registro anterior — Fase 4

Fecha: **21 de noviembre de 2026**. Ejecutado con **LÖVE 11.5 / LuaJIT**, renderizador real e identidades de prueba aisladas. **39 126 comprobaciones**, tomando una ejecución válida de cada módulo y sin sumar repeticiones. Los PNG y ASE originales no cambiaron.

La ejecución general completó reglas, narrativa y los **35 recorridos de campaña**. Una prueba de integración anterior elegía un encuentro mediante `pairs` y atacaba sin defenderse: se sustituyó por un escenario estable de persistencia y la estrategia actual, que lee intenciones y usa acciones legales. Se volvió a ejecutar el grupo gráfico completo. Los grupos focalizados finales y la campaña gráfica terminaron con **`ALL TESTS PASSED`, salida 0**; la validación final consta de la suite general y esas ejecuciones focalizadas, no de una segunda corrida completa.

| Cobertura | Resultado |
| --- | --- |
| Reglas nuevas: fórmulas, umbrales, daño real, curación, recargas, Orsted, separación, guardado y migración | 217 comprobaciones; incluye 36 batallas intermedias |
| Balance de Badigadi | 1 200 comprobaciones; 576 simulaciones, ocho composiciones familiares |
| Interfaz de apoyo, preparación, cuatro fases, antídoto y confirmación de riesgo | 10 comprobaciones; 12 capturas reales |
| Campaña de siete días, cinco finales, distribución libre y compras legales | 24 306 comprobaciones; 35 recorridos completos |
| Campaña gráfica | 1 339 comprobaciones; 767 pasos de pantalla |
| Combate gráfico e integración | 44 + 24 comprobaciones |
| Compatibilidad de combates históricos | 1 620 + 956 comprobaciones; 120 + 300 victorias |
| Entrenamiento y su integración | 84 + 444 comprobaciones |
| Familia e interfaz | 228 + 2 400 comprobaciones |
| Ciclo diario e interfaz | 1 017 + 36 comprobaciones |
| Niveles, economía e interfaz | 398 + 25 comprobaciones |
| Diálogos e interfaz | 73 + 2 788 + 277 comprobaciones |
| Barras, afinidad e introducción | 138 + 260 + 34 comprobaciones |
| Recursos, movimiento, retratos, audio y matrimonios | 654 + 172 + 181 + 101 + 100 comprobaciones |

El balance actual se evalúa en `war_balance`, `war`, `campaign` y las pantallas. `combat` y `combat_balance` mantienen fixtures del motor histórico para comprobar compatibilidad; sus victorias no se presentan como medidas del nuevo jefe. Los perfiles actuales de días 5/6 usan 180/260 PV base y se probaron en los 35 recorridos finales.

Badigadi mantiene 1000 PV en todas las simulaciones. Con cartas de nivel 5 o 10 gana la estrategia de prueba en las ocho semillas de cada combinación; con nivel 1 y Rudy solo gana 6/8 y pierde dos por plazo. [CSV completo](BALANCE_FASE_4.csv) y [metodología, mazo y métricas](FASE_4_COMBATE.md). Las simulaciones de nivel homogéneo aíslan variables; los recorridos de campaña usan únicamente cartas adquiridas y mejoras pagadas. La especialización alcanza Bastón y Dar ánimo a nivel 10: ingreso 1 908 oro, saldo 1 106 y 238 994 bytes de progreso final. Orsted no es requisito para ninguna victoria del jefe.

Se probaron 24.99, 25, 49, 50, 79, 80, 89, 90 y 100 de afinidad, además de valores negativos y amor distinto de confianza. Los tests comparan la fórmula con el daño aplicado, no solo la vista previa. La interferencia de Sylphiette exige confirmar; cancelar no gasta y aceptar puede dejar a Rudy en cero PV. Las barras convergen al resultado real. Roxy muestra el daño posterior a disolver escudo y exponer resistencia.

La migración v6→v7 conserva los bytes del original y reanuda una batalla histórica contra Badigadi con sus antiguos 72 PV. Los comandos alterados se rechazan. La prueba extensa guarda **582 563 bytes**, **414 comandos** y 600 entradas de historial, y recupera el turno 70 sin reponer apoyos. El límite de lectura/escritura pasa a 2 MiB para admitir historia y batallas largas. Las migraciones de economía y familia siguen pasando.

Capturas inspeccionadas del renderizador real: [preparación](../tests/artifacts/war-preparation.png), [habilidades de Roxy](../tests/artifacts/war-roxy-skills.png), [resistencia reforzada](../tests/artifacts/war-phase-resolve.png), [sello](../tests/artifacts/war-phase-seal.png), [confirmación de interferencia](../tests/artifacts/war-risk-confirmation.png) y [derrota por interferencia](../tests/artifacts/war-interference-defeat.png). Se reutilizan retratos y fondos existentes, con desplazamiento de ataque cercano para Eris y apoyos mágicos diferenciados.

Registros locales: `war-final.log`, `war-final-targeted.log`, `war-persistence.log` y `war-final-ui-campaign.log` en `tests/artifacts/`. Las capturas y logs se excluyen de Git; el CSV publicado permanece en `docs/`. Las pruebas automatizadas y la inspección visual no sustituyen sesiones de balance con jugadores ni equivalen a una partida manual completa.

## Registro anterior — Fase 3

Fecha: **21 de noviembre de 2026**. Pruebas ejecutadas con **LÖVE 11.5 / LuaJIT**, renderizador real y guardados aislados. **44 224 comprobaciones** sumando los módulos de la suite y sus ejecuciones focalizadas finales, sin contar repeticiones. No se modificaron los PNG ni los ASE originales.

La primera ejecución general detectó expectativas anteriores del límite mínimo cero. Se actualizaron para verificar −100 y se ejecutaron los módulos afectados. Los grupos finales `family-ui`, `daily-ui`, `narrative`, `economy-ui`, `campaign` y `ui` terminaron con **`ALL TESTS PASSED`, salida 0**. La validación se realizó en varias ejecuciones, no en una única corrida final de toda la suite.

| Cobertura | Resultado |
| --- | --- |
| Familia: 16 actividades, duelo real, visitas, recuperación, abandono, separaciones, encargos, libros y migración | 228 comprobaciones |
| Interfaz familiar: confirmación/cancelación, tercera visita, anillo, caballo, libro y retratos grises | 2 400 comprobaciones; 22 capturas |
| Ciclo diario y su interfaz | 1 010 + 36 comprobaciones |
| Campaña: cinco finales, distribución libre, ausencia de compañeras, encargos y especialización | 30 924 comprobaciones; 35 recorridos completos |
| Campaña gráfica | 1 290 comprobaciones; 742 pasos de pantalla |
| Combate gráfico y su integración | 44 + 24 comprobaciones |
| Niveles/economía e interfaz | 398 + 25 comprobaciones |
| Diálogos y su interfaz | 73 + 2 788 + 277 comprobaciones |
| Combate, equilibrio y entrenamiento | 1 620 + 919 + 84 comprobaciones; 120 + 288 victorias |
| Entrenamiento integrado, barras, afinidad e introducción | 444 + 138 + 260 + 34 comprobaciones |
| Recursos, movimiento, retratos, audio y matrimonios | 654 + 172 + 181 + 101 + 100 comprobaciones |

Las rutas usan decisiones, combates y recursos reales. Para cubrir rutas con menos apoyo familiar, el conductor de campaña compra y mejora cartas con oro ganado; no inyecta recursos ni estadísticas. La ruta de especialización obtiene **1 908 oro**, lleva **Bastón y Dar ánimo a nivel 10**, termina con **1 106 oro** y ocupa **232 905 bytes** serializada. Las fixtures históricas de módulos independientes fijan explícitamente su antiguo 65/65; familia y campaña verifican el inicio nuevo 50/50.

La migración v5→v6 conserva los bytes del archivo original. Se probaron también conversaciones históricas cuyas pérdidas habían quedado recortadas en cero: cargar no las reinterpreta con el nuevo mínimo −100. Permanecen vigentes las pruebas de migración v4, duplicados, presupuesto diario y gastos únicos.

Se verificó por píxeles la escala de grises del retrato. Las escenas de separación se guardaron durante el anillo y continuaron sin repetir la consecuencia. Capturas revisadas: [agenda](../tests/artifacts/family-agenda.png), [librería](../tests/artifacts/family-books.png), [tercera visita de Roxy](../tests/artifacts/family-third-roxy.png), [Sylphiette y su hija](../tests/artifacts/family-horse-sylphiette.png) y [registro gris](../tests/artifacts/family-gray-journal.png).

Registros locales: `tests/artifacts/family-final.log`, `family-daily.log`, `family-narrative.log`, `family-campaign.log` y `family-ui-campaign.log`. Los artefactos se excluyen de Git. `git diff --check` pasa. Las pruebas automatizadas verifican reglas y viabilidad; no sustituyen sesiones de equilibrio y lectura con jugadores.

## Registro anterior — Fase 2

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

## Migración de exploración — 22 de noviembre de 2026

Entorno ejecutado: **LÖVE 11.5 (Mysterious Mysteries), Windows / LuaJIT**. Se ejecutó la suite completa antes de modificar la integración y nuevamente con la integración terminada. Ambas finalizaron con `ALL TESTS PASSED`. Las identidades de prueba existentes aislaron los guardados del usuario.

| Ejecución | Resultado observado | Registro local |
| --- | --- | --- |
| Suite anterior, antes de integrar | `ALL TESTS PASSED` | `tests/artifacts/exploration-baseline.log` |
| Suite completa con migración integrada | `ALL TESTS PASSED`; incluye las pruebas nuevas | `tests/artifacts/exploration-full-suite.log` |
| Recursos de exploración después de retirar `assets/New` | 3,702 comprobaciones, `ALL TESTS PASSED` | `tests/artifacts/exploration-after-cleanup.log` |
| Recursos anteriores después de retirar `assets/New` | 654 comprobaciones, `ALL TESTS PASSED` | `tests/artifacts/exploration-legacy-after-cleanup.log` |
| Capturas de calibración | 14 mapas renderizados, `ALL TESTS PASSED` | `tests/artifacts/exploration-visual.log` |
| Verificación SHA-256 | 109 archivos migrados + 157 anteriores intactos; ZIP y carpeta archivada coinciden con los originales | `python tools/migrate_exploration_assets.py verify` y cotejo de `.asset_backups/original-delivery/` |

La suite integrada completó **40 rutas de campaña**, cinco finales y **28,848 comprobaciones de campaña**, incluyendo guardado/carga y progresión. El recorrido de interfaz registró **1,462 comprobaciones y 825 pasos por pantallas reales**. Se ejecutaron también recursos, animación, retratos, audio/opciones, matrimonios, economía, familia, agenda diaria, combate/balance, entrenamiento, guerra, finales, afinidad, diálogos y las integraciones incluidas en `tests/run.lua`. No hubo regresiones observadas en esos sistemas. Los avisos de recursos ausentes o corruptos del registro son fallos deliberadamente inyectados por las suites; la precarga normal exige cero sustituciones.

La nueva prueba comprueba los 53 PNG y 53 ASE, metadatos, hashes y dimensiones originales; nombres exactos incluyendo mayúsculas; carga CPU/GPU; fotogramas y duraciones; sprites 4 × 4; reposo NPC; caballo; píxeles de objetos frente al atlas; caché compartida; 78 referencias antiguas del manifiesto; datos de 14 mapas, 13 conexiones bidireccionales y 26 portales. Verifica destinos, retornos, lados, alcance, geometría declarada y rechazo de errores introducidos en memoria. No hay referencias a la carpeta temporal en el código de ejecución.

Se inspeccionaron visualmente los 14 mapas originales y las 14 capturas con zonas transitables, portales y Rudy. Se ajustaron la llegada junto a los pilares de Sharia, los umbrales de Sylphie/Eris y la activación de las cuatro puertas superiores. Las capturas finales están en `tests/artifacts/exploration-<id>.png`; los datos revisados se exportan a `tests/artifacts/exploration-map-review.json`.

**Límites comprobados y documentados:**

- El grafo previsto alcanza los 14 mapas desde casa. Sólo 12 enlaces están calibrados y habilitados en los datos; el acceso izquierdo de la universidad no muestra una abertura. Ese enlace permanece pendiente en ambos sentidos. El grafo habilitado alcanza 10 mapas desde casa.
- Las colisiones cubren accesos y corredores revisados; el resto queda bloqueado. No se implementó ni se probó un motor de movimiento libre, que no existía. Todos los mapas mantienen `explorationReady=false`.
- Las cabeceras generales, dimensiones y límites de chunks de los 53 ASE se comprobaron. Los 18 ASE originales de mapas/tilesets contienen 120 registros de capa no estándar; se conservan exactamente, sin reparación. No se certificó su apertura en LibreSprite. Esta advertencia no se confunde con un fallo de integridad causado por la migración.
- La comprobación del juego existente fue automática, con su renderer real; no se realizó una sesión humana prolongada.

`assets/New` quedó fuera del árbol de ejecución: la revisión automática rechazó el borrado recursivo (`blocked by policy`) y se eligió trasladar todos los originales, sin eliminarlos, a `.asset_backups/original-delivery/`. También se conserva `.asset_backups/exploration-originals.zip`, SHA-256 `d0203de646979369b682b6332060dd1c4f248d918f818a9792cacc2a63a809a4`. Ambos respaldos son locales e ignorados por Git. Tras el traslado se repitieron con éxito las suites de recursos nuevos y anteriores. Totales definitivos, incluyendo anteriores: **130 PNG en assets y 127 ASE en sprite_sources**.

Detalle: [inventario](ASSETS_INVENTORY.md), [conexiones y coordenadas](MAPAS_CONEXIONES.md).
