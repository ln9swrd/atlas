"""
Tests for UnrealLiveSyncExecutor (v1.1)
"""
import unittest
import os
import tempfile
from forge.executors.ue_live_sync import UnrealLiveSyncExecutor


class TestUnrealLiveSyncExecutor(unittest.TestCase):

    def setUp(self):
        self.executor = UnrealLiveSyncExecutor()

    def test_validate(self):
        self.assertTrue(self.executor.validate({"export_file": "sample.fbx"}))
        self.assertTrue(self.executor.validate({"asset_id": "EX-001"}))
        self.assertFalse(self.executor.validate({}))

    def test_payload_generation(self):
        context = {
            "export_file": "/path/to/mech.fbx",
            "asset_id": "EX-MECH-001",
            "destination_path": "/Game/Excelion/Mechs",
        }
        payload = self.executor.generate_import_payload(context)
        self.assertEqual(payload["functionName"], "ImportAsset")
        self.assertEqual(payload["parameters"]["AssetId"], "EX-MECH-001")
        self.assertEqual(payload["parameters"]["DestinationPath"], "/Game/Excelion/Mechs")

    def test_execute(self):
        context = {
            "export_file": "test_weapon.fbx",
            "asset_id": "EX-WEAPON-001",
            "dry_run": True,
        }
        result = self.executor.execute(context)
        self.assertTrue(result["success"])
        self.assertEqual(result["status"], "PASS")
        self.assertTrue(result["sync_details"]["synced"])


if __name__ == "__main__":
    unittest.main()
