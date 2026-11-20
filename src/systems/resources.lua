-- Recursos sustituibles. Los PNG válidos tienen prioridad; los dibujos de
-- desarrollo se construyen en lienzos de baja resolución y usan nearest.
local Resources = {}
Resources.__index = Resources
local P = require("src.ui.palette")
local Characters = require("src.data.characters")
local Assets = require("src.data.assets")
local SPRITE_WIDTH = Characters.spriteWidth
local SPRITE_HEIGHT = Characters.spriteHeight
local EXPRESSIONS = Characters.expressions
local SHEET_WIDTH = SPRITE_WIDTH * Characters.expressionCount
local BACKGROUND_WIDTH,BACKGROUND_HEIGHT=unpack(Assets.sizes.background)
local CARD_WIDTH,CARD_HEIGHT=unpack(Assets.sizes.card)
local ICON_WIDTH,ICON_HEIGHT=unpack(Assets.sizes.icon)
local function color(hex)
    if type(hex) == "table" then love.graphics.setColor(hex); return end
    love.graphics.setColor(tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255,1)
end
local function r(c,x,y,w,h) color(c); love.graphics.rectangle("fill",math.floor(x),math.floor(y),math.floor(w),math.floor(h)) end
local function poly(c,points)
    local snapped={};for i,value in ipairs(points) do snapped[i]=math.floor(value) end
    color(c);love.graphics.polygon("fill",snapped)
end
local function pixelLine(c,x1,y1,x2,y2,width)
    local dx,dy=x2-x1,y2-y1; local steps=math.max(math.abs(dx),math.abs(dy))
    for n=0,steps do local t=steps==0 and 0 or n/steps; r(c,math.floor(x1+dx*t),math.floor(y1+dy*t),width or 1,width or 1) end
end
local function canvas(w,h,draw)
    local c=love.graphics.newCanvas(w,h); c:setFilter("nearest","nearest")
    love.graphics.push("all"); love.graphics.setCanvas(c); love.graphics.origin(); love.graphics.clear(0,0,0,0)
    draw(); love.graphics.setCanvas(); love.graphics.pop()
    return c
end
local function image(path,w,h)
    if not path then return nil,"identificador sin entrada en src/data/assets.lua" end
    if not love.filesystem.getInfo(path,"file") then return nil,"archivo inexistente" end
    local ok,img=pcall(love.graphics.newImage,path)
    if not ok then return nil,"PNG inválido: "..tostring(img) end
    if img:getWidth()~=w or img:getHeight()~=h then
        local reason=string.format("dimensiones %dx%d; se esperaban %dx%d",img:getWidth(),img:getHeight(),w,h)
        img:release()
        return nil,reason
    end
    img:setFilter("nearest","nearest")
    return img
end
local function stars()
    for i=1,24 do local x=(i*53+19)%320; local y=(i*17)%73; r("CAC1CB",x,y,1,1) end
end
local function sky()
    r("66778F",0,0,320,180); r("7D8D9E",0,26,320,35); r("A4A4AC",0,61,320,37); r("D5BCAD",0,98,320,82)
    r("EAD5BA",251,19,17,13); r("EAD5BA",253,17,13,17); r("EAD5BA",255,15,9,21)
    r("ADB0BA",15,32,41,4); r("ADB0BA",22,29,21,4); r("BDC0C5",205,48,46,3)
    stars()
end
local function tree(x,y,s)
    s=s or 1
    r("3C4D48",x+12*s,y+21*s,5*s,39*s)
    r("4B6157",x+10*s,y+33*s,2*s,12*s)
    r("3C5A56",x,y+13*s,30*s,18*s);r("3C5A56",x+5*s,y+3*s,21*s,34*s)
    r("4F7768",x+2*s,y+8*s,24*s,18*s);r("4F7768",x+7*s,y,17*s,30*s)
    r("71957B",x+7*s,y+5*s,10*s,5*s);r("71957B",x+3*s,y+14*s,7*s,4*s)
    r("658771",x+15*s,y+12*s,9*s,6*s); r("80A085",x+10*s,y+2*s,6*s,2*s)
