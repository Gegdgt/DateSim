# Fase 6 — Integración, economía y verificación

Fecha: **21 de noviembre de 2026**. Implementación sobre el repositorio existente, ejecutada en **LÖVE 11.5 / LuaJIT**. Se conservan los 40 identificadores, los mazos, los PNG y los ASE originales. El guardado sigue en **v8**; no se necesita una migración para estos cambios de presentación y precios.

## Auditoría de las cinco fases anteriores

Se inspeccionaron datos, pantallas, sistemas, guardado y pruebas antes de modificar el proyecto. Ya existían implementaciones funcionales de:

| Sistema | Estado comprobado |
| --- | --- |
| Jornada | Siete días, tres espacios repetibles, un encargo independiente, historia obligatoria sin gasto automático, cierre voluntario y resumen idempotente. |
| Colección y economía | 40 cartas, diez niveles, duplicados por ID, oro, tienda, mazos persistentes y mejoras con bloqueo de pulsaciones repetidas. |
| Familia | 16 actividades, relaciones negativas, límite diario compartido, reconciliaciones, abandono, advertencias, separaciones permanentes y encargos acelerables. |
| Combate | Enemigos por día, cartas escaladas, energía externa, defensa, curación, habilidades por afinidad y Badigadi con 1000 PV. |
| Desenlace | Entrenamiento de Eris por fecha, Orsted opcional, investigación del emisario, antídoto, recuperación de voz/magia, devolución de cartas y cinco epílogos. |

La Fase 6 integra y corrige esos sistemas. No sustituye el motor narrativo ni reconstruye el juego desde cero.

## Cambios implementados

- Agenda con día, espacios restantes, disponibilidad del encargo, oro, cartas recibidas y misiones. Los accesos a las tres esposas, encargos, colección y cierre permanecen visibles mientras se decide una actividad. Consultar otra esposa no reserva un cuarto espacio ni pierde la actividad en curso. Finalizar queda deshabilitado mientras falta resolverla.
- Seguimiento de cartas del día y misiones desde el HUD. El contador de cartas indica patrones desbloqueados; el incremento de hoy cuenta **IDs recibidos distintos**, incluidos duplicados, no el número total de copias. La lista muestra nivel y copias disponibles.
- Recompensas y costes de actividades visibles, incluido el bono de **15 oro al cerrar** por su misión completada. Librería, recompensas, escenas familiares y combates de actividad conservan un HUD compacto.
- Barras con cero central, tramo rojo y `!` para relaciones negativas, conservando el valor numérico real. El resumen anima el estado anterior hacia el definitivo; cargar no vuelve a aplicar las pérdidas.
- Colección con oro, nivel, efecto siguiente, requisitos y equipamiento. La vista de edición ahora usa el nivel real. La mano de combate muestra niveles. Movimiento reducido elimina también la elevación de la mejora.
- Manual interno con fórmula de afinidad, ejemplo, costes y riesgo de curación. Se corrigió una descripción antigua que limitaba visualmente las relaciones a 0–100.
- Sonidos sintetizados reales para oro, entrenamiento, separación, Orsted, Badigadi y victoria final, además de los existentes para jornada, recompensa, mejora, combate y curación. Tres contextos musicales nuevos: `orsted`, `separation`, `final_victory`.
- El regalo de Orsted desbloquea los patrones faltantes incluso de esposas separadas. La colección se completa; el filtro de combate mantiene bloqueadas sus técnicas y apoyos. La entrega sigue siendo única.
- Libro de estudio reducido de **12 a 5 oro**, con stock de cuatro al día. Antes costaba más que sus tres copias sociales comunes compradas por separado.
- Simulador de campañas con perfiles y semillas, métricas por combate/día, CSV y JSON. Modo de revisión humana aislado con capturas F8.

Las separaciones conservan diálogos propios, expresiones, anillo, salida a caballo dibujada con primitivas pixel art y retratos grises. La de Sylphiette narra expresamente la partida con su hija. No se añadieron imágenes externas ni referencias a archivos de audio ausentes.

