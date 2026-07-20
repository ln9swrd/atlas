from __future__ import annotations

import inspect
import unittest

from excelion_forge.core.rules.loader import iter_registered_rule_ids, iter_rule_package_specs, iter_rule_packages
from excelion_forge.core.rules.metadata import parse_rule_number
from excelion_forge.core.rules.spec import RulePackageSpec


class TestRulePackageContract(unittest.TestCase):
    def test_rule_package_spec_contract(self) -> None:
        specs = tuple(iter_rule_packages("excelion_forge.core.rules.packages"))
        self.assertTrue(specs)
        self.assertTrue(all(isinstance(spec, RulePackageSpec) for spec in specs))

        for spec in specs:
            self.assertRegex(spec.metadata.rule_id, r"^EF\d+$")
            self.assertEqual(spec.metadata.rule_number, parse_rule_number(spec.metadata.rule_id))
            self.assertTrue(inspect.isfunction(spec.validate))

            if spec.autofix is not None:
                self.assertTrue(inspect.isfunction(spec.autofix))

    def test_root_package_discovery_matches_registry_ids(self) -> None:
        root_spec_ids = {spec.metadata.rule_id for spec in iter_rule_packages("excelion_forge.core.rules.packages")}
        registry_ids = set(iter_registered_rule_ids())
        self.assertEqual(root_spec_ids, registry_ids)

    def test_registry_rule_ids_match_spec_metadata(self) -> None:
        for rule_id, spec in zip(iter_registered_rule_ids(), iter_rule_package_specs()):
            self.assertEqual(spec.metadata.rule_id, rule_id)
