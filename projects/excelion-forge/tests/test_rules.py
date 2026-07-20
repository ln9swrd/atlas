"""Unit tests for Excelion Forge validation rules."""

from __future__ import annotations

from types import SimpleNamespace
import unittest

from excelion_forge.core.rules.bone_name_rule import BoneNameRule
from excelion_forge.core.rules.object_rule import (
    ArmatureHasBonesRule,
    EmptyArmatureRule,
    SingleRootBoneRule,
    TargetIsArmatureRule,
)
from excelion_forge.core.rules.transform_rule import ArmatureTransformRule


class TestTargetIsArmatureRule(unittest.TestCase):
    """Test cases for TargetIsArmatureRule."""

    def setUp(self) -> None:
        self.rule = TargetIsArmatureRule()

    def test_target_missing(self) -> None:
        issues = self.rule.validate(None)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "TARGET_MISSING")

    def test_target_not_armature(self) -> None:
        target = SimpleNamespace(type="MESH", name="Cube")
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "TARGET_NOT_ARMATURE")
        self.assertEqual(issues[0].location_type, "object")
        self.assertEqual(issues[0].object_name, "Cube")

    def test_target_is_armature(self) -> None:
        target = SimpleNamespace(type="ARMATURE", name="Armature")
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)


class TestEmptyArmatureRule(unittest.TestCase):
    """Test cases for EmptyArmatureRule."""

    def setUp(self) -> None:
        self.rule = EmptyArmatureRule()

    def test_not_armature_ignored(self) -> None:
        target = SimpleNamespace(type="MESH", data=None)
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)

    def test_armature_data_missing(self) -> None:
        target = SimpleNamespace(type="ARMATURE", data=None)
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "ARMATURE_DATA_MISSING")

    def test_armature_data_exists(self) -> None:
        target = SimpleNamespace(type="ARMATURE", data=SimpleNamespace())
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)


class TestArmatureHasBonesRule(unittest.TestCase):
    """Test cases for ArmatureHasBonesRule."""

    def setUp(self) -> None:
        self.rule = ArmatureHasBonesRule()

    def test_not_armature_ignored(self) -> None:
        target = SimpleNamespace(type="MESH", data=None)
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)

    def test_armature_no_data_ignored(self) -> None:
        target = SimpleNamespace(type="ARMATURE", data=None)
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)

    def test_armature_has_no_bones(self) -> None:
        target = SimpleNamespace(
            type="ARMATURE",
            data=SimpleNamespace(bones=[]),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "ARMATURE_HAS_NO_BONES")

    def test_armature_has_bones(self) -> None:
        target = SimpleNamespace(
            type="ARMATURE",
            data=SimpleNamespace(bones=[SimpleNamespace(name="Bone")]),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)


class TestSingleRootBoneRule(unittest.TestCase):
    """Test cases for SingleRootBoneRule."""

    def setUp(self) -> None:
        self.rule = SingleRootBoneRule()

    def test_no_bones_ignored(self) -> None:
        target = SimpleNamespace(type="ARMATURE", data=None)
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)

        target2 = SimpleNamespace(type="ARMATURE", data=SimpleNamespace(bones=[]))
        issues2 = self.rule.validate(target2)
        self.assertEqual(len(issues2), 0)

    def test_root_bone_missing(self) -> None:
        # All bones have a parent
        bone1 = SimpleNamespace(name="Bone1", parent=object())
        target = SimpleNamespace(
            type="ARMATURE",
            data=SimpleNamespace(bones=[bone1]),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "ROOT_BONE_MISSING")

    def test_single_root_bone_success(self) -> None:
        root_bone = SimpleNamespace(name="Root", parent=None)
        child_bone = SimpleNamespace(name="Child", parent=root_bone)
        target = SimpleNamespace(
            type="ARMATURE",
            data=SimpleNamespace(bones=[root_bone, child_bone]),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)

    def test_multiple_root_bones(self) -> None:
        root1 = SimpleNamespace(name="Root1", parent=None)
        root2 = SimpleNamespace(name="Root2", parent=None)
        target = SimpleNamespace(
            type="ARMATURE",
            data=SimpleNamespace(bones=[root1, root2]),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "MULTIPLE_ROOT_BONES")
        self.assertEqual(issues[0].location_type, "bone")
        self.assertIn(issues[0].bone_name, ["Root1", "Root2"])
        self.assertIn("Root1", issues[0].message)
        self.assertIn("Root2", issues[0].message)