## Niveles y economía

Desde nivel `L`: **2 × L copias** y **5 × L × factor de clase** de oro. El factor de clase es 1/2/3/4/5 para básica/intermedia/avanzada/especial/definitiva. Los descuentos de recetas se consumen; ninguna mejora ordinaria es ilimitadamente gratuita.

| Nivel alcanzado | Copias de este paso | Copias acumuladas, con original | Oro del paso, básica | Efecto positivo con base +1 |
| --- | ---: | ---: | ---: | ---: |
| 1 | 1 original | 1 | 0 | 1 |
| 2 | 2 | 3 | 5 | 1 |
| 3 | 4 | 7 | 10 | 2 |
| 4 | 6 | 13 | 15 | 2 |
| 5 | 8 | 21 | 20 | 3 |
| 6 | 10 | 31 | 25 | 3 |
| 7 | 12 | 43 | 30 | 4 |
| 8 | 14 | 57 | 35 | 4 |
| 9 | 16 | 73 | 40 | 5 |
| 10 | 18 | 91 | 45 | 5 |

Una básica consume **225 oro** en las nueve mejoras; comprar sus 90 duplicados costaría otros 180. Las recompensas y libros reducen las compras necesarias. N10 no pide más copias ni habilita N11. La fórmula social es `baseEffect * (1 + floor((level - 1) / 2))` solamente para componentes positivos definidos; las penalizaciones dependen de la respuesta narrativa.

El saldo inicial es **120**. Las actividades y encargos tienen recompensas específicas en sus datos; una misión completada aporta 15, un capítulo 30 y el entrenamiento evaluado 45. Las victorias ordinarias de días 1–6 aportan 30/40/50/60/70/90. Badigadi entrega el antídoto; no añade la recompensa ordinaria de oro del Día 7.

| Compra | Precio | Límite |
| --- | ---: | --- |
| Copia adquirida, por clase | 2 / 4 / 7 / 10 / 14 | 30 por ID y día; no comprar para N10 |
| Libro de estudio: tres copias sociales | 5 | Cuatro al día; consumir una vez |
| Material: +4 energía externa | 20 | Tres al día; energía máxima 30 |
| Preparación: +4 escudo inicial | 30 | Una al día; no se acumula |

La librería de Roxy mantiene sus títulos únicos de 35/50/70 oro, habilidades y recetas. Es distinta del consumible Libro de estudio de la tienda general.

Cada transacción conserva ID/revisión. El simulador comprueba `saldo = 120 + ingresos - gastos`; guardar y cargar no renueva stock ni recompensas. En el CSV, **ingresos excluye los 120 iniciales**. La campaña de especialización de la regresión llega a Bastón y Dar ánimo N10 sin Orsted: 1839 contando el saldo inicial, 1037 restantes. No se exige maximizar las cuarenta cartas.

## Método de simulación

Se ejecutaron **11 estrategias × tres semillas (17, 43, 97): 33 campañas completas**, con **23 382 comprobaciones**. Usan eventos, actividades, compras, cartas y comandos legales, con guardado/carga entre checkpoints. No se asignan niveles, oro o victorias desde fuera del juego. Una derrota obligatoria se registra como bloqueo; no se transforma en victoria. La demostración narrativa de Orsted y las derrotas de entrenamiento conservan sus reglas particulares.

El agente de prueba busca respuestas sociales favorables y usa una política de combate que consulta intenciones, compara daño/escudo/curación y respeta acciones, recursos y recargas. En cada encuentro reinicia el generador con la semilla de la campaña. Esto hace comparables los perfiles, pero **no simula el aprendizaje ni los errores de un jugador**. Las tres semillas son una muestra pequeña; 3/3 no es una probabilidad garantizada de victoria.

