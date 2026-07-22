"""
Tests for AgentOrchestrator (Atlas v1.3)
"""
import unittest
from core.execution.orchestrator import AgentOrchestrator


class TestAgentOrchestrator(unittest.TestCase):

    def setUp(self):
        self.orchestrator = AgentOrchestrator()

    def test_select_agent(self):
        task_forge = {"focus_area": "modeling", "category": "Blender Modeling", "bottleneck": "Topology"}
        self.assertEqual(self.orchestrator.select_agent(task_forge), "Forge")

        task_marie = {"focus_area": "audit", "category": "Quality Review", "bottleneck": "Pre-flight QA"}
        self.assertEqual(self.orchestrator.select_agent(task_marie), "Marie")

        task_antigravity = {"focus_area": "rules", "category": "Core Rules", "bottleneck": "Architecture"}
        self.assertEqual(self.orchestrator.select_agent(task_antigravity), "Antigravity")

    def test_orchestrate_backlog(self):
        tasks = [
            {"id": "T1", "focus_area": "modeling"},
            {"id": "T2", "focus_area": "audit"},
        ]
        orchestrated = self.orchestrator.orchestrate_backlog(tasks)
        self.assertEqual(orchestrated[0]["assigned_agent"], "Forge")
        self.assertEqual(orchestrated[1]["assigned_agent"], "Marie")

    def test_generate_report(self):
        tasks = [
            {"id": "T1", "focus_area": "modeling"},
            {"id": "T2", "focus_area": "modeling"},
            {"id": "T3", "focus_area": "audit"},
        ]
        report = self.orchestrator.generate_orchestration_report(tasks)
        self.assertEqual(report["total_tasks"], 3)
        self.assertEqual(report["load_distribution"]["Forge"], 2)
        self.assertEqual(report["load_distribution"]["Marie"], 1)


if __name__ == "__main__":
    unittest.main()
