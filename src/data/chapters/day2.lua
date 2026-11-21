local allMeetings={all={{event="meeting_sylphiette"},{event="meeting_roxy"},{event="meeting_eris"}}}
local chapter={
 id="day2",day=2,title="Palabras prestadas",implemented=true,initial="hub",nextChapter="day3",completionEvent="day2_complete",
 companion={decisionKey="companion",selectionCheckpoint="hub",event="companion_selected"},
 scenes={
  meet_sylphiette={title="Día 2 · Las responsabilidades también se comparten",background="home",music="casual",lines={
   {speaker="sylphiette",expression="neutral",text="Norn llevará a Zenith al jardín. Me toca revisar las barreras de casa y preparar las provisiones. Quiero que hagamos ambas cosas juntos, no que me dejes una nota al marcharte."},
   {speaker="rudeus",delivery="enchanted",expression="worried",text="Puedo traer las provisiones mientras tú pruebas el círculo exterior. Confío en tu criterio; revisaremos las tareas juntos."},
   {speaker="sylphiette",expression="worried",text="Tu voz suena extraña hoy; tardas en responder. Eso sí ayuda. Promete avisarme de las expediciones. Puedo asumir riesgos si participo en decidirlos."},
  },choices={
   {id="listen_first",label="Compartir las tareas y acordar avisarnos.",effects={character="sylphiette",love=5,trust=5,relationshipEvent="shared_mission",promise={id="daily_commitment",status="pending"},decision="sylphiette_priority",value="shared"}},
   {id="leave_tasks",label="Dejarle las tareas y salir sin informar.",effects={character="sylphiette",love=-9,trust=-9,conflict="broken_trust",promise={id="daily_commitment",status="broken"},decision="sylphiette_priority",value="neglected"}},
  }},
  meet_roxy={title="Día 2 · Una mesa entre iguales",background="library",music="university",lines={
   {speaker="roxy",expression="neutral",text="Encontré una inversión en estas runas. Necesito otro par de ojos, no alguien que afirme que su antigua maestra jamás se equivoca."},
   {speaker="rudeus",delivery="enchanted",expression="happy",text="Mi esposa también puede equivocarse. Lo sé porque se casó con un hombre que etiqueta sus calcetines como componentes mágicos."},
   {speaker="roxy",expression="happy",text="Una decisión que aún defiendo. Ahora escucha: comparemos las muestras y entreguemos un informe con ambos nombres. Después quiero hablar de nosotros, sin títulos de maestra."},
  },choices={
   {id="compare_notes",label="Contrastar sus ideas y trabajar como iguales.",effects={character="roxy",love=5,trust=5,relationshipEvent="shared_mission",promise={id="daily_commitment",status="pending"},decision="roxy_equality",value="colleagues"}},
   {id="pedestal",label="Adorar su talento sin escuchar sus dudas.",effects={character="roxy",love=-9,trust=-9,conflict="broken_trust",promise={id="daily_commitment",status="broken"},decision="roxy_equality",value="pedestal"}},
  }},
  meet_eris={title="Día 2 · Cubrirse de verdad",background="training",music="forest",lines={
   {speaker="eris",expression="neutral",text="Ruijerd mandó noticias: hay bestias alteradas cerca del camino. Practicaremos una retirada antes de escoltar las provisiones. No todo se arregla corriendo hacia delante."},
   {speaker="rudeus",delivery="enchanted",expression="happy",text="Tú abres espacio; yo cubro la retirada con el bastón. Si necesitas salir, haz la señal. No intentaré ganar una carrera contra tu espada."},
   {speaker="eris",expression="happy",text="¡Eso! Quiero a mi marido al lado, no a un guardia que me prohíba luchar. Y si estoy herida, espero que me ayudes; no es lo mismo."},
  },choices={
   {id="mutual_support",label="Practicar juntos y acordar una retirada.",effects={character="eris",love=5,trust=5,relationshipEvent="shared_mission",promise={id="daily_commitment",status="pending"},decision="eris_support",value="mutual"}},
   {id="overprotect",label="Prohibirle participar aunque controla el riesgo.",effects={character="eris",love=-9,trust=-9,conflict="broken_trust",promise={id="daily_commitment",status="broken"},decision="eris_support",value="overprotect"}},
  }},
  seal_intro={title="Día 2 · El sendero de las provisiones",background="forest",requiresCompanion=true,lines={
   {speaker="narrator",text="Rudy y {companion} dejan las provisiones en el puesto del camino. Un guardia informa de una bestia desviada por pulsos de maná. Hay un desvío seguro hacia las ruinas."},
   {speaker="companion",expression="neutral",text="Podemos despejar el paso juntos o avisar a la guardia y usar el desvío. No hay civiles atrapados; ambas opciones son responsables."},
  },choices={
   {id="explore",label="Despejar juntos el sendero de la bestia.",effects={decision="forest_patrol",value="fight"}},
   {id="detour",label="Avisar a la guardia y seguir por el desvío.",effects={decision="forest_patrol",value="detour"}},
  }},
  seal_result={title="Día 2 · El rastro de la botica",background="ruins",requiresCompanion=true,lines={
   {speaker="rudeus",delivery="enchanted",expression="neutral",text="El grabado coincide con la caja que encontró Zanoba. Podemos copiarlo y recoger el frasco vacío sin tocar el residuo."},
   {speaker="companion",expression="happy",text="{companionMemory}"},
   {speaker="narrator",text="Entre las provisiones abandonadas hay una etiqueta de botica. Rudy reconoce el mismo papel del regalo que aceptó. Guarda la muestra; sus cartas sólo dicen que es una pista de la investigación."},
  }},
  day2_close={title="Día 2 · Regresar también es una decisión",background="laboratory",requiresCompanion=true,lines={
   {speaker="narrator",text="Después de acompañar a su esposa a casa, Rudy entrega la muestra a Nanahoshi en privado. Sus notas pueden explicar el bloqueo aquí sin ponerla bajo la amenaza dirigida a sus esposas."},
   {speaker="nanahoshi",expression="neutral",text="La etiqueta contiene un reactivo presente en tu muestra. Buscaré al proveedor. En las ruinas del bosque hay fragmentos capaces de alimentar las cartas sin usar tu maná."},
   {speaker="rudeus",delivery="note",expression="worried",text="Hoy mis esposas me pidieron cosas concretas. Una expedición no reemplaza esas responsabilidades. Mañana seguiremos investigando y volveremos a hablar."},
  }},
 },
 encounters={
  encounter_sylphiette={title="Preparar juntos el hogar",kind="conversation",character="sylphiette",background="home",intro="Acuerden el reparto de tareas y la seguridad de casa.",targetScore=5},
  encounter_roxy={title="Contrastar el informe",kind="investigation",character="roxy",background="library",intro="Roxy necesita una colaboración real, no admiración ciega.",targetScore=5},
  encounter_eris={title="La invitación de Eris",kind="conversation",character="eris",background="training",intro="¡Rudy! ¿Quieres ir a entrenar conmigo?",targetScore=5},
  seal_encounter={title="Bestia del bosque",kind="magic",character="companion",enemyId="forest_beast",background="forest",requiresCompanion=true,targetScore=5,tacticalContext={danger=false},intro="La bestia sigue el maná. Coordina la retirada y despeja el camino."},
 },
 locations={
  {character="sylphiette",scene="meet_sylphiette",completedEvent="meeting_sylphiette",title="Hogar y barreras",background="home"},
  {character="roxy",scene="meet_roxy",completedEvent="meeting_roxy",title="Una investigación compartida",background="library"},
  {character="eris",scene="meet_eris",completedEvent="meeting_eris",title="Escolta y entrenamiento",background="training"},
 },
 hubs={hub={title="DÍA 2 / PALABRAS PRESTADAS",background="courtyard",heading="TRES COMPROMISOS COTIDIANOS",description="Completa las visitas. Una conversación no borra una promesa incumplida.",readyHeading="PREPARAR LA EXPLORACIÓN",readyDescription="Elige compañía. M permite preparar tus mazos antes de salir.",companion={decision="companion",event="companion_selected",to="seal_intro",requires=allMeetings,options={"sylphiette","roxy","eris"}}}},
 summaries={phase_complete={title="UN RASTRO DE LA POCIÓN",subtitle="DÍA 2 COMPLETADO",background="courtyard",body="La etiqueta de la botica ofrece una pista. Las respuestas prestadas dejan consecuencias en la familia.",footer="Mañana investigaréis las ruinas del bosque.",continueLabel="Continuar al Día 3"}},
 transitions={
  seal_intro={{to="seal_encounter",requires={decision="forest_patrol",equals="fight"}},{to="seal_result"}},
  seal_encounter={{to="seal_result",effects={{id="forest_patrol_complete",character="companion",relationshipEvent="forest_mission"}}}},
  seal_result={{to="day2_close",effects={{id="seal_memory",character="companion",relationshipEvent="potion_trace",clue="apothecary_label"}}}},
  day2_close={{to="phase_complete",effects={{id="day2_complete"}}}},phase_complete={{to="day3_intro"}},
 },
}
for _,place in ipairs(chapter.locations) do
 local id=place.character
 chapter.scenes["result_"..id]={title="Día 2 · Lo que queda después",background=place.background,lines={
  {speaker=id,expression="neutral",text="Tus pausas me preocupan, pero la conversación nos ayuda a entendernos. Mañana recordaré lo que decidimos hacer, no solo las palabras que sonaron bien."},
  {speaker="rudeus",delivery="enchanted",expression="neutral",text="El compromiso sigue en pie. Tendré que demostrarlo cuando cueste cumplirlo."},
 }}
 chapter.transitions["meet_"..id]={{to="encounter_"..id}}
 chapter.transitions["encounter_"..id]={{to="result_"..id}}
 chapter.transitions["result_"..id]={{to="hub",effects={{id="meeting_"..id},{id="all_reunions",requires=allMeetings,unlock={"remember","happy_reply","bold_reply","admit_error","share_fear"},presenter=id}}}}
