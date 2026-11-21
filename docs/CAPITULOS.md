# La maldición de Rudy: campaña de siete días

Continuidad alternativa posterior a los matrimonios de Rudy con Sylphiette, Roxy y Eris. Todos los protagonistas son adultos. La poción y la maldición son creaciones de esta historia; no pretenden describir una regla canónica de Mushoku Tensei.

Hitogami es el manipulador principal. Badigadi custodia el antídoto por una promesa y ofrece el desafío final; su derrota no pone fin a su inmortalidad. Orsted es un aliado y fue quien entregó originalmente las cartas a Nanahoshi.

## Orden y contenido jugable

Cada capítulo incluye además una agenda con tres actividades libres repetibles y un encargo independiente. El Día 1 la abre después del tutorial; los siguientes empiezan en ella. La historia de la tabla conserva sus encuentros obligatorios con coste cero. El jugador cierra la jornada desde la agenda, revisa el resumen y confirma el avance. El Día 7 fija el tiempo libre antes de sus acuerdos finales. [Ciclo diario](FASE_1_ACTIVIDADES.md).

| Día | Historia y actividades | Progreso permanente |
| --- | --- | --- |
| 1 · El silencio de Rudy | Sueño con Hitogami; despertar en el hogar; interacción con el sobre; lectura de la carta firmada por —H; asociación de la firma; descubrimiento de voz sellada y maná bloqueado; visita privada a Nanahoshi mediante notas; cartas de Orsted; tutorial social y combate real contra la anomalía. | Pista `hitogami_letter`; descubrimientos; cinco cartas sociales y cinco físicas; tutorial completado. |
| 2 · Palabras prestadas | Visitas a las tres esposas mediante respuestas encantadas. Reparto del hogar, investigación entre iguales y práctica de retirada. Elección de compañera; bestia del bosque o desvío seguro; etiqueta de botica. | Promesas y conflictos separados por esposa; pistas de la poción; Recordar un detalle, Respuesta feliz, Respuesta atrevida, Reconocer un error y Compartir un miedo al completar las visitas. |
| 3 · El primer fragmento | Consulta privada; elección de compañera; exploración del bosque; alarma ilusoria y guardián de las ruinas; primer fragmento; discusión familiar sobre responsabilidades. | Fragmento: +12 de energía externa; Proyectil de Agua y Muro de Tierra; Proponer un plan, Analizar runas y Barrera de Tierra. Investigar con cuidado concede Barrera reforzada. El maná natural sigue bloqueado. |
| 4 · El precio del silencio | Orsted y Cliff confirman en privado que escribir el secreto tampoco evita la maldición. Encuentro con el emisario; recuerdo de la entrega y consumo de la poción; consejo familiar sobre riesgos; protector del almacén; investigación del antídoto; promesa de Badigadi y práctica opcional. | Pista `potion_origin`; fragmento: +16 de energía externa; Bala de Agua, Proyectil de Piedra, Respuesta enojada, Disculpa sincera y Cambiar de tema. El análisis cuidadoso concede Pantano. |
| 5 · Lazos puestos a prueba | Tareas individuales con las tres esposas, encuentro social y combate de apoyo para cada una; compromisos, límites y reparaciones. Se anticipan sus proyectos de vida para que las decisiones finales tengan antecedentes. | Refuerzo: +20 de energía externa (máximo 30); Cañón de Agua y su versión superior; técnicas exclusivas si la tarea social tuvo éxito, se asume el compromiso y hay confianza suficiente. |
| 6 · El último cerco | Elección de compañera; reflejo de Rudy; lacayo de Hitogami; prueba opcional de Orsted habilitada por investigar las runas. La prueba permite continuar incluso perdiendo. | Camino abierto y preparación del contenedor. El antídoto sigue con Badigadi; voz y magia permanecen bloqueadas. |
| 7 · El desafío y la verdadera voz | Elegir una compañera, todas las disponibles o viajar solo; Badigadi de 1000 PV, cuatro fases y ruptura del sello; beber el antídoto; conversaciones y epílogo. | `antidote_obtained`, consumo único y uno de cinco finales. Badigadi sigue vivo. La cura no suma afinidad ni restaura matrimonios separados. |

