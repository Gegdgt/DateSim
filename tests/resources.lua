-- Pruebas de recorte con un PNG real generado en memoria; no modifica assets.
local Suite={}
function Suite.run()
    local Resources=require("src.systems.resources")
    local Characters=require("src.data.characters")
    local count=0
    local function check(ok,message) count=count+1; assert(ok,message) end
    local originalInfo,originalImage=love.filesystem.getInfo,love.graphics.newImage
    local path="assets/characters/rudeus.png"
    local colors={{1,0,0,1},{0,1,0,1},{0,0,1,1},{1,1,0,1}}
    local pixels=love.image.newImageData(256,64)
    pixels:mapPixel(function(x) return unpack(colors[math.floor(x/64)+1]) end)
    local png=pixels:encode("png")
    local oldPng=love.image.newImageData(384,128):encode("png")
    local mode="valid"
    love.filesystem.getInfo=function(candidate,...)
        if candidate==path then return mode~="missing" and {type="file"} or nil end
        return originalInfo(candidate,...)
    end
    love.graphics.newImage=function(candidate,...)
        if candidate==path then
            local file=mode=="invalid_size" and oldPng or png
            if mode=="corrupt" then file=love.filesystem.newFileData("invalid PNG","invalid.png") end
            local img=originalImage(file)
            img:setFilter("linear","linear") -- El cargador debe sustituirlo por nearest.
            return img
        end
        return originalImage(candidate,...)
    end
    love.graphics.push("all")
    local ok,err=xpcall(function()
        local resources=Resources.new()
        local target=love.graphics.newCanvas(72,72)
        local function render(expression)
            love.graphics.setCanvas(target)
            love.graphics.origin()
            love.graphics.clear(0,0,0,0)
            resources:portrait("rudeus",expression,4,4,1)
            love.graphics.setCanvas()
            return target:newImageData()
        end
        for index,expression in ipairs({"neutral","happy","worried","angry"}) do
            local result=render(expression)
            local r,g,b,a=result:getPixel(4,4)
            local color=colors[index]
            check(r==color[1] and g==color[2] and b==color[3] and a==1,"Seleccionar cuadro: "..expression)
            local x,y,w,h=resources.quads[index-1]:getViewport()
            check(x==(index-1)*64 and y==0 and w==64 and h==64,"Recorte 64x64: "..expression)
            local _,_,_,inside=result:getPixel(67,67)
            local _,_,_,outside=result:getPixel(68,67)
            check(inside==1 and outside==0,"No invadir el siguiente cuadro: "..expression)
        end
        local r,g,b=render("desconocida"):getPixel(4,4)
        check(r==1 and g==0 and b==0,"Expresión desconocida utiliza neutral")
        local min,mag=resources.portraits.rudeus:getFilter()
        check(min=="nearest" and mag=="nearest","PNG cargado utiliza nearest")
        for _,variant in ipairs({"missing","invalid_size","corrupt"}) do
            mode=variant
            resources=Resources.new()
            render("angry")
            local w,h=resources.portraits.rudeus:getDimensions()
            check(w==256 and h==64,"Fallback con hoja 256x64: "..variant)
            check(resources.portraits.rudeus:typeOf("Canvas"),"Usar dibujo provisional: "..variant)
        end
        for _,character in ipairs(Characters.list) do
            resources:portrait(character.id,"worried",0,0,1)
            local w,h=resources.portraits[character.id]:getDimensions()
            check(w==256 and h==64,"Dimensiones de "..character.id)
        end
    end,debug.traceback)
    love.graphics.setCanvas()
    love.graphics.pop()
    love.filesystem.getInfo,love.graphics.newImage=originalInfo,originalImage
    assert(ok,err)
    print("Resources: "..count.." checks passed (64x64 frames, PNG and fallback).")
end
return Suite
