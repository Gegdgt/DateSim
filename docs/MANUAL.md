# Manual del aventurero

Rudy y sus tres esposas son adultos. Una poción le ha quitado la voz y la magia. Hitogami amenaza sus matrimonios si revela deliberadamente su secreto mientras permanece maldito. Tienes siete días para encontrar el antídoto y afrontar las consecuencias de tus decisiones.

## Terminar y consultar tu campaña

El Día 7 puedes preparar cartas, equipo y relaciones y guardar con F5 antes de afrontar a Badigadi. Viajar solo es una opción válida; sus 1000 PV, ataques y sello se resuelven con las mismas reglas de combate. Una derrota permite reintentar. El antídoto recupera la voz y el maná, pero no recupera matrimonios separados.

Las explicaciones familiares, la devolución de las cartas a Nanahoshi y el epílogo preceden al cierre de la última jornada. El Día 7 concluye por desenlace, sin una séptima noche obligatoria. Al continuar aparece **Resumen de los siete días**. Las pestañas General, Sylphie, Roxy y Eris se eligen con clic o 1–4. **Recuerdos y decisiones** permite recorrer los acontecimientos; **Ver final** vuelve a la tarjeta del desenlace. Puedes consultar el diario y la colección sin cambiar las cifras. Un guardado antiguo señala si carece del historial de combates anterior a esta versión.

## Comenzar y leer

Ejecuta `./ejecutar.ps1` con LÖVE 11.5 instalado y elige Nueva partida. El juego comienza en el sueño de Hitogami. Enter, Espacio o clic completan el texto y permiten avanzar. Al despertar controlas a Rudy junto a la cama de Eris. Camina con WASD o flechas (80 píxeles por segundo); mantén Shift izquierdo o derecho para correr (150 píxeles por segundo). Al soltarlo vuelves a caminar. Correr está disponible desde el inicio, no consume recursos y se pausa durante diálogos, menús y transiciones. Saluda con E; estos saludos son gratuitos. La cuarta puerta del segundo piso conduce al estudio. Acércate al escritorio y pulsa **E — Examinar carta**. Enter abre y avanza la lectura. Confirma la firma **—H** para descubrir lo ocurrido; Escape conserva la lectura pendiente sin completar el objetivo.

M abre el minimapa, I el inventario, J el diario, Tab las relaciones y Escape la pausa. Después de leer, camina al jardín, sal a Sharia y usa el punto **T — Traslado** para llegar a la universidad. La tercera puerta lleva a Nanahoshi: pulsa E cerca de ella para pedir ayuda. La carta queda disponible para releer en el diario. Tras el tutorial, busca físicamente a cada personaje. G no abre menús ni avanza la historia. [Controles y capturas de exploración](EXPLORACION_SOCIAL.md).

En el laboratorio se comunica con notas. Nanahoshi adapta las cartas que recibió de Orsted: su magia almacenada permite emitir respuestas sin utilizar el maná de Rudy. El regalo contiene cinco cartas sociales y cinco físicas. Puedes verlas una por una o recibirlas todas en páginas de cuatro. Completa la prueba social y el combate de la anomalía para habilitar las actividades del primer día.

En las entregas múltiples, **1** elige «Ver una por una» y **2**, «Recibir todas»; también puedes usar el mouse, Tab y Enter. **S / Esc** omite las animaciones y abre el resumen, **M** cambia la modalidad y **R** consulta la siguiente reacción. Las flechas izquierda/derecha recorren las páginas del resumen. **F5** guarda. Las cartas ya están en la colección al empezar la presentación; omitir o cargar no las pierde ni duplica. Las repetidas añaden copias para mejorar y conservan el nivel actual. [Más detalles](ENTREGA_CARTAS.md).

## Organizar la jornada

Eris está en el patio de entrenamiento, Roxy en la biblioteca y Sylphie en la sala de la casa. Acércate y pulsa **E — Hablar con...**. La conversación pausa el movimiento, orienta a los personajes y muestra tres propuestas horizontales de su banco de quince. Selecciona con el ratón, flechas o 1–3 y confirma con Enter. Escape permite despedirte sin gastar una interacción. No existe catálogo global ni botón para cambiar de esposa.

