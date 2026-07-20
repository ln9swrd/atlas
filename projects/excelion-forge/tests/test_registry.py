from __future__ import annotations

import unittest

from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.rules import DEFAULT_REGISTRY
from excelion_forge.core.rules import DEFAULT_RULES
from excelion_forge.core.rules.base import ValidationRule
from excelion_forge.core.rules.metadata import InvalidRuleMetadataError
from excelion_forge.core.rules.metadata import RuleCategory
from excelion_forge.core.rules.metadata import RuleMetadata
from excelion_forge.core.rules.registry import DuplicateRuleError
from excelion_forge.core.rules.registry import InvalidRuleIdError
from excelion_forge.core.rules.registry import RuleCategoryMismatchError
from excelion_forge.core.rules.registry import RuleRegistry
from excelion_forge.core.severity import Severity


class DummyRule(ValidationRule):
    """Simple rule used for registry tests."""

    def __init__(self, name: str, rule_id: str, category: RuleCategory | str = RuleCategory.INTERNAL) -> None:
        self.name = name
        self.description = f"Dummy rule {name}"
        super().__init__(RuleMetadata(rule_id=rule_id, category=category))

    def validate(self, target: object) -> list[ValidationIssue]:
        return []


class TestRuleRegistry(unittest.TestCase):
    def test_empty_registry(self) -> None:
        registry = RuleRegistry()
        self.assertEqual(registry.get_all(), ())
        self.assertEqual(len(registry), 0)

    def test_register_and_query_rules(self) -> None:
        registry = RuleRegistry()
        rule_a = DummyRule("Rule A", "EF301", category="Hierarchy")
        rule_b = DummyRule("Rule B", "EF101", category="Bone")

        registry.register(rule_a)
        registry.register(rule_b)

        self.assertEqual(registry.get_all(), (rule_a, rule_b))
        self.assertEqual(registry.get_by_category("Hierarchy"), (rule_a,))
        self.assertEqual(registry.get_by_category("Bone"), (rule_b,))
        self.assertEqual(registry.get("EF101"), rule_b)

    def test_duplicate_rule_id_raises(self) -> None:
        registry = RuleRegistry()
        registry.register(DummyRule("Rule A", "EF101", category="Bone"))

        with self.assertRaises(DuplicateRuleError):
            registry.register(DummyRule("Rule B", "EF101", category="Bone"))

    def test_get_by_severity(self) -> None:
        registry = RuleRegistry()
        rule_error = DummyRule("Error", "EF101", category="Bone")
        rule_error.metadata = rule_error.metadata.with_severity(Severity.ERROR)
        rule_warn = DummyRule("Warn", "EF201", category="Transform")
        rule_warn.metadata = rule_warn.metadata.with_severity(Severity.WARNING)

        registry.register(rule_error)
        registry.register(rule_warn)

        self.assertEqual(registry.get_by_severity(Severity.ERROR), (rule_error,))
        self.assertEqual(registry.get_by_severity(Severity.WARNING), (rule_warn,))

    def test_default_rules_remain_ordered(self) -> None:
        registry = RuleRegistry(DEFAULT_RULES)
        self.assertEqual(registry.get_all(), DEFAULT_RULES)
        self.assertIsInstance(registry.get_all(), tuple)

    def test_registry_preserves_registration_order(self) -> None:
        registry = RuleRegistry()
        first = DummyRule("First", "EF101", category="Bone")
        second = DummyRule("Second", "EF201", category="Transform")
        third = DummyRule("Third", "EF301", category="Hierarchy")

        registry.register(first)
        registry.register(second)
        registry.register(third)

        ids = [rule.metadata.rule_id for rule in registry.get_all()]
        self.assertEqual(ids, ["EF101", "EF201", "EF301"])

    def test_invalid_rule_id_raises(self) -> None:
        with self.assertRaises(InvalidRuleMetadataError):
            DummyRule("Invalid", "bone_001")

    def test_rule_category_id_range_mismatch_raises(self) -> None:
        registry = RuleRegistry()

        with self.assertRaises(RuleCategoryMismatchError):
            registry.register(
                DummyRule("Mismatch", "EF101", category="Hierarchy")
            )

    def test_category_filter_preserves_registration_order(self) -> None:
        registry = RuleRegistry()
        first = DummyRule("First", "EF101", category="Bone")
        second = DummyRule("Second", "EF301", category="Hierarchy")
        third = DummyRule("Third", "EF201", category="Transform")

        registry.register(first)
        registry.register(second)
        registry.register(third)

        self.assertEqual(
            [rule.metadata.rule_id for rule in registry.get_by_category("Hierarchy")],
            ["EF301"],
        )
        self.assertEqual(
            [rule.metadata.rule_id for rule in registry.get_by_severity(Severity.ERROR)],
            ["EF101", "EF301", "EF201"],
        )

    def test_default_registry_contract(self) -> None:
        ids = [rule.metadata.rule_id for rule in DEFAULT_REGISTRY.get_all()]
        self.assertEqual(ids, ["EF301", "EF302", "EF303", "EF304", "EF201", "EF101"])


if __name__ == "__main__":
    unittest.main()
