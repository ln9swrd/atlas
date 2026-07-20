"""Unit tests for object validation rules."""

from __future__ import annotations

from dataclasses import dataclass
from unittest import TestCase

from excelion_forge.core import RigValidator
from excelion_forge.core.rules import DEFAULT_RULES
from excelion_forge.core.rules import ArmatureHasBonesRule
from excelion_forge.core.rules import ArmatureTransformRule
from excelion_forge.core.rules import BoneNameRule
from excelion_forge.core.rules import EmptyArmatureRule
from excelion_forge.core.rules import SingleRootBoneRule
from excelion_forge.core.rules import TargetIsArmatureRule
from excelion_forge.core.manager import ValidationReport

@dataclass
class FakeBone:
    """Minimal bone-like object for core rule tests."""

    name: str
    parent: object | None = None


@dataclass
class FakeArmatureData:
    """Minimal armature data-like object for core rule tests."""

    bones: list[FakeBone]


@dataclass
class FakeObject:
    """Minimal Blender object-like value for core rule tests."""

    name: str
    type: str
    data: FakeArmatureData | None = None


class ObjectValidationRulesTest(TestCase):
    """Verify Sprint 2 object validation behavior."""

    def test_default_rules_run_in_prerequisite_order(self) -> None:
        """Default rules should guard later rules from duplicate findings."""
        rule_types = tuple(type(rule) for rule in DEFAULT_RULES)

        self.assertEqual(
            rule_types,
            (
                TargetIsArmatureRule,
                EmptyArmatureRule,
                ArmatureHasBonesRule,
                SingleRootBoneRule,
                ArmatureTransformRule,
                BoneNameRule,
            ),
        )

    def test_no_target_reports_only_missing_target(self) -> None:
        """A missing target should not produce follow-up armature errors."""
        report = RigValidator().validate(None)

        self.assert_issue_codes(report, ["TARGET_MISSING"])

    def test_mesh_target_reports_only_not_armature(self) -> None:
        """A non-armature target should not produce bone errors."""
        target = FakeObject(name="Cube", type="MESH")
        report = RigValidator().validate(target)

        self.assert_issue_codes(report, ["TARGET_NOT_ARMATURE"])

    def test_armature_without_data_reports_only_missing_data(self) -> None:
        """An armature without data should skip bone-specific checks."""
        target = FakeObject(name="BrokenRig", type="ARMATURE", data=None)
        report = RigValidator().validate(target)

        self.assert_issue_codes(report, ["ARMATURE_DATA_MISSING"])

    def test_armature_without_bones_reports_only_no_bones(self) -> None:
        """An armature with empty data should not report root errors."""
        target = FakeObject(
            name="EmptyRig",
            type="ARMATURE",
            data=FakeArmatureData(bones=[]),
        )
        report = RigValidator().validate(target)

        self.assert_issue_codes(report, ["ARMATURE_HAS_NO_BONES"])

    def test_valid_armature_reports_no_issues(self) -> None:
        """A single-root armature should pass Sprint 2 validation."""
        target = FakeObject(
            name="ValidRig",
            type="ARMATURE",
            data=FakeArmatureData(bones=[FakeBone(name="Root")]),
        )
        report = RigValidator().validate(target)

        self.assertEqual(report.issues, ())
        self.assertTrue(report.is_valid)

    def test_multiple_roots_reports_only_multiple_roots(self) -> None:
        """Multiple parentless bones should produce one root-count issue."""
        target = FakeObject(
            name="MultiRootRig",
            type="ARMATURE",
            data=FakeArmatureData(
                bones=[
                    FakeBone(name="Root"),
                    FakeBone(name="Pelvis"),
                ],
            ),
        )
        report = RigValidator().validate(target)

        self.assert_issue_codes(report, ["MULTIPLE_ROOT_BONES"])

    def test_no_root_reports_only_missing_root(self) -> None:
        """A bone collection with no parentless bone should fail gracefully."""
        parent = object()
        target = FakeObject(
            name="NoRootRig",
            type="ARMATURE",
            data=FakeArmatureData(
                bones=[
                    FakeBone(name="LoopBone", parent=parent),
                ],
            ),
        )
        report = RigValidator().validate(target)

        self.assert_issue_codes(report, ["ROOT_BONE_MISSING"])

    def assert_issue_codes(
        self,
        report: ValidationReport,
        expected_codes: list[str],
    ) -> None:
        """Assert the report issue codes match exactly."""
        actual_codes = [issue.code for issue in report.issues]
        self.assertEqual(actual_codes, expected_codes)
