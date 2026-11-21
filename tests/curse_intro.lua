local Suite={}
function Suite.run()
 local Save=require("src.systems.save")
 local Events=require("src.systems.events")
 local Progression=require("src.systems.progression")
 local Chapters=require("src.data.chapters")
 local Curse=require("src.systems.curse")
 local Json=require("src.systems.json")
 local Resources=require("src.systems.resources")
 local count=0
 local function check(ok,msg) assert(ok,msg); count=count+1 end
 local function round(s) return assert(Save.validate(assert(Json.decode(assert(Json.encode(s)))))) end
 local s=Save.newSession({love=65,trust=65})
 check(s.checkpoint=="intro" and Chapters.get("intro").definition.background=="dream","La historia comienza en el sueño")
 check(not s.curse.discoveredVoice and not s.curse.discoveredMana,"Rudy todavía desconoce los bloqueos")
 check(not Curse.canUseNaturalMagic(s) and not Curse.canSpeak(s),"Los bloqueos son efectivos desde el inicio")
 check(Curse.canSpeak(s,"dream") and Curse.canSpeak(s,"thought"),"El sueño y los pensamientos conservan su voz mental")
 check(not Curse.canReveal(s,"roxy") and Curse.canReveal(s,"nanahoshi"),"La prohibición afecta a sus esposas")
 local before=Json.encode(s)
 check(not Events.apply(s,"forbidden",{character="roxy",revealSecret=true,love=-100}) and before==Json.encode(s),"Revelar el secreto se bloquea sin mutación parcial")
 check(not Events.apply(s,"early_cure",{cure=true}),"Sin antídoto no hay cura")
 Progression.next(s); Progression.next(s)
 check(s.checkpoint=="day1_letter" and not Progression.next(s),"No puede saltarse la interacción con el sobre")
 local sounds={}
 local app={session=s,options={reducedMotion=false,textAnimation=false},resources=Resources.new():preload(),
  audio={effect=function(_,name) sounds[#sounds+1]=name end}}
 function app:save() self.session=round(self.session); return true end
 function app:mouse() return nil end
 function app:next() return Progression.next(self.session) end
 function app:notify() end
 local function capture(screen,name)
  local canvas=love.graphics.newCanvas(640,360)
  love.graphics.push("all"); love.graphics.setCanvas(canvas); screen:draw(); love.graphics.setCanvas(); love.graphics.pop()
  local data=canvas:newImageData(); local bytes=data:encode("png")
  local f=assert(io.open(love.filesystem.getSource().."/tests/artifacts/curse-"..name..".png","wb")); f:write(bytes:getString()); f:close()
  data:release(); canvas:release()
 end
 local Document=require("src.screens.document")
 local doc=Document.new(app,"hitogami_letter")
 capture(doc,"envelope"); doc:interact(); doc:update(.2); app:save()
 check(not app.session.clues.hitogami_letter,"Guardar durante el vuelo no inventa lectura")
 doc=Document.new(app,"hitogami_letter")
 check(doc.phase=="lifting" and doc.elapsed==.2,"Continuar recupera el progreso de recoger el sobre")
 doc:update(.7); doc:update(.5)
 check(doc.phase=="reading","La apertura llega a un estado legible")
 capture(doc,"letter"); app:save(); doc=Document.new(app,"hitogami_letter")
 check(doc.phase=="reading","Continuar conserva el documento abierto")
 for _=1,doc.pages do doc:interact() end
 capture(doc,"signature"); doc:update(.7)
 check(app.session.checkpoint=="day1_signature" and app.session.clues.hitogami_letter,"Lectura guarda la pista y permite recordar a Hitogami")
 check(not app.session.curse.discoveredVoice,"La voz se descubre después de leer")
 local journal=#app.session.journal
 local returned=false; local reread=Document.new(app,"hitogami_letter",function() returned=true end)
 for _=1,reread.pages do reread:interact() end
 check(returned and #app.session.journal==journal,"Releer no repite acontecimientos")
 Progression.next(app.session)
 local dialogue=require("src.screens.dialogue").new(app)
 for _=1,#dialogue.scene.lines-1 do dialogue:advance(); dialogue:update(2) end
 capture(dialogue,"sealed")
 check(app.session.curse.discoveredVoice and app.session.curse.discoveredMana,"Ambos descubrimientos se registran al leer sus líneas")
 app:save()
 check(app.session.curse.voiceSealed and app.session.curse.manaBlocked,"Guardar no cura la maldición")
 Events.apply(app.session,"starter_gift",{starter=true})
 check(#app.session.deck==5 and #app.session.combatDeck==5 and #app.session.rewardQueue[1].cards==10,"Nanahoshi entrega exactamente diez cartas")
 Events.apply(app.session,"antidote_obtained",{antidote=true})
 local relations=Json.encode(app.session.relationships)
 check(Events.apply(app.session,"cured",{cure=true}),"El antídoto permite la cura")
 local healed=round(app.session)
 check(not healed.curse.active and Curse.canSpeak(healed) and Curse.canUseNaturalMagic(healed),"Voz y magia recuperadas sobreviven al guardado")
 check(Json.encode(healed.relationships)==relations,"La cura no restaura automáticamente relaciones")
 check(not Events.apply(healed,"cured",{cure=true}),"Antídoto se consume una sola vez")
 local documents=require("src.data.documents")
 documents.test_document={id="test_document",title="Documento de prueba",background="library",signature="Archivo",text=string.rep("Línea de investigación.\n",45)}
 function app:next() return true end
 local second=Document.new(app,"test_document")
 second:interact(); second:update(.7); second:update(.5); second:interact(); app:save()
 second=Document.new(app,"test_document")
 check(second.phase=="reading" and second.page==2,"Documento de varias páginas conserva la lectura")
 while second.phase=="reading" do second:interact() end
 second:update(.7)
 check(app.session.events.test_document_read and app.session.clues.test_document,"Segundo documento usa su propio ID sin colisión")
 documents.test_document=nil
 local animation=require("src.systems.animation")
 for _,kind in ipairs({"enter_left","enter_right","exit_left","exit_right","happy_bounce","small_shake","surprised_jump","sad_lower","angry_shake","expression_change"}) do
  local a=animation.actor(kind,{reducedMotion=true}); check(a.done and a.value.x==0 and a.value.y==0,"Movimiento reducido: "..kind)
 end
 print("Curse intro: "..count.." checks passed (letter interaction, save/resume, secrecy, cure and motion).")
 return count
end
return Suite
