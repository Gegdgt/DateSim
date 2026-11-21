# Conversaciones, cartas y memoria narrativa

Las cartas sociales representan frases escritas para una situación concreta. El catálogo cubre la prueba de voz de Nanahoshi, sus investigaciones de los días tres y cuatro, las tres conversaciones del día dos y las tres misiones personales del día cinco. El resto de la campaña conserva sus escenas declarativas y elecciones. No se afirma que todos sus diálogos sean encuentros de cartas ni que cada combinación posible tenga un texto exclusivo.

El inventario real contiene 15 cartas sociales, seis híbridas y 19 técnicas de combate. La poción, el antídoto y los documentos narrativos no se mezclan en los mazos. [Conteos y matriz generados desde los datos](COBERTURA_DIALOGOS.md).

## Cómo jugar una conversación

Prepara entre cinco y diez cartas sociales adquiridas con **M**, antes de entrar al encuentro. Las misiones y acontecimientos conceden cartas; el calendario por sí solo no las desbloquea. Puedes empezar con las cinco entregadas por Nanahoshi y ampliar el mazo al conseguir más. Las cartas exclusivas requieren a la compañera correspondiente.

Al entrar, el motor aparta las cartas sin respuesta escrita para esa situación o incompatibles con el personaje y baraja las restantes. Robas hasta tres de tu propio mazo. El tutorial usa un reparto guiado para enseñar los controles. Fuera de él, diferentes estados del generador pueden producir manos distintas; una repetición casual de la misma mano sigue siendo posible.

1. Selecciona con clic, **1–3** o las flechas.
2. Lee nombre, coste, intención y la frase exacta bajo **«Rudy dirá»**.
3. Confirma con el botón de jugar o **Enter**, o cancela con **Cancelar / Esc** sin gastar recursos.
4. La carta se anima, se descarta y, si queda alguna, se roba la siguiente.
5. Lee la frase de Rudy, la reacción y las continuaciones con **Enter**. Los efectos de relación y memoria se aplican al mostrar la reacción de la otra persona.

Cada encuentro social admite **tres acciones y cuatro puntos de energía total**. El coste no se repone al avanzar una línea. Si no hay una carta asequible o prefieres no utilizarla, **P** ofrece un respiro: Rudy escucha en silencio. Consume una acción, cuesta cero, no concede puntos y no permite hablar sin carta. Un mazo con menos de tres respuestas compatibles muestra un aviso para prepararlo mejor antes de la próxima conversación; no recibe cartas bloqueadas de regalo.

Las barras y el resultado muestran el cambio real, limitado por 0–100. Por ejemplo, una respuesta de +5 amor a una relación que ya tiene 98 aumenta dos puntos. Leer las continuaciones, guardar o volver a cargar no concede ese cambio otra vez. El avance de la tarea y la calidad de la relación son valores distintos.

Las placas siguen al retrato y animan esos valores durante 0,6 segundos. Las esposas muestran Amor y Confianza; Nanahoshi muestra Confianza e Interés. Sus cinco cartas favorables, los límites por contexto y la memoria del duelo de Eris se detallan en [Afinidad y entrenamiento](AFINIDAD_Y_ENTRENAMIENTO.md). Una respuesta positiva de Nanahoshi no establece un romance ni modifica los cinco finales matrimoniales.

## Las mismas cartas, situaciones diferentes

| Situación | Carta y frase de Rudy | Consecuencia narrativa |
| --- | --- | --- |
| Eris invita a entrenar | Broma ligera: «¿Quieres que me deje ganar?» | Se enfada; −5 amor, −2 confianza y recuerdo de la burla. |
| La misma invitación | Dar ánimo: «¡Claro que sí! Estoy contigo. Entrenemos juntos» | Acepta el apoyo; +5 amor, +3 confianza y práctica compartida. |
| La misma invitación | Coqueteo sutil: «Iré, pero si gano, quiero un beso» | Desafío romántico; +10 amor, +1 confianza y oportunidad posterior de entrenamiento. |
| Roxy revisa una fórmula | Escuchar: «Cuéntame qué has descubierto. Quizá podamos resolverlo juntos» | Explica dónde falla y abre una comprobación entre iguales. |
| Sylphiette pide tiempo juntos | Dar ánimo: «Tienes razón. Quiero que encontremos tiempo para nosotros» | Registra una promesa pendiente; decirlo no equivale a cumplirla. |

Los valores de Eris pertenecen a esa escena, no a bonificaciones universales de esas cartas. En el día cinco, con Eris lesionada, las mismas intenciones tienen otras frases y consecuencias. Las cuatro expresiones siguen siendo `neutral`, `happy`, `worried` y `angry`; el rubor es un efecto visual discreto, no un fotograma adicional.

La promesa familiar se decide con hechos al regresar el día tres. Sylphiette recuerda el cumplimiento o incumplimiento el cuarto; una disculpa permite reconocer el problema y la reparación explícita llega con el compromiso del quinto. Roxy recuerda el apoyo a sus dudas o las bromas que le dolieron. El desafío de Eris tiene un resultado propio que puede recordarse más adelante. Amor alto no elimina conflictos ni promesas rotas.

