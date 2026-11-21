# Mushoku Tensei: Las Cartas del Destino

Juego narrativo de cartas en español para **LÖVE 11.5 / LuaJIT**. En esta continuidad alternativa, Rudy, Sylphiette, Roxy y Eris son adultos y ya están casados. Una poción vinculada a Hitogami sella la voz y el maná de Rudy; tiene siete días para conseguir el antídoto sin destruir sus matrimonios.

## Ejecutar

```powershell
./ejecutar.ps1
# O bien:
& 'C:\Program Files\LOVE\love.exe' .
```

No requiere red ni paquetes de Lua adicionales. Ventana inicial de 1280 × 720, canvas lógico de 640 × 360 y filtro `nearest`. El menú ofrece campaña, continuación, práctica social y de combate, combate libre, manual y opciones.

## Campaña completa

Las **40 cartas se mejoran hasta nivel 10** con duplicados y oro. Abre **M → Mejorar** para comparar efectos, costes y copias; la tienda vende copias adquiridas, libros, materiales y preparación. Cada esposa tiene un máximo diario de **+10 amor y +10 confianza**, compartido entre todas las fuentes. [Fórmulas, costes y arquitectura de la Fase 2](docs/FASE_2_PROGRESION.md).

Cada día dispone de **tres interacciones libres**, repetibles con cualquier esposa, y **un encargo independiente a Cliff o Zanoba**. La agenda muestra visitas, recompensas posibles y encargos pendientes. Permite dormir con espacios sin usar después de completar la historia obligatoria y consultar los cambios de ayer. Las escenas principales no gastan espacios. El Día 1 habilita actividades después del tutorial; el Día 7 cierra el tiempo libre antes de resolver los matrimonios. [Arquitectura y reglas de la agenda](docs/FASE_1_ACTIVIDADES.md).

| Día | Contenido |
| --- | --- |
| 1 · El silencio de Rudy | Sueño con Hitogami; despertar; recoger y leer la carta —H; descubrir voz y maná sellados; notas a Nanahoshi; regalo de Orsted; tutoriales jugables. |
| 2 · Palabras prestadas | Conversaciones con las tres esposas, necesidades distintas, nuevas cartas e investigación de la botica. |
| 3 · El primer fragmento | Investigación con Nanahoshi, bosque, ruinas, compañera elegida, combates y magia alimentada por energía externa. |
| 4 · El precio del silencio | Investigación del sello con Nanahoshi, conflictos familiares, emisario, recuerdo de la poción y pistas sobre Badigadi. |
| 5 · Lazos puestos a prueba | Duelo de entrenamiento con Eris; misiones personales, compromisos, reconciliaciones y cartas de compañeras. |
| 6 · El desafío del rey inmortal | Posible revancha con Eris; viaje a la arena, enfrentamientos previos y Badigadi en varias fases; neutralizar el sello libera el antídoto. |
| 7 · La verdadera voz | Uso del antídoto, conversación directa, resolución de relaciones y epílogo. |

Hitogami manipula la historia; no es un enemigo físico convencional. Orsted es aliado. Badigadi acepta la derrota y sobrevive. Hay exactamente **cinco finales**: las tres esposas, solamente Roxy, solamente Eris, solamente Sylphiette o ninguna. Las parejas viables pendientes se resuelven mediante decisiones narrativas, sin escoger automáticamente el mayor amor. [Capítulos y condiciones](docs/CAPITULOS.md).

## Cartas, emociones y relaciones

Nanahoshi entrega **diez cartas en total**: cinco sociales y cinco físicas. Los mazos empiezan vacíos y admiten después entre cinco y diez cartas adquiridas cada uno. Las cartas parlantes muestran una respuesta contextual con la voz encantada indicada en pantalla y un efecto sonoro; esta versión no incluye doblaje grabado.

En cada conversación se barajan las cartas **equipadas, adquiridas y compatibles** y se roban hasta tres. El tutorial conserva un reparto guiado. Selecciona una carta para leer **«Rudy dirá»**, su intención y su coste; puedes cancelar antes de usarla. Cada encuentro social admite tres acciones y cuatro puntos de energía total. Jugar descarta la carta y roba la siguiente si queda alguna; **P** permite escuchar en silencio, sin energía ni voz gratuita, cuando prefieras esperar o no tengas una opción asequible. Cargar conserva la mano y el orden restante.

Las conversaciones de Nanahoshi, Eris, Roxy y Sylphiette utilizan respuestas escritas por situación. La carta abre la frase de Rudy, la reacción de la otra persona y una continuación; amor, confianza y memoria se aplican al mostrar la reacción. Los números indican el cambio real, respetando el límite de 0–100. Una broma ante el entrenamiento de Eris, una duda sobre la fórmula de Roxy y una promesa a Sylphiette producen consecuencias distintas. La promesa de tiempo familiar puede cumplirse o incumplirse el día tres, recordarse el cuarto y repararse expresamente el quinto.

