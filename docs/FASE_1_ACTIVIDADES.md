# Fase 1: agenda y progresión diaria

> Este documento describe la base de la agenda. La [Fase 3](FASE_3_FAMILIA.md) amplía las actividades y reemplaza sus valores iniciales de atención y encargos: −20 amor/−20 confianza por esposa no visitada, entregas al comenzar mañana, aceleración con una interacción y guardado v6.

Los siete capítulos conservan sus escenas, elecciones, cartas y combates. Cada jornada tiene **tres actividades ordinarias y un encargo independiente**, elegido entre Cliff y Zanoba. Se puede repetir la misma esposa tres veces o combinar visitas. Dormir no exige gastar todos los espacios; exige terminar la historia obligatoria y cualquier decisión de actividad abierta.

## Recorrido jugable

1. El Día 1 conserva el sueño de Hitogami, la carta —H, la maldición, la entrega de Nanahoshi y ambos tutoriales. Después de la primera anomalía abre su agenda con tres espacios.
2. Los días 2–7 comienzan en su agenda. **Continuar historia** abre las escenas y encuentros existentes; al completarlos se regresa a la agenda. Sus costes son explícitamente cero.
3. **Actividades** muestra visitas, espacios y posibles cambios de amor/confianza. Reservar consume un espacio; decidir completa la actividad. Guardar durante la decisión conserva esa reserva.
4. **Encargos** muestra recompensas, plazos y trabajos pendientes. Pedir uno bloquea ambas opciones hasta mañana, sin consumir una actividad.
5. **Finalizar día** aplica el cierre, guarda, presenta las entregas de cartas pendientes y muestra el resumen. Confirmarlo abre el siguiente capítulo. **Cambios de ayer** permite consultar el informe anterior.

El Día 7 anuncia **Cerrar tiempo libre e ir a la historia**: fija primero las consecuencias de atención y bloquea actividades/encargos antes de las decisiones matrimoniales. Así, una actividad posterior no contradice un desenlace ya resuelto. El cierre posterior no vuelve a aplicar esas consecuencias. Después del resumen del Día 7 se presenta el epílogo existente.

## Estado y responsabilidades

`src/systems/daily.lua` mantiene las reglas. `session.day` sigue siendo la referencia compatible con los sistemas antiguos; `Progression.move` sincroniza `daily.day` al entrar al capítulo siguiente.

```lua
daily = {
    day = 1,
    interactions_total = 3,
    interactions_used = 0,
    visits = {sylphiette = 0, roxy = 0, eris = 0},
    favor_used = false,
    favor_requested = nil,
    active_activity = nil,
    activities_completed = {},
    activities_locked = false,
    events = {},
    rewards_granted = {},
    baseline = {}, -- amor, confianza y matrimonio al empezar
    ending_processed = false
}
```

`pending_favors` conserva solicitudes con `requested_day`, `due_day`, `status` e `instance_id`; las entregadas conservan su registro. `daily_history["1"]` a `["7"]` contiene visitas, actividades, espacios perdidos, encargo, recompensas, cambios y valores de relaciones antes/después. `events_by_day["1"][id]` indexa eventos sin quitar las claves globales que ya consultan los capítulos.

Las escenas declaran `interactionRule="narrative"` e `interactionCost=0`. Las actividades tienen IDs propios (`time_roxy`, etc.) y `cost=1`. Las tres acciones internas de una conversación con cartas son independientes de los tres espacios de la agenda.

## Cierre e idempotencia

El cierre registra interacciones, aplica atención, entrega encargos vencidos, actualiza misiones, consolida separaciones explícitas y crea el informe. La aplicación guarda antes de mostrarlo. Si falla la escritura, informa el error y permite reintentar el mismo cierre sin repetir efectos.

- Cada reserva tiene una clave como `day3_activity_2`. Las visitas cuentan al reservar y el efecto se aplica al decidir. No hay cancelación que devuelva un espacio consumido.
- Cada esposa visitada recibe +1 confianza al cierre; no visitarla cuesta 1 confianza. Las actividades conceden +2 amor/+1 confianza o +1 amor/+2 confianza, respetando 0–100. Ninguna cifra separa automáticamente un matrimonio: siguen vigentes las decisiones narrativas existentes.
- Cada efecto de atención usa `day3_attention_roxy`; cada cierre, `day3_ending_processed`.
- Cliff entrega Curación básica y +2 energía externa al cierre siguiente; el encargo del Día 7 vence ese mismo día. Zanoba entrega Defensa física y +2 energía externa al cierre actual. La energía respeta el límite de 30.
- `day3_favor_cliff_notes_delivered` protege tanto cartas como energía. Otro día permite un nuevo trabajo; una carta ya adquirida no vuelve a añadirse ni a presentar su entrega.
- Las actividades reservadas deben terminar antes del cierre. Los encargos que aún no vencen continúan pendientes al día siguiente.

## Agregar contenido

Agregar una actividad a `src/data/activities.lua` con ID estable, esposa, título, descripción, `cost=1` y decisiones con ID, etiqueta, resultado y efectos compatibles con `Events.apply`. `requires` admite el lenguaje de condiciones existente. `Daily.startActivity` controla disponibilidad, matrimonio y presupuesto; `resolveActivity` aplica el efecto con una clave por ejecución. La máquina principal no necesita una rama por actividad.

El catálogo de encargos usa `delay` y `effects`. La interfaz pagina el catálogo de actividades en grupos de tres. Las siguientes fases pueden agregar escenas o un presentador específico conservando la reserva persistente y su identificador.

`src/data/day_cycle.lua` conecta agendas y resúmenes con los capítulos declarativos. Las escenas originales permanecen en `src/data/chapters/dayN.lua`. `agenda.lua` y `day_report.lua` presentan la jornada y el informe, con teclado y ratón.

## Guardado y pruebas

El formato **v4** usa `campaign-v4.json` y su respaldo. No intenta continuar una campaña v3 como si ya tuviera reservas diarias: ofrece importar su colección compatible e iniciar la nueva progresión, conservando los archivos originales. [Formato](GUARDADO.md).

`tests/daily.lua` recorre las 27 distribuciones, decisiones pendientes, carga en disco, cierre voluntario, encargos diferidos, duplicados, datos inconsistentes y conservación de v3. `tests/campaign.lua` recorre la historia con agendas y carga entre checkpoints. `tests/restructure_integration.lua` conduce y renderiza las pantallas reales. [Resultados ejecutados](VERIFICACION.md).

```powershell
$env:DATESIM_TEST_GROUP='daily'
& 'C:\Program Files\LOVE\lovec.exe' . --test
# Suite completa:
Remove-Item Env:DATESIM_TEST_GROUP
& 'C:\Program Files\LOVE\lovec.exe' . --test
```
