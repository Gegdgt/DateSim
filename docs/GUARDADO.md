# Guardado de la campaña de la maldición

`src/systems/save.lua` usa **versión 4**, continuidad `rudy_curse`. LÖVE escribe en la identidad `cartas_del_destino`, normalmente `%APPDATA%\LOVE\cartas_del_destino\` en Windows.

| Archivo | Función |
| --- | --- |
| `campaign-v4.json` | Partida actual. |
| `campaign-v4.backup.json` | Última partida anterior válida. |
| `campaign-v4.tmp.json` | Escritura temporal previa; se elimina al completar el guardado. |
| `options.json` | Preferencias globales de audio, texto, movimiento y ventana. |

F5 guarda. También se guarda al avanzar, aplicar decisiones, resolver acciones, cambiar de pantalla y salir. La práctica usa una sesión desechable y no escribe la campaña; al terminar restaura la referencia a la partida original.

## Estado persistido

Incluye checkpoint, día y posición de diálogo; maldición y descubrimientos; pistas; inventario del antídoto; capacidad externa; relaciones y sus historiales; decisiones, misiones y enemigos vencidos; cartas adquiridas; ambos mazos; entregas pendientes y su página; estado del documento abierto; encuentros y combate.

La versión 4 añade `daily` (espacios, reservas, visitas, actividades, encargo solicitado, eventos, recompensas y cierre), `pending_favors`, `daily_history` y `events_by_day`. Una actividad pendiente ya reservó su espacio: cargar no lo devuelve. El cierre registra el resumen antes de avanzar; las entregas y la atención usan claves por día y ejecución. [Esquema y reglas](FASE_1_ACTIVIDADES.md).

La restauración mantiene el bloqueo de voz y magia hasta que el inventario registre `antidoteUsed`. `documentState` conserva fase, tiempo transcurrido y página: una animación interrumpida continúa desde ese punto sin volver a premiar una lectura registrada. La pista `hitogami_letter` permanece disponible para releer desde el diario.

Los eventos y recompensas usan claves estables. Cargar después de jugar una carta, entregar el primer mazo o vencer un enemigo no aplica de nuevo sus efectos. Los resultados visuales se reconstruyen a partir del estado lógico; no se guardan objetos gráficos ni fuentes de audio.

Los retratos contextuales se reconstruyen desde `checkpoint` y `dialogueIndex`: el sueño recupera fondo `dream`, Rudy japonés y las expresiones de ambos personajes; `day1_wake` recupera hogar y Rudy rubio. Se conservan las 11 posiciones de diálogo iniciales. La apariencia no necesita campos nuevos; la agenda sí requiere el formato v4. Al cargar se repite la entrada visual, sin repetir efectos narrativos. [Autoría y funcionamiento](RETRATOS.md).

## Conversaciones, reparto y memoria

Las conversaciones conservan `encounter.narrativeVersion=1`, dentro del formato general de campaña v4. `initialOrder` conserva el reparto después del barajado; `hand`, `drawPile`, `discard` y `reserve` conservan mano, pila, descarte y cartas incompatibles apartadas. `initialMemory` es la memoria al entrar; `memory` reconstruye las decisiones de esa conversación. No hace falta volver a consultar un generador aleatorio para cargarla.

Cada acción registrada identifica la carta, su `responseId`, la secuencia escrita y sus consecuencias. `reactionIndex` conserva la línea del intercambio y `encounterReview` indica que aún se está leyendo su resultado. Al restaurar, `Cards.restore` reproduce las acciones desde el reparto y la memoria iniciales, comprueba los IDs resueltos, las cuatro zonas de cartas, energía, turno y avance. Un snapshot incompatible no se acepta como si fuera válido.

La carta consume energía y pasa al descarte al confirmarla. Los efectos sobre la campaña se registran al mostrar la reacción de la persona que la recibe. La clave `social_<sceneId>_<turn>` impide aplicarlos dos veces, incluso si se guarda entre la frase de Rudy y la respuesta, se vuelve a mostrar esa respuesta o se confirma el final del encuentro. El replay local de la mano no vuelve a conceder recompensas a la campaña.

`dialogueMemory.used` conserva el número de usos de cada respuesta o variante. Los eventos y decisiones de las cartas viven en los mapas habituales; promesas, conflictos, reconciliaciones y momentos compartidos continúan dentro de cada relación. No se crean estadísticas paralelas. Entre variantes con igual prioridad y condiciones válidas se prefiere la menos utilizada; cargar no cambia la memoria que decidió una respuesta ya jugada.

El motor social conserva su soporte de replay anterior, pero la campaña v4 no importa encuentros activos de campañas v1/v2/v3. Las nuevas conversaciones usan el catálogo contextual; no se inventan decisiones, promesas ni premios para acciones históricas.

## Validación y recuperación

Antes de escribir se normalizan los datos. El guardado anterior válido se copia al respaldo; la carga intenta primero el principal y luego el respaldo. Esto es una escritura con respaldo, no una promesa de reemplazo atómico del sistema de archivos.

Se comprueban IDs, límites numéricos, checkpoints, elecciones, compañeras y mazos. Un mazo incompleto vuelve al punto de revisión de Nanahoshi conservando las decisiones. El combate se reproduce desde su reparto y comandos: cartas, turnos, tácticas, defensa, esquiva y ruptura del sello. Si el estado resultante no coincide con el snapshot, se descarta ese intento de batalla y se permite reconstruirlo; no se entregan premios al restaurar.

Los combates nuevos guardan `balanceVersion=2`, el día o perfil de dificultad, los usos de curación y la recuperación de escudo enemigo. El motor conserva el replay anterior con `balanceVersion=1`. El versionado del combate es independiente del formato de campaña v4. [Dificultad y límites](COMBATE.md).

## Importación de partidas anteriores

El menú detecta `campaign-v3.json`, `campaign-v2.json`, sus respaldos, `save.json` y `save.backup.json`. Cuando no hay una partida v4, ofrece **Importar campaña anterior**. La aceptación explícita inicia la nueva introducción e importa las cartas sociales y de combate compatibles, además de las opciones. No continúa escenas ni encuentros activos anteriores. Los archivos originales permanecen intactos. Si el destino contiene otra versión reconocible, la escritura se rechaza para conservarlo.

Una partida nueva sin importación empieza sin cartas; Nanahoshi entrega diez en total. Una colección importada puede contener cartas previas compatibles: eso no equivale a conceder de nuevo esos premios.

## Afinidad y entrenamiento

Se conservan `affinities.nanahoshi` (confianza, interés, claves premiadas e historial), `trainingResults` (resultado y métricas por checkpoint) y `trainingReview.line` mientras se lee la valoración de Eris. Los campos de afinidad ausentes reciben valores iniciales sin añadir a Nanahoshi a los matrimonios ni otorgar premios retroactivos. Las barras guardan únicamente su estado lógico definitivo; su interpolación no se serializa.

El duelo se restaura reproduciendo sus comandos, incluido el contraataque. La pantalla de resultados puede guardarse antes o después de la reacción que aplica puntos. `training_result_<checkpoint>` impide premiar otra vez al cargar o continuar. Una derrota de entrenamiento continúa la historia; no utiliza el flujo letal de derrota de los combates normales. [Campos, umbrales y eventos](AFINIDAD_Y_ENTRENAMIENTO.md).

## Verificación

La suite general usa `cartas_del_destino_v4_tests`, separada de los archivos del jugador. El entrenamiento usa además `cartas_del_destino_training_tests`. El ciclo diario prueba escritura/carga, cierres repetidos, encargos pendientes y conservación de v3; la interfaz prueba un fallo de escritura y su reintento. [Resultados](VERIFICACION.md). No se verificó resistencia frente a cortes físicos de energía.