Los IDs históricos de algunos checkpoints (`seal_result`, `seal_truth`, `mirror_final_plan`) permanecen como claves internas para reutilizar las reglas y pruebas de relaciones. Ya no describen una campaña centrada en el Espejo. No se muestran como títulos narrativos.

La consulta del día tres y el estudio del sello del cuarto incluyen encuentros de cartas con Nanahoshi, con Confianza e Interés persistentes. Antes de las tareas personales del día cinco, Eris invita a un duelo no letal (`day5_eris_duel`). Su evaluación distingue victoria, derrota exigente, derrota honesta y aparente falta de esfuerzo. Si esta última provocó un conflicto y Rudy se disculpa, el día seis ofrece una revancha opcional (`day6_eris_rematch`). Una pelea seria puede reconciliarlos; ambos resultados permanecen guardados. [Reglas y umbrales](AFINIDAD_Y_ENTRENAMIENTO.md).

## Voz, cartas y confidencialidad

Cada línea de Rudy de los días 2–6 declara `delivery="enchanted"`, `"note"` o `"thought"`. Sus cartas reproducen una voz almacenada: no rehabilitan las cuerdas vocales ni el flujo de maná. Las conversaciones con sus esposas usan respuestas encantadas; los detalles prohibidos sólo aparecen en pensamientos o consultas explícitamente privadas con aliados. Las esposas pueden expresar sospechas y exigir información sobre rutas, tareas y riesgos sin conocer todavía el secreto de Hitogami.

El recuerdo de la poción se presenta el cuarto día, después del encuentro con el emisario. La introducción nunca comienza con su entrega. El séptimo día, sólo tras usar el antídoto, Rudy vuelve a hablar directamente y explica lo sucedido a las tres.

## Relaciones y cinco finales

Cada esposa empieza con amor y confianza positivos porque el matrimonio ya existe. Se guardan tareas, promesas, incumplimientos, momentos compartidos, conflictos, reconciliaciones y decisiones. Las conversaciones posteriores consultan ese historial: Sylphiette recuerda el reparto de tareas; Roxy, si se escucharon sus dudas; Eris, si se respetaron su criterio y su lesión.

Para mantener una relación se necesitan al menos 55 de amor y confianza, resolución personal, compromiso explícito y conflictos reparados. La familia unida requiere además 75/75 en las tres. Los umbrales se concentran en `src/systems/relationships.lua`.

Los finales principales son exactamente:

1. **La familia Greyrat unida**: continúan los tres matrimonios y los proyectos se coordinan desde el hogar.
2. **Roxy**: continúan juntos en la investigación prolongada acordada.
3. **Eris**: continúan juntos en la ruta de protección.
4. **Sylphiette**: continúan juntos en Sharia con responsabilidades compartidas.
5. **El camino solitario**: terminan los tres matrimonios; Rudy conserva sus responsabilidades familiares.

Cuando dos relaciones siguen siendo viables, las conversaciones del día siete revisan los proyectos anticipados el día cinco. Comprometerse con uno implica despedidas románticas explícitas de los otros matrimonios. El evaluador no selecciona automáticamente a la esposa con mayor amor. Una derrota de combate permite reintentar y no introduce un sexto final.

## Autoría y pruebas

`src/data/chapters/day1.lua`–`day7.lua` contienen escenas, encuentros, decisiones y transiciones. `src/data/endings.lua` contiene los cinco epílogos. Los efectos persistentes pasan por eventos con IDs estables, de modo que guardar, cargar y volver a entrar no repite recompensas.

`tests/campaign.lua` recorre 35 campañas reales variando los ocho conjuntos posibles de matrimonios conservados, las tres compañeras y decisiones de reparación. El recorrido registra la carta como pista, equipa exclusivamente técnicas adquiridas, ejecuta combates legales, neutraliza el sello de Badigadi mediante acciones explícitas, comprueba el consumo del antídoto y guarda/carga entre checkpoints. También prueba que una equivocación temprana o del quinto día puede repararse con antecedentes concretos.

La suite recorre **31 campañas completas y los cinco finales**, incluyendo el duelo real antes de continuar las misiones. La integración adicional verifica los cuatro resultados y la revancha reconciliadora. Es una verificación automatizada del flujo y las reglas; no sustituye una sesión larga de prueba narrativa con jugadores. Las cifras de la ejecución actual se mantienen en [VERIFICACION.md](VERIFICACION.md).
