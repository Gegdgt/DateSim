"""Auditable, byte-preserving migration. Run inventory BEFORE copy; never deletes originals.

python tools/migrate_exploration_assets.py inventory|copy|verify
Only inventory needs Pillow (PNG decoding); verify uses the standard library.
"""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import re
import shutil
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/New"
REPORT = ROOT / "docs/assets_migration.json"
BACKUP = ROOT / ".asset_backups/exploration-originals.zip"
HOUSE = {"casa_planta_baja", "casa_segundo_piso", "dormitorio_sylphie",
         "dormitorio_roxy", "dormitorio_eris", "estudio_rudy", "jardin_casa", "patio_eris"}
SHARIA = {"camino_sharia", "cementerio_ranoa"}
RANOA = {"universidad_exterior", "biblioteca_ranoa", "taller_cliff_zanoba", "laboratorio_nanahoshi"}
WALK = {"Rudeus_walk", "Sylphie_walk", "Roxy_walk", "Eris_walk", "Nanahoshi_walk", "Cliff_walk", "Zanoba_walk"}
PORTRAITS = {"aisha", "lilia", "norn", "zenith", "lucy"}
IDLE = {"aisha_idle", "lilia_idle", "norn_idle", "zenith_lucy_idle", "lucy_idle"}
TILES = {"tileset_hogar", "tileset_exterior", "tileset_universidad", "tileset_cementerio"}
ITEMS = {"01_moneda_oro", "02_bolsa_oro", "03_libro_magia", "04_pergamino", "05_carta_encantada",
         "06_cofre_cerrado", "07_cofre_abierto", "08_fragmento_mana", "09_material_magico", "10_frasco_pocion",
         "11_antidoto", "12_escoba", "13_flor", "14_anillo_matrimonio", "15_nota_misteriosa", "16_indicador_interaccion"}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def category(stem):
    if stem in WALK: return "characters/overworld"
    if stem in PORTRAITS: return "characters/portraits"
    if stem in IDLE: return "characters/npc_idle"
    if stem in TILES: return "tilesets"
    if stem in ITEMS: return "objects/items"
    if stem == "objetos_atlas_64x64": return "objects/atlases"
    if stem == "caballo_salida": return "animations/horse"
    if stem.endswith("_map"):
        ident = stem[:-4]
        for ids, folder in ((HOUSE, "greyrat_house"), (SHARIA, "sharia"), (RANOA, "ranoa")):
            if ident in ids: return "maps/" + folder
    raise ValueError("Unclassified resource (original retained): " + stem)


def ase_metadata(data):
    # https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md
    size, magic, frames, width, height, depth = struct.unpack_from("<IHHHHH", data)
    assert len(data) >= 128 and size == len(data) and magic == 0xA5E0
    assert frames > 0 and width > 0 and height > 0 and depth in (8, 16, 32)
    offset, durations, layers, chunks, warnings = 128, [], [], Counter(), []
    for _ in range(frames):
        frame_size, frame_magic, old_count, duration = struct.unpack_from("<IHHH", data, offset)
        new_count = struct.unpack_from("<I", data, offset + 12)[0]
        assert frame_magic == 0xF1FA and frame_size >= 16 and offset + frame_size <= size
        pos = offset + 16
        for _ in range(new_count or old_count):
            chunk_size, kind = struct.unpack_from("<IH", data, pos)
            assert chunk_size >= 6 and pos + chunk_size <= offset + frame_size
            chunks[hex(kind)] += 1
            if kind == 0x2004:
                length = struct.unpack_from("<H", data, pos + 22)[0] if chunk_size >= 24 else chunk_size
                if 24 + length <= chunk_size:
                    layers.append(data[pos + 24:pos + 24 + length].decode("utf-8"))
                else:
                    # Preserve malformed source bytes; do NOT repair/export a native project.
                    warnings.append("Layer chunk at byte %d does not match the standard 16-byte layer header" % pos)
                    layers.append(None)
            pos += chunk_size
        assert pos == offset + frame_size
        durations.append(duration)
        offset += frame_size
    assert offset == size
    return dict(width=width, height=height, frames=frames, depth=depth,
                durationsMs=durations, layers=layers, chunks=dict(chunks), warnings=warnings)


