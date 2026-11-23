# Entrega: objetivos, diario y descanso

Fecha: 22 de noviembre de 2026. Implementación sobre el repositorio existente, con LÖVE 11.5 / LuaJIT. Los sistemas de cartas, combate, exploración y relaciones se mantienen; no se modificaron los PNG ni ASE originales.

## Causa y corrección

El instalador de agendas cambiaba la salida de `day1_result` a `day1_agenda`, omitiendo `day1_close`, cuyo efecto era `day1_complete`. Al volver a un dormitorio con tres actividades completas, `Rest.available` seguía exigiendo `Daily.storyComplete` y devolvía el aviso genérico. La transición ahora pasa por el cierre antes de abrir el tiempo libre. Las partidas afectadas se recuperan desde evidencia del tutorial terminado, sin repetir historia ni premios.

El catálogo central contiene los siete días y observa los eventos existentes. El diario J, el objetivo de exploración, el destino del minimapa y la validación del descanso comparten ese registro. Las visitas por esposa son recomendaciones sin recorte del numerador; el requisito normal es tres actividades totales. El Día 7 se cierra por desenlace. Orsted puede declinarse. La carta permanece en el escritorio y la relectura no tiene efectos narrativos o económicos.

## Archivos de esta intervención

| Área | Archivos |
| --- | --- |
| Registro nuevo | `src/data/objectives.lua`, `src/systems/objectives.lua` |
| Diario nuevo | `src/ui/objective_journal.lua` |
| Entrada e interfaz | `main.lua`, `src/app.lua`, `src/screens/exploration.lua`, `src/screens/exploration_letter.lua`, `src/screens/rest.lua`, `src/screens/commissions.lua` |
| Progresión y persistencia | `src/systems/prologue.lua`, `src/systems/progression.lua`, `src/systems/events.lua`, `src/systems/daily.lua`, `src/systems/wife_activities.lua`, `src/systems/rest.lua`, `src/systems/exploration.lua`, `src/systems/finale.lua`, `src/systems/save.lua` |
| Narrativa y manual integrado | `src/data/chapters/day1.lua`, `src/data/day_cycle.lua`, `src/data/final_chapters.lua`, `src/data/manual.lua` |
| Prueba nueva | `tests/objectives.lua` |
| Integración de pruebas | `tests/run.lua`, `tests/exploration.lua`, `tests/social_driver.lua`, `tests/social_exploration.lua`, `tests/wife_activities.lua`, `tests/wife_activities_ui.lua`, `tests/world_content.lua`, `tests/campaign.lua`, `tests/campaign_world_driver.lua`, `tests/campaign_integration.lua` |
| Documentación nueva | `docs/MISIONES.md`, `docs/PROGRESION_DIARIA.md`, `docs/DESCANSO.md`, `docs/OBJETOS_NARRATIVOS.md`, este informe |
| Documentación actualizada | `README.md`, `docs/MANUAL.md`, `docs/GUARDADO.md`, `docs/CAPITULOS.md`, `docs/SISTEMAS.md`, `docs/VERIFICACION.md` |

Las pruebas anteriores se ajustaron para declarar la finalización de **ambos** tutoriales en sus fixtures. El piloto de campaña ejecuta las acciones sociales antes del combate. La campaña de abandono sigue completando actividades válidas y resuelve las separaciones mediante las decisiones existentes. La expectativa de siete noches se sustituyó por seis noches y cierre narrativo. Los demás cambios que ya existían en el árbol de trabajo se conservaron.

## Cobertura de los 30 casos solicitados

