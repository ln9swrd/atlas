#!/usr/bin/env python3
"""Build a fresh, filtered MENOS Runtime content package from Content Editor inputs."""
import argparse
import hashlib
import json
import os
import shutil
import sqlite3
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath

PACKAGE_FORMAT_VERSION = 1
CONTENT_SCHEMA_VERSION = 1
EXCLUDED_TABLES = {"editor", "player_profile", "schema_migrations"}
EXPECTED_TABLES = {
    "allied_units", "asset_catalog", "bgm_definitions", "buildings", "campaign",
    "editor", "enemies", "factions", "gameplay", "items", "map_01", "map_01_src",
    "map_02", "map_03", "missions", "northbridge_sector_01", "odb_registry",
    "player_profile", "rewards", "robots", "schema_migrations", "sfx_definitions",
    "skills", "stage_01", "stage_02", "stage_03", "stage_catalog", "towers",
    "vfx_definitions", "visual_assets", "voice_definitions",
}
MAP_TABLES = {
    "northbridge_sector_01": "northbridge_sector_01",
    "map_02": "map_02",
    "map_03": "map_03",
}
LEGACY_MAP_TABLES = {"map_01": "northbridge_sector_01"}


class PublishError(RuntimeError):
    pass


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_json_file(path):
    try:
        with open(path, "r", encoding="utf-8-sig") as stream:
            return json.load(stream)
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise PublishError("Invalid UTF-8 JSON at %s: %s" % (path, exc))


def collect_resource_paths(value, found):
    if isinstance(value, dict):
        for child in value.values():
            collect_resource_paths(child, found)
    elif isinstance(value, list):
        for child in value:
            collect_resource_paths(child, found)
    elif isinstance(value, str) and value.startswith("res://"):
        normalized = value.replace("\\", "/")
        relative = normalized[6:]
        pure = PurePosixPath(relative)
        if not relative or pure.is_absolute() or any(part in ("", ".", "..") for part in pure.parts):
            raise PublishError("Unsafe Runtime resource path: %r" % value)
        found.add(normalized)


def connect_readonly(path):
    uri = path.resolve().as_uri() + "?mode=ro"
    try:
        return sqlite3.connect(uri, uri=True)
    except sqlite3.Error as exc:
        raise PublishError("Cannot open authoring DB read-only: %s" % exc)


