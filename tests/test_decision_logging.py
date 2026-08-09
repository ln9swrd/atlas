import os
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.append(str(REPO_ROOT))

from tools.atlas_runner import build_start_report, get_repo_root


class DecisionLoggingTests(unittest.TestCase):
    def test_decision_is_logged_to_event_stream(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            repo_root = Path(tmpdir)
            os.makedirs(repo_root / "logs", exist_ok=True)
            os.makedirs(repo_root / "projects" / "exelion" / "sprints", exist_ok=True)
            (repo_root / "ENVIRONMENTS.md").write_text(
                "# Environments\n\n"
                "## DEV_HOME\n"
                "- role: Home Development\n"
                "- capabilities: blender, unreal engine, gpu, ai models\n"
                "- limitations: none\n",
                encoding="utf-8",
            )
            (repo_root / "core" / "execution").mkdir(parents=True, exist_ok=True)
            (repo_root / "core" / "config").mkdir(parents=True, exist_ok=True)
            (repo_root / "core" / "workflow").mkdir(parents=True, exist_ok=True)
            (repo_root / "core" / "execution" / "atlas_backlog.json").write_text("[]", encoding="utf-8")
            (repo_root / "core" / "config" / "project_lifecycle.json").write_text("{}", encoding="utf-8")
            (repo_root / "projects" / "exelion" / "backlog.json").write_text("[]", encoding="utf-8")
            (repo_root / "projects" / "exelion" / "sprints" / "Sprint-001.md").write_text("# Sprint-001\n", encoding="utf-8")
            (repo_root / "logs" / "atlas_events.jsonl").write_text("", encoding="utf-8")

            report = build_start_report(repo_root, environment_id="DEV_HOME", project_name="Exelion")
            self.assertEqual(report["decision"]["status"], "approved")

            with open(repo_root / "logs" / "atlas_events.jsonl", "r", encoding="utf-8") as handle:
                lines = [line.strip() for line in handle if line.strip()]

            self.assertTrue(any("decision.generated" in line for line in lines))


if __name__ == "__main__":
    unittest.main()
