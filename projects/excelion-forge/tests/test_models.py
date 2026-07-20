from __future__ import annotations

import unittest

from excelion_forge.core.models.armature import ArmatureModel
from excelion_forge.core.models.bone import BoneModel
from excelion_forge.core.models.builders import build_armature_model


class TestCoreModels(unittest.TestCase):
    def test_build_armature_model_creates_consistent_map(self) -> None:
        bones = [
            BoneModel(name="root", head=(0.0, 0.0, 0.0), tail=(0.0, 0.0, 1.0)),
            BoneModel(name="spine", head=(0.0, 0.0, 1.0), tail=(0.0, 0.0, 2.0), parent="root"),
        ]
        model = build_armature_model(name="TestArmature", bones=bones, source="generated")

        self.assertEqual(model.name, "TestArmature")
        self.assertEqual(model.source, "generated")
        self.assertEqual(len(model.bones), 2)
        self.assertEqual(model.bone_map["root"], bones[0])
        self.assertEqual(model.bone_map["spine"], bones[1])

    def test_build_armature_model_allows_duplicate_bone_names(self) -> None:
        """ArmatureModel allows duplicate bone names - validator's concern."""
        bones = [
            BoneModel(name="root", head=(0.0, 0.0, 0.0), tail=(0.0, 0.0, 1.0)),
            BoneModel(name="root", head=(0.1, 0.0, 0.0), tail=(0.1, 0.0, 1.0)),
        ]
        model = build_armature_model(name="ArmatureWithDuplicates", bones=bones)
        
        # ArmatureModel is created successfully
        self.assertEqual(len(model.bones), 2)
        # bone_map has only one entry (last duplicate wins)
        self.assertEqual(len(model.bone_map), 1)
        self.assertIn("root", model.bone_map)
