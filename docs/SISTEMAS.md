# Sistemas de juego de la Fase 1

Los módulos usan Lua compatible con LÖVE 11.5. Cartas y relaciones no dependen del renderizado. Los datos están separados de sus reglas; los textos y encuentros narrativos se definen en `src/data/story.lua`.

## Datos de cartas y personajes

`src/data/cards.lua` exporta `list` (16 definiciones ordenadas), `byId`, `categories` y `starterDeck` (10 identificadores distintos). Cada carta tiene `id`, `name`, `category`, `cost`, `description`, `icon`, `effects`, `contexts`, `affinities`, `conditions` y `unlockedAt`. Los efectos base se suman a los del contexto y a los de afinidad del personaje. `unlockedAt` documenta la intención de contenido; los desbloqueos reales se conceden mediante eventos de historia.

Las categorías son `empathy`, `humor`, `sincerity` e `initiative`. Los contextos implementados son `conversation`, `investigation` y `magic`. `conditions.character` restringe las tres cartas exclusivas a su acompañante. `conditions.kind` permite restringir una futura carta a un contexto. El icono usa el identificador de la carta y `src/data/assets.lua` lo vincula a su PNG español. Los IDs existentes son `remember` y `self_joke`; `choose_together` conserva la categoría `sincerity`.

El mazo inicial contiene Escuchar, Dar ánimo, Broma ligera, Cambiar de tema, Hablar con honestidad, Reconocer un error, Compartir un miedo, Proponer un plan, Analizar runas y Barrera de Tierra. La Fase 1 desbloquea Reírse de uno mismo y Recordar un detalle para la colección, pero no incorpora edición de mazo. Las cartas exclusivas y Elegir Juntos tienen definiciones y condiciones, y no se desbloquean durante estos dos días.

`src/data/characters.lua` exporta `list`, `byId`, `romanceIds`, `spriteWidth`, `spriteHeight`, `expressionCount` y `expressions`. Las expresiones usan índices desde cero: `neutral=0`, `happy=1`, `worried=2` y `angry=3`, correspondientes a los cuatro fotogramas de izquierda a derecha. Cada fotograma mide **64 × 64** y la hoja completa mide **256 × 64**. El recorte comienza en `índice × 64, 0`; una expresión desconocida utiliza el cuadro neutral. `src/systems/resources.lua` aplica `image:setFilter("nearest", "nearest")` a los PNG válidos. Las hojas ausentes, ilegibles o con otras dimensiones utilizan el retrato provisional, incluidas las del formato anterior.

## Recursos: manifiesto y cargador

`src/data/assets.lua` centraliza las rutas, dimensiones, diez identificadores de escenario, dieciséis iconos de cartas y cuatro categorías visuales. `src/systems/resources.lua` carga los 42 PNG únicos, conserva el alfa y utiliza `nearest`. Los alias de escenario comparten la imagen cargada. Solo un recurso ausente, ilegible o de dimensiones incorrectas activa un provisional, con diagnóstico registrado en `sources` y `warnings`. La documentación de rutas, composición por capas y API está en [RECURSOS.md](RECURSOS.md).

Los PNG siguen en `assets/`; los 42 ASE editables se conservan en `sprite_sources/` con el árbol equivalente. Las fuentes no son necesarias para ejecutar LÖVE y deben permanecer versionadas.

## Encuentros: `src/systems/cards.lua`

| API | Resultado |
| --- | --- |
| `Cards.validateDeck(deck, unlocked)` | `true` o `false, motivo`; comprueba 10 cartas conocidas, sin duplicados, y desbloqueadas si se proporciona el mapa. |
| `Cards.new(deck, context, rng)` | Encuentro nuevo. `rng(n)` es opcional y devuelve un entero uniforme de 1 a n. |
| `Cards.canPlay(encounter, index)` | Disponibilidad de una carta de la mano y motivo del rechazo. |
| `Cards.preview(encounter, index)` | Efectos de la carta sin modificar el encuentro. |
| `Cards.play(encounter, index)` | Resultado o `nil, motivo`; aplica una acción válida. |
| `Cards.pass(encounter)` | Acción gratuita que consume un turno y no otorga puntos. |
| `Cards.restore(snapshot, deck, context)` | Encuentro reconstruido y validado, o `nil`. |

Un encuentro comienza con 4 puntos de energía para los tres turnos completos, 3 cartas en mano, 7 en el mazo de robo y ninguna en el descarte. Cada carta jugada consume un turno, paga su coste, pasa al descarte y roba una carta si queda alguna. La energía no se recarga. Una carta inválida, impagable o que incumple condiciones no consume energía ni turno. Tomar un respiro siempre está disponible mientras no hayan terminado los tres turnos, incluso sin energía.

El barajado Fisher-Yates intercambia cada posición `i`, de 10 a 2, con un índice aleatorio entre 1 e `i`. No modifica el mazo seleccionado. Cada encuentro crea sus propias pilas y energía. No se vuelve a mezclar el descarte durante un encuentro.

El resultado contiene `cardId`, `score`, `trust`, `chemistry` y `text`. El estado contiene `hand`, `drawPile`, `discard`, `energy`, `turn`, `maxTurns`, `score`, `finished`, `log` y `context`. Después de la tercera acción, `finished` es verdadero y `turn` vale 4. La interfaz muestra el encuentro como completado. Los cambios de confianza y química se suman del registro y se confirman una sola vez al ver el resultado, mediante el sistema de eventos.