Cada día hay tres interacciones compartidas. Puedes distribuirlas como quieras. Elegir una actividad válida reserva su lugar; se cuenta como utilizada cuando termina. Los gastos propios de una actividad se aplican al confirmarla. La selección de propuestas filtra requisitos y cartas equipadas. Entrenar con Eris permanece disponible los días 1–5 mientras falte ese entrenamiento; la investigación de Roxy se fija cuando corresponde.

Una actividad social permite jugar hasta tres cartas con **seis puntos de energía**. Las cinco cartas iniciales sirven en todas las actividades. El reverso original se baraja, tres cartas llegan a la mano y dos quedan en el mazo. Tras cada una de las dos primeras respuestas se toma otra carta distinta; siempre hay tres opciones antes de cada turno. Las cartas que no puedes pagar indican SIN ENERGÍA. Cada marco muestra categoría, icono, nombre y coste para esa persona. Selecciona para leer la frase exacta de Rudy y confirma con Enter. Escape cambia de carta sin gastar; P termina la conversación antes de agotar la mano. Las reacciones y los puntos reales aparecen después de jugar. Las compras, desafíos y combates continúan tras esta conversación y conservan sus mecánicas.

**Escuchar** cuesta 3 con Sylphie, 1 con Roxy y 2 con Eris. En un contexto favorable de nivel 1 puede aportar respectivamente 5, 1 y 2 de amor. El contexto puede producir una penalización; el coste no garantiza una respuesta favorable. Los niveles, las relaciones y el límite diario siguen modificando el resultado.

Al cerrar la tercera actividad, todas las esposas activas regresan a sus dormitorios. Termina la conversación antes de verlas cambiar de lugar. El minimapa y el objetivo se actualizan. No hay cuarta actividad. La investigación obligatoria continúa hablando con Nanahoshi en el laboratorio, incluso después de usar las interacciones. En el día 7, esa conversación cierra el tiempo libre para afrontar el desenlace.

Cliff y Zanoba ofrecen encargos al hablar con ellos en el taller. Conservan inversión, ptomabilidad de fracaso, entrega mañana y prohibición de repetir la tarea de ayer. Ayudar personalmente gasta una interacción y requiere seguir junto al encargado. El diario muestra encargos pendientes, pero no permite contratarlos.

Vuelve al segundo piso para descansar con una esposa presente. Confirma la conversación nocturna o regresa al mapa. El descanso aporta hasta +10 amor/+10 confianza, fuera del límite diurno, una sola vez. No visitar a una esposa durante el día mantiene la penalización de −20/−20 aunque duermas con ella. Una separación impide el descanso romántico. El jergón permite dormir solo. Los días 1–6 exigen tres interacciones totales y la historia obligatoria; si todas las esposas están separadas, el diario explica la dispensa de actividades. Las visitas individuales son recomendaciones, no requisitos.

Después de la transición nocturna se guarda y aparece el resumen. Rudy despierta donde descansó; las esposas vuelven a sus lugares diurnos. F5 conserva mapa, posición, mano, descarte, energía y resultados pendientes. Cargar no vuelve a repartir ni entrega premios otra vez.

## Conversar mediante cartas

En el mapa, los saludos breves son gratuitos y no dan amor ni confianza. La familia recuerda su última reacción incluso al cargar. Acércate a Zenith y pulsa E: **1** saluda a Zenith y **2** a Lucy, que permanece en sus brazos. Zenith responde con gestos; Lucy con movimientos y balbuceos. Rudy saluda mediante pensamientos y gestos mientras tiene la voz sellada.

Los hallazgos aparecen después del tutorial inicial: entre uno y tres por día. Pulsa E para examinarlos; el inventario I muestra cantidades y oro. **F**, dentro del inventario, usa un fragmento (+2 energía externa, máximo 30); no recupera la voz ni el maná natural. Los libros comunes se usan desde la colección/mejoras; los títulos de Roxy se compran una sola vez. La carta —H nunca se vende ni se consume. Las tumbas de Paul y Oldeus permiten reflexionar sin gastar interacciones ni obtener botín.

Después de saludar a Roxy, sus opciones permiten reservar una visita para comprar libros o materiales, investigar o consultar mejoras. Reservar una visita no entrega artículos: confirma la compra y paga el precio en la librería o tienda. Si solo comparas precios, no recibes objetos.

