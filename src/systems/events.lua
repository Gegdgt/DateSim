local Relationships = require("src.systems.relationships")
local Events = {}

-- Un evento persistido nunca vuelve a conceder puntos o cartas al cargar.
function Events.apply(session, id, effects)
    assert(type(id) == "string", "El evento necesita identificador")
    session.events = session.events or {}
    if session.events[id] then return false end
    effects = effects or {}
    session.decisions = session.decisions or {}
    session.unlocked = session.unlocked or {}
    if effects.character and session.relationships[effects.character] then
        Relationships.apply(session.relationships, effects.character, {
            trust=effects.trust or 0, chemistry=effects.chemistry or 0,
        })
        if effects.relationshipEvent then
            Relationships.complete(session.relationships, effects.character, effects.relationshipEvent)
        end
        if effects.decision then
            local relationship = session.relationships[effects.character]
            relationship.decisions = relationship.decisions or {}
            relationship.decisions[effects.decision] = effects.value
        end
    end
    if effects.decision then session.decisions[effects.decision] = effects.value end
    for _, cardId in ipairs(effects.unlock or {}) do session.unlocked[cardId] = true end
    session.events[id] = true
    return true
end

return Events
