import sys, os, unittest
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

from forge.executors.animation_validator import AnimationValidator

class TestAnimationValidator(unittest.TestCase):
    def setUp(self):
        self.validator = AnimationValidator()

    def test_valid_animation(self):
        context = {
            "action_name": "Anim_Brave_Run",
            "frame_start": 1,
            "frame_end": 60,
            "bone_names": ["root", "pelvis", "hand_r"],
            "unweighted_vertices": 0
        }
        res = self.validator.execute(context)
        self.assertTrue(res["success"])
        self.assertEqual(res["status"], "PASS")

    def test_invalid_frame_range(self):
        context = {
            "action_name": "Anim_Bad",
            "frame_start": 60,
            "frame_end": 10,
            "bone_names": ["root"],
            "unweighted_vertices": 0
        }
        res = self.validator.execute(context)
        self.assertFalse(res["success"])
        self.assertEqual(res["status"], "FAIL")

if __name__ == "__main__":
    unittest.main()
