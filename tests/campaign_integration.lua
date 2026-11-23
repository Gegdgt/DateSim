local Suite={}
function Suite.run()
 local all={sylphiette=true,roxy=true,eris=true}
 local cases={
  {id="A",seed=117,keep=all,preferred="roxy",expected="family_united"},
  {id="B",seed=218,keep=all,preferred="eris",dailyWife="eris",expected="eris"},
  {id="C",seed=319,keep=all,preferred="roxy",dailyWife="roxy",expected="roxy",skipErisTraining=true},
  {id="D",seed=420,keep=all,preferred="sylphiette",dailyWife="sylphiette",expected="sylphiette",skipErisTraining=true},
  {id="E",seed=521,keep={roxy=true,eris=true},preferred="roxy",expected="roxy",expectViable=2},
  {id="F",seed=622,keep={sylphiette=true},preferred="sylphiette",expected="sylphiette",expectViable=1},
  {id="G",seed=723,keep={},badGlobal=true,dailyWife="eris",preferred="solo",companion="solo",expected="solitary",skipErisTraining=true},
  {id="H",seed=824,keep=all,preferred="roxy",expected="family_united",skipErisTraining=true,expectOrsted=false},
  {id="I",seed=925,keep=all,preferred="eris",expected="family_united",expectOrsted=true},
 }
 local configs={};local selected=os.getenv("DATESIM_CAMPAIGN_CASE")
 for _,c in ipairs(cases) do if not selected or c.id==selected then c.exploration=true;configs[#configs+1]=c end end
 assert(#configs>0,"Unknown campaign case")
 local results,count=require("tests.campaign").run(configs)
 local Save=require("src.systems.save");local Json=require("src.systems.json")
 local oldWrite,oldOptions=Save.write,Save.readOptions
 local captures=0
 Save.write=function(s)assert(Save.validate(s));return true end
 Save.readOptions=function()return {muted=true,textAnimation=false,reducedMotion=true}end
 local ok,err=xpcall(function()
  local app=require("src.app").new()
  for _,c in ipairs(configs) do
   local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/campaign-"..c.id..".json","rb"))
   local data=assert(Json.decode(file:read("*a")));file:close()
   app.session=assert(Save.validate(data.session));app.session.rewardQueue={};app.session.family.queue={};app:resume()
   assert(app.manager.current.kind=="campaign_summary","El epílogo conduce al resumen")
   local screen=app.manager.current
   local function capture(suffix)
    app.manager:finishTransition();app:draw()
    local pixels=app.canvas:newImageData();local bytes=pixels:encode("png")
    local target=assert(io.open(love.filesystem.getSource().."/tests/artifacts/campaign-"..c.id.."-"..suffix..".png","wb"))
    target:write(bytes:getString());target:close();pixels:release();bytes:release();captures=captures+1
   end
   capture("summary")
   if c.id=="A" then
    for i=1,3 do screen:select(i);capture("wife-"..i) end
    screen.eventsOpen=true;capture("memories")
   elseif c.id=="G" then
    screen:select(1);capture("separated")
   end
   assert(data.statistics.general.ending==c.expected,"Real statistics agree with ending")
  end
  app.audio:stop()
 end,debug.traceback)
 Save.write=oldWrite;Save.readOptions=oldOptions
 assert(ok,err)
 local out=assert(io.open(love.filesystem.getSource().."/tests/artifacts/campaign-integration-results.json","wb"))
 out:write(assert(Json.encode(results)));out:close()
 print("Integrated exploration campaign: "..#configs.." reproducible routes; "..count.." checks; "..captures.." captures.")
end
return Suite
