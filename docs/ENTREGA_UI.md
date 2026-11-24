# Entrega de sistemas de interfaz

## Ejecutar la demostración

Abre PowerShell en la raíz de `entrega/ui-system` con LÖVE 11.5 instalado.

```powershell
& 'C:\Program Files\LOVE\love.exe' . --demo-ui
```

También puedes usar `love . --demo-ui` si el ejecutable está en el PATH. El menú acepta clic o Tab y Enter. **F9** regresa desde cualquier pantalla. Cada ejercicio comienza con una sesión en memoria. El modo usa la identidad de LÖVE `cartas_del_destino_demo_ui` para sus preferencias. F5 informa que la sesión es temporal.

## UI 1 · HUD de exploración

Selecciona **HUD de exploración · Patio de Eris**. El encabezado muestra el patio y el día 1. Mueve a Rudy unos pasos a la derecha para acercarte a Eris y ver el indicador **E**. La cámara sigue al personaje y el nombre del mapa, el día, el objetivo y los controles se mantienen en el HUD. **M** muestra suelo, puertas, personajes, puntos de interés y lugares visitados. **J** abre el diario de objetivos.

| Etapa | Implementación |
| --- | --- |
| Setup | `src/demos/ui.lua` crea la sesión al despertar y la coloca en el punto inicial definido para el patio. `App:explore()` prepara la presencia de NPC, los recursos y la escena. |
| Update | `src/screens/exploration.lua` lee movimiento e interacción. `src/systems/exploration.lua` calcula posición, portales, cámara y el punto de interés más cercano. |
| Render | `drawWorld()` aplica cámara y recorte. `draw()` pinta las barras y el objetivo en coordenadas del canvas de 640 × 360. `src/ui/objective_journal.lua` muestra el diario. |
| Dependencias | Mapas, recursos de exploración, prólogo, diario y controles de `src/config/controls.lua`. |

## UI 2 · Conversaciones con cartas

Selecciona **Conversación con cartas · Sylphie** y elige una de las tres actividades. Pulsa **Enter** o **Preparar las cartas** para ver el reparto. Elige una carta con **1–3**, flechas o clic. La vista previa muestra la frase de Rudy, el coste de energía y el retrato de Sylphie. Confirma con **Enter** y compara las barras de amor y confianza al llegar la reacción. Las cartas y el contexto determinan los cambios. **P** termina la actividad desde la mano. **Tutorial social · Nanahoshi** abre el encuentro guiado que aparece en la campaña.

| Etapa | Implementación |
| --- | --- |
| Setup | La sesión de Sylphie se sitúa en la agenda del día 1. El evento inicial equipa el mazo. El tutorial opcional entra por `App:startPractice()`. |
| Update | `src/screens/wife_activities.lua` confirma la selección y avanza el reparto, la voz, la reacción y la reposición. `src/systems/wife_activities.lua` resuelve costes y efectos. `src/screens/encounter.lua` usa el flujo equivalente de práctica. |
| Render | `src/ui/social_hand.lua` anima la mano y consulta sus cartas reales. `src/ui/card.lua` dibuja marcos e iconos y `src/ui/relationship_bars.lua` presenta valores y deltas aplicados. |
| Dependencias | Catálogo de cartas, respuestas escritas, retratos, equipo de cartas, eventos, colección y audio. |

## UI 3 · Combate

Selecciona **Combate libre · Anomalía** y pulsa **Enter** para cerrar la introducción táctica. Revisa vida, escudo, energía externa, acciones, cartas e intención enemiga. **D** defiende, **V** esquiva, **1–3** o clic seleccionan la carta, **Enter** la juega y **E** termina el turno. Usa cartas de daño para ver las animaciones y llegar a **Victoria**. En otro intento, termina turnos sin atacar para ver **Derrota**, **Reintentar** y **Regresar al punto seguro**. La práctica vuelve al menú al continuar después de una victoria.

| Etapa | Implementación |
| --- | --- |
| Setup | `App:startPractice("free")` crea una sesión, equipa las cinco técnicas iniciales y abre el combate de la anomalía. |
| Update | `src/systems/combat.lua` verifica jugadas, acciones, intención, daño y resultado. `src/screens/combat.lua` recibe los comandos y anima sus cambios. |
| Render | `src/screens/combat.lua` compone HUD, personajes, cartas, resultados y registro. `src/ui/widgets.lua` aporta paneles, barras y botones compartidos. |
| Dependencias | Técnicas, reglas de combate, enemigos, maldición, retratos, cartas, audio y gestor de escenas. |

## Pruebas

```powershell
$env:DATESIM_TEST_MODULE = 'demo_ui'
./probar.ps1
$env:DATESIM_TEST_MODULE = 'war_ui'
./probar.ps1
Remove-Item Env:DATESIM_TEST_MODULE
$env:DATESIM_TEST_GROUP = 'entrega_ui'
./probar.ps1
Remove-Item Env:DATESIM_TEST_GROUP
```

La prueba `demo_ui` pasó **22 comprobaciones** y generó **8 capturas** en `tests/artifacts/demo-ui-*.png` con el renderizador de LÖVE. Ejercitó el teclado y el ratón, el HUD con la cámara en movimiento, el minimapa y el diario, la animación social, la defensa, el daño, la derrota y la victoria. También verificó el retorno al menú, F5 y el cierre de la sesión temporal.

`war_ui` pasó **10 comprobaciones** y generó **12 capturas** de combate.

El arranque directo con `love.exe . --demo-ui` abrió la ventana **Sistemas de interfaz**.

La suite general terminó con código 0 y `ALL TESTS PASSED` con la identidad de pruebas `entrega_ui`. Incluyó 40 rutas de campaña y los cinco finales. `combat_visual` pasó **44 comprobaciones** con **22 capturas** cuando la suite le proporcionó una instancia de `App`. Seleccionar ese módulo directamente mediante `DATESIM_TEST_MODULE` devolvió código 1 en esta rama y en el commit base.