Estas campañas eligen **una compañera** preferida para el jefe, si está disponible. La ruta familiar lleva a Roxy aunque conserve las tres esposas. La matriz separada de 576 batallas cubre las ocho composiciones posibles. La repetición adicional de `balanced`, semilla 17, produjo **JSON de métricas idéntico** al de la corrida principal; esa repetición no se suma como otra campaña distinta.

Resultados completos: [33 campañas y métricas en CSV](BALANCE_FASE_6.csv). El JSON generado localmente incluye niveles por ID, visitas, relaciones por día, daños reales, curación, escudo y equipo de cada combate.

### Recursos y finales (tres semillas por fila)

| Estrategia | Ingresos / gasto | Saldo | IDs / duplicados restantes | Niveles mejorados | Separaciones D6 → final | Final |
| --- | ---: | ---: | ---: | --- | ---: | --- |
| Equilibrada | 1757 / 754 | 1123 | 40 / 50 | 4 en N6; 2 en N10 | 0 → 0 | Familia unida |
| Tres con Eris | 2100 / 746 | 1474 | 40 / 62 | 4 en N6; 2 en N10 | 2 → 2 | Eris |
| Tres con Roxy | 1575 / 714 | 981 | 34 / 37 | 4 en N6 | 2 → 2 | Roxy |
| Tres con Sylphiette | 1792 / 782 | 1130 | 34 / 52 | 4 en N6 | 2 → 2 | Sylphiette |
| Priorizar oro | 2671 / 0 | 2791 | 34 / 112 | Ninguno (N1) | 2 → 2 | Eris |
| Priorizar mejoras | 1757 / 788 | 1089 | 40 / 64 | 4 en N10 | 0 → 0 | Familia unida |
| Sin Orsted | 1659 / 754 | 1025 | 36 / 41 | 4 en N6 | 0 → 0 | Familia unida |
| Cañón N10 de Orsted | 1757 / 754 | 1123 | 40 / 50 | 4 en N6; 2 en N10 | 0 → 0 | Familia unida |
| Perder una antes del final | 1674 / 742 | 1052 | 35 / 44 | 4 en N6 | 1 → 2 | Roxy |
| Perder dos | 1390 / 714 | 796 | 34 / 30 | 4 en N6 | 2 → 2 | Roxy |
| Perder tres | 1075 / 782 | 413 | 33 / 23 | 4 en N6 | 3 → 3 | Rudy solo |

Los N10 gratuitos de Orsted están incluidos en la columna de niveles. Los duplicados son el inventario restante después de las mejoras, no las copias acumuladas recibidas.

### Badigadi (rango observado entre las tres semillas)

| Estrategia | Victorias | Turnos | PV restantes | Daño/turno | Mayor daño base de carta disponible | Curación real / escudo generado | Cartas que pueden curar |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Equilibrada | 3/3 | 19 | 25–29 | 52.63 | 26 | 0 / 35–46 | 2 |
| Tres con Eris | 3/3 | 12 | 30 | 83.33 | 26 | 0 / 27–32 | 1 |
| Tres con Roxy | 3/3 | 19 | 25–30 | 52.63 | 26 | 0 / 35–55 | 1 |
| Tres con Sylphiette | 3/3 | 28–31 | 27–29 | 32.26–35.71 | 26 | 0 / 124–141 | 2 |
| Priorizar oro | 3/3 | 13 | 27–30 | 76.92 | 15 | 0 / 24–33 | 1 |
| Priorizar mejoras | 3/3 | 21 | 21–30 | 47.62 | 20 | 0 / 33–43 | 2 |
| Sin Orsted | 3/3 | 19 | 25–29 | 52.63 | 26 | 0 / 35–46 | 2 |
| Cañón N10 de Orsted | 3/3 | 14–15 | 21–24 | 66.67–71.43 | 250 | 0 / 32–42 | 2 |
| Perder una antes del final | 3/3 | 19 | 25–30 | 52.63 | 26 | 0 / 35–55 | 1 |
| Perder dos | 3/3 | 19 | 25–30 | 52.63 | 26 | 0 / 35–55 | 1 |
| Perder tres | 3/3 | 44–48 | 18–25 | 20.83–22.73 | 26 | 0 / 116–143 | 1 |

