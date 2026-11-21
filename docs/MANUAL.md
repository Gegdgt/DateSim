# Manual del aventurero

Rudy y sus tres esposas son adultos. Una poción le ha quitado la voz y la magia. Hitogami amenaza sus matrimonios si revela deliberadamente su secreto mientras permanece maldito. Tienes siete días para encontrar el antídoto y afrontar las consecuencias de tus decisiones.

## Comenzar y leer

Ejecuta `./ejecutar.ps1` con LÖVE 11.5 instalado y elige Nueva partida. El juego comienza en el sueño de Hitogami. Enter, Espacio o clic completan el texto y permiten avanzar. Al despertar, pulsa **Examinar carta**, haz clic en el sobre o usa E/Enter/Espacio. Lee todas las páginas y cierra la carta: después Rudy descubre que no puede hablar ni canalizar magia.

En el laboratorio se comunica con notas. Nanahoshi adapta las cartas que recibió de Orsted: su magia almacenada permite emitir respuestas sin utilizar el maná de Rudy. El regalo contiene cinco cartas sociales y cinco físicas, presentadas en dos grupos. Completa la prueba social y el combate de la anomalía para abrir la agenda del primer día.

## Organizar la jornada

La cabecera de la agenda muestra día y oro; la franja inferior muestra espacios libres, encargo, cartas y misiones. **Cartas** abre los patrones recibidos hoy y sus copias disponibles; **Misiones** muestra objetivo, promesas y entregas pendientes. El incremento de cartas cuenta tipos recibidos, incluidos duplicados. Los tres personajes y la colección siguen accesibles mientras resuelves una actividad: consultar otra esposa permite leer sus opciones sin consumir otro espacio; **Volver a la actividad** retoma la decisión pendiente.

Dispones de tres actividades libres al día. **Elegir actividad** reserva exactamente un espacio y abre una decisión con su recompensa visible. Puedes repetir esposa: tres visitas a Roxy, por ejemplo, son válidas. La cuarta actividad queda bloqueada. Las escenas obligatorias y las acciones internas de los encuentros con cartas no consumen estos espacios.

En **Encargos**, elige un trabajo de Cliff o Zanoba. Comparten un espacio diario independiente de las actividades y entregan al comenzar mañana. No puedes repetir el ID de ayer cambiando de encargado. **Ayudar hoy** muestra una advertencia: gasta una interacción, sin visita matrimonial, para recibir la recompensa hoy. El día 7 solo se aceptan encargos con ayuda inmediata. Una carta ya adquirida entrega copias para mejorarla.

Eris ofrece práctica física, cacerías, duelos reales y coordinación; Sylphiette, hogar, recados de vuestra hija, Zenith, Lilia y conversaciones; Roxy, magia, cartas encantadas, libros e investigación. **Reparar un compromiso** facilita recuperar una relación negativa. La tercera visita recibe una reacción propia sobre las responsabilidades con las demás. La librería cobra oro y vende cada título una vez; las recetas reducen un 20% el oro de una mejora y se consumen.

**Continuar historia** permite resolver los eventos obligatorios. Después puedes **Finalizar día** aunque sobren interacciones: se pierden al avanzar. Haber visitado a una esposa concede +1 confianza al cierre; no visitarla cuesta 20 de amor y 20 de confianza. El resumen muestra visitas, relaciones, decisiones y cartas recibidas; **Ayer** permite volver a consultarlo.

El Día 7 anuncia que continuar la historia cierra el tiempo libre antes de resolver los acuerdos matrimoniales. Realiza las actividades y solicita el encargo que quieras antes de pulsar ese botón. [Reglas y guardado de la agenda](FASE_1_ACTIVIDADES.md).

## Conversar mediante cartas

Cada esposa puede ganar hasta **+10 amor y +10 confianza por jornada**, sumando cartas, actividades, combates y eventos. El juego muestra los puntos realmente aplicados. Las pérdidas no restituyen el margen de ganancias del día.

## Mejorar cartas y comprar suministros

Abre **M → Mejorar**. Selecciona una carta para ver imagen, nivel, efectos actuales y siguientes, copias y oro. La primera copia desbloquea nivel 1; cada mejora desde nivel L consume `2 × L` duplicados más oro. Llegar a nivel 10 requiere 91 copias en total. **Mejorar** se deshabilita si falta algún recurso. La carta se eleva, aparece el destello y se confirma una sola mejora; pulsa **Continuar** para otra. La carta equipada permanece en tu mazo.

La **Tienda** vende copias de cartas que ya tienes, libros (+3 copias sociales al usarlos), materiales (+4 energía externa, máximo 30) y preparación (+4 escudo al comenzar la siguiente batalla). Las existencias se renuevan al cambiar de día. Actividades, encargos, misiones, entrenamientos y combates entregan oro. Elegir algunas cartas para especializar es suficiente; no necesitas mejorar las cuarenta.

