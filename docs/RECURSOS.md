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
