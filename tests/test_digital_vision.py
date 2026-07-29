import unittest
import sys
import os
import tempfile

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from core.vision.digital_vision_inspector import DigitalVisionInspector


class TestDigitalVisionInspector(unittest.TestCase):

    def setUp(self):
        self.config_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../core/vision/vision_config.json"))
        self.inspector = DigitalVisionInspector(self.config_path)

    def test_camera_excluded_config(self):
        self.assertFalse(self.inspector.config.get("hardware_camera_enabled", True))
        self.assertEqual(self.inspector.config.get("target_mode"), "digital_screen_only")

    def test_inspect_image_asset(self):
        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
            tmp.write(b"fake png content")
            tmp_path = tmp.name

        try:
            res = self.inspector.inspect_image_asset(tmp_path)
            self.assertEqual(res["status"], "VERIFIED")
            self.assertTrue(res["camera_excluded"])
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)

    def test_analyze_screen_viewport_buffer(self):
        buf = b"\x00" * 1024
        res = self.inspector.analyze_screen_viewport_buffer(buf, 1920, 1080)
        self.assertEqual(res["status"], "VERIFIED")
        self.assertTrue(res["camera_excluded"])
        self.assertEqual(res["resolution"], "1920x1080")


if __name__ == "__main__":
    unittest.main()