end
local function window(x,y,w,h,lit)
    r("354454",x,y,w,h);r("354454",x+2,y-3,w-4,3)
    r(lit and "DDBB81" or "8EA9B3",x+2,y+1,w-4,h-3)
    r("596477",x+math.floor(w/2),y,1,h);r("596477",x+1,y+math.floor(h/2),w-2,1)
    r("D9C7AC",x-1,y+h,w+2,2)
end
local function brickWall(x,y,w,h,base)
    r(base or "9A9693",x,y,w,h)
    for yy=y+8,y+h-1,9 do
        r("777B81",x,yy,w,1)
        for xx=x+(math.floor(yy/9)%2)*9,x+w-1,19 do r("777B81",xx,yy-8,1,8) end
    end
end
local function path()
    r("536B66",0,132,320,48)
    poly("B5AA99",{142,129,181,129,232,180,85,180})
    for i=1,28 do local x=(i*37)%320;local y=136+(i*13)%44;r("748573",x,y,3,1) end
    for i=0,4 do local yy=138+i*9; r("8B9089",139-i*10,yy,49+i*21,1) end
end
local function courtyard()
    sky(); r("566D76",0,84,320,48)
    brickWall(50,69,220,68,"A7A09B")
    poly("414B67",{39,72,59,46,265,46,283,72});r("66708A",53,54,215,3);r("8991A2",60,48,202,2)
    brickWall(136,39,50,97,"B5AAA1")
    poly("3C4965",{128,42,161,10,195,42});poly("667A8B",{140,37,161,15,180,37})
    r("E1C496",159,4,3,12);r("D9B982",160,5,16,5)
    for _,x in ipairs({65,91,215,241}) do window(x,80,13,22,true);window(x,111,13,17,false) end
    window(151,48,19,24,true)
    r("CBBDA7",143,86,36,48); r("494B5D",147,90,28,44); r("494B5D",151,86,20,5)
    r("6B6670",151,94,20,40);r("C6A77C",160,91,2,43);r("E4C69C",154,114,2,2)
    r("D0BDA5",132,133,58,4);r("AAA79F",127,137,68,4)
    path();r("CDC1AB",127,136,68,3)
    tree(6,70,1.3);tree(276,70,1.3)
    for _,x in ipairs({43,211}) do
        r("384F4B",x,145,69,8);r("81937B",x+2,143,65,4)
        for i=1,10 do local xx=x+i*6;r(i%2==0 and "D5A5B4" or "E4C797",xx,141-(i%3),2,3) end
    end
    pixelLine("5E6575",22,54,112,69);pixelLine("5E6575",208,69,303,54)
    for i=0,7 do local xx=26+i*12;local yy=55+i*2;poly(i%2==0 and "BA8A96" or "C4B394",{xx,yy,xx+7,yy+1,xx+4,yy+10}) end
    for i=0,7 do local xx=212+i*12;local yy=68-i*2;poly(i%2==0 and "8BAEA1" or "BCACCA",{xx,yy,xx+7,yy-1,xx+4,yy+8}) end
end
local function floorTiles()
    r("6C6A73",0,129,320,51)
    for yy=133,180,12 do r("515765",0,yy,320,1) end
    for i=0,8 do pixelLine("515765",i*40,130,(i-4)*55+160,180) end
end
local function bookcase(x,y,w,h)
    r("322F42",x,y,w,h);r("746271",x,y,4,h);r("746271",x+w-4,y,4,h)
    for row=0,3 do
        local yy=y+6+row*25
        for i=0,math.floor((w-10)/6)-1 do
            local colors={"A3808A","78958F","9D9CAD","B49E7D","6E7E98"}
            local bh=13+(i*7+row*3)%8
            r(colors[(i+row)%5+1],x+6+i*6,yy+20-bh,4,bh)
            r("CAB59C",x+6+i*6,yy+23-bh,4,1)
        end
        r("9A7F7A",x+4,yy+20,w-8,3);r("463F50",x+4,yy+23,w-8,2)
    end
end
local function candle(x,y)
    r("D3BD8B",x,y+4,3,10);r("F4D99A",x+1,y+1,1,4);r("D19776",x,y+2,3,3);r("F3DDA1",x+1,y+2,1,2)
    r("91785F",x-2,y+14,7,2)
