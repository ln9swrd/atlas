"""
Tests for AssetDatabaseManager (v0.5)
"""
import unittest
import os
import tempfile
from forge.executors.asset_database import AssetDatabaseManager, AssetMetadata


class TestAssetDatabaseManager(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.db_file = os.path.join(self.temp_dir.name, "assets.json")
        self.dummy_asset_path = os.path.join(self.temp_dir.name, "dummy_model.fbx")
        with open(self.dummy_asset_path, "w") as f:
            f.write("FBX Dummy Content v1")

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_register_and_get_asset(self):
        db = AssetDatabaseManager(self.db_file)
        metadata = db.register_asset(
            asset_id="EX-MODEL-001",
            name="Primary Weapon",
            asset_type="mesh",
            file_path=self.dummy_asset_path,
            tags=["weapon", "rifle"],
        )
        self.assertEqual(metadata.asset_id, "EX-MODEL-001")
        self.assertEqual(metadata.name, "Primary Weapon")
        self.assertTrue(len(metadata.file_hash) > 0)

        retrieved = db.get_asset("EX-MODEL-001")
        self.assertIsNotNone(retrieved)
        self.assertEqual(retrieved.name, "Primary Weapon")

    def test_persistence(self):
        db1 = AssetDatabaseManager(self.db_file)
        db1.register_asset("EX-RIG-001", "Brave Skeleton", "rig", tags=["character"])

        db2 = AssetDatabaseManager(self.db_file)
        asset = db2.get_asset("EX-RIG-001")
        self.assertIsNotNone(asset)
        self.assertEqual(asset.name, "Brave Skeleton")
        self.assertIn("character", asset.tags)

    def test_search_by_tag_and_type(self):
        db = AssetDatabaseManager()
        db.register_asset("A1", "Weapon Rifle", "mesh", tags=["weapon"])
        db.register_asset("A2", "Weapon Sword", "mesh", tags=["weapon", "melee"])
        db.register_asset("A3", "Idle Motion", "animation", tags=["anim"])

        weapons = db.search_by_tag("weapon")
        self.assertEqual(len(weapons), 2)

        anims = db.search_by_type("animation")
        self.assertEqual(len(anims), 1)
        self.assertEqual(anims[0].name, "Idle Motion")

    def test_verify_integrity(self):
        db = AssetDatabaseManager()
        db.register_asset("A1", "File Asset", "mesh", file_path=self.dummy_asset_path)
        self.assertTrue(db.verify_integrity("A1"))

        # Modify file content
        with open(self.dummy_asset_path, "w") as f:
            f.write("FBX Modified Content v2")

        self.assertFalse(db.verify_integrity("A1"))

        # Update version and file
        db.update_version("A1", "1.1.0", file_path=self.dummy_asset_path)
        self.assertTrue(db.verify_integrity("A1"))


if __name__ == "__main__":
    unittest.main()
