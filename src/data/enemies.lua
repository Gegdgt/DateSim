-- Amenazas locales y del espejo. Su derrota jamás mata físicamente a Hitogami.
local function attack(id,name,damage,extra)
    local a={id=id,name=name,kind="attack",damage=damage}
    for k,v in pairs(extra or {}) do a[k]=v end
    return a
end
local list={
    {id="eris_training",name="Eris · duelo de entrenamiento",character="eris",portrait="eris",maxHp=42,weakness="earth",shape="guardian",
        training=true,trainingId="eris",nonlethal=true,actions={
            attack("training_cut","Toque de espada",6),
            {id="training_guard",name="Guardia de espadachina",kind="shield",shield=5},
            {id="training_prepare",name="Medir la distancia",kind="prepare",nextDamage=10},
            attack("training_lunge","Estocada controlada",10),
        },reward={text="El entrenamiento termina sin heridas. Eris valora cómo luchó Rudy.",event="eris_training_completed"},
        defeatText="Eris baja la espada de práctica. Rudy ha ganado el ejercicio con sus recursos y decisiones; ambos están ilesos."},
    {id="badigadi_final",name="Badigadi · rey inmortal",portrait="badigadi",maxHp=72,weakness="water",shape="guardian",boss=true,sealMax=12,actions={
        attack("royal_punch","Puño del rey inmortal",7),{id="royal_laugh",name="Carcajada de desafío",kind="prepare",nextDamage=10},attack("royal_charge","Embestida orgullosa",10)},
        defeatText="Badigadi acepta la derrota entre carcajadas. El sello cede y entrega el antídoto según su promesa; el rey inmortal sigue vivo."},
    {id="emissary_guard",name="Protector del emisario",portrait="guardian_ruinas",maxHp=42,weakness="earth",shape="guardian",actions={
        attack("bodyguard","Golpe de escolta",6),{id="guard",name="Proteger la pista",kind="shield",shield=4},attack("ambush","Emboscada",8)},
        defeatText="El protector depone las armas. El emisario ya no puede esconder el rastro de la poción."},
    {id="mana_anomaly",name="Anomalía de maná",maxHp=22,weakness="earth",shape="mirror",actions={
        attack("magic_attack","Pulso de maná",4),{id="arcane_barrier",name="Barrera inestable",kind="shield",shield=3},
        {id="gather_mana",name="Acumular maná",kind="prepare",nextDamage=7},attack("charged_attack","Descarga",7),
        {id="weakening",name="Interferencia",kind="status",status="weak",duration=1}},
        defeatText="La anomalía se deshace en chispas. El laboratorio vuelve a estar a salvo."},
    {id="forest_beast",name="Bestia del bosque",maxHp=35,weakness="water",shape="beast",actions={
        attack("claw","Zarpazo",5),{id="stalk",name="Acechar",kind="prepare",nextDamage=9},attack("pounce","Salto feroz",9,{companionDamage=3}),
        {id="hide",name="Piel endurecida",kind="shield",shield=3}},
        defeatText="La bestia huye del sendero. Los viajeros podrán regresar a Sharia."},
    {id="ruins_guardian",name="Guardián de las ruinas",maxHp=44,weakness="water",shape="guardian",actions={
        {id="stone_skin",name="Armadura de piedra",kind="shield",shield=5},attack("slam","Golpe del guardián",7),
        {id="runes",name="Encender runas",kind="prepare",nextDamage=11},attack("quake","Temblor",11,{companionDamage=3})},
        defeatText="El círculo del guardián se apaga. El sello puede retirarse sin destruir las ruinas."},
    {id="distorted_reflection",name="Reflejo distorsionado",maxHp=48,weakness="earth",shape="mirror",actions={
        attack("shard","Fragmentos",6),{id="doubt",name="Duda inducida",kind="status",status="weak",duration=1},
        attack("false_memory","Recuerdo falso",9,{companionDamage=4}),{id="refraction",name="Refracción",kind="shield",shield=6}},
        defeatText="La imagen se rompe. Las notas de Orsted permiten aislar la influencia de Hitogami."},
    {id="rudy_reflection",name="Reflejo de Rudy",maxHp=52,weakness="earth",shape="rudy",actions={
        attack("water_copy","Cañón reflejado",7),{id="isolation",name="Aislamiento",kind="status",status="weak",duration=1},
        {id="mirror_charge",name="Cargar el reflejo",kind="prepare",nextDamage=12},attack("denial","Negación",12,{companionDamage=4})},
        defeatText="Rudy admite su miedo sin obedecerlo. Su reflejo deja de conjurar."},
    {id="mirror_manifestation",name="Manifestación del Espejo",maxHp=68,weakness="water",shape="mirror",boss=true,actions={
        attack("fracture","Fractura de posibilidades",8,{companionDamage=3}),{id="veil",name="Velo del espejo",kind="shield",shield=6},
        {id="gather_futures",name="Concentrar futuros",kind="prepare",nextDamage=14},attack("collapse","Colapso",14,{companionDamage=5}),
        {id="whisper",name="Susurro de Hitogami",kind="status",status="weak",duration=1}},
        defeatText="Los sellos cierran el espejo. La manifestación se disuelve; Hitogami sigue existiendo, pero ha perdido este acceso."},
    {id="badigadi_training",name="Badigadi · duelo amistoso",maxHp=60,weakness="water",shape="guardian",training=true,actions={
        attack("friendly_punch","Puñetazo contenido",6),{id="laugh",name="Carcajada de desafío",kind="prepare",nextDamage=10},attack("challenge","¡Otra vez!",10)},
        defeatText="Badigadi se ríe y termina el ejercicio. ¡Buen golpe! Está ileso y exige otra ronda algún día."},
}
local byId={}
for _,enemy in ipairs(list) do
    enemy.behavior="cycle"
    enemy.portrait=enemy.portrait or ({mana_anomaly="anomalia_mana",ruins_guardian="guardian_ruinas",distorted_reflection="anomalia_mana",rudy_reflection="rudeus",badigadi_training="badigadi"})[enemy.id]
    enemy.sprite=enemy.portrait or "procedural_"..enemy.shape
    enemy.reward=enemy.reward or {text=enemy.training and "Ejercicio completado. Badigadi reconoce tu esfuerzo." or "Amenaza neutralizada. La investigación puede continuar.",event=enemy.id.."_defeated"}
    enemy.narrativeEvent=enemy.id.."_defeated";enemy.defeatedEvent=enemy.narrativeEvent;byId[enemy.id]=enemy
