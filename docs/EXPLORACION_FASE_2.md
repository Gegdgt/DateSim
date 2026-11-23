# Exploración 2: familia, objetos y encargos

Implementada el 22 de noviembre de 2026 sobre la fase 1, con LÖVE 11.5 / LuaJIT. Se reutilizan el movimiento, la cámara, los mapas, los sprites definitivos, la economía, la agenda y el guardado. No se movieron ni editaron recursos binarios.

## Familia y conversaciones

| Personaje | Presencia | Reacciones |
| --- | --- | --- |
| Lilia | Cocina, `lilia_idle` | Hogar, limpieza, responsabilidades y cuidado de Zenith |
| Aisha | Paso cocina/comedor, `aisha_idle` | Organización, iniciativa y ayuda a la familia |
| Norn | Zona familiar, cerca de Zenith, `norn_idle` | Estudios, Lucy y acompañamiento a su madre |
| Zenith | Zona familiar, `zenith_lucy_idle` | Miradas, sonrisas y movimientos; sin discursos normales |
| Lucy | En brazos de Zenith, dentro del mismo sprite | Balbuceos, sonrisas, movimientos y atención a Rudy |

E frente a Zenith abre una elección: **1 Zenith / 2 Lucy**. Lucy tiene retrato y memoria de conversación propios, sin duplicar su figura en el mapa. `lucy_idle` sigue disponible para eventos que la separen de los brazos de Zenith; esta fase mantiene a ambas juntas.

Los once interlocutores del mundo tienen al menos ocho respuestas originales: cinco familiares, Eris, Roxy, Sylphiette, Cliff, Zanoba y Nanahoshi. Roxy incluye una variante adicional después de la introducción. La selección tiene en cuenta día y estado, evita la respuesta inmediatamente anterior y guarda su memoria. Las animaciones de dos cuadros usan el reloj del mundo, incluso con una conversación abierta.

Antes de leer la carta, los saludos solo cambian esa memoria. No gastan espacios, no dan amor/confianza, no descubren la maldición ni entregan cartas. Rudy saluda con un pensamiento y un gesto. Después de la introducción, terminar el saludo de Roxy, Cliff o Zanoba abre sus servicios cuando la agenda permite actividades; las conversaciones largas siguen usando los sistemas anteriores.

## Objetos y hallazgos

Los 16 recursos de objetos existentes se utilizan como recompensas, decoración o elementos reservados. La caja del taller cambia de cofre cerrado a abierto al recoger su material. Escoba, pergamino doméstico, anillo y reactivos se examinan sin apropiarse de ellos. El patrón de Nanahoshi es una muestra, no una entrega gratuita de cartas. El antídoto solo se muestra cuando ya se ha obtenido por la historia; examinarlo no lo consume ni lo concede.

La carta `hitogami_letter` sigue únicamente en `estudio_rudy`. Su interacción se delega a `exploration_letter`; no pertenece al generador, tienda, inventario consumible ni mazos. Sigue siendo posible guardarla sin terminar, completar su lectura y releerla desde el diario.

Al completar la introducción con Nanahoshi y la primera anomalía (`first_anomaly`, o `day1_complete` en partidas compatibles), se generan **1–3 objetos por día**. Hay ocho posiciones revisadas: planta baja, segundo piso, jardín, patio, Sharia, universidad, biblioteca y laboratorio. Se comprueba la huella real, la distancia a NPC y la separación de portales. Las pruebas recorren físicamente el suelo hasta ellas. Nunca se generan hallazgos en el cementerio.

El generador guarda una semilla por campaña y las instancias concretas por día. No vuelve a sortear al entrar o cargar. Los objetos recogidos desaparecen durante ese día; los únicos conservan su registro entre jornadas. Las recompensas son oro, copias de cartas sociales/físicas, libros comunes, materiales y fragmentos. El indicador existente aparece al acercarse. E muestra nombre, una breve elevación del icono y el resultado.

I muestra el inventario real de `economy.items` y el saldo. F consume un fragmento para añadir dos puntos de energía externa, limitada a 30; no elimina la maldición. Los libros comunes y materiales mantienen los usos de la economía anterior. La flor de fase 1 se conserva y no vuelve a recogerse.

## Inversiones

Configuración central: `src/data/commissions.lua`. Las probabilidades no están en los botones.