end
local function library()
    r("53566E",0,0,320,180);r("6B697E",16,0,288,130)
    r("A39591",0,0,320,9);r("8C8285",0,9,320,3)
    for _,x in ipairs({10,105,209,305}) do r("807D89",x,12,6,120);r("B1A79D",x-2,12,10,4) end
    bookcase(20,20,73,106); bookcase(226,20,73,106)
    r("343E56",121,19,77,96);r("343E56",130,11,59,10)
    r("7D94AC",126,23,67,87);r("C3C2BD",157,18,4,94);r("C3C2BD",125,64,69,4)
    r("859EB3",128,28,27,30);r("B6BFC4",165,72,25,32)
    r("D9D0B8",117,112,86,5);r("B1A29C",114,117,92,4)
    floorTiles();r("796473",81,144,166,36);r("B69C98",85,146,158,2);r("B69C98",85,176,158,2)
    r("4B4255",102,136,7,34);r("4B4255",213,136,7,34)
    r("574858",94,130,134,12);r("B39986",94,127,134,5);r("CFB79A",96,127,130,2)
    r("DBD0AD",136,121,31,5);r("EADABD",139,118,27,4);r("9C9183",151,119,1,7)
    r("637C82",184,122,15,4);r("C0AD97",184,123,15,1);candle(115,112);candle(208,111)
    pixelLine("B1A181",160,0,160,28,2);r("B8A381",145,27,32,3);candle(147,13);candle(172,13)
    r("A8A6AD",33,163,11,2);r("A8A6AD",268,161,18,2)
end
local function mirror(x,y)
    r("A79094",x+6,y,49,5);r("A79094",x,y+6,61,74);r("A79094",x+6,y+80,49,5)
    r("D4BB96",x+8,y+4,45,3);r("D4BB96",x+4,y+8,3,68);r("D4BB96",x+54,y+8,3,68);r("D4BB96",x+8,y+78,45,3)
    r("365567",x+8,y+8,45,68);r("4A7280",x+12,y+12,37,60)
    r("77959A",x+16,y+16,29,52);r("9BB3AA",x+20,y+21,21,43)
    pixelLine("D5D8BD",x+37,y+12,x+23,y+31,2);pixelLine("D5D8BD",x+23,y+31,x+32,y+45,2);pixelLine("D5D8BD",x+32,y+45,x+19,y+69,2)
    r("405C6B",x+7,y+85,47,4);r("968A8D",x+10,y+89,6,14);r("968A8D",x+45,y+89,6,14)
end
local function laboratory()
    r("343F57",0,0,320,180);brickWall(0,12,320,118,"626C7E")
    r("303D56",0,0,320,12);r("B1A596",0,10,320,2)
    r("35455E",117,20,86,112);r("465774",123,24,74,108)
    mirror(130,34);floorTiles()
    r("536777",102,142,117,21);r("7D9F9F",110,141,101,2);r("7D9F9F",110,161,101,2)
    pixelLine("91B7AE",111,144,209,158);pixelLine("91B7AE",111,158,209,144)
    for _,x in ipairs({18,239}) do
        r("463E54",x,113,65,8);r("A18C86",x,110,65,4);r("463E54",x+4,120,5,27);r("463E54",x+56,120,5,27)
        for i=0,2 do
            local xx=x+10+i*19;r("A9B9BB",xx,89+i%2*4,9,20-i%2*4);r("79A99F",xx+1,100,7,8);r("CFBDA6",xx+3,85+i%2*4,3,5)
        end
    end
    bookcase(21,26,64,77);r("646C7D",21,101,64,9)
    r("B8B298",235,29,60,58);r("D9CDB4",238,32,54,52)
    for i=0,4 do pixelLine("8C958C",244,39+i*8,284-(i%3)*6,39+i*8) end
    r("BE9497",257,49,12,13);r("DCC7AF",260,52,6,7)
    for i=1,14 do r("A8CBB7",110+(i*17)%100,25+(i*23)%100,1,1) end