Daño/turno usa PV enemigos realmente perdidos. El máximo de carta es su efecto base a ese nivel, antes de defensa/debilidad; no es una suma de ataques ni garantiza ese impacto. Curación real y escudo son acumulados del combate. Las cartas curativas se cuentan en la colección utilizable; no necesariamente se equiparon. La política no necesitó curarse en varias rutas; la curación y el riesgo se ejercitan además en las pruebas de combate.

### Amor/confianza al terminar

| Estrategia | Sylphiette | Roxy | Eris |
| --- | ---: | ---: | ---: |
| Equilibrada | 99 / 100 | 100 / 100 | 96 / 97 |
| Tres con Eris | -49 / -44 | -34 / -31 | 100 / 100 |
| Tres con Roxy | -49 / -44 | 100 / 100 | -46 / -46 |
| Tres con Sylphiette | 100 / 100 | -34 / -31 | -46 / -46 |
| Priorizar oro | -49 / -44 | -34 / -31 | 100 / 100 |
| Priorizar mejoras | 99 / 100 | 100 / 100 | 96 / 97 |
| Sin Orsted | 99 / 100 | 100 / 100 | 100 / 100 |
| Cañón N10 de Orsted | 99 / 100 | 100 / 100 | 96 / 97 |
| Perder una antes del final | 100 / 100 | 100 / 100 | -46 / -46 |
| Perder dos | -32 / -29 | 100 / 100 | -32 / -32 |
| Perder tres | -32 / -29 | -57 / -55 | -32 / -32 |

Los tres valores finales fueron iguales entre semillas en cada perfil. El estado matrimonial se consulta por separado; una puntuación alta no anula una separación explícita.

## Interpretación del balance

La atención equilibrada consigue familia unida con y sin Orsted. La atención exclusiva alcanza cada final individual, a costa de dos matrimonios. Buscar oro mediante monstruos deja el mayor saldo, pero pierde dos apoyos y no obtiene mejoras: no domina simultáneamente economía, familia y colección.

La ruta `upgrades` compra y mejora Bastón y Dar ánimo hasta N10; además cumple la condición de Orsted y recibe dos máximos gratuitos de utilidad. No deben atribuirse esos cuatro N10 al gasto ordinario. `with_orsted` escoge Cañón de agua N10 y Dar ánimo N10, de modo que el regalo aporta una mejora de combate mucho más visible. `balanced` recibe otros máximos gratuitos; un N10 de utilidad no equivale a 250 de daño.

`lose_one` llega al cierre del Día 6 con una separación. Las conversaciones finales resuelven las dos relaciones restantes mediante la elección explícita de Roxy; termina con dos separaciones. Esto responde al catálogo de **exactamente cinco finales**: no existe epílogo con dos esposas. Los valores altos de Sylphiette en esa fila no reactivan el matrimonio terminado.

Sin compañeras, la política necesita 44–48 turnos contra Badigadi, frente a 19 con Roxy en las rutas equilibradas. Su vida sigue siendo 1000. No se detectaron bloqueos, saldos negativos, niveles superiores a diez ni duplicación de entregas en estas rutas. El nivel 1 con Eris puede vencer, pero ello no demuestra que cualquier mazo inicial o una estrategia sin defensa resulte viable.

La matriz independiente de combate ejecutó **576 batallas**: niveles 1/5/10, ocho equipos, afinidades 20/50/90 y ocho semillas. Resultados: **186/192 victorias a N1**, **192/192 a N5** y **192/192 a N10**. Las seis derrotas de N1 son resultados reales, no fallos ocultados. Las medias de turnos por celda van de 7 a 71,63 en N1, 5,25 a 22,25 en N5 y 4,13 a 10,88 en N10. Estas son configuraciones de combate preparadas; no prueban que toda esa colección sea obtenible al mismo tiempo en una campaña.

## Relaciones y combate

