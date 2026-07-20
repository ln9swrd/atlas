"""Test executor with adapter layer."""

import unittest
from unittest.mock import MagicMock

from excelion_forge.core.models import BoneModel, build_armature_model
from excelion_forge.core.rules.executor import _to_armature_model
from excelion_forge.adapters import BlenderArmatureAdapter


class TestExecutorAdapterBridge(unittest.TestCase):
    """Test executor-adapter connection."""

    def test_to_armature_model_from_armature_model(self):
        """Passing ArmatureModel returns it as-is."""
        bones = [
            BoneModel(name="Bone1", head=(0, 0, 0), tail=(0, 1, 0), parent=None, index=0),
        ]
        armature = build_armature_model("Test", bones)
        
        result = _to_armature_model(armature)
        
        self.assertIs(result, armature)

    def test_to_armature_model_from_blender_object(self):
        """Passing Blender object converts via adapter."""
        # Mock Blender object
        mock_bone = MagicMock()
        mock_bone.name = "Bone1"
        mock_bone.head_local = (0, 0, 0)
        mock_bone.tail_local = (0, 1, 0)
        mock_bone.parent = None

        mock_armature_data = MagicMock()
        mock_armature_data.bones = [mock_bone]

        mock_obj = MagicMock()
        mock_obj.type = "ARMATURE"
        mock_obj.name = "Armature"
        mock_obj.data = mock_armature_data

        result = _to_armature_model(mock_obj)

        self.assertEqual(result.name, "Armature")
        self.assertEqual(len(result.bones), 1)
        self.assertEqual(result.bones[0].name, "Bone1")

    def test_to_armature_model_invalid_type(self):
        """Passing invalid type raises TypeError."""
        with self.assertRaises(TypeError):
            _to_armature_model("invalid")

    def test_blender_adapter_extract(self):
        """BlenderArmatureAdapter.extract converts mock object."""
        mock_bone = MagicMock()
        mock_bone.name = "TestBone"
        mock_bone.head_local = (1.0, 2.0, 3.0)
        mock_bone.tail_local = (4.0, 5.0, 6.0)
        mock_bone.parent = None

        mock_armature_data = MagicMock()
        mock_armature_data.bones = [mock_bone]

        mock_obj = MagicMock()
        mock_obj.type = "ARMATURE"
        mock_obj.name = "MyArmature"
        mock_obj.data = mock_armature_data

        result = BlenderArmatureAdapter.extract(mock_obj)

        self.assertEqual(result.name, "MyArmature")
        self.assertEqual(len(result.bones), 1)
        self.assertEqual(result.bones[0].name, "TestBone")
        self.assertEqual(result.bones[0].head, (1.0, 2.0, 3.0))
        self.assertEqual(result.bones[0].tail, (4.0, 5.0, 6.0))

    def test_blender_adapter_not_armature(self):
        """BlenderArmatureAdapter rejects non-armature objects."""
        mock_obj = MagicMock()
        mock_obj.type = "MESH"
        mock_obj.name = "NotArmature"

        with self.assertRaises(ValueError):
            BlenderArmatureAdapter.extract(mock_obj)


if __name__ == "__main__":
    unittest.main()
