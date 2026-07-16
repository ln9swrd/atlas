import json
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

import tools.atlas_runner as atlas_runner


class AtlasRunnerMVPTests(unittest.TestCase):
    def test_build_start_report_reads_sprint_and_top_five_tasks(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            for relpath in [
                "core/execution",
                "core/config",
                "core/workflow",
                "projects/exelion/sprints",
                "projects/exelion/goals",
                "logs",
            ]:
                (base_dir / relpath).mkdir(parents=True, exist_ok=True)

            (base_dir / "core" / "execution" / "README.md").write_text(
                "# Execution\n\n## 2. Today's Recommended Tasks\n\n## 3. Execution Log\n",
                encoding="utf-8",
            )
            (base_dir / "core" / "execution" / "atlas_backlog.json").write_text(
                json.dumps([
                    {
                        "id": "AT-001",
                        "description": "Atlas maintenance task",
                        "target_stage": "Core - Maintenance",
                        "projected_gain": 1.0,
                        "est_time": 30,
                        "focus_area": "maintenance",
                    }
                ]),
                encoding="utf-8",
            )
            (base_dir / "projects" / "exelion" / "backlog.json").write_text(
                json.dumps([
                    {
                        "id": "EX-001",
                        "description": "Brave 기본 프레임 제작",
                        "target_stage": "Blender - 모델링",
                        "projected_gain": 8.0,
                        "est_time": 90,
                        "focus_area": "modeling",
                    },
                    {
                        "id": "EX-002",
                        "description": "Brave 기본 프레임 UV 매핑",
                        "target_stage": "Blender - UV",
                        "projected_gain": 7.0,
                        "est_time": 60,
                        "focus_area": "uv",
                    },
                    {
                        "id": "EX-003",
                        "description": "Brave 외장 장갑 제작",
                        "target_stage": "Blender - 모델링",
                        "projected_gain": 6.0,
                        "est_time": 80,
                        "focus_area": "modeling",
                    },
                    {
                        "id": "EX-004",
                        "description": "Unreal 임포트 및 셋업",
                        "target_stage": "Unreal - Import",
                        "projected_gain": 5.0,
                        "est_time": 50,
                        "focus_area": "unreal",
                    },
                    {
                        "id": "EX-005",
                        "description": "플레이 테스트 준비",
                        "target_stage": "Unreal - Testing",
                        "projected_gain": 4.0,
                        "est_time": 40,
                        "focus_area": "testing",
                    },
                    {
                        "id": "EX-006",
                        "description": "문서 업데이트",
                        "target_stage": "Documentation",
                        "projected_gain": 3.0,
                        "est_time": 30,
                        "focus_area": "documentation",
                    },
                ]),
                encoding="utf-8",
            )
            (base_dir / "core" / "config" / "agent_registry.json").write_text(
                json.dumps([
                    {"agent": "Antigravity", "capabilities": ["python", "automation"]},
                    {"agent": "Forge", "capabilities": ["modeling", "uv", "blender"]},
                ]),
                encoding="utf-8",
            )
            (base_dir / "core" / "config" / "project_lifecycle.json").write_text(
                json.dumps({"Exelion": {"status": "active"}, "Atlas": {"status": "active"}}),
                encoding="utf-8",
            )
            (base_dir / "core" / "workflow" / "bottleneck_analysis.md").write_text(
                "| **Blender - 모델링** | 5 | 4 | 4 | 4 | 2 | `19` | **`76` 점** |\n"
                "| **Blender - UV** | 4 | 3 | 3 | 3 | 2 | `15` | **`60` 점** |\n"
                "| **Unreal - Import** | 3 | 4 | 4 | 3 | 2 | `16` | **`52` 점** |\n"
                "| **Unreal - Testing** | 2 | 3 | 3 | 2 | 2 | `12` | **`44` 점** |\n"
                "| **Documentation** | 2 | 2 | 2 | 2 | 2 | `10` | **`40` 점** |\n",
                encoding="utf-8",
            )
            (base_dir / "ENVIRONMENTS.md").write_text(
                "# Environments\n\n## DEV_HOME\nCapabilities:\n- Unreal Engine\n- Blender\n",
                encoding="utf-8",
            )
            (base_dir / "projects" / "exelion" / "sprints" / "Sprint-001-tasklist.md").write_text(
                "# Sprint-001 Task List\n\n## Priority Tasks\n"
                "1. EX-BRAVE-001 — Brave 기본 프레임 제작\n"
                "2. EX-BRAVE-002 — Brave 기본 프레임 UV 매핑\n"
                "3. EX-BRAVE-003 — Brave 외장 장갑 제작\n"
                "4. EX-BRAVE-004 — Unreal 임포트 및 셋업\n"
                "5. EX-BRAVE-005 — 플레이 테스트 준비\n",
                encoding="utf-8",
            )
            (base_dir / "projects" / "exelion" / "goals" / "EX-GOAL-001.md").write_text(
                "# EX-GOAL-001\n\n## Sprint\n- Sprint-001\n",
                encoding="utf-8",
            )

            report = atlas_runner.build_start_report(base_dir, environment_id="DEV_HOME", project_name="Exelion")

            self.assertEqual(report["environment"], "DEV_HOME")
            self.assertEqual(report["current_sprint"], "Sprint-001")
            self.assertEqual(len(report["recommended_tasks"]), 5)
            self.assertIn("Brave", report["recommended_tasks"][0]["description"])

    def test_next_command_marks_first_task_in_progress_and_logs_event(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            for relpath in [
                "core/execution",
                "core/config",
                "core/workflow",
                "projects/exelion/sprints",
                "projects/exelion/goals",
                "logs",
            ]:
                (base_dir / relpath).mkdir(parents=True, exist_ok=True)

            (base_dir / "core" / "execution" / "README.md").write_text("# Execution\n", encoding="utf-8")
            (base_dir / "core" / "execution" / "atlas_backlog.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "projects" / "exelion" / "backlog.json").write_text(
                json.dumps([
                    {"id": "EX-001", "description": "Brave 기본 프레임 제작", "target_stage": "Blender - 모델링", "projected_gain": 8.0, "est_time": 90, "focus_area": "modeling"},
                    {"id": "EX-002", "description": "Brave UV 매핑", "target_stage": "Blender - UV", "projected_gain": 7.0, "est_time": 60, "focus_area": "uv"},
                ]),
                encoding="utf-8",
            )
            (base_dir / "core" / "config" / "agent_registry.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "core" / "config" / "project_lifecycle.json").write_text(json.dumps({"Exelion": {"status": "active"}}), encoding="utf-8")
            (base_dir / "core" / "workflow" / "bottleneck_analysis.md").write_text("| **Blender - 모델링** | 5 | 4 | 4 | 4 | 2 | `19` | **`76` 점** |\n", encoding="utf-8")
            (base_dir / "ENVIRONMENTS.md").write_text("# Environments\n\n## DEV_HOME\nCapabilities:\n- Blender\n", encoding="utf-8")
            (base_dir / "projects" / "exelion" / "sprints" / "Sprint-001-tasklist.md").write_text("1. EX-BRAVE-001 — Brave 기본 프레임 제작\n2. EX-BRAVE-002 — Brave UV 매핑\n", encoding="utf-8")
            (base_dir / "projects" / "exelion" / "goals" / "EX-GOAL-001.md").write_text("# EX-GOAL-001\n\n## Sprint\n- Sprint-001\n", encoding="utf-8")

            report = atlas_runner.build_start_report(base_dir, environment_id="DEV_HOME", project_name="Exelion")
            atlas_runner.initialize_task_state(base_dir, report)
            result = atlas_runner.advance_task(base_dir, command="next")

            self.assertEqual(result["status"], "IN_PROGRESS")
            state_data = json.loads((base_dir / "ATLAS_STATE.json").read_text(encoding="utf-8"))
            self.assertEqual(state_data["task_states"][0]["status"], "IN_PROGRESS")
            self.assertEqual(state_data["current_task"], state_data["task_states"][0]["id"])
            log_lines = (base_dir / "logs" / "atlas_events.jsonl").read_text(encoding="utf-8").splitlines()
            self.assertTrue(any("task.started" in line for line in log_lines))


if __name__ == "__main__":
    unittest.main()
