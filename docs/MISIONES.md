# Objetivos diarios

`src/data/objectives.lua` es el catálogo único. `src/systems/objectives.lua` calcula estados, progreso, objetivo actual y requisitos pendientes. El diario, el indicador de exploración, el minimapa y el descanso consultan este sistema. El diario no entrega recompensas.

Cada definición contiene `id`, `day`, `title`, `description`, `type`, `required`, `requiredProgress`, `unlock`, `dependencies`, `event`, `destination` y `order`. El estado persistido añade `status`, `unlocked` y `progress`. Tipos: `main`, `daily`, `side`, `research`, `combat`, `rest`, `special`. Estados: `locked`, `available`, `in_progress`, `completed`, `failed`.

El catálogo se consulta sólo hasta el día actual. Las dependencias no resueltas ocultan tareas posteriores; un objetivo completado sigue consultable. `unlock` y `complete` usan el lenguaje declarativo de `conditions.lua`; `{}` en `unlock` significa sin condición adicional. `failEvent` permite registrar un fracaso cuando corresponda. Un evento completado tiene prioridad sobre el fracaso.

## Agregar un objetivo mediante datos

Dentro del catálogo, después de declarar la misión de la que depende:

```lua
add(4, "notas", "Contrasta las notas de investigación.", "research", "notas_contrastadas", {
    required=false,
    dependencies={"day4_potion"},
    unlock={event="potion_memory"},
    description="Consulta las notas junto a Nanahoshi.",
    destination={map="laboratorio_nanahoshi",x=312,y=240,label="Laboratorio de Nanahoshi"},
})
```

La actividad física registra `Events.apply(session, "notas_contrastadas", efectos)` al terminar. Si ese evento ya existe, basta con añadir la definición. No agregar condiciones al diario ni a `rest.lua`. Para varios hitos independientes puede usarse `events={"pista_a", "pista_b"}, requiredProgress=2`; cada ID cuenta una vez. Los eventos y recompensas conservan sus transacciones idempotentes originales.

`Events.mark/apply` refresca el registro. Los cierres de actividades también lo refrescan después de actualizar el contador y retirar la reserva. `Q.list`, `Q.current`, `Q.pending` y `Q.requirements` ofrecen las vistas compartidas. La interfaz consulta los datos al dibujar: no hace falta cerrar el diario. Los avisos de finalización son transitorios y no vuelven a aparecer al cargar.

## Interacciones

El progreso se deriva de actividades **terminadas** con un evento válido y único, nunca de una reserva ni del número de cartas jugadas. Incluye ayudar personalmente en un encargo. Las visitas se atribuyen a la esposa de la actividad; ayudar en el taller sólo suma al total. El catálogo anterior conserva sus reservas para compatibilidad, pero el diario sólo cuenta sus cierres.

Las tres visitas individuales son recomendaciones opcionales. Los numeradores no se recortan: Eris puede tener `3/1` y las otras `0/1`. El requisito es el total `3/3`. Si todas están separadas, el requisito de interacciones queda explícitamente dispensado y el diario explica el descanso solo, sin inventar actividades completadas. El Día 7 ofrece actividades opcionales antes del desenlace.

## Auditoría del bloqueo

`day_cycle.lua` desviaba `day1_result` directamente a `day1_agenda`, saltando `day1_close`. Sólo la salida de `day1_close` emitía `day1_complete`. `Rest.available` exigía tanto estar en la agenda como `Daily.storyComplete`, y devolvía el aviso genérico de historia incompleta. El tutorial y las tres actividades podían haber terminado sin ese cierre.

La transición ahora conserva `day1_result → day1_close → day1_agenda`. Al cargar una partida afectada en la agenda o en días posteriores, se recupera el cierre sólo con evidencia de ambas prácticas, el encuentro resuelto y la primera anomalía. No se repiten escenas ni recompensas. Los cierres de los días 2–6 acreditan sus hitos internos; no se añaden flags retrospectivos capaces de bloquear una narrativa ya terminada.

Consulta [progresión](PROGRESION_DIARIA.md), [descanso](DESCANSO.md), [guardado](GUARDADO.md) y [carta permanente](OBJETOS_NARRATIVOS.md).
