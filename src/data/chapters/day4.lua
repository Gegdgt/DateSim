return {
 id="day4",day=4,title="El precio del silencio",initial="day4_intro",nextChapter="day5",completionEvent="day4_complete",
 companion={decisionKey="day4_companion",selectionCheckpoint="day4_companion",event="day4_companion_selected"},
 scenes={
  day4_intro={title="Día 4 · El origen de las cartas",background="laboratory",music="mystery",lines={
   {speaker="narrator",text="Con sus esposas atendiendo las tareas acordadas, Rudy se reúne en privado con Orsted, Nanahoshi y Cliff. La carta firmada por —H permanece sobre la mesa."},
   {speaker="orsted",expression="neutral",animation="enter_right",text="Reconozco la firma del encantamiento. Hitogami busca aislarte. Las cartas que entregué a Nanahoshi contienen energía propia; no uses su voz almacenada para transmitir el secreto a tus esposas."},
   {speaker="rudeus",delivery="note",expression="worried",text="¿La amenaza alcanza también una nota? No quiero comprobarlo poniendo a mi familia en peligro."},
   {speaker="cliff",expression="worried",text="Sí. La maldición reacciona a la intención de revelarlo, no al sonido. No hay un atajo escrito. Pero el reactivo tiene un antídoto: necesitamos encontrar a su fabricante."},
   {speaker="nanahoshi",expression="neutral",text="Encontré la botica de la etiqueta. Su proveedor vuelve esta mañana. Ve solo hasta la puerta; luego reuniremos al grupo para registrar el almacén."},
  }},
  day4_emissary={title="Día 4 · Una cara conocida",background="apothecary",music="tension",lines={
   {speaker="emisario",expression="happy",animation="enter_right",text="Vaya, el señor Greyrat. ¿Le sentó bien mi tónico? No recuerdo haberle prometido que sus efectos fueran agradables."},
   {speaker="rudeus",delivery="thought",expression="worried",animation="surprised_jump",text="Esa voz... El paquete que acepté antes del sueño. Ahora lo recuerdo."},
   {speaker="narrator",text="Recuerdo de la víspera. El emisario le ofreció una botella como agradecimiento por ayudar a la botica. Rudy bebió un sorbo sin preguntar por los ingredientes. No hubo brillo ni aviso: sólo un sabor amargo."},
   {speaker="rudeus",delivery="note",expression="angry",text="Sabías lo que contenía. Dame el antídoto."},
   {speaker="emisario",expression="neutral",text="Ya no está aquí. Badigadi prometió custodiarlo hasta que alguien superara su desafío. El sello no cede sólo ante la fuerza. Mi protector les cerrará el almacén; inténtalo si quieres."},
   {speaker="narrator",text="El emisario huye por una salida estrecha. Rudy copia el registro de entrega para Nanahoshi. Su recuerdo confirma cómo recibió la poción, pero el secreto sigue lejos de sus esposas."},
  }},
  day4_council={title="Día 4 · Lo que sí puede compartirse",background="home",lines={
   {speaker="sylphiette",expression="happy",text="Ayer guardaste las notas y te quedaste conmigo. Recuerdo aquella promesa del segundo día; hoy me resulta más fácil confiar en la hora de regreso.",requires={decision="family_time_outcome",equals="kept"}},
   {speaker="sylphiette",expression="worried",text="Me prometiste tiempo juntos y ayer volviste a marcharte. No necesito otra frase bonita. Necesito que cumplas una hora que hayamos acordado.",requires={decision="family_time_outcome",equals="broken"}},
   {speaker="sylphiette",expression="worried",text="Te marchaste a la botica sin explicar el plan. Quiero conocer la ruta, los riesgos y quién protege el regreso."},
   {speaker="roxy",expression="neutral",text="Puedo analizar el mecanismo que bloquea el almacén. Tus pausas y esas cartas me inquietan; no las tomaré como excusa para decidir por mí."},
   {speaker="eris",expression="angry",text="Si hay un guardián, lo enfrentamos juntos. ¡Pero no me dejes esperando sin saber cuándo vuelves!"},
   {speaker="rudeus",delivery="enchanted",expression="worried",text="El almacén tiene un guardián y dos salidas. Compartiré el mapa y las señales. No puedo explicar todo todavía, pero cumpliré la hora de regreso."},
  },choices={
   {id="share_plan",label="Compartir riesgos y repartir funciones.",effects={decision="observatory_plan",value="shared",batch={{character="sylphiette",love=4,trust=4},{character="roxy",love=4,trust=4},{character="eris",love=4,trust=4}}}},
   {id="apologize_time",label="Disculparme por la ausencia y compartir el plan.",requires={decision="family_time_outcome",equals="broken"},effects={decision="observatory_plan",value="shared",batch={{character="sylphiette",love=1,trust=2,relationshipEvent="family_time_apology"},{character="roxy",love=4,trust=4},{character="eris",love=4,trust=4}}}},
   {id="secret_plan",label="Ocultar también el mapa y decidir por las tres.",effects={decision="observatory_plan",value="secret",batch={{character="sylphiette",love=-6,trust=-8,conflict="broken_trust"},{character="roxy",love=-6,trust=-8,conflict="broken_trust"},{character="eris",love=-6,trust=-8,conflict="broken_trust"}}}},
  }},
  day4_observatory={title="Día 4 · El protector del almacén",background="apothecary",requiresCompanion=true,lines={
   {speaker="companion",expression="neutral",text="Las lentes alimentan al guardián. Si comprobamos la secuencia antes de romperlas, podremos dejar intacta la salida."},
   {speaker="rudeus",delivery="enchanted",expression="neutral",text="Revisemos las marcas juntos. Tú miras la salida; yo preparo el receptáculo del fragmento."},
  },choices={
   {id="test_sequence",label="Comprobar la hipótesis con mi compañera.",effects={character="companion",trust=3,decision="observatory_research",value="tested"}},
   {id="blast_lenses",label="Romper las lentes sin escuchar el análisis.",effects={character="companion",trust=-5,decision="observatory_research",value="rushed"}},
  }},
  day4_return={title="Día 4 · Una cura, no una absolución",background="laboratory",lines={
   {speaker="narrator",text="Su compañera lleva las provisiones a casa. Rudy se queda a solas con Nanahoshi y Cliff para analizar el registro de entrega."},
   {speaker="nanahoshi",expression="happy",text="El registro confirma la entrega. La fórmula necesita madurar durante una noche después de retirar el sello. Si consigues el frasco el sexto día, podrás beberlo al amanecer del séptimo."},
   {speaker="cliff",expression="neutral",text="He estabilizado más energía externa y dos patrones: Bala de Agua y Proyectil de Piedra. Tu reserva natural sigue bloqueada. Revisa el mazo antes de salir."},
   {speaker="rudeus",delivery="note",expression="worried",text="Recuperar mi voz no reparará las decisiones que tomé. Necesito cumplir mis promesas antes del desafío."},
  }},
  day4_badigadi={title="Día 4 · La promesa del rey inmortal",background="arena",requiresCompanion=true,music="casual",lines={
   {speaker="badigadi",expression="happy",animation="happy_bounce",text="¡Ja, ja, ja! ¡Así que vienes por el frasco! Mi promesa exige un desafío digno. Tengo seis brazos, tiempo de sobra y ninguna intención de morir por un encargo."},
   {speaker="badigadi",expression="neutral",text="El sexto día defenderé el sello de la arena. Si me obligas a ceder y lo neutralizas, el frasco será tuyo. Hoy puedo mostrarte el ritmo de mis golpes."},
   {speaker="rudeus",delivery="enchanted",expression="neutral",text="Acepto las condiciones del desafío. Si practicamos hoy, será con mi compañera y con una señal de alto."},
  },choices={
   {id="train",label="Practicar juntos en el duelo amistoso.",effects={decision="badigadi_offer",value="accepted"}},
   {id="rest",label="Agradecer la oferta y volver a descansar.",effects={decision="badigadi_offer",value="declined"}},
  }},
  day4_training_end={title="Día 4 · Aprender el ritmo",background="arena",requiresCompanion=true,lines={
   {speaker="badigadi",expression="happy",text="¡Suficiente por hoy! Estos golpes eran lentos. Cuando use los seis brazos, defenderse será tan importante como atacar."},
   {speaker="companion",expression="happy",text="Practicar juntos sirvió. Ahora nos toca descansar y cumplir lo prometido en casa."},
  }},
 },
 encounters={
  day4_nanahoshi_research={title="Nanahoshi · Contrastar el sello",kind="investigation",character="nanahoshi",background="laboratory",targetScore=4,intro="Comprobad la lectura del fragmento y la pista de la botica."},
  day4_encounter={title="Protector del emisario",kind="magic",character="companion",enemyId="protector_emissary",background="apothecary",requiresCompanion=true,targetScore=5,tacticalContext={danger=true},intro="El guardián protege el registro de la botica. Observa su intención y coordina el ataque."},
  day4_training={title="Badigadi · ensayo del desafío",kind="magic",character="companion",enemyId="badigadi_training",background="arena",requiresCompanion=true,targetScore=5,tacticalContext={danger=false},intro="Ejercicio controlado: Badigadi detendrá el entrenamiento cuando completes la prueba."},
 },
 locations={
  {character="sylphiette",title="Anclar la salida",description="Protección y mitigación de la descarga.",background="courtyard"},
  {character="roxy",title="Leer las lentes",description="Control mágico y análisis de debilidades.",background="courtyard"},
  {character="eris",title="Romper el ritmo",description="Interrupción y ataques cuerpo a cuerpo.",background="courtyard"},
 },
 hubs={day4_companion={title="DÍA 4 / LA BOTICA OCULTA",background="courtyard",heading="PREPARAR EL REGISTRO",description="Revisa el mazo con M y elige quién entra contigo.",companion={decision="day4_companion",event="day4_companion_selected",to="day4_observatory",options={"sylphiette","roxy","eris"}}}},
 summaries={day4_complete={title="EL PRECIO DEL SILENCIO",subtitle="DÍA 4 COMPLETADO",background="laboratory",body="El emisario entregó la poción. Badigadi custodia el antídoto por una promesa. Las sospechas familiares requieren hechos.",footer="Antes del desafío, hay compromisos que cumplir.",continueLabel="Continuar al Día 5"}},
 transitions={
  day4_intro={{to="day4_nanahoshi_research"}},day4_nanahoshi_research={{to="day4_emissary"}},day4_emissary={{to="day4_council",effects={{id="potion_memory",clue="potion_origin"}}}},
  day4_council={{to="day4_companion"}},day4_observatory={{to="day4_encounter"}},
  day4_encounter={{to="day4_return",effects={{id="seal_will",externalEnergy=16,unlock={"magic_bolt","ice_lance","angry_reply","sincere_apology","change_subject"},presenter="cliff"},{id="observatory_discovery",requires={decision="observatory_research",equals="tested"},unlock={"swamp"},presenter="companion"}}}},
  day4_return={{to="day4_badigadi"}},
  day4_badigadi={{to="day4_training",requires={decision="badigadi_offer",equals="accepted"}},{to="day4_complete",effects={{id="day4_complete"}}}},
  day4_training={{to="day4_training_end",effects={{id="training_complete",mission="friendly_duel"}}}},
  day4_training_end={{to="day4_complete",effects={{id="day4_complete"}}}},day4_complete={{to="day5_intro"}},
 },
}
