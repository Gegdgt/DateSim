# Mushoku Tensei: Las Cartas del Destino

**Portafolio de desarrollo | Sistemas de UI · Progression Cycles · Map System**

**Motor:** LÖVE 11.5 (LuaJIT)  |  **Proyecto:** individual  |  **Código:** [Gegdgt/DateSim](https://github.com/Gegdgt/DateSim)

## Presentación del juego

Quise hacer un *dating sim* que tuviera algo más que conversaciones. Por eso tomé el universo de *Mushoku Tensei* y planteé una historia alternativa en la que Rudy pierde su voz y su maná debido a una poción relacionada con Hitogami. Tiene siete días para buscar un antídoto y, mientras investiga, debe seguir cuidando su relación con Sylphie, Roxy y Eris.

La partida combina exploración, actividades familiares, decisiones mediante cartas y combate por turnos. Preparé este portafolio con capturas reales de **una partida que llega al final del Día 1**. Aunque el juego contempla siete días y diferentes finales, ese primer día ya sirve para demostrar las tres entregas del curso.

![Figura 1. Menú principal de la versión presentada, con las opciones para empezar y practicar.](<captures/1. Menu.png>)

*Figura 1. Menú principal de la versión presentada, con las opciones para empezar y practicar.*

## Cómo instalarlo y ejecutarlo

El juego funciona en Windows con LÖVE 11.5. Una vez descargado el repositorio, basta con abrir PowerShell en la carpeta que contiene `main.lua` y ejecutar el script incluido.

1. Descargar o clonar el [repositorio](https://github.com/Gegdgt/DateSim).
2. Instalar [LÖVE 11.5](https://love2d.org/).
3. Abrir PowerShell dentro de la carpeta del proyecto.
4. Ejecutar el comando siguiente y seleccionar **Nueva partida**.

```powershell
.\ejecutar.ps1
```

También puede iniciarse con `& 'C:\Program Files\LOVE\love.exe' .` desde la carpeta raíz. El juego usa una ventana inicial de 1280 × 720 píxeles, con un lienzo interno de 640 × 360 y filtro `nearest` para que los sprites no se vean borrosos. No requiere conexión a Internet ni librerías extra de Lua.

## Qué pasa al comenzar

El primer día inicia con el sueño de Hitogami. Después Rudy despierta en el dormitorio de Eris y el jugador puede recorrer la casa. La primera tarea importante es encontrar una carta en el estudio de Rudy; al leerla, comienza la búsqueda de Nanahoshi. En su laboratorio recibimos las cartas iniciales, completamos los tutoriales y empezamos a elegir actividades con las esposas.

![Figura 2. Introducción del Día 1 y primer encuentro con Hitogami.](<captures/2. Inicio de la partida.png>)

*Figura 2. Introducción del Día 1 y primer encuentro con Hitogami.*

## Controles que utilizamos

| Control | Función |
| --- | --- |
| WASD / flechas | Mover a Rudy por los mapas |
| Shift + movimiento | Correr para recorrer los escenarios más rápido |
| E | Hablar, examinar, recoger objetos o descansar |
| M | Abrir el minimapa |
| I | Abrir la bolsa y acceder a la colección |
| J | Consultar las tareas del diario |
| Tab | Ver el estado de la partida |
| 1, 2, 3 / flechas / Enter / mouse | Elegir respuestas y cartas en las pantallas correspondientes |
| F5 | Guardar la partida |
| Esc | Pausar o volver, según la escena |

## Cómo preparé el apartado visual

Opté por pixel art sencillo porque me interesaba que los personajes y los lugares fueran reconocibles sin utilizar ilustraciones demasiado grandes. Organicé el arte por separado: retratos con cuatro expresiones, sprites de exploración con varias direcciones, mapas, fondos de conversación, iconos y marcos de cartas. Para el juego se utilizan archivos **PNG** y las fuentes de pixel art se conservan en **ASE** para poder editarse en LibreSprite.

Los retratos normales tienen cuatro expresiones de 64 × 64 píxeles, distribuidas en hojas de 256 × 64. Los fondos narrativos suelen ser de 320 × 180, las cartas usan marcos de 80 × 112 y los iconos son de 24 × 24. Los mapas se construyeron con una estética consistente de RPG 2D, usando elementos de 16 × 16 como referencia para los tilesets.

Los PNG se encuentran en `assets/`, mientras que los archivos ASE están en `sprite_sources/`. El archivo `src/data/assets.lua` registra los recursos y `src/systems/resources.lua` los carga desde el juego. **La apertura de algunos ASE de mapas y tilesets todavía requiere una revisión en LibreSprite**, aunque sus PNG sí están integrados y se dibujan correctamente.

**Recursos y código:** [carpeta de imágenes](https://github.com/Gegdgt/DateSim/tree/main/assets) · [fuentes ASE](https://github.com/Gegdgt/DateSim/tree/main/sprite_sources) · [carga de recursos](https://github.com/Gegdgt/DateSim/blob/main/src/systems/resources.lua).

## Cómo se organizó el motor

Separé la aplicación en pantallas, sistemas y archivos de datos. `main.lua` recibe las llamadas de LÖVE; `src/app.lua` mantiene el estado general y cambia de pantalla; `src/core/state_manager.lua` administra la escena activa. Las reglas de combate, actividades y cartas viven en `src/systems/`, mientras que las definiciones de mapas y actividades están en `src/data/`. Esto me permite corregir una interfaz sin reescribir las reglas de toda la partida.

El proyecto utiliza la secuencia **Setup → Update → Render**: se crea la pantalla con `new(...)`, se procesan actualizaciones mediante `update(dt)` cuando son necesarias y se dibuja con `draw()`. Las pantallas también reciben eventos de teclado y mouse. El progreso se conserva dentro de una sesión serializable y puede guardarse en disco.

## Dónde se ve todo esto durante el Día 1

1. **Menú e introducción:** seleccionar Nueva partida y terminar la conversación inicial con Hitogami.
2. **Exploración:** salir del dormitorio, recorrer la casa y buscar la carta del estudio.
3. **Tutorial:** encontrar a Nanahoshi, recibir las diez cartas y aprender las interacciones sociales y el combate.
4. **Progresión:** visitar a Roxy, Eris y Sylphie y realizar las tres interacciones del día.
5. **Descanso:** revisar el diario, regresar a los dormitorios y pasar al resumen del Día 1.

---

# Sistemas de UI

Para esta tarea elegí tres interfaces que el jugador utiliza realmente: el HUD de exploración, las conversaciones con cartas y el combate. Cada una toma datos del juego, responde al jugador y presenta información diferente.

## 1. HUD de exploración

**Dónde aparece:** desde que Rudy despierta en el dormitorio de Eris. El HUD continúa visible al recorrer la casa y las otras zonas. Muestra el lugar actual, el día y los controles; cuando nos acercamos a algo que podemos examinar aparece la indicación de interacción. Abrimos el diario con `J` y el minimapa con `M`.

**Setup:** `Exploration.new(app)` prepara la escena y sus referencias. **Update:** `s:update(dt)` actualiza cámara, animación, movimiento y cercanía a objetos. **Render:** `drawWorld()` dibuja el mapa; `s:draw()` coloca encima el HUD, fijo en la pantalla aunque se mueva la cámara.

![Figura 3. HUD de exploración mientras Rudy recorre la casa Greyrat.](<captures/3. Exploracion del mapa.png>)

*Figura 3. HUD de exploración mientras Rudy recorre la casa Greyrat.*

![Figura 5. Primeros mensajes y objetivo de la historia dentro de la exploración.](<captures/5. Inicio de las misiones .png>)

*Figura 5. Primeros mensajes y objetivo de la historia dentro de la exploración.*

![Figura 28. Diario del Día 1: tres interacciones completadas y objetivo de descanso pendiente.](<captures/28. Lista de cosas pendientes.png>)

*Figura 28. Diario del Día 1: tres interacciones completadas y objetivo de descanso pendiente.*

**Dónde está el código:** [pantalla de exploración](https://github.com/Gegdgt/DateSim/blob/main/src/screens/exploration.lua) · [lógica de exploración](https://github.com/Gegdgt/DateSim/blob/main/src/systems/exploration.lua) · [diario de objetivos](https://github.com/Gegdgt/DateSim/blob/main/src/ui/objective_journal.lua).

## 2. Conversaciones con cartas

**Dónde aparece:** durante el tutorial de Nanahoshi y al hablar con Eris, Roxy o Sylphie después de recibir las cartas. Las cartas representan lo que Rudy quiere decir mientras no puede usar su voz normal. Antes de confirmar se puede consultar la frase y el coste, y después vemos la reacción del personaje y las barras de amor y confianza.

**Setup:** la pantalla prepara retratos, mazo, mano y barras de relación. **Update:** controla animaciones de barajado, selección, uso, descarte y cambios de estadísticas. **Render:** dibuja las cartas con sus marcos e iconos, el texto y las reacciones. Para los encuentros de historia se usa `Encounter.new(app)`; las actividades de esposas utilizan `View.new(app, wife)` y comparten componentes visuales.

![Figura 8. Tutorial de cartas sociales con la mano, el coste y las opciones de respuesta.](<captures/8. Tutorial.png>)

*Figura 8. Tutorial de cartas sociales con la mano, el coste y las opciones de respuesta.*

![Figura 15. Conversación con Roxy y cartas sociales disponibles durante una actividad.](<captures/15. Cartas con Roxy.png>)

*Figura 15. Conversación con Roxy y cartas sociales disponibles durante una actividad.*

![Figura 20. Encuentro con Eris: diálogo y estado de cartas durante su actividad.](<captures/20. Cartas Eris.png>)

*Figura 20. Encuentro con Eris: diálogo y estado de cartas durante su actividad.*

**Dónde está el código:** [pantalla de encuentros](https://github.com/Gegdgt/DateSim/blob/main/src/screens/encounter.lua) · [actividades sociales](https://github.com/Gegdgt/DateSim/blob/main/src/screens/wife_activities.lua) · [componente de mano](https://github.com/Gegdgt/DateSim/blob/main/src/ui/social_hand.lua) · [dibujo de cartas](https://github.com/Gegdgt/DateSim/blob/main/src/ui/card.lua) · [barras de relación](https://github.com/Gegdgt/DateSim/blob/main/src/ui/relationship_bars.lua).

## 3. Interfaz de combate

**Dónde aparece:** el Día 1 incluye el tutorial de combate con una anomalía de maná. También se puede acceder a combates de práctica desde el menú principal. El jugador ve su vida, escudo, recursos, cartas y la intención del enemigo antes de elegir una acción.

**Setup:** `CombatScreen.new(app, definition)` carga las reglas, personajes y cartas del encuentro. **Update:** controla turnos, animaciones de daño y cambios de recursos. **Render:** presenta combatientes, barras, cartas, opciones e información sobre el siguiente ataque enemigo.

![Figura 9. Tutorial de combate: vida de Rudy, cartas, anomalía y ataque anunciado del enemigo.](<captures/9. Tutorial de ataque.png>)

*Figura 9. Tutorial de combate: vida de Rudy, cartas, anomalía y ataque anunciado del enemigo.*

Esta captura permite comprobar la interfaz; para mostrar **un turno completo** conviene grabar cómo se utiliza una carta y cómo responde el enemigo.

**VIDEO — Combate.** Mostrar la elección de una carta, el daño producido y la siguiente acción del enemigo. El tutorial de combate del Día 1 es suficiente para grabarlo.

**Video del proyecto:** [Ver gameplay](<gameplay/Mushoku Tensei_ Las Cartas del Destino.mp4>) *(enlace preparado; el archivo MP4 no estaba incluido en el ZIP recibido).*




**Dónde está el código:** [pantalla de combate](https://github.com/Gegdgt/DateSim/blob/main/src/screens/combat.lua) · [reglas de combate](https://github.com/Gegdgt/DateSim/blob/main/src/systems/combat.lua).

## Comprobación de Sistemas de UI

| Lo que pidió el ejercicio | Cómo lo demuestro |
| --- | --- |
| Tres sistemas distintos | HUD (figuras 3, 5 y 28), cartas (8, 15 y 20) y combate (9) |
| Setup → Update → Render | Constructores `new(...)`, actualización y métodos `draw()` en las tres pantallas |
| Conexión con el juego | HUD consulta día y objetivos; cartas modifican relaciones; combate utiliza vida y recursos reales |
| Separación de la cámara | El HUD permanece fijo mientras el escenario se desplaza |
| Código fuente | Enlaces a los módulos de cada interfaz y al repositorio |
| Evidencia de interacción | Capturas disponibles; el video permite mostrar las acciones en movimiento |
| Limpieza de Breakout | No aparecieron módulos de Breakout en la revisión previa del repositorio |

---

# Progression Cycles

La progresión del juego se entiende mejor cuando una actividad termina y se ve lo que consiguió Rudy. La idea es que las cartas obtenidas tengan relación con lo que acabamos de hacer, en lugar de recibir siempre las mismas recompensas.

## El ciclo que programé

**Buscar a un personaje → elegir una actividad → responder con cartas o completar un reto → cambiar amor, confianza y recursos → recibir cartas o copias cuando corresponda → revisar la colección.**

Las tres interacciones del día se pueden distribuir libremente entre las esposas. Para esta evidencia utilicé una actividad con cada una, así que también puedo enseñar cómo se actualizan los contadores y cómo cambia el estado de la jornada.

## 1. Pantalla de progresión: actividades

**Dónde está:** Eris espera en el patio de entrenamiento; Roxy está en la biblioteca de Ranoa y Sylphie en la sala de la casa. Al hablar con ellas aparecen tres propuestas de actividad. En cada encuentro elijo las respuestas mediante cartas y el juego actualiza el amor, la confianza y, cuando corresponde, oro, materiales y recompensas.

**Dos o más acciones:** estudiar con Roxy, entrenar con Eris o realizar tareas del hogar con Sylphie ya son ejemplos diferentes. **Dos o más atributos:** las barras de amor y confianza cambian según las respuestas, y algunas actividades afectan el oro o los objetos. El HUD y las pantallas muestran el Día 1 y las interacciones disponibles. Al terminar, recibo un resumen de lo que sucedió.

**Implementación:** `View.new(app, wife)` prepara la conversación; `s:update(dt)` avanza las animaciones y las respuestas; `s:draw()` mantiene visible la escena y los elementos de la actividad. Las reglas están en `src/systems/wife_activities.lua` y `src/systems/daily.lua`, separadas del dibujo.

### Actividad con Roxy

En la biblioteca puedo hablar con Roxy y escoger una actividad relacionada con estudiar magia, investigar o trabajar con cartas. Las decisiones tienen sus propias respuestas, y al finalizar aparece un resumen con lo conseguido.

![Figura 14. Tres opciones de actividad al hablar con Roxy en la biblioteca.](<captures/14. Opciones de Roxy.png>)

*Figura 14. Tres opciones de actividad al hablar con Roxy en la biblioteca.*

![Figura 16. Resultado de una actividad con Roxy y cambios de relación mostrados en pantalla.](<captures/16. Final de la interaccion con Roxy.png>)

*Figura 16. Resultado de una actividad con Roxy y cambios de relación mostrados en pantalla.*

### Actividad con Eris

Con Eris el contenido cambia: las opciones giran alrededor del entrenamiento y los enfrentamientos. El Día 1 me deja enseñar una actividad de práctica, su preparación y el resultado final.

![Figura 18. Opciones de entrenamiento y conversación al hablar con Eris.](<captures/18. Opciones de Eris.png>)

*Figura 18. Opciones de entrenamiento y conversación al hablar con Eris.*

![Figura 19. Inicio de una actividad con Eris y preparación de las cartas sociales.](<captures/19. Inicio de Juego Eris.png>)

*Figura 19. Inicio de una actividad con Eris y preparación de las cartas sociales.*

![Figura 21. Pantalla de preparación del entrenamiento que solo corresponde a Eris.](<captures/21. Inicio de entrenamiento Solo disponible con eris.png>)

*Figura 21. Pantalla de preparación del entrenamiento que solo corresponde a Eris.*

![Figura 22. Resultado y recompensas obtenidas después del entrenamiento.](<captures/22. Recompensas del entrenamiento.png>)

*Figura 22. Resultado y recompensas obtenidas después del entrenamiento.*

### Actividad con Sylphie

Con Sylphie aparecen actividades de la casa y conversaciones familiares. La dinámica de cartas es la misma, pero las frases y las reacciones son distintas porque el contexto no es un entrenamiento ni una investigación.

![Figura 24. Tres propuestas de actividad en la conversación con Sylphie.](<captures/24. Opciones Sylphie.png>)

*Figura 24. Tres propuestas de actividad en la conversación con Sylphie.*

![Figura 25. Inicio del encuentro de cartas durante una actividad con Sylphie.](<captures/25. Inicio de Juego Sylphie.png>)

*Figura 25. Inicio del encuentro de cartas durante una actividad con Sylphie.*

![Figura 26. Final de la actividad de Sylphie y resumen de la conversación.](<captures/26. Final de cartas con sylphie.png>)

*Figura 26. Final de la actividad de Sylphie y resumen de la conversación.*

**Código principal:** [pantalla de actividades](https://github.com/Gegdgt/DateSim/blob/main/src/screens/wife_activities.lua) · [sistema de actividades](https://github.com/Gegdgt/DateSim/blob/main/src/systems/wife_activities.lua) · [jornada e interacciones](https://github.com/Gegdgt/DateSim/blob/main/src/systems/daily.lua) · [datos de Eris](https://github.com/Gegdgt/DateSim/blob/main/src/data/wife_activities_eris.lua) · [datos de Roxy](https://github.com/Gegdgt/DateSim/blob/main/src/data/wife_activities_roxy.lua) · [datos de Sylphie](https://github.com/Gegdgt/DateSim/blob/main/src/data/wife_activities_sylphie.lua).

## 2. Adquisición de cartas

**Dónde se ve:** el primer lote aparece al visitar a Nanahoshi después de encontrar la carta del estudio. Ella entrega diez cartas iniciales. La pantalla permite **verlas una por una** o **recibirlas todas**, y después revisar el resumen. Más adelante las actividades y eventos pueden conceder copias o cartas concretas.

![Figura 6. Entrega inicial de diez cartas por Nanahoshi y elección del modo de presentación.](<captures/6. Recibir cartas.png>)

*Figura 6. Entrega inicial de diez cartas por Nanahoshi y elección del modo de presentación.*

![Figura 7. Resumen de las diez cartas recibidas al completar la entrega.](<captures/7. Ver las cartas que se recibieron.png>)

*Figura 7. Resumen de las diez cartas recibidas al completar la entrega.*

![Figura 10. Nueva recompensa presentada durante el tutorial.](<captures/10. Recompensa del tutorial.png>)

*Figura 10. Nueva recompensa presentada durante el tutorial.*

**Cómo depende del progreso:** las cartas no salen de una lista totalmente independiente del juego. Cada actividad o evento define las recompensas y los requisitos. Por ejemplo, la limpieza de Sylphie puede dar una copia de Escuchar, mientras que un entrenamiento con Eris puede entregar cartas relacionadas con combate. La regla se aplica al completar la actividad, no al abrir el menú de recompensas.

**Implementación:** `Reward.new(app, returnTo)` prepara la entrega; `s:update(dt)` maneja la revelación y los sonidos; `s:draw()` muestra los marcos e iconos. La concesión ocurre antes, mediante `src/systems/events.lua` y `src/systems/card_collection.lua`, para evitar recibir una carta dos veces por volver a ver la animación.

**Código:** [pantalla de adquisición](https://github.com/Gegdgt/DateSim/blob/main/src/screens/reward.lua) · [presentación de cartas](https://github.com/Gegdgt/DateSim/blob/main/src/ui/reward_presentation.lua) · [eventos](https://github.com/Gegdgt/DateSim/blob/main/src/systems/events.lua) · [colección persistente](https://github.com/Gegdgt/DateSim/blob/main/src/systems/card_collection.lua).

## 3. Colección y persistencia

Después de recibir cartas puedo entrar a la bolsa y abrir la colección. Allí se consultan nombre, tipo, efectos, coste, nivel y copias. La información se conserva al cambiar de pantalla porque las cartas pertenecen a la sesión de la partida (`session.collection`), no a la animación de recompensa. En la pantalla de Roxy también puedo acceder a mejoras cuando la actividad lo permite.

**Importante para la evidencia:** la figura 7 es el **resumen de adquisición**, no una captura de la colección abierta. Necesito añadir una imagen de la colección con una carta seleccionada si quiero mostrar claramente la navegación e inspección exigidas por el ejercicio.

**EVIDENCIA ADICIONAL RECOMENDADA:** Abrir `I` → Colección, seleccionar una carta recién recibida y capturar su nombre, coste, efecto, nivel y copias. Después de salir y volver a entrar, tomar una segunda captura o grabar el regreso para demostrar persistencia.




**Código:** [interfaz de colección](https://github.com/Gegdgt/DateSim/blob/main/src/screens/collection.lua) · [datos, niveles y copias](https://github.com/Gegdgt/DateSim/blob/main/src/systems/card_collection.lua) · [sistema de guardado](https://github.com/Gegdgt/DateSim/blob/main/src/systems/save.lua).

## 4. Cierre del Día 1 como prueba de progreso

Después de utilizar las tres interacciones, las esposas regresan a sus dormitorios. Esto muestra que el mismo estado controla los personajes del mapa, los objetivos del diario y la posibilidad de terminar el día. Al descansar aparece el resumen de la jornada.

![Figura 27. Las esposas regresan a sus habitaciones al finalizar las tres interacciones.](<captures/27. Al terminar Sylphie, roxy y eris regresan a sus habitarciones.png>)

*Figura 27. Las esposas regresan a sus habitaciones al finalizar las tres interacciones.*

![Figura 33. Conversación de descanso que permite cerrar la jornada.](<captures/33. Fin del dia.png>)

*Figura 33. Conversación de descanso que permite cerrar la jornada.*

![Figura 34. Resumen del Día 1 con las estadísticas y el resultado de la jornada.](<captures/34. Estadisticas dia 1.png>)

*Figura 34. Resumen del Día 1 con las estadísticas y el resultado de la jornada.*

## Arquitectura, estado compartido y pruebas

Las pantallas no calculan por su cuenta qué carta se entrega. Las actividades se resuelven en los sistemas correspondientes; `events.lua` registra el resultado con un identificador; `card_collection.lua` actualiza cartas y copias; y la pantalla `reward.lua` solo muestra la adquisición. Los datos compartidos incluyen día, visitas, relaciones, oro y cartas. Las imágenes se cargan por separado y no se guardan dentro del estado de la partida.

**Referencias:** [estado y guardado](https://github.com/Gegdgt/DateSim/blob/main/src/systems/save.lua) · [datos de progresión de cartas](https://github.com/Gegdgt/DateSim/blob/main/src/data/card_progression.lua) · [prueba de actividades](https://github.com/Gegdgt/DateSim/blob/main/tests/daily.lua) · [prueba de recompensas](https://github.com/Gegdgt/DateSim/blob/main/tests/card_rewards.lua) · [pruebas de interfaz](https://github.com/Gegdgt/DateSim/blob/main/tests/wife_activities_ui.lua).

| Requisito de Progression Cycles | Evidencia del Día 1 |
| --- | --- |
| Dos fases conectadas | Actividades con esposas y entregas de cartas (figuras 14–26 y 6–10) |
| Dos o más decisiones | Opciones diferentes con Roxy, Eris y Sylphie |
| Dos o más variables | Amor, confianza, oro y recompensas |
| Día/turnos/acciones | Día 1 y las tres interacciones diarias |
| Feedback | Diálogos, barras y resúmenes (16, 22, 26, 34) |
| Obtención de varias cartas | Entrega inicial de Nanahoshi (6, 7) |
| Cartas relacionadas con decisiones | Datos de recompensa específicos de actividades y requisitos de desbloqueo |
| Colección persistente y navegable | El código la implementa; falta una captura específica de su pantalla |
| Estado compartido y eventos | `save.lua`, `daily.lua`, `events.lua` y `card_collection.lua` |
| Pruebas | Suite de actividades, recompensas y guardado enlazada |

---

# Map System

La exploración es la manera en que conecté las demás partes del juego. Rudy no elige a qué esposa visitar desde un menú global: debe caminar hasta el lugar donde se encuentra cada una. Lo mismo pasa con Nanahoshi y con los encargos de Cliff y Zanoba.

## 1. Diseño del mapa y puntos de interés

El mundo está dividido en **14 mapas** de la casa Greyrat, sus alrededores en Sharia y la Universidad de Ranoa. Incluí habitaciones, sala, jardín, patio de entrenamiento, biblioteca, taller, laboratorio y cementerio porque forman parte de la historia o de las actividades que hacemos durante la semana.

En estas capturas del primer día puedo mostrar **más de tres lugares diferentes** y explicar para qué sirven. Los personajes y las señales `E` ayudan a reconocer los puntos con los que se puede interactuar.

![Figura 4. Otra zona de la planta baja de la casa Greyrat, con muebles y personajes.](<captures/4. Exploracion del mapa.png>)

*Figura 4. Otra zona de la planta baja de la casa Greyrat, con muebles y personajes.*

![Figura 11. Punto de interés con un objeto que se puede recoger durante la exploración.](<captures/11. Recolectar Objetos.png>)

*Figura 11. Punto de interés con un objeto que se puede recoger durante la exploración.*

![Figura 12. Interacción con el taller de Cliff y Zanoba, donde se consultan encargos.](<captures/12. Interaccion con Zanoba y Cliff.png>)

*Figura 12. Interacción con el taller de Cliff y Zanoba, donde se consultan encargos.*

![Figura 13. Roxy aparece en la biblioteca de Ranoa, su ubicación diurna.](<captures/13. Ubicacion de Roxy.png>)

*Figura 13. Roxy aparece en la biblioteca de Ranoa, su ubicación diurna.*

![Figura 17. Eris se encuentra en el patio de entrenamiento.](<captures/17. Ubicacion de Eris.png>)

*Figura 17. Eris se encuentra en el patio de entrenamiento.*

![Figura 23. Sylphie aparece en la planta baja de la casa Greyrat.](<captures/23. Ubicacion Sylphie.png>)

*Figura 23. Sylphie aparece en la planta baja de la casa Greyrat.*

![Figura 29. Minimapa con zonas visitadas y lugares pendientes de explorar.](<captures/29. Mapa de todo lo que tenemos explorado o por explorar.png>)

*Figura 29. Minimapa con zonas visitadas y lugares pendientes de explorar.*

| Punto de interés | Cómo encontrarlo | Para qué sirve |
| --- | --- | --- |
| Estudio de Rudy | Segundo piso, cuarta puerta de la zona superior | Encontrar y volver a leer la carta de Hitogami |
| Sala de la casa | Planta baja de la casa Greyrat | Encontrar a Sylphie y la familia |
| Patio de Eris | A la izquierda del jardín | Entrenar y conversar con Eris |
| Biblioteca | Universidad de Ranoa, acceso superior izquierdo | Estudiar y hablar con Roxy |
| Taller | Universidad, acceso superior central | Encontrar a Cliff y Zanoba |
| Laboratorio | Universidad, acceso superior derecho | Buscar a Nanahoshi y recibir las primeras cartas |
| Dormitorios | Segundo piso | Descansar y cerrar el día |

## 2. Escena de exploración: Setup → Update → Render

**Dónde inicia:** después del sueño con Hitogami, Rudy despierta en el dormitorio de Eris. Desde ese momento puedo caminar y usar las puertas para salir al segundo piso. La escena del mapa ya forma parte de la campaña; no hay que cargar un proyecto distinto.

**Setup:** `Exploration.new(app)` prepara el mapa, la posición de Rudy, los sprites y la cámara. Los datos del mundo están en `maps.lua` y `exploration_world.lua`. **Update:** `s:update(dt)` procesa movimiento, animaciones y portales. **Render:** `drawWorld()` dibuja mapa, obstáculos y NPC; `s:draw()` agrega los datos fijos del HUD.

**Movimiento:** utilizo `WASD` o flechas para caminar, y `Shift` para correr. La velocidad configurada es de 80 píxeles por segundo al caminar y 150 al correr. La diagonal se normaliza y el desplazamiento se divide en pasos para evitar atravesar obstáculos.

**Colisiones y límites:** las paredes, mesas y cercas bloquean el paso. Las sillas y ciertas decoraciones se pueden atravesar para no obstruir corredores estrechos. La huella de colisión se calcula junto a los pies del personaje, y los límites del mapa evitan salir por una zona sin acceso. Las imágenes muestran estos lugares, aunque la **prueba del bloqueo en movimiento** se aprecia mejor en el video.

**Código:** [escena](https://github.com/Gegdgt/DateSim/blob/main/src/screens/exploration.lua) · [movimiento y cámara](https://github.com/Gegdgt/DateSim/blob/main/src/systems/exploration.lua) · [datos de mapas](https://github.com/Gegdgt/DateSim/blob/main/src/data/maps.lua) · [colisiones](https://github.com/Gegdgt/DateSim/blob/main/src/data/map_collisions.lua).

**VIDEO — Movimiento y colisiones.** Mostrar a Rudy caminando, corriendo con Shift, intentando pasar por una pared o mesa y rodeándola.

**Video del proyecto:** [Ver gameplay](<gameplay/Mushoku Tensei_ Las Cartas del Destino.mp4>) *(enlace preparado; el archivo MP4 no estaba incluido en el ZIP recibido).*




## 3. Habitaciones, transiciones y salida de la escena

Los mapas se conectan mediante puertas, escaleras y accesos exteriores. Cuando Rudy cruza uno de esos puntos, el juego actualiza su mapa y posición sin perder el progreso. Para viajar entre el camino de Sharia y la Universidad se utiliza temporalmente un traslado señalado con `T`, porque el acceso directo del gráfico tiene un muro continuo.

El Día 1 también puedo mostrar los tres dormitorios. Al completar las actividades, las esposas regresan a ellos y Rudy puede descansar. La exploración permite volver a otras pantallas, como las conversaciones, la bolsa, el diario y la pausa; desde la pausa es posible regresar al menú principal.

![Figura 30. Dormitorio de Sylphie, disponible para el cierre de la jornada.](<captures/30. Dormitorio De Sylphie.png>)

*Figura 30. Dormitorio de Sylphie, disponible para el cierre de la jornada.*

![Figura 31. Dormitorio de Roxy con el personaje presente al terminar las actividades.](<captures/31. Dormitorio de Roxy.png>)

*Figura 31. Dormitorio de Roxy con el personaje presente al terminar las actividades.*

![Figura 32. Dormitorio de Eris y acceso a la opción de descanso.](<captures/32. Dormitorio de Eris.png>)

*Figura 32. Dormitorio de Eris y acceso a la opción de descanso.*

**VIDEO — Transiciones y regreso.** Mostrar una puerta o escalera, cambiar de mapa y abrir la pausa para regresar al menú principal.

**Video del proyecto:** [Ver gameplay](<gameplay/Mushoku Tensei_ Las Cartas del Destino.mp4>) *(enlace preparado; el archivo MP4 no estaba incluido en el ZIP recibido).*




**Código:** [conexiones de mapas](https://github.com/Gegdgt/DateSim/blob/main/src/data/map_connections.lua) · [puntos de entrada y NPC](https://github.com/Gegdgt/DateSim/blob/main/src/data/exploration_world.lua) · [integración con la aplicación](https://github.com/Gegdgt/DateSim/blob/main/src/app.lua).

## Comprobación de Map System

| Requisito de Map System | Dónde lo demuestro |
| --- | --- |
| Escena dedicada | Rudy despierta y recorre mapas desde el Día 1 |
| Setup → Update → Render | `Exploration.new`, `s:update` y `s:draw` |
| Personaje y controles | Rudy con `WASD`/flechas y Shift |
| Mapa explorable | Casa Greyrat, patio, Sharia y Universidad |
| Colisiones y límites | Sistema de obstáculos; video recomendado para mostrar bloqueo |
| Al menos tres puntos de interés | Sala/Sylphie, patio/Eris, biblioteca/Roxy, taller y laboratorio |
| Lugares identificables | Sprites, muebles, mapas y minimapa (29) |
| Entrar desde otra escena | Nueva partida → sueño → dormitorio de Eris |
| Salir/regresar | Puertas, escaleras, traslado y pausa |
| Integración | Conversaciones, objetos, misiones, dormitorios y descanso |

## Pruebas de exploración

El repositorio contiene pruebas para movimiento, carrera, accesibilidad y conexión de mapas. En esta versión del portafolio estoy usando las capturas reales del Día 1; el video debe completar la evidencia de colisiones y de transiciones. No afirmo haber vuelto a ejecutar toda la suite al preparar el documento.

**Referencias:** [pruebas generales](https://github.com/Gegdgt/DateSim/blob/main/tests/exploration.lua) · [pruebas de carrera](https://github.com/Gegdgt/DateSim/blob/main/tests/exploration_running.lua) · [recorridos por mapas](https://github.com/Gegdgt/DateSim/blob/main/tests/exploration_driver.lua) · [documentación de conexiones](https://github.com/Gegdgt/DateSim/blob/main/docs/MAPAS_CONEXIONES.md).

---
