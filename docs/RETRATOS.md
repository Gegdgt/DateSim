# Identidad y apariencia contextual

`rudeus` sigue siendo la única identidad lógica del protagonista. El manifiesto registra dos recursos independientes: `assets/characters/rudeus.png` y `assets/characters/rudeus_japones.png`. El segundo ya estaba en el repositorio, junto con `sprite_sources/characters/rudeus_japones.ase`; no se redibujó ni reexportó ninguno.

La hoja japonesa es PNG RGBA de **256 × 64**, con cuatro celdas horizontales de **64 × 64**: `neutral=0`, `happy=1`, `worried=2`, `angry=3`. El ASE conserva cuatro cuadros de 64 × 64 y profundidad de 32 bits. Cada recurso tiene caché propia; los Quad recortan cada celda y se dibujan con `nearest`, posiciones enteras y escala uniforme 2× en diálogo. Si falta el PNG, es ilegible o tiene dimensiones incorrectas, el cargador muestra un retrato provisional de pelo oscuro y registra una advertencia con ruta y causa. Nunca reemplaza el archivo del usuario.

## Cómo escribir otra escena

`src/data/appearances.lua` define el contexto `hitogami_dream`: asigna `rudeus_japones` a la identidad `rudeus` y propone el fondo `dream`. Una escena lo activa explícitamente; mencionar a Hitogami, recordar sus palabras o dibujar su retrato no activa ese contexto.

```lua
{
    context="hitogami_dream",
    background="dream", music="dream",
    entranceTransition={type="dream",duration=.6},
    transition={type="dream",duration=.6},
    cast={
        {character="hitogami",position="right",expression="happy",enterAt=1},
        {character="rudeus",position="left",expression="neutral",enterAt=1,entranceDelay=.28},
    },
    lines={
        {speaker="hitogami",expression="happy",text="Escucha mi consejo."},
        {speaker="rudeus",delivery="dream",expression="worried",
         animation="small_shake",text="¿Qué intentas decirme?"},
        {speaker="hitogami",expression="happy",
         stage={rudeus={expression="angry",animation="angry_shake"}},
         text="Ten cuidado con tus palabras."},
    },
}
```

`speaker` identifica al personaje; `portrait` elige un recurso; `expression` selecciona una de las cuatro celdas. También se admite una sustitución explícita:

```lua
{speaker="rudeus", portrait="rudeus_japones", expression="worried",
 delivery="dream", text="¿Qué estás intentando decirme?"}
```

La prioridad es `line.portrait`, `scene.portraits[identidad]`, contexto y, finalmente, el recurso habitual de la identidad. `line.stage` puede cambiar la expresión, retrato, animación o visibilidad de un personaje del reparto, aunque esté escuchando. En un reparto esos cambios visuales permanecen dentro de la escena hasta otra indicación; una animación solo se inicia en su propia línea. Sin `cast`, se mantiene el retrato individual del hablante y la sustitución de línea solo se aplica a esa línea.

El reparto admite uno o dos personajes, con posiciones `left` y `right` distintas. `enterAt` cuenta las líneas de la escena resuelta; `entranceDelay` va de 0 a 1 segundos. `visible=false` desvanece al personaje y `visible=true` lo hace entrar de nuevo. No coloques cambios de relaciones ni de estado de juego dentro de estos datos visuales. El validador rechaza contextos, recursos, expresiones, animaciones, repartos y direcciones inválidos. La comprobación de archivos se omite al arrancar para permitir el respaldo gráfico.

## Introducción, animación y restauración

La introducción conserva sus **11 líneas** y sus posiciones de guardado. Empieza con un fundido blanco; entra Hitogami y, 0,28 segundos después, Rudy japonés. La escritura comienza cuando terminan ambas entradas; un clic permite completar esa presentación. Los dos permanecen en escena: Rudy pasa de neutral a preocupado, reacciona con enfado a la advertencia indirecta sobre los remedios y sacude brevemente el retrato. Hitogami se despide sonriendo. Ambos salen suavemente y el fundido blanco conduce al hogar, donde Rudy vuelve al PNG habitual. La expresión feliz japonesa también está disponible para futuras escenas.

Las animaciones reutilizan `src/systems/animation.lua`: entradas, salidas, movimiento al hablar, preocupación, alegría y sacudidas. No deforman ni generan fotogramas. Movimiento reducido conserva las expresiones, elimina desplazamientos y acorta el fundido blanco.

`src/systems/portraits.lua` reconstruye la composición desde `checkpoint` y `dialogueIndex`, reproduciendo únicamente las indicaciones visuales hasta esa línea. No ejecuta efectos narrativos ni escribe en la sesión. Al cambiar de escena, la reconstrucción empieza desde sus propios datos. El guardado sigue siendo **v3**, sin campo de apariencia global, migraciones ni nuevas estadísticas; los guardados anteriores no se reescriben por esta integración. Pausar o cargar dentro del sueño recupera su fondo, Rudy japonés, reparto y expresiones; cargar después del despertar recupera el cuerpo reencarnado. Las entradas visuales se presentan de nuevo al cargar; no se persisten tiempos de animación.

El canal `dream` conserva la voz mental permitida por la maldición. Fuera del sueño siguen vigentes las reglas de pensamientos, silencio, notas y cartas encantadas. El combate físico continúa solicitando `rudeus`, incluso si los recursos japoneses ya están en caché.

## Archivos de la integración

- Recursos: `src/data/assets.lua`, `src/systems/resources.lua`.
- Contextos y resolución: `src/data/appearances.lua`, `src/systems/portraits.lua`.
- Narrativa y validación: `src/data/chapters/day1.lua`, `src/systems/progression.lua`, `src/systems/narrative_validator.lua`.
- Presentación: `src/screens/dialogue.lua`, `src/app.lua`, `src/core/state_manager.lua`.
- Pruebas: `tests/resources.lua`, `tests/portraits.lua`, `tests/motion.lua`, `tests/run.lua`.
- Documentación: `README.md`, `assets/README.md`, `docs/RETRATOS.md`, `docs/ANIMACIONES.md`, `docs/GUARDADO.md`, `docs/VERIFICACION.md` y exportación `docs/CODIGO_COMPLETO.md`.

No fue necesario modificar `src/data/characters.lua`, la lógica de relaciones, estadísticas, combate ni el formato del guardado. [Resultados y capturas](VERIFICACION.md).
