local Curse={}
function Curse.new()
 return {active=true,voiceSealed=true,manaBlocked=true,chantlessBlocked=true,discoveredVoice=false,discoveredMana=false}
end
function Curse.canSpeak(session,delivery)
 return not (session.curse and session.curse.voiceSealed) or delivery=="dream" or delivery=="thought" or delivery=="note" or delivery=="enchanted" or delivery=="silence"
end
function Curse.canReveal(session,recipient)
 local wife=require("src.data.characters").byId[recipient]
 return not (session.curse and session.curse.active and wife and wife.romance)
end
function Curse.canUseNaturalMagic(session) return not (session.curse and session.curse.manaBlocked) end
function Curse.canUseChantlessMagic(session) return Curse.canUseNaturalMagic(session) and not (session.curse and session.curse.chantlessBlocked) end
return Curse
