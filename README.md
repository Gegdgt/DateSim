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

Ventana inicial 1280×720. Canvas lógico 640×360, filtro `nearest`, escalado entero y centrado con bandas cuando el tamaño de la ventana no coincide. F11 alterna pantalla completa. Fondos provisionales a 320×180 y retratos de 64×64 en hojas de 256×64 con cuatro expresiones.

## Controles

| Acción | Control |
| --- | --- |
| Seleccionar botones y cartas | Clic izquierdo |
| Mostrar texto completo / siguiente fragmento | Clic, Enter o Espacio |
| Jugar carta de la mano | Clic o teclas 1, 2, 3 |
| Acción gratuita | Botón «Tomar un respiro» o P |
| Diario / colección | J / M |
| Pausa / volver | Esc |
| Guardar | F5 |
| Pantalla completa | F11 |

Una pulsación revela el texto en curso; la siguiente avanza una sola línea. Se ignora la repetición del teclado. Las decisiones narrativas se eligen con el mouse. Al terminar tres acciones, «Ver resultado» confirma los efectos del encuentro sobre las relaciones.

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

Para comprobar PNG opcionales, consulta [assets/README.md](assets/README.md). Una imagen ausente, ilegible o de tamaño incorrecto se sustituye por pixel art provisional.

## Arquitectura y ampliación

| Archivo / carpeta | Responsabilidad y contenido editable |
| --- | --- |
| `main.lua`, `conf.lua` | Callbacks de LÖVE, resolución, ventana, identidad |
| `src/app.lua`, `src/core/state_manager.lua` | Pantallas, coordinación, transiciones, escala y guardado |
| `src/data/story.lua` | Diálogos, elecciones, lugares y encuentros |
| `src/data/cards.lua` | Las 16 cartas, costes, iconos, condiciones, efectos, mazo inicial |
| `src/data/characters.lua` | Personajes, nombres, temas, colores e identificadores |
| `src/systems/progression.lua` | Conexiones entre escenas, días, visitas y acompañante |
| `src/systems/events.lua` | Aplicación única de decisiones, desbloqueos y eventos |
| `src/systems/dialogue.lua` | Índice de diálogo y avance |
| `src/systems/cards.lua` | Reglas, barajado, previsión, juego y restauración |
| `src/systems/relationships.lua` | Vínculos, límites y evaluación de finales |
| `src/systems/save.lua`, `json.lua` | Esquema validado, lectura/escritura y respaldo |
| `src/systems/resources.lua` | Carga PNG y dibujos provisionales |
| `src/screens/` | Menú, diálogo, mapa, cartas, pantallas auxiliares y resumen |
| `src/ui/` | Paleta, fuente bitmap original, marcos, botones, barras e hitboxes |
| `src/config/controls.lua` | Configuración de atajos |
| `tests/` | Pruebas de lógica y recorrido real de pantallas |

Para añadir líneas a una escena, edita solo `story.lua`. Una nueva carta se define en `cards.lua`; los efectos existentes no requieren cambios del motor. Un capítulo nuevo requiere sus tablas, transiciones en `progression.lua`, checkpoints reconocidos en `save.lua` y pruebas de progreso. Los sprites se reemplazan sin cambiar diálogos ni pantallas. Las expresiones usan `neutral=0`, `happy=1`, `worried=2`, `angry=3`, de izquierda a derecha en la hoja. Las hojas del formato anterior no cumplen el tamaño esperado y se sustituyen por el recurso provisional hasta exportarlas al formato nuevo.

El contenido completo de cada archivo y su ruta exacta están en [docs/CODIGO_COMPLETO.md](docs/CODIGO_COMPLETO.md). Se regenera con `python tools/export_source.py`. Detalle de APIs en [docs/SISTEMAS.md](docs/SISTEMAS.md).

## Fases pendientes

- **Fase 2:** días tres y cuatro, desafíos adicionales, editor de mazo e integración de cartas desbloqueadas en mazos personalizados.
- **Fase 3:** elección de ruta, conflictos de días cinco y seis, escenas de confesión y los siete desenlaces del día siete.
- **Fase 4:** sprites y archivos `.ase` definitivos, audio original/licenciado, pulido, pruebas de la historia completa y distribución autónoma para Windows.

Los recursos actuales son pixel art provisional dibujado por el proyecto. No se entregan sprites definitivos ni se presentan archivos generados como exportaciones de LibreSprite.
