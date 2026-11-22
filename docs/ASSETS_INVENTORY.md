# Inventario de assets de exploración

Revisión: 22 de noviembre de 2026. Inventario real previo a mover archivos: **109 archivos**: 53 PNG, 53 ASE, un TXT, un CSV y un JSON. No faltan archivos, no hay extras ni coincidencias de nombre con recursos anteriores. Se conservan los nombres originales y las mayúsculas de las hojas `*_walk`.

## Integridad y recuperación

[assets_migration.json](assets_migration.json) conserva la evidencia previa: origen, destino, tamaño, SHA-256, dimensiones PNG, cabeceras, fotogramas, duraciones, chunks ASE, nombres de capas legibles y advertencias. Incluye los hashes de **157 archivos anteriores** y las rutas/IDs del manifiesto original. No regenerar esta evidencia sobre los archivos migrados.

Se siguió la secuencia inventario → hashes → duplicados → respaldo → copia → verificación → referencias → pruebas. Los 106 binarios y los tres metadatos conservan exactamente sus bytes. Ningún PNG o ASE fue convertido, recodificado o reparado.

Respaldo local: `.asset_backups/exploration-originals.zip`, ignorado por Git. Contiene los 109 originales con su ruta previa; cada entrada se compara con su hash de origen. Para recuperar, extraer **en una carpeta aparte**, comprobar hashes y copiar sólo el recurso requerido, sin sobrescribir contenido diferente. La carpeta temporal se retira sólo tras verificar toda la migración y las pruebas. Conservar el ZIP al limpiar el repositorio.

Cierre de la migración: `assets/New` ya no existe. La revisión automática bloqueó su eliminación recursiva; se trasladó íntegra a `.asset_backups/original-delivery/` como respaldo adicional, después de validar los 109 originales. No se borró ningún archivo. Ambos respaldos quedan fuera de los recursos de ejecución y se ignoran en Git. En las carpetas definitivas hay **130 PNG y 127 ASE**, contando recursos anteriores; no hay ASE bajo `assets/` ni PNG bajo `sprite_sources/`.

```powershell
python tools/migrate_exploration_assets.py verify
```

`inventory` registra el estado una sola vez; `copy` crea el respaldo y las copias sin sobrescribir archivos distintos; ninguna de estas acciones elimina los originales. Sólo `inventory` necesita Pillow. `verify` usa la biblioteca estándar de Python. El juego y las pruebas LÖVE no requieren Python.

## Incidencia original en los ASE

Los **53 ASE** tienen firma general `0xA5E0`, tamaño declarado correcto, dimensiones esperadas y cabeceras de fotograma `0xF1FA`. Se verificaron los límites de frames y chunks. Los PNG son legibles. Un ASE animado contiene el tamaño de **un fotograma**, mientras su PNG contiene toda la hoja; esto es correcto.

