from __future__ import annotations

import unittest

from excelion_forge.core.models import BoneModel, build_armature_model
from excelion_forge.core.rules.packages.invalid_bone_character.autofix import apply_invalid_bone_character_fixes
from excelion_forge.core.rules.packages.invalid_bone_character.validator import InvalidBoneCharacterRule


class TestInvalidBoneCharacterRule(unittest.TestCase):
    def setUp(self) -> None:
        self.rule = InvalidBoneCharacterRule()

    def test_invalid_bone_characters_are_reported(self) -> None:
        bones = [
            BoneModel(name="Root*", head=(0.0, 0.0, 0.0), tail=(0.0, 0.0, 1.0), index=0),
            BoneModel(name="Spine?", head=(0.0, 0.0, 1.0), tail=(0.0, 0.0, 2.0), index=1),
            BoneModel(name="Arm:L", head=(0.0, 0.0, 2.0), tail=(0.0, 0.0, 3.0), index=2),
        ]
        armature = build_armature_model(name="TestArmature", bones=bones)

        issues = self.rule.validate(armature)

        self.assertEqual(len(issues), 3)
        self.assertEqual(issues[0].code, "INVALID_BONE_CHARACTER")
        self.assertEqual(issues[0].bone_name, "Root*")
        self.assertEqual(issues[1].bone_name, "Spine?")
        self.assertEqual(issues[2].bone_name, "Arm:L")

    def test_autofix_sanitizes_invalid_bone_names(self) -> None:
        bones = [
            BoneModel(name="Root*", head=(0.0, 0.0, 0.0), tail=(0.0, 0.0, 1.0), index=0),
            BoneModel(name="Spine?", head=(0.0, 0.0, 1.0), tail=(0.0, 0.0, 2.0), index=1),
            BoneModel(name="Arm:L", head=(0.0, 0.0, 2.0), tail=(0.0, 0.0, 3.0), index=2),
        ]
        armature = build_armature_model(name="TestArmature", bones=bones)

        operations = apply_invalid_bone_character_fixes(armature)

        self.assertEqual(len(operations), 3)
        self.assertEqual(operations[0]["new_name"], "Root")
        self.assertEqual(operations[1]["new_name"], "Spine")
        self.assertEqual(operations[2]["new_name"], "Arm_L")
        self.assertEqual(armature.bones[2].name, "Arm_L")


if __name__ == "__main__":
    unittest.main()
