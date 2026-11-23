-- Conversaciones completas, escritas por situación. Nunca se ensamblan frases.
local bank={list={},byId={},byWife={eris={},roxy={},sylphiette={}}}
function bank.answer(card,rudy,reply,love,trust,expression,effects)
    return {id=card,label=rudy,rudy=rudy,reply=reply,result=reply,
        expression=expression or "happy",animation=love<0 and "shake" or "nod",
        effects=effects or {},love=love,trust=trust}
end
function bank.add(wife,id,title,intro,question,emotion,reward,effects,answers,options)
    local d=options or {};d.id=id;d.character=wife;d.title=title;d.intro=intro
    d.question=question;d.emotion=emotion;d.description=intro;d.reward=reward;d.effects=effects
    d.cost=1;d.goldCost=d.goldCost or 0;d.wifeActivity=true;d.choices=answers;d.responses={}
    d.background=d.background or ({eris="training",roxy="library",sylphiette="home"})[wife]
    for _,a in ipairs(answers) do d.responses[a.id]=a end
    bank.list[#bank.list+1]=d;bank.byId[id]=d;table.insert(bank.byWife[wife],d)
end
require("src.data.wife_activities_eris")(bank)
require("src.data.wife_activities_roxy")(bank)
require("src.data.wife_activities_sylphie")(bank)
for id,lines in pairs(require("src.data.activity_conversations")) do
 local d=assert(bank.byId[id]);d.offer=lines[1];d.moments={lines[2],lines[3]}
 d.closing=lines[4] or d.continuation or d.intro
end
-- Tres intenciones que muestran por qué el contexto importa durante el entrenamiento.
bank.byId.E01.responses.light_joke.rudy="¿Quieres que me deje ganar?"
bank.byId.E01.responses.light_joke.reply="¡No me insultes! ¡Quiero que pelees en serio!"
bank.byId.E01.responses.light_joke.love=-2;bank.byId.E01.responses.light_joke.trust=-2
bank.byId.E01.responses.light_joke.expression="angry"
local erisEncourage=bank.answer("encourage","Claro. Entrenemos juntos y veamos cuánto hemos mejorado.","¡Eso quería escuchar! Ponte a mi lado.",2,2)
local erisFlirt=bank.answer("subtle_flirt","De acuerdo, pero si gano quiero un beso.","¡Solo si consigues vencerme!",2,1)
for _,response in ipairs({erisEncourage,erisFlirt}) do
 table.insert(bank.byId.E01.choices,response);bank.byId.E01.responses[response.id]=response
end
bank.byId.E01.responses.be_honest.after={light_joke={rudy="La broma estuvo fuera de lugar. Quiero entrenar en serio contigo.",reply="Entonces demuestra que lo dices en serio. Volvamos a la guardia.",love=1,trust=2}}
bank.byId.E01.responses.encourage.after={light_joke={rudy="Tienes razón. Voy a dar lo mejor de mí en esta serie.",reply="Bien. Eso sí merece que sigamos entrenando.",love=1,trust=1}}
bank.byId.E01.repairQuestion="¿Vas a tomarte en serio el entrenamiento conmigo?"
bank.byId.S15.responses.listen.after={light_joke={
 rudy="Quiero escucharte, Sylphie. ¿Podemos volver a leer las promesas?",
 reply="Acabo de explicártelas y has hecho una broma. Ahora necesito que asumas lo pendiente.",
 love=-1,trust=-1,expression="worried"}}
bank.byId.S15.responses.be_honest.after={light_joke={
 rudy="He hecho una broma para evitarlo. El recado sigue siendo responsabilidad mía.",
 reply="Eso sí responde a lo que te estoy diciendo. La lista seguirá aquí hasta que lo hagas.",
 love=1,trust=2,expression="worried"}}
-- La expedición secundaria utiliza los conocimientos del fragmento principal.
bank.byId.E04.requiredEvent="ruins_mission"
bank.byId.E04.requirementLabel="Recupera el primer fragmento durante la historia del Día 3."
bank.byId.E04.effects.copies={earth_wall=1}
bank.byId.E04.reward="22 oro, fragmento, pista; Barrera reforzada si está desbloqueada."
bank.byId.S10.maxDay=6 -- La promesa exige disponer del día siguiente para cumplirla.
require("src.data.wife_starter_responses")(bank)
table.sort(bank.list,function(a,b)return a.id<b.id end)
for _,list in pairs(bank.byWife) do table.sort(list,function(a,b)return a.id<b.id end) end
return bank
