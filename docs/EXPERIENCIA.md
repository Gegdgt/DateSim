# Presentación, tutorial y accesibilidad

> Referencia histórica de la base anterior. La campaña matrimonial actual, sus siete días, cinco finales, cartas adquiridas y guardado v2 se documentan en [README](../README.md) y [REESTRUCTURACION](REESTRUCTURACION.md).

Esta ampliación conserva los días uno a tres, sus decisiones, sus recompensas y los PNG/ASE originales. No añade capítulos. La resolución lógica sigue siendo 640×360, con escalado entero, fuente bitmap y filtro `nearest`.

## Leer las cartas

La cara de 80×112 muestra el pergamino y marco originales, un nombre corto, el icono de 24×24 y el coste de energía. No contiene descripción ni una segunda etiqueta de categoría. El panel externo muestra el nombre completo y los datos necesarios para decidir. La categoría se reconoce también por su nombre en ese panel, sin depender únicamente del color del marco.

`src/data/cards.lua` declara `shortName` y `unlockHint` para las dieciséis cartas. `shortName` solo afecta a la interfaz; `id`, `name`, efectos, costes y requisitos conservan su significado. Las etiquetas usan la fuente nativa de 5×7 dentro de una región de 64×11. No se reduce su tamaño para encajar nombres largos.

| Nombre completo | Etiqueta en la carta |
| --- | --- |
| Recordar un detalle | RECORDAR |
| Hablar con honestidad | HONESTIDAD |
| Reírse de uno mismo | AUTOHUMOR |
| Reconocer un error | DISCULPA |
| Conjuro Combinado | CONJURO |

`src/ui/card.lua` compone las mismas capas en la mano y en la colección. Los textos se dibujan con Lua; ninguna imagen incorpora letras nuevas. Los estados de disponibilidad acompañan la carta con texto, además de resaltados.

## Conseguir cartas y consultar el mazo

El mazo inicial de diez cartas se equipa automáticamente al comenzar. Su contenido sigue fijo en esta versión: no hay un editor interactivo ni un botón que prometa equipar una carta. Desbloquear una carta la añade a la colección, sin reemplazar silenciosamente otra del mazo ni añadir una undécima.

La colección (`M`) mantiene las dieciséis cartas accesibles y las agrupa en **equipadas**, **desbloqueadas sin equipar** y **bloqueadas**. Cada grupo tiene icono, nombre y contador. Seleccionar una fila muestra imagen, nombre completo, categoría, coste, efecto, contextos recomendados, afinidad o condición de compañía, estado y obtención conocida.

- Las diez cartas iniciales están disponibles desde el comienzo.
- Reírse de uno mismo se obtiene al completar la primera anomalía del día uno.
- Recordar un detalle se obtiene al completar los tres reencuentros del día dos. El Sello de la Verdad conserva el desbloqueo compatible del día tres, sin copias adicionales.
- Las cartas exclusivas indican su ruta y día cinco; Elegir Juntos indica el capítulo final. Esos capítulos siguen pendientes y sus cartas permanecen bloqueadas.

Las recomendaciones de contexto y los efectos base de la colección se leen de `contexts` y `effects`; no hay una segunda tabla de bonificaciones de interfaz. El texto de obtención informa de requisitos conocidos sin contar los desenlaces.

## Seleccionar, confirmar y entender un resultado

En un encuentro, el clic o las teclas `1`, `2`, `3` seleccionan una carta para consultar su ficha. Izquierda/Derecha cambia la selección. Enter/Espacio o el botón de jugar confirman la carta seleccionada. Separar consulta y confirmación permite leer un nombre largo y su coste antes de gastar energía.

