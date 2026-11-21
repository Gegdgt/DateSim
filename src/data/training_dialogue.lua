-- Texto del resultado separado del cálculo del combate. Los cuatro estados
-- mantienen la identidad Eris; no son enemigos ni relaciones adicionales.
return {
 victory={eventId="eris_training_rudy_victory",title="¡VICTORIA! — RUDY",effort="Estrategia y esfuerzo",lines={
  {speaker="eris",expression="worried",animation="surprised_jump",text="¡¿Qué?! ¡No esperaba que consiguieras atraparme con esa estrategia!"},
  {speaker="rudeus",expression="happy",delivery="thought",text="No gané un intercambio de espadas. Preparé el terreno y aproveché una apertura. Eris detiene el ejercicio con una sonrisa."},
  {speaker="eris",expression="happy",animation="happy_bounce",text="¡Ja! Parece que todavía tengo mucho que entrenar. ¡La próxima vez no voy a perder!",apply=true},
 }},
 honorable_defeat={eventId="eris_training_honorable_defeat",title="DERROTA EN ENTRENAMIENTO — ERIS GANA",effort="Derrota honorable",lines={
  {speaker="eris",expression="happy",animation="happy_bounce",text="¡Lo conseguí! ¡Esta vez gané!"},
  {speaker="eris",expression="happy",text="Pero vaya pelea, Rudy... ¡Me hiciste esforzarme de verdad!",apply=true},
 }},
 suspected_throw={eventId="eris_training_suspected_throw",title="DERROTA EN ENTRENAMIENTO — ERIS GANA",effort="Esfuerzo insuficiente observado",lines={
  {speaker="eris",expression="happy",text="¡He ganado! ...Espera. ¡Rudy! ¿Qué fue eso?"},
  {speaker="eris",expression="angry",animation="angry_shake",text="¡No me digas que te dejaste ganar!"},
  {speaker="eris",expression="angry",text="¡No quiero ganar porque tú no te esfuerzas! ¡Quiero vencerte cuando peleas en serio!",apply=true},
 }},
 honest_defeat={eventId="eris_training_honest_defeat",title="DERROTA EN ENTRENAMIENTO — ERIS GANA",effort="Derrota honesta",lines={
  {speaker="eris",expression="neutral",text="¡Alto! Ese golpe ya contaba como punto. Te vi intentarlo; perder pronto no significa que me hayas regalado la victoria."},
  {speaker="eris",expression="happy",text="Mi espada fue más rápida. Prueba a cubrirte antes de responder. ¡Para aprender estamos entrenando!",apply=true},
 }},
}
