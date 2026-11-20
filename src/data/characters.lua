local list = {
    {id="rudeus",name="Rudeus Greyrat",shortName="Rudy",romance=false,color={0.73,0.55,0.33},description="Un mago adulto que aprende a elegir por sí mismo."},
    {id="sylphiette",name="Sylphiette",shortName="Sylphiette",romance=true,color={0.57,0.78,0.60},theme="Confianza y compañerismo",description="Escuchar y compartir las decisiones fortalece vuestro vínculo."},
    {id="roxy",name="Roxy Migurdia",shortName="Roxy",romance=true,color={0.48,0.63,0.88},theme="Admiración e igualdad",description="La honestidad permite encontrarse como iguales."},
    {id="eris",name="Eris Boreas Greyrat",shortName="Eris",romance=true,color={0.88,0.38,0.36},theme="Desafío y apoyo mutuo",description="Avanzar juntos requiere valor y apoyo, no competir por todo."},
    {id="nanahoshi",name="Nanahoshi",shortName="Nanahoshi",romance=false,color={0.56,0.60,0.67},description="Investiga el Espejo de las Posibilidades."},
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