end
local function garden()
    sky();r("647F76",0,98,320,82)
    brickWall(0,80,320,43,"A0AAA0");r("CED0BB",0,78,320,4)
    for _,x in ipairs({68,134,200}) do
        r("617F7D",x,87,38,35);r("617F7D",x+4,83,30,4)
        r("A9B3A1",x-4,85,4,43);r("A9B3A1",x+38,85,4,43)
    end
    tree(-5,25,2);tree(264,29,2)
    poly("BAB6A1",{132,122,187,122,239,180,79,180})
    r("526C6E",128,145,65,13);r("A9B5AD",125,142,71,10);r("CEE0C9",130,141,61,3)
    r("8EAAAC",133,144,56,4);r("B6C7BC",154,122,13,23);r("D3D7BF",149,119,23,5)
    r("8EB8B8",157,109,6,11);r("D0E1CD",159,106,2,19);r("93BBB9",146,125,3,11);r("93BBB9",173,125,3,11)
    for i=0,23 do local x=(i*29)%320;local y=132+(i*17)%44
        if x<95 or x>235 then r("4E725B",x,y,1,5);r(i%3==0 and "D6B58D" or "D49BA8",x-1,y-1,3,2) end
    end
    r("4F6266",29,141,54,5);r("A6AAA0",29,132,54,7);r("4F6266",32,146,4,12);r("4F6266",76,146,4,12)
    r("A6AAA0",30,141,53,2)
end
local function training()
    sky();r("668177",0,93,320,48);r("BAAE95",0,132,320,48)
    brickWall(0,100,320,29,"969F98");r("CCD0BA",0,98,320,3)
    tree(20,43,1);tree(279,45,1)
    for _,x in ipairs({82,222}) do
        r("5C6668",x+11,112,4,43);r("5C6668",x+1,153,25,3)
        r("6F6969",x,94,28,29);r("C8B697",x+3,97,22,23)
        r("B0837A",x+7,101,14,15);r("E2CBA0",x+10,104,8,9);r("AA796E",x+12,106,4,5)
    end
    r("57636A",21,145,46,4);r("57636A",24,128,3,36);r("57636A",61,128,3,36)
    for i=0,3 do local x=28+i*9;pixelLine("BEC4B7",x,153,x+4,122,2);r("9C8677",x-2,145,7,3) end
    for i=0,30 do r("968F83",(i*37)%320,137+(i*11)%43,3,1) end
    pixelLine("D5C7A7",125,149,194,149);pixelLine("D5C7A7",120,153,199,153);pixelLine("D5C7A7",120,166,199,166)
    r("A48E87",138,160,42,1)
end
local function ruins()
    r("526B76",0,0,320,180);r("718D8C",0,57,320,123)
    for i=0,8 do tree(i*42-10,25+(i%3)*10,1.5) end
    r("526E62",0,122,320,58);poly("89968B",{132,112,190,112,224,180,93,180})
    for _,x in ipairs({86,203}) do
        brickWall(x,35,31,110,"8D9B94");r("BBC4AF",x-5,29,41,7);r("586F6B",x-3,142,38,5)
        r("B9C1AE",x+5,38,3,96);r("5A7D64",x+22,43,8,23);r("5A7D64",x+17,65,7,18)
    end
    brickWall(108,30,97,19,"9EA99D");r("BCC5B0",111,25,89,5)
    r("4B6868",120,52,79,75);r("647D78",126,57,67,66)
    for i=1,7 do r("8BA395",128+i*8,64+(i%2)*5,2,8) end
    r("617A74",137,125,45,19);r("B2BDA8",133,121,53,5)
    r("B7A77D",151,107,17,14);r("E0D4A8",154,104,11,18);r("84A997",157,108,5,9)
    for i=1,15 do local x=(i*47)%320;local y=143+(i*13)%36;r("657A6C",x,y,10,5);r("8D9D83",x+2,y,7,1) end
    r("405E57",20,170,61,10);r("405E57",245,167,75,13)
end
local backgrounds={courtyard=courtyard,library=library,laboratory=laboratory,garden=garden,training=training,ruins=ruins}

