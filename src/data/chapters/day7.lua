-- Los planes se anticiparon el día cinco. Dos vínculos viables requieren un
-- acuerdo visible; nunca se resuelven comparando el amor ni separando en secreto.
local chapter={
 id="day7",day=7,title="La verdadera voz",initial="day7_intro",completionEvent="campaign_complete",
 scenes={
  day7_intro={title="Día 7 · El antídoto",background="home",music="mystery",lines={
   {speaker="nanahoshi",expression="neutral",text="La lectura es estable. El antídoto ha madurado. Bébelo ahora; después comprobaremos la voz y el flujo natural de maná."},
   {speaker="rudeus",delivery="thought",expression="worried",text="Siete días. Este frasco puede devolverme la voz, pero no deshacer cada respuesta que elegí con las cartas."},
  },choices={
   {id="use_antidote",label="Beber el antídoto y romper la maldición.",effects={cure=true,decision="antidote_use",value=true,text="Rudy bebe el antídoto. Voz y maná natural recuperados."}},
  }},
  day7_voice={title="Día 7 · La verdadera voz",background="home",music="romantic",lines={
   {speaker="rudeus",effect="cure",expression="happy",animation="happy_bounce",text="Puedo... hablar. Esta vez no es una carta. Gracias, Nanahoshi."},
   {speaker="narrator",text="VOZ: RECUPERADA. Una pequeña esfera de agua se forma sobre su mano y permanece estable. MANÁ NATURAL: RECUPERADO. El sello se ha deshecho."},
   {speaker="nanahoshi",expression="happy",text="Funciona. Conserva las cartas: hicieron su trabajo. Lo que les digas hoy a tus esposas ya puede salir de ti."},
   {speaker="rudeus",expression="neutral",text="No usaré la victoria para evitar esas conversaciones. Les explicaré la poción, la carta de Hitogami y por qué callé. También responderé por mis propias decisiones."},
   {speaker="narrator",text="Durante el día, Rudy cuenta por fin la verdad a las tres. La amenaza de la maldición ya no actúa. Escucharlo explica su silencio; no obliga a nadie a perdonar las promesas que rompió."},
  }},
  day7_council={title="Día 7 · Una casa que se elige",background="home",music="romantic",lines={
   {speaker="sylphiette",expression="neutral",text="Hemos hablado por separado. Ahora debemos decidir si la convivencia compartida tiene una base real: responsabilidades, información y tiempo para todas."},
   {speaker="roxy",expression="neutral",text="El afecto por sí solo no organiza tres proyectos. No aceptaremos que una promesa de presencia signifique otra ausencia sin explicar."},
   {speaker="eris",expression="neutral",text="Lo acordamos antes del desafío. Si podemos sostener la casa juntos, nos quedamos. Si no, hablaremos claro de quién emprende cada camino."},
  },choices={
   {id="unite",label="Renovar juntos los tres compromisos cumplidos.",requires={familyReady=true},effects={decision="family_agreement",value="united",familyEvent="family_renewal"}},
   {id="repair_household",label="Completar un plan común de reparación.",requires={all={{familyReady=false},{marriage="sylphiette",viable=true},{marriage="roxy",viable=true},{marriage="eris",viable=true},{relationship="sylphiette",love=65,trust=65},{relationship="roxy",love=65,trust=65},{relationship="eris",love=65,trust=65}}},effects={decision="family_agreement",value="repair",batch={{character="sylphiette",love=10,trust=10,sharedMoment="family_repair"},{character="roxy",love=10,trust=10,sharedMoment="family_repair"},{character="eris",love=10,trust=10,sharedMoment="family_repair"}}}},
   {id="review_plans",label="Escuchar los planes que permite nuestro historial.",requires={familyReady=false},effects={decision="family_agreement",value="review"}},
  }},
  day7_family={title="Día 7 · La familia Greyrat unida",background="festival",music="romantic",lines={
   {speaker="sylphiette",expression="happy",text="El reparto de tareas está firmado. Tu nombre aparece incluso en lavar los platos. Y no, invocar lluvia dentro de casa no cuenta."},
   {speaker="roxy",expression="happy",text="Mantendremos la investigación en Sharia y las visitas acordadas. Nuestro hogar tiene espacio para preguntas; no necesito ser perfecta para pertenecer a él."},
   {speaker="eris",expression="happy",text="Y haremos relevos en la ruta. ¡Cuando vuelva, entrenas conmigo! Ahora sí sé que cubrimos la espalda del otro."},
   {speaker="rudeus",expression="happy",text="No puedo prometer que nunca fallaré. Puedo cumplir lo que acordamos, reconocer cuando falle y no esconderme detrás de una amenaza."},
  }},
  day7_plans={title="Día 7 · Planes que sí pueden cumplirse",background="home",music="romantic",lines={
   {speaker="narrator",text="Si un vínculo terminó, los demás no desaparecen por tener menos amor. Las conversaciones vuelven a los proyectos concretos que cada esposa expuso antes de la batalla."},
   {speaker="rudeus",expression="worried",text="Roxy tiene una investigación larga fuera de Sharia; Eris, una ruta de escolta; Sylphie quiere reconstruir aquí una vida estable. No puedo prometer presencia continua en los tres lugares."},
   {speaker="narrator",text="Las esposas con un vínculo viable rechazan volver a una convivencia incompleta mientras las heridas de la familia sigan abiertas. Quieren una presencia sostenida en el proyecto acordado, y reconocen que elegirlo implica despedirse de los otros matrimonios."},
   {speaker="rudeus",expression="neutral",text="No elegiré según una cifra. Responderé por los compromisos que sí puedo sostener. Hablaré de cada separación de frente, sin convertir a nadie en una segunda opción secreta."},
  }},
  day7_departures={title="Día 7 · Despedidas sin borrar el pasado",background="festival",music="romantic",lines={
   {speaker="narrator",text="Rudy habla personalmente con quienes no compartirán su siguiente etapa. Las separaciones románticas se acuerdan de forma explícita; la familia organiza cuidados y responsabilidades sin pedir a nadie que finja un matrimonio."},
   {speaker="narrator",text="No son amistades instantáneas ni efectos obligatorios de la maldición. Hay dolor, tiempo y trabajo por delante. Cada una conserva sus capacidades, sus aliados y el derecho a construir una vida propia."},
  }},
 },encounters={},hubs={},locations={},
 summaries={campaign_complete={title="EL DESTINO DE LOS GREYRAT",subtitle="EPÍLOGO",background="festival",terminal=true,ending=true,body="Rudy ha recuperado su voz y su magia. El futuro familiar depende de los hechos de estos siete días.",footer="Fin de la campaña. El diario conserva tus decisiones."}},
 transitions={
  day7_intro={{to="day7_voice"}},
  day7_voice={{to="day7_sylphiette",effects={{id="festival_choice",unlock={"choose_together"},presenter="nanahoshi",familyEvent="festival"}}}},
  day7_council={{to="day7_family",requires={familyReady=true}},{to="day7_plans"}},
  day7_family={{to="campaign_complete",effects={{id="campaign_complete",decision="ending",value="family_united"}}}},
  day7_plans={{to="day7_plan_sylphiette"}},
  day7_departures={{to="campaign_complete",effects={{id="campaign_complete"}}}},
 },
}
local wives={"sylphiette","roxy","eris"}
local names={sylphiette="Sylphiette",roxy="Roxy",eris="Eris"}
local plans={sylphiette="Quedarse en Sharia y sostener el hogar acordado.",roxy="Acompañar a Roxy en su investigación prolongada.",eris="Acompañar a Eris en la ruta de protección."}
local farewell={
 sylphiette="Necesito estabilidad, y nuestros acuerdos no la han construido. Voy a cerrar nuestro matrimonio. Organizaré mi hogar con apoyo de la familia; seguiremos hablando de nuestras responsabilidades, pero no como esposos.",
 roxy="Puedo apreciar lo que aprendimos y admitir que no me he sentido escuchada como esposa. No continuaré este matrimonio. La investigación me dará espacio para decidir mi futuro sin ocupar un pedestal.",
 eris="Te digo esto de frente: no quiero seguir casada si no podemos respetar los compromisos. Me iré a la ruta. No borro lo que vivimos, pero tampoco voy a fingir que luchar juntos arregló todo.",
}
for index,id in ipairs(wives) do
 local nextId=wives[index+1] and ("day7_"..wives[index+1]) or "day7_council"
 chapter.scenes["day7_"..id]={title="Día 7 · Hablar con "..names[id],background="home",music="romantic",lines={
  {speaker=id,expression="neutral",text="Quiero revisar nuestros hechos: la tarea del segundo día, la discusión de las ruinas y lo que hicimos cuando hubo que cumplir una promesa."},
  {speaker=id,expression="happy",text="Has trabajado en nuestro conflicto y puedo considerar seguir contigo. Necesito que ese esfuerzo dure más que esta semana.",requires={marriage=id,viable=true}},
  {speaker=id,expression="worried",text="Todavía hay distancia o compromisos sin reparar. Una victoria no los cancela. Si tenemos una reparación empezada, podemos revisarla; si no, necesito que aceptes mi límite.",requires={marriage=id,viable=false}},
  {speaker=id,expression="neutral",text="Ayer rechazaste el acuerdo después de hacer la tarea conmigo. También cumpliste la primera misión. Si corriges ese rechazo y asumes por escrito tu parte, esos hechos nos dan una base para intentarlo; no una garantía sin esfuerzo.",requires={all={{relationship=id,love=60,trust=60,personalEvent="shared_mission"},{relationship=id,personalEvent="personal_mission"},{['not']={relationship=id,personalEvent="personal_resolution"}}}}},
  {speaker="rudeus",expression="neutral",text="Te escucho. No te pediré que niegues lo que pasó para que mi historia termine como yo quiero."},
 },choices={
  {id="renew",label="Renovar con hechos el compromiso que cumplí.",requires={marriage=id,viable=true},effects={character=id,love=4,trust=4,sharedMoment="festival_conversation"}},
  {id="reconcile",label="Retomar la reparación que ya habíamos iniciado.",requires={all={{marriage=id,viable=false},{relationship=id,love=45,trust=45,personalEvent="personal_resolution",commitment=true}}},effects={batch={{character=id,love=10,trust=10,reconcile="daily_commitment",promise={id="daily_commitment",status="kept"}},{character=id,reconcile="broken_trust"},{character=id,reconcile="mirror_doubt"}}}},
  {id="repair_late",label="Corregir el rechazo de ayer con las tareas ya hechas.",requires={all={{marriage=id,viable=false},{relationship=id,love=60,trust=60,personalEvent="shared_mission"},{relationship=id,personalEvent="personal_mission"},{['not']={relationship=id,personalEvent="personal_resolution"}}}},effects={batch={
   {character=id,love=4,trust=6,relationshipEvent="personal_resolution",critical={id="commitment",value=true},promise={id="daily_commitment",status="kept"},reconcile="daily_commitment",sharedMoment="late_accountability"},
   {character=id,reconcile="broken_trust"},{character=id,reconcile="mirror_doubt"},
  }}},
  {id="listen",label="Escuchar su conclusión sin pedir que borre el pasado.",effects={character=id,sharedMoment="heard_boundary"}},
 }}
 chapter.scenes["day7_farewell_"..id]={title="Día 7 · Una separación: "..names[id],background="home",music="romantic",lines={{speaker=id,expression="worried",text=farewell[id]},{speaker="rudeus",expression="worried",text="Me duele, pero aceptaré tu decisión. No convertiré mi arrepentimiento en otra obligación para ti."}}}
 chapter.transitions["day7_"..id]={{to=nextId,requires={marriage=id,viable=true}},{to="day7_farewell_"..id}}
 chapter.transitions["day7_farewell_"..id]={{to=nextId,effects={{id="separation_"..id,character=id,marriageState="separated",decision="separated_"..id,value=true}}}}
 local batch={}
 for _,other in ipairs(wives) do if other~=id then batch[#batch+1]={character=other,marriageState="separated",decision="separated_"..other,value=true} end end
 chapter.scenes["day7_plan_"..id]={title="Día 7 · El compromiso con "..names[id],background="home",music="romantic",lines={
  {speaker="narrator",text="La propuesta de "..names[id].." se revisa a la luz de lo vivido. Solo puede mantenerse un matrimonio que haya resuelto su conflicto, cuidado la confianza y reparado las promesas rotas."},
  {speaker=id,expression="neutral",text="Si seguimos juntos en esta etapa, necesito presencia real en el proyecto que acordamos. No quiero otra promesa que dependa de que las demás renuncien a sus vidas.",requires={marriage=id,viable=true}},
  {speaker="rudeus",expression="neutral",text="Lo que decida aquí debe ser posible de cumplir. Si no continúo este proyecto contigo, lo diremos como una separación romántica, no como una espera indefinida."},
 },choices={
  {id="commit",label=plans[id],requires={marriage=id,viable=true},effects={decision="final_commitment",value=id,batch=batch}},
  {id="release",label="Aceptar su camino y revisar el siguiente acuerdo.",effects={character=id,marriageState="separated",decision="separated_"..id,value=true}},
 }}
 chapter.transitions["day7_plan_"..id]={
  {to="day7_departures",requires={decision="choice_day7_plan_"..id,equals="commit"}},
  {to=wives[index+1] and ("day7_plan_"..wives[index+1]) or "day7_departures"},
 }
end
return chapter