Cada esposa puede ganar hasta **+10 amor y +10 confianza durante el día**, sumando cartas, actividades, combates y eventos. El descanso tiene su bonificación separada. El juego muestra los puntos realmente aplicados, respetando también el máximo de 100. Las pérdidas no restituyen el margen de ganancias del día.

## Mejorar cartas y comprar suministros

En exploración abre **I → C → Mejorar**, o solicita la mejora al hablar con Roxy. Desde la preparación de combate puedes abrir **M → Mejorar**. Selecciona una carta para ver imagen, nivel, efectos actuales y siguientes, copias y oro. La primera copia desbloquea nivel 1; cada mejora desde nivel L consume `2 × L` duplicados más oro. Llegar a nivel 10 requiere 91 copias en total. **Mejorar** se deshabilita si falta algún recurso. La carta se eleva, aparece el destello y se confirma una sola mejora; pulsa **Continuar** para otra. La carta equipada permanece en tu mazo.

La **Tienda** vende copias de cartas que ya tienes, libros (+3 copias sociales al usarlos), materiales (+4 energía externa, máximo 30) y preparación (+4 escudo al comenzar la siguiente batalla). Las existencias se renuevan al cambiar de día. Actividades, encargos, misiones, entrenamientos y combates entregan oro. Elegir algunas cartas para especializar es suficiente; no necesitas mejorar las cuarenta.

El Libro de estudio cuesta **5 oro**, con un máximo de cuatro compras por día. Es un consumible diferente de los títulos únicos de la librería de Roxy. Cada actividad completada también entrega **15 oro al cerrar** por su misión; el resumen registra ese pago diferido. La colección y **MEJORAR CARTAS** muestran si la carta está desbloqueada y equipada, el efecto actual/siguiente y ambos requisitos. Movimiento reducido muestra el resultado estático de la mejora.

**¡CARTA REPETIDA!** indica cuántas copias se añadieron al inventario. Las mejoras sociales multiplican las bonificaciones positivas de la carta y su afinidad con el interlocutor; una consecuencia negativa conserva su valor contextual. Las penalizaciones dependen de la respuesta y la situación. Las técnicas de combate tienen curvas distintas; las más potentes también imponen costes y límites de uso. [Tabla completa de costes](FASE_2_PROGRESION.md).

## Elegir una respuesta

Escuchar, Broma ligera, Hablar con honestidad, Dar ánimo y Coqueteo sutil representan intenciones; las frases cambian según personaje y situación. La mano muestra tres cartas, con tres acciones y seis puntos de energía social. Selecciona para inspeccionar y confirma para jugar. El marco identifica la categoría; el detalle muestra el coste real y la frase exacta de Rudy. La reacción y los puntos aparecen después de confirmar. P ofrece el respiro social disponible en el encuentro.

Los ocho tonos son empático, gracioso, feliz, coqueto, atrevido, sincero, enojado y evasivo. Una frase puede ayudar en un contexto y molestar en otro. Observa el rostro, la respuesta y los cambios de amor/confianza. Las cartas no autorizan revelar el secreto prohibido. Después del antídoto Rudy puede hablar directamente.

Sobre el retrato ves las barras y sus valores. Al aparecer la reacción, los indicadores muestran el cambio con signo y las barras tardan 0,6 segundos en llegar al valor definitivo. Puedes seguir leyendo durante la animación. Movimiento reducido elimina el desplazamiento y conserva los números.

Nanahoshi muestra **Confianza e Interés** durante el tutorial y las investigaciones de los días tres y cuatro. Escuchar, Hablar con honestidad, Dar ánimo, Broma ligera y Coqueteo sutil son las únicas cinco cartas que pueden aumentar su interés. La respuesta depende de la situación; repetir una carta en la misma conversación no repite la recompensa. Su curiosidad o un halago favorable no la convierten en esposa ni crean otro final.

## Cuidar los matrimonios

