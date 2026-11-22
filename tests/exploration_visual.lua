-- Superposiciones de QA; nunca reescribe los PNG de assets ni exporta los ASE.
local Suite={}
function Suite.run()
    local Maps=require("src.data.maps")
    local Connections=require("src.data.map_connections")
    local Resources=require("src.systems.resources").new()
    local validation=require("src.systems.map_validation").validate(Maps,Connections)
    assert(validation.ok,table.concat(validation.errors,"\n"))
    local walk=assert(Resources:getExploration("overworld","rudeus"))
    local rows={down=0,left=1,right=2,up=3}
    local font=love.graphics.newFont(11)
    love.graphics.push("all")
    love.graphics.setFont(font)
    for id,map in pairs(Maps) do
        local canvas=love.graphics.newCanvas(map.width,map.height+32)
        love.graphics.setCanvas(canvas);love.graphics.origin();love.graphics.clear(0,0,0,1)
        love.graphics.setColor(1,1,1,1);love.graphics.draw(assert(Resources:getExploration("maps",id)))
        love.graphics.setColor(0,.6,1,.12)
        for _,r in ipairs(map.collisions.walkable) do love.graphics.rectangle("fill",r.x,r.y,r.w,r.h) end
        local drawn={}
        for _,p in pairs(map.spawnPoints) do
            local key=p.x..":"..p.y
            if not drawn[key] then
                drawn[key]=true
                local q=love.graphics.newQuad(0,rows[p.facing]*32,24,32,96,128)
                love.graphics.setColor(1,1,1,1);love.graphics.draw(walk,q,p.x-12,p.y-32)
                love.graphics.setColor(0,1,.7,1);love.graphics.rectangle("line",p.x-6,p.y-8,12,8)
                q:release()
            end
        end
        for _,link in ipairs(Connections.links) do
            for _,a in ipairs({link.a,link.b}) do
                if a.map==id and a.trigger then
                    local r=a.trigger
                    love.graphics.setColor(1,link.enabled and 1 or .3,0,1)
                    love.graphics.rectangle("line",r.x+.5,r.y+.5,r.w-1,r.h-1)
                end
            end
        end
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(id.." | cyan: suelo revisado; verde: pies",4,map.height+1)
        love.graphics.print(id=="universidad_exterior" and "Acceso izquierdo: PENDIENTE (sin coordenadas)" or "Amarillo: portal; naranja: extremo de enlace pendiente",4,map.height+16)
        love.graphics.setCanvas()
        local data=canvas:newImageData()
        local bytes=data:encode("png")
        local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/exploration-"..id..".png","wb"))
        file:write(bytes:getString());file:close()
        data:release();bytes:release();canvas:release()
    end
    love.graphics.pop();font:release()
    local payload={maps=Maps,connections=Connections,validation=validation}
    local json=assert(require("src.systems.json").encode(payload))
    local record=assert(io.open(love.filesystem.getSource().."/tests/artifacts/exploration-map-review.json","wb"))
    record:write(json);record:close()
    print("Exploration visual: 14 annotated map captures in tests/artifacts/exploration-*.png.")
end
return Suite
