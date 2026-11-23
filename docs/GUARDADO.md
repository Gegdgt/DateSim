# Guardado de la campaña de la maldición

## Presentación de recompensas (22 de noviembre de 2026)

Se conserva el esquema general v8. Cada entrada de `rewardQueue` añade `celebration` (participantes, fondo, importancia y efecto desconocido) y `presentation.version=1`: modalidad, fase (`choice`, `individual`, `group`, `summary`), índice de carta, página grupal, reacción seleccionada, tiempo transcurrido y señales de sonido ya iniciadas.

La concesión sigue en `Events.apply` / `Collection.grant` y en las transacciones de compra. Se valida antes de modificar el inventario, y el evento se marca junto con el recibo. La cola rechaza recibos con identificador ya registrado. Abrir la presentación guarda el estado concedido; avanzar, cambiar modalidad u omitir sólo cambia la presentación. Cerrar retira únicamente el recibo visual. No se guardan callbacks ni objetos gráficos.

Al cargar, una entrega ya iniciada tiene prioridad incluso dentro de una actividad con servicio pendiente; al cerrarla, el juego retoma ese servicio. Las entregas antiguas con `presentationPage` vuelven a la carta pendiente en modalidad individual. Las nuevas sin modalidad guardada conservan la selección inicial. La prueba `card_rewards` escribe y lee archivos reales en una identidad aislada durante las cuatro fases, comprueba la migración y verifica que no se vuelven a conceder cartas. [Implementación y pruebas](ENTREGA_CARTAS.md).

## Extensión social presencial (22 de noviembre de 2026)

La versión general sigue siendo v8. `exploration` conserva `period`, `periodDay`, `npcLocations` (mapa, pies y orientación) y ausencias; `prologue.wake_departed` cierra la excepción del dormitorio inicial. La restauración deriva la presencia de día, reservas, recibos y separaciones, en vez de confiar en un horario incoherente del archivo.

Las nuevas actividades llevan `daily.active_activity.socialVersion=2`, `pendingReservation`, `initialOrder`, `shuffleSource`, `shuffleSteps`, `hand`, `drawPile`, `discard`, `energy`, `maxEnergy`, `maxCards`, `log`, `before`, `delta`, `choice`, `emotion` y `origin`. Las fases son `intro`, `deal`, `hand`, `playing`, `reply`, `refill` y, según el contenido, `battle`, `service` o `challenge`. Se guardan también tiempos de animación. Confirmar una carta descuenta la energía y cambia de fase; la reacción posterior aplica el evento único de esa carta. Repetir la confirmación o cargar no repite el efecto.

La validación reconstruye las particiones del mazo y el consumo desde el orden y el registro guardados. Comprueba los intercambios de mezcla, pertenencia al mazo equipado, eventos y energía. Los requisitos narrativos de entrada de una carta no se vuelven a exigir a mitad de una mano ya iniciada. El contador diario y la visita se incrementan al completar una reserva nueva, no al abrir la propuesta. Las reservas anteriores que ya gastaron su espacio no se cobran otra vez.

La corrección de la mano añade `handVersion=2`: exige al menos cinco cartas iniciales y tres cartas visibles en las fases `hand` y `refill`. El orden mezclado y la carta tomada en cada entrada de `log` quedan guardados; cargar no vuelve a sortear, reponer, gastar energía ni aplicar efectos. La tercera respuesta nunca toma otra carta. `excludedCards` identifica las cartas equipadas que no cumplen los requisitos de esa actividad.

Las reservas antiguas sin `handVersion` se validan antes de migrar. Si el filtro anterior había omitido cartas ahora compatibles, se incorporan al fondo del orden pendiente y se reconstruyen las reposiciones que faltaban, preservando las cartas ya recibidas, el descarte, la energía y los efectos. No se vuelve a barajar. La migración ocurre una sola vez; los mazos antiguos personalizados que sigan teniendo menos de cinco compatibles pueden completar su reserva con `handVersion=1`. Las reservas nuevas siempre requieren cinco. La prueba `social_hand_cycle` verifica la migración tras cero, una y dos respuestas, además de guardar/cargar durante elección, animación, reacción y reposición. Tres encuentros adicionales prueban `Save.write` y `Save.load` sobre archivos reales, con una identidad exclusiva de pruebas que no toca la partida del jugador.

`wifeActivities.history` conserva cada recibo y las cartas jugadas; `review` permite volver a leer el resultado sin entregar premios. El traslado nocturno espera a cerrar ese recibo. Los encuentros de Nanahoshi nuevos usan `energyVersion=2`; los antiguos conservan su presupuesto original. Los historiales internos de combate mantienen el vocabulario previo para no alterar el replay; la interfaz muestra «tomar».

