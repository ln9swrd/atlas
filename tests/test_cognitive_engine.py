import unittest
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from core.cognitive.cognitive_engine import CognitiveEngine


class TestCognitiveEngine(unittest.TestCase):

    def setUp(self):
        self.engine = CognitiveEngine()

    def test_observe_workspace(self):
        result = self.engine.observe_workspace("/path/to/workspace", ["file1.py", "file2.py"])
        self.assertEqual(result["active_project"], "Atlas")
        self.assertEqual(len(self.engine.observation_history), 1)

    def test_update_intent(self):
        self.engine.update_intent("DEVELOPING_VISION_MODULE")
        self.assertEqual(self.engine.state["developer_intent"], "DEVELOPING_VISION_MODULE")

    def test_cognition_summary(self):
        summary = self.engine.get_cognition_summary()
        self.assertEqual(summary["status"], "ACTIVE")


if __name__ == "__main__":
    unittest.main()
