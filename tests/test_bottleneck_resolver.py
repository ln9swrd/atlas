"""
Tests for BottleneckResolver (Atlas v2.2)
"""
import unittest
from core.execution.bottleneck_resolver import BottleneckResolver
from core.telemetry.event_stream import TelemetryEvent


class TestBottleneckResolver(unittest.TestCase):

    def setUp(self):
        self.resolver = BottleneckResolver()

    def test_analyze_bottlenecks(self):
        tasks = [
            {"id": "EX-001", "bottleneck": "Topology mesh distortion"},
            {"id": "EX-002", "bottleneck": "Collision missing"},
        ]
        report = self.resolver.analyze_bottlenecks(tasks)
        self.assertEqual(report["total_analyzed"], 2)
        self.assertEqual(report["bottleneck_frequencies"]["topology"], 1)
        self.assertEqual(report["bottleneck_frequencies"]["collision"], 1)

    def test_resolve_event_finding(self):
        event = TelemetryEvent(
            event_type="RULE_CHECK",
            source="BlenderTool",
            message="Error: Collision geometry missing in mesh export",
        )
        resolution = self.resolver.resolve_event_finding(event)
        self.assertIsNotNone(resolution)
        self.assertEqual(resolution["diagnosed_key"], "collision")
        self.assertEqual(resolution["resolution"]["assigned_agent"], "Forge")


if __name__ == "__main__":
    unittest.main()
