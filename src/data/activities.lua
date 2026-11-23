local list=require("src.data.family_activities")
local favors={
 {id="cliff_notes",character="cliff",providers={"cliff"},title="Investigar cartas sociales",reward="45 oro; 2 Escuchar; Curación",effects={gold=45,copies={listen=2,heal=1}}},
 {id="zanoba_artifact",character="zanoba",providers={"zanoba"},title="Conseguir cartas de combate",reward="40 oro; 2 Bastón; Defensa",effects={gold=40,copies={staff_strike=2,wind_guard=1}}},
 {id="magic_materials",character="cliff",providers={"cliff","zanoba"},title="Obtener materiales mágicos",reward="2 materiales; 15 oro",effects={gold=15,items={magic_material=2}}},
 {id="gold_search",character="cliff",providers={"cliff","zanoba"},title="Encargo remunerado",reward="65 oro",effects={gold=65}},
 {id="enchantment_study",character="cliff",providers={"cliff"},title="Estudiar encantamientos",reward="1 receta; 1 Analizar runas",effects={discount=1,copies={analyze_runes=1}}},
 {id="craft_materials",character="zanoba",providers={"zanoba"},title="Fabricar y reunir recursos",reward="1 material; 1 libro; 20 oro",effects={gold=20,items={magic_material=1,study_book=1}}},
}
local catalog={list=list,byId={},favors=favors,favorsById={}}
for _,favor in ipairs(require("src.data.commissions")) do
    favor.investment=true;favor.effects={};favors[#favors+1]=favor
end
for _,activity in ipairs(list) do catalog.byId[activity.id]=activity end
catalog.wifeList=require("src.data.wife_activities").list
for _,activity in ipairs(catalog.wifeList) do catalog.byId[activity.id]=activity end
for _,favor in ipairs(favors) do favor.delay=1;favor.description="Entrega al comenzar mañana.";catalog.favorsById[favor.id]=favor end
return catalog
