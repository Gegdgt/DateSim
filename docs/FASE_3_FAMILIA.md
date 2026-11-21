# Fase 3 — Actividades y consecuencias familiares

La campaña conserva sus siete capítulos, introducción, cartas, mazos, PNG y ASE. La agenda ofrece **16 actividades**, tres espacios diarios repartibles libremente y un encargo independiente. Reservar una actividad consume exactamente un espacio; sus decisiones, combate y recompensas no consumen otro. Ayudar a un encargado sí utiliza uno y exige confirmar la advertencia en pantalla.

## Actividades

| Esposa | Actividades y recompensas |
| --- | --- |
| Eris | Entrenamiento físico, monstruos en solitario o acompañados, duelo amistoso y coordinación. Oro, copias ofensivas, materiales y progreso. El duelo evalúa los ataques, bloqueos, esquivas y oportunidades reales; admite victoria, derrota honorable, derrota honesta y aparente falta de esfuerzo. |
| Sylphiette | Hogar, recados de su hija, cuidar a Zenith, ayudar a Lilia y conversaciones familiares. Cartas sociales, oro y responsabilidades verificables. Prometer un recado fija un plazo al cierre del día siguiente (día 7 como máximo); incumplir cuesta −3 amor/−5 confianza. Hacer el recado repara el conflicto. |
| Roxy | Magia, cartas encantadas, libros e investigación. Cartas mágicas, materiales, recetas y conocimientos. Cada receta reduce un 20% el oro de una mejora, con coste mínimo de 1; se consume al mejorar y no reduce duplicados. |
| Cada esposa | Reparar un compromiso: hasta +8 amor/+8 confianza, sujeto al límite diario pero sin reducción por afinidad negativa. No revierte una separación. |

Tres sesiones de hogar, investigación o coordinación, con al menos 50/50 y matrimonio activo, permiten adquirir respectivamente Magia compartida, Conjuro combinado o Espada y magia, una sola vez. Dos victorias contra monstruos abren cacerías del guardián de las ruinas: hasta 60 oro y dos materiales en lugar de 40 oro y uno. Perder no cuenta como victoria.

La segunda y tercera visita reconocen el regreso. La tercera añade una conversación original de la esposa sobre las responsabilidades familiares. Oro y copias se multiplican por 1, 0,9 y 0,8 según la visita, redondeando hacia abajo con mínimo 1. Las relaciones muestran siempre el valor aplicado.

## Relaciones y separaciones

Partidas nuevas: **50 amor/50 confianza**, matrimonio activo. Intervalo configurable **−100 a 100**. Si ambas cifras son al menos 75, una ganancia ordinaria de 2 o más recibe +1; si alguna es negativa, las ganancias ordinarias se reducen a la mitad, redondeando hacia abajo con mínimo 1. Los componentes originalmente cero siguen siendo cero. Las penalizaciones no se multiplican ni recuperan margen diario.

El límite de **+10 amor y +10 confianza por esposa y jornada** suma cartas, actividades, combate e historia ordinaria. La reconciliación también respeta ese límite. Una visita concede hasta +1 confianza al cierre. Cero visitas aplica **−20 amor y −20 confianza** una sola vez; la historia obligatoria no cuenta como visita.

El abandono puede separar cuando amor o confianza llega a −30, hubo al menos dos días sin visita y una advertencia de una jornada anterior. La cifra negativa aislada no separa. Las decisiones narrativas críticas conservan su capacidad de ruptura. El cierre muestra advertencias y pérdidas en el resumen.

La separación se registra antes de su presentación. La escena tiene confrontación propia, expresión, anillo animado, salida hacia el bosque y partida a caballo; Sylphiette parte con su hija. Usa fondos y retratos originales y figuras pixeladas dibujadas con primitivas. La cola conserva fase y tiempo para continuar al cargar. El diario y registro de personajes aplican un shader gris real. Quedan bloqueadas actividades matrimoniales, nuevas cartas exclusivas, apoyos y selección como compañera. Las escenas personales pendientes se omiten y existe la opción de viajar solo. Curar la maldición no restablece matrimonios.

## Encargos y libros

| Tarea | Encargado | Premio |
| --- | --- | --- |
| `cliff_notes` | Cliff | 45 oro, 2 Escuchar y 1 Curación |
| `zanoba_artifact` | Zanoba | 40 oro, 2 Bastón y 1 Defensa |
| `magic_materials` | Cualquiera | 15 oro y 2 materiales |
| `gold_search` | Cualquiera | 65 oro |
| `enchantment_study` | Cliff | 1 receta y 1 Analizar runas |
| `craft_materials` | Zanoba | 20 oro, 1 material y 1 libro de estudio |

Se solicita un encargo total al día y se entrega al comenzar el siguiente. No puede repetirse el ID de ayer, aunque cambie el encargado. Ayudar entrega el mismo día y consume una interacción sin sumar visita. El día 7 solo se acepta solicitar y ayudar con un espacio disponible. Las entregas usan eventos únicos, independientes de las animaciones.

La librería ofrece Fundamentos del flujo de agua (35 oro), Recetas de encantamiento (50) y Formas avanzadas de tierra (70). Cada título se compra una vez y desbloquea cartas, conocimiento o recetas. El libro consumible de estudio de la tienda anterior sigue disponible. Comprar durante una visita a la librería completa la actividad sin gastar un segundo espacio; comprar desde la tienda no cuenta como visita.

## Archivos y persistencia

| Archivo | Responsabilidad |
| --- | --- |
| `src/data/family.lua` | Afinidad, límites, repetición, advertencias, despedidas y propietarios de cartas exclusivas. |
| `src/data/family_activities.lua` | Catálogo de actividades, decisiones y premios. |
| `src/data/activities.lua` | Registro por ID y catálogo de encargos/proveedores. |
| `src/data/books.lua` | Precios y efectos de libros. |
| `src/data/family_routes.lua` | Continuación de escenas cuando una esposa ya se separó. |
| `src/systems/family.lua` | Progreso, promesas, escenas, hitos y separación irreversible. |
| `src/systems/daily.lua` | Reservas, combate de actividad, visitas, encargos y cierre idempotente. |
| `src/screens/agenda.lua`, `books.lua`, `family_scene.lua` | Menú diario, librería, advertencias y presentación familiar. |

`family` guarda progreso, advertencias, ausencias, separaciones, libros, recetas, plazo del recado y escenas vistas/pendientes. `daily` conserva reservas, visitas, actividades, ayuda al encargado y ganancias; `pending_favors` conserva ID, proveedor, fechas y entrega. Los registros por evento impiden duplicar recompensas o consecuencias.

El formato **v6** utiliza `campaign-v6.json` y respaldo propio. Carga v5 conservando valores y progreso históricos; v4 pasa primero por la migración de economía. Los archivos anteriores permanecen intactos y las nuevas partidas empiezan en 50/50. Los encuentros sociales históricos mantienen sus efectos durante el replay; las nuevas acciones usan las reglas actuales.

## Pruebas

Con LÖVE 11.5 instalado:

```powershell
$env:DATESIM_TEST_GROUP = 'family-ui'
& 'C:\Program Files\LOVE\lovec.exe' . --test
Remove-Item Env:DATESIM_TEST_GROUP
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

`tests/family.lua` cubre actividades, efectos reales, duelos, cupos, penalizaciones, recuperación, separaciones, encargos, libros y migración. `tests/family_ui.lua` ejercita confirmación/cancelación, diálogos, anillo guardado, caballo, librería y píxeles grises. La campaña se prueba además con todos los finales y distribuciones diarias; véase [VERIFICACION.md](VERIFICACION.md).
