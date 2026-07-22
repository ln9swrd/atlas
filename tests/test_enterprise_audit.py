"""
Tests for EnterpriseAuditEngine (v2.0 Enterprise)
"""
import unittest
import os
import tempfile
from core.review.enterprise_audit import EnterpriseAuditEngine


class TestEnterpriseAuditEngine(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.engine = EnterpriseAuditEngine(base_dir=self.temp_dir.name)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_run_audit(self):
        report = self.engine.run_audit()
        self.assertEqual(report["status"], "PASS")
        self.assertEqual(report["total_score"], 100.0)
        self.assertIn("ManifestIntegrity", report["score_breakdown"])

    def test_export_scorecard(self):
        output_file = os.path.join(self.temp_dir.name, "scorecard_v2.md")
        exported_path = self.engine.export_scorecard(output_file)
        self.assertTrue(os.path.exists(exported_path))
        with open(exported_path, "r", encoding="utf-8") as f:
            content = f.read()
        self.assertIn("Atlas DevOS v2.0 Enterprise Quality Scorecard", content)


if __name__ == "__main__":
    unittest.main()
