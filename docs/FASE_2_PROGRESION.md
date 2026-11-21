# Fase 2 — Cartas, duplicados y economía

> Las fórmulas y los diez niveles siguen vigentes. La [Fase 3](FASE_3_FAMILIA.md) añade actividades, libros únicos, recetas de descuento y afinidad positiva/negativa. El guardado actual es v8 y conserva las migraciones anteriores. La [Fase 6](FASE_6_INFORME.md) ajusta el libro consumible a 5 oro y publica el balance vigente. El límite diario de +10 por estadística permanece.

La colección conserva los **40 IDs**, los dos mazos y todos los PNG y ASE existentes. Cada ID tiene una sola entrada mejorable. La pantalla **MEJORAR CARTAS** se abre desde **M → Mejorar**; desde ella se accede a la tienda.

## Copias y niveles

La primera copia desbloquea nivel 1. Las siguientes se acumulan en `collection[id].copies`, sin añadir posiciones al mazo. Una mejora consume duplicados y oro; nunca consume la carta original ni sustituye su ID.

| Nivel de destino | Copias adicionales | Copias totales desde cero | Oro de esa mejora, clase básica |
| --- | ---: | ---: | ---: |
| 1 | 1 original | 1 | 0 |
| 2 | 2 | 3 | 5 |
| 3 | 4 | 7 | 10 |
| 4 | 6 | 13 | 15 |
| 5 | 8 | 21 | 20 |
| 6 | 10 | 31 | 25 |
| 7 | 12 | 43 | 30 |
| 8 | 14 | 57 | 35 |
| 9 | 16 | 73 | 40 |
| 10 | 18 | 91 | 45 |

Desde nivel `L`, `copies_required = 2 * L` y `gold_required = 5 * L * goldFactor`. Al llegar a 10 ambos requisitos son cero y se rechazan mejoras y compras de copias. Los duplicados ganados después se conservan, sin crear otro nivel. Una carta básica cuesta 225 de oro en mejoras desde 1 hasta 10; comprar sus 90 duplicados cuesta otros 180. Las recompensas reducen ese gasto.

## Efectos sociales y presupuesto diario

Para cada componente positivo permitido por el perfil de la carta:

```lua
effect = baseEffect * (1 + math.floor((level - 1) / 2))
```

Una base +1 produce 1, 1, 2, 2, 3, 3, 4, 4, 5, 5. Escuchar solo mejora confianza; Broma ligera y Coqueteo sutil solo amor; Dar ánimo mejora ambos. Un componente positivo del diálogo se sustituye por el componente escalado de la carta; cero permanece cero y una respuesta negativa conserva su penalización contextual. Las exclusivas tienen base +2 amor/+1 confianza. La afinidad investigadora de Nanahoshi conserva sus reglas independientes.

`daily.relationship_gains[wife]` acumula ganancias **realmente aplicadas**, con presupuestos separados de 10 amor y 10 confianza. `Events.apply` concentra cartas, actividades, cierres, decisiones, entrenamiento y combate. Las vistas previas consultan el mismo presupuesto. Si quedan tres puntos y la carta ofrece cinco, muestra y aplica tres. El límite global de relación sigue siendo 100. Las pérdidas no consumen ni restituyen presupuesto. Cambiar de jornada reinicia ambos contadores.

Las actividades ofrecen +2/+1 o +1/+2. Dos visitas aportan cuatro puntos a la estadística elegida; tres, seis, además de una confianza por atención al cerrar. Las escenas y cartas completan esta atención, sujetas al máximo diario. La memoria de promesas y los requisitos narrativos se conservan.

## Combate

Los rangos individuales se interpolan según su clase:

```lua
value = math.floor(base + (maximum - base) * ((level - 1) / 9)^exponent + 0.5)
```

| Clase | Exponente | Factor de oro | Precio por copia | Ejemplos de daño N1 → N10 |
| --- | ---: | ---: | ---: | --- |
| Básica | 1.35 | 1 | 2 | Bastón 2 → 20; piedra 1 → 16; corte 3 → 24 |
| Intermedia | 1.55 | 2 | 4 | Proyectil de agua 6 → 55; descarga 6 → 60 |
| Avanzada | 1.8 | 3 | 7 | Lanza de hielo 7 → 95; conjuro pesado 11 → 125 |
| Especial | 2 | 4 | 10 | Magia compartida 6 → 140; conjuro combinado 12 → 180 |
| Definitiva | 2.3 | 5 | 14 | Cañón de agua 15 → 250 |

Las barreras tienen rangos propios (Barrera reforzada: 9 → 18); Curación básica pasa de 5 a 10 PV, sin superar los PV máximos y con tres usos por combate. Robo, acciones, recuperación de maná, estados y oportunidades de uso no escalan. Desde N7, avanzadas/especiales añaden tres de maná y admiten dos usos; la definitiva exige 12 de maná/energía externa, 6 PV y un uso. Los costes de acciones originales permanecen. La interfaz muestra los costes actuales y los cambios del siguiente nivel.

El nivel no elimina la defensa enemiga, la maldición, las intenciones ni las fases de Badigadi. El mazo, los niveles y la preparación forman parte del contexto determinista de cada batalla; las mejoras se bloquean durante encuentros activos.

## Economía de siete días

Oro inicial: **120**. No se permite gastar más del saldo. El stock se controla por día y artículo, sin poder renovarlo cargando la partida.