local profiles={
    rudeus={hair="9C7954",light="C3A174",shade="674E3E",coat="697B6E",trim="CAB48F",eyes="578B78",style="short"},
    sylphiette={hair="DFDDD0",light="F8EDDA",shade="A9B6B0",coat="6E9E90",trim="DCD2B4",eyes="B55F72",style="elf"},
    roxy={hair="7288BB",light="9CAED3",shade="48577F",coat="606D97",trim="C7B7C6",eyes="6389AE",style="witch"},
    eris={hair="B6535A",light="DA7A70",shade="773C4F",coat="E0D1BB",trim="A45259",eyes="A54D52",style="long"},
    nanahoshi={hair="373544",light="60536A",shade="262B3D",coat="83788D",trim="DBCCC3",eyes="776B8B",style="long"},
    zanoba={hair="A68F66",light="D4BB89",shade="736950",coat="63807B",trim="DDC08E",eyes="667A6D",style="noble"},
    cliff={hair="735845",light="A27B57",shade="4E3F3F",coat="4C566D",trim="B8A4AE",eyes="777D70",style="glasses"},
}
local function portrait(id,expression)
    -- Adapta el boceto provisional a 64x64 con proporciones uniformes.
    -- Cada trazo se rasteriza a píxeles enteros, sin estirar ni recortar la cara.
    local drawRect,drawPolygon,drawLine=r,poly,pixelLine
    local function r(c,x,y,w,h)
        local left,top=math.floor(x/2),math.floor(y/2)
        drawRect(c,left+8,top,math.max(1,math.floor((x+w)/2)-left),math.max(1,math.floor((y+h)/2)-top))
    end
    local function poly(c,points)
        local scaled={}
        for i,value in ipairs(points) do scaled[i]=math.floor(value/2)+(i%2==1 and 8 or 0) end
        drawPolygon(c,scaled)
    end
    local function pixelLine(c,x1,y1,x2,y2,width)
        drawLine(c,math.floor(x1/2)+8,math.floor(y1/2),math.floor(x2/2)+8,math.floor(y2/2),math.max(1,math.floor((width or 1)/2)))
    end
    local c=profiles[id] or profiles.rudeus; local outline="292D40";local skin="E5BEA3";local skinLight="F2D0B0";local skinShade="C18F83"
    local long=c.style=="long" or c.style=="witch"
    -- Silueta común: cara y hombros se mantienen en la misma posición en los cuatro cuadros.
    r(outline,29,18,38,7);r(outline,24,25,48,long and 77 or 43)
    r(c.shade,27,27,42,long and 74 or 41);r(c.hair,28,24,40,41)
    if long then
        r(c.hair,23,43,11,56);r(c.hair,64,42,10,58);r(c.light,25,46,3,40);r(c.shade,68,59,4,42)
    end
    r(outline,19,87,58,41);r(outline,11,97,74,31);r(c.coat,17,95,62,33);r(c.coat,23,86,50,42)
    r(c.shade,14,103,5,25);r(c.trim,20,93,5,35);r(c.trim,71,93,5,35)
    r(skinShade,38,69,20,23);r(skin,40,68,16,18)
    r(skinShade,30,40,36,28);r(skin,32,35,32,34);r(skin,35,67,26,6);r(skinShade,39,73,18,3)
    r(skinLight,35,38,24,24);r(skinLight,38,63,18,7)
    r(skinShade,28,48,4,12);r(skinShade,64,48,4,12);r(skin,28,49,3,7);r(skin,65,49,3,7)
    if c.style=="elf" then
        poly(outline,{18,45,31,49,31,61,25,56});poly(skin,{20,47,31,51,30,58,25,54})
        poly(outline,{78,45,65,49,65,61,71,56});poly(skin,{76,47,65,51,66,58,71,54})
    end
    r(c.hair,29,28,38,12);r(c.hair,28,33,8,17);r(c.hair,59,34,8,13)
    r(c.hair,35,36,9,6);r(c.hair,45,35,9,9);r(c.hair,54,34,6,7)
    r(c.light,32,27,27,3);r(c.light,30,31,5,11);r(c.light,37,32,8,3);r(c.light,51,31,9,3)
    -- Rasgos pequeños con ojos a la misma altura para evitar saltos entre expresiones.
    if expression=="happy" then
        r(outline,35,51,8,2);r(outline,36,49,6,2);r(outline,53,51,8,2);r(outline,54,49,6,2)
        r("DFA39A",34,57,7,2);r("DFA39A",55,57,7,2);r("AE7272",44,64,9,2);r("AE7272",46,66,5,1)
    else
        r(outline,34,48,10,2);r(outline,52,48,10,2);r("FFF0DA",35,50,8,5);r("FFF0DA",53,50,8,5)
        r(c.eyes,38,50,4,5);r(c.eyes,54,50,4,5);r(outline,39,51,2,4);r(outline,55,51,2,4)
        r("FFF4DF",38,50,1,2);r("FFF4DF",54,50,1,2)
        if expression=="worried" then pixelLine(c.shade,34,46,43,44);pixelLine(c.shade,53,44,62,46);r("AE7272",44,66,9,1);r("AE7272",46,65,5,1)
        elseif expression=="angry" then pixelLine(c.shade,34,44,43,47,2);pixelLine(c.shade,53,47,62,44,2);r("9F6D6D",44,65,9,2)
        else r(c.shade,35,45,8,1);r(c.shade,53,45,8,1);r("AE7272",44,65,9,1) end
    end
    r(skinShade,47,55,2,6);r("CD9C8B",48,61,3,1)
    poly(c.trim,{28,86,39,80,47,92,34,102});poly(c.trim,{68,86,57,80,49,92,62,102})
    r(outline,46,91,4,37);r(c.trim,47,93,2,35)
    for y=102,124,10 do r("DFC39A",49,y,2,2) end
    if c.style=="witch" then
        poly(outline,{22,25,32,6,57,2,70,25});poly(c.coat,{26,24,35,9,55,5,65,24})
        r(outline,13,24,70,8);r(c.coat,16,25,64,5);r(c.trim,27,21,40,3);r("DBBA84",52,21,5,4)
        r(c.light,29,63,5,35);r(c.light,63,63,5,35);r(c.trim,27,82,9,4);r(c.trim,61,82,9,4)
    elseif c.style=="glasses" then
        r("C1B7AB",33,48,12,1);r("C1B7AB",33,55,12,1);r("C1B7AB",33,48,1,8);r("C1B7AB",44,48,1,8)
        r("C1B7AB",51,48,12,1);r("C1B7AB",51,55,12,1);r("C1B7AB",51,48,1,8);r("C1B7AB",62,48,1,8);r("C1B7AB",45,50,6,1)
        r(c.trim,43,113,10,2);r(c.trim,47,109,2,11)
    elseif c.style=="noble" then
        r(c.trim,23,97,13,4);r(c.trim,60,97,13,4);r("D7C491",31,105,5,5);r("D7C491",60,105,5,5)
    elseif id=="sylphiette" then
        poly("86B4A4",{29,84,49,91,65,84,61,97,36,100});r("D9CFB4",48,94,7,5);r("76A494",54,98,9,25)
    elseif id=="eris" then
        r(c.trim,25,117,46,8);r("D4AE7E",44,118,9,6);r(outline,47,119,3,4)
    elseif id=="nanahoshi" then
        r("D3C7C3",23,99,12,20);r("8C8191",25,105,8,2);r("8C8191",27,112,5,1)
    end
