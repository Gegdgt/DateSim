local War={}
function War.install(list)
 local six,seven=list[6],list[7]
 six.title="El último cerco";seven.title="El desafío y la verdadera voz"
 -- La secuencia anterior se conserva en IDs heredados cuando ya existe antídoto.
 local truth,close=six.scenes.day6_truth,six.scenes.day6_close
 seven.scenes.day7_challenge=truth;truth.title="Día 7 · La promesa de Badigadi"
 seven.scenes.day7_victory=close;close.title="Día 7 · El antídoto conquistado"
 close.lines[2].text="Badigadi sigue vivo. Rudy recoge el antídoto; Nanahoshi verifica su estabilización en el contenedor preparado durante la noche."
 close.lines[3].text="El reactivo está estable. Podemos usarlo ahora. No necesitas buscar otra cura."
 close.lines[4].text="La cura está en mis manos. No borrará las decisiones que tomé con las cartas, pero hoy podré hablar sin esconder su causa."
 six.scenes.day6_truth={title="Día 6 · El último cerco",background="arena",lines={
  {speaker="nanahoshi",expression="worried",text="El reflejo cayó, pero un lacayo de Hitogami bloquea el paso. No lleva el antídoto. Badigadi nos espera mañana con el frasco protegido."},
  {speaker="rudeus",delivery="thought",text="Debo cuidar los recursos y preparar mis cartas. Ganar hoy abre el camino; la última batalla sigue pendiente."},
 }}
 six.encounters.day6_boss.legacyEncounter=true
 six.encounters.day6_hitogami={title="Lacayo de Hitogami",kind="magic",character="companion",enemyId="hitogami_minion",background="arena",targetScore=5,intro="Observa los ataques preparados y conserva recursos para las defensas."}
 six.scenes.day6_orsted_offer={title="Día 6 · Una prueba opcional",background="training",lines={
  {speaker="orsted",expression="neutral",text="Si contrastaste las runas del observatorio, puedo comprobar tu control bajo presión. Es una prueba, no una condición para obtener la cura. Puedes descansar."},
 },choices={
  {id="rest",label="Descansar y preparar el enfrentamiento final.",effects={decision="orsted_trial",value="declined"}},
  {id="accept",label="Aceptar la prueba de control de Orsted.",requires={decision="observatory_research",equals="tested"},effects={decision="orsted_trial",value="accepted"}},
 }}
 six.encounters.day6_orsted={title="Orsted · Control bajo presión",kind="magic",enemyId="orsted_trial",background="training",targetScore=5,intro="Prueba opcional y no letal. Termina al vencer o agotar tus PV; puedes continuar en ambos casos."}
 six.scenes.day6_close={title="Día 6 · Antes del desafío",background="laboratory",lines={
  {speaker="nanahoshi",expression="neutral",text="El camino está despejado. El antídoto sigue con Badigadi. Descansa y utiliza la última jornada para preparar cartas, materiales y apoyos."},
  {speaker="rudeus",delivery="thought",text="Todavía no recupero la magia natural. Mañana dependeré de mis cartas y de quienes hayan elegido seguir a mi lado."},
 }}
 six.transitions.day6_truth={{to="day6_hitogami"}}
 six.transitions.day6_boss={{to="day6_close",effects={{id="antidote_obtained",antidote=true,enemyDefeated="badigadi_final"}}}}
 six.transitions.day6_hitogami={{to="day6_orsted_offer"}}
 six.transitions.day6_orsted_offer={{to="day6_orsted",requires={decision="orsted_trial",equals="accepted"}},{to="day6_close"}}
 six.transitions.day6_orsted={{to="day6_close"}}
 six.summaries.day6_complete.title="EL CAMINO ESTÁ ABIERTO"
 six.summaries.day6_complete.body="Los lacayos han retrocedido. El antídoto sigue protegido por Badigadi; la magia natural de Rudy permanece bloqueada."
 six.summaries.day6_complete.footer="Mañana: preparar el equipo y afrontar al rey inmortal."
 six.hubs.day6_companion.heading="RUTA DEL DÍA 6"
 six.hubs.day6_companion.description="Elige una compañera disponible o viaja solo. El jefe final espera mañana."
 seven.initial="day7_muster"
 seven.companion={decisionKey="day7_companion",selectionCheckpoint="day7_muster",event="day7_companion_selected"}
 seven.hubs.day7_muster={title="DÍA 7 / PREPARACIÓN FINAL",background="arena",heading="BADIGADI · 1000 PV",
  description="Elige una compañera, todas las disponibles o viajar solo. M abre las mejoras.",
  companion={decision="day7_companion",event="day7_companion_selected",to="day7_challenge",options={"sylphiette","roxy","eris","all"}}}
 seven.locations=six.locations
 seven.encounters.day7_boss={title="Badigadi · El rey inmortal",kind="magic",character="companion",enemyId="badigadi_final",background="arena",targetScore=5,intro="1000 PV. Resistencia, seis brazos, defensa reforzada y sello. Las compañeras disponibles aportan una acción de apoyo cada una."}
 seven.transitions.day7_challenge={{to="day7_boss"}}
 seven.transitions.day7_boss={{to="day7_victory",effects={{id="antidote_obtained",antidote=true,enemyDefeated="badigadi_final"}}}}
 seven.transitions.day7_victory={{to="day7_intro"}}
 seven.scenes.day7_intro.lines[1].text="La lectura es estable. El antídoto que ganaste a Badigadi está listo. Bébelo; después comprobaremos tu voz y tu magia natural."
end
return War
