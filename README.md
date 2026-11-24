# Mushoku Tensei: Las Cartas del Destino

- **Rama** `entrega/progression-cycle`
- **Entrega** Progression Cycles
- **Objetivo** Conectar actividades matrimoniales, estadísticas, eventos, adquisición de cartas y colección en un perfil académico persistente.

**Ejecución con LÖVE 11.5 / LuaJIT** desde la raíz de esta rama en PowerShell

```powershell
& 'C:\Program Files\LOVE\love.exe' . --demo-progression
```

- **Archivos principales** [actividades](src/systems/wife_activities.lua), [progresión diaria](src/systems/daily.lua), [eventos](src/systems/events.lua), [recompensa](src/screens/reward.lua) y [colección](src/systems/card_collection.lua).
- **Pruebas** `./probar.ps1` ejecuta la suite general. Usa `DATESIM_TEST_MODULE=demo_progression` para seleccionar la prueba de la demostración.
- **Repositorio** [Abrir la rama en GitHub](https://github.com/Gegdgt/DateSim/tree/entrega/progression-cycle)

[Guía de la entrega con recorrido, arquitectura y resultados de pruebas](docs/ENTREGA_PROGRESSION_CYCLE.md)

El resto del README describe la campaña, que se abre al ejecutar LÖVE sin argumentos.

Juego narrativo de cartas en español para **LÖVE 11.5 / LuaJIT**. En esta continuidad alternativa, Rudy, Sylphiette, Roxy y Eris son adultos y ya están casados. Una poción vinculada a Hitogami sella la voz y el maná de Rudy; tiene siete días para conseguir el antídoto sin destruir sus matrimonios.

La campaña explorable incorpora **45 actividades matrimoniales**, **255 respuestas contextuales** y descanso en los dormitorios. Se habilitan después de leer la carta de Hitogami y completar la introducción de Nanahoshi. [Informe de exploración 3](docs/EXPLORACION_FASE_3.md) · [Cobertura de diálogos y recompensas](docs/COBERTURA_ACTIVIDADES.md).

**J abre los objetivos del día** en cualquier mapa explorable: historia, progreso total `0/3`, visitas recomendadas como `Eris 3/1`, opcionales y tareas completadas. Usa flechas o rueda para desplazarte y ←/→ para consultar días anteriores. El mapa, el diario y el descanso comparten los mismos requisitos. La carta —H permanece en el estudio para releerla. [Sistema de misiones y corrección del bloqueo](docs/MISIONES.md) · [Progresión diaria](docs/PROGRESION_DIARIA.md) · [Descanso](docs/DESCANSO.md) · [Objetos narrativos](docs/OBJETOS_NARRATIVOS.md).

La integración de los **siete días** conecta ese mundo con el emisario, Orsted opcional, Badigadi, la recuperación de la voz y **cinco finales**. Después del epílogo y el cierre de la última jornada aparece **Resumen de los siete días**, con cifras calculadas de la partida y recuerdos de cada esposa. [Entrega de exploración 4, pruebas A–I y capturas](docs/EXPLORACION_FASE_4.md) · [Cómo ampliar el contenido](docs/AMPLIAR_CONTENIDO.md).

La corrección de exploración social elimina el catálogo global y unifica las manos de cartas. [Cambios, pruebas y capturas](docs/EXPLORACION_SOCIAL.md) · [Configurar costes, contextos y frases](docs/CARTAS_SOCIALES.md) · [Colisiones y horarios de NPC](docs/COLISIONES_NPC.md).

## Ejecutar

```powershell
./ejecutar.ps1
# O bien:
& 'C:\Program Files\LOVE\love.exe' .
```

No requiere red ni paquetes de Lua adicionales. Ventana inicial de 1280 × 720, canvas lógico de 640 × 360 y filtro `nearest`. El menú ofrece campaña, continuación, práctica social y de combate, combate libre, manual y opciones.

## Recursos y mundo explorable

Los **53 PNG nuevos** están organizados en `assets/characters/{portraits,overworld,npc_idle}`, `assets/maps/{greyrat_house,sharia,ranoa}`, `assets/tilesets`, `assets/objects/{items,atlases}` y `assets/animations/horse`. Los **53 ASE originales** están en las mismas categorías bajo `sprite_sources/`, sin conversión ni modificación binaria. El TXT de tilesets y el CSV/JSON del atlas se conservan junto a sus PNG. Los recursos anteriores mantienen sus rutas.

`src/data/assets.lua` incorpora el catálogo `exploration` mediante `src/data/exploration_assets.lua`. Se carga bajo demanda con `Resources:getExploration(grupo,id)`; `Resources:getObjectSprite(id)` comparte un solo atlas para todos los objetos. El audio existente sigue usando `src/data/audio.lua` y síntesis; `assets/audio/` y `assets/ui/` quedan preparados para futuros archivos.

`src/data/maps.lua` registra **14 mapas**, `map_connections.lua` define **13 enlaces bidireccionales** y `map_collisions.lua` separa suelo revisado, obstáculos y accesos. Ya puedes caminar con Rudy, saludar a su familia y consultar el minimapa. La campaña nueva empieza con el sueño de Hitogami y entrega el control junto a la cama de Eris. La historia espera a que recojas y termines de leer la carta en la cuarta puerta del segundo piso: el estudio. Los fondos de conversación de 320 × 180 siguen siendo recursos distintos.

Hay **12 enlaces calibrados y uno pendiente**: el acceso izquierdo de la universidad no presenta una abertura visible en el PNG. Además, los 18 ASE de mapas/tilesets traen registros de capas no estándar; se conservan sus bytes y se documenta la incidencia, sin certificar su apertura en LibreSprite. Consulta el [inventario completo, hashes y recuperación](docs/ASSETS_INVENTORY.md) y el [diagrama, coordenadas y convenciones](docs/MAPAS_CONEXIONES.md).

Un punto **T — Traslado** permite viajar entre Sharia y la universidad en ambos sentidos; el portal del muro continúa desactivado. Tras descubrir la maldición, camina hasta Nanahoshi e interactúa con ella. [Entrega de exploración: estados, controles, capturas, archivos y pruebas](docs/EXPLORACION_FASE_1.md).

### Exploración 2: familia, hallazgos e inversiones

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

## Campaña completa

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

## Cartas, emociones y relaciones

Nanahoshi entrega **diez cartas en total**: cinco sociales y cinco físicas. Los mazos empiezan vacíos y admiten después entre cinco y diez cartas adquiridas cada uno. Las cartas parlantes muestran una respuesta contextual con la voz encantada indicada en pantalla y un efecto sonoro; esta versión no incluye doblaje grabado.

Las entregas múltiples permiten **ver una por una o recibir todas**, con resumen paginado y opción de omitir. La celebración muestra los participantes del evento: Rudy, Nanahoshi, Cliff y Zanoba aparecen juntos en la investigación del cuarto día; otras entregas conservan su interlocutor. Las copias, niveles y desbloqueos se conceden antes de animar y se conservan al guardar. [Entrega de cartas y controles](docs/ENTREGA_CARTAS.md).

En cada conversación se animan los intercambios reales del mazo **equipado, adquirido y compatible** y se toman tres cartas con los marcos e iconos originales. Las cinco cartas iniciales tienen respuesta en las 45 actividades matrimoniales; las dos primeras jugadas se reponen para mantener tres opciones antes de cada turno, sin reciclar el descarte. El tutorial conserva un reparto guiado. Selecciona una carta para leer **«Rudy dirá»**, su intención y su coste; puedes cancelar antes de usarla. Cada encuentro social admite hasta tres cartas y seis puntos de energía total. Jugar descarta la carta y toma la siguiente si quedan turnos; **P** permite terminar una actividad matrimonial; en las escenas narrativas permite escuchar en silencio sin energía ni voz gratuita. Cargar conserva la mano y el orden restante.

Las conversaciones de Nanahoshi, Eris, Roxy y Sylphiette utilizan respuestas escritas por situación. La carta abre la frase de Rudy, la reacción de la otra persona y una continuación; amor, confianza y memoria se aplican al mostrar la reacción. Los números indican el cambio real, respetando el límite de −100–100. Una broma ante el entrenamiento de Eris, una duda sobre la fórmula de Roxy y una promesa a Sylphiette producen consecuencias distintas. La promesa de tiempo familiar puede cumplirse o incumplirse el día tres, recordarse el cuarto y repararse expresamente el quinto.

El inventario contiene **15 cartas sociales, seis híbridas y 19 de combate**. El catálogo escrito cubre nueve conversaciones de entrada; el [informe de cobertura](docs/COBERTURA_DIALOGOS.md) distingue respuestas, variantes, continuaciones y combinaciones posibles. Todo funciona sin conexión mediante tablas Lua, sin generación de texto durante la partida. [Guía de conversaciones y autoría](docs/DIALOGOS.md).

La carta firmada por **—H** es un documento, separado de ambos mazos. Se recoge mediante clic o teclado, se abre con animación y queda disponible en **J → Carta —H**. Leerla o cargar una partida no duplica sus eventos ni los regalos.

Cada personaje utiliza sus cuatro expresiones reales y movimientos breves. Las tres relaciones empiezan en **50 de amor y 50 de confianza**, con límites de −100–100. Promesas, conflictos, decisiones, reconciliaciones y misiones afectan los diálogos y el desenlace; curarse no repara automáticamente los matrimonios. [Sistemas](docs/SISTEMAS.md).

Sobre los retratos se muestran barras animadas con valores y cambios con signo. Las esposas tienen **Amor y Confianza**; Nanahoshi, **Confianza e Interés**, sin añadirse a los finales matrimoniales. Solo cinco cartas sociales pueden despertar su interés. El día cinco incluye un duelo real contra Eris, evaluado por estrategia y esfuerzo: una derrota honesta no recibe el castigo por dejar pasar repetidamente oportunidades claras. [Barras, afinidad y reglas del entrenamiento](docs/AFINIDAD_Y_ENTRENAMIENTO.md).

En el sueño inicial, Rudy recupera el cuerpo japonés de su vida anterior y aparece junto a Hitogami. Al despertar en casa vuelve a su aspecto rubio. Ambos retratos pertenecen a la misma identidad: el contexto visual no cambia relaciones, maldición ni progreso. Guardar y continuar recupera fondo, apariencia y expresión desde la línea narrativa. [Retratos contextuales y autoría](docs/RETRATOS.md).

## Combate

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

## Guardado y pruebas

La continuidad `rudy_curse` conserva **versión 8**, ampliada con `exploration.version=1`. Guarda en `%APPDATA%\LOVE\cartas_del_destino\campaign-exploration-v1.json`, con respaldo `campaign-exploration-v1.backup.json`. Incluye posición, orientación, prólogo, página de la carta, objetivo, lugares visitados y recursos, además de los sistemas anteriores. **Continuar** recupera v8/v7/v6/v5/v4 conservando su historia y archivos originales; esos archivos nunca se sobrescriben. Las campañas anteriores mantienen su recorrido narrativo. El menú también permite importar la colección compatible de v1/v2/v3, comenzando una nueva campaña. [Formato y recuperación](docs/GUARDADO.md).

```powershell
./probar.ps1
# O bien:
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

La suite usa la identidad aislada `cartas_del_destino_v8_tests` y genera capturas en `tests/artifacts/`. Los resultados realmente ejecutados y sus límites figuran en [VERIFICACION.md](docs/VERIFICACION.md). [Entrega y archivos](docs/REESTRUCTURACION.md), [manual](docs/MANUAL.md), [animaciones](docs/ANIMACIONES.md), [audio](docs/AUDIO.md) y [recursos](assets/README.md).

Para revisar una partida humana sin tocar tu guardado habitual, ejecuta `./revisar.ps1`. Abre una campaña normal con identidad separada; **F8** guarda una captura y su checkpoint. Para ejecutar los once perfiles de balance usa `DATESIM_TEST_MODULE=seven_day_balance`; el [informe](docs/FASE_6_INFORME.md#ejecución-y-reproducción) contiene los comandos completos y la selección de semilla.

Se conservan los PNG y ASE existentes. Música y efectos son síntesis original sencilla; la valoración auditiva y las pruebas prolongadas con jugadores siguen siendo trabajo de producción.
