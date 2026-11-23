-- Los eventos pertenecen a los capítulos; este catálogo sólo los observa.
local Chapters=require("src.data.chapters")
local D={list={},byId={},byDay={}}
local lab={map="laboratorio_nanahoshi",x=312,y=240,label="Laboratorio de Nanahoshi"}
local home={map="casa_segundo_piso",label="Dormitorios de la casa"}
local function add(day,id,title,kind,event,extra)
    local o={id="day"..day.."_"..id,day=day,title=title,description="",type=kind,
        required=true,requiredProgress=1,event=event,unlock={},dependencies={},destination=lab,order=#D.list+1}
    for k,v in pairs(extra or {}) do o[k]=v end
    D.list[#D.list+1]=o;D.byId[o.id]=o;D.byDay[day]=D.byDay[day] or {};table.insert(D.byDay[day],o)
    return o.id
end
local letter=add(1,"letter","Ve al estudio de Rudy y busca la carta misteriosa.","main","hitogami_letter_read",{
    completedTitle="Leer la carta misteriosa",description="Examina el documento sobre el escritorio y lee hasta la firma —H.",
    destination={map="estudio_rudy",x=176,y=116,label="Estudio de Rudy"}})
local nano=add(1,"nanahoshi","Busca a Nanahoshi en su laboratorio.","main","nanahoshi_conversation_started",{
    dependencies={letter},unlock={event="mana_discovered"},description="Habla con ella para pedir ayuda; entrar al laboratorio no basta."})
local cards=add(1,"cards","Obtén las cartas encantadas de Nanahoshi.","main","starter_gift",{
    dependencies={nano},description="Recibe cinco cartas sociales y cinco físicas; la entrega se registra una sola vez."})
local tutorial=add(1,"tutorial","Aprende a utilizar las cartas sociales y de combate.","main","combat_tutorial_completed",{
    dependencies={cards},complete={all={{event="tutorial_completed"},{event="combat_tutorial_completed"}}},
    description="Finaliza la práctica social y vence la anomalía del tutorial.",
    blockedMessage="Debes completar el tutorial de cartas antes de descansar."})
add(1,"story","Termina la conversación de regreso a casa.","main","day1_complete",{
    dependencies={tutorial},description="Escucha el cierre después de contener la anomalía."})

-- Los cierres son los completionEvent reales, después de instalar las rutas.
local stories={
    [2]={"Completa los acontecimientos principales del día.","Consulta a Nanahoshi y sigue las escenas de compromisos y del bosque. Las escenas narrativas no consumen interacciones."},
    [3]={"Investiga el bosque y las ruinas con Nanahoshi.","Sigue la expedición hasta recuperar el fragmento y concluir los acontecimientos de hoy."},
    [4]={"Avanza en la investigación de la maldición.","Consulta a Nanahoshi, sigue al emisario e investiga el observatorio."},
    [5]={"Completa los acuerdos y eventos importantes de hoy.","Consulta a Nanahoshi y resuelve las misiones personales disponibles. Las separaciones se respetan."},
    [6]={"Resuelve los acontecimientos principales con Nanahoshi.","Sigue el registro del emisario y regresa para preparar la última jornada."},
}
for day=2,6 do
    add(day,"story",stories[day][1],"main",Chapters.byId["day"..day].daily.completionEvent,{description=stories[day][2]})
end
add(3,"fragment","Recupera el fragmento de las ruinas.","research","ruins_mission",{unlock={event="day3_companion_selected"}})
add(3,"truth","Investiga el Sello de la Verdad.","research","seal_truth",{dependencies={"day3_fragment"}})
add(4,"potion","Sigue la pista de la poción.","research","potion_memory",{unlock={event="resolved_day4_nanahoshi_research"}})
add(4,"seal","Completa la investigación del observatorio.","research","seal_will",{dependencies={"day4_potion"}})
add(6,"emissary","Completa el encuentro con el emisario.","combat","emissary_investigation_completed",{
    unlock={event="rudy_reflection_defeated"},complete={any={{event="emissary_investigation_completed"},{event="antidote_obtained"}}}})
add(6,"antidote_clue","Registra el descubrimiento sobre el antídoto.","research","antidote_holder_revealed",{
    dependencies={"day6_emissary"},complete={any={{event="antidote_holder_revealed"},{event="antidote_obtained"}}}})
add(6,"orsted","Acepta la demostración de Orsted si deseas practicar.","special","orsted_demonstration_completed",{
    required=false,unlock={all={{event="eris_five_training_days"},{event="antidote_holder_revealed"}}},
    description="Opcional. Puedes declinar la invitación y continuar hacia el descanso."})

add(7,"prepare","Prepárate para Badigadi con Nanahoshi.","main","day7_companion_selected",{
    complete={any={{event="day7_companion_selected"},{event="antidote_obtained"}}},
    description="Revisa cartas y habilidades antes de elegir compañía o viajar solo."})
add(7,"antidote","Consigue el antídoto.","combat","antidote_obtained",{dependencies={"day7_prepare"}})
add(7,"voice","Recupera tu voz y tu maná.","main","choice_day7_intro",{dependencies={"day7_antidote"}})
add(7,"relationships","Resuelve los acuerdos matrimoniales.","main","relationships_resolved",{
    dependencies={"day7_voice"},description="Escucha las decisiones de quienes siguen a tu lado y respeta las separaciones."})
add(7,"return_cards","Devuelve las cartas a Nanahoshi.","main","enchanted_cards_returned",{dependencies={"day7_relationships"}})
add(7,"ending","Alcanza un final y consulta el resumen de la semana.","main","campaign_complete",{dependencies={"day7_return_cards"}})

for day=1,7 do
    local deps=day==1 and {tutorial} or {}
    add(day,"interactions","Realiza tres interacciones durante el día.","daily","activity_completed",{
        source="interactions",requiredProgress=3,required=day<7,dependencies=deps,
        destination={map="casa_planta_baja",label="Esposas o taller de Cliff y Zanoba"},
        description=day==7 and "Opcionales antes del desafío final; las disponibles no se acumulan." or "Cualquier distribución es válida. Los saludos gratuitos no cuentan."})
    for _,wife in ipairs({{"sylphiette","Sylphie"},{"roxy","Roxy"},{"eris","Eris"}}) do
        add(day,"visit_"..wife[1],"Interactuar con "..wife[2]..".","daily","activity_completed",{
            source="wife",wife=wife[1],required=false,dependencies=deps,destination=false,
            description="Visita recomendada, sin límite por esposa. Dormir juntos no cuenta como visita diurna."})
    end
    add(day,"commissions","Consulta los encargos opcionales.","side","day"..day.."_commissions_consulted",{
        required=false,dependencies=deps,destination={map="taller_cliff_zanoba",x=224,y=180,label="Taller de Cliff y Zanoba"},
        description="Puedes consultar costes y entregas sin gastar una interacción."})
    if day<7 then
        add(day,"rest","Regresa a casa y descansa con una de tus esposas.","rest","day"..day.."_rest",{
            dependencies={"day"..day.."_interactions"},destination=home,
            description="También puedes dormir solo en el jergón. Primero termina los requisitos de historia."})
    end
end
-- El cierre del capítulo acredita sus hitos internos, también en partidas antiguas.
-- Nunca se usa para omitir los tutoriales del prólogo.
for _,o in ipairs(D.list) do
    if o.day>=2 and o.day<=6 and o.required and (o.type=="research" or o.type=="combat") then
        o.complete={any={o.complete or {event=o.event},{event=Chapters.byId["day"..o.day].daily.completionEvent}}}
    end
end
return D