class TestArmatureTransformRule(unittest.TestCase):
    """Test cases for ArmatureTransformRule."""

    def setUp(self) -> None:
        self.rule = ArmatureTransformRule()

    def test_not_armature_ignored(self) -> None:
        target = SimpleNamespace(type="MESH")
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)

    def test_transform_applied_success(self) -> None:
        target = SimpleNamespace(
            type="ARMATURE",
            location=(0.0, 0.0, 0.0),
            rotation_euler=(0.0, 0.0, 0.0),
            scale=(1.0, 1.0, 1.0),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)

    def test_unapplied_location(self) -> None:
        target = SimpleNamespace(
            type="ARMATURE",
            location=(1.0, 0.0, 0.0),
            rotation_euler=(0.0, 0.0, 0.0),
            scale=(1.0, 1.0, 1.0),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "ARMATURE_TRANSFORM_NOT_APPLIED")
        self.assertEqual(issues[0].location_type, "object")
        self.assertIsNotNone(issues[0].object_name)
        self.assertIn("location", issues[0].message)
        self.assertIsNotNone(issues[0].fix_suggestion)
        self.assertEqual(issues[0].fix_suggestion.action_code, "APPLY_TRANSFORMS")

    def test_unapplied_rotation(self) -> None:
        target = SimpleNamespace(
            type="ARMATURE",
            location=(0.0, 0.0, 0.0),
            rotation_euler=(0.0, 0.5, 0.0),
            scale=(1.0, 1.0, 1.0),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "ARMATURE_TRANSFORM_NOT_APPLIED")
        self.assertIn("rotation_euler", issues[0].message)

    def test_unapplied_scale(self) -> None:
        target = SimpleNamespace(
            type="ARMATURE",
            location=(0.0, 0.0, 0.0),
            rotation_euler=(0.0, 0.0, 0.0),
            scale=(2.0, 2.0, 2.0),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "ARMATURE_TRANSFORM_NOT_APPLIED")
        self.assertIn("scale", issues[0].message)

    def test_multiple_unapplied_transforms(self) -> None:
        target = SimpleNamespace(
            type="ARMATURE",
            location=(1.0, 0.0, 0.0),
            rotation_euler=(0.0, 0.0, 0.0),
            scale=(2.0, 2.0, 2.0),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "ARMATURE_TRANSFORM_NOT_APPLIED")
        self.assertIn("location", issues[0].message)
        self.assertIn("scale", issues[0].message)


class TestBoneNameRule(unittest.TestCase):
    """Test cases for BoneNameRule."""

    def setUp(self) -> None:
        self.rule = BoneNameRule()

    def test_not_armature_ignored(self) -> None:
        target = SimpleNamespace(type="MESH")
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)

    def test_no_bones_ignored(self) -> None:
        target = SimpleNamespace(type="ARMATURE", data=None)
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)

        target2 = SimpleNamespace(type="ARMATURE", data=SimpleNamespace(bones=[]))
        issues2 = self.rule.validate(target2)
        self.assertEqual(len(issues2), 0)

    def test_valid_bone_names(self) -> None:
        bone1 = SimpleNamespace(name="Root")
        bone2 = SimpleNamespace(name="Spine")
        target = SimpleNamespace(
            type="ARMATURE",
            data=SimpleNamespace(bones=[bone1, bone2]),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 0)

    def test_empty_bone_name(self) -> None:
        bone1 = SimpleNamespace(name="")
        bone2 = SimpleNamespace(name="   ")
        target = SimpleNamespace(
            type="ARMATURE",
            data=SimpleNamespace(bones=[bone1, bone2]),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 2)
        self.assertEqual(issues[0].code, "BONE_NAME_EMPTY")
        self.assertEqual(issues[1].code, "BONE_NAME_EMPTY")
        self.assertIsNotNone(issues[0].fix_suggestion)
        self.assertEqual(issues[0].fix_suggestion.action_code, "RENAME_EMPTY_BONE")

    def test_duplicate_bone_name(self) -> None:
        bone1 = SimpleNamespace(name="Root")
        bone2 = SimpleNamespace(name="Root")
        bone3 = SimpleNamespace(name="Spine")
        target = SimpleNamespace(
            type="ARMATURE",
            data=SimpleNamespace(bones=[bone1, bone2, bone3]),
        )
        issues = self.rule.validate(target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "DUPLICATE_BONE_NAME")
        self.assertEqual(issues[0].location_type, "bone")
        self.assertEqual(issues[0].bone_name, "Root")
        self.assertIsNotNone(issues[0].fix_suggestion)
        self.assertEqual(issues[0].fix_suggestion.action_code, "RENAME_DUPLICATE_BONE")
        self.assertEqual(issues[0].fix_suggestion.params.get("old_name"), "Root")


if __name__ == "__main__":
    unittest.main()