def create_filtered_database(source_db, target_db, map_documents):
    source = connect_readonly(source_db)
    target = sqlite3.connect(str(target_db))
    try:
        source_tables = {row[0] for row in source.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")}
        if source_tables != EXPECTED_TABLES:
            raise PublishError("Authoring DB table set changed; review publisher allowlist. Missing=%s Unexpected=%s" % (
                sorted(EXPECTED_TABLES - source_tables), sorted(source_tables - EXPECTED_TABLES)))
        included = sorted(source_tables - EXCLUDED_TABLES)
        for table in included:
            row = source.execute("SELECT sql FROM sqlite_master WHERE type='table' AND name=?", (table,)).fetchone()
            if not row or not row[0]:
                raise PublishError("Missing CREATE TABLE SQL for %s" % table)
            target.execute(row[0])
            columns = [item[1] for item in source.execute('PRAGMA table_info("%s")' % table)]
            quoted_cols = ",".join('"%s"' % col.replace('"', '""') for col in columns)
            placeholders = ",".join("?" for _ in columns)
            rows = source.execute('SELECT %s FROM "%s"' % (quoted_cols, table)).fetchall()
            if rows:
                target.executemany('INSERT INTO "%s" (%s) VALUES (%s)' % (table, quoted_cols, placeholders), rows)
        # Runtime UI needs only the title-screen visual subsection of the authoring
        # editor settings. Publish that narrow contract separately; never ship the
        # full Content Editor settings table into Runtime.
        editor_row = source.execute('SELECT raw_json FROM "editor" LIMIT 1').fetchone()
        if not editor_row:
            raise PublishError("Editor settings document is missing")
        editor_settings = json.loads(editor_row[0])
        title_screen_settings = editor_settings.get("title_screen", {}) if isinstance(editor_settings, dict) else {}
        if not isinstance(title_screen_settings, dict):
            raise PublishError("Editor title_screen settings must be an object")
        target.execute("CREATE TABLE runtime_settings (raw_json TEXT NOT NULL)")
        target.execute("INSERT INTO runtime_settings(raw_json) VALUES (?)",
                       (json.dumps({"title_screen": title_screen_settings}, ensure_ascii=False, separators=(",", ":")),))
        # Runtime compatibility: fixed legacy tables remain, while new maps are also
        # materialized in the dynamic table consumed by Runtime MapLoader.
        for table, map_id in LEGACY_MAP_TABLES.items():
            payload = json.dumps(map_documents[map_id], ensure_ascii=False, separators=(",", ":"))
            target.execute('UPDATE "%s" SET raw_json=? WHERE document_id=?' % table, (payload, table))
        for table, map_id in MAP_TABLES.items():
            payload = json.dumps(map_documents[map_id], ensure_ascii=False, separators=(",", ":"))
            target.execute('UPDATE "%s" SET raw_json=? WHERE document_id=?' % table, (payload, table))
        target.execute("CREATE TABLE map_documents (map_id TEXT PRIMARY KEY, raw_json TEXT NOT NULL)")
        for map_id, data in sorted(map_documents.items()):
            target.execute("INSERT INTO map_documents(map_id, raw_json) VALUES (?, ?)",
                           (map_id, json.dumps(data, ensure_ascii=False, separators=(",", ":"))))
        # Preserve source indexes belonging to included tables.
        for name, sql in source.execute("SELECT name, sql FROM sqlite_master WHERE type='index' AND sql IS NOT NULL ORDER BY name"):
            table_row = source.execute("SELECT tbl_name FROM sqlite_master WHERE type='index' AND name=?", (name,)).fetchone()
            if table_row and table_row[0] in included:
                target.execute(sql)
        target.commit()
        result_tables = {row[0] for row in target.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")}
        expected_result = set(included) | {"map_documents", "runtime_settings"}
        if result_tables != expected_result:
            raise PublishError("Filtered DB table mismatch. Missing=%s Unexpected=%s" % (
                sorted(expected_result - result_tables), sorted(result_tables - expected_result)))
        integrity = target.execute("PRAGMA integrity_check").fetchone()[0]
        if integrity != "ok":
            raise PublishError("Published SQLite integrity check failed: %s" % integrity)
        return sorted(expected_result)
    finally:
        target.close()
        source.close()


def load_maps(maps_dir):
    result = {}
    warnings = []
    if not maps_dir.is_dir():
        raise PublishError("Map authoring directory is missing: %s" % maps_dir)
    files = sorted(maps_dir.glob("*.json"))
    if not files:
        raise PublishError("No map JSON files found in %s" % maps_dir)
    casefold_names = set()
    for path in files:
        map_id = path.stem
        if map_id.casefold() in casefold_names:
            raise PublishError("Duplicate map filename ignoring case: %s" % path.name)
        casefold_names.add(map_id.casefold())
        if not map_id or map_id != map_id.strip() or any(ch in map_id for ch in "/\\.: "):
            raise PublishError("Unsafe map ID / filename: %s" % path.name)
        data = parse_json_file(path)
        if not isinstance(data, dict):
            raise PublishError("Map document must be a JSON object: %s" % path.name)
        if data.get("map_id") != map_id:
            raise PublishError("Map map_id must exactly match filename stem: %s" % path.name)
        modes = data.get("play_modes", ["campaign", "single"])
        if not isinstance(modes, list):
            raise PublishError("Map play_modes must be an array: %s" % path.name)
        unsupported = [mode for mode in modes if str(mode).lower() not in ("campaign", "single")]
        unknown = [mode for mode in unsupported if str(mode).lower() != "multiplayer"]
        if unknown:
            raise PublishError("Unknown play mode in %s: %s" % (path.name, unknown))
        if unsupported:
            warnings.append({"code": "UNSUPPORTED_PLAY_MODE_IGNORED", "map_id": map_id,
                             "modes": [str(mode) for mode in unsupported],
                             "message": "Only Campaign and Single Play are published; legacy mode metadata is preserved outside play_modes."})
        published = dict(data)
        published["play_modes"] = [mode for mode in modes if str(mode).lower() in ("campaign", "single")]
        if not published["play_modes"]:
            raise PublishError("Map has no supported play mode: %s" % path.name)
        result[map_id] = published
    required = {"northbridge_sector_01", "map_02", "map_03"}
    if not required.issubset(result):
        raise PublishError("Required canonical maps missing: %s" % sorted(required - set(result)))
    return result, warnings


def validate_campaign_stage_references(source_db, maps):
    db = connect_readonly(source_db)
    try:
        row = db.execute("SELECT raw_json FROM campaign LIMIT 1").fetchone()
        if not row:
            raise PublishError("Campaign document is missing")
        campaign = json.loads(row[0])
        stage_refs = campaign.get("stages", [])
        stage_tables = ["stage_01", "stage_02", "stage_03"]
        stages_by_pk = {}
        for table in stage_tables:
            for odb_pk, document_id, raw_json in db.execute('SELECT odb_pk, document_id, raw_json FROM "%s"' % table):
                stages_by_pk[int(odb_pk)] = (table, json.loads(raw_json))
        for stage_ref in stage_refs:
            if isinstance(stage_ref, int):
                resolved = stages_by_pk.get(stage_ref)
            else:
                resolved = next((item for item in stages_by_pk.values() if item[1].get("stage_id") == str(stage_ref)), None)
            if resolved is None:
                raise PublishError("Campaign references missing Stage: %r" % (stage_ref,))
            stage = resolved[1]
            legacy_map_ref = str(stage.get("map_file", ""))
            map_id = {"map_01": "northbridge_sector_01"}.get(legacy_map_ref, legacy_map_ref)
            if map_id not in maps:
                raise PublishError("Stage %s references missing map %s (resolved %s)" % (stage.get("stage_id", resolved[0]), legacy_map_ref, map_id))
            for field, table in (("mission_id", "missions"), ("reward_id", "rewards")):
                ref = stage.get(field)
                if ref is None:
                    continue
                if isinstance(ref, int):
                    exists = db.execute('SELECT 1 FROM "%s" WHERE odb_pk=? LIMIT 1' % table, (ref,)).fetchone()
                else:
                    exists = db.execute('SELECT 1 FROM "%s" WHERE id=? LIMIT 1' % table, (str(ref),)).fetchone()
                if not exists:
                    raise PublishError("Stage %s references missing %s: %r" % (stage.get("stage_id", resolved[0]), field, ref))
    except (sqlite3.Error, json.JSONDecodeError) as exc:
        raise PublishError("Campaign/Stage reference validation failed: %s" % exc)
    finally:
        db.close()


def collect_db_resource_paths(db_path):
    found = set()
    db = connect_readonly(db_path)
    try:
        for (table,) in db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"):
            if table in EXCLUDED_TABLES:
                continue
            cursor = db.execute('SELECT * FROM "%s"' % table.replace('"', '""'))
            for row in cursor:
                for value in row:
                    if not isinstance(value, str):
                        continue
                    try:
                        parsed = json.loads(value)
                    except (ValueError, TypeError):
                        parsed = value
                    collect_resource_paths(parsed, found)
    finally:
        db.close()
    return found


def publish(source_db, maps_dir, runtime_root, output_dir):
    source_db = source_db.resolve()
    maps_dir = maps_dir.resolve()
    runtime_root = runtime_root.resolve()
    output_dir = output_dir.resolve()
    if not source_db.is_file():
        raise PublishError("Authoring DB not found: %s" % source_db)
    if not runtime_root.is_dir():
        raise PublishError("Runtime project root not found: %s" % runtime_root)
    if output_dir.exists():
        raise PublishError("Output path already exists; refusing to overwrite: %s" % output_dir)
    maps, warnings = load_maps(maps_dir)
    validate_campaign_stage_references(source_db, maps)
    source_hash_before = sha256_file(source_db)
    map_hashes = {map_id: sha256_file(maps_dir / (map_id + ".json")) for map_id in sorted(maps)}
    paths = collect_db_resource_paths(source_db)
    for map_data in maps.values():
        collect_resource_paths(map_data, paths)
    resolved = {}
    missing = []
    for resource in sorted(paths):
        source = runtime_root / resource[6:]
        if not source.is_file():
            missing.append(resource)
        else:
            resolved[resource] = source
    if missing:
        raise PublishError("Referenced Runtime Assets are missing: %s" % missing)

    output_dir.parent.mkdir(parents=True, exist_ok=True)
    temp_root = Path(tempfile.mkdtemp(prefix=output_dir.name + ".tmp-", dir=str(output_dir.parent)))
    try:
        db_target = temp_root / "content" / "menos.sqlite"
        db_target.parent.mkdir(parents=True, exist_ok=True)
        included_tables = create_filtered_database(source_db, db_target, maps)
        assets_manifest = []
        for resource, source in sorted(resolved.items()):
            relative = PurePosixPath(resource[6:])
            target = temp_root.joinpath(*relative.parts)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(str(source), str(target))
            assets_manifest.append({"path": resource, "size_bytes": target.stat().st_size,
                                    "sha256": sha256_file(target), "role": "content_asset"})
            # Godot's adjacent import metadata preserves the project's import settings/UID.
            import_source = Path(str(source) + ".import")
            if import_source.is_file():
                import_target = Path(str(target) + ".import")
                shutil.copy2(str(import_source), str(import_target))
                assets_manifest.append({"path": resource + ".import", "size_bytes": import_target.stat().st_size,
                                        "sha256": sha256_file(import_target), "role": "godot_import_metadata"})
        database_hash = sha256_file(db_target)
        manifest = {
            "package_format_version": PACKAGE_FORMAT_VERSION,
            "content_schema_version": CONTENT_SCHEMA_VERSION,
            "generated_at_utc": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
            "source": {"authoring_database_sha256": source_hash_before},
            "database": {"path": "content/menos.sqlite", "sha256": database_hash,
                         "read_only": True, "included_tables": included_tables},
            "maps": [{"map_id": map_id, "source_path": "data/maps/" + map_id + ".json",
                      "source_sha256": map_hashes[map_id]} for map_id in sorted(maps)],
            "supported_play_modes": ["campaign", "single"],
            "warnings": warnings,
            "assets": assets_manifest,
        }
        with open(temp_root / "manifest.json", "w", encoding="utf-8", newline="\n") as stream:
            json.dump(manifest, stream, ensure_ascii=False, indent=2, sort_keys=True)
            stream.write("\n")
        # Verify the manifest and every emitted asset before publishing the directory.
        check_manifest = parse_json_file(temp_root / "manifest.json")
        if check_manifest["database"]["sha256"] != sha256_file(db_target):
            raise PublishError("Manifest database hash does not match output DB")
        for item in check_manifest["assets"]:
            rel = item["path"][6:] if item["path"].startswith("res://") else item["path"]
            file_path = temp_root.joinpath(*PurePosixPath(rel).parts)
            if not file_path.is_file() or file_path.stat().st_size != item["size_bytes"] or sha256_file(file_path) != item["sha256"]:
                raise PublishError("Manifest Asset verification failed: %s" % item["path"])
        if sha256_file(source_db) != source_hash_before:
            raise PublishError("Authoring database changed during publishing")
        if {map_id: sha256_file(maps_dir / (map_id + ".json")) for map_id in maps} != map_hashes:
            raise PublishError("Authoring map JSON changed during publishing")
        os.replace(str(temp_root), str(output_dir))
        return {"output": str(output_dir), "database_sha256": database_hash,
                "included_tables": included_tables, "map_count": len(maps),
                "asset_file_count": len(assets_manifest), "resource_count": len(resolved),
                "warning_count": len(warnings)}
    except Exception:
        shutil.rmtree(str(temp_root), ignore_errors=True)
        raise


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    here = Path(__file__).resolve().parents[1]
    parser.add_argument("--source-db", type=Path, default=here / "data" / "menos.sqlite")
    parser.add_argument("--maps-dir", type=Path, default=here / "data" / "maps")
    parser.add_argument("--runtime-root", type=Path, required=True, help="Explicit Runtime project root used only as the source for referenced res:// assets")
    parser.add_argument("--output", type=Path, required=True, help="New output directory; must not already exist")
    args = parser.parse_args(argv)
    try:
        result = publish(args.source_db, args.maps_dir, args.runtime_root, args.output)
    except PublishError as exc:
        print("PUBLISH_FAILED: %s" % exc, file=sys.stderr)
        return 2
    except (OSError, sqlite3.Error, ValueError, KeyError) as exc:
        print("PUBLISH_FAILED: %s" % exc, file=sys.stderr)
        return 3
    print("PUBLISH_PASS")
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
