-- Fuente bitmap original 5x7. No requiere TTF, red ni archivos adicionales.
-- Caja de línea: 11 px. El español conserva sus tildes y signos de apertura.
local Font = {lineHeight = 11, advance = 6}
local glyphs = {}
local function add(char, rows)
    local bitmap = {}
    for row in rows:gmatch("[^/]+") do bitmap[#bitmap + 1] = row end
    glyphs[char] = bitmap
end
local patterns = {
    A="01110/10001/10001/11111/10001/10001/10001", B="11110/10001/10001/11110/10001/10001/11110",
    C="01111/10000/10000/10000/10000/10000/01111", D="11110/10001/10001/10001/10001/10001/11110",
    E="11111/10000/10000/11110/10000/10000/11111", F="11111/10000/10000/11110/10000/10000/10000",
    G="01111/10000/10000/10111/10001/10001/01110", H="10001/10001/10001/11111/10001/10001/10001",
    I="11111/00100/00100/00100/00100/00100/11111", J="00111/00010/00010/00010/10010/10010/01100",
    K="10001/10010/10100/11000/10100/10010/10001", L="10000/10000/10000/10000/10000/10000/11111",
    M="10001/11011/10101/10101/10001/10001/10001", N="10001/11001/11001/10101/10011/10011/10001",
    O="01110/10001/10001/10001/10001/10001/01110", P="11110/10001/10001/11110/10000/10000/10000",
    Q="01110/10001/10001/10001/10101/10010/01101", R="11110/10001/10001/11110/10100/10010/10001",
    S="01111/10000/10000/01110/00001/00001/11110", T="11111/00100/00100/00100/00100/00100/00100",
    U="10001/10001/10001/10001/10001/10001/01110", V="10001/10001/10001/10001/10001/01010/00100",
    W="10001/10001/10001/10101/10101/10101/01010", X="10001/10001/01010/00100/01010/10001/10001",
    Y="10001/10001/01010/00100/00100/00100/00100", Z="11111/00001/00010/00100/01000/10000/11111",
    ["0"]="01110/10001/10011/10101/11001/10001/01110", ["1"]="00100/01100/00100/00100/00100/00100/01110",
    ["2"]="01110/10001/00001/00010/00100/01000/11111", ["3"]="11110/00001/00001/01110/00001/00001/11110",
    ["4"]="00010/00110/01010/10010/11111/00010/00010", ["5"]="11111/10000/10000/11110/00001/00001/11110",
    ["6"]="01110/10000/10000/11110/10001/10001/01110", ["7"]="11111/00001/00010/00100/01000/01000/01000",
    ["8"]="01110/10001/10001/01110/10001/10001/01110", ["9"]="01110/10001/10001/01111/00001/00001/01110",
    [" "]="00000/00000/00000/00000/00000/00000/00000", ["."]="00000/00000/00000/00000/00000/00110/00110",
    [","]="00000/00000/00000/00000/00110/00100/01000", [":"]="00000/00110/00110/00000/00110/00110/00000",
    [";"]="00000/00110/00110/00000/00110/00100/01000", ["!"]="00100/00100/00100/00100/00100/00000/00100",
    ["?"]="01110/10001/00001/00010/00100/00000/00100", ["¡"]="00100/00000/00100/00100/00100/00100/00100",
    ["¿"]="00100/00000/00100/01000/10000/10001/01110", ["-"]="00000/00000/00000/11111/00000/00000/00000",
    ["+"]="00000/00100/00100/11111/00100/00100/00000", ["="]="00000/00000/11111/00000/11111/00000/00000",
    ["/"]="00001/00001/00010/00100/01000/10000/10000", ["\\"]="10000/10000/01000/00100/00010/00001/00001",
    ["("]="00010/00100/01000/01000/01000/00100/00010", [")"]="01000/00100/00010/00010/00010/00100/01000",
    ["["]="01110/01000/01000/01000/01000/01000/01110", ["]"]="01110/00010/00010/00010/00010/00010/01110",
    ["'"]="00100/00100/01000/00000/00000/00000/00000", ['"']="01010/01010/01010/00000/00000/00000/00000",
    ["<"]="00010/00100/01000/10000/01000/00100/00010", [">"]="01000/00100/00010/00001/00010/00100/01000",
    ["%"]="11001/11010/00010/00100/01000/01011/10011", ["_"]="00000/00000/00000/00000/00000/00000/11111",
    ["*"]="00000/10101/01110/11111/01110/10101/00000", ["#"]="01010/01010/11111/01010/11111/01010/01010",
    ["|"]="00100/00100/00100/00100/00100/00100/00100", ["&"]="01100/10010/10100/01000/10101/10010/01101",
    ["@"]="01110/10001/10111/10101/10111/10000/01110",
    ["·"]="00000/00000/00000/00110/00110/00000/00000", ["…"]="00000/00000/00000/00000/00000/00000/10101",
}
for char, pattern in pairs(patterns) do add(char, pattern) end
local accents = { ["Á"]="A", ["É"]="E", ["Í"]="I", ["Ó"]="O", ["Ú"]="U", ["Ñ"]="N", ["Ü"]="U" }
for char, base in pairs(accents) do
    local rows = {}
    rows[1] = char == "Ñ" and "01010" or (char == "Ü" and "01010" or "00010")
    rows[2] = char == "Ñ" and "10100" or (char == "Ü" and "00000" or "00100")
    for i, row in ipairs(glyphs[base]) do rows[i+2] = row end
    glyphs[char] = rows
end
local upper = { ["á"]="Á", ["é"]="É", ["í"]="Í", ["ó"]="Ó", ["ú"]="Ú", ["ñ"]="Ñ", ["ü"]="Ü" }
local aliases = { ["—"]="-", ["–"]="-", ["‘"]="'", ["’"]="'", ["“"]='"', ["”"]='"', ["«"]='"', ["»"]='"', ["•"]="*", ["→"]=">", ["♥"]="*" }
local function chars(text)
    local result = {}
    for char in tostring(text or ""):gmatch("[%z\1-\127\194-\244][\128-\191]*") do result[#result + 1] = char end
    return result
end
function Font.width(text, scale)
    scale = scale or 1
    local width, maximum = 0, 0
    for _, char in ipairs(chars(text)) do
        if char == "\n" then maximum = math.max(maximum, width); width = 0 else width = width + 6 end
    end
    return math.max(maximum, width) * scale
end
function Font.wrap(text, maxWidth, scale)
    text, scale = tostring(text or ""), scale or 1
    if not maxWidth then
        local lines = {}; for line in (text.."\n"):gmatch("(.-)\n") do lines[#lines+1] = line end
        return lines
    end
    local capacity = math.max(1, math.floor(maxWidth / (6 * scale)))
    local lines = {}
    for paragraph in (text.."\n"):gmatch("(.-)\n") do
        local line = ""
        for word in paragraph:gmatch("%S+") do
            if line ~= "" and Font.width(line.." "..word, 1) > capacity*6 then lines[#lines+1] = line; line = "" end
            local wordChars = chars(word)
            while #wordChars > capacity do
                if line ~= "" then lines[#lines+1] = line; line = "" end
                lines[#lines+1] = table.concat(wordChars, "", 1, capacity)
                local rest = {}; for i=capacity+1,#wordChars do rest[#rest+1] = wordChars[i] end
                wordChars = rest
            end
            word = table.concat(wordChars)
            if word ~= "" then line = line == "" and word or (line.." "..word) end
        end
        lines[#lines+1] = line
    end
    return lines
end
function Font.height(text, maxWidth, scale)
    scale = scale or 1
    return #Font.wrap(text, maxWidth, scale) * Font.lineHeight * scale
end
function Font.draw(text, x, y, opts)
    opts = opts or {}
    local scale = opts.scale or 1
    local color = opts.color or {1,1,1,1}
    love.graphics.setColor(color)
    local lines = Font.wrap(text, opts.maxWidth, scale)
    for rowIndex, line in ipairs(lines) do
        local xx = x
        if opts.maxWidth and opts.align == "center" then xx = x + math.floor((opts.maxWidth - Font.width(line,scale))/2)
        elseif opts.maxWidth and opts.align == "right" then xx = x + opts.maxWidth - Font.width(line,scale) end
        for _, char in ipairs(chars(line)) do
            char = upper[char] or aliases[char] or char:upper()
            local glyph = glyphs[char] or glyphs["?"]
            local top = y + (rowIndex-1)*Font.lineHeight*scale + (#glyph == 9 and 0 or 2*scale)
            for gy, pixels in ipairs(glyph) do
                for gx=1,#pixels do
                    if pixels:sub(gx,gx) == "1" then love.graphics.rectangle("fill", math.floor(xx + (gx-1)*scale), math.floor(top + (gy-1)*scale), scale, scale) end
                end
            end
            xx = xx + 6*scale
        end
    end
    return #lines*Font.lineHeight*scale
end
return Font
