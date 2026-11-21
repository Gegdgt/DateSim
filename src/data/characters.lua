local list = {
    {id="rudeus",name="Rudeus Greyrat",shortName="Rudy",romance=false,color={0.73,0.55,0.33},description="Mago adulto, esposo de Sylphiette, Roxy y Eris. Domina agua y tierra; sus decisiones deben cuidar una familia que ya existe."},
    {id="sylphiette",name="Sylphiette",shortName="Sylphiette",romance=true,color={0.57,0.78,0.60},theme="Estabilidad y apoyo mutuo",description="Esposa de Rudy y maga capaz. Busca seguridad emocional, responsabilidades compartidas y participar en las decisiones. Apoya, protege y cura en combate."},
    {id="roxy",name="Roxy Migurdia",shortName="Roxy",romance=true,color={0.48,0.63,0.88},theme="Cercanía e igualdad",description="Esposa de Rudy, maga e investigadora experimentada. Quiere ser escuchada como persona, sin idolatría. Aporta análisis, control y magia ofensiva."},
    {id="eris",name="Eris Boreas Greyrat",shortName="Eris",romance=true,color={0.88,0.38,0.36},theme="Igualdad y protección compartida",description="Esposa de Rudy y espadachina extraordinaria. Valora la lealtad, la franqueza y el respeto a su criterio. Su fuerza supera la espada de Rudy; puede atacar e interrumpir."},
    {id="nanahoshi",name="Nanahoshi",shortName="Nanahoshi",romance=false,color={0.56,0.60,0.67},description="Investigadora pragmática. Adapta las cartas que le regaló Orsted para prestar su voz a Rudy."},
    {id="hitogami",name="Hitogami",shortName="Hitogami",romance=false,color={.9,.9,.85},description="Dios Humano. Manipula a Rudy mediante una maldición y consejos ambiguos; no es un enemigo físico."},
    {id="orsted",name="Orsted",shortName="Orsted",romance=false,color={.7,.75,.8},description="Aliado de la investigación y creador del regalo de cartas que conserva Nanahoshi."},
    {id="emisario",name="Emisario",shortName="Emisario",romance=false,color={.6,.5,.65},description="Personaje original que entregó la poción siguiendo las indicaciones de Hitogami."},
    {id="badigadi",name="Badigadi",shortName="Badigadi",romance=false,color={.6,.4,.75},description="Rey inmortal de seis brazos. Guarda el antídoto por una promesa y acepta un desafío honorable."},
    {id="zanoba",name="Zanoba",shortName="Zanoba",romance=false,color={0.77,0.66,0.46},description="Busca pistas en el oficio de los antiguos artesanos."},
    {id="cliff",name="Cliff",shortName="Cliff",romance=false,color={0.58,0.69,0.56},description="Estudia cómo contener la anomalía mágica."},
}
local byId = {}
for _, character in ipairs(list) do byId[character.id]=character end
return {
    list=list, byId=byId, romanceIds={"sylphiette","roxy","eris"},
    spriteWidth=64, spriteHeight=64, expressionCount=4,
    expressions={neutral=0,happy=1,worried=2,angry=3},
}