| Casos | Verificación |
| --- | --- |
| 1–4 | Sólo se muestra el estudio al despertar; entrar/levantar no completa; confirmar la firma registra lectura; tras los descubrimientos se revela Nanahoshi. |
| 5–7 | Entrar al laboratorio no basta; conversación física, entrega única de cinco más cinco cartas, prácticas social y de combate completas. Abrir el tutorial no lo acredita. |
| 8–14 | Progreso 0/3 → 1/3 → 2/3 → 3/3 tras cierres; Eris 3/1 y otras 0/1; distribuciones repetidas válidas. |
| 15–16 | Encargos y visitas recomendadas no bloquean; Orsted se puede declinar; consulta del diario actualizada sin recrear pantalla. |
| 17–20 | Traslado después de cerrar resultado, también tras ayudar en el taller; mensaje compartido con el diario; descanso permitido al cumplir todo; recuperación del flag obsoleto con evidencia. |
| 21–24 | Bono +10/+10, ausencia −20/−20 una sola vez, visitas intactas, resumen, despertar y objetivos nuevos; dispensa por separación total conservada en el historial. |
| 25–28 | Carta física todavía alcanzable y visible; relectura desde el principio; mismos eventos, relaciones, colección, checkpoint y objetivos después de releer. |
| 29 | Serialización JSON y validación, escritura/carga en suites existentes, objetivos históricos, contadores, lectura interrumpida y recuperación entre confirmar la noche y mostrar el informe. |
| 30 | Nueve recorridos completos de exploración por siete días y cinco finales, con y sin Orsted. Se exige no dejar objetivos obligatorios pendientes en el desenlace. |

La regresión específica usa la pantalla real: Rudy se acerca a Roxy después de tres actividades con Eris, pulsa E, confirma el descanso, recibe el informe y avanza al Día 2. Se comprueba también que faltar un requisito produce exactamente el mismo mensaje en diario y descanso.

## Ejecuciones

- `DATESIM_TEST_MODULE=objectives`: **311 comprobaciones, 9 capturas, ALL TESTS PASSED**. [Registro](../tests/artifacts/objectives-tests.log).
- `DATESIM_TEST_MODULE=campaign_integration`: **9 campañas, 7.602 comprobaciones, 14 capturas, ALL TESTS PASSED**. [Registro](../tests/artifacts/objectives-campaigns.log).
- `DATESIM_TEST_GROUP=regression`: **ALL TESTS PASSED**; incluye recursos, exploración, relaciones, actividades, economía, tutoriales, combates, guardado e interfaz. [Registro](../tests/artifacts/objectives-regression.log).
- Suite completa `lovec.exe . --test`: **ALL TESTS PASSED**, incluidas **40 campañas / 28.691 comprobaciones**, las **9 rutas de exploración / 7.602 comprobaciones** y **1.771 comprobaciones de interfaz / 1.164 pasos por pantallas**. [Registro completo](../tests/artifacts/objectives-full-suite.log). La validación focalizada más reciente añade la comprobación visual del manual y el mensaje de confirmación bloqueada, hasta las 311 indicadas arriba.
- `git diff --check`: sin errores de espacios.

Las pruebas usan identidades de guardado separadas de la partida del jugador. La validación de recursos verifica integridad de los originales. Se inspeccionaron visualmente el diario inicial, los contadores nocturnos, la carta permanente, el descanso con Roxy y la página del manual. La cobertura es automatizada con renderer real; no se presenta como una sesión humana completa.

Capturas: [objetivo inicial](../tests/artifacts/objectives-wake-objective.png), [diario inicial](../tests/artifacts/objectives-wake-journal.png), [Eris 3/1](../tests/artifacts/objectives-journal-night.png), [tareas completadas](../tests/artifacts/objectives-journal-completed.png), [carta permanente](../tests/artifacts/objectives-permanent-letter.png), [descanso con Roxy](../tests/artifacts/objectives-roxy-rest.png), [informe diario](../tests/artifacts/objectives-day-report.png), [día siguiente](../tests/artifacts/objectives-day-two.png), [manual](../tests/artifacts/objectives-manual.png).

Guía de autoría: [MISIONES.md](MISIONES.md). Eventos reales: [PROGRESION_DIARIA.md](PROGRESION_DIARIA.md). Persistencia: [GUARDADO.md](GUARDADO.md).