## Arquitectura actual

| Archivo | Responsabilidad |
| --- | --- |
| `src/data/dialogue/init.lua` | Une los paquetes y registra raíces por ID de encuentro; diagnostica duplicados. |
| `src/data/dialogue/nanahoshi.lua` | Prueba de voz y controles de las cartas. |
| `src/data/dialogue/eris.lua` | Entrenamiento del día dos y coordinación con una lesión el quinto. |
| `src/data/dialogue/roxy.lua` | Fórmula del segundo día y círculo de retorno del quinto. |
| `src/data/dialogue/sylphiette.lua` | Tiempo familiar y reparación del ancla del hogar. |
| `src/systems/dialogue_resolver.lua` | Comprueba compatibilidad, escoge una variante y construye una secuencia a partir de líneas ya escritas. |
| `src/systems/dialogue_memory.lua` | Captura el contexto y registra consecuencias una sola vez. |
| `src/systems/dialogue_validator.lua` | Valida datos, cobertura, referencias y ciclos; genera el informe. |
| `src/systems/cards.lua` | Filtra, baraja, roba, calcula vistas previas y reconstruye acciones guardadas. |
| `src/screens/encounter.lua` | Selección, cancelación, animación y lectura por líneas; aplica los efectos al aparecer la reacción. |

No hay servicios externos ni generación de prosa durante la partida. `src/systems/dialogue.lua` sigue administrando las escenas lineales; el resolver de cartas se añade a la arquitectura existente.

## Crear una conversación

Añade el contenido al paquete del personaje. `encounters` relaciona el checkpoint con la raíz, por ejemplo `encounter_roxy="roxy_formula"`. `nodes` es un mapa por ID; cada nodo repite su `id` para que el validador detecte claves equivocadas. El alias `nanahoshi_test` identifica la fase social del checkpoint `day1_tutorial`.

Una raíz declara `id`, `character`, `day`, `background`, `emotion`, `text`, `cards` y `fallback`. `character` es una identidad de `src/data/characters.lua`; no debe ser un ID de apariencia. `background` usa el manifiesto de recursos. `cards` debe incluir todas las cartas sociales o híbridas compatibles con el personaje y disponibles para ese día. La matriz señala además las respuestas escritas para cartas importadas de días posteriores. Añadir una respuesta nunca desbloquea su carta.

Este es un registro de respuesta dentro de `nodes.roxy_formula.cards`:

```lua
listen = {
    id = "roxy_formula_listen",
    rudy = "Cuéntame qué has descubierto. Quizá podamos resolverlo juntos.",
    response = "Gracias. A veces me concentro tanto que olvido que puedo pedir ayuda.",
    expression = "happy",
    animation = "speaking",
    effects = {score=3, love=3, trust=4},
    flags = {"roxy_supported_research"},
    next = "roxy_formula_check",
}
```

`score` mide avance, `love` y `trust` cambian la relación. En el resultado del motor, `chemistry` conserva el alias histórico de `love`; no es otra estadística. Los efectos escritos para el encuentro sustituyen el cálculo social genérico de afinidades. Las cartas de combate conservan sus propios costes y efectos.

Las consecuencias opcionales son:

| Campo | Ejemplo | Uso |
| --- | --- | --- |
| `flags` | `{"roxy_supported_research"}` | Eventos y decisiones booleanas consultables en conversaciones posteriores. |
| `promise` | `{id="family_time",status="pending"}` | Compromiso pendiente, cumplido (`kept`) o roto (`broken`). |
| `conflict` | `"broken_trust"` | Abre un conflicto que requiere reparación. |
| `reconcile` | `"family_time"` | Repara expresamente ese conflicto; no todos los demás. |
| `sharedMoment` | `"roxy_return_review"` | Registra una experiencia compartida. |
| `relationshipEvent` | `"personal_resolution"` | Evento personal ya utilizado por el sistema de relaciones. |
| `critical` | `{id="commitment",value=true}` | Decisión persistente utilizada por la resolución matrimonial. |

Usa IDs estables y no reutilices un identificador de respuesta para otra elección. Una disculpa cotidiana no debe declarar `reconcile` para una traición o promesa importante si la escena no contiene su reparación real.

## Variantes y continuaciones

`variants` contiene respuestas escritas con `id`, `requires` y una `priority` opcional. Sus campos sustituyen a los de la base; los campos omitidos se heredan. Si una variante declara `effects`, debe escribir los tres valores: el mapa se sustituye completo. La condición utiliza `src/systems/conditions.lua`, no funciones Lua arbitrarias.

```lua
variants = {
    {
        id = "roxy_formula_listen_pedestal",
        priority = 80,
        requires = {decision="roxy_equality", equals="pedestal"},
        rudy = "Antes elogié tu talento sin atender a la duda. Ahora quiero escuchar exactamente dónde falla.",
        response = "Entonces mira esta columna conmigo. Necesito una comprobación, no otra garantía de que soy perfecta.",
        expression = "neutral",
        effects = {score=2, love=1, trust=2},
        flags = {"roxy_supported_research", "roxy_heard_doubt"},
        next = "roxy_formula_check",
    },
}
```

