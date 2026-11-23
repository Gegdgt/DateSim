-- Cierre de la campaña. Se instala antes de las agendas y conserva IDs históricos.
local Final={}
function Final.install(list)
 local four,five,six,seven=list[4],list[5],list[6],list[7]
 six.title="La verdadera amenaza";seven.title="La verdadera voz"
 four.scenes.day4_intro.lines[1].text="Rudy se reúne en privado con Nanahoshi y Cliff. La carta firmada por —H permanece sobre la mesa; aún falta localizar a quien preparó la poción."
 four.scenes.day4_intro.lines[2]={speaker="nanahoshi",expression="worried",text="Las runas de la carta y de la poción comparten una firma. Las cartas parlantes contienen energía propia, pero no eliminan la amenaza de revelar el secreto."}
 four.scenes.day4_emissary.lines[5].text="¿Crees que llevo la cura en el bolsillo? Primero tendrás que encontrarme otra vez. Mi protector se encargará de que no leas el registro completo."
 four.scenes.day4_emissary.lines[6].text="El emisario huye. Rudy reconoce al responsable de la poción, pero no sabe dónde está el antídoto. El registro del almacén puede revelar su ruta."
 four.transitions.day4_emissary[1].effects[#four.transitions.day4_emissary[1].effects+1]={id="emissary_investigation_started",text="Investigación: recuperar el registro, seguir la ruta del emisario y obligarlo a revelar dónde está la cura."}
 four.scenes.day4_return.lines[2].text="El registro está cifrado, pero las entregas terminan cerca de la arena. Prepararé un contenedor estabilizador; así podremos usar la cura cuando la encontremos."
 four.scenes.day4_badigadi.title="Día 4 · Un encuentro en el camino"
 four.scenes.day4_badigadi.lines[1].text="¡Ja, ja, ja! ¡Greyrat! Caminas como si el mundo pesara sobre tus hombros. Un ejercicio corto te enseñaría más que apretar los dientes."
 four.scenes.day4_badigadi.lines[2].text="Hoy sólo practicaremos el ritmo. Tengo seis brazos y suficiente paciencia para detenerme cuando alguien pida una pausa. ¿Vienes con tu compañera?"
 four.scenes.day4_badigadi.lines[3].text="Acepto un ejercicio breve, con una señal de alto. Después debo continuar la investigación y volver a casa."
 four.summaries.day4_complete.body="El emisario entregó la poción y huyó. Su registro apunta hacia la arena, pero todavía oculta al poseedor del antídoto. Los compromisos familiares siguen pendientes."
 five.summaries.day5_complete.footer="Mañana: seguir el rastro del emisario y encontrar la cura."
 six.scenes.day6_intro.title="Día 6 · Seguir el último rastro"
 six.scenes.day6_intro.lines[1].text="Cliff descifró el registro: el emisario regresará hoy a la arena. Zanoba lleva el contenedor. Comparte la ruta con quienes sigan contigo y acuerda una señal de retirada."
 six.scenes.day6_intro.lines[5].text="La ruta incluye barreras de ocultación. Si localizamos al emisario, podremos averiguar quién tiene la cura. Todavía no conocemos ese nombre."
 six.scenes.day6_truth.title="Día 6 · La firma del emisario"
 six.scenes.day6_truth.lines={
  {speaker="nanahoshi",expression="neutral",text="El reflejo protegía la misma firma que encontramos en la botica. Detrás está el hombre que te entregó la poción. Tenemos que detener su huida."},
  {speaker="emisario",expression="angry",text="Has seguido demasiadas pistas, Greyrat. Las instrucciones eran claras: hacerte dudar de tu familia hasta que decidieras apartarla tú mismo."},
  {speaker="rudeus",delivery="thought",text="Esta vez no voy a perderlo. Primero neutralizaré sus barreras; después responderá por la botella que me entregó."},
 }
 six.encounters.day6_hitogami.title="Emisario de Hitogami · El responsable de la poción"
 six.encounters.day6_hitogami.enemyId="hitogami_emissary"
 six.encounters.day6_hitogami.requiresVictory=true
 six.encounters.day6_hitogami.intro="La investigación llega al responsable. Vence sus barreras y ataques preparados para descubrir quién custodia el antídoto."
 six.scenes.day6_emissary_confession={title="Día 6 · El nombre tras el sello",background="arena",music="mystery",lines={
  {speaker="narrator",text="La última barrera se rompe. El emisario deja caer el registro completo. Rudy reconoce su letra y le muestra la botella vacía."},
  {speaker="emisario",expression="worried",text="Badigadi posee el antídoto. Prometió custodiarlo hasta que alguien superara su desafío. El sello protege el frasco; vencer sus golpes no bastará."},
  {speaker="emisario",expression="neutral",text="Hitogami quería poner a prueba la estabilidad de los Greyrat. La poción y la advertencia eran suyas. Pero las decisiones de esta semana las tomaste tú."},
  {speaker="rudeus",delivery="thought",expression="angry",text="Badigadi. Estuvo frente a mí sin decirlo. Ya tengo un destino concreto; ahora debo decidir cómo llegar y quién todavía quiere acompañarme."},
  {speaker="nanahoshi",expression="neutral",text="Conservaremos este registro. El contenedor estará listo mañana. Prepara cartas y materiales; la fuerza que necesites no depende de otra recompensa secreta."},
 }}
 six.transitions.day6_hitogami={{to="day6_emissary_confession",effects={{id="emissary_investigation_completed",mission="emissary_investigation",enemyDefeated="hitogami_emissary"}}}}
 local reveal={id="antidote_holder_revealed",clue="antidote_location",text="El emisario derrotado confirma que Badigadi custodia el antídoto en la arena."}
 six.transitions.day6_emissary_confession={
  {to="day6_orsted_arrival",requires={event="eris_five_training_days"},effects={reveal}},
  {to="day6_close",effects={reveal}},
 }
 -- Las partidas v7 que ya estaban en la prueba anterior pueden concluirla.
 six.scenes.day6_orsted_offer.historical=true;six.encounters.day6_orsted.historical=true
 six.runtimeEvents={{id="eris_five_training_days",checkpoint="day5_eris_duel"}}
 six.scenes.day6_orsted_arrival={title="Día 6 · Cinco días de esfuerzo",background="training",music="training",lines={
  {speaker="orsted",expression="neutral",animation="enter_right",text="He visto tus registros con Eris: no cinco ejercicios apresurados, sino práctica cada día desde que empezó esta semana. Tu postura ya no es la del primer día."},
  {speaker="rudeus",delivery="enchanted",expression="neutral",text="Ella me enseñó a repetir lo que aún no controlo. Sigo dependiendo de estas cartas para dar instrucciones y atacar."},
  {speaker="orsted",expression="neutral",text="Quiero comprobar lo que aprendiste. No podrás vencerme. Usa tus cartas y defiéndete; terminaré la demostración antes de hacerte una herida grave."},
  {speaker="narrator",text="DEMOSTRACIÓN CONTROLADA: sobrevivir y responder importa. La derrota será narrativa; no acaba la partida ni perjudica tus relaciones."},
 }}
 six.encounters.day6_orsted_demonstration={title="Orsted · Demostración de superioridad",kind="magic",enemyId="orsted_demonstration",background="training",targetScore=1,scriptedDefeat="orsted_demonstration",
  intro="Encuentro no ganable y no letal. Usa tus cartas, defiéndete y observa cuatro turnos; Orsted pondrá fin a la prueba."}
 six.scenes.day6_orsted_discovery={title="Día 6 · El origen de los artefactos",background="training",music="mystery",finaleAction="orsted_grant",lines={
  {speaker="orsted",expression="neutral",text="Basta. Conservaste la guardia cuando el segundo golpe cambió de ángulo. Ahora déjame ver esa carta: reconozco el sello de los artefactos que entregué a Nanahoshi."},
  {speaker="rudeus",delivery="note",expression="worried",text="Ella adaptó sus patrones para prestarme una voz. Una poción selló la mía y mi maná. La carta de —H me amenazó con perder a mi familia si les explicaba lo ocurrido."},
  {speaker="orsted",expression="angry",text="La interferencia sobre tu maná tiene la marca de Hitogami. Pretendía convertir cada silencio en una decisión contra ellas. No voy a dejarle todos los recursos de este juego."},
  {speaker="orsted",expression="neutral",text="Te daré los patrones que faltan. Elige una carta de combate y otra social: llevaré ambas al nivel diez sin consumir tus copias ni tu oro. Serán dos cartas distintas."},
  {speaker="orsted",expression="neutral",text="Puedo reforzar un artefacto. No puedo restaurar por ti un matrimonio que hayas perdido. Las técnicas compartidas seguirán necesitando a la persona que las hace posibles."},
 }}
 six.hubs.day6_orsted_gifts={title="LA AYUDA DE ORSTED",background="training",locations={},orstedReward=true,finaleAction="orsted_choices"}
 six.scenes.day6_orsted_arrival.choices={
  {id="accept",label="Aceptar la demostración opcional.",effects={decision="orsted_demonstration",value="accepted"}},
  {id="rest",label="Agradecer la invitación y continuar hacia el descanso.",effects={decision="orsted_demonstration",value="declined"}},
 }
 six.transitions.day6_orsted_arrival={{to="day6_close",requires={decision="orsted_demonstration",equals="declined"}},{to="day6_orsted_demonstration"}}
 six.transitions.day6_orsted_demonstration={{to="day6_orsted_discovery",effects={{id="orsted_demonstration_completed",text="Orsted termina una demostración no letal. La derrota no modifica los matrimonios."}}}}
 six.transitions.day6_orsted_discovery={{to="day6_orsted_gifts"}}
 six.transitions.day6_orsted_gifts={{to="day6_close"}}
 six.hubs.day6_companion.heading="SEGUIR AL EMISARIO"
 six.hubs.day6_companion.description="Revisa el mazo y elige una compañera disponible o viaja solo. El registro conduce a la arena."
 for _,location in ipairs(six.locations)do location.description="Revisa su afinidad y sus habilidades antes de elegir. Las esposas separadas no participarán." end
 seven.scenes.day7_voice.lines[2].text="VOZ: RECUPERADA. Sin pronunciar un conjuro, Rudy forma una esfera de agua sobre la palma. MANÁ NATURAL Y MAGIA SIN CONJURO: RECUPERADOS. Sus manos tiemblan al deshacerla."
 seven.encounters.day7_boss.requiresVictory=true
 seven.scenes.day7_voice.lines[3].text="Es tu voz, Rudy. Habla con quienes siguen a tu lado. Después trae las cartas al laboratorio; ya no tendrás que pedirles que hablen por ti."
 seven.scenes.day7_voice.lines[5].text="Rudy regresa a casa para explicar la verdad a quienes permanecen con él. Entender la amenaza explica su silencio, pero no obliga a perdonar sus promesas rotas."
 local replies={
  sylphiette="Escuchar tu voz me alivia. Pero nuestra hija también esperó tus regresos. La amenaza no decidió quién asumía las tareas de casa; necesito que recuerdes eso cuando hagamos planes.",
  roxy="Ahora entiendo la interferencia que veía en las cartas. Me duele que tuvieras que ocultarla. Aun así, escuchar mis hipótesis o descartarlas fue una decisión tuya, no de ese sello.",
  eris="¡Debiste de estar furioso! Yo también lo estoy. Me alegra oírte otra vez. Pero no usaré a Hitogami para olvidar cuándo luchaste conmigo en serio y cuándo me dejaste esperando.",
 }
 for _,id in ipairs({"sylphiette","roxy","eris"})do
  local scene=seven.scenes["day7_"..id]
  table.insert(scene.lines,1,{speaker="rudeus",expression="worried",text="La poción selló mi voz. Hitogami amenazó nuestro vínculo si revelaba la causa. Nanahoshi adaptó las cartas para hablar; seguí al emisario hasta el antídoto. Mis decisiones siguen siendo mías."})
  table.insert(scene.lines,2,{speaker=id,expression=id=="eris" and "angry" or "worried",text=replies[id]})
  for _,transition in ipairs(seven.transitions["day7_"..id])do
   transition.effects=transition.effects or {};transition.effects[#transition.effects+1]={id="final_explanation_"..id,character=id,sharedMoment="truth_after_curse",text="Rudy explica la maldición, las cartas y sus decisiones; escucha la respuesta de "..id.."."}
  end
 end
 seven.scenes.day7_return_cards={title="Día 7 · Las palabras ya son mías",background="laboratory",music="romantic",finaleAction="return_cards",lines={
  {speaker="narrator",text="Después de las conversaciones, Rudy vuelve al laboratorio. Coloca ante Nanahoshi las cartas que prestaron sonido a sus decisiones durante siete días."},
  {speaker="rudeus",expression="neutral",text="Vengo a devolvértelas. Me ayudaron a hablar cuando no podía hacerlo. También me mostraron cuánto podía esconder detrás de una respuesta bien escogida."},
  {speaker="nanahoshi",expression="happy",text="Ahora puedes decirlo tú. No porque todas tus decisiones fueran buenas, sino porque has dejado de confundir recuperar la voz con evitar sus consecuencias."},
  {speaker="nanahoshi",expression="neutral",text="Guardaré los artefactos y una copia de tus registros. Tus patrones, niveles y estudios seguirán en el catálogo; devolver las cartas no borra lo que aprendiste."},
  {speaker="rudeus",expression="happy",text="Gracias. Esta vez no hay una carta entre nosotros. Lo que haga mañana también tendrá que salir de mí."},
 }}
 seven.transitions.day7_family={{to="day7_return_cards"}}
 seven.transitions.day7_departures={{to="day7_return_cards"}}
 seven.transitions.day7_return_cards={
  {to="day7_epilogue_family_united",requires={familyReady=true}},
  {to="day7_epilogue_roxy",requires={marriage="roxy",viable=true}},
  {to="day7_epilogue_eris",requires={marriage="eris",viable=true}},
  {to="day7_epilogue_sylphiette",requires={marriage="sylphiette",viable=true}},
  {to="day7_epilogue_solitary"},
 }
 local epilogues={
  family_united={background="home",lines={
   {speaker="sylphiette",expression="happy",text="Mañana me toca descansar. Está escrito y lo hemos hablado. Me gusta que este calendario tenga cuatro letras diferentes."},
   {speaker="roxy",expression="happy",text="Mi investigación puede esperar hasta después de la cena. Quiero escuchar cómo os fue, sin convertirlo en otro informe."},
   {speaker="eris",expression="happy",text="¡Y después practicamos! Un rato. También sé cuándo hay que guardar la espada y sentarse con todos."},
   {speaker="rudeus",expression="happy",text="La casa no se salvó con una sola victoria. Seguimos aquí porque aprendimos a responder por lo que prometimos."}}},
  roxy={background="library",lines={
   {speaker="roxy",expression="happy",text="He dejado dos sillas. Una para discutir mis cálculos y otra para que me digas que necesitas descansar. Puedes usar la misma, si lo dices a tiempo."},
   {speaker="rudeus",expression="neutral",text="Las despedidas siguen doliendo. No voy a ocultarlas detrás de nuestro trabajo. Quiero construir esta vida contigo sin fingir que no hubo consecuencias."},
   {speaker="roxy",expression="neutral",text="Entonces empezaremos por un experimento pequeño y una conversación honesta. Lo demás se sostiene un día a la vez."}}},
  eris={background="forest",lines={
   {speaker="eris",expression="happy",text="¡Ya basta de revisar el mismo nudo! La escolta sale al amanecer. Esta noche cenamos y descansamos; mañana podrás demostrar lo que entrenaste."},
   {speaker="rudeus",expression="neutral",text="Prepararé la barrera. También cumpliré mis responsabilidades con quienes tomaron otro camino. Viajar contigo no borra esas despedidas."},
   {speaker="eris",expression="neutral",text="Eso quería oír. No necesito que finjas ser invencible. Necesito saber que vas a decirme la verdad y cubrir mi espalda."}}},
  sylphiette={background="home",lines={
   {speaker="sylphiette",expression="happy",text="Nuestra hija eligió el cuento de esta noche. Ya terminé la barrera; tú puedes ordenar la mesa. Hoy no tenemos que salvar el mundo para hacer algo importante."},
   {speaker="rudeus",expression="neutral",text="Quiero reconstruir nuestra rutina contigo. Conozco lo que perdí y no voy a pedirte que llenes todos esos espacios por mí."},
   {speaker="sylphiette",expression="neutral",text="Podemos hablar de ello sin dejar de cuidar lo que tenemos. Empieza por sentarte. Esta vez tenemos tiempo."}}},
  solitary={background="courtyard",lines={
   {speaker="narrator",text="La casa está silenciosa por una razón que ningún antídoto puede cambiar. Rudy conserva su voz, su magia y los acuerdos de cuidado que debe seguir cumpliendo."},
   {speaker="rudeus",expression="worried",text="Quise llamar maldición a todo lo que dolía. Ellas se marcharon por decisiones que también fueron mías. No puedo exigir que regresen para demostrar que aprendí."},
   {speaker="rudeus",expression="neutral",text="Mañana cumpliré el primer acuerdo pendiente. Sin esperar que me devuelvan amor por hacerlo. Será un comienzo pequeño, pero esta vez será mío."}}},
 }
 for id,epilogue in pairs(epilogues)do
  epilogue.title="Epílogo · "..require("src.data.endings").byId[id].title;epilogue.music="romantic"
  seven.scenes["day7_epilogue_"..id]=epilogue
  seven.transitions["day7_epilogue_"..id]={{to="campaign_complete",effects={{id="campaign_complete",decision="ending",value=id}}}}
 end
end
return Final
