# Fase 4: combate, afinidad y Badigadi

Implementado sobre la campaña existente para LÖVE 11.5 / LuaJIT. Se conservan los 40 IDs de cartas, los mazos, PNG y ASE. Estas reglas corresponden a combates nuevos; las batallas históricas conservan sus reglas al cargar.

## Acciones y recursos

Rudy comienza con 30 PV, tres acciones por turno y magia natural bloqueada. Cada compañera presente tiene **una acción propia por turno**, que puede intercalarse con las de Rudy. Terminar turno ejecuta la intención enemiga, elimina los escudos restantes y renueva las acciones. Los apoyos no se ejecutan automáticamente ni duplican acciones de Rudy.

El artefacto recupera cuatro de energía externa por turno hasta su capacidad adquirida (máximo 30). Los apoyos con coste mágico comparten ese recurso; después del antídoto utilizan maná natural. Los ataques normales de compañeras no consumen el recurso de Rudy. Defensa básica y esquiva cuestan una acción cada una: conceden cinco y tres de escudo físico respectivamente, una vez por turno. Eris concede protección física; Sylphiette y Roxy, mágica. Todo escudo de Rudy caduca al volver su turno.

Las cartas consultan `card_collection`: en nivel 1, bastón causa 2, espada 3 con esfuerzo de 1 PV, piedra 1, empuje 1 y coordinación 2. El esfuerzo nunca paga el último PV. Se mantienen diferencias de elemento, daño y coste entre bastón, espada, ataques físicos, agua, tierra y magia combinada. Cañón de Agua superior (`water_cannon`) llega a 250 de daño base en nivel 10; bastón a 20 y Cañón de Agua (`heavy_spell`) a 125. Desde nivel 7 la definitiva exige 12 de energía, 6 PV y un uso por batalla; las avanzadas tienen dos usos y mayor coste mágico. Curación básica mejora de 5 a 10 PV y mantiene tres usos. [Fórmulas de cartas](FASE_2_PROGRESION.md).

## Enemigos por día

`src/data/battle_balance.lua` concentra magnitudes y habilidades; `enemies.resolve(id, context)` produce una copia independiente para cada batalla.

| Día | PV base | Ataque | Escudo | Patrón añadido |
| --- | ---: | ---: | ---: | --- |
| 1 | 10 | 2 | 0 | Ataque y pausa; tutorial corto |
| 2 | 20 | 3 | 2 | Defensa, máximo tres usos |
| 3 | 36 | 4 | 3 | Preparación y golpe de daño normal +3 |
| 4 | 55 | 5 | 5 | Debilita a Rudy un turno |
| 5 | 180 | 6 | 7 | Interrumpe una acción; dos golpes de 3 |
| 6 | 260 | 7 | 9 | Lacayo de Hitogami y prueba opcional de Orsted |
| 7 | 300 | 8 | 10 | Actividades ordinarias; el jefe tiene configuración propia |

Guardián de las ruinas multiplica PV por 1,15; reflejo de Rudy por 1,10; reflejo distorsionado por 1,05, redondeando al entero más cercano. Los entrenamientos conservan reglas específicas. El salto de los días 5–6 acompaña el acceso a técnicas mejoradas y apoyos: se verifica con acciones legales, defensa, mejoras pagadas y recorridos de campaña. Hay además 36 simulaciones intermedias: seis semillas por día, sin compañeras, niveles 1, 1, 2, 3, 4 y 5.

El Día 6 abre el camino tras el reflejo y el lacayo. Investigar las runas (`observatory_research="tested"`) habilita una prueba no letal de Orsted. Aceptarla es opcional y perder permite continuar; no concede antídoto. El Día 7 permite elegir una compañera, todas las disponibles o viajar solo. Una separación definitiva excluye apoyos y cartas exclusivas de esa esposa.

## Afinidad y habilidades

El contexto toma amor, confianza y matrimonio persistentes al comenzar. Las relaciones no cambian a mitad de batalla; cargar reproduce el mismo contexto.

```lua
local affinity = (love + trust) / 2
local multiplier = math.max(0, math.min(100, affinity)) / 100
local damage = math.floor(baseDamage * multiplier + 0.5)
```