def inventory():
    from PIL import Image
    assert not REPORT.exists(), "Inventory already exists; do not replace the pre-migration evidence."
    files = sorted(p for p in SOURCE.rglob("*") if p.is_file())
    assert files, "No source files"
    expected_stems = WALK | PORTRAITS | IDLE | TILES | ITEMS | {"caballo_salida", "objetos_atlas_64x64"}
    expected_stems |= {i + "_map" for i in HOUSE | SHARIA | RANOA}
    expected_names = {s + ext for s in expected_stems for ext in (".png", ".ase")}
    expected_names |= {"LEEME.txt", "objetos_atlas.csv", "objetos_atlas.json"}
    legacy = []
    names = defaultdict(list)
    for folder in (ROOT / "assets", ROOT / "sprite_sources"):
        for p in sorted(folder.rglob("*")):
            if p.is_file() and SOURCE not in p.parents:
                names[p.name.lower()].append(p)
                if p.suffix.lower() != ".md":
                    legacy.append(dict(path=p.relative_to(ROOT).as_posix(), sha256=sha(p), bytes=p.stat().st_size))
    records, duplicates = [], []
    for p in files:
        if p.name == "LEEME.txt": cat, base = "tilesets", "assets"
        elif p.name in ("objetos_atlas.csv", "objetos_atlas.json"): cat, base = "objects/atlases", "assets"
        else: cat, base = category(p.stem), ("sprite_sources" if p.suffix == ".ase" else "assets")
        target = ROOT / base / cat / p.name
        record = dict(name=p.name, original=p.relative_to(ROOT).as_posix(),
                      destination=target.relative_to(ROOT).as_posix(), category=cat,
                      bytes=p.stat().st_size, sha256=sha(p))
        if p.suffix == ".png":
            with Image.open(p) as im:
                assert im.format == "PNG"
                im.load()
                record["png"] = dict(width=im.width, height=im.height, mode=im.mode)
        elif p.suffix == ".ase": record["ase"] = ase_metadata(p.read_bytes())
        for old in names[p.name.lower()]:
            duplicates.append(dict(original=record["original"], existing=old.relative_to(ROOT).as_posix(),
                                   identical=record["sha256"] == sha(old)))
        assert not target.exists() or sha(target) == record["sha256"], "Different destination: " + str(target)
        records.append(record)
    # Capture the original manifest's path identities, including aliases, before extending it.
    old_manifest = (ROOT / "src/data/assets.lua").read_text(encoding="utf-8")
    paths, group = [], None
    for line in old_manifest.splitlines():
        opening = re.match(r"    (\w+)=\{", line)
        if opening: group = opening[1]
        if line.strip() == "},": group = None
        match = re.match(r'\s*(\w+)="(assets/[^"\n]+)"', line)
        if match: paths.append(dict(group=group or "", id=match[1], path=match[2]))
    report = dict(schema=1, source="assets/New", backup=BACKUP.relative_to(ROOT).as_posix(),
                  counts=dict(Counter(p.suffix for p in files)),
                  missing=sorted(expected_names - {p.name for p in files}),
                  unexpected=sorted({p.name for p in files} - expected_names),
                  duplicates=duplicates, files=records, legacyFiles=legacy, legacyManifest=paths)
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: report[k] for k in ("counts", "missing", "unexpected", "duplicates")}, ensure_ascii=False))
    print("Pre-migration SHA-256 recorded:", len(records), "incoming;", len(legacy), "existing files")
    print("Source ASE files with nonstandard layer headers:", sum(bool(f.get("ase", {}).get("warnings")) for f in records))


def read_report():
    return json.loads(REPORT.read_text(encoding="utf-8"))


def verify_backup(report):
    with zipfile.ZipFile(BACKUP) as archive:
        assert len(archive.namelist()) == len(report["files"])
        for record in report["files"]:
            assert hashlib.sha256(archive.read(record["original"])).hexdigest() == record["sha256"]


def copy():
    report = read_report()
    for record in report["files"]:
        assert sha(ROOT / record["original"]) == record["sha256"], "Source changed"
        dest = ROOT / record["destination"]
        assert not dest.exists() or sha(dest) == record["sha256"], "Destination conflict: " + str(dest)
    BACKUP.parent.mkdir(parents=True, exist_ok=True)
    if not BACKUP.exists():
        with zipfile.ZipFile(BACKUP, "x", zipfile.ZIP_DEFLATED) as archive:
            for record in report["files"]: archive.write(ROOT / record["original"], record["original"])
    verify_backup(report)
    for record in report["files"]:
        dest = ROOT / record["destination"]
        dest.parent.mkdir(parents=True, exist_ok=True)
        if not dest.exists(): shutil.copy2(ROOT / record["original"], dest)
    verify()
    print("Copies and recovery archive verified. Originals retained until tests pass.")


def verify():
    report = read_report()
    for record in report["files"]:
        dest = ROOT / record["destination"]
        assert dest.stat().st_size == record["bytes"] and sha(dest) == record["sha256"], str(dest)
        if dest.suffix == ".ase": assert ase_metadata(dest.read_bytes()) == record["ase"]
    for record in report["legacyFiles"]:
        assert sha(ROOT / record["path"]) == record["sha256"], "Legacy resource changed: " + record["path"]
    if BACKUP.exists(): verify_backup(report)
    warnings = sum(bool(f.get("ase", {}).get("warnings")) for f in report["files"])
    print("Verified:", len(report["files"]), "migrated files;", len(report["legacyFiles"]),
          "existing files; ASE bytes unchanged;", warnings, "pre-existing layer-header warnings.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("inventory", "copy", "verify"))
    globals()[parser.parse_args().action]()
