from __future__ import annotations

import unittest
from dataclasses import replace

from excelion_forge.core.rules.metadata import CATEGORY_BASE
from excelion_forge.core.rules.metadata import InvalidRuleCategoryError
from excelion_forge.core.rules.metadata import InvalidRuleMetadataError
from excelion_forge.core.rules.metadata import RuleCategory
from excelion_forge.core.rules.metadata import RuleMetadata
from excelion_forge.core.rules.metadata import rule_id_for
from excelion_forge.core.rules.metadata import parse_rule_number
from excelion_forge.core.severity import Severity


class TestRuleMetadata(unittest.TestCase):
    def test_metadata_is_immutable(self) -> None:
        metadata = RuleMetadata(rule_id="EF101", category="bone", severity=Severity.ERROR)

        with self.assertRaises(AttributeError):
            metadata.rule_id = "changed"  # type: ignore[misc,assignment]

    def test_replace_supports_field_updates(self) -> None:
        metadata = RuleMetadata(rule_id="EF101", category="bone", severity=Severity.ERROR)
        updated = replace(metadata, severity=Severity.WARNING)

        self.assertIsNot(updated, metadata)
        self.assertEqual(updated.severity, Severity.WARNING)
        self.assertEqual(metadata.severity, Severity.ERROR)

    def test_rule_id_for_uses_category_base(self) -> None:
        self.assertEqual(rule_id_for(RuleCategory.BONE, 1), "EF101")
        self.assertEqual(rule_id_for("Transform", 1), "EF201")
        self.assertEqual(rule_id_for(RuleCategory.HIERARCHY, 1), "EF301")
        self.assertEqual(CATEGORY_BASE[RuleCategory.BONE], 100)

    def test_rule_category_id_range(self) -> None:
        self.assertEqual(RuleCategory.BONE.id_range, range(100, 200))
        self.assertEqual(RuleCategory.WEIGHT.id_range, range(400, 500))

    def test_rule_id_for_invalid_category(self) -> None:
        with self.assertRaises(InvalidRuleCategoryError):
            rule_id_for("Unknown", 1)

    def test_rule_id_for_negative_number(self) -> None:
        with self.assertRaises(ValueError):
            rule_id_for(RuleCategory.BONE, -1)

    def test_rule_id_for_range_overflow(self) -> None:
        with self.assertRaises(ValueError):
            rule_id_for(RuleCategory.BONE, 100)

    def test_parse_rule_number_returns_numeric_value(self) -> None:
        self.assertEqual(parse_rule_number("EF101"), 101)

    def test_parse_rule_number_rejects_invalid_rule_id(self) -> None:
        with self.assertRaises(InvalidRuleMetadataError):
            parse_rule_number("EF10")

    def test_parse_rule_number_rejects_non_string(self) -> None:
        with self.assertRaises(InvalidRuleMetadataError):
            parse_rule_number(None)  # type: ignore[arg-type]

    def test_rule_number_property_matches_parse_rule_number(self) -> None:
        metadata = RuleMetadata(rule_id="EF101", category=RuleCategory.BONE)
        self.assertEqual(metadata.rule_number, parse_rule_number(metadata.rule_id))

    def test_rule_metadata_rejects_invalid_rule_id(self) -> None:
        with self.assertRaises(InvalidRuleMetadataError):
            RuleMetadata(rule_id="bone_001", category=RuleCategory.BONE)


if __name__ == "__main__":
    unittest.main()