Después se aplican resistencia, vulnerabilidad y escudo. La interfaz distingue **daño base** de **PV que perderá ahora**, y la preparación compara el especial con el último combate completado. Afinidad negativa produce cero daño.

| Habilidad | Potencia máxima / efecto | Energía | Recarga | Usos por batalla |
| --- | --- | ---: | ---: | ---: |
| Sylphiette: Proyectil | 12 | 0 | 1 | Sin límite adicional |
| Luz coordinada | 90; atraviesa resistencia reforzada | 4 | 3 | 3 |
| Curar a Rudy | Tabla inferior | 2 | 2 | 3 |
| Barrera familiar | 8 escudo | 2 | 1 | Sin límite adicional |
| Eris: Corte normal | 24 | 0 | 1 | Sin límite adicional |
| Ataque fuerte | 65 | 0 | 2 | 5 |
| Interrumpir | 12; debilita un turno | 0 | 2 | Sin límite adicional |
| Proteger a Rudy | 5 escudo | 0 | 1 | Sin límite adicional |
| Espada coordinada | 150; atraviesa resistencia reforzada | 4 | 3 | 3 |
| Roxy: Proyectil mágico | 18 | 0 | 1 | Sin límite adicional |
| Analizar debilidad | Debilita y anula resistencia 2 turnos | 0 | 2 | Sin límite adicional |
| Disolver defensa | 10; quita hasta 12 escudo; expone 3 turnos | 2 | 2 | Sin límite adicional |
| Coordinar magia | 40; debilita un turno | 2 | 2 | Sin límite adicional |
| Conjuro combinado | 110; atraviesa resistencia reforzada | 5 | 3 | 3 |
| Muro de apoyo | 7 escudo | 2 | 1 | Sin límite adicional |

Las potencias escalan por afinidad; escudos y estados conservan su magnitud. Debilitar reduce dos puntos por golpe enemigo. Una recarga de tres permite repetir en turno 4 lo usado en turno 1; las cargas agotadas no se regeneran. Cada esposa puede registrar una consecuencia de coordinación (+1 amor/+2 confianza) al vencer, sujeta a modulación familiar y al límite diario de +10 por estadística.

| Afinidad media de Sylphiette | Efecto sobre PV máximos |
| --- | --- |
| 90 o más | Cura 40% |
| 80 a menos de 90 | Cura 30% |
| 50 a menos de 80 | Cura 20% |
| 25 a menos de 50 | Cura 10% |
| Menos de 25 | Interferencia: daño del 40% |

Con 30 PV máximos: +12, +9, +6, +3 o −12. Se cura como máximo la vida faltante; estar ileso no consume carga. La interferencia daña directamente los PV, puede derrotar y exige confirmación visible. Cancelar no gasta acción, carga ni energía. Se atribuye el problema a la sincronización de la maldición, no a la capacidad profesional de Sylphiette.

## Badigadi: 1000 PV, cuatro fases

1. **Resistencia, 1000–751 PV:** golpe de 4 y preparación alternados.
2. **Seis brazos, 750–351 PV:** tres golpes de 2 y preparación alternados; el escudo se consume entre impactos.
3. **Resistencia mejorada, 350–1 PV:** tres golpes de 3 y preparación; reduce en 6 cada ataque mientras Roxy no lo exponga. Los especiales combinados de compañeras atraviesan esa resistencia. El agua obtiene +8 antes de resistencia; la vulnerabilidad ordinaria añade +2.
4. **Protección del antídoto, 0 PV:** sello con 12 de resistencia. Dos acciones explícitas de `Romper sello [B]` eliminan 6 cada una. El sello puede emitir pulsos de 3. Solo romperlo concede victoria narrativa.

Badigadi sigue vivo. `day7_boss → day7_victory` entrega una vez el antídoto; beberlo en la escena posterior libera voz y magia. La cura no reactiva matrimonios separados. Se mantienen los 1000 PV con cualquier equipo. Límite de turnos: 75 para el jefe, 30 para ordinarios y 18 para entrenamiento de Eris. Agotar el plazo causa derrota, no bloqueo.

