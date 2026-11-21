# Fase 5 — Orsted, el antídoto y los cinco finales

La fase continúa los sistemas de agenda, colección, familia y combate. Conserva los 40 identificadores de cartas, los mazos, los PNG y los ASE. No añade niveles ni un sexto final.

## Entrenamiento y aparición de Orsted

`src/systems/finale.lua` registra `eris_training_days` y el evento estable `eris_training_day_<día>` al **completar** un entrenamiento. En memoria y JSON las claves son cadenas (`"1"`…`"7"`). Reservar una actividad, guardar durante ella o repetirla no completa otro día.

Cuentan `time_eris` (entrenamiento compartido), `eris_physical` y `eris_duel`, además de los duelos narrativos `day5_eris_duel` y `day6_eris_rematch`. Cazar monstruos o reconciliarse no sustituye el entrenamiento. El resultado de un duelo puede ser victoria o derrota: cuenta haber terminado su evaluación. El duelo principal del Día 5 también puede completar esa fecha sin consumir una interacción libre.

Cuando existen las cinco fechas 1–5, se registra `eris_five_training_days`. El diario muestra las fechas completadas. En el Día 6, después de la investigación y del enfrentamiento con el emisario, aparece Orsted sólo si existe esa secuencia. Sin ella se continúa directamente a los preparativos; no hay premio de consolación ni bloqueo del jefe.

## Demostración controlada

`day6_orsted_demonstration` utiliza el motor real: reparto, costes, cartas, defensa, esquiva y replay de comandos. La preparación anuncia que no se puede ganar y que no es letal. Orsted tiene **120 de guardia finita**, nunca menos de uno; incluso una carta N10 no permite convertir la escena en una victoria ordinaria.

| Turno | Intención de Orsted |
| --- | --- |
| 1 | Ataque de 4 |
| 2 | Ataque de 8 |
| 3 | Dos ataques de 6 |
| 4 | Termina la demostración |

Si Rudy agota sus PV antes, el encuentro también termina como derrota narrativa. Defender permite sobrevivir los cuatro turnos. `narrativeDefeat="orsted_demonstration"` abre su evaluación, sin perder la partida, penalizar matrimonios ni conceder un premio ordinario de combate. Orsted reconoce sus artefactos, la intervención de Nanahoshi y la maldición de Hitogami después de verlos en uso.

## Dos mejoras gratuitas y colección

`orsted_collection_gift` desbloquea **sólo los patrones faltantes**. Las cartas ya adquiridas conservan niveles y duplicados; volver a cargar o ejecutar la transición no añade copias. Las técnicas matrimoniales permanecen sujetas a la presencia de su esposa.

La pantalla `src/screens/orsted_reward.lua` presenta todas las opciones con sus imágenes existentes y compara el efecto actual con el de N10. El jugador elige una carta de combate y una social. Una híbrida puede ocupar cualquiera de los espacios, pero no ambos: se exigen dos IDs distintos.

Cada elección cambia el nivel una vez y registra `orsted_max_combat` o `orsted_max_social`, la decisión con el ID y una revisión. No gasta oro, duplicados ni descuentos. `orsted_reward.pending` conserva carta, nivel previo y tiempo de presentación; la elevación, destello y sonido no vuelven a ejecutar la mejora. Pulsar rápidamente o cargar durante la animación no concede otra elección.

Una carta ya N10 se rechaza mientras exista una alternativa mejorable en su categoría. Si toda la categoría ya está al máximo, se permite reconocer una carta distinta sin aumentar niveles ni entregar recursos adicionales, evitando bloquear una colección importada. El modo de movimiento reducido elimina elevación y destellos.

## Misterio y antídoto

El Día 4 presenta al emisario, el recuerdo de la poción y una ruta cifrada. La práctica amistosa con Badigadi conserva su identidad, pero no revela que tenga el antídoto. El manual y la pista temprana tampoco lo revelan.

En el Día 6, `day6_hitogami` enfrenta al **emisario de la poción** (`hitogami_emissary`, perfil de combate del Día 6). No se puede saltar su victoria. Su confesión explica la manipulación familiar y revela a Badigadi; al terminarla se registra `antidote_holder_revealed`, se completa la investigación y se obtiene `antidote_location`. El diario refleja el cambio.

Antes del jefe se pueden revisar mazos, mejorar, comprar materiales, elegir entre las compañeras disponibles y guardar. Badigadi mantiene **1000 PV y cuatro fases** con el balance de la Fase 4. Romper el sello completa la victoria: música, diálogo, `antidote_obtained` y consumo único. Badigadi sobrevive. La ayuda de Orsted y las compañeras son ventajas, no requisitos de acceso o victoria.

