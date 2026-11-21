local chapter={
 id="day5",day=5,title="Lazos puestos a prueba",initial="day5_intro",nextChapter="day6",completionEvent="day5_complete",
 scenes={day5_intro={title="Día 5 · Cumplir antes de prometer",background="home",music="romantic",lines={
  {speaker="rudeus",delivery="enchanted",expression="neutral",text="Tenemos una ruta a la arena y una señal de retirada. Hoy no pediré que me perdonen porque mañana haya peligro. Quiero hacerme cargo de tres compromisos concretos."},
  {speaker="narrator",text="Norn y Aisha organizan la mesa del festival con Lilia. Zenith escucha el bullicio familiar. Rudy ayuda a preparar las cajas antes de hablar con cada una de sus esposas."},
  {speaker="narrator",text="Salvar la casa no da derecho a decidir quién vive en ella. Las tres también tienen proyectos, límites y un futuro propio."},
 }}},encounters={},hubs={},locations={},summaries={
  day5_complete={title="COMPROMISOS CON HECHOS",subtitle="DÍA 5 COMPLETADO",background="home",body="Cada matrimonio conserva sus propias decisiones, promesas y conflictos. Ninguna carta compra una reconciliación.",footer="Mañana enfrentaréis a Badigadi por el antídoto.",continueLabel="Continuar al Día 6"},
 },transitions={day5_intro={{to="day5_sylphiette",effects={{id="advanced_patterns",externalEnergy=20,unlock={"heavy_spell","water_cannon"},presenter="nanahoshi"}}}},day5_complete={{to="day6_intro"}}},
}
local definitions={
 {id="sylphiette",background="home",kind="investigation",card="shared_magic",title="La barrera de casa",mission="Reparar el ancla del hogar",
  request="La descarga dañó el ancla del hogar. Yo dirigiré la barrera; tú regula con tus cartas el agua que enfría las runas. Después reparte conmigo los turnos de vigilancia y las tareas de esta semana.",
  reply="Confío en tu magia. Trabajaré siguiendo tus señales, y el calendario llevará mi nombre tantas veces como el tuyo.",
  plan="Si podemos reparar nuestra convivencia, quiero seguir juntos en Sharia. Si no, reconstruiré aquí un hogar estable. No aceptaré otro acuerdo donde siempre espere a que vuelvas de dos vidas distintas.",
  gift="El ancla ya es estable. Esta carta conserva nuestra sincronización: Magia Compartida. No es un premio por decir que sí; trabajamos juntos hasta sostener la barrera.",
  positive="Cumplir el reparto y reconocer su autonomía.",negative="Dejarle de nuevo la carga y exigir confianza.",
  priorKey="sylphiette_priority",priorGood="shared",priorBad="neglected",memoryGood="Compartiste las tareas del segundo día. Ese rato me mostró que podíamos repartirlas; quiero que se convierta en un hábito.",memoryBad="El segundo día saliste sin avisar y dejaste las tareas conmigo. Reparar el ancla no borra eso; necesito que también reparemos nuestro acuerdo.",
 },
 {id="roxy",background="library",kind="investigation",card="combined_spell",title="El informe con dos firmas",mission="Resolver el círculo de retorno",
  request="El sello de la arena invierte dos runas. Comprueba mis cálculos conmigo, incluido ese error que marqué. Necesito a mi compañero de investigación y a mi marido, no a un creyente.",
  reply="Revisaré cada paso contigo. Si encontramos un error, constará en las notas. También quiero saber cómo estás tú después de todo esto.",
  plan="Nos ofrecieron una investigación larga fuera de Sharia. Si la familia se sostiene, trabajaré desde aquí con visitas acordadas. Si se rompe, aceptaré la estancia. No quiero reconstruir mi matrimonio mediante promesas de visitas que no llegan.",
  gift="El retorno responde a ambas firmas. Conjuro Combinado: la energía del artefacto y mi control. Gracias por escuchar mis dudas sin convertirlas en otra prueba de que soy perfecta.",
  positive="Revisar juntos y escuchar sus inseguridades.",negative="Firmar por ella y tratarla como infalible.",
  priorKey="roxy_equality",priorGood="colleagues",priorBad="pedestal",memoryGood="El otro día contrastaste mis notas en lugar de aceptarlas sin mirar. Sentí que estaba trabajando con mi esposo, no dando una clase a alguien que teme contradecirme.",memoryBad="Cuando expliqué mis dudas, respondiste elogiándome. Te pedía que me escucharas, no que me convencieras de que soy incapaz de equivocarme.",
 },
 {id="eris",background="training",kind="conversation",card="sword_magic",title="Una retirada bien ensayada",mission="Coordinar espada y barrera",
  request="Durante el ensayo me torcí el tobillo. Puedo dirigirlo sentada. Tú ejecuta las señales de cobertura; no necesito fingir que estoy bien para que me respetes.",
  reply="Te cubriré y seguiremos tu plan. Parar ahora protege la misión de mañana. Cuando estés recuperada, tú abrirás el paso.",
  plan="Ruijerd necesita escoltas en una ruta larga. Si seguimos juntos todos, haremos relevos. Si esa casa deja de funcionar, yo iré a la ruta. Quiero un compañero que camine conmigo, no que me pida quedarme esperando.",
  gift="¡Las señales funcionan! Espada y Magia. Mañana mi espada abrirá espacio y tu barrera cubrirá el regreso. Hoy me ayudaste sin tratarme como si fuera inútil.",
  positive="Protegerla ahora y respetar su plan táctico.",negative="Ignorar la lesión y exigir que siga luchando.",
  priorKey="eris_support",priorGood="mutual",priorBad="overprotect",memoryGood="En la primera práctica acordamos cubrirnos. Hoy necesito esa ayuda de otra forma: proteger una lesión no es tratarme como débil.",memoryBad="El otro día me prohibiste participar cuando controlaba el riesgo. Hoy sí estoy herida. Quiero que veas la diferencia y me escuches en las dos situaciones.",
 },
}
for index,d in ipairs(definitions) do
 local id=d.id
 local mission="day5_mission_"..id
 local resolve="day5_resolution_"..id
 local nextId=definitions[index+1] and ("day5_"..definitions[index+1].id) or "day5_complete"
 chapter.scenes["day5_"..id]={title="Día 5 · "..d.title,background=d.background,music="romantic",lines={
  {speaker=id,expression="worried",text=d.request},
  {speaker=id,expression="neutral",text=d.memoryGood,requires={decision=d.priorKey,equals=d.priorGood}},
  {speaker=id,expression="worried",text=d.memoryBad,requires={decision=d.priorKey,equals=d.priorBad}},
  {speaker="rudeus",delivery="enchanted",expression="neutral",text=d.reply},
  {speaker=id,expression="neutral",text=d.plan},
 }}
 chapter.encounters[mission]={title=d.mission,kind=d.kind,character=id,background=d.background,targetScore=4,intro="Completa la tarea compartida. La carta especial exige éxito, confianza y asumir el compromiso."}
 chapter.scenes[resolve]={title="Día 5 · Responsabilidad y reparación",background=d.background,lines={
  {speaker=id,expression="neutral",text="Trabajar juntos es un comienzo. Lo que necesito ahora es saber si cumplirás esto cuando no haya una investigación a la que culpar."},
  {speaker="rudeus",delivery="enchanted",expression="worried",text="He tenido oportunidades de hacerlo bien y de equivocarme. No puedo cambiar las anteriores; sí puedo responder por lo que haga a partir de ahora."},
 },choices={
  {id="repair",label=d.positive,effects={batch={
   {character=id,love=8,trust=10,relationshipEvent="personal_resolution",critical={id="commitment",value=true},promise={id="daily_commitment",status="kept"},reconcile="daily_commitment",sharedMoment="day5_mission"},
   {character=id,reconcile="broken_trust"},{character=id,reconcile="mirror_doubt"},
   {character=id,reconcile=id=="eris" and "eris_training_respect" or "family_time"},
   {character=id,reconcile=id=="eris" and "eris_injury_attention" or "daily_commitment"},
  }}},
  {id="dismiss",label=d.negative,effects={character=id,love=-12,trust=-15,conflict="broken_trust",critical={id="commitment",value=false},promise={id="daily_commitment",status="broken"}}},
 }}
 chapter.scenes["day5_gift_"..id]={title="Día 5 · Una técnica compartida",background=d.background,lines={{speaker=id,expression="happy",text=d.gift},{speaker="rudeus",delivery="enchanted",expression="happy",text="Guardaré la carta y lo que aprendimos haciéndola posible."}}}
 chapter.scenes["day5_after_"..id]={title="Día 5 · El compromiso continúa",background=d.background,lines={
  {speaker=id,expression="neutral",text="Mi decisión sobre nosotros no depende de la colección de cartas. Si hoy no terminamos la técnica, podremos seguir trabajando. Pero necesito que mis límites tengan consecuencias."},
 }}
 chapter.transitions["day5_"..id]={{to=mission}}
 chapter.transitions[mission]={{to="day5_battle_"..id}}
 chapter.encounters["day5_battle_"..id]={title="Proteger la preparación: "..d.title,kind="magic",character=id,enemyId=id=="eris" and "forest_beast" or "mana_anomaly",background=d.background,targetScore=4,tacticalContext={danger=true,companionInjured=id=="eris"},intro="Una descarga amenaza el trabajo compartido. Usa las señales acordadas y protege a tu compañera."}
 chapter.transitions["day5_battle_"..id]={{to=resolve,effects={{id="personal_mission_"..id,character=id,relationshipEvent="personal_mission"}}}}
 chapter.transitions[resolve]={
  {to="day5_gift_"..id,requires={all={{decision="choice_"..resolve,equals="repair"},{decision="outcome_"..mission,equals="success"},{relationship=id,trust=60}}}},
  {to="day5_after_"..id},
 }
 chapter.transitions["day5_gift_"..id]={{to="day5_after_"..id,effects={{id="wife_card_"..id,character=id,presenter=id,unlock={d.card},relationshipEvent="special_card"}}}}
 chapter.transitions["day5_after_"..id]={{to=nextId,effects=index==3 and {{id="day5_complete"}} or {}}}