## Simulaciones reproducibles

`tests/war_balance.lua` ejecuta 576 batallas: niveles 1/5/10 × ocho equipos × afinidades 20/50/90 × ocho semillas. Usa diez cartas a nivel homogéneo, capacidad externa 30 y magia natural bloqueada para aislar variables. **No representa una colección que deba maximizarse en campaña.** Los recorridos completos compran mejoras con oro y copias reales por separado.

La estrategia observa intenciones, defiende, cura cuando conviene, explota agua, análisis e interrupción y respeta costes, usos y recargas. [Resultados completos en CSV](BALANCE_FASE_4.csv). Máscaras: bit 1 Sylphiette, bit 2 Roxy, bit 4 Eris. Las medias incluyen derrotas. `mean_shield` cuenta escudo generado, no necesariamente absorbido; `mean_healing`, curación efectiva; daño por turno mide PV quitados al jefe, sin la resistencia del sello.

| Nivel | Equipo / afinidad | Victorias | Turnos medios | PV restantes | Daño/turno | Curación | Escudo |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | Solo | 6/8 | 71,63 | 19,38 | 13,98 | 4,00 | 200,00 |
| 1 | Tres / 90 | 8/8 | 7,00 | 29,63 | 142,86 | 0,25 | 20,88 |
| 5 | Solo | 8/8 | 22,25 | 23,75 | 45,07 | 9,75 | 44,00 |
| 5 | Tres / 20 | 8/8 | 18,13 | 28,63 | 55,37 | 2,63 | 43,00 |
| 5 | Tres / 50 | 8/8 | 9,75 | 29,63 | 102,78 | 2,75 | 23,88 |
| 5 | Tres / 90 | 8/8 | 5,25 | 30,00 | 191,67 | 0,88 | 19,38 |
| 10 | Solo | 8/8 | 8,88 | 26,00 | 115,08 | 9,88 | 21,00 |
| 10 | Tres / 90 | 8/8 | 4,25 | 28,75 | 237,50 | 9,25 | 8,75 |

Todas las combinaciones de nivel 5/10 ganan sus ocho semillas. Nivel 1 solo pierde dos por plazo: mejorar algunas cartas importa. Más apoyo ofrece opciones, pero un especial con afinidad baja puede rendir menos que reservar energía para una carta fuerte; se puede omitir ese apoyo. Son frecuencias de esta estrategia y estas semillas, no una probabilidad universal de victoria humana. Pasar turnos sin actuar pierde incluso con nivel 10 y tres esposas a afinidad 100.

## Arquitectura, guardado y pruebas

`companions.lua` calcula afinidad y equipo; `support_actions.lua` resuelve habilidades; `combat.lua`, turnos y comandos; `support_panel.lua`, preparación y confirmación. `war_chapters.lua` enlaza los encuentros antes de instalar la agenda. Nuevas habilidades y magnitudes se declaran en datos.

Guardado **v7**, con archivo y respaldo propios: migra v6/v5/v4 sin modificarlos. Combates nuevos guardan `context.warVersion=1`, `balanceVersion=3`, relaciones iniciales, equipo, cargas, recargas y acciones. Restaurar reproduce los comandos, incluidos apoyos y confirmación de riesgo, y compara el resultado; no repone cargas ni concede premios. `combat_legacy.lua` y `enemies_legacy.lua` preservan las batallas anteriores. Si una partida obtuvo el antídoto en el antiguo Día 6, continúa su desenlace sin exigir otro jefe.

Las suites `war`, `war_balance` y `war_ui` cubren fórmulas, umbrales 24.99/25/49/50/79/80/89/90/100, valores negativos, recargas, pulsaciones repetidas, separación, fases, carga, barras y riesgo. `campaign` recorre siete días con compras legales; `restructure_integration` usa las pantallas reales. [Verificación ejecutada](VERIFICACION.md).

```powershell
$env:DATESIM_TEST_GROUP='war-ui'
& 'C:\Program Files\LOVE\lovec.exe' . --test
# Suite completa: quitar DATESIM_TEST_GROUP y DATESIM_TEST_MODULE.
```
