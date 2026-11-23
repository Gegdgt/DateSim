# Carta permanente de Hitogami

El objeto `hitogami_letter` está sobre el escritorio del mapa lógico `estudio_rudy` (recurso `estudio_rudy_map`). Su colocación original es `x=176,y=64`, con alcance desde `180,116`. No es consumible ni carta equipable; no se modifica el PNG ni el ASE.

La primera interacción muestra **E — Examinar carta misteriosa**. Rudy levanta el sobre, lo abre y lee todas las páginas; la firma **—H** requiere confirmación. Sólo entonces se emite `hitogami_letter_read` y comienza la secuencia de descubrimiento de voz y maná. Entrar al estudio o levantar el sobre no completa la misión.

La animación oculta temporalmente el objeto mientras está en las manos de Rudy. Al volver al mapa se dibuja sobre el escritorio, incluso después de leerlo o completar la campaña. **E — Volver a leer la carta** abre de nuevo el texto desde la primera página y permite cerrar con Esc. La relectura no ejecuta la maldición, no modifica relaciones, no entrega premios y no reinicia objetivos. También queda accesible desde el diario o el inventario una vez encontrada.

Estados independientes en `prologue`: `letter_found`, `letter_collected` (compatibilidad con la animación original; no significa retirar el objeto), `letter_read`, `hitogami_identified`, `document_available`. El último permanece verdadero. `documentState` conserva página/fase de la primera lectura interrumpida. Releer no sustituye ese registro ni vuelve a emitir el evento narrativo.
