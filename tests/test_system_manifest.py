"""
Tests for SystemManifestRegistry (v2.0 Enterprise)
"""
import unittest
import os
import tempfile
from core.registry.manifest import SystemManifestRegistry, SystemManifest


class TestSystemManifestRegistry(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.registry = SystemManifestRegistry(base_dir=self.temp_dir.name)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_generate_and_validate(self):
        manifest = self.registry.generate_manifest()
        self.assertEqual(manifest.version, "2.0.0")
        self.assertTrue(self.registry.validate_manifest(manifest))

    def test_persistence(self):
        manifest_file = os.path.join(self.temp_dir.name, "system_manifest.json")
        self.registry.save_manifest(manifest_file)
        self.assertTrue(os.path.exists(manifest_file))

        loaded = self.registry.load_manifest(manifest_file)
        self.assertIsNotNone(loaded)
        self.assertEqual(loaded.platform_name, "Atlas DevOS Enterprise")


if __name__ == "__main__":
    unittest.main()
