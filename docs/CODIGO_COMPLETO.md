# Entrega completa de la Fase 1

Este documento contiene las rutas y el contenido completo de los archivos de texto del proyecto. Los archivos reales ya están creados; no es necesario copiarlos desde aquí. Los PNG del juego están en assets/ y los editables ASE en sprite_sources/; los archivos binarios no se incluyen en este documento. La Fase 1 comprende los días uno y dos; los capítulos restantes siguen pendientes.

Raíz del proyecto: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim`

## .gitignore

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/.gitignore`

````text
tests/artifacts/*.png
tests/artifacts/*.log
dist/
*.love
__pycache__/
````

## assets/audio/.gitkeep

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/assets/audio/.gitkeep`

````text

````

## assets/backgrounds/.gitkeep

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/assets/backgrounds/.gitkeep`

````text

````

## assets/cards/.gitkeep

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/assets/cards/.gitkeep`

````text

````

## assets/cards/extras/ejemplo_love2d.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/assets/cards/extras/ejemplo_love2d.lua`

````lua
-- Ejemplo ilustrativo LÖVE 2D (sustituye la ruta base por la de tu proyecto)
local raiz = 'Mushoku_Tensei_Cartas_Del_Destino/'
local img = {}
function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  img.base = love.graphics.newImage(raiz .. 'bases/fondo_pergamino.png')
  img.marco = love.graphics.newImage(raiz .. 'marcos/marco_empatia.png')
  img.icono = love.graphics.newImage(raiz .. 'iconos/escuchar.png')
  img.reverso = love.graphics.newImage(raiz .. 'reverso/reverso_espejo.png')
  img.fuente = love.graphics.newFont(12)
  love.graphics.setFont(img.fuente)
end
function love.draw()
  local x, y, escala = 45, 30, 3
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(img.base, x, y, 0, escala, escala)
  love.graphics.draw(img.marco, x, y, 0, escala, escala)
  love.graphics.draw(img.icono, x + 28*escala, y + 31*escala, 0, escala, escala)
  love.graphics.setColor(0.14, 0.13, 0.22, 1)
  love.graphics.print('Escuchar', x + 12*escala, y + 12*escala, 0, 1, 1)
  love.graphics.print('Coste: 0', x + 12*escala, y + 94*escala, 0, 1, 1)
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(img.reverso, x + 90*escala, y, 0, escala, escala)
end
````

## assets/cards/LEEME.md

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/assets/cards/LEEME.md`

````markdown
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
````

## assets/characters/.gitkeep

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/assets/characters/.gitkeep`

````text

````

## assets/icons/.gitkeep

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/assets/icons/.gitkeep`

````text

````

## assets/README.md

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/assets/README.md`

````markdown
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
````

## assets/source/.gitkeep

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/assets/source/.gitkeep`

````text

````

## conf.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/conf.lua`

````lua
function love.conf(t)
    t.identity = "cartas_del_destino"
    t.version = "11.5"
    t.console = false
    t.window.title = "Mushoku Tensei: Las Cartas del Destino"
    t.window.width, t.window.height = 1280, 720
    t.window.minwidth, t.window.minheight = 640, 360
    t.window.resizable = true
    t.window.vsync = 1
    t.modules.physics = false
    t.modules.joystick = false
end
````

## docs/FASE_2.md

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/docs/FASE_2.md`

````markdown
# Preparación de los siguientes capítulos

La implementación jugable termina en el resumen del día dos. Los fondos de bosque, observatorio, dimensión del espejo y festival ya tienen rutas en `src/data/assets.lua`; su presencia no significa que las escenas de esos capítulos estén escritas.

## Arquitectura existente y límite actual

`src/data/story.lua` concentra diálogos, decisiones y encuentros. `src/systems/cards.lua` trabaja con datos de efectos, contextos y afinidades; `src/systems/events.lua` registra efectos una sola vez. Esta separación permite añadir contenido sin mezclar texto con dibujo ni alterar las reglas del encuentro.

La progresión aún depende de ramas específicas de la Fase 1 en `src/systems/progression.lua`. `src/systems/save.lua` mantiene su propio conjunto de checkpoints, días y decisiones permitidas. Añadir cinco capítulos directamente a ambas listas duplicaría reglas de navegación y dificultaría las migraciones. La siguiente fase debe convertir esas listas en un registro compartido, conservando los identificadores y guardados actuales.

## Cambios propuestos, todavía no implementados

| Módulo | Cambio para la siguiente fase |
| --- | --- |
| `src/data/chapters.lua` (nuevo) | Registro de capítulos con día, checkpoint inicial, escenas, encuentros y cierre. Derivar los checkpoints válidos de este registro. |
| `src/data/chapters/day3.lua` y sucesivos (nuevos) | Tablas narrativas por capítulo; identificadores estables, fondos del manifiesto y decisiones con efectos explícitos. |
| `src/data/story.lua` | Agregar las tablas de capítulos detrás de su API actual; mantener las claves de la Fase 1 para no invalidar partidas. |
| `src/systems/progression.lua` | Interpretar transiciones declaradas (`next`, resultado de encuentro, requisitos, efectos de salida); conservar la comprobación del checkpoint activo. |
| `src/systems/conditions.lua` (nuevo) | Evaluador pequeño para requisitos por evento, decisión, ruta y vínculo; validación de operadores y referencias. Evitar fragmentos de Lua ejecutables desde datos. |
| `src/systems/events.lua` | Reutilizar claves estables e idempotencia para sellos, desbloqueos, elecciones y confesiones. |
| `src/systems/save.lua` | Consultar el registro compartido de capítulos; generalizar validación de decisiones y acompañantes; añadir migración si cambia el esquema. |
| `src/data/cards.lua` | Declarar desbloqueos y cartas especiales; conservar costes 0–2, mazo de diez y reglas actuales salvo cambio de diseño explícito. |
| `src/screens/overlays.lua` o `src/screens/deck.lua` | Editor de mazo separado de la colección, limitado a diez cartas distintas y desbloqueadas mediante `Cards.validateDeck`. |
| `src/screens/hub.lua` | Consumir los lugares y requisitos del capítulo activo; evitar asumir siempre tres visitas del día dos. |
| `src/systems/relationships.lua` | Reutilizar requisitos de romance y siete IDs de final; separar acompañante de encuentro, ruta y confesión. |
| `tests/story.lua`, `tests/gameplay.lua`, integración | Comprobar todas las ramas, cargas entre decisiones, migración, rechazos de condiciones y aplicación única de efectos. |

Las transiciones deberían contener identificadores de destino y condiciones limitadas a datos, por ejemplo `next="day3_ruins"`, `requires={event="seal_truth"}` y `onComplete={event="day3_complete"}`. Antes de incorporar capítulos nuevos, un validador debe rechazar destinos, personajes, cartas y fondos desconocidos. El cierre de la Fase 1 debe seguir funcionando durante esa migración.

## Contenido previsto

| Día | Escenarios y objetivo | Estado |
| --- | --- | --- |
| 3 | `forest`, `ruins`; investigación del Sello de la Verdad | Fondos listos; narrativa, encuentros y transiciones pendientes |
| 4 | `observatory`; Sello de la Voluntad | Fondo listo; contenido pendiente |
| 5 | Elección explícita de Sylphiette, Roxy o Eris y desbloqueo de su carta especial | Definiciones e iconos de las tres cartas listos; elección y escenas pendientes |
| 6 | `mirror_dimension`; conflicto de ruta y desafío final | Fondo y evaluador de efectos listos; escenas y requisitos narrativos pendientes |
| 7 | `festival`; confesión/decisión final y uno de siete desenlaces | Fondo e IDs de final listos; escenas de los siete finales pendientes |

El siguiente incremento recomendado es extraer el registro de capítulos y migrar la Fase 1 sin cambiar su comportamiento. Una vez que pase el recorrido completo existente, implementar el día tres con el Sello de la Verdad y pruebas de continuación desde guardados del día dos. Audio y distribución independiente pueden esperar a que las rutas narrativas estén completas.
````

## docs/RECURSOS.md

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/docs/RECURSOS.md`

````markdown
# Manifiesto y cargador de recursos

`src/data/assets.lua` relaciona identificadores de juego con rutas completas relativas a la raíz que contiene `main.lua`. El juego conserva los identificadores de personajes, cartas y escenas; los PNG mantienen sus nombres originales. No hay búsquedas heurísticas por traducción ni renombrados automáticos.

## Estructura del manifiesto

| Campo | Contenido |
| --- | --- |
| `characters` | ID de personaje → hoja PNG, 7 entradas |
| `backgrounds` | ID de escenario → PNG, 10 entradas para 8 imágenes distintas |
| `cardIcons` | ID real de carta → PNG de icono, 16 entradas |
| `cardFrames` | Categoría → PNG de marco, 4 entradas |
| `categoryIcons` | Categoría → icono auxiliar, 4 entradas |
| `cardBase`, `cardBack`, `manaIcon` | Rutas del pergamino, reverso y coste de maná |
| `sizes` | Dimensiones de `character`, `background`, `card` e `icon` |

Los escenarios se documentan en [assets/README.md](../assets/README.md). Los alias `garden` y `courtyard` comparten `patio_universidad.png`; `training` y `forest` comparten `bosque.png`. La caché por ruta evita cargar dos veces una imagen compartida. Los alias temporales no son recursos provisionales dibujados por código.

## Iconos de cartas

Cada ruta parte de `assets/cards/iconos/`. Los nombres de las cartas y sus efectos siguen definidos en `src/data/cards.lua`.

| ID real | PNG |
| --- | --- |
| `listen` | `escuchar.png` |
| `encourage` | `dar_animo.png` |
| `remember` | `recordar_un_detalle.png` |
| `light_joke` | `broma_ligera.png` |
| `change_subject` | `cambiar_de_tema.png` |
| `self_joke` | `reirse_de_uno_mismo.png` |
| `be_honest` | `hablar_con_honestidad.png` |
| `admit_error` | `reconocer_un_error.png` |
| `share_fear` | `compartir_un_miedo.png` |
| `propose_plan` | `proponer_un_plan.png` |
| `analyze_runes` | `analizar_runas.png` |
| `earth_barrier` | `barrera_de_tierra.png` |
| `shared_magic` | `magia_compartida.png` |
| `combined_spell` | `conjuro_combinado.png` |
| `sword_magic` | `espada_y_magia.png` |
| `choose_together` | `elegir_juntos.png` |

`remember_detail` y `laugh_at_self` no son IDs del repositorio. El mapa utiliza `remember` y `self_joke` para conservar la compatibilidad con mazos, desbloqueos y guardados existentes.

## Marcos y composición

| Categoría de `cards.lua` | Marco en `assets/cards/marcos/` |
| --- | --- |
| `empathy` | `marco_empatia.png` |
| `humor` | `marco_humor.png` |
| `sincerity` | `marco_sinceridad.png` |
| `initiative` | `marco_magia_iniciativa.png` |

`choose_together` pertenece a `sincerity` en los datos de juego y usa ese marco. La selección del marco depende de `card.category`, nunca del nombre del icono ni de una lista visual separada.

`src/ui/card.lua` comparte la composición entre mano y colección: dibuja `bases/fondo_pergamino.png`, el marco y después nombre, categoría breve, icono y coste. Nombre y coste usan la fuente bitmap Lua en texto oscuro sobre el pergamino; la disponibilidad se muestra debajo sobre una banda oscura. La categoría breve «Magia» cabe dentro de la carta; el panel muestra «Magia e iniciativa» completo. La descripción y los efectos se muestran en ese panel separado para mantener legible el área de 80 × 112. La colección también muestra los iconos auxiliares de categoría y maná. El reverso es `reverso/reverso_espejo.png`: se precarga y tiene API de dibujo, aunque todavía no se usa en una animación de robo. Los atlas y vistas previas de `extras/` se conservan, pero no se cargan para construir las cartas.

## API de `Resources`

`Resources.new()` crea una caché independiente. `preload()` carga y valida los 42 PNG únicos del manifiesto sin dibujarlos; `App.new()` lo invoca al iniciar. Los métodos de dibujo reciben coordenadas lógicas; la escala se normaliza a un entero de al menos 1 y las coordenadas se ajustan a píxeles enteros.

| Método | Uso |
| --- | --- |
| `background(id)` | Dibuja el fondo a escala 2 en 640 × 360 |
| `portrait(id, expression, x, y, scale)` | Recorta un cuadro de la hoja y conserva transparencia |
| `cardBase(x, y, scale)` | Pergamino de 80 × 112 |
| `cardFrame(category, x, y, scale)` | Marco transparente de la categoría |
| `icon(cardId, x, y, scale)` | Icono de carta de 24 × 24 |
| `cardBack(x, y, scale)` | Reverso de 80 × 112 |
| `categoryIcon(category, x, y, scale)` | Icono auxiliar de categoría de 24 × 24 |
| `manaIcon(x, y, scale)` | Icono auxiliar de maná de 24 × 24 |

Los métodos `getBackground`, `getPortrait`, `getCardBase`, `getCardFrame`, `getIcon`, `getCardBack`, `getCategoryIcon` y `getManaIcon` permiten consultar recursos sin dibujarlos. Las hojas usan cuadros `neutral=0`, `happy=1`, `worried=2`, `angry=3`, siempre con origen `(índice × 64, 0)` y tamaño 64 × 64. Una expresión desconocida usa neutral; el PNG completo debe medir 256 × 64.

## Errores y diagnóstico

El cargador verifica existencia, decodificación protegida y dimensiones antes de aceptar un PNG. Un fallo conserva la partida abierta y activa el recurso provisional existente. No modifica el archivo original. Un PNG válido se registra con `status="png"`; los respaldos usan `status="fallback"`.

`resources.sources[path]` expone el estado, dimensiones y, cuando corresponde, `reason`. `resources.warnings` conserva los mensajes en español. El cargador imprime cada aviso una sola vez por ruta, indicando archivo y motivo: inexistente, inválido o dimensiones incorrectas. Los identificadores sin mapa se registran como `unmapped:<tipo>:<id>`. La aplicación muestra un aviso si la precarga encontró respaldos. Ejecutar mediante `lovec.exe` permite leer los detalles en consola.

Todos los objetos Image y Canvas utilizan `nearest`. La ventana normal tiene un mínimo de 640 × 360; el canvas mantiene escala entera de al menos 1. Una pantalla físicamente menor puede recortar contenido en lugar de interpolar el pixel art. La ausencia de interpolación no sustituye las comprobaciones de tamaño: una hoja antigua o un icono exportado a otra resolución se considera inválido. El manifiesto tiene 7 hojas, 8 fondos, 1 base, 4 marcos, 1 reverso, 16 iconos y 5 auxiliares: 42 PNG únicos.

## Fuentes editables

Los 42 ASE originales están en `sprite_sources/characters/`, `sprite_sources/backgrounds/` y `sprite_sources/cards/`. La rama de cartas conserva las subcarpetas originales. Se verificaron 42 coincidencias SHA-256 antes y después del traslado (175 114 bytes en total); no se regeneraron imágenes ni fuentes. `.gitignore` no excluye los ASE.

Al editar en LibreSprite, exporta al PNG homónimo dentro de `assets/`, conserva dimensiones y canal alfa, reinicia el juego para descartar su caché y ejecuta `./probar.ps1`. Los diagnósticos, las pruebas de recursos y las capturas ayudan a distinguir un archivo defectuoso de un problema de composición de UI.
````

## docs/SISTEMAS.md

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/docs/SISTEMAS.md`

````markdown
# Sistemas de juego de la Fase 1

Los módulos usan Lua compatible con LÖVE 11.5. Cartas y relaciones no dependen del renderizado. Los datos están separados de sus reglas; los textos y encuentros narrativos se definen en `src/data/story.lua`.

## Datos de cartas y personajes

`src/data/cards.lua` exporta `list` (16 definiciones ordenadas), `byId`, `categories` y `starterDeck` (10 identificadores distintos). Cada carta tiene `id`, `name`, `category`, `cost`, `description`, `icon`, `effects`, `contexts`, `affinities`, `conditions` y `unlockedAt`. Los efectos base se suman a los del contexto y a los de afinidad del personaje. `unlockedAt` documenta la intención de contenido; los desbloqueos reales se conceden mediante eventos de historia.

Las categorías son `empathy`, `humor`, `sincerity` e `initiative`. Los contextos implementados son `conversation`, `investigation` y `magic`. `conditions.character` restringe las tres cartas exclusivas a su acompañante. `conditions.kind` permite restringir una futura carta a un contexto. El icono usa el identificador de la carta y `src/data/assets.lua` lo vincula a su PNG español. Los IDs existentes son `remember` y `self_joke`; `choose_together` conserva la categoría `sincerity`.

El mazo inicial contiene Escuchar, Dar ánimo, Broma ligera, Cambiar de tema, Hablar con honestidad, Reconocer un error, Compartir un miedo, Proponer un plan, Analizar runas y Barrera de Tierra. La Fase 1 desbloquea Reírse de uno mismo y Recordar un detalle para la colección, pero no incorpora edición de mazo. Las cartas exclusivas y Elegir Juntos tienen definiciones y condiciones, y no se desbloquean durante estos dos días.

`src/data/characters.lua` exporta `list`, `byId`, `romanceIds`, `spriteWidth`, `spriteHeight`, `expressionCount` y `expressions`. Las expresiones usan índices desde cero: `neutral=0`, `happy=1`, `worried=2` y `angry=3`, correspondientes a los cuatro fotogramas de izquierda a derecha. Cada fotograma mide **64 × 64** y la hoja completa mide **256 × 64**. El recorte comienza en `índice × 64, 0`; una expresión desconocida utiliza el cuadro neutral. `src/systems/resources.lua` aplica `image:setFilter("nearest", "nearest")` a los PNG válidos. Las hojas ausentes, ilegibles o con otras dimensiones utilizan el retrato provisional, incluidas las del formato anterior.

## Recursos: manifiesto y cargador

`src/data/assets.lua` centraliza las rutas, dimensiones, diez identificadores de escenario, dieciséis iconos de cartas y cuatro categorías visuales. `src/systems/resources.lua` carga los 42 PNG únicos, conserva el alfa y utiliza `nearest`. Los alias de escenario comparten la imagen cargada. Solo un recurso ausente, ilegible o de dimensiones incorrectas activa un provisional, con diagnóstico registrado en `sources` y `warnings`. La documentación de rutas, composición por capas y API está en [RECURSOS.md](RECURSOS.md).

Los PNG siguen en `assets/`; los 42 ASE editables se conservan en `sprite_sources/` con el árbol equivalente. Las fuentes no son necesarias para ejecutar LÖVE y deben permanecer versionadas.

## Encuentros: `src/systems/cards.lua`

| API | Resultado |
| --- | --- |
| `Cards.validateDeck(deck, unlocked)` | `true` o `false, motivo`; comprueba 10 cartas conocidas, sin duplicados, y desbloqueadas si se proporciona el mapa. |
| `Cards.new(deck, context, rng)` | Encuentro nuevo. `rng(n)` es opcional y devuelve un entero uniforme de 1 a n. |
| `Cards.canPlay(encounter, index)` | Disponibilidad de una carta de la mano y motivo del rechazo. |
| `Cards.preview(encounter, index)` | Efectos de la carta sin modificar el encuentro. |
| `Cards.play(encounter, index)` | Resultado o `nil, motivo`; aplica una acción válida. |
| `Cards.pass(encounter)` | Acción gratuita que consume un turno y no otorga puntos. |
| `Cards.restore(snapshot, deck, context)` | Encuentro reconstruido y validado, o `nil`. |

Un encuentro comienza con 4 puntos de energía para los tres turnos completos, 3 cartas en mano, 7 en el mazo de robo y ninguna en el descarte. Cada carta jugada consume un turno, paga su coste, pasa al descarte y roba una carta si queda alguna. La energía no se recarga. Una carta inválida, impagable o que incumple condiciones no consume energía ni turno. Tomar un respiro siempre está disponible mientras no hayan terminado los tres turnos, incluso sin energía.

El barajado Fisher-Yates intercambia cada posición `i`, de 10 a 2, con un índice aleatorio entre 1 e `i`. No modifica el mazo seleccionado. Cada encuentro crea sus propias pilas y energía. No se vuelve a mezclar el descarte durante un encuentro.

El resultado contiene `cardId`, `score`, `trust`, `chemistry` y `text`. El estado contiene `hand`, `drawPile`, `discard`, `energy`, `turn`, `maxTurns`, `score`, `finished`, `log` y `context`. Después de la tercera acción, `finished` es verdadero y `turn` vale 4. La interfaz muestra el encuentro como completado. Los cambios de confianza y química se suman del registro y se confirman una sola vez al ver el resultado, mediante el sistema de eventos.

La restauración comprueba que las diez cartas se conservan exactamente una vez entre las tres zonas, que hay tres cartas en mano, que el registro no supera tres acciones y que coincide con el descarte. Recalcula energía, avance y efectos desde las definiciones canónicas. Los encuentros con un registro inconsistente se reinician al continuar; los datos de relación ya confirmados permanecen guardados.

## Relaciones: `src/systems/relationships.lua`

`Relationships.new()` crea registros para Sylphiette, Roxy y Eris con `trust=0`, `chemistry=0`, `events={}`, `routeState="unmet"` y `decisions={}`. `Relationships.apply(all, id, delta)` aplica `trust` y `chemistry`, limitados al intervalo de 0 a 10. `Relationships.complete(all, id, event)` registra un evento y cambia el estado inicial a `friend`.

`Relationships.canRomance(all, id, decisions)` comprueba confianza ≥ 6, química ≥ 5, eventos `route_conflict` y `mirror_truth`, y la confesión explícita `decisions.confession == id`. Es un contrato para contenido futuro: la Fase 1 no concede esos eventos ni presenta confesiones.

`Relationships.ending(all, route, decisions)` devuelve `independent` si no hay una ruta válida, `romance_sylphiette`, `romance_roxy` o `romance_eris` al cumplir todos los requisitos, y `friendship_sylphiette`, `friendship_roxy` o `friendship_eris` en los demás casos con ruta válida. Este soporte lógico está probado. Las escenas de las rutas y de los siete finales pertenecen a fases pendientes; el resumen del día 2 no es un final narrativo.

## Guardado: `src/systems/save.lua`

| API | Resultado |
| --- | --- |
| `Save.newSession()` | Partida inicial con esquema de versión 1. |
| `Save.validate(data)` | Copia normalizada o `nil, motivo`. |
| `Save.write(session)` | `true` o `false, motivo`. |
| `Save.load()` | Partida validada, o `nil, motivo`; puede devolver aviso si recuperó la copia anterior. |
| `Save.exists()` | Indica si existe una partida recuperable. |
| `Save.readOptions()` | Opciones de audio validadas, con valores predeterminados si faltan. |
| `Save.writeOptions(options)` | Guarda opciones independientemente de la partida. |

Se utiliza `love.filesystem` y la identidad configurada en `conf.lua`. Los archivos son `save.json`, `save.backup.json` y `options.json`. El archivo temporal se escribe antes del principal; se conserva una copia anterior válida. No se promete una sustitución atómica: si una escritura se interrumpe, la carga intenta recuperar la copia anterior. Una primera escritura interrumpida puede no tener copia recuperable.

Se guardan día, punto narrativo, índice del diálogo, relaciones, cartas desbloqueadas, mazo, ruta cuando exista, eventos, decisiones, opciones, último resultado y estado del encuentro activo. El día se deriva del punto narrativo válido. Se limitan estadísticas y volumen, se descartan identificadores desconocidos y se sustituye un mazo inválido por el inicial. La validación corrige decisiones mal tipadas. Una decisión de diálogo ya persistida conserva su identificador y el punto de lectura; el sistema narrativo oculta las opciones ya respondidas para permitir continuar. Un capítulo que requiere acompañante vuelve al mapa si falta esa elección.

`src/systems/json.lua` ofrece `Json.encode(value)` y `Json.decode(text)`. El lector no ejecuta código Lua; rechaza sintaxis incompleta, claves duplicadas, números no finitos y estructuras excesivamente profundas. Admite texto UTF-8, escapes Unicode y pares sustitutos. Los archivos de carga se limitan a 512 KiB.

## Verificación

`tests/gameplay.lua` exporta `run()`. Comprueba reglas de cartas, energía cero, índices inválidos, acción gratuita, finalización, preferencias y exclusivas; los siete resultados lógicos de relación; guardados parciales y corruptos, copia de respaldo, opciones, errores de escritura y conservación exacta de encuentros. El sistema de archivos de estas pruebas es una tabla en memoria: no cambia las partidas del jugador.

`tests/resources.lua` verifica el manifiesto contra los PNG existentes, expresiones, dimensiones, transparencia, filtrado y respaldos ante fallos. `tests/story.lua` comprueba decisiones, acompañantes y progresión de ambos días. `tests/ui.lua` comprueba composición, píxeles de texto, disponibilidad y controles de mouse/teclado. `tests/run.lua` integra las pantallas reales, guarda en una identidad de prueba separada, alterna resoluciones y pantalla completa, y produce capturas. Los resultados y límites de cada ejecución se documentan en [VERIFICACION.md](VERIFICACION.md).

## Ampliación narrativa

Las tablas actuales separan contenido de motor, pero `progression.lua` y `save.lua` todavía contienen transiciones y checkpoints específicos de la Fase 1. La ampliación requiere un registro compartido de capítulos y condiciones declarativas, no solo añadir diálogos. [FASE_2.md](FASE_2.md) detalla los módulos, migraciones y pruebas pendientes para los días tres a siete. El evaluador de finales y los fondos preparados no equivalen a capítulos implementados.
````

## docs/VERIFICACION.md

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/docs/VERIFICACION.md`

````markdown
# Auditoría y verificación de la Fase 1

Ejecutada el **20 de noviembre de 2026** en Windows con **LÖVE 11.5 (Mysterious Mysteries)** real, usando `C:\Program Files\LOVE\lovec.exe`. Se revisaron `main.lua`, `conf.lua`, `src/app.lua`, datos, pantallas, sistemas, UI, recursos, pruebas y documentación antes de implementar los cambios.

## Hallazgos y correcciones

- La lógica existente ya implementaba los días uno y dos, cinco encuentros, decisiones, vínculos, diario, colección, pausa y guardado. Se conservaron las reglas de diez cartas, tres en mano, tres turnos, cuatro puntos de energía por encuentro y costes de cero a dos.
- El cargador buscaba fondos con nombres ingleses y cartas en rutas antiguas. Por eso usaba provisionales aunque los PNG definitivos estaban presentes. `src/data/assets.lua` ahora resuelve explícitamente las rutas españolas, sin renombrar PNG ni cambiar identificadores narrativos o de guardado.
- Las pruebas antiguas aceptaban imágenes de reserva con las dimensiones correctas. Las nuevas exigen objetos Image provenientes de los 42 PNG reales, sin avisos de reserva, y comparan las 28 expresiones con sus píxeles originales.
- La UI dibujaba un marco genérico y colores de texto pensados para ese provisional. `src/ui/card.lua` compone pergamino, marco de categoría, nombre, categoría breve, icono y coste; usa tinta oscura y deja la disponibilidad debajo y la descripción en un panel separado. Mano y colección comparten esa composición.
- El texto del registro de «Tomar un respiro» cambiaba al restaurar el encuentro. `Cards.pass` y `Cards.restore` ahora comparten su constructor; pausa y carga conservan el estado completo.
- Faltaba navegación general por teclado. Se añadió foco visible para botones y selección de cartas con flechas, manteniendo mouse, atajos y protección contra entradas duplicadas. Los controles están centralizados en `src/config/controls.lua`.
- Los ASE estaban mezclados con los recursos de ejecución. Se trasladaron 42 archivos a `sprite_sources/`, conservando exactamente sus SHA-256 y 175 114 bytes. Los PNG y los recursos auxiliares permanecen intactos; `.gitignore` sigue permitiendo versionar los ASE.

## Ejecuciones reales

La suite original pasó antes de modificar el código: 64 comprobaciones de lógica, 871 de narrativa, 27 de recursos, 4 de disco y 91 de integración. Ese resultado no detectaba el uso incorrecto de provisionales.

La ejecución final se realizó con:

```powershell
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

Resultado: **código de salida 0, 2 116 comprobaciones aprobadas**.

```text
OK: 340 comprobaciones de cartas, relaciones, JSON y guardado.
OK: 880 comprobaciones de narrativa, progresión y carga intermedia.
Resources: 412 checks passed (42 real PNGs, mappings, expressions, transparency and diagnosed fallbacks).
OK: 374 comprobaciones de composición de cartas, márgenes e interacción.
Filesystem: 6 checks passed in isolated test identity.
Integration: 104 checks passed; 70 screen steps.
ALL TESTS PASSED
```

El registro completo local está en `tests/artifacts/test.log`. Sus avisos de imágenes ausentes, de 1 × 1 o corruptas pertenecen a fallos inyectados deliberadamente en memoria. No indican errores de los PNG del repositorio. Ninguna prueba modifica esos PNG.

En el entorno de auditoría, el primer intento dentro del sandbox falló al inicializar el sistema de archivos de LÖVE. Las ejecuciones anteriores se realizaron después mediante la ejecución autorizada fuera de ese aislamiento. No se trató el intento fallido como una prueba aprobada.

## Cobertura

| Requisito | Evidencia |
| --- | --- |
| Siete personajes y hojas de 256 × 64 | Decodificación real, Image, nearest, alfa y comparación de los cuatro cuadros de cada personaje |
| Ocho fondos de 320 × 180 | Diez identificadores con mapas esperados; caché compartida de jardín/patio y entrenamiento/bosque |
| Dieciséis iconos y cuatro marcos | Rutas exactas por ID real y categoría de `cards.lua`; dimensiones, filtros y transparencia |
| Base, reverso y cinco auxiliares | Precarga real incluida en los 42 PNG únicos |
| Provisionales solo ante error | PNG válido nunca sustituido; ausente, corrupto, tamaño incorrecto e ID desconocido generan diagnóstico y reserva |
| Cartas legibles | Medición de todos los nombres, categorías, costes y descripciones; inspección de los píxeles dibujados dentro de márgenes y orden de capas |
| Reglas y efectos únicos | Dieciséis cartas en tres contextos, previsión sin mutación, energía, condiciones, pilas, acción gratuita y restauraciones repetidas |
| Guardado y decisiones | JSON validado, copias de respaldo y restauración de decisiones y encuentro exacto, también mediante archivos físicos |
| Pausa y continuación | Encuentros guardados después de cartas y acción gratuita; comparación del estado completo al volver y cargar |
| Fase 1 completa | Pantallas reales desde Nueva partida hasta el resumen del día dos en 70 pasos; variantes narrativas de los tres acompañantes con resultados altos y bajos |
| Mouse y teclado | Hitboxes transformadas, clics en bandas rechazados, foco visible, cartas deshabilitadas, coste cero sin energía y protección contra doble entrada |
| Ventana y pantalla completa | Cambios reales a 640 × 360, 960 × 540 y 1280 × 720; F11 entra/sale de pantalla completa, escala entera y transformación inversa del mouse |

El guardado físico usa `%APPDATA%\LOVE\cartas_del_destino_tests`; las pruebas no escriben en `cartas_del_destino`. Las pruebas de UI y el recorrido de integración sustituyen el guardado por memoria.

## Revisión visual

Se inspeccionaron las diez capturas renderizadas por LÖVE en `tests/artifacts/`: menú, diálogo, encuentro, mapa, resumen, diario, colección, opciones, galería de siete personajes con sus cuatro expresiones y galería de las dieciséis cartas. Se comprobaron las capas reales, las proporciones, el contraste, los márgenes y la separación entre personajes, cartas, detalles y botones. Los pies de pantalla y etiquetas de disponibilidad tienen fondo opaco para seguir siendo legibles sobre los escenarios reales.

Las capturas y logs son artefactos regenerables ignorados por Git, no recursos del juego. La inspección visual se realizó sobre capturas; el recorrido de pantallas, entradas y cambios de ventana fue automatizado mediante LÖVE. No se presenta como una sesión manual de juego prolongada.

La comprobación final contra los blobs originales de Git confirmó SHA-256 idénticos para los **45 PNG** (42 de ejecución y tres auxiliares) y los **42 ASE** trasladados. `git diff --check` terminó sin errores.

## Archivos de la entrega

| Área | Archivos creados o modificados |
| --- | --- |
| Recursos | `src/data/assets.lua` (nuevo), `src/systems/resources.lua` |
| Coordinación y controles | `src/app.lua`, `src/config/controls.lua` |
| UI | `src/ui/card.lua` (nuevo), `src/ui/screen.lua`; `src/screens/encounter.lua`, `overlays.lua`, `dialogue.lua`, `hub.lua`, `summary.lua` |
| Lógica | `src/systems/cards.lua` |
| Pruebas | `tests/gameplay.lua`, `story.lua`, `resources.lua`, `run.lua`, `ui.lua` (nuevo) |
| Documentación | `README.md`, `assets/README.md`, `assets/cards/LEEME.md`, `docs/SISTEMAS.md`, `docs/VERIFICACION.md`, `docs/RECURSOS.md` (nuevo), `docs/FASE_2.md` (nuevo), `docs/CODIGO_COMPLETO.md` regenerado |
| Herramientas | `tools/export_source.py` |
| Fuentes | 42 movimientos desde `assets/` hacia el mismo árbol relativo dentro de `sprite_sources/` |

`main.lua`, `conf.lua`, las definiciones de cartas y personajes, la narrativa, el esquema de guardado y `.gitignore` se revisaron y se conservaron.

## Límites y siguiente fase

La verificación cubre la Fase 1 y los recursos preparados. No implementa ni valida escenas de días tres a siete. Permanecen pendientes el editor de mazo, audio, elección de ruta y confesiones, escenas de los siete finales y distribución autónoma para Windows. Jardín y entrenamiento reutilizan temporalmente patio y bosque.

Las transiciones y checkpoints todavía contienen casos específicos de la Fase 1. [FASE_2.md](FASE_2.md) detalla su migración a un registro declarativo compartido antes de incorporar el día tres. No se modificaron sus reglas narrativas durante esta integración visual.
````

## ejecutar.ps1

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/ejecutar.ps1`

````powershell
$ErrorActionPreference = 'Stop'
$loveCommand = Get-Command love.exe -ErrorAction SilentlyContinue
$loveExecutable = if ($loveCommand) { $loveCommand.Source } else { Join-Path $env:ProgramFiles 'LOVE\love.exe' }
if (-not (Test-Path -LiteralPath $loveExecutable)) {
    throw 'Instala LÖVE 11.5 desde https://love2d.org/ o agrega love.exe al PATH.'
}
& $loveExecutable $PSScriptRoot
````

## main.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/main.lua`

````lua
local App = require("src.app")
local app

function love.load(args)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    love.keyboard.setKeyRepeat(false)
    love.math.setRandomSeed(os.time())
    for _, value in ipairs(args or {}) do
        if value == "--test" then
            local ok, err = xpcall(function() require("tests.run")() end, debug.traceback)
            print(ok and "ALL TESTS PASSED" or err)
            love.event.quit(ok and 0 or 1)
            return
        end
    end
    app = App.new()
end

function love.update(dt) if app then app:update(math.min(dt, 0.1)) end end
function love.draw() if app then app:draw() end end
function love.mousepressed(x,y,button) if app then app:mousepressed(x,y,button) end end
function love.keypressed(key,scancode,isrepeat)
    if app and not isrepeat then app:keypressed(key) end
end
function love.resize() if app then app:resize() end end
function love.quit() if app then app:save() end end
````

## probar.ps1

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/probar.ps1`

````powershell
$ErrorActionPreference = 'Stop'
$loveCommand = Get-Command lovec.exe -ErrorAction SilentlyContinue
$loveExecutable = if ($loveCommand) { $loveCommand.Source } else { Join-Path $env:ProgramFiles 'LOVE\lovec.exe' }
if (-not (Test-Path -LiteralPath $loveExecutable)) {
    throw 'No se encontró lovec.exe. Instala LÖVE 11.5 para Windows.'
}
& $loveExecutable $PSScriptRoot --test
exit $LASTEXITCODE
````

## README.md

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/README.md`

````markdown
# Mushoku Tensei: Las Cartas del Destino

Proyecto jugable en español, sin conexión, desarrollado para **LÖVE 11.5 / LuaJIT (Lua 5.1)**. Historia alternativa: todos los protagonistas son adultos y Rudy no está casado. No se incluyen imágenes, música ni voces extraídas del anime.

La **Fase 1 está implementada**: menú, introducción, día uno completo, reencuentro y encuentro de cartas con Sylphiette, Roxy y Eris, elección de acompañante, recuperación del Sello de la Memoria y cierre del día dos. Incluye decisiones, estadísticas, cinco encuentros, diario, colección, pausa, opciones y guardado local. La pantalla final de esta fase es un resumen de progreso; no es uno de los siete finales de la historia.

## Ejecutar en Windows

1. Instala [LÖVE 11.5 para Windows](https://github.com/love2d/love/releases/tag/11.5).
2. Abre PowerShell en esta carpeta y ejecuta:

```powershell
& 'C:\Program Files\LOVE\love.exe' .
```

También puedes arrastrar la carpeta que contiene `main.lua` sobre `love.exe`, o ejecutar `./ejecutar.ps1` si tu configuración permite scripts locales. No requiere Lua por separado, Python para jugar, conexión, paquetes, imágenes descargadas ni compilación.

Ventana inicial 1280×720. Canvas lógico 640×360, filtro `nearest`, escalado entero y centrado con bandas cuando el tamaño de la ventana no coincide. F11 alterna pantalla completa. Los ocho escenarios PNG existentes miden 320×180 y se dibujan al doble dentro del canvas; los siete personajes utilizan cuadros de 64×64 en hojas de 256×64 con cuatro expresiones.

Los **recursos definitivos existentes están integrados** mediante `src/data/assets.lua`: personajes, escenarios, pergamino, cuatro marcos por categoría, reverso y dieciséis iconos de cartas. Se conservaron los PNG originales. Los 42 archivos editables `.ase` se encuentran en `sprite_sources/`, separados de los recursos que carga LÖVE. Los dibujos provisionales solo cubren archivos ausentes o inválidos y generan un diagnóstico.

## Controles

| Acción | Control |
| --- | --- |
| Seleccionar botones y cartas | Clic izquierdo |
| Recorrer botones habilitados | Tab, Arriba o Abajo; Enter/Espacio activa el foco |
| Mostrar texto completo / siguiente fragmento | Clic, Enter o Espacio |
| Jugar carta de la mano | Clic o teclas 1, 2, 3 |
| Inspeccionar y jugar la carta seleccionada | Izquierda/Derecha y después Enter/Espacio |
| Acción gratuita | Botón «Tomar un respiro» o P |
| Diario / colección | J / M |
| Pausa / volver | Esc |
| Guardar | F5 |
| Pantalla completa | F11 |

Una pulsación revela el texto en curso; la siguiente avanza una sola línea. Se ignora la repetición del teclado. Las decisiones narrativas se eligen con mouse o recorriendo sus botones por teclado. Al terminar tres acciones, «Ver resultado» confirma los efectos del encuentro sobre las relaciones.

## Reglas implementadas

- Mazo de exactamente diez cartas diferentes. Tres en la mano inicial, barajado Fisher–Yates nuevo en cada encuentro.
- Tres turnos; jugar una carta o tomar un respiro consume uno. Cuatro puntos de energía para **todo** el encuentro, sin recarga.
- Costes de cero a dos. Las cartas impagables o incompatibles quedan deshabilitadas. Cada carta jugada va al descarte y se roba otra si quedan cartas.
- «Tomar un respiro» siempre está disponible hasta terminar el encuentro. No consume energía ni modifica vínculos; permite completar cualquier mano.
- Efectos según contexto (conversación, investigación o magia) y personaje. La ficha a la derecha muestra la previsión exacta de efectos.
- Dieciséis cartas definidas. Diez iniciales equipadas. «Reírse de uno mismo» se desbloquea tras la anomalía; «Recordar un detalle», al completar los tres reencuentros. Las cuatro cartas de rutas/capítulo final permanecen bloqueadas. En esta fase el mazo equipado no se edita.
- Confianza y química se limitan a 0–10. Las decisiones, eventos y compañero se guardan. La compañía del día dos no elige una ruta romántica.
- Un resultado bajo tiene diálogo propio y permite seguir. La obtención del sello no depende de una mano favorable.
- El evaluador de relaciones contempla siete identificadores de final. Un romance exige confianza ≥6, química ≥5, los eventos `route_conflict` y `mirror_truth` y `decisions.confession` igual al personaje. Estos eventos y las confesiones no se obtienen en la Fase 1; sus escenas pertenecen a la Fase 3.

## Guardado

Se utiliza `love.filesystem`, identidad `cartas_del_destino`. En una instalación Windows habitual:

```text
%APPDATA%\LOVE\cartas_del_destino\save.json
%APPDATA%\LOVE\cartas_del_destino\save.backup.json
%APPDATA%\LOVE\cartas_del_destino\options.json
```

Guardado automático al cambiar de fragmento/pantalla, elegir, jugar una carta, pausar y salir. Se conserva el orden de la mano y del mazo, descarte, energía, turno y registro del encuentro. Los deltas de relación del encuentro se aplican una sola vez al confirmar el resultado.

El JSON se analiza sin ejecutar código. La carga valida versión, tipos, límites, cartas y conservación del mazo. Completa campos ausentes y recupera la copia anterior si el archivo principal está corrupto. Si un encuentro está incompleto o es inconsistente se reinicia ese encuentro; no se duplican sus efectos. Se informa de errores de escritura. «Nueva partida» pide confirmación dentro del juego si existe un guardado válido.

Las opciones de volumen y silencio se guardan y controlan el volumen de LÖVE. **Esta versión no contiene audio**.

## Cómo comprobar cada sistema

Ejecuta las pruebas con LÖVE real:

```powershell
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

También existe `./probar.ps1`. La suite comprueba cartas, barajado, energía, índices, manos inválidas, acción gratuita, relaciones, requisitos de los siete finales, JSON, datos parciales, copia de respaldo, eventos idempotentes y los tres acompañantes. Recorre las pantallas reales del día uno al cierre del día dos y verifica que pausar/continuar no altere el encuentro. Las pruebas de guardado real usan la identidad separada `cartas_del_destino_tests`; el recorrido de integración guarda en memoria. Las capturas se escriben en `tests/artifacts/`.

Prueba manual recomendada:

1. Abre Nueva partida. Verifica tipografía española, expresiones y avance con clic/Enter/Espacio. Mantener Enter no debe saltar varias líneas.
2. En la anomalía, juega cartas y observa coste, avance, descarte y robo. Usa P hasta finalizar para comprobar que una mala mano no bloquea la historia.
3. A mitad de otro encuentro, pulsa Esc, regresa al menú y elige Continuar. La mano, energía y turno deben coincidir.
4. Visita los tres lugares del día dos. Elige respuestas diferentes y revisa confianza/química en el diario antes y después de cada resultado.
5. Tras las tres visitas elige compañía, recupera el sello y llega al resumen. Reinicia para comparar los diálogos de los otros acompañantes.
6. Consulta las dieciséis cartas en M. Comprueba diez equipadas, desbloqueos y exclusivas bloqueadas.
7. Cambia tamaño de ventana y usa F11: imagen proporcionada y clics alineados. Pulsa en las bandas: no debe activarse ningún botón.
8. Cambia volumen/silencio, cierra y abre el juego para verificar persistencia. No habrá sonido hasta incorporar audio.

Consulta los resultados reales de la auditoría y sus límites en [docs/VERIFICACION.md](docs/VERIFICACION.md). La suite verifica también las dimensiones, recortes, rutas y filtrado de los PNG existentes, el respaldo ante recursos inválidos y los márgenes de los textos de cartas.

Para añadir o editar recursos, consulta [assets/README.md](assets/README.md) y [docs/RECURSOS.md](docs/RECURSOS.md). Los nombres internos de la historia no necesitan coincidir con los nombres españoles de los PNG: el manifiesto resuelve esa relación explícitamente. Una imagen ausente, ilegible o de tamaño incorrecto activa un provisional con diagnóstico; un PNG válido tiene prioridad.

## Arquitectura y ampliación

| Archivo / carpeta | Responsabilidad y contenido editable |
| --- | --- |
| `main.lua`, `conf.lua` | Callbacks de LÖVE, resolución, ventana, identidad |
| `src/app.lua`, `src/core/state_manager.lua` | Pantallas, coordinación, transiciones, escala y guardado |
| `src/data/story.lua` | Diálogos, elecciones, lugares y encuentros |
| `src/data/cards.lua` | Las 16 cartas, costes, iconos, condiciones, efectos, mazo inicial |
| `src/data/characters.lua` | Personajes, nombres, temas, colores e identificadores |
| `src/data/assets.lua` | Rutas PNG, dimensiones y mapeo explícito de escenarios, cartas y categorías |
| `src/systems/progression.lua` | Conexiones entre escenas, días, visitas y acompañante |
| `src/systems/events.lua` | Aplicación única de decisiones, desbloqueos y eventos |
| `src/systems/dialogue.lua` | Índice de diálogo y avance |
| `src/systems/cards.lua` | Reglas, barajado, previsión, juego y restauración |
| `src/systems/relationships.lua` | Vínculos, límites y evaluación de finales |
| `src/systems/save.lua`, `json.lua` | Esquema validado, lectura/escritura y respaldo |
| `src/systems/resources.lua` | Carga y validación de PNG, recortes, caché y diagnósticos; respaldo provisional |
| `src/screens/` | Menú, diálogo, mapa, cartas, pantallas auxiliares y resumen |
| `src/ui/card.lua` | Composición compartida de cartas en mano y colección; márgenes, textos y capas |
| `src/ui/` | Paleta, fuente bitmap original, botones, foco de teclado, barras e hitboxes |
| `src/config/controls.lua` | Configuración de atajos |
| `tests/` | Pruebas de lógica y recorrido real de pantallas |
| `sprite_sources/` | Fuentes editables ASE de personajes, escenarios y cartas, versionadas |

Para añadir líneas a una escena, edita solo `story.lua`. Una nueva carta se define en `cards.lua` y vincula su PNG en `assets.lua`; los efectos existentes no requieren cambios del motor. La Fase 1 todavía tiene transiciones y checkpoints específicos en `progression.lua` y `save.lua`. Antes de ampliar a siete días conviene convertirlos en un registro compartido de capítulos y transiciones declarativas; el plan concreto está en [docs/FASE_2.md](docs/FASE_2.md). Los sprites se reemplazan sin cambiar diálogos ni pantallas. Las expresiones usan `neutral=0`, `happy=1`, `worried=2`, `angry=3`, de izquierda a derecha en la hoja.

El contenido completo de cada archivo y su ruta exacta están en [docs/CODIGO_COMPLETO.md](docs/CODIGO_COMPLETO.md). Se regenera con `python tools/export_source.py`. Detalle de APIs en [docs/SISTEMAS.md](docs/SISTEMAS.md).

## Fases pendientes

- **Fase 2:** días tres y cuatro, desafíos adicionales, editor de mazo e integración de cartas desbloqueadas en mazos personalizados.
- **Fase 3:** elección de ruta, conflictos de días cinco y seis, escenas de confesión y los siete desenlaces del día siete.
- **Fase 4:** audio original/licenciado, pulido, pruebas de la historia completa y distribución autónoma para Windows.

La integración visual no implementa los días tres a siete. Hay escenarios preparados para esos capítulos, pero faltan sus escenas, encuentros, elección de ruta, confesiones y desenlaces. También siguen pendientes el editor de mazo, audio y distribución autónoma. `garden` reutiliza temporalmente el patio y `training` el bosque hasta contar con escenarios propios.
````

## src/app.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/app.lua`

````lua
local Manager = require("src.core.state_manager")
local Resources = require("src.systems.resources")
local Save = require("src.systems.save")
local Progression = require("src.systems.progression")
local Story = require("src.data.story")
local Controls = require("src.config.controls")
local Font = require("src.ui.font")
local App = {}
App.__index = App

function App.new()
    local self = setmetatable({},App)
    self.canvas=love.graphics.newCanvas(640,360)
    self.canvas:setFilter("nearest","nearest")
    self.resources=Resources.new():preload()
    self.options=Save.readOptions and Save.readOptions() or {volume=.6,muted=false}
    self.manager=Manager.new(self)
    self.toast,self.toastTime="",0
    self:resize()
    self:applyAudio()
    self:menu()
    if #self.resources.warnings>0 then
        self:notify("Aviso: "..#self.resources.warnings.." recursos provisionales. Consulta la consola.")
    end
    return self
end

function App:resize()
    local w,h=love.graphics.getDimensions()
    local fit=math.min(w/640,h/360)
    self.scale=math.max(1,math.floor(fit))
    self.offsetX=math.floor((w-640*self.scale)/2)
    self.offsetY=math.floor((h-360*self.scale)/2)
end

function App:logical(x,y)
    x,y=(x-self.offsetX)/self.scale,(y-self.offsetY)/self.scale
    if x<0 or y<0 or x>=640 or y>=360 then return nil end
    return x,y
end
function App:mouse() return self:logical(love.mouse.getPosition()) end
function App:notify(message) self.toast,self.toastTime=message,3 end
function App:applyAudio() love.audio.setVolume(self.options.muted and 0 or self.options.volume) end

function App:save()
    if not self.session then return true end
    self.session.options=self.options
    local ok,err=Save.write(self.session)
    if not ok then self:notify("No se pudo guardar: "..tostring(err)) end
    return ok
end

function App:newGame()
    self.session=Save.newSession()
    self.session.options=self.options
    self:save()
    self:resume()
end

function App:continueGame()
    local session,err=Save.load()
    if not session then self:notify(err or "No hay una partida válida."); return end
    self.session=session
    -- Las preferencias elegidas en el menú son globales y más recientes que
    -- las incluidas en una partida antigua.
    self.session.options=self.options
    self:applyAudio()
    self:resume()
    if err then self:notify(err) end
end

function App:menu()
    self.manager:switch(require("src.screens.menu").new(self))
end

function App:resume()
    if not self.session then self:menu(); return end
    local checkpoint=self.session.checkpoint
    if checkpoint=="hub" then
        self.manager:switch(require("src.screens.hub").new(self))
    elseif checkpoint=="phase_complete" then
        self.manager:switch(require("src.screens.summary").new(self))
    elseif Story.encounters[checkpoint] then
        self.manager:switch(require("src.screens.encounter").new(self))
    else
        self.manager:switch(require("src.screens.dialogue").new(self))
    end
end

function App:next(result)
    local nextId,err=Progression.next(self.session,self.session.checkpoint,result)
    if not nextId then self:notify(err or "Completa la decisión antes de continuar."); return end
    self:save()
    self:resume()
end

function App:overlay(kind)
    self:save()
    self.manager:switch(require("src.screens.overlays").new(self,kind))
end

function App:update(dt)
    self.toastTime=math.max(0,self.toastTime-dt)
    self.manager:update(dt)
end

function App:draw()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(.04,.05,.1,1)
    self.manager:draw()
    if self.toastTime>0 then
        love.graphics.setColor(.04,.05,.1,.97)
        love.graphics.rectangle("fill",12,335,616,20)
        Font.draw(self.toast,18,341,{maxWidth=604,color={1,.83,.48}})
    end
    love.graphics.setCanvas()
    love.graphics.clear(.015,.02,.04,1)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.canvas,self.offsetX,self.offsetY,0,self.scale,self.scale)
end

function App:mousepressed(x,y,button)
    x,y=self:logical(x,y)
    if x then self.manager:mousepressed(x,y,button) end
end

function App:keypressed(key)
    if Controls.matches(Controls.fullscreen,key) then
        love.window.setFullscreen(not love.window.getFullscreen(),"desktop")
        self:resize()
        return
    end
    if self.manager.transition>0 then return end
    if self.session and Controls.matches(Controls.save,key) then
        if self:save() then self:notify("Partida guardada.") end
        return
    end
    self.manager:keypressed(key)
end

return App
````

## src/config/controls.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/config/controls.lua`

````lua
-- Todos los atajos del motor se editan aquí.
return {
    advance = { "return", "space", "kpenter" },
    back = { "escape" },
    journal = { "j" },
    deck = { "m" },
    save = { "f5" },
    fullscreen = { "f11" },
    freeAction = { "p" },
    cards = { "1", "2", "3" },
    nextButton = { "tab", "down" },
    previousButton = { "up" },
    nextCard = { "right" },
    previousCard = { "left" },
    matches = function(keys, key)
        for _, candidate in ipairs(keys) do if candidate == key then return true end end
        return false
    end,
}
````

## src/core/state_manager.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/core/state_manager.lua`

````lua
local Manager = {}
Manager.__index = Manager

function Manager.new(app)
    return setmetatable({app=app,current=nil,transition=0}, Manager)
end

function Manager:switch(screen)
    self.current = screen
    self.transition = 0.18
    if screen.enter then screen:enter(self.app) end
end

function Manager:update(dt)
    self.transition = math.max(0,self.transition-dt)
    if self.current and self.current.update then self.current:update(dt) end
end

function Manager:draw()
    if self.current then self.current:draw() end
    if self.transition > 0 then
        love.graphics.setColor(0.035,0.045,0.09,self.transition/0.18)
        love.graphics.rectangle("fill",0,0,640,360)
    end
end

function Manager:mousepressed(x,y,button)
    if self.transition > 0 then return end
    if self.current and self.current.mousepressed then self.current:mousepressed(x,y,button) end
end

function Manager:keypressed(key)
    if self.transition > 0 then return end
    if self.current and self.current.keypressed then self.current:keypressed(key) end
end

return Manager
````

## src/data/assets.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/data/assets.lua`

````lua
-- Manifiesto de PNG de ejecución. Los ASE editables viven en sprite_sources/.
-- Los identificadores son los de las tablas narrativas y src/data/cards.lua.
return {
    characters={
        rudeus="assets/characters/rudeus.png",
        sylphiette="assets/characters/sylphiette.png",
        roxy="assets/characters/roxy.png",
        eris="assets/characters/eris.png",
        nanahoshi="assets/characters/nanahoshi.png",
        zanoba="assets/characters/zanoba.png",
        cliff="assets/characters/cliff.png",
    },
    backgrounds={
        laboratory="assets/backgrounds/laboratorio.png",
        courtyard="assets/backgrounds/patio_universidad.png",
        library="assets/backgrounds/biblioteca.png",
        ruins="assets/backgrounds/ruinas.png",
        garden="assets/backgrounds/patio_universidad.png", -- Reutilización temporal.
        training="assets/backgrounds/bosque.png", -- Reutilización temporal.
        forest="assets/backgrounds/bosque.png",
        observatory="assets/backgrounds/observatorio.png",
        mirror_dimension="assets/backgrounds/dimension_espejo.png",
        festival="assets/backgrounds/festival.png",
    },
    cardIcons={
        listen="assets/cards/iconos/escuchar.png",
        encourage="assets/cards/iconos/dar_animo.png",
        remember="assets/cards/iconos/recordar_un_detalle.png",
        light_joke="assets/cards/iconos/broma_ligera.png",
        change_subject="assets/cards/iconos/cambiar_de_tema.png",
        self_joke="assets/cards/iconos/reirse_de_uno_mismo.png",
        be_honest="assets/cards/iconos/hablar_con_honestidad.png",
        admit_error="assets/cards/iconos/reconocer_un_error.png",
        share_fear="assets/cards/iconos/compartir_un_miedo.png",
        propose_plan="assets/cards/iconos/proponer_un_plan.png",
        analyze_runes="assets/cards/iconos/analizar_runas.png",
        earth_barrier="assets/cards/iconos/barrera_de_tierra.png",
        shared_magic="assets/cards/iconos/magia_compartida.png",
        combined_spell="assets/cards/iconos/conjuro_combinado.png",
        sword_magic="assets/cards/iconos/espada_y_magia.png",
        choose_together="assets/cards/iconos/elegir_juntos.png",
    },
    cardFrames={
        empathy="assets/cards/marcos/marco_empatia.png",
        humor="assets/cards/marcos/marco_humor.png",
        sincerity="assets/cards/marcos/marco_sinceridad.png",
        initiative="assets/cards/marcos/marco_magia_iniciativa.png",
    },
    categoryIcons={
        empathy="assets/cards/iconos/categoria_empatia.png",
        humor="assets/cards/iconos/categoria_humor.png",
        sincerity="assets/cards/iconos/categoria_sinceridad.png",
        initiative="assets/cards/iconos/categoria_magia_iniciativa.png",
    },
    cardBase="assets/cards/bases/fondo_pergamino.png",
    cardBack="assets/cards/reverso/reverso_espejo.png",
    manaIcon="assets/cards/iconos/coste_mana.png",
    sizes={character={256,64},background={320,180},card={80,112},icon={24,24}},
}
````

## src/data/cards.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/data/cards.lua`

````lua
-- Data only: edit these records to add cards without changing the encounter engine.
local list = {
    {id="listen", name="Escuchar", category="empathy", cost=1, icon="listen",
     description="Da espacio a la otra persona. +2 confianza; destaca con Sylphiette.",
     effects={score=1, trust=2, chemistry=0}, contexts={conversation={score=1}},
     affinities={sylphiette={chemistry=1}}, conditions={}, unlockedAt=1},
    {id="encourage", name="Dar ánimo", category="empathy", cost=1, icon="encourage",
     description="Ofrece apoyo sin decidir por nadie. +1 confianza y química.",
     effects={score=1, trust=1, chemistry=1}, contexts={magic={score=1}},
     affinities={eris={trust=1}}, conditions={}, unlockedAt=1},
    {id="remember", name="Recordar un detalle", category="empathy", cost=1, icon="remember",
     description="Demuestra atención. +1 confianza, +2 química en una conversación.",
     effects={score=1, trust=1, chemistry=1}, contexts={conversation={chemistry=1}},
     affinities={sylphiette={score=1}}, conditions={}, unlockedAt=2},
    {id="light_joke", name="Broma ligera", category="humor", cost=0, icon="light_joke",
     description="Alivia la tensión. +1 química; poco eficaz ante una anomalía.",
     effects={score=0, trust=0, chemistry=1}, contexts={conversation={score=1}},
     affinities={eris={score=1}}, conditions={}, unlockedAt=1},
    {id="change_subject", name="Cambiar de tema", category="humor", cost=0, icon="change_subject",
     description="Permite respirar. Sin cambios de relación; no resuelve el desafío.",
     effects={score=0, trust=0, chemistry=0}, contexts={}, affinities={}, conditions={}, unlockedAt=1},
    {id="self_joke", name="Reírse de uno mismo", category="humor", cost=1, icon="self_joke",
     description="Se ríe de su propia torpeza. +1 confianza y química.",
     effects={score=1, trust=1, chemistry=1}, contexts={conversation={score=1}},
     affinities={roxy={chemistry=1}}, conditions={}, unlockedAt=1},
    {id="be_honest", name="Hablar con honestidad", category="sincerity", cost=1, icon="be_honest",
     description="Comparte lo que realmente piensa. +1 confianza y química.",
     effects={score=1, trust=1, chemistry=1}, contexts={investigation={score=1}},
     affinities={roxy={trust=1}}, conditions={}, unlockedAt=1},
    {id="admit_error", name="Reconocer un error", category="sincerity", cost=0, icon="admit_error",
     description="Asume su responsabilidad. +1 confianza; ayuda a revisar las runas.",
     effects={score=0, trust=1, chemistry=0}, contexts={investigation={score=1}},
     affinities={roxy={score=1}}, conditions={}, unlockedAt=1},
    {id="share_fear", name="Compartir un miedo", category="sincerity", cost=1, icon="share_fear",
     description="Se permite ser vulnerable. +1 confianza y química.",
     effects={score=1, trust=1, chemistry=1}, contexts={conversation={score=1}},
     affinities={sylphiette={trust=1}}, conditions={}, unlockedAt=1},
    {id="propose_plan", name="Proponer un plan", category="initiative", cost=1, icon="propose_plan",
     description="Propone una solución compartida. +1 confianza; eficaz al investigar.",
     effects={score=1, trust=1, chemistry=0}, contexts={investigation={score=2},magic={score=1}},
     affinities={eris={chemistry=1}}, conditions={}, unlockedAt=1},
    {id="analyze_runes", name="Analizar runas", category="initiative", cost=1, icon="analyze_runes",
     description="Examina el flujo del maná. +3 avance al investigar, +2 en magia.",
     effects={score=1, trust=0, chemistry=0}, contexts={investigation={score=2},magic={score=1}},
     affinities={roxy={trust=1}}, conditions={}, unlockedAt=1},
    {id="earth_barrier", name="Barrera de Tierra", category="initiative", cost=2, icon="earth_barrier",
     description="Protege al grupo. +4 avance en magia; +1 confianza.",
     effects={score=1, trust=1, chemistry=0}, contexts={magic={score=3}},
     affinities={eris={trust=1}}, conditions={}, unlockedAt=1},
    {id="shared_magic", name="Magia Compartida", category="initiative", cost=2, icon="shared_magic",
     description="Sylphiette y Rudy sincronizan su maná. Requiere su compañía.",
     effects={score=3,trust=1,chemistry=2}, contexts={magic={score=2}}, affinities={},
     conditions={character="sylphiette"}, exclusive="sylphiette", unlockedAt=5},
    {id="combined_spell", name="Conjuro Combinado", category="initiative", cost=2, icon="combined_spell",
     description="Roxy y Rudy conjuran como iguales. Requiere su compañía.",
     effects={score=3,trust=1,chemistry=2}, contexts={magic={score=2}}, affinities={},
     conditions={character="roxy"}, exclusive="roxy", unlockedAt=5},
    {id="sword_magic", name="Espada y Magia", category="initiative", cost=2, icon="sword_magic",
     description="Eris abre un camino para Rudy. Requiere su compañía.",
     effects={score=3,trust=1,chemistry=2}, contexts={magic={score=2}}, affinities={},
     conditions={character="eris"}, exclusive="eris", unlockedAt=5},
    {id="choose_together", name="Elegir Juntos", category="sincerity", cost=0, icon="choose_together",
     description="Renuncia al futuro impuesto. Se desbloquea en el capítulo final.",
     effects={score=3,trust=1,chemistry=1}, contexts={}, affinities={}, conditions={}, unlockedAt=7},
}

local byId = {}
for _, card in ipairs(list) do
    byId[card.id] = card
end
return {
    list=list, byId=byId,
    categories={empathy="Empatía", humor="Humor", sincerity="Sinceridad", initiative="Magia e iniciativa"},
    starterDeck={"listen","encourage","light_joke","change_subject","be_honest",
                 "admit_error","share_fear","propose_plan","analyze_runes","earth_barrier"},
}
````

## src/data/characters.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/data/characters.lua`

````lua
local list = {
    {id="rudeus",name="Rudeus Greyrat",shortName="Rudy",romance=false,color={0.73,0.55,0.33},description="Un mago adulto que aprende a elegir por sí mismo."},
    {id="sylphiette",name="Sylphiette",shortName="Sylphiette",romance=true,color={0.57,0.78,0.60},theme="Confianza y compañerismo",description="Escuchar y compartir las decisiones fortalece vuestro vínculo."},
    {id="roxy",name="Roxy Migurdia",shortName="Roxy",romance=true,color={0.48,0.63,0.88},theme="Admiración e igualdad",description="La honestidad permite encontrarse como iguales."},
    {id="eris",name="Eris Boreas Greyrat",shortName="Eris",romance=true,color={0.88,0.38,0.36},theme="Desafío y apoyo mutuo",description="Avanzar juntos requiere valor y apoyo, no competir por todo."},
    {id="nanahoshi",name="Nanahoshi",shortName="Nanahoshi",romance=false,color={0.56,0.60,0.67},description="Investiga el Espejo de las Posibilidades."},
    {id="zanoba",name="Zanoba",shortName="Zanoba",romance=false,color={0.77,0.66,0.46},description="Busca pistas en el oficio de los antiguos artesanos."},
    {id="cliff",name="Cliff",shortName="Cliff",romance=false,color={0.58,0.69,0.56},description="Estudia cómo contener la anomalía mágica."},
}
local byId = {}
for _, character in ipairs(list) do byId[character.id]=character end
return {
    list=list, byId=byId, romanceIds={"sylphiette","roxy","eris"},
    spriteWidth=64, spriteHeight=64, expressionCount=4,
    expressions={neutral=0,happy=1,worried=2,angry=3},
}
````

## src/data/story.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/data/story.lua`

````lua
-- Contenido de la Fase 1. Las escenas y elecciones no contienen lógica del motor.
local Story = {}

Story.scenes = {
    intro = {
        title = "Día 1 · Una baraja sin dueño",
        background = "laboratory",
        lines = {
            {speaker="narrator", text="Universidad de Ranoa. Una historia alternativa: Rudy y sus compañeros son adultos. Rudy está soltero. Faltan siete días para el Festival de las Seis Caras."},
            {speaker="rudeus", expression="neutral", text="Nanahoshi, encontré esta baraja entre las cajas del festival. Sus símbolos cambian cuando la toco."},
            {speaker="nanahoshi", expression="worried", text="Pertenece al Espejo de las Posibilidades. El artefacto muestra futuros posibles, pero está dañado. Si recibe el maná del festival, puede desbordarse."},
            {speaker="rudeus", expression="worried", text="Entonces tenemos siete días. ¿Las cartas nos dicen qué ocurrirá?"},
            {speaker="nanahoshi", expression="neutral", text="No. Responden a tus acciones. Elige qué decir y cómo investigar. Ninguna carta puede decidir por otra persona."},
            {speaker="nanahoshi", expression="neutral", text="Tu mazo tiene 10 cartas. Robas 3 al empezar. Hay 3 turnos y 4 puntos de energía para TODO el encuentro. Cada carta jugada se descarta y robas otra."},
            {speaker="nanahoshi", expression="worried", text="¡Una runa acaba de romperse! Juega una carta por turno. Si no puedes pagarla, puedes Tomar aire gratis. La energía no se recupera entre turnos."},
        },
    },
    day1_result = {
        title = "Día 1 · La primera anomalía",
        background = "laboratory",
        lines = {
            {speaker="nanahoshi", expression="neutral", text="La descarga se ha detenido. Las cartas reaccionan de forma distinta en una conversación y ante una anomalía mágica."},
            {speaker="rudeus", expression="worried", text="No basta con usar la carta más cara. Necesito pensar en la situación... y escuchar a quien tengo delante."},
        },
        resultKey = "day1_tutorial",
        resultLines = {
            success = {speaker="nanahoshi", expression="happy", text="Estabilizaste el círculo antes de que cediera. Hemos conservado una lectura clara de las runas."},
            partial = {speaker="nanahoshi", expression="worried", text="Mi cierre de emergencia contuvo la descarga. Se perdieron algunas lecturas, pero ya sabemos cómo seguir. Puedes aprender sin quedar atrapado."},
        },
    },
    day1_close = {
        title = "Día 1 · Tres sellos",
        background = "courtyard",
        lines = {
            {speaker="cliff", expression="neutral", text="He revisado la inscripción. Memoria, Verdad y Voluntad: tres sellos mantienen unido el espejo."},
            {speaker="zanoba", expression="happy", text="¡Una obra extraordinaria! La base indica que el Sello de la Memoria está en las ruinas del jardín antiguo."},
            {speaker="rudeus", expression="neutral", text="Mañana hablaré con Sylphiette, Roxy y Eris. Quiero saber cómo están antes de pedirles ayuda."},
            {speaker="nanahoshi", expression="neutral", text="Descansa. Ya has aprendido a Reírte de ti mismo: esa carta queda en tu colección. Cambiar el mazo llegará en la Fase 2."},
        },
    },
    meet_sylphiette = {
        title = "Día 2 · Entre las hojas",
        background = "garden",
        lines = {
            {speaker="sylphiette", expression="happy", text="¡Rudy! Preparé té mientras cuidaba las plantas del festival. Me alegra que hayas venido sin que haya una emergencia."},
            {speaker="rudeus", expression="worried", text="Me alegra verte, Sylphie. Sí hay un problema con el espejo... pero también quería pasar un rato contigo."},
            {speaker="sylphiette", expression="neutral", text="Puedo ayudar. Aunque a veces temo que solo cuentes conmigo porque siempre digo que sí."},
            {speaker="rudeus", expression="neutral", text="Quiero que puedas hablarme con libertad. También cuando no estemos de acuerdo."},
        },
        choices = {
            {id="listen_first", label="Preguntarle qué necesita ella.", effects={character="sylphiette", trust=1, chemistry=0, decision="sylphiette_priority", value="listen"}},
            {id="share_time", label="Invitarla a compartir el té, sin prisas.", effects={character="sylphiette", trust=0, chemistry=1, decision="sylphiette_priority", value="time"}},
        },
    },
    result_sylphiette = {
        title = "Día 2 · Un lugar a tu lado",
        background = "garden",
        resultKey = "encounter_sylphiette",
        resultLines = {
            success = {speaker="sylphiette", expression="happy", text="Gracias por escucharme. Quiero caminar a tu lado porque lo elijo, no porque esperes que siempre esté disponible."},
            partial = {speaker="sylphiette", expression="neutral", text="Todavía me cuesta explicarlo. Podemos seguir hablando otro día. Gracias por quedarte este rato."},
        },
        lines = {
            {speaker="rudeus", expression="neutral", text="Si vienes a las ruinas, decidiremos juntos. Tu opinión cuenta tanto como la mía."},
            {speaker="sylphiette", expression="happy", text="Entonces cuenta conmigo. Y la próxima vez prepararás tú el té."},
        },
    },
    meet_roxy = {
        title = "Día 2 · Una mesa entre iguales",
        background = "library",
        lines = {
            {speaker="roxy", expression="neutral", text="Rudeus. He encontrado una referencia al espejo entre los registros de Ranoa. Puedes sentarte; no tienes que saludarme como a un tribunal."},
            {speaker="rudeus", expression="happy", text="Es difícil dejar de pensar en usted como mi maestra."},
            {speaker="roxy", expression="worried", text="Lo fui. Pero ahora somos dos adultos estudiando el mismo problema. Si me colocas en un pedestal, no podrás ver cuándo necesito ayuda."},
            {speaker="rudeus", expression="neutral", text="Tienes razón, Roxy. Empecemos de nuevo."},
        },
        choices = {
            {id="compare_notes", label="Contrastar nuestras notas como colegas.", effects={character="roxy", trust=1, chemistry=0, decision="roxy_equality", value="colleagues"}},
            {id="invite_break", label="Proponer un descanso para conocernos mejor.", effects={character="roxy", trust=0, chemistry=1, decision="roxy_equality", value="personal"}},
        },
    },
    result_roxy = {
        title = "Día 2 · Aprender del otro",
        background = "library",
        resultKey = "encounter_roxy",
        resultLines = {
            success = {speaker="roxy", expression="happy", text="Tu interpretación me ha hecho revisar la mía. Así sí podemos trabajar: dos personas que tienen algo que aprender."},
            partial = {speaker="roxy", expression="neutral", text="No hemos aclarado todas las runas. Podemos volver a ellas con calma; prefiero una duda honesta a una respuesta apresurada."},
        },
        lines = {
            {speaker="rudeus", expression="neutral", text="Las ruinas del jardín guardan el primer sello. Me gustaría contar con tu criterio allí."},
            {speaker="roxy", expression="happy", text="Acepto. Siempre que puedas decirme que me equivoco cuando sea necesario."},
        },
    },
    meet_eris = {
        title = "Día 2 · Junto al campo de práctica",
        background = "training",
        lines = {
            {speaker="eris", expression="happy", text="¡Rudeus! Estás justo a tiempo. Sostén este blanco mientras termino la serie."},
            {speaker="rudeus", expression="worried", text="¿Puedo colocarlo detrás de una barrera primero? Me gustaría conservar todos mis dedos."},
            {speaker="eris", expression="happy", text="¡Claro! Tampoco quiero entrenar sola. He oído lo del espejo. Iré contigo si hace falta."},
            {speaker="eris", expression="neutral", text="Pero no decidas por mí qué es demasiado peligroso. Podemos protegernos los dos."},
        },
        choices = {
            {id="mutual_support", label="Acordar cómo cubrirnos el uno al otro.", effects={character="eris", trust=1, chemistry=0, decision="eris_support", value="mutual"}},
            {id="friendly_challenge", label="Aceptar un pequeño reto amistoso.", effects={character="eris", trust=0, chemistry=1, decision="eris_support", value="challenge"}},
        },
    },
    result_eris = {
        title = "Día 2 · Dos formas de ser fuerte",
        background = "training",
        resultKey = "encounter_eris",
        resultLines = {
            success = {speaker="eris", expression="happy", text="¡Así sí! Avisaste antes de mover la barrera y pude adaptarme. Formamos un buen equipo."},
            partial = {speaker="eris", expression="neutral", text="Nos falta práctica. La próxima vez dime qué intentas antes de lanzarte. Yo haré lo mismo."},
        },
        lines = {
            {speaker="rudeus", expression="neutral", text="El primer sello está en las ruinas. No sé qué encontraremos, pero no quiero cargar con todo solo."},
            {speaker="eris", expression="happy", text="Bien. Pedir apoyo también cuenta. Avísame cuando salgas."},
        },
    },
    seal_intro = {
        title = "Día 2 · El Sello de la Memoria",
        background = "ruins",
        lines = {
            {speaker="narrator", text="Rudy y {companion} cruzan el jardín antiguo. Una puerta sin cerradura responde al brillo de la baraja."},
            {speaker="rudeus", expression="worried", text="Las runas muestran recuerdos que no reconozco. El espejo intenta convertirlos en algo que desee creer."},
            {speaker="companion", expression="neutral", text="{companionAdvice}"},
            {speaker="rudeus", expression="neutral", text="No voy a prometer un futuro perfecto. Vamos a recuperar el sello, paso a paso."},
        },
    },
    seal_result = {
        title = "Día 2 · Un recuerdo verdadero",
        background = "ruins",
        resultKey = "seal_encounter",
        resultLines = {
            success = {speaker="companion", expression="happy", text="La barrera cedió sin romperse. ¡El sello está intacto! Mantuvimos el ritmo juntos."},
            partial = {speaker="companion", expression="worried", text="La barrera se cerró otra vez. Esperemos... mira, al dejar de forzarla aparece un paso. Podemos recoger el sello con cuidado."},
        },
        lines = {
            {speaker="rudeus", expression="happy", text="Lo tenemos: el Sello de la Memoria. No muestra una vida ideal. Solo lo que realmente hemos compartido."},
            {speaker="companion", expression="happy", text="{companionMemory}"},
        },
    },
    day2_close = {
        title = "Día 2 · Lo que elegimos recordar",
        background = "laboratory",
        lines = {
            {speaker="nanahoshi", expression="happy", text="El primer sello está a salvo. El espejo sigue inestable, pero ya no absorbe maná de esta sala."},
            {speaker="zanoba", expression="neutral", text="La siguiente inscripción señala unas ruinas en el bosque. Deben de custodiar el Sello de la Verdad."},
            {speaker="cliff", expression="neutral", text="Yo vigilaré el laboratorio esta noche. Todos necesitamos descansar antes de seguir."},
            {speaker="rudeus", expression="neutral", text="Hoy elegí compartir el camino con {companion}. Aún no sé qué futuro quiero. Sí sé que debo construirlo con mis decisiones."},
            {speaker="narrator", text="Fin del contenido jugable de la Fase 1. Tu progreso queda guardado. Los días 3 a 7, las rutas y los finales se desarrollarán en las siguientes fases."},
        },
    },
}

Story.encounters = {
    day1_tutorial = {title="La runa desbordada", kind="magic", character=nil, background="laboratory", intro="Contén la anomalía. Magia e iniciativa ayudan; puedes Tomar aire gratis.", targetScore=5},
    encounter_sylphiette = {title="Escucharnos de verdad", kind="conversation", character="sylphiette", background="garden", intro="Sylphie quiere poder contar contigo sin dejar de elegir por sí misma.", targetScore=5},
    encounter_roxy = {title="Entre colegas", kind="investigation", character="roxy", background="library", intro="Investiga junto a Roxy: honestidad, ideas y espacio para las dudas.", targetScore=5},
    encounter_eris = {title="Cubrirnos la espalda", kind="conversation", character="eris", background="training", intro="Eris valora la franqueza y la iniciativa. Acuerden cómo apoyarse.", targetScore=5},
    seal_encounter = {title="La puerta de los recuerdos", kind="magic", character="companion", background="ruins", intro="Recupera el Sello de la Memoria con tu acompañante.", targetScore=5},
}

Story.locations = {
    {character="sylphiette", title="Jardín de Ranoa", description="Sylphiette · Confianza y compañerismo", background="garden"},
    {character="roxy", title="Biblioteca", description="Roxy · Admiración e igualdad", background="library"},
    {character="eris", title="Campo de práctica", description="Eris · Desafío y apoyo mutuo", background="training"},
}

Story.companionNames = {sylphiette="Sylphiette", roxy="Roxy", eris="Eris"}
Story.companionAdvice = {
    sylphiette="Mírame, Rudy. Podemos comprobar juntos qué es real. No tienes que resolverlo sin ayuda.",
    roxy="La ilusión repite un patrón. Yo leeré la secuencia; tú comprueba mi hipótesis. Si falla, la revisamos.",
    eris="Yo cubriré el paso. Tú dime cuándo avanzar. Si uno se pierde, el otro lo trae de vuelta.",
}
Story.companionMemory = {
    sylphiette="Me quedaré con el té de esta mañana. Fue un momento pequeño, pero me escuchaste.",
    roxy="Recordaré esta investigación compartida. Tener preguntas a tu lado me resulta más fácil.",
    eris="Yo recordaré que confiamos en el otro. Y que todavía me debes otra ronda de entrenamiento.",
}

return Story
````

## src/screens/dialogue.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/screens/dialogue.lua`

````lua
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Progression=require("src.systems.progression")
local Dialogue=require("src.systems.dialogue")
local Characters=require("src.data.characters")
local Controls=require("src.config.controls")
local utf8=require("utf8")
local DialogueScreen={}

function DialogueScreen.new(app)
    local s=Screen.new(app)
    s.scene=Progression.scene(app.session,app.session.checkpoint)
    assert(s.scene,"Escena desconocida: "..tostring(app.session.checkpoint))
    s.dialogue=Dialogue.new(s.scene,app.session.dialogueIndex)
    s.elapsed=0
    s.visible=0
    function s:update(dt)
        self.elapsed=self.elapsed+dt
        self.visible=math.floor(self.elapsed*50)
    end
    function s:fullText() return self.dialogue:current().text end
    function s:ready() return self.visible >= utf8.len(self:fullText()) end
    function s:advance()
        if not self:ready() then
            self.elapsed=utf8.len(self:fullText())/50+.1
            self.visible=utf8.len(self:fullText())
            return
        end
        if self.dialogue:isLast() then
            if self.scene.choices and #self.scene.choices>0 then return end
            app:next()
        else
            self.dialogue:advance()
            app.session.dialogueIndex=self.dialogue.index
            self.elapsed,self.visible=0,0
            app:save()
        end
    end
    function s:draw()
        self:begin()
        local line=self.dialogue:current()
        app.resources:background(self.scene.background or "courtyard")
        self:header(self.scene.title)
        local char=Characters.byId[line.speaker]
        local portrait=char and line.speaker or "rudeus"
        app.resources:portrait(portrait,line.expression or "neutral",39,83,2)
        W.panel(172,67,435,49)
        self:text("RANOA · FESTIVAL DE LAS SEIS CARAS",185,79,408,P.gold)
        self:text("Las decisiones de Rudy son tuyas.",185,97,408,P.muted)
        local choices=self.scene.choices
        if self.dialogue:isLast() and self:ready() and choices then
            for i,choice in ipairs(choices) do
                self:button(choice.label,172,126+(i-1)*39,435,34,function()
                    local ok,err=Progression.choose(app.session,app.session.checkpoint,choice.id)
                    if ok then app:next() else app:notify(err) end
                end)
            end
        end
        W.panel(18,227,604,116)
        W.panel(30,214,math.max(112,math.min(272,#(char and char.name or "Narración")*6+28)),24)
        self:text(char and char.name or "Narración",42,222,260,P.gold)
        local full=self:fullText()
        local boundary=utf8.offset(full,self.visible+1)
        local shown=boundary and full:sub(1,boundary-1) or full
        self:text(shown,34,250,572,P.ink)
        local hint=self:ready() and ((choices and self.dialogue:isLast()) and "Elige una respuesta arriba" or "CLIC / ENTER / ESPACIO  >") or "CLIC para mostrar el texto"
        self:text(hint,34,325,572,P.muted,1,"right")
    end
    function s:mousepressed(x,y,b)
        if self:click(x,y,b) then return end
        if b==1 then self:advance() end
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.advance,key) then self:advance()
        elseif Controls.matches(Controls.back,key) then app:overlay("pause")
        elseif Controls.matches(Controls.journal,key) then app:overlay("journal")
        elseif Controls.matches(Controls.deck,key) then app:overlay("deck") end
    end
    return s
end
return DialogueScreen
````

## src/screens/encounter.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/screens/encounter.lua`

````lua
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Data=require("src.data.cards")
local Characters=require("src.data.characters")
local Cards=require("src.systems.cards")
local Progression=require("src.systems.progression")
local Controls=require("src.config.controls")
local CardView=require("src.ui.card")
local Encounter={}

function Encounter.new(app)
    local s=Screen.new(app)
    s.definition=Progression.encounter(app.session,app.session.checkpoint)
    local context={kind=s.definition.kind,character=s.definition.character}
    local restored=Cards.restore(app.session.encounter,app.session.deck,context)
    app.session.encounter=restored or Cards.new(app.session.deck,context)
    s.enc=app.session.encounter
    s.age=0
    s.selected=1
    s.feedback=#s.enc.log>0 and s.enc.log[#s.enc.log].text or "Elige una carta. Cada acción utiliza uno de tus tres turnos."
    app:save()
    function s:update(dt) self.age=self.age+dt end
    function s:act(index)
        if self.age<.18 then return end
        local result,err
        if index then result,err=Cards.play(self.enc,index) else result,err=Cards.pass(self.enc) end
        if not result then app:notify(err); return end
        self.feedback=result.text
        self.selected=math.min(self.selected,#self.enc.hand)
        self.age=0
        app:save()
    end
    function s:finish()
        if not self.enc.finished then return end
        local result={score=self.enc.score,trust=0,chemistry=0}
        for _,entry in ipairs(self.enc.log) do
            result.trust=result.trust+entry.trust
            result.chemistry=result.chemistry+entry.chemistry
        end
        app:next(result)
    end
    function s:draw()
        self:begin()
        local enc,def=self.enc,self.definition
        app.resources:background(def.background)
        love.graphics.setColor(.025,.035,.07,.45)
        love.graphics.rectangle("fill",0,38,640,322)
        self:header("DÍA "..app.session.day.." / "..def.title)
        local char=def.character and Characters.byId[def.character]
        app.resources:portrait(def.character or "nanahoshi",enc.finished and "happy" or "neutral",6,52,2)
        W.panel(135,48,487,96)
        self:text(char and char.name or "Nanahoshi · Tutorial",147,60,462,P.gold)
        self:text(def.intro,147,79,462,P.ink)
        self:text("3 turnos · 4 energía TOTAL · Robas después de jugar",147,111,462,P.teal)
        self:text("Los puntos de vínculo se confirman al ver el resultado.",147,128,462,P.muted)
        W.panel(135,151,487,40)
        self:text(self.feedback,147,162,462,P.gold)
        W.panel(18,196,110,128)
        self:text(enc.finished and "COMPLETADO" or "TURNO "..enc.turn.." / 3",28,208,90,P.gold)
        self:text("ENERGÍA",28,229,90,P.muted)
        for i=1,4 do
            love.graphics.setColor(unpack(i<=enc.energy and P.teal or P.border))
            love.graphics.rectangle("fill",28+(i-1)*21,245,15,9)
        end
        self:text("AVANCE "..enc.score.."/"..def.targetScore,28,267,90,P.ink)
        W.bar(28,286,90,6,enc.score,def.targetScore,P.gold)
        self:text("Robo "..#enc.drawPile.."\nDescarte "..#enc.discard,28,301,90,P.muted)
        local mx,my=app:mouse()
        local mouseMoved=mx~=self.lastMouseX or my~=self.lastMouseY
        self.lastMouseX,self.lastMouseY=mx,my
        for i,id in ipairs(enc.hand) do
            local x,y=143+(i-1)*94,199
            local card=Data.byId[id]
            local can=Cards.canPlay(enc,i)
            local hover=mx and mx>=x and mx<x+80 and my>=y and my<y+112
            if hover and mouseMoved then self.selected=i; self.keyboardFocus=nil end
            CardView.draw(app.resources,card,x,y,{selected=self.selected==i,disabled=not can,
                status="["..i.."] "..(can and "JUGAR" or (enc.finished and "FIN" or "NO DISP."))})
            self.buttons[#self.buttons+1]={x=x,y=y,w=80,h=112,disabled=not can,action=function() self:act(i) end}
        end
        W.panel(429,196,193,128)
        local card=Data.byId[enc.hand[self.selected] or enc.hand[1]]
        if card then
            self:text(Data.categories[card.category],439,203,173,P.teal)
            self:text(card.description,439,227,173,P.ink)
            local preview=Cards.preview(enc,self.selected)
            local can,reason=Cards.canPlay(enc,self.selected)
            if can and preview then
                self:text("Aquí: +"..preview.score.." avance\n+"..preview.trust.." conf. +"..preview.chemistry.." química",439,296,173,P.gold)
            elseif reason then self:text(reason,439,291,173,P.muted) end
        end
        W.panel(18,333,361,21,{shadow=false})
        self:text("Flechas: elegir · Enter: jugar · 1/2/3",24,340,349,P.muted)
        self:button(enc.finished and "Ver resultado >" or "Tomar un respiro [P]",387,331,235,23,function()
            if enc.finished then self:finish() else self:act() end
        end)
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.previousCard,key) or Controls.matches(Controls.nextCard,key) then
            self.keyboardFocus=nil
            self.selected=(self.selected-1+(Controls.matches(Controls.nextCard,key) and 1 or -1))%#self.enc.hand+1
        elseif Controls.matches(Controls.back,key) then app:overlay("pause")
        elseif Controls.matches(Controls.journal,key) then app:overlay("journal")
        elseif Controls.matches(Controls.deck,key) then app:overlay("deck")
        elseif self.enc.finished and Controls.matches(Controls.advance,key) then self:finish()
        elseif Controls.matches(Controls.advance,key) then self:act(self.selected)
        elseif Controls.matches(Controls.freeAction,key) then self:act()
        else for i,k in ipairs(Controls.cards) do if key==k then self:act(i); return end end end
    end
    return s
end
return Encounter
````

## src/screens/hub.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/screens/hub.lua`

````lua
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Story=require("src.data.story")
local Characters=require("src.data.characters")
local Progression=require("src.systems.progression")
local Controls=require("src.config.controls")
local Hub={}
function Hub.new(app)
    local s=Screen.new(app)
    function s:draw()
        self:begin()
        app.resources:background("courtyard")
        self:header("DÍA 2 / REENCUENTROS EN RANOA")
        W.panel(18,47,604,41)
        local companions=Progression.availableCompanions(app.session)
        local ready=#companions==3
        self:text(ready and "EL SELLO DE LA MEMORIA" or "TRES CAMINOS QUE VUELVEN A ENCONTRARSE",30,58,578,P.gold)
        self:text(ready and "Elige quién vendrá a las ruinas. La ruta romántica se decidirá más adelante." or "Visita a las tres. Cada encuentro revela una forma distinta de conectar.",30,74,578,P.ink)
        for i,place in ipairs(Story.locations) do
            local id=place.character
            local char=Characters.byId[id]
            local x=18+(i-1)*204
            W.panel(x,99,196,231)
            app.resources:portrait(id,app.session.events["meeting_"..id] and "happy" or "neutral",x+34,108,2)
            self:text(char.shortName,x+10,241,176,P.gold,1,"center")
            self:text(place.title,x+10,258,176,P.muted,1,"center")
            local r=app.session.relationships[id]
            self:text("Conf. "..r.trust.."  /  Química "..r.chemistry,x+10,276,176,P.ink,1,"center")
            local visited=app.session.events["meeting_"..id]
            self:button(ready and "Elegir compañía" or (visited and "Encuentro completo" or "Visitar"),x+8,297,180,24,function()
                local nextId,err
                if ready then nextId,err=Progression.selectCompanion(app.session,id)
                else nextId,err=Progression.visit(app.session,id) end
                if nextId then app:save(); app:resume() else app:notify(err) end
            end,visited and not ready)
        end
        W.panel(18,336,604,20,{shadow=false})
        self:text("Puedes consultar tus vínculos en el diario. Guardado automático activado.",26,343,588,P.ink)
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.back,key) then app:overlay("pause")
        elseif Controls.matches(Controls.journal,key) then app:overlay("journal")
        elseif Controls.matches(Controls.deck,key) then app:overlay("deck") end
    end
    return s
end
return Hub
````

## src/screens/menu.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/screens/menu.lua`

````lua
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Save=require("src.systems.save")
local Menu={}
function Menu.new(app)
    local s=Screen.new(app)
    s.confirm=false
    s.hasSave=Save.exists()
    function s:draw()
        self:begin()
        app.resources:background("courtyard")
        love.graphics.setColor(.035,.045,.09,.48)
        love.graphics.rectangle("fill",0,0,640,360)
        W.panel(26,24,364,302)
        self:text("UNA HISTORIA ALTERNATIVA",44,42,330,P.teal)
        self:text("MUSHOKU TENSEI",44,65,330,P.gold,2)
        self:text("LAS CARTAS\nDEL DESTINO",44,94,330,P.ink,2)
        self:text("Siete días. Un espejo roto.\nUn futuro que se construye contigo.",44,146,310,P.muted)
        if self.confirm then
            self:text("Nueva partida reemplazará el guardado.\n¿Comenzar de nuevo?",44,195,320,P.gold)
            self:button("Comenzar",44,239,150,28,function() app:newGame() end)
            self:button("Cancelar",205,239,150,28,function() self.confirm=false end)
        else
            self:button("Nueva partida",44,190,310,27,function()
                if self.hasSave then self.confirm=true else app:newGame() end
            end)
            self:button("Continuar",44,223,310,27,function() app:continueGame() end,not self.hasSave)
            self:button("Opciones",44,256,150,27,function() app:overlay("options") end)
            self:button("Salir",204,256,150,27,function() love.event.quit() end)
        end
        self:text("FASE 1  /  DÍAS 1 Y 2",44,303,320,P.muted)
        app.resources:portrait("sylphiette","happy",417,131,1)
        app.resources:portrait("roxy","neutral",523,131,1)
        app.resources:portrait("eris","neutral",476,217,1)
        self:text("FAN GAME · PERSONAJES ADULTOS",400,333,229,P.ink)
    end
    return s
end
return Menu
````

## src/screens/overlays.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/screens/overlays.lua`

````lua
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Data=require("src.data.cards")
local Characters=require("src.data.characters")
local Save=require("src.systems.save")
local Controls=require("src.config.controls")
local CardView=require("src.ui.card")
local Overlays={}

function Overlays.new(app,kind)
    local s=Screen.new(app)
    s.kind=kind
    s.selected=1
    local function optionChanged()
        app:applyAudio()
        local ok,err=Save.writeOptions(app.options)
        if not ok then app:notify("No se guardaron las opciones: "..tostring(err)) end
        if app.session then app:save() end
    end
    function s:draw()
        self:begin()
        app.resources:background("library")
        love.graphics.setColor(.025,.035,.07,.7)
        love.graphics.rectangle("fill",0,0,640,360)
        if kind=="options" then
            self:header("OPCIONES",true)
            W.panel(70,65,500,246)
            self:text("AUDIO",90,86,460,P.gold,2)
            self:text("Volumen general: "..math.floor(app.options.volume*100+.5).."%",90,124,460,P.ink)
            self:button("-",90,148,60,29,function() app.options.volume=math.max(0,app.options.volume-.1); optionChanged() end)
            W.bar(166,157,250,10,app.options.volume,1,P.teal)
            self:button("+",434,148,60,29,function() app.options.volume=math.min(1,app.options.volume+.1); optionChanged() end)
            self:button(app.options.muted and "Sonido: silenciado" or "Sonido: activado",90,192,404,29,function() app.options.muted=not app.options.muted; optionChanged() end)
            self:text("La Fase 1 no incluye música ni efectos de sonido.\nLa configuración queda preparada y guardada.",90,240,450,P.muted)
            self:text("F11: pantalla completa · Esc: volver",90,282,450,P.teal)
        elseif kind=="pause" then
            self:header("PARTIDA EN PAUSA",true)
            W.panel(132,67,376,249)
            self:text("UN MOMENTO PARA RESPIRAR",151,88,338,P.gold)
            self:button("Volver a la historia",153,118,334,29,function() app:resume() end)
            self:button("Guardar partida [F5]",153,154,334,29,function() if app:save() then app:notify("Partida guardada.") end end)
            self:button("Opciones",153,190,334,29,function() app:overlay("options") end)
            self:button("Menú principal",153,226,334,29,function() app:save(); app.session=nil; app:menu() end)
            self:button("Salir",153,262,334,29,function() love.event.quit() end)
        elseif kind=="journal" then
            self:header("DIARIO / PERSONAJES Y RECUERDOS",true)
            for i,id in ipairs(Characters.romanceIds) do
                local char=Characters.byId[id]
                local r=app.session.relationships[id]
                local x=18+(i-1)*204
                W.panel(x,49,196,215)
                self:text(char.shortName,x+10,61,176,P.gold)
                self:text(char.theme,x+10,79,176,P.muted)
                self:text("Confianza "..r.trust.." / 10",x+10,113,176,P.ink)
                W.bar(x+10,129,176,7,r.trust,10,P.teal)
                self:text("Química "..r.chemistry.." / 10",x+10,150,176,P.ink)
                W.bar(x+10,166,176,7,r.chemistry,10,P.rose)
                self:text("Reencuentro: "..(r.events.reunion and "sí" or "pendiente").."\nSello: "..(r.events.memory_seal and "compartido" or "pendiente"),x+10,187,176,P.ink)
                local states={unmet="sin conocer",friend="amistad",chosen="elegida",romance="romance",friendship="amistad",active="en curso",locked="sin elegir"}
                self:text("Vínculo: "..(states[r.routeState] or "sin elegir"),x+10,232,176,P.muted)
            end
            W.panel(18,275,604,67)
            local companion=app.session.decisions.companion
            self:text("Día "..app.session.day.." · Sello de la Memoria: "..(app.session.events.seal_memory and "recuperado" or "pendiente"),30,287,578,P.gold)
            self:text("Compañía: "..(companion and Characters.byId[companion].shortName or "por elegir")..". Romance: requiere eventos de ruta y una confesión expresa.",30,305,578,P.ink)
            self:text("Los puntos por sí solos no desbloquean una relación romántica.",30,328,578,P.muted)
        elseif kind=="deck" then
            self:header("MAZO / COLECCIÓN DE CARTAS",true)
            W.panel(18,49,306,293)
            self:text("10 CARTAS EQUIPADAS",30,60,282,P.gold)
            local equipped={}
            for _,id in ipairs(app.session.deck) do equipped[id]=true end
            for i,card in ipairs(Data.list) do
                local unlocked=app.session.unlocked[card.id]
                local label=(equipped[card.id] and "* " or (unlocked and "+ " or "- "))..card.name
                self:button(label,27,79+(i-1)*16,288,15,function() self.selected=i end,false,self.selected==i)
            end
            W.panel(336,49,286,293)
            local card=Data.list[self.selected]
            CardView.draw(app.resources,card,350,62)
            app.resources:categoryIcon(card.category,442,64,1)
            self:text(Data.categories[card.category],474,70,134,P.teal)
            app.resources:manaIcon(442,99,1)
            self:text("Energía: "..card.cost,474,105,134,P.ink)
            self:text(app.session.unlocked[card.id] and (equipped[card.id] and "EN EL MAZO" or "DESBLOQUEADA") or "BLOQUEADA\nCapítulos futuros",442,139,166,P.gold)
            self:text(card.description,352,188,254,P.ink)
            self:text("* Equipada   + Desbloqueada\n- Bloqueada\n\nEl editor de mazo llegará en la Fase 2. Revisa aquí las 16 cartas.",352,249,254,P.muted)
        end
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.back,key) then app:resume() end
    end
    return s
end
return Overlays
````

## src/screens/summary.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/screens/summary.lua`

````lua
local Screen=require("src.ui.screen")
local W=require("src.ui.widgets")
local P=require("src.ui.palette")
local Characters=require("src.data.characters")
local Controls=require("src.config.controls")
local Summary={}
function Summary.new(app)
    local s=Screen.new(app)
    function s:draw()
        self:begin()
        app.resources:background("courtyard")
        love.graphics.setColor(.025,.035,.07,.65)
        love.graphics.rectangle("fill",0,0,640,360)
        W.panel(26,23,588,309)
        self:text("EL PRIMER SELLO",46,44,548,P.gold,2)
        self:text("FASE 1 COMPLETADA · DÍAS 1 Y 2",46,76,548,P.teal)
        local companion=app.session.decisions.companion or "sylphiette"
        app.resources:portrait(companion,"happy",39,110,2)
        self:text("Recuperaste el Sello de la Memoria junto a "..Characters.byId[companion].shortName..".",174,110,418,P.ink)
        for i,id in ipairs(Characters.romanceIds) do
            local r=app.session.relationships[id]
            self:text(Characters.byId[id].shortName..": confianza "..r.trust.."/10 · química "..r.chemistry.."/10",174,155+(i-1)*22,418,P.gold)
        end
        self:text("Tu partida está guardada. La ruta romántica sigue sin elegir. Los días 3 a 7 y sus siete desenlaces quedan pendientes de las siguientes fases.",174,231,414,P.muted)
        self:button("Diario",46,290,156,27,function() app:overlay("journal") end)
        self:button("Colección",214,290,170,27,function() app:overlay("deck") end)
        self:button("Menú principal",396,290,198,27,function() app:save(); app.session=nil; app:menu() end)
        self:text("Las cartas no deciden por ti. Tú eliges los vínculos que construyes.",26,345,588,P.ink,1,"center")
    end
    function s:keypressed(key)
        if self:navigate(key) then return end
        if Controls.matches(Controls.back,key) then app:overlay("pause") end
    end
    return s
end
return Summary
````

## src/systems/cards.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/systems/cards.lua`

````lua
local Data = require("src.data.cards")
local Cards = {}

local function copy(list)
    local out={}
    for i,v in ipairs(list) do out[i]=v end
    return out
end

function Cards.validateDeck(deck,unlocked)
    if type(deck)~="table" or #deck~=10 then return false,"El mazo debe tener exactamente 10 cartas." end
    local seen={}
    for _,id in ipairs(deck) do
        if not Data.byId[id] then return false,"El mazo contiene una carta desconocida." end
        if seen[id] then return false,"Este mazo no permite cartas repetidas." end
        if unlocked and not unlocked[id] then return false,"El mazo contiene una carta bloqueada." end
        seen[id]=true
    end
    return true
end

function Cards.new(deck,context,rng)
    local ok,err=Cards.validateDeck(deck)
    assert(ok,err)
    local pile=copy(deck)
    rng=rng or (love and love.math and love.math.random) or math.random
    -- Fisher-Yates, each permutation equally likely with a uniform RNG.
    for i=#pile,2,-1 do
        local j=rng(i)
        pile[i],pile[j]=pile[j],pile[i]
    end
    local encounter={hand={},drawPile=pile,discard={},energy=4,turn=1,maxTurns=3,
                     score=0,finished=false,log={},context=context or {kind="conversation"}}
    for _=1,3 do encounter.hand[#encounter.hand+1]=table.remove(pile) end
    return encounter
end

function Cards.canPlay(enc,index)
    if enc.finished then return false,"El encuentro ya terminó." end
    if type(index)~="number" or index%1~=0 then return false,"Selecciona una carta de la mano." end
    local card=Data.byId[enc.hand[index]]
    if not card then return false,"Selecciona una carta de la mano." end
    if enc.energy<card.cost then return false,"No hay energía suficiente." end
    local conditions=card.conditions or {}
    if conditions.character and enc.context.character~=conditions.character then
        return false,"Esta carta necesita a "..conditions.character.." como acompañante."
    end
    if conditions.kind and enc.context.kind~=conditions.kind then
        return false,"Esta carta no se puede usar en este contexto."
    end
    return true
end

function Cards.preview(enc,index)
    local card=Data.byId[enc.hand[index]]
    if not card then return nil end
    local result={cardId=card.id,score=0,trust=0,chemistry=0}
    local layers={card.effects,card.contexts[enc.context.kind] or {},card.affinities[enc.context.character] or {}}
    for _,layer in ipairs(layers) do
        for _,key in ipairs({"score","trust","chemistry"}) do result[key]=result[key]+(layer[key] or 0) end
    end
    if not enc.context.character or not require("src.data.characters").byId[enc.context.character]
        or not require("src.data.characters").byId[enc.context.character].romance then
        result.trust=0; result.chemistry=0
    end
    result.text=card.name..": +"..result.score.." avance"
    if enc.context.character and (result.trust~=0 or result.chemistry~=0) then
        result.text=result.text..", +"..result.trust.." confianza, +"..result.chemistry.." química"
    end
    return result
end

local function finishAction(enc,result)
    enc.score=enc.score+result.score
    enc.log[#enc.log+1]=result
    enc.turn=enc.turn+1
    enc.finished=enc.turn>enc.maxTurns
    return result
end

function Cards.play(enc,index)
    local ok,err=Cards.canPlay(enc,index)
    if not ok then return nil,err end
    local result=Cards.preview(enc,index)
    local id=table.remove(enc.hand,index)
    enc.energy=enc.energy-Data.byId[id].cost
    enc.discard[#enc.discard+1]=id
    if #enc.drawPile>0 then enc.hand[#enc.hand+1]=table.remove(enc.drawPile) end
    return finishAction(enc,result)
end

local function freeAction()
    return {cardId="pass",score=0,trust=0,chemistry=0,
        text="Tomar un respiro: Rudy escucha y deja que el maná se calme. Sin coste."}
end

function Cards.pass(enc)
    if enc.finished then return nil,"El encuentro ya terminó." end
    return finishAction(enc,freeAction())
end

-- A saved encounter must conserve the exact cards and action history. Invalid
-- snapshots are rejected rather than granting energy or duplicating cards.
function Cards.restore(snapshot,deck,context)
    if type(snapshot)~="table" then return nil end
    if not Cards.validateDeck(deck) then return nil end
    local counts={}
    for _,id in ipairs(deck) do counts[id]=1 end
    local enc={context=context or snapshot.context,hand={},drawPile={},discard={},log={}}
    if type(enc.context)~="table" then return nil end
    local total=0
    for _,zone in ipairs({"hand","drawPile","discard"}) do
        if type(snapshot[zone])~="table" then return nil end
        for _,id in ipairs(snapshot[zone]) do
            if counts[id]~=1 then return nil end
            counts[id]=0; total=total+1; enc[zone][#enc[zone]+1]=id
        end
    end
    if total~=10 or #enc.hand~=3 or #enc.discard>3 then return nil end
    if type(snapshot.log)~="table" or #snapshot.log>3 then return nil end
    local energy,score,played=4,0,0
    for _,entry in ipairs(snapshot.log) do
        if type(entry)~="table" then return nil end
        local result
        if entry.cardId=="pass" then
            result=freeAction()
        else
            played=played+1
            if enc.discard[played]~=entry.cardId then return nil end
            local card=Data.byId[entry.cardId]
            if not card or energy<card.cost then return nil end
            local scratch={hand={entry.cardId},context=enc.context,finished=false,energy=energy}
            if not Cards.canPlay(scratch,1) then return nil end
            result=Cards.preview(scratch,1)
            energy=energy-card.cost
        end
        score=score+result.score
        enc.log[#enc.log+1]=result
    end
    if played~=#enc.discard then return nil end
    enc.energy=energy; enc.score=score; enc.turn=#enc.log+1
    enc.maxTurns=3; enc.finished=enc.turn>3
    return enc
end

return Cards
````

## src/systems/dialogue.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/systems/dialogue.lua`

````lua
-- Avance explícito: una llamada mueve exactamente una línea.
local Dialogue = {}
Dialogue.__index = Dialogue

function Dialogue.new(scene, index)
    assert(type(scene) == "table" and type(scene.lines) == "table" and #scene.lines > 0,
        "La escena necesita al menos una línea")
    local first = tonumber(index) or 1
    first = math.max(1, math.min(#scene.lines, math.floor(first)))
    return setmetatable({scene=scene, index=first, ended=false}, Dialogue)
end

function Dialogue:current()
    return self.scene.lines[self.index]
end

function Dialogue:isLast()
    return self.index == #self.scene.lines
end

function Dialogue:advance()
    if self.ended then return true end
    if self.index < #self.scene.lines then
        self.index = self.index + 1
        return false
    end
    self.ended = true
    return true
end

return Dialogue
````

## src/systems/events.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/systems/events.lua`

````lua
local Relationships = require("src.systems.relationships")
local Events = {}

-- Un evento persistido nunca vuelve a conceder puntos o cartas al cargar.
function Events.apply(session, id, effects)
    assert(type(id) == "string", "El evento necesita identificador")
    session.events = session.events or {}
    if session.events[id] then return false end
    effects = effects or {}
    session.decisions = session.decisions or {}
    session.unlocked = session.unlocked or {}
    if effects.character and session.relationships[effects.character] then
        Relationships.apply(session.relationships, effects.character, {
            trust=effects.trust or 0, chemistry=effects.chemistry or 0,
        })
        if effects.relationshipEvent then
            Relationships.complete(session.relationships, effects.character, effects.relationshipEvent)
        end
        if effects.decision then
            local relationship = session.relationships[effects.character]
            relationship.decisions = relationship.decisions or {}
            relationship.decisions[effects.decision] = effects.value
        end
    end
    if effects.decision then session.decisions[effects.decision] = effects.value end
    for _, cardId in ipairs(effects.unlock or {}) do session.unlocked[cardId] = true end
    session.events[id] = true
    return true
end

return Events
````

## src/systems/json.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/systems/json.lua`

````lua
-- Small strict JSON codec. Never evaluates Lua from a save file.
local Json = {}
Json.null = {}
local escapes={['"']='\\"',['\\']='\\\\',['\b']='\\b',['\f']='\\f',['\n']='\\n',['\r']='\\r',['\t']='\\t'}
local function quote(s)
    return '"'..s:gsub('[%z\1-\31\\"]',function(c)
        return escapes[c] or string.format('\\u%04x',c:byte())
    end)..'"'
end
local function finite(n) return n==n and n~=math.huge and n~=-math.huge end

function Json.encode(value)
    local seen={}
    local function encode(v,depth)
        if depth>32 then error("JSON demasiado profundo") end
        if v==Json.null or v==nil then return "null" end
        local kind=type(v)
        if kind=="boolean" then return v and "true" or "false" end
        if kind=="number" then
            assert(finite(v),"Número JSON inválido")
            return string.format("%.17g",v)
        end
        if kind=="string" then return quote(v) end
        assert(kind=="table","Tipo JSON no compatible")
        assert(not seen[v],"Ciclo en tabla JSON")
        seen[v]=true
        local count,max=0,0
        local array=true
        for k in pairs(v) do
            count=count+1
            if type(k)~="number" or k%1~=0 or k<1 then array=false
            elseif k>max then max=k end
        end
        array=array and count>0 and count==max
        local parts={}
        if array then
            for i=1,max do parts[#parts+1]=encode(v[i],depth+1) end
        else
            local keys={}
            for k in pairs(v) do assert(type(k)=="string","Clave JSON inválida"); keys[#keys+1]=k end
            table.sort(keys)
            for _,k in ipairs(keys) do parts[#parts+1]=quote(k)..":"..encode(v[k],depth+1) end
        end
        seen[v]=nil
        return (array and "[" or "{")..table.concat(parts,",")..(array and "]" or "}")
    end
    local ok,result=pcall(encode,value,0)
    if not ok then return nil,result end
    return result
end

local function utf8(code)
    if code<=0x7f then return string.char(code) end
    if code<=0x7ff then return string.char(0xc0+math.floor(code/64),0x80+code%64) end
    if code<=0xffff then return string.char(0xe0+math.floor(code/4096),0x80+math.floor(code/64)%64,0x80+code%64) end
    return string.char(0xf0+math.floor(code/262144),0x80+math.floor(code/4096)%64,0x80+math.floor(code/64)%64,0x80+code%64)
end

function Json.decode(source)
    if type(source)~="string" then return nil,"Se esperaba texto JSON" end
    local pos,length=1,#source
    local function fail(message) error(message.." (posición "..pos..")",0) end
    local function skip()
        while pos<=length and source:sub(pos,pos):match("[ \t\n\r]") do pos=pos+1 end
    end
    local function readString()
        pos=pos+1
        local parts={}
        while pos<=length do
            local c=source:sub(pos,pos); pos=pos+1
            if c=='"' then return table.concat(parts) end
            if c=='\\' then
                local e=source:sub(pos,pos); pos=pos+1
                local map={['"']='"',['\\']='\\',['/']='/',b='\b',f='\f',n='\n',r='\r',t='\t'}
                if map[e] then parts[#parts+1]=map[e]
                elseif e=='u' then
                    local hex=source:sub(pos,pos+3)
                    if #hex~=4 or not hex:match('^%x%x%x%x$') then fail("Escape Unicode inválido") end
                    local code=tonumber(hex,16); pos=pos+4
                    if code>=0xd800 and code<=0xdbff then
                        if source:sub(pos,pos+1)~='\\u' then fail("Par Unicode incompleto") end
                        local low=tonumber(source:sub(pos+2,pos+5),16)
                        if not low or low<0xdc00 or low>0xdfff then fail("Par Unicode inválido") end
                        code=0x10000+(code-0xd800)*1024+(low-0xdc00); pos=pos+6
                    elseif code>=0xdc00 and code<=0xdfff then fail("Unicode inválido") end
                    parts[#parts+1]=utf8(code)
                else fail("Escape JSON inválido") end
            else
                if c:byte()<32 then fail("Control dentro de cadena JSON") end
                parts[#parts+1]=c
            end
        end
        fail("Cadena JSON sin cerrar")
    end
    local parse
    parse=function(depth)
        if depth>32 then fail("JSON demasiado profundo") end
        skip()
        local c=source:sub(pos,pos)
        if c=='"' then return readString() end
        if c=='{' or c=='[' then
            local object=c=='{'; local close=object and '}' or ']'
            pos=pos+1; skip()
            local out={}; local count=0
            if source:sub(pos,pos)==close then pos=pos+1; return out end
            while true do
                count=count+1
                if count>4096 then fail("Demasiados elementos JSON") end
                local key=count
                if object then
                    if source:sub(pos,pos)~='"' then fail("Clave JSON inválida") end
                    key=readString(); skip()
                    if out[key]~=nil then fail("Clave JSON repetida") end
                    if source:sub(pos,pos)~=':' then fail("Falta separador JSON") end
                    pos=pos+1
                end
                out[key]=parse(depth+1); skip()
                c=source:sub(pos,pos); pos=pos+1
                if c==close then return out end
                if c~=',' then fail("Falta coma JSON") end
                skip()
            end
        end
        for _,literal in ipairs({"true","false","null"}) do
            if source:sub(pos,pos+#literal-1)==literal then
                pos=pos+#literal
                if literal=="null" then return Json.null end
                return literal=="true"
            end
        end
        local rest=source:sub(pos)
        local token=rest:match('^-?%d+%.?%d*[eE][+-]?%d+') or rest:match('^-?%d+%.%d+') or rest:match('^-?%d+')
        if not token then fail("Valor JSON inválido") end
        if token:match('^-?0%d') or token:match('%.e') or token:match('%.E') then fail("Número JSON inválido") end
        local n=tonumber(token)
        if not n or not finite(n) then fail("Número JSON fuera de rango") end
        pos=pos+#token
        return n
    end
    local ok,result=pcall(parse,0)
    if not ok then return nil,result end
    skip()
    if pos<=length then return nil,"Contenido extra después del JSON" end
    return result
end
return Json
````

## src/systems/progression.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/systems/progression.lua`

````lua
local Story = require("src.data.story")
local Events = require("src.systems.events")
local Progression = {}
local characters = {"sylphiette", "roxy", "eris"}

local function containsCharacter(id)
    return Story.companionNames[id] ~= nil
end

local function savedChoice(session, sceneId)
    local scene = Story.scenes[sceneId]
    if not scene or not scene.choices then return nil end
    local selected = session.decisions["choice_" .. sceneId]
    for _, choice in ipairs(scene.choices) do
        if choice.id == selected then return choice end
    end
end

local function move(session, checkpoint)
    session.checkpoint = checkpoint
    session.dialogueIndex = 1
    session.encounter = nil
    return checkpoint
end

local function allMeetings(session)
    for _, id in ipairs(characters) do
        if not session.events["meeting_" .. id] then return false end
    end
    return true
end

function Progression.availableCompanions(session)
    local available = {}
    if allMeetings(session) then
        for _, id in ipairs(characters) do available[#available+1] = id end
    end
    return available
end

function Progression.visit(session, character)
    if session.checkpoint ~= "hub" or session.day ~= 2 then return nil, "No estás en el mapa del día 2." end
    if not containsCharacter(character) then return nil, "Acompañante desconocido." end
    if session.events["meeting_" .. character] then return nil, "Este encuentro ya está completado." end
    return move(session, "meet_" .. character)
end

function Progression.selectCompanion(session, character)
    if session.checkpoint ~= "hub" or not allMeetings(session) then
        return nil, "Visita a los tres personajes antes de salir hacia las ruinas."
    end
    if not containsCharacter(character) then return nil, "Acompañante desconocido." end
    Events.apply(session, "companion_selected", {decision="companion", value=character})
    -- Un guardado parcial puede conservar el evento y perder su decisión.
    -- Elegir desde el mapa siempre restablece el acompañante explícitamente.
    session.decisions.companion = character
    return move(session, "seal_intro")
end

function Progression.choose(session, sceneId, choiceId)
    if session.checkpoint ~= sceneId then return false, "Esta escena ya no está activa." end
    local scene = Story.scenes[sceneId]
    if not scene or not scene.choices then return false, "La escena no contiene decisiones." end
    local key = "choice_" .. sceneId
    local previous = savedChoice(session, sceneId)
    if previous then
        if previous.id == choiceId then return true end
        return false, "Esta decisión ya quedó guardada."
    end
    for _, choice in ipairs(scene.choices) do
        if choice.id == choiceId then
            Events.apply(session, key, choice.effects)
            session.decisions[key] = choiceId
            return true
        end
    end
    return false, "Decisión desconocida."
end

local function resolveText(text, session)
    local id = session.decisions.companion or "sylphiette"
    local replacements = {
        companion=Story.companionNames[id] or "tu acompañante",
        companionAdvice=Story.companionAdvice[id] or "Lo resolveremos juntos.",
        companionMemory=Story.companionMemory[id] or "Compartimos un recuerdo verdadero.",
    }
    return (text:gsub("{(%w+)}", function(key) return replacements[key] or "{" .. key .. "}" end))
end

-- Copia resuelta: nunca se modifica el contenido estático compartido.
function Progression.scene(session, id)
    local original = Story.scenes[id]
    if not original then return nil end
    local scene = {title=original.title, background=original.background, lines={}}
    if not savedChoice(session, id) then scene.choices = original.choices end
    local function append(line)
        scene.lines[#scene.lines+1] = {
            speaker=line.speaker == "companion" and (session.decisions.companion or "sylphiette") or line.speaker,
            expression=line.expression or "neutral", text=resolveText(line.text, session),
        }
    end
    if original.resultLines then
        local outcome = session.decisions["outcome_" .. original.resultKey] or "partial"
        append(original.resultLines[outcome] or original.resultLines.partial)
    end
    for _, line in ipairs(original.lines) do append(line) end
    return scene
end

function Progression.encounter(session, id)
    local original = Story.encounters[id]
    if not original then return nil end
    local encounter = {}
    for key, value in pairs(original) do encounter[key] = value end
    if encounter.character == "companion" then encounter.character = session.decisions.companion end
    return encounter
end

local function recordEncounter(session, checkpoint, result)
    local definition = Progression.encounter(session, checkpoint)
    local score = type(result) == "table" and tonumber(result.score) or 0
    score = score or 0
    local success = score >= definition.targetScore
    local key = "resolved_" .. checkpoint
    if not session.events[key] then
        local trust = type(result) == "table" and tonumber(result.trust) or 0
        local chemistry = type(result) == "table" and tonumber(result.chemistry) or 0
        Events.apply(session, key, {
            decision="outcome_" .. checkpoint, value=success and "success" or "partial",
            character=definition.character, trust=trust or 0, chemistry=chemistry or 0,
        })
        session.lastResult = {
            score=score, success=success, character=definition.character, title=definition.title,
            trust=trust or 0, chemistry=chemistry or 0,
        }
    end
end

function Progression.next(session, checkpoint, result)
    checkpoint = checkpoint or session.checkpoint
    if session.checkpoint ~= checkpoint then return nil, "La pantalla de origen ya cambió." end
    local scene = Story.scenes[checkpoint]
    if scene and scene.choices and not savedChoice(session, checkpoint) then
        return nil, "Elige una respuesta antes de continuar."
    end
    if Story.encounters[checkpoint] then recordEncounter(session, checkpoint, result) end
    if checkpoint == "intro" then return move(session, "day1_tutorial") end
    if checkpoint == "day1_tutorial" then return move(session, "day1_result") end
    if checkpoint == "day1_result" then
        Events.apply(session, "first_anomaly", {unlock={"self_joke"}})
        return move(session, "day1_close")
    end
    if checkpoint == "day1_close" then
        Events.apply(session, "day1_complete")
        session.day = 2
        return move(session, "hub")
    end
    for _, character in ipairs(characters) do
        if checkpoint == "meet_" .. character then return move(session, "encounter_" .. character) end
        if checkpoint == "encounter_" .. character then return move(session, "result_" .. character) end
        if checkpoint == "result_" .. character then
            Events.apply(session, "meeting_" .. character, {character=character, relationshipEvent="reunion"})
            if allMeetings(session) then Events.apply(session, "all_reunions", {unlock={"remember"}}) end
            return move(session, "hub")
        end
    end
    if checkpoint == "seal_intro" then return move(session, "seal_encounter") end
    if checkpoint == "seal_encounter" then return move(session, "seal_result") end
    if checkpoint == "seal_result" then
        Events.apply(session, "seal_memory", {
            character=session.decisions.companion, relationshipEvent="memory_seal", trust=1,
        })
        return move(session, "day2_close")
    end
    if checkpoint == "day2_close" then
        Events.apply(session, "day2_complete")
        Events.apply(session, "phase1_complete")
        return move(session, "phase_complete")
    end
    if checkpoint == "phase_complete" or checkpoint == "hub" then return checkpoint end
    return nil, "Punto de historia desconocido: " .. tostring(checkpoint)
end

return Progression
````

## src/systems/relationships.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/systems/relationships.lua`

````lua
local Characters = require("src.data.characters")
local Relationships = {}
local function clamp(n) return math.max(0,math.min(10,n)) end

function Relationships.new()
    local all = {}
    for _, id in ipairs(Characters.romanceIds) do
        all[id]={trust=0,chemistry=0,events={},routeState="unmet",decisions={}}
    end
    return all
end

function Relationships.apply(all,id,delta)
    local relationship = all[id]
    if not relationship then return end
    relationship.trust=clamp(relationship.trust+(delta.trust or 0))
    relationship.chemistry=clamp(relationship.chemistry+(delta.chemistry or 0))
end

function Relationships.complete(all,id,event)
    if not all[id] then return end
    all[id].events[event]=true
    if all[id].routeState=="unmet" then all[id].routeState="friend" end
end

function Relationships.canRomance(all,id,decisions)
    local r=all[id]
    if not r then return false end
    return r.trust>=6 and r.chemistry>=5 and r.events.route_conflict==true
        and r.events.mirror_truth==true and decisions.confession==id
end

function Relationships.ending(all,route,decisions)
    if not route or not all[route] then return "independent" end
    if Relationships.canRomance(all,route,decisions or {}) then return "romance_"..route end
    return "friendship_"..route
end

return Relationships
````

## src/systems/resources.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/systems/resources.lua`

````lua
-- Recursos sustituibles. Los PNG válidos tienen prioridad; los dibujos de
-- desarrollo se construyen en lienzos de baja resolución y usan nearest.
local Resources = {}
Resources.__index = Resources
local P = require("src.ui.palette")
local Characters = require("src.data.characters")
local Assets = require("src.data.assets")
local SPRITE_WIDTH = Characters.spriteWidth
local SPRITE_HEIGHT = Characters.spriteHeight
local EXPRESSIONS = Characters.expressions
local SHEET_WIDTH = SPRITE_WIDTH * Characters.expressionCount
local BACKGROUND_WIDTH,BACKGROUND_HEIGHT=unpack(Assets.sizes.background)
local CARD_WIDTH,CARD_HEIGHT=unpack(Assets.sizes.card)
local ICON_WIDTH,ICON_HEIGHT=unpack(Assets.sizes.icon)
local function color(hex)
    if type(hex) == "table" then love.graphics.setColor(hex); return end
    love.graphics.setColor(tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255,1)
end
local function r(c,x,y,w,h) color(c); love.graphics.rectangle("fill",math.floor(x),math.floor(y),math.floor(w),math.floor(h)) end
local function poly(c,points)
    local snapped={};for i,value in ipairs(points) do snapped[i]=math.floor(value) end
    color(c);love.graphics.polygon("fill",snapped)
end
local function pixelLine(c,x1,y1,x2,y2,width)
    local dx,dy=x2-x1,y2-y1; local steps=math.max(math.abs(dx),math.abs(dy))
    for n=0,steps do local t=steps==0 and 0 or n/steps; r(c,math.floor(x1+dx*t),math.floor(y1+dy*t),width or 1,width or 1) end
end
local function canvas(w,h,draw)
    local c=love.graphics.newCanvas(w,h); c:setFilter("nearest","nearest")
    love.graphics.push("all"); love.graphics.setCanvas(c); love.graphics.origin(); love.graphics.clear(0,0,0,0)
    draw(); love.graphics.setCanvas(); love.graphics.pop()
    return c
end
local function image(path,w,h)
    if not path then return nil,"identificador sin entrada en src/data/assets.lua" end
    if not love.filesystem.getInfo(path,"file") then return nil,"archivo inexistente" end
    local ok,img=pcall(love.graphics.newImage,path)
    if not ok then return nil,"PNG inválido: "..tostring(img) end
    if img:getWidth()~=w or img:getHeight()~=h then
        local reason=string.format("dimensiones %dx%d; se esperaban %dx%d",img:getWidth(),img:getHeight(),w,h)
        img:release()
        return nil,reason
    end
    img:setFilter("nearest","nearest")
    return img
end
local function stars()
    for i=1,24 do local x=(i*53+19)%320; local y=(i*17)%73; r("CAC1CB",x,y,1,1) end
end
local function sky()
    r("66778F",0,0,320,180); r("7D8D9E",0,26,320,35); r("A4A4AC",0,61,320,37); r("D5BCAD",0,98,320,82)
    r("EAD5BA",251,19,17,13); r("EAD5BA",253,17,13,17); r("EAD5BA",255,15,9,21)
    r("ADB0BA",15,32,41,4); r("ADB0BA",22,29,21,4); r("BDC0C5",205,48,46,3)
    stars()
end
local function tree(x,y,s)
    s=s or 1
    r("3C4D48",x+12*s,y+21*s,5*s,39*s)
    r("4B6157",x+10*s,y+33*s,2*s,12*s)
    r("3C5A56",x,y+13*s,30*s,18*s);r("3C5A56",x+5*s,y+3*s,21*s,34*s)
    r("4F7768",x+2*s,y+8*s,24*s,18*s);r("4F7768",x+7*s,y,17*s,30*s)
    r("71957B",x+7*s,y+5*s,10*s,5*s);r("71957B",x+3*s,y+14*s,7*s,4*s)
    r("658771",x+15*s,y+12*s,9*s,6*s); r("80A085",x+10*s,y+2*s,6*s,2*s)
end
local function window(x,y,w,h,lit)
    r("354454",x,y,w,h);r("354454",x+2,y-3,w-4,3)
    r(lit and "DDBB81" or "8EA9B3",x+2,y+1,w-4,h-3)
    r("596477",x+math.floor(w/2),y,1,h);r("596477",x+1,y+math.floor(h/2),w-2,1)
    r("D9C7AC",x-1,y+h,w+2,2)
end
local function brickWall(x,y,w,h,base)
    r(base or "9A9693",x,y,w,h)
    for yy=y+8,y+h-1,9 do
        r("777B81",x,yy,w,1)
        for xx=x+(math.floor(yy/9)%2)*9,x+w-1,19 do r("777B81",xx,yy-8,1,8) end
    end
end
local function path()
    r("536B66",0,132,320,48)
    poly("B5AA99",{142,129,181,129,232,180,85,180})
    for i=1,28 do local x=(i*37)%320;local y=136+(i*13)%44;r("748573",x,y,3,1) end
    for i=0,4 do local yy=138+i*9; r("8B9089",139-i*10,yy,49+i*21,1) end
end
local function courtyard()
    sky(); r("566D76",0,84,320,48)
    brickWall(50,69,220,68,"A7A09B")
    poly("414B67",{39,72,59,46,265,46,283,72});r("66708A",53,54,215,3);r("8991A2",60,48,202,2)
    brickWall(136,39,50,97,"B5AAA1")
    poly("3C4965",{128,42,161,10,195,42});poly("667A8B",{140,37,161,15,180,37})
    r("E1C496",159,4,3,12);r("D9B982",160,5,16,5)
    for _,x in ipairs({65,91,215,241}) do window(x,80,13,22,true);window(x,111,13,17,false) end
    window(151,48,19,24,true)
    r("CBBDA7",143,86,36,48); r("494B5D",147,90,28,44); r("494B5D",151,86,20,5)
    r("6B6670",151,94,20,40);r("C6A77C",160,91,2,43);r("E4C69C",154,114,2,2)
    r("D0BDA5",132,133,58,4);r("AAA79F",127,137,68,4)
    path();r("CDC1AB",127,136,68,3)
    tree(6,70,1.3);tree(276,70,1.3)
    for _,x in ipairs({43,211}) do
        r("384F4B",x,145,69,8);r("81937B",x+2,143,65,4)
        for i=1,10 do local xx=x+i*6;r(i%2==0 and "D5A5B4" or "E4C797",xx,141-(i%3),2,3) end
    end
    pixelLine("5E6575",22,54,112,69);pixelLine("5E6575",208,69,303,54)
    for i=0,7 do local xx=26+i*12;local yy=55+i*2;poly(i%2==0 and "BA8A96" or "C4B394",{xx,yy,xx+7,yy+1,xx+4,yy+10}) end
    for i=0,7 do local xx=212+i*12;local yy=68-i*2;poly(i%2==0 and "8BAEA1" or "BCACCA",{xx,yy,xx+7,yy-1,xx+4,yy+8}) end
end
local function floorTiles()
    r("6C6A73",0,129,320,51)
    for yy=133,180,12 do r("515765",0,yy,320,1) end
    for i=0,8 do pixelLine("515765",i*40,130,(i-4)*55+160,180) end
end
local function bookcase(x,y,w,h)
    r("322F42",x,y,w,h);r("746271",x,y,4,h);r("746271",x+w-4,y,4,h)
    for row=0,3 do
        local yy=y+6+row*25
        for i=0,math.floor((w-10)/6)-1 do
            local colors={"A3808A","78958F","9D9CAD","B49E7D","6E7E98"}
            local bh=13+(i*7+row*3)%8
            r(colors[(i+row)%5+1],x+6+i*6,yy+20-bh,4,bh)
            r("CAB59C",x+6+i*6,yy+23-bh,4,1)
        end
        r("9A7F7A",x+4,yy+20,w-8,3);r("463F50",x+4,yy+23,w-8,2)
    end
end
local function candle(x,y)
    r("D3BD8B",x,y+4,3,10);r("F4D99A",x+1,y+1,1,4);r("D19776",x,y+2,3,3);r("F3DDA1",x+1,y+2,1,2)
    r("91785F",x-2,y+14,7,2)
end
local function library()
    r("53566E",0,0,320,180);r("6B697E",16,0,288,130)
    r("A39591",0,0,320,9);r("8C8285",0,9,320,3)
    for _,x in ipairs({10,105,209,305}) do r("807D89",x,12,6,120);r("B1A79D",x-2,12,10,4) end
    bookcase(20,20,73,106); bookcase(226,20,73,106)
    r("343E56",121,19,77,96);r("343E56",130,11,59,10)
    r("7D94AC",126,23,67,87);r("C3C2BD",157,18,4,94);r("C3C2BD",125,64,69,4)
    r("859EB3",128,28,27,30);r("B6BFC4",165,72,25,32)
    r("D9D0B8",117,112,86,5);r("B1A29C",114,117,92,4)
    floorTiles();r("796473",81,144,166,36);r("B69C98",85,146,158,2);r("B69C98",85,176,158,2)
    r("4B4255",102,136,7,34);r("4B4255",213,136,7,34)
    r("574858",94,130,134,12);r("B39986",94,127,134,5);r("CFB79A",96,127,130,2)
    r("DBD0AD",136,121,31,5);r("EADABD",139,118,27,4);r("9C9183",151,119,1,7)
    r("637C82",184,122,15,4);r("C0AD97",184,123,15,1);candle(115,112);candle(208,111)
    pixelLine("B1A181",160,0,160,28,2);r("B8A381",145,27,32,3);candle(147,13);candle(172,13)
    r("A8A6AD",33,163,11,2);r("A8A6AD",268,161,18,2)
end
local function mirror(x,y)
    r("A79094",x+6,y,49,5);r("A79094",x,y+6,61,74);r("A79094",x+6,y+80,49,5)
    r("D4BB96",x+8,y+4,45,3);r("D4BB96",x+4,y+8,3,68);r("D4BB96",x+54,y+8,3,68);r("D4BB96",x+8,y+78,45,3)
    r("365567",x+8,y+8,45,68);r("4A7280",x+12,y+12,37,60)
    r("77959A",x+16,y+16,29,52);r("9BB3AA",x+20,y+21,21,43)
    pixelLine("D5D8BD",x+37,y+12,x+23,y+31,2);pixelLine("D5D8BD",x+23,y+31,x+32,y+45,2);pixelLine("D5D8BD",x+32,y+45,x+19,y+69,2)
    r("405C6B",x+7,y+85,47,4);r("968A8D",x+10,y+89,6,14);r("968A8D",x+45,y+89,6,14)
end
local function laboratory()
    r("343F57",0,0,320,180);brickWall(0,12,320,118,"626C7E")
    r("303D56",0,0,320,12);r("B1A596",0,10,320,2)
    r("35455E",117,20,86,112);r("465774",123,24,74,108)
    mirror(130,34);floorTiles()
    r("536777",102,142,117,21);r("7D9F9F",110,141,101,2);r("7D9F9F",110,161,101,2)
    pixelLine("91B7AE",111,144,209,158);pixelLine("91B7AE",111,158,209,144)
    for _,x in ipairs({18,239}) do
        r("463E54",x,113,65,8);r("A18C86",x,110,65,4);r("463E54",x+4,120,5,27);r("463E54",x+56,120,5,27)
        for i=0,2 do
            local xx=x+10+i*19;r("A9B9BB",xx,89+i%2*4,9,20-i%2*4);r("79A99F",xx+1,100,7,8);r("CFBDA6",xx+3,85+i%2*4,3,5)
        end
    end
    bookcase(21,26,64,77);r("646C7D",21,101,64,9)
    r("B8B298",235,29,60,58);r("D9CDB4",238,32,54,52)
    for i=0,4 do pixelLine("8C958C",244,39+i*8,284-(i%3)*6,39+i*8) end
    r("BE9497",257,49,12,13);r("DCC7AF",260,52,6,7)
    for i=1,14 do r("A8CBB7",110+(i*17)%100,25+(i*23)%100,1,1) end
end
local function garden()
    sky();r("647F76",0,98,320,82)
    brickWall(0,80,320,43,"A0AAA0");r("CED0BB",0,78,320,4)
    for _,x in ipairs({68,134,200}) do
        r("617F7D",x,87,38,35);r("617F7D",x+4,83,30,4)
        r("A9B3A1",x-4,85,4,43);r("A9B3A1",x+38,85,4,43)
    end
    tree(-5,25,2);tree(264,29,2)
    poly("BAB6A1",{132,122,187,122,239,180,79,180})
    r("526C6E",128,145,65,13);r("A9B5AD",125,142,71,10);r("CEE0C9",130,141,61,3)
    r("8EAAAC",133,144,56,4);r("B6C7BC",154,122,13,23);r("D3D7BF",149,119,23,5)
    r("8EB8B8",157,109,6,11);r("D0E1CD",159,106,2,19);r("93BBB9",146,125,3,11);r("93BBB9",173,125,3,11)
    for i=0,23 do local x=(i*29)%320;local y=132+(i*17)%44
        if x<95 or x>235 then r("4E725B",x,y,1,5);r(i%3==0 and "D6B58D" or "D49BA8",x-1,y-1,3,2) end
    end
    r("4F6266",29,141,54,5);r("A6AAA0",29,132,54,7);r("4F6266",32,146,4,12);r("4F6266",76,146,4,12)
    r("A6AAA0",30,141,53,2)
end
local function training()
    sky();r("668177",0,93,320,48);r("BAAE95",0,132,320,48)
    brickWall(0,100,320,29,"969F98");r("CCD0BA",0,98,320,3)
    tree(20,43,1);tree(279,45,1)
    for _,x in ipairs({82,222}) do
        r("5C6668",x+11,112,4,43);r("5C6668",x+1,153,25,3)
        r("6F6969",x,94,28,29);r("C8B697",x+3,97,22,23)
        r("B0837A",x+7,101,14,15);r("E2CBA0",x+10,104,8,9);r("AA796E",x+12,106,4,5)
    end
    r("57636A",21,145,46,4);r("57636A",24,128,3,36);r("57636A",61,128,3,36)
    for i=0,3 do local x=28+i*9;pixelLine("BEC4B7",x,153,x+4,122,2);r("9C8677",x-2,145,7,3) end
    for i=0,30 do r("968F83",(i*37)%320,137+(i*11)%43,3,1) end
    pixelLine("D5C7A7",125,149,194,149);pixelLine("D5C7A7",120,153,199,153);pixelLine("D5C7A7",120,166,199,166)
    r("A48E87",138,160,42,1)
end
local function ruins()
    r("526B76",0,0,320,180);r("718D8C",0,57,320,123)
    for i=0,8 do tree(i*42-10,25+(i%3)*10,1.5) end
    r("526E62",0,122,320,58);poly("89968B",{132,112,190,112,224,180,93,180})
    for _,x in ipairs({86,203}) do
        brickWall(x,35,31,110,"8D9B94");r("BBC4AF",x-5,29,41,7);r("586F6B",x-3,142,38,5)
        r("B9C1AE",x+5,38,3,96);r("5A7D64",x+22,43,8,23);r("5A7D64",x+17,65,7,18)
    end
    brickWall(108,30,97,19,"9EA99D");r("BCC5B0",111,25,89,5)
    r("4B6868",120,52,79,75);r("647D78",126,57,67,66)
    for i=1,7 do r("8BA395",128+i*8,64+(i%2)*5,2,8) end
    r("617A74",137,125,45,19);r("B2BDA8",133,121,53,5)
    r("B7A77D",151,107,17,14);r("E0D4A8",154,104,11,18);r("84A997",157,108,5,9)
    for i=1,15 do local x=(i*47)%320;local y=143+(i*13)%36;r("657A6C",x,y,10,5);r("8D9D83",x+2,y,7,1) end
    r("405E57",20,170,61,10);r("405E57",245,167,75,13)
end
local backgrounds={courtyard=courtyard,library=library,laboratory=laboratory,garden=garden,training=training,ruins=ruins}

local profiles={
    rudeus={hair="9C7954",light="C3A174",shade="674E3E",coat="697B6E",trim="CAB48F",eyes="578B78",style="short"},
    sylphiette={hair="DFDDD0",light="F8EDDA",shade="A9B6B0",coat="6E9E90",trim="DCD2B4",eyes="B55F72",style="elf"},
    roxy={hair="7288BB",light="9CAED3",shade="48577F",coat="606D97",trim="C7B7C6",eyes="6389AE",style="witch"},
    eris={hair="B6535A",light="DA7A70",shade="773C4F",coat="E0D1BB",trim="A45259",eyes="A54D52",style="long"},
    nanahoshi={hair="373544",light="60536A",shade="262B3D",coat="83788D",trim="DBCCC3",eyes="776B8B",style="long"},
    zanoba={hair="A68F66",light="D4BB89",shade="736950",coat="63807B",trim="DDC08E",eyes="667A6D",style="noble"},
    cliff={hair="735845",light="A27B57",shade="4E3F3F",coat="4C566D",trim="B8A4AE",eyes="777D70",style="glasses"},
}
local function portrait(id,expression)
    -- Adapta el boceto provisional a 64x64 con proporciones uniformes.
    -- Cada trazo se rasteriza a píxeles enteros, sin estirar ni recortar la cara.
    local drawRect,drawPolygon,drawLine=r,poly,pixelLine
    local function r(c,x,y,w,h)
        local left,top=math.floor(x/2),math.floor(y/2)
        drawRect(c,left+8,top,math.max(1,math.floor((x+w)/2)-left),math.max(1,math.floor((y+h)/2)-top))
    end
    local function poly(c,points)
        local scaled={}
        for i,value in ipairs(points) do scaled[i]=math.floor(value/2)+(i%2==1 and 8 or 0) end
        drawPolygon(c,scaled)
    end
    local function pixelLine(c,x1,y1,x2,y2,width)
        drawLine(c,math.floor(x1/2)+8,math.floor(y1/2),math.floor(x2/2)+8,math.floor(y2/2),math.max(1,math.floor((width or 1)/2)))
    end
    local c=profiles[id] or profiles.rudeus; local outline="292D40";local skin="E5BEA3";local skinLight="F2D0B0";local skinShade="C18F83"
    local long=c.style=="long" or c.style=="witch"
    -- Silueta común: cara y hombros se mantienen en la misma posición en los cuatro cuadros.
    r(outline,29,18,38,7);r(outline,24,25,48,long and 77 or 43)
    r(c.shade,27,27,42,long and 74 or 41);r(c.hair,28,24,40,41)
    if long then
        r(c.hair,23,43,11,56);r(c.hair,64,42,10,58);r(c.light,25,46,3,40);r(c.shade,68,59,4,42)
    end
    r(outline,19,87,58,41);r(outline,11,97,74,31);r(c.coat,17,95,62,33);r(c.coat,23,86,50,42)
    r(c.shade,14,103,5,25);r(c.trim,20,93,5,35);r(c.trim,71,93,5,35)
    r(skinShade,38,69,20,23);r(skin,40,68,16,18)
    r(skinShade,30,40,36,28);r(skin,32,35,32,34);r(skin,35,67,26,6);r(skinShade,39,73,18,3)
    r(skinLight,35,38,24,24);r(skinLight,38,63,18,7)
    r(skinShade,28,48,4,12);r(skinShade,64,48,4,12);r(skin,28,49,3,7);r(skin,65,49,3,7)
    if c.style=="elf" then
        poly(outline,{18,45,31,49,31,61,25,56});poly(skin,{20,47,31,51,30,58,25,54})
        poly(outline,{78,45,65,49,65,61,71,56});poly(skin,{76,47,65,51,66,58,71,54})
    end
    r(c.hair,29,28,38,12);r(c.hair,28,33,8,17);r(c.hair,59,34,8,13)
    r(c.hair,35,36,9,6);r(c.hair,45,35,9,9);r(c.hair,54,34,6,7)
    r(c.light,32,27,27,3);r(c.light,30,31,5,11);r(c.light,37,32,8,3);r(c.light,51,31,9,3)
    -- Rasgos pequeños con ojos a la misma altura para evitar saltos entre expresiones.
    if expression=="happy" then
        r(outline,35,51,8,2);r(outline,36,49,6,2);r(outline,53,51,8,2);r(outline,54,49,6,2)
        r("DFA39A",34,57,7,2);r("DFA39A",55,57,7,2);r("AE7272",44,64,9,2);r("AE7272",46,66,5,1)
    else
        r(outline,34,48,10,2);r(outline,52,48,10,2);r("FFF0DA",35,50,8,5);r("FFF0DA",53,50,8,5)
        r(c.eyes,38,50,4,5);r(c.eyes,54,50,4,5);r(outline,39,51,2,4);r(outline,55,51,2,4)
        r("FFF4DF",38,50,1,2);r("FFF4DF",54,50,1,2)
        if expression=="worried" then pixelLine(c.shade,34,46,43,44);pixelLine(c.shade,53,44,62,46);r("AE7272",44,66,9,1);r("AE7272",46,65,5,1)
        elseif expression=="angry" then pixelLine(c.shade,34,44,43,47,2);pixelLine(c.shade,53,47,62,44,2);r("9F6D6D",44,65,9,2)
        else r(c.shade,35,45,8,1);r(c.shade,53,45,8,1);r("AE7272",44,65,9,1) end
    end
    r(skinShade,47,55,2,6);r("CD9C8B",48,61,3,1)
    poly(c.trim,{28,86,39,80,47,92,34,102});poly(c.trim,{68,86,57,80,49,92,62,102})
    r(outline,46,91,4,37);r(c.trim,47,93,2,35)
    for y=102,124,10 do r("DFC39A",49,y,2,2) end
    if c.style=="witch" then
        poly(outline,{22,25,32,6,57,2,70,25});poly(c.coat,{26,24,35,9,55,5,65,24})
        r(outline,13,24,70,8);r(c.coat,16,25,64,5);r(c.trim,27,21,40,3);r("DBBA84",52,21,5,4)
        r(c.light,29,63,5,35);r(c.light,63,63,5,35);r(c.trim,27,82,9,4);r(c.trim,61,82,9,4)
    elseif c.style=="glasses" then
        r("C1B7AB",33,48,12,1);r("C1B7AB",33,55,12,1);r("C1B7AB",33,48,1,8);r("C1B7AB",44,48,1,8)
        r("C1B7AB",51,48,12,1);r("C1B7AB",51,55,12,1);r("C1B7AB",51,48,1,8);r("C1B7AB",62,48,1,8);r("C1B7AB",45,50,6,1)
        r(c.trim,43,113,10,2);r(c.trim,47,109,2,11)
    elseif c.style=="noble" then
        r(c.trim,23,97,13,4);r(c.trim,60,97,13,4);r("D7C491",31,105,5,5);r("D7C491",60,105,5,5)
    elseif id=="sylphiette" then
        poly("86B4A4",{29,84,49,91,65,84,61,97,36,100});r("D9CFB4",48,94,7,5);r("76A494",54,98,9,25)
    elseif id=="eris" then
        r(c.trim,25,117,46,8);r("D4AE7E",44,118,9,6);r(outline,47,119,3,4)
    elseif id=="nanahoshi" then
        r("D3C7C3",23,99,12,20);r("8C8191",25,105,8,2);r("8C8191",27,112,5,1)
    end
end

local function icon(id)
    local empathy={listen=true,encourage=true,remember=true,empathy=true}
    local humor={light_joke=true,change_subject=true,self_joke=true,humor=true}
    local honesty={be_honest=true,admit_error=true,share_fear=true,sincerity=true}
    if empathy[id] then
        poly("DAA3A0",{4,6,9,6,12,9,15,6,20,6,20,13,12,21,4,13})
        r("F1C4B3",6,7,4,2);r("F1C4B3",5,9,2,3)
        if id=="remember" then r("E6D09E",16,2,2,6);r("E6D09E",14,4,6,2) end
    elseif humor[id] then
        r("E4C67D",5,4,14,16);r("E4C67D",3,7,18,10);r("F2DB9D",6,5,10,2)
        r("6F5A5C",7,9,2,2);r("6F5A5C",15,9,2,2);r("986F63",7,14,10,2);r("986F63",9,16,6,2)
    elseif honesty[id] then
        poly("B6ABD5",{12,2,21,11,12,22,3,11});poly("E0CBE1",{12,5,18,11,12,18,6,11})
        r("9C8EB6",11,8,2,6);r("9C8EB6",11,16,2,2)
    elseif id=="earth_barrier" then
        poly("AFBE9D",{4,4,12,2,20,4,20,13,16,19,12,22,8,19,4,13});poly("6E998D",{7,6,12,5,17,6,17,12,14,17,12,19,10,17,7,12})
        r("BED1B6",11,7,2,10);r("BED1B6",8,10,8,2)
    elseif id=="sword_magic" then
        pixelLine("CED3CD",5,19,18,4,3);pixelLine("A3B8C2",7,19,20,4);pixelLine("D4B67F",4,13,11,20,2);r("B67274",2,20,4,3)
        r("BCADD8",18,14,2,6);r("BCADD8",16,16,6,2)
    elseif id=="choose_together" then
        r("D6B295",3,9,8,6);r("A2C2B0",13,9,8,6);r("E4D1B0",9,11,6,6);r("F0DAA8",11,2,2,5);r("F0DAA8",9,4,6,1)
    elseif id=="analyze_runes" then
        r("B5C6B5",4,3,16,18);r("708E92",6,5,12,14);pixelLine("CFE0C0",9,7,15,13);pixelLine("CFE0C0",15,7,9,13);r("CFE0C0",11,10,2,7)
    elseif id=="propose_plan" then
        r("DCCCAB",4,4,16,17);r("AE9D89",7,7,8,1);r("AE9D89",7,10,5,1);r("AE9D89",7,13,9,1);r("92B6A2",15,17,6,2);r("92B6A2",18,14,2,6)
    else
        poly("83C6BA",{12,1,15,9,23,12,15,15,12,23,9,15,1,12,9,9});poly("D5E2BF",{12,6,14,10,18,12,14,14,12,18,10,14,6,12,10,10})
        if id=="combined_spell" or id=="shared_magic" then r("C0ADD5",2,2,4,4);r("C0ADD5",18,18,4,4) end
    end
end
function Resources.new()
    return setmetatable({backgrounds={},portraits={},icons={},frames={},categoryIcons={},quads={},
        images={},sources={},warnings={}},Resources)
end
-- Una única carga por ruta: garden/courtyard y training/forest comparten imagen.
-- sources permite inspeccionar cada sustitución; nunca se oculta un fallo de PNG.
function Resources:_load(path,w,h,fallback,id)
    local key=path or ("unmapped:"..id)
    if not self.images[key] then
        local img,reason=image(path,w,h)
        if img then
            self.sources[key]={status="png",path=path,width=w,height=h}
        else
            local message="[Recursos] "..key..": "..reason.."; usando recurso provisional."
            self.warnings[#self.warnings+1]=message
            print(message)
            self.sources[key]={status="fallback",path=path,reason=reason,width=w,height=h}
            img=canvas(w,h,fallback)
        end
        self.images[key]=img
    end
    return self.images[key]
end
local function integerScale(scale) return math.max(1,math.floor(tonumber(scale) or 1)) end
local function draw(img,x,y,scale)
    scale=integerScale(scale)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(img,math.floor(x or 0),math.floor(y or 0),0,scale,scale)
    return img
end
function Resources:getBackground(id)
    id=id or "courtyard"
    if not self.backgrounds[id] then
        self.backgrounds[id]=self:_load(Assets.backgrounds[id],BACKGROUND_WIDTH,BACKGROUND_HEIGHT,backgrounds[id] or courtyard,"background:"..id)
    end
    return self.backgrounds[id]
end
function Resources:background(id) return draw(self:getBackground(id),0,0,2) end
function Resources:getPortrait(id)
    id=id or "rudeus"
    if not self.portraits[id] then
        self.portraits[id]=self:_load(Assets.characters[id],SHEET_WIDTH,SPRITE_HEIGHT,function()
            for name,index in pairs(EXPRESSIONS) do
                love.graphics.push()
                love.graphics.translate(index*SPRITE_WIDTH,0)
                portrait(profiles[id] and id or "rudeus",name)
                love.graphics.pop()
            end
        end,"character:"..id)
    end
    return self.portraits[id]
end
function Resources:portrait(id,expression,x,y,scale)
    local img=self:getPortrait(id)
    local frame=EXPRESSIONS[expression or "neutral"] or 0
    if not self.quads[frame] then
        self.quads[frame]=love.graphics.newQuad(frame*SPRITE_WIDTH,0,SPRITE_WIDTH,SPRITE_HEIGHT,SHEET_WIDTH,SPRITE_HEIGHT)
    end
    scale=integerScale(scale)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(img,self.quads[frame],math.floor(x),math.floor(y),0,scale,scale)
    return img
end
function Resources:getIcon(id)
    id=id or "magic"
    if not self.icons[id] then
        self.icons[id]=self:_load(Assets.cardIcons[id],ICON_WIDTH,ICON_HEIGHT,function() icon(id) end,"card-icon:"..id)
    end
    return self.icons[id]
end
function Resources:icon(id,x,y,scale) return draw(self:getIcon(id),x,y,scale) end
function Resources:getCardBase()
    self.base=self.base or self:_load(Assets.cardBase,CARD_WIDTH,CARD_HEIGHT,function()
        r("E2CC9F",1,1,78,110);r("D5BD92",3,3,74,106)
    end,"card-base")
    return self.base
end
function Resources:cardBase(x,y,scale) return draw(self:getCardBase(),x,y,scale) end
function Resources:getCardFrame(category)
    category=category or "empathy"
    if not self.frames[category] then
        self.frames[category]=self:_load(Assets.cardFrames[category],CARD_WIDTH,CARD_HEIGHT,function()
            local tint=({empathy=P.teal,humor=P.gold,sincerity=P.rose,initiative=P.lavender})[category] or P.gold
            r("101A2B",0,0,80,3);r("101A2B",0,109,80,3)
            r("101A2B",0,0,3,112);r("101A2B",77,0,3,112)
            r(tint,3,3,74,3);r(tint,3,106,74,3)
            r(tint,3,3,3,106);r(tint,74,3,3,106)
        end,"card-frame:"..category)
    end
    return self.frames[category]
end
function Resources:cardFrame(category,x,y,scale) return draw(self:getCardFrame(category),x,y,scale) end
function Resources:getCardBack()
    self.back=self.back or self:_load(Assets.cardBack,CARD_WIDTH,CARD_HEIGHT,function()
        r("21344B",0,0,80,112);r("BBA78A",4,4,72,104);r("344B60",7,7,66,98)
        r("83C6BA",25,31,30,50);r("D5E2BF",29,35,22,42)
    end,"card-back")
    return self.back
end
function Resources:cardBack(x,y,scale) return draw(self:getCardBack(),x,y,scale) end
function Resources:getCategoryIcon(category)
    category=category or "empathy"
    if not self.categoryIcons[category] then
        local representative=({empathy="listen",humor="light_joke",sincerity="be_honest",initiative="shared_magic"})[category]
        self.categoryIcons[category]=self:_load(Assets.categoryIcons[category],ICON_WIDTH,ICON_HEIGHT,function() icon(representative) end,"category-icon:"..category)
    end
    return self.categoryIcons[category]
end
function Resources:categoryIcon(category,x,y,scale) return draw(self:getCategoryIcon(category),x,y,scale) end
function Resources:getManaIcon()
    self.mana=self.mana or self:_load(Assets.manaIcon,ICON_WIDTH,ICON_HEIGHT,function() icon("magic") end,"mana-icon")
    return self.mana
end
function Resources:manaIcon(x,y,scale) return draw(self:getManaIcon(),x,y,scale) end
-- Valida todos los PNG sin dibujarlos ni exigir que la historia ya los visite.
function Resources:preload()
    for id in pairs(Assets.characters) do self:getPortrait(id) end
    for id in pairs(Assets.backgrounds) do self:getBackground(id) end
    for id in pairs(Assets.cardIcons) do self:getIcon(id) end
    for category in pairs(Assets.cardFrames) do self:getCardFrame(category); self:getCategoryIcon(category) end
    self:getCardBase(); self:getCardBack(); self:getManaIcon()
    return self
end
return Resources
````

## src/systems/save.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/systems/save.lua`

````lua
local Json=require("src.systems.json")
local Cards=require("src.systems.cards")
local CardData=require("src.data.cards")
local Characters=require("src.data.characters")
local Relationships=require("src.systems.relationships")
local Story=require("src.data.story")
local Save={filename="save.json",backup="save.backup.json",optionsFile="options.json"}
local checkpoints={intro=1,day1_tutorial=1,day1_result=1,day1_close=1,hub=2,
    meet_sylphiette=2,meet_roxy=2,meet_eris=2,encounter_sylphiette=2,encounter_roxy=2,encounter_eris=2,
    result_sylphiette=2,result_roxy=2,result_eris=2,seal_intro=2,seal_encounter=2,seal_result=2,day2_close=2,phase_complete=2}
local function number(value,default,min,max)
    if type(value)~="number" or value~=value or value==math.huge or value==-math.huge then return default end
    return math.max(min,math.min(max,value))
end
local function map(value,booleans)
    local out={}
    if type(value)~="table" then return out end
    local count=0
    for key,item in pairs(value) do
        if type(key)=="string" and #key<=100 then
            if booleans then
                if item==true then out[key]=true end
            elseif type(item)=="boolean" or (type(item)=="string" and #item<=1000) then out[key]=item
            elseif type(item)=="number" and item==item and math.abs(item)<=100000 then out[key]=item end
            count=count+1
            if count>=256 then break end
        end
    end
    return out
end
local function options(value)
    value=type(value)=="table" and value or {}
    return {volume=number(value.volume,0.6,0,1),muted=value.muted==true}
end
local function starter()
    local deck,unlocked={},{}
    for i,id in ipairs(CardData.starterDeck) do deck[i]=id; unlocked[id]=true end
    return deck,unlocked
end

function Save.newSession()
    local deck,unlocked=starter()
    return {version=1,day=1,checkpoint="intro",dialogueIndex=1,relationships=Relationships.new(),
        unlocked=unlocked,deck=deck,events={},decisions={},options=options()}
end

function Save.validate(input)
    if type(input)~="table" or input==Json.null then return nil,"El guardado no contiene una partida." end
    if input.version~=nil and input.version~=1 then return nil,"Versión de guardado no compatible." end
    if not next(input) then return nil,"El guardado está vacío." end
    local s=Save.newSession()
    s.checkpoint=checkpoints[input.checkpoint] and input.checkpoint or "intro"
    s.day=checkpoints[s.checkpoint]
    s.dialogueIndex=math.floor(number(input.dialogueIndex,1,1,100))
    s.events=map(input.events,true); s.decisions=map(input.decisions,false)
    s.options=options(input.options)
    if type(input.relationships)=="table" then
        for _,id in ipairs(Characters.romanceIds) do
            local data=input.relationships[id]
            if type(data)=="table" then
                local r=s.relationships[id]
                r.trust=number(data.trust,0,0,10); r.chemistry=number(data.chemistry,0,0,10)
                r.events=map(data.events,true); r.decisions=map(data.decisions,false)
                local states={unmet=true,friend=true,chosen=true,romance=true,friendship=true,active=true}
                if states[data.routeState] then r.routeState=data.routeState end
            end
        end
    end
    for id in pairs(map(input.unlocked,true)) do if CardData.byId[id] then s.unlocked[id]=true end end
    if Cards.validateDeck(input.deck,s.unlocked) then
        s.deck={}; for i,id in ipairs(input.deck) do s.deck[i]=id end
    end
    if type(input.route)=="string" and s.relationships[input.route] then s.route=input.route end
    if type(input.selectedCompanion)=="string" and s.relationships[input.selectedCompanion] then s.selectedCompanion=input.selectedCompanion end
    if type(s.decisions.companion)~="string" or not s.relationships[s.decisions.companion] then
        s.decisions.companion=nil
        s.events.companion_selected=nil
    end
    -- Keep only known choice IDs. Progression.scene hides already answered
    -- choices while preserving the saved dialogue position.
    for _,id in ipairs(Characters.romanceIds) do
        local sceneId="meet_"..id
        local key="choice_"..sceneId
        local selected=s.decisions[key]
        local valid=false
        for _,choice in ipairs(Story.scenes[sceneId].choices) do
            if selected==choice.id then valid=true end
        end
        if not valid then s.decisions[key]=nil end
    end
    local needsCompanion=s.checkpoint:match("^seal_") or s.checkpoint=="day2_close" or s.checkpoint=="phase_complete"
    if needsCompanion and not s.decisions.companion then
        s.checkpoint="hub"; s.dialogueIndex=1
    end
    local context
    local definition=Story.encounters[s.checkpoint]
    if definition then
        context={kind=definition.kind,character=definition.character}
        if context.character=="companion" then context.character=s.decisions.companion end
    end
    if context then s.encounter=Cards.restore(input.encounter,s.deck,context) end
    if type(input.lastResult)=="table" then
        s.lastResult={score=number(input.lastResult.score,0,0,100),success=input.lastResult.success==true,
            targetScore=number(input.lastResult.targetScore,3,0,100),
            trust=number(input.lastResult.trust,0,-30,30),chemistry=number(input.lastResult.chemistry,0,-30,30)}
        if type(input.lastResult.title)=="string" and #input.lastResult.title<=200 then s.lastResult.title=input.lastResult.title end
        if Characters.byId[input.lastResult.character] then s.lastResult.character=input.lastResult.character end
    end
    return s
end

local function readFile(path)
    local ok,info=pcall(love.filesystem.getInfo,path,"file")
    if not ok or not info then return nil,"No hay guardado disponible." end
    if info.size and info.size>524288 then return nil,"El archivo de guardado es demasiado grande." end
    local readOk,data,err=pcall(love.filesystem.read,path)
    if not readOk or not data then return nil,err or "No se pudo leer el archivo." end
    return data
end
local function writeFile(path,data)
    local ok,written,err=pcall(love.filesystem.write,path,data)
    if not ok or not written then return false,err or "No se pudo escribir el archivo." end
    return true
end
local function decodeSession(data)
    local decoded,err=Json.decode(data)
    if not decoded then return nil,err end
    return Save.validate(decoded)
end

function Save.write(session)
    local clean,err=Save.validate(session)
    if not clean then return false,err end
    local data; data,err=Json.encode(clean)
    if not data then return false,err end
    local ok; ok,err=writeFile("save.tmp.json",data)
    if not ok then return false,err end
    local old=readFile(Save.filename)
    if old and decodeSession(old) then
        ok,err=writeFile(Save.backup,old)
        if not ok then return false,err end
    end
    ok,err=writeFile(Save.filename,data)
    if not ok then return false,err end
    pcall(love.filesystem.remove,"save.tmp.json")
    return true
end

function Save.load()
    local raw,err=readFile(Save.filename)
    if raw then
        local session; session,err=decodeSession(raw)
        if session then return session end
    end
    local backup=readFile(Save.backup)
    if backup then
        local session=decodeSession(backup)
        if session then return session,"Se recuperó la copia anterior del guardado." end
    end
    return nil,err or "No hay guardado válido disponible."
end

function Save.exists() return Save.load()~=nil end
function Save.readOptions()
    local data=readFile(Save.optionsFile)
    if not data then return options() end
    local parsed=Json.decode(data)
    return options(parsed)
end
function Save.writeOptions(value)
    local data,err=Json.encode(options(value))
    if not data then return false,err end
    return writeFile(Save.optionsFile,data)
end

return Save
````

## src/ui/card.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/ui/card.lua`

````lua
-- Composición compartida por la mano y la colección. Todas las medidas son
-- píxeles lógicos; el texto se mantiene fuera del icono y del borde del PNG.
local Font = require("src.ui.font")
local P = require("src.ui.palette")
local Card = {width=80,height=112}
local ink = {.17,.14,.21,1}
local categoryNames = {empathy="Empatía",humor="Humor",sincerity="Sinceridad",initiative="Magia"}
Card.regions = {
    name={x=8,y=11,w=64,h=33},
    category={x=8,y=47,w=64,h=11},
    icon={x=28,y=65,w=24,h=24},
    cost={x=10,y=95,w=60,h=11},
}

function Card.labels(card)
    return {name=card.name,category=categoryNames[card.category],cost="Coste "..card.cost}
end

function Card.draw(resources,card,x,y,opts)
    opts=opts or {}
    x,y=math.floor(x),math.floor(y)
    if opts.selected then
        love.graphics.setColor(P.gold)
        love.graphics.rectangle("fill",x-2,y-2,84,116)
    end
    resources:cardBase(x,y,1)
    resources:cardFrame(card.category,x,y,1)
    local labels=Card.labels(card)
    local function label(key)
        local box=Card.regions[key]
        Font.draw(labels[key],x+box.x,y+box.y,{maxWidth=box.w,align="center",color=ink})
    end
    label("name")
    label("category")
    resources:icon(card.id,x+Card.regions.icon.x,y+Card.regions.icon.y,1)
    label("cost")
    if opts.status then
        love.graphics.setColor(P.panel)
        love.graphics.rectangle("fill",x,y+112,80,13)
        Font.draw(opts.status,x,y+114,{maxWidth=80,align="center",color=opts.disabled and P.muted or P.gold})
    end
end

return Card
````

## src/ui/font.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/ui/font.lua`

````lua
-- Fuente bitmap original 5x7. No requiere TTF, red ni archivos adicionales.
-- Caja de línea: 11 px. El español conserva sus tildes y signos de apertura.
local Font = {lineHeight = 11, advance = 6}
local glyphs = {}
local function add(char, rows)
    local bitmap = {}
    for row in rows:gmatch("[^/]+") do bitmap[#bitmap + 1] = row end
    glyphs[char] = bitmap
end
local patterns = {
    A="01110/10001/10001/11111/10001/10001/10001", B="11110/10001/10001/11110/10001/10001/11110",
    C="01111/10000/10000/10000/10000/10000/01111", D="11110/10001/10001/10001/10001/10001/11110",
    E="11111/10000/10000/11110/10000/10000/11111", F="11111/10000/10000/11110/10000/10000/10000",
    G="01111/10000/10000/10111/10001/10001/01110", H="10001/10001/10001/11111/10001/10001/10001",
    I="11111/00100/00100/00100/00100/00100/11111", J="00111/00010/00010/00010/10010/10010/01100",
    K="10001/10010/10100/11000/10100/10010/10001", L="10000/10000/10000/10000/10000/10000/11111",
    M="10001/11011/10101/10101/10001/10001/10001", N="10001/11001/11001/10101/10011/10011/10001",
    O="01110/10001/10001/10001/10001/10001/01110", P="11110/10001/10001/11110/10000/10000/10000",
    Q="01110/10001/10001/10001/10101/10010/01101", R="11110/10001/10001/11110/10100/10010/10001",
    S="01111/10000/10000/01110/00001/00001/11110", T="11111/00100/00100/00100/00100/00100/00100",
    U="10001/10001/10001/10001/10001/10001/01110", V="10001/10001/10001/10001/10001/01010/00100",
    W="10001/10001/10001/10101/10101/10101/01010", X="10001/10001/01010/00100/01010/10001/10001",
    Y="10001/10001/01010/00100/00100/00100/00100", Z="11111/00001/00010/00100/01000/10000/11111",
    ["0"]="01110/10001/10011/10101/11001/10001/01110", ["1"]="00100/01100/00100/00100/00100/00100/01110",
    ["2"]="01110/10001/00001/00010/00100/01000/11111", ["3"]="11110/00001/00001/01110/00001/00001/11110",
    ["4"]="00010/00110/01010/10010/11111/00010/00010", ["5"]="11111/10000/10000/11110/00001/00001/11110",
    ["6"]="01110/10000/10000/11110/10001/10001/01110", ["7"]="11111/00001/00010/00100/01000/01000/01000",
    ["8"]="01110/10001/10001/01110/10001/10001/01110", ["9"]="01110/10001/10001/01111/00001/00001/01110",
    [" "]="00000/00000/00000/00000/00000/00000/00000", ["."]="00000/00000/00000/00000/00000/00110/00110",
    [","]="00000/00000/00000/00000/00110/00100/01000", [":"]="00000/00110/00110/00000/00110/00110/00000",
    [";"]="00000/00110/00110/00000/00110/00100/01000", ["!"]="00100/00100/00100/00100/00100/00000/00100",
    ["?"]="01110/10001/00001/00010/00100/00000/00100", ["¡"]="00100/00000/00100/00100/00100/00100/00100",
    ["¿"]="00100/00000/00100/01000/10000/10001/01110", ["-"]="00000/00000/00000/11111/00000/00000/00000",
    ["+"]="00000/00100/00100/11111/00100/00100/00000", ["="]="00000/00000/11111/00000/11111/00000/00000",
    ["/"]="00001/00001/00010/00100/01000/10000/10000", ["\\"]="10000/10000/01000/00100/00010/00001/00001",
    ["("]="00010/00100/01000/01000/01000/00100/00010", [")"]="01000/00100/00010/00010/00010/00100/01000",
    ["["]="01110/01000/01000/01000/01000/01000/01110", ["]"]="01110/00010/00010/00010/00010/00010/01110",
    ["'"]="00100/00100/01000/00000/00000/00000/00000", ['"']="01010/01010/01010/00000/00000/00000/00000",
    ["<"]="00010/00100/01000/10000/01000/00100/00010", [">"]="01000/00100/00010/00001/00010/00100/01000",
    ["%"]="11001/11010/00010/00100/01000/01011/10011", ["_"]="00000/00000/00000/00000/00000/00000/11111",
    ["*"]="00000/10101/01110/11111/01110/10101/00000", ["#"]="01010/01010/11111/01010/11111/01010/01010",
    ["|"]="00100/00100/00100/00100/00100/00100/00100", ["&"]="01100/10010/10100/01000/10101/10010/01101",
    ["@"]="01110/10001/10111/10101/10111/10000/01110",
    ["·"]="00000/00000/00000/00110/00110/00000/00000", ["…"]="00000/00000/00000/00000/00000/00000/10101",
}
for char, pattern in pairs(patterns) do add(char, pattern) end
local accents = { ["Á"]="A", ["É"]="E", ["Í"]="I", ["Ó"]="O", ["Ú"]="U", ["Ñ"]="N", ["Ü"]="U" }
for char, base in pairs(accents) do
    local rows = {}
    rows[1] = char == "Ñ" and "01010" or (char == "Ü" and "01010" or "00010")
    rows[2] = char == "Ñ" and "10100" or (char == "Ü" and "00000" or "00100")
    for i, row in ipairs(glyphs[base]) do rows[i+2] = row end
    glyphs[char] = rows
end
local upper = { ["á"]="Á", ["é"]="É", ["í"]="Í", ["ó"]="Ó", ["ú"]="Ú", ["ñ"]="Ñ", ["ü"]="Ü" }
local aliases = { ["—"]="-", ["–"]="-", ["‘"]="'", ["’"]="'", ["“"]='"', ["”"]='"', ["•"]="*", ["→"]=">", ["♥"]="*" }
local function chars(text)
    local result = {}
    for char in tostring(text or ""):gmatch("[%z\1-\127\194-\244][\128-\191]*") do result[#result + 1] = char end
    return result
end
function Font.width(text, scale)
    scale = scale or 1
    local width, maximum = 0, 0
    for _, char in ipairs(chars(text)) do
        if char == "\n" then maximum = math.max(maximum, width); width = 0 else width = width + 6 end
    end
    return math.max(maximum, width) * scale
end
function Font.wrap(text, maxWidth, scale)
    text, scale = tostring(text or ""), scale or 1
    if not maxWidth then
        local lines = {}; for line in (text.."\n"):gmatch("(.-)\n") do lines[#lines+1] = line end
        return lines
    end
    local capacity = math.max(1, math.floor(maxWidth / (6 * scale)))
    local lines = {}
    for paragraph in (text.."\n"):gmatch("(.-)\n") do
        local line = ""
        for word in paragraph:gmatch("%S+") do
            if line ~= "" and Font.width(line.." "..word, 1) > capacity*6 then lines[#lines+1] = line; line = "" end
            local wordChars = chars(word)
            while #wordChars > capacity do
                if line ~= "" then lines[#lines+1] = line; line = "" end
                lines[#lines+1] = table.concat(wordChars, "", 1, capacity)
                local rest = {}; for i=capacity+1,#wordChars do rest[#rest+1] = wordChars[i] end
                wordChars = rest
            end
            word = table.concat(wordChars)
            if word ~= "" then line = line == "" and word or (line.." "..word) end
        end
        lines[#lines+1] = line
    end
    return lines
end
function Font.height(text, maxWidth, scale)
    scale = scale or 1
    return #Font.wrap(text, maxWidth, scale) * Font.lineHeight * scale
end
function Font.draw(text, x, y, opts)
    opts = opts or {}
    local scale = opts.scale or 1
    local color = opts.color or {1,1,1,1}
    love.graphics.setColor(color)
    local lines = Font.wrap(text, opts.maxWidth, scale)
    for rowIndex, line in ipairs(lines) do
        local xx = x
        if opts.maxWidth and opts.align == "center" then xx = x + math.floor((opts.maxWidth - Font.width(line,scale))/2)
        elseif opts.maxWidth and opts.align == "right" then xx = x + opts.maxWidth - Font.width(line,scale) end
        for _, char in ipairs(chars(line)) do
            char = upper[char] or aliases[char] or char:upper()
            local glyph = glyphs[char] or glyphs["?"]
            local top = y + (rowIndex-1)*Font.lineHeight*scale + (#glyph == 9 and 0 or 2*scale)
            for gy, pixels in ipairs(glyph) do
                for gx=1,#pixels do
                    if pixels:sub(gx,gx) == "1" then love.graphics.rectangle("fill", math.floor(xx + (gx-1)*scale), math.floor(top + (gy-1)*scale), scale, scale) end
                end
            end
            xx = xx + 6*scale
        end
    end
    return #lines*Font.lineHeight*scale
end
return Font
````

## src/ui/palette.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/ui/palette.lua`

````lua
-- Paleta compartida; los valores están normalizados para LÖVE 11.
local function rgb(hex)
    return {tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255, 1}
end
return {
    bg = rgb("101828"), panel = rgb("19283B"), panelLight = rgb("283C50"),
    ink = rgb("F8EDD7"), muted = rgb("B5BAC4"), gold = rgb("E8BC73"),
    teal = rgb("80C8BE"), rose = rgb("E2A4A1"), lavender = rgb("B2A5D1"),
    border = rgb("51637B"), shadow = rgb("0B1322"), danger = rgb("D77A85"),
    green = rgb("A0C395"), white = rgb("FFFFFF"),
}
````

## src/ui/screen.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/ui/screen.lua`

````lua
local Font = require("src.ui.font")
local W = require("src.ui.widgets")
local P = require("src.ui.palette")
local Controls = require("src.config.controls")
local Screen = {}
Screen.__index = Screen

function Screen.new(app)
    return setmetatable({app=app,buttons={}},Screen)
end

function Screen:begin()
    self.buttons = {}
end

function Screen:text(text,x,y,width,color,scale,align)
    Font.draw(tostring(text or ""),x,y,{maxWidth=width,color=color or P.ink,scale=scale or 1,align=align or "left"})
end

function Screen:button(label,x,y,w,h,action,disabled,selected)
    local mx,my = self.app:mouse()
    local hover = mx and mx >= x and mx < x+w and my >= y and my < y+h
    W.button(label,x,y,w,h,{hover=hover,disabled=disabled,selected=selected or self.keyboardFocus==#self.buttons+1})
    self.buttons[#self.buttons+1]={label=label,x=x,y=y,w=w,h=h,action=action,disabled=disabled}
    return hover
end

function Screen:click(x,y,button)
    if button ~= 1 then return false end
    self.keyboardFocus=nil
    for _,b in ipairs(self.buttons) do
        if x >= b.x and x < b.x+b.w and y >= b.y and y < b.y+b.h then
            if not b.disabled then b.action() end
            return true
        end
    end
    return false
end

-- Reutiliza las mismas acciones e hitboxes del mouse. Tab y flechas verticales
-- recorren botones habilitados; Enter/Espacio activan únicamente el foco visible.
function Screen:navigate(key)
    local direction=(Controls.matches(Controls.previousButton,key) and -1)
        or (Controls.matches(Controls.nextButton,key) and 1)
    if direction then
        local count=#self.buttons
        if count==0 then return true end
        local current=self.keyboardFocus or (direction==1 and 0 or count+1)
        for _=1,count do
            current=(current-1+direction)%count+1
            local button=self.buttons[current]
            if button.label and not button.disabled then self.keyboardFocus=current; return true end
        end
        return true
    end
    if self.keyboardFocus and Controls.matches(Controls.advance,key) then
        local button=self.buttons[self.keyboardFocus]
        if button and not button.disabled then button.action() end
        return true
    end
    return false
end

function Screen:header(title,back)
    W.panel(8,7,624,30)
    self:text(title,18,18,340,P.gold)
    if back then
        self:button("Volver",548,12,76,20,function() self.app:resume() end)
    else
        self:button("Diario [J]",350,12,94,20,function() self.app:overlay("journal") end)
        self:button("Mazo [M]",450,12,88,20,function() self.app:overlay("deck") end)
        self:button("Pausa",544,12,80,20,function() self.app:overlay("pause") end)
    end
end

function Screen:mousepressed(x,y,button) self:click(x,y,button) end
function Screen:keypressed(key) self:navigate(key) end
return Screen
````

## src/ui/widgets.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/src/ui/widgets.lua`

````lua
local P = require("src.ui.palette")
local Font = require("src.ui.font")
local W = {}
local function rect(color,x,y,w,h)
    love.graphics.setColor(color); love.graphics.rectangle("fill",math.floor(x),math.floor(y),w,h)
end
function W.panel(x,y,w,h,opts)
    opts = opts or {}
    if opts.shadow ~= false then rect(P.shadow,x+3,y+3,w,h) end
    rect(opts.border or P.border,x+1,y,w-2,h)
    rect(opts.border or P.border,x,y+1,w,h-2)
    rect(opts.fill or P.panel,x+1,y+1,w-2,h-2)
    if opts.accent then rect(opts.accent,x+1,y+1,2,h-2) end
end
function W.button(label,x,y,w,h,opts)
    opts = opts or {}
    local active = (opts.hover or opts.selected) and not opts.disabled
    W.panel(x,y,w,h,{border=active and P.gold or P.border,fill=active and P.panelLight or P.panel,shadow=opts.shadow})
    if active then rect(P.gold,x+2,y+2,2,h-4) end
    local scale = opts.scale or 1
    local height = Font.height(label,w-12,scale)
    Font.draw(label,x+6,y+math.floor((h-height)/2),{maxWidth=w-12,align=opts.align or "center",scale=scale,color=opts.disabled and P.border or (active and P.gold or P.ink)})
end
function W.bar(x,y,w,h,value,maximum,color)
    rect(P.shadow,x,y,w,h)
    local ratio = math.max(0,math.min(1,(tonumber(value) or 0)/math.max(1,maximum or 10)))
    local available = w-2
    rect(color or P.teal,x+1,y+1,math.floor(available*ratio),h-2)
    for i=1,(maximum or 10)-1 do rect(P.panel,x+math.floor(available*i/(maximum or 10)),y+1,1,h-2) end
end
function W.label(text,x,y,opts) return Font.draw(text,x,y,opts) end
function W.divider(x,y,w,color) rect(color or P.border,x,y,w,1) end
return W
````

## tests/gameplay.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/tests/gameplay.lua`

````lua
-- Run with the project's LÖVE test switch, or: lua -e "require('tests.gameplay').run()"
local Suite={}
function Suite.run()
    local Cards=require("src.systems.cards")
    local Data=require("src.data.cards")
    local Relationships=require("src.systems.relationships")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local checked=0
    local function check(condition,message)
        assert(condition,message); checked=checked+1
    end
    check(#Data.list==16,"16 cartas definidas")
    check(Cards.validateDeck(Data.starterDeck),"Mazo inicial válido")
    check(not Cards.validateDeck({"listen"}),"Rechazar longitud incorrecta")
    local duplicate={}; for i,id in ipairs(Data.starterDeck) do duplicate[i]=id end
    duplicate[10]=duplicate[1]
    check(not Cards.validateDeck(duplicate),"Rechazar cartas repetidas")

    local calls={}
    local enc=Cards.new(Data.starterDeck,{kind="magic",character="nanahoshi"},function(n) calls[#calls+1]=n; return n end)
    check(#calls==9 and calls[1]==10 and calls[9]==2,"Fisher-Yates usa rangos descendentes")
    check(#enc.hand==3 and #enc.drawPile==7 and #enc.discard==0,"Repartir 3 de 10")
    check(enc.hand[1]=="earth_barrier","RNG determinista conserva orden")
    local first=Cards.play(enc,1)
    check(first.score==4 and first.trust==0,"Efecto mágico sin relación no romántica")
    check(enc.energy==2 and #enc.hand==3 and #enc.drawPile==6 and #enc.discard==1,"Pagar, descartar y robar")
    check(enc.turn==2 and not enc.finished,"Un turno por acción")
    local restored=Cards.restore(enc,Data.starterDeck,{kind="magic",character="nanahoshi"})
    check(restored and restored.energy==2 and restored.hand[1]==enc.hand[1] and restored.turn==2,"Restaurar turno y mano")
    check(not Cards.play(enc,0) and not Cards.play(enc,99) and not Cards.play(enc,1.1),"Rechazar índices inválidos")
    check(enc.turn==2 and enc.energy==2,"Acción inválida no modifica estado")
    Cards.pass(enc); Cards.pass(enc)
    check(enc.finished and enc.turn==4 and #enc.log==3,"Tres turnos exactos")
    check(not Cards.pass(enc) and not Cards.play(enc,1),"No actuar tras el final")

    local empty=Cards.new(Data.starterDeck,{kind="conversation",character="eris"},function(n) return n end)
    empty.energy=0
    local before=table.concat(empty.hand,",")
    check(not Cards.play(empty,1),"Una carta de coste 2 no se juega sin energía")
    check(empty.turn==1 and table.concat(empty.hand,",")==before,"No gastar turno al rechazar")
    Cards.pass(empty); Cards.pass(empty); Cards.pass(empty)
    check(empty.finished,"Acción gratuita evita bloqueo con mano cara")
    local free={hand={"light_joke"},context={kind="conversation",character="eris"},energy=0,finished=false,
        drawPile={},discard={},score=0,turn=1,maxTurns=3,log={}}
    check(Cards.play(free,1)~=nil and free.energy==0 and #free.hand==0,"Coste cero y pila vacía son seguros")
    local conditional={hand={"shared_magic"},context={kind="magic",character="eris"},energy=4,finished=false}
    check(not Cards.canPlay(conditional,1),"Carta exclusiva exige acompañante correcto")
    conditional.context.character="sylphiette"
    check(Cards.canPlay(conditional,1),"Carta exclusiva disponible con su acompañante")
    local a=Cards.preview({hand={"listen"},context={kind="conversation",character="sylphiette"}},1)
    local b=Cards.preview({hand={"listen"},context={kind="conversation",character="eris"}},1)
    check(a.chemistry>b.chemistry,"Preferencias modifican los efectos")
    local fresh=Cards.new(Data.starterDeck,{kind="magic"},function(n) return n end)
    check(fresh.energy==4 and fresh.turn==1 and #fresh.discard==0,"Cada encuentro reinicia mazo y energía")

    -- Every real card must apply exactly once, and inspecting its effect must
    -- leave the encounter untouched. Exercise all three narrative contexts.
    for _,card in ipairs(Data.list) do
        check(card.cost>=0 and card.cost<=2 and card.cost%1==0,"Coste permitido: "..card.id)
        for _,kind in ipairs({"conversation","investigation","magic"}) do
            local deck={}
            local position
            for i,id in ipairs(Data.starterDeck) do deck[i]=id; if id==card.id then position=i end end
            if position then deck[position],deck[10]=deck[10],deck[position] else deck[10]=card.id end
            local context={kind=kind,character=card.exclusive or "roxy"}
            local action=Cards.new(deck,context,function(n) return n end)
            local beforePreview=assert(Json.encode(action))
            local preview=Cards.preview(action,1)
            check(Json.encode(action)==beforePreview,"Vista previa no aplica efectos: "..card.id.."/"..kind)
            check(Cards.canPlay(action,1),"Carta jugable con su acompañante: "..card.id)
            local result=assert(Cards.play(action,1))
            check(action.score==preview.score and result.trust==preview.trust and result.chemistry==preview.chemistry,
                "Efectos aplicados una vez: "..card.id.."/"..kind)
            check(action.energy==4-card.cost and action.turn==2 and #action.log==1 and action.discard[1]==card.id,
                "Una sola acción y un solo pago: "..card.id)
            local snapshot=assert(Json.encode(action))
            for _=1,3 do action=assert(Cards.restore(action,deck,context)) end
            check(Json.encode(action)==snapshot,"Restaurar no duplica efectos: "..card.id.."/"..kind)
        end
    end

    local resting=Cards.new(Data.starterDeck,{kind="magic"},function(n) return n end)
    for turn=1,3 do
        local hand,pile=table.concat(resting.hand,","),table.concat(resting.drawPile,",")
        Cards.pass(resting)
        local snapshot=assert(Json.encode(resting))
        resting=assert(Cards.restore(resting,Data.starterDeck,{kind="magic"}))
        check(Json.encode(resting)==snapshot,"Acción gratuita conserva incluso su registro al continuar")
        check(resting.energy==4 and resting.turn==turn+1 and #resting.log==turn and #resting.discard==0,
            "Acción gratuita gasta solo un turno")
        check(table.concat(resting.hand,",")==hand and table.concat(resting.drawPile,",")==pile,
            "Acción gratuita no roba ni descarta")
    end
    check(resting.finished and not Cards.pass(resting),"Continuar encuentro gratuito terminado no concede otro turno")

    local all=Relationships.new()
    Relationships.apply(all,"sylphiette",{trust=30,chemistry=-2})
    check(all.sylphiette.trust==10 and all.sylphiette.chemistry==0,"Límites de relación")
    Relationships.apply(all,"sylphiette",{chemistry=10})
    check(Relationships.ending(all,"sylphiette",{confession="sylphiette"})=="friendship_sylphiette","Puntos no bastan para romance")
    Relationships.complete(all,"sylphiette","route_conflict")
    Relationships.complete(all,"sylphiette","mirror_truth")
    check(Relationships.ending(all,"sylphiette",{})=="friendship_sylphiette","Confesión debe ser explícita")
    check(Relationships.ending(all,"sylphiette",{confession="sylphiette"})=="romance_sylphiette","Romance con todos los requisitos")
    check(Relationships.ending(all,nil,{})=="independent","Final independiente")
    for _,id in ipairs({"roxy","eris"}) do
        all[id].trust=6; all[id].chemistry=5; all[id].events.route_conflict=true; all[id].events.mirror_truth=true
        check(Relationships.ending(all,id,{confession=id})=="romance_"..id,"Romance "..id)
        check(Relationships.ending(all,id,{})=="friendship_"..id,"Amistad "..id)
    end

    local input={version=1,checkpoint="encounter_roxy",deck={"bad"},day=99,
        relationships={roxy={trust=99,chemistry=-50}},options={volume=20,muted=true},
        events={reunion=true},decisions={companion="roxy",outcome_day1_tutorial="partial"}}
    local valid=Save.validate(input)
    check(valid.day==2 and valid.relationships.roxy.trust==10 and valid.relationships.roxy.chemistry==0,"Normalizar guardado parcial")
    check(#valid.deck==10 and valid.options.volume==1 and valid.options.muted,"Reparar mazo y opciones")
    check(valid.events.reunion and valid.decisions.companion=="roxy","Preservar decisiones y eventos")
    check(not Save.validate({version=99}) and not Save.validate({}),"Rechazar versión desconocida y vacío")
    local chosen=Save.validate({version=1,checkpoint="meet_roxy",decisions={choice_meet_roxy="compare_notes"}})
    check(chosen.checkpoint=="meet_roxy" and chosen.decisions.choice_meet_roxy=="compare_notes","Conservar elección y punto de diálogo")
    local invalidChoice=Save.validate({version=1,checkpoint="meet_roxy",decisions={choice_meet_roxy=true,companion=true}})
    check(invalidChoice.checkpoint=="meet_roxy" and invalidChoice.decisions.choice_meet_roxy==nil and invalidChoice.decisions.companion==nil,"Eliminar tipos inválidos en elecciones")
    local missingCompanion=Save.validate({version=1,checkpoint="seal_result",events={companion_selected=true}})
    check(missingCompanion.checkpoint=="hub" and not missingCompanion.events.companion_selected,"Acompañante ausente se vuelve a elegir")
    local encoded=assert(Json.encode({message="¡Sí, mañana!\n\"Roxy\"",integer=7,flag=false,array={1,2,3}}))
    local decoded=assert(Json.decode(encoded))
    check(decoded.message=="¡Sí, mañana!\n\"Roxy\"" and decoded.array[3]==3 and decoded.flag==false,"JSON conserva español y escapes")
    check(Json.decode('"\\u00f1\\ud83c\\udf1f"')=="ñ🌟","Decodificar Unicode")
    for _,bad in ipairs({'{','{"a":1,}','{"a":1,"a":2}','[1,]','01','1.','1.e3','1e999','"\\uD800"','os.execute("bad")'}) do
        check(Json.decode(bad)==nil,"Rechazar JSON mal formado: "..bad)
    end
    local s=Save.newSession()
    s.checkpoint="day1_tutorial"; s.encounter=Cards.new(s.deck,{kind="magic",character="nanahoshi"},function(n) return n end)
    Cards.play(s.encounter,1)
    local round=Save.validate(assert(Json.decode(assert(Json.encode(s)))))
    check(round.encounter.energy==2 and round.encounter.turn==2 and round.encounter.discard[1]=="earth_barrier","Guardar estado exacto del encuentro")
    local roxySave=Save.newSession()
    roxySave.checkpoint="encounter_roxy"
    roxySave.encounter=Cards.new(roxySave.deck,{kind="investigation",character="roxy"},function(n) return n end)
    Cards.play(roxySave.encounter,2)
    local roxyRestored=Save.validate(roxySave)
    check(roxyRestored.encounter.context.kind=="investigation" and roxyRestored.encounter.score==3,"Restaurar contexto canónico de Roxy")
    local sealSave=Save.newSession()
    sealSave.checkpoint="seal_encounter"; sealSave.decisions.companion="eris"
    sealSave.encounter=Cards.new(sealSave.deck,{kind="magic",character="eris"},function(n) return n end)
    Cards.play(sealSave.encounter,1)
    local sealRestored=Save.validate(sealSave)
    check(sealRestored.encounter.context.kind=="magic" and sealRestored.encounter.score==4,"Restaurar contexto canónico del sello")
    s.encounter.hand[1]=s.encounter.hand[2]
    check(Save.validate(s).encounter==nil,"Rechazar snapshot con cartas duplicadas")

    -- In-memory filesystem: the test never changes a player's actual save.
    local previousLove=love
    local files={}
    love={filesystem={
        getInfo=function(path) if files[path] then return {size=#files[path]} end end,
        read=function(path) return files[path] end,
        write=function(path,data) files[path]=data; return true end,
        remove=function(path) files[path]=nil; return true end,
    }}
    local ok,errorMessage=pcall(function()
        local session=Save.newSession()
        check(Save.write(session),"Guardar nueva partida")
        check(Save.exists() and Save.load().checkpoint=="intro","Continuar partida")
        session.checkpoint="hub"; session.decisions.companion="eris"
        check(Save.write(session),"Guardar segundo checkpoint")
        check(Save.load().checkpoint=="hub","Cargar checkpoint nuevo")
        files[Save.filename]="truncated{"
        local backup,message=Save.load()
        check(backup and backup.checkpoint=="intro" and message~=nil,"Recuperar backup si archivo está truncado")
        local active=Save.newSession()
        active.checkpoint="encounter_roxy"
        active.decisions.choice_meet_roxy="compare_notes"
        active.decisions.roxy_equality="colleagues"
        active.events.choice_meet_roxy=true
        active.relationships.roxy.trust=1
        active.encounter=Cards.new(active.deck,{kind="investigation",character="roxy"},function(n) return n end)
        Cards.pass(active.encounter)
        Cards.play(active.encounter,2)
        local expectedEncounter=assert(Json.encode(active.encounter))
        check(Save.write(active),"Guardar decisión y encuentro con acción gratuita")
        for _=1,3 do
            active=assert(Save.load())
            check(Json.encode(active.encounter)==expectedEncounter,"Carga mantiene mano, pilas, energía, turnos y registro")
            check(active.events.choice_meet_roxy and active.decisions.choice_meet_roxy=="compare_notes"
                and active.decisions.roxy_equality=="colleagues" and active.relationships.roxy.trust==1,
                "Carga conserva decisiones sin anticipar ni duplicar efectos del encuentro")
            check(Save.write(active),"Volver a guardar encuentro restaurado")
        end
        check(Save.writeOptions({volume=0.2,muted=true}),"Guardar opciones")
        local prefs=Save.readOptions()
        check(prefs.volume==0.2 and prefs.muted,"Cargar opciones")
        files[Save.filename]="truncated{"
        files[Save.backup]=nil
        check(Save.load()==nil and not Save.exists(),"Guardado corrupto no provoca cierre")
        love.filesystem.write=function() return false,"sin espacio" end
        check(not Save.write(session),"Propagar error de escritura")
    end)
    love=previousLove
    assert(ok,errorMessage)
    print("OK: "..checked.." comprobaciones de cartas, relaciones, JSON y guardado.")
    return checked
end
return Suite
````

## tests/resources.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/tests/resources.lua`

````lua
-- Se decodifican los PNG del repositorio y se prueba la reserva con fallos
-- inyectados en memoria. No modifica ningún recurso ni archivo del usuario.
local Suite={}
function Suite.run()
    local Resources=require("src.systems.resources")
    local Assets=require("src.data.assets")
    local Characters=require("src.data.characters")
    local Cards=require("src.data.cards")
    local count=0
    local function check(ok,message) count=count+1; assert(ok,message) end
    local originalInfo,originalImage,originalDraw=love.filesystem.getInfo,love.graphics.newImage,love.graphics.draw
    love.graphics.push("all")
    local ok,err=xpcall(function()
        local resources=Resources.new():preload()
        check(#resources.warnings==0,"Todos los PNG definitivos cargan sin reservas")
        local loaded=0
        for path,source in pairs(resources.sources) do
            loaded=loaded+1
            check(source.status=="png" and resources.images[path]:typeOf("Image"),"Nunca sustituir silenciosamente: "..path)
            local min,mag=resources.images[path]:getFilter()
            check(min=="nearest" and mag=="nearest","Filtrado nearest: "..path)
            local data=love.image.newImageData(path)
            local w,h=data:getDimensions()
            check(w==source.width and h==source.height,"Dimensiones reales: "..path)
        end
        check(loaded==42,"42 PNG únicos: 7 personajes, 8 fondos, 27 capas e iconos de cartas")
        local expectedBackgrounds={laboratory="laboratorio",courtyard="patio_universidad",library="biblioteca",
            ruins="ruinas",garden="patio_universidad",training="bosque",forest="bosque",observatory="observatorio",
            mirror_dimension="dimension_espejo",festival="festival"}
        local unique={}
        for id,name in pairs(expectedBackgrounds) do
            local path="assets/backgrounds/"..name..".png"
            unique[path]=true
            check(Assets.backgrounds[id]==path,"Mapa explícito del escenario "..id)
            check(resources:getBackground(id)==resources.images[path],"Escenario usa su PNG: "..id)
        end
        local backgroundCount=0; for _ in pairs(unique) do backgroundCount=backgroundCount+1 end
        check(backgroundCount==8,"Ocho fondos distintos para diez IDs")
        check(resources.backgrounds.garden==resources.backgrounds.courtyard,"Jardín reutiliza la misma imagen del patio")
        check(resources.backgrounds.training==resources.backgrounds.forest,"Entrenamiento reutiliza la misma imagen del bosque")
        local expectedIcons={listen="escuchar",encourage="dar_animo",remember="recordar_un_detalle",
            light_joke="broma_ligera",change_subject="cambiar_de_tema",self_joke="reirse_de_uno_mismo",
            be_honest="hablar_con_honestidad",admit_error="reconocer_un_error",share_fear="compartir_un_miedo",
            propose_plan="proponer_un_plan",analyze_runes="analizar_runas",earth_barrier="barrera_de_tierra",
            shared_magic="magia_compartida",combined_spell="conjuro_combinado",sword_magic="espada_y_magia",
            choose_together="elegir_juntos"}
        local expectedFrames={empathy="empatia",humor="humor",sincerity="sinceridad",initiative="magia_iniciativa"}
        check(#Cards.list==16,"Dieciséis cartas jugables definidas")
        for _,card in ipairs(Cards.list) do
            local path="assets/cards/iconos/"..expectedIcons[card.id]..".png"
            check(Assets.cardIcons[card.id]==path,"Icono español para el ID real "..card.id)
            check(resources:getIcon(card.id)==resources.images[path],"Carta usa icono definitivo: "..card.id)
            check(Assets.cardFrames[card.category]=="assets/cards/marcos/marco_"..expectedFrames[card.category]..".png",
                "Marco depende de la categoría real: "..card.id)
        end
        check(Cards.byId.choose_together.category=="sincerity","Elegir Juntos conserva la categoría del código")
        for category in pairs(Cards.categories) do
            check(resources:getCardFrame(category)==resources.images[Assets.cardFrames[category]],"Marco definitivo: "..category)
        end
        -- La transparencia se comprueba en el archivo y tras el dibujo real.
        local target=love.graphics.newCanvas(72,72)
        local function renderPortrait(id,expression)
            love.graphics.setCanvas(target); love.graphics.origin(); love.graphics.clear(0,0,0,0)
            resources:portrait(id,expression,4,4,1)
            love.graphics.setCanvas()
            return target:newImageData()
        end
        for _,character in ipairs(Characters.list) do
            local path=Assets.characters[character.id]
            local source=love.image.newImageData(path)
            check(resources:getPortrait(character.id):typeOf("Image"),"PNG de personaje real: "..character.id)
            for index,expression in ipairs({"neutral","happy","worried","angry"}) do
                local rendered=renderPortrait(character.id,expression)
                local matches,transparent=true,false
                for y=0,63 do for x=0,63 do
                    local sr,sg,sb,sa=source:getPixel((index-1)*64+x,y)
                    local rr,rg,rb,ra=rendered:getPixel(x+4,y+4)
                    if sa==0 then transparent=true end
                    if math.abs(sa-ra)>.005 or (sa>0 and
                        (math.abs(sr-rr)>.005 or math.abs(sg-rg)>.005 or math.abs(sb-rb)>.005)) then matches=false end
                end end
                check(matches,"Expresión exacta y alfa intacto: "..character.id.."/"..expression)
                check(transparent,"La expresión conserva fondo transparente: "..character.id.."/"..expression)
                local x,y,w,h=resources.quads[index-1]:getViewport()
                check(x==(index-1)*64 and y==0 and w==64 and h==64,"Quad estable: "..expression)
                local _,_,_,outside=rendered:getPixel(68,67)
                check(outside==0,"El recorte no invade el cuadro vecino")
            end
        end
        for _,card in ipairs(Cards.list) do
            local source=love.image.newImageData(Assets.cardIcons[card.id])
            love.graphics.setCanvas(target); love.graphics.clear(0,0,0,0)
            resources:icon(card.id,4,4,1)
            love.graphics.setCanvas()
            local rendered=target:newImageData()
            local matches,transparent=true,false
            for y=0,23 do for x=0,23 do
                local _,_,_,sa=source:getPixel(x,y)
                local _,_,_,ra=rendered:getPixel(x+4,y+4)
                if sa==0 then transparent=true end
                if math.abs(sa-ra)>.005 then matches=false end
            end end
            check(matches and transparent,"Icono conserva transparencia al dibujarse: "..card.id)
        end
        -- Ni escalas fraccionarias ni posiciones subpíxel llegan al renderer.
        local calls={}
        love.graphics.draw=function(...) calls[#calls+1]={...} end
        resources:portrait("rudeus","neutral",4.8,5.6,2.75)
        resources:icon("listen",4.8,5.6,2.75)
        resources:cardBase(4.8,5.6,2.75)
        resources:cardFrame("empathy",4.8,5.6,2.75)
        resources:cardBack(4.8,5.6,2.75)
        love.graphics.draw=originalDraw
        check(calls[1][3]==4 and calls[1][4]==5 and calls[1][6]==2 and calls[1][7]==2,"Retratos a escala y posición enteras")
        for i=2,#calls do
            check(calls[i][2]==4 and calls[i][3]==5 and calls[i][5]==2 and calls[i][6]==2,"Capas a escala y posición enteras")
        end
        -- Los colores detectan cuadros cambiados incluso con expresiones iguales.
        local path=Assets.characters.rudeus
        local colors={{1,0,0,1},{0,1,0,1},{0,0,1,1},{1,1,0,1}}
        local pixels=love.image.newImageData(256,64)
        pixels:mapPixel(function(x) return unpack(colors[math.floor(x/64)+1]) end)
        local png=pixels:encode("png")
        love.graphics.newImage=function(candidate,...)
            if candidate==path then
                local img=originalImage(png); img:setFilter("linear","linear"); return img
            end
            return originalImage(candidate,...)
        end
        resources=Resources.new()
        for index,expression in ipairs({"neutral","happy","worried","angry"}) do
            local r,g,b,a=renderPortrait("rudeus",expression):getPixel(4,4)
            local color=colors[index]
            check(r==color[1] and g==color[2] and b==color[3] and a==1,"Orden horizontal fijo: "..expression)
        end
        local r,g,b=renderPortrait("rudeus","desconocida"):getPixel(4,4)
        check(r==1 and g==0 and b==0,"Expresión desconocida utiliza neutral")
        local min,mag=resources.portraits.rudeus:getFilter()
        check(min=="nearest" and mag=="nearest","El cargador fuerza nearest")
        local wrongSize=love.image.newImageData(1,1):encode("png")
        local corrupt=love.filesystem.newFileData("invalid PNG","invalid.png")
        local failingPath,mode
        love.filesystem.getInfo=function(candidate,...)
            if candidate==failingPath and mode=="missing" then return nil end
            return originalInfo(candidate,...)
        end
        love.graphics.newImage=function(candidate,...)
            if candidate==failingPath then return originalImage(mode=="wrong_size" and wrongSize or corrupt) end
            return originalImage(candidate,...)
        end
        local cases={
            {path=Assets.characters.rudeus,w=256,h=64,get=function(res) return res:getPortrait("rudeus") end},
            {path=Assets.backgrounds.library,w=320,h=180,get=function(res) return res:getBackground("library") end},
            {path=Assets.cardIcons.listen,w=24,h=24,get=function(res) return res:getIcon("listen") end},
            {path=Assets.cardFrames.empathy,w=80,h=112,get=function(res) return res:getCardFrame("empathy") end},
        }
        for _,case in ipairs(cases) do
            failingPath=case.path
            for _,variant in ipairs({"missing","wrong_size","corrupt"}) do
                mode=variant
                resources=Resources.new()
                local fallback=case.get(resources)
                check(fallback:typeOf("Canvas"),"Reserva sin cierre: "..variant.."/"..failingPath)
                local w,h=fallback:getDimensions()
                check(w==case.w and h==case.h,"Reserva mantiene dimensiones esperadas")
                check(resources.sources[failingPath].status=="fallback" and resources.sources[failingPath].reason,
                    "La reserva conserva diagnóstico consultable")
                check(#resources.warnings==1 and resources.warnings[1]:find(failingPath,1,true),"Diagnóstico identifica la ruta")
                check(case.get(resources)==fallback and #resources.warnings==1,"No repetir carga ni avisos por fotograma")
            end
        end
        love.filesystem.getInfo,love.graphics.newImage=originalInfo,originalImage
        resources=Resources.new()
        resources:getBackground("unknown_scene")
        check(#resources.warnings==1 and resources.sources["unmapped:background:unknown_scene"].status=="fallback",
            "Un ID no registrado se diagnostica sin fingir un escenario definitivo")
    end,debug.traceback)
    love.filesystem.getInfo,love.graphics.newImage,love.graphics.draw=originalInfo,originalImage,originalDraw
    love.graphics.setCanvas(); love.graphics.pop()
    assert(ok,err)
    print("Resources: "..count.." checks passed (42 real PNGs, mappings, expressions, transparency and diagnosed fallbacks).")
    return count
end
return Suite
````

## tests/run.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/tests/run.lua`

````lua
-- Se ejecuta dentro de LÖVE: lovec.exe . --test
-- Las pruebas de disco usan otra identidad; nunca pisan una partida real.
return function()
    love.filesystem.setIdentity("cartas_del_destino_tests")
    require("tests.gameplay").run()
    require("tests.story").run()
    require("tests.resources").run()
    require("tests.ui").run()
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local Story=require("src.data.story")
    local Cards=require("src.systems.cards")
    local Controls=require("src.config.controls")
    local Font=require("src.ui.font")
    local Progression=require("src.systems.progression")
    local diskChecks=0
    local function diskCheck(ok,message) assert(ok,message); diskChecks=diskChecks+1 end
    local diskSession=Save.newSession()
    diskSession.day,diskSession.checkpoint=2,"meet_roxy"
    assert(Progression.choose(diskSession,"meet_roxy","compare_notes"))
    assert(Progression.next(diskSession)=="encounter_roxy")
    diskSession.encounter=Cards.new(diskSession.deck,{kind="investigation",character="roxy"})
    Cards.pass(diskSession.encounter)
    diskCheck(Save.write(diskSession),"Escritura real de love.filesystem")
    local diskLoaded=assert(Save.load())
    diskCheck(diskLoaded.encounter.turn==2 and diskLoaded.encounter.energy==4,"Roundtrip real de guardado")
    diskCheck(Json.encode(diskLoaded.decisions)==Json.encode(diskSession.decisions),"Decisiones reales conservadas en disco")
    diskCheck(Json.encode(diskLoaded.encounter)==Json.encode(diskSession.encounter),"Encuentro exacto conservado en disco")
    diskCheck(Save.writeOptions({volume=.3,muted=true}),"Escribir opciones reales")
    diskCheck(Save.readOptions().muted==true and Save.readOptions().volume==.3,"Opciones reales en disco")
    print("Filesystem: "..diskChecks.." checks passed in isolated test identity.")
    local old={write=Save.write,load=Save.load,exists=Save.exists,readOptions=Save.readOptions,writeOptions=Save.writeOptions}
    local stored
    Save.write=function(session) stored=assert(Json.encode(assert(Save.validate(session)))); return true end
    Save.load=function() return stored and Save.validate(assert(Json.decode(stored))) or nil end
    Save.exists=function() return stored~=nil end
    Save.readOptions=function() return {volume=.6,muted=false} end
    Save.writeOptions=function() return true end
    local App=require("src.app")
    local app=App.new()
    local count=0
    local function check(ok,msg) count=count+1; assert(ok,msg) end
    local function render(name)
        app:update(1)
        app:draw()
        if name then
            local data=app.canvas:newImageData():encode("png")
            local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/"..name..".png","wb"))
            file:write(data:getString()); file:close()
        end
    end
    local function captureCanvas(target,name)
        local data=target:newImageData():encode("png")
        local file=assert(io.open(love.filesystem.getSource().."/tests/artifacts/"..name..".png","wb"))
        file:write(data:getString()); file:close()
    end
    local function clickLabel(label)
        render()
        for _,b in ipairs(app.manager.current.buttons) do
            if b.label==label then
                app:mousepressed(app.offsetX+(b.x+b.w/2)*app.scale,app.offsetY+(b.y+b.h/2)*app.scale,1)
                return
            end
        end
        error("No se encontró el botón "..label)
    end
    render("01-menu")
    clickLabel("Nueva partida")
    check(app.session.checkpoint=="intro","Nueva partida desde menú")
    render("02-dialogue")
    local s=app.manager.current
    s.visible=0; s.elapsed=0
    app:keypressed(Controls.advance[1])
    check(s.dialogue.index==1,"Primera pulsación revela sin saltar")
    app:keypressed(Controls.advance[1])
    check(s.dialogue.index==2,"Segunda pulsación avanza una línea")
    local steps=0
    local captured={}
    while app.session.checkpoint~="phase_complete" do
        steps=steps+1
        assert(steps<250,"Posible bloqueo de progresión")
        render()
        s=app.manager.current
        local cp=app.session.checkpoint
        if Story.scenes[cp] then
            s.elapsed=100; s.visible=10000
            if s.dialogue:isLast() and s.scene.choices then
                render()
                clickLabel(s.scene.choices[1].label)
            else s:advance() end
        elseif Story.encounters[cp] then
            if not captured[cp] then
                render(cp=="day1_tutorial" and "03-cards" or nil)
                captured[cp]=true
            end
            if not s.enc.finished then
                local idx
                for i in ipairs(s.enc.hand) do if Cards.canPlay(s.enc,i) then idx=i; break end end
                -- Incluir la acción gratuita en pausa/carga sobre pantallas reales.
                if cp=="day1_tutorial" and s.enc.turn==1 then s:act() else s:act(idx) end
                local before=assert(Json.encode(s.enc))
                app:overlay("journal"); render()
                app:resume(); render()
                check(Json.encode(app.session.encounter)==before,"Pausa conserva mano, energía y descarte exactos")
                -- La carga normaliza el contexto según la definición narrativa.
                app:continueGame(); render()
                check(Json.encode(app.session.encounter)==before,"Continuar conserva encuentro exacto")
            else s:finish() end
        elseif cp=="hub" then
            if not captured.hub then render("04-hub"); captured.hub=true end
            local all=true
            for _,place in ipairs(Story.locations) do
                if not app.session.events["meeting_"..place.character] then all=false; break end
            end
            clickLabel(all and "Elegir compañía" or "Visitar")
        else error("Pantalla sin manejador: "..cp) end
    end
    check(app.session.events.seal_memory,"Recorrido completo recupera sello")
    check(app.session.route==nil,"No hay romance automático")
    render("05-complete")
    app:overlay("journal"); render("06-journal")
    app:overlay("deck"); render("07-deck")
    app:overlay("options"); render("08-options")
    app:overlay("pause"); render()
    local dimensions=love.graphics.getDimensions
    love.graphics.getDimensions=function() return 1600,900 end
    app:resize()
    check(app.scale==2 and app.offsetX==160 and app.offsetY==90,"Escala entera centrada sin deformar")
    check(app:logical(159,90)==nil and app:logical(1440,90)==nil,"Bandas rechazan clics")
    local lx,ly=app:logical(360,290)
    check(lx==100 and ly==100,"Ratón usa la transformación inversa")
    love.graphics.getDimensions=dimensions
    app:resize()
    -- Comprobar también la ventana real, además de la transformación aislada.
    local originalWidth,originalHeight,originalFlags=love.window.getMode()
    for _,size in ipairs({{640,360},{960,540},{1280,720}}) do
        check(love.window.setMode(size[1],size[2],{resizable=true,minwidth=640,minheight=360}),"Cambiar resolución real")
        app:resize()
        local w,h=love.graphics.getDimensions()
        check(app.scale==math.max(1,math.floor(math.min(w/640,h/360))),"Escala entera en ventana real")
        local x,y=app:logical(app.offsetX+320*app.scale,app.offsetY+180*app.scale)
        check(x==320 and y==180,"Mouse centrado en ventana real")
        render()
    end
    app:keypressed("f11")
    check(love.window.getFullscreen(),"F11 activa pantalla completa real")
    check(app.scale>=1 and app.scale%1==0,"Pantalla completa conserva escala entera")
    render()
    app:keypressed("f11")
    check(not love.window.getFullscreen(),"F11 vuelve a ventana")
    check(love.window.setMode(originalWidth,originalHeight,originalFlags),"Restaurar ventana tras pruebas")
    app:resize()
    for id,scene in pairs(Story.scenes) do
        local resolved=require("src.systems.progression").scene(app.session,id)
        for _,line in ipairs(resolved.lines) do
            check(Font.height(line.text,572,1)<=66,"Diálogo cabe en caja: "..id)
        end
        if scene.choices then
            for _,choice in ipairs(scene.choices) do check(Font.height(choice.label,419,1)<=22,"Elección cabe: "..id) end
        end
    end
    -- Galerías de QA: todas las expresiones y cartas, incluidos capítulos futuros.
    love.graphics.push("all")
    local gallery=love.graphics.newCanvas(640,360)
    love.graphics.setCanvas(gallery); love.graphics.origin(); love.graphics.clear(.1,.15,.23,1)
    local Characters=require("src.data.characters")
    for i,character in ipairs(Characters.list) do
        local x=14+(i-1)*89
        Font.draw(character.shortName,x,10,{maxWidth=84,align="center"})
        for j,expression in ipairs({"neutral","happy","worried","angry"}) do
            app.resources:portrait(character.id,expression,x+10,32+(j-1)*80,1)
            Font.draw(expression,x,96+(j-1)*80,{maxWidth=84,align="center"})
        end
    end
    love.graphics.setCanvas(); captureCanvas(gallery,"09-characters")
    gallery=love.graphics.newCanvas(716,290)
    love.graphics.setCanvas(gallery); love.graphics.origin(); love.graphics.clear(.1,.15,.23,1)
    for i,card in ipairs(require("src.data.cards").list) do
        require("src.ui.card").draw(app.resources,card,10+((i-1)%8)*88,12+math.floor((i-1)/8)*140)
    end
    love.graphics.setCanvas(); captureCanvas(gallery,"10-all-cards")
    love.graphics.pop()
    for key,value in pairs(old) do Save[key]=value end
    print("Integration: "..count.." checks passed; "..steps.." screen steps.")
end
````

## tests/story.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/tests/story.lua`

````lua
-- Pruebas puras Lua: no leen ni escriben la partida real.
local Suite = {}

function Suite.run()
    local Story = require("src.data.story")
    local Characters = require("src.data.characters")
    local Dialogue = require("src.systems.dialogue")
    local Progression = require("src.systems.progression")
    local Events = require("src.systems.events")
    local Relationships = require("src.systems.relationships")
    local Save = require("src.systems.save")
    local Json = require("src.systems.json")
    local Cards = require("src.systems.cards")
    local checked = 0
    local function check(condition, message)
        assert(condition, message)
        checked = checked + 1
    end
    local function roundtrip(session)
        return assert(Save.validate(assert(Json.decode(assert(Json.encode(session))))))
    end
    local function nextTo(session, expected, result)
        local nextId, err = Progression.next(session, session.checkpoint, result)
        check(nextId == expected, "Avance a " .. expected .. ": " .. tostring(err))
        check(session.dialogueIndex == 1 and session.encounter == nil, "Limpiar estado de pantalla anterior")
        return roundtrip(session)
    end

    local session = Save.newSession()
    local expressions = {neutral=true, happy=true, worried=true, angry=true}
    for id in pairs(Story.scenes) do
        local scene = Progression.scene(session, id)
        check(scene and #scene.lines > 0, "Escena no vacía: " .. id)
        local dialogue = Dialogue.new(scene, 1)
        check(dialogue:current() == scene.lines[1], "Primera línea: " .. id)
        for i = 1, #scene.lines - 1 do
            check(not dialogue:advance() and dialogue.index == i + 1, "Una línea por avance: " .. id)
        end
        check(dialogue:isLast() and dialogue:advance() and dialogue:advance(), "Final estable: " .. id)
        check(Dialogue.new(scene, -200).index == 1, "Limitar índice inferior")
        check(Dialogue.new(scene, 200).index == #scene.lines, "Limitar índice superior")
        for _, line in ipairs(scene.lines) do
            check(line.speaker == "narrator" or Characters.byId[line.speaker], "Personaje conocido: " .. id)
            check(expressions[line.expression], "Expresión conocida: " .. id)
            check(not line.text:find("{"), "Sustituciones resueltas: " .. id)
        end
    end
    check(not pcall(Dialogue.new, {lines={}}), "Rechazar escena vacía")
    check(not Progression.visit(session, "roxy"), "No visitar durante introducción")
    check(not Progression.selectCompanion(session, "roxy"), "No elegir compañero antes de las visitas")

    -- Recorrido independiente para cada compañero y cada tipo de resultado.
    for _, companion in ipairs({"sylphiette", "roxy", "eris"}) do
        for _, score in ipairs({0, 8}) do
            session = Save.newSession()
            session = nextTo(session, "day1_tutorial")
            session = nextTo(session, "day1_result", {score=score, trust=9, chemistry=9})
            check(session.relationships[companion].trust == 0, "Tutorial no afecta relaciones ajenas")
            check(session.decisions.outcome_day1_tutorial == (score >= 5 and "success" or "partial"), "Resultado del tutorial")
            session = nextTo(session, "day1_close")
            check(session.unlocked.self_joke, "Desbloquear Reírse de uno mismo")
            session = nextTo(session, "hub")
            check(session.day == 2 and #Progression.availableCompanions(session) == 0, "Inicio de día dos")
            check(not Progression.selectCompanion(session, companion), "No saltar reencuentros")
            for _, character in ipairs({"eris", "sylphiette", "roxy"}) do
                check(Progression.visit(session, character) == "meet_" .. character, "Visita en orden libre")
                local checkpoint = session.checkpoint
                check(not Progression.next(session), "Requerir elección explícita")
                check(not Progression.choose(session, checkpoint, "missing"), "Rechazar elección desconocida")
                local choices = Story.scenes[checkpoint].choices
                local selected = choices[1]
                check(Progression.choose(session, checkpoint, selected.id), "Aplicar elección")
                check(Progression.choose(session, checkpoint, selected.id), "Repetir misma elección es idempotente")
                check(not Progression.choose(session, checkpoint, choices[2].id), "No sustituir elección confirmada")
                check(session.relationships[character].trust == 1, "Puntos de elección una sola vez")
                session = roundtrip(session)
                check(Progression.scene(session, checkpoint).choices == nil, "Al cargar elección confirmada se permite continuar")
                check(Progression.scene(session, checkpoint).lines[#Story.scenes[checkpoint].lines], "Conservar líneas al ocultar opciones")
                session = nextTo(session, "encounter_" .. character)
                local context = Progression.encounter(session, session.checkpoint)
                session.encounter = Cards.new(session.deck, context, function(n) return n end)
                Cards.pass(session.encounter)
                local saved = roundtrip(session)
                check(saved.encounter and saved.encounter.turn == 2, "Restaurar encuentro a mitad")
                check(saved.encounter.context.kind == context.kind and saved.encounter.context.character == character,
                    "Guardar no cambia contexto del encuentro")
                session = nextTo(session, "result_" .. character, {score=score, trust=3, chemistry=2})
                check(session.relationships[character].trust == 4, "Aplicar deltas al completar encuentro")
                check(session.relationships[character].chemistry == 2, "Aplicar química del encuentro")
                check(not Progression.next(session, "encounter_" .. character, {score=8, trust=3}), "No repetir resultado desde pantalla antigua")
                local resultScene = Progression.scene(session, session.checkpoint)
                check(resultScene.lines[1].text == Story.scenes[session.checkpoint].resultLines[score >= 5 and "success" or "partial"].text,
                    "Diálogo refleja éxito o avance parcial")
                session = nextTo(session, "hub")
                check(session.relationships[character].events.reunion, "Registrar evento del personaje")
                check(not Progression.visit(session, character), "No repetir reencuentro terminado")
            end
            check(session.unlocked.remember and #Progression.availableCompanions(session) == 3, "Desbloquear recuerdo y salida a ruinas")
            check(not Progression.selectCompanion(session, "unknown"), "Rechazar compañero desconocido")
            check(Progression.selectCompanion(session, companion) == "seal_intro", "Elegir compañero explícitamente")
            check(session.decisions.companion == companion and session.route == nil, "Compañero todavía no es ruta romántica")
            session = roundtrip(session)
            local seal = Progression.scene(session, "seal_intro")
            check(seal.lines[3].speaker == companion and seal.lines[3].text == Story.companionAdvice[companion], "Variante del consejo del compañero")
            session = nextTo(session, "seal_encounter")
            local context = Progression.encounter(session, "seal_encounter")
            check(context.character == companion and context.kind == "magic", "Contexto mágico con compañero")
            session.encounter = Cards.new(session.deck, context, function(n) return n end)
            Cards.pass(session.encounter)
            session = roundtrip(session)
            check(session.encounter and session.encounter.context.kind == "magic", "Conservar contexto mágico del sello al guardar")
            session = nextTo(session, "seal_result", {score=score, trust=1, chemistry=0})
            local result = Progression.scene(session, "seal_result")
            check(result.lines[3].speaker == companion and result.lines[3].text == Story.companionMemory[companion], "Variante del recuerdo del compañero")
            session = nextTo(session, "day2_close")
            check(session.events.seal_memory and session.relationships[companion].events.memory_seal, "Obtener sello incluso con cero puntos")
            check(session.relationships[companion].trust == 6, "Puntos totales del compañero")
            check(not Events.apply(session, "seal_memory", {character=companion, trust=8}), "Sello idempotente")
            check(session.relationships[companion].trust == 6, "No duplicar puntos del sello")
            session = nextTo(session, "phase_complete")
            check(session.events.phase1_complete and session.day == 2, "Terminar contenido exactamente en día dos")
            check(Relationships.ending(session.relationships, session.route, session.decisions) == "independent", "No asignar romance al terminar Fase 1")
        end
    end

    local invalid = Save.validate({version=1, checkpoint="missing", dialogueIndex=999})
    check(invalid and invalid.checkpoint == "intro", "Recuperar checkpoint desconocido")
    check(Dialogue.new(Progression.scene(invalid, invalid.checkpoint), invalid.dialogueIndex):current(), "Índice inválido no bloquea diálogo")
    local partial = Save.validate({version=1, checkpoint="seal_encounter", events={companion_selected=true}})
    check(partial and partial.checkpoint == "hub" and not partial.decisions.companion, "Volver al mapa si se perdió el compañero")
    check(not partial.events.companion_selected, "Permitir nueva selección tras guardado incompleto")
    partial.events.meeting_sylphiette, partial.events.meeting_roxy, partial.events.meeting_eris = true, true, true
    check(Progression.selectCompanion(partial, "eris") == "seal_intro" and partial.decisions.companion == "eris", "Reparar elección de compañero")
    local lostChoice = Save.newSession()
    lostChoice.day, lostChoice.checkpoint = 2, "meet_roxy"
    lostChoice.events.choice_meet_roxy = true
    lostChoice.relationships.roxy.trust = 4
    check(Progression.choose(lostChoice, "meet_roxy", "compare_notes"), "Recuperar decisión perdida con evento persistido")
    check(lostChoice.relationships.roxy.trust == 4, "Recuperar decisión sin volver a aplicar puntos")
    check(Progression.next(lostChoice) == "encounter_roxy", "Continuar después de recuperar elección")

    -- A completed encounter can be saved before confirming its result. The
    -- restored actions, including the free action, grant their effects once.
    local resumed=Save.newSession()
    resumed.day,resumed.checkpoint=2,"meet_roxy"
    check(Progression.choose(resumed,"meet_roxy","compare_notes"),"Elegir antes del encuentro real")
    check(Progression.next(resumed)=="encounter_roxy","Abrir encuentro real")
    resumed.encounter=Cards.new(resumed.deck,{kind="investigation",character="roxy"},function(n) return n end)
    Cards.play(resumed.encounter,2)
    resumed=roundtrip(resumed)
    Cards.pass(resumed.encounter)
    resumed=roundtrip(resumed)
    Cards.play(resumed.encounter,2)
    resumed=roundtrip(resumed)
    check(resumed.encounter.finished and #resumed.encounter.log==3,"Cargar encuentro finalizado antes del resultado")
    check(resumed.relationships.roxy.trust==1 and resumed.relationships.roxy.chemistry==0,
        "Guardar acciones no aplica todavía los vínculos")
    local result={score=resumed.encounter.score,trust=0,chemistry=0}
    for _,entry in ipairs(resumed.encounter.log) do
        result.trust=result.trust+entry.trust
        result.chemistry=result.chemistry+entry.chemistry
    end
    check(Progression.next(resumed,"encounter_roxy",result)=="result_roxy","Confirmar resultado restaurado")
    check(resumed.relationships.roxy.trust==1+result.trust and resumed.relationships.roxy.chemistry==result.chemistry,
        "Aplicar exactamente los vínculos registrados")
    resumed=roundtrip(resumed)
    local afterResult=assert(Json.encode(resumed.relationships))
    check(not Progression.next(resumed,"encounter_roxy",result),"Rechazar confirmación repetida tras cargar")
    check(Json.encode(resumed.relationships)==afterResult,"Confirmación repetida no duplica vínculos")
    check(Progression.next(resumed)=="hub" and resumed.events.meeting_roxy,"Volver al mapa tras encuentro restaurado")

    print("OK: " .. checked .. " comprobaciones de narrativa, progresión y carga intermedia.")
    return checked
end

return Suite
````

## tests/ui.lua

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/tests/ui.lua`

````lua
-- Ejecutar dentro de LÖVE. Usa las pantallas reales con guardado en memoria.
local Suite={}

function Suite.run()
    local CardView=require("src.ui.card")
    local Font=require("src.ui.font")
    local Data=require("src.data.cards")
    local Cards=require("src.systems.cards")
    local Save=require("src.systems.save")
    local Json=require("src.systems.json")
    local checked=0
    local function check(ok,message) assert(ok,message); checked=checked+1 end
    local function overlaps(a,b)
        return a.x<b.x+b.w and a.x+a.w>b.x and a.y<b.y+b.h and a.y+a.h>b.y
    end

    for name,region in pairs(CardView.regions) do
        check(region.x>=6 and region.y>=6 and region.x+region.w<=74 and region.y+region.h<=106,
            "Región dentro del margen del marco: "..name)
        for other,otherRegion in pairs(CardView.regions) do
            if name<other then check(not overlaps(region,otherRegion),"Regiones separadas: "..name.."/"..other) end
        end
    end
    for _,card in ipairs(Data.list) do
        for key,label in pairs(CardView.labels(card)) do
            local region=CardView.regions[key]
            check(Font.height(label,region.w)<=region.h,"Texto cabe en carta: "..card.id.."/"..key)
            for _,line in ipairs(Font.wrap(label,region.w)) do
                check(Font.width(line)<=region.w,"Línea respeta margen: "..card.id.."/"..key)
            end
        end
        check(Font.height(card.description,173)<=64,"Descripción cabe en panel del encuentro: "..card.id)
        check(Font.height(Data.categories[card.category],173)<=22,"Categoría completa cabe en detalles: "..card.id)
    end

    -- Observe the actual draw calls, including the individual bitmap glyph
    -- pixels. A clipping rectangle cannot hide an overflowing label here.
    local originalDraw,originalRectangle=Font.draw,love.graphics.rectangle
    local ok,err=xpcall(function()
        for _,card in ipairs(Data.list) do
            local labels=CardView.labels(card)
            local order,bounds={},{}
            local active
            local function record(kind) order[#order+1]=kind end
            local resources={
                cardBase=function(_,x,y,scale)
                    check(x==20 and y==10 and scale==1,"Pergamino en coordenadas enteras")
                    record("base")
                end,
                cardFrame=function(_,category,x,y,scale)
                    check(category==card.category and x==20 and y==10 and scale==1,"Marco corresponde a categoría")
                    record("frame")
                end,
                icon=function(_,id,x,y,scale)
                    check(id==card.id and x==48 and y==75 and scale==1,"Icono propio sin escala fraccionaria")
                    record("icon")
                end,
            }
            Font.draw=function(text,x,y,opts)
                local key
                for candidate,label in pairs(labels) do if text==label then key=candidate end end
                check(key~=nil,"Texto reconocido de la carta")
                local region=CardView.regions[key]
                check(x==20+region.x and y==10+region.y,"Texto colocado en su región")
                active={x=x,y=y,w=region.w,h=region.h,inside=true,pixels=0}
                bounds[key]=active
                record(key)
                local height=originalDraw(text,x,y,opts)
                active=nil
                return height
            end
            love.graphics.rectangle=function(mode,x,y,w,h,...)
                if active then
                    active.pixels=active.pixels+1
                    active.inside=active.inside and x>=active.x and y>=active.y
                        and x+w<=active.x+active.w and y+h<=active.y+active.h
                        and x%1==0 and y%1==0 and w%1==0 and h%1==0
                end
            end
            CardView.draw(resources,card,20.75,10.75)
            for key,box in pairs(bounds) do
                check(box.inside and box.pixels>0,"Píxeles del texto dentro de región: "..card.id.."/"..key)
            end
            local index={}; for i,kind in ipairs(order) do index[kind]=i end
            check(index.base<index.frame and index.frame<index.name and index.name<index.icon and index.icon<index.cost,
                "Capas: pergamino, marco, nombre, icono, coste: "..card.id)
        end
    end,debug.traceback)
    Font.draw,love.graphics.rectangle=originalDraw,originalRectangle
    assert(ok,err)

    local old={write=Save.write,load=Save.load,exists=Save.exists,readOptions=Save.readOptions,writeOptions=Save.writeOptions}
    local volume=love.audio.getVolume()
    local stored
    Save.write=function(session) stored=assert(Json.encode(assert(Save.validate(session)))); return true end
    Save.load=function() return stored and Save.validate(assert(Json.decode(stored))) end
    Save.exists=function() return stored~=nil end
    Save.readOptions=function() return {volume=.6,muted=false} end
    Save.writeOptions=function() return true end
    ok,err=xpcall(function()
        local app=require("src.app").new()
        local mx,my
        app.mouse=function() return mx,my end
        local function render() app:update(.3); app:draw() end
        local function click(x,y)
            app:mousepressed(app.offsetX+x*app.scale,app.offsetY+y*app.scale,1)
        end
        render()
        app:keypressed("tab")
        app:keypressed("down")
        check(app.manager.current.buttons[app.manager.current.keyboardFocus].label=="Opciones",
            "Teclado del menú salta Continuar deshabilitado")
        app:keypressed("return")
        check(app.manager.current.kind=="options","Enter abre opción enfocada")
        render()
        app:keypressed("escape")
        render()
        app:keypressed("tab")
        app:keypressed("return")
        check(app.session and app.session.checkpoint=="intro","Nueva partida accesible por teclado")
        app:keypressed("return")
        click(100,300)
        check(app.session.dialogueIndex==1 and app.manager.current.visible==0,
            "Entrada repetida durante transición no salta texto nuevo")

        app.session=Save.newSession()
        app.session.day,app.session.checkpoint=2,"encounter_roxy"
        -- Two legal cards costing two leave the third turn with no energy.
        app.session.deck[9]="combined_spell"
        app.session.unlocked.combined_spell=true
        app.session.encounter=Cards.new(app.session.deck,{kind="investigation",character="roxy"},function(n) return n end)
        app:resume()
        mx,my=341,220
        render()
        local screen=app.manager.current
        check(screen.selected==3,"Ratón selecciona tercera carta para ver detalles")
        app:keypressed("left")
        app:draw()
        check(screen.selected==2,"Ratón inmóvil no deshace selección de teclado")
        app:keypressed("left")
        app:keypressed("return")
        check(screen.enc.turn==2 and screen.enc.energy==2 and screen.enc.discard[1]=="earth_barrier",
            "Enter juega carta seleccionada una vez")
        app:keypressed("return")
        click(153,209)
        check(screen.enc.turn==2 and #screen.enc.discard==1,"Doble entrada de teclado/ratón no juega carta recién robada")
        render()
        click(153,209)
        check(screen.enc.turn==3 and screen.enc.energy==0 and screen.enc.discard[2]=="combined_spell",
            "Ratón usa hitbox de carta y respeta su coste")
        render()
        local textSeen={}
        Font.draw=function(text,...)
            textSeen[text]=true
            return originalDraw(text,...)
        end
        app:draw()
        Font.draw=originalDraw
        check(textSeen["[1] NO DISP."] and textSeen["No hay energía suficiente."],
            "Carta sin energía informa disponibilidad y motivo")
        local before=assert(Json.encode(screen.enc))
        click(153,209)
        app:keypressed("return")
        check(Json.encode(screen.enc)==before,"Carta deshabilitada no consume turno ni cambia pilas")
        app:keypressed("right")
        app:keypressed("right")
        app:keypressed("return")
        check(screen.enc.finished and screen.enc.energy==0 and screen.enc.discard[3]=="admit_error",
            "Carta de coste cero disponible al agotarse energía")
        app:overlay("deck")
        mx,my=nil,nil
        render()
        screen=app.manager.current
        app:keypressed("tab")
        app:keypressed("down")
        app:keypressed("down")
        app:keypressed("return")
        check(screen.selected==2,"Colección permite inspeccionar cartas con teclado")
        app:draw()
        click(40,79+15*16+7)
        check(screen.selected==16,"Colección permite inspeccionar una carta futura bloqueada")
        app:draw()
    end,debug.traceback)
    Font.draw=originalDraw
    for key,value in pairs(old) do Save[key]=value end
    love.audio.setVolume(volume)
    assert(ok,err)
    print("OK: "..checked.." comprobaciones de composición de cartas, márgenes e interacción.")
    return checked
end

return Suite
````

## tools/export_source.py

Ruta exacta: `C:/Users/gegdg/Documents/.UVG/Anio6/SegundoSemestre/GameEngine/DateSim/tools/export_source.py`

````python
"""Genera una entrega con la ruta y el contenido íntegro de cada archivo de texto."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
destination = root / "docs" / "CODIGO_COMPLETO.md"
extensions = {".lua": "lua", ".ps1": "powershell", ".py": "python", ".md": "markdown"}
files = sorted(p for p in root.rglob("*") if p.is_file()
               and (p.suffix in extensions or p.name in {".gitignore", ".gitkeep"}) and p != destination
               and not any(part in {".git", "dist", ".codex", ".agents", "sprite_sources", "artifacts"} for part in p.relative_to(root).parts))
chunks = ["# Entrega completa de la Fase 1\n\n"
          "Este documento contiene las rutas y el contenido completo de los archivos de texto del proyecto. "
          "Los archivos reales ya están creados; no es necesario copiarlos desde aquí. "
          "Los PNG del juego están en assets/ y los editables ASE en sprite_sources/; "
          "los archivos binarios no se incluyen en este documento. "
          "La Fase 1 comprende los días uno y dos; los capítulos restantes siguen pendientes.\n\n"
          f"Raíz del proyecto: `{root.as_posix()}`\n"]
for path in files:
    content = path.read_text(encoding="utf-8-sig")
    fence = "`" * max(4, max((len(s) for s in content.split() if set(s) == {"`"}), default=0) + 1)
    chunks.append(f"\n## {path.relative_to(root).as_posix()}\n\nRuta exacta: `{path.as_posix()}`\n\n"
                  f"{fence}{extensions.get(path.suffix, 'text')}\n{content.rstrip()}\n{fence}\n")
destination.parent.mkdir(exist_ok=True)
destination.write_text("".join(chunks), encoding="utf-8")
print(f"Exportados {len(files)} archivos: {destination}")
````