end
-- El duelo sucede antes de la lesión del ensayo posterior. Su resultado se
-- confirma en una pantalla propia, sin convertir una derrota en muerte.
chapter.scenes.day5_eris_training_invitation={title="Día 5 · Un rival de verdad",background="training",music="training",lines={
 {speaker="eris",expression="happy",text="¡Rudy! Quiero que luchemos. ¡Y esta vez no quiero que te contengas!"},
 {speaker="rudeus",delivery="enchanted",expression="happy",text="Acepto. Usaré mis cartas y el maná del artefacto. No puedo ganarte un cruce de espadas, pero puedo preparar una apertura."},
 {speaker="eris",expression="neutral",text="¡Eso quiero ver! Contamos resistencia, no heridas. Paramos cuando uno ceda. Puedes preparar tu mazo antes de empezar."},
}}
chapter.encounters.day5_eris_duel={title="Entrenamiento · Rudy contra Eris",kind="magic",character="eris",enemyId="eris_training",training=true,background="training",music="training",targetScore=1,intro="Agota su resistencia usando aperturas, defensa y tus técnicas. Eris detendrá el golpe final."}
chapter.scenes.day5_training_reflection={title="Día 5 · Lo que importa del duelo",background="training",music="casual",lines={
 {speaker="eris",expression="happy",text="¡Quiero una revancha a esa estrategia! La próxima vez vigilaré cómo preparas tus ataques, no solo tu bastón.",requires={event="eris_training_rudy_victory"}},
 {speaker="eris",expression="happy",text="He ganado, pero me hiciste cambiar el ritmo. Eso sí fue entrenar juntos. ¡Repetiremos cuando haya tiempo!",requires={event="eris_training_honorable_defeat"}},
 {speaker="eris",expression="neutral",text="Te adelantaste a mi golpe. Perder una apertura no significa que no te esforzaras. La próxima vez prueba a defender y responder.",requires={event="eris_training_honest_defeat"}},
 {speaker="eris",expression="angry",text="Podías actuar y esperaste una y otra vez. No quiero que me regales una victoria. Necesito ver que me respetas como rival.",requires={event="eris_training_suspected_throw"}},
 {speaker="rudeus",delivery="thought",expression="neutral",text="La puntuación no resume lo que acaba de pasar. Eris recordará cómo competí y lo que haga después."},
},choices={
 {id="acknowledge",label="Escuchar su valoración y acordar el descanso.",effects={decision="eris_training_followup",value="acknowledged"}},
 {id="apologize",label="Disculparme y pedir demostrar mi esfuerzo después.",requires={event="eris_training_suspected_throw"},effects={decision="eris_training_followup",value="apologized"}},
}}
chapter.transitions.day5_intro[1].to="day5_eris_training_invitation"
chapter.transitions.day5_eris_training_invitation={{to="day5_eris_duel"}}
chapter.transitions.day5_eris_duel={{to="day5_training_reflection"}}
chapter.transitions.day5_training_reflection={{to="day5_sylphiette"}}
table.insert(chapter.scenes.day5_eris.lines,1,{speaker="narrator",text="Después del duelo, Eris se torció el tobillo durante otro ejercicio. Ahora detiene el ensayo y pide ayuda para adaptar el plan."})
return chapter
