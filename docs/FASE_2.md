# Preparación de los siguientes capítulos

La implementación jugable termina en el resumen del día dos. Los fondos de bosque, observatorio, dimensión del espejo y festival ya tienen rutas en `src/data/assets.lua`; su presencia no significa que las escenas de esos capítulos estén escritas.

## Arquitectura existente y límite actual

`src/data/story.lua` concentra diálogos, decisiones y encuentros. `src/systems/cards.lua` trabaja con datos de efectos, contextos y afinidades; `src/systems/events.lua` registra efectos una sola vez. Esta separación permite añadir contenido sin mezclar texto con dibujo ni alterar las reglas del encuentro.

La progresión aún depende de ramas específicas de la Fase 1 en `src/systems/progression.lua`. `src/systems/save.lua` mantiene su propio conjunto de checkpoints, días y decisiones permitidas. Añadir cinco capítulos directamente a ambas listas duplicaría reglas de navegación y dificultaría las migraciones. La siguiente fase debe convertir esas listas en un registro compartido, conservando los identificadores y guardados actuales.

## Cambios propuestos, todavía no implementados

| Módulo | Cambio para la siguiente fase |
| --- | --- |
| `src/data/chapters.lua` (nuevo) | Registro de capítulos con día, checkpoint inicial, escenas, encuentros y cierre. Derivar los checkpoints válidos de este registro. |
| `src/data/chapters/day3.lua` y sucesivos (nuevos) | Tablas narrativas por capítulo; identificadores estables, fondos del manifiesto y decisiones con efectos explícitos. |
| `src/data/story.lua` | Agregar las tablas de capítulos detrás de su API actual; mantener las claves de la Fase 1 para no invalidar partidas. |
| `src/systems/progression.lua` | Interpretar transiciones declaradas (`next`, resultado de encuentro, requisitos, efectos de salida); conservar la comprobación del checkpoint activo. |
| `src/systems/conditions.lua` (nuevo) | Evaluador pequeño para requisitos por evento, decisión, ruta y vínculo; validación de operadores y referencias. Evitar fragmentos de Lua ejecutables desde datos. |
| `src/systems/events.lua` | Reutilizar claves estables e idempotencia para sellos, desbloqueos, elecciones y confesiones. |
| `src/systems/save.lua` | Consultar el registro compartido de capítulos; generalizar validación de decisiones y acompañantes; añadir migración si cambia el esquema. |
| `src/data/cards.lua` | Declarar desbloqueos y cartas especiales; conservar costes 0–2, mazo de diez y reglas actuales salvo cambio de diseño explícito. |
| `src/screens/overlays.lua` o `src/screens/deck.lua` | Editor de mazo separado de la colección, limitado a diez cartas distintas y desbloqueadas mediante `Cards.validateDeck`. |
| `src/screens/hub.lua` | Consumir los lugares y requisitos del capítulo activo; evitar asumir siempre tres visitas del día dos. |
| `src/systems/relationships.lua` | Reutilizar requisitos de romance y siete IDs de final; separar acompañante de encuentro, ruta y confesión. |
| `tests/story.lua`, `tests/gameplay.lua`, integración | Comprobar todas las ramas, cargas entre decisiones, migración, rechazos de condiciones y aplicación única de efectos. |

Las transiciones deberían contener identificadores de destino y condiciones limitadas a datos, por ejemplo `next="day3_ruins"`, `requires={event="seal_truth"}` y `onComplete={event="day3_complete"}`. Antes de incorporar capítulos nuevos, un validador debe rechazar destinos, personajes, cartas y fondos desconocidos. El cierre de la Fase 1 debe seguir funcionando durante esa migración.

## Contenido previsto

| Día | Escenarios y objetivo | Estado |
| --- | --- | --- |
| 3 | `forest`, `ruins`; investigación del Sello de la Verdad | Fondos listos; narrativa, encuentros y transiciones pendientes |
| 4 | `observatory`; Sello de la Voluntad | Fondo listo; contenido pendiente |
| 5 | Elección explícita de Sylphiette, Roxy o Eris y desbloqueo de su carta especial | Definiciones e iconos de las tres cartas listos; elección y escenas pendientes |
| 6 | `mirror_dimension`; conflicto de ruta y desafío final | Fondo y evaluador de efectos listos; escenas y requisitos narrativos pendientes |
| 7 | `festival`; confesión/decisión final y uno de siete desenlaces | Fondo e IDs de final listos; escenas de los siete finales pendientes |

El siguiente incremento recomendado es extraer el registro de capítulos y migrar la Fase 1 sin cambiar su comportamiento. Una vez que pase el recorrido completo existente, implementar el día tres con el Sello de la Verdad y pruebas de continuación desde guardados del día dos. Audio y distribución independiente pueden esperar a que las rutas narrativas estén completas.
