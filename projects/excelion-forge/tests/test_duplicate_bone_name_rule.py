from __future__ import annotations

import unittest

from excelion_forge.core.models import BoneModel, build_armature_model
from excelion_forge.core.rules.duplicate_bone_name_rule import DuplicateBoneNameRule
from excelion_forge.core.rules.packages.duplicate_bone_name.autofix import apply_duplicate_bone_name_fixes


class TestDuplicateBoneNameRule(unittest.TestCase):
    def setUp(self) -> None:
        self.rule = DuplicateBoneNameRule()

    def test_duplicate_bone_names_are_reported(self) -> None:
        bones = [
            BoneModel(name="Root", head=(0.0, 0.0, 0.0), tail=(0.0, 0.0, 1.0), index=0),
            BoneModel(name="Root", head=(0.0, 0.0, 1.0), tail=(0.0, 0.0, 2.0), index=1),
            BoneModel(name="Spine", head=(0.0, 0.0, 2.0), tail=(0.0, 0.0, 3.0), index=2),
        ]
        armature = build_armature_model(name="TestArmature", bones=bones)

        issues = self.rule.validate(armature)

        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "DUPLICATE_BONE_NAME")
        self.assertEqual(issues[0].bone_name, "Root")
        self.assertEqual(issues[0].location_type, "bone")
        self.assertEqual(issues[0].fix_suggestion is not None, True)
        self.assertEqual(issues[0].fix_suggestion.action_code, "RENAME_DUPLICATE_BONE")

    def test_autofix_makes_duplicate_names_unique(self) -> None:
        bones = [
            BoneModel(name="Root", head=(0.0, 0.0, 0.0), tail=(0.0, 0.0, 1.0), index=0),
            BoneModel(name="Root", head=(0.0, 0.0, 1.0), tail=(0.0, 0.0, 2.0), index=1),
            BoneModel(name="Spine", head=(0.0, 0.0, 2.0), tail=(0.0, 0.0, 3.0), index=2),
        ]
        armature = build_armature_model(name="TestArmature", bones=bones)

        operations = apply_duplicate_bone_name_fixes(armature)

        self.assertEqual(len(operations), 1)
        self.assertEqual(operations[0]["old_name"], "Root")
        self.assertEqual(operations[0]["new_name"], "Root_2")
        self.assertEqual(armature.bones[1].name, "Root_2")

    def test_autofix_preserves_existing_names(self) -> None:
        bones = [
            BoneModel(name="Root", head=(0.0, 0.0, 0.0), tail=(0.0, 0.0, 1.0), index=0),
            BoneModel(name="Root", head=(0.0, 0.0, 1.0), tail=(0.0, 0.0, 2.0), index=1),
            BoneModel(name="Root_2", head=(0.0, 0.0, 2.0), tail=(0.0, 0.0, 3.0), index=2),
        ]
        armature = build_armature_model(name="TestArmature", bones=bones)

        operations = apply_duplicate_bone_name_fixes(armature)

        self.assertEqual(len(operations), 1)
        self.assertEqual(operations[0]["old_name"], "Root")
        self.assertEqual(operations[0]["new_name"], "Root_3")
        self.assertEqual(armature.bones[1].name, "Root_3")
        self.assertEqual(armature.bones[2].name, "Root_2")

    def test_rule_metadata_is_explicit(self) -> None:
        self.assertEqual(self.rule.metadata.rule_id, "EF101")
        self.assertEqual(self.rule.metadata.category.value, "Bone")
