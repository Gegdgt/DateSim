-- Inserta las agendas sin duplicar ni reescribir las escenas de los capítulos.
local Cycle={}
function Cycle.install(list)
    for _,chapter in ipairs(list) do
        local day=chapter.day
        local agenda="day"..day.."_agenda"
        local summary=day==1 and "day1_summary" or day==2 and "phase_complete" or day==7 and "day7_summary" or "day"..day.."_complete"
        local story=day==1 and "day1_close" or chapter.initial
        chapter.daily={agenda=agenda,summary=summary,story=story,completionEvent=chapter.completionEvent,
            lockBeforeStory=day==7}
        if day==1 then
            chapter.summaries[summary]={title="EL PRIMER DÍA",subtitle="DÍA 1 COMPLETADO",background="home",body="Las cartas permiten seguir adelante. La agenda conserva cómo empleaste el tiempo de hoy."}
            chapter.transitions[summary]={{to="day2_agenda"}}
            chapter.transitions.day1_result[1].to="day1_close"
            chapter.transitions.day1_close[1].to=agenda
        elseif day==7 then
            chapter.summaries[summary]={title="LA ÚLTIMA JORNADA",subtitle="DÍA 7 COMPLETADO",background="home",body="La voz ha regresado. Las decisiones y los acuerdos de la familia quedan registrados.",continueLabel="Ver epílogo"}
            chapter.transitions[summary]={{to="campaign_complete"}}
            chapter.initial=agenda
        else
            chapter.initial=agenda
        end
        -- Las salidas narrativas regresan a la agenda. Dormir abre el resumen.
        for from,transitions in pairs(chapter.transitions) do
            if from~=summary then
                for _,transition in ipairs(transitions) do
                    if transition.to==summary or (day==7 and transition.to=="campaign_complete") then transition.to=agenda end
                end
            end
        end
        chapter.hubs[agenda]={title="DÍA "..day.." / AGENDA",background="home",agenda=true,locations={}}
        chapter.transitions[agenda]={{to=summary,requires={event=chapter.completionEvent}},{to=story}}
    end
    -- Las entradas entre capítulos apuntan a sus agendas, excepto el prólogo.
    for _,chapter in ipairs(list) do
        if chapter.day<7 then
            for _,transition in ipairs(chapter.transitions[chapter.daily.summary]) do
                transition.to=list[chapter.day+1].daily.agenda
            end
        end
        for _,group in ipairs({"scenes","encounters","hubs","summaries"}) do
            for _,definition in pairs(chapter[group] or {}) do
                definition.interactionRule="narrative"
                definition.interactionCost=0
            end
        end
    end
end
return Cycle
