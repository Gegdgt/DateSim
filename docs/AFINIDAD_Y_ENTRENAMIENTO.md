# Barras, afinidad y entrenamiento con Eris

Las estadísticas guardadas son los valores definitivos. La animación pertenece a la interfaz: no concede puntos ni escribe valores intermedios en la partida.

## Barras sobre los retratos

`src/ui/relationship_bars.lua` dibuja una placa de 42 píxeles sobre la posición real del retrato. Muestra nombre, dos etiquetas, valores de 0 a 100 y barras de color. Las esposas tienen Amor y Confianza; Nanahoshi tiene Confianza e Interés. Las barras permanecen durante las frases de Rudy y siguen los desplazamientos del personaje. El sueño de Hitogami no muestra estadísticas ajenas.

Al mostrarse la reacción, el motor aplica el evento una sola vez y guarda el estado definitivo. El componente interpola desde su objetivo anterior hasta el nuevo valor durante **0,6 segundos**. Durante **1,2 segundos** muestra los deltas reales con signos, corazones discretos o una indicación negativa y un único sonido de relación. De 98 a 100 se muestra +2, aunque el efecto nominal fuese +5.

Con movimiento reducido, los valores llegan directamente al destino y los indicadores permanecen estáticos. La conversación puede continuar mientras termina la animación. Volver a cargar no reproduce recompensas, corazones ni sonidos ya registrados.

```lua
local Bars = require("src.ui.relationship_bars")
local display = Bars.new(session, "eris", {
    reducedMotion = options.reducedMotion,
    audio = audio,
})
-- Aplicar y guardar el evento lógico antes de llamar a apply.
display:apply(eventId, session, actualDeltas, explanation)
display:update(dt)
display:draw({x=470, y=112, w=64, h=64, width=148})
```

`sync` actualiza objetivos sin emitir feedback. `apply` deduplica el ID y calcula la diferencia entre los estados reales. Ninguna función del componente modifica la sesión.

## Nanahoshi

Su estado vive en `session.affinities.nanahoshi`, separado de `session.relationships`. Empieza con **35 de Confianza y 0 de Interés**. Interés describe curiosidad, agrado o posible atracción, no una relación establecida. No se añade a `romanceIds`, a las rutas matrimoniales ni a los cinco finales.

La lista cerrada está en `src/data/relationships/nanahoshi.lua`:

| Carta | ID real | Máximo de interés por respuesta |
| --- | --- | ---: |
| Escuchar | `listen` | +2 |
| Hablar con honestidad | `be_honest` | +3 |
| Dar ánimo | `encourage` | +2 |
| Broma ligera | `light_joke` | +2 |
| Coqueteo sutil | `subtle_flirt` | +4 |

Son exactamente cinco cartas sociales del mazo inicial. La cifra es un límite, no una bonificación universal: cada respuesta escrita declara sus efectos y sus variantes consultan confianza, interés y decisiones anteriores. El resto de cartas compatibles puede cambiar confianza, pero el motor impide que aumente interés por esta mecánica, incluso si un dato solicita una bonificación indebida.

Hay conversaciones en la práctica inicial y en las investigaciones de los días tres y cuatro. Nanahoshi puede apreciar una observación precisa, contestar con sarcasmo o aceptar un halago sin abandonar su escepticismo. Las respuestas no mezclan frases al azar.

`src/systems/affinity.lua` limita ambos valores a 0–100 y registra dos claves: una por aplicación y otra por conversación/carta ya premiada. Repetir el tutorial o restaurar un resultado no vuelve a conceder puntos positivos. Seleccionar o cancelar nunca aplica efectos. La práctica del menú sigue usando una sesión desechable.

## Duelo del día cinco

Eris invita a Rudy antes de las misiones personales. Rudy acepta mediante una carta parlante y puede preparar su mazo antes de entrar. Ambos usan **resistencia de entrenamiento**, no heridas letales. La lesión del ensayo posterior sucede después del duelo; Eris no compite con el tobillo lesionado.

El encuentro usa `src/systems/combat.lua`: cartas adquiridas, acciones, energía externa, intenciones, escudos, esquiva y replay. Eris aparece como rival, nunca también como compañera aliada. Su ID de encuentro es `eris_training`; el personaje y el retrato siguen siendo `eris`.

La configuración está en `src/data/training.lua` y sus estadísticas en `src/data/enemies.lua`. Actualmente Eris tiene **42 de resistencia** y desvía **dos puntos de cada técnica de espada** de Rudy. Las técnicas de tierra aprovechan su postura. Rudy gana agotando su resistencia mediante preparación y recursos. La configuración también admite un objetivo de impactos válidos, pero ese modo no está activo.