Cada esposa empieza en **50/50**; el intervalo es **−100 a 100**. Ganancias reales de todas las fuentes comparten **+10 por estadística y día**. Las pérdidas no consumen ni restauran ese margen. Dos valores de al menos 75 añaden una pequeña bonificación a ganancias ordinarias de dos o más; un valor negativo reduce las ganancias ordinarias. Reconciliar mantiene una vía de recuperación, limitada por el mismo presupuesto. Cero visitas implica **−20/−20** una sola vez; las advertencias y decisiones justifican las separaciones.

```lua
local affinity = (love + trust) / 2
local multiplier = math.max(0, math.min(100, affinity)) / 100
local damage = math.floor(baseDamage * multiplier + 0.5)
```

Especiales máximos: Sylphiette 90, Eris 150, Roxy 110; ataques normales menores, costes, recargas y usos acotados. Las separadas no actúan. Curación de Sylphiette: 40% desde 90, 30% desde 80, 20% desde 50 y 10% desde 25; por debajo de 25, la maldición causa 40% de daño a Rudy con confirmación previa. Se prueban 24,99 / 25 / 49 / 50 / 79 / 80 / 89 / 90 / 100.

Los ataques básicos empiezan en 1–3. Bastón llega a 20, Proyectil de agua a 55 y Cañón de agua a 250. La definitiva desde N7 requiere 12 de energía, 6 PV y admite un uso. La curación tiene límites; el escudo caduca. Las fases, debilidades, intenciones y acciones de apoyo siguen siendo necesarias aunque suba el nivel. La pantalla distingue daño base, bloqueo y PV realmente perdidos.

## Pruebas y revisión visual

La [verificación consolidada](VERIFICACION.md) detalla la regresión ejecutada, campañas, matriz de combate, guardado y recorrido gráfico. La prueba nueva de integración verifica HUD persistente, consulta sin consumo extra, estado negativo, guardado/carga, resumen, 16 actividades, restricciones de Orsted, libro acotado, audio real y legibilidad de la fórmula: **323 comprobaciones y nueve capturas** en su última ejecución focalizada.

Se inspeccionaron imágenes producidas por el renderizador real: [agenda](../tests/artifacts/phase6-agenda.png), [actividad](../tests/artifacts/phase6-activity-hud.png), [conflicto](../tests/artifacts/phase6-negative-affinity.png), [resumen](../tests/artifacts/phase6-day-report.png), [colección](../tests/artifacts/phase6-collection.png), [mejoras](../tests/artifacts/phase6-upgrades-state.png), [misiones](../tests/artifacts/phase6-missions.png), [anillo](../tests/artifacts/family-ring-eris.png), [partida de Sylphiette](../tests/artifacts/family-horse-sylphiette.png), [retrato gris](../tests/artifacts/family-gray-character.png), [fase de ataques múltiples](../tests/artifacts/war-phase-six_arms.png), [habilidades](../tests/artifacts/war-roxy-skills.png), [victoria](../tests/artifacts/war-boss-victory.png), [devolución](../tests/artifacts/finale-return-cards.png) y [epílogo familiar](../tests/artifacts/finale-epilogue-family_united.png). Son capturas de pruebas; algunas preparan estados específicos y no representan una partida humana continua. Se generan localmente y se excluyen de Git.

Los 11 efectos solicitados producen PCM no silencioso y acotado, y crean fuentes reales de LÖVE. El manifiesto contiene **20 contextos musicales sintetizados**. No son grabaciones ni una banda sonora comercial. La escucha humana de mezcla, volumen y fatiga sigue pendiente.

## Límites y trabajo pendiente

