local Suite={}
function Suite.run()
 local Save=require("src.systems.save")
 local Events=require("src.systems.events")
 local Daily=require("src.systems.daily")
 local Family=require("src.systems.family")
 local Json=require("src.systems.json")
 local old={write=Save.write,load=Save.load,exists=Save.exists,readOptions=Save.readOptions,legacyInfo=Save.legacyInfo}
 local stored;local count=0;local captures=0
 local function check(ok,msg)assert(ok,msg);count=count+1 end
 Save.write=function(s)stored=assert(Json.encode(assert(Save.validate(s))));return true end
 Save.load=function()return stored and Save.validate(assert(Json.decode(stored)))end
 Save.exists=function()return stored~=nil end
 Save.readOptions=function()return{muted=true,textAnimation=false,reducedMotion=false}end
 Save.legacyInfo=function()return nil end
 local ok,err=xpcall(function()
  local app=require("src.app").new()
  app.session=Save.newSession();Events.apply(app.session,"starter_gift",{starter=true});app.session.rewardQueue={};app.session.checkpoint="day1_agenda"
  local function settle()app:update(2);if app.manager.transition>0 then app:update(2)end;app:draw()end
  local function capture(name)
   settle();local pixels=app.canvas:newImageData();local bytes=pixels:encode("png")
   local f=assert(io.open(love.filesystem.getSource().."/tests/artifacts/family-"..name..".png","wb"));f:write(bytes:getString());f:close()
   pixels:release();bytes:release();captures=captures+1
  end
  local function click(label)
   app:draw();for _,b in ipairs(app.manager.current.buttons)do if b.label==label then check(not b.disabled,"Botón activo "..label);b.action();settle();return end end
   error("Botón ausente "..label)
  end
  local function drain()
   for _=1,80 do
    local screen=app.manager.current
    if screen.kind=="family_scene" then screen:advance()
    elseif screen.kind=="reward" then screen:continue()
    else return end
    settle()
   end
   error("Presentaciones sin fin")
  end
  app:resume();capture("agenda")
  click("Roxy");capture("roxy")
  click("Eris");capture("eris")
  check(Daily.startActivity(app.session,"time_eris"),"Reserva primera visita")
  app:save();app:resume();capture("activity")
  local result=Daily.resolveActivity(app.session,"together");check(result,"Actividad aplicada")
  app:save();app:resume();check(app.manager.current.kind=="family_scene","Resultado narrativo visible");capture("result");drain()
  for _=2,3 do Daily.startActivity(app.session,"time_eris");Daily.resolveActivity(app.session,"together");app:save();app:resume();drain()end
  check(app.session.family.seen.day1_third_eris,"Tercera conversación registrada")
  local scene=require("src.data.family").repeated.eris
  Family.notice(app.session,"visual_third","eris",scene.text,scene.expression,scene.reply);app:resume();capture("third-eris");drain()
  for _,id in ipairs({"sylphiette","roxy"}) do
   local line=require("src.data.family").repeated[id];Family.notice(app.session,"visual_third_"..id,id,line.text,line.expression,line.reply)
   app:resume();capture("third-"..id);drain()
  end
  app.session=Save.newSession();Events.apply(app.session,"starter_gift",{starter=true});app.session.rewardQueue={};app.session.checkpoint="day1_agenda"
  app:resume();click("Encargos");capture("favors");click("Solicitar")
  check(app.session.daily.interactions_used==0,"Solicitud no gasta espacio")
  click("Encargos");click("Ayudar hoy (1 espacio)");capture("help-warning")
  check(app.session.daily.interactions_used==0,"Advertencia no gasta antes de confirmar")
  click("Cancelar");check(app.session.daily.interactions_used==0,"Cancelar conserva espacios")
  click("Ayudar hoy (1 espacio)");click("Confirmar: gastar 1 espacio");drain()
  check(app.session.daily.interactions_used==1 and app.session.daily.visits.sylphiette==0,"Confirmación gasta un espacio sin visita")
  app.session.gold=200;app:switch(require("src.screens.books").new(app));capture("books")
  click("50 oro");drain();check(app.session.family.books.rune_recipes,"Librería compra y guarda")
  for _,id in ipairs({"sylphiette","roxy","eris"})do
   Events.apply(app.session,"visual_departure_"..id,{character=id,marriageState="separated"})
   app:save();app:resume();capture("confrontation-"..id)
   app.manager.current:advance();settle();app.manager.current:advance();settle();capture("ring-"..id)
   local phase=app.session.family.queue[1].phase;app:save();app.session=assert(Save.load());app:resume();settle()
   check(app.session.family.queue[1].phase==phase and app.session.relationships[id].marriageState=="separated","Cargar conserva anillo y separación")
   app.manager.current:advance();settle();capture("horse-"..id)
   drain();check(app.session.events["departure_"..id.."_presented"],"Partida presentada una sola vez")
  end
  app:overlay("journal");capture("gray-journal")
  local resources=app.resources;local original=resources.portrait;local grays={}
  resources.portrait=function(self,id,expression,x,y,scale,gray)if gray then grays[id]=true end;return original(self,id,expression,x,y,scale,gray)end
  app:draw();for _,id in ipairs({"eris","roxy","sylphiette"})do check(grays[id],"Registro dibuja en gris "..id)end
  resources.portrait=original
  app:switch(require("src.screens.manual").new(app));app.manager.current:changeSection(1);app.manager.current.page=2;capture("gray-character")
  -- Confirm the shader output, not just its flag, on an actual portrait pixel.
  local canvas=love.graphics.newCanvas(64,64);love.graphics.setCanvas(canvas);love.graphics.clear(0,0,0,0)
  resources:portrait("sylphiette","neutral",0,0,1,true);love.graphics.setCanvas()
  local image=canvas:newImageData();local opaque=0
  for y=0,63 do for x=0,63 do local r,g,b,a=image:getPixel(x,y);if a>.5 then opaque=opaque+1;check(math.abs(r-g)<.01 and math.abs(g-b)<.01,"Píxel de retrato realmente gris")end end end
  check(opaque>100,"Retrato gris conserva el sprite");image:release();canvas:release();app.audio:stop()
 end,debug.traceback)
 for key,value in pairs(old)do Save[key]=value end
 assert(ok,err)
 print("Family UI: "..count.." checks passed; "..captures.." real-renderer captures.")
end
return Suite
