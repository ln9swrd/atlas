"""
Tests for BlenderMeshGenerator 3D Geometry Synthesis Engine
"""
import unittest
import os
import tempfile
from projects.excelion.src.blender.mesh_generator import BlenderMeshGenerator


class TestBlenderMeshGenerator(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.generator = BlenderMeshGenerator(output_dir=self.temp_dir.name)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_generate_phantom_mech_3d_asset(self):
        res = self.generator.generate_phantom_mech_3d_asset("TestPhantomMech.obj")
        self.assertEqual(res["status"], "SUCCESS")
        self.assertTrue(os.path.exists(res["filepath"]))
        self.assertGreater(res["file_size_bytes"], 0)
        self.assertGreater(res["vertex_count"], 0)
        self.assertGreater(res["face_count"], 0)

        # Inspect generated OBJ content
        with open(res["filepath"], "r", encoding="utf-8") as f:
            content = f.read()
        self.assertIn("v ", content)
        self.assertIn("f ", content)
        self.assertIn("o PhantomStealthMech", content)


if __name__ == "__main__":
    unittest.main()
