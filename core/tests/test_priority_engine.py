import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.append(str(REPO_ROOT / "execution"))
import priority_engine


class PriorityEngineLifecycleTests(unittest.TestCase):
    def test_maintenance_projects_are_skipped(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            (base_dir / "core" / "execution").mkdir(parents=True, exist_ok=True)
            (base_dir / "core" / "config").mkdir(parents=True, exist_ok=True)
            (base_dir / "projects" / "exelion").mkdir(parents=True, exist_ok=True)

            (base_dir / "core" / "execution" / "atlas_backlog.json").write_text(
                json.dumps([
                    {
                        "id": "AT-001",
                        "description": "Atlas maintenance task",
                        "target_stage": "Core - Maintenance",
                        "projected_gain": 4.0,
                        "est_time": 60,
                        "focus_area": "maintenance"
                    }
                ]),
                encoding="utf-8"
            )
            (base_dir / "projects" / "exelion" / "backlog.json").write_text(
                json.dumps([
                    {
                        "id": "EX-001",
                        "description": "Exelion active task",
                        "target_stage": "Blender - 모델링",
                        "projected_gain": 8.0,
                        "est_time": 120,
                        "focus_area": "modeling"
                    }
                ]),
                encoding="utf-8"
            )
            (base_dir / "core" / "config" / "project_lifecycle.json").write_text(
                json.dumps({
                    "Atlas": {"status": "maintenance"},
                    "Sera": {"status": "maintenance"},
                    "Exelion": {"status": "active"}
                }),
                encoding="utf-8"
            )

            backlog_files = priority_engine.collect_backlog_files(base_dir, lifecycle_path=base_dir / "core" / "config" / "project_lifecycle.json")

            self.assertEqual(list(backlog_files.keys()), ["Exelion"])


if __name__ == "__main__":
    unittest.main()