end
byId.protector_emissary=byId.emissary_guard
byId.mirror_anomaly=byId.mana_anomaly

-- Bonificaciones acotadas y repertorios escritos, aplicados al encuentro.
-- Badigadi conserva sus estadísticas y sus fases; nunca recibe multiplicadores.
local difficulty={
    [1]={name="Aprendizaje",hp=0,damage=0,shield=0},
    [2]={name="Básica",hp=0,damage=0,shield=0},
    [3]={name="Resistencia",hp=0,damage=0,shield=0},
    [4]={name="Presión",hp=4,damage=1,shield=1,extraActions={
        {id="disorient",name="Desorientar",kind="status",status="weak",duration=1},
    }},
    [5]={name="Coordinación",hp=18,damage=2,shield=2,extraActions={
        {id="interrupt",name="Cortar el ritmo",kind="interrupt",actionLoss=1},
        attack("rapid_strikes","Ataques consecutivos",3,{hits=2}),
    }},
    [6]={name="Desafío final",hp=8,damage=1,shield=1,extraActions={
        {id="interrupt",name="Cortar el ritmo",kind="interrupt",actionLoss=1},
    }},
}
local function copy(value)
    if type(value)~="table" then return value end
    local out={};for key,item in pairs(value) do out[key]=copy(item) end;return out
end
local function resolve(id,context)
    context=context or {}
    local enemy=copy(byId[id] or byId.mana_anomaly)
    local level=context.tutorial and 1 or context.difficulty or context.day
    local profile=difficulty[level]
    enemy.difficulty={level=level or 0,name=profile and profile.name or "Base"}
    if profile and not enemy.boss and not enemy.training then
        enemy.maxHp=math.min(80,enemy.maxHp+profile.hp)
        for _,action in ipairs(enemy.actions) do
            if action.damage then action.damage=math.min(15,action.damage+profile.damage) end
            if action.nextDamage then action.nextDamage=math.min(15,action.nextDamage+profile.damage) end
            if action.shield then action.shield=math.min(9,action.shield+profile.shield) end
        end
        -- Las habilidades avanzadas se anuncian antes de actuar; no se sortean
        -- después de que el jugador haya elegido su defensa.
        for index,action in ipairs(profile.extraActions or {}) do
            table.insert(enemy.actions,index+1,copy(action))
        end
    end
    for _,action in ipairs(enemy.actions) do
        if action.kind=="shield" then action.maxUses=action.maxUses or 3 end
    end
    return enemy
end
return {list=list,byId=byId,default="mana_anomaly",difficulty=difficulty,resolve=resolve}
