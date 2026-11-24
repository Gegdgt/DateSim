# Entrega de Map System

## Ejecutar la demostración

Abre PowerShell en la raíz de `entrega/map-system` con LÖVE 11.5 instalado.

```powershell
& 'C:\Program Files\LOVE\love.exe' . --demo-map
```

También puedes usar `love . --demo-map` si el ejecutable está en el PATH. Selecciona **Empezar desde el dormitorio de Eris**. **F9** abre el menú y **Continuar explorando** vuelve a la última posición de la sesión. La exploración académica vive en memoria y usa la identidad de LÖVE `cartas_del_destino_demo_mapa` para las preferencias.

## Controles y ruta

**WASD** o **flechas** mueven a Rudy. **Shift** corre, **E** examina, saluda o abre un traslado, **Enter** confirma y **M** abre el minimapa. Usa la lista de visitados para comprobar el recorrido.

| Tramo | Qué hacer |
| --- | --- |
| Dormitorio de Eris → segundo piso | Camina por la abertura inferior central del dormitorio. |
| Segundo piso → estudio de Rudy | Entra por la cuarta puerta de arriba, con paño ocre. Acércate al escritorio y pulsa **E** junto a la carta. **Esc** cierra la escena y devuelve a Rudy a la misma posición. |
| Estudio → segundo piso → planta baja → jardín | Regresa al pasillo del segundo piso y baja por la escalera inferior central. Cruza la planta baja hasta la puerta inferior que da al jardín. |
| Jardín → patio de Eris | Toma la salida oeste de la cerca a la altura del sendero horizontal. Acércate a Eris y salúdala con **E**. |
| Patio → jardín → camino de Sharia | Sal del patio por la abertura este y atraviesa el sendero sur del jardín. |
| Sharia → exterior de la Universidad | Ve hacia el este, hasta la parada lila **T** en `(672, 160)`. Pulsa **E** y confirma con **Enter**. La parada **T** de la Universidad también permite volver. |
| Exterior → biblioteca de Ranoa | Sigue el sendero de la izquierda a la primera puerta de la fila superior. En la biblioteca puedes saludar a Roxy con **E**. Las puertas central y derecha llevan al taller y al laboratorio. |

La **T** identifica la parada. El acceso físico Sharia–Universidad conserva el estado deshabilitado debido al muro continuo del PNG. El traslado y los portales calibrados usan los fundidos y los puntos de llegada del mundo. [Plano, coordenadas y accesos del mundo](MAPAS_CONEXIONES.md)

## Comprobación de colisiones

En el segundo piso, mueve a Rudy hacia el paño de pared entre puertas. En la planta baja, prueba la mesa de la izquierda desde el sur, rodea la mesa por el pasillo y cruza las sillas por el lateral. En el patio, corre hacia una sección cerrada de la cerca y recórrela hasta la abertura. Compara el mismo intervalo de marcha recta y diagonal en suelo libre. El motor normaliza la diagonal y comprueba la huella de pies de **10 × 6** en pasos de hasta dos píxeles de mapa tanto a **80 px/s** como a **150 px/s**.

| Caso | Punto de partida de las pruebas, en píxeles del mapa |
| --- | --- |
| Mesa sólida | Planta baja `(130, 180)`, hacia arriba. |
| Pared entre accesos | Segundo piso `(260, 144)`, hacia arriba. |
| Cerca y límite | Patio de Eris `(240, 310)`, hacia abajo. |
| Decoración transitable | Planta baja `(65, 160)`, hacia la derecha por las sillas. |

## Setup, Update y Render

| Etapa | Código y datos |
| --- | --- |
| Setup | `src/demos/map.lua` usa `src/systems/prologue.lua` para iniciar desde la posición real de Rudy. `src/data/maps.lua` asocia los PNG a dimensiones, posiciones, NPC y objetos de `src/data/exploration_world.lua`. `src/data/map_collisions.lua` aporta suelo y obstáculos y `src/data/map_connections.lua` registra portales y llegadas. |
| Update | `src/screens/exploration.lua` lee el teclado, detecta E y gestiona escenas y transiciones. `src/systems/exploration.lua` actualiza posición y orientación, normaliza la diagonal, detecta colisiones y selecciona el punto de interés. `src/systems/map_validation.lua` verifica geometría y accesibilidad. |
| Render | La pantalla dibuja mapa, decoración, objetos y sprites de Rudy y los NPC en orden de profundidad. La cámara ajusta el encuadre a los límites del mapa. El HUD, el minimapa y el texto de interacción se componen en el canvas lógico. |

## Pruebas

```powershell
$env:DATESIM_TEST_MODULE = 'demo_map'
./probar.ps1
$env:DATESIM_TEST_MODULE = 'exploration'
./probar.ps1
$env:DATESIM_TEST_MODULE = 'exploration_running'
./probar.ps1
$env:DATESIM_TEST_MODULE = 'exploration_visual'
./probar.ps1
$env:DATESIM_TEST_MODULE = 'exploration_assets'
./probar.ps1
Remove-Item Env:DATESIM_TEST_MODULE
./probar.ps1
```

La prueba `demo_map` pasó **34 comprobaciones** con **7 capturas** en `tests/artifacts/demo-map-*.png`. Recorrió los portales desde el dormitorio, cerró la carta en el estudio, verificó teclado y carrera, visitó el patio, usó el traslado en ambos sentidos y saludó a Roxy en la biblioteca. Verificó el retorno desde el menú y el reinicio temporal.

- `exploration` pasó **773 comprobaciones** y generó **12 capturas** de exploración, transiciones e interacción.
- `exploration_running` pasó **76 comprobaciones** de movimientos, velocidad diagonal, colisiones y transiciones.
- `exploration_visual` pasó y generó **14 superposiciones** de geometría.
- `exploration_assets` pasó **3 736 comprobaciones** en una copia nueva con `core.autocrlf=true`, incluidos los SHA-256 del inventario.

El arranque directo con `love.exe . --demo-map` abrió la ventana **Sistema de mapas**.

La suite general `./probar.ps1` terminó con código 0 y `ALL TESTS PASSED`. La integración de exploración incluyó nueve rutas reproducibles de la campaña y 7 602 comprobaciones.
