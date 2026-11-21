# Sistemas de la maldición de Rudy

La campaña usa `continuity="rudy_curse"` y esquema de guardado 7. `src/data/chapters.lua` registra los siete capítulos, sus escenas, encuentros, agendas y transiciones. `Progression` evalúa requisitos, resuelve acompañantes y aplica acontecimientos por identificadores estables.

## Actividades y cierre diario

`Family` conserva progreso, promesas, advertencias, separaciones permanentes y escenas pendientes. El catálogo ofrece 16 actividades; los combates reservan el espacio antes de empezar y aplican premios por resultado una vez. Cero visitas cuesta −20 amor/−20 confianza; la separación por abandono requiere umbral, historial y advertencia anterior. `family_routes` permite continuar sin escenas matrimoniales de esposas separadas. Los encargos entregan mañana, o hoy al gastar una interacción con advertencia previa. [Reglas y archivos de la Fase 3](FASE_3_FAMILIA.md).

`CardCollection` mantiene una copia canónica por ID y deriva efectos y costes de `src/data/card_progression.lua`. `Economy` controla oro, stock por día y transacciones con revisión esperada; una confirmación antigua no puede volver a gastar. `Events.apply` acepta `copies={id=cantidad}` y `gold`, además de los desbloqueos existentes. `RelationshipBudget` limita las ganancias a diez por esposa y estadística, incluidas las decisiones narrativas ordinarias. [Contratos y fórmulas](FASE_2_PROGRESION.md).

`Daily` centraliza los tres espacios, visitas repetibles, reservas pendientes, encargo independiente y cierre único. `src/data/activities.lua` declara actividades y encargos; `src/data/day_cycle.lua` conecta las siete agendas sin reemplazar las escenas existentes. Las escenas tienen `interactionRule="narrative"`, coste cero e IDs distintos de las actividades.

La jornada puede terminar con espacios libres una vez resuelta su historia. Registra atención, entrega encargos vencidos, actualiza misiones y matrimonios, guarda y presenta el resumen antes de avanzar. El Día 7 fija la atención antes de las conversaciones finales. `daily_history` permite consultar ayer; `events_by_day` conserva los identificadores de cada jornada. [Esquema, reglas y extensión](FASE_1_ACTIVIDADES.md).

## Maldición y comunicación

`src/systems/curse.lua` crea `active`, `voiceSealed` y `manaBlocked` en verdadero. `discoveredVoice` y `discoveredMana` empiezan falsos: el estado físico existe antes de que Rudy lo descubra, pero la introducción revela ambos bloqueos después de la carta.

Las líneas admiten `delivery`: `dream`, `thought`, `note`, `enchanted`, `silence` o diálogo directo. El sueño es un espacio mental; las notas no son voz. `Progression.scene` impide presentar voz directa de Rudy mientras está sellada, sustituyéndola por pensamiento antes del regalo y por comunicación encantada después. La pantalla muestra el modo de comunicación. Los intentos `silence` no reproducen el sonido de escritura del diálogo.

`Curse.canReveal` rechaza revelar deliberadamente el secreto a una esposa durante la maldición. `Events.apply` comprueba efectos `revealSecret` y el motor social comprueba cartas `revealsSecret`. Las frases disponibles no revelan esa información. `Curse.canUseNaturalMagic` expresa el bloqueo de magia; el combate aplica además el coste de energía externa de los artefactos.

## Documentos y eventos únicos

`src/data/documents.lua` contiene pistas narrativas, incluida `hitogami_letter`. `src/screens/document.lua` anima el sobre, muestra el texto paginado y destaca la firma. Su lectura concede `hitogami_letter_read` y la pista en `session.clues`. Reabrirla desde el diario usa un retorno de pantalla y no concede eventos. Estos documentos nunca entran en `deck` ni `combatDeck`.

