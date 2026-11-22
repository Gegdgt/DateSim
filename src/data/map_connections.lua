-- Un enlace = dos portales. Coordenadas en píxeles del PNG, origen arriba/izquierda.
-- spawn.x/y = centro de los pies; facing usa down/left/right/up.
-- Un extremo sin acceso visible usa false, nunca coordenadas inventadas.
local function access(map,id,side,x,y,w,h,sx,sy,facing,evidence,kind)
    return {map=map,id=id,side=side,trigger={x=x,y=y,w=w,h=h},
        spawn={x=sx,y=sy,facing=facing},facing=facing,status="calibrated",
        evidence=evidence,kind=kind or "door"}
end

local links={
    {id="segundo_sylphie",a=access("casa_segundo_piso","puerta_sylphie","top",100,116,24,12,112,144,"down",
        "Primera puerta superior, paño verde; suelo delante del umbral."),
        b=access("dormitorio_sylphie","salida","bottom",148,172,24,12,160,160,"up","Hueco inferior central entre jambas.")},
    {id="segundo_roxy",a=access("casa_segundo_piso","puerta_roxy","top",196,116,24,12,208,144,"down",
        "Segunda puerta superior, paño azul; suelo delante del umbral."),
        b=access("dormitorio_roxy","salida","bottom",148,176,24,12,160,160,"up","Hueco inferior central entre jambas.")},
    {id="segundo_eris",a=access("casa_segundo_piso","puerta_eris","top",292,116,24,12,304,144,"down",
        "Tercera puerta superior, paño rojo; suelo delante del umbral."),
        b=access("dormitorio_eris","salida","bottom",148,172,24,12,160,160,"up","Hueco inferior central entre jambas.")},
    {id="segundo_estudio",a=access("casa_segundo_piso","puerta_estudio","top",380,116,24,12,392,144,"down",
        "Cuarta puerta superior, paño ocre; suelo delante del umbral."),
        b=access("estudio_rudy","salida","bottom",148,176,24,12,160,160,"up","Hueco inferior central entre jambas.")},
    {id="escaleras_casa",a=access("casa_segundo_piso","escaleras","bottom",232,280,48,16,256,248,"up",
        "Escalera inferior central entre las dos barandas.","stair"),
        b=access("casa_planta_baja","escaleras","top",360,104,24,16,372,144,"down",
        "Base de la escalera superior, a la derecha del recibidor.","stair")},
    {id="casa_jardin",a=access("casa_planta_baja","puerta_principal","bottom",300,352,40,12,320,336,"up",
        "Puerta inferior central, delante del felpudo."),
        b=access("jardin_casa","entrada_casa","top",220,72,24,16,232,104,"down",
        "Umbral de la casa al inicio del sendero vertical.")},
    {id="jardin_patio",a=access("jardin_casa","paso_patio","left",0,192,16,32,40,216,"right",
        "Sendero horizontal que sale por la abertura de la cerca izquierda.","passage"),
        b=access("patio_eris","paso_jardin","right",624,192,16,32,600,216,"left",
        "Abertura derecha de la cerca en la pista de tierra.","passage")},
    {id="jardin_sharia",a=access("jardin_casa","salida_sharia","bottom",220,304,24,16,232,280,"up",
        "Sendero vertical interrumpe la cerca inferior.","passage"),
        b=access("camino_sharia","paso_jardin","top",216,0,24,16,228,48,"down",
        "Calle superior entre las cercas, a la izquierda de la fuente.","passage")},
    {id="sharia_cementerio",a=access("camino_sharia","paso_cementerio","bottom",368,304,24,16,384,280,"up",
        "Calle inferior central flanqueada por cipreses.","passage"),
        b=access("cementerio_ranoa","salida_sharia","top",240,0,32,16,256,48,"down",
        "Sendero superior que atraviesa la cerca y llega a las escaleras.","passage")},
    {id="sharia_universidad",a=access("camino_sharia","paso_universidad","right",752,144,16,32,696,160,"left",
        "Calle empedrada que cruza la puerta del borde derecho.","passage"),
        b={map="universidad_exterior",id="paso_sharia",side="left",trigger=false,spawn=false,facing="right",
            kind="passage",status="pending_calibration",
            evidence="El borde izquierdo tiene muro y postes continuos delante del camino. No se identifica una abertura segura."}},
    {id="universidad_biblioteca",a=access("universidad_exterior","puerta_biblioteca","top",144,88,24,16,156,120,"down",
        "Primera de las tres puertas superiores, alineada con el sendero izquierdo."),
        b=access("biblioteca_ranoa","salida","bottom",240,296,32,16,256,272,"up",
        "Hueco inferior al final de la alfombra central.")},
    {id="universidad_taller",a=access("universidad_exterior","puerta_taller","top",320,88,24,16,332,120,"down",
        "Puerta superior central, bajo el emblema de la torre."),
        b=access("taller_cliff_zanoba","salida","bottom",240,296,32,16,256,272,"up",
        "Hueco inferior central, entre los tramos de pared.")},
    {id="universidad_laboratorio",a=access("universidad_exterior","puerta_laboratorio","top",500,88,24,16,512,120,"down",
        "Tercera puerta superior, alineada con el sendero derecho."),
        b=access("laboratorio_nanahoshi","salida","bottom",240,296,32,16,256,272,"up",
        "Hueco inferior entre pilares; suelo libre al sur de la mesa.")},
}

local result={links=links,portals={},byMap={}}
for _,link in ipairs(links) do
    link.transition="fade"
    link.enabled=link.a.status=="calibrated" and link.b.status=="calibrated"
    link.status=link.enabled and "calibrated" or "pending_calibration"
    for index,pair in ipairs({{link.a,link.b},{link.b,link.a}}) do
        local origin,target=pair[1],pair[2]
        local portal={id=link.id..(index==1 and ":a_to_b" or ":b_to_a"),connectionId=link.id,
            reverseId=link.id..(index==1 and ":b_to_a" or ":a_to_b"),
            sourceMap=origin.map,targetMap=target.map,sourceAccess=origin.id,targetAccess=target.id,
            exitSide=origin.side,entrySide=target.side,trigger=origin.trigger,arrival=target.spawn,
            initialDirection=target.facing,transition=link.transition,
            status=link.status,enabled=link.enabled,
            pendingReason=not link.enabled and (link.a.status~="calibrated" and link.a.evidence or link.b.evidence) or nil}
        result.portals[#result.portals+1]=portal
        result.byMap[origin.map]=result.byMap[origin.map] or {}
        table.insert(result.byMap[origin.map],portal)
    end
end
return result
