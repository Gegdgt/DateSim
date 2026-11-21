local Suite={}
function Suite.run()
 local Save=require("src.systems.save");local Daily=require("src.systems.daily");local Events=require("src.systems.events")
 local Json=require("src.systems.json");local Hud=require("src.ui.daily_hud");local Collection=require("src.systems.card_collection")
 local old=Save.readOptions;Save.readOptions=function()return {muted=true,textAnimation=false,reducedMotion=false}end
 local app=require("src.app").new();app.mouse=function()return nil,nil end
 local checks,captures=0,0;local function check(ok,msg)assert(ok,msg);checks=checks+1 end
 local function fresh(day)
  local s=Save.newSession();Events.apply(s,"starter_gift",{starter=true});s.rewardQueue={};s.day=day or 1;s.checkpoint="day"..s.day.."_agenda";Daily.ensure(s)
  app.session=s;return s
 end
 local function settle()app:update(2);if app.manager.transition>0 then app:update(2)end;app:draw()end
 local function capture(id)
  app.toastTime=0;app:draw();local pixels=app.canvas:newImageData();local data=pixels:encode("png")
  local f=assert(io.open(love.filesystem.getSource().."/tests/artifacts/phase6-"..id..".png","wb"));f:write(data:getString());f:close();pixels:release();data:release();captures=captures+1
 end
 local function button(label)
  app:draw();for _,b in ipairs(app.manager.current.buttons)do if b.label==label then return b end end
 end
 local function click(label)
  local b=assert(button(label),"Falta botón "..label);check(not b.disabled,"Accesible: "..label)
  app:mousepressed(app.offsetX+(b.x+b.w/2)*app.scale,app.offsetY+(b.y+b.h/2)*app.scale,1);settle()
 end
 local function drain()
  for _=1,100 do
   local screen=app.manager.current
   if screen.kind=="reward"then screen:continue()elseif screen.kind=="family_scene"then screen:advance()else return end
   settle()
  end;error("Presentación bloqueada")
 end
 local s=fresh();app:resume();settle();capture("agenda")
 check(s.relationships.eris.love==50 and s.relationships.eris.trust==50,"Valores iniciales reales 50/50")
 click("Elegir actividad");capture("activity-hud")
 check(Hud.snapshot(s).remaining==2 and s.daily.visits.sylphiette==1,"Reserva exacta reflejada en HUD")
 for _,label in ipairs({"Sylphiette","Roxy","Eris","Encargos","Finalizar día","Mazo [M]"})do check(button(label),"Acceso permanece: "..label)end
 check(button("Finalizar día").disabled,"No abandona un resultado pendiente")
 click("Roxy");capture("inspect-roxy")
 for _,b in ipairs(app.manager.current.buttons)do if b.label=="Elegir actividad"then check(b.disabled,"Consulta no puede reservar otro espacio")end end
 check(s.daily.interactions_used==1 and s.daily.active_activity.id=="time_sylphiette","Consultar no modifica la actividad")
 click("Volver a la actividad");click("Misiones 0");capture("missions");click("Volver")
 click("Mazo [M]");capture("collection");click("Mejorar");capture("upgrades-state");click("Volver");click("Volver")
 s.relationships.sylphiette.love=-15;s.relationships.sylphiette.trust=-3;app:resume();settle();capture("negative-affinity")
 check(app.manager.current.relationshipBars.sylphiette.target.love==-15,"La barra conserva el valor negativo")
 check(Save.write(s),"Guardar actividad y relación negativa");app:continueGame();settle();s=app.session
 check(s.daily.interactions_used==1 and s.relationships.sylphiette.love==-15,"Cargar no repone espacios ni borra conflicto")
 assert(Daily.resolveActivity(s,"together"));s.rewardQueue={};s.family.queue={};Events.apply(s,"day1_complete",{})
 app:resume();settle();app:endDay();settle();drain();capture("day-report")
 check(app.manager.current.kind=="day_report","Resumen animado al cerrar")
 for _,id in ipairs({"sylphiette","roxy","eris"})do
  local b=app.manager.current.bars[id];check(b.target.love==s.relationships[id].love and b.value.trust==s.relationships[id].trust,"Resumen coincide con "..id)
 end
 -- Todas las actividades muestran costes y recompensas sin desbordar sus botones.
 local Font=require("src.ui.font")
 for _,def in ipairs(require("src.data.activities").list)do
  s=fresh(3);assert(Daily.startActivity(s,def.id));app:resume();settle()
  for _,b in ipairs(app.manager.current.buttons)do check(Font.height(b.label,b.w-12)<=b.h-4,"Texto cabe: "..def.id.." / "..b.label)end
 end
 -- El regalo archiva las 40 cartas aunque no quede ninguna esposa; no devuelve habilidades.
 s=fresh(6);for _,r in pairs(s.relationships)do r.marriageState="separated"end
 s.checkpoint="day6_orsted_gifts";s.events.orsted_demonstration_completed=true
 assert(require("src.systems.finale").advance(s,"orsted_grant"))
 for _,card in ipairs(Collection.list)do check(s.unlocked[card.id],"Orsted archiva "..card.id)end
 local before=assert(Json.encode(s.collection));require("src.systems.finale").advance(s,"orsted_grant")
 check(assert(Json.encode(s.collection))==before,"Regalo no duplica copias")
 local combat=require("src.systems.combat").new(s.deck,{enemyId="badigadi_final",day=7,team={sylphiette=true,roxy=true,eris=true},relationships=s.relationships,
  combatDeck={"shared_magic","combined_spell","sword_magic","staff_strike","simple_cut"},unlocked=s.unlocked,cardLevels=Collection.levels(s),curse=s.curse})
 check(next(combat.allies)==nil,"Sin apoyos de matrimonios separados")
 for _,id in ipairs(combat.initial.pile)do check(id~="shared_magic" and id~="combined_spell" and id~="sword_magic","Sin técnicas exclusivas de las separadas")end
 -- El libro ofrece una ventaja limitada respecto de tres copias comunes.
 local data=require("src.data.economy");check(data.items.study_book.price<3*require("src.data.card_progression").classes.basic.copyPrice,"Libro útil también para cartas comunes")
 s=fresh();local E=require("src.systems.economy")
 for _=1,4 do assert(E.buy(s,"study_book",s.economy.revision))end
 check(not E.buy(s,"study_book",s.economy.revision),"Stock diario limita el descuento")
 local gold=s.gold;assert(E.use(s,"study_book","listen",s.economy.revision))
 check(s.gold==gold and s.collection.listen.copies==3 and s.economy.items.study_book==3,"Uso consume un libro sin duplicar oro")
 -- PCM real, no rutas nominales a archivos ausentes.
 local Audio=require("src.systems.audio");local manifest=require("src.data.audio")
 for _,id in ipairs({"new_day","card_gift","upgrade","gold","training","combat_start","heal","separation","orsted","badigadi","final_victory"})do
  local pcm=Audio.synthesize(manifest.effects[id],false,love.sound.newSoundData);local peak=0
  for i=0,pcm:getSampleCount()-1 do peak=math.max(peak,math.abs(pcm:getSample(i)))end
  check(peak>0 and peak<=1 and pcm:getDuration()>0,"PCM audible y acotado: "..id);pcm:release()
  check(app.audio:source(id,manifest.effects[id],false),"Fuente real: "..id)
 end
 local sounds=0;local effect=app.audio.effect
 app.audio.effect=function(self,id)if id=="gold"then sounds=sounds+1 end;return effect(self,id)end
 app:update(.1);Events.apply(s,"sound_gold",{gold=9});app:update(.1);app:update(.1)
 check(sounds==1,"El oro suena una sola vez al obtenerlo")
 app.session=assert(Save.validate(s));app:update(.1);check(sounds==1,"Cargar no repite sonido de oro")
 local manual=require("src.screens.manual").new(app);app:switch(manual);manual:changeSection(5)
 for i,rule in ipairs(require("src.data.manual").rules)do if rule.title=="Turnos y compañeras" then
  manual.page=i;settle();capture("manual-affinity")
  check(Font.height(rule.text,578)<=180,"La fórmula de afinidad cabe en el manual")
 end end
 Save.readOptions=old;app.audio:stop()
 print("Final integration: "..checks.." checks; "..captures.." real-renderer captures; persistent HUD, negative bars, collection, Orsted restrictions and real PCM.")
 return checks
end
return Suite