`Events.apply(session,id,effect)` valida el lote antes de mutarlo y rechaza un identificador ya registrado. Conserva `session.events`, decisiones y diario. Efectos principales:

| Campo | Resultado |
| --- | --- |
| `starter=true` | Entrega los cinco IDs sociales y los cinco físicos iniciales. |
| `unlock`, `presenter` | Adquiere cartas nuevas y prepara su presentación. |
| `clue` | Añade un documento al registro de pistas. |
| `discoverVoice`, `discoverMana` | Revela los estados al jugador. |
| `externalEnergy` | Aumenta la capacidad de energía externa hasta 30. |
| `antidote` | Añade el antídoto al inventario. |
| `cure` | Exige el antídoto, lo consume, registra `antidoteUsed` y libera voz y magia. |
| `character`, `love`, `trust` | Aplica cambios limitados a una relación. |
| `promise`, `conflict`, `reconcile`, `critical`, `sharedMoment` | Conserva consecuencias narrativas. |
| `mission`, `enemyDefeated`, `familyEvent` | Registra acontecimientos de campaña. |
| `batch` | Aplica varios efectos con la misma clave de acontecimiento. |

La carta se adquiere antes de animarse. `rewardQueue` contiene únicamente cartas recién obtenidas; cerrar la presentación consume la cola. Guardar durante la entrega conserva su página, colección y evento, sin concederlos otra vez.

## Relaciones y finales

`Relationships.new` crea los tres matrimonios con valores configurables, predeterminados en 50/50. `love` y `trust` se limitan a −100–100. Se guardan eventos personales, decisiones críticas, promesas, incumplimientos, momentos compartidos, conflictos pendientes, reconciliaciones y estado matrimonial. Los alias `chemistry` y `routeState` mantienen compatibles las vistas originales; no son estadísticas adicionales.

Una promesa rota crea un conflicto. Cumplirla posteriormente no borra el historial: se necesita `reconcile` para reparar el conflicto. Un descenso de puntuación marca tensión; una separación exige una decisión narrativa explícita. El diario registra los cambios efectivos después de aplicar los límites.

Mantener un matrimonio requiere 55 de amor y confianza, evento `personal_resolution`, compromiso explícito y ausencia de conflictos o incumplimientos sin reparar. La familia unida requiere además 75/75 en cada una. `Relationships.ending` devuelve `family_united`, `roxy`, `eris`, `sylphiette` o `solitary`. Si quedan varias relaciones viables sin cumplir la unión, devuelve `resolution_required`: el día siete abre la conversación correspondiente. No existe un sexto final ni selección automática por puntuación.

## Cartas sociales y combate

`battle_balance.lua` declara enemigos por día y habilidades de apoyo. `companions.lua` toma las relaciones persistentes; `support_actions.lua` aplica afinidad, costes, acciones y recargas. `war_chapters.lua` coloca el jefe en el Día 7. El guardado v7 reproduce apoyos mediante comandos y conserva batallas anteriores con módulos `*_legacy`. [Arquitectura y balance](FASE_4_COMBATE.md).

Las cartas sociales declaran ID, categoría, tono, coste, contextos, frases, efectos, modificadores y obtención. El encuentro conserva la mano y sus acciones; la vista previa no muta el estado. La resolución muestra frase encantada, reacción y cambios, y bloquea entradas repetidas durante la animación. Repetir el mismo acontecimiento no acumula amor.

Los dos mazos admiten 5–10 cartas distintas adquiridas. El social valida viabilidad por personaje; el de combate exige dos ataques ofensivos. Las habilidades exclusivas requieren su compañera. El combate mantiene maná natural, energía externa, escudo físico y mágico, acciones, PV, estados, intenciones y comandos reproducibles. Las tácticas no confirman consecuencias afectivas hasta resolver la victoria. [Combate](COMBATE.md), [persistencia](GUARDADO.md).

La suite general y sus resultados reales se documentan en [VERIFICACION.md](VERIFICACION.md).
