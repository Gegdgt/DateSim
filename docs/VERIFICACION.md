# Verificación de la Fase 1

Ejecutada el 20 de noviembre de 2026 con **LÖVE 11.5 (Mysterious Mysteries)** instalado en Windows, no solamente con un intérprete simulado.

```powershell
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

Resultado: código de salida 0. Resumen de la suite:

```text
OK: 64 comprobaciones de cartas, relaciones, JSON y guardado.
OK: 871 comprobaciones de narrativa, progresión y carga intermedia.
Resources: 27 checks passed (64x64 frames, PNG and fallback).
Filesystem: 4 checks passed in isolated test identity.
Integration: 91 checks passed; 70 screen steps.
ALL TESTS PASSED
```

Las comprobaciones cubren conservación de las diez cartas, Fisher–Yates, costes, energía agotada, acción gratuita, tres turnos exactos, índices incorrectos, contexto y exclusividad, recuperación de encuentros, límites de vínculos, requisitos de romance, siete resultados lógicos, parsing seguro y respaldo. Se recorrieron las tres variantes de compañía con puntuación alta y baja, comprobando decisiones y eventos sin duplicación.

Los retratos usan cuadros de 64 × 64 y hojas de 256 × 64. Una prueba con PNG generado en memoria verifica los cuatro recortes con índices 0–3, la expresión neutral por defecto, los límites de cada cuadro y el filtro `nearest`. También comprueba los siete personajes y el recurso provisional ante imágenes ausentes, corruptas o con dimensiones antiguas. Se revisaron nuevamente las capturas de menú, diálogo, encuentro y mapa tras ajustar las posiciones y escalas.

La integración ejecuta las pantallas reales sobre el renderer de LÖVE, utiliza clics transformados al espacio lógico y avance de diálogo, y recorre 70 pasos desde Nueva partida hasta el resumen del día dos. Comprueba la restauración exacta del encuentro tanto al pausar como al continuar, el ajuste de los diálogos, la escala entera, el centrado y el rechazo de clics en las bandas.

El guardado físico usa `%APPDATA%\LOVE\cartas_del_destino_tests`; las pruebas no alteran `cartas_del_destino`. El resto de recorridos usa guardado en memoria.

Se inspeccionaron las ocho capturas generadas en `tests/artifacts/`: menú, diálogo, encuentro, mapa, resumen, diario, colección y opciones. Se corrigieron la etiqueta de vínculo para mostrar español y la posición del icono dentro del marco. Las imágenes son regenerables y no forman parte de los recursos obligatorios del juego.

Alcance: esta verificación cubre la Fase 1. No afirma que existan o hayan sido probadas escenas de días tres a siete, música, sprites definitivos, un editor de mazo o una distribución ejecutable independiente de LÖVE.
