# Cartas sociales y actividades presenciales

Las 45 actividades se abren hablando con la esposa que está delante de Rudy. `src/data/wife_activities_{eris,roxy,sylphie}.lua` conserva sus respuestas, combates, compras, premios y requisitos. `src/data/activity_conversations.lua` añade para cada ID una propuesta breve, dos preguntas de continuación y un cierre. `wife_activities.lua` integra los bancos, las variantes que dependen de la carta anterior y las 88 respuestas añadidas en `src/data/wife_starter_responses.lua`. Al cargar los datos se comprueba que las cinco cartas iniciales tengan una respuesta escrita para cada actividad.

## Límites y energía

`src/data/social_rules.lua` define `energy=6` y `maxCards=3`. Son límites **por actividad**, independientes de las tres interacciones diarias y del maná de combate. Una actividad sólo cuenta al terminar, incluidos su combate o servicio. Cancelar la propuesta no reserva ni consume nada. Tras empezarla, P permite cerrar la conversación; los servicios y combates pendientes se resuelven a continuación.

El mazo inicial contiene **Escuchar, Broma ligera, Hablar con honestidad, Dar ánimo y Coqueteo sutil**. Las cinco sirven en las 45 actividades y permanecen desbloqueadas y equipadas después de conversar; el descarte pertenece al encuentro, no a la colección. La primera copia se representa mediante `unlocked` y nivel 1; `collection.copies` cuenta los duplicados disponibles para mejorar.

Una nueva actividad exige al menos cinco cartas equipadas, desbloqueadas y compatibles. Se mezclan todas las elegibles, también las avanzadas con respuesta escrita; se toman tres y se conservan las demás en el mazo. Las avanzadas excluidas por requisitos o falta de respuesta se nombran en la introducción, sin inventar frases. Si un mazo personalizado deja menos de cinco elegibles, hay que ajustarlo antes de comenzar; no se paga ni reserva una actividad con una mano reducida.

| Momento, con el mazo inicial | Mano | Mazo | Descarte |
| --- | --- | --- | --- |
| Antes de la respuesta 1 | 3 | 2 | 0 |
| Antes de la respuesta 2 | 3 | 1 | 1 |
| Antes de la respuesta 3 | 3 | 0 | 2 |
| Después de la respuesta 3, encuentro resuelto | 2 | 0 | 3 |

Confirmar una de las dos primeras cartas y continuar tras su reacción repone automáticamente la mano. Inspeccionar o cancelar no toma ni descarta nada. No se mezcla el descarte durante el encuentro y no se repone tras la tercera respuesta. El siguiente encuentro mezcla de nuevo el mazo equipado completo.

**Tres visibles no significa tres pagables.** Los costes y las mejoras no se alteran. Si la energía no alcanza, la carta indica «SIN ENERGÍA» y la confirmación está deshabilitada; aun con cero de energía permanecen las tres opciones visibles y P permite terminar. La animación de reposición conserva las otras dos cartas en sus posiciones.

## Coste y efecto por persona

Los IDs de carta existentes se mantienen. `src/data/cards.lua` incorpora `target_affinity` desde la tabla `affinities` de `social_rules.lua`. Ejemplo real:

```lua
listen = {
    sylphiette = {cost=3, love=5, trust=1},
    roxy       = {cost=1, love=1, trust=1},
    eris       = {cost=2, love=2, trust=1},
}
```

Estos valores son la base de una respuesta apropiada en nivel 1. También hay afinidades de `encourage`, `be_honest` y `subtle_flirt`. Para las demás cartas, el coste social procede de `card.cost`, limitado a 1–3. Un `cost` explícito en una afinidad puede establecer una excepción especial. Conviene mantenerlo entre 1 y 3 para el mazo ordinario.

El efecto se calcula en este orden:

1. Se elige la respuesta de la actividad y su variante `after`, si corresponde.
2. Para cada estadística **positiva**, se usa la base de afinidad o la base de esa respuesta. Un cero permanece en cero; una penalización no se transforma en premio por afinidad.
3. La base positiva se multiplica por `1 + floor((nivel - 1) / 2)`: factores 1/2/3/4/5 en niveles 1/3/5/7/9. Los niveles y mejoras existentes llegan hasta 10.
4. Se añaden los `context_modifiers` que cumplan estado emocional, carta previa y requisitos narrativos.
5. El sistema existente de relaciones aplica estado matrimonial, bonificaciones/reducciones narrativas, rango −100…100 y el margen diurno restante de +10 amor/+10 confianza por esposa. Una pérdida no devuelve margen.
6. La interfaz presenta la diferencia **real** entre el valor anterior y posterior. No muestra la predicción durante la selección.

`src/systems/social_rules.lua` centraliza coste y efecto. Nanahoshi usa su resolución narrativa y sus estadísticas propias de confianza/interés; no se convierte en matrimonio. Sus encuentros nuevos también parten de seis de energía. Los encuentros narrativos antiguos conservan su presupuesto original al restaurarlos.

## Frase, reacción y contexto

Una entrada `bank.answer` escribe el contenido específico de la situación:

