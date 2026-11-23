return function(b)
 local a=b.answer
 local function add(...) b.add("roxy",...) end
 add("R01","Estudiar magia de agua","Roxy dispone una jarra junto a una carta alimentada por un cristal.","¿Qué variable cambiarías antes de aumentar la presión?","Aprender sin presumir.","Progreso de agua; una copia de Bala de agua si ya está desbloqueada.",{familyProgress={water_skill=1},copies={magic_bolt=1}},{
  a("listen","Muéstrame qué cambia en el borde del flujo. Quiero entenderlo antes de probar.","Observa esta ondulación, Rudy. La presión no lo explica todo.",1,2),
  a("be_honest","No estoy canalizando maná propio; compararé la salida del artefacto.","Entonces mediremos la carta, no tu reserva. Gracias por precisarlo.",1,2),
  a("light_joke","Empiezo por alejar tus apuntes de mi historial de inundaciones.","Por fin una medida preventiva impecable. Ponlos en el estante alto.",2,1)})
 add("R02","Estudiar magia de tierra","Dos muestras de suelo reaccionan de forma distinta a la misma carta.","¿Debemos cambiar la fórmula o conocer mejor el material?","Curiosidad y método.","Material mágico, estudio de tierra; Barrera de Tierra si está desbloqueada.",{items={magic_material=1},copies={earth_barrier=1},familyProgress={earth_skill=1}},{
  a("listen","¿Cómo separas la arcilla de la arena al comparar los resultados?","Con agua y paciencia. Hoy necesitarás más de lo segundo.",1,2),
  a("be_honest","Mi primera explicación era demasiado rápida. Volvamos a pesar las muestras.","Eso hace un investigador, Rudy: revisar antes de defender su idea.",1,2),
  a("encourage","Tu tabla deja ver la diferencia. Haré las mediciones que faltan.","Bien. Cuando la completemos, la conclusión será de los dos.",1,1),
  a("analyze_runes","Compararé la runa con cada muestra, manteniendo igual la carga externa.","Y yo anotaré la humedad. Así cambiaremos una sola variable.",1,2)})
 add("R03","Comprar grimorios","Roxy coloca tres libros del librero sobre una mesa de consulta.","¿Qué conocimiento quieres llevarte a casa y cuánto puedes gastar?","Elegir con criterio.","Compra confirmada de un libro: habilidad o receta; el precio se paga aparte.",{familyProgress={research=1}},{
  a("listen","Quiero oír qué aporta cada libro antes de elegir uno.","Entonces empecemos por el índice, no por el tamaño del lomo.",1,2),
  a("be_honest","Necesito revisar el precio. Prefiero comprar uno que de verdad vaya a estudiar.","Me alegra que lo pienses así. Podemos volver otro día.",1,2),
  a("subtle_flirt","El libro tendrá que esforzarse para resultar tan interesante como mi compañera.","Rudy... primero el índice. Después puedes intentar distraerme otra vez.",2,1)}, {service="books"})
 add("R04","Mejorar cartas","Roxy extiende las copias junto al catalizador y deja el presupuesto a la vista.","¿Qué carta usarás lo suficiente para justificar esta mejora?","Responsabilidad material.","Mejora real con copias y oro; progreso de encantamientos.",{familyProgress={enchantments=1}},{
  a("listen","Revisa conmigo la estabilidad de estas copias antes de fusionarlas.","Esta runa es legible. La otra necesita compararse con el original.",1,2),
  a("be_honest","No quiero gastar por tener un nivel más. Revisaré mi mazo primero.","Buena decisión. Una mejora olvidada en la colección sirve de poco.",1,2),
  a("light_joke","¿Existe una mejora para mi capacidad de ordenar las copias?","Sí. Se llama poner etiquetas. Y cuesta bastante menos.",2,1),
  a("analyze_runes","Busquemos una repetición estable en el circuito antes de pagar la fusión.","Ahí está. Ahora sí podemos comprobar el coste exacto.",1,2)}, {service="upgrade"})
 add("R05","Investigar la maldición","Consultas con Roxy un catálogo público de preparados y conservas en privado las notas de Hitogami.","Hay residuos que reaccionan con un catalizador. ¿Qué podemos comprobar sin especular?","Cautela y respeto por los límites.","Pista privada sobre catalizadores y progreso de investigación; no revela el secreto.",{familyProgress={antidote_research=1,research=1}},{
  a("listen","Explícame cómo se distingue una reacción residual de una activa.","Midiendo después de retirar la muestra. Podemos hacerlo sin probarla en nadie.",1,2),
  a("be_honest","No puedo dar una conclusión sobre su origen. Sólo quiero contrastar estos datos públicos.","Entonces no la daremos. Un dato incompleto sigue siendo un dato incompleto.",1,2),
  a("encourage","Tu método evita poner a nadie en peligro. Prepararé las etiquetas.","Gracias, Rudy. El cuidado también forma parte del experimento.",1,1)}, {stable=true,continuation="La relación entre residuo y catalizador queda en el diario privado para consultarla con Nanahoshi."})
 add("R06","Examinar runas antiguas","Roxy trae una copia autorizada de una inscripción. Un trazo parece añadido después.","¿Cómo distinguirías una corrección de una grieta?","Atención compartida.","Un material mágico y conocimiento de runas.",{items={magic_material=1},familyProgress={runes=1}},{
  a("listen","Enséñame dónde cambia el pulso del grabado. Yo seguiré el trazo en la copia.","Aquí, en la esquina. Quien lo añadió quería cerrar el circuito.",1,2),
  a("be_honest","Podría estar viendo un símbolo donde sólo hay una rotura. Compararé otra copia.","Yo buscaré una referencia. No hace falta que acertemos a la primera.",1,2),
  a("light_joke","Espero que no sea la firma de alguien que tampoco entendía la runa.","Si lo es, al menos nos dejó una advertencia muy honesta.",2,1),
  a("analyze_runes","Aislemos el trazo añadido y sigamos por dónde vuelve la energía.","Exacto. El regreso del circuito nos dirá qué cambió.",1,2)}, {minDay=2})
 add("R07","Realizar un experimento","Dos recipientes protegidos esperan una muestra pequeña. Roxy anota el margen de error.","¿Aceptas registrar también un resultado fallido?","Incertidumbre científica.","5 oro de reactivos. 65% de éxito: 2 materiales; fracaso: sin materiales.",{items={magic_material=2},familyProgress={research=1}},{
  a("be_honest","Si falla, conservaremos las medidas. No voy a cambiar el informe para quedar bien.","Entonces podemos empezar. Un fracaso medido sí nos enseña algo.",1,2),
  a("encourage","Me gusta trabajar contigo aunque el resultado tarde. Vamos paso a paso.","Y si no funciona, lo revisaremos juntos, Rudy.",1,1),
  a("light_joke","He dejado libre el apartado de humo inesperado en el formulario.","Muy considerado. Procura que siga vacío.",2,1),
  a("admit_error","La última vez anoté tarde una medida. Hoy llevaré el registro desde el principio.","Eso es una corrección útil. Te avisaré en cada intervalo.",1,2)}, {goldCost=5,successChance=65,continuation="El informe conserva el resultado original, incluso después de cargar."})
 add("R08","Practicar control de maná","El cristal de una carta ilumina la mesa. Roxy te pide regular su salida, sin usar energía propia.","¿Puedes reducir el flujo sin cortar el circuito?","Paciencia ante una limitación.","Un fragmento de maná y control de artefactos.",{items={mana_fragment=1},familyProgress={artifact_control=1}},{
  a("listen","Guíame por los cambios de luz. Ajustaré sólo la válvula del artefacto.","Despacio. Ese tono indica que la carga vuelve a estabilizarse.",1,2),
  a("be_honest","Siento la tentación de forzarlo. Voy a parar antes de sobrecargar la carta.","Parar a tiempo también es control, Rudy.",1,2),
  a("encourage","Tus señales hacen que pueda repetir el ajuste. Hagamos otra serie corta.","Una más, y registramos el límite seguro.",1,1)})
 add("R09","Buscar libros raros","El librero permite consultar su estante reservado. Roxy comprueba las referencias.","¿Vale el precio por lo que contiene o sólo por ser difícil de encontrar?","Entusiasmo contenido.","Catálogo avanzado con precios reales; una compra única y registro bibliográfico.",{familyProgress={rare_books=1}},{
  a("listen","Revisemos las referencias. Quiero saber qué buscarías tú en este volumen.","Una demostración completa. Si sólo copia rumores, se queda aquí.",1,2),
  a("be_honest","Me atrae que sea raro, pero no quiero gastar nuestro dinero por impulso.","Gracias por decirlo. Podemos admirarlo sin comprarlo.",1,2),
  a("subtle_flirt","Encontrar un libro contigo ya convierte la mañana en algo raro y valioso.","Eso no figurará en el recibo... aunque me alegra que lo digas.",2,1)}, {service="rare_books",minDay=3})
 add("R10","Analizar las cartas de Orsted","Roxy compara el sello del lote de Orsted con sus notas de circulación externa.","¿Qué aprendemos del límite que impone esta carta?","Asombro con prudencia.","Conocimiento de Orsted y 2 fragmentos; requiere su lote de cartas.",{items={mana_fragment=2},familyProgress={orsted_analysis=1}},{
  a("listen","Quiero entender por qué el sello devuelve parte de la carga.","Para impedir una salida sostenida. No intentemos eliminarlo.",1,2),
  a("be_honest","Tener la carta no significa que pueda controlarla. Empezaré por su límite.","Ésa es la diferencia entre estudiar y jugar con algo peligroso.",1,2),
  a("encourage","Tu comparación aclara el circuito. Yo documentaré las restricciones.","Anota también quién puede usarla. No todo el lote sirve para cualquier equipo.",1,1),
  a("combined_spell","Comparemos el retorno del sello con el de nuestro conjuro compartido.","Sólo en el papel por ahora. Después decidiremos qué prueba tiene sentido.",2,2)}, {requiredEvent="orsted_collection_gift"})
 add("R11","Preparar una clase juntos","Roxy ensaya una explicación y se detiene al ver una página demasiado llena.","¿Qué pregunta harías si hoy fuera tu primera clase?","Colaboración sin jerarquías.","14 oro por preparar material docente y una copia de Dar ánimo.",{gold=14,copies={encourage=1},familyProgress={teaching=1}},{
  a("listen","Preguntaría qué vemos cambiar antes de aprender el nombre de la fórmula.","Eso les dará algo que observar. Voy a empezar por la jarra.",1,2),
  a("be_honest","Aquí me perdería. ¿Podemos separar el ejemplo de la definición?","Sí. A veces olvido cuánto presupongo. Gracias, Rudy.",1,2),
  a("light_joke","Mi primera pregunta sería si el examen incluye sobrevivir al dibujo de mi jarra.","Entonces dibujaré yo y tú repartirás las hojas.",2,1),
  a("happy_reply","El ejemplo nuevo se entiende mucho mejor. Me alegra haberlo probado contigo.","A mí también. Ya no siento que tenga que acertarlo todo sola.",2,2)})
 add("R12","Estudiar combinaciones mágicas","Roxy coloca dos cartas en circuitos separados y deja un puente sin cerrar.","¿Qué señal usaremos para conectar ambos flujos?","Confianza recíproca.","Material mágico y progreso de Conjuro Combinado (3 investigaciones).",{items={magic_material=1},familyProgress={research=1}},{
  a("listen","Quiero aprender tu señal de parada antes de acordar la de inicio.","Dos toques sobre la mesa. Si los oyes, abrimos el circuito.",1,2),
  a("be_honest","Mi parte depende del artefacto. Ajustemos el ritmo a lo que realmente sostiene.","Así lo haremos. La coordinación no consiste en fingir el mismo límite.",1,2),
  a("encourage","Probemos primero una conexión pequeña que ambos podamos detener.","De acuerdo. El resultado llevará los dos nombres.",1,1),
  a("combined_spell","Conectemos las cartas a la señal común y cortemos juntos al segundo pulso.","Preparada. Miraré tu mano antes de cerrar el puente.",2,2)})
 add("R13","Conversar sobre el pasado","Roxy guarda una libreta de sus primeros viajes y te deja ver una página manchada.","¿También recuerdas lo insegura que podía estar entonces?","Memoria sin idealización.","Un recuerdo del viaje y confianza.",{familyProgress={roxy_memories=1}},{
  a("listen","Me gustaría oír cómo viviste esa época, no sólo lo que yo recuerdo de ti.","A veces preparaba una respuesta toda la noche. Me daba miedo no estar a la altura.",2,2,"worried"),
  a("be_honest","Te admiraba y no veía tus dudas. Ahora quiero conocer también esa parte.","Me cuesta mostrarla, Rudy. Pero contigo puedo intentarlo.",2,2,"worried"),
  a("subtle_flirt","Me enamora conocerte mejor, incluso las páginas que quisieras esconder.","Hay páginas bastante torpes. Supongo que puedes quedarte a leerlas.",2,1),
  a("remember","En esa página guardaste una flor seca. Dijiste que te recordaba un camino seguro.","No creía que lo recordaras. Todavía busco esa sensación al volver a casa.",2,2)})
 add("R14","Hablar de sentimientos","Roxy deja los apuntes cerrados. Hoy ha reservado la mesa para una conversación distinta.","¿Puedes hablar conmigo sin convertirlo todo en una lección?","Intimidad y límites.","Recuerdo afectivo; una respuesta evasiva deja un conflicto.",{familyProgress={roxy_feelings=1}},{
  a("listen","No voy a buscar una solución rápida. Quiero escucharte como tu esposo.","Necesitaba ese espacio. A veces temo que sólo veas a tu maestra.",2,2,"worried"),
  a("subtle_flirt","Hoy no quiero una lección. Quiero tomar tu mano y quedarme contigo.","Eso... sí puedo aceptarlo. Acerca la silla, Rudy.",2,1),
  a("be_honest","Me refugio en las preguntas cuando estoy nervioso. Tú me importas más que acertar.","Entonces podemos estar nerviosos los dos y hablar igualmente.",1,2),
  a("angry_reply","No puedo adivinar lo que quieres si cada conversación se vuelve una prueba.","No es una prueba. Si me hablas así, necesito que paremos.",-2,-3,"angry",{conflict="roxy_feelings"}),
  a("sincere_apology","Te hice sentir examinada cuando buscabas cariño. Lo siento; voy a escucharte.","Acepto que lo reconozcas. Quiero ver esa escucha ahora.",1,2,"worried",{reconcile="roxy_feelings"})}, {minTrust=20})
 add("R15","Leer juntos","Una historia de viajes queda abierta entre los dos. Roxy señala un párrafo y sonríe.","¿Leemos otra página o comentamos lo que hizo la protagonista?","Calma compartida.","Un libro común y recuerdo de lectura.",{items={study_book=1},familyProgress={shared_reading=1}},{
  a("listen","Quiero oír por qué te hizo sonreír ese párrafo.","Porque por fin pide ayuda antes de perderse. Me resulta familiar.",1,2),
  a("be_honest","No esperaba que una escena tan pequeña me importara tanto. Sigamos juntos.","A mí me ocurre con los regresos a casa. Lee conmigo esa parte.",2,1),
  a("light_joke","Sugiero que el mapa del protagonista incluya una flecha hacia el sentido común.","Quizá en el siguiente capítulo. Por ahora sólo lleva una brújula rota.",2,1)})
end
