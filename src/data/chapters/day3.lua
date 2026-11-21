return {
 id="day3",day=3,title="El primer fragmento",initial="day3_intro",nextChapter="day4",completionEvent="day3_complete",
 companion={decisionKey="day3_companion",selectionCheckpoint="day3_companion",event="day3_companion_selected"},
 scenes={
  day3_intro={title="Día 3 · Una copia incompleta",background="laboratory",music="mystery",lines={
   {speaker="narrator",text="Antes de reunirse con sus esposas, Rudy consulta a Cliff y Nanahoshi en privado. Eligen qué riesgos de la expedición podrán comunicar sin revelar el origen de la maldición."},
   {speaker="cliff",expression="neutral",text="La etiqueta señala unas ruinas bajo el bosque. Zanoba reforzó nuestras herramientas. Necesitamos un fragmento de su depósito de maná y otra muestra del reactivo."},
   {speaker="nanahoshi",expression="worried",text="Los fragmentos almacenan energía externa. No romperán tu bloqueo natural, pero pueden alimentar hechizos grabados en las cartas. Lleva compañía: todavía dependes del bastón."},
   {speaker="rudeus",delivery="enchanted",expression="neutral",text="Dejaré la ruta y una hora de regreso. Mi familia no tiene por qué adivinar dónde estoy."},
  }},
  day3_forest={title="Día 3 · Lo que recordamos juntos",background="forest",requiresCompanion=true,music="forest",variants={
   sylphiette={lines={
    {speaker="sylphiette",expression="neutral",text="Recuerdo cuando reconociste quién era detrás de Fitz. Quiero que también me reconozcas cuando digo que algo me preocupa; no soy solo la persona que espera en casa."},
    {speaker="rudeus",delivery="enchanted",expression="worried",text="Me preocupa perderte. Tengo cosas que todavía no sé explicar bien. Sí puedo compartir la ruta y escuchar qué necesitas para sentirte segura."},
    {speaker="sylphiette",expression="neutral",text="Puedo estar asustada y aun así ayudarte. Tú también."},
   }},
   roxy={lines={
    {speaker="roxy",expression="neutral",text="Recuerdo tu primer entusiasmo por la magia. Ahora me alegra poder discutir contigo. Pero, cuando dices que soy perfecta, siento que mis dudas no tienen sitio."},
    {speaker="rudeus",delivery="enchanted",expression="worried",text="De niño te admiraba. Como marido necesito aprender a escucharte incluso cuando no tienes una respuesta."},
    {speaker="roxy",expression="happy",text="Bien. Primera respuesta honesta: no sé si ese hongo es venenoso, así que deja de olerlo."},
   }},
   eris={lines={
    {speaker="eris",expression="neutral",text="Viajamos mucho antes de tener una casa. No quiero volver a dejar una explicación incompleta entre nosotros. Si me aparto, te diré por qué."},
    {speaker="rudeus",delivery="enchanted",expression="neutral",text="Y yo preguntaré antes de imaginar lo peor. Combatir juntos también exige hablar después."},
    {speaker="eris",expression="happy",text="¡Bien! Ahora pisa donde piso yo. Esa raíz ya intentó derrotarte dos veces."},
   }},
  },choices={
   {id="compare_evidence",label="Comparar recuerdos y comprobar el riesgo.",effects={character="companion",love=3,trust=3,decision="truth_method",value="evidence"}},
   {id="force_alone",label="Ignorar su criterio y forzar el paso solo.",effects={character="companion",love=-5,trust=-7,conflict="broken_trust",decision="truth_method",value="control"}},
  }},
  day3_illusion={title="Día 3 · El depósito protegido",background="ruins",requiresCompanion=true,lines={
   {speaker="narrator",text="Un sello del depósito proyecta copias rígidas de los viajeros. Es una alarma para desorientar a quien intenta retirar sus fragmentos. El guardián bloquea la salida."},
   {speaker="companion",expression="angry",text="Es una trampa. Mi copia repite la misma orden sin mirar el terreno. Escucha mis señales y retrocedamos juntos."},
   {speaker="rudeus",delivery="enchanted",expression="worried",text="El guardián despierta. Tú cubres el frente; yo protejo la muestra. Después volveremos a casa a la hora acordada."},
  }},
  day3_truth={title="Día 3 · La energía que sí responde",background="ruins",requiresCompanion=true,lines={
   {speaker="companion",expression="neutral",text="El guardián se detuvo. La ranura contiene un fragmento intacto. Lo colocaremos en el receptáculo de tus cartas."},
   {speaker="rudeus",delivery="thought",expression="happy",animation="happy_bounce",text="La carta canaliza el agua del fragmento. Mi maná sigue bloqueado: esto funciona con energía almacenada, igual que la voz prestada."},
  }},
  day3_family_time={title="Día 3 · El tiempo prometido",background="home",music="romantic",lines={
   {speaker="sylphiette",expression="worried",text="Ayer me dijiste que encontraríamos tiempo para nosotros. Las provisiones ya están guardadas. ¿Te quedas un rato conmigo?"},
   {speaker="rudeus",delivery="thought",expression="neutral",text="Las notas pueden esperar. Pero quedarme tiene que ser una decisión, no otra frase que la carta prometa por mí."},
  },choices={
   {id="keep",label="Guardar las notas y compartir la tarde.",effects={character="sylphiette",love=3,trust=5,promise={id="family_time",status="kept"},sharedMoment="family_time",decision="family_time_outcome",value="kept"}},
   {id="break",label="Marcharme a estudiar sin acordar otra hora.",effects={character="sylphiette",love=-4,trust=-7,promise={id="family_time",status="broken"},decision="family_time_outcome",value="broken"}},
  }},
  day3_return={title="Día 3 · La discusión que hacía falta",background="home",music="romantic",lines={
   {speaker="sylphiette",expression="worried",text="Hay dificultades aunque esta investigación termine bien. Me pesa sostener la casa si no compartimos las decisiones."},
   {speaker="roxy",expression="neutral",text="Y yo no quiero convertirme en un remedio para tu miedo. Nuestra investigación necesita honestidad, también sobre sus límites."},
   {speaker="eris",expression="angry",text="¡Pregúntanos! Si solo me dejas luchar cuando te conviene, no estás confiando en mí."},
   {speaker="rudeus",delivery="enchanted",expression="worried",text="No resolveremos esto con una frase. Antes de la próxima expedición cumpliré los compromisos que tengo con cada una."},
  },choices={
   {id="take_responsibility",label="Escuchar los tres conflictos sin excusas.",effects={decision="family_conflict",value="acknowledged"}},
   {id="blame_mirror",label="Culpar a la investigación y rechazar la conversación.",effects={decision="family_conflict",value="denied",batch={{character="sylphiette",love=-5,trust=-8},{character="roxy",love=-5,trust=-8},{character="eris",love=-5,trust=-8}}}},
  }},
 },
 encounters={
  day3_nanahoshi_research={title="Nanahoshi · Preparar la prueba",kind="investigation",character="nanahoshi",background="laboratory",targetScore=4,intro="Revisad los límites del artefacto antes de buscar su fragmento."},
  day3_encounter={title="Guardián de las ruinas",kind="magic",character="companion",enemyId="ruins_guardian",background="ruins",requiresCompanion=true,targetScore=5,tacticalContext={danger=true},intro="El guardián reúne energía. Coordina la defensa y aprovecha su debilidad al agua."}},
 locations={
  {character="sylphiette",title="Magia y protección",description="Comprueba señales y protege al grupo.",background="courtyard"},
  {character="roxy",title="Análisis y control",description="Estudia el mecanismo y sus puntos débiles.",background="courtyard"},
  {character="eris",title="Abrir el camino",description="Interrumpe al enemigo y combate junto a Rudy.",background="courtyard"},
 },
 hubs={day3_companion={title="DÍA 3 / EXPEDICIÓN A LAS RUINAS",background="courtyard",heading="PREPARAR UNA MISIÓN COMPARTIDA",description="Elige compañía y prepara ambos mazos con M.",companion={decision="day3_companion",event="day3_companion_selected",to="day3_forest",options={"sylphiette","roxy","eris"}}}},
 summaries={day3_complete={title="EL PRIMER FRAGMENTO",subtitle="DÍA 3 COMPLETADO",background="laboratory",body="El fragmento permite cartas mágicas de agua y tierra. La voz y el maná natural siguen sellados.",footer="Nanahoshi investigará la botica y el origen de la poción.",continueLabel="Continuar al Día 4"}},
 transitions={
  day3_intro={{to="day3_nanahoshi_research"}},day3_nanahoshi_research={{to="day3_companion"}},day3_forest={{to="day3_illusion"}},day3_illusion={{to="day3_encounter"}},
  day3_encounter={{to="day3_truth",effects={{id="ruins_mission",character="companion",relationshipEvent="ruins_mission",externalEnergy=12,clue="mana_fragment",unlock={"water_projectile","arcane_guard","heal","propose_plan","analyze_runes","earth_barrier"},presenter="companion"}}}},
  day3_truth={{to="day3_return",effects={{id="seal_truth"},{id="careful_research",requires={decision="truth_method",equals="evidence"},unlock={"earth_wall"},presenter="companion"},
   {id="family_doubts",batch={{character="sylphiette",conflict="mirror_doubt"},{character="roxy",conflict="mirror_doubt"},{character="eris",conflict="mirror_doubt"}}}}}},
  day3_return={{to="day3_family_time",requires={event="sylphiette_promised_family_time"}},{to="day3_complete",effects={{id="day3_complete"}}}},
  day3_family_time={{to="day3_complete",effects={{id="day3_complete"},{id="sylphiette_family_time_kept",requires={decision="family_time_outcome",equals="kept"}},{id="sylphiette_family_time_broken",requires={decision="family_time_outcome",equals="broken"}}}}},
  day3_complete={{to="day4_intro"}},
 },
}
