# Guardado de la campaña de la maldición

`src/systems/save.lua` usa **versión 3**, continuidad `rudy_curse`. LÖVE escribe en la identidad `cartas_del_destino`, normalmente `%APPDATA%\LOVE\cartas_del_destino\` en Windows.

| Archivo | Función |
| --- | --- |
| `campaign-v3.json` | Partida actual. |
| `campaign-v3.backup.json` | Última partida anterior válida. |
| `campaign-v3.tmp.json` | Escritura temporal previa; se elimina al completar el guardado. |
| `options.json` | Preferencias globales de audio, texto, movimiento y ventana. |

F5 guarda. También se guarda al avanzar, aplicar decisiones, resolver acciones, cambiar de pantalla y salir. La práctica usa una sesión desechable y no escribe la campaña; al terminar restaura la referencia a la partida original.

## Estado persistido

Incluye checkpoint, día y posición de diálogo; maldición y descubrimientos; pistas; inventario del antídoto; capacidad externa; relaciones y sus historiales; decisiones, misiones y enemigos vencidos; cartas adquiridas; ambos mazos; entregas pendientes y su página; estado del documento abierto; encuentros y combate.

La restauración mantiene el bloqueo de voz y magia hasta que el inventario registre `antidoteUsed`. `documentState` conserva fase, tiempo transcurrido y página: una animación interrumpida continúa desde ese punto sin volver a premiar una lectura registrada. La pista `hitogami_letter` permanece disponible para releer desde el diario.

Los eventos y recompensas usan claves estables. Cargar después de jugar una carta, entregar el primer mazo o vencer un enemigo no aplica de nuevo sus efectos. Los resultados visuales se reconstruyen a partir del estado lógico; no se guardan objetos gráficos ni fuentes de audio.

Los retratos contextuales se reconstruyen desde `checkpoint` y `dialogueIndex`: el sueño recupera fondo `dream`, Rudy japonés y las expresiones de ambos personajes; `day1_wake` recupera hogar y Rudy rubio. Se conservan las 11 posiciones de diálogo iniciales. No se añade una identidad ni un campo de apariencia persistente, no cambia la versión y no hay migración de partidas. Al cargar se repite la entrada visual, sin repetir efectos narrativos. [Autoría y funcionamiento](RETRATOS.md).

## Conversaciones, reparto y memoria

Las conversaciones nuevas incluyen `encounter.narrativeVersion=1`, dentro del formato general de campaña v3. `initialOrder` conserva el reparto después del barajado; `hand`, `drawPile`, `discard` y `reserve` conservan mano, pila, descarte y cartas incompatibles apartadas. `initialMemory` es la memoria al entrar; `memory` reconstruye las decisiones de esa conversación. No hace falta volver a consultar un generador aleatorio para cargarla.

Cada acción registrada identifica la carta, su `responseId`, la secuencia escrita y sus consecuencias. `reactionIndex` conserva la línea del intercambio y `encounterReview` indica que aún se está leyendo su resultado. Al restaurar, `Cards.restore` reproduce las acciones desde el reparto y la memoria iniciales, comprueba los IDs resueltos, las cuatro zonas de cartas, energía, turno y avance. Un snapshot incompatible no se acepta como si fuera válido.

La carta consume energía y pasa al descarte al confirmarla. Los efectos sobre la campaña se registran al mostrar la reacción de la persona que la recibe. La clave `social_<sceneId>_<turn>` impide aplicarlos dos veces, incluso si se guarda entre la frase de Rudy y la respuesta, se vuelve a mostrar esa respuesta o se confirma el final del encuentro. El replay local de la mano no vuelve a conceder recompensas a la campaña.

`dialogueMemory.used` conserva el número de usos de cada respuesta o variante. Los eventos y decisiones de las cartas viven en los mapas habituales; promesas, conflictos, reconciliaciones y momentos compartidos continúan dentro de cada relación. No se crean estadísticas paralelas. Entre variantes con igual prioridad y condiciones válidas se prefiere la menos utilizada; cargar no cambia la memoria que decidió una respuesta ya jugada.

Un encuentro social v3 iniciado antes de este rediseño, sin `narrativeVersion`, conserva su replay y sus efectos originales. Las conversaciones nuevas usan el catálogo contextual. No se inventan decisiones, promesas ni premios para acciones históricas. Los campos de memoria ausentes se normalizan a mapas vacíos, sin convertir automáticamente partidas v1/v2 a la campaña actual.

## Validación y recuperación

Antes de escribir se normalizan los datos. El guardado anterior válido se copia al respaldo; la carga intenta primero el principal y luego el respaldo. Esto es una escritura con respaldo, no una promesa de reemplazo atómico del sistema de archivos.

Se comprueban IDs, límites numéricos, checkpoints, elecciones, compañeras y mazos. Un mazo incompleto vuelve al punto de revisión de Nanahoshi conservando las decisiones. El combate se reproduce desde su reparto y comandos: cartas, turnos, tácticas, defensa, esquiva y ruptura del sello. Si el estado resultante no coincide con el snapshot, se descarta ese intento de batalla y se permite reconstruirlo; no se entregan premios al restaurar.

Los combates nuevos guardan `balanceVersion=2`, el día o perfil de dificultad, los usos de curación y la recuperación de escudo enemigo. Una batalla anterior reconocida mantiene `balanceVersion=1` y sus reglas durante el replay y el reintento: no recibe más daño ni nuevos límites de curación a mitad de una partida. La versión de campaña sigue siendo 3. [Dificultad y límites](COMBATE.md).

## Importación de partidas anteriores

El menú detecta `campaign-v2.json`, su respaldo, `save.json` y `save.backup.json`. Cuando no hay una partida v3 disponible, ofrece **Importar campaña anterior** y explica el cambio. La aceptación explícita inicia la nueva introducción e importa las cartas sociales cuyos IDs siguen siendo compatibles, además de las opciones. No continúa escenas de la historia anterior ni importa su combate. Los archivos originales permanecen intactos.

Una partida nueva sin importación empieza sin cartas; Nanahoshi entrega diez en total. Una colección importada puede contener cartas previas compatibles: eso no equivale a conceder de nuevo esos premios.

## Afinidad y entrenamiento

La ampliación de afinidad conserva v3 y añade `affinities.nanahoshi` (confianza, interés, claves ya premiadas y aplicadas e historial), `trainingResults` (resultado y métricas por checkpoint) y `trainingReview.line` mientras se lee la valoración de Eris. Los guardados anteriores reciben los valores iniciales de Nanahoshi sin añadirla a los matrimonios ni otorgar premios retroactivos. Las barras guardan únicamente su estado lógico definitivo; su interpolación no se serializa.

El duelo se restaura reproduciendo sus comandos, incluido el contraataque. La pantalla de resultados puede guardarse antes o después de la reacción que aplica puntos. `training_result_<checkpoint>` impide premiar otra vez al cargar o continuar. Una derrota de entrenamiento continúa la historia; no utiliza el flujo letal de derrota de los combates normales. [Campos, umbrales y eventos](AFINIDAD_Y_ENTRENAMIENTO.md).

## Verificación

La suite general usa `cartas_del_destino_v3_tests`, separada de los archivos del jugador. En la ejecución aislada de combate se superaron 24 comprobaciones de integración de persistencia, premios únicos, compañeras y reintentos; el entrenamiento usa además `cartas_del_destino_training_tests`. Los resultados completos de esta entrega están en [VERIFICACION.md](VERIFICACION.md). No se verificó resistencia frente a cortes físicos de energía del equipo.
