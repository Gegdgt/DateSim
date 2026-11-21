# Combate durante la maldición de Rudy

El motor conserva vida, acciones, robo, descarte, intenciones, compañeras y reintento mediante comandos reproducibles. La campaña empieza con 30 PV, tres acciones por turno y **maná natural bloqueado en cero**. La maldición se recibe en `context.curse`; el antídoto la desactiva en el capítulo siete.

## Mazo inicial y controles

Nanahoshi entrega exactamente cinco técnicas: Golpe de bastón (4 daño), Corte sencillo (5 daño y 1 PV de esfuerzo), Lanzamiento de piedra (3 daño), Empuje (2 daño y 3 escudo), Ataque coordinado (4 daño y debilitamiento de un turno). Todas cuestan una acción y cero maná. El esfuerzo nunca puede pagar el último PV.

La mano contiene tres cartas. Clic o 1–3 selecciona; Enter confirma; E termina el turno. **D: defensa básica** otorga cinco puntos de escudo; **V: esquiva** otorga tres. Son acciones físicas independientes de la mano, de un uso por turno cada una. H abre el historial y T las tácticas. Los mazos admiten entre cinco y diez cartas distintas adquiridas, con al menos dos ataques de tres o más de daño.

## Energía y protección

El primer fragmento da una capacidad de 12 de energía externa, utilizada por las cartas encantadas de agua y tierra. El artefacto se recarga hasta cuatro puntos por turno; esto no restaura la magia natural de Rudy. `player.mana` y `player.externalEnergy` son campos separados. Las cartas con `resource="natural"` se rechazan antes del antídoto. Tras curarse, Rudy puede canalizar su maná normal.

La interfaz distingue escudo físico y mágico. Ambos absorben daño antes de los PV y caducan al comenzar el turno siguiente. El motor conserva su suma en `shield` para las vistas y registros originales. Los estados de debilitamiento y vulnerabilidad modifican también la intención y la vista previa, con duraciones finitas.

Curación básica cuesta una acción y tres puntos de energía mágica, recupera hasta cinco PV y permite **tres usos por combate**. Las cartas híbridas con curación, como Magia compartida, también tienen tres usos; el detalle muestra los restantes y explica el bloqueo al agotarlos. La vida nunca supera su máximo. Sylphiette dispone de tres curaciones efectivas por combate: actuar con Rudy ileso no consume una. Después puede seguir atacando y protegiendo. Estos límites se reconstruyen al cargar; terminar un turno no los repone y reintentar comienza con las cargas iniciales.

## Dificultad por día

`src/data/enemies.lua` conserva las definiciones base y publica `difficulty` y `resolve(id, context)`. El contexto admite `day` y una dificultad opcional de 1 a 6. Una batalla conserva ese contexto durante guardado y reintento. Los datos compartidos nunca se modifican.

| Día | Ajuste sobre el enemigo base | Repertorio adicional |
| --- | --- | --- |
| 1 | Sin bonificación; tutorial de 22 PV y ataques de 4 | Patrón guiado |
| 2 | Sin bonificación; bestia de 35 PV | Ataque, preparación y defensa |
| 3 | Sin bonificación; guardián de 44 PV | Golpe fuerte anunciado y defensa |
| 4 | +4 PV, +1 daño, +1 escudo | Debilitamiento |
| 5 | +18 PV, +2 daño, +2 escudo | Interrupción y dos golpes anunciados |
| 6 | +8 PV, +1 daño, +1 escudo | Interrupción |
| 7 | Desenlace sin enfrentamientos | Ninguno |

Los bonos tienen topes de 80 PV, 15 de daño por ataque y 9 de escudo. El tutorial siempre usa el primer nivel. **Badigadi y los jefes conservan sus estadísticas y fases**, sin recibir estos bonos. El encuentro del día cinco con la anomalía pasa de 22 a 40 PV y añade acciones; la progresión no se reduce a subir su vida.

