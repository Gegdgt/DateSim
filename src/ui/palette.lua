-- Paleta compartida; los valores están normalizados para LÖVE 11.
local function rgb(hex)
    return {tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255, 1}
end
return {
    bg = rgb("101828"), panel = rgb("19283B"), panelLight = rgb("283C50"),
    ink = rgb("F8EDD7"), muted = rgb("B5BAC4"), gold = rgb("E8BC73"),
    teal = rgb("80C8BE"), rose = rgb("E2A4A1"), lavender = rgb("B2A5D1"),
    border = rgb("51637B"), shadow = rgb("0B1322"), danger = rgb("D77A85"),
    green = rgb("A0C395"), white = rgb("FFFFFF"),
}
