# Descanso

El diario y `Rest.available` usan `Objectives.requirements`. La primera tarea pendiente determina el mensaje: lectura de la carta, conversación, tutorial, investigación o interacciones, con progreso como `1/3`. Una actividad reservada o su resultado todavía abierto debe cerrarse antes de dormir. No hay una segunda condición oculta de `day1_complete` en el dormitorio.

Después de tres actividades, Eris pasa del patio a su dormitorio; Roxy, de la biblioteca al suyo; Sylphie, de la sala al suyo. El movimiento espera al cierre de la conversación. El minimapa usa las mismas ubicaciones y el destino del objetivo activo.

Acércate a una esposa disponible o a su cama y pulsa E. Confirma el descanso para recibir hasta **+10 amor y +10 confianza**, sujeto al máximo de relación, fuera del presupuesto diurno. El jergón del segundo piso permite dormir solo. Si todas las esposas se separaron, no se exigen actividades imposibles: el diario muestra esa excepción.

Una esposa sin ninguna interacción diurna recibe **−20 amor y −20 confianza**, aunque Rudy duerma con ella. El descanso no modifica las visitas. Se conservan las advertencias y separaciones del sistema familiar.

`dayN_attention_<esposa>` evita repetir ausencia/atención, `dayN_rest` evita repetir el bono y `dayN_ending_processed` evita duplicar el informe. `rest.nights` guarda la noche y el punto de despertar. Cargar después de confirmar, incluso antes de ver el informe, permite continuar al resumen sin volver a premiar. Si falla el guardado, la pantalla ofrece reintentar el paso al resumen.

Los días 1–6 terminan mediante descanso y resumen. El Día 7 termina mediante el desenlace, sin noche ordinaria adicional.