end
chapter.scenes.eris_training_challenge_scene={title="Día 2 · El desafío prometido",background="training",lines={
 {speaker="eris",expression="happy",text="¡Dijiste que querías un beso si ganabas! Tu prueba es cubrir mi retirada sin adelantarte a mi señal. No voy a dejártelo fácil."},
 {speaker="rudeus",delivery="thought",expression="worried",text="Eris levanta la mano. Acabamos de acordar qué significa. Tengo que escucharla incluso cuando quiera impresionarla."},
},choices={
 {id="cover",label="Cubrir la retirada y esperar su señal.",effects={character="eris",love=2,trust=3,sharedMoment="training_challenge",decision="eris_challenge_result",value="coordinated"}},
 {id="rush",label="Adelantarme e intentar sorprenderla.",effects={character="eris",love=-2,trust=-3,decision="eris_challenge_result",value="rushed"}},
}}
chapter.scenes.eris_training_challenge_result={title="Día 2 · Ganar confianza",background="training",lines={
 {speaker="eris",expression="happy",text="¡Bien! Me cubriste sin decidir por mí. Eso sí merece que cumpla mi parte del trato.",requires={decision="eris_challenge_result",equals="coordinated"}},
 {speaker="rudeus",delivery="thought",expression="happy",text="Su beso llega antes de que encuentre la siguiente carta. Habernos entendido vale más que presumir de victoria.",requires={decision="eris_challenge_result",equals="coordinated"}},
 {speaker="eris",expression="angry",text="¡La señal era para retirarnos! Podemos repetir el ejercicio otro día. Hoy no has ganado ese beso.",requires={decision="eris_challenge_result",equals="rushed"}},
 {speaker="rudeus",delivery="thought",expression="worried",text="Quise impresionarla y dejé de escuchar. Una carta atrevida no sustituye cumplir las reglas.",requires={decision="eris_challenge_result",equals="rushed"}},
 {speaker="narrator",text="El ensayo termina. La escolta y sus compromisos siguen pendientes."},
}}
chapter.transitions.encounter_eris={{to="eris_training_challenge_scene",requires={event="eris_romantic_training"}},{to="result_eris"}}
chapter.transitions.eris_training_challenge_scene={{to="eris_training_challenge_result"}}
chapter.transitions.eris_training_challenge_result={{to="result_eris"}}
return chapter