| ID | Encargado | Coste | Éxito | Posible recompensa | Devolución al fallar |
| --- | --- | ---: | ---: | --- | ---: |
| `social_research` | Cliff | 15 | 70 % | 2 Escuchar o 1 libro común | 0 |
| `enchantment_research` | Cliff | 20 | 60 % | 2 materiales o 1 Analizar runas | 5 |
| `physical_cards` | Zanoba | 20 | 65 % | 2 Bastón o 2 Corte sencillo | 0 |
| `gather_materials` | Zanoba o Cliff | 15 | 75 % | 2 materiales o 1 material + 8 oro | 0 |

Tras el saludo, **1** abre «¿EN QUÉ QUIERES QUE TE AYUDE?». La agenda ofrece la misma pantalla. Primero se revisa la tarea y después se confirma el contrato. Solo entonces se descuenta oro. Se comprueba que el saldo no haya cambiado desde la revisión.

Hay un encargo total al día, compartido por ambos encargados, y no puede repetirse el ID solicitado ayer, aunque cambie quien lo realiza. Tampoco se duplica una tarea pendiente. El coste, probabilidad, tirada y recompensa concreta se guardan al iniciar el contrato. La entrega siguiente no vuelve a sortear. Los resultados pueden ser éxito o fracaso; un fallo pierde la inversión menos la devolución especificada, sin un premio de misión adicional que anule esa pérdida.

La entrega normal ocurre al comenzar el día siguiente. **H / Ayudar ahora** abre una advertencia explícita: «Ayudar consumirá una interacción que podrías dedicar a tus esposas». Confirmar consume una sola interacción y entrega hoy; cancelar no cambia nada. La ayuda no cambia la tirada, no cobra de nuevo y no cuenta como visita a una esposa. En el día siete solo se acepta solicitar y ayudar de inmediato; sin espacios disponibles no se inicia un contrato con entrega imposible.

Los contratos antiguos ya pendientes mantienen sus condiciones originales. Las campañas explorables usan el catálogo de inversión para las solicitudes nuevas; las campañas anteriores sin modo explorable conservan su interfaz previa. Todos comparten el mismo registro `pending_favors` y presupuesto `daily.favor_used`.

## Roxy y cementerio

Roxy ofrece cuatro opciones tras el saludo: comprar libros, investigar juntos, consultar mejoras y comprar materiales. Las visitas de compras/investigación requieren una interacción; se muestra antes de reservar. La actividad nueva `roxy_supplies` abre la tienda existente. La compra paga oro mediante `Economy.buy`; la librería usa `Economy.buyBook`. Ningún artículo se entrega al reservar una visita o comparar precios. Una compra completa la visita sin consumir otro espacio. Los libros especiales mantienen sus habilidades y recetas anteriores.

La tumba central se identifica como **Tumba de Paul** y la placa menor al sureste como **Lugar de descanso de Oldeus**. Hay una reflexión opcional en cada lugar. Se registra la visita, sin oro, romance, gasto matrimonial ni revelaciones a otro personaje. Se amplió únicamente el suelo necesario para bordear la tumba central; se conservó el PNG.

## Guardado y módulos

La extensión `worldContent.version=1` guarda semilla, hallazgos diarios, recogidas, objetos examinados, memoria de NPC y lugares especiales visitados. Los contratos amplían los registros de encargos existentes con costes, recibos y resultados. Se mantiene `campaign-exploration-v1.json`; las partidas de fase 1 se amplían sin reiniciar el prólogo y los archivos de campañas anteriores no se sobrescriben. [Detalle del formato](GUARDADO.md).

| Archivo nuevo | Responsabilidad |
| --- | --- |
| `src/data/ambient_dialogue.lua` | Frases y expresiones ambientales |
| `src/data/world_content.lua` | Objetos, hallazgos, posiciones y reflexiones |
| `src/data/commissions.lua` | Costes, probabilidades, devolución y recompensas |
| `src/systems/world_content.lua` | Selección de frases, generación, recogida y restauración |
| `src/systems/commissions.lua` | Resultado único, entrega y validación de contrato |
| `src/screens/commissions.lua` | Revisión, confirmación, ayuda y resultados |
| `tests/world_content.lua` | Pruebas y capturas de la fase |

