# Recursos de pixel art

LÖVE carga los PNG desde `assets/`. El manifiesto [`src/data/assets.lua`](../src/data/assets.lua) declara las rutas y [`src/systems/resources.lua`](../src/systems/resources.lua) valida dimensiones, aplica `nearest` y mantiene una caché. Los editables ASE permanecen en `sprite_sources/`. Esta reestructuración conecta los recursos existentes; no sustituye las ilustraciones por nuevas imágenes provisionales.

| Carpeta | Recursos existentes | Fuentes editables |
| --- | --- | --- |
| `characters/` | 15 hojas: catorce de 256 × 64 y `badigadi_battle.png` de 512 × 128. | `sprite_sources/characters/` |
| `backgrounds/` | 12 fondos de 320 × 180. | `sprite_sources/backgrounds/` |
| `cards/bases/` | Pergamino de 80 × 112. | `sprite_sources/cards/bases/` |
| `cards/marcos/` | Cuatro marcos de 80 × 112. | `sprite_sources/cards/marcos/` |
| `cards/reverso/` | Reverso de 80 × 112. | `sprite_sources/cards/reverso/` |
| `cards/iconos/` | 41 iconos de 24 × 24, incluidas categorías y recursos auxiliares. | `sprite_sources/cards/iconos/` |
| `cards/extras/` | Atlas, vista previa, manifiestos y ejemplo independientes. | Auxiliares conservados. |
| `audio/` | Destino para grabaciones locales opcionales. | La versión actual sintetiza música y efectos desde Lua. |

El árbol `sprite_sources/` contiene 74 ASE. Estos recuentos proceden de la inspección del repositorio; los resultados de carga real se registran en [VERIFICACION.md](../docs/VERIFICACION.md).

## Personajes y expresiones

Están disponibles Rudy, Sylphiette, Roxy, Eris, Nanahoshi, Zanoba, Cliff, Hitogami, Orsted, Emisario, Badigadi, Anomalía de maná y Guardián de las ruinas, además de la hoja grande de Badigadi. El orden de cada hoja es `neutral=0`, `happy=1`, `worried=2`, `angry=3`.

`rudeus_japones.png` es una segunda apariencia de Rudy, no otro personaje: PNG RGBA de 256 × 64, acompañado por `sprite_sources/characters/rudeus_japones.ase` (cuatro cuadros de 64 × 64 y 32 bits). Ambos archivos existentes se conservan intactos. El contexto narrativo `hitogami_dream` selecciona esta hoja; el despertar y el combate físico utilizan `rudeus.png`. [Retratos contextuales](../docs/RETRATOS.md).

Los cuadros normales miden 64 × 64, sin separación. La hoja grande contiene cuatro cuadros de 128 × 128 y el cargador la trata explícitamente. Las animaciones mueven los retratos sin estirarlos; la escala es igual en ambos ejes. El combate usa la hoja normal de Badigadi para mantener legible su interfaz, y también precarga la grande.

La silueta corregida de Sylphiette ya estaba en el proyecto y se conserva junto con su ASE. Al reexportar una hoja, mantén transparencia, disposición horizontal, dimensiones nativas y ausencia de recorte o separación entre cuadros. No suavices ni estires los retratos.

## Escenarios

Cada fondo de 320 × 180 se dibuja a escala 2 sobre el canvas de 640 × 360.

| ID | PNG en `assets/backgrounds/` |
| --- | --- |
| `dream` | `sueno_hitogami.png` |
| `home` | `hogar_greyrat.png` |
| `laboratory` | `laboratorio.png` |
| `apothecary` | `botica_oculta.png` |
| `arena` | `arena_badigadi.png` |
| `courtyard`, `garden` | `patio_universidad.png` |
| `library` | `biblioteca.png` |
| `forest`, `training` | `bosque.png` |
| `ruins` | `ruinas.png` |
| `observatory` | `observatorio.png` |
| `mirror_dimension` | `dimension_espejo.png`, conservado para reutilización. |
| `festival` | `festival.png` |

## Cartas y documentos

Las cartas combinan pergamino, marco, texto, icono y coste. Los iconos nuevos de bastón, corte, piedra, empuje, coordinación, agua, tierra, fragmentos, poción, sello y antídoto están conectados mediante IDs estables. Los recursos auxiliares y las ilustraciones anteriores se conservan.

El sobre y su solapa se dibujan con geometría pixel art dentro de LÖVE. Su movimiento usa escalas enteras y el contenido se presenta en el visor de documentos; no se crea un PNG nuevo para la carta narrativa.

Para añadir recursos: guarda el ASE en su carpeta, exporta el PNG sin alterar su tamaño, declara la ruta en el manifiesto y ejecuta `./probar.ps1`. Un PNG ausente, ilegible o de dimensiones incorrectas activa el respaldo ya existente y un diagnóstico con ruta y causa; no sobrescribe el archivo original. Los enemigos sin un PNG específico pueden seguir usando las figuras programadas disponibles.
