# Combate durante la maldición de Rudy

Rudy tiene 30 PV, tres acciones por turno y magia natural bloqueada hasta beber el antídoto. Las cartas físicas iniciales causan entre 1 y 3 puntos; después mejora cartas y canaliza magia mediante energía externa. Cada compañera disponible tiene una acción propia por turno. [Configuración, fórmulas, habilidades y balance de la Fase 4](FASE_4_COMBATE.md).

## Preparación y controles

Antes de luchar se muestran enemigo, PV, equipo, afinidad y potencia. **T** permite revisar habilidades, costes, cargas y recargas; **M** vuelve a preparar el mazo y comprar mejoras. El mazo admite entre cinco y diez cartas distintas adquiridas y al menos dos ataques. Las exclusivas requieren a su esposa presente y con matrimonio activo. Comenzar habilita las acciones.

| Control | Acción |
| --- | --- |
| Clic o 1–3 | Inspeccionar una carta |
| Enter | Confirmar carta o comenzar desde preparación |
| D | Defensa: 5 escudo físico, una acción, una vez por turno |
| V | Esquiva: 3 escudo físico, una acción, una vez por turno |
| T | Elegir compañera y habilidad |
| E | Terminar turno; actúa el enemigo y se roba nueva mano |
| H | Historial de daños, bloqueos y apoyos |
| B | Romper un anclaje del sello expuesto: una acción |
| C | Contraataque de entrenamiento con Eris tras defensa efectiva |

Escudos absorben antes que la vida y caducan al volver a Rudy. Golpes múltiples consumen el mismo escudo entre impactos. Intenciones y vistas previas consideran debilitamientos y muestran daño real. El artefacto recupera cuatro de energía por turno hasta su capacidad adquirida, máximo 30; el maná natural permanece separado y bloqueado. El esfuerzo no puede consumir el último PV.

## Progresión y compañeras

PV ordinarios de referencia: 10, 20, 36, 55, 180, 260 y 300 según día; guardianes y reflejos varían. Aparecen defensas, golpes preparados, debilitamientos e interrupciones. Día 6 incluye el emisario de Hitogami y, si se entrenó con Eris en cada día 1–5, la demostración no ganable y no letal de Orsted. Ésta usa 120 de guardia finita, tres turnos de ataques y una terminación controlada en el cuarto; la derrota narrativa permite continuar sin penalizar relaciones. [Secuencia y recompensas](FASE_5_CIERRE.md). Día 7 presenta a Badigadi con **1000 PV**, independientemente del equipo.

El daño de apoyo escala con el promedio de amor y confianza, acotado a 0–100 y dividido entre 100. Especiales máximos: Sylphiette 90, Eris 150 y Roxy 110; tres usos, recarga de tres turnos y costes de 4, 4 y 5 de energía. Sus ataques normales son menores. Roxy analiza y reduce defensas; Eris protege e interrumpe; Sylphiette alterna ataque, barrera y curación. Las separadas no participan.

La curación de Sylphiette cuesta dos de energía, recarga en dos turnos y tiene tres usos. Con afinidad media 90/80/50/25 cura respectivamente 40%/30%/20%/10% de PV máximos, sin sobrepasarlos. Por debajo de 25, la interferencia de la maldición causa 40% de daño: exige confirmación explícita y puede causar derrota. Cancelar no gasta recursos.

## Badigadi y el antídoto

1. Resistencia: ataques de 4 y preparación.
2. A 750 PV: tres ataques de 2, alternados con preparación.
3. A 350 PV: tres ataques de 3 y resistencia de 6. Agua, análisis y especiales combinados ayudan a superarla.
4. A cero PV: dos anclajes del sello, 12 de resistencia total; **B** quita 6 por acción. Agotar PV no basta para ganar.

Badigadi acepta la derrota y sigue vivo. La victoria entrega el antídoto una vez; beberlo después restaura voz y magia sin reparar relaciones automáticamente. Puede vencerse sin Orsted ni compañeras. Perder permite reintentar o revisar el mazo. El plazo máximo es 75 turnos para el jefe y 30 para encuentros ordinarios.

## Entrenamiento y continuidad

El duelo con Eris conserva resistencia no letal, contraataque, métricas de esfuerzo y resultados narrativos. Perder permite continuar. [Afinidad, entrenamiento y revancha](AFINIDAD_Y_ENTRENAMIENTO.md).

Los combates nuevos guardan `warVersion=1` y `balanceVersion=3` dentro del formato v8. Las batallas antiguas se reproducen con módulos históricos, incluidas sus cifras originales; los archivos anteriores no se sobrescriben. Cargar no duplica cargas, acciones ni premios. [Guardado](GUARDADO.md).

La verificación incluye 576 simulaciones del jefe, 36 encuentros intermedios, fórmulas de afinidad, controles reales, capturas y recorridos completos de campaña con compras legales. Los ensayos históricos están separados del balance actual. [Resultados medidos](VERIFICACION.md).
