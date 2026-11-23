local function choice(id,label,result,love,trust,effects)
 effects=effects or {};effects.love=love;effects.trust=trust
 return {id=id,label=label,result=result,effects=effects}
end
local list={
 {id="time_sylphiette",character="sylphiette",title="Ayudar en el hogar",background="home",description="Repartir las tareas permite que Sylphiette también descanse.",reward="12 oro; empatía y sinceridad",choices={
  choice("together","Preparar juntos la casa","Termináis las barreras y recogéis la mesa. Sylphiette puede sentarse antes de que se enfríe el té.",3,2,{gold=12,copies={listen=1},familyProgress={household=1}}),
  choice("listen","Escuchar cómo estuvo su día","Anotas lo que falta y asumes una tarea concreta para mañana.",2,3,{gold=10,copies={be_honest=1},familyProgress={household=1}})}},
 {id="time_roxy",character="roxy",title="Estudiar magia",background="library",description="Comprobar una fórmula juntos, sin tratar a Roxy como una maestra infalible.",reward="Magia; materiales; investigación",choices={
  choice("together","Comparar las fórmulas","Roxy corrige una runa y tú detectas otra. El experimento lleva ambos nombres.",3,2,{copies={water_projectile=1},items={magic_material=1},familyProgress={research=1}}),
  choice("listen","Revisar juntos sus notas","Escuchas su hipótesis antes de probarla. La muestra confirma lo que faltaba.",2,3,{gold=8,copies={analyze_runes=1},familyProgress={research=1}})}},
 {id="time_eris",character="eris",title="Entrenamiento compartido",background="training",description="Acordar señales de ataque y retirada. La coordinación exige escuchar a ambos.",reward="Ofensiva; coordinación; 14 oro",choices={
  choice("together","Practicar relevos","Eris abre espacio y tú cubres la retirada. Ninguno decide por el otro.",3,2,{gold=14,copies={coordinated_attack=1},familyProgress={coordination=1}}),
  choice("listen","Practicar señales de apoyo","Repetís la señal hasta reconocerla sin hablar. Eris aprueba con una sonrisa.",2,3,{gold=12,copies={staff_strike=2},familyProgress={coordination=1}})}},
 {id="eris_physical",character="eris",title="Entrenamiento físico",background="training",description="Ataques, bloqueos y desplazamientos frente a un blanco encantado. Se juega un combate real.",reward="Hasta 28 oro; 3 Bastón; entrenamiento",battle="practice",choices={choice("practice","Comenzar la práctica","Eris observa tu postura y tus bloqueos.",0,0)}},
 {id="eris_monsters",character="eris",title="Combatir monstruos",background="forest",description="Acordar una ruta con Eris y enfrentar una bestia. Puedes salir solo o junto a ella.",reward="Hasta 40 oro; cartas; materiales",battle="monsters",choices={choice("together","Salir junto a Eris","Revisáis las señales antes de entrar al bosque.",0,0),choice("solo","Salir solo con la ruta acordada","Eris comprueba la ruta y espera tu informe al regreso.",0,0)}},
 {id="eris_duel",character="eris",title="Duelo amistoso",background="training",description="Eris evaluará ataques, defensa y esfuerzo reales. Perder con honor también tiene valor.",reward="Hasta 32 oro; ofensiva; desempeño real",battle="duel",choices={choice("duel","Aceptar el duelo","Eris apunta la espada al suelo. La práctica no será letal.",0,0)}},
 {id="sylphiette_errands",character="sylphiette",title="Encargos familiares",background="home",description="Tu hija espera ayuda con sus recados. Sylphiette necesita que el compromiso llegue hasta el final.",reward="18 oro; sinceridad; compromiso",choices={
  choice("shopping","Comprar lo que vuestra hija pidió","Comprobáis la lista y lleváis las compras juntos. Tu hija elige el cuento para la tarde.",3,2,{gold=18,copies={be_honest=1},familyProgress={family_errands=1}}),
  choice("prepare","Preparar la tarde familiar","Dejas lista la merienda y organizas los recados para que nadie tenga que marcharse a mitad.",2,3,{gold=12,copies={remember=1},familyProgress={family_errands=1}})}},
 {id="sylphiette_zenith",character="sylphiette",title="Cuidar a Zenith",background="home",description="Acompañar a Zenith, cuidar su comodidad y mantener una rutina digna.",reward="Empatía; cuidado; confianza",choices={
  choice("garden","Acompañarla al jardín","Caminas al ritmo de Zenith y te sientas a su lado. Sylphiette puede descansar sabiendo que no está sola.",3,3,{copies={listen=2},familyProgress={zenith_care=1}}),
  choice("routine","Preparar sus cuidados","Repasas la rutina con Sylphiette, sin hablar de Zenith como si no estuviera presente.",2,4,{copies={remember=1},familyProgress={zenith_care=1}})}},
 {id="sylphiette_lilia",character="sylphiette",title="Ayudar a Lilia",background="home",description="Compartir trabajo doméstico real. Lilia no debería perseguirte para que cumplas.",reward="16 oro; sinceridad; tareas cumplidas",choices={
  choice("repair","Reparar y ordenar la despensa","Lilia revisa el arreglo y te entrega el siguiente estante. No has terminado hasta dejarlo limpio.",2,3,{gold=16,copies={admit_error=1},familyProgress={lilia_help=1}}),
  choice("supplies","Organizar las provisiones","Anotas las existencias con Lilia y dejas una lista clara para el próximo turno de compras.",3,2,{gold=12,copies={propose_plan=1},familyProgress={lilia_help=1}})}},
 {id="sylphiette_talk",character="sylphiette",title="Conversación familiar",background="home",description="Escuchar a la familia y comprometerse con una acción verificable.",reward="Cartas sociales; promesas; apoyo",choices={
  choice("promise","Asumir el próximo recado","Sylphiette acepta el compromiso. Lo importante será cumplirlo, no decirlo de una forma bonita.",2,3,{copies={encourage=1},promise={id="family_errand",status="pending"},familyProgress={family_talk=1}}),
  choice("listen","Escuchar sin interrumpir","Dejas las cartas sobre la mesa y escuchas hasta el final. Después escribís un acuerdo entre los dos.",3,2,{copies={share_fear=1},familyProgress={family_talk=1}})}},
 {id="roxy_cards",character="roxy",title="Cartas encantadas",background="library",description="Roxy revisa las runas de Nanahoshi. La receta ahorra oro en una mejora, sin eliminar su coste.",reward="Receta: 20% en una mejora; materiales",choices={
  choice("recipe","Preparar una receta de mejora","Separáis el catalizador estable. Servirá para una mejora; después habrá que preparar otra muestra.",2,3,{discount=1,copies={analyze_runes=1},familyProgress={enchantments=1}}),
  choice("materials","Recuperar materiales útiles","Roxy descarta los restos inestables. Conserváis dos muestras seguras.",3,2,{items={magic_material=2},familyProgress={enchantments=1}})}},
 {id="roxy_books",character="roxy",title="Comprar libros",background="library",description="Roxy te acompaña a la librería. Los libros cuestan oro y se adquieren una sola vez.",reward="Habilidades, cartas o recetas",books=true,choices={choice("browse","Conversar sobre el catálogo","Comentáis los títulos y decidís esperar antes de gastar. También es útil elegir con cuidado.",1,2,{familyProgress={research=1}})}},
 {id="roxy_research",character="roxy",title="Investigación conjunta",background="laboratory",description="Contrastar resultados como colegas. Cada sesión deja un registro para desafíos mayores.",reward="Investigación; magia; habilidades conjuntas",choices={
  choice("test","Probar una hipótesis juntos","Roxy contiene el flujo mientras tú ajustas la runa. Ambos anotáis el error antes del resultado.",3,3,{copies={magic_bolt=1},items={magic_material=1},familyProgress={research=1}}),
  choice("review","Revisar el experimento anterior","Reconocéis qué no funcionó. Roxy propone repetirlo con una variable menos.",2,4,{gold=10,copies={quick_study=1},familyProgress={research=1}})}},
}
for _,id in ipairs({"sylphiette","roxy","eris"}) do
 list[#list+1]={id="reconcile_"..id,character=id,title="Reparar un compromiso",background="home",description="Reconocer el daño y cumplir una responsabilidad concreta. No revierte una separación definitiva.",reward="Recuperación: hasta +8 amor y +8 confianza",recovery=true,choices={choice("repair","Escuchar y reparar con hechos","Rudy reconoce el daño sin exigir perdón. Cumple la tarea acordada y deja espacio para volver a hablar.",8,8,{recovery=true,reconcile="daily_neglect",familyProgress={reconciliation=1}})}}
end
list[#list+1]={id="roxy_supplies",character="roxy",title="Comprar materiales",background="library",shop=true,
 description="Roxy compara contigo materiales y patrones. Reservar la visita no incluye ninguna compra.",reward="Comercio; inventario; estudio compartido",
 choices={choice("browse","Comparar precios y volver","Revisáis los precios y decidís esperar. No se compra ni se entrega ningún objeto.",1,2,{})}}
for _,activity in ipairs(list) do activity.cost=1 end
return list
