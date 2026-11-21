-- Registro único de puntos jugables. Los capítulos futuros no crean checkpoints.
local Registry={}
local groups={scenes="scene",encounters="encounter",hubs="hub",summaries="summary"}

function Registry.build(list)
    local catalog={list=list,byId={},checkpoints={},scenes={},encounters={},hubs={},summaries={},buildErrors={}}
    for _,chapter in ipairs(list) do
        if catalog.byId[chapter.id] then
            catalog.buildErrors[#catalog.buildErrors+1]="Capítulo duplicado: "..tostring(chapter.id)
        else catalog.byId[chapter.id]=chapter end
        if chapter.implemented~=false then
            catalog.first=catalog.first or chapter
            if not catalog.last or chapter.day>catalog.last.day then catalog.last=chapter end
            for group,kind in pairs(groups) do
                for id,definition in pairs(chapter[group] or {}) do
                    if catalog.checkpoints[id] then
                        catalog.buildErrors[#catalog.buildErrors+1]="Checkpoint duplicado: "..id
                    else
                        catalog.checkpoints[id]={id=id,day=chapter.day,chapterId=chapter.id,kind=kind,definition=definition}
                        catalog[group][id]=definition
                    end
                end
            end
        end
    end
    function catalog.get(id) return catalog.checkpoints[id] end
    function catalog.chapterFor(id)
        local node=catalog.get(id)
        return node and catalog.byId[node.chapterId]
    end
    return catalog
end

local list={}
for day=1,7 do list[#list+1]=require("src.data.chapters.day"..day) end
require("src.data.war_chapters").install(list)
require("src.data.day_cycle").install(list)
local Chapters=Registry.build(list)
Chapters.build=Registry.build
return Chapters
