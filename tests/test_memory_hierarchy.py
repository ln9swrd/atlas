import asyncio
import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.append(str(REPO_ROOT))

from core.memory import AtlasMemory, DecisionMemory, ProjectMemory, PersistentMemory, SessionMemory
from core.sdk import AtlasSDK


class MemoryHierarchyTests(unittest.TestCase):
    def test_layers_are_independent(self):
        memory = AtlasMemory()
        memory.session.set("active_task", "TASK-001")
        memory.decision.current_project = "Exelion"
        memory.decision.current_goal = "Complete backlog"
        memory.project.set("status", "in_progress")
        memory.persistent.set("last_review", "PASS")

        self.assertEqual(memory.session.get("active_task"), "TASK-001")
        self.assertEqual(memory.decision.current_project, "Exelion")
        self.assertEqual(memory.project.get("status"), "in_progress")
        self.assertEqual(memory.persistent.get("last_review"), "PASS")

    def test_mock_sdk_exposes_layered_memory(self):
        async def _run():
            sdk = AtlasSDK.create_mock_sdk()
            await sdk.memory.set_session_state("agent", "forge")
            value = await sdk.memory.get_session_state("agent")
            self.assertEqual(value, "forge")
            self.assertIsInstance(sdk.memory.memory_layers.session, SessionMemory)
            self.assertIsInstance(sdk.memory.memory_layers.decision, DecisionMemory)
            self.assertIsInstance(sdk.memory.memory_layers.project, ProjectMemory)
            self.assertIsInstance(sdk.memory.memory_layers.persistent, PersistentMemory)

        asyncio.run(_run())


if __name__ == "__main__":
    unittest.main()
