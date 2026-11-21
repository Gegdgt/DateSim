# Expresiones, documentos y transiciones

El juego utiliza los PNG originales con filtro `nearest`, posiciones rasterizadas y escala uniforme. El canvas es de 640 × 360. Los retratos normales tienen cuatro cuadros horizontales de 64 × 64: `neutral=0`, `happy=1`, `worried=2`, `angry=3`. No se inventan expresiones adicionales: sorpresa se representa mediante movimiento y uno de esos rostros. Sylphiette conserva la misma escala en ambos ejes.

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

La pantalla de recompensas revela primero las cinco cartas sociales y luego las cinco físicas, con nombre, icono, coste y explicación. `rewardQueue` conserva el avance de la entrega. Al jugar una carta social, la animación precede a la frase encantada y a la reacción; el resultado lógico se aplica una sola vez y la entrada queda bloqueada durante la presentación.

El combate muestra movimientos de Rudy, compañera y enemigo, impactos, escudos, curación y barras de vida. Los retratos usan los recursos reales disponibles; Badigadi usa su hoja normal de 64 × 64 para caber en la arena de la interfaz. Su hoja grande `badigadi_battle` también se valida y carga, con cuadros de 128 × 128.

`src/core/state_manager.lua` controla fundidos, sueño, desplazamiento horizontal, nuevo día, entrada a combate y regreso. Durante la transición no se duplican entradas.

Se ejecutaron 40 comprobaciones visuales de combate y 20 capturas reales en LÖVE, incluidas las cuatro fases de Badigadi. Se inspeccionaron las capturas del tutorial y del sello. El resto de los recorridos visuales y sus límites se detallan en [VERIFICACION.md](VERIFICACION.md).
