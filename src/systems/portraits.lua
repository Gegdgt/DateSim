-- Reconstrucción visual pura a partir de la escena y la línea guardadas.
-- No se conserva estado entre escenas ni se ejecutan efectos narrativos.
local Characters=require("src.data.characters")
local Appearances=require("src.data.appearances")
local Portraits={}

function Portraits.resolve(scene,index)
    local context=Appearances.contexts[scene.context] or {}
    local function appearance(character)
        return (scene.portraits or {})[character] or (context.portraits or {})[character] or character
    end
    index=math.max(1,math.min(#scene.lines,math.floor(tonumber(index) or 1)))
    local line=scene.lines[index]
    local result={background=scene.background or context.background or "courtyard",cast={}}
    if not scene.cast then
        local character=Characters.byId[line.speaker] and line.speaker or "rudeus"
        result.cast[1]={character=character,portrait=line.portrait or appearance(character),
            expression=(type(line.animation)=="table" and line.animation.expression) or line.expression or "neutral",
            position="left",visible=true,animation=line.animation}
        return result
    end
    local byId={}
    for _,entry in ipairs(scene.cast) do
        local actor={character=entry.character,portrait=appearance(entry.character),
            expression=entry.expression or "neutral",position=entry.position or "left",visible=false,
            enterAt=entry.enterAt or 1,entranceDelay=entry.entranceDelay or 0}
        result.cast[#result.cast+1]=actor; byId[actor.character]=actor
    end
    for current=1,index do
        for _,actor in ipairs(result.cast) do
            actor.animation=nil
            if current==actor.enterAt then actor.visible=true end
        end
        local item=scene.lines[current]
        local speaker=byId[item.speaker]
        if speaker then
            speaker.expression=(type(item.animation)=="table" and item.animation.expression) or item.expression or speaker.expression
            speaker.portrait=item.portrait or speaker.portrait
            speaker.animation=item.animation
        end
        for character,change in pairs(item.stage or {}) do
            local actor=byId[character]
            if actor then
                actor.portrait=change.portrait or actor.portrait
                actor.expression=(type(change.animation)=="table" and change.animation.expression) or change.expression or actor.expression
                if change.visible~=nil then actor.visible=change.visible end
                actor.animation=change.animation or actor.animation
            end
        end
    end
    return result
end

return Portraits
