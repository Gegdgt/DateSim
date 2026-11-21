-- Reglas de evaluación; ninguna puntuación se aplica desde el motor de combate.
return {
    eris={
        name="Duelo de entrenamiento con Eris",resourceName="Resistencia",nonlethal=true,
        swordReduction=2,maxTurns=18,
        counter={damage=5,cost=1},
        victory={kind="resistance",targetHits=3,minHitDamage=5},
        honorable={minTurns=5,minAttempts=3,minHits=2,minDamageRatio=.30,
            minDefensiveActions=1,minActivityRatio=.50,minSignals=3},
        suspected={minTurns=4,minRepeatedMisses=3,minAvoidableEmptyTurns=3,
            maxAttempts=1,maxDamageRatio=.10,maxTacticalActions=1},
        results={
            victory={eventId="eris_training_rudy_victory",love=8,trust=6,
                reason="Rudy ganó aprovechando los movimientos de Eris y sus recursos; no superó su dominio de la espada."},
            honorable_defeat={eventId="eris_training_honorable_defeat",love=4,trust=3,
                reason="Eris ganó, pero Rudy atacó y sostuvo un entrenamiento exigente con decisiones activas."},
            suspected_throw={eventId="eris_training_suspected_throw",love=-10,trust=-8,
                reason="Eris vio varios turnos vacíos con ataques disponibles y casi ningún intento. Sospecha que Rudy se dejó ganar."},
            honest_defeat={eventId="eris_training_honest_defeat",love=1,trust=1,
                reason="Eris ganó. El resultado no basta para atribuir a Rudy la intención de dejarse vencer; pueden aprender del intento."},
        },
    },
}
