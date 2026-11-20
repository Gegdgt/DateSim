# Auditoría y verificación de la Fase 1

Ejecutada el **20 de noviembre de 2026** en Windows con **LÖVE 11.5 (Mysterious Mysteries)** real, usando `C:\Program Files\LOVE\lovec.exe`. Se revisaron `main.lua`, `conf.lua`, `src/app.lua`, datos, pantallas, sistemas, UI, recursos, pruebas y documentación antes de implementar los cambios.

## Hallazgos y correcciones

- La lógica existente ya implementaba los días uno y dos, cinco encuentros, decisiones, vínculos, diario, colección, pausa y guardado. Se conservaron las reglas de diez cartas, tres en mano, tres turnos, cuatro puntos de energía por encuentro y costes de cero a dos.
- El cargador buscaba fondos con nombres ingleses y cartas en rutas antiguas. Por eso usaba provisionales aunque los PNG definitivos estaban presentes. `src/data/assets.lua` ahora resuelve explícitamente las rutas españolas, sin renombrar PNG ni cambiar identificadores narrativos o de guardado.
- Las pruebas antiguas aceptaban imágenes de reserva con las dimensiones correctas. Las nuevas exigen objetos Image provenientes de los 42 PNG reales, sin avisos de reserva, y comparan las 28 expresiones con sus píxeles originales.
- La UI dibujaba un marco genérico y colores de texto pensados para ese provisional. `src/ui/card.lua` compone pergamino, marco de categoría, nombre, categoría breve, icono y coste; usa tinta oscura y deja la disponibilidad debajo y la descripción en un panel separado. Mano y colección comparten esa composición.
- El texto del registro de «Tomar un respiro» cambiaba al restaurar el encuentro. `Cards.pass` y `Cards.restore` ahora comparten su constructor; pausa y carga conservan el estado completo.
- Faltaba navegación general por teclado. Se añadió foco visible para botones y selección de cartas con flechas, manteniendo mouse, atajos y protección contra entradas duplicadas. Los controles están centralizados en `src/config/controls.lua`.
- Los ASE estaban mezclados con los recursos de ejecución. Se trasladaron 42 archivos a `sprite_sources/`, conservando exactamente sus SHA-256 y 175 114 bytes. Los PNG y los recursos auxiliares permanecen intactos; `.gitignore` sigue permitiendo versionar los ASE.

## Ejecuciones reales

La suite original pasó antes de modificar el código: 64 comprobaciones de lógica, 871 de narrativa, 27 de recursos, 4 de disco y 91 de integración. Ese resultado no detectaba el uso incorrecto de provisionales.

La ejecución final se realizó con:

