# Entrega: la maldición de Rudy

Implementación sobre el repositorio existente. Se reutilizaron el motor de escenas, cartas, relaciones, combate, guardado y audio. No se crearon ni sustituyeron PNG o ASE. El repositorio ya contenía trabajo local previo; esta entrega lo integra y no atribuye todos los cambios de Git a esta sesión.

## Secuencia y capítulos

La campaña comienza en el sueño de Hitogami, con transición blanca, música inquietante y su retrato real. Sus expresiones cambian entre neutral y sonrisa. Sus alusiones al regalo y a los secretos anticipan el peligro sin explicar la maldición. Rudy puede hablar dentro del espacio mental.

Al despertar, Rudy ve un sobre en el hogar. **Examinar carta** inicia elevación, desplazamiento, escalado entero y apertura. El texto completo termina en **—H**. El acercamiento a la firma conduce a un recuerdo de Hitogami. Sólo después se descubren la pérdida de voz y los fallos de agua y tierra, con efectos visuales y sonoros. Los intentos mudos no reproducen el sonido de escritura del diálogo.

En el laboratorio, Rudy utiliza notas. Nanahoshi analiza la carta, abre el cofre de Orsted y adapta el encantamiento de voz. Entrega **cinco cartas sociales y cinco físicas**, una por una. Siguen una prueba social real con Nanahoshi y el combate contra la anomalía. Las cartas utilizan magia almacenada; no curan a Rudy.

Los días 2–7 están conectados: palabras prestadas y necesidades de cada esposa; fragmentos de energía; investigación y recuerdo del emisario; misiones matrimoniales; Badigadi y antídoto; recuperación de voz, conversaciones directas y cinco epílogos. La narración detallada, decisiones y condiciones están en [CAPITULOS.md](CAPITULOS.md).

## Sistemas entregados

- **Documentos:** `hitogami_letter` se guarda en `session.clues`, separado de la colección. El diario permite releerla. La apertura conserva fase, tiempo y página al guardar; leer y releer no repite recompensas. El visor también sirve para otros documentos con identidad propia.
- **Cartas parlantes:** 21 cartas sociales con ocho tonos, frases por contexto y destinataria, costes, requisitos, iconos y procedencia. Seleccionar y confirmar reproduce la frase mediante el encantamiento, anima la carta y muestra una reacción. Las decisiones se registran y sus efectos se confirman una vez.
- **Expresiones:** las cuatro celdas reales son neutral, feliz, preocupada y enojada. Las entradas, salidas, rebotes, saltos y sacudidas son movimientos finitos; no añaden fotogramas ni deforman sprites. Se respeta el movimiento reducido. Sylphiette se dibuja con la misma escala en ambos ejes.
- **Relaciones:** amor y confianza entre 0 y 100, valores iniciales 65/65, promesas, acontecimientos, conflictos, reconciliaciones, decisiones e historial matrimonial. Repetir un evento no concede amor. La cura no borra consecuencias.
- **Combate:** cinco ataques físicos iniciales, defensa y esquiva disponibles sin cartas, vida, acciones, escudos físico/mágico, maná natural y energía externa separados. Los fragmentos alimentan artefactos mientras el maná natural permanece bloqueado. Las habilidades de agua, tierra y compañeras se obtienen durante la campaña.
- **Badigadi:** resistencia, seis brazos, sello y victoria. Llevar sus PV a cero abre la fase del sello; hay que neutralizarlo expresamente con B o su botón. Badigadi acepta la derrota y entrega el antídoto; no muere. Las derrotas permiten reintentar o preparar el mazo.
- **Finales:** familia unida, sólo Roxy, sólo Eris, sólo Sylphiette o solitario. Dependen de historia y compromisos además de cifras. Las situaciones con dos vínculos viables se resuelven mediante acuerdos visibles.
- **Guardado:** versión 3, `campaign-v3.json`, respaldo independiente y pruebas aisladas. La importación explícita conserva la colección compatible y reinicia la continuidad sin modificar los archivos v1/v2.

## Módulos nuevos de esta entrega

| Archivo | Función |
| --- | --- |
| `src/data/documents.lua` | Carta —H y pistas de investigación |
| `src/systems/curse.lua` | Reglas de voz, magia natural y secreto |
| `src/screens/document.lua` | Recoger, abrir, leer y releer documentos |
| `tests/curse_intro.lua` | Orden de introducción, documento persistente, secreto, cura y movimiento |
| `tests/curse_social.lua` | Mazo inicial, tonos, frases, reacciones, persistencia e iconos |

## Archivos actualizados

| Área | Archivos |
| --- | --- |
| Narrativa | `src/data/chapters/day1.lua`–`day7.lua`, `endings.lua`, `characters.lua`, `manual.lua` |
| Datos jugables y presentación | `src/data/cards.lua`, `combat_cards.lua`, `enemies.lua`, `assets.lua`, `audio.lua`, `presentation.lua` |
| Reglas | `src/systems/cards.lua`, `combat.lua`, `combat_tutorial.lua`, `tutorial.lua`, `events.lua`, `progression.lua`, `save.lua`, `animation.lua`, `resources.lua`, `narrative_validator.lua` |
| Pantallas | `src/screens/dialogue.lua`, `encounter.lua`, `reward.lua`, `collection.lua`, `overlays.lua`, `menu.lua`, `combat.lua`, `combat_deck.lua`, `combat_safe.lua` |
| Integración y gráficos | `src/app.lua`, `src/core/state_manager.lua`, `src/ui/card.lua` |
| Pruebas | `tests/run.lua`, `resources.lua`, `marriages.lua`, `audio_options.lua`, `campaign.lua`, `combat.lua`, `combat_integration.lua`, `combat_visual.lua`, `restructure_integration.lua` |
| Documentación | README, manifiesto de recursos, capítulos, sistemas, guardado, combate, audio, animaciones, manual, verificación e informe de entrega |
| Exportación | `tools/export_source.py`, `docs/CODIGO_COMPLETO.md` |

## Ejecutar y verificar

```powershell
./ejecutar.ps1
./probar.ps1
```

Requiere LÖVE 11.5 para Windows. También se puede ejecutar `love.exe .` y `lovec.exe . --test` desde el proyecto. El resultado real de la suite integrada y las capturas están documentados en [VERIFICACION.md](VERIFICACION.md).

## Límites de producción

La campaña y los cinco desenlaces están implementados; no quedan módulos narrativos anunciados pero desconectados. La música y los efectos son síntesis original sencilla. La voz de las cartas se representa mediante texto y sonido de encantamiento, sin doblaje grabado ni TTS. La suite automatizada y la inspección de capturas no sustituyen una prueba prolongada con jugadores ni una revisión auditiva subjetiva. Los guardados de la narrativa anterior requieren comenzar la nueva historia mediante importación explícita.
