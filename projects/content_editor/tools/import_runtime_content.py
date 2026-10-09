#!/usr/bin/env python3
"""Safely import a Runtime SQLite snapshot and its canonical maps into Content Editor.

Default mode is read-only preview. Applying replaces the authoring DB and map JSON
snapshot only after validation, and creates a recoverable timestamped backup first.
The selected Runtime DB is never opened for writing.
"""
import argparse
import hashlib
import json
import os
import shutil
import sqlite3
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
DEFAULT_AUTHORING_DB = HERE / "data" / "content_editor.sqlite"
DEFAULT_MAPS_DIR = HERE / "data" / "maps"
REQUIRED_MAP_TABLES = {
    "northbridge_sector_01": "map_01",
    "map_02": "map_02",
    "map_03": "map_03",
}

class ImportErrorSafe(RuntimeError):
    pass

def sha256_file(path):
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def connect_readonly(path):
    return sqlite3.connect(Path(path).resolve().as_uri() + "?mode=ro", uri=True)

def inspect_source(source_db):
    source_db = Path(source_db).resolve()
    if not source_db.is_file():
        raise ImportErrorSafe(f"Runtime database does not exist: {source_db}")
    try:
        db = connect_readonly(source_db)
        try:
            integrity = db.execute("PRAGMA integrity_check").fetchone()[0]
            if integrity != "ok":
                raise ImportErrorSafe(f"Runtime database integrity check failed: {integrity}")
            tables = {r[0] for r in db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")}
            if not tables:
                raise ImportErrorSafe("Runtime database contains no application tables")
            counts = {t: db.execute('SELECT COUNT(*) FROM "' + t.replace('"', '""') + '"').fetchone()[0] for t in sorted(tables)}
            maps = {}
            for map_id, table in REQUIRED_MAP_TABLES.items():
                if table not in tables:
                    raise ImportErrorSafe(f"Runtime database is missing required map table: {table}")
                rows = db.execute(f'SELECT raw_json FROM "{table}"').fetchall()
                if len(rows) != 1:
                    raise ImportErrorSafe(f"Expected exactly one canonical map row in {table}; found {len(rows)}")
                try:
                    payload = json.loads(rows[0][0])
                except (TypeError, json.JSONDecodeError) as exc:
                    raise ImportErrorSafe(f"Invalid map JSON in Runtime table {table}: {exc}") from exc
                if not isinstance(payload, dict) or payload.get("map_id") != map_id:
                    raise ImportErrorSafe(f"Map identity mismatch in Runtime table {table}; expected map_id={map_id}")
                maps[map_id] = payload
            return {"source_db": source_db, "sha256": sha256_file(source_db), "integrity": integrity,
                    "tables": tables, "table_counts": counts, "maps": maps}
        finally:
            db.close()
    except sqlite3.Error as exc:
        raise ImportErrorSafe(f"Cannot read Runtime database: {exc}") from exc

def validate_authoring_db(authoring_db, source_tables):
    authoring_db = Path(authoring_db).resolve()
    if not authoring_db.is_file():
        raise ImportErrorSafe(f"Content Editor authoring database does not exist: {authoring_db}")
    db = connect_readonly(authoring_db)
    try:
        integrity = db.execute("PRAGMA integrity_check").fetchone()[0]
        if integrity != "ok":
            raise ImportErrorSafe(f"Current authoring database integrity check failed: {integrity}")
        tables = {r[0] for r in db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")}
        if tables != source_tables:
            raise ImportErrorSafe("Runtime and authoring schemas differ; import refused. "
                                  f"Runtime-only tables={sorted(source_tables-tables)}, "
                                  f"Authoring-only tables={sorted(tables-source_tables)}")
        return sha256_file(authoring_db)
    finally:
        db.close()

def run_import(source_db, authoring_db=DEFAULT_AUTHORING_DB, maps_dir=DEFAULT_MAPS_DIR, apply=False):
    source_db = Path(source_db).resolve()
    authoring_db = Path(authoring_db).resolve()
    maps_dir = Path(maps_dir).resolve()
    if source_db == authoring_db:
        raise ImportErrorSafe("Source Runtime DB and target authoring DB resolve to the same file")
    source = inspect_source(source_db)
    authoring_hash = validate_authoring_db(authoring_db, source["tables"])
    existing_maps = {}
    if maps_dir.exists():
        for p in sorted(maps_dir.glob("*.json")):
            try:
                existing_maps[p.name] = json.loads(p.read_text(encoding="utf-8-sig"))
            except (OSError, json.JSONDecodeError) as exc:
                raise ImportErrorSafe(f"Current authoring map is invalid; no changes made: {p}: {exc}") from exc
    for map_id, payload in source["maps"].items():
        payload_bytes = json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
        if json.loads(payload_bytes).get("map_id") != map_id:
            raise ImportErrorSafe(f"Staged map identity validation failed: {map_id}")
    report = {
        "mode": "APPLY" if apply else "PREVIEW ONLY",
        "runtime_source": str(source_db),
        "runtime_sha256": source["sha256"],
        "runtime_integrity": source["integrity"],
        "authoring_target": str(authoring_db),
        "authoring_sha256_before": authoring_hash,
        "schema_table_count": len(source["tables"]),
        "table_counts": source["table_counts"],
        "maps_to_import": {k: {"objects": len(v.get("objects", [])), "name": v.get("name", ""),
                               "existing_json": (maps_dir / f"{k}.json").exists()} for k, v in source["maps"].items()},
        "existing_authoring_maps": sorted(existing_maps),
        "runtime_db_will_be_modified": False,
    }
    if not apply:
        return report

    maps_parent = maps_dir.parent
    maps_parent.mkdir(parents=True, exist_ok=True)
    authoring_db.parent.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    backup_root = authoring_db.parent / "backups" / f"runtime_import_{stamp}"
    if backup_root.exists():
        raise ImportErrorSafe(f"Backup path collision: {backup_root}")
    backup_root.mkdir(parents=True)
    db_stage = None
    maps_stage = None
    db_replaced = False
    maps_replaced = False
    old_maps_backup = backup_root / "maps_before"
    db_backup = backup_root / "menos.sqlite.before"
    try:
        shutil.copy2(authoring_db, db_backup)
        if sha256_file(db_backup) != authoring_hash:
            raise ImportErrorSafe("Authoring DB backup hash mismatch")
        if maps_dir.exists():
            shutil.copytree(maps_dir, old_maps_backup)
        with tempfile.NamedTemporaryFile(prefix="menos_runtime_import_", suffix=".sqlite", dir=str(authoring_db.parent), delete=False) as tmp:
            db_stage = Path(tmp.name)
        shutil.copy2(source_db, db_stage)
        staged = inspect_source(db_stage)
        if staged["sha256"] != source["sha256"]:
            raise ImportErrorSafe("Staged Runtime DB hash mismatch")
        maps_stage = Path(tempfile.mkdtemp(prefix="maps_runtime_import_", dir=str(maps_parent)))
        for map_id, payload in source["maps"].items():
            target = maps_stage / f"{map_id}.json"
            target.write_text(json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
            loaded = json.loads(target.read_text(encoding="utf-8"))
            if loaded.get("map_id") != map_id:
                raise ImportErrorSafe(f"Staged map verification failed: {map_id}")
        # Preserve unexpected/custom maps rather than silently deleting them. Canonical IDs are replaced by source snapshot.
        for name, payload in existing_maps.items():
            if name not in {f"{k}.json" for k in source["maps"]}:
                (maps_stage / name).write_text(json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        # Replace maps via rename, then DB. If either step fails, restore from backups.
        maps_old = maps_parent / f"{maps_dir.name}.before_{stamp}"
        if maps_dir.exists():
            os.replace(maps_dir, maps_old)
        try:
            os.replace(maps_stage, maps_dir)
            maps_stage = None
            maps_replaced = True
            os.replace(db_stage, authoring_db)
            db_stage = None
            db_replaced = True
        except Exception:
            if maps_dir.exists():
                shutil.rmtree(maps_dir)
            if maps_old.exists():
                os.replace(maps_old, maps_dir)
            raise
        # Keep both a permanent backup and the renamed pre-import map folder until hashes are confirmed.
        if sha256_file(authoring_db) != source["sha256"]:
            raise ImportErrorSafe("Installed authoring DB hash differs from Runtime source")
        installed = inspect_source(authoring_db)
        if installed["integrity"] != "ok":
            raise ImportErrorSafe("Installed authoring DB integrity check failed")
        for map_id in source["maps"]:
            installed_map = json.loads((maps_dir / f"{map_id}.json").read_text(encoding="utf-8"))
            if installed_map != source["maps"][map_id]:
                raise ImportErrorSafe(f"Installed map differs from Runtime source: {map_id}")
        shutil.rmtree(maps_old, ignore_errors=True)
        report["backup_directory"] = str(backup_root)
        report["authoring_sha256_after"] = sha256_file(authoring_db)
        report["maps_imported"] = sorted(source["maps"])
        report["result"] = "PASS"
        return report
    except Exception:
        # Best-effort rollback for failures after replacement; never alter the Runtime source.
        if db_replaced and db_backup.exists():
            shutil.copy2(db_backup, authoring_db)
        if maps_replaced and old_maps_backup.exists():
            if maps_dir.exists():
                shutil.rmtree(maps_dir)
            shutil.copytree(old_maps_backup, maps_dir)
        raise
    finally:
        if db_stage and db_stage.exists():
            db_stage.unlink()
        if maps_stage and maps_stage.exists():
            shutil.rmtree(maps_stage, ignore_errors=True)

def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-db", type=Path, required=True, help="Runtime or published-package SQLite DB; opened read-only")
    parser.add_argument("--authoring-db", type=Path, default=DEFAULT_AUTHORING_DB)
    parser.add_argument("--maps-dir", type=Path, default=DEFAULT_MAPS_DIR)
    parser.add_argument("--apply", action="store_true", help="Apply import after validation; otherwise print preview only")
    args = parser.parse_args(argv)
    try:
        print(json.dumps(run_import(args.source_db, args.authoring_db, args.maps_dir, args.apply), ensure_ascii=False, indent=2))
        return 0
    except (ImportErrorSafe, OSError, sqlite3.Error) as exc:
        print(f"RUNTIME_IMPORT_FAILED: {exc}", file=sys.stderr)
        return 2

if __name__ == "__main__":
    raise SystemExit(main())
