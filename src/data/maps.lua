-- Registro de mapas explorables. Los backgrounds 320x180 conservan otro catálogo.
local Assets=require("src.data.assets").exploration
local Connections=require("src.data.map_connections")
local Collisions=require("src.data.map_collisions")
local definitions={
    casa_planta_baja={"Casa Greyrat - Planta baja","hogar","home",320,304,{"aisha","lilia","norn","zenith","lucy"}},
    casa_segundo_piso={"Casa Greyrat - Segundo piso","hogar","home",256,208,{}},
    dormitorio_sylphie={"Dormitorio de Sylphie","hogar","home",160,160,{"sylphiette"}},
    dormitorio_roxy={"Dormitorio de Roxy","hogar","home",160,160,{"roxy"}},
    dormitorio_eris={"Dormitorio de Eris","hogar","home",160,160,{"eris"}},
    estudio_rudy={"Estudio de Rudy","hogar","home",160,160,{}},
    jardin_casa={"Jardín de la casa Greyrat","exterior","home",232,152,{"aisha","lilia","norn","zenith","lucy"}},
    patio_eris={"Patio de entrenamiento de Eris","exterior","training",320,216,{"eris"}},
    camino_sharia={"Camino de Sharia","exterior","casual",384,168,{}},
    cementerio_ranoa={"Cementerio de Ranoa","cementerio","mystery",256,80,{}},
    universidad_exterior={"Universidad de Ranoa - Exterior","universidad","university",332,168,{}},
    biblioteca_ranoa={"Biblioteca de Ranoa","universidad","university",256,208,{"roxy"}},
    taller_cliff_zanoba={"Taller de Cliff y Zanoba","universidad","university",256,208,{"cliff","zanoba"}},
    laboratorio_nanahoshi={"Laboratorio de Nanahoshi","universidad","mystery",256,248,{"nanahoshi"}},
}

local maps={}
for id,d in pairs(definitions) do
    local asset=assert(Assets.maps[id],"Mapa sin recurso registrado: "..id)
    local initial={x=d[4],y=d[5],facing="down"}
    maps[id]={id=id,name=d[1],image=asset.image,width=asset.width,height=asset.height,
        category=asset.category,tileSize=16,tileset=d[2],initialPosition=initial,
        spawnPoints={default=initial},collisions=Collisions[id],portals=Connections.byMap[id] or {},
        npcs={available=d[6],placements={},status="pending_placement"},
        objects={},objectPlacementStatus="not_authored",music=d[3],explorationReady=false}
end

for _,link in ipairs(Connections.links) do
    for _,endpoint in ipairs({link.a,link.b}) do
        local map=assert(maps[endpoint.map])
        if endpoint.spawn then map.spawnPoints[endpoint.id]=endpoint.spawn end
        if endpoint.trigger then
            local kind=endpoint.kind=="stair" and "stairs" or "doors"
            table.insert(map.collisions[kind],{id=endpoint.id,rect=endpoint.trigger,kind=endpoint.kind})
            if link.enabled then
                table.insert(map.collisions.portals,{connectionId=link.id,accessId=endpoint.id,rect=endpoint.trigger})
            end
        end
    end
end
return maps
