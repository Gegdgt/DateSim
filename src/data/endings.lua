local list={
 {id="family_united",title="La familia Greyrat unida",subtitle="FINAL 1 DE 5",background="festival",
  body="Sylphiette, Roxy y Eris eligen continuar sus matrimonios con Rudy. Rudy ha recuperado su voz y su magia; sus conflictos importantes fueron atendidos con trabajo, confianza y compromisos cumplidos. La mesa vuelve a tener cuatro voces distintas.",
  footer="Meses después, el calendario reúne tareas del hogar, investigación y relevos de viaje. Hay desacuerdos, disculpas y risas. La familia sigue unida porque sus cuatro integrantes la cuidan."},
 {id="roxy",title="Roxy",subtitle="FINAL 2 DE 5",background="library",
  body="Rudy y Roxy conservan su matrimonio y emprenden juntos la investigación acordada. Ella dirige parte del trabajo y comparte también sus dudas. Sylphiette y Eris cierran sus relaciones románticas con Rudy y siguen sus propios proyectos.",
  footer="En una mesa llena de notas, Roxy corrige un cálculo de Rudy. Él le pregunta cómo se siente antes de buscar otra respuesta en los libros. Su vida juntos continúa entre afecto, estudio y respeto mutuo."},
 {id="eris",title="Eris",subtitle="FINAL 3 DE 5",background="forest",
  body="Rudy conserva su matrimonio con Eris y la acompaña en la ruta de protección. Su magia sostiene el avance de una espadachina mucho más capaz que él. Sylphiette y Roxy se separan románticamente de Rudy sin renunciar a sus propias vidas.",
  footer="Al terminar una escolta, Eris pide descanso antes del siguiente tramo. Rudy prepara la barrera y la cena. Se protegen, discuten con franqueza y vuelven a ponerse en camino como compañeros."},
 {id="sylphiette",title="Sylphiette",subtitle="FINAL 4 DE 5",background="home",
  body="Rudy y Sylphiette mantienen su matrimonio en Sharia. El hogar se reconstruye mediante responsabilidades compartidas y decisiones tomadas entre ambos. Roxy y Eris cierran sus matrimonios y emprenden los caminos que habían elegido.",
  footer="Sylphiette revisa una barrera mientras Rudy organiza las tareas de la tarde. Su calma no nace de ignorar el peligro, sino de saber que ambos pueden pedir ayuda y participar en lo que les afecta."},
 {id="solitary",title="El camino solitario",subtitle="FINAL 5 DE 5",background="courtyard",
  body="Los tres matrimonios terminan. Recuperar su voz no reparó promesas rotas, conflictos ignorados ni decisiones tomadas por las demás. Rudy acepta las separaciones y las responsabilidades que siguen existiendo después de ellas.",
  footer="Comienza por cumplir acuerdos pequeños sin esperar amor como recompensa. Sus errores no desaparecen, pero tampoco deciden todo su futuro. Aprender a cuidar a otros será una tarea diaria, aunque ahora camine solo."},
}
local byId={}
for _,ending in ipairs(list) do byId[ending.id]=ending end
return {list=list,byId=byId}
