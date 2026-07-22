"""
Tests for PhantomStealthMechImporter (EX-BRAVE-037)
"""
import unittest
import os
from projects.excelion.src.pipeline.mech_importer import PhantomStealthMechImporter


class TestPhantomStealthMechImporter(unittest.TestCase):

    def setUp(self):
        self.spec_file = os.path.join(
            os.path.dirname(__file__), "..", "assets", "models", "phantom_stealth_mech.json"
        )
        self.importer = PhantomStealthMechImporter(spec_path=self.spec_file)

    def test_load_and_validate(self):
        result = self.importer.process_import()
        self.assertEqual(result["status"], "PASS")
        self.assertEqual(result["asset_id"], "EX-MECH-004")
        self.assertEqual(result["total_bones"], 15)
        self.assertEqual(result["imported_sockets_count"], 3)
        self.assertEqual(len(result["errors"]), 0)


if __name__ == "__main__":
    unittest.main()
