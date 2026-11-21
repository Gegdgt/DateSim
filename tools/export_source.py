"""Genera una entrega con la ruta y el contenido íntegro de cada archivo de texto."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
destination = root / "docs" / "CODIGO_COMPLETO.md"
extensions = {".lua": "lua", ".ps1": "powershell", ".py": "python", ".md": "markdown"}
files = sorted(p for p in root.rglob("*") if p.is_file()
               and (p.suffix in extensions or p.name in {".gitignore", ".gitkeep"}) and p != destination
               and not any(part in {".git", ".tmp", "dist", ".codex", ".agents", "sprite_sources", "artifacts"} for part in p.relative_to(root).parts))
chunks = ["# Código completo del proyecto\n\n"
          "Este documento contiene las rutas y el contenido completo de los archivos de texto del proyecto. "
          "Los archivos reales ya están creados; no es necesario copiarlos desde aquí. "
          "Los PNG del juego están en assets/ y los editables ASE en sprite_sources/; "
          "los archivos binarios no se incluyen en este documento. "
          "Esta versión comprende siete días, cinco finales matrimoniales, colección progresiva, "
          "la maldición de Rudy, retratos contextuales, conversaciones ramificadas escritas, memoria de promesas, "
          "cartas parlantes, barras animadas, afinidad de Nanahoshi, entrenamiento con Eris, "
          "dificultad por día, energía externa, compañeras, agenda diaria con tres actividades y un encargo, "
          "Badigadi de 1000 PV, apoyos por afinidad, Orsted condicional, dos mejoras elegidas, devolución de cartas, guardado v8, animaciones y audio sintetizado.\n\n"
          f"Raíz del proyecto: `{root.as_posix()}`\n"]
for path in files:
    content = path.read_text(encoding="utf-8-sig")
    fence = "`" * max(4, max((len(s) for s in content.split() if set(s) == {"`"}), default=0) + 1)
    chunks.append(f"\n## {path.relative_to(root).as_posix()}\n\nRuta exacta: `{path.as_posix()}`\n\n"
                  f"{fence}{extensions.get(path.suffix, 'text')}\n{content.rstrip()}\n{fence}\n")
destination.parent.mkdir(exist_ok=True)
destination.write_text("".join(chunks), encoding="utf-8")
print(f"Exportados {len(files)} archivos: {destination}")