end

local function icon(id)
    local empathy={listen=true,encourage=true,remember=true,empathy=true}
    local humor={light_joke=true,change_subject=true,self_joke=true,humor=true}
    local honesty={be_honest=true,admit_error=true,share_fear=true,sincerity=true}
    if empathy[id] then
        poly("DAA3A0",{4,6,9,6,12,9,15,6,20,6,20,13,12,21,4,13})
        r("F1C4B3",6,7,4,2);r("F1C4B3",5,9,2,3)
        if id=="remember" then r("E6D09E",16,2,2,6);r("E6D09E",14,4,6,2) end
    elseif humor[id] then
        r("E4C67D",5,4,14,16);r("E4C67D",3,7,18,10);r("F2DB9D",6,5,10,2)
        r("6F5A5C",7,9,2,2);r("6F5A5C",15,9,2,2);r("986F63",7,14,10,2);r("986F63",9,16,6,2)
    elseif honesty[id] then
        poly("B6ABD5",{12,2,21,11,12,22,3,11});poly("E0CBE1",{12,5,18,11,12,18,6,11})
        r("9C8EB6",11,8,2,6);r("9C8EB6",11,16,2,2)
    elseif id=="earth_barrier" then
        poly("AFBE9D",{4,4,12,2,20,4,20,13,16,19,12,22,8,19,4,13});poly("6E998D",{7,6,12,5,17,6,17,12,14,17,12,19,10,17,7,12})
        r("BED1B6",11,7,2,10);r("BED1B6",8,10,8,2)
    elseif id=="sword_magic" then
        pixelLine("CED3CD",5,19,18,4,3);pixelLine("A3B8C2",7,19,20,4);pixelLine("D4B67F",4,13,11,20,2);r("B67274",2,20,4,3)
        r("BCADD8",18,14,2,6);r("BCADD8",16,16,6,2)
    elseif id=="choose_together" then
        r("D6B295",3,9,8,6);r("A2C2B0",13,9,8,6);r("E4D1B0",9,11,6,6);r("F0DAA8",11,2,2,5);r("F0DAA8",9,4,6,1)
    elseif id=="analyze_runes" then
        r("B5C6B5",4,3,16,18);r("708E92",6,5,12,14);pixelLine("CFE0C0",9,7,15,13);pixelLine("CFE0C0",15,7,9,13);r("CFE0C0",11,10,2,7)
    elseif id=="propose_plan" then
        r("DCCCAB",4,4,16,17);r("AE9D89",7,7,8,1);r("AE9D89",7,10,5,1);r("AE9D89",7,13,9,1);r("92B6A2",15,17,6,2);r("92B6A2",18,14,2,6)
    else
        poly("83C6BA",{12,1,15,9,23,12,15,15,12,23,9,15,1,12,9,9});poly("D5E2BF",{12,6,14,10,18,12,14,14,12,18,10,14,6,12,10,10})
        if id=="combined_spell" or id=="shared_magic" then r("C0ADD5",2,2,4,4);r("C0ADD5",18,18,4,4) end
    end