```lua
local r = bank.answer(
    "listen",
    "Explícame qué parte de la fórmula te preocupa.", -- frase visible antes de confirmar
    "La presión cambia justo al cerrar el circuito.", -- reacción posterior
    1, 2, "worried", {}                              -- amor, confianza, expresión, efectos
)
r.minLevel = 1
r.requires = {event="starter_gift"}
r.after = {
    light_joke = {
        rudy="La broma estuvo fuera de lugar. Quiero entenderte.",
        reply="Entonces revisemos primero lo que dejaste sin responder.",
        love=-1, trust=-1, expression="worried"
    }
}
r.context_modifiers = {
    {after="be_honest", emotion="worried", trust=1},
    {requires={event="ruins_mission"}, love=0, trust=1}
}
```

Este fragmento ilustra la configuración; no añade otra carta. Incluye `r` en las respuestas de la actividad correspondiente. `requires` usa el lenguaje de tablas de `src/systems/conditions.lua` (`event`, `decision`, `relationship`, `all`, `any`, `not`, etc.). Sus requisitos de entrada se evalúan antes de repartir y no eliminan cartas de una mano ya guardada si un evento cambia durante la conversación.

`emotion` compara el estado guardado: inicialmente `def.emotion`, después la expresión de la última reacción (`worried`, `angry`, `happy`, etc.). Los modificadores se aplican después del factor de nivel. Usa valores negativos en la respuesta/variante para una intención inapropiada, y no una base positiva esperando que la afinidad la ignore.

Ejemplos implementados: E01 reacciona mal a «¿Quieres que me deje ganar?» y permite reparar con honestidad o ánimo. S15 mantiene una reacción negativa al escuchar después de trivializar las promesas con una broma; la afinidad de Sylphie no borra esa consecuencia. Las 255 respuestas base y las variantes contextuales están en los datos, no generadas a partir de una frase genérica.

Los requisitos de actividad incluyen día mínimo/máximo, confianza, evento, duelo previo, oro disponible, matrimonio activo y cartas compatibles. E01 se mantiene accesible en los días 1–5 mientras falte entrenar; R05 conserva el acceso a la investigación desde el día 3; S03 se fija cuando existe un recado pendiente o incumplido.

## Interfaz, animación y persistencia

`src/ui/social_hand.lua` sirve a `screens/encounter.lua` y `screens/wife_activities.lua`. Dibuja los marcos, iconos, categorías y reversos existentes a través de `src/ui/card.lua`. Antes de confirmar se ve el nombre completo, coste para el interlocutor y frase exacta de Rudy; la reacción y las ganancias se ocultan.

El barajado visual reproduce los intercambios Fisher–Yates guardados, sin llamar a un generador aleatorio desde el dibujo. Sigue el reparto, revelado, elevación de la carta, voz encantada sintetizada, reacción, descarte y reposición animada. El modo de movimiento reducido acorta la duración. «Tomar» es la terminología de la interfaz.

`daily.active_activity.socialVersion=2`, con `handVersion=2` para las manos completas, guarda orden, intercambios, mano, pila, descarte, energía, registro de cartas, elección y fase. Confirmar bloquea la entrada y descuenta energía; al terminar la animación se aplica el evento único `<reserva>_card_<n>`. Cargar en cualquiera de estas fases no vuelve a barajar ni cobra dos veces. El resultado definitivo y los recibos permanecen en `wifeActivities.history`; ver de nuevo el cierre no da otro premio. [Detalles del guardado](GUARDADO.md).

Para verificar cambios de datos:

```powershell
$env:DATESIM_TEST_MODULE='social_exploration'
./probar.ps1
$env:DATESIM_TEST_MODULE='wife_activities'
./probar.ps1
Remove-Item Env:DATESIM_TEST_MODULE
```

## Causa y verificación de la mano completa

El reemplazo ya existía, pero `handCandidates` eliminaba las cartas sin respuesta escrita. En 44 actividades faltaban dos de las cinco iniciales: el mazo quedaba reducido a tres y la toma inicial lo vaciaba. Se completaron 88 pares de frase/reacción específicos de la situación; ahora hay 255 respuestas base. La validación mínima de cinco evita repetir el problema al editar un mazo.

`tests/social_hand_cycle.lua` comprueba el ciclo 3/2/0 → 3/1/1 → 3/0/2, conservación de la colección, 36 encuentros con distintas semillas y otros tres mediante escritura/lectura real del archivo de partida, mazos ampliados, inspección/cancelación, falta de energía, eventos únicos y guardado/carga exactos antes y después de cada reacción y reposición. También verifica la ampliación de guardados antiguos que habían perdido cartas por el filtro. `tests/social_exploration.lua` y `tests/wife_activities.lua` comprueban todas las respuestas, tamaños de texto, recompensas y accesos físicos. La regresión incluye el tutorial y las animaciones de Nanahoshi.

Cambios principales: `src/data/wife_starter_responses.lua` (nuevo), `src/data/wife_activities.lua`, `src/systems/wife_activities.lua`, `src/screens/wife_activities.lua`, `src/ui/social_hand.lua`; pruebas en `tests/social_hand_cycle.lua` (nuevo), `tests/social_driver.lua`, `tests/social_exploration.lua`, `tests/wife_activities.lua` y `tests/run.lua`.

Capturas de Eris: [turno 1](../tests/artifacts/hand-cycle-eris-turn-1.png), [turno 2](../tests/artifacts/hand-cycle-eris-turn-2.png), [turno 3](../tests/artifacts/hand-cycle-eris-turn-3.png), [reposición](../tests/artifacts/hand-cycle-refill.png), [sin energía](../tests/artifacts/hand-cycle-no-energy.png). También se capturaron los tres turnos de Roxy y Sylphie. [Resultados de las pruebas](VERIFICACION.md).
