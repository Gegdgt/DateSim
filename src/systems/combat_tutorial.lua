-- La guía observa acciones reales del motor. No aplica daño ni concede energía.
local Tutorial={}
local stages={attack=true,attack_result=true,shield=true,end_turn=true,enemy_result=true,free=true,complete=true}

function Tutorial.restore(value,enc)
    if type(value)~="table" or not stages[value.stage] then value={stage="attack"} end
    local cards={};for _,id in ipairs(enc.deck) do cards[id]=true end
    -- Un mazo editado sigue siendo legal; la guía no exige una carta retirada.
    if not cards.staff_strike then value.stage="free" end
    if enc.finished then value.stage="complete" end
    return {stage=value.stage}
end

function Tutorial.canPlay(tutorial,card)
    if not tutorial or tutorial.stage=="free" then return true end
    if tutorial.stage=="attack" and card and card.id=="staff_strike" then return true end
    if tutorial.stage=="shield" then return false,"Pulsa Defensa [D]: siempre disponible sin carta ni magia." end
    if tutorial.stage=="attack" then return false,"Primero selecciona Golpe de bastón y confirma Jugar." end
    if tutorial.stage=="end_turn" then return false,"Pulsa Terminar turno para observar al enemigo." end
    return false,"Lee la demostración y pulsa Entendido."
end

function Tutorial.canEndTurn(tutorial)
    return not tutorial or tutorial.stage=="end_turn" or tutorial.stage=="free"
end

function Tutorial.played(tutorial,cardId)
    if not tutorial then return end
    if tutorial.stage=="attack" and cardId=="staff_strike" then tutorial.stage="attack_result"
    elseif tutorial.stage=="shield" and cardId=="defend" then tutorial.stage="end_turn" end
end

function Tutorial.endedTurn(tutorial)
    if tutorial and tutorial.stage=="end_turn" then tutorial.stage="enemy_result" end
end

function Tutorial.advance(tutorial)
    if not tutorial then return false end
    if tutorial.stage=="attack_result" then tutorial.stage="shield"; return true end
    if tutorial.stage=="enemy_result" then tutorial.stage="free"; return true end
    return false
end

function Tutorial.message(tutorial,enc)
    if not tutorial then return nil end
    local stage=tutorial.stage
    if stage=="attack" then
        return "NANAHOSHI · 1/6: ATACAR","Golpe de bastón [1]: 1 acción y 0 maná; causa "..require("src.systems.combat").card("staff_strike",enc).effects.damage.." daño. Seleccionar inspecciona; Jugar [Enter] confirma."
    elseif stage=="attack_result" then
        return "2/6: VIDA E INTENCIÓN","Enemigo: "..enc.enemy.maxHp.." > "..enc.enemy.hp.." PV. "..enc.enemy.intent.text.." No gastaste maná: la maldición sigue activa.",true
    elseif stage=="shield" then
        return "3/6: PROTEGERSE","Defensa básica [D]: 1 acción, sin magia ni carta. Ganarás 5 escudo, suficiente para el ataque anunciado."
    elseif stage=="end_turn" then
        return "4/6: TURNO ENEMIGO","Tienes 5 escudo. Terminar turno [E] ejecuta la intención anunciada y descarta la mano restante."
    elseif stage=="enemy_result" then
        return "5/6: DAÑO Y BLOQUEO","El escudo absorbió el golpe. Rudy: "..enc.player.hp.."/30. Nueva mano, 3 acciones y maná natural bloqueado. El escudo caduca.",true
    elseif stage=="free" then
        return "6/6: DERROTA A LA ANOMALÍA","Usa tus ataques hasta llevar su vida a 0. Puedes jugar varias cartas por turno. Revisa la intención antes de terminar."
    end
end

return Tutorial