Se ampliaron `src/app.lua`, `src/data/{activities,economy,family_activities,exploration_world,map_collisions}.lua`, `src/systems/{daily,economy,exploration,progression,save}.lua`, `src/screens/{exploration,agenda,shop}.lua`, `tests/{run,exploration_driver}.lua`, README y los documentos de manual, guardado y verificación. El controlador de movimiento conserva su algoritmo; solo se añadió la consulta de objetos a su selector de interacción. Las dos colisiones nuevas de planta baja protegen una cesta y una estantería existentes.

## Ejemplos visuales

Capturas del renderer real, revisadas visualmente; se regeneran con `tests.world_content`. Permanecen en `tests/artifacts/` según la exclusión de Git existente.

| Ejemplo | Evidencia |
| --- | --- |
| Lilia limpiando, dos cuadros | [Cuadro 1](../tests/artifacts/world2-lilia-cleaning-1.png) · [Cuadro 2](../tests/artifacts/world2-lilia-cleaning-2.png) |
| Aisha interactuando | [Saludo](../tests/artifacts/world2-aisha.png) |
| Zenith con Lucy, interacción de la niña | [Lucy en brazos](../tests/artifacts/world2-zenith-lucy.png) |
| Hallazgo oculto | [Objeto en el mundo](../tests/artifacts/world2-hidden-find.png) · [Recogida](../tests/artifacts/world2-pickup.png) |
| Revisión de una inversión | [Contrato](../tests/artifacts/world2-commission-preview-success.png) |
| Advertencia antes de ayudar | [Confirmación](../tests/artifacts/world2-commission-help-success.png) |
| Encargo exitoso | [Éxito real](../tests/artifacts/world2-commission-success.png) |
| Encargo fallido | [Fracaso real](../tests/artifacts/world2-commission-failure.png) |
| Cementerio | [Paul](../tests/artifacts/world2-cemetery-paul.png) · [Oldeus](../tests/artifacts/world2-cemetery-oldeus.png) |

## Pruebas

```powershell
$env:DATESIM_TEST_MODULE = 'world_content'
./probar.ps1
Remove-Item Env:DATESIM_TEST_MODULE
# Incluye la fase 1 y todos los sistemas anteriores
./probar.ps1
```

La prueba nueva pasó **5.420 comprobaciones**: 48 semillas × 7 días, variación y memoria de once interlocutores, diferencias reales entre los cuadros de animación, presencia única de Lucy, protección del prólogo, rutas hasta todos los hallazgos y objetos, inventario, recogidas únicas, pago/fracaso de contratos, persistencia antes de entregar, ayuda/cancelación, restricción entre encargados, día siete, tumbas y compras de Roxy. Genera **14 capturas**.

La regresión de movimiento y prólogo pasó **770 comprobaciones**. El grupo de regresión general terminó con `ALL TESTS PASSED`, incluyendo integración por pantallas desde Nueva partida hasta el final, combate, relaciones, economía, cartas y guardado. El verificador de assets confirmó 109 archivos migrados y 157 anteriores conservados, incluidos los bytes ASE; permanecen los 18 avisos de capas preexistentes.

[Registro focalizado](../tests/artifacts/world2-focused.log) · [Regresión de movimiento](../tests/artifacts/world2-movement-regression.log) · [Regresión general](../tests/artifacts/world2-regression.log) · [Suite completa](../tests/artifacts/world2-full-suite.log).

La **suite completa terminó con `ALL TESTS PASSED`, salida 0**: 28.848 comprobaciones en 40 campañas simuladas, cinco finales y 576 batallas de jefes; la integración por pantallas añadió 1.473 comprobaciones en 836 pasos. Después de los últimos ajustes visuales y de colisión se repitieron satisfactoriamente las pruebas focalizadas de esta fase y de movimiento. [Registro actualizado](VERIFICACION.md).

## Alcance y pendientes

Los NPC permanecen en sus posiciones, sin rutas ni horarios de paseo. Lucy comparte siempre el sprite de Zenith en esta fase; no se añadió un evento de separación solo para duplicar su representación. La solución gráfica definitiva del acceso Sharia–Universidad sigue pendiente de la fase anterior y su traslado reversible continúa operativo. Las capturas y pruebas son automatizadas; no sustituyen una sesión prolongada de juego y escucha para ajustar el ritmo narrativo.
