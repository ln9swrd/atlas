from __future__ import annotations

import unittest

from excelion_forge.core.rules.loader import (
    iter_registered_rule_ids,
    iter_rule_package_specs,
    iter_rule_packages,
    load_rule_spec,
)
from excelion_forge.core.rules.package_registry import RulePackageRegistry
from excelion_forge.core.rules.spec import RulePackageSpec


class TestRuleSpecLoader(unittest.TestCase):
    def test_iter_rule_packages_builds_specs(self) -> None:
        specs = tuple(iter_rule_packages("excelion_forge.core.rules.packages"))
        self.assertTrue(specs)
        self.assertTrue(all(isinstance(spec, RulePackageSpec) for spec in specs))

    def test_load_rule_spec_by_id_returns_spec(self) -> None:
        spec = load_rule_spec("EF101")
        self.assertIsInstance(spec, RulePackageSpec)
        self.assertEqual(spec.metadata.rule_id, "EF101")

    def test_load_rule_spec_returns_cached_instance(self) -> None:
        first = load_rule_spec("EF101")
        second = load_rule_spec("EF101")
        self.assertIs(first, second)

    def test_iter_registered_rule_ids_loads_all_specs(self) -> None:
        rule_ids = tuple(iter_registered_rule_ids())
        self.assertTrue(rule_ids)
        for rule_id in rule_ids:
            spec = load_rule_spec(rule_id)
            self.assertEqual(spec.metadata.rule_id, rule_id)

    def test_iter_rule_package_specs_yields_matching_ids(self) -> None:
        rule_ids = tuple(iter_registered_rule_ids())
        specs = tuple(iter_rule_package_specs())
        self.assertEqual(len(rule_ids), len(specs))
        for rule_id, spec in zip(rule_ids, specs):
            self.assertEqual(spec.metadata.rule_id, rule_id)

    def test_registry_can_register_package_index(self) -> None:
        index = {
            "EF101": "excelion_forge.core.rules.packages.duplicate_bone_name",
            "EF102": "excelion_forge.core.rules.packages.invalid_bone_character",
        }
        registry = RulePackageRegistry(index)
        self.assertEqual(len(registry), 2)
        self.assertEqual(registry.get("EF101"), "excelion_forge.core.rules.packages.duplicate_bone_name")
