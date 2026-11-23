-- Sólo presentación: estas frases nunca conceden cartas ni habilitan magia.
return {
 backgrounds={rudeus="home",nanahoshi="laboratory",cliff="laboratory",zanoba="laboratory",eris="training",roxy="library",sylphiette="home",orsted="courtyard"},
 events={
  starter_gift={participants={"rudeus","nanahoshi"},background="laboratory",important=true},
  practice_starter={participants={"rudeus","nanahoshi"},background="laboratory"},
  first_anomaly={participants={"rudeus","nanahoshi"},background="laboratory"},
 },
 lines={
  nanahoshi={
   magic={"El patrón ya está registrado. Mientras tu maná siga sellado, tendrás que alimentarlo con energía externa.","La inscripción regula el flujo; no elimina su coste. Comprueba la reserva antes de activar la carta.","El ensayo dejó un patrón estable. Tenerlo en la colección no sustituye las condiciones de uso."},
   combat={"El gesto está grabado. La carta no te ahorrará el esfuerzo de ejecutarlo.","Comprueba el coste antes de encadenar técnicas. El encantamiento no vuelve inagotables tus fuerzas.","La secuencia es reproducible. Ahora falta aprender cuándo conviene utilizarla."},
   social={"Esta inscripción presta una voz a tu intención. La respuesta de quien te escucha seguirá siendo suya.","Hay otra frase disponible. Escoge la situación antes de escoger la carta.","El encantamiento reproduce palabras; cumplirlas sigue siendo trabajo tuyo."},
   unknown={"Esa variación no estaba en las notas. La guardaremos sin dar por probado su efecto.","No confundamos el brillo con una prueba de seguridad. Primero anotemos lo que cambió."},
  },
  cliff={
   magic={"¡La línea de retorno se mantiene! Quiero comparar esta lectura con la del ensayo anterior.","Un resultado interesante. Repetiremos la medición antes de llamarlo una ley.","El encantamiento conserva el patrón sin abrir el flujo natural. Son dos mecanismos distintos."},
   combat={"La activación tiene un intervalo claro. Si lo medimos, podrás coordinar mejor el siguiente movimiento.","¡Funciona! Aunque una prueba controlada todavía no demuestra cómo responderá bajo presión.","Anotaré el coste y el tiempo de recuperación. La utilidad también depende de sus límites."},
   social={"¿También conserva esa entonación? El registro de voz es más preciso de lo que esperaba.","Dos intenciones próximas producen frases distintas. Conviene catalogarlas por separado.","¡Otra respuesta completa! Aun así, una conversación no puede reducirse a repetir resultados."},
  },
  zanoba={
   magic={"¡Maestro, mire la precisión de ese trazo! Quisiera estudiar cómo lo sostienen las otras runas.","¡Una pieza magnífica! Prometo observarla sin desmontar el encantamiento.","Ese borde parece sencillo, pero mantiene unido todo el patrón. ¡Qué trabajo tan cuidadoso!"},
   combat={"¡Con esa técnica podremos proteger mejor las piezas durante el viaje, maestro!", "Una carta compacta y una función clara. ¡Hasta el diseño invita a practicarla!", "¡Excelente! Quiero ver cómo encaja con las técnicas que ya conoce, maestro."},
   social={"¡Maestro, hasta una respuesta delicada cabe en estas runas! No habría imaginado tanta variedad.","La voz sale de una pieza tan pequeña... ¡Cada carta merece su propia ficha de estudio!", "¡Otra forma de hacerse entender! Guardaré mis preguntas hasta que termine de leerla."},
  },
  rudeus={
   magic={"Un patrón nuevo. Tendré que revisar la energía que necesita antes de confiar en él.","Quiero practicar esta habilidad sin saltarme las precauciones de la investigación.","La carta está a salvo. Lo siguiente será aprender a usarla con cuidado."},
   combat={"Esta técnica puede cubrir un hueco de mi defensa. Necesito practicar el momento de usarla.","Ahora tengo otra opción. Elegirla bien será tan importante como conseguirla.","Quiero comprobar cómo encaja en mi mazo antes del próximo combate."},
   social={"Quizá esta intención me ayude a expresarme mejor. Primero tendré que escuchar.","Otra respuesta posible. No quiero confundir disponer de palabras con saber qué decir.","Guardaré esta carta para una ocasión en la que pueda sostener lo que expresa."},
  },
  eris={
   magic={"Ensáyala a una distancia segura. Yo te aviso si dejas un hueco en la guardia.","Bien. Ahora aprende a usarla sin perder de vista a quien tienes delante."},
   combat={"¡Eso sirve! Vamos a repetir el movimiento hasta que puedas hacerlo cansado.","No la guardes sólo porque se vea bien. Quiero verte usarla cuando toque retirarse."},
   social={"Si vas a decirme algo con esa carta, mírame cuando lo hagas.","Tienes otra respuesta. Bien. Ahora elige una que de verdad puedas cumplir."},
  },
  roxy={
   magic={"Anotemos el resultado con los errores del ensayo. Así podremos repetirlo juntos.","La fórmula ya está guardada. Empezaremos con un caudal pequeño cuando puedas practicar."},
   combat={"Revisemos dónde encaja en tu secuencia. No hace falta llevar todas las técnicas a la vez.","Buen hallazgo. La probaremos sin mezclar demasiadas variables."},
   social={"Me interesa lo que quieres decir con ella, no que encuentres una frase perfecta.","Podemos leerla juntos. A veces una intención sencilla abre una conversación difícil."},
  },
  sylphiette={
   magic={"Podemos practicar cuando terminemos lo de casa. Dejemos preparado un lugar seguro.","Me alegra que tengas otra herramienta. Revisemos juntos lo que necesita."},
   combat={"Si esa técnica te ayuda a volver a salvo, vale la pena practicarla despacio.","Anótala antes de guardar el mazo. Quiero saber cómo puedo apoyarte con ella."},
   social={"Me alegra que puedas expresarte de otra manera. También podemos quedarnos un rato escuchando.","Una carta nueva no tiene que ser una promesa grande. Podemos empezar por algo concreto."},
  },
  orsted={
   magic={"Conserva el patrón. Sus restricciones no desaparecen por haberlo adquirido.","La reserva y el control determinan su utilidad. No adelantes el ensayo."},
   combat={"Aprende sus límites antes del combate. Una técnica desconocida también puede exponerte.","El patrón está completo. La decisión de emplearlo seguirá siendo tuya."},
   social={"El encantamiento transmite la intención. No decide por quien la recibe.","Guarda la carta. No necesitas utilizar cada respuesta por el hecho de tenerla."},
  },
 },
}
