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
                "projects/excelion/sprints",
                "projects/excelion/goals",
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
            (base_dir / "projects" / "excelion" / "backlog.json").write_text(
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
                json.dumps({"Excelion": {"status": "active"}, "Atlas": {"status": "active"}}),
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
            (base_dir / "projects" / "excelion" / "sprints" / "Sprint-001-tasklist.md").write_text(
                "# Sprint-001 Task List\n\n## Priority Tasks\n"
                "1. EX-BRAVE-001 — Brave 기본 프레임 제작\n"
                "2. EX-BRAVE-002 — Brave 기본 프레임 UV 매핑\n"
                "3. EX-BRAVE-003 — Brave 외장 장갑 제작\n"
                "4. EX-BRAVE-004 — Unreal 임포트 및 셋업\n"
                "5. EX-BRAVE-005 — 플레이 테스트 준비\n",
                encoding="utf-8",
            )
            (base_dir / "projects" / "excelion" / "goals" / "EX-GOAL-001.md").write_text(
                "# EX-GOAL-001\n\n## Sprint\n- Sprint-001\n",
                encoding="utf-8",
            )

            report = atlas_runner.build_start_report(base_dir, environment_id="DEV_HOME", project_name="Excelion")

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
                "projects/excelion/sprints",
                "projects/excelion/goals",
                "logs",
            ]:
                (base_dir / relpath).mkdir(parents=True, exist_ok=True)

            (base_dir / "core" / "execution" / "README.md").write_text("# Execution\n", encoding="utf-8")
            (base_dir / "core" / "execution" / "atlas_backlog.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "projects" / "excelion" / "backlog.json").write_text(
                json.dumps([
                    {"id": "EX-001", "description": "Brave 기본 프레임 제작", "target_stage": "Blender - 모델링", "projected_gain": 8.0, "est_time": 90, "focus_area": "modeling"},
                    {"id": "EX-002", "description": "Brave UV 매핑", "target_stage": "Blender - UV", "projected_gain": 7.0, "est_time": 60, "focus_area": "uv"},
                ]),
                encoding="utf-8",
            )
            (base_dir / "core" / "config" / "agent_registry.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "core" / "config" / "project_lifecycle.json").write_text(json.dumps({"Excelion": {"status": "active"}}), encoding="utf-8")
            (base_dir / "core" / "workflow" / "bottleneck_analysis.md").write_text("| **Blender - 모델링** | 5 | 4 | 4 | 4 | 2 | `19` | **`76` 점** |\n", encoding="utf-8")
            (base_dir / "ENVIRONMENTS.md").write_text("# Environments\n\n## DEV_HOME\nCapabilities:\n- Blender\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "sprints" / "Sprint-001-tasklist.md").write_text("1. EX-BRAVE-001 — Brave 기본 프레임 제작\n2. EX-BRAVE-002 — Brave UV 매핑\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "goals" / "EX-GOAL-001.md").write_text("# EX-GOAL-001\n\n## Sprint\n- Sprint-001\n", encoding="utf-8")

            report = atlas_runner.build_start_report(base_dir, environment_id="DEV_HOME", project_name="Excelion")
            atlas_runner.initialize_task_state(base_dir, report)
            result = atlas_runner.advance_task(base_dir, command="next")

            self.assertEqual(result["status"], "IN_PROGRESS")
            state_data = json.loads((base_dir / "ATLAS_STATE.json").read_text(encoding="utf-8"))
            self.assertEqual(state_data["task_states"][0]["status"], "IN_PROGRESS")
            self.assertEqual(state_data["current_task"], state_data["task_states"][0]["id"])
            log_lines = (base_dir / "logs" / "atlas_events.jsonl").read_text(encoding="utf-8").splitlines()
            self.assertTrue(any("task.started" in line for line in log_lines))

    def test_daily_cycle_advances_state_and_progress(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            for relpath in [
                "core/execution",
                "core/config",
                "core/workflow",
                "projects/excelion/sprints",
                "projects/excelion/goals",
                "logs",
            ]:
                (base_dir / relpath).mkdir(parents=True, exist_ok=True)

            (base_dir / "core" / "execution" / "README.md").write_text("# Execution\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "backlog.json").write_text(
                json.dumps([
                    {"id": "EX-001", "description": "Brave 기본 프레임 제작", "target_stage": "Blender - 모델링", "projected_gain": 8.0, "est_time": 90, "focus_area": "modeling"},
                    {"id": "EX-002", "description": "Brave UV 매핑", "target_stage": "Blender - UV", "projected_gain": 7.0, "est_time": 60, "focus_area": "uv"},
                    {"id": "EX-003", "description": "Brave 외장 장갑 제작", "target_stage": "Blender - 모델링", "projected_gain": 6.0, "est_time": 80, "focus_area": "modeling"},
                ]),
                encoding="utf-8",
            )
            (base_dir / "core" / "execution" / "atlas_backlog.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "core" / "config" / "agent_registry.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "core" / "config" / "project_lifecycle.json").write_text(json.dumps({"Excelion": {"status": "active"}}), encoding="utf-8")
            (base_dir / "core" / "workflow" / "bottleneck_analysis.md").write_text("| **Blender - 모델링** | 5 | 4 | 4 | 4 | 2 | `19` | **`76` 점** |\n", encoding="utf-8")
            (base_dir / "ENVIRONMENTS.md").write_text("# Environments\n\n## DEV_HOME\nCapabilities:\n- Blender\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "sprints" / "Sprint-001-tasklist.md").write_text("1. EX-BRAVE-001 — Brave 기본 프레임 제작\n2. EX-BRAVE-002 — Brave UV 매핑\n3. EX-BRAVE-003 — Brave 외장 장갑 제작\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "goals" / "EX-GOAL-001.md").write_text("# EX-GOAL-001\n\n## Sprint\n- Sprint-001\n", encoding="utf-8")

            report = atlas_runner.build_start_report(base_dir, environment_id="DEV_HOME", project_name="Excelion")
            atlas_runner.initialize_task_state(base_dir, report)

            first = atlas_runner.advance_task(base_dir, command="next")
            atlas_runner.complete_current_task(base_dir)
            second = atlas_runner.advance_task(base_dir, command="next")
            atlas_runner.complete_current_task(base_dir)
            third = atlas_runner.advance_task(base_dir, command="next")
            atlas_runner.complete_current_task(base_dir)

            state_data = json.loads((base_dir / "ATLAS_STATE.json").read_text(encoding="utf-8"))
            statuses = [task["status"] for task in state_data["task_states"]]
            self.assertEqual(statuses.count("DONE"), 3)
            self.assertEqual(first["status"], "IN_PROGRESS")
            self.assertEqual(second["status"], "IN_PROGRESS")
            self.assertEqual(third["status"], "IN_PROGRESS")
            self.assertGreaterEqual(state_data["task_states"][0].get("priority", 0), 1)
            log_lines = (base_dir / "logs" / "atlas_events.jsonl").read_text(encoding="utf-8").splitlines()
            self.assertTrue(any("task.completed" in line for line in log_lines))
            self.assertTrue(any("sprint.updated" in line for line in log_lines))

    def test_real_backlog_metadata_is_captured_in_task_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            for relpath in [
                "core/execution",
                "core/config",
                "core/workflow",
                "projects/excelion/sprints",
                "projects/excelion/goals",
                "logs",
            ]:
                (base_dir / relpath).mkdir(parents=True, exist_ok=True)

            (base_dir / "core" / "execution" / "README.md").write_text("# Execution\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "backlog.json").write_text(
                json.dumps([
                    {
                        "id": "EX-BRAVE-001",
                        "description": "Brave 기본 프레임 제작",
                        "target_stage": "Blender - 모델링",
                        "est_time": 120,
                        "projected_gain": 8.0,
                        "focus_area": "modeling",
                        "environment": "DEV_HOME",
                        "depends_on": ["EX-BRAVE-000"],
                    }
                ]),
                encoding="utf-8",
            )
            (base_dir / "core" / "execution" / "atlas_backlog.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "core" / "config" / "agent_registry.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "core" / "config" / "project_lifecycle.json").write_text(json.dumps({"Excelion": {"status": "active"}}), encoding="utf-8")
            (base_dir / "core" / "workflow" / "bottleneck_analysis.md").write_text("| **Blender - 모델링** | 5 | 4 | 4 | 4 | 2 | `19` | **`76` 점** |\n", encoding="utf-8")
            (base_dir / "ENVIRONMENTS.md").write_text("# Environments\n\n## DEV_HOME\nCapabilities:\n- Blender\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "sprints" / "Sprint-001-tasklist.md").write_text("1. EX-BRAVE-001 — Brave 기본 프레임 제작\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "goals" / "EX-GOAL-001.md").write_text("# EX-GOAL-001\n\n## Sprint\n- Sprint-001\n", encoding="utf-8")

            report = atlas_runner.build_start_report(
                base_dir,
                environment_id="DEV_HOME",
                project_name="Excelion",
                state={"task_states": [{"id": "EX-BRAVE-000", "status": "DONE"}]},
            )
            atlas_runner.initialize_task_state(base_dir, report)
            state_data = json.loads((base_dir / "ATLAS_STATE.json").read_text(encoding="utf-8"))
            task = state_data["task_states"][0]
            self.assertEqual(task["estimate"], 120)
            self.assertEqual(task["environment"], "DEV_HOME")
            self.assertEqual(task["depends_on"], ["EX-BRAVE-000"])

    def test_runtime_context_filters_tasks_by_environment_dependency_and_time(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            for relpath in [
                "core/execution",
                "core/config",
                "core/workflow",
                "projects/excelion/sprints",
                "projects/excelion/goals",
                "logs",
            ]:
                (base_dir / relpath).mkdir(parents=True, exist_ok=True)

            (base_dir / "core" / "execution" / "README.md").write_text("# Execution\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "backlog.json").write_text(
                json.dumps([
                    {
                        "id": "EX-001",
                        "description": "Home-only task",
                        "target_stage": "Blender - 모델링",
                        "projected_gain": 8.0,
                        "est_time": 45,
                        "focus_area": "modeling",
                        "environment": "DEV_HOME",
                    },
                    {
                        "id": "EX-002",
                        "description": "Office-only task",
                        "target_stage": "Blender - UV",
                        "projected_gain": 7.0,
                        "est_time": 30,
                        "focus_area": "uv",
                        "environment": "DEV_WORK",
                    },
                    {
                        "id": "EX-003",
                        "description": "Blocked by dependency",
                        "target_stage": "Blender - Export",
                        "projected_gain": 6.0,
                        "est_time": 20,
                        "focus_area": "materials",
                        "environment": "DEV_HOME",
                        "depends_on": ["EX-999"],
                    },
                    {
                        "id": "EX-004",
                        "description": "Too long for budget",
                        "target_stage": "Documentation",
                        "projected_gain": 4.0,
                        "est_time": 100,
                        "focus_area": "documentation",
                        "environment": "DEV_HOME",
                    },
                ]),
                encoding="utf-8",
            )
            (base_dir / "core" / "execution" / "atlas_backlog.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "core" / "config" / "agent_registry.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "core" / "config" / "project_lifecycle.json").write_text(json.dumps({"Excelion": {"status": "active"}}), encoding="utf-8")
            (base_dir / "core" / "workflow" / "bottleneck_analysis.md").write_text("| **Blender - 모델링** | 5 | 4 | 4 | 4 | 2 | `19` | **`76` 점** |\n", encoding="utf-8")
            (base_dir / "ENVIRONMENTS.md").write_text("# Environments\n\n## DEV_HOME\nCapabilities:\n- Blender\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "sprints" / "Sprint-001-tasklist.md").write_text("1. EX-001 — Home-only task\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "goals" / "EX-GOAL-001.md").write_text("# EX-GOAL-001\n\n## Sprint\n- Sprint-001\n", encoding="utf-8")

            report = atlas_runner.build_start_report(
                base_dir,
                environment_id="DEV_HOME",
                project_name="Excelion",
                runtime_overrides={"available_minutes": 60, "energy": "high"},
                state={"task_states": [{"id": "EX-001", "status": "DONE"}]},
            )
            ids = [task["id"] for task in report["recommended_tasks"]]
            self.assertIn("EX-001", ids)
            self.assertNotIn("EX-002", ids)
            self.assertNotIn("EX-003", ids)
            self.assertNotIn("EX-004", ids)

    def test_simulate_day_returns_recommendation_and_actual_selection(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            for relpath in [
                "core/execution",
                "core/config",
                "core/workflow",
                "projects/excelion/sprints",
                "projects/excelion/goals",
                "logs",
            ]:
                (base_dir / relpath).mkdir(parents=True, exist_ok=True)

            (base_dir / "core" / "execution" / "README.md").write_text("# Execution\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "backlog.json").write_text(
                json.dumps([
                    {"id": "EX-001", "description": "Task A", "target_stage": "Blender - 모델링", "projected_gain": 8.0, "est_time": 45, "focus_area": "modeling", "environment": "DEV_HOME"},
                    {"id": "EX-002", "description": "Task B", "target_stage": "Blender - UV", "projected_gain": 7.0, "est_time": 30, "focus_area": "uv", "environment": "DEV_HOME"},
                ]),
                encoding="utf-8",
            )
            (base_dir / "core" / "execution" / "atlas_backlog.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "core" / "config" / "agent_registry.json").write_text(json.dumps([]), encoding="utf-8")
            (base_dir / "core" / "config" / "project_lifecycle.json").write_text(json.dumps({"Excelion": {"status": "active"}}), encoding="utf-8")
            (base_dir / "core" / "workflow" / "bottleneck_analysis.md").write_text("| **Blender - 모델링** | 5 | 4 | 4 | 4 | 2 | `19` | **`76` 점** |\n", encoding="utf-8")
            (base_dir / "ENVIRONMENTS.md").write_text("# Environments\n\n## DEV_HOME\nCapabilities:\n- Blender\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "sprints" / "Sprint-001-tasklist.md").write_text("1. EX-001 — Task A\n2. EX-002 — Task B\n", encoding="utf-8")
            (base_dir / "projects" / "excelion" / "goals" / "EX-GOAL-001.md").write_text("# EX-GOAL-001\n\n## Sprint\n- Sprint-001\n", encoding="utf-8")

            simulation = atlas_runner.simulate_day(
                base_dir,
                environment_id="DEV_HOME",
                project_name="Excelion",
                runtime_overrides={"available_minutes": 60, "energy": "high"},
            )
            self.assertEqual(simulation["context"]["environment"], "DEV_HOME")
            self.assertIn("EX-001", simulation["recommended_ids"])
            self.assertEqual(simulation["actual_ids"], ["EX-001"])

    def test_sync_status_doc_writes_state_summary_into_project_status_document(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            (base_dir / "docs").mkdir(parents=True, exist_ok=True)
            (base_dir / "docs" / "PROJECT_STATUS.md").write_text("# Project Status\n\n## 1. 현재 상태\n\n- Repo: Atlas DevOS\n", encoding="utf-8")
            state = {
                "platform_version": "1.0",
                "mode": "development",
                "active_project": "Atlas",
                "current_sprint": "Sprint-001",
                "current_task": "EX-BRAVE-001",
                "last_review": "PASS",
                "task_states": []
            }
            (base_dir / "ATLAS_STATE.json").write_text(json.dumps(state), encoding="utf-8")

            atlas_runner.sync_status_doc(str(base_dir))
            content = (base_dir / "docs" / "PROJECT_STATUS.md").read_text(encoding="utf-8")
            self.assertIn("- Last Sync:", content)
            self.assertIn("- Project: `Atlas`", content)
            self.assertIn("- Mode: `development`", content)
            self.assertIn("- Current Sprint: `Sprint-001`", content)
            self.assertIn("- Current Task: `EX-BRAVE-001`", content)

    def test_log_feedback_writes_recommendation_record(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            (base_dir / "logs").mkdir(parents=True, exist_ok=True)

            record = atlas_runner.log_feedback(
                base_dir,
                date="2026-07-16",
                context={"environment": "office", "available_minutes": 120, "energy": "high"},
                recommended=["EX-102", "EX-087", "EX-091"],
                selected="EX-087",
                completed=True,
                duration=95,
                reason="manual_override",
                task="EX-214",
                recommendation_score=84,
                recommendation_reasons=["dependency satisfied", "environment matched", "estimate fits budget"],
                override_reason="urgent customer issue",
            )

            log_path = base_dir / "logs" / "feedback_log.jsonl"
            self.assertTrue(log_path.exists())
            saved = json.loads(log_path.read_text(encoding="utf-8").strip())
            self.assertEqual(saved["selected"], "EX-087")
            self.assertEqual(saved["reason"], "manual_override")
            self.assertEqual(saved["task"], "EX-214")
            self.assertEqual(saved["recommendation_score"], 84)
            self.assertEqual(saved["recommendation_reasons"], ["dependency satisfied", "environment matched", "estimate fits budget"])
            self.assertEqual(saved["override_reason"], "urgent customer issue")
            self.assertEqual(record["selected"], "EX-087")

    def test_replay_feedback_and_compare_replay(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            (base_dir / "logs").mkdir(parents=True, exist_ok=True)
            (base_dir / "logs" / "feedback_log.jsonl").write_text(
                json.dumps({
                    "date": "2026-07-09",
                    "selected": "EX-101",
                    "recommended_task": "EX-101",
                    "override_reason": "none",
                    "completed": True,
                }) + "\n",
                encoding="utf-8",
            )

            replay = atlas_runner.replay_feedback(base_dir)
            comparison = atlas_runner.compare_replay(base_dir)
            self.assertEqual(len(replay), 1)
            self.assertEqual(comparison[0]["selected"], "EX-101")
            self.assertEqual(comparison[0]["override_reason"], "none")

    def test_evaluate_feedback_returns_metrics(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            (base_dir / "logs").mkdir(parents=True, exist_ok=True)
            (base_dir / "logs" / "feedback_log.jsonl").write_text(
                json.dumps({
                    "date": "2026-07-09",
                    "selected": "EX-101",
                    "recommended_task": "EX-101",
                    "override_reason": "urgent request",
                    "completed": True,
                    "duration": 95,
                    "context": {"environment": "office"},
                }) + "\n" +
                json.dumps({
                    "date": "2026-07-10",
                    "selected": "EX-102",
                    "recommended_task": "EX-103",
                    "override_reason": "customer issue",
                    "completed": False,
                    "duration": 40,
                    "context": {"environment": "office"},
                    "reason": "dependency violation",
                }) + "\n",
                encoding="utf-8",
            )

            metrics = atlas_runner.evaluate_feedback(base_dir)
            self.assertEqual(metrics["recommendation_accuracy"], 0.5)
            self.assertEqual(metrics["completion_rate"], 0.5)
            self.assertEqual(metrics["override_rate"], 1.0)
            self.assertEqual(metrics["dependency_violations"], 1)
            self.assertIn("urgent request", metrics["top_override_reasons"])

    def test_feedback_log_records_schema_and_engine_versions(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            entry = atlas_runner.log_feedback(
                base_dir,
                date="2026-07-11",
                recommended=["EX-101"],
                selected="EX-101",
                completed=True,
                duration=60,
                task="EX-101",
                engine_version="priority-v0.8.2",
                policy_version="policy-v0.1.0",
            )
            self.assertEqual(entry["schema_version"], 1)
            self.assertEqual(entry["engine_version"], "priority-v0.8.2")
            self.assertEqual(entry["policy_version"], "policy-v0.1.0")
            self.assertTrue(entry["session_id"])

    def test_compare_versions_groups_metrics_by_engine(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_dir = Path(tmpdir)
            (base_dir / "logs").mkdir(parents=True, exist_ok=True)
            (base_dir / "logs" / "feedback_log.jsonl").write_text(
                json.dumps({
                    "date": "2026-07-09",
                    "selected": "EX-101",
                    "recommended_task": "EX-101",
                    "completed": True,
                    "engine_version": "priority-v0.8.1",
                    "policy_version": "policy-v0.1.0",
                }) + "\n" +
                json.dumps({
                    "date": "2026-07-10",
                    "selected": "EX-102",
                    "recommended_task": "EX-103",
                    "completed": False,
                    "engine_version": "priority-v0.8.2",
                    "policy_version": "policy-v0.1.1",
                }) + "\n",
                encoding="utf-8",
            )

            comparison = atlas_runner.compare_versions(base_dir)
            self.assertEqual(len(comparison["versions"]), 2)
            self.assertIn("priority-v0.8.1", comparison["versions"])
            self.assertIn("priority-v0.8.2", comparison["versions"])


if __name__ == "__main__":
    unittest.main()
