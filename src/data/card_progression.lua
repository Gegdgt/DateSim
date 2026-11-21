-- Balance de niveles. Los IDs y las ilustraciones pertenecen al catálogo original.
local P={maxLevel=10,goldPerLevel=5,copiesPerLevel=2,
    costRules={fromLevel=7,ultimate={mana=12,hp=6,uses=1},advanced={extraMana=3,maxMana=12,uses=2}},classes={
    basic={name="Básica",goldFactor=1,copyPrice=2,exponent=1.35},
    intermediate={name="Intermedia",goldFactor=2,copyPrice=4,exponent=1.55},
    advanced={name="Avanzada",goldFactor=3,copyPrice=7,exponent=1.8},
    special={name="Especial",goldFactor=4,copyPrice=10,exponent=2},
    ultimate={name="Definitiva",goldFactor=5,copyPrice=14,exponent=2.3},
},combat={
    staff_strike={class="basic",damage={2,20}},simple_cut={class="basic",damage={3,24}},
    stone_throw={class="basic",damage={1,16}},push={class="basic",damage={1,12},shield={3,8}},
    coordinated_attack={class="basic",damage={2,22}},
    water_projectile={class="intermediate",damage={6,55}},magic_bolt={class="intermediate",damage={6,60}},
    arcane_guard={class="intermediate",shield={5,13}},heavy_spell={class="advanced",damage={11,125}},
    heal={class="intermediate",heal={5,10}},focus={class="basic"},
    ice_lance={class="advanced",damage={7,95}},wind_guard={class="basic",shield={3,8}},
    mana_spark={class="basic",damage={2,18}},disrupting_ray={class="intermediate",damage={3,45},shield={2,6}},
    quick_study={class="intermediate",damage={6,65}},swamp={class="advanced",damage={2,70}},
    earth_wall={class="advanced",shield={9,18}},water_cannon={class="ultimate",damage={15,250}},
    propose_plan={class="basic"},analyze_runes={class="intermediate"},earth_barrier={class="intermediate",shield={5,12}},
    shared_magic={class="special",damage={6,140},heal={4,8},shield={3,8}},
    combined_spell={class="special",damage={12,180}},sword_magic={class="special",damage={13,170},shield={3,8}},
},social={
    listen={love=0,trust=1},encourage={love=1,trust=1},remember={love=1,trust=1},
    light_joke={love=1,trust=0},change_subject={love=0,trust=0},self_joke={love=1,trust=1},
    be_honest={love=1,trust=1},admit_error={love=0,trust=1},share_fear={love=1,trust=1},
    propose_plan={love=0,trust=1},analyze_runes={love=0,trust=1},earth_barrier={love=0,trust=1},
    shared_magic={love=2,trust=1},combined_spell={love=2,trust=1},sword_magic={love=2,trust=1},
    choose_together={love=1,trust=1},subtle_flirt={love=1,trust=0},happy_reply={love=1,trust=1},
    bold_reply={love=1,trust=0},angry_reply={love=-2,trust=-4},sincere_apology={love=0,trust=1},
}}
function P.copiesRequired(level) return level<P.maxLevel and P.copiesPerLevel*level or 0 end
function P.goldRequired(level,class) return level<P.maxLevel and P.goldPerLevel*level*P.classes[class].goldFactor or 0 end
return P