La vista previa distingue efecto base, contexto actual y adecuación. El resultado procede del cálculo real del motor: coste pagado, efecto básico, modificador de contexto, afinidad y total. `Cards.preview` devuelve `base`, `contextBonus`, `affinityBonus` y `targetAdjustment`, además de los totales de avance, confianza y química. La interfaz consulta esos registros; no vuelve a calcular las bonificaciones por su cuenta. Un signo `-` y el texto identifican una variación negativa; el color es un refuerzo visual. Nanahoshi participa en la investigación, sin recibir confianza ni química románticas: el renglón «Sin romance» explica el ajuste que elimina esos puntos para ella.

El registro breve conserva las acciones del encuentro y permite consultar lo ocurrido con `H` o el botón Historial, sin cambiar de conversación. Después de tres turnos, el resumen confirma los efectos de relación una sola vez mediante los eventos existentes. El bloqueo durante la resolución evita que una pulsación repetida juegue también la carta recién robada.

Las reglas no cambian: diez cartas en el mazo, tres en la mano, tres turnos, cuatro de energía total, costes entre cero y dos, descarte y robo al jugar. Tomar un respiro consume un turno, no energía, y no roba ni descarta. Sigue siendo una salida válida cuando la mano no ofrece una acción pagable.

## Práctica interactiva con Nanahoshi

La práctica se integra en el primer encuentro del laboratorio. `src/systems/tutorial.lua` controla el orden de instrucciones a partir de acciones reales y conserva el paso actual al guardar. Los pasos que exigen seleccionar, jugar o tomar un respiro no avanzan con un botón genérico de continuar.

1. **Mano:** identifica las tres acciones disponibles y resalta una recomendación inicial.
2. **Energía:** explica cuatro unidades para los tres turnos, costes de cero a dos y mazo inicial equipado.
3. **Decisión:** exige seleccionar una carta y consultar su ficha antes de confirmarla.
4. **Animación:** eleva y desplaza la carta; bloquea nuevas jugadas durante su resolución.
5. **Consecuencias:** presenta la reacción de Nanahoshi y el desglose del resultado aplicado.
6. **Robo:** muestra descarte y reemplazo de la carta, y permite jugar un segundo turno.
7. **Acción gratuita:** comprueba una Barrera de Tierra con energía cero en una copia de demostración. **La energía real del encuentro no cambia.** Después exige usar Tomar un respiro en el tercer turno.
8. **Cierre:** permite revisar las tres acciones y explica avance, confianza, química y desbloqueos de historia.

Completar la guía registra `tutorial_completed` en los eventos y `tutorialCompleted` en las preferencias globales. Una partida posterior puede omitir las instrucciones ya aprendidas; no se omite el encuentro ni se repiten sus recompensas. Una guía interrumpida se restaura según el registro de acciones, sin volver a cobrar una carta ni conceder efectos nuevos.

## Movimiento y lectura

`src/systems/animation.lua` contiene interpolaciones y movimientos finitos reutilizables. Las posiciones se redondean al dibujar; los sprites mantienen escala entera. Las animaciones de cartas cubren hover, selección, desplazamiento al jugar, señal de categoría, descarte y robo. No añaden suavizado de imagen ni modifican el estado de las reglas.

Los personajes pueden entrar o salir de lado, aparecer gradualmente, hacer un pequeño movimiento al hablar, reaccionar con un rebote a una expresión feliz o temblar brevemente al enfadarse. No hay un rebote continuo en reposo. Las cuatro expresiones siguen usando sus recortes originales de 64×64.

Una escena o línea puede declarar `animation`; una escena puede declarar `exitAnimation`. Los nombres admitidos son `enter_left`, `enter_right`, `happy_bounce`, `shake`, `expression_change`, `exit_left`, `exit_right` y `speaking`. `line.expression` selecciona la expresión; una declaración `{type="expression_change", expression="happy"}` permite asociar el cambio a la animación. Las escenas anteriores sin estos campos siguen funcionando.

