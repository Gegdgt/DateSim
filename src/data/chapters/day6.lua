return {
 id="day6",day=6,title="El desafío del rey inmortal",initial="day6_intro",nextChapter="day7",completionEvent="day6_complete",
 companion={decisionKey="day6_companion",selectionCheckpoint="day6_companion",event="day6_companion_selected"},
 scenes={
  day6_intro={title="Día 6 · El camino a la arena",background="laboratory",music="tension",lines={
   {speaker="nanahoshi",expression="neutral",text="Cliff vigila las lecturas y Zanoba lleva el contenedor. Dos compañeras mantendrán despejada la salida; la tercera entrará contigo. Todos conocen la señal de retirada."},
   {speaker="nanahoshi",expression="worried",text="Esta vez todas tienen la copia del mapa. Ocultarla ayer complicó nuestro trabajo; nadie debería depender de adivinar tus intenciones.",requires={decision="observatory_plan",equals="secret"}},
   {speaker="nanahoshi",expression="happy",text="El reparto que acordasteis ayer nos permitió preparar cada puesto. Seguiremos ese mismo protocolo.",requires={decision="observatory_plan",equals="shared"}},
   {speaker="sylphiette",expression="neutral",text="Ayudaré en el desafío aunque tengamos cosas pendientes. Eso no significa que todas nuestras discusiones estén resueltas."},
   {speaker="roxy",expression="neutral",text="El frasco está protegido por un sello. Agotar la resistencia de Badigadi nos dará una apertura, pero habrá que neutralizar ese mecanismo expresamente."},
   {speaker="eris",expression="happy",text="El tobillo está recuperado. La pausa de ayer sirvió. Hagamos lo que practicamos y volvamos vivos."},
  }},
  day6_reflection={title="Día 6 · Una voz robada",background="arena",requiresCompanion=true,music="tension",lines={
   {speaker="narrator",text="En la entrada, el sello produce un reflejo distorsionado de Rudy. Copia la voz grabada de sus cartas y repite órdenes: avanzar solo, rechazar ayuda, controlar cada paso."},
   {speaker="rudeus",delivery="enchanted",expression="worried",text="No seguiré a una copia que ni siquiera escucha. Comprobemos la salida antes de avanzar."},
   {speaker="companion",expression="neutral",text="Te cubro. La copia alterna ataques y barreras; esperemos su apertura."},
  }},
  day6_eris_rematch_offer={title="Día 6 · Demostrarlo en la práctica",background="training",music="training",lines={
   {speaker="eris",expression="neutral",text="Ayer te disculpaste. El tobillo ya está bien. Podemos hacer un ejercicio corto antes de salir; quiero ver esfuerzo, no una promesa de que vas a ganar."},
   {speaker="rudeus",delivery="enchanted",expression="neutral",text="Acepto tus límites. Si repetimos, usaré las aperturas y pediré una pausa cuando la necesite."},
  },choices={
   {id="accept",label="Repetir el duelo con las mismas reglas de seguridad.",effects={decision="eris_rematch_offer",value="accepted"}},
   {id="rest",label="Descansar; todavía queda reparar ese desacuerdo.",effects={decision="eris_rematch_offer",value="declined"}},
  }},
  day6_eris_rematch_close={title="Día 6 · Hechos después de una disculpa",background="training",music="casual",lines={
   {speaker="eris",expression="happy",text="Eso era lo que te pedía: que te enfrentaras a mí en serio. Acepto la disculpa. Ahora guardemos fuerzas para la arena.",requires={event="eris_training_reconciled"}},
   {speaker="eris",expression="worried",text="Ya hemos practicado suficiente. Lo de ayer sigue pendiente. Podremos hablarlo sin fingir que una frase arregla todo.",requires={['not']={event="eris_training_reconciled"}}},
   {speaker="rudeus",delivery="thought",expression="neutral",text="Guardo ambas experiencias. Volver a intentarlo no borra lo que hice antes."},
  }},
  day6_truth={title="Día 6 · Las condiciones del desafío",background="arena",requiresCompanion=true,lines={
   {speaker="badigadi",expression="happy",animation="enter_right",text="¡Pasasteis la entrada! Ahora viene la parte divertida. Primero mi resistencia. Después, mis seis brazos. Y cuando me hagáis ceder, todavía quedará el sello."},
   {speaker="badigadi",expression="neutral",text="No voy a regalaros el frasco: di mi palabra. Tampoco pienso destrozar a quienes ya no pueden levantarse. Si caéis, os recuperaréis y podréis intentarlo otra vez."},
   {speaker="rudeus",delivery="thought",expression="angry",text="Hitogami contó con que llegara aislado y sin magia. Cada fragmento y cada ayuda conservada nos trajeron hasta aquí. No voy a desperdiciarlo persiguiendo su voz."},
   {speaker="companion",expression="worried",text="El sello ya está cargándose. Acordemos cómo proteger el regreso antes de entrar."},
  },choices={
   {id="protect_return",label="Priorizar la salida y avisar a todo el grupo.",effects={decision="mirror_final_plan",value="return",batch={{character="sylphiette",trust=2},{character="roxy",trust=2},{character="eris",trust=2}}}},
   {id="chase_voice",label="Lanzarse al desafío sin avisar al grupo.",effects={decision="mirror_final_plan",value="reckless",batch={{character="sylphiette",trust=-8},{character="roxy",trust=-8},{character="eris",trust=-8}}}},
  }},
  day6_close={title="Día 6 · La promesa cumplida",background="arena",music="victory",lines={
   {speaker="badigadi",expression="happy",animation="happy_bounce",text="¡Ja, ja, ja! ¡Basta! Me habéis obligado a ceder y el sello está abierto. El frasco es vuestro. Dadme un rato para recuperar estos brazos y volveré a brindar."},
   {speaker="narrator",text="Badigadi sigue vivo. La victoria termina el desafío; no su inmortalidad. Rudy recoge el antídoto y Nanahoshi lo coloca en el contenedor para completar su estabilización durante la noche."},
   {speaker="nanahoshi",expression="happy",text="El reactivo está íntegro. Al amanecer comprobaré la última lectura. Ya no necesitas buscar otra cura."},
   {speaker="rudeus",delivery="thought",expression="worried",text="Quería que el silencio me obligara a aislarme hasta perderlas. Sus cartas no tomaron mis decisiones: algunas fueron cuidadosas y otras hicieron daño. Mañana podré hablar sin esconder la causa."},
   {speaker="narrator",text="En privado, Orsted confirma la intención de Hitogami: usar el miedo a revelar el secreto para destruir los vínculos desde dentro. Rudy guarda esa explicación hasta que la maldición termine."},
  }},
 },
 encounters={
  day6_eris_rematch={title="Entrenamiento · Segunda oportunidad",kind="magic",character="eris",enemyId="eris_training",training=true,background="training",music="training",targetScore=1,intro="Una segunda oportunidad para competir en serio. La victoria no es obligatoria para demostrarlo."},
  day6_reflection_fight={title="Reflejo distorsionado de Rudy",kind="magic",character="companion",enemyId="rudy_reflection",background="arena",requiresCompanion=true,targetScore=5,tacticalContext={danger=true},intro="El reflejo alterna magia y barreras. Escucha el análisis de tu compañera."},
  day6_boss={title="Badigadi · El rey inmortal",kind="magic",character="companion",enemyId="badigadi_final",background="arena",requiresCompanion=true,targetScore=5,tacticalContext={danger=true,companionInjured=true},intro="Resiste sus seis brazos, agota su resistencia y neutraliza el sello. Reducir sus PV a cero no basta para obtener el antídoto."},
 },
 locations={
  {character="sylphiette",title="Protección y apoyo",description="Entra contigo; Roxy y Eris despejan la salida.",background="courtyard"},
  {character="roxy",title="Coordinación mágica",description="Entra contigo; Sylphie y Eris despejan la salida.",background="courtyard"},
  {character="eris",title="Espada y magia",description="Entra contigo; Sylphie y Roxy despejan la salida.",background="courtyard"},
 },
 hubs={day6_companion={title="DÍA 6 / LA ARENA",background="arena",heading="PREPARACIÓN FINAL",description="Edita el mazo con M. Las otras dos esposas mantendrán la salida despejada.",companion={decision="day6_companion",event="day6_companion_selected",to="day6_reflection",options={"sylphiette","roxy","eris"}}}},
 summaries={day6_complete={title="EL ANTÍDOTO ESTÁ A SALVO",subtitle="DÍA 6 COMPLETADO",background="laboratory",body="Badigadi cumplió su promesa. Hitogami continúa siendo una amenaza, pero su poción tiene cura. La voz y el maná siguen sellados hasta beberla.",footer="El antídoto estará listo al amanecer.",continueLabel="Continuar al Día 7"}},
 transitions={
  day6_intro={{to="day6_eris_rematch_offer",requires={all={{event="eris_training_suspected_throw"},{any={{decision="eris_training_followup",equals="apologized"},{event="eris_duel_apology_heard"}}}}}},{to="day6_companion"}},
  day6_eris_rematch_offer={{to="day6_eris_rematch",requires={decision="eris_rematch_offer",equals="accepted"}},{to="day6_companion"}},
  day6_eris_rematch={{to="day6_eris_rematch_close"}},day6_eris_rematch_close={{to="day6_companion"}},
  day6_reflection={{to="day6_reflection_fight"}},day6_reflection_fight={{to="day6_truth",effects={{id="rudy_reflection_defeated"}}}},
  day6_truth={{to="day6_boss"}},day6_boss={{to="day6_close",effects={{id="antidote_obtained",antidote=true,enemyDefeated="badigadi_final"}}}},
  day6_close={{to="day6_complete",effects={{id="day6_complete"}}}},day6_complete={{to="day7_intro"}},
 },
}