La restauración comprueba que las diez cartas se conservan exactamente una vez entre las tres zonas, que hay tres cartas en mano, que el registro no supera tres acciones y que coincide con el descarte. Recalcula energía, avance y efectos desde las definiciones canónicas. Los encuentros con un registro inconsistente se reinician al continuar; los datos de relación ya confirmados permanecen guardados.

## Relaciones: `src/systems/relationships.lua`

`Relationships.new()` crea registros para Sylphiette, Roxy y Eris con `trust=0`, `chemistry=0`, `events={}`, `routeState="unmet"` y `decisions={}`. `Relationships.apply(all, id, delta)` aplica `trust` y `chemistry`, limitados al intervalo de 0 a 10. `Relationships.complete(all, id, event)` registra un evento y cambia el estado inicial a `friend`.

`Relationships.canRomance(all, id, decisions)` comprueba confianza ≥ 6, química ≥ 5, eventos `route_conflict` y `mirror_truth`, y la confesión explícita `decisions.confession == id`. Es un contrato para contenido futuro: la Fase 1 no concede esos eventos ni presenta confesiones.

`Relationships.ending(all, route, decisions)` devuelve `independent` si no hay una ruta válida, `romance_sylphiette`, `romance_roxy` o `romance_eris` al cumplir todos los requisitos, y `friendship_sylphiette`, `friendship_roxy` o `friendship_eris` en los demás casos con ruta válida. Este soporte lógico está probado. Las escenas de las rutas y de los siete finales pertenecen a fases pendientes; el resumen del día 2 no es un final narrativo.

## Guardado: `src/systems/save.lua`

| API | Resultado |
| --- | --- |
| `Save.newSession()` | Partida inicial con esquema de versión 1. |
| `Save.validate(data)` | Copia normalizada o `nil, motivo`. |
| `Save.write(session)` | `true` o `false, motivo`. |
| `Save.load()` | Partida validada, o `nil, motivo`; puede devolver aviso si recuperó la copia anterior. |
| `Save.exists()` | Indica si existe una partida recuperable. |
| `Save.readOptions()` | Opciones de audio validadas, con valores predeterminados si faltan. |
| `Save.writeOptions(options)` | Guarda opciones independientemente de la partida. |

Se utiliza `love.filesystem` y la identidad configurada en `conf.lua`. Los archivos son `save.json`, `save.backup.json` y `options.json`. El archivo temporal se escribe antes del principal; se conserva una copia anterior válida. No se promete una sustitución atómica: si una escritura se interrumpe, la carga intenta recuperar la copia anterior. Una primera escritura interrumpida puede no tener copia recuperable.

Se guardan día, punto narrativo, índice del diálogo, relaciones, cartas desbloqueadas, mazo, ruta cuando exista, eventos, decisiones, opciones, último resultado y estado del encuentro activo. El día se deriva del punto narrativo válido. Se limitan estadísticas y volumen, se descartan identificadores desconocidos y se sustituye un mazo inválido por el inicial. La validación corrige decisiones mal tipadas. Una decisión de diálogo ya persistida conserva su identificador y el punto de lectura; el sistema narrativo oculta las opciones ya respondidas para permitir continuar. Un capítulo que requiere acompañante vuelve al mapa si falta esa elección.

`src/systems/json.lua` ofrece `Json.encode(value)` y `Json.decode(text)`. El lector no ejecuta código Lua; rechaza sintaxis incompleta, claves duplicadas, números no finitos y estructuras excesivamente profundas. Admite texto UTF-8, escapes Unicode y pares sustitutos. Los archivos de carga se limitan a 512 KiB.

## Verificación

`tests/gameplay.lua` exporta `run()`. Comprueba reglas de cartas, energía cero, índices inválidos, acción gratuita, finalización, preferencias y exclusivas; los siete resultados lógicos de relación; guardados parciales y corruptos, copia de respaldo, opciones, errores de escritura y conservación exacta de encuentros. El sistema de archivos de estas pruebas es una tabla en memoria: no cambia las partidas del jugador.

`tests/resources.lua` verifica el manifiesto contra los PNG existentes, expresiones, dimensiones, transparencia, filtrado y respaldos ante fallos. `tests/story.lua` comprueba decisiones, acompañantes y progresión de ambos días. `tests/ui.lua` comprueba composición, píxeles de texto, disponibilidad y controles de mouse/teclado. `tests/run.lua` integra las pantallas reales, guarda en una identidad de prueba separada, alterna resoluciones y pantalla completa, y produce capturas. Los resultados y límites de cada ejecución se documentan en [VERIFICACION.md](VERIFICACION.md).

## Ampliación narrativa

Las tablas actuales separan contenido de motor, pero `progression.lua` y `save.lua` todavía contienen transiciones y checkpoints específicos de la Fase 1. La ampliación requiere un registro compartido de capítulos y condiciones declarativas, no solo añadir diálogos. [FASE_2.md](FASE_2.md) detalla los módulos, migraciones y pruebas pendientes para los días tres a siete. El evaluador de finales y los fondos preparados no equivalen a capítulos implementados.
