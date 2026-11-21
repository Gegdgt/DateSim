-- Actividades ordinarias: cada ejecución cuesta un espacio, aunque se repita.
-- Las escenas de chapters tienen su propia regla narrativa y nunca usan este coste.
local list={
    {id="time_sylphiette",character="sylphiette",title="Tiempo con Sylphiette",background="home",cost=1,
        description="Compartir las tareas de casa o reservar un momento para escucharla.",
        choices={
            {id="together",label="Preparar juntos la casa",result="Repartís las tareas y dejáis tiempo para descansar juntos.",effects={love=2,trust=1}},
            {id="listen",label="Escuchar cómo estuvo su día",result="Sylphiette puede terminar de contar lo que le preocupaba. Te quedas a escuchar.",effects={love=1,trust=2}},
        }},
    {id="time_roxy",character="roxy",title="Tiempo con Roxy",background="library",cost=1,
        description="Una pausa entre libros para conversar o contrastar sus anotaciones.",
        choices={
            {id="together",label="Compartir una lectura",result="Elegís un relato y comparáis las partes que más os gustaron.",effects={love=2,trust=1}},
            {id="listen",label="Revisar juntos sus notas",result="Roxy explica una duda. Revisáis las anotaciones como iguales.",effects={love=1,trust=2}},
        }},
    {id="time_eris",character="eris",title="Tiempo con Eris",background="training",cost=1,
        description="Acompañarla durante una pausa o practicar coordinación sin un duelo.",
        choices={
            {id="together",label="Pasear después de la práctica",result="Eris baja la espada y camináis juntos antes de volver a casa.",effects={love=2,trust=1}},
            {id="listen",label="Practicar señales de apoyo",result="Acordáis cuándo avanzar y cuándo cubrir la retirada del otro.",effects={love=1,trust=2}},
        }},
}
local favors={
    {id="cliff_notes",character="cliff",title="Cliff: estudiar una técnica",delay=1,
        description="Entrega al cierre de mañana (hoy en el Día 7).",reward="Curación básica y +2 energía externa",
        effects={unlock={"heal"},externalEnergy=2}},
    {id="zanoba_artifact",character="zanoba",title="Zanoba: ajustar un artefacto",delay=0,
        description="Entrega al cerrar esta jornada.",reward="Defensa física y +2 energía externa",
        effects={unlock={"wind_guard"},externalEnergy=2}},
}
local catalog={list=list,byId={},favors=favors,favorsById={}}
for _,activity in ipairs(list) do catalog.byId[activity.id]=activity end
for _,favor in ipairs(favors) do catalog.favorsById[favor.id]=favor end
return catalog
