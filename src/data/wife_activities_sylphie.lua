return function(b)
 local a=b.answer
 local function add(...) b.add("sylphiette",...) end
 add("S01","Preparar comida","Sylphie ha elegido una receta sencilla y te deja sitio junto a la tabla.","¿Cortas tú las verduras mientras yo pruebo el caldo?","Cooperación cotidiana.","8 oro de ahorro familiar y progreso del hogar.",{gold=8,familyProgress={household=1}},{
  a("listen","Dime cómo las prefieres. Quiero que podamos terminar al mismo tiempo.","Pequeñas, por favor. Y avísame si necesitas que deje algo preparado.",1,2),
  a("be_honest","Cocino más despacio que tú, pero puedo encargarme de esto hasta el final.","No necesito que corras, Rudy. Me ayuda saber que puedo contar contigo.",1,2),
  a("light_joke","Mi corte de zanahoria no ha alcanzado todavía el rango de santo.","Mientras no desafíes a la olla a un duelo, estaremos bien.",2,1)})
 add("S02","Limpiar la casa","Sylphie abre las ventanas y señala el estante que siempre queda para después.","Hoy quiero terminar temprano. ¿Cómo nos repartimos el trabajo?","Cansancio y reparto justo.","12 oro recuperados al ordenar y una copia de Escuchar.",{gold=12,copies={listen=1},familyProgress={household=1}},{
  a("be_honest","Ese estante lo he ido posponiendo yo. Me encargo de él y del suelo.","Gracias. Así podré sentarme un rato sin estar repasando lo pendiente.",1,2),
  a("encourage","Elijamos una parte cada uno y terminemos juntos. Tú también mereces descansar.","Me gusta más eso que oír que puedo con todo.",2,1),
  a("light_joke","He encontrado polvo suficientemente antiguo para pedir permiso a la biblioteca.","Pues devuélvelo con un paño, bibliotecario. Yo te abro la ventana.",2,1),
  a("admit_error","Dejé mis cosas encima y te obligué a moverlas. Voy a ordenarlas yo.","Eso era lo que necesitaba, Rudy: que lo vieras y lo hicieras.",1,2)})
 add("S03","Realizar mandados para Lucy","Sylphie revisa las cintas y el abrigo de Lucy antes de salir.","No quiero decidirlo todo sola. ¿Qué falta para que esté cómoda?","Atención familiar.","10 oro de recados, detalle para Lucy y cumplimiento del compromiso familiar.",{gold=10,familyProgress={family_errands=1}},{
  a("listen","Enséñame qué le molesta del abrigo. Revisaré la cinta antes de salir.","Le roza aquí. Gracias por fijarte en algo tan pequeño.",1,2),
  a("be_honest","Olvidé apuntar la talla. Voy a comprobarla antes de hacerte repetir el viaje.","Entonces sí podemos salir tranquilos. Llevaré la lista contigo.",1,2),
  a("encourage","Hoy me encargo de recoger lo acordado. Tú elige cuándo quieres descansar.","Quiero acompañarte, Rudy. Lo que necesitaba era compartir la responsabilidad.",2,1),
  a("remember","La cinta azul le molestaba al girarse. Busquemos una más suave.","Lo recuerdas. Lucy estará mucho más cómoda con esa.",2,2)})
 add("S04","Cuidar a Zenith","Sylphie prepara una silla junto a la luz. Zenith sigue con la mirada el movimiento de Lucy.","¿La acompañas mientras preparo una manta?","Cuidado respetuoso.","Confianza, memoria familiar y una copia de Escuchar.",{copies={listen=1},familyProgress={zenith_care=1}},{
  a("listen","Me sentaré a su lado. Esperaré su reacción antes de mover la silla.","Sí. Quiero que siga sintiendo que éste es su espacio.",1,2),
  a("be_honest","A veces no sé si la estoy entendiendo. No quiero dejar de intentarlo.","Puedes quedarte sin tener una respuesta, Rudy. Eso también cuenta.",2,2,"worried"),
  a("encourage","Puedes preparar la manta sin prisa. Mamá estará acompañada.","Gracias. Luego podemos quedarnos los tres un rato.",1,2)})
 add("S05","Ayudar a Lilia","Lilia termina una lista mientras Sylphie separa los utensilios que necesitan arreglo.","¿Asumimos el trabajo completo o sólo lo que se ve?","Reconocer el trabajo ajeno.","14 oro y una copia de Hablar con honestidad.",{gold=14,copies={be_honest=1},familyProgress={lilia_help=1}},{
  a("be_honest","Si dejamos la limpieza final a Lilia, no habremos terminado. La haré yo.","Bien. Yo comprobaré los cierres antes de guardarlos.",1,2),
  a("listen","Preguntemos a Lilia qué le quita más tiempo cada mañana.","Eso nos ayudará más que decidir por ella. Vamos juntos.",1,2),
  a("light_joke","Acepto el rango de aprendiz de cajones que por fin cierran.","Lilia será una examinadora exigente. Yo revisaré tu primera obra.",2,1)})
 add("S06","Colaborar con Aisha","Aisha ha preparado una lista sorprendentemente precisa. Sylphie detecta demasiadas tareas para una sola mañana.","¿Le seguimos el ritmo o hablamos del reparto?","Iniciativa y límites.","11 oro y progreso de organización.",{gold=11,familyProgress={organization=1}},{
  a("listen","Quiero entender qué tareas le preocupan antes de aceptar toda la lista.","Le preguntaremos. Tener iniciativa no significa tener que hacerlo todo.",1,2),
  a("be_honest","No terminaré estas cinco bien. Puedo asumir dos y dejar un relevo claro.","Me parece más responsable. Yo hablaré con ella sobre las otras tres.",1,2),
  a("encourage","Su plan es bueno; hagamos que incluya también descanso para ella.","Exacto, Rudy. Una casa no funciona mejor porque nadie pare.",2,1),
  a("propose_plan","Marquemos dos prioridades, repartamos responsables y revisemos al mediodía.","Y dejemos hueco para lo inesperado. Voy a buscar a Aisha.",1,2)})
 add("S07","Cuidar el jardín","Sylphie observa un tallo doblado y aparta las herramientas grandes.","¿Lo enderezamos ahora o le damos apoyo sin forzarlo?","Paciencia compartida.","Una flor, un material mágico vegetal y progreso del jardín.",{items={flower=1,magic_material=1},familyProgress={garden=1}},{
  a("listen","Enséñame dónde atar el soporte sin apretar el tallo.","Aquí, dejando holgura. A veces ayudar significa dar espacio.",1,2),
  a("be_honest","Lo habría enderezado demasiado deprisa. Prefiero hacerlo contigo.","Me alegra que hayas parado a mirar, Rudy.",1,2),
  a("subtle_flirt","Quiero que este rincón tenga sitio para sentarnos juntos cuando florezca.","Entonces deja ese banco libre de macetas. Yo elegiré las flores.",2,1)})
 add("S08","Organizar habitaciones","Una caja de recuerdos impide cerrar el armario. Sylphie sostiene una prenda antigua.","No quiero que ordenemos tirando lo que importa. ¿Por dónde empezamos?","Memoria y consentimiento.","9 oro recuperados y progreso familiar.",{gold=9,familyProgress={household=1}},{
  a("listen","Cuéntame qué quieres conservar. Yo separaré mis cosas después.","Esta prenda era de Lucy. Quisiera guardarla aunque ya no le sirva.",2,2),
  a("be_honest","He ocupado el estante común con cosas mías. Voy a hacer espacio primero.","Gracias. Me costaba pedirte sitio en nuestra propia habitación.",1,2),
  a("light_joke","Propongo retirar mis mapas antes de que soliciten un dormitorio propio.","Aceptado. Y no les cedas el cajón de las mantas.",2,1),
  a("remember","Esa prenda fue la primera que doblamos para Lucy. Conservemos la caja pequeña.","Sí. Me alegra no ser la única que recuerda aquella tarde.",2,2)})
 add("S09","Comprar provisiones","Sylphie compara una lista de alimentos con el dinero reservado para la casa.","Tenemos doce monedas para esta compra. ¿Qué ponemos primero?","Economía y prioridades.","Coste confirmado: 12 oro. Provisiones familiares y una copia de Dar ánimo.",{copies={encourage=1},familyProgress={provisions=1}},{
  a("listen","Revisemos qué necesita la familia antes de añadir mis antojos.","Primero lo de la lista. Si sobra, elegimos algo entre los dos.",1,2),
  a("be_honest","Quería comprar algo para mí. Puede esperar hasta cubrir las provisiones.","Gracias por decirlo sin convertirlo en un sacrificio que debamos agradecer.",1,2),
  a("light_joke","La lista no reconoce mi propuesta de vivir sólo de postres.","La cocinera tampoco. Pero podemos compartir uno al volver.",2,1),
  a("bold_reply","Compremos los postres primero; seguro que resolvemos lo demás después.","No, Rudy. La comida de la casa no puede depender de que sobre dinero.",-1,-2,"angry",{conflict="family_budget"})}, {goldCost=12})
 add("S10","Preparar una reunión familiar","Sylphie deja varias sillas vacías alrededor de la mesa. Quiere que todos puedan sentarse.","¿Qué parte puedes prometer y cumplir tú?","Compromiso verificable.","Una copia de Dar ánimo y una promesa familiar para el siguiente día.",{copies={encourage=1},familyProgress={family_meeting=1}},{
  a("be_honest","Puedo encargarme del recado pendiente. Lo anotaré para cumplirlo mañana.","Entonces yo preparo la mesa. Confío en que esa nota se convierta en hechos.",1,2,"happy",{promise={id="family_errand",status="pending"}}),
  a("listen","Dime qué parte te ha dejado sin tiempo en otras reuniones.","Esperar los encargos. Si te ocupas de uno, podremos empezar juntos.",1,2,"happy",{promise={id="family_errand",status="pending"}}),
  a("encourage","Quiero que también tengas una silla libre de responsabilidades. Haré el recado.","Me gustaría sentarme contigo desde el principio, Rudy.",2,1,"happy",{promise={id="family_errand",status="pending"}})})
 add("S11","Pasear por el jardín","Sylphie ha salido sin una cesta ni una lista. Te hace sitio en el sendero.","Hoy sólo quiero caminar. ¿Podemos dejar las tareas un momento?","Romance y autonomía.","Una flor y recuerdo de una cita elegida por Sylphie.",{items={flower=1},familyProgress={sylphie_date=1}},{
  a("listen","Sí. Tú elige el camino; hoy no vamos a convertirlo en un recado.","Entonces vamos por el lado del sol. Tenía ganas de enseñártelo.",2,2),
  a("subtle_flirt","Me gusta este plan, Sylphie. ¿Puedo tomar tu mano?","Puedes. Y puedes dejar de mirar la puerta cada pocos pasos.",2,1),
  a("light_joke","He comprobado la lista: caminar contigo es la única tarea pendiente.","Por esta vez apruebo esa lista. Ahora guárdala.",2,1)})
 add("S12","Hablar de responsabilidades","Sylphie pone el horario familiar entre los dos y mantiene la mano sobre una casilla vacía.","No quiero tener que pedir cada ayuda. ¿Cómo lo cambiamos?","Desacuerdo legítimo.","Acuerdo doméstico; posibilidad de reparar abandono y registrar una decisión.",{familyProgress={responsibility=1}},{
  a("listen","Quiero entender qué estás teniendo que recordarme cada día.","Las tareas pequeñas y el tiempo juntas. No debería gestionar también tu atención.",1,2,"worried",{reconcile="daily_neglect"}),
  a("be_honest","He esperado a que me lo pidieras. Voy a asumir un turno y anotarlo yo.","Eso es un comienzo concreto, Rudy. Hablaremos de cómo ha funcionado.",1,2,"worried",{decision="household_turn",value="shared",reconcile="daily_neglect"}),
  a("light_joke","Quizá el horario pueda perseguirme por la casa hasta que obedezca.","No quiero perseguirte yo ni poner a nadie a hacerlo. Te estoy hablando en serio.",-2,-2,"angry",{conflict="household_turn"}),
  a("shared_magic","Como en nuestra cobertura, acordemos turnos que ambos conozcamos y podamos revisar.","Sí, pero los revisamos entre los dos. No quiero dirigir también todos los relevos.",2,2) })
 add("S13","Preparar una sorpresa","Sylphie propone una merienda pequeña para celebrar algo bueno sin cargar a nadie de trabajo.","Quiero sorprenderlas, no agotarnos. ¿Qué detalle elegimos?","Alegría con límites.","Coste: 6 oro. Recuerdo de una sorpresa y progreso familiar.",{familyProgress={family_surprise=1}},{
  a("listen","¿Qué detalle crees que disfrutarían Roxy y Eris? Yo preparo las tazas.","Un sitio tranquilo para Roxy y algo sustancioso para Eris. No hace falta más.",1,2),
  a("encourage","Tu idea basta sin hacer una fiesta enorme. Yo recogeré cuando terminemos.","Gracias. Así la sorpresa también será agradable para mí.",2,1),
  a("light_joke","Nada de esconder a Eris detrás de una puerta con una espada, entonces.","Definitivamente no. Prefiero que la vajilla sobreviva a la sorpresa.",2,1),
  a("happy_reply","Me alegra que lo hayas propuesto tú. Quiero ayudarte a disfrutarlo.","Entonces empecemos por algo sencillo, Rudy. Eso sí me ilusiona.",2,2)}, {goldCost=6})
 add("S14","Practicar cartas de carisma","Sylphie lee una frase de la carta parlante y te pide que la pruebes con intención.","¿Quieres sonar convincente o decir algo que puedas sostener?","Sinceridad frente a actuación.","Una copia de Hablar con honestidad y progreso social.",{copies={be_honest=1},familyProgress={social_practice=1}},{
  a("be_honest","Quiero que la carta diga lo que pienso, incluso si la frase queda menos elegante.","Eso me importa más que una voz perfecta, Rudy.",1,2),
  a("listen","Léeme dónde suena ensayada. Quiero escuchar qué efecto tiene en ti.","Aquí prometes demasiado. Prueba una cosa que puedas cumplir hoy.",1,2),
  a("light_joke","Mi carisma ha pedido dejar de ensayar frente a la escoba.","La escoba es muy paciente, pero yo puedo contestarte.",2,1),
  a("self_joke","He practicado tanto la sonrisa que olvidé escuchar la pregunta.","Entonces vamos bien: ya sabes por dónde empezar a mejorar.",2,1)})
 add("S15","Recordar promesas familiares","Sylphie abre la página de los compromisos. No todos tienen la misma marca.","¿Qué hacemos con lo que dejamos pendiente?","Reconciliación o conflicto según los hechos.","Revisión persistente de promesas; los recados pendientes todavía deben cumplirse.",{familyProgress={reconciliation=1}},{
  a("listen","Leamos lo que falta antes de hacer otra promesa. Quiero oír cómo te afectó.","Puedo hablarlo, Rudy. Lo que no quiero es que otra frase sustituya el recado.",1,2,"worried"),
  a("be_honest","No voy a dar por cumplido algo sólo por recordarlo. Revisemos los hechos.","Gracias. Podemos seguir desde ahí, aunque la página no sea perfecta.",1,2,"worried"),
  a("light_joke","Podríamos escribir las promesas con letra más pequeña para que pesaran menos.","No pesan por el tamaño, Rudy. No bromees con lo que seguimos esperando.",-2,-3,"angry",{conflict="family_errand"}),
  a("sincere_apology","Dejé una responsabilidad pendiente. Lo siento; no te pediré que la borres.","Puedo aceptar la disculpa y seguir esperando que lo cumplas. Las dos cosas.",1,2,"worried",{reconcile="family_errand"}),
  a("choose_together","Decidamos qué podemos sostener los dos, sin borrar las promesas que ya hicimos.","Sí. Quiero elegir contigo, no tener que adivinar en qué puedo confiar.",2,2)}, {continuation="La libreta muestra si el recado está pendiente, cumplido o incumplido; S03 permite cumplirlo."})
end
