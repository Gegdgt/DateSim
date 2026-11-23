# Corrección de exploración y cartas sociales

Actualización posterior: la [corrección de la mano de tres cartas](CARTAS_SOCIALES.md) completa las respuestas de las cinco iniciales en todas las actividades, para un total de 255 respuestas base. Los resultados siguientes corresponden a la integración anterior; la [verificación actual](VERIFICACION.md#mano-social-de-tres-cartas) incluye las nuevas pruebas de reposición y persistencia.

Entrega del 22 de noviembre de 2026 sobre el proyecto existente de LÖVE 11.5. Se mantiene el prólogo, los siete días de campaña, el combate, los niveles de cartas, las relaciones y el guardado v8. No se reorganizaron ni editaron los recursos PNG o ASE. Este informe describe esta corrección; los informes de fases anteriores conservan su valor histórico.

## Experiencia implementada

Busca a **Eris en el patio**, **Roxy en la biblioteca** o **Sylphie en la sala** y pulsa E. Rudy y la esposa se orientan uno hacia el otro. El mapa permanece visible detrás del retrato, el saludo y tres propuestas horizontales. Las teclas 1–3 o las flechas seleccionan; Enter confirma; el mouse activa la propuesta. Escape vuelve al mapa sin consumir una interacción si todavía no empezó.

Se eliminaron G, «Siguiente esposa», el catálogo matrimonial y el acceso a encargos desde el diario en la exploración normal. Las actividades comprueban la cercanía al personaje también en el sistema, no sólo en los botones. Cliff y Zanoba ofrecen sus propios encargos en el taller. El diario muestra los pendientes. Las investigaciones obligatorias se continúan hablando con Nanahoshi en su laboratorio. Los guardados anteriores sin exploración mantienen su flujo compatible.

Las opciones no anuncian premios, puntos de relación ni detalles extensos. Una vez elegida una actividad comienza su conversación, seguida del combate, compra o desafío correspondiente cuando lo requiere. El recibo final muestra oro, copias y objetos realmente añadidos, las variaciones reales de relación y un cierre de la situación. Se vuelve al mapa de origen.

La mano comparte el componente visual de Nanahoshi: reversos, marcos, iconos y categorías originales. El jugador consulta **frase y coste**, confirma la carta y ve entonces la reacción. Cada actividad permite hasta **tres cartas con seis puntos de energía social**; sólo al completar la actividad se consume una interacción diaria. P termina la conversación antes si el jugador lo desea. Las animaciones bloquean dobles confirmaciones.

El coste y la base positiva de Escuchar son 3 / +5 amor con Sylphie, 1 / +1 con Roxy y 2 / +2 con Eris, en nivel 1 y contexto apropiado. Los niveles, estados matrimoniales, decisiones, penalizaciones y el límite diario siguen interviniendo. Una afinidad positiva no anula una respuesta inapropiada. [Configuración exacta](CARTAS_SOCIALES.md).

Después de cerrar la tercera actividad total, las esposas activas regresan a sus dormitorios. Se conserva el horario durante una conversación o un recibo pendiente de lectura. El siguiente día restaura sus lugares diurnos. Dormir junto a una esposa aporta hasta +10 amor/+10 confianza una sola vez, fuera del margen diurno, sin borrar las ausencias. Las separadas no aparecen ni dan bonificación y Rudy puede dormir solo. [Coordenadas, colisiones y horarios](COLISIONES_NPC.md).

## Archivos de esta corrección

| Área | Archivos principales |
| --- | --- |
| Colisiones y colocación | `src/data/map_collisions.lua`, `src/data/exploration_world.lua`, `src/systems/exploration.lua` |
| Acceso físico y prólogo | `src/screens/exploration.lua`, `src/systems/prologue.lua`, `src/systems/progression.lua`, `src/app.lua` |
| Actividades y conversación | `src/data/activity_conversations.lua` (nuevo), `src/data/wife_activities.lua`, `src/systems/wife_activities.lua`, `src/screens/wife_activities.lua`, `src/systems/daily.lua` |
| Costes y efectos | `src/data/social_rules.lua` y `src/systems/social_rules.lua` (nuevos), `src/data/cards.lua`, `src/systems/cards.lua`, `src/systems/dialogue_resolver.lua` |
| Mano y animaciones | `src/ui/social_hand.lua` (nuevo), `src/ui/card.lua`, `src/screens/encounter.lua`, `src/data/audio.lua` |
| Descanso y edición de mazos | `src/systems/rest.lua`, `src/screens/rest.lua`, `src/screens/collection.lua`, `src/systems/card_collection.lua` |
| Texto y tutorial | `src/systems/tutorial.lua`, `src/data/manual.lua`, `src/screens/combat.lua`, `src/screens/upgrades.lua` |
| Pruebas nuevas | `tests/social_driver.lua`, `tests/social_exploration.lua` |
| Pruebas adaptadas | `tests/run.lua`, `tests/exploration.lua`, `tests/exploration_driver.lua`, `tests/world_content.lua`, `tests/wife_activities.lua`, `tests/wife_activities_ui.lua`, `tests/campaign_world_driver.lua`, `tests/campaign.lua`, `tests/restructure_integration.lua`, `tests/dialogue_branching.lua`, `tests/dialogue_visual.lua`, `tests/economy.lua`, `tests/relationship_bars.lua` |
| Documentación | README, Manual del aventurero, este informe, `CARTAS_SOCIALES.md`, `COLISIONES_NPC.md`, guardado, sistemas, capítulos, animaciones, mapas, verificación y cobertura generada de actividades |

El repositorio ya contenía cambios y archivos sin seguimiento al comenzar. Esta lista describe el trabajo de la corrección; no atribuye todos los cambios del directorio a esta entrega.

## Verificación reproducible

Resultado final: **suite completa y regresión aprobadas**, 40 campañas más nueve recorridos explorables, 724 comprobaciones focales y 28 capturas de esta corrección. La campaña final por interfaz completó 1.099 pasos con el descanso simplificado.

Las pruebas usan identidades de LÖVE separadas del guardado normal. Las capturas proceden del renderer real de la aplicación a 640 × 360, con entradas invocadas por los controladores de prueba. **Son recorridos automatizados, no una partida manual con mouse y teclado del sistema operativo.**

```powershell
# Suite completa
./probar.ps1

# Regresión rápida: todos los módulos y campaña de interfaz,
# sin repetir las 40 + 9 simulaciones completas.
$env:DATESIM_TEST_GROUP='regression'
./probar.ps1
Remove-Item Env:DATESIM_TEST_GROUP

# Casos de esta corrección y sus capturas
$env:DATESIM_TEST_MODULE='social_exploration'
./probar.ps1
Remove-Item Env:DATESIM_TEST_MODULE

# Integridad de recursos
python tools/migrate_exploration_assets.py verify
```

### Cobertura de los 48 requisitos de prueba

| Casos del pedido | Comprobación y evidencia |
| --- | --- |
| 1–6 · Colisiones | Puntos transitables y movimiento real por sillón/sillas/farol; mesa, pared y bordes bloqueados; validación de portales y rutas en `social_exploration` y `exploration`. |
| 7–11 · NPC | Mapas diurnos, conteo único por identidad, caminos físicos y persistencia de ubicación. |
| 12–16 · Acceso y opciones | G no cambia la pantalla; inicio remoto rechazado sin gasto; tres botones a la misma altura, sin premios ni navegación entre esposas; selección por flechas, números, Enter y mouse. |
| 17–18 · Conversación y premios | Banco de 45 actividades y 167 respuestas; comprobación de oro/copias/objetos contra el estado real, tanto en éxitos como en fallos, servicios y combates. |
| 19–25 · Mano visual | PNG de cartas compartidos, tutorial de Nanahoshi, mezcla persistente, tres cartas compatibles, frase y coste visibles; capturas de barajado, mano y juego. |
| 26–30 · Reglas sociales | Tres cartas por actividad, gasto de energía, afinidades 3/1/2 y +5/+1/+2, nivel y margen diario, cierre voluntario y continuación de una reserva antigua. |
| 31–33 · Reacciones | Broma y reparación, contexto negativo pese a afinidad, barras con deltas efectivos y eventos idempotentes; guardado antes y después de la reacción. |
| 34–41 · Jornada | Horarios tras 1/2/3 actividades; distribuciones 1+1+1, 2+1, tres con Eris y tres con Sylphie; cuarta actividad bloqueada; dormitorios, bonus nocturno y ausencia separados, siguiente mañana, separaciones y descanso solo. |
| 42–47 · Guardado | JSON de ida y vuelta conserva posiciones, manos, intercambios, energía, descarte, reservas, relaciones, recibos y horario. Rechaza energía o mazos inconsistentes y no repite premios. Incluye guardar durante la reposición. |
| 48 · Campaña | Simulaciones de siete días, recorridos físicos A–I, tutorial, Orsted, Badigadi y campaña completa mediante pantallas reales. |

### Recorridos A–F del pedido

| Recorrido | Validación automatizada |
| --- | --- |
| A | Camino a Eris, oferta real obtenida por diálogo, selección y tres cartas sociales. E01 cubre además la reposición desde un mazo con más de tres cartas compatibles. |
| B | Camino a Roxy, Escuchar cuesta 1 y aplica +1 amor en el contexto positivo de R15. |
| C | Camino a Sylphie, Escuchar cuesta 3 y aplica +5 amor en S11. |
| D | Tres actividades con Eris; las tres esposas aparecen una sola vez en sus dormitorios y dejan de estar en sus lugares diurnos. |
| E | Contrato físico con Cliff, persistencia y rechazo de contratación o ayuda remotas; interfaz de encargos propia del NPC y diario de consulta. |
| F | Movimiento por la sala, sillas y junto al farol; sólidos y accesos conservados. |

Los resultados numéricos finales se registran en [VERIFICACION.md](VERIFICACION.md). La cobertura completa de actividades se regenera en [COBERTURA_ACTIVIDADES.md](COBERTURA_ACTIVIDADES.md).

## Capturas

- Ubicación: [Eris en el patio](../tests/artifacts/social-eris-world.png), [Roxy en la biblioteca](../tests/artifacts/social-roxy-world.png), [Sylphie en la sala](../tests/artifacts/social-sylphiette-world.png).
- Propuestas: [Eris](../tests/artifacts/social-eris-offers.png), [Roxy](../tests/artifacts/social-roxy-offers.png), [Sylphie](../tests/artifacts/social-sylphiette-offers.png).
- Cartas: [barajado](../tests/artifacts/social-eris-shuffle.png), [mano y frase](../tests/artifacts/social-eris-hand.png), [carta en movimiento](../tests/artifacts/social-eris-play.png), [reposición](../tests/artifacts/social-eris-refill.png).
- Resultado: [reacción de Roxy](../tests/artifacts/social-roxy-reaction.png), [recibo de Sylphie](../tests/artifacts/social-sylphiette-receipt.png).
- Noche: [Eris](../tests/artifacts/social-eris-night.png), [Roxy](../tests/artifacts/social-roxy-night.png), [Sylphie](../tests/artifacts/social-sylphiette-night.png), [propuesta de descanso](../tests/artifacts/social-rest-question.png).
- Colisiones: [paso junto al farol](../tests/artifacts/social-lamp-passage.png).

## Pendiente y límites conocidos

- Falta la comprobación manual con entrada física de Windows y escucha del audio. La herramienta `node_repl` no estaba disponible en esta sesión. La habilidad [Computer Use](C:/Users/gegdg/.codex/plugins/cache/openai-bundled/computer-use/26.1111.21308/skills/computer-use/SKILL.md) remite a su [guía de ejecución](C:/Users/gegdg/.codex/plugins/cache/openai-bundled/computer-use/26.1111.21308/docs/guidance.md), que exige: «Use `node_repl` JavaScript for all Computer Use actions». Se verificaron el renderer, los manejadores de entrada y las muestras sintetizadas mediante pruebas; eso no certifica una revisión auditiva humana.
- El portal directo Sharia–universidad sigue cerrado por la geometría del PNG original. El traslado T mantiene la ruta jugable.
- El verificador conserva 18 advertencias de cabeceras de capas ASE preexistentes. Se verificaron sus bytes, sin certificar apertura en LibreSprite.
- Los muebles forman parte del PNG de fondo: se permite la superposición de Rudy sobre los asientos, sin oclusión individual de su respaldo.
