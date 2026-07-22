"""
Tests for Dashboard REST API and Handler (v2.1)
"""
import unittest
import os
import tempfile
import json
import urllib.request
import threading
from forge.dashboard.app import create_server
from forge.executors.asset_database import AssetDatabaseManager


class TestDashboardServer(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.db_path = os.path.join(self.temp_dir.name, "assets.json")
        db = AssetDatabaseManager(self.db_path)
        db.register_asset("EX-DASH-001", "Dashboard Test Weapon", "mesh", tags=["weapon", "test"])

        self.server = create_server("127.0.0.1", 0, db_path=self.db_path)
        self.port = self.server.server_address[1]
        self.server_thread = threading.Thread(target=self.server.serve_forever)
        self.server_thread.daemon = True
        self.server_thread.start()

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.temp_dir.cleanup()

    def test_api_status(self):
        url = f"http://127.0.0.1:{self.port}/api/pipeline/status"
        req = urllib.request.urlopen(url)
        self.assertEqual(req.status, 200)
        data = json.loads(req.read().decode("utf-8"))
        self.assertEqual(data["status"], "IDLE")
        self.assertIn("FBXExporter", data["supported_executors"])

    def test_api_assets(self):
        url = f"http://127.0.0.1:{self.port}/api/assets"
        req = urllib.request.urlopen(url)
        self.assertEqual(req.status, 200)
        data = json.loads(req.read().decode("utf-8"))
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["assets"][0]["asset_id"], "EX-DASH-001")


if __name__ == "__main__":
    unittest.main()
