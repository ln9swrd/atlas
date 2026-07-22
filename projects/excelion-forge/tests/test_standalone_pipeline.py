"""
Tests for StandalonePipelineOrchestrator and CLI (v1.0)
"""
import unittest
import os
import tempfile
import sys
from unittest.mock import patch
from forge.executors.standalone_pipeline import StandalonePipelineOrchestrator
from forge.cli import main as cli_main


class TestStandalonePipeline(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.export_dir = os.path.join(self.temp_dir.name, "exports")
        self.db_path = os.path.join(self.temp_dir.name, "assets.json")

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_run_pipeline_success(self):
        orchestrator = StandalonePipelineOrchestrator(db_path=self.db_path)
        context = {
            "asset_id": "EX-TEST-001",
            "asset_name": "Test Mecha Primary Rifle",
            "asset_type": "mesh",
            "export_dir": self.export_dir,
            "filename": "rifle.fbx",
            "tags": ["mecha", "weapon"],
            "skip_validation": True,
        }

        report = orchestrator.run_pipeline(context)
        self.assertEqual(report["status"], "SUCCESS")
        self.assertTrue(os.path.exists(report["export_file"]))

        # Verify DB registration
        registered = orchestrator.db.get_asset("EX-TEST-001")
        self.assertIsNotNone(registered)
        self.assertEqual(registered.name, "Test Mecha Primary Rifle")
        self.assertIn("weapon", registered.tags)

    def test_cli_execution(self):
        test_args = [
            "cli.py",
            "--asset-id", "EX-CLI-001",
            "--asset-name", "CLI Rifle Test",
            "--asset-type", "mesh",
            "--export-dir", self.export_dir,
            "--db-path", self.db_path,
            "--skip-validation",
            "--json-output",
        ]
        with patch.object(sys, "argv", test_args):
            with patch("sys.exit") as mock_exit:
                cli_main()
                mock_exit.assert_not_called()

        self.assertTrue(os.path.exists(os.path.join(self.export_dir, "EX-CLI-001.fbx")))


if __name__ == "__main__":
    unittest.main()
