# Recursos de pixel art

La Fase 1 funciona sin PNG. `src/systems/resources.lua` dibuja recursos provisionales originales en lienzos de baja resolución. No contiene recursos extraídos del anime. `src/ui/font.lua` contiene una fuente bitmap original con caracteres españoles.

Los PNG válidos sustituyen automáticamente los recursos provisionales al volver a iniciar el juego. Los PNG ausentes, ilegibles o con tamaño incorrecto utilizan el recurso provisional.

| Carpeta | Archivos y dimensiones |
| --- | --- |
| `characters/` | `rudeus.png`, `sylphiette.png`, `roxy.png`, `eris.png`, `nanahoshi.png`, `zanoba.png`, `cliff.png`: **256 × 64**, fondo transparente |
| `backgrounds/` | `courtyard.png`, `library.png`, `laboratory.png`, `garden.png`, `training.png`, `ruins.png`: **320 × 180** |
| `icons/` | Un archivo por identificador de carta, por ejemplo `listen.png`: **24 × 24** |
| `cards/` | `frame.png`: **80 × 112** |
| `source/` | Archivos editables `.ase` de LibreSprite; el juego no los carga |
| `audio/` | Reservada para audio original o autorizado de la Fase 4; no hay audio obligatorio |

Cada hoja de personaje tiene cuatro cuadros horizontales de **64 × 64**, en este orden e índices: `neutral=0`, `happy=1`, `worried=2`, `angry=3`. El cuadro comienza en `x = índice × 64`, siempre en `y = 0`. Conserva la posición de ojos, cara y hombros en los cuatro cuadros para evitar saltos. Exporta desde LibreSprite a PNG, sin aumentar la resolución ni añadir espacios entre cuadros. Todos los PNG cargados usan `image:setFilter("nearest", "nearest")`. Los fondos se muestran a escala entera 2; los retratos, iconos y marcos mantienen sus píxeles definidos.

Las hojas del formato anterior de **384 × 128** se consideran de tamaño incorrecto y activan el recurso provisional. Exporta una hoja nueva de **256 × 64** para sustituirlo; el cargador no recorta ni deforma automáticamente una hoja antigua.

Los recursos provisionales son dibujos hechos por código: no se presentan como archivos `.ase` exportados. Puedes crear los recursos definitivos en LibreSprite y guardarlos en estas rutas sin modificar el motor.
