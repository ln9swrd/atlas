import sys, os, unittest
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

from forge.executors.fbx_exporter import FBXExporter

class TestFBXExporter(unittest.TestCase):
    def setUp(self):
        self.exporter = FBXExporter()

    def test_valid_export(self):
        context = {
            "export_path": "exports/SM_Brave_Rifle_01.fbx",
            "target_mesh": "SM_Brave_Rifle_01",
            "scale_applied": True,
            "preserve_sockets": True
        }
        res = self.exporter.execute(context)
        self.assertTrue(res["success"])
        self.assertEqual(res["status"], "PASS")

    def test_invalid_extension(self):
        context = {
            "export_path": "exports/SM_Brave_Rifle_01.obj",
            "target_mesh": "SM_Brave_Rifle_01"
        }
        res = self.exporter.execute(context)
        self.assertFalse(res["success"])
        self.assertEqual(res["status"], "FAIL")

if __name__ == "__main__":
    unittest.main()
