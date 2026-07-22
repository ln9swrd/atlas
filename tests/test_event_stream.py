"""
Tests for EventStreamEngine (v2.1 Telemetry)
"""
import unittest
import os
import tempfile
from core.telemetry.event_stream import EventStreamEngine, TelemetryEvent


class TestEventStreamEngine(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.log_file = os.path.join(self.temp_dir.name, "events.jsonl")
        self.engine = EventStreamEngine(log_path=self.log_file)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_publish_and_history(self):
        event = self.engine.publish("RULE_CHECK", "RuleEngine", "Rule check passed", {"score": 100})
        self.assertEqual(event.event_type, "RULE_CHECK")
        self.assertEqual(len(self.engine.get_history()), 1)

        history_filtered = self.engine.get_history("RULE_CHECK")
        self.assertEqual(len(history_filtered), 1)

    def test_subscribers(self):
        received = []
        self.engine.subscribe(lambda e: received.append(e.message))

        self.engine.publish("AGENT_ACTION", "Marie", "Review approved")
        self.assertEqual(len(received), 1)
        self.assertEqual(received[0], "Review approved")

    def test_file_logging(self):
        self.engine.publish("SYSTEM", "AtlasRunner", "Start routine")
        self.assertTrue(os.path.exists(self.log_file))
        with open(self.log_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
        self.assertEqual(len(lines), 1)
        self.assertIn("Start routine", lines[0])


if __name__ == "__main__":
    unittest.main()