- **No se completó una partida manual de principio a fin.** Sí se ejecutaron campañas automatizadas y el recorrido de pantallas reales. La herramienta `node_repl` no estaba disponible. La [habilidad computer-use](C:/Users/gegdg/.codex/plugins/cache/openai-bundled/computer-use/26.1111.21308/skills/computer-use/SKILL.md) requiere leer su [guía](C:/Users/gegdg/.codex/plugins/cache/openai-bundled/computer-use/26.1111.21308/docs/guidance.md), que indica: “Use `node_repl` JavaScript for all Computer Use actions.” No se sustituyó ese control por automatización de ventanas desde PowerShell.
- Falta validar con jugadores la dificultad percibida, el tiempo de lectura, la fatiga de sonido y la comodidad con teclado/ratón. Los resultados del agente de prueba no resuelven estas preguntas.
- La presentación de partida a caballo es una animación sencilla con primitivas y sprites existentes. No hay doblaje grabado ni ilustraciones nuevas.
- El precio del libro era una compra dominada y fue corregido. No se detectaron actividades inútiles ni recursos infinitos en la cobertura ejecutada; eso no equivale a una demostración exhaustiva de todas las secuencias posibles.

## Ejecución y reproducción

```powershell
./ejecutar.ps1                     # Juego normal, guardado del jugador
./probar.ps1                       # Suite general en LÖVE 11.5

# Las 33 estrategias; no modifica la campaña del jugador.
$env:DATESIM_TEST_GROUP=$null
$env:DATESIM_TEST_MODULE='seven_day_balance'
$env:DATESIM_BALANCE_PROFILE=$null
$env:DATESIM_BALANCE_SEED=$null
& 'C:\Program Files\LOVE\lovec.exe' . --test

# Reproducir una de las campañas:
$env:DATESIM_BALANCE_PROFILE='balanced'
$env:DATESIM_BALANCE_SEED='17'
& 'C:\Program Files\LOVE\lovec.exe' . --test

# Dejar el entorno listo para la suite general:
$env:DATESIM_TEST_MODULE=$null
$env:DATESIM_TEST_GROUP=$null
$env:DATESIM_BALANCE_PROFILE=$null
$env:DATESIM_BALANCE_SEED=$null

./revisar.ps1                      # Partida humana aislada; F8 guarda evidencia
```

El modo `--qa-campaign` usa `cartas_del_destino_phase6_manual`, empieza en el menú y no salta checkpoints ni entrega recursos. F8 escribe PNG 640×360 y JSON con pantalla/checkpoint en `tests/artifacts/manual-...`. Estos archivos registran lo visto; no certifican por sí solos una partida completa. Para cerrar la revisión pendiente, jugar desde el sueño hasta un epílogo y registrar actividades, encargo, mejoras, defensas, curación, emisario, antídoto y devolución. Usar recorridos adicionales para Orsted y las separaciones incompatibles con esa primera ruta.

## Archivos de extensión

| Archivo | Responsabilidad |
| --- | --- |
| `src/ui/daily_hud.lua`, `src/screens/daily_status.lua` | Estado diario y consulta de recompensas/misiones |
| `src/screens/agenda.lua`, `day_report.lua` | Actividades, consultas, costes y resumen animado |
| `src/ui/relationship_bars.lua` | Valores negativos y animación de cambios reales |
| `src/data/economy.lua`, `card_progression.lua`, `family_activities.lua` | Precios, curvas, recompensas y actividades |
| `src/data/audio.lua`, `src/systems/audio.lua` | Contextos, señales y síntesis original |
| `tests/seven_day_balance.lua`, `campaign.lua`, `campaign_metrics.lua` | Perfiles, ejecución legal y métricas reproducibles |
| `tests/integration_final.lua` | Integración visual, persistencia y audio |
| `tests/manual_campaign.lua`, `revisar.ps1` | Preparación de la revisión humana aislada |

Registros principales: `tests/artifacts/phase6-full.log`, `phase6-balance-final.log`, `phase6-reproducibility.log` y `phase6-integration.log`. Los módulos, reglas de datos y fórmulas se documentan también en [SISTEMAS](SISTEMAS.md), [MANUAL](MANUAL.md), [Fase 2](FASE_2_PROGRESION.md), [Fase 4](FASE_4_COMBATE.md) y [Fase 5](FASE_5_CIERRE.md).