Las partidas v3 con un combate ya empezado antes de este ajuste se validan reproduciendo sus comandos con las reglas anteriores. Conservan exactamente enemigo, PV, mano, mazo, descarte, semilla, historial y revisión. Su `balanceVersion=1` mantiene esas reglas hasta acabar o reintentar esa batalla; no se añaden límites de curación o dificultad a mitad del encuentro. Los combates nuevos usan `balanceVersion=2`. Esta migración no cambia el formato general de campaña ni acepta estados manipulados; los snapshots inválidos siguen usando la recuperación segura existente.

Interrumpir quita una acción en el siguiente turno de Rudy, dejándole dos para actuar. Terminado ese turno recupera tres. Cada recuperación enemiga de escudo admite tres usos; después la intención anuncia que está agotada. Los ataques múltiples anuncian daño por golpe y cantidad: el mismo escudo se va consumiendo entre los impactos. El resumen visual acumula todo el ataque y muestra daño, bloqueo y PV perdidos; el historial conserva cada golpe.

## Compañeras

Sylphiette protege y cura, Roxy analiza y debilita, Eris golpea e interrumpe. Atacar juntos, dejar que ella actúe y defenderla no requieren magia natural de Rudy. Las combinaciones mágicas consumen energía externa mientras está maldito. Una sola decisión táctica contextual por encuentro puede modificar la relación, al confirmar la victoria; ataques repetidos no conceden amor. Proteger a Eris herida ayuda; impedir actuar a Eris capaz perjudica la confianza.

## Duelo de entrenamiento con Eris

El día cinco usa el motor de combate con resistencia no letal y sin una segunda Eris como aliada. Ella tiene 42 puntos de resistencia, desvía dos puntos de los ataques con espada y es vulnerable al control de tierra. Después de un bloqueo o esquiva efectivos, **C** permite un contraataque de bastón de cinco puntos por una acción. La ventana se consume una vez.

El motor registra intentos, impactos, daño, bloqueos, esquivas, acciones tácticas, turnos vacíos y oportunidades desperdiciadas. Al terminar, una pantalla de valoración distingue victoria, derrota honorable, derrota honesta y sospecha de dejarse ganar. Los valores, umbrales, memoria y revancha están documentados en [Afinidad y entrenamiento](AFINIDAD_Y_ENTRENAMIENTO.md). La recompensa afectiva se aplica una sola vez al leer la reacción; perder continúa la historia y no abre el reintento de las batallas normales.

## Badigadi y el antídoto

`badigadi_final` tiene 72 PV y cuatro fases:

1. Resistencia: alterna golpes y preparación.
2. Seis brazos: al perder la mitad de la vida anuncia tres golpes consecutivos de tres puntos, alternados con una pausa.
3. Romper el sello: cero PV expone los anclajes, pero **no concede victoria**. `B` o el botón Romper sello ejecuta `Combat.breakSeal`, cuesta una acción y elimina seis de sus doce puntos de resistencia. El sello aún puede emitir pulsos.
4. Victoria: con ambos anclajes neutralizados Badigadi acepta su derrota y entrega el antídoto por su promesa. No muere.

Una derrota conserva las decisiones previas y permite reintentar con el mismo reparto o regresar a preparación. Nunca crea un sexto final ni concede premios. El guardado valida el registro completo de cartas, defensa, esquiva, tácticas y sello antes de restaurar la batalla.

## Verificación ejecutada

Las pruebas se ejecutan con LuaJIT incluido en LÖVE 11.5. `tests/combat.lua` pasa **1620 comprobaciones y 120/120 victorias**. `tests/combat_balance.lua` recorre los encuentros de campaña con seis semillas, mazo inicial y ampliado, y las compañeras elegibles: **919 comprobaciones y 288/288 victorias legales**, leyendo intenciones y utilizando defensa. También comprueba cargas de curación, interrupción de un turno, daño múltiple, bloqueo, dificultad acotada, datos inmutables, ausencia de combates en el día siete y restauración por replay. No se exige obtener una carta concreta para superar las batallas. Entrenamiento añade 84 comprobaciones de reglas y 444 de integración en la App con los cuatro desenlaces, guardado, música, controles, barras y reconciliación. [Ejecuciones y registros](VERIFICACION.md).