| Fuente | Oro | Copias adicionales |
| --- | ---: | --- |
| Actividad familiar | 12 | 1 Escuchar, Honestidad o Ánimo, según esposa |
| Encargo de Cliff | 45 | 2 Escuchar y 1 Curación básica |
| Encargo de Zanoba | 40 | 2 Bastón y 1 Defensa física |
| Misión | 15 | Las definidas por la misión |
| Cierre de capítulo | 30 | Las definidas por la historia |
| Entrenamiento evaluado | 45 | 3 Bastón |
| Victoria, días 1–6 | 30 / 40 / 50 / 60 / 70 / 90 | 2 de la primera técnica equipada |

El resultado de entrenamiento y la conclusión victoriosa son eventos distintos; ambos solo se conceden una vez. No hay ingresos por reintentar derrotas ni por releer recompensas. El Día 7 incluye a Badigadi, cuya victoria entrega el antídoto sin añadir oro ordinario de combate. Las actividades específicas de la Fase 3 sustituyen las recompensas genéricas donde corresponde y completan misiones que pagan 15 oro al cierre.

| Compra | Precio | Stock diario | Uso |
| --- | ---: | ---: | --- |
| Copias de carta adquirida | Según clase | 30 por ID | Comprar lotes de 1, 5 o 10 |
| Libro de estudio | 5 | 4 | Consumir para recibir 3 copias sociales |
| Material mágico | 20 | 3 | Consumir para +4 energía externa, máximo 30 |
| Preparación | 30 | 1 | +4 escudo al iniciar la siguiente batalla, sin acumulación |

Los ingresos permiten elegir algunas especializaciones; no se espera completar las cuarenta cartas en una campaña. La regresión vigente llega a Bastón y Dar ánimo N10 sin Orsted, con 1839 de oro contando los 120 iniciales y 1037 restantes. Las técnicas nuevas siguen requiriendo sus desbloqueos narrativos. El libro cuesta menos que tres copias comunes y tiene stock limitado. Las [33 campañas de Fase 6](BALANCE_FASE_6.csv) distinguen ingresos obtenidos, gastos y saldo.

## Integración y extensión

| Archivo | Responsabilidad |
| --- | --- |
| `src/data/card_progression.lua` | Perfiles sociales, rangos de combate, clases, costes y reglas desde N7 |
| `src/data/economy.lua` | Oro inicial, recompensas, precios, suministros y stock |
| `src/systems/card_collection.lua` | Colección canónica, vistas derivadas, entregas y mejoras |
| `src/systems/economy.lua` | Transacciones, revisiones, compras y consumo |
| `src/systems/relationship_budget.lua` | Presupuesto compartido por esposa y jornada |
| `src/systems/events.lua` | Aplicación única de efectos, oro y lotes de copias |
| `src/screens/upgrades.lua`, `shop.lua`, `reward.lua` | Comparación, animación, compras y duplicados |
| `src/systems/save.lua` | Formato actual v8; conserva migración desde v4/v5/v6/v7 sin sobrescribir originales |

Ejemplo de recompensa extensible:

```lua
Events.apply(session, "day3_research_bonus", {
    copies = {listen = 4, water_projectile = 2},
    gold = 35,
    text = "Notas de investigación completadas.",
})
```

Usar un ID de evento estable evita volver a entregar el lote. `unlock={...}` equivale a recibir una copia; si ya existe, se convierte en duplicado. Para consultar la carta se usa `Collection.view(session,id)`, que reúne ID, desbloqueo, nivel, copias, tipo, efectos base/actuales, requisitos y nivel máximo. Solo se persisten los datos propios del jugador; los efectos se derivan de la configuración.

`Collection.upgrade(session,id,expectedRevision)` verifica requisitos antes de descontar. La pantalla eleva la carta y dibuja un destello con primitivas pixel art; a los 0,45 segundos confirma una única transacción, reproduce el sonido y guarda. Continuar habilita una nueva mejora. Cargar antes de la confirmación conserva los recursos; cargar después conserva el nivel y el gasto. No se generaron imágenes nuevas.

## Guardado y pruebas

`campaign-v5.json` conserva colección, oro, compras, objetos, transacciones, presupuesto de relaciones y todo el progreso diario/narrativo anterior. La migración de v4 conserva historia, matrimonios, mazos y acciones en curso; inicializa las cartas adquiridas en N1 y reconstruye las ganancias de hoy desde el diario. Los archivos v4 quedan intactos. Las conversaciones históricas reproducen sus respuestas anteriores; las nuevas acciones usan las reglas actuales. Los combates v4 mantienen su contexto anterior hasta terminar.

```powershell
& 'C:\Program Files\LOVE\lovec.exe' . --test
# Pruebas focalizadas:
$env:DATESIM_TEST_GROUP='economy-ui'       # dominio, persistencia e interfaz
& 'C:\Program Files\LOVE\lovec.exe' . --test
$env:DATESIM_TEST_GROUP='economy-campaign' # ingresos reales y dos especializaciones
& 'C:\Program Files\LOVE\lovec.exe' . --test
Remove-Item Env:DATESIM_TEST_GROUP
```

Las pruebas abarcan 91 copias, diez niveles, costes, descuentos, límites, duplicados, pulsaciones rápidas, replay, migración en disco y compatibilidad narrativa. Los resultados de ejecución están en [VERIFICACION.md](VERIFICACION.md).