El inventario contiene **15 cartas sociales, seis híbridas y 19 de combate**. El catálogo escrito cubre nueve conversaciones de entrada; el [informe de cobertura](docs/COBERTURA_DIALOGOS.md) distingue respuestas, variantes, continuaciones y combinaciones posibles. Todo funciona sin conexión mediante tablas Lua, sin generación de texto durante la partida. [Guía de conversaciones y autoría](docs/DIALOGOS.md).

La carta firmada por **—H** es un documento, separado de ambos mazos. Se recoge mediante clic o teclado, se abre con animación y queda disponible en **J → Carta —H**. Leerla o cargar una partida no duplica sus eventos ni los regalos.

Cada personaje utiliza sus cuatro expresiones reales y movimientos breves. Las tres relaciones empiezan en **65 de amor y 65 de confianza**, con límites de 0–100. Promesas, conflictos, decisiones, reconciliaciones y misiones afectan los diálogos y el desenlace; curarse no repara automáticamente los matrimonios. [Sistemas](docs/SISTEMAS.md).

Sobre los retratos se muestran barras animadas con valores y cambios con signo. Las esposas tienen **Amor y Confianza**; Nanahoshi, **Confianza e Interés**, sin añadirse a los finales matrimoniales. Solo cinco cartas sociales pueden despertar su interés. El día cinco incluye un duelo real contra Eris, evaluado por estrategia y esfuerzo: una derrota honesta no recibe el castigo por dejar pasar repetidamente oportunidades claras. [Barras, afinidad y reglas del entrenamiento](docs/AFINIDAD_Y_ENTRENAMIENTO.md).

En el sueño inicial, Rudy recupera el cuerpo japonés de su vida anterior y aparece junto a Hitogami. Al despertar en casa vuelve a su aspecto rubio. Ambos retratos pertenecen a la misma identidad: el contexto visual no cambia relaciones, maldición ni progreso. Guardar y continuar recupera fondo, apariencia y expresión desde la línea narrativa. [Retratos contextuales y autoría](docs/RETRATOS.md).

## Combate

Rudy empieza con **30 PV, tres acciones por turno y maná natural bloqueado**. Los cinco ataques iniciales funcionan sin magia. Defensa y esquiva siempre están disponibles independientemente de la mano. Los fragmentos permiten alimentar hechizos de agua y tierra con energía externa; el antídoto restaura la magia natural.

Sylphiette protege y cura, Roxy analiza y conjura, Eris golpea e interrumpe. Badigadi pasa por resistencia, seis brazos, sello y victoria: reducir su vida a cero no basta; hay que **romper el sello con B**. La derrota permite reintentar o preparar el mazo. [Reglas de combate](docs/COMBATE.md).

La dificultad combina enemigos propios de cada día con perfiles acotados: aparecen debilitamientos, interrupciones y ataques múltiples anunciados. Antes de terminar el turno, compara la intención con tus PV y escudo; la defensa y la esquiva no dependen de robar una carta concreta. Curación básica y las cartas híbridas que curan permiten tres usos por batalla; Sylphiette dispone de tres curaciones efectivas y después conserva sus acciones de ataque y protección. Badigadi mantiene sus fases y el día siete se dedica al desenlace.

| Acción | Control |
| --- | --- |
| Leer / confirmar | Clic, Enter o Espacio |
| Examinar el sobre | Clic, E, Enter o Espacio |
| Seleccionar carta | 1–3, flechas o clic |
| Cancelar la carta social seleccionada | Esc o Cancelar |
| Terminar turno / tácticas | E / T |
| Defensa / esquiva / romper sello | D / V / B |
| Contraataque en el entrenamiento de Eris | C, después de un bloqueo o esquiva efectivos |
| Respiro social / historial de combate | P / H |
| Diario / mazos | J / M, desde la historia |
| Guardar / pausa / pantalla completa | F5 / Esc / F11 |

## Guardado y pruebas

La continuidad `rudy_curse` usa **versión 5**, en `%APPDATA%\LOVE\cartas_del_destino\campaign-v5.json`, con respaldo `campaign-v5.backup.json`. Incluye niveles, duplicados, oro, transacciones, presupuesto diario y todo el progreso anterior. **Continuar** migra v4 conservando la historia y el archivo original. El menú también puede importar la colección compatible de v1/v2/v3 con aceptación explícita, comenzando una nueva campaña. [Formato y recuperación](docs/GUARDADO.md).

```powershell
./probar.ps1
# O bien:
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

La suite usa la identidad aislada `cartas_del_destino_v5_tests` y genera capturas en `tests/artifacts/`. Los resultados realmente ejecutados y sus límites figuran en [VERIFICACION.md](docs/VERIFICACION.md). [Entrega y archivos](docs/REESTRUCTURACION.md), [manual](docs/MANUAL.md), [animaciones](docs/ANIMACIONES.md), [audio](docs/AUDIO.md) y [recursos](assets/README.md).

Se conservan los PNG y ASE existentes. Música y efectos son síntesis original sencilla; la valoración auditiva y las pruebas prolongadas con jugadores siguen siendo trabajo de producción.
