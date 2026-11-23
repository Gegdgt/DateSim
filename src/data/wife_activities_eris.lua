return function(b)
 local a=b.answer
 local function add(...) b.add("eris",...) end
 add("E01","Entrenar técnicas básicas","Eris dibuja tres posiciones en la arena y te entrega un bastón.","¿Repetimos los pasos o ya crees que te los sabes?","Exigencia y complicidad.","Combate: hasta 18 oro, Bastón y entrenamiento diario.",{gold=18,copies={staff_strike=1},familyProgress={training=1}},{
  a("listen","Enséñame dónde pierdo el equilibrio al retroceder.","En el talón izquierdo, Rudeus. Mírame y vuelve a intentarlo.",1,2),
  a("be_honest","Me cuesta bajar la guardia sin dejar un hueco. Quiero practicarlo.","Eso puedo corregirlo. No necesitas fingir que ya lo dominas.",1,2),
  a("light_joke","Mi técnica más constante sigue siendo recoger el bastón del suelo.","¡Entonces hoy practicaremos cómo conservarlo! Ponte en posición.",2,1),
  a("bold_reply","Hagamos una serie sin descansos; tú marcas cuándo debo parar.","Acepto. Y cuando diga basta, basta. Entrenar también es escuchar.",1,2)}, {battle="practice",stable=true})
 add("E02","Duelo entre Rudy y Eris","Eris comprueba el filo de práctica. Esta vez anotará tus decisiones reales.","No quiero que me regales la victoria. ¿Entendido?","Respeto competitivo.","Duelo real: resultado de esfuerzo, hasta 26 oro y Corte simple.",{gold=26,copies={simple_cut=1},familyProgress={training=1}},{
  a("be_honest","Voy a intentar ganarte. Si pierdo, quiero saber por qué.","Así me gusta. Ven con todo lo que puedas sostener.",1,2),
  a("encourage","Tu guardia me obliga a pensar. No voy a desperdiciar esta oportunidad.","Deja que tus movimientos lo demuestren, Rudeus.",1,1),
  a("light_joke","Si sobrevivo a la primera ronda, exigiré una revancha ceremonial.","¡Primero exige algo a tus piernas! La revancha tendrás que ganártela.",2,1)}, {battle="duel"})
 add("E03","Explorar el bosque","Una rama partida marca la entrada del sendero. Eris escucha antes de avanzar.","¿Seguimos las huellas o revisamos primero la salida?","Curiosidad con cautela.","Encuentro: 12 oro y material mágico si vencéis.",{gold=12,items={magic_material=1},familyProgress={monster_hunts=1}},{
  a("listen","¿Qué te dice ese silencio entre los árboles? Espero tu señal.","Que no estamos solos. Mantente a mi derecha.",1,2),
  a("be_honest","No conozco bien este sendero. Marcaré el camino de regreso.","Bien. Ser valiente no exige perderse.",1,2),
  a("light_joke","Prometo no desafiar a ningún árbol que parezca más fuerte que yo.","Ese de allí te ganaría. Anda, deja una marca en su tronco.",2,1),
  a("earth_barrier","Dejemos preparada una carta de barrera para cubrir la retirada.","Úsala cuando dé la señal. No quiero una pared entre los dos.",1,2)}, {battle="monsters",background="forest"})
 add("E04","Investigar las ruinas","Eris aparta grava de un relieve. Hay marcas recientes junto al acceso.","¿Qué merece la pena arriesgar aquí?","Inquietud y descubrimiento.","Guardián: 22 oro, fragmento de maná y registro del relieve.",{gold=22,items={mana_fragment=1},familyProgress={ruin_clues=1}},{
  a("listen","Muéstrame las marcas. Quiero distinguir una salida de una emboscada.","Estas vienen de dentro. Entramos juntos y dejamos libre la puerta.",1,2),
  a("be_honest","La inscripción me interesa, pero no vale más que volver contigo.","Entonces copia lo que puedas sin separarte.",2,1),
  a("encourage","Tu lectura del terreno nos ha traído hasta aquí. Confío en tu aviso.","Y yo necesito que vigiles detrás. Hagámoslo.",1,2),
  a("analyze_runes","Copiaré la runa desde fuera antes de tocar el mecanismo.","Eso suena mejor que pisar la losa para ver qué ocurre.",1,2)}, {battle="monsters",enemyId="ruins_guardian",background="ruins",minDay=3})
 add("E05","Practicar esquivas","Eris ata una cinta al bastón para que sigas su trayectoria.","¿Miras mi arma o mis hombros?","Paciencia corporal.","Una copia de Empujar y progreso defensivo.",{copies={push=1},familyProgress={defense=1}},{
  a("listen","Muévete despacio una vez. Quiero fijarme en cuándo cambia tu peso.","Ahí. Antes del golpe, no cuando ya lo tienes encima.",1,2),
  a("be_honest","Miro el arma y reacciono tarde. Voy a probar con tus hombros.","Ahora sí estás corrigiendo algo concreto.",1,2),
  a("subtle_flirt","Me distraen tus ojos; hoy intentaré admirarlos después de esquivar.","Más te vale. No pienso frenar cada vez que me mires.",2,0)})
 add("E06","Entrenar con escudo","Un escudo prestado pesa más de lo que parecía. Eris llama con los nudillos sobre él.","¿Puedes protegerte sin dejar de verme?","Confianza en la cobertura.","Defensa física, material mágico y progreso de protección.",{unlock={"wind_guard"},items={magic_material=1},familyProgress={shield=1}},{
  a("listen","Avísame cuando el borde te tape. Ajustaré la altura.","Un poco más abajo. Ahora podemos cubrirnos sin perdernos de vista.",1,2),
  a("be_honest","Mi brazo ya tiembla. Prefiero una serie corta bien hecha.","Descansa después de esta. Quiero una guardia firme, no una lesión.",1,2),
  a("light_joke","He descubierto una puerta que se lleva en el brazo.","Pues evita cerrármela en la cara cuando avance.",2,1),
  a("earth_barrier","Compararé la postura del escudo con la cobertura de la carta de tierra.","Primero entiende el hueco; después elige con qué cerrarlo.",1,2)})
 add("E07","Practicar ataques combinados","Eris dibuja una flecha de entrada y otra de retirada.","¿Cuándo sabré que estás listo para cubrirme?","Coordinación entre iguales.","Ataque coordinado y progreso de Espada y Magia (3 sesiones).",{copies={coordinated_attack=1},familyProgress={coordination=1}},{
  a("listen","Elige una señal que puedas dar incluso al girarte. La repetiré contigo.","Dos golpes en la empuñadura. Y no avances si no respondo.",1,2),
  a("be_honest","La energía viene de la carta. Necesito un instante para orientarla.","Te lo daré. Tú dime cuándo acaba ese instante.",1,2),
  a("encourage","Tu entrada abre el camino; mi trabajo es que puedas volver.","Eso sí es pelear conmigo, Rudeus.",2,1),
  a("sword_magic","Tu espada abre la guardia; mi carta cubre tu salida a la señal acordada.","La misma señal, incluso cuando parezca fácil. Vamos.",2,2)})
 add("E08","Cazar monstruos","El tablón ofrece una recompensa por la bestia del paso. Eris revisa la ruta.","¿Hemos preparado todo antes de cobrar?","Determinación práctica.","Cacería: 36 oro, Corte simple y material al vencer.",{gold=36,copies={simple_cut=1},items={magic_material=1},familyProgress={monster_hunts=1}},{
  a("listen","Repasemos por dónde puede embestir. Quiero conocer tu plan.","Desde el terraplén. Yo atraigo el primer ataque.",1,2),
  a("be_honest","La recompensa me viene bien, pero nos retiramos si perdemos la ruta.","Bien. Ninguna bolsa compra una segunda vida.",1,2),
  a("light_joke","Contaré las monedas después de contar que seguimos teniendo todos los dedos.","Cuenta rápido; quiero volver antes de cenar.",2,1)}, {battle="monsters",background="forest",minDay=2})
 add("E09","Proteger viajeros","Un carro roto bloquea el paso. Los viajeros no pueden pagar una escolta.","Podemos ayudarlos o perseguir la recompensa. ¿Qué decides?","Responsabilidad frente al beneficio.","Combate de escolta: material y confianza; elegir a quién proteger queda registrado.",{items={magic_material=1},familyProgress={traveler_help=1}},{
  a("encourage","Me quedo con el carro. Esa familia necesita llegar antes de que oscurezca.","Entonces yo despejo el paso. El dinero puede esperar.",2,2,"happy",{decision="travelers_choice",value="protect"}),
  a("be_honest","Quiero la recompensa, pero no a costa de dejarlos indefensos.","Me basta con que lo hayas elegido tú. Pongámonos en marcha.",1,2,"happy",{decision="travelers_choice",value="protect"}),
  a("light_joke","Quizá el monstruo acepte esperar mientras negociamos las tarifas.","No es momento de hacerlos esperar, Rudeus. Mueve el carro conmigo.",-1,-2,"angry",{decision="travelers_choice",value="hesitated",conflict="travelers_delay"}),
  a("change_subject","La recompensa debe seguir por el otro sendero. Podemos mirar primero.","Yo no dejo a esta gente aquí. Ayuda o apártate del camino.",-2,-3,"angry",{decision="travelers_choice",value="reward_first",conflict="travelers_delay"})}, {battle="monsters",background="forest"})
 add("E10","Competencia de resistencia","Eris coloca tres marcas en el circuito y acuerda un ritmo seguro.","¿Preparado para mantener el paso sin precipitarte?","Juego y concentración.","Tres pulsaciones de ritmo: hasta 12 oro y progreso de resistencia.",{gold=12,familyProgress={endurance=1}},{
  a("be_honest","Prefiero mantener un ritmo que pueda terminar. No competiré con una lesión.","Bien dicho. Ahora intenta no quedarte atrás.",1,2),
  a("encourage","Marca tú la primera vuelta y yo sostendré el ritmo en la segunda.","Trato hecho. Te escucharé golpear las marcas.",1,1),
  a("light_joke","Si mis piernas presentan una queja, te la entregaré por escrito.","¡Que la firmen después de la última vuelta!",2,1)}, {challenge="rhythm"})
 add("E13","Apuesta romántica","Eris apuesta una merienda a un pequeño desafío de reflejos.","El perdedor elige el sitio y el ganador lleva la cesta. ¿Te atreves?","Coqueteo con juego limpio.","5 oro de apuesta; hasta 15 oro al acertar y una cita recordada.",{gold=15,familyProgress={eris_date=1}},{
  a("subtle_flirt","Acepto, aunque ya he ganado si la merienda es contigo.","Eso no te dará puntos en el desafío. Pero me gusta oírlo.",2,1),
  a("be_honest","Voy a intentar ganar. También quiero que elijas un sitio que te guste.","El del árbol grande. Ahora concéntrate, Rudeus.",1,2),
  a("light_joke","Pido que la cesta pese menos que tu espada.","Depende de cuánto comas. No pienso llevar tus porciones.",2,1)}, {challenge="rhythm",goldCost=5})
 add("E11","Hablar de aventuras","Eris se sienta a quitar barro de las botas. Un olor a lluvia trae recuerdos del viaje.","¿Qué parte de aquel camino volverías a recorrer?","Nostalgia compartida.","8 oro de una bolsa de viaje revisada y recuerdo compartido.",{gold=8,familyProgress={adventure_memories=1}},{
  a("listen","Quiero oír cuál recuerdas tú cuando empieza a llover así.","La posada con goteras. Me dejaste el lado seco sin decir nada.",2,1),
  a("be_honest","Recorrería la tarde en que dejamos de caminar cada uno por su cuenta.","Fue cuando aprendiste a esperar mi paso. Yo también la recuerdo.",2,2),
  a("light_joke","Volvería a aquella posada, pero llevaría mi propio techo.","Y una manta que no oliera a caballo. Esa parte sí podemos mejorarla.",2,1),
  a("remember","Recuerdo que pusiste tu capa sobre mis mapas antes de cubrirte tú.","No quería que perdiéramos la ruta. Ni que te quedaras atrás.",2,2)})
 add("E12","Preguntar por sus preocupaciones","Eris tarda en guardar la espada. Hoy mira más hacia la casa que hacia el patio.","No necesito que arregles todo. ¿Puedes quedarte a escuchar?","Vulnerabilidad sin condescendencia.","Recuerdo emocional y posibilidad de reparar el conflicto de esfuerzo.",{familyProgress={eris_concerns=1}},{
  a("listen","Me quedo. Cuéntame lo que quieras, sin que yo decida por ti.","A veces temo que sólo me busques cuando necesitas pelear. Quería decirlo.",2,2,"worried",{reconcile="training_effort"}),
  a("be_honest","También te busco porque eres mi familia. No siempre lo demuestro bien.","Entonces ven algún día sin traer un bastón. Eso sí me ayudaría.",1,2,"worried"),
  a("light_joke","Podría declarar que mi espada se encarga de los problemas difíciles.","Estoy intentando hablar de nosotros. Deja la espada fuera de esto.",-2,-2,"angry"),
  a("share_fear","Me preocupa que confundas mi silencio con distancia. Quiero aprender a estar aquí.","No necesito palabras perfectas. Necesito notar que te quedas.",2,2,"worried")})
 add("E14","Revisar estrategias","Las fichas de enemigos ocupan media mesa. Eris espera tu propuesta de retirada.","¿Qué hacemos si mi primer ataque falla?","Confianza táctica.","Una copia de Lanzar piedra y progreso de estrategia.",{copies={stone_throw=1},familyProgress={strategy=1}},{
  a("listen","Dime cuánto espacio necesitas para recuperar la guardia.","Dos pasos. Cubre esos dos y podré volver a entrar.",1,2),
  a("be_honest","No puedo improvisar energía propia. Guardaré una carta para cubrirte.","Entonces esa carta no se gasta por presumir en el primer turno.",1,2),
  a("encourage","Tu retirada también forma parte del plan. No tienes que ganar sola.","Y tú no vas a quedarte atrás por orgullo. Estamos de acuerdo.",2,1),
  a("propose_plan","Señal de retirada, cobertura y cambio de lado. Probemos los tres pasos.","Pon las fichas otra vez. Esta vez haré que el ataque falle.",1,2)})
 add("E15","Pedir revancha","Eris relee el resultado del último duelo antes de aceptar otro.","Esta vez quiero ver qué cambiaste desde aquel combate.","Memoria del esfuerzo anterior.","Duelo: hasta 20 oro, Bastón y revisión del conflicto previo.",{gold=20,copies={staff_strike=2},familyProgress={training=1}},{
  a("be_honest","He revisado mis bloqueos. Quiero probar una corrección, no borrar el resultado.","Eso sí merece otra ronda. Ponte delante de mí.",1,2),
  a("encourage","Tu valoración me hizo volver al patio. Voy a responder con esfuerzo.","Te daré una oportunidad real, como la otra vez.",1,2),
  a("light_joke","Mi orgullo ha solicitado una segunda revisión; mis pies aceptaron entrenar.","Pues que tus pies hablen primero. El orgullo puede esperar.",2,1),
  a("admit_error","En el último duelo dejé huecos por querer terminar deprisa. Voy a corregirlos.","Lo veremos en la guardia. Admitirlo es un principio, Rudeus.",1,2)}, {battle="duel",previousDuel=true})
end
