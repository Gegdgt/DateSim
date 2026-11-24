# Mushoku Tensei: Las Cartas del Destino

## Sistemas de UI

### 1. Introducción a la entrega

Programé tres interfaces para la campaña de *Las Cartas del Destino*. El HUD guía a Rudy por la casa Greyrat, la conversación deja leer la frase de cada carta antes de jugarla y el combate anuncia la próxima acción enemiga. Preparé un menú que abre esas mismas pantallas en situaciones concretas para que puedas probarlas desde el primer minuto. [Guía de la entrega](docs/ENTREGA_UI.md).

### 2. Cómo ejecutar la demostración

Usa **LÖVE 11.5**, que incluye LuaJIT. [Descargar LÖVE 11.5](https://github.com/love2d/love/releases/tag/11.5).

Clona la rama de la entrega en PowerShell. [Rama entrega/ui-system en GitHub](https://github.com/Gegdgt/DateSim/tree/entrega/ui-system).

```powershell
git clone --branch entrega/ui-system --single-branch https://github.com/Gegdgt/DateSim.git
cd DateSim
```

Desde la carpeta `DateSim`, abre el menú **Sistemas de interfaz**.

```powershell
& 'C:\Program Files\LOVE\love.exe' . --demo-ui
```

Si LÖVE está en el `PATH`, también puedes usar `love . --demo-ui`. Elige con **Tab** y **Enter** o haz clic. **F9** te devuelve al menú de la demostración desde cualquier escena y descarta el progreso del ejercicio.

Cada ejercicio empieza con una sesión temporal en memoria. Las preferencias de la demo usan la identidad `cartas_del_destino_demo_ui` y `App:save()` omite la escritura del guardado de campaña. **F5** muestra un aviso de sesión temporal. [Arranque y callbacks de LÖVE](main.lua) · [Menú y sesiones de demostración](src/demos/ui.lua) · [Guardado y teclas globales](src/app.lua).

### 3. UI 1: HUD de exploración

Elige **HUD de exploración · Patio de Eris**. En la campaña, el mismo HUD aparece el Día 1, cuando Rudy despierta en el dormitorio de Eris después del sueño con Hitogami. Puse arriba el nombre del mapa, el día y el objetivo principal. La franja inferior indica los controles y, al acercarte a un personaje u objeto, aparece el indicador **E** con la acción disponible.

En el patio, camina con **WASD** o las **flechas** y mantén **Shift** para correr. Acércate a Eris para ver el aviso de interacción y pulsa **E** para hablar con ella. **M** abre el minimapa con la posición de Rudy, personajes, accesos, puntos de interés y lugares visitados. **J** abre el diario de misiones, donde puedes revisar el objetivo del día, el progreso de las interacciones y las tareas completadas.

- En **Setup**, `Exploration.new(app)` toma el mapa y la posición de Rudy de `app.session.exploration` e inicializa la animación y la caché de fotogramas de los sprites. [Pantalla de exploración](src/screens/exploration.lua).
- En **Update**, `s:update(dt)` lee las teclas de movimiento y actualiza la marcha o la carrera. El sistema de exploración resuelve colisiones y detecta los portales. `s:keypressed(key)` atiende la interacción y abre el minimapa o el diario. [Pantalla](src/screens/exploration.lua) · [Sistema de exploración](src/systems/exploration.lua).
- En **Render**, `s:drawWorld()` calcula la cámara que sigue a Rudy y aplica su desplazamiento al mapa, los personajes y los indicadores del mundo. Tras restaurar la transformación, `s:draw()` pinta el día, el mapa, el objetivo y los controles en posiciones fijas del canvas. El diario se dibuja como panel sobre la escena. [Pantalla](src/screens/exploration.lua) · [Diario de objetivos](src/ui/objective_journal.lua).

### 4. UI 2: Conversaciones con cartas

Elige **Conversación con cartas · Sylphie**. También puedes abrir **Tutorial social · Nanahoshi** para ver la práctica guiada. En la historia, Rudy perdió la voz y se comunica con las cartas encantadas de Nanahoshi. Habilité las actividades matrimoniales después de la entrega de las cartas y la introducción. De día puedes pulsar **E** junto a **Sylphie** en la sala de la casa Greyrat, **Eris** en el patio de entrenamiento o **Roxy** en la biblioteca de Ranoa.

Haz clic en una actividad o selecciónala con **1–3** o las flechas y confirma con **Enter**. En la introducción usa **Preparar las cartas** o **Enter** para ver el barajado y el reparto. Junto al retrato y el diálogo aparecen tres cartas compatibles del mazo equipado con sus marcos, iconos y costes de energía social.

Elige una carta con **1–3**, las flechas o un clic para leer **«Rudy dirá»**. Confirma con **Enter** o **Decir la frase** y observa la reacción y los cambios en las barras de **Amor** y **Confianza**. Pulsa **Continuar** para reponer la carta si quedan turnos y cartas en el mazo. Puedes cancelar la vista previa con **Esc** o cerrar la actividad con **P** desde la mano. En el tutorial de Nanahoshi las barras muestran **Confianza** e **Interés**.

- En **Setup**, `View.new(app, wife)` prepara la actividad y las barras a partir de la esposa y del estado de la jornada. `Encounter.new(app)` lee el encuentro del punto de la historia y prepara el mazo y los pasos guiados de Nanahoshi en el tutorial. [Actividades matrimoniales](src/screens/wife_activities.lua) · [Pantalla de encuentros](src/screens/encounter.lua).
- En **Update**, las dos pantallas reciben la selección y la confirmación por teclado o clic. `s:update(dt)` avanza el reparto, la jugada y la reposición cuando quedan turnos y cartas. En las actividades, el sistema cobra la energía al confirmar y registra el cambio de relación cuando aparece la reacción. [Reglas de actividades](src/systems/wife_activities.lua) · [Lógica de cartas del encuentro](src/systems/cards.lua).
- En **Render**, `s:draw()` compone el diálogo, el retrato, la reacción y la vista previa. Reutilicé los componentes de mano y cartas para animar el barajado, el uso y la reposición. Las barras leen los valores de la sesión y muestran sus cambios con signo. [Mano social](src/ui/social_hand.lua) · [Dibujo de cartas](src/ui/card.lua) · [Barras de relación](src/ui/relationship_bars.lua).

### 5. UI 3: Combate

Elige **Combate libre · Anomalía** y pulsa **Enter** en la introducción táctica. En la campaña usé esta interfaz para el combate guiado contra la anomalía de maná en el laboratorio de Nanahoshi el Día 1, el duelo de entrenamiento con Eris del Día 5 y encuentros narrativos como el de Badigadi. [Primer combate](src/data/chapters/day1.lua) · [Entrenamiento con Eris](src/data/chapters/day5.lua) · [Desenlace de combate](src/data/chapters/day7.lua).

El HUD muestra los PV y el escudo de Rudy y del enemigo, la energía y las acciones que quedan, la mano de combate y la intención enemiga. Selecciona una carta con **1–3**, las flechas o un clic para revisar su coste y confirma con **Enter** o **Jugar**. Al atacar, verás la animación del golpe y cómo baja la vida del enemigo. Usa **D** para defenderte, **V** para esquivar y **E** para terminar el turno. El resultado muestra **Victoria** o **Derrota**. Para ver la derrota en otro intento, deja que la anomalía actúe durante varios turnos sin atacarla. Tras perder puedes reintentar o regresar al punto seguro. Tras una victoria en la demo, **Enter** vuelve a su menú.

- Para el **Setup**, la demo llama a `App:startPractice("free")`, que equipa las técnicas iniciales. `CombatScreen.new(app, definition)` prepara la interfaz y crea o restaura el combate con el enemigo, el mazo y la energía de la sesión. [Aplicación](src/app.lua) · [Pantalla de combate](src/screens/combat.lua).
- En **Update**, la pantalla llama a reglas como `Combat.play()`, `Combat.basic()` y `Combat.endTurn()` para validar los comandos y resolver escudos, daño e intención. `s:update(dt)` avanza la animación y ajusta las barras de vida al resultado. [Pantalla](src/screens/combat.lua) · [Reglas de combate](src/systems/combat.lua).
- En **Render**, `s:draw()` reúne el HUD, los personajes, las cartas, las animaciones y el panel de resultado. Usa widgets compartidos para los paneles, las barras de vida y energía, y los botones. [Pantalla](src/screens/combat.lua) · [Widgets](src/ui/widgets.lua).

### 6. Arquitectura y Setup → Update → Render

Las tres interfaces usan el mismo ciclo de LÖVE y el canvas lógico de 640 × 360. **Setup → Update → Render** son las etapas del ejercicio. En Lua las implementé con los constructores `new(...)` y los métodos `update(dt)` y `draw()` que usa el ciclo del juego.

- LÖVE llama a `love.load`, `love.update` y `love.draw` y envía los eventos de teclado y ratón a la aplicación. [main.lua](main.lua).
- La aplicación comparte `app.session` con la pantalla activa. De ahí salen el día y el mapa del HUD, el mazo y las relaciones de las conversaciones y el estado de la batalla. [src/app.lua](src/app.lua).
- El gestor activa pantallas, aplica transiciones y llama a la actualización, el dibujo y los manejadores de entrada de la pantalla activa. [src/core/state_manager.lua](src/core/state_manager.lua).
- Las pantallas reciben la entrada y presentan el estado al jugador. [src/screens/](src/screens/).
- Los sistemas resuelven las reglas de movimiento, cartas, relaciones y combate. [src/systems/](src/systems/).
- Las definiciones de mapas, capítulos, cartas y enemigos viven en tablas Lua. [src/data/](src/data/).
- Las pantallas comparten componentes de dibujo como paneles, cartas y barras. [src/ui/](src/ui/).

### 7. Limpieza de Breakout

Revisé los archivos versionados, los nombres de los recursos y las referencias en el código de esta rama. La revisión encontró cero módulos o recursos obsoletos de Breakout. *Las Cartas del Destino* carga sus propios mapas, retratos, cartas y fondos. La función `brickWall()` que apareció en la búsqueda dibuja paredes para esos fondos. [Catálogo de recursos](src/data/assets.lua) · [Recursos gráficos del juego](src/systems/resources.lua).

### 8. Pruebas

Desde la raíz del proyecto, `probar.ps1` usa `lovec.exe` de LÖVE 11.5 para ejecutar las pruebas con identidades de guardado separadas. En PowerShell puedes reproducir las dos pruebas de UI y luego ejecutar la suite general.

```powershell
$env:DATESIM_TEST_MODULE = 'demo_ui'
.\probar.ps1
$env:DATESIM_TEST_MODULE = 'war_ui'
.\probar.ps1
Remove-Item Env:DATESIM_TEST_MODULE
$env:DATESIM_TEST_GROUP = 'entrega_ui'
.\probar.ps1
Remove-Item Env:DATESIM_TEST_GROUP
```

- **`demo_ui`** pasó **22 comprobaciones** y generó **8 capturas** en `tests/artifacts/demo-ui-*.png`. Comprueba el encabezado fijo del HUD, la apertura del minimapa y el diario, el reparto de tres cartas reales y el cambio de relación. En combate verifica el escudo, la intención enemiga, el daño y los dos desenlaces. También ejercita teclado y ratón, el regreso con **F9** y el aislamiento del guardado al pulsar **F5** y cerrar el juego. [Prueba `demo_ui`](tests/demo_ui.lua).
- **`war_ui`** pasó **10 comprobaciones** y generó **12 capturas** en `tests/artifacts/war-*.png`. Revisa la preparación, las barras de PV al recibir daño, los apoyos, sus efectos al recargar, las fases de Badigadi y los resultados del combate. [Prueba `war_ui`](tests/war_ui.lua).
- La **suite general** terminó con código 0 y `ALL TESTS PASSED`. Incluyó 40 rutas completas de la campaña con los cinco finales y nueve recorridos de integración de exploración. [Ejecutor de la suite](tests/run.lua).

Consulta el recorrido de revisión y el registro de pruebas de la rama. [Guía de la entrega](docs/ENTREGA_UI.md#pruebas) · [Script de pruebas](probar.ps1).

### 9. Tabla de cumplimiento

| Requisito | Dónde se demuestra | Código |
| --- | --- | --- |
| Limpieza de Breakout | Revisión de los archivos de la rama y del catálogo de recursos del juego. | [Catálogo](src/data/assets.lua) · [Cargador](src/systems/resources.lua) |
| Tres sistemas diferentes de UI | Patio de Eris, conversación con Sylphie y combate contra la anomalía, accesibles desde el menú de la demo. | [Menú de demostración](src/demos/ui.lua) |
| Setup | Entrar al patio, abrir una actividad o iniciar el combate prepara el estado de la pantalla. | [Exploración](src/screens/exploration.lua) · [Actividades](src/screens/wife_activities.lua) · [Encuentro](src/screens/encounter.lua) · [Combate](src/screens/combat.lua) |
| Update | Movimiento y atajos, selección y reposición de cartas, acciones y animaciones de combate. | [Exploración](src/screens/exploration.lua) · [Actividades](src/screens/wife_activities.lua) · [Combate](src/screens/combat.lua) |
| Render | HUD y diario, mano y barras de relación, y paneles de batalla. | [Diario](src/ui/objective_journal.lua) · [Mano social](src/ui/social_hand.lua) · [Widgets](src/ui/widgets.lua) |
| Integración con el estado del juego | El día y el mapa salen de la sesión, las cartas cambian relaciones y el combate actualiza PV, escudo y resultado. | [Aplicación](src/app.lua) · [Actividades](src/systems/wife_activities.lua) · [Combate](src/systems/combat.lua) |
| HUD independiente de la cámara | Camina por el patio y observa el encabezado fijo mientras se desplaza el mapa. | [Render de exploración](src/screens/exploration.lua) · [Prueba de la demo](tests/demo_ui.lua) |
| Interacción mediante teclado y mouse | Abre las escenas con **Tab** y **Enter** o clic, y selecciona cartas y acciones con teclado o ratón. | [Callbacks](main.lua) · [Botones y foco](src/ui/screen.lua) · [Prueba de la demo](tests/demo_ui.lua) |
| Evidencia visual | Hay capturas de campaña en el portafolio. Las de la demo se generan en local y queda pendiente agregar el recorrido grabado de la demo. | [Generación de capturas](tests/demo_ui.lua) · [Evidencias](#10-evidencias-necesarias-y-enlaces-al-portafolio) |
| Enlaces al código | Cada interfaz enlaza sus funciones, sus reglas y sus componentes en esta rama. | [HUD](src/screens/exploration.lua) · [Conversación](src/screens/wife_activities.lua) · [Combate](src/screens/combat.lua) |
| Participación individual | Desarrollo e integración a cargo de una sola persona. | [Participación individual](#11-participación-individual) |
| Accesibilidad del portafolio | El portafolio se puede abrir en GitHub desde esta rama. | [Sistemas de UI en el portafolio](portafolio.md#sistemas-de-ui) |

### 10. Evidencias necesarias y enlaces al portafolio

El portafolio publicado en este repositorio recoge capturas de la campaña. Entre ellas se ven el HUD del patio, el reparto de Sylphie y la interfaz de la anomalía en el tutorial. [Sistemas de UI en el portafolio](portafolio.md#sistemas-de-ui) · [Patio de Eris](<captures/17. Ubicacion de Eris.png>) · [Reparto de Sylphie](<captures/25. Inicio de Juego Sylphie.png>) · [Tutorial de combate](<captures/9. Tutorial de ataque.png>) · [Video de gameplay](<gameplay/Mushoku Tensei_ Las Cartas del Destino.mp4>).

Para documentar el recorrido de `--demo-ui`, estas son las tomas que necesito reunir en el portafolio. La prueba `demo_ui` genera en `tests/artifacts/` las capturas `demo-ui-hud.png`, `demo-ui-social.png` y `demo-ui-combate.png`.

| Interfaz | Captura | Video |
| --- | --- | --- |
| HUD de exploración | Rudy en el patio de Eris con el HUD visible. | Caminar, correr con **Shift**, abrir el minimapa con **M** y consultar el diario con **J**. |
| Conversación con cartas | Sylphie con su retrato, las tres cartas visibles y las barras de **Amor** y **Confianza**. | Elegir una actividad, mostrar el barajado, seleccionar una carta, confirmar la frase de Rudy y mostrar la reacción y los cambios de relación. |
| Combate | Anomalía con las barras, las cartas y la intención enemiga a la vista. | Atacar, mostrar el daño, defenderse, terminar el turno y llegar a una victoria o una derrota. |

### 11. Participación individual

Desarrollé este proyecto individualmente. Me encargué de conectar el HUD con los objetivos y la posición de Rudy, de enlazar las cartas y el diálogo con el estado de las relaciones y de llevar el resultado de cada acción de combate a las barras y animaciones. También preparé las sesiones temporales del menú de entrega y las pruebas que recorren las tres interfaces.

---

## Documentación general del videojuego

Juego narrativo de cartas en español para **LÖVE 11.5 / LuaJIT**. En esta continuidad alternativa, Rudy, Sylphiette, Roxy y Eris son adultos y ya están casados. Una poción vinculada a Hitogami sella la voz y el maná de Rudy; tiene siete días para conseguir el antídoto sin destruir sus matrimonios.

La campaña explorable incorpora **45 actividades matrimoniales**, **255 respuestas contextuales** y descanso en los dormitorios. Se habilitan después de leer la carta de Hitogami y completar la introducción de Nanahoshi. [Informe de exploración 3](docs/EXPLORACION_FASE_3.md) · [Cobertura de diálogos y recompensas](docs/COBERTURA_ACTIVIDADES.md).

**J abre los objetivos del día** en cualquier mapa explorable: historia, progreso total `0/3`, visitas recomendadas como `Eris 3/1`, opcionales y tareas completadas. Usa flechas o rueda para desplazarte y ←/→ para consultar días anteriores. El mapa, el diario y el descanso comparten los mismos requisitos. La carta —H permanece en el estudio para releerla. [Sistema de misiones y corrección del bloqueo](docs/MISIONES.md) · [Progresión diaria](docs/PROGRESION_DIARIA.md) · [Descanso](docs/DESCANSO.md) · [Objetos narrativos](docs/OBJETOS_NARRATIVOS.md).

La integración de los **siete días** conecta ese mundo con el emisario, Orsted opcional, Badigadi, la recuperación de la voz y **cinco finales**. Después del epílogo y el cierre de la última jornada aparece **Resumen de los siete días**, con cifras calculadas de la partida y recuerdos de cada esposa. [Entrega de exploración 4, pruebas A–I y capturas](docs/EXPLORACION_FASE_4.md) · [Cómo ampliar el contenido](docs/AMPLIAR_CONTENIDO.md).

La corrección de exploración social elimina el catálogo global y unifica las manos de cartas. [Cambios, pruebas y capturas](docs/EXPLORACION_SOCIAL.md) · [Configurar costes, contextos y frases](docs/CARTAS_SOCIALES.md) · [Colisiones y horarios de NPC](docs/COLISIONES_NPC.md).

### Ejecutar

Para abrir el menú principal de la campaña, ejecuta LÖVE sin argumentos desde la raíz del proyecto.

```powershell
./ejecutar.ps1
# O bien:
& 'C:\Program Files\LOVE\love.exe' .
```

No requiere red ni paquetes de Lua adicionales. Ventana inicial de 1280 × 720, canvas lógico de 640 × 360 y filtro `nearest`. El menú ofrece campaña, continuación, práctica social y de combate, combate libre, manual y opciones.

### Recursos y mundo explorable

Los **53 PNG nuevos** están organizados en `assets/characters/{portraits,overworld,npc_idle}`, `assets/maps/{greyrat_house,sharia,ranoa}`, `assets/tilesets`, `assets/objects/{items,atlases}` y `assets/animations/horse`. Los **53 ASE originales** están en las mismas categorías bajo `sprite_sources/`, sin conversión ni modificación binaria. El TXT de tilesets y el CSV/JSON del atlas se conservan junto a sus PNG. Los recursos anteriores mantienen sus rutas.

`src/data/assets.lua` incorpora el catálogo `exploration` mediante `src/data/exploration_assets.lua`. Se carga bajo demanda con `Resources:getExploration(grupo,id)`; `Resources:getObjectSprite(id)` comparte un solo atlas para todos los objetos. El audio existente sigue usando `src/data/audio.lua` y síntesis; `assets/audio/` y `assets/ui/` quedan preparados para futuros archivos.

`src/data/maps.lua` registra **14 mapas**, `map_connections.lua` define **13 enlaces bidireccionales** y `map_collisions.lua` separa suelo revisado, obstáculos y accesos. Ya puedes caminar con Rudy, saludar a su familia y consultar el minimapa. La campaña nueva empieza con el sueño de Hitogami y entrega el control junto a la cama de Eris. La historia espera a que recojas y termines de leer la carta en la cuarta puerta del segundo piso: el estudio. Los fondos de conversación de 320 × 180 siguen siendo recursos distintos.

Hay **12 enlaces calibrados y uno pendiente**: el acceso izquierdo de la universidad no presenta una abertura visible en el PNG. Además, los 18 ASE de mapas/tilesets traen registros de capas no estándar; se conservan sus bytes y se documenta la incidencia, sin certificar su apertura en LibreSprite. Consulta el [inventario completo, hashes y recuperación](docs/ASSETS_INVENTORY.md) y el [diagrama, coordenadas y convenciones](docs/MAPAS_CONEXIONES.md).

Un punto **T — Traslado** permite viajar entre Sharia y la universidad en ambos sentidos; el portal del muro continúa desactivado. Tras descubrir la maldición, camina hasta Nanahoshi e interactúa con ella. [Entrega de exploración: estados, controles, capturas, archivos y pruebas](docs/EXPLORACION_FASE_1.md).

#### Exploración 2: familia, hallazgos e inversiones

La familia dispone de conversaciones ambientales sin coste, con al menos ocho reacciones por personaje y memoria para evitar repeticiones inmediatas. **Zenith y Lucy comparten un solo sprite**: E permite elegir a quién saludar. Lilia y Aisha trabajan en la cocina/comedor; Norn acompaña a Zenith. Antes de la carta los saludos siguen siendo gestos y pensamientos, sin activar historia, romance ni cartas.

Después del tutorial de Nanahoshi aparecen **1–3 hallazgos por día**, derivados de una semilla guardada. Oro, copias, libros, materiales y fragmentos se recogen una vez; entrar en mapas o cargar no cambia el botín. I muestra el inventario y F usa un fragmento como energía externa. La carta —H conserva su secuencia y su ubicación exclusiva en el estudio.

Tras saludar a Cliff o Zanoba en el taller, solicita ayuda para revisar una inversión: **15/20 oro**, **60–75 % de éxito**, entrega mañana o ayuda personal confirmada que consume una interacción. El resultado se calcula una vez al solicitar; puede fallar. Ambos comparten el cupo diario y no permiten repetir el ID de ayer. Los encargos se contratan exclusivamente junto al NPC del taller; el diario sólo informa del estado. Los contratos anteriores se conservan.

Roxy permite reservar visitas a librería o tienda de materiales, investigar y acceder a mejoras. Las compras usan el sistema económico existente. Paul y Oldeus tienen reflexiones opcionales en el cementerio, sin oro ni gasto matrimonial. [Informe de fase 2, configuración, pruebas y ejemplos visuales](docs/EXPLORACION_FASE_2.md).

```powershell
python tools/migrate_exploration_assets.py verify
$env:DATESIM_TEST_MODULE = 'exploration_assets'
./probar.ps1
$env:DATESIM_TEST_MODULE = 'exploration_visual'
./probar.ps1
$env:DATESIM_TEST_MODULE = 'world_content'
./probar.ps1
Remove-Item Env:DATESIM_TEST_MODULE
./probar.ps1
```

### Campaña completa

La **Fase 6** integra el HUD de actividades, seguimiento de misiones y cartas, relaciones negativas visibles, resumen animado, información de mejoras y audio sintetizado. Incluye simulación reproducible de **33 campañas**, además de la regresión de 40 rutas y 576 batallas de Badigadi. Los cinco finales se alcanzaron; la partida manual completa y la revisión auditiva quedan pendientes. [Informe, costes, resultados y límites](docs/FASE_6_INFORME.md) · [CSV de balance](docs/BALANCE_FASE_6.csv).

La **Fase 5** completa la investigación del emisario, la revelación del antídoto y el regreso a Nanahoshi. Entrenar con Eris en cada uno de los días 1–5 abre la demostración controlada de Orsted y dos mejoras gratuitas elegidas por el jugador. Los cinco finales tienen escenas propias y también son alcanzables sin su ayuda. [Eventos, reglas y persistencia](docs/FASE_5_CIERRE.md).

La **Fase 4** añade enemigos por día, apoyos con afinidad persistente, costes y recargas, preparación de combate y Badigadi de **1000 PV en el Día 7**. Puede vencerse sin compañeras ni el evento opcional de Orsted. [Reglas y simulaciones](docs/FASE_4_COMBATE.md).

Las **40 cartas se mejoran hasta nivel 10** con duplicados y oro. En exploración abre **I → Colección** o visita a Roxy para la actividad **R04 — Mejorar cartas**; en preparación de combate, M abre el mazo. La tienda vende copias adquiridas, libros, materiales y preparación. Cada esposa tiene un máximo **diurno de +10 amor y +10 confianza**; el descanso nocturno añade su bonificación por separado. [Fórmulas, costes y arquitectura de la Fase 2](docs/FASE_2_PROGRESION.md).

Las 16 actividades del catálogo anterior se conservan para sus guardados; la campaña explorable utiliza el banco nuevo de **45 actividades**. No visitar a una esposa cuesta **−20 amor y −20 confianza** al cierre. Las advertencias preceden a una separación por abandono; la partida conserva la separación, su escena y el retrato gris. Cliff y Zanoba entregan al día siguiente; ayudar consume un espacio y adelanta la entrega. [Reglas del sistema familiar](docs/FASE_3_FAMILIA.md) · [Catálogo explorable](docs/COBERTURA_ACTIVIDADES.md).

Cada día dispone de **tres interacciones compartidas**, repetibles con cualquier esposa, y **un encargo independiente a Cliff o Zanoba**. Busca a Eris en el patio, a Roxy en la biblioteca o a Sylphie en la sala y pulsa E. Cada esposa ofrece tres respuestas horizontales de su banco de quince, sin premios anticipados. G no tiene acción. La mano procede del mazo social equipado y permite revisar la frase y el coste antes de confirmar. Las escenas principales no gastan espacios. El Día 7 cierra el tiempo libre antes de resolver los matrimonios.

Al cerrar la tercera actividad, las tres esposas activas regresan a sus dormitorios. Para continuar los eventos obligatorios, habla con Nanahoshi en su laboratorio. Los días 1–6 terminan al cumplir la historia y tres interacciones totales, con cualquier distribución, y confirmar el descanso en una cama o el jergón. Compartir la noche concede hasta **+10 amor/+10 confianza**, aparte del límite diurno y sin sustituir las visitas del día. El resumen conserva la penalización de **−20/−20** por ausencia. Rudy despierta en el lugar elegido. El Día 7 termina por desenlace sin una noche adicional. [Descanso y persistencia](docs/DESCANSO.md).

| Día | Contenido |
| --- | --- |
| 1 · El silencio de Rudy | Sueño con Hitogami; despertar; recoger y leer la carta —H; descubrir voz y maná sellados; notas a Nanahoshi; regalo de Orsted; tutoriales jugables. |
| 2 · Palabras prestadas | Conversaciones con las tres esposas, necesidades distintas, nuevas cartas e investigación de la botica. |
| 3 · El primer fragmento | Investigación con Nanahoshi, bosque, ruinas, compañera elegida, combates y magia alimentada por energía externa. |
| 4 · El precio del silencio | Investigación del sello con Nanahoshi, conflictos familiares, emisario, recuerdo de la poción y ruta cifrada hacia su responsable. |
| 5 · Lazos puestos a prueba | Duelo de entrenamiento con Eris; misiones personales, compromisos, reconciliaciones y cartas de compañeras. |
| 6 · El último cerco | Revancha opcional con Eris, reflejo de Rudy, combate contra el emisario y revelación del guardián del antídoto; Orsted aparece si entrenaste los cinco días. |
| 7 · El desafío y la verdadera voz | Preparación del equipo; Badigadi de 1000 PV y cuatro fases; antídoto, recuperación de voz y magia, resolución matrimonial, devolución de cartas y cinco epílogos específicos. |

Hitogami manipula la historia; no es un enemigo físico convencional. Orsted es aliado. Badigadi acepta la derrota y sobrevive. Hay exactamente **cinco finales**: las tres esposas, solamente Roxy, solamente Eris, solamente Sylphiette o ninguna. Las parejas viables pendientes se resuelven mediante decisiones narrativas, sin escoger automáticamente el mayor amor. [Capítulos y condiciones](docs/CAPITULOS.md).

### Cartas, emociones y relaciones

Nanahoshi entrega **diez cartas en total**: cinco sociales y cinco físicas. Los mazos empiezan vacíos y admiten después entre cinco y diez cartas adquiridas cada uno. Las cartas parlantes muestran una respuesta contextual con la voz encantada indicada en pantalla y un efecto sonoro; esta versión no incluye doblaje grabado.

Las entregas múltiples permiten **ver una por una o recibir todas**, con resumen paginado y opción de omitir. La celebración muestra los participantes del evento: Rudy, Nanahoshi, Cliff y Zanoba aparecen juntos en la investigación del cuarto día; otras entregas conservan su interlocutor. Las copias, niveles y desbloqueos se conceden antes de animar y se conservan al guardar. [Entrega de cartas y controles](docs/ENTREGA_CARTAS.md).

En cada conversación se animan los intercambios reales del mazo **equipado, adquirido y compatible** y se toman tres cartas con los marcos e iconos originales. Las cinco cartas iniciales tienen respuesta en las 45 actividades matrimoniales; las dos primeras jugadas se reponen para mantener tres opciones antes de cada turno, sin reciclar el descarte. El tutorial conserva un reparto guiado. Selecciona una carta para leer **«Rudy dirá»**, su intención y su coste; puedes cancelar antes de usarla. Cada encuentro social admite hasta tres cartas y seis puntos de energía total. Jugar descarta la carta y toma la siguiente si quedan turnos; **P** permite terminar una actividad matrimonial; en las escenas narrativas permite escuchar en silencio sin energía ni voz gratuita. Cargar conserva la mano y el orden restante.

Las conversaciones de Nanahoshi, Eris, Roxy y Sylphiette utilizan respuestas escritas por situación. La carta abre la frase de Rudy, la reacción de la otra persona y una continuación; amor, confianza y memoria se aplican al mostrar la reacción. Los números indican el cambio real, respetando el límite de −100–100. Una broma ante el entrenamiento de Eris, una duda sobre la fórmula de Roxy y una promesa a Sylphiette producen consecuencias distintas. La promesa de tiempo familiar puede cumplirse o incumplirse el día tres, recordarse el cuarto y repararse expresamente el quinto.

El inventario contiene **15 cartas sociales, seis híbridas y 19 de combate**. El catálogo escrito cubre nueve conversaciones de entrada; el [informe de cobertura](docs/COBERTURA_DIALOGOS.md) distingue respuestas, variantes, continuaciones y combinaciones posibles. Todo funciona sin conexión mediante tablas Lua, sin generación de texto durante la partida. [Guía de conversaciones y autoría](docs/DIALOGOS.md).

La carta firmada por **—H** es un documento, separado de ambos mazos. Se recoge mediante clic o teclado, se abre con animación y queda disponible en **J → Carta —H**. Leerla o cargar una partida no duplica sus eventos ni los regalos.

Cada personaje utiliza sus cuatro expresiones reales y movimientos breves. Las tres relaciones empiezan en **50 de amor y 50 de confianza**, con límites de −100–100. Promesas, conflictos, decisiones, reconciliaciones y misiones afectan los diálogos y el desenlace; curarse no repara automáticamente los matrimonios. [Sistemas](docs/SISTEMAS.md).

Sobre los retratos se muestran barras animadas con valores y cambios con signo. Las esposas tienen **Amor y Confianza**; Nanahoshi, **Confianza e Interés**, sin añadirse a los finales matrimoniales. Solo cinco cartas sociales pueden despertar su interés. El día cinco incluye un duelo real contra Eris, evaluado por estrategia y esfuerzo: una derrota honesta no recibe el castigo por dejar pasar repetidamente oportunidades claras. [Barras, afinidad y reglas del entrenamiento](docs/AFINIDAD_Y_ENTRENAMIENTO.md).

En el sueño inicial, Rudy recupera el cuerpo japonés de su vida anterior y aparece junto a Hitogami. Al despertar en casa vuelve a su aspecto rubio. Ambos retratos pertenecen a la misma identidad: el contexto visual no cambia relaciones, maldición ni progreso. Guardar y continuar recupera fondo, apariencia y expresión desde la línea narrativa. [Retratos contextuales y autoría](docs/RETRATOS.md).

### Combate

Rudy empieza con **30 PV, tres acciones por turno y maná natural bloqueado**. Los cinco ataques iniciales funcionan sin magia. Defensa y esquiva siempre están disponibles independientemente de la mano. Los fragmentos permiten alimentar hechizos de agua y tierra con energía externa; el antídoto restaura la magia natural.

Sylphiette protege y cura, Roxy analiza y conjura, Eris golpea e interrumpe. Badigadi pasa por resistencia, seis brazos, sello y victoria: reducir su vida a cero no basta; hay que **romper el sello con B**. La derrota permite reintentar o preparar el mazo. [Reglas de combate](docs/COMBATE.md).

La dificultad combina enemigos propios de cada día con perfiles acotados: aparecen debilitamientos, interrupciones y ataques múltiples anunciados. Antes de terminar el turno, compara la intención con tus PV y escudo; la defensa y la esquiva no dependen de tomar una carta concreta. Curación básica y las cartas híbridas que curan permiten tres usos por batalla; Sylphiette dispone de tres curaciones efectivas y después conserva sus acciones de ataque y protección. Badigadi mantiene sus fases y el día siete se dedica al desenlace.

| Acción | Control |
| --- | --- |
| Caminar en exploración (80 px/s) | WASD o flechas |
| Correr en exploración (150 px/s) | Shift izquierdo o derecho + movimiento |
| Saludar / examinar / traslado | E, cerca del objeto o personaje |
| Minimapa / inventario / diario / estado diario | M / I / J / Tab, en exploración |
| Actividades / investigación / encargos | E junto a la esposa / Nanahoshi / Cliff o Zanoba |
| Leer / confirmar | Clic, Enter o Espacio |
| Examinar el sobre | Clic, E, Enter o Espacio |
| Seleccionar carta | 1–3, flechas o clic |
| Cancelar la carta social seleccionada | Esc o Cancelar |
| Terminar turno / tácticas | E / T |
| Defensa / esquiva / romper sello | D / V / B |
| Contraataque en el entrenamiento de Eris | C, después de un bloqueo o esquiva efectivos |
| Respiro social / historial de combate | P / H |
| Diario / mazos | J / M, desde la historia |
| Guardar / pausa / pantalla completa | F5 / Esc / F11 |

### Guardado y pruebas

La continuidad `rudy_curse` conserva **versión 8**, ampliada con `exploration.version=1`. Guarda en `%APPDATA%\LOVE\cartas_del_destino\campaign-exploration-v1.json`, con respaldo `campaign-exploration-v1.backup.json`. Incluye posición, orientación, prólogo, página de la carta, objetivo, lugares visitados y recursos, además de los sistemas anteriores. **Continuar** recupera v8/v7/v6/v5/v4 conservando su historia y archivos originales; esos archivos nunca se sobrescriben. Las campañas anteriores mantienen su recorrido narrativo. El menú también permite importar la colección compatible de v1/v2/v3, comenzando una nueva campaña. [Formato y recuperación](docs/GUARDADO.md).

```powershell
./probar.ps1
# O bien:
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

La suite usa la identidad aislada `cartas_del_destino_v8_tests` y genera capturas en `tests/artifacts/`. Los resultados realmente ejecutados y sus límites figuran en [VERIFICACION.md](docs/VERIFICACION.md). [Entrega y archivos](docs/REESTRUCTURACION.md), [manual](docs/MANUAL.md), [animaciones](docs/ANIMACIONES.md), [audio](docs/AUDIO.md) y [recursos](assets/README.md).

Para revisar una partida humana sin tocar tu guardado habitual, ejecuta `./revisar.ps1`. Abre una campaña normal con identidad separada; **F8** guarda una captura y su checkpoint. Para ejecutar los once perfiles de balance usa `DATESIM_TEST_MODULE=seven_day_balance`; el [informe](docs/FASE_6_INFORME.md#ejecución-y-reproducción) contiene los comandos completos y la selección de semilla.

Se conservan los PNG y ASE existentes. Música y efectos son síntesis original sencilla; la valoración auditiva y las pruebas prolongadas con jugadores siguen siendo trabajo de producción.
