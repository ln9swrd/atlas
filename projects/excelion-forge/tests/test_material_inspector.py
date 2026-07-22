"""
Tests for MaterialInspectorExecutor (v1.2)
"""
import unittest
from forge.executors.material_inspector import MaterialInspectorExecutor


class TestMaterialInspectorExecutor(unittest.TestCase):

    def setUp(self):
        self.inspector = MaterialInspectorExecutor()

    def test_power_of_two(self):
        self.assertTrue(self.inspector._is_power_of_two(2048))
        self.assertTrue(self.inspector._is_power_of_two(1024))
        self.assertFalse(self.inspector._is_power_of_two(1920))

    def test_inspect_material(self):
        findings = self.inspector.inspect_material({"name": "Unprefixed_Mat", "has_orm_texture": False})
        self.assertEqual(len(findings), 2)
        rules = [f["rule"] for f in findings]
        self.assertIn("MaterialNamingRule", rules)
        self.assertIn("TexturePackingRule", rules)

    def test_inspect_texture_resolution(self):
        findings = self.inspector.inspect_texture({"name": "T_NonPowerOfTwo", "width": 1920, "height": 1080})
        self.assertEqual(len(findings), 1)
        self.assertEqual(findings[0]["severity"], "ERROR")

    def test_execute_pass(self):
        context = {
            "materials": [{"name": "M_Brave_Armor", "has_orm_texture": True}],
            "textures": [{"name": "T_Brave_ORM", "width": 4096, "height": 4096}],
        }
        result = self.inspector.execute(context)
        self.assertTrue(result["success"])
        self.assertEqual(result["status"], "PASS")


if __name__ == "__main__":
    unittest.main()
