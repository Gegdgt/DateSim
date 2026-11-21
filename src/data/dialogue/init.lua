local Catalog={nodes={},encounters={},buildErrors={}}
for _,name in ipairs({"nanahoshi","nanahoshi_research","eris","roxy","sylphiette"}) do
    local package=require("src.data.dialogue."..name)
    for id,node in pairs(package.nodes) do
        if Catalog.nodes[id] then Catalog.buildErrors[#Catalog.buildErrors+1]="Nodo duplicado: "..id end
        Catalog.nodes[id]=node
    end
    for scene,id in pairs(package.encounters) do
        if Catalog.encounters[scene] then Catalog.buildErrors[#Catalog.buildErrors+1]="Encuentro duplicado: "..scene end
        Catalog.encounters[scene]=id
    end
end
return Catalog