Las tres relaciones comienzan con 50 de amor y confianza y admiten valores de −100 a 100. Roxy valora cercanía y respeto intelectual; Sylphiette, responsabilidad y apoyo familiar; Eris, igualdad y confianza en su capacidad. Las decisiones, promesas y conflictos quedan en el diario; repetir acciones no borra lo ocurrido. La afinidad alta facilita pequeñas bonificaciones; la negativa reduce ganancias ordinarias, pero permite reconciliación.

La marca central de cada barra es cero. El tramo rojo hacia la izquierda y el indicador **!** señalan conflicto; el número conserva su signo. El resumen muestra las visitas, las pérdidas por abandono y los cambios reales mediante barras animadas. Releerlo o cargar no vuelve a aplicar sus consecuencias.

El abandono reiterado puede provocar una separación a −30 o menos después de advertencias anteriores; una decisión crítica también puede romper el matrimonio. La esposa devuelve el anillo y se marcha (Sylphiette con su hija). Su retrato queda gris, sus actividades se bloquean y no podrá acompañarte ni conceder nuevas habilidades matrimoniales. Guardar, cargar y recuperar la voz no la hacen regresar. [Detalle de las reglas](FASE_3_FAMILIA.md).

J abre el diario desde la historia. Consulta Historial y el botón Carta —H para releer la pista. Las misiones personales, el compromiso explícito y la reparación de conflictos cuentan para el final, además de las puntuaciones. Recuperar voz y poderes no restaura por sí solo una relación.

## Preparar los mazos

En exploración, I y C abren la colección; desde la historia o la preparación de combate se usa M. Elige Social o Combate. Consulta obtención, efectos y requisitos antes de cambiar el borrador. Ambos mazos admiten entre cinco y diez cartas distintas que hayas adquirido. El social debe seguir siendo viable con las tres esposas; el de combate necesita al menos dos ataques. Las exclusivas requieren a su compañera. No se edita durante un encuentro; tras una derrota puedes volver a preparación.

## Combatir

Rudy tiene 30 PV y tres acciones por turno. Sus ataques físicos iniciales no consumen maná. Corte sencillo cuesta además un PV de esfuerzo: ninguna técnica puede pagar tu último punto de vida. La intención enemiga anuncia su próxima acción.

| Control | Acción |
| --- | --- |
| 1–3, flechas o clic | Inspeccionar una carta de la mano. |
| Enter | Confirmar Jugar. |
| D | Defensa básica: cinco de escudo físico, una acción, una vez por turno. |
| V | Esquiva: tres de escudo físico, una acción, una vez por turno. |
| C | Contraataque contra Eris tras bloquear o esquivar efectivamente: una acción. |
| T | Elegir compañera y habilidad de apoyo. |
| E | Terminar turno y tomar una nueva mano después de la acción enemiga. |
| H | Consultar historial de daños, bloqueos y acciones. |
| B | Neutralizar un anclaje del sello de Badigadi cuando esté expuesto. |

Defensa y esquiva no necesitan cartas. El escudo absorbe antes que la vida y caduca al comenzar el siguiente turno. Los fragmentos recuperados permiten usar energía externa para los hechizos de agua y tierra: el indicador natural continúa bloqueado hasta la cura. Sylphiette cura/protege, Roxy analiza/conjura y Eris golpea/interrumpe. Cada compañera tiene una acción propia por turno; sus ataques escalan con el promedio de amor y confianza. Antes de comenzar se muestran potencia, costes, recargas y usos. Las separadas no participan. Con afinidad menor de 25, la curación de Sylphiette exige confirmar el riesgo: la interferencia causa daño del 40% de los PV máximos y puede derrotar a Rudy.

Badigadi tiene 1000 PV en el Día 7. A 750 entra en la fase de seis brazos; a 350 refuerza su resistencia, que el agua, análisis y especiales combinados ayudan a superar. Cuando llega a cero PV, el sello aún protege el antídoto. Usa **Romper sello [B]** dos veces, una acción por anclaje. Badigadi acepta su derrota y sigue vivo. Perder permite reintentar o preparar el mazo; no es un final adicional.

En **Manual → Reglas → Turnos y compañeras** puedes consultar la fórmula: `afinidad = (amor + confianza) / 2`; `multiplicador = max(0, min(100, afinidad)) / 100`; `daño = floor(base × multiplicador + 0.5)`. El especial de Eris, por ejemplo, hace 75 antes de defensas con 50/50 y llega a 150 con 100/100. No todos sus ataques son especiales: cada habilidad muestra costes, recarga, potencia y usos. Las barras de vida y el historial muestran el daño y la curación realmente aplicados.