Las condiciones admiten `all`, `any`, `['not']`, eventos, decisiones, umbrales de relación y los operadores matrimoniales existentes. Para confianza baja se puede negar un umbral: `{['not']={relationship="roxy",trust=55}}`. Los eventos y decisiones deben tener un productor real en capítulos o respuestas. Se selecciona primero la prioridad mayor; en un empate, la variante usada menos veces. Si persiste el empate, manda el orden de la lista. No se sortean estados emocionales incompatibles.

`next` apunta a un nodo con `id`, `character`, `expression` y `text`. Puede añadir `lines` con `{speaker,delivery,expression,text,animation}` y otro `next`. Rudy necesita `thought`, `note`, `enchanted` o `silence` como canal. La secuencia puede incluir su pensamiento y una segunda intervención de su esposa. Los enlaces se recorren sin ejecutar código de autoría y se rechazan los ciclos. Varias cartas pueden compartir una continuación si sus frases iniciales siguen siendo distintas y ese destino tiene sentido para ambas.

`fallback` tiene un ID propio, `rudy=""`, una reacción de espera, expresión, continuación y efectos cero. El motor puede omitir su mapa de efectos, que equivale a cero. La pausa nunca presta una voz encantada gratuita ni concede amor.

## Memoria, aplicación y guardado

`Resolver.context(session, definition, sceneId)` toma una copia de la memoria necesaria para el encuentro. `Cards.preview` resuelve la frase y la secuencia sin consumir cartas ni modificar la campaña. `Cards.play` paga el coste, descarta, roba y guarda el resultado. También avanza la memoria local del encuentro, para que las siguientes decisiones puedan recordar la acción confirmada.

La campaña recibe los cambios mediante `Memory.commit` al mostrar la línea de reacción marcada `apply=true`. La clave `social_<sceneId>_<turn>` impide duplicar el evento. El resultado conserva `actualLove` y `actualTrust` después de aplicar los límites; esos son los valores mostrados. Confirmar el cierre del encuentro no vuelve a sumar los deltas de las cartas.

El guardado conserva `narrativeVersion`, `initialOrder`, `initialMemory`, las zonas de cartas, energía, acciones, registro, `reactionIndex` y la lectura pendiente. `dialogueMemory.used` conserva el uso de variantes. `Cards.restore` reproduce el registro y compara los resultados; no baraja otra vez al cargar. Un encuentro anterior sin versión narrativa utiliza la compatibilidad de sus efectos originales, sin recuerdos o recompensas retroactivos. [Detalles de persistencia y recuperación](GUARDADO.md).

## Validar contenido y actualizar el informe

`Validator.validate(catalog?, options?)` devuelve `ok, errors, report`. `Validator.assertValid()` falla con diagnósticos legibles; `Validator.report()` devuelve Markdown. Comprueba IDs únicos, contenido no vacío, cuatro expresiones, puntuación básica, efectos finitos, cartas conocidas, exclusivas, condiciones y sus productores, destinos existentes, ciclos y cobertura por día/personaje. La coherencia de una frase con la personalidad exige además revisión editorial: una comprobación de signos no la demuestra.

Ejecuta `./probar.ps1` para la suite del proyecto. Dentro del runtime LuaJIT/LÖVE, el informe se actualiza así:

```lua
local Validator = require("src.systems.dialogue_validator")
Validator.assertValid()
local file = assert(io.open("docs/COBERTURA_DIALOGOS.md", "wb"))
file:write(Validator.report())
file:close()
```

El reporte cuenta nodos y respuestas escritos, variantes y conexiones. Su cifra de secuencias es una enumeración de una a tres cartas diferentes, hasta cuatro puntos de energía, sobre la colección compatible del día. Describe posibilidades entre mazos y repartos: no coloca más de diez cartas en un mazo real ni equivale a ese número de diálogos exclusivos o campañas completas.

## Relación con la dificultad del combate

Las respuestas sociales no activan por sí mismas un hechizo de combate ni aumentan estadísticas enemigas. `src/data/enemies.lua` define enemigos base, perfiles por día y repertorios anunciados; `resolve(id, context)` crea una copia para el encuentro. Los jefes y el entrenamiento de Badigadi conservan sus datos propios. `src/data/combat_cards.lua` contiene costes y límites; `src/systems/combat.lua` calcula daño, escudo, curación y replay. [Configuración, cifras y límites](COMBATE.md).

Las pruebas de diálogos están en `tests/dialogue_branching.lua` y `tests/dialogue_visual.lua`; las de dificultad en `tests/combat_balance.lua`. Se integran con las suites de campañas, combate y persistencia. Los resultados realmente ejecutados se documentan en [VERIFICACION.md](VERIFICACION.md).