end
function Resources.new()
    return setmetatable({backgrounds={},portraits={},icons={},frames={},categoryIcons={},quads={},
        images={},sources={},warnings={}},Resources)
end
-- Una única carga por ruta: garden/courtyard y training/forest comparten imagen.
-- sources permite inspeccionar cada sustitución; nunca se oculta un fallo de PNG.
function Resources:_load(path,w,h,fallback,id)
    local key=path or ("unmapped:"..id)
    if not self.images[key] then
        local img,reason=image(path,w,h)
        if img then
            self.sources[key]={status="png",path=path,width=w,height=h}
        else
            local message="[Recursos] "..key..": "..reason.."; usando recurso provisional."
            self.warnings[#self.warnings+1]=message
            print(message)
            self.sources[key]={status="fallback",path=path,reason=reason,width=w,height=h}
            img=canvas(w,h,fallback)
        end
        self.images[key]=img
    end
    return self.images[key]
end
local function integerScale(scale) return math.max(1,math.floor(tonumber(scale) or 1)) end
local function draw(img,x,y,scale)
    scale=integerScale(scale)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(img,math.floor(x or 0),math.floor(y or 0),0,scale,scale)
    return img
end
function Resources:getBackground(id)
    id=id or "courtyard"
    if not self.backgrounds[id] then
        self.backgrounds[id]=self:_load(Assets.backgrounds[id],BACKGROUND_WIDTH,BACKGROUND_HEIGHT,backgrounds[id] or courtyard,"background:"..id)
    end
    return self.backgrounds[id]
end
function Resources:background(id) return draw(self:getBackground(id),0,0,2) end
function Resources:getPortrait(id)
    id=id or "rudeus"
    if not self.portraits[id] then
        self.portraits[id]=self:_load(Assets.characters[id],SHEET_WIDTH,SPRITE_HEIGHT,function()
            for name,index in pairs(EXPRESSIONS) do
                love.graphics.push()
                love.graphics.translate(index*SPRITE_WIDTH,0)
                portrait(profiles[id] and id or "rudeus",name)
                love.graphics.pop()
            end
        end,"character:"..id)
    end
    return self.portraits[id]
end
function Resources:portrait(id,expression,x,y,scale)
    local img=self:getPortrait(id)
    local frame=EXPRESSIONS[expression or "neutral"] or 0
    if not self.quads[frame] then
        self.quads[frame]=love.graphics.newQuad(frame*SPRITE_WIDTH,0,SPRITE_WIDTH,SPRITE_HEIGHT,SHEET_WIDTH,SPRITE_HEIGHT)
    end
    scale=integerScale(scale)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(img,self.quads[frame],math.floor(x),math.floor(y),0,scale,scale)
    return img
end
function Resources:getIcon(id)
    id=id or "magic"
    if not self.icons[id] then
        self.icons[id]=self:_load(Assets.cardIcons[id],ICON_WIDTH,ICON_HEIGHT,function() icon(id) end,"card-icon:"..id)
    end
    return self.icons[id]
end
function Resources:icon(id,x,y,scale) return draw(self:getIcon(id),x,y,scale) end
function Resources:getCardBase()
    self.base=self.base or self:_load(Assets.cardBase,CARD_WIDTH,CARD_HEIGHT,function()
        r("E2CC9F",1,1,78,110);r("D5BD92",3,3,74,106)
    end,"card-base")
    return self.base
end
function Resources:cardBase(x,y,scale) return draw(self:getCardBase(),x,y,scale) end
function Resources:getCardFrame(category)
    category=category or "empathy"
    if not self.frames[category] then
        self.frames[category]=self:_load(Assets.cardFrames[category],CARD_WIDTH,CARD_HEIGHT,function()
            local tint=({empathy=P.teal,humor=P.gold,sincerity=P.rose,initiative=P.lavender})[category] or P.gold
            r("101A2B",0,0,80,3);r("101A2B",0,109,80,3)
            r("101A2B",0,0,3,112);r("101A2B",77,0,3,112)
            r(tint,3,3,74,3);r(tint,3,106,74,3)
            r(tint,3,3,3,106);r(tint,74,3,3,106)
        end,"card-frame:"..category)
    end
    return self.frames[category]
end
function Resources:cardFrame(category,x,y,scale) return draw(self:getCardFrame(category),x,y,scale) end
function Resources:getCardBack()
    self.back=self.back or self:_load(Assets.cardBack,CARD_WIDTH,CARD_HEIGHT,function()
        r("21344B",0,0,80,112);r("BBA78A",4,4,72,104);r("344B60",7,7,66,98)
        r("83C6BA",25,31,30,50);r("D5E2BF",29,35,22,42)
    end,"card-back")
    return self.back
end
function Resources:cardBack(x,y,scale) return draw(self:getCardBack(),x,y,scale) end
function Resources:getCategoryIcon(category)
    category=category or "empathy"
    if not self.categoryIcons[category] then
        local representative=({empathy="listen",humor="light_joke",sincerity="be_honest",initiative="shared_magic"})[category]
        self.categoryIcons[category]=self:_load(Assets.categoryIcons[category],ICON_WIDTH,ICON_HEIGHT,function() icon(representative) end,"category-icon:"..category)
    end
    return self.categoryIcons[category]
end
function Resources:categoryIcon(category,x,y,scale) return draw(self:getCategoryIcon(category),x,y,scale) end
function Resources:getManaIcon()
    self.mana=self.mana or self:_load(Assets.manaIcon,ICON_WIDTH,ICON_HEIGHT,function() icon("magic") end,"mana-icon")
    return self.mana
end
function Resources:manaIcon(x,y,scale) return draw(self:getManaIcon(),x,y,scale) end
-- Valida todos los PNG sin dibujarlos ni exigir que la historia ya los visite.
function Resources:preload()
    for id in pairs(Assets.characters) do self:getPortrait(id) end
    for id in pairs(Assets.backgrounds) do self:getBackground(id) end
    for id in pairs(Assets.cardIcons) do self:getIcon(id) end
    for category in pairs(Assets.cardFrames) do self:getCardFrame(category); self:getCategoryIcon(category) end
    self:getCardBase(); self:getCardBack(); self:getManaIcon()
    return self
end
return Resources
