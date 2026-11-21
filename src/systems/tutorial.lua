-- Guía persistente: los pasos de acción solo avanzan al recibir una acción real.
-- La demostración de energía cero usa una copia de consulta, nunca altera la partida.
local Cards=require("src.systems.cards")
local Tutorial={}
local stages={hand=0,energy=0,select=0,ready=0,result=1,draw=1,second=1,
    second_result=2,free_demo=2,free=2,summary=3,complete=3}
Tutorial.instructions={
    hand={step=1,title="MAZO Y MANO",text="Nanahoshi: recibes 5 cartas sociales y robas 3 a tu mano. Su magia almacenada reproduce tu voz. Verde: Empatía; naranja: Humor; azul: Sinceridad; violeta: Magia e iniciativa. Cada color indica una intención.",button="Ver la energía"},
    energy={step=2,title="ENERGÍA SOCIAL",text="Tienes 4 de energía para 3 acciones sociales. El coste se paga al jugar; no recuperas energía. La energía permite actuar, no es vida. En combate se recarga a 3 cada turno.",button="Elegir una carta"},
    select={step=3,title="PRIMERO, CONSULTA LA CARTA",text="Selecciona una carta con clic, 1/2/3 o flechas. Lee su nombre completo, coste y efecto a la derecha. Después confirma con Enter o Jugar."},
    ready={step=3,title="DECIDE CON EL CONTEXTO",text="Nanahoshi: amor mide cercanía; confianza, seguridad en tus actos. Una broma en mal momento puede reducirlos. Aquí prueba una respuesta: necesito que acordemos cómo investigar."},
    result={step=5,title="LEE LO QUE OCURRIÓ",text="Nanahoshi: has reproducido la voz con magia almacenada, sin gastar tu maná. Mira mi reacción. No soy una relación romántica; tus esposas sí valoran el tono y el contexto.",button="Ver el robo"},
    draw={step=6,title="DESCARTA Y ROBA",text="La carta usada fue al descarte. Has robado otra del mazo y vuelves a tener 3. El robo no cuesta energía. Ahora juega tu segundo turno.",button="Jugar el segundo turno"},
    second={step=6,title="PONLO EN PRÁCTICA",text="Selecciona otra carta y confirma su uso. Compara categorías y contexto. Una carta barata también puede ser útil."},
    second_result={step=6,title="SEGUNDA ACCIÓN",text="El registro conserva ambos resultados. La energía restante depende de lo que pagaste. Falta un turno: aprenderás la acción gratuita.",button="Aprender la acción gratuita"},
    free_demo={step=7,title="EJEMPLO: SIN ENERGÍA",text="Probemos en una simulación: Escuchar cuesta 1. Con 0 energía no puede jugarse. Tu energía real NO cambia. Comprueba el coste para continuar.",button="Probar carta con 0 energía"},
    free={step=7,title="TOMAR UN RESPIRO",text="Sin energía puedes usar cartas de coste 0 o Tomar un respiro [P]. El respiro gasta un turno, no roba ni descarta. Úsalo ahora para cerrar la práctica."},
    summary={step=8,title="EL RESULTADO SOCIAL",text="Al alcanzar la meta: ENCUENTRO EXITOSO. Si falta avance: ENCUENTRO DESFAVORABLE. Cambian la respuesta y los vínculos, pero la historia sigue. Tu voz y maná siguen sellados. Continúa para practicar ataques físicos, vida y escudo."},
    complete={step=8,title="PRÁCTICA COMPLETADA",text="Ya puedes continuar la historia."},
}
function Tutorial.restore(value,enc)
    local count=enc and #enc.log or 0
    local stage=type(value)=="table" and value.stage
    if stage=="complete" or stages[stage]~=count then stage=({[0]="hand",[1]="result",[2]="second_result",[3]="summary"})[count] or "hand" end
    return {stage=stage}
end
function Tutorial.instruction(state) return Tutorial.instructions[state.stage] end
function Tutorial.select(state)
    if state.stage=="select" then state.stage="ready"; return true end
end
function Tutorial.canAct(state,index)
    if not state then return true end
    if index then return state.stage=="ready" or state.stage=="second" end
    return state.stage=="free"
end
function Tutorial.action(state,enc)
    state.stage=({[1]="result",[2]="second_result",[3]="summary"})[#enc.log]
end
function Tutorial.advance(state)
    local nextStage={hand="energy",energy="select",result="draw",draw="second",second_result="free_demo"}
    if nextStage[state.stage] then state.stage=nextStage[state.stage]; return true end
    if state.stage=="free_demo" then
        local allowed=Cards.canPlay({hand={"listen"},context={kind="conversation",character="nanahoshi"},energy=0,finished=false},1)
        if not allowed then state.stage="free"; return true end
    end
    return false
end
function Tutorial.complete(session,options)
    if not session.tutorial or session.tutorial.stage~="summary" or not session.encounter or not session.encounter.finished then return false end
    session.tutorial.stage="complete"
    require("src.systems.events").mark(session,"tutorial_completed")
    options.tutorialCompleted=true
    return true
end
function Tutorial.skip(session,options)
    if not options.tutorialCompleted and not session.events.tutorial_completed then return false end
    session.tutorial=nil
    require("src.systems.events").mark(session,"tutorial_completed")
    return true
end
return Tutorial
