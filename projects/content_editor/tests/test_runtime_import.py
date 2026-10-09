import importlib.util
import os
import shutil
import sqlite3
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNTIME_DB = Path(os.environ.get("MENOS_RUNTIME_DB", ""))
SPEC = importlib.util.spec_from_file_location("import_runtime_content", ROOT / "tools" / "import_runtime_content.py")
IMPORTER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(IMPORTER)

@unittest.skipUnless(RUNTIME_DB.is_file(), "Set MENOS_RUNTIME_DB to the Runtime project's content/menos.sqlite")
class RuntimeImportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="menos_runtime_import_test_")
        self.root = Path(self.temp.name)
        self.authoring_db = self.root / "data" / "content_editor.sqlite"
        self.authoring_db.parent.mkdir(parents=True)
        shutil.copy2(ROOT / "data" / "content_editor.sqlite", self.authoring_db)
        self.maps_dir = self.root / "data" / "maps"
        shutil.copytree(ROOT / "data" / "maps", self.maps_dir)

    def tearDown(self):
        self.temp.cleanup()

    def test_preview_is_read_only(self):
        source_before = IMPORTER.sha256_file(RUNTIME_DB)
        target_before = IMPORTER.sha256_file(self.authoring_db)
        report = IMPORTER.run_import(RUNTIME_DB, self.authoring_db, self.maps_dir, False)
        self.assertEqual(report["mode"], "PREVIEW ONLY")
        self.assertEqual(report["maps_to_import"]["northbridge_sector_01"]["objects"], 309)
        self.assertEqual(IMPORTER.sha256_file(RUNTIME_DB), source_before)
        self.assertEqual(IMPORTER.sha256_file(self.authoring_db), target_before)

    def test_apply_backs_up_and_imports_to_temporary_target(self):
        source_hash = IMPORTER.sha256_file(RUNTIME_DB)
        report = IMPORTER.run_import(RUNTIME_DB, self.authoring_db, self.maps_dir, True)
        self.assertEqual(report["result"], "PASS")
        self.assertEqual(IMPORTER.sha256_file(self.authoring_db), source_hash)
        backup = Path(report["backup_directory"])
        self.assertTrue((backup / "menos.sqlite.before").is_file())
        self.assertTrue((backup / "maps_before").is_dir())
        self.assertEqual(len(__import__("json").loads((self.maps_dir / "northbridge_sector_01.json").read_text(encoding="utf-8"))["objects"]), 309)
        self.assertEqual(IMPORTER.sha256_file(RUNTIME_DB), source_hash)

    def test_schema_mismatch_rejected_without_target_changes(self):
        bad_source = self.root / "bad.sqlite"
        shutil.copy2(RUNTIME_DB, bad_source)
        db = sqlite3.connect(bad_source)
        db.execute("DROP TABLE stage_03")
        db.commit()
        db.close()
        before = IMPORTER.sha256_file(self.authoring_db)
        with self.assertRaises(IMPORTER.ImportErrorSafe):
            IMPORTER.run_import(bad_source, self.authoring_db, self.maps_dir, True)
        self.assertEqual(IMPORTER.sha256_file(self.authoring_db), before)

    def test_source_and_target_cannot_be_same_file(self):
        with self.assertRaises(IMPORTER.ImportErrorSafe):
            IMPORTER.run_import(self.authoring_db, self.authoring_db, self.maps_dir, True)

if __name__ == "__main__":
    unittest.main()
