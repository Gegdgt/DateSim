-- Data only: edit these records to add cards without changing the encounter engine.
local list = {
    {id="listen", name="Escuchar", category="empathy", cost=1, icon="listen",
     description="Da espacio a la otra persona. +2 confianza; destaca con Sylphiette.",
     effects={score=1, trust=2, chemistry=0}, contexts={conversation={score=1},investigation={score=1}},
     affinities={sylphiette={chemistry=1}}, conditions={}, unlockedAt=1},
    {id="encourage", name="Dar ánimo", category="empathy", cost=1, icon="encourage",
     description="Ofrece apoyo sin decidir por nadie. +1 confianza y amor.",
     effects={score=1, trust=1, chemistry=1}, contexts={magic={score=1},conversation={score=1}},
     affinities={eris={trust=1}}, conditions={}, unlockedAt=1},
    {id="remember", name="Recordar un detalle", category="empathy", cost=1, icon="remember",
     description="Demuestra atención. +1 confianza, +2 amor en una conversación.",
     effects={score=1, trust=1, chemistry=1}, contexts={conversation={chemistry=1}},
     affinities={sylphiette={score=1}}, conditions={}, unlockedAt=2},
    {id="light_joke", name="Broma ligera", category="humor", cost=0, icon="light_joke",
     description="Alivia la tensión. +1 amor; poco eficaz ante una anomalía.",
     effects={score=0, trust=0, chemistry=1}, contexts={conversation={score=1}},
     affinities={eris={score=1}}, conditions={}, unlockedAt=1},
    {id="change_subject", name="Cambiar de tema", category="humor", cost=0, icon="change_subject",
     description="Permite respirar. Sin cambios de relación; no resuelve el desafío.",
     effects={score=0, trust=0, chemistry=0}, contexts={}, affinities={}, conditions={}, unlockedAt=1},
    {id="self_joke", name="Reírse de uno mismo", category="humor", cost=1, icon="self_joke",
     description="Se ríe de su propia torpeza. +1 confianza y amor.",
     effects={score=1, trust=1, chemistry=1}, contexts={conversation={score=1}},
     affinities={roxy={chemistry=1}}, conditions={}, unlockedAt=1},
    {id="be_honest", name="Hablar con honestidad", category="sincerity", cost=1, icon="be_honest",
     description="Comparte lo que realmente piensa. +1 confianza y amor.",
     effects={score=1, trust=1, chemistry=1}, contexts={investigation={score=1}},
     affinities={roxy={trust=1}}, conditions={}, unlockedAt=1},
    {id="admit_error", name="Reconocer un error", category="sincerity", cost=0, icon="admit_error",
     description="Asume su responsabilidad. +1 confianza; ayuda a revisar las runas.",
     effects={score=0, trust=1, chemistry=0}, contexts={investigation={score=1}},
     affinities={roxy={score=1}}, conditions={}, unlockedAt=1},
    {id="share_fear", name="Compartir un miedo", category="sincerity", cost=1, icon="share_fear",
     description="Se permite ser vulnerable. +1 confianza y amor.",
     effects={score=1, trust=1, chemistry=1}, contexts={conversation={score=1}},
     affinities={sylphiette={trust=1}}, conditions={}, unlockedAt=1},
    {id="propose_plan", name="Proponer un plan", category="initiative", cost=1, icon="propose_plan",
     description="Propone una solución compartida. +1 confianza; eficaz al investigar.",
     effects={score=1, trust=1, chemistry=0}, contexts={investigation={score=2},magic={score=1}},
     affinities={eris={chemistry=1}}, conditions={}, unlockedAt=1},
    {id="analyze_runes", name="Analizar runas", category="initiative", cost=1, icon="analyze_runes",
     description="Examina el flujo del maná. +3 avance al investigar, +2 en magia.",
     effects={score=1, trust=0, chemistry=0}, contexts={investigation={score=2},magic={score=1}},
     affinities={roxy={trust=1}}, conditions={}, unlockedAt=1},
    {id="earth_barrier", name="Barrera de Tierra", category="initiative", cost=2, icon="earth_barrier",
     description="Protege al grupo. +4 avance en magia; +1 confianza.",
     effects={score=1, trust=1, chemistry=0}, contexts={magic={score=3}},
     affinities={eris={trust=1}}, conditions={}, unlockedAt=1},
    {id="shared_magic", name="Magia Compartida", category="initiative", cost=2, icon="shared_magic",
     description="Sylphiette alimenta el artefacto de Rudy con energía externa. Requiere su compañía.",
     effects={score=3,trust=1,chemistry=2}, contexts={magic={score=2}}, affinities={},
     conditions={character="sylphiette"}, exclusive="sylphiette", unlockedAt=5},
    {id="combined_spell", name="Conjuro Combinado", category="initiative", cost=2, icon="combined_spell",
     description="Roxy y Rudy coordinan magia almacenada como iguales. Requiere su compañía.",
     effects={score=3,trust=1,chemistry=2}, contexts={magic={score=2}}, affinities={},
     conditions={character="roxy"}, exclusive="roxy", unlockedAt=5},
    {id="sword_magic", name="Espada y Magia", category="initiative", cost=2, icon="sword_magic",
     description="Eris abre un camino para Rudy. Requiere su compañía.",
     effects={score=3,trust=1,chemistry=2}, contexts={magic={score=2}}, affinities={},
     conditions={character="eris"}, exclusive="eris", unlockedAt=5},
    {id="choose_together", name="Elegir Juntos", category="sincerity", cost=0, icon="choose_together",
     description="Renuncia al futuro impuesto. Se desbloquea en el capítulo final.",
     effects={score=3,trust=1,chemistry=1}, contexts={}, affinities={}, conditions={}, unlockedAt=7},
}

