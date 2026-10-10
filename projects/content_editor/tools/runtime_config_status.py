#!/usr/bin/env python3
"""Read-only Runtime-specific package selection status query."""
import argparse
import hashlib
import json
import os
import sys
import sqlite3
import re
from pathlib import Path


def normalize_project_root(value: str) -> str:
    raw = value.strip().replace("\\", "/")
    if not raw:
        return ""
    normalized = os.path.normpath(raw).replace("\\", "/")
    # Windows paths are case-insensitive. Preserve POSIX path case.
    if os.name == "nt":
        normalized = normalized.lower()
    return normalized.rstrip("/") if len(normalized) > 1 else normalized


def query(project_path: str, user_data_root: str) -> dict:
    normalized = normalize_project_root(project_path)
    if not normalized or not Path(normalized).is_absolute():
        return {"status": "FAIL", "state": "INVALID_RUNTIME_PATH", "error": "Runtime project path must be absolute."}
    project = Path(project_path.strip())
    if not (project / "project.godot").is_file():
        return {"status": "FAIL", "state": "RUNTIME_PROJECT_NOT_FOUND", "project_root": normalized, "error": "project.godot was not found at the registered Runtime path."}
    identity = hashlib.sha256(normalized.encode("utf-8")).hexdigest()
    config_path = Path(user_data_root) / ("runtime_content_package_" + identity + ".json")
    result = {"status": "PASS", "runtime_identity": identity, "project_root": normalized,
              "config_path": str(config_path), "configured": False, "package_root": "",
              "config_state": "BUILT_IN_CONTENT_CONFIGURED", "package_state": "NOT_CHECKED"}
    if not config_path.exists():
        return result
    try:
        raw = config_path.read_text(encoding="utf-8")
        config = json.loads(raw)
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        result.update(status="FAIL", config_state="INVALID_CONFIG", error=str(exc))
        return result
    package_root = config.get("package_root") if isinstance(config, dict) else None
    if not isinstance(package_root, str) or not package_root.strip() or not Path(package_root).is_absolute():
        result.update(status="FAIL", config_state="INVALID_CONFIG", error="Config must contain an absolute package_root.")
        return result
    package_root = str(Path(package_root.strip()))
    result.update(configured=True, package_root=package_root, config_state="PACKAGE_CONFIGURED_FOR_NEXT_LAUNCH")
    manifest_path = Path(package_root) / "manifest.json"
    database_path = Path(package_root) / "content" / "menos.sqlite"
    if not manifest_path.is_file() or not database_path.is_file():
        result.update(package_state="PACKAGE_FILES_MISSING")
        return result
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8-sig"))
        expected = manifest.get("database", {}).get("sha256", "") if isinstance(manifest, dict) else ""
        if not expected:
            result.update(package_state="MANIFEST_INVALID", warning="Manifest does not declare database SHA-256.")
            return result
        digest = hashlib.sha256()
        with database_path.open("rb") as stream:
            for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                digest.update(chunk)
        if digest.hexdigest().lower() != str(expected).lower():
            result.update(package_state="DATABASE_HASH_MISMATCH")
            return result
        assets = manifest.get("assets", [])
        if not isinstance(assets, list):
            result.update(package_state="MANIFEST_INVALID", warning="Manifest assets must be a list.")
            return result
        package_root_resolved = Path(package_root).resolve()
        for asset in assets:
            if not isinstance(asset, dict):
                result.update(package_state="MANIFEST_INVALID", warning="Manifest asset entry must be an object.")
                return result
            resource_path = asset.get("path", "")
            if not isinstance(resource_path, str) or not resource_path.startswith("res://"):
                result.update(package_state="MANIFEST_INVALID", warning="Manifest asset path must use res://.")
                return result
            relative_path = Path(resource_path[6:].replace("\\", "/"))
            if relative_path.is_absolute() or ".." in relative_path.parts:
                result.update(package_state="MANIFEST_INVALID", warning="Manifest asset path escapes package root.")
                return result
            asset_path = package_root_resolved.joinpath(*relative_path.parts)
            try:
                asset_path.resolve().relative_to(package_root_resolved)
            except ValueError:
                result.update(package_state="MANIFEST_INVALID", warning="Manifest asset resolves outside package root.")
                return result
            if not asset_path.is_file():
                result.update(package_state="PACKAGE_ASSET_MISSING", failing_asset=resource_path)
                return result
            if not isinstance(asset.get("size_bytes"), int) or asset_path.stat().st_size != asset["size_bytes"]:
                result.update(package_state="PACKAGE_ASSET_SIZE_MISMATCH", failing_asset=resource_path)
                return result
            expected_asset_hash = asset.get("sha256", "")
            if not isinstance(expected_asset_hash, str) or len(expected_asset_hash) != 64:
                result.update(package_state="MANIFEST_INVALID", warning="Manifest asset SHA-256 is missing or malformed.")
                return result
            asset_digest = hashlib.sha256()
            with asset_path.open("rb") as stream:
                for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                    asset_digest.update(chunk)
            if asset_digest.hexdigest().lower() != expected_asset_hash.lower():
                result.update(package_state="PACKAGE_ASSET_HASH_MISMATCH", failing_asset=resource_path)
                return result
        result.update(package_state="PACKAGE_INTEGRITY_OK", verified_asset_count=len(assets))
    except (OSError, UnicodeError, json.JSONDecodeError, AttributeError, TypeError) as exc:
        result.update(package_state="MANIFEST_INVALID", warning=str(exc))
    return result


