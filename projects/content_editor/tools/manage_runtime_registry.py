#!/usr/bin/env python3
"""Manage registered Runtime targets and per-target table publication settings."""
import argparse
import json
import shutil
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path

TABLES = [
    "asset_catalog", "bgm_definitions", "buildings", "campaign", "factions",
    "gameplay", "items", "missions", "odb_registry", "rewards", "robots",
    "sfx_definitions", "skills", "stage_01", "stage_02", "stage_03",
    "stage_catalog", "towers", "units", "vfx_definitions", "visual_assets",
    "voice_definitions",
]
EDITOR_ONLY = {"editor", "player_profile", "schema_migrations"}
ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "data" / "menos.sqlite"


def connect():
    DB.parent.mkdir(parents=True, exist_ok=True)
    existed = DB.exists()
    needs_migration = not existed
    if existed:
        probe = sqlite3.connect("file:" + str(DB).replace("\\", "/") + "?mode=ro", uri=True)
        try:
            existing = {row[0] for row in probe.execute("SELECT name FROM sqlite_master WHERE type='table'")}
            needs_migration = not {"runtime_targets", "runtime_table_settings"}.issubset(existing)
        finally:
            probe.close()
    if existed and needs_migration:
        backup_dir = DB.parent / "backups"
        backup_dir.mkdir(parents=True, exist_ok=True)
        stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        backup = backup_dir / ("runtime_registry_pre_migration_" + stamp + ".sqlite")
        shutil.copy2(DB, backup)
    conn = sqlite3.connect(str(DB))
    try:
        conn.execute("PRAGMA foreign_keys=ON")
        conn.execute("""CREATE TABLE IF NOT EXISTS runtime_targets (
            runtime_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            project_path TEXT NOT NULL UNIQUE,
            enabled INTEGER NOT NULL DEFAULT 1 CHECK(enabled IN (0,1)),
            notes TEXT NOT NULL DEFAULT '',
            created_at_utc TEXT NOT NULL,
            updated_at_utc TEXT NOT NULL
        )""")
        conn.execute("""CREATE TABLE IF NOT EXISTS runtime_table_settings (
            runtime_id INTEGER NOT NULL REFERENCES runtime_targets(runtime_id) ON DELETE CASCADE,
            table_name TEXT NOT NULL,
            enabled INTEGER NOT NULL DEFAULT 1 CHECK(enabled IN (0,1)),
            last_publish_status TEXT NOT NULL DEFAULT 'NEVER',
            last_published_at_utc TEXT NOT NULL DEFAULT '',
            last_published_sha256 TEXT NOT NULL DEFAULT '',
            PRIMARY KEY(runtime_id, table_name)
        )""")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_runtime_targets_enabled ON runtime_targets(enabled)")
        # Keep per-runtime settings aligned with the current publishable content
        # catalog. Map documents are JSON assets, not SQLite tables.
        runtime_ids = [row[0] for row in conn.execute("SELECT runtime_id FROM runtime_targets")]
        placeholders = ",".join("?" for _ in TABLES)
        for runtime_id in runtime_ids:
            conn.executemany(
                "INSERT OR IGNORE INTO runtime_table_settings(runtime_id, table_name, enabled) VALUES(?,?,1)",
                [(runtime_id, table_name) for table_name in TABLES],
            )
            conn.execute(
                "DELETE FROM runtime_table_settings WHERE runtime_id=? AND table_name NOT IN (" + placeholders + ")",
                [runtime_id, *TABLES],
            )
        conn.commit()
        return conn
    except Exception:
        conn.close()
        raise


def result(data):
    print(json.dumps(data, ensure_ascii=False))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["list", "add", "update", "delete", "set_table", "init"])
    parser.add_argument("--id", type=int, default=0)
    parser.add_argument("--name", default="")
    parser.add_argument("--path", default="")
    parser.add_argument("--notes", default="")
    parser.add_argument("--enabled", type=int, choices=[0, 1], default=1)
    parser.add_argument("--table", default="")
    args = parser.parse_args()
    conn = connect()
    try:
        if args.action in ("init", "list"):
            targets = []
            for row in conn.execute("SELECT runtime_id,name,project_path,enabled,notes,created_at_utc,updated_at_utc FROM runtime_targets ORDER BY runtime_id"):
                target = dict(zip(["id","name","path","enabled","notes","created_at_utc","updated_at_utc"], row))
                tables = []
                for tr in conn.execute("SELECT table_name,enabled,last_publish_status,last_published_at_utc,last_published_sha256 FROM runtime_table_settings WHERE runtime_id=? ORDER BY table_name", (target["id"],)):
                    tables.append(dict(zip(["name","enabled","last_publish_status","last_published_at_utc","last_published_sha256"], tr)))
                target["tables"] = tables
                targets.append(target)
            result({"status":"PASS","targets":targets,"table_catalog":TABLES,"editor_only_tables":sorted(EDITOR_ONLY)})
        elif args.action == "add":
            name, path = args.name.strip(), str(Path(args.path).expanduser().resolve())
            if not name or not args.path or not (Path(path) / "project.godot").is_file():
                raise ValueError("Name and a valid Runtime project folder containing project.godot are required.")
            now = datetime.now(timezone.utc).isoformat()
            cur = conn.execute("INSERT INTO runtime_targets(name,project_path,enabled,notes,created_at_utc,updated_at_utc) VALUES(?,?,?,?,?,?)",
                               (name,path,args.enabled,args.notes,now,now))
            rid = cur.lastrowid
            conn.executemany("INSERT INTO runtime_table_settings(runtime_id,table_name,enabled) VALUES(?,?,1)",
                             [(rid,t) for t in TABLES])
            conn.commit()
            result({"status":"PASS","id":rid})
        elif args.action == "update":
            if not args.id or not args.name.strip() or not args.path:
                raise ValueError("Runtime ID, name and path are required.")
            path = str(Path(args.path).expanduser().resolve())
            if not (Path(path) / "project.godot").is_file():
                raise ValueError("Selected path does not contain project.godot.")
            conn.execute("UPDATE runtime_targets SET name=?,project_path=?,enabled=?,notes=?,updated_at_utc=? WHERE runtime_id=?",
                         (args.name.strip(),path,args.enabled,args.notes,datetime.now(timezone.utc).isoformat(),args.id))
            conn.commit()
            result({"status":"PASS","updated":conn.total_changes > 0})
        elif args.action == "delete":
            conn.execute("DELETE FROM runtime_targets WHERE runtime_id=?", (args.id,))
            conn.commit()
            result({"status":"PASS","deleted":conn.total_changes > 0})
        elif args.action == "set_table":
            if not args.id or args.table not in TABLES:
                raise ValueError("A valid Runtime ID and table name are required.")
            conn.execute("UPDATE runtime_table_settings SET enabled=? WHERE runtime_id=? AND table_name=?",
                         (args.enabled,args.id,args.table))
            if conn.total_changes == 0:
                raise ValueError("Runtime/table setting not found.")
            conn.execute("UPDATE runtime_targets SET updated_at_utc=? WHERE runtime_id=?",
                         (datetime.now(timezone.utc).isoformat(),args.id))
            conn.commit()
            result({"status":"PASS"})
    except (sqlite3.Error, OSError, ValueError) as exc:
        conn.rollback()
        result({"status":"FAIL","error":str(exc)})
        return 2
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
