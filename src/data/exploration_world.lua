-- Colocación sobre los PNG originales. Coordenadas = centro de los pies.
local function npc(id,name,x,y,sprite)
    return {id=id,name=name,x=x,y=y,sprite=sprite or id,kind="npc",solid=true}
end
local function wife(id,name,x,y,period)
    local n=npc(id,name,x,y);n.period=period;return n
end
return {
    start={map="dormitorio_eris",x=112,y=112,facing="down"},
    npcs={
        dormitorio_eris={wife("eris","Eris",132,112,"night")},
        dormitorio_roxy={wife("roxy","Roxy",104,104,"night")},
        dormitorio_sylphie={wife("sylphiette","Sylphie",132,112,"night")},
        patio_eris={wife("eris","Eris",360,216,"day")},
        biblioteca_ranoa={wife("roxy","Roxy",200,216,"day")},
        casa_planta_baja={npc("lilia","Lilia",432,176),npc("aisha","Aisha",520,200),
            wife("sylphiette","Sylphie",196,172,"day"),
            npc("norn","Norn",72,320),npc("zenith","Zenith y Lucy",72,284,"zenith_lucy")},
        taller_cliff_zanoba={npc("cliff","Cliff",224,180),npc("zanoba","Zanoba",288,224)},
        laboratorio_nanahoshi={npc("nanahoshi","Nanahoshi",312,240)},
    },
    -- Identidades únicas; las colocaciones alternativas nunca se activan juntas.
    wifeLocations={
        eris={day="patio_eris",night="dormitorio_eris"},
        roxy={day="biblioteca_ranoa",night="dormitorio_roxy"},
        sylphiette={day="casa_planta_baja",night="dormitorio_sylphie"},
    },
    passableDecorations={"chair","armchair","seat","rug","small_plant","flower"},
    objects={
        estudio_rudy={{id="hitogami_letter",kind="letter",x=176,y=64,reachX=180,reachY=116,
            sprite="15_nota_misteriosa",label="Examinar carta"}},
        jardin_casa={{id="garden_flower",kind="resource",x=264,y=268,sprite="13_flor",label="Recoger flor"}},
    },
    -- NO se habilita sharia_universidad: su muro sigue cerrado.
    -- Dos paradas de viaje sobre suelo accesible sustituyen temporalmente ese enlace.
    transfers={
        camino_sharia={id="transfer_university",kind="travel",x=672,y=160,label="Traslado a la Universidad",
            target="universidad_exterior",arrival={x=80,y=164,facing="right"}},
        universidad_exterior={id="transfer_sharia",kind="travel",x=64,y=164,label="Traslado a Sharia",
            target="camino_sharia",arrival={x=648,y=160,facing="left"}},
    },
    greetings={
        eris="¡Buenos días, Rudy! Voy a entrenar después. Tómate tu tiempo.",
        roxy="Buenos días. Estaba ordenando mis apuntes. Nos vemos más tarde.",
        sylphiette="Buenos días, Rudy. Qué gusto verte descansado. El desayuno ya casi está.",
        lilia="Buenos días, joven Rudy. Espero que haya descansado bien.",
        aisha="¡Buenos días! Estoy ayudando a Lilia con la casa.",
        norn="Buenos días. Dejaré el libro aquí cuando termine.",
        zenith="Zenith responde a tu saludo con una sonrisa. Lucy mueve la mano desde sus brazos.",
        cliff="Buenos días, Rudeus. Estoy revisando estos instrumentos.",
        zanoba="¡Maestro! Estoy ordenando el taller. Pase cuando quiera.",
        nanahoshi="Buenos días. Estoy organizando unas muestras; puedes mirar la universidad con calma.",
    },
}
