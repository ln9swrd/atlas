import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.append(str(REPO_ROOT))

from core.decision.decision_registry import DecisionRegistry


class DecisionRegistryTests(unittest.TestCase):
    def test_registry_contains_rule_strategy(self):
        registry = DecisionRegistry()
        self.assertIsNotNone(registry.get("rule"))
        self.assertGreaterEqual(len(registry.list()), 1)


if __name__ == "__main__":
    unittest.main()