## Regreso y desenlaces

El antídoto restaura voz, maná natural y magia sin conjuro (`chantlessBlocked=false`). Las primeras palabras y una esfera de agua sin conjuro lo muestran. No modifica amor, confianza ni separaciones.

Las conversaciones finales explican la amenaza, las cartas, la búsqueda y las decisiones de la semana. Sylphiette recuerda los cuidados y su hija; Roxy, la colaboración intelectual; Eris, el esfuerzo y las ausencias. Los diálogos existentes siguen consultando promesas, conflictos, compromisos y reconciliaciones. Las separadas no regresan ni participan en estas conversaciones.

Después de resolver los acuerdos, `day7_return_cards` lleva a Rudy al laboratorio. Devuelve los artefactos a Nanahoshi; `enchanted_cards_returned` e `inventory.enchantedCardsReturned` registran el cierre. La colección, niveles, duplicados e historial se conservan como registro, sin implementar todavía Nueva Partida+.

Cada desenlace tiene una escena `day7_epilogue_<id>` antes del resumen final:

| ID | Escena |
| --- | --- |
| `family_united` | Hogar compartido, tareas y proyectos de las tres esposas |
| `roxy` | Investigación y vida con Roxy |
| `eris` | Escoltas, entrenamiento y aventuras con Eris |
| `sylphiette` | Reconstrucción de la rutina familiar en Sharia |
| `solitary` | Rudy reconoce sus decisiones y responsabilidades sin exigir el regreso de nadie |

Se mantiene `Relationships.ending`: matrimonio vigente, amor y confianza ≥55, resolución personal, compromiso explícito y conflictos/promesas reparados. La familia unida requiere además ≥75/75 en las tres. Varias relaciones viables sin unión completa abren una decisión explícita de proyectos; la devolución no permite saltarla. Nunca se selecciona silenciosamente la estadística más alta.

## Archivos y persistencia

| Archivo | Responsabilidad |
| --- | --- |
| `src/data/final_chapters.lua` | Investigación, nuevas escenas, bifurcación, premios y epílogos; se instala después de `war_chapters` y antes de `day_cycle` |
| `src/systems/finale.lua` | Fechas, condiciones, elección única, devolución y reconstrucción |
| `src/systems/family.lua`, `training_result.lua` | Notificación al completar entrenamientos reales |
| `src/data/battle_balance.lua`, `enemies.lua` | Secuencia de Orsted y emisario |
| `src/systems/combat.lua`, `progression.lua` | Derrota narrativa, continuidad y requisitos de victoria |
| `src/screens/orsted_reward.lua`, `combat.lua`, `history.lua` | Elecciones, presentación de derrota e información del diario |
| `src/systems/save.lua` | Guardado v8, migración y replay |

V8 usa archivos propios y migra v7/v6/v5/v4 sin modificarlos. Reconstruye las fechas de v7 desde actividades terminadas y evaluaciones, nunca desde visitas reservadas. Una batalla v7 ya iniciada contra el lacayo conserva su ID y comandos. La antigua prueba de Orsted por runas permanece únicamente para terminar checkpoints históricos; una campaña nueva sólo utiliza la condición de cinco días y no recibe premios retroactivos por la prueba antigua. Una partida ya completada no se reinicia ni pierde su colección. [Formato completo](GUARDADO.md).

## Pruebas reproducibles

```powershell
# Reglas y capturas específicas
$env:DATESIM_TEST_GROUP='finale-ui'
& 'C:\Program Files\LOVE\lovec.exe' . --test
# Sistemas anteriores, interfaces y recorrido gráfico completo
$env:DATESIM_TEST_GROUP='regression'
& 'C:\Program Files\LOVE\lovec.exe' . --test
# Recorridos completos con guardado entre checkpoints
$env:DATESIM_TEST_GROUP='campaign'
& 'C:\Program Files\LOVE\lovec.exe' . --test
Remove-Item Env:DATESIM_TEST_GROUP
```

`tests/finale.lua` cubre los 32 calendarios, repetición, combate controlado con niveles 1/5/10, premios, elecciones, persistencia, revelación y devolución. `tests/finale_ui.lua` usa las pantallas y el renderizador de LÖVE, incluida la carga durante una mejora y los cinco epílogos. `tests/campaign.lua` recorre todas las composiciones familiares y los cinco finales tanto con la ruta especial como sin ella; la especialización económica paga sus mejoras sin Orsted. Las cifras ejecutadas y sus límites se registran en [VERIFICACION.md](VERIFICACION.md).
