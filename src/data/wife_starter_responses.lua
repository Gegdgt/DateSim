-- Respuestas escritas para las cinco intenciones iniciales en cada actividad.
-- Se agregan a las respuestas avanzadas existentes, sin reemplazarlas.
return function(bank)
 local a=bank.answer
 local extra={
  E02={
   a("listen","Dime las reglas del duelo. Quiero que juzgues mi esfuerzo, no una cortesía.","Sin golpes a la cabeza. Y si tienes una abertura, aprovéchala.",1,2),
   a("subtle_flirt","Me gusta esa mirada de desafío. Voy a intentar estar a su altura.","Pues deja de mirarme y ponte en guardia. Veremos cuánto te dura.",2,1)},
  E03={
   a("encourage","Tú reconoces esas huellas mejor que yo. Marcaré el camino mientras las sigues.","Bien. Quiero poder volver sin tener que pelear también con el bosque.",1,2),
   a("subtle_flirt","Si volvemos antes de la lluvia, me gustaría pasear contigo sin perseguir nada.","Primero salgamos de aquí enteros. Después podemos caminar más despacio.",1,1)},
  E04={
   a("light_joke","Si esa estatua empieza a cobrar entrada, me encargo yo de negociar.","Tú mira el suelo. No pienso sacarte de otro agujero por mirar una estatua.",0,1,"neutral"),
   a("subtle_flirt","Prefiero regresar contigo que llevarme una reliquia que no pueda enseñarte.","Entonces no te separes de mí por una piedra brillante.",2,1)},
  E05={
   a("light_joke","Mis botas han entendido la esquiva antes que yo; quieren salir corriendo.","¡Que se queden! Repite el paso hasta que puedas hacerlo sin huir.",1,1),
   a("encourage","Tu cambio de hombro casi no se ve. Quiero aprender a reconocerlo contigo.","Ahí tienes algo que practicar. Voy a hacerlo despacio una vez.",1,2)},
  E06={
   a("encourage","Mantén esa presión. Si puedo seguir viéndote, sabré que la guardia sirve.","¡Eso es! No conviertas el escudo en una pared que te encierre.",2,2),
   a("subtle_flirt","Quiero poder cubrirte cuando haga falta, aunque hoy seas tú quien me ponga a prueba.","Puedes empezar por sostener ese escudo. Luego practicamos juntos.",1,1)},
  E07={
   a("light_joke","Dos golpes para entrar, uno para salir. Prometo no convertirlo en una canción.","Más te vale. Necesito una señal que pueda oír en medio de la pelea.",1,1),
   a("subtle_flirt","Me gusta cuando encontramos el mismo paso. Quiero lograrlo también peleando.","Entonces cubre mi salida. No me sirve que entres conmigo y te olvides del resto.",2,1)},
  E08={
   a("encourage","Tu plan deja espacio para retirarnos. Revisaré vendas y provisiones antes de salir.","Bien. La recompensa no sirve si volvemos destrozados.",1,2),
   a("subtle_flirt","Reservaría una parte de la recompensa para cenar contigo al volver.","Podemos pensarlo después. Ahora dime si llevas todo el equipo.",0,0,"neutral")},
  E09={
   a("listen","Cuéntame dónde los viste y quién necesita ayuda primero.","Junto al carro. Hay una persona herida; no debemos dejarla allí.",1,2),
   a("subtle_flirt","Podríamos dejar el carro un momento y buscar un sitio a solas.","¿Ahora? Esa gente necesita ayuda. No vuelvas a proponérmelo.",-2,-2,"angry")},
  E10={
   a("listen","Explícame las marcas antes de empezar. Quiero sostener el ritmo hasta el final.","Son tres. Respira al pasar la primera y no esprintes todavía.",1,2),
   a("subtle_flirt","Si consigo seguir tu paso, ¿nos sentamos juntos a recuperar el aliento?","Si terminas la vuelta. No pienso llevarte a cuestas hasta el banco.",2,1)},
  E11={
   a("encourage","En aquel camino aprendí a seguir adelante porque podía contar contigo.","También te vi levantarte cuando estabas agotado. No lo hice todo yo.",2,2),
   a("subtle_flirt","Volvería a la posada de las goteras si pudiera quedarme otra vez junto a ti.","Esta vez pediríamos una habitación seca. Pero sí, me sentaría contigo.",2,1)},
  E12={
   a("encourage","No tienes que poner buena cara mientras hablas. Puedo quedarme aunque te cueste.","Entonces quédate. Todavía no sé cómo ordenar lo que quiero decir.",1,2,"worried"),
   a("subtle_flirt","Esa cara preocupada se te quitaría si me dieras un beso.","Te estoy hablando en serio. No quiero que cambies de tema.",-1,-2,"angry")},
  E13={
   a("listen","Repíteme qué le toca a cada uno. Quiero cumplir la apuesta aunque pierda.","El ganador carga la cesta. El perdedor elige dónde nos sentamos.",1,2),
   a("encourage","Quiero una competencia de verdad. Da lo mejor de ti; yo haré lo mismo.","¡Así sí! Nada de dejarte ganar para quedar bien.",2,2)},
  E14={
   a("light_joke","Podríamos pedirle al enemigo que espere mientras borramos el dibujo.","O podríamos tener preparada la retirada. Elige la segunda opción.",-1,-1,"angry"),
   a("subtle_flirt","Lo que más quiero del plan es volver a casa contigo después.","Entonces señala dónde vas a cubrirme si fallo. Eso sí me ayuda.",1,1)},
  E15={
   a("listen","Dime dónde viste el hueco en mi guardia. Quiero demostrar que lo he trabajado.","En el costado al retroceder. Voy a buscarlo otra vez; tendrás que cerrarlo.",1,2),
   a("subtle_flirt","He pensado tanto en nuestra revancha como en verte sonreír después.","Tendrás que ganarte las dos cosas. En guardia, Rudeus.",2,1)},
  R01={
   a("encourage","Tu registro permite cambiar una sola variable. Prepararé otra jarra igual.","Gracias. Así sabremos si la diferencia viene de la fórmula.",1,2),
   a("subtle_flirt","Podría quedarme toda la tarde viéndote explicar esa corriente.","Y yo agradecería que también miraras la marca de presión, Rudy.",1,1)},
  R02={
   a("light_joke","La tierra parece llevar más tiempo pensando la respuesta que yo.","Por eso medimos la humedad. No vamos a pedirle una explicación verbal.",1,1),
   a("subtle_flirt","Me gusta estudiar a tu lado, incluso cuando terminamos cubiertos de polvo.","El polvo puede esperar a que guardemos las muestras. Acércame ese frasco.",2,1)},
  R03={
   a("light_joke","¿Venden un grimorio que recuerde por mí dónde dejé los demás?","Empieza por uno que vayas a leer. Para los otros podemos hacer una lista.",1,1),
   a("encourage","Tus recomendaciones me han servido. Revisemos el índice y el precio juntos.","Éste empieza con ejercicios sencillos. Veamos si encaja con lo que buscas.",1,2)},
  R04={
   a("encourage","Has preparado bien el catalizador. Revisemos las copias antes de activar nada.","Eso evita gastar materiales por una decisión apresurada.",1,2),
   a("subtle_flirt","Me gustaría mejorar una carta que me ayude a decirte lo que siento.","Entonces piensa cuál usarías de verdad. El catalizador no elige por ti.",2,1)},
  R05={
   a("light_joke","Si el residuo se pone tímido, prometo dejar de mirarlo tan fijamente.","El residuo no tiene sentimientos. Anota cuándo cambia de color.",0,1,"neutral"),
   a("subtle_flirt","Podríamos olvidarnos de las notas y escaparnos juntos de la biblioteca.","Me pediste investigar algo serio. No quiero abandonar la muestra abierta.",-1,-1,"worried")},
  R06={
   a("encourage","Tu comparación con el otro trazo nos da una referencia. Haré una copia exacta.","Incluye el borde roto. También puede decirnos cuándo se hizo la marca.",1,2),
   a("subtle_flirt","Reconocería tu letra entre todos estos apuntes. Me alegra compartirlos contigo.","Pues ayúdame a distinguirla de la runa original antes de copiarla.",1,1)},
  R07={
   a("listen","Dime qué medidas registrarás si falla. Quiero que podamos aprender del resultado.","Tiempo, presión y color. Una prueba fallida también tiene que poder repetirse.",1,2),
   a("subtle_flirt","Si no sale como esperamos, me quedaré contigo a recoger el laboratorio.","Puedes quedarte también si sale bien. Los frascos habrá que lavarlos igual.",2,1)},
  R08={
   a("light_joke","Le pediré al cristal que hable más bajo; quizá nos estamos entendiendo a gritos.","Reduce el canal poco a poco. La comparación sirve, pero hay que hacerlo.",1,1),
   a("subtle_flirt","Me tranquiliza tenerte al lado mientras ajusto el circuito.","Seguiré aquí. Ahora mira la luz del cristal y avísame si cambia.",2,1)},
  R09={
   a("light_joke","Por ese precio espero que el libro aprenda a volver solo a su estante.","Yo prefiero que tenga todas sus páginas. Revisemos la encuadernación.",1,1),
   a("encourage","Has encontrado una referencia difícil. Comparemos el contenido antes de pagar.","Traeré el catálogo. Puede haber otra edición que nos sirva igual.",1,2)},
  R10={
   a("light_joke","La carta de Orsted parece tener más disciplina que nosotros dos juntos.","Su límite es muy preciso. Sería mejor entenderlo que ponerlo a prueba a ciegas.",0,1,"neutral"),
   a("subtle_flirt","Prefiero descubrir ese límite contigo que presumir de una carta que no entiendo.","Entonces empecemos por el sello. No voy a dejar que te hagas daño por curiosidad.",1,2)},
  R11={
   a("encourage","Tu ejemplo con la jarra se entiende. Podemos empezar la clase por ahí.","Sí, y después pedirles que predigan qué pasará al inclinarla.",1,2),
   a("subtle_flirt","Me temo que yo seguiría buscando excusas para quedarme después de tu clase.","Entonces te pondría a ordenar los materiales. Hoy también puedes ayudarme.",2,1)},
  R12={
   a("light_joke","Si los dos flujos se saludan tan mal como yo al despertar, conviene ensayar primero.","Sin activar el puente. Quiero que reconozcamos la señal antes de conectarlos.",1,1),
   a("subtle_flirt","Me gusta que tengamos que escucharnos para hacer esto juntos.","Escucharnos incluye parar cuando cualquiera lo pida. Recordemos la señal.",2,2)},
  R13={
   a("light_joke","Recuerdo tus mapas. Los míos parecían dibujados por un caballo durante el viaje.","Los míos también tenían manchas. Sólo procuraba que pudieras leer el destino.",1,1),
   a("encourage","Aquellas dudas no borran lo que enseñaste. Seguiste buscando cómo ayudarme.","Me alegra que recuerdes eso. Yo también estaba aprendiendo entonces.",2,2)},
  R14={
   a("light_joke","Iba a pedir un examen para saber si lo digo bien, pero sería esconderme otra vez.","Prefiero que no prepares una respuesta perfecta. Habla conmigo.",1,1),
   a("encourage","Puedes decirme lo que necesitas aunque te cueste. Hoy quiero atenderte como tu esposo.","Necesito que haya sitio para estas conversaciones sin abrir antes un libro.",2,2)},
  R15={
   a("encourage","La protagonista eligió algo difícil. Quiero saber qué viste tú en esa decisión.","Que dejó de esperar una certeza que nadie podía darle. Volvamos a ese párrafo.",1,2),
   a("subtle_flirt","Leería otra página si puedo quedarme así de cerca de ti.","Puedes quedarte. Pero no pases la hoja antes de que yo termine.",2,1)},
  S01={
   a("encourage","El caldo huele bien. Yo terminaré las verduras y limpiaré la tabla.","Gracias. Así podremos sentarnos a comer los dos al mismo tiempo.",1,2),
   a("subtle_flirt","Después de cocinar, me gustaría sentarme junto a ti en la mesa.","Guárdame el sitio cuando acabes de cortar. Primero terminemos la comida.",2,1)},
  S02={
   a("listen","Dime qué falta y qué parte prefieres hacer. Yo me quedaré con la otra.","Quiero ordenar los armarios. Puedes encargarte del suelo y de guardar los cubos.",1,2),
   a("subtle_flirt","¿Te gustaría descansar conmigo cuando dejemos la casa lista?","Sí, si los dos terminamos antes. No quiero verte sentado mientras sigo limpiando.",2,1)},
  S03={
   a("light_joke","Lucy sabe elegir un abrigo mejor que yo; al menos ella comprueba si puede moverse.","Entonces sigamos su criterio: que pueda jugar y que no le roce el cuello.",1,1),
   a("subtle_flirt","Me gusta salir contigo a cuidar estas cosas de nuestra hija.","A mí me gusta compartirlas. Ayúdame a revisar la talla antes de irnos.",2,2)},
  S04={
   a("light_joke","Le contaré a mamá que Lucy ya organiza la casa mejor que nosotros.","Se le ilumina la cara cuando oye hablar de ella. Cuéntaselo despacio.",1,1),
   a("subtle_flirt","Cuando traigas la manta, me gustaría que te sentaras aquí conmigo y con mamá.","Lo haré. Hay sitio para los dos a su lado.",2,1)},
  S05={
   a("encourage","Tienes razón en contar lo que nadie ve. Me quedaré hasta guardar el último utensilio.","Eso le dará a Lilia un descanso de verdad. Empecemos por los que están rotos.",1,2),
   a("subtle_flirt","Podríamos dejarle lo que falta a Lilia y salir tú y yo antes.","Precisamente venimos a ayudarla. No quiero que nuestra salida sea a costa suya.",-1,-2,"worried")},
  S06={
   a("light_joke","Si esa lista sigue creciendo, habrá que darle su propia habitación.","O quitarle trabajo a Aisha. Prefiero que revisemos qué puede asumir cada uno.",0,1,"neutral"),
   a("subtle_flirt","Quiero que al repartir las tareas también quede tiempo para estar contigo.","Yo también. Hagamos un reparto justo para que nadie pague por ese rato libre.",2,2)},
  S07={
   a("light_joke","Le pondré un tutor al tallo; prometo que no le mandará deberes.","Con que lo sostenga sin apretarlo bastará. Acércame esa cinta.",1,1),
   a("encourage","Has visto a tiempo dónde se dobla. Lo sujetaré mientras colocas el apoyo.","Despacio, así. Dejaremos que encuentre su posición sin forzarlo.",1,2)},
  S08={
   a("encourage","Podemos hacer sitio sin perder esos recuerdos. Prepararé una caja para revisarlos juntos.","Dejemos esa caja a mano. No quiero que lo importante desaparezca en el fondo.",1,2),
   a("subtle_flirt","Esa nota tuya merece un lugar donde pueda volver a leerla.","Entonces guárdala bien. Yo también he conservado cosas pequeñas de nosotros.",2,1)},
  S09={
   a("encourage","Tu lista cubre lo necesario. Revisaré las cantidades para que alcance el dinero.","Empecemos por la comida. Si sobra algo, decidimos los dos qué añadir.",1,2),
   a("subtle_flirt","Gastaría las doce monedas en un regalo para ti y resolvería la comida después.","No quiero un regalo que deje a la familia sin provisiones. Miremos la lista.",-1,-2,"worried")},
  S10={
   a("light_joke","Podría prometer que las sillas llegarán solas, pero será mejor que las lleve yo.","Eso último sí sirve. Déjalas listas antes de que llegue la familia.",1,1),
   a("subtle_flirt","Quiero reservarte un asiento junto al mío cuando acabemos de prepararlo todo.","Me gustaría sentarme contigo, sin tener que levantarme a terminar sola lo pendiente.",2,1)},
  S11={
   a("be_honest","Me cuesta dejar las tareas en casa. Pero hoy quiero dar este paseo contigo sin mirar la hora.","No hace falta que lo hagas perfecto. Podemos empezar por caminar despacio.",2,2),
   a("encourage","Has hecho bien en pedir este rato para ti. La casa puede esperar mientras paseamos.","También quiero que sea un rato para nosotros. Sigamos por donde da el sol.",1,2)},
  S12={
   a("encourage","Tu cansancio tiene sentido. Quiero ocuparme de mi parte antes de que tengas que recordármela.","Entonces escribe qué vas a hacer y cuándo. Necesito poder contar con ello.",1,2,"worried"),
   a("subtle_flirt","¿Y si dejamos el horario y te doy un beso para que no sigas preocupada?","No te estoy pidiendo que me distraigas. Te estoy pidiendo que compartas el trabajo.",-2,-2,"worried")},
  S13={
   a("be_honest","Me entusiasmé con algo demasiado grande. Prefiero preparar una merienda que podamos disfrutar todos.","Me parece bien. Elijamos algo sencillo y terminemos a tiempo.",1,2),
   a("subtle_flirt","Quiero incluir un detalle para ti, aunque estés ayudándome con la sorpresa.","Entonces guarda un poco de esa merienda para que podamos compartirla después.",2,1)},
  S14={
   a("encourage","Tienes razón en mirar más allá de cómo suena. Practicaré una frase que pueda cumplir.","Puedes empezar por algo pequeño y concreto. La voz no tiene que hacerlo todo.",1,2),
   a("subtle_flirt","Quiero usar estas cartas para invitarte a estar conmigo, y luego hacer sitio para ese tiempo.","Esa segunda parte me importa. Dime cuándo podemos reservarlo los dos.",2,2)},
  S15={
   a("encourage","La libreta nos ayuda a no escondernos de lo pendiente. Revisemos qué puedo cumplir ahora.","Empecemos por un compromiso concreto. No hace falta añadir otra promesa hoy.",1,2,"worried"),
   a("subtle_flirt","Quizá un abrazo consiga que olvides por un rato lo que prometí.","No quiero olvidarlo, Rudy. Quiero que lo cumplas.",-2,-2,"worried")},
 }
 for id,responses in pairs(extra) do
  local def=assert(bank.byId[id])
  for _,response in ipairs(responses) do
   assert(not def.responses[response.id],"Respuesta inicial duplicada: "..id.."/"..response.id)
   def.responses[response.id]=response;def.choices[#def.choices+1]=response
  end
 end
 for _,def in ipairs(bank.list) do
  for _,id in ipairs(require("src.data.cards").starterDeck) do
   local response=def.responses[id]
   assert(response and response.rudy and response.reply,"Falta respuesta inicial: "..def.id.."/"..id)
  end
 end
end