Los **14 ASE de mapas y cuatro ASE de tilesets** traen registros de capa incompatibles con el encabezado estándar de 16 bytes de datos de capa. Ejemplo: el primer chunk de capa de `biblioteca_ranoa_map.ase` empieza en el byte 144, mide 37 bytes y la longitud del nombre en el offset estándar excede ese chunk. Se contrastó con la [especificación ASE](https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md) y el [lector oficial de LibreSprite](https://github.com/LibreSprite/LibreSprite/blob/master/src/app/file/ase_format.cpp).

Hay **120 registros de capa afectados**: cuatro por mapa y dieciséis por tileset. Se preservan esos bytes originales. No se certifica la apertura correcta de estos 18 proyectos en LibreSprite: queda pendiente su revisión en el editor. No se reparan en esta migración porque cambiaría sus binarios. Los otros 35 ASE no presentan esta advertencia estructural. Las pruebas de integridad pasan con la incidencia documentada; no certifican la editabilidad de los 53 proyectos.

## Estructura final

```text
assets/
  characters/portraits/       5 PNG nuevos
  characters/overworld/       7 PNG
  characters/npc_idle/        5 PNG
  maps/greyrat_house/         8 PNG
  maps/sharia/               2 PNG
  maps/ranoa/                4 PNG
  tilesets/                  4 PNG + LEEME.txt
  objects/items/            16 PNG
  objects/atlases/            1 PNG + CSV + JSON
  animations/horse/          1 PNG
  backgrounds/               fondos narrativos anteriores (320 × 180)
  cards/                     cartas, marcos e iconos anteriores
  ui/                        preparado; interfaz existente dibujada por el motor
  audio/                     preparado; audio existente sintetizado
sprite_sources/
  characters/{portraits,overworld,npc_idle}/
  maps/{greyrat_house,sharia,ranoa}/
  tilesets/
  objects/{items,atlases}/
  animations/horse/
  backgrounds/ y cards/      fuentes anteriores conservadas
```

Los retratos principales anteriores siguen directamente en `assets/characters/`. Las carpetas y módulos ajenos a esta migración permanecen en su lugar.

## Catálogo completo

Las dimensiones ASE son por fotograma; `f` indica fotogramas nativos. Todas las rutas son relativas a la raíz.

| Recurso | Ruta PNG | Ruta ASE | Categoría | PNG | ASE / frames | Uso previsto |
| --- | --- | --- | --- | --- | --- | --- |
| `01_moneda_oro` | `assets/objects/items/01_moneda_oro.png` | `sprite_sources/objects/items/01_moneda_oro.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `02_bolsa_oro` | `assets/objects/items/02_bolsa_oro.png` | `sprite_sources/objects/items/02_bolsa_oro.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `03_libro_magia` | `assets/objects/items/03_libro_magia.png` | `sprite_sources/objects/items/03_libro_magia.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `04_pergamino` | `assets/objects/items/04_pergamino.png` | `sprite_sources/objects/items/04_pergamino.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `05_carta_encantada` | `assets/objects/items/05_carta_encantada.png` | `sprite_sources/objects/items/05_carta_encantada.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `06_cofre_cerrado` | `assets/objects/items/06_cofre_cerrado.png` | `sprite_sources/objects/items/06_cofre_cerrado.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `07_cofre_abierto` | `assets/objects/items/07_cofre_abierto.png` | `sprite_sources/objects/items/07_cofre_abierto.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `08_fragmento_mana` | `assets/objects/items/08_fragmento_mana.png` | `sprite_sources/objects/items/08_fragmento_mana.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `09_material_magico` | `assets/objects/items/09_material_magico.png` | `sprite_sources/objects/items/09_material_magico.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `10_frasco_pocion` | `assets/objects/items/10_frasco_pocion.png` | `sprite_sources/objects/items/10_frasco_pocion.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `11_antidoto` | `assets/objects/items/11_antidoto.png` | `sprite_sources/objects/items/11_antidoto.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `12_escoba` | `assets/objects/items/12_escoba.png` | `sprite_sources/objects/items/12_escoba.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `13_flor` | `assets/objects/items/13_flor.png` | `sprite_sources/objects/items/13_flor.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `14_anillo_matrimonio` | `assets/objects/items/14_anillo_matrimonio.png` | `sprite_sources/objects/items/14_anillo_matrimonio.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `15_nota_misteriosa` | `assets/objects/items/15_nota_misteriosa.png` | `sprite_sources/objects/items/15_nota_misteriosa.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `16_indicador_interaccion` | `assets/objects/items/16_indicador_interaccion.png` | `sprite_sources/objects/items/16_indicador_interaccion.ase` | `objects/items` | 16 × 16 | 16 × 16 / 1 f | Objeto individual opcional |
| `aisha` | `assets/characters/portraits/aisha.png` | `sprite_sources/characters/portraits/aisha.ase` | `characters/portraits` | 256 × 64 | 64 × 64 / 4 f | Cuatro expresiones familiares |
| `aisha_idle` | `assets/characters/npc_idle/aisha_idle.png` | `sprite_sources/characters/npc_idle/aisha_idle.ase` | `characters/npc_idle` | 48 × 32 | 24 × 32 / 2 f | Reposo NPC; dos fotogramas |
| `biblioteca_ranoa_map` | `assets/maps/ranoa/biblioteca_ranoa_map.png` | `sprite_sources/maps/ranoa/biblioteca_ranoa_map.ase` | `maps/ranoa` | 512 × 320 | 512 × 320 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `caballo_salida` | `assets/animations/horse/caballo_salida.png` | `sprite_sources/animations/horse/caballo_salida.ase` | `animations/horse` | 192 × 32 | 48 × 32 / 4 f | Cinemática de separación matrimonial |
| `camino_sharia_map` | `assets/maps/sharia/camino_sharia_map.png` | `sprite_sources/maps/sharia/camino_sharia_map.ase` | `maps/sharia` | 768 × 320 | 768 × 320 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `casa_planta_baja_map` | `assets/maps/greyrat_house/casa_planta_baja_map.png` | `sprite_sources/maps/greyrat_house/casa_planta_baja_map.ase` | `maps/greyrat_house` | 640 × 384 | 640 × 384 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `casa_segundo_piso_map` | `assets/maps/greyrat_house/casa_segundo_piso_map.png` | `sprite_sources/maps/greyrat_house/casa_segundo_piso_map.ase` | `maps/greyrat_house` | 512 × 320 | 512 × 320 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `cementerio_ranoa_map` | `assets/maps/sharia/cementerio_ranoa_map.png` | `sprite_sources/maps/sharia/cementerio_ranoa_map.ase` | `maps/sharia` | 512 × 320 | 512 × 320 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `Cliff_walk` | `assets/characters/overworld/Cliff_walk.png` | `sprite_sources/characters/overworld/Cliff_walk.ase` | `characters/overworld` | 96 × 128 | 24 × 32 / 16 f | Caminar: abajo, izquierda, derecha, arriba |
| `dormitorio_eris_map` | `assets/maps/greyrat_house/dormitorio_eris_map.png` | `sprite_sources/maps/greyrat_house/dormitorio_eris_map.ase` | `maps/greyrat_house` | 320 × 192 | 320 × 192 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `dormitorio_roxy_map` | `assets/maps/greyrat_house/dormitorio_roxy_map.png` | `sprite_sources/maps/greyrat_house/dormitorio_roxy_map.ase` | `maps/greyrat_house` | 320 × 192 | 320 × 192 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `dormitorio_sylphie_map` | `assets/maps/greyrat_house/dormitorio_sylphie_map.png` | `sprite_sources/maps/greyrat_house/dormitorio_sylphie_map.ase` | `maps/greyrat_house` | 320 × 192 | 320 × 192 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `Eris_walk` | `assets/characters/overworld/Eris_walk.png` | `sprite_sources/characters/overworld/Eris_walk.ase` | `characters/overworld` | 96 × 128 | 24 × 32 / 16 f | Caminar: abajo, izquierda, derecha, arriba |
| `estudio_rudy_map` | `assets/maps/greyrat_house/estudio_rudy_map.png` | `sprite_sources/maps/greyrat_house/estudio_rudy_map.ase` | `maps/greyrat_house` | 320 × 192 | 320 × 192 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `jardin_casa_map` | `assets/maps/greyrat_house/jardin_casa_map.png` | `sprite_sources/maps/greyrat_house/jardin_casa_map.ase` | `maps/greyrat_house` | 512 × 320 | 512 × 320 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `laboratorio_nanahoshi_map` | `assets/maps/ranoa/laboratorio_nanahoshi_map.png` | `sprite_sources/maps/ranoa/laboratorio_nanahoshi_map.ase` | `maps/ranoa` | 512 × 320 | 512 × 320 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `lilia` | `assets/characters/portraits/lilia.png` | `sprite_sources/characters/portraits/lilia.ase` | `characters/portraits` | 256 × 64 | 64 × 64 / 4 f | Cuatro expresiones familiares |
| `lilia_idle` | `assets/characters/npc_idle/lilia_idle.png` | `sprite_sources/characters/npc_idle/lilia_idle.ase` | `characters/npc_idle` | 48 × 32 | 24 × 32 / 2 f | Reposo NPC; dos fotogramas |
| `lucy` | `assets/characters/portraits/lucy.png` | `sprite_sources/characters/portraits/lucy.ase` | `characters/portraits` | 256 × 64 | 64 × 64 / 4 f | Cuatro expresiones familiares |
| `lucy_idle` | `assets/characters/npc_idle/lucy_idle.png` | `sprite_sources/characters/npc_idle/lucy_idle.ase` | `characters/npc_idle` | 32 × 16 | 16 × 16 / 2 f | Reposo NPC; dos fotogramas |
| `Nanahoshi_walk` | `assets/characters/overworld/Nanahoshi_walk.png` | `sprite_sources/characters/overworld/Nanahoshi_walk.ase` | `characters/overworld` | 96 × 128 | 24 × 32 / 16 f | Caminar: abajo, izquierda, derecha, arriba |
| `norn` | `assets/characters/portraits/norn.png` | `sprite_sources/characters/portraits/norn.ase` | `characters/portraits` | 256 × 64 | 64 × 64 / 4 f | Cuatro expresiones familiares |
| `norn_idle` | `assets/characters/npc_idle/norn_idle.png` | `sprite_sources/characters/npc_idle/norn_idle.ase` | `characters/npc_idle` | 48 × 32 | 24 × 32 / 2 f | Reposo NPC; dos fotogramas |
| `objetos_atlas_64x64` | `assets/objects/atlases/objetos_atlas_64x64.png` | `sprite_sources/objects/atlases/objetos_atlas_64x64.ase` | `objects/atlases` | 64 × 64 | 64 × 64 / 1 f | Atlas compartido de objetos |
| `patio_eris_map` | `assets/maps/greyrat_house/patio_eris_map.png` | `sprite_sources/maps/greyrat_house/patio_eris_map.ase` | `maps/greyrat_house` | 640 × 384 | 640 × 384 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `Roxy_walk` | `assets/characters/overworld/Roxy_walk.png` | `sprite_sources/characters/overworld/Roxy_walk.ase` | `characters/overworld` | 96 × 128 | 24 × 32 / 16 f | Caminar: abajo, izquierda, derecha, arriba |
| `Rudeus_walk` | `assets/characters/overworld/Rudeus_walk.png` | `sprite_sources/characters/overworld/Rudeus_walk.ase` | `characters/overworld` | 96 × 128 | 24 × 32 / 16 f | Caminar: abajo, izquierda, derecha, arriba |
| `Sylphie_walk` | `assets/characters/overworld/Sylphie_walk.png` | `sprite_sources/characters/overworld/Sylphie_walk.ase` | `characters/overworld` | 96 × 128 | 24 × 32 / 16 f | Caminar: abajo, izquierda, derecha, arriba |
| `taller_cliff_zanoba_map` | `assets/maps/ranoa/taller_cliff_zanoba_map.png` | `sprite_sources/maps/ranoa/taller_cliff_zanoba_map.ase` | `maps/ranoa` | 512 × 320 | 512 × 320 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `tileset_cementerio` | `assets/tilesets/tileset_cementerio.png` | `sprite_sources/tilesets/tileset_cementerio.ase` | `tilesets` | 256 × 256 | 256 × 256 / 1 f | Autoría de mapas; tiles 16 × 16 |
| `tileset_exterior` | `assets/tilesets/tileset_exterior.png` | `sprite_sources/tilesets/tileset_exterior.ase` | `tilesets` | 256 × 256 | 256 × 256 / 1 f | Autoría de mapas; tiles 16 × 16 |
| `tileset_hogar` | `assets/tilesets/tileset_hogar.png` | `sprite_sources/tilesets/tileset_hogar.ase` | `tilesets` | 256 × 256 | 256 × 256 / 1 f | Autoría de mapas; tiles 16 × 16 |
| `tileset_universidad` | `assets/tilesets/tileset_universidad.png` | `sprite_sources/tilesets/tileset_universidad.ase` | `tilesets` | 256 × 256 | 256 × 256 / 1 f | Autoría de mapas; tiles 16 × 16 |
| `universidad_exterior_map` | `assets/maps/ranoa/universidad_exterior_map.png` | `sprite_sources/maps/ranoa/universidad_exterior_map.ase` | `maps/ranoa` | 640 × 384 | 640 × 384 / 1 f | Mapa explorable; accesos y colisiones en Lua |
| `Zanoba_walk` | `assets/characters/overworld/Zanoba_walk.png` | `sprite_sources/characters/overworld/Zanoba_walk.ase` | `characters/overworld` | 96 × 128 | 24 × 32 / 16 f | Caminar: abajo, izquierda, derecha, arriba |
| `zenith` | `assets/characters/portraits/zenith.png` | `sprite_sources/characters/portraits/zenith.ase` | `characters/portraits` | 256 × 64 | 64 × 64 / 4 f | Cuatro expresiones familiares |
| `zenith_lucy_idle` | `assets/characters/npc_idle/zenith_lucy_idle.png` | `sprite_sources/characters/npc_idle/zenith_lucy_idle.ase` | `characters/npc_idle` | 64 × 32 | 32 × 32 / 2 f | Reposo NPC; dos fotogramas |

## Metadatos preservados

| Archivo original | Destino | Uso |
| --- | --- | --- |
| `LEEME.txt` | `assets/tilesets/LEEME.txt` | Reglas originales de tilesets |
| `objetos_atlas.csv` | `assets/objects/atlases/objetos_atlas.csv` | Coordenadas de los dieciséis objetos |
| `objetos_atlas.json` | `assets/objects/atlases/objetos_atlas.json` | Tamaños y rectángulos del atlas |

## Tilesets y máscaras

Cada hoja mide 256 × 256; cada celda, 16 × 16. Las filas **1–4** contienen familias conectables: columnas **1–16** para máscaras **0–15**. Bits: norte=1, este=2, sur=4, oeste=8. Sumar los lados conectados: norte+sur=5 selecciona la columna 6; los cuatro lados=15 seleccionan la columna 16. Coordenadas desde cero: `x = mascara * 16`, `y = (fila - 1) * 16`.

| Tileset | Fila 1 | Fila 2 | Fila 3 | Fila 4 |
| --- | --- | --- | --- | --- |
| Hogar | Alfombra | Pared crema | Madera | Piedra |
| Exterior | Tierra | Piedra | Entrenamiento | Césped claro |
| Universidad | Piedra clara | Pared crema | Alfombra | Madera |
| Cementerio | Tierra | Piedra | Tierra alternativa | Césped claro |

Fila 5, columnas 1–4: superficies completas. Filas restantes: objetos de una celda, algunas variantes repetidas. El LEEME declara 24 colores y 16 capas por hoja; la incidencia anterior impide certificar esas capas en el editor. Los fondos de objetos de los tilesets son opacos y no se modificaron. Usar filtro `nearest`, sin mipmaps. **Ninguna máscara genera colisión automáticamente.**

## Registro y carga

`src/data/assets.lua` conserva sus grupos y añade `exploration`, definido en `src/data/exploration_assets.lua`: `portraits`, `overworld`, `npcIdle`, `maps`, `tilesets`, `items`, `atlases`, `animations`. Cada entrada tiene `image`, `width` y `height`; las hojas animadas incluyen tamaño de fotograma, columnas, filas, número de frames y duraciones originales. `Sylphie_walk.png` usa el ID narrativo estable `sylphiette`.

`Resources:getExploration(grupo,id)` usa la caché por ruta; devuelve `nil, motivo` si falla. Los 53 PNG no se precargan con el dating sim. `Resources:getObjectSprite(id)` devuelve imagen y quad del atlas; dieciséis objetos comparten una imagen. El modo explícito `individual` carga sólo la imagen individual. LÖVE nunca carga los ASE.

Los retratos familiares se consultan con `getExploration("portraits", id)` y están separados de los retratos anteriores. Las listas de NPC disponibles no activan eventos ni cambian la historia. Los fondos de conversación de 320 × 180 son recursos distintos de los mapas explorables.

## Validación reproducible

`tests/exploration_assets.lua` verifica nombres exactos, hashes originales/nuevos, cabeceras ASE, carga CPU/GPU real, dimensiones, frames/duraciones, máscaras, equivalencia píxel a píxel atlas/objetos, caché, manifiesto, rutas antiguas y ausencia de referencias temporales en `src/`, `main.lua` y `conf.lua`. Valida además retornos, destinos, posiciones y errores deliberados. Las rutas de origen del inventario y de la herramienta son evidencia histórica, no dependencias de ejecución.

`tests/exploration_visual.lua` produce 14 capturas con suelo revisado, Rudy y portales, sin cambiar recursos. Consulta los resultados ejecutados en [VERIFICACION.md](VERIFICACION.md) y el grafo con coordenadas en [MAPAS_CONEXIONES.md](MAPAS_CONEXIONES.md).
