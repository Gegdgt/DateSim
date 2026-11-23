-- Ejecutar con LÖVE real: DATESIM_TEST_MODULE=exploration_assets ./probar.ps1
local Suite={}
function Suite.run()
    local Assets=require("src.data.assets")
    local Catalog=Assets.exploration
    local Maps=require("src.data.maps")
    local Connections=require("src.data.map_connections")
    local Validation=require("src.systems.map_validation")
    local Resources=require("src.systems.resources")
    local Json=require("src.systems.json")
    local report=assert(Json.decode(assert(love.filesystem.read("docs/assets_migration.json"))))
    local checked=0
    local function check(ok,message) checked=checked+1;assert(ok,message) end
    local function count(t) local n=0;for _ in pairs(t) do n=n+1 end;return n end
    local function u16(s,p) return s:byte(p)+256*s:byte(p+1) end
    local function u32(s,p) return u16(s,p)+65536*u16(s,p+2) end
    local function hash(s) return love.data.encode("string","hex",love.data.hash("sha256",s)) end
    local function exactPath(path)
        local parent=""
        for segment in path:gmatch("[^/]+") do
            local found=false
            for _,name in ipairs(love.filesystem.getDirectoryItems(parent)) do if name==segment then found=true;break end end
            if not found then return false end
            parent=parent=="" and segment or parent.."/"..segment
        end
        return true
    end
    local migrated,ases,pngs,aseWarnings={}, {}, {},0
    local totals={png=0,ase=0,txt=0,csv=0,json=0}
    for _,file in ipairs(report.files) do
        local path=file.destination
        check(not migrated[path],"Destino duplicado: "..path);migrated[path]=file
        check(exactPath(path),"Mayúsculas/minúsculas reales: "..path)
        local data=assert(love.filesystem.read(path))
        check(#data==file.bytes and hash(data)==file.sha256,"Integridad binaria original: "..path)
        local extension=path:match("%.([^.]+)$")
        totals[extension]=totals[extension]+1
        if extension=="png" then
            check(path:match("^assets/"),"PNG bajo assets: "..path)
            local cpu=love.image.newImageData(path)
            local gpu=love.graphics.newImage(cpu)
            check(cpu:getWidth()==file.png.width and cpu:getHeight()==file.png.height,"Dimensiones originales: "..path)
            check(gpu:typeOf("Image"),"Carga GPU: "..path)
            pngs[file.name:gsub("%.png$","")]=file
            cpu:release();gpu:release()
        elseif extension=="ase" then
            check(path:match("^sprite_sources/"),"ASE nativo bajo sprite_sources: "..path)
            local a=file.ase
            check(#data>=128 and u32(data,1)==#data and u16(data,5)==0xA5E0,"Cabecera ASE: "..path)
            check(u16(data,7)==a.frames and u16(data,9)==a.width and u16(data,11)==a.height and u16(data,13)==32,
                "Frames y dimensiones ASE intactos: "..path)
            local offset=129
            for frame=1,a.frames do
                local bytes=u32(data,offset)
                check(u16(data,offset+4)==0xF1FA and bytes>=16 and offset+bytes<=#data+1,"Frame ASE válido: "..path)
                check(u16(data,offset+8)==a.durationsMs[frame],"Duración original: "..path)
                local chunks=u32(data,offset+12)
                if chunks==0 then chunks=u16(data,offset+6) end
                local pos=offset+16
                for _=1,chunks do
                    local size=u32(data,pos)
                    check(size>=6 and pos+size<=offset+bytes,"Límites de chunk ASE: "..path)
                    pos=pos+size
                end
                check(pos==offset+bytes,"Fin de frame ASE: "..path)
                offset=offset+bytes
            end
            check(offset==#data+1,"Fin de ASE sin pérdida de chunks: "..path)
            if #a.warnings>0 then aseWarnings=aseWarnings+1 end
            ases[file.name:gsub("%.ase$","")]=a
        end
    end
    check(totals.png==53 and totals.ase==53 and totals.txt==1 and totals.csv==1 and totals.json==1,"Entrega: 109 archivos")
    check(#report.missing==0 and #report.unexpected==0 and #report.duplicates==0,"Sin faltantes ni conflictos")
    -- Advertencia de ORIGEN: las capas de 14 mapas + 4 tilesets no tienen header estándar.
    -- Sus hashes deben conservarse; no se confunde preservación con reparación/editabilidad certificada.
    check(aseWarnings==18,"Se conservan las 18 advertencias ASE de origen documentadas")
    for _,file in ipairs(report.legacyFiles) do
        local data=assert(love.filesystem.read(file.path))
        check(hash(data)==file.sha256,"Recurso anterior intacto: "..file.path)
        if file.path:match("%.png$") then
            local img=love.graphics.newImage(file.path)
            check(img:typeOf("Image"),"PNG anterior carga: "..file.path);img:release()
        end
    end
    for _,old in ipairs(report.legacyManifest) do
        local group=old.group=="" and Assets or Assets[old.group]
        check(group[old.id]==old.path,"ID/ruta anterior conservado: "..old.group.."/"..old.id)
    end
    local resource=Resources.new():preload()
    check(#resource.warnings==0,"Dating sim carga sin sustituciones")
    for path in pairs(migrated) do check(not resource.images[path],"Precarga anterior no carga exploración: "..path) end

    local expectedCounts={portraits=5,overworld=7,npcIdle=5,maps=14,tilesets=4,items=16,atlases=1,animations=1}
    local registered={}
    for group,expected in pairs(expectedCounts) do
        check(count(Catalog[group])==expected,"Cantidad de "..group)
        for id,entry in pairs(Catalog[group]) do
            check(migrated[entry.image] and not registered[entry.image],"Ruta nueva única registrada: "..entry.image)
            registered[entry.image]=true
            local img=assert(resource:getExploration(group,id))
            check(img==resource:getExploration(group,id),"Caché por ruta: "..id)
            local min,mag=img:getFilter()
            check(min=="nearest" and mag=="nearest" and img:getMipmapCount()==1,"Pixel art sin mipmaps: "..id)
            check(img:getWidth()==entry.width and img:getHeight()==entry.height,"Dimensiones del manifiesto: "..id)
            local stem=entry.image:match("([^/]+)%.png$")
            local ase=assert(ases[stem])
            if entry.frames then
                check(entry.frameWidth==ase.width and entry.frameHeight==ase.height and entry.frames==ase.frames,"PNG/ASE animados: "..id)
                check(entry.columns*entry.rows==entry.frames and entry.width==entry.columns*entry.frameWidth
                    and entry.height==entry.rows*entry.frameHeight,"Distribución de frames: "..id)
                for frame=1,entry.frames do check(entry.durationsMs[frame]==ase.durationsMs[frame],"Duración registrada: "..id) end
            else check(entry.width==ase.width and entry.height==ase.height,"PNG/ASE estáticos: "..id) end
        end
    end
    check(count(registered)==53,"Los 53 PNG están registrados una sola vez")
    for _,file in pairs(pngs) do check(registered[file.destination],"Ningún PNG sin registrar: "..file.name) end
    for id,entry in pairs(Catalog.overworld) do
        check(entry.width==96 and entry.height==128 and entry.frameWidth==24 and entry.frameHeight==32
            and entry.frames==16 and entry.columns==4 and entry.rows==4,"Hoja de caminar: "..id)
        check(table.concat(entry.directions,",")=="down,left,right,up","Orden de direcciones: "..id)
        for row=0,3 do for column=0,3 do
            local q=love.graphics.newQuad(column*24,row*32,24,32,entry.width,entry.height)
            local x,y,w,h=q:getViewport()
            check(x==column*24 and y==row*32 and w==24 and h==32,"Recorte de caminar: "..id)
            q:release()
        end end
    end
    for id,e in pairs(Catalog.portraits) do check(e.width==256 and e.height==64 and e.frames==4 and e.columns==4,"Retrato familiar: "..id) end
    for id,e in pairs(Catalog.npcIdle) do
        local w,h=24,32
        if id=="lucy" then w,h=16,16 elseif id=="zenith_lucy" then w,h=32,32 end
        check(e.width==w*2 and e.height==h and e.frames==2 and e.frameWidth==w and e.frameHeight==h,"Reposo NPC: "..id)
    end
    local horse=Catalog.animations.horseExit
    check(horse.width==192 and horse.height==32 and horse.frameWidth==48 and horse.frameHeight==32 and horse.frames==4,"Cuatro frames del caballo")
    for id,e in pairs(Catalog.tilesets) do
        check(e.width==256 and e.height==256 and e.tileSize==16 and #e.connectionRows==4,"Tileset: "..id)
        check(e.maskBits.north==1 and e.maskBits.east==2 and e.maskBits.south==4 and e.maskBits.west==8,"Máscaras: "..id)
    end
    local atlas=assert(Json.decode(assert(love.filesystem.read(Catalog.atlases.objects.json))))
    local csv=assert(love.filesystem.read(Catalog.atlases.objects.csv))
    local atlasPixels=love.image.newImageData(Catalog.atlases.objects.image)
    local objects=Resources.new()
    for _,s in ipairs(atlas.sprites) do
        local e=assert(Catalog.items[s.archivo])
        check(e.width==16 and e.height==16,"Objeto 16x16: "..s.archivo)
        check(csv:find(s.archivo,1,true),"CSV conserva objeto: "..s.archivo)
        local img,q=objects:getObjectSprite(s.archivo)
        check(img and q,"Objeto por atlas: "..s.archivo)
        local x,y,w,h=q:getViewport()
        check(x==s.x and y==s.y and w==s.ancho and h==s.alto,"Quad coincide con JSON original: "..s.archivo)
        local pixels=love.image.newImageData(e.image)
        local same=true
        for yy=0,15 do for xx=0,15 do
            local a,b,c,d=pixels:getPixel(xx,yy)
            local aa,bb,cc,dd=atlasPixels:getPixel(s.x+xx,s.y+yy)
            if a~=aa or b~=bb or c~=cc or d~=dd then same=false end
        end end
        check(same,"Atlas reproduce el objeto individual: "..s.archivo);pixels:release()
    end
    atlasPixels:release()
    check(count(objects.images)==1,"Dieciséis objetos cargan una sola imagen por defecto")
    local individual=Resources.new()
    local img,quad=individual:getObjectSprite("01_moneda_oro","individual")
    check(img and not quad and count(individual.images)==1,"Modo individual no carga atlas")
    check(not objects:getObjectSprite("01_moneda_oro","invalid"),"Modo inválido rechazado")
    check(not objects:getExploration("maps","missing"),"ID inexistente no crea sustitución")

    local result=Validation.validate(Maps,Connections)
    check(result.ok,table.concat(result.errors,"\n"))
    check(result.stats.maps==14 and result.stats.links==13 and result.stats.portals==26,"14 mapas / 13 enlaces / 26 portales")
    check(result.stats.calibratedAccesses==25 and result.stats.calibratedLinks==12 and result.stats.pendingLinks==1,"Calibración honesta de la universidad")
    local expectedEdges={
        segundo_sylphie={"casa_segundo_piso","top","dormitorio_sylphie","bottom"},
        segundo_roxy={"casa_segundo_piso","top","dormitorio_roxy","bottom"},
        segundo_eris={"casa_segundo_piso","top","dormitorio_eris","bottom"},
        segundo_estudio={"casa_segundo_piso","top","estudio_rudy","bottom"},
        escaleras_casa={"casa_segundo_piso","bottom","casa_planta_baja","top"},
        casa_jardin={"casa_planta_baja","bottom","jardin_casa","top"},
        jardin_patio={"jardin_casa","left","patio_eris","right"},
        jardin_sharia={"jardin_casa","bottom","camino_sharia","top"},
        sharia_cementerio={"camino_sharia","bottom","cementerio_ranoa","top"},
        sharia_universidad={"camino_sharia","right","universidad_exterior","left"},
        universidad_biblioteca={"universidad_exterior","top","biblioteca_ranoa","bottom"},
        universidad_taller={"universidad_exterior","top","taller_cliff_zanoba","bottom"},
        universidad_laboratorio={"universidad_exterior","top","laboratorio_nanahoshi","bottom"},
    }
    for _,link in ipairs(Connections.links) do
        local expected=expectedEdges[link.id]
        check(expected and link.a.map==expected[1] and link.a.side==expected[2] and link.b.map==expected[3]
            and link.b.side==expected[4],"Conexión exacta del diagrama: "..link.id)
        if link.id=="sharia_universidad" then check(not link.enabled and link.b.spawn==false and link.b.trigger==false,"No inventar acceso izquierdo") end
    end
    local lastX=-1
    for _,id in ipairs({"segundo_sylphie","segundo_roxy","segundo_eris","segundo_estudio"}) do
        for _,link in ipairs(Connections.links) do if link.id==id then check(link.a.trigger.x>lastX,"Orden de puertas superiores");lastX=link.a.trigger.x end end
    end
    lastX=-1
    for _,id in ipairs({"universidad_biblioteca","universidad_taller","universidad_laboratorio"}) do
        for _,link in ipairs(Connections.links) do if link.id==id then check(link.a.trigger.x>lastX,"Orden de puertas universidad");lastX=link.a.trigger.x end end
    end
    check(count(Validation.reachable(Maps,Connections,"casa_planta_baja"))==14,"Grafo completo alcanzable desde casa")
    check(count(Validation.reachable(Maps,Connections,"casa_planta_baja",true))==10,"Grafo habilitado informa los cuatro mapas aislados por calibración")
    for id,map in pairs(Maps) do
        local e=Catalog.maps[id]
        check(map.id==id and map.name and map.image==e.image and map.width==e.width and map.height==e.height,"Registro del mapa: "..id)
        check(Catalog.tilesets[map.tileset] and require("src.data.audio").music[map.music],"Tileset y música existentes: "..id)
        check(map.tileSize==16 and map.width%16==0 and map.height%16==0,"Cuadrícula del mapa: "..id)
        check(map.collisions.status=="routes_reviewed" and map.collisions.unknown=="blocked" and map.explorationReady,"Rutas revisadas; zonas desconocidas bloqueadas: "..id)
        for _,kind in ipairs({"walkable","walls","furniture","obstacles","doors","stairs","portals","interactive"}) do
            check(type(map.collisions[kind])=="table","Tipo de colisión separado: "..id.."/"..kind)
        end
        check(type(map.npcs.available)=="table" and type(map.npcs.placements)=="table" and type(map.objects)=="table","NPC y objetos configurables: "..id)
        for _,npc in ipairs(map.npcs.available) do check(Catalog.portraits[npc] or Catalog.overworld[npc],"Sprite disponible para NPC: "..npc) end
        check(#map.portals==#Connections.byMap[id],"Índice de portales del mapa: "..id)
    end
    -- Errores reales de autoría: destinos, duplicados, retornos y llegadas peligrosas.
    local function clone(t,seen)
        if type(t)~="table" then return t end
        seen=seen or {};if seen[t] then return seen[t] end
        local c={};seen[t]=c;for k,v in pairs(t) do c[k]=clone(v,seen) end;return c
    end
    local function invalid(edit,message)
        local data=clone({maps=Maps,connections=Connections})
        edit(data)
        check(not Validation.validate(data.maps,data.connections).ok,message)
    end
    invalid(function(d) d.connections.portals[1].targetMap="missing" end,"Rechaza destino inexistente")
    invalid(function(d) table.insert(d.connections.portals,d.connections.portals[1]) end,"Rechaza duplicado")
    invalid(function(d) d.connections.portals[1].reverseId="missing" end,"Rechaza salida sin regreso")
    invalid(function(d) d.connections.links[1].b.spawn.x=52;d.connections.links[1].b.spawn.y=80 end,"Rechaza llegada dentro de la cama")
    invalid(function(d) d.connections.links[1].a.side="bottom" end,"Rechaza lado incompatible")
    local function scan(path)
        for _,name in ipairs(love.filesystem.getDirectoryItems(path)) do
            local file=path.."/"..name
            if love.filesystem.getInfo(file,"directory") then scan(file)
            elseif name:match("%.lua$") then
                local code=assert(love.filesystem.read(file)):gsub("\\","/"):lower()
                check(not code:find("assets/new",1,true),"Sin referencia temporal en ejecución: "..file)
            end
        end
    end
    scan("src")
    for _,file in ipairs({"main.lua","conf.lua"}) do check(not assert(love.filesystem.read(file)):lower():find("assets/new",1,true),"Entrada sin ruta temporal") end
    print(string.format("Exploration assets: %d checks; 53 PNG + 53 ASE + 3 metadata; 14 maps / 13 bidirectional links / 26 portals; 12 calibrated links, 1 pending; 18 pre-existing ASE layer warnings.",checked))
    return checked
end
return Suite
