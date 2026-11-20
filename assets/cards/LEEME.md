# Mushoku Tensei: Las Cartas del Destino — Recursos de cartas

Paquete original de **pixel art básico**, preparado para **LÖVE 2D / Lua** y edición con **LibreSprite**. Los elementos NO llevan texto grabado.

## Carpeta y archivos

- `marcos/`: 4 marcos de **80 × 112 px**, según categoría (Empatía: verde; Humor: naranja; Sinceridad: azul; Magia/Iniciativa: violeta); tienen **interior transparente**.
- `reverso/`: reverso completo de 80 × 112 px, con el **Espejo de las Posibilidades**.
- `bases/fondo_pergamino`: fondo claro opcional de 80 × 112 px, dibujable debajo de cualquier marco.
- `iconos/`: 16 iconos para cartas jugables, 4 iconos de categoría y un icono de coste de maná, todos de **24 × 24 px** transparentes.
- `extras/cartas_atlas_5x1.png`: atlas horizontal en orden Empatía, Humor, Sinceridad, Magia/Iniciativa, Reverso; cada celda ocupa 80 × 112 px.
- `extras/iconos_atlas.png`: atlas de iconos de 5 columnas, celdas de 24 × 24 px. El orden exacto está en `extras/manifest.json`.
- `extras/vista_previa.png`: imagen de previsualización, **no** recurso del juego.

En cada elemento individual hay **dos archivos homónimos**: `.png` para LÖVE 2D y `.ase` nativo para abrir y editar. Todos los `.ase` contienen capas editables; no son PNG renombrados. Se guardaron con celdas RGBA comprimidas ZLIB y cabeceras de formato ASE.

## Cartas definidas e iconos

| Categoría | Cartas | Iconos PNG/ASE |
| --- | --- | --- |
| Empatía | Escuchar; Dar ánimo; Recordar un detalle | `escuchar`, `dar_animo`, `recordar_un_detalle` |
| Humor | Broma ligera; Cambiar de tema; Reírse de uno mismo | `broma_ligera`, `cambiar_de_tema`, `reirse_de_uno_mismo` |
| Sinceridad | Hablar con honestidad; Reconocer un error; Compartir un miedo | `hablar_con_honestidad`, `reconocer_un_error`, `compartir_un_miedo` |
| Magia/Iniciativa | Proponer un plan; Analizar runas; Barrera de Tierra; Magia Compartida; Conjuro Combinado; Espada y Magia; Elegir Juntos | `proponer_un_plan`, `analizar_runas`, `barrera_de_tierra`, `magia_compartida`, `conjuro_combinado`, `espada_y_magia`, `elegir_juntos` |

## Implementación en Lua

Revisa `extras/ejemplo_love2d.lua`. Dibuja `fondo_pergamino.png` y después el marco, y coloca el icono y las etiquetas por código. **Filtrado `nearest`** para que los píxeles no se suavicen; escala entera (2×, 3×, 4×). Las dimensiones originales se conservan.

## Edición

Abre directamente cualquier `.ase` desde LibreSprite; cambia los colores en las capas `Color`, `Contorno`, `Detalle` y exporta PNG con canal alfa. No redimensiones con suavizado.
