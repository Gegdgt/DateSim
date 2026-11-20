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