**Defensa [D]**, **Esquiva [V]** y **Contraataque [C]** tienen botones. El contraataque requiere haber bloqueado o esquivado daño real en el turno enemigo anterior: cuesta una acción, causa cinco puntos con el bastón y consume la apertura. No concede otra carta ni utiliza maná natural bloqueado. Una esquiva solo cuenta como efectiva si evita daño que las otras protecciones no cubrían.

## Evaluación y consecuencias

Se registran turnos, acciones, ataques intentados y acertados, puntos causados y recibidos, bloqueos, puntos absorbidos, esquivas efectivas, tácticas, turnos vacíos, aperturas ofensivas perdidas y ganador. `src/systems/training.lua` deriva las métricas de los comandos y las calcula de nuevo al cargar; no confía en cifras de desempeño pegadas al snapshot.

| Resultado | Condición | Amor / Confianza |
| --- | --- | --- |
| Victoria de Rudy | Agota la resistencia de Eris con acciones legales. | +8 / +6 |
| Derrota exigente | Ataques reales, al menos tres indicios de esfuerzo y actividad sostenida. | +4 / +3 |
| Aparente falta de esfuerzo | Varias señales de inactividad evitable y ausencia de presión. | −10 / −8 |
| Derrota honesta | Derrota que no cumple los criterios anteriores. | +1 / +1 |

La derrota exigente cuenta seis indicios: cinco turnos, tres intentos, dos aciertos, al menos un 30 % de resistencia rival reducido, defensa/esquiva y actividad en al menos la mitad de los turnos. No se exigen todos. Además de tres indicios, debe haber cinco turnos o una reducción del 30 % acompañada de bloqueo/esquiva efectivos.

La sospecha exige conjuntamente: al menos cuatro turnos, tres oportunidades legales de atacar desaprovechadas, tres turnos completamente vacíos evitables, como máximo un intento de ataque, como máximo un 10 % de daño relativo y como máximo una acción táctica. La rapidez de la derrota, un mal ataque o poco daño no bastan. Estos umbrales son configurables.

La pantalla presenta ganador, métricas y comentario. Eris pasa por sorpresa y alegría al perder; reconoce una pelea exigente; o pasa de alegría a enfado si observó inactividad repetida. Los efectos se aplican al mostrar su última reacción, con la misma animación de barras que las conversaciones. Salir de la pantalla no los suma otra vez.

Eventos persistentes:

- `eris_training_rudy_victory`
- `eris_training_honorable_defeat`
- `eris_training_suspected_throw`
- `eris_training_honest_defeat`

Las cartas posteriores de Eris recuerdan la estrategia ganadora, la pelea exigente o la derrota honesta. Tras una aparente falta de esfuerzo, una broma puede empeorar el conflicto. Una disculpa reconoce lo sucedido, pero no borra el desacuerdo `training_effort`.

Si el jugador se disculpa en la escena posterior o con la carta correspondiente, puede aceptar **una revancha opcional el día seis**, con Eris recuperada. Una victoria o derrota exigente en esa segunda oportunidad repara el conflicto y registra `eris_training_reconciled`. Los dos resultados permanecen en el historial. El día siete conserva su desenlace sin combates nuevos.

## Guardado y archivos

La versión general sigue siendo v3. Se añaden `affinities`, `trainingResults` y, mientras se lee el resultado, `trainingReview.line`. Los guardados anteriores reciben valores iniciales de afinidad, sin premios retroactivos. El combate y sus métricas se recuperan por replay, y la página pendiente distingue entre una reacción todavía sin aplicar y otra ya registrada.

Las decisiones `eris_training_result`, `eris_training_last_result`, `eris_training_followup` y `eris_rematch_offer` se consultan desde los datos narrativos. Las recompensas usan `training_result_<checkpoint>`: solo una por duelo. Reiniciar una animación o abrir el menú no entrega otra recompensa.

Los módulos nuevos son `relationship_bars`, `affinity`, `training` y `training_result`, con configuraciones, diálogos y pantalla de resultados. Se integran en las pantallas de conversación y combate, los capítulos tres a seis, guardado, validadores y audio. Las pruebas están en `tests/relationship_bars.lua`, `tests/affinity.lua`, `tests/training.lua` y `tests/training_integration.lua`, además de las regresiones de campaña. Los resultados ejecutados se recogen en [VERIFICACION.md](VERIFICACION.md).
