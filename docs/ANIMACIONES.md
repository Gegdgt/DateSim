# Expresiones, documentos y transiciones

## Carrera de Rudy

Mantener cualquiera de las teclas Shift acelera los cuatro fotogramas de `Rudeus_walk.png` según la relación entre velocidad de carrera y caminata: 150/80 = 1,875. Caminar mantiene el intervalo normal de 0,1 s. Sin desplazamiento se muestra el fotograma 0 de reposo. Se conservan las dimensiones, escala entera y filtrado `nearest`; no se añaden sprites. [Configuración y colisiones](COLISIONES_NPC.md#caminar-y-correr-con-shift).

## Mano social compartida

La corrección social usa `src/ui/social_hand.lua` tanto en Nanahoshi como en las esposas. El reverso original aparece durante 0,55 s; cada intercambio real guardado de Fisher–Yates ocupa 0,12 s; después salen y se revelan las tres cartas. La duración total del reparto es `0,55 + 0,12 × intercambios + 1,15` segundos. El renderer no sortea otra mano.

Al confirmar, la carta de una actividad matrimonial sube desde su posición hacia el centro, se reproduce la voz encantada sintetizada y termina en el descarte en un segundo. Entonces se aplica la reacción, se cambia el retrato y se animan las barras con los deltas efectivos. Tras las dos primeras respuestas, una reposición de 0,45 s toma la siguiente carta del mazo persistido mientras las otras dos permanecen visibles. La reposición también ocurre sin energía: las tres opciones muestran su disponibilidad real y P permite terminar. Después de la tercera respuesta no se toma otra carta. Los estados bloquean confirmaciones repetidas. Movimiento reducido acelera estas transiciones al doble y mantiene el resultado legible.

Se añadieron `card_shuffle` y `enchanted_voice` al catálogo de síntesis existente; no son grabaciones de voz. Las capturas y pruebas se describen en [EXPLORACION_SOCIAL.md](EXPLORACION_SOCIAL.md). La escucha manual sigue pendiente.

El juego utiliza los PNG originales con filtro `nearest`, posiciones rasterizadas y escala uniforme. El canvas es de 640 × 360. Los retratos normales tienen cuatro cuadros horizontales de 64 × 64: `neutral=0`, `happy=1`, `worried=2`, `angry=3`. No se inventan expresiones adicionales: sorpresa se representa mediante movimiento y uno de esos rostros. Sylphiette conserva la misma escala en ambos ejes.

La campaña integrada reutiliza caminar/reposo de Rudy, los cinco idles familiares, elevación y apertura de la carta, magia fallida, entrega/mejora de cartas, ataques, escudos, curación, victoria/derrota, transiciones nocturnas y despedidas con anillo y caballo. La salida de Sylphie incluye a Lucy; el mundo actualiza sus ausencias. Los retratos separados se mantienen grises también en el resumen final. No se incorporaron ilustraciones nuevas ni se editaron PNG/ASE. [Capturas y límites conocidos](EXPLORACION_FASE_4.md).

`src/systems/animation.lua` proporciona interpolaciones y actores. Una línea puede declarar:

```lua
{speaker="nanahoshi", expression="worried",
 animation="small_shake", text="¿Rudeus? ¿Te encuentras bien?"}
```

| Movimiento | Comportamiento |
| --- | --- |
| `enter_left`, `enter_right` | Entrada lateral breve y aparición. |
| `exit_left`, `exit_right` | Salida lateral y desvanecimiento. |
| `happy_bounce` | Rebote de alegría. |
| `small_shake`, `angry_shake` | Sacudida discreta o más marcada. |
| `surprised_jump` | Salto breve. |
| `sad_lower` | Descenso suave y retorno. |
| `expression_change` | Cambio de rostro sin deformación. |

Los nombres históricos `shake` y `speaking` siguen disponibles. Las animaciones terminan una vez, vuelven a la posición base y no modifican las proporciones. Movimiento reducido elimina los desplazamientos; las acciones y avances siguen siendo accesibles.

## Introducción y documentos

La entrada al sueño utiliza un fundido blanco. Entra Hitogami y después Rudy con su cuerpo japonés; ambos permanecen visibles y tienen animaciones independientes. La escritura empieza al completar las entradas. Las líneas pueden animar también al oyente mediante `stage`. Hitogami se despide sonriendo, ambos salen y otro fundido blanco conduce al hogar y al Rudy rubio. Movimiento reducido elimina desplazamientos y conserva un fundido blanco breve. [Datos de apariencia y reparto](RETRATOS.md).

El sobre de `src/screens/document.lua` se dibuja como pixel art, se eleva desde la mesa, avanza al centro, pasa por escalas enteras 1–3, abre la solapa y presenta el texto paginado. La firma —H se destaca antes de la reacción de Rudy y el flashback del retrato real de Hitogami. Ese recuerdo en el mundo físico no cambia la apariencia de Rudy.

`src/data/documents.lua` conserva texto, título, fondo y firma. El visor acepta un documento y un callback para releerlo sin aplicar acontecimientos. La secuencia inicial registra una única lectura. Los intentos de agua y tierra producen destellos que se disipan, sonido de fallo y cambios de expresión; el silencio de Rudy no produce sonidos de voz.

## Cartas y combate

La entrega de una carta abre su reverso directamente; varios ejemplares ofrecen ver una por una o recibir todas. El regalo inicial mantiene las cinco sociales y las cinco físicas. La presentación individual conserva ese orden; la grupal usa páginas de cuatro cartas de 80 × 112, sin reducirlas. La revelación recorta el frente en píxeles enteros, sin estirar el PNG. `rewardQueue` conserva modalidad, fase, carta, página, reacción y progreso de animación. Recibir restantes abre el resumen completo.

Cada recompensa declara su reparto: hasta cuatro retratos reales a escala 1, a los lados de las cartas. Las expresiones usan los cuatro cuadros existentes; la sorpresa combina el cuadro preocupado con movimiento ligero. Hay destellos de dos píxeles, sonidos de aparición/revelación y señales distintas para desbloqueos y duplicados. Los eventos importantes utilizan la melodía breve `card_reward`, sin repetición; después se restaura el contexto anterior. Movimiento reducido elimina los saltos y destellos y acelera la entrega. Se respetan los controles de volumen de música y efectos. [Datos, controles y persistencia](ENTREGA_CARTAS.md).

Al jugar una carta social, la animación precede a la frase encantada y a la reacción; el resultado lógico se aplica una sola vez y la entrada queda bloqueada durante la presentación.

El combate muestra movimientos de Rudy, compañera y enemigo, impactos, escudos, curación y barras de vida. Los retratos usan los recursos reales disponibles; Badigadi usa su hoja normal de 64 × 64 para caber en la arena de la interfaz. Su hoja grande `badigadi_battle` también se valida y carga, con cuadros de 128 × 128.

`src/core/state_manager.lua` controla fundidos, sueño, desplazamiento horizontal, nuevo día, entrada a combate y regreso. Durante la transición no se duplican entradas.

Se ejecutaron 40 comprobaciones visuales de combate y 20 capturas reales en LÖVE, incluidas las cuatro fases de Badigadi. Se inspeccionaron las capturas del tutorial y del sello. El resto de los recorridos visuales y sus límites se detallan en [VERIFICACION.md](VERIFICACION.md).
