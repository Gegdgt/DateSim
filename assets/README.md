# Recursos de pixel art

LÖVE utiliza los PNG existentes de estas carpetas. Las rutas y dimensiones esperadas se centralizan en [`src/data/assets.lua`](../src/data/assets.lua); [`src/systems/resources.lua`](../src/systems/resources.lua) valida cada imagen y aplica `nearest`. Los PNG originales no se renombraron ni redibujaron.

| Carpeta de ejecución | Contenido | Fuente editable desde la raíz |
| --- | --- | --- |
| `assets/characters/` | 7 hojas PNG de 256 × 64 | `sprite_sources/characters/` |
| `assets/backgrounds/` | 8 fondos PNG de 320 × 180 | `sprite_sources/backgrounds/` |
| `assets/cards/bases/` | Pergamino de 80 × 112 | `sprite_sources/cards/bases/` |
| `assets/cards/marcos/` | 4 marcos de 80 × 112 | `sprite_sources/cards/marcos/` |
| `assets/cards/reverso/` | Reverso de 80 × 112 | `sprite_sources/cards/reverso/` |
| `assets/cards/iconos/` | 16 iconos de carta y 5 auxiliares de 24 × 24 | `sprite_sources/cards/iconos/` |
| `assets/cards/extras/` | Atlas, vista previa, manifiestos y ejemplo independientes | Se conservan como auxiliares |
| `assets/audio/` | Reservada; esta versión no contiene audio | Pendiente |

Los 42 ASE se trasladaron conservando subcarpetas y contenido, comprobado mediante SHA-256 antes y después. Siguen siendo parte versionada del proyecto. `assets/source/` es una carpeta histórica vacía conservada; los nuevos editables pertenecen a `sprite_sources/`.

## Personajes

Las hojas son `rudeus.png`, `sylphiette.png`, `roxy.png`, `eris.png`, `nanahoshi.png`, `zanoba.png` y `cliff.png`. Cada una contiene cuatro cuadros horizontales de **64 × 64**, sin espacios, en este orden: `neutral=0`, `happy=1`, `worried=2`, `angry=3`. El recorte comienza en `x = índice × 64`, `y = 0`.

Conserva el canal alfa y la alineación original de los cuatro cuadros. Una expresión desconocida utiliza el cuadro neutral. El cargador no recoloca las expresiones ni adapta hojas de otras dimensiones. Los retratos se dibujan con escalas enteras.

## Escenarios

El canvas lógico mide 640 × 360: cada fondo de 320 × 180 se dibuja a escala 2. Los identificadores de la historia permanecen en inglés; no es necesario renombrar PNG:

| Identificador | PNG en `assets/backgrounds/` |
| --- | --- |
| `laboratory` | `laboratorio.png` |
| `courtyard` | `patio_universidad.png` |
| `library` | `biblioteca.png` |
| `ruins` | `ruinas.png` |
| `garden` | `patio_universidad.png` (reutilización temporal) |
| `training` | `bosque.png` (reutilización temporal) |
| `forest` | `bosque.png` |
| `observatory` | `observatorio.png` |
| `mirror_dimension` | `dimension_espejo.png` |
| `festival` | `festival.png` |

## Cartas y mantenimiento

Las cartas combinan pergamino, marco de categoría, nombre, icono, coste y disponibilidad. Los textos siguen en Lua y los detalles se muestran fuera del área de 80 × 112. Consulta [`cards/LEEME.md`](cards/LEEME.md) y el mapa completo de iconos en [`docs/RECURSOS.md`](../docs/RECURSOS.md).

Para incorporar un recurso nuevo:

1. Guarda el editable ASE en la subcarpeta de `sprite_sources/` correspondiente.
2. Exporta el PNG al árbol de `assets/`, con dimensiones nativas y transparencia donde corresponda.
3. Declara su identificador, ruta y tamaño en `src/data/assets.lua`; conserva los identificadores narrativos y de cartas existentes.
4. Reinicia el juego para renovar la caché y ejecuta `./probar.ps1`.

Los PNG válidos tienen prioridad. Un archivo ausente, ilegible o de tamaño incorrecto activa el dibujo provisional existente y un diagnóstico con la ruta y la causa. Usa `lovec.exe` para ver los mensajes de consola. No se generan ni sobrescriben PNG cuando se activa ese respaldo.
