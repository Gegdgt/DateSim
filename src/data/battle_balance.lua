-- Todas las magnitudes nuevas viven aquí; el replay anterior usa enemies_legacy.
return {
 orsted={hp=120,turns=4,actions={
  {id="measure_guard",name="Medir la guardia",kind="attack",damage=4},
  {id="change_angle",name="Cambiar el ángulo",kind="attack",damage=8},
  {id="close_distance",name="Cerrar la distancia",kind="attack",damage=6,hits=2},
  {id="end_demonstration",name="Orsted detendrá la demostración",kind="demonstration_finish"},
 }},
 hpFactors={ruins_guardian=1.15,rudy_reflection=1.1,distorted_reflection=1.05},
 days={
  {name="Aprendizaje",hp=10,damage=2,shield=0},
  {name="Primeras defensas",hp=20,damage=3,shield=2},
  {name="Ataques preparados",hp=36,damage=4,shield=3},
  {name="Barreras y debilitamiento",hp=55,damage=5,shield=5},
  {name="Coordinación",hp=180,damage=6,shield=7},
  {name="Lacayos y desafíos",hp=260,damage=7,shield=9},
  {name="Última jornada",hp=300,damage=8,shield=10},
 },
 boss={hp=1000,maxTurns=75,seal=12,thresholds={.75,.35},armor=6,weaknessBonus=8,
  phases={
   endurance={{id="royal_punch",name="Puño del rey",kind="attack",damage=4},{id="royal_prepare",name="Medir resistencia",kind="prepare",nextDamage=4}},
   six_arms={{id="six_arms",name="Seis brazos",kind="attack",damage=2,hits=3},{id="royal_breath",name="Rearmar postura",kind="prepare",nextDamage=6}},
   resolve={{id="royal_assault",name="Asalto del rey",kind="attack",damage=3,hits=3},{id="royal_opening",name="Preparar asalto",kind="prepare",nextDamage=9}},
   seal={{id="seal_pulse",name="Pulso del sello",kind="attack",damage=3}},
  }},
 support={
  sylphiette={name="Sylphiette",role="Ataque, barreras y curación",special=90,normal=12},
  eris={name="Eris",role="Ataque físico e interrupción",special=150,normal=24},
  roxy={name="Roxy",role="Magia, análisis y defensa reducida",special=110,normal=18},
 },
 skills={
  sylphiette={
   {id="attack",name="Proyectil",power=12,mana=0},
   {id="special",name="Luz coordinada",power=90,mana=4,cooldown=3,uses=3},
   {id="heal",name="Curar a Rudy",mana=2,cooldown=2,uses=3,heal=true},
   {id="guard",name="Barrera familiar",mana=2,shield=8},
  },
  eris={
   {id="attack",name="Corte normal",power=24,mana=0},
   {id="strong",name="Ataque fuerte",power=65,mana=0,cooldown=2,uses=5},
   {id="interrupt",name="Interrumpir",power=12,mana=0,weak=1,cooldown=2},
   {id="guard",name="Proteger a Rudy",mana=0,shield=5},
   {id="special",name="Espada coordinada",power=150,mana=4,cooldown=3,uses=3},
  },
  roxy={
   {id="attack",name="Proyectil mágico",power=18,mana=0},
   {id="analyze",name="Analizar debilidad",mana=0,weak=2,expose=2,cooldown=2},
   {id="shatter",name="Disolver defensa",power=10,mana=2,shatter=12,expose=3,cooldown=2},
   {id="coordinate",name="Coordinar magia",power=40,mana=2,weak=1,cooldown=2},
   {id="special",name="Conjuro combinado",power=110,mana=5,cooldown=3,uses=3},
   {id="guard",name="Muro de apoyo",mana=2,shield=7},
  },
 },
}
