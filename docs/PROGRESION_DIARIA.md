# Progresión diaria y eventos

Las escenas, combates y relaciones siguen usando los capítulos existentes. Los objetivos observan sus identificadores reales; no crean una segunda campaña.

| Día | Objetivos narrativos / evidencia |
| --- | --- |
| 1 · El silencio de Rudy | `hitogami_letter_read`, `nanahoshi_conversation_started`, `starter_gift`, `tutorial_completed` + `combat_tutorial_completed`, `day1_complete` |
| 2 · Palabras prestadas | Compromisos narrativos y expedición del bosque; `day2_complete`. Las escenas principales no gastan las tres actividades diurnas. |
| 3 · El primer fragmento | Expedición; `ruins_mission`, `seal_truth`, `day3_complete`. Los hitos se revelan según la compañía elegida y las pistas obtenidas. |
| 4 · El precio del silencio | Investigación de Nanahoshi y emisario; `potion_memory`, `seal_will`, `day4_complete`. |
| 5 · Lazos puestos a prueba | Misiones personales y preparación existente; `day5_complete`, respetando las rutas omitidas por separación. |
| 6 · La verdadera amenaza | `emissary_investigation_completed`, `antidote_holder_revealed`, `day6_complete`. La ruta histórica con antídoto ya obtenido sigue siendo válida. |
| 7 · La verdadera voz | `day7_companion_selected`, `antidote_obtained`, `choice_day7_intro`, `relationships_resolved`, `enchanted_cards_returned`, `campaign_complete`. |

En los días 1–6 se requieren tres actividades terminadas y los objetivos narrativos. El traslado nocturno ocurre después de cerrar el resultado de la tercera actividad. Aunque falte historia, las ubicaciones nocturnas se conservan y el diario indica la investigación pendiente. Los encargos y las recomendaciones individuales nunca bloquean el cierre.

El Día 7 cierra el tiempo libre al partir al desafío. Las interacciones disponibles son opcionales; las ausencias se procesan una vez. La devolución de las cartas y el epílogo conducen al resumen diario y al resumen semanal sin exigir una séptima noche.

Orsted se muestra como opcional al cumplir `eris_five_training_days` y conocer `antidote_holder_revealed`. Su invitación permite aceptar o declinar; ambas rutas llegan al cierre del Día 6. Aceptar conserva la demostración y sus recompensas existentes.

El cambio de día conserva los objetivos anteriores y crea contadores nuevos. Las ubicaciones se recalculan desde el día, actividades pendientes, resultados todavía abiertos y separaciones; se guardan junto a posición y orientación de Rudy.