## Entrenar con Eris

El día cinco Eris propone un duelo sin heridas letales. Conserva su ventaja con la espada: usa defensa, esquiva, contraataque y técnicas de tierra. Ganas al agotar su resistencia. Tras la pelea, lee su valoración: los puntos se aplican cuando responde y quedan guardados una sola vez.

Ganar concede +8 amor y +6 confianza. Una derrota después de una pelea exigente concede +4/+3; una derrota honesta normal, +1/+1. Perder rápido mientras intentas competir no recibe la penalización máxima. Dejar pasar repetidamente ataques disponibles, terminar turnos vacíos y apenas intentar atacar o defender puede hacerle sospechar que te dejaste ganar: −10/−8.

El resultado muestra tus acciones y Eris lo recuerda. Si quedó molesta, puedes disculparte y aceptar una revancha el día seis; ganar o ofrecer una pelea exigente después de la disculpa repara ese conflicto. No hay reintentos para acumular puntos de entrenamiento.

## La visita de Orsted

Completa al menos un entrenamiento con Eris en cada uno de los días 1–5. Repetir tres veces un solo día no sustituye las fechas que faltan. El diario muestra el calendario; cuentan el entrenamiento físico, el compartido, los duelos y la evaluación del duelo principal del Día 5.

Orsted aparece el Día 6 si se cumple la condición. Su demostración anuncia una derrota narrativa: usa cartas y defensa durante cuatro turnos. No pierdes la campaña ni afinidad. Después entrega los patrones que falten y deja elegir dos cartas distintas para N10, una de combate y otra social. Es gratis y no recupera matrimonios separados. Puedes completar la campaña sin esta ayuda.

## Finales, guardado y opciones

El séptimo día usas el antídoto y resuelves las conversaciones pendientes. Los cinco desenlaces posibles conservan a las tres esposas, solamente a Roxy, solamente a Eris, solamente a Sylphiette o a ninguna. Cuando quedan varias relaciones viables sin unión completa, una conversación explícita resuelve los proyectos compartidos. Después Rudy devuelve las cartas a Nanahoshi, conservando el catálogo y los niveles, y se muestra la escena del epílogo correspondiente.

F5 guarda, Esc abre pausa y F11 cambia pantalla completa. En las pantallas de campaña, Tab/Arriba/Abajo recorren botones; Enter confirma. Opciones ofrece texto instantáneo o velocidad de escritura, movimiento reducido, silencio y volúmenes independientes. El menú permite práctica sin alterar tu campaña. La continuación usa `campaign-exploration-v1.json` y recupera campañas v8 anteriores sin sobrescribir sus archivos. Importar v1/v2/v3 conserva los originales y comienza una nueva campaña. [Detalles del guardado](GUARDADO.md).

## Objetivos del día — J

Pulsa **J** desde cualquier mapa explorable. El diario muestra día, capítulo, historia principal, interacciones, actividades opcionales y objetivos completados con **[X] HECHO** en verde. Las tareas pendientes incluyen progreso y destino. Usa flechas verticales, RePág/AvPág o rueda para desplazarte; ←/→ consulta jornadas anteriores y H abre recuerdos y decisiones. El contenido se actualiza sin cerrar la pantalla.

Después del sueño, el único objetivo es ir al estudio y leer la carta hasta **—H**. Entrar o levantarla no basta. Luego habla con Nanahoshi, recibe cinco cartas sociales y cinco físicas y completa las prácticas social y de combate. Se habilitan tres interacciones: cualquier distribución sirve, incluidas tres con una misma esposa. El diario puede mostrar **Sylphie 0/1, Roxy 0/1, Eris 3/1**; el denominador es una recomendación.

La carta permanece sobre el escritorio. **E — Volver a leer la carta** permite consultarla sin repetir el descubrimiento ni sus efectos. El descanso indica la tarea exacta pendiente o el número de interacciones que falta, usando los mismos objetivos del diario. [Reglas completas](MISIONES.md).
