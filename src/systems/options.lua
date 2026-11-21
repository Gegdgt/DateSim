-- Preferencias globales, independientes de los eventos de una partida.
-- `volume` conserva el nombre usado por los guardados de la Fase 1.
local Options = {}
Options.defaults = {
    volume=.6, musicVolume=.45, effectsVolume=.55, muted=false,
    textSpeed=50, textAnimation=true, reducedMotion=false, fullscreen=false, tutorialCompleted=false,
}

local function number(value, fallback, minimum, maximum)
    if type(value)~="number" or value~=value or value==math.huge or value==-math.huge then return fallback end
    return math.max(minimum,math.min(maximum,value))
end

function Options.normalize(value)
    value=type(value)=="table" and value or {}
    local d=Options.defaults
    return {
        volume=number(value.volume,d.volume,0,1),
        musicVolume=number(value.musicVolume,d.musicVolume,0,1),
        effectsVolume=number(value.effectsVolume,d.effectsVolume,0,1),
        muted=value.muted==true,
        textSpeed=number(value.textSpeed,d.textSpeed,15,100),
        textAnimation=value.textAnimation~=false,
        reducedMotion=value.reducedMotion==true,
        fullscreen=value.fullscreen==true,
        tutorialCompleted=value.tutorialCompleted==true,
    }
end

return Options
