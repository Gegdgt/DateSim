# Entrega de cartas y celebración contextual

Implementación para LÖVE 11.5 / LuaJIT y resolución lógica de 640 × 360. Se reutilizan los PNG de cartas, marcos, iconos, reversos y retratos. No se editan PNG ni ASE, no se generan sprites y se mantiene el filtrado `nearest`.

## Experiencia

Una entrega de un ejemplar abre directamente la revelación individual. Si hay dos o más ejemplares, incluyendo copias acumulables del mismo tipo, se ofrecen **VER UNA POR UNA** y **RECIBIR TODAS**. El contador individual cuenta tipos de carta; las cantidades recibidas aparecen por separado, sin inventar cartas independientes para cada duplicado.

La modalidad individual muestra reverso, revelación, marco e icono reales, nombre completo, categoría, nivel, cantidad, copias disponibles y efecto. Las técnicas de combate muestran sus valores del nivel actual. Las cartas sociales conservan la descripción de su intención: sus efectos finales siguen dependiendo del interlocutor y del contexto. Al terminar aparece el resumen. **RECIBIR RESTANTES** lleva al mismo resumen sin ejecutar de nuevo la concesión.

La modalidad grupal revela las cartas en páginas de cuatro a tamaño 80 × 112. Todas son accesibles en el resumen; se muestran sus nombres completos, condición nueva/repetida, cantidad y nivel. No se reduce el tamaño de las cartas para encajar entregas grandes como la de Orsted.

| Control | Acción |
| --- | --- |
| 1 / 2 | Elegir individual / grupal |
| Mouse, Tab, arriba/abajo y Enter | Seleccionar botones |
| Enter / Espacio | Completar revelación, avanzar o cerrar el resumen |
| S / Esc | Recibir restantes y abrir resumen |
| M | Volver a elegir modalidad, si hay varios ejemplares |
| R | Ver la reacción del siguiente participante |
| Izquierda / derecha | Página anterior / siguiente del resumen |
| F5 | Guardar |

## Participantes y narrativa

Los cuatro espacios de retrato se sitúan a los lados del contenido. Cada evento tiene entre uno y cuatro participantes, incluido Rudy. Los datos de `src/data/reward_celebrations.lua` contienen variantes distintas para magia, combate y cartas sociales de Rudy, Nanahoshi, Cliff, Zanoba, Eris, Roxy, Sylphie y Orsted.

- El regalo inicial mantiene la escena privada de Rudy y Nanahoshi.
- `seal_will`, en la investigación del cuarto día, declara a Rudy, Nanahoshi, Cliff y Zanoba. La escena de regreso al laboratorio reconoce la colaboración de los cuatro.
- Las actividades de Eris, Roxy y Sylphie conservan a su participante. Los encargos usan a Cliff o Zanoba según quien realizó el trabajo.
- Las victorias usan a la compañera real; los hallazgos muestran a Rudy solo. Comprar dentro de una actividad conserva a su interlocutor; una compra o uso de libro sin interlocutor no inventa un testigo.
- Los regalos de Orsted usan a Orsted. No se cambian las condiciones para acceder a sus recompensas.

Los retratos tienen los cuadros existentes `neutral`, `happy`, `worried` y `angry`; no hay un quinto cuadro de sorpresa. Se utiliza el cuadro preocupado y movimiento breve para sorpresa, y el feliz para celebración. Nanahoshi empieza neutral y se preocupa cuando el evento declara `unknownEffect`. Los movimientos y destellos se omiten con movimiento reducido.

Rudy muestra **PENSAMIENTO** mientras `curse.voiceSealed` esté activo. Después de recuperar su voz, las mismas intervenciones pueden mostrarse como habla. La presentación no usa su voz normal antes de curarse, no consume cartas sociales y no altera el bloqueo de maná. Al recibir magia durante el bloqueo se recuerda la necesidad de energía externa.

## Datos reutilizables

Una recompensa se concede mediante el sistema existente. Los metadatos de celebración sólo describen su presentación:

```lua
Events.apply(session, "research_card_reward", {
    unlock = {"magic_bolt"}, -- Sólo en un evento autorizado por la progresión.
    celebration = {
        participants = {"rudeus", "nanahoshi", "cliff", "zanoba"},
        background = "laboratory",
        important = true,
        unknownEffect = false,
    },
})
```

