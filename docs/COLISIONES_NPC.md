# Colisiones y horarios de exploración

La corrección conserva los PNG y ASE originales. `src/data/map_collisions.lua` define superficies transitables y sólidos en coordenadas de imagen; las zonas no revisadas siguen bloqueadas. La huella de Rudy mide **10 × 6 píxeles**, centrada en los pies: `(x−5, y−6, 10, 6)`. El movimiento avanza en pasos de hasta 2 píxeles y separa ejes para evitar atravesar paredes en diagonal o con un frame largo.

## Caminar y correr con Shift

`src/systems/exploration.lua` permite configurar `E.speed=80` (caminar) y `E.runSpeed=150` (correr), en píxeles del mapa por segundo. `Controls.run` en `src/config/controls.lua` contiene `lshift` y `rshift`. La pantalla consulta esas teclas en cada actualización: la carrera no se guarda en la partida ni se activa mediante un interruptor.

Ambas velocidades usan el mismo movimiento normalizado y la resolución de sólidos en pasos de hasta 2 píxeles. Las colisiones de NPC, paredes y muebles permanecen activas, también con un `dt` grande. Las sillas, sillones y zonas transitables junto a los faroles conservan su geometría corregida.

Se reutiliza el sprite de caminar de Rudy: el reloj de animación avanza al ritmo `runSpeed / speed` cuando corre (1,875 veces con estos valores). Al detenerse vuelve al fotograma de reposo. No se modifica la escala ni el filtro `nearest`. Los diálogos, menús y transiciones bloquean movimiento y carrera; al regresar se lee el teclado actual, incluido un Shift liberado durante el cambio de mapa.

La prueba `tests/exploration_running.lua` cubre los diez requisitos de carrera, los 14 mapas y el guardado sin estado de carrera persistente. Se ejecuta con `$env:DATESIM_TEST_MODULE='exploration_running'; ./probar.ps1` o dentro de la suite completa. [Captura de los controles](../tests/artifacts/exploration-running-controls.png).

## Muebles y accesos

- **Planta baja:** las cajas que incluían sillones y sillas se sustituyeron por las mesas reales: `(105,142,54,26)`, `(464,250,86,33)`, `(463,120,94,26)`, mesa pequeña `(123,245,23,20)` y estantería `(32,224,32,52)`. Las plantas pequeñas dejan de ser obstáculos.
- **Biblioteca:** se estrechan los escritorios a `(88,238,77,28)` y `(347,238,77,28)`, dejando libres sus sillas.
- **Sharia:** el tramo horizontal transitable comienza en y=128 y mide 64 píxeles de alto. Cada farol conserva sólo una base de 8 × 8: `(173,198)` y `(539,198)`. Las columnas junto al acceso usan cajas pequeñas independientes. Los brazos de las lámparas no bloquean el camino.
- Camas, paredes, mesas, estanterías y obstáculos estructurales mantienen sus colisiones. Los portales habilitados se comprueban con la nueva huella.

`passableDecorations` en `exploration_world.lua` documenta las clases transitables: sillas, sillones, asientos, alfombras, plantas pequeñas y flores. La geometría efectiva procede de los rectángulos revisados, no de los colores del PNG. Como los muebles están pintados en el fondo, Rudy pasa visualmente delante de ellos; los sprites dinámicos se ordenan por la coordenada de sus pies. No se inventaron capas de muebles ni se editaron imágenes para simular oclusión.

## Ubicaciones únicas

Las claves del juego omiten el sufijo `_map` del nombre del recurso. Son IDs estables y se relacionan con los sprites existentes:

| Personaje | ID | Día: mapa y pies `(x,y)` | Noche: mapa y pies `(x,y)` |
| --- | --- | --- | --- |
| Eris | `eris` | `patio_eris` · (360,216) | `dormitorio_eris` · (132,112) |
| Roxy | `roxy` | `biblioteca_ranoa` · (200,216) | `dormitorio_roxy` · (104,104) |
| Sylphie | `sylphiette` | `casa_planta_baja` · (196,172) | `dormitorio_sylphie` · (132,112) |

Cliff (224,180) y Zanoba (288,224) permanecen en `taller_cliff_zanoba`; Nanahoshi (312,240), en `laboratorio_nanahoshi`. La interacción exige estar a menos de 30 píxeles del objetivo y tener una línea accesible, sin atravesar paredes. `E.nearCharacter` aplica la misma comprobación al comenzar actividades, historia y encargos.

`E.syncPresence` calcula un registro `exploration.npcLocations` por identidad, valida el suelo y filtra las colocaciones alternativas. Cámara, minimapa, colisiones e interacción consultan esa misma presencia. No se crean nuevas entidades al regresar de una conversación.

## Transición diaria

Al despertar en el prólogo, Eris aparece brevemente en su dormitorio. Salir marca `prologue.wake_departed` y activa el patio; la lectura de la carta también termina esa excepción. Nunca se dibujan las dos colocaciones juntas.

Con cero, una o dos interacciones completadas, las esposas siguen de día. Al cerrar el resultado de la tercera, todas las esposas activas pasan a sus dormitorios y aparece el aviso de fin de jornada. La actividad activa y el recibo pendiente de lectura impiden mover a la interlocutora antes de que termine la conversación. El cierre narrativo del tiempo libre del día 7 también activa el horario nocturno.

El cambio es por el total diario, incluso si las tres actividades fueron con la misma esposa o se gastó un espacio ayudando en el taller. No hay una cuarta actividad. Los objetivos y marcadores se actualizan; si falta una escena obligatoria, el diario mantiene el objetivo de Nanahoshi antes de permitir descansar. Al día siguiente se restaura el horario diurno.

Una esposa separada se excluye de ambas ubicaciones y de las bonificaciones nocturnas. El descanso sólo puede confirmarse junto a la esposa o su cama, una vez por noche. Aplica hasta +10/+10 fuera del margen diurno, conserva las penalizaciones por ausencia y permite dormir solo aunque no quede ningún matrimonio activo.

`period`, `periodDay`, posiciones y orientación se guardan. Al cargar se reconcilian con día, reservas, recibos y separaciones; el guardado no puede adelantar por sí solo el traslado nocturno. [Pruebas y capturas](EXPLORACION_SOCIAL.md).

## Limitaciones conservadas

El portal directo Sharia–universidad sigue deshabilitado porque el PNG no muestra una abertura. El punto **T — Traslado** conecta ambos lados sin atravesar el muro. La verificación de recursos conserva las 18 advertencias preexistentes de cabeceras de capas ASE; no se modificaron sus bytes.
