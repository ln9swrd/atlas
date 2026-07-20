from __future__ import annotations

import unittest
from types import SimpleNamespace

from excelion_forge.core.rules.packages.missing_lr_suffix.validator import MissingLRSuffixRule


class TestMissingLRSuffixRule(unittest.TestCase):
    def setUp(self) -> None:
        self.rule = MissingLRSuffixRule()

    def test_missing_lr_suffix_is_reported(self) -> None:
        target = SimpleNamespace(
            type="ARMATURE",
            data=SimpleNamespace(
                bones=[
                    SimpleNamespace(name="Arm"),
                    SimpleNamespace(name="Arm.L"),
                    SimpleNamespace(name="Leg"),
                    SimpleNamespace(name="CenterSpine"),
                ]
            ),
        )

        issues = self.rule.validate(target)

        self.assertEqual(len(issues), 2)
        self.assertEqual(issues[0].code, "MISSING_LR_SUFFIX")
        self.assertEqual(issues[0].bone_name, "Arm")
        self.assertEqual(issues[1].bone_name, "Leg")

    def test_center_names_are_ignored(self) -> None:
        target = SimpleNamespace(
            type="ARMATURE",
            data=SimpleNamespace(
                bones=[SimpleNamespace(name="CenterPelvis"), SimpleNamespace(name="CenterHead")],
            ),
        )

        issues = self.rule.validate(target)

        self.assertEqual(len(issues), 0)