`src/systems/typewriter.lua` muestra puntos de código UTF-8, sin dividir bytes de tildes o signos. Una pulsación revela el texto y otra avanza. La velocidad se configura en opciones; la escritura instantánea es independiente del movimiento reducido. El indicador de continuar se mueve suavemente y queda fijo con movimiento reducido.

## Transiciones entre pantallas

`src/core/state_manager.lua` centraliza `fade`, `fade_in`, `horizontal`, `new_day`, `magic` y `return`. Captura la imagen saliente para evitar que una pantalla antigua lea el checkpoint nuevo. Cada pantalla entrante se activa una sola vez; no se aceptan transiciones concurrentes ni entrada durante el tramo bloqueado. El reloj del texto nuevo empieza al despejarse la transición.

Los datos narrativos admiten `transition={type="horizontal",duration=.35}` en la definición de una escena para configurar su salida. Las transiciones normales se limitan a 0,25–0,6 segundos. Movimiento reducido utiliza un fundido breve y elimina los desplazamientos; conserva los mismos destinos, acciones y recompensas. `src/data/presentation.lua` centraliza los contextos musicales por lugar y los valores compatibles con las tablas anteriores; una escena puede declarar `music="forest"` u otro contexto del manifiesto.

## Audio y opciones

Hay melodías instrumentales originales generadas por síntesis para `menu`, `university`, `casual`, `romantic`, `mystery`, `forest`, `tension`, `mirror` y `festival`, además de diez señales breves de interfaz y juego. Son acompañamientos provisionales sencillos, no grabaciones del anime. El gestor admite pistas locales y funciona con silencio si falta un recurso y no hay síntesis de respaldo. El manifiesto, API, límites de voces y procedimiento para añadir pistas se documentan en [AUDIO.md](AUDIO.md).

Opciones permite cambiar volumen maestro, música, efectos, silencio, velocidad del texto, escritura progresiva/instantánea, movimiento reducido y pantalla completa. Se guardan al cambiarlas en `options.json`, independientemente de la partida. `volume` conserva el nombre usado por las versiones anteriores. F11 también cambia la preferencia de pantalla completa.

## Módulos y comprobaciones

| Módulo | Responsabilidad |
| --- | --- |
| `src/data/cards.lua` | Datos completos, etiquetas cortas y obtención conocida |
| `src/ui/card.lua` | Cara de carta compartida y regiones de texto |
| `src/screens/collection.lua` | Agrupación y consulta de las dieciséis cartas |
| `src/systems/cards.lua` | Cálculo, desglose y registro de efectos reales |
| `src/systems/tutorial.lua` | Orden de instrucciones, restauración y finalización |
| `src/screens/encounter.lua` | Consulta, confirmación, animaciones y resultados |
| `src/systems/animation.lua` | Movimientos e interpolaciones finitas |
| `src/systems/typewriter.lua` | Texto progresivo UTF-8 |
| `src/core/state_manager.lua` | Transición única y bloqueo de entrada |
| `src/data/presentation.lua` | Contextos por lugar y valores predeterminados para la narrativa |
| `src/systems/audio.lua`, `src/data/audio.lua` | Síntesis original, manifiesto, mezcla y contexto |
| `src/systems/options.lua`, `src/screens/options.lua` | Preferencias normalizadas y controles |

`tests/card_collection.lua` comprueba las dieciséis caras a tamaño nativo, datos completos, márgenes del panel, grupos, mouse/teclado y ausencia de modificaciones al consultar. La suite completa mantiene los recorridos de los días uno a tres y añade pruebas de tutorial, efectos, entradas repetidas, animaciones, transiciones, UTF-8, audio y preferencias. Los resultados efectivamente ejecutados y las capturas se registran en [VERIFICACION.md](VERIFICACION.md), no en una cifra fija dentro de este documento.

El editor de mazo, las pistas definitivas grabadas, los capítulos cuatro a siete y la distribución autónoma siguen pendientes. Las mejoras de presentación no equivalen a esos contenidos.