```powershell
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

Resultado: **código de salida 0, 2 116 comprobaciones aprobadas**.

```text
OK: 340 comprobaciones de cartas, relaciones, JSON y guardado.
OK: 880 comprobaciones de narrativa, progresión y carga intermedia.
Resources: 412 checks passed (42 real PNGs, mappings, expressions, transparency and diagnosed fallbacks).
OK: 374 comprobaciones de composición de cartas, márgenes e interacción.
Filesystem: 6 checks passed in isolated test identity.
Integration: 104 checks passed; 70 screen steps.
ALL TESTS PASSED
```

El registro completo local está en `tests/artifacts/test.log`. Sus avisos de imágenes ausentes, de 1 × 1 o corruptas pertenecen a fallos inyectados deliberadamente en memoria. No indican errores de los PNG del repositorio. Ninguna prueba modifica esos PNG.

En el entorno de auditoría, el primer intento dentro del sandbox falló al inicializar el sistema de archivos de LÖVE. Las ejecuciones anteriores se realizaron después mediante la ejecución autorizada fuera de ese aislamiento. No se trató el intento fallido como una prueba aprobada.

## Cobertura

| Requisito | Evidencia |
| --- | --- |
| Siete personajes y hojas de 256 × 64 | Decodificación real, Image, nearest, alfa y comparación de los cuatro cuadros de cada personaje |
| Ocho fondos de 320 × 180 | Diez identificadores con mapas esperados; caché compartida de jardín/patio y entrenamiento/bosque |
| Dieciséis iconos y cuatro marcos | Rutas exactas por ID real y categoría de `cards.lua`; dimensiones, filtros y transparencia |
| Base, reverso y cinco auxiliares | Precarga real incluida en los 42 PNG únicos |
| Provisionales solo ante error | PNG válido nunca sustituido; ausente, corrupto, tamaño incorrecto e ID desconocido generan diagnóstico y reserva |
| Cartas legibles | Medición de todos los nombres, categorías, costes y descripciones; inspección de los píxeles dibujados dentro de márgenes y orden de capas |
| Reglas y efectos únicos | Dieciséis cartas en tres contextos, previsión sin mutación, energía, condiciones, pilas, acción gratuita y restauraciones repetidas |
| Guardado y decisiones | JSON validado, copias de respaldo y restauración de decisiones y encuentro exacto, también mediante archivos físicos |
| Pausa y continuación | Encuentros guardados después de cartas y acción gratuita; comparación del estado completo al volver y cargar |
| Fase 1 completa | Pantallas reales desde Nueva partida hasta el resumen del día dos en 70 pasos; variantes narrativas de los tres acompañantes con resultados altos y bajos |
| Mouse y teclado | Hitboxes transformadas, clics en bandas rechazados, foco visible, cartas deshabilitadas, coste cero sin energía y protección contra doble entrada |
| Ventana y pantalla completa | Cambios reales a 640 × 360, 960 × 540 y 1280 × 720; F11 entra/sale de pantalla completa, escala entera y transformación inversa del mouse |

El guardado físico usa `%APPDATA%\LOVE\cartas_del_destino_tests`; las pruebas no escriben en `cartas_del_destino`. Las pruebas de UI y el recorrido de integración sustituyen el guardado por memoria.

## Revisión visual

Se inspeccionaron las diez capturas renderizadas por LÖVE en `tests/artifacts/`: menú, diálogo, encuentro, mapa, resumen, diario, colección, opciones, galería de siete personajes con sus cuatro expresiones y galería de las dieciséis cartas. Se comprobaron las capas reales, las proporciones, el contraste, los márgenes y la separación entre personajes, cartas, detalles y botones. Los pies de pantalla y etiquetas de disponibilidad tienen fondo opaco para seguir siendo legibles sobre los escenarios reales.

Las capturas y logs son artefactos regenerables ignorados por Git, no recursos del juego. La inspección visual se realizó sobre capturas; el recorrido de pantallas, entradas y cambios de ventana fue automatizado mediante LÖVE. No se presenta como una sesión manual de juego prolongada.

La comprobación final contra los blobs originales de Git confirmó SHA-256 idénticos para los **45 PNG** (42 de ejecución y tres auxiliares) y los **42 ASE** trasladados. `git diff --check` terminó sin errores.

## Archivos de la entrega

| Área | Archivos creados o modificados |
| --- | --- |
| Recursos | `src/data/assets.lua` (nuevo), `src/systems/resources.lua` |
| Coordinación y controles | `src/app.lua`, `src/config/controls.lua` |
| UI | `src/ui/card.lua` (nuevo), `src/ui/screen.lua`; `src/screens/encounter.lua`, `overlays.lua`, `dialogue.lua`, `hub.lua`, `summary.lua` |
| Lógica | `src/systems/cards.lua` |
| Pruebas | `tests/gameplay.lua`, `story.lua`, `resources.lua`, `run.lua`, `ui.lua` (nuevo) |
| Documentación | `README.md`, `assets/README.md`, `assets/cards/LEEME.md`, `docs/SISTEMAS.md`, `docs/VERIFICACION.md`, `docs/RECURSOS.md` (nuevo), `docs/FASE_2.md` (nuevo), `docs/CODIGO_COMPLETO.md` regenerado |
| Herramientas | `tools/export_source.py` |
| Fuentes | 42 movimientos desde `assets/` hacia el mismo árbol relativo dentro de `sprite_sources/` |

`main.lua`, `conf.lua`, las definiciones de cartas y personajes, la narrativa, el esquema de guardado y `.gitignore` se revisaron y se conservaron.

## Límites y siguiente fase

La verificación cubre la Fase 1 y los recursos preparados. No implementa ni valida escenas de días tres a siete. Permanecen pendientes el editor de mazo, audio, elección de ruta y confesiones, escenas de los siete finales y distribución autónoma para Windows. Jardín y entrenamiento reutilizan temporalmente patio y bosque.

Las transiciones y checkpoints todavía contienen casos específicos de la Fase 1. [FASE_2.md](FASE_2.md) detalla su migración a un registro declarativo compartido antes de incorporar el día tres. No se modificaron sus reglas narrativas durante esta integración visual.