def query_selected_runtime(registry_db: str, selected_runtime_id: int, userdata_base: str) -> dict:
    if selected_runtime_id <= 0:
        return {"status": "FAIL", "state": "NO_RUNTIME_SELECTED", "error": "No Runtime is selected in Content Editor settings."}
    db_path = Path(registry_db)
    if not db_path.is_file():
        return {"status": "FAIL", "state": "REGISTRY_NOT_FOUND", "error": "Runtime registry database was not found."}
    try:
        uri = db_path.resolve().as_uri() + "?mode=ro"
        connection = sqlite3.connect(uri, uri=True)
        connection.row_factory = sqlite3.Row
        try:
            row = connection.execute(
                "SELECT runtime_id, name, project_path, enabled FROM runtime_targets WHERE runtime_id=?",
                (selected_runtime_id,),
            ).fetchone()
        finally:
            connection.close()
    except (sqlite3.Error, OSError) as exc:
        return {"status": "FAIL", "state": "REGISTRY_READ_FAILED", "error": str(exc)}
    if row is None:
        return {"status": "FAIL", "state": "SELECTED_RUNTIME_NOT_REGISTERED", "selected_runtime_id": selected_runtime_id}
    if int(row["enabled"]) != 1:
        return {"status": "FAIL", "state": "SELECTED_RUNTIME_DISABLED", "selected_runtime_id": selected_runtime_id, "runtime_name": row["name"]}
    project_path = str(row["project_path"])
    project_file = Path(project_path) / "project.godot"
    app_name = ""
    if project_file.is_file():
        try:
            project_text = project_file.read_text(encoding="utf-8-sig")
            match = re.search(r'^config/name\s*=\s*"(.*)"\s*$', project_text, re.MULTILINE)
            if match:
                app_name = match.group(1)
        except (OSError, UnicodeError):
            pass
    if not app_name:
        return {"status": "FAIL", "state": "RUNTIME_APP_NAME_UNRESOLVED", "selected_runtime_id": selected_runtime_id, "runtime_name": row["name"], "project_root": normalize_project_root(project_path)}
    userdata_root = Path(userdata_base) / app_name
    result = query(project_path, str(userdata_root))
    result["selected_runtime_id"] = selected_runtime_id
    result["runtime_name"] = str(row["name"])
    result["userdata_root"] = str(userdata_root)
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-path", default="")
    parser.add_argument("--user-data-root", default="")
    parser.add_argument("--registry-db", default="")
    parser.add_argument("--selected-runtime-id", type=int, default=0)
    parser.add_argument("--userdata-base", default="")
    args = parser.parse_args()
    try:
        if args.registry_db:
            if not args.userdata_base:
                parser.error("--userdata-base is required with --registry-db")
            result = query_selected_runtime(args.registry_db, args.selected_runtime_id, args.userdata_base)
        else:
            if not args.project_path or not args.user_data_root:
                parser.error("--project-path and --user-data-root are required without --registry-db")
            result = query(args.project_path, args.user_data_root)
        print(json.dumps(result, ensure_ascii=False))
        return 0 if result.get("status") == "PASS" else 2
    except Exception as exc:
        print(json.dumps({"status": "FAIL", "state": "QUERY_ERROR", "error": str(exc)}, ensure_ascii=False))
        return 2


if __name__ == "__main__":
    sys.exit(main())
