"""
Tests for CloudDriverExecutor (Excelion Forge v3.0)
"""
import unittest
from forge.executors.cloud_driver import CloudDriverExecutor


class TestCloudDriverExecutor(unittest.TestCase):

    def setUp(self):
        self.driver = CloudDriverExecutor()

    def test_dispatch_cloud_export(self):
        res = self.driver.dispatch_cloud_export(
            asset_id="EX-TEST-999",
            asset_name="Test Cloud Weapon",
            asset_type="mesh",
        )
        self.assertEqual(res["status"], "SUCCESS")
        self.assertEqual(res["asset_id"], "EX-TEST-999")
        self.assertEqual(res["cloud_build"]["status"], "QUEUED")


if __name__ == "__main__":
    unittest.main()
