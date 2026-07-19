import json
import tempfile
import unittest
from pathlib import Path

from core.execution.goal_registry import load_goal_registry, set_active_goal, sync_state_with_goal


class GoalRegistryTests(unittest.TestCase):
    def test_load_goal_registry_returns_defaults_when_missing(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            registry_path = Path(tmpdir) / "GOAL_REGISTRY.json"
            registry = load_goal_registry(registry_path)

            self.assertEqual(registry["active_goal"], None)
            self.assertEqual(registry["completed_goals"], [])
            self.assertEqual(registry["next_goal"], None)

    def test_set_active_goal_updates_registry_and_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            registry_path = Path(tmpdir) / "GOAL_REGISTRY.json"
            state_path = Path(tmpdir) / "ATLAS_STATE.json"

            set_active_goal(registry_path, "EX-GOAL-001")
            sync_state_with_goal(state_path, registry_path)

            with state_path.open("r", encoding="utf-8") as handle:
                state = json.load(handle)

            self.assertEqual(state["active_goal"], "EX-GOAL-001")
            self.assertEqual(state["current_goal_status"], "Active")


if __name__ == "__main__":
    unittest.main()
