import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.append(str(REPO_ROOT))

from core.decision.strategy_descriptor import StrategyDescriptor
from core.decision.decision_memory import DecisionMemory


class DecisionMetadataTests(unittest.TestCase):
    def test_strategy_descriptor_and_memory_are_created(self):
        descriptor = StrategyDescriptor(
            strategy_id="rule-v1",
            name="RuleStrategy",
            version="1.0",
            author="Atlas",
            description="Rule-based decision",
            priority=100,
            supports_ai=False,
            requires_knowledge=False,
            tags=["rule", "deterministic"],
        )
        memory = DecisionMemory(current_project="Exelion", current_goal="Complete backlog", current_sprint="Sprint-001")

        self.assertEqual(descriptor.name, "RuleStrategy")
        self.assertTrue(memory.current_project)
        self.assertEqual(memory.current_sprint, "Sprint-001")


if __name__ == "__main__":
    unittest.main()
