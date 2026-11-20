-- Todos los atajos del motor se editan aquí.
return {
    advance = { "return", "space", "kpenter" },
    back = { "escape" },
    journal = { "j" },
    deck = { "m" },
    save = { "f5" },
    fullscreen = { "f11" },
    freeAction = { "p" },
    cards = { "1", "2", "3" },
    nextButton = { "tab", "down" },
    previousButton = { "up" },
    nextCard = { "right" },
    previousCard = { "left" },
    matches = function(keys, key)
        for _, candidate in ipairs(keys) do if candidate == key then return true end end
        return false
    end,
}
