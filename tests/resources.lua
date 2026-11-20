-- Se decodifican los PNG del repositorio y se prueba la reserva con fallos
-- inyectados en memoria. No modifica ningún recurso ni archivo del usuario.
local Suite={}
function Suite.run()
    local Resources=require("src.systems.resources")
    local Assets=require("src.data.assets")
    local Characters=require("src.data.characters")
    local Cards=require("src.data.cards")
    local count=0
    local function check(ok,message) count=count+1; assert(ok,message) end
    local originalInfo,originalImage,originalDraw=love.filesystem.getInfo,love.graphics.newImage,love.graphics.draw
    love.graphics.push("all")
    local ok,err=xpcall(function()
        local resources=Resources.new():preload()
        check(#resources.warnings==0,"Todos los PNG definitivos cargan sin reservas")
        local loaded=0
        for path,source in pairs(resources.sources) do
            loaded=loaded+1
            check(source.status=="png" and resources.images[path]:typeOf("Image"),"Nunca sustituir silenciosamente: "..path)
            local min,mag=resources.images[path]:getFilter()
            check(min=="nearest" and mag=="nearest","Filtrado nearest: "..path)
            local data=love.image.newImageData(path)
            local w,h=data:getDimensions()
            check(w==source.width and h==source.height,"Dimensiones reales: "..path)
        end
        check(loaded==42,"42 PNG únicos: 7 personajes, 8 fondos, 27 capas e iconos de cartas")
        local expectedBackgrounds={laboratory="laboratorio",courtyard="patio_universidad",library="biblioteca",
            ruins="ruinas",garden="patio_universidad",training="bosque",forest="bosque",observatory="observatorio",
            mirror_dimension="dimension_espejo",festival="festival"}
        local unique={}
        for id,name in pairs(expectedBackgrounds) do
            local path="assets/backgrounds/"..name..".png"
            unique[path]=true
            check(Assets.backgrounds[id]==path,"Mapa explícito del escenario "..id)
            check(resources:getBackground(id)==resources.images[path],"Escenario usa su PNG: "..id)
        end
        local backgroundCount=0; for _ in pairs(unique) do backgroundCount=backgroundCount+1 end
        check(backgroundCount==8,"Ocho fondos distintos para diez IDs")
        check(resources.backgrounds.garden==resources.backgrounds.courtyard,"Jardín reutiliza la misma imagen del patio")
        check(resources.backgrounds.training==resources.backgrounds.forest,"Entrenamiento reutiliza la misma imagen del bosque")
        local expectedIcons={listen="escuchar",encourage="dar_animo",remember="recordar_un_detalle",
            light_joke="broma_ligera",change_subject="cambiar_de_tema",self_joke="reirse_de_uno_mismo",
            be_honest="hablar_con_honestidad",admit_error="reconocer_un_error",share_fear="compartir_un_miedo",
            propose_plan="proponer_un_plan",analyze_runes="analizar_runas",earth_barrier="barrera_de_tierra",
            shared_magic="magia_compartida",combined_spell="conjuro_combinado",sword_magic="espada_y_magia",
            choose_together="elegir_juntos"}
        local expectedFrames={empathy="empatia",humor="humor",sincerity="sinceridad",initiative="magia_iniciativa"}
        check(#Cards.list==16,"Dieciséis cartas jugables definidas")
        for _,card in ipairs(Cards.list) do
            local path="assets/cards/iconos/"..expectedIcons[card.id]..".png"
            check(Assets.cardIcons[card.id]==path,"Icono español para el ID real "..card.id)
            check(resources:getIcon(card.id)==resources.images[path],"Carta usa icono definitivo: "..card.id)
            check(Assets.cardFrames[card.category]=="assets/cards/marcos/marco_"..expectedFrames[card.category]..".png",
                "Marco depende de la categoría real: "..card.id)
        end
        check(Cards.byId.choose_together.category=="sincerity","Elegir Juntos conserva la categoría del código")
        for category in pairs(Cards.categories) do
            check(resources:getCardFrame(category)==resources.images[Assets.cardFrames[category]],"Marco definitivo: "..category)
        end
        -- La transparencia se comprueba en el archivo y tras el dibujo real.
        local target=love.graphics.newCanvas(72,72)
        local function renderPortrait(id,expression)
            love.graphics.setCanvas(target); love.graphics.origin(); love.graphics.clear(0,0,0,0)
            resources:portrait(id,expression,4,4,1)
            love.graphics.setCanvas()
            return target:newImageData()
        end
        for _,character in ipairs(Characters.list) do
            local path=Assets.characters[character.id]
            local source=love.image.newImageData(path)
            check(resources:getPortrait(character.id):typeOf("Image"),"PNG de personaje real: "..character.id)
            for index,expression in ipairs({"neutral","happy","worried","angry"}) do
                local rendered=renderPortrait(character.id,expression)
                local matches,transparent=true,false
                for y=0,63 do for x=0,63 do
                    local sr,sg,sb,sa=source:getPixel((index-1)*64+x,y)
                    local rr,rg,rb,ra=rendered:getPixel(x+4,y+4)
                    if sa==0 then transparent=true end
                    if math.abs(sa-ra)>.005 or (sa>0 and
                        (math.abs(sr-rr)>.005 or math.abs(sg-rg)>.005 or math.abs(sb-rb)>.005)) then matches=false end
                end end
                check(matches,"Expresión exacta y alfa intacto: "..character.id.."/"..expression)
                check(transparent,"La expresión conserva fondo transparente: "..character.id.."/"..expression)
                local x,y,w,h=resources.quads[index-1]:getViewport()
                check(x==(index-1)*64 and y==0 and w==64 and h==64,"Quad estable: "..expression)
                local _,_,_,outside=rendered:getPixel(68,67)
                check(outside==0,"El recorte no invade el cuadro vecino")
            end
        end
        for _,card in ipairs(Cards.list) do
            local source=love.image.newImageData(Assets.cardIcons[card.id])
            love.graphics.setCanvas(target); love.graphics.clear(0,0,0,0)
            resources:icon(card.id,4,4,1)
            love.graphics.setCanvas()
            local rendered=target:newImageData()
            local matches,transparent=true,false
            for y=0,23 do for x=0,23 do
                local _,_,_,sa=source:getPixel(x,y)
                local _,_,_,ra=rendered:getPixel(x+4,y+4)
                if sa==0 then transparent=true end
                if math.abs(sa-ra)>.005 then matches=false end
            end end
            check(matches and transparent,"Icono conserva transparencia al dibujarse: "..card.id)
        end
        -- Ni escalas fraccionarias ni posiciones subpíxel llegan al renderer.
        local calls={}
        love.graphics.draw=function(...) calls[#calls+1]={...} end
        resources:portrait("rudeus","neutral",4.8,5.6,2.75)
        resources:icon("listen",4.8,5.6,2.75)
        resources:cardBase(4.8,5.6,2.75)
        resources:cardFrame("empathy",4.8,5.6,2.75)
        resources:cardBack(4.8,5.6,2.75)
        love.graphics.draw=originalDraw
        check(calls[1][3]==4 and calls[1][4]==5 and calls[1][6]==2 and calls[1][7]==2,"Retratos a escala y posición enteras")
        for i=2,#calls do
            check(calls[i][2]==4 and calls[i][3]==5 and calls[i][5]==2 and calls[i][6]==2,"Capas a escala y posición enteras")
        end
        -- Los colores detectan cuadros cambiados incluso con expresiones iguales.
        local path=Assets.characters.rudeus
        local colors={{1,0,0,1},{0,1,0,1},{0,0,1,1},{1,1,0,1}}
        local pixels=love.image.newImageData(256,64)
        pixels:mapPixel(function(x) return unpack(colors[math.floor(x/64)+1]) end)
        local png=pixels:encode("png")
        love.graphics.newImage=function(candidate,...)
            if candidate==path then
                local img=originalImage(png); img:setFilter("linear","linear"); return img
            end
            return originalImage(candidate,...)
        end
        resources=Resources.new()
        for index,expression in ipairs({"neutral","happy","worried","angry"}) do
            local r,g,b,a=renderPortrait("rudeus",expression):getPixel(4,4)
            local color=colors[index]
            check(r==color[1] and g==color[2] and b==color[3] and a==1,"Orden horizontal fijo: "..expression)
        end
        local r,g,b=renderPortrait("rudeus","desconocida"):getPixel(4,4)
        check(r==1 and g==0 and b==0,"Expresión desconocida utiliza neutral")
        local min,mag=resources.portraits.rudeus:getFilter()
        check(min=="nearest" and mag=="nearest","El cargador fuerza nearest")
        local wrongSize=love.image.newImageData(1,1):encode("png")
        local corrupt=love.filesystem.newFileData("invalid PNG","invalid.png")
        local failingPath,mode
        love.filesystem.getInfo=function(candidate,...)
            if candidate==failingPath and mode=="missing" then return nil end
            return originalInfo(candidate,...)
        end
        love.graphics.newImage=function(candidate,...)
            if candidate==failingPath then return originalImage(mode=="wrong_size" and wrongSize or corrupt) end
            return originalImage(candidate,...)
        end
        local cases={
            {path=Assets.characters.rudeus,w=256,h=64,get=function(res) return res:getPortrait("rudeus") end},
            {path=Assets.backgrounds.library,w=320,h=180,get=function(res) return res:getBackground("library") end},
            {path=Assets.cardIcons.listen,w=24,h=24,get=function(res) return res:getIcon("listen") end},
            {path=Assets.cardFrames.empathy,w=80,h=112,get=function(res) return res:getCardFrame("empathy") end},
        }
        for _,case in ipairs(cases) do
            failingPath=case.path
            for _,variant in ipairs({"missing","wrong_size","corrupt"}) do
                mode=variant
                resources=Resources.new()
                local fallback=case.get(resources)
                check(fallback:typeOf("Canvas"),"Reserva sin cierre: "..variant.."/"..failingPath)
                local w,h=fallback:getDimensions()
                check(w==case.w and h==case.h,"Reserva mantiene dimensiones esperadas")
                check(resources.sources[failingPath].status=="fallback" and resources.sources[failingPath].reason,
                    "La reserva conserva diagnóstico consultable")
                check(#resources.warnings==1 and resources.warnings[1]:find(failingPath,1,true),"Diagnóstico identifica la ruta")
                check(case.get(resources)==fallback and #resources.warnings==1,"No repetir carga ni avisos por fotograma")
            end
        end
        love.filesystem.getInfo,love.graphics.newImage=originalInfo,originalImage
        resources=Resources.new()
        resources:getBackground("unknown_scene")
        check(#resources.warnings==1 and resources.sources["unmapped:background:unknown_scene"].status=="fallback",
            "Un ID no registrado se diagnostica sin fingir un escenario definitivo")
    end,debug.traceback)
    love.filesystem.getInfo,love.graphics.newImage,love.graphics.draw=originalInfo,originalImage,originalDraw
    love.graphics.setCanvas(); love.graphics.pop()
    assert(ok,err)
    print("Resources: "..count.." checks passed (42 real PNGs, mappings, expressions, transparency and diagnosed fallbacks).")
    return count
end
return Suite