[Reglas y configuración social](CARTAS_SOCIALES.md) · [Ubicaciones y reconciliación](COLISIONES_NPC.md)

`src/systems/save.lua` usa **versión 8**, continuidad `rudy_curse`. LÖVE escribe en la identidad `cartas_del_destino`, normalmente `%APPDATA%\LOVE\cartas_del_destino\` en Windows.

| Archivo | Función |
| --- | --- |
| `campaign-exploration-v1.json` | Partida actual; conserva el esquema de campaña v8. |
| `campaign-exploration-v1.backup.json` | Última partida anterior válida. |
| `campaign-exploration-v1.tmp.json` | Escritura temporal previa; se elimina al completar el guardado. |
| `campaign-v8.json` y versiones anteriores | Fuentes de recuperación; nunca se sobrescriben. |
| `options.json` | Preferencias globales de audio, texto, movimiento y ventana. |

F5 guarda. También se guarda al avanzar, aplicar decisiones, resolver acciones, cambiar de pantalla y salir. La práctica usa una sesión desechable y no escribe la campaña; al terminar restaura la referencia a la partida original.

La exploración 4 añade `campaignStats.version=1`: valores iniciales observados de las tres relaciones, indicador de historial completo, secuencia de intentos, intento activo y resultados de combates. Cada resultado guarda fuente (checkpoint o reserva), enemigo, día, turnos, victoria/derrota, entrenamiento, derrota narrativa y compañeras. Se registra antes de guardar la acción final; cargar la victoria o la derrota no vuelve a contarlo. Reintentar abre otro intento. La práctica queda excluida.

El resumen no guarda totales duplicados: deriva oro de `economy.transactions`, copias obtenidas del stock más las gastadas en mejoras, fragmentos del stock más consumos y el fragmento narrativo instalado, visitas de `daily_history`, noches de `rest`, decisiones de los historiales y encargos de sus resultados entregados. Las reconciliaciones cuentan resoluciones de conflictos presentes, no efectos vacíos. Cargar un guardado sin `campaignStats` conserva la campaña y marca su registro de combate como incompleto; no inventa intentos anteriores ni valores iniciales desconocidos.

La exploración 3 añade campos opcionales compatibles con v8:

- **wifeActivities**: contador de encuentros, historial por reserva diaria y resultado pendiente de lectura. Guarda elección, consecuencias reales, compras y recuerdos.
- **daily.active_activity**: mano social repartida, fase, carta confirmada, recibo, tirada y resultado experimental fijados al iniciar, origen y progreso del desafío de ritmo. Cargar no vuelve a repartir ni sortear.
- **rest**: una entrada por noche con esposa o descanso solo, mapa de la cama, punto de despertar y bonificación realmente aplicada. El evento dayN_rest impide repetirla; el cierre diario conserva la ausencia por separado.
- **objectives**: registro versionado con ID, día, desbloqueo, estado, progreso numérico, progreso requerido, dispensa por separación total y objetivo actual. Los eventos y actividades validados reconstruyen progreso/completados al cargar; los desbloqueos ya obtenidos se conservan. No se confía en un contador o un estado `completed` editado en el archivo. El catálogo no se copia dentro del guardado.
- **prologue.document_available**: mantiene la carta física en el estudio. Es independiente de `letter_found`, `letter_read`, `hitogami_identified` y del estado de lectura interrumpida. Releer no repite eventos.

El formato exterior continúa en v8 y acepta partidas sin `objectives`. Las partidas afectadas por el salto `day1_result → day1_agenda` recuperan `day1_complete` únicamente si existen las dos prácticas completas, `resolved_day1_tutorial` y `first_anomaly`. `combat_reward_day1_tutorial` junto al encuentro resuelto permite recuperar el marcador del tutorial de combate. No se conceden cartas ni oro durante la migración. El nuevo flujo pasa por `day1_close` antes de abrir la agenda.

Los objetivos se refrescan desde `Events.mark/apply`, cierres de actividades y transiciones. Las pantallas guardan después de sus transacciones habituales. `dayN_attention_<esposa>`, `dayN_rest` y `dayN_ending_processed` siguen protegiendo penalizaciones, bonos e informes. Si se carga entre la confirmación de una noche y su informe, la aplicación continúa el cierre pendiente. El Día 7 termina por desenlace sin exigir un registro `day7_rest`; los registros históricos existentes se conservan.

Las actividades con combate mantienen el replay existente. La validación comprueba cartas equipadas, fases, recibos, recuerdos y reservas antes de aceptar la partida. Las campañas anteriores sin estos campos siguen su recorrido original. Los NPC ausentes tras una separación se derivan de las relaciones guardadas, sin modificar el catálogo de mapas.

La Fase 6 conserva el esquema v8. Sus contadores, barras y vistas derivan del estado existente; no generan otra fuente de verdad. El ajuste del precio del libro afecta compras futuras, sin rehacer recibos antiguos. El modo `--qa-campaign` usa la identidad separada `cartas_del_destino_phase6_manual`; F8 escribe evidencias en `tests/artifacts/` sin tocar el guardado normal.

## Estado persistido

La fase de exploración 2 añade `worldContent.version=1`: `seed`, `days[día]` (instancias, lugares y recompensas de hallazgos), `collected`, `examined`, `npcMemory` y `specialVisits`. La semilla y las instancias se persisten antes de recoger botín; cargar restaura las instancias guardadas. La generación es determinista por semilla y día. El inventario cuantitativo reutiliza `economy.items`, incluidos `mana_fragment` y `flower`. La flor recogida en fase 1 se reconoce al ampliar una partida anterior.

Los nuevos contratos viven en `pending_favors`, dentro del cupo diario existente. Cada inversión añade coste, probabilidad al solicitar, tirada, éxito/fracaso, recompensa concreta, devolución por fallo y `receipt_id`. La fecha de entrega y la ayuda permanecen en los campos existentes. La restauración valida el recibo pagado, el resultado coherente con la tirada y la reserva de interacción de ayuda. Un cambio posterior en la configuración no vuelve a sortear contratos iniciados. Entregas y hallazgos se aplican con claves de evento únicas; los fallos no reciben el premio económico de misión del sistema antiguo.

La fase de exploración añade `exploration={version=1,map,x,y,facing,active,visited,resources,objective}` y `prologue={dream_completed,letter_found,letter_collected,letter_read,hitogami_identified,curse_discovered,nanahoshi_visited,starting_cards_received}`. Se valida el mapa, las coordenadas finitas, la huella libre de sólidos y la orientación. La carta recogida vive en `inventory.hitogami_letter`; la leída también se registra mediante el evento idempotente `hitogami_letter_read` y la pista del mismo nombre.

`documentState` conserva página y fase. Cargar durante la exploración devuelve al mapa y permite reabrir la carta donde quedó; una recogida interrumpida antes de completarse vuelve a mostrar el objeto. Cerrar una página o la firma con Escape no da por terminada la lectura. Solo confirmar la firma activa el descubrimiento. Después del descubrimiento, cargar vuelve al mapa con el objetivo Nanahoshi, sin repetirlo. Las escenas pendientes conservan su índice de diálogo.

Las campañas v8 anteriores, sin `exploration`, mantienen su flujo y checkpoint. La extensión se activa al elegir **Nueva partida**; `Save.newSession()` sigue disponible como base neutral para prácticas, simulaciones y continuidad anterior, y `Prologue.start(session)` inicializa el recorrido nuevo. Se escribe siempre en el nuevo destino, también al continuar una campaña recuperada.

La versión 8 añade `eris_training_days` (fechas con claves de cadena), los eventos de entrenamiento, `orsted_reward` (elecciones, revisión y presentación pendiente), la investigación del emisario, los eventos de las dos mejoras gratuitas y la devolución a Nanahoshi. `curse.chantlessBlocked` se restaura según el consumo del antídoto. Las elecciones y sus niveles se reconstruyen desde eventos y decisiones: cargar durante el destello no vuelve a premiar ni gastar. La devolución conserva la colección completa. [Reglas del cierre](FASE_5_CIERRE.md).

La versión 7 añade el contexto de combate `warVersion=1`: equipo y relaciones iniciales, acción propia de cada compañera, usos, recargas y comandos de apoyo. `support_previous_<esposa>` conserva la potencia del especial en el último combate completado para compararla en preparación. La selección del Día 7 admite una esposa, `all` o `solo`; se filtran las separadas.

La versión 6 añade `family`: progreso de actividades, advertencias, ausencias, separaciones definitivas, libros, recetas, plazo del recado y escenas pendientes con fase/tiempo. Conserva relaciones entre −100 y 100, proveedor y aceleración de encargos y reservas de ayuda sin visitas. Un matrimonio separado permanece separado aunque se cargue otra escena o se cure la maldición. [Reglas familiares](FASE_3_FAMILIA.md).

La versión 5 introdujo `collection[id]={id,level,copies,unlocked}`, `gold`, `economy` (revisión, transacciones, stock por jornada, objetos y escudo preparado) y `daily.relationship_gains`. Tipo, efectos y costes se reconstruyen desde los catálogos. Las entregas guardan cantidades y distinguen primeros desbloqueos de duplicados. Las mejoras guardan el nivel y el gasto en la misma operación; la animación no vuelve a ejecutar transacciones al cargar.

Incluye checkpoint, día y posición de diálogo; maldición y descubrimientos; pistas; inventario del antídoto; capacidad externa; relaciones y sus historiales; decisiones, misiones y enemigos vencidos; cartas adquiridas; ambos mazos; entregas pendientes y su página; estado del documento abierto; encuentros y combate.

La versión 4 introdujo `daily` (espacios, reservas, visitas, actividades, encargo solicitado, eventos, recompensas y cierre), `pending_favors`, `daily_history` y `events_by_day`. Una actividad pendiente ya reservó su espacio: cargar no lo devuelve. El cierre registra el resumen antes de avanzar; las entregas y la atención usan claves por día y ejecución. [Esquema y reglas](FASE_1_ACTIVIDADES.md).

La restauración mantiene el bloqueo de voz y magia hasta que el inventario registre `antidoteUsed`. `documentState` conserva fase, tiempo transcurrido y página: una animación interrumpida continúa desde ese punto sin volver a premiar una lectura registrada. La pista `hitogami_letter` permanece disponible para releer desde el diario.

Los eventos y recompensas usan claves estables. Cargar después de jugar una carta, entregar el primer mazo o vencer un enemigo no aplica de nuevo sus efectos. Los resultados visuales se reconstruyen a partir del estado lógico; no se guardan objetos gráficos ni fuentes de audio.

Los retratos contextuales se reconstruyen desde `checkpoint` y `dialogueIndex`: el sueño recupera fondo `dream`, Rudy japonés y las expresiones de ambos personajes. En campañas nuevas, `day1_wake` recupera el mapa y posición guardados con el sprite rubio; las campañas anteriores conservan su escena de hogar. Se conservan las 11 posiciones de diálogo iniciales. Al cargar se repite la entrada visual, sin repetir efectos narrativos. [Autoría y funcionamiento](RETRATOS.md).

## Conversaciones, reparto y memoria

Las conversaciones conservan `encounter.narrativeVersion=1`, dentro del formato general de campaña v8. `initialOrder` conserva el reparto después del barajado; `hand`, `drawPile`, `discard` y `reserve` conservan mano, pila, descarte y cartas incompatibles apartadas. `initialMemory` es la memoria al entrar; `memory` reconstruye las decisiones de esa conversación. No hace falta volver a consultar un generador aleatorio para cargarla.

Cada acción registrada identifica la carta, su `responseId`, la secuencia escrita y sus consecuencias. `reactionIndex` conserva la línea del intercambio y `encounterReview` indica que aún se está leyendo su resultado. Al restaurar, `Cards.restore` reproduce las acciones desde el reparto y la memoria iniciales, comprueba los IDs resueltos, las cuatro zonas de cartas, energía, turno y avance. Un snapshot incompatible no se acepta como si fuera válido.

La carta consume energía y pasa al descarte al confirmarla. Los efectos sobre la campaña se registran al mostrar la reacción de la persona que la recibe. La clave `social_<sceneId>_<turn>` impide aplicarlos dos veces, incluso si se guarda entre la frase de Rudy y la respuesta, se vuelve a mostrar esa respuesta o se confirma el final del encuentro. El replay local de la mano no vuelve a conceder recompensas a la campaña.

`dialogueMemory.used` conserva el número de usos de cada respuesta o variante. Los eventos y decisiones de las cartas viven en los mapas habituales; promesas, conflictos, reconciliaciones y momentos compartidos continúan dentro de cada relación. No se crean estadísticas paralelas. Entre variantes con igual prioridad y condiciones válidas se prefiere la menos utilizada; cargar no cambia la memoria que decidió una respuesta ya jugada.

El motor social conserva su soporte de replay anterior, pero la campaña v8 no importa encuentros activos de campañas v1/v2/v3. Las nuevas conversaciones usan el catálogo contextual; no se inventan decisiones, promesas ni premios para acciones históricas.

## Validación y recuperación

Antes de escribir se normalizan los datos. El guardado anterior válido se copia al respaldo; la carga intenta primero el principal y luego el respaldo. Esto es una escritura con respaldo, no una promesa de reemplazo atómico del sistema de archivos.

El límite de lectura y escritura es 2 MiB (`Save.maxBytes`): permite combinar un historial extenso con los comandos de hasta 75 turnos del jefe. La prueba de persistencia guarda 582.655 bytes, 600 entradas de historial y 414 comandos; recupera el turno 70 y todos los apoyos. Si la representación supera el límite, se rechaza antes de escribir un archivo que después no pudiera cargarse.

Se comprueban IDs, límites numéricos, checkpoints, elecciones, compañeras y mazos. Un mazo incompleto vuelve al punto de revisión de Nanahoshi conservando las decisiones. El combate se reproduce desde su reparto y comandos: cartas, turnos, tácticas, defensa, esquiva y ruptura del sello. Si el estado resultante no coincide con el snapshot, se descarta ese intento de batalla y se permite reconstruirlo; no se entregan premios al restaurar.

Los combates nuevos guardan `balanceVersion=3` y `context.warVersion=1`, perfil por día, niveles de cartas, equipo y apoyos. El replay verifica PV, fase, mano, recursos, acciones, usos y recargas. `combat_legacy.lua` y `enemies_legacy.lua` conservan balances anteriores para terminar batallas históricas con sus reglas originales. Este versionado es independiente del esquema de campaña. [Reglas de combate](FASE_4_COMBATE.md).

## Importación de partidas anteriores

Si no hay v8 válido, **Continuar** busca v7, v6, v5 y v4 con sus respaldos. V7 conserva combate, familia y colección; las fechas de entrenamiento se reconstruyen únicamente desde actividades completadas y resultados de duelos. Un encuentro ya iniciado contra el lacayo conserva sus reglas e ID. Los checkpoints históricos de la prueba de Orsted por runas siguen pudiendo terminarse, sin conceder retroactivamente el premio nuevo. V6 conserva familia, economía y progreso; v5 recibe los campos familiares; v4 recibe primero la migración económica (cartas en nivel 1, oro inicial 120 y presupuesto diario reconstruido). El siguiente guardado escribe v8 y **no modifica v7, v6, v5 ni v4**. Migrar no reinicia estadísticas. Si el antídoto fue obtenido en el antiguo Día 6, el Día 7 continúa hacia su uso sin exigir repetir el jefe. Un combate histórico mantiene sus reglas y comandos, incluso el antiguo Badigadi de 72 PV.

Los registros sociales anteriores conservan sus efectos históricos durante el replay; las nuevas acciones usan niveles y presupuesto diario. Los combates en curso conservan sus reglas anteriores hasta terminar. Los nuevos guardan `context.progressionVersion=1`, niveles por ID y preparación inicial, además de los comandos existentes. Cambiar el nivel durante un encuentro está prohibido.

El menú detecta `campaign-v3.json`, `campaign-v2.json`, sus respaldos, `save.json` y `save.backup.json`. Cuando no hay una partida v8, ofrece **Importar campaña anterior**. La aceptación explícita inicia la nueva introducción e importa las cartas sociales y de combate compatibles, además de las opciones. No continúa escenas ni encuentros activos anteriores. Los archivos originales permanecen intactos. Si el destino contiene otra versión reconocible, la escritura se rechaza para conservarlo.

Una partida nueva sin importación empieza sin cartas; Nanahoshi entrega diez en total. Una colección importada puede contener cartas previas compatibles: eso no equivale a conceder de nuevo esos premios.

## Afinidad y entrenamiento

Se conservan `affinities.nanahoshi` (confianza, interés, claves premiadas e historial), `trainingResults` (resultado y métricas por checkpoint) y `trainingReview.line` mientras se lee la valoración de Eris. Los campos de afinidad ausentes reciben valores iniciales sin añadir a Nanahoshi a los matrimonios ni otorgar premios retroactivos. Las barras guardan únicamente su estado lógico definitivo; su interpolación no se serializa.

El duelo se restaura reproduciendo sus comandos, incluido el contraataque. La pantalla de resultados puede guardarse antes o después de la reacción que aplica puntos. `training_result_<checkpoint>` impide premiar otra vez al cargar o continuar. Una derrota de entrenamiento continúa la historia; no utiliza el flujo letal de derrota de los combates normales. [Campos, umbrales y eventos](AFINIDAD_Y_ENTRENAMIENTO.md).

## Verificación

La suite general usa `cartas_del_destino_v8_tests`, separada de los archivos del jugador. El entrenamiento usa además `cartas_del_destino_training_tests`. El ciclo diario prueba escritura/carga, cierres repetidos, encargos pendientes y conservación de v3; la interfaz prueba un fallo de escritura y su reintento. [Resultados](VERIFICACION.md). No se verificó resistencia frente a cortes físicos de energía.
