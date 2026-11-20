# Mushoku Tensei: Las Cartas del Destino — Recursos de cartas

Paquete original de **pixel art básico**, preparado para **LÖVE 2D / Lua** y edición con **LibreSprite**. Los elementos NO llevan texto grabado.

## Carpeta y archivos

- `marcos/`: 4 marcos de **80 × 112 px**, según categoría (Empatía: verde; Humor: naranja; Sinceridad: azul; Magia/Iniciativa: violeta); tienen **interior transparente**.
- `reverso/`: reverso completo de 80 × 112 px, con el **Espejo de las Posibilidades**.
- `bases/fondo_pergamino.png`: fondo claro de 80 × 112 px, dibujado debajo del marco en el juego.
- `iconos/`: 16 iconos para cartas jugables, 4 iconos de categoría y un icono de coste de maná, todos de **24 × 24 px** transparentes.
- `extras/cartas_atlas_5x1.png`: atlas horizontal en orden Empatía, Humor, Sinceridad, Magia/Iniciativa, Reverso; cada celda ocupa 80 × 112 px.
- `extras/iconos_atlas.png`: atlas de iconos de 5 columnas, celdas de 24 × 24 px. El orden exacto está en `extras/manifest.json`.
- `extras/vista_previa.png`: imagen de previsualización, **no** recurso del juego.

Cada elemento individual conserva **dos archivos homónimos en árboles separados**: los `.png` permanecen aquí para LÖVE 2D; los `.ase` nativos están en `sprite_sources/cards/`, desde la raíz del repositorio, con las mismas subcarpetas `bases/`, `marcos/`, `iconos/` y `reverso/`. Todos los `.ase` contienen capas editables; no son PNG renombrados. Se conservaron sus bytes originales durante el traslado.

## Cartas definidas e iconos

| Categoría | Cartas | Iconos PNG/ASE |
| --- | --- | --- |
| Empatía | Escuchar; Dar ánimo; Recordar un detalle | `escuchar`, `dar_animo`, `recordar_un_detalle` |
| Humor | Broma ligera; Cambiar de tema; Reírse de uno mismo | `broma_ligera`, `cambiar_de_tema`, `reirse_de_uno_mismo` |
| Sinceridad | Hablar con honestidad; Reconocer un error; Compartir un miedo; Elegir Juntos | `hablar_con_honestidad`, `reconocer_un_error`, `compartir_un_miedo`, `elegir_juntos` |
| Magia/Iniciativa | Proponer un plan; Analizar runas; Barrera de Tierra; Magia Compartida; Conjuro Combinado; Espada y Magia | `proponer_un_plan`, `analizar_runas`, `barrera_de_tierra`, `magia_compartida`, `conjuro_combinado`, `espada_y_magia` |

## Implementación en Lua

El juego integra estos recursos mediante `src/data/assets.lua` y `src/systems/resources.lua`. La categoría real proviene de `src/data/cards.lua`: `Elegir Juntos` usa Sinceridad. Los identificadores de `Recordar un detalle` y `Reírse de uno mismo` son `remember` y `self_joke`; el manifiesto los vincula con sus nombres de archivo españoles sin alterar partidas guardadas.

Se dibuja primero `fondo_pergamino.png`, después el marco de categoría, y luego el nombre, icono, coste y disponibilidad con Lua. La descripción y los efectos se consultan en un panel separado. **Filtrado `nearest`** y escalas enteras conservan los píxeles. El archivo `extras/ejemplo_love2d.lua` es solo una demostración independiente; los datos y costes del juego están en `src/data/cards.lua`.

## Edición

Abre el `.ase` correspondiente en `sprite_sources/cards/` desde LibreSprite y exporta el PNG con canal alfa a su subcarpeta homónima de `assets/cards/`. No redimensiones con suavizado. Conserva ambos archivos versionados. Los atlas, manifiestos originales y la vista previa siguen en `extras/` como auxiliares; el cargador usa las imágenes individuales.
