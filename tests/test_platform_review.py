import unittest
import os
import sys
import json
import tempfile
import shutil

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.review.platform_review_engine import run_platform_review


class TestPlatformReview(unittest.TestCase):
    def test_run_platform_review_returns_string(self):
        """Platform review should return a markdown scorecard string."""
        result = run_platform_review()
        self.assertIsInstance(result, str)
        self.assertIn("Total Score", result)
        self.assertIn("Schema Integrity", result)
        self.assertIn("Modular Decoupling", result)
        self.assertIn("Code Quality", result)
        self.assertIn("Doc Integrity", result)

    def test_scorecard_file_created(self):
        """Platform review should create scorecard_Atlas_Platform.md."""
        run_platform_review()
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        scorecard_path = os.path.join(base_dir, "core", "review", "scorecard_Atlas_Platform.md")
        self.assertTrue(os.path.exists(scorecard_path))

    def test_run_review_engine_uses_active_project_for_platform_review(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = tmpdir
            state = {
                "platform_version": "1.0",
                "mode": "idle",
                "active_project": "Atlas",
                "current_phase": "Maintenance",
                "task_states": []
            }
            with open(os.path.join(base_dir, "ATLAS_STATE.json"), "w", encoding="utf-8") as f:
                json.dump(state, f)

            from core.review.review_engine import run_review_engine
            result = run_review_engine(asset_name=None, base_dir=base_dir)
            self.assertIsInstance(result, str)
            self.assertIn("Atlas Platform Review", result)


if __name__ == "__main__":
    unittest.main()
