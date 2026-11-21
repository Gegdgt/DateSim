# Música y efectos

`src/data/audio.lua` define música y señales originales que `src/systems/audio.lua` sintetiza al ejecutar el juego. No se incluyen grabaciones de la banda sonora ni voces oficiales del anime. Las respuestas de las cartas aparecen como texto identificado y efecto de encantamiento; no hay doblaje grabado de Rudy.

Los contextos incluyen sueño de Hitogami, hogar, misterio, tensión, investigación, conversación, romance, exploración, combate, Badigadi, victoria, derrota y finales. `src/data/presentation.lua` elige el contexto por escena y permite que cada definición lo especifique. Los contextos anteriores que siguen en el manifiesto pueden reutilizarse sin determinar la premisa de la campaña.

La carta narrativa utiliza `paper`, `envelope_open` y `revelation`. Los intentos de agua/tierra usan `magic_fail`; las entregas usan `card_gift` y `unlock`. También hay señales de escritura, selección, robo, uso y descarte de cartas, cambios de estadísticas, ataques, defensa, curación y transición. Las líneas de silencio de Rudy no ejecutan `text_blip`.

El cambio musical aplica un fundido de 0,45 segundos. Opciones permite silencio y volúmenes general, música y efectos independientes; `options.json` conserva las preferencias globales. La escritura y la selección tienen límites de frecuencia para evitar sonidos acumulados por repetición de entradas.

Para añadir una grabación propia o con permiso, declara `path="assets/audio/nombre.ogg"` en el contexto del manifiesto. `synth` puede mantenerse como respaldo. Un contexto sin archivo ni síntesis queda en silencio. No hace falta convertir las melodías actuales en archivos para ejecutar el juego.

La suite de audio valida el manifiesto y el comportamiento del gestor; consulta sus resultados reales en [VERIFICACION.md](VERIFICACION.md). Las pruebas de combate comprobaron que las acciones y transiciones ejecutan la interfaz sin errores, pero no sustituyen una revisión auditiva de mezcla, volumen y fatiga durante una sesión prolongada.
