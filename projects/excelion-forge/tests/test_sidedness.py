from __future__ import annotations

import importlib
import unittest

from excelion_forge.core.rules.primitives.sidedness import (
    BoneSide,
    detect_side,
    get_side_suffix,
    is_lateral_candidate,
    strip_side_suffix,
    tokenize_name,
)


class TestSidednessPrimitives(unittest.TestCase):
    def test_detect_side_identifies_left_right_center_unknown(self) -> None:
        self.assertEqual(detect_side("upper_arm.L"), BoneSide.LEFT)
        self.assertEqual(detect_side("leg.R"), BoneSide.RIGHT)
        self.assertEqual(detect_side("pelvis"), BoneSide.CENTER)
        self.assertEqual(detect_side("spine_03"), BoneSide.CENTER)
        self.assertEqual(detect_side("SpineUpper"), BoneSide.CENTER)
        self.assertEqual(detect_side("foo_bar"), BoneSide.UNKNOWN)
        self.assertEqual(detect_side(""), BoneSide.UNKNOWN)

    def test_detect_side_ignores_spine_left_as_unknown(self) -> None:
        self.assertEqual(detect_side("SpineLeft"), BoneSide.UNKNOWN)

    def test_tokenize_name_splits_tokens_cleanly(self) -> None:
        self.assertEqual(tokenize_name("UpperArm.L"), ["upper", "arm", "l"])
        self.assertEqual(tokenize_name("Pelvis_CTRL"), ["pelvis", "ctrl"])
        self.assertEqual(tokenize_name("root-m"), ["root", "m"])
        self.assertEqual(tokenize_name(""), [])

    def test_get_side_suffix_and_strip_side_suffix(self) -> None:
        self.assertEqual(get_side_suffix("arm.L"), "L")
        self.assertEqual(get_side_suffix("hand_r"), "R")
        self.assertIsNone(get_side_suffix("pelvis"))
        self.assertEqual(strip_side_suffix("leg.L"), "leg")
        self.assertEqual(strip_side_suffix("foot_r"), "foot")

    def test_is_lateral_candidate_detects_lateral_tokens(self) -> None:
        self.assertTrue(is_lateral_candidate("forearm"))
        self.assertTrue(is_lateral_candidate("thigh"))
        self.assertFalse(is_lateral_candidate("pelvis"))
        self.assertFalse(is_lateral_candidate("upper_body"))
