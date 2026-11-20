-- Avance explícito: una llamada mueve exactamente una línea.
local Dialogue = {}
Dialogue.__index = Dialogue

function Dialogue.new(scene, index)
    assert(type(scene) == "table" and type(scene.lines) == "table" and #scene.lines > 0,
        "La escena necesita al menos una línea")
    local first = tonumber(index) or 1
    first = math.max(1, math.min(#scene.lines, math.floor(first)))
    return setmetatable({scene=scene, index=first, ended=false}, Dialogue)
end

function Dialogue:current()
    return self.scene.lines[self.index]
end

function Dialogue:isLast()
    return self.index == #self.scene.lines
end

function Dialogue:advance()
    if self.ended then return true end
    if self.index < #self.scene.lines then
        self.index = self.index + 1
        return false
    end
    self.ended = true
    return true
end

return Dialogue
