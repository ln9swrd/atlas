"""
Tests for LODGeneratorExecutor (v1.3)
"""
import unittest
from forge.executors.lod_generator import LODGeneratorExecutor


class TestLODGeneratorExecutor(unittest.TestCase):

    def setUp(self):
        self.executor = LODGeneratorExecutor()

    def test_calculate_lod_levels(self):
        lod_counts = self.executor.calculate_lod_levels(10000)
        self.assertEqual(lod_counts["LOD0"], 10000)
        self.assertEqual(lod_counts["LOD1"], 5000)
        self.assertEqual(lod_counts["LOD2"], 2500)

    def test_execute(self):
        context = {
            "target_mesh": "SM_Hero_Mech",
            "base_poly_count": 20000,
        }
        result = self.executor.execute(context)
        self.assertTrue(result["success"])
        self.assertEqual(result["status"], "PASS")
        self.assertEqual(len(result["generated_lods"]), 3)
        self.assertEqual(result["generated_lods"][1]["mesh_name"], "SM_Hero_Mech_LOD1")
        self.assertEqual(result["generated_lods"][1]["target_poly_count"], 10000)


if __name__ == "__main__":
    unittest.main()
