# Cobertura de conversaciones escritas

Inventario real: **15 cartas sociales, 6 híbridas y 19 de combate** (40 cartas jugables). Además hay **4 documentos/pistas narrativos**, que no entran en los mazos.

La poción del silencio (`silence_potion`) y el antídoto (`antidote`) son objetos de trama con iconos propios, fuera de ambos catálogos de cartas jugables. Tampoco se mezclan ni se roban como cartas sociales o de combate.

**9 conversaciones de entrada, 52 nodos totales, 126 respuestas base, 63 variantes escritas, 9 pausas y 43 conexiones distintas entre nodos.**

Las variantes consultan condiciones declaradas y tienen prioridad; no se construyen frases mezclando fragmentos. Las pausas no conceden puntos ni voz gratis.

## Cobertura por encuentro

| Encuentro | Día | Respuestas escritas | Cartas disponibles por día | Extras importables | Secuencias posibles |
| --- | ---: | ---: | ---: | ---: | ---: |
| `nanahoshi_test` | 1 | 6 | 6 | 0 | 156 |
| `encounter_eris` | 2 | 11 | 11 | 0 | 1111 |
| `encounter_roxy` | 2 | 12 | 11 | 1 | 1111 |
| `encounter_sylphiette` | 2 | 12 | 11 | 1 | 1111 |
| `day3_nanahoshi_research` | 3 | 14 | 14 | 0 | 2380 |
| `day4_nanahoshi_research` | 4 | 17 | 17 | 0 | 4369 |
| `day5_mission_eris` | 5 | 18 | 18 | 0 | 5148 |
| `day5_mission_roxy` | 5 | 18 | 18 | 0 | 5148 |
| `day5_mission_sylphiette` | 5 | 18 | 18 | 0 | 5148 |

`nanahoshi_test` es la fase social del checkpoint `day1_tutorial`, no una segunda campaña. Los extras tienen texto escrito para colecciones importadas; escribirlos no desbloquea sus cartas.

## Matriz de cartas y respuestas

| Carta | `nanahoshi_voice_test` | `eris_training_invitation` | `roxy_formula` | `sylphiette_family_time` | `nano_fragment_review` | `nano_seal_review` | `eris_injured_coordination` | `roxy_return_circle` | `sylphiette_home_anchor` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `listen` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `encourage` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `remember` | — | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `light_joke` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `change_subject` | — | — | Importada | Importada | — | Sí | Sí | Sí | Sí |
| `self_joke` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `be_honest` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `admit_error` | — | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `share_fear` | — | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `propose_plan` | — | — | — | — | Sí | Sí | Sí | Sí | Sí |
| `analyze_runes` | — | — | — | — | Sí | Sí | Sí | Sí | Sí |
| `earth_barrier` | — | — | — | — | Sí | Sí | Sí | Sí | Sí |
| `shared_magic` | — | — | — | — | — | — | — | — | Sí |
| `combined_spell` | — | — | — | — | — | — | — | Sí | — |
| `sword_magic` | — | — | — | — | — | — | Sí | — | — |
| `choose_together` | — | — | — | — | — | — | — | — | — |
| `subtle_flirt` | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `happy_reply` | — | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `bold_reply` | — | Sí | Sí | Sí | Sí | Sí | Sí | Sí | Sí |
| `angry_reply` | — | — | — | — | — | Sí | Sí | Sí | Sí |
| `sincere_apology` | — | — | — | — | — | Sí | Sí | Sí | Sí |

Sí = respuesta compatible por día/personaje; Importada = cobertura adicional; — = fuera del conjunto normal de ese día o de esa esposa. Una combinación sin contenido no es jugable.

## Alcance del cálculo

**25682 secuencias locales posibles** sumadas entre encuentros: permutaciones de una a tres cartas distintas, coste social total máximo de cuatro, sobre toda la colección compatible disponible por día. No se cuentan pausas, cartas futuras importadas ni multiplicaciones por variantes.

Es un espacio teórico de elecciones entre mazos y repartos posibles: cada partida usa solo su mazo equipado de cinco a diez cartas y su mano real. No son ese número de textos únicos ni una estimación de campañas completas; las condiciones, los costes de energía y el orden robado limitan cada recorrido.

Validación: **correcta**.
