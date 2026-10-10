import hashlib
import importlib.util
import json
import sqlite3
import tempfile
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / "tools" / "runtime_config_status.py"
spec = importlib.util.spec_from_file_location("runtime_config_status", MODULE_PATH)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class RuntimeConfigStatusTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.project = self.root / "RuntimeA"
        self.project.mkdir()
        (self.project / "project.godot").write_text("config_version=5\nconfig/name=\"RuntimeA\"\n", encoding="utf-8")
        self.user_data = self.root / "userdata"
        self.user_data.mkdir()
        normalized = module.normalize_project_root(str(self.project))
        self.identity = hashlib.sha256(normalized.encode("utf-8")).hexdigest()
        self.config = self.user_data / f"runtime_content_package_{self.identity}.json"
    def tearDown(self):
        self.temp.cleanup()
    def test_missing_config_is_built_in_and_read_only(self):
        before = sorted(p.name for p in self.user_data.iterdir())
        result = module.query(str(self.project), str(self.user_data))
        after = sorted(p.name for p in self.user_data.iterdir())
        self.assertEqual(result["config_state"], "BUILT_IN_CONTENT_CONFIGURED")
        self.assertEqual(before, after)
    def test_valid_config_reports_next_launch_and_package_hash(self):
        package = self.root / "package"
        (package / "content").mkdir(parents=True)
        db = package / "content" / "menos.sqlite"
        db.write_bytes(b"test-db")
        (package / "manifest.json").write_text(json.dumps({"database": {"sha256": hashlib.sha256(b"test-db").hexdigest()}}), encoding="utf-8")
        self.config.write_text(json.dumps({"package_root": str(package)}), encoding="utf-8")
        result = module.query(str(self.project), str(self.user_data))
        self.assertEqual(result["config_state"], "PACKAGE_CONFIGURED_FOR_NEXT_LAUNCH")
        self.assertEqual(result["package_state"], "PACKAGE_INTEGRITY_OK")
        self.assertEqual(result["verified_asset_count"], 0)
    def test_missing_package_files_are_distinguished(self):
        self.config.write_text(json.dumps({"package_root": str(self.root / "missing_package")}), encoding="utf-8")
        result = module.query(str(self.project), str(self.user_data))
        self.assertEqual(result["package_state"], "PACKAGE_FILES_MISSING")
    def test_bad_json_is_invalid_config(self):
        self.config.write_text("{bad", encoding="utf-8")
        result = module.query(str(self.project), str(self.user_data))
        self.assertEqual(result["config_state"], "INVALID_CONFIG")
        self.assertEqual(result["status"], "FAIL")
    def test_database_hash_mismatch_is_detected(self):
        package = self.root / "package"
        (package / "content").mkdir(parents=True)
        (package / "content" / "menos.sqlite").write_bytes(b"actual")
        (package / "manifest.json").write_text(json.dumps({"database": {"sha256": "0" * 64}}), encoding="utf-8")
        self.config.write_text(json.dumps({"package_root": str(package)}), encoding="utf-8")
        result = module.query(str(self.project), str(self.user_data))
        self.assertEqual(result["package_state"], "DATABASE_HASH_MISMATCH")
    def test_asset_hash_mismatch_is_detected(self):
        package = self.root / "package_assets"
        (package / "content").mkdir(parents=True)
        (package / "content" / "menos.sqlite").write_bytes(b"db")
        (package / "res" / "sprites").mkdir(parents=True)
        asset = package / "res" / "sprites" / "hero.png"
        asset.write_bytes(b"actual asset")
        manifest = {"database": {"sha256": hashlib.sha256(b"db").hexdigest()},
                    "assets": [{"path": "res://res/sprites/hero.png", "size_bytes": len(b"actual asset"), "sha256": "0" * 64}]}
        (package / "manifest.json").write_text(json.dumps(manifest), encoding="utf-8")
        self.config.write_text(json.dumps({"package_root": str(package)}), encoding="utf-8")
        result = module.query(str(self.project), str(self.user_data))
        self.assertEqual(result["package_state"], "PACKAGE_ASSET_HASH_MISMATCH")

    def test_selected_runtime_lookup_uses_read_only_registry(self):
        registry = self.root / "runtime_registry.sqlite"
        connection = sqlite3.connect(registry)
        connection.execute("CREATE TABLE runtime_targets (runtime_id INTEGER PRIMARY KEY, name TEXT, project_path TEXT, enabled INTEGER)")
        connection.execute("INSERT INTO runtime_targets VALUES (2, 'Fixture Runtime', ?, 1)", (str(self.project),))
        connection.commit()
        connection.close()
        before = hashlib.sha256(registry.read_bytes()).hexdigest()
        result = module.query_selected_runtime(str(registry), 2, str(self.root / "godot_userdata"))
        after = hashlib.sha256(registry.read_bytes()).hexdigest()
        self.assertEqual(result["status"], "PASS")
        self.assertEqual(result["runtime_name"], "Fixture Runtime")
        self.assertEqual(result["config_state"], "BUILT_IN_CONTENT_CONFIGURED")
        self.assertEqual(before, after)

    def test_selected_runtime_lookup_reports_missing_selection(self):
        registry = self.root / "runtime_registry.sqlite"
        connection = sqlite3.connect(registry)
        connection.execute("CREATE TABLE runtime_targets (runtime_id INTEGER PRIMARY KEY, name TEXT, project_path TEXT, enabled INTEGER)")
        connection.commit()
        connection.close()
        result = module.query_selected_runtime(str(registry), 99, str(self.root / "godot_userdata"))
        self.assertEqual(result["state"], "SELECTED_RUNTIME_NOT_REGISTERED")

    def test_different_runtime_paths_have_different_configs(self):
        other = self.root / "RuntimeB"
        other.mkdir()
        (other / "project.godot").write_text("config_version=5\nconfig/name=\"RuntimeA\"\n", encoding="utf-8")
        a = module.query(str(self.project), str(self.user_data))
        b = module.query(str(other), str(self.user_data))
        self.assertNotEqual(a["runtime_identity"], b["runtime_identity"])
        self.assertNotEqual(a["config_path"], b["config_path"])

if __name__ == "__main__":
    unittest.main()