Los participantes se validan antes de aplicar efectos. Si no hay una declaración explícita, `presenter` o el personaje del evento determinan el reparto; algunos eventos antiguos conservan una configuración identificada por `eventId`. Ninguna frase, retrato o animación concede cartas. Los cofres que actualmente contienen materiales siguen conteniendo materiales; si un objeto concede cartas mediante `copies` o una misión mediante `unlock`, utiliza esta misma cola.

## Concesión y persistencia

`Events.apply` valida el lote y usa el identificador único como protección frente a repeticiones. `Collection.grant` desbloquea la primera copia y acumula los duplicados; las compras mantienen su revisión y recibo existentes. `Events.queueCards` crea un recibo agregado por ID de carta y evita volver a encolar un evento registrado.

La animación se abre cuando las recompensas ya están en la colección y guarda la partida al comenzar. Las funciones de presentación nunca llaman a `Collection.grant`. Cambiar modalidad, saltar, recorrer páginas, reaccionar y cargar no modifica cartas, nivel, maná ni condiciones de uso. Un lote de tres copias de Bala de Agua ya adquirida a nivel 2 y con dos duplicados disponibles muestra **+3 copias**, **nivel 2** y **5 disponibles**.

El guardado v8 conserva `celebration` y `presentation` dentro de cada entrada de `rewardQueue`. Se guarda modalidad, fase, índice individual, página, tiempo de animación y reacción elegida. La entrega iniciada se reanuda antes de un servicio pendiente; al cerrarla continúa ese servicio. Los guardados antiguos con `presentationPage` mantienen su carta pendiente. [Esquema de guardado](GUARDADO.md).

## Archivos

| Función | Archivos |
| --- | --- |
| Datos narrativos | `src/data/reward_celebrations.lua` (nuevo), `src/data/chapters/day4.lua` |
| Estado y recibos | `src/systems/card_rewards.lua` (nuevo), `src/systems/events.lua`, `src/systems/save.lua` |
| Interfaz compartida | `src/ui/reward_presentation.lua` (nuevo), `src/screens/reward.lua`, `src/app.lua` |
| Fuentes de recompensas | `src/systems/economy.lua`, `src/systems/world_content.lua`, `src/systems/progression.lua` |
| Regreso a la actividad | `src/screens/shop.lua`, `src/screens/upgrades.lua`, `src/screens/commissions.lua`, `src/screens/exploration.lua` |
| Audio y ayuda | `src/data/audio.lua`, `src/data/manual.lua`, `README.md`, `docs/MANUAL.md`, `docs/ANIMACIONES.md`, `docs/GUARDADO.md` |
| Verificación | `tests/card_rewards.lua` (nuevo), `tests/economy_ui.lua`, `tests/audio_options.lua`, `tests/run.lua`, `docs/VERIFICACION.md` |

## Pruebas y capturas

`tests/card_rewards.lua` cubre una carta, selección múltiple, ambas modalidades con el mismo inventario, omisión, cambio de modo, idempotencia, cantidades y niveles reales, guardado/carga en disco durante las cuatro fases y migración de entregas antiguas. También comprueba reparto contextual, pensamientos de Rudy, variantes de diálogo, tamaño de textos, paginación, mouse, teclado, movimiento reducido, compra real con Roxy, reanudación del servicio, posiciones de NPC, hallazgo sin testigos y regreso a la tienda.

La regresión incluye recursos, audio, Nanahoshi, economía, actividades matrimoniales, exploración, combate, Orsted y la campaña por pantallas. [Resultados y registros](VERIFICACION.md#entrega-de-cartas-y-celebración).

Capturas del renderer real: [elección y cuatro participantes](../tests/artifacts/reward-choice-party.png), [carta mágica](../tests/artifacts/reward-individual-magic.png), [entrega grupal](../tests/artifacts/reward-group-revealed.png), [segunda página](../tests/artifacts/reward-summary-page-2.png), [tres copias con Roxy](../tests/artifacts/reward-duplicate-roxy.png), [Eris](../tests/artifacts/reward-training-eris.png), [hallazgo de Rudy](../tests/artifacts/reward-found-card-solo.png).

```powershell
$env:DATESIM_TEST_MODULE='card_rewards'
./probar.ps1
Remove-Item Env:DATESIM_TEST_MODULE
$env:DATESIM_TEST_GROUP='regression'
./probar.ps1
Remove-Item Env:DATESIM_TEST_GROUP
```