El Libro de estudio cuesta **5 oro**, con un máximo de cuatro compras por día. Es un consumible diferente de los títulos únicos de la librería de Roxy. Cada actividad completada también entrega **15 oro al cerrar** por su misión; la agenda anuncia ese pago diferido. La colección y **MEJORAR CARTAS** muestran si la carta está desbloqueada y equipada, el efecto actual/siguiente y ambos requisitos. Movimiento reducido muestra el resultado estático de la mejora.

**¡CARTA REPETIDA!** indica cuántas copias se añadieron al inventario. Las mejoras sociales aumentan solo las bonificaciones propias de cada carta: Escuchar sigue dando confianza y Coqueteo sutil sigue dando amor. Las penalizaciones dependen de la respuesta y la situación. Las técnicas de combate tienen curvas distintas; las más potentes también imponen costes y límites de uso. [Tabla completa de costes](FASE_2_PROGRESION.md).

## Elegir una respuesta

Escuchar, Broma ligera, Hablar con honestidad, Dar ánimo y Coqueteo sutil representan intenciones; las frases cambian según personaje y situación. La mano muestra tres cartas, con tres acciones y cuatro puntos de energía social. Selecciona para inspeccionar y confirma para jugar. El color identifica categoría; el detalle muestra coste, tono, contexto y efectos. P ofrece el respiro social disponible en el encuentro.

Los ocho tonos son empático, gracioso, feliz, coqueto, atrevido, sincero, enojado y evasivo. Una frase puede ayudar en un contexto y molestar en otro. Observa el rostro, la respuesta y los cambios de amor/confianza. Las cartas no autorizan revelar el secreto prohibido. Después del antídoto Rudy puede hablar directamente.

Sobre el retrato ves las barras y sus valores. Al aparecer la reacción, los indicadores muestran el cambio con signo y las barras tardan 0,6 segundos en llegar al valor definitivo. Puedes seguir leyendo durante la animación. Movimiento reducido elimina el desplazamiento y conserva los números.

Nanahoshi muestra **Confianza e Interés** durante el tutorial y las investigaciones de los días tres y cuatro. Escuchar, Hablar con honestidad, Dar ánimo, Broma ligera y Coqueteo sutil son las únicas cinco cartas que pueden aumentar su interés. La respuesta depende de la situación; repetir una carta en la misma conversación no repite la recompensa. Su curiosidad o un halago favorable no la convierten en esposa ni crean otro final.

## Cuidar los matrimonios

Las tres relaciones comienzan con 50 de amor y confianza y admiten valores de −100 a 100. Roxy valora cercanía y respeto intelectual; Sylphiette, responsabilidad y apoyo familiar; Eris, igualdad y confianza en su capacidad. Las decisiones, promesas y conflictos quedan en el diario; repetir acciones no borra lo ocurrido. La afinidad alta facilita pequeñas bonificaciones; la negativa reduce ganancias ordinarias, pero permite reconciliación.

La marca central de cada barra es cero. El tramo rojo hacia la izquierda y el indicador **!** señalan conflicto; el número conserva su signo. El resumen muestra las visitas, las pérdidas por abandono y los cambios reales mediante barras animadas. Releerlo o cargar no vuelve a aplicar sus consecuencias.

El abandono reiterado puede provocar una separación a −30 o menos después de advertencias anteriores; una decisión crítica también puede romper el matrimonio. La esposa devuelve el anillo y se marcha (Sylphiette con su hija). Su retrato queda gris, sus actividades se bloquean y no podrá acompañarte ni conceder nuevas habilidades matrimoniales. Guardar, cargar y recuperar la voz no la hacen regresar. [Detalle de las reglas](FASE_3_FAMILIA.md).

J abre el diario desde la historia. Consulta Historial y el botón Carta —H para releer la pista. Las misiones personales, el compromiso explícito y la reparación de conflictos cuentan para el final, además de las puntuaciones. Recuperar voz y poderes no restaura por sí solo una relación.

## Preparar los mazos

M abre la colección desde la historia; elige Social o Combate. Consulta obtención, efectos y requisitos antes de cambiar el borrador. Ambos mazos admiten entre cinco y diez cartas distintas que hayas adquirido. El social debe seguir siendo viable con las tres esposas; el de combate necesita al menos dos ataques. Las exclusivas requieren a su compañera. No se edita durante un encuentro; tras una derrota puedes volver a preparación.

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
| E | Terminar turno y robar una nueva mano después de la acción enemiga. |
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

F5 guarda, Esc abre pausa y F11 cambia pantalla completa. Tab/Arriba/Abajo recorren botones; Enter confirma. Opciones ofrece texto instantáneo o velocidad de escritura, movimiento reducido, silencio y volúmenes independientes. El menú permite práctica sin alterar tu campaña. La continuación usa `campaign-v8.json`; importar v1/v2/v3 conserva los archivos originales y comienza la nueva progresión diaria. [Detalles del guardado](GUARDADO.md).
