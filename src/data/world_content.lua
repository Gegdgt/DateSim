local r={}
r.items={
 gold={name="Moneda de oro",sprite="01_moneda_oro",reward={gold=8}},
 purse={name="Bolsa olvidada",sprite="02_bolsa_oro",reward={gold=14}},
 study_book={name="Libro común",sprite="03_libro_magia",reward={items={study_book=1}}},
 scroll={name="Pergamino de tareas",sprite="04_pergamino"},
 social_copy={name="Patrón de carta social",sprite="05_carta_encantada",reward={copies={listen=1}}},
 physical_copy={name="Patrón de carta física",sprite="05_carta_encantada",reward={copies={staff_strike=1}}},
 chest={name="Caja de recortes",sprite="06_cofre_cerrado",openedSprite="07_cofre_abierto",reward={items={magic_material=1}}},
 mana_fragment={name="Fragmento de maná",sprite="08_fragmento_mana",reward={items={mana_fragment=1}}},
 magic_material={name="Material mágico",sprite="09_material_magico",reward={items={magic_material=1}}},
 potion={name="Frasco de reactivo",sprite="10_frasco_pocion"},
 antidote={name="Antídoto",sprite="11_antidoto",reserved=true},
 broom={name="Escoba de Lilia",sprite="12_escoba"},
 flower={name="Flor del jardín",sprite="13_flor",reward={items={flower=1}}},
 ring={name="Anillo familiar",sprite="14_anillo_matrimonio"},
 hitogami_letter={name="Carta —H",sprite="15_nota_misteriosa",reserved=true},
 indicator={sprite="16_indicador_interaccion",reserved=true},
}
r.lootTypes={"gold","purse","study_book","social_copy","physical_copy","mana_fragment","magic_material"}
-- Puntos de suelo revisados, alejados de puertas, muebles y NPC. Nunca tumbas.
r.sites={
 {id="home_hall",map="casa_planta_baja",x=304,y=236},
 {id="upper_hall",map="casa_segundo_piso",x=168,y=208},
 {id="garden_path",map="jardin_casa",x=128,y=216},
 {id="training_ground",map="patio_eris",x=384,y=264},
 {id="sharia_road",map="camino_sharia",x=448,y=160},
 {id="university_court",map="universidad_exterior",x=320,y=272},
 {id="library_aisle",map="biblioteca_ranoa",x=312,y=192},
 {id="laboratory_floor",map="laboratorio_nanahoshi",x=144,y=248},
}
r.objects={
 casa_planta_baja={
  {id="lilia_broom",item="broom",kind="object",x=440,y=112,reachX=436,reachY=120,text="La escoba está apoyada al alcance de Lilia. Rudy la deja donde ella puede encontrarla."},
  {id="house_tasks",item="scroll",kind="object",x=296,y=112,reachX=296,reachY=128,text="Una lista de Aisha: despensa, ropa y ventanas. Hay pequeñas marcas junto a las tareas terminadas."},
  {id="family_ring",item="ring",kind="object",x=192,y=304,text="Un anillo guardado junto a una cajita familiar. No es un objeto para vender ni llevarse."},
 },
 taller_cliff_zanoba={{id="workshop_scraps",item="chest",kind="object",x=256,y=168,collectible=true,requiresIntro=true,text="Zanoba reservó estos recortes para ti. Obtienes un material mágico."}},
 laboratorio_nanahoshi={
  {id="lab_reagent",item="potion",kind="object",x=176,y=184,reachX=176,reachY=216,text="Un reactivo de laboratorio, etiquetado por Nanahoshi. Rudy lo deja cerrado; no es para beber."},
  {id="lab_card_sample",item="social_copy",kind="object",x=216,y=184,reachX=216,reachY=216,text="Un patrón de trabajo de Nanahoshi. Se queda sobre la mesa; aún no es un objeto que Rudy pueda llevarse."},
  {id="secured_antidote",item="antidote",kind="object",x=376,y=232,requiresAntidote=true,text="El antídoto conseguido durante la investigación. Su uso corresponde al desenlace; aquí solo compruebas que sigue a salvo."},
 },
 cementerio_ranoa={
  {id="paul_grave",kind="reflection",name="Tumba de Paul",x=256,y=216,reachX=256,reachY=184,
   lines={"Rudy se detiene ante el nombre de Paul y baja la cabeza.","Papá... Todavía me descubro buscando lo que habrías dicho. A veces me equivoco; sigo intentando cuidar de los nuestros.","El viento mueve las hojas. Rudy permanece un momento en silencio y vuelve al camino."}},
  {id="oldeus_rest",kind="reflection",name="Lugar de descanso de Oldeus",x=304,y=248,reachX=304,reachY=232,
   lines={"Rudy se aparta del sendero y permanece ante el pequeño lugar de descanso.","Oldeus. Un futuro que no quiero repetir. Lo que haga con este día también cuenta, aunque nadie más lo vea.","Rudy guarda la reflexión para sí. No hay recompensa que recoger aquí."}},
 },
}
return r
