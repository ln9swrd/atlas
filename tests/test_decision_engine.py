import unittest
from pathlib import Path
import sys

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.append(str(REPO_ROOT))

from core.decision.decision_engine import DecisionEngine, DecisionRequest, DecisionContext, RuleDecisionStrategy
from tools.atlas_runner import build_start_report, get_repo_root


class DecisionEngineTests(unittest.TestCase):
    def test_rule_strategy_returns_approved_decision(self):
        context = DecisionContext(
            environment="DEV_HOME",
            project="Exelion",
            goals=["complete backlog", "preserve quality"],
            constraints=["no_unreal"],
            capabilities=["blender", "gpu"],
            resources={"available_minutes": 180},
            time={"work_hours": True},
        )
        request = DecisionRequest(
            request_id="req-001",
            context=context,
            goals=context.goals,
            constraints=context.constraints,
            knowledge=["follow naming rules"],
            strategies=["rule"],
            preferred_strategy="rule",
        )

        engine = DecisionEngine(strategy=RuleDecisionStrategy())
        result = engine.make_decision(request)

        self.assertEqual(result.status, "approved")
        self.assertGreaterEqual(result.priority, 0.0)
        self.assertTrue(result.actions)
        self.assertTrue(result.evidence)

    def test_runner_includes_decision_in_start_report(self):
        report = build_start_report(get_repo_root('.'), environment_id="DEV_HOME", project_name="Exelion")
        self.assertIn("decision", report)
        self.assertEqual(report["decision"]["status"], "approved")


if __name__ == "__main__":
    unittest.main()