-- Intenciones estables, frases adaptadas al interlocutor.
local extra={
 {id="subtle_flirt",name="Coqueteo sutil",category="sincerity",tone="flirty",cost=1,icon="subtle_flirt",
  description="Una muestra discreta de cariño. En una investigación urgente puede distraer.",
  effects={score=1,trust=0,chemistry=1},contexts={conversation={score=1},investigation={trust=-1}},
  affinities={eris={chemistry=1},roxy={trust=-1},nanahoshi={score=-2,trust=-3}},conditions={},unlockedAt=1},
 {id="happy_reply",name="Respuesta feliz",category="empathy",tone="happy",cost=1,icon="happy_reply",
  description="Celebra un logro compartido sin atribuírselo a Rudy.",effects={score=1,trust=1,chemistry=1},
  contexts={conversation={score=1}},affinities={sylphiette={chemistry=1}},conditions={},unlockedAt=2},
 {id="bold_reply",name="Respuesta atrevida",category="initiative",tone="bold",cost=1,icon="bold_reply",
  description="Propone un reto. Eris valora el impulso; Sylphy necesita un plan responsable.",
  effects={score=1,trust=0,chemistry=0},contexts={conversation={score=1}},
  affinities={eris={trust=2,chemistry=2},sylphiette={trust=-3,chemistry=-1},roxy={trust=-1}},conditions={},unlockedAt=2},
 {id="angry_reply",name="Respuesta enojada",category="sincerity",tone="angry",cost=0,icon="angry_reply",
  description="Descarga frustración. Daña la confianza y no resuelve la conversación.",
  effects={score=-1,trust=-4,chemistry=-2},contexts={},affinities={eris={trust=1}},conditions={},unlockedAt=4},
 {id="sincere_apology",name="Disculpa sincera",category="sincerity",tone="sincere",cost=1,icon="sincere_apology",
  description="Asume una equivocación. Reparar una promesa requiere también cumplirla.",
  effects={score=1,trust=2,chemistry=1},contexts={conversation={score=1}},affinities={sylphiette={trust=1}},conditions={},unlockedAt=4},
}
for _,card in ipairs(extra) do list[#list+1]=card end

-- Presentación solamente: estas etiquetas nunca sustituyen el ID o el nombre
-- narrativo. Diez caracteres caben a tamaño nativo en el marco de 80 píxeles.
local presentation = {
    subtle_flirt={shortName="COQUETEO"}, happy_reply={shortName="ALEGRÍA"},
    bold_reply={shortName="RETO"}, angry_reply={shortName="ENFADO"}, sincere_apology={shortName="PERDÓN"},
    listen={shortName="ESCUCHAR"},
    encourage={shortName="ÁNIMO"},
    remember={shortName="RECORDAR",unlockHint="Reunirse con las tres compañeras durante el día 2."},
    light_joke={shortName="BROMA"},
    change_subject={shortName="CAMBIAR"},
    self_joke={shortName="AUTOHUMOR",unlockHint="Completar la primera anomalía del día 1."},
    be_honest={shortName="HONESTIDAD"},
    admit_error={shortName="DISCULPA"},
    share_fear={shortName="MIEDO"},
    propose_plan={shortName="PLAN"},
    analyze_runes={shortName="RUNAS"},
    earth_barrier={shortName="BARRERA"},
    shared_magic={shortName="COMPARTIR",unlockHint="Misión familiar y compromiso con Sylphiette, día 5."},
    combined_spell={shortName="CONJURO",unlockHint="Investigación y compromiso con Roxy, día 5."},
    sword_magic={shortName="ESPADA",unlockHint="Entrenamiento conjunto y compromiso con Eris, día 5."},
    choose_together={shortName="JUNTOS",unlockHint="Resolver juntos los acuerdos del día 7."},
}
-- Los valores sociales y los IDs originales siguen intactos. Los efectos de
-- combate son otro contexto, con su propio coste y sin modificar relaciones.
local combat={
    propose_plan={cost=1,manaCost=0,effects={draw=1},description="Toma 1 carta del grimorio."},
    analyze_runes={cost=1,manaCost=1,effects={vulnerable=1},description="El enemigo recibe +2 daño por golpe hasta acabar tu turno."},
    earth_barrier={cost=1,manaCost=2,effects={shield=5},description="Gana 5 de escudo hasta tu próximo turno."},
    shared_magic={cost=1,manaCost=3,effects={damage=6,heal=4,shield=3},description="6 daño, 4 vida y 3 escudo. Requiere a Sylphiette."},
    combined_spell={cost=2,manaCost=4,effects={damage=12,weak=1},description="12 daño y debilita al enemigo. Requiere a Roxy."},
    sword_magic={cost=2,manaCost=2,effects={damage=13,shield=3},description="Eris ataca y Rudy cubre: 13 daño y 3 escudo. Requiere a Eris."},
}
local tones={listen="empathetic",encourage="empathetic",remember="empathetic",light_joke="funny",
 change_subject="evasive",self_joke="funny",be_honest="sincere",admit_error="sincere",share_fear="sincere",
 propose_plan="bold",analyze_runes="sincere",earth_barrier="empathetic",shared_magic="empathetic",
 combined_spell="sincere",sword_magic="bold",choose_together="sincere"}
local phrases={
 listen={default="Te escucho. Quiero entender qué necesitas.",roxy="Quiero escuchar tu interpretación, Roxy.",sylphiette="Cuéntame qué necesitas de mí en casa, Sylphy.",eris="Dime cómo quieres que te apoye, Eris.",nanahoshi="Primero escucharé tus instrucciones."},
 encourage={default="Confío en tu criterio. Hagámoslo juntos.",roxy="Tu análisis nos ayuda. Confío en lo que observaste.",sylphiette="No tienes que cargar con todo. Cuenta conmigo.",eris="Sé que puedes hacerlo. Cubriré tu retirada."},
 light_joke={default="Prometo que esta vez el plan tendrá menos accidentes.",roxy="Podríamos publicar mis errores como manual de lo que no hay que hacer.",sylphiette="Hoy intentaré lavar platos sin inventar vajilla de un solo uso.",eris="Mis piernas todavía recuerdan tu último entrenamiento.",nanahoshi="Al menos estas cartas no se quedan afónicas."},
 subtle_flirt={default="Estar contigo hace mejor este momento.",roxy="Me gusta estudiar contigo, Roxy.",sylphiette="Estar contigo hace que este lugar sea especial.",eris="Entrenar contigo siempre es emocionante.",nanahoshi="Con esa concentración, cuesta dejar de mirarte."},
 be_honest={default="No tengo todas las respuestas. Quiero que decidamos con lo que sabemos.",roxy="Tu opinión importa tanto como la mía.",sylphiette="Me preocupa descuidar nuestra casa. Quiero asumir mi parte.",eris="Necesito tu ayuda y respeto tu decisión.",nanahoshi="Estoy preocupado. Revisemos cada paso antes de actuar."},
 change_subject={default="Preferiría hablar de otra cosa por ahora."},
 happy_reply={default="¡Lo logramos juntos! Me alegra compartirlo contigo."},
 bold_reply={default="Aceptemos el reto. Estoy dispuesto a intentarlo contigo."},
 angry_reply={default="¡Estoy cansado de dar explicaciones! Déjame resolverlo solo."},
 sincere_apology={default="Lo que hice te hirió. Lo siento; quiero demostrar con hechos que lo entendí."},
 self_joke={default="Mi especialidad sigue siendo complicar las cosas sencillas."},
 remember={default="Recuerdo lo que acordamos. Sigue siendo importante para mí."},
 admit_error={default="Me equivoqué. Voy a asumir mi responsabilidad."},
 share_fear={default="Me asusta decepcionarte. No quiero que cargues con mis errores."},
 propose_plan={default="Comparemos las opciones y acordemos el siguiente paso."},
 analyze_runes={default="Revisemos juntos estas marcas antes de tocar el sello."},
 earth_barrier={default="Aseguremos una protección para todos antes de avanzar."},
 shared_magic={default="Sylphy, coordinemos la energía del artefacto con tu protección."},
 combined_spell={default="Roxy, seguiré tu cálculo para activar el encantamiento."},
 sword_magic={default="Eris, abrirás el camino y yo cubriré el flanco con el artefacto."},
 choose_together={default="Quiero que el futuro lo decidamos juntos, con nuestra propia voz."},
}
-- El mismo tono también cambia entre tareas con la misma persona.
phrases.listen.roxy_investigation="Explícame tu hipótesis; revisaré contigo las pruebas."
phrases.listen.sylphiette_investigation="Te escucho, Sylphy. Organicemos el trabajo y el regreso a casa."
phrases.listen.eris_investigation="Señala los riesgos que viste. Confío en tu experiencia."
phrases.light_joke.roxy_investigation="Si contamos mis notas torcidas como runas, ya tenemos demasiadas pistas."
phrases.subtle_flirt.roxy_investigation="Me gusta estudiar contigo, Roxy, incluso entre tantas notas."
phrases.subtle_flirt.sylphiette_investigation="Quiero terminar esto y compartir una tarde tranquila contigo."
phrases.be_honest.roxy_investigation="No estoy seguro de mi hipótesis. Revisemos primero la tuya."
phrases.be_honest.eris_investigation="No puedo afrontar este riesgo solo. Necesito tu criterio."
local acquisition={
 self_joke={event="first_anomaly",day=1,giver="nanahoshi"},
 remember={event="all_reunions",day=2,giver="companion"},
 happy_reply={event="all_reunions",day=2,giver="companion"},
 bold_reply={event="all_reunions",day=2,giver="companion"},
 admit_error={event="all_reunions",day=2,giver="companion"},
 share_fear={event="all_reunions",day=2,giver="companion"},
 propose_plan={event="ruins_mission",day=3,giver="companion"},
 analyze_runes={event="ruins_mission",day=3,giver="companion"},
 earth_barrier={event="ruins_mission",day=3,giver="companion"},
 angry_reply={event="seal_will",day=4,giver="cliff"},
 sincere_apology={event="seal_will",day=4,giver="cliff"},
 change_subject={event="seal_will",day=4,giver="cliff"},
 shared_magic={event="wife_card_sylphiette",day=5,giver="sylphiette"},
 combined_spell={event="wife_card_roxy",day=5,giver="roxy"},
 sword_magic={event="wife_card_eris",day=5,giver="eris"},
 choose_together={event="festival_choice",day=7,giver="nanahoshi"},
}
local byId = {}
local intentions={
 listen="Escucha a la otra persona antes de proponer una solución.",encourage="Ofrece apoyo; el compromiso deberá cumplirse después.",
 remember="Recuerda un detalle importante de la conversación.",light_joke="Bromea sobre la situación; puede herir en un momento delicado.",
 change_subject="Desvía la conversación; puede dejar un conflicto pendiente.",self_joke="Reconoce su torpeza con humor sin ridiculizar a su esposa.",
 be_honest="Explica lo que piensa y admite sus límites.",admit_error="Reconoce una equivocación concreta.",share_fear="Comparte una preocupación sin decidir por la otra persona.",
 propose_plan="Propone pasos que ambos puedan discutir.",analyze_runes="Pide revisar juntos el funcionamiento de las runas.",earth_barrier="Plantea una protección temporal y una salida segura.",
 shared_magic="Acuerda señales de coordinación con Sylphiette.",combined_spell="Contrasta un conjuro con Roxy como iguales.",sword_magic="Coordina espada y cobertura respetando el criterio de Eris.",
 choose_together="Defiende una decisión compartida en el desenlace.",subtle_flirt="Expresa cariño; no reemplaza escuchar un problema.",happy_reply="Celebra un avance compartido.",
 bold_reply="Propone un reto; su oportunidad depende de la situación.",angry_reply="Descarga frustración y puede agravar un conflicto.",sincere_apology="Asume responsabilidad; una disculpa no borra promesas incumplidas.",
}
local starterDeck={"listen","light_joke","be_honest","encourage","subtle_flirt"}
local starter={}; for _,id in ipairs(starterDeck) do starter[id]=true end
for _,card in ipairs(list) do
    local display=presentation[card.id]
    card.shortName=display.shortName
    card.tone=card.tone or tones[card.id]
    card.description=intentions[card.id]
    card.phrases=phrases[card.id]
    local source=acquisition[card.id] or {event="starter_gift",day=1,giver="nanahoshi"}
    card.unlockedAt=source.day
    card.unlockHint=display.unlockHint or (starter[card.id] and "Regalo de Orsted adaptado por Nanahoshi, día 1."
        or ({[2]="Visitar a las tres esposas, día 2.",[3]="Recuperar el fragmento en las ruinas, día 3.",[4]="Completar la investigación del emisario, día 4."})[source.day])
    card.unlockRequirements={event=source.event,day=source.day}
    card.giver=source.giver
    card.rewardMessage="¡Nueva carta obtenida: "..card.name.."!"
    card.combat=combat[card.id]
    card.encounterTypes={social=true,combat=card.combat~=nil}
    card.target_affinity=require("src.data.social_rules").affinities[card.id] or {}
    byId[card.id]=card
end
return {list=list,byId=byId,starterDeck=starterDeck,
 categories={empathy="Empatía",humor="Humor",sincerity="Sinceridad",initiative="Magia e iniciativa"},
 tones={empathetic="Empático",funny="Gracioso",happy="Feliz",flirty="Coqueto",bold="Atrevido",sincere="Sincero",angry="Enojado",evasive="Evasivo"}}
