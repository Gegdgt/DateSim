-- Técnicas persistentes: los IDs antiguos conservan los recursos y guardados compatibles.
local list={
    {id="staff_strike",name="Golpe de bastón",shortName="BASTÓN",element="physical",cost=1,manaCost=0,effects={damage=4},icon="staff_strike"},
    {id="simple_cut",name="Corte sencillo",shortName="CORTE",element="sword",cost=1,manaCost=0,hpCost=1,effects={damage=5},icon="simple_cut"},
    {id="stone_throw",name="Lanzamiento de piedra",shortName="PIEDRA",element="physical",cost=1,manaCost=0,effects={damage=3},icon="stone_throw"},
    {id="push",name="Empuje",shortName="EMPUJE",element="physical",cost=1,manaCost=0,effects={damage=2,shield=3},icon="push"},
    {id="coordinated_attack",name="Ataque coordinado",shortName="COORDINAR",element="physical",cost=1,manaCost=0,effects={damage=4,weak=1},icon="coordinated_attack"},
    {id="water_projectile",name="Proyectil de Agua",shortName="PROYECTIL",element="water",cost=1,manaCost=1,effects={damage=6},icon="water_projectile",unlockHint="Recuperar el primer fragmento de maná con tu compañera."},
    {id="magic_bolt",name="Bala de Agua",shortName="AGUA",element="water",cost=1,manaCost=2,effects={damage=6},icon="procedural_bolt"},
    {id="arcane_guard",name="Muro de Tierra",shortName="MURO",element="earth",cost=1,manaCost=2,effects={shield=5},icon="procedural_guard"},
    {id="heavy_spell",name="Cañón de Agua",shortName="CAÑÓN",element="water",cost=2,manaCost=4,effects={damage=11},icon="procedural_heavy"},
    {id="heal",name="Curación básica",shortName="CURACIÓN",element="healing",cost=1,manaCost=3,perBattle=3,effects={heal=5},icon="procedural_heal"},
    {id="focus",name="Recuperar aliento",shortName="ALIENTO",cost=1,manaCost=0,effects={mana=5},perTurn=1,icon="procedural_focus"},
    {id="ice_lance",name="Proyectil de Piedra",shortName="PIEDRA",element="earth",cost=1,manaCost=2,effects={damage=7},icon="procedural_bolt"},
    {id="wind_guard",name="Defensa física",shortName="DEFENSA",element="physical",cost=1,manaCost=0,effects={shield=3},icon="procedural_guard"},
    {id="mana_spark",name="Corte rápido",shortName="CORTE",element="sword",cost=1,manaCost=0,hpCost=2,effects={damage=3},icon="procedural_bolt"},
    {id="disrupting_ray",name="Contraataque",shortName="CONTRA",element="sword",cost=1,manaCost=0,hpCost=2,effects={damage=3,shield=2},icon="procedural_heavy"},
    {id="quick_study",name="Ataque arriesgado",shortName="RIESGO",element="sword",cost=2,manaCost=0,hpCost=4,effects={damage=6},icon="procedural_focus"},
    {id="swamp",name="Pantano",shortName="PANTANO",element="earth",cost=1,manaCost=2,effects={damage=2,weak=2},icon="procedural_guard",unlockHint="Contrastar las runas con tu compañera en las ruinas."},
    {id="earth_wall",name="Barrera reforzada",shortName="FORTÍN",element="earth",cost=1,manaCost=3,effects={shield=9},icon="procedural_guard",unlockHint="Investigar los fragmentos protegidos por el guardián."},
    {id="water_cannon",name="Cañón de Agua superior",shortName="TORRENTE",element="water",cost=2,manaCost=5,effects={damage=15},icon="procedural_heavy",unlockHint="Completar la investigación del observatorio con confianza."},
}
local byId={}
for _,card in ipairs(list) do
    card.resource=(card.manaCost or 0)>0 and "artifact" or "physical"
    card.category="initiative";card.contexts={combat=true};card.conditions={};card.hpCost=card.hpCost or 0
    local e,parts=card.effects,{}
    if e.damage then parts[#parts+1]=e.damage.." daño" end
    if e.shield then parts[#parts+1]="+"..e.shield.." escudo" end
    if e.heal then parts[#parts+1]="+"..e.heal.." vida" end
    if e.mana then parts[#parts+1]="+"..e.mana.." maná" end
    if e.weak then parts[#parts+1]="debilita "..e.weak.." turnos" end
    if card.perBattle then parts[#parts+1]="máx. "..card.perBattle.." usos por combate" end
    card.description=table.concat(parts,"; ")..". "..card.cost.." acción; "..card.manaCost.." energía mágica; "..card.hpCost.." PV de esfuerzo."
    card.unlockHint=card.unlockHint or "Investigación y recompensas narrativas; las cinco técnicas físicas iniciales las entrega Nanahoshi."
    local icons={magic_bolt="magic_bolt",arcane_guard="arcane_guard",heavy_spell="heavy_spell",ice_lance="ice_lance",swamp="swamp",earth_wall="arcane_guard",water_cannon="heavy_spell",
        mana_spark="simple_cut",disrupting_ray="staff_strike",quick_study="coordinated_attack",wind_guard="push",focus="mana_fragment",heal="encourage"}
    card.icon=icons[card.id] or card.icon
    byId[card.id]=card
end
local starter={"staff_strike","simple_cut","stone_throw","push","coordinated_attack"}
return {list=list,byId=byId,starterDeck=starter,core=starter,reserve={},
    rules={playerHp=30,playerMana=12,manaRegen=4,energy=3,handSize=3,maxTurns=30,weakReduction=2,vulnerableBonus=2,healUses=3,companionHealUses=3}}

