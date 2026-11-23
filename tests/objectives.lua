local Suite={}
function Suite.run()
 local Save=require("src.systems.save")
 local Json=require("src.systems.json")
 local Q=require("src.systems.objectives")
 local P=require("src.systems.prologue")
 local Events=require("src.systems.events")
 local Progress=require("src.systems.progression")
 local E=require("src.systems.exploration")
 local Daily=require("src.systems.daily")
 local Rest=require("src.systems.rest")
 local Wife=require("src.systems.wife_activities")
 local D=require("tests.social_driver")
 local Journal=require("src.ui.objective_journal")
 local count,captures=0,0
 local function check(v,m)assert(v,m);count=count+1;return v end
 local function encode(v)return assert(Json.encode(v))end
 local function round(s)return check(Save.validate(assert(Json.decode(encode(s)))),"Guardado validado")end
 local function entry(s,id)Q.sync(s);return s.objectives.entries[id]end
 local function journal(s,day)
  local rows={};for _,row in ipairs(Journal.rows(s,day or s.day)) do rows[#rows+1]=row.text end
  return table.concat(rows,"\n")
 end
 -- Catálogo: esquema, referencias y dependencias verificables.
 for _,def in ipairs(Q.data.list) do
  check(def.id and def.day and def.title and def.description and def.type and type(def.required)=="boolean"
   and def.event and def.dependencies and def.unlock and def.order and def.requiredProgress,"Esquema completo: "..def.id)
  check(not next(def.unlock) or require("src.systems.conditions").validate(def.unlock),"Desbloqueo válido")
  if def.complete then check(require("src.systems.conditions").validate(def.complete),"Condición de progreso válida") end
  for _,id in ipairs(def.dependencies) do check(Q.data.byId[id] and Q.data.byId[id].day<=def.day,"Dependencia conocida") end
  if def.destination then check(require("src.data.maps")[def.destination.map],"Destino real") end
 end
 local s=P.start(Save.newSession());P.wake(s)
 check(#Q.list(s)==1 and Q.current(s).id=="day1_letter","Sólo objetivo de estudio al despertar")
 check(journal(s):find("Ve al estudio",1,true) and not journal(s):find("Badigadi",1,true),"Diario sin spoilers")
 local _,journalReason=Q.requirements(s);local _,restReason=Rest.available(s,Rest.bed(s))
 check(journalReason==restReason and journal(s):find(restReason,1,true),"Diario y descanso usan exactamente el mismo requisito")
 E.enter(s.exploration,"estudio_rudy",{x=180,y=116})
 check(entry(s,"day1_letter").status=="available" and not s.events.hitogami_letter_read,"Entrar no completa")
 local stub={session=s,options={textAnimation=false,reducedMotion=true},audio={effect=function()end},save=function()return true end,switch=function()end,resume=function()end}
 local letter=require("src.screens.exploration_letter").new(stub,{})
 letter:update(1)
 check(s.prologue.letter_found and s.prologue.letter_collected and s.prologue.document_available,"Estados independientes del documento")
 check(not P.readLetter(s),"No completa al levantar")
 letter:interact();letter:update(1)
 while letter.phase=="reading" do letter:update(1);letter:interact() end
 check(letter.phase=="signature" and not s.events.hitogami_letter_read,"Texto entero antes de confirmar firma")
 letter:interact()
 check(s.events.hitogami_letter_read and entry(s,"day1_letter").status=="completed","Lectura registra evento y objetivo")
 check(Q.popNotice(s),"Notificación de objetivo completado")
 check(s.checkpoint=="day1_signature" and not s.prologue.curse_discovered,"Descubrimiento empieza después de la firma")
 check(Progress.next(s)=="day1_silence","Recuerdo narrativo")
 check(Progress.next(s)=="day1_warning" and s.curse.discoveredVoice and s.curse.discoveredMana,"Descubrimientos de voz y maná")
 check(Q.current(s).id=="day1_nanahoshi","Nanahoshi desbloqueada")
 local markers=E.markers(s);local goal=false;for _,m in ipairs(markers) do if m.kind=="objective" then goal=true end end
 check(goal,"Minimapa señala el siguiente acceso al laboratorio")
 E.enter(s.exploration,"laboratorio_nanahoshi",require("src.data.maps").laboratorio_nanahoshi.initialPosition)
 check(not P.visitNanahoshi(s) and not s.events.nanahoshi_conversation_started,"Entrar o estar lejos no completa conversación")
 E.enter(s.exploration,"laboratorio_nanahoshi",{x=312,y=260})
 check(P.visitNanahoshi(s) and entry(s,"day1_nanahoshi").status=="completed","Conversación física completa búsqueda")
 check(Q.current(s).id=="day1_cards","Se revela la entrega")
 Progress.next(s);Progress.next(s)
 check(s.events.starter_gift and #s.deck==5 and #s.combatDeck==5,"Entrega real de cinco más cinco cartas")
 local collection=encode(s.collection)
 check(not Events.apply(s,"starter_gift",{starter=true}) and collection==encode(s.collection),"Entrega idempotente")
 check(Q.current(s).id=="day1_tutorial" and not Wife.ready(s),"Abrir tutorial no lo completa")
 local ready,reason=Q.requirements(s)
 check(not ready and reason:find("tutorial",1,true),"Mensaje de descanso identifica el tutorial")
 local Tutorial=require("src.systems.tutorial")
 s.tutorial={stage="summary"};s.encounter={finished=false}
 check(not Tutorial.complete(s,{}) and not s.events.tutorial_completed,"Tutorial sin finalizar no cuenta")
 s.encounter.finished=true;check(Tutorial.complete(s,{}),"Finalización social registrada")
 s.encounter=nil;s.tutorial=nil
 check(not Wife.ready(s),"La práctica social no sustituye al combate")
 local Combat=require("src.systems.combat")
 local enc=Combat.new(s.deck,{relationships=s.relationships,enemyId="mana_anomaly",day=1,tutorial=true,
  combatDeck=s.combatDeck,unlocked=s.unlocked,curse=s.curse,externalEnergy=s.externalEnergy,
  cardLevels=require("src.systems.card_collection").levels(s)},function(n)return n end)
 s.combat=enc
 check(not Progress.finishCombat(s,enc),"Abrir combate no completa tutorial")
 require("tests.war_balance").solve(enc)
 check(enc.outcome=="victory" and Progress.finishCombat(s,enc),"Victoria real completa tutorial obligatorio")
 check(entry(s,"day1_tutorial").status=="completed" and Wife.ready(s),"Actividades desbloqueadas por ambos tutoriales")
 check(Progress.next(s)=="day1_close","Resultado ya no salta el cierre del prólogo")
 check(Progress.next(s)=="day1_agenda" and s.events.day1_complete,"Cierre registra day1_complete antes del tiempo libre")
 check(entry(s,"day1_interactions").progress==0 and journal(s):find("0/3",1,true),"Contador inicial visible 0/3")
 s.rewardQueue={};s=round(s)
 -- La carta permanece y releer no altera la historia ni los matrimonios.
 E.enter(s.exploration,"estudio_rudy",{x=180,y=116})
 check(E.nearby(s).id=="hitogami_letter","Objeto permanente después de completar")
 stub.session=s
 local before=encode({s.events,s.relationships,s.collection,s.checkpoint,s.prologue,s.objectives})
 letter=require("src.screens.exploration_letter").new(stub,{})
 check(letter.reread and letter.phase=="reading" and letter.page==1,"Relectura desde el principio")
 while letter.phase=="reading" do letter:update(1);letter:interact() end
 letter:interact()
 check(before==encode({s.events,s.relationships,s.collection,s.checkpoint,s.prologue,s.objectives}),"Relectura sin maldición, premios o reinicio")
 -- Tres cierres con Eris; el diario se consulta sin recrearlo.
 local world={journalDay=1,journalScroll=0}
 for n=1,3 do
  D.approach(s,"eris");check(Wife.start(s,"E11",s.economy.revision),"Actividad física con Eris")
  check(entry(s,"day1_interactions").progress==n-1,"Reservar no incrementa")
  D.play(s);D.close(s)
  check(entry(s,"day1_interactions").progress==n,"Progreso al completar "..n)
  check(entry(s,"day1_visit_eris").progress==n and journal(s):find(n.."/1",1,true),"Contador individual sin limitar")
  check(journal(s):find(n.."/3",1,true),"Diario actualizado inmediatamente")
  E.syncPresence(s);check(s.exploration.npcLocations.eris.map=="patio_eris","No mover durante resultado")
  Wife.closeReview(s)
  if n<3 then
   local ok,msg=Q.requirements(s)
   check(not ok and msg:find(n.."/3",1,true),"Mensaje concreto de interacciones")
  end
 end
 check(entry(s,"day1_visit_eris").progress==3 and entry(s,"day1_visit_roxy").progress==0,"Eris 3/1, Roxy 0/1")
 for _,id in ipairs({"eris","roxy","sylphiette"}) do check(s.exploration.npcLocations[id].map:match("^dormitorio_"),"Traslado nocturno: "..id) end
 check(Q.requirements(s) and Q.current(s).type=="rest","Tres Eris suficientes; opcionales no bloquean")
 check(entry(s,"day1_commissions").status~="completed","Encargo sigue opcional")
 -- Partida anterior afectada: prueba concreta del tutorial, sin cierre perdido.
 local affected=assert(Json.decode(encode(s)))
 affected.events.day1_complete=nil;affected.objectives=nil
 local migrated=round(affected)
 check(migrated.events.day1_complete and Q.requirements(migrated),"Migra bloqueo antiguo sin saltar tutorial")
 local bad=assert(Json.decode(encode(affected)));bad.events.combat_tutorial_completed=nil;bad.events.combat_reward_day1_tutorial=nil
 check(not Q.requirements(round(bad)),"No inventa un tutorial sin evidencia")
 -- Regresión solicitada desde la pantalla real en el dormitorio de Roxy.
 D.approach(s,"roxy");local bed=Rest.bed(s)
 check(Rest.available(s,bed),"Dormitorio de Roxy permite descanso")
 local nightStart=round(s)
 local oldWrite,oldRead=Save.write,Save.readOptions
 Save.write=function(game)assert(Save.validate(game));return true end
 Save.readOptions=function()return {muted=true,textAnimation=false,reducedMotion=true}end
 local app
 local ok,err=xpcall(function()
  app=require("src.app").new();app.session=s;app:explore();app.manager:finishTransition()
  local function capture(name)
   app.manager:finishTransition();app.toastTime=0;app:draw()
   local pixels=app.canvas:newImageData();local data=pixels:encode("png")
   local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/objectives-"..name..".png","wb"))
   file:write(data:getString());file:close();pixels:release();data:release();captures=captures+1
  end
  local screen=app.manager.current;screen:keypressed("j");capture("journal-night")
  screen:keypressed("end");capture("journal-completed")
  screen:keypressed("j");screen:keypressed("e");app.manager:finishTransition()
  check(app.manager.current.kind=="rest","E abre descanso con Roxy")
  capture("roxy-rest")
  local love,trust=s.relationships.roxy.love,s.relationships.roxy.trust
  app.manager.current:confirm()
  check(Rest.completed(s) and s.rest.nights["1"].wife=="roxy","Noche registrada una vez")
  check(s.relationships.roxy.love==love-20+10 and s.relationships.roxy.trust==trust-20+10,"Ausencia -20 y noche +10 independientes")
  check(s.daily.visits.roxy==0,"Dormir no simula visita diurna")
  local stable=encode(s.relationships);check(not Rest.confirm(s,bed,"gesture"),"No segunda bonificación")
  s=round(s);Daily.applyAttention(s);check(stable==encode(s.relationships),"Carga no duplica penalización ni bonificación")
  app.session=s;app.session.family.queue={};app:resume();app.manager:finishTransition()
  check(app.manager.current.kind=="day_report","Descanso abre resumen diario")
  capture("day-report")
  check(Progress.next(s) and s.day==2,"Comienza el siguiente día")
  check(Q.current(s).id=="day2_story" and entry(s,"day2_interactions").progress==0,"Objetivos nuevos y contadores reiniciados")
  check(entry(s,"day1_visit_eris").progress==3 and journal(s,1):find("3/1",1,true),"Consulta de objetivos anteriores")
  app.session=s;app:explore();app.manager:finishTransition();app.manager.current:keypressed("j");capture("day-two")
  for id in pairs(require("src.data.maps")) do
   E.enter(s.exploration,id,require("src.data.maps")[id].initialPosition);app:explore();app.manager:finishTransition()
   app.manager.current:keypressed("j");check(app.manager.current.modal=="journal","J disponible en "..id)
  end
  app.session=P.start(Save.newSession());P.wake(app.session);app:explore();app.manager:finishTransition()
  capture("wake-objective");app.manager.current:keypressed("j");capture("wake-journal")
  local blocked=require("src.screens.rest").new(app,Rest.bed(app.session));blocked:confirm()
  local _,blockedReason=Q.requirements(app.session)
  check(blocked.message==blockedReason,"El intento de confirmar conserva el mensaje específico del bloqueo")
  app.session=nightStart;E.enter(nightStart.exploration,"estudio_rudy",{x=180,y=116});app:explore();capture("permanent-letter")
  local help=D.fresh();Events.mark(help,"day1_complete")
  for _=1,2 do D.approach(help,"eris");assert(Wife.start(help,"E11",help.economy.revision));D.play(help);D.close(help);Wife.closeReview(help) end
  D.approach(help,"cliff");app.session=help;app:explore();app.manager:finishTransition()
  local returned=app.manager.current
  check(Daily.requestFavor(help,"social_research","cliff",true),"Ayuda en el taller como tercera interacción")
  returned:update(.01)
  check(Q.counts(help,1)==3 and help.exploration.period=="night","Volver del taller actualiza el horario sin recrear el mapa")
  local manual=require("src.screens.manual").new(app)
  manual:changeSection(5);app:switch(manual)
  check(require("src.ui.font").height(require("src.data.manual").rules[1].text,578,1)<=178,"La nueva página del manual cabe en su panel")
  capture("manual")
 end,debug.traceback)
 Save.write,Save.readOptions=oldWrite,oldRead
 if app then app.audio:stop() end
 assert(ok,err)
 -- La confirmación persiste antes del resumen: cargar debe poder finalizarla.
 local interrupted=round(nightStart);D.approach(interrupted,"roxy");check(Rest.confirm(interrupted,Rest.bed(interrupted),"gesture"),"Confirmar antes de interrupción")
 interrupted=round(interrupted);check(Progress.endDay(interrupted),"Carga entre noche y resumen permite finalizar")
 local solo=D.fresh();Events.mark(solo,"day1_complete")
 for _,id in ipairs({"eris","roxy","sylphiette"}) do require("src.systems.family").depart(solo,id,"test") end
 E.enter(solo.exploration,"casa_segundo_piso",require("src.data.rest").beds.casa_segundo_piso)
 check(Rest.available(solo,Rest.bed(solo)) and Rest.confirm(solo,Rest.bed(solo),"gesture"),"Todas separadas: descanso solo sin bloqueo")
 check(Progress.endDay(solo) and Progress.next(solo),"Avanza una noche con todas separadas")
 check(entry(round(solo),"day1_interactions").status=="completed","La dispensa de una jornada anterior no se reinicia")
 local optional=D.fresh(6)
 Events.mark(optional,"eris_five_training_days");Events.mark(optional,"antidote_holder_revealed")
 local found=false;for _,o in ipairs(Q.list(optional)) do if o.id=="day6_orsted" then found=not o.required end end
 check(found,"Orsted aparece como opcional al cumplir sus condiciones")
 optional.checkpoint="day6_orsted_arrival"
 check(Progress.choose(optional,optional.checkpoint,"rest") and Progress.next(optional)=="day6_close","Se puede declinar la invitación")
 check(Progress.next(optional)=="day6_agenda" and optional.events.day6_complete,"Declinar permite concluir la historia")
 for _=1,3 do D.approach(optional,"eris");assert(Wife.start(optional,"E11",optional.economy.revision));D.play(optional);D.close(optional);Wife.closeReview(optional) end
 check(Q.requirements(optional) and not optional.events.orsted_demonstration_completed,"Orsted pendiente nunca bloquea el descanso")
 -- Un snapshot manipulado no puede completar una misión.
 local corrupt=P.start(Save.newSession());corrupt.objectives.entries.day1_letter.status="completed"
 check(entry(round(corrupt),"day1_letter").status=="available","La carga reconstruye progreso desde evidencia")
 print("Daily objectives: "..count.." checks; "..captures.." renderer captures; prologue, journal, counters, Roxy regression, persistence and permanent document.")
 return count
end
return Suite
