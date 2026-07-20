"""Unit tests for Excelion Forge validation manager and facades."""

from __future__ import annotations

from types import SimpleNamespace
import unittest

from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.manager import RuleManager
from excelion_forge.core.report import ValidationReport
from excelion_forge.core.result import ValidationResult
from excelion_forge.core.rules.base import ValidationRule
from excelion_forge.core.severity import Severity
from excelion_forge.core.validator import RigValidator, validate_armature_object


class MockRule(ValidationRule):
    """Simple mock validation rule for testing managers."""

    def __init__(self, name: str, code: str, severity: Severity) -> None:
        self.name = name
        self.description = f"Mock rule {name}"
        self.code = code
        self.severity = severity

    def validate(self, target: object) -> list[ValidationIssue]:
        """Produce a single issue if target has a 'fail' attribute."""
        if getattr(target, "fail", False):
            return [
                ValidationIssue(
                    severity=self.severity,
                    code=self.code,
                    message=f"Failed {self.name}",
                    rule_name=self.name,
                )
            ]
        return []


class TestValidationResult(unittest.TestCase):
    """Test cases for ValidationResult class."""

    def test_passed(self) -> None:
        result = ValidationResult(rule_name="Mock", issues=())
        self.assertTrue(result.passed)
        self.assertFalse(result.has_errors)

    def test_failed_warning(self) -> None:
        issue = ValidationIssue(
            severity=Severity.WARNING,
            code="WARN",
            message="Warn",
            rule_name="Mock",
        )
        result = ValidationResult(rule_name="Mock", issues=(issue,))
        self.assertFalse(result.passed)
        self.assertFalse(result.has_errors)

    def test_failed_error(self) -> None:
        issue = ValidationIssue(
            severity=Severity.ERROR,
            code="ERR",
            message="Err",
            rule_name="Mock",
        )
        result = ValidationResult(rule_name="Mock", issues=(issue,))
        self.assertFalse(result.passed)
        self.assertTrue(result.has_errors)


class TestValidationReport(unittest.TestCase):
    """Test cases for ValidationReport class."""

    def test_empty_report(self) -> None:
        report = ValidationReport(issues=())
        self.assertTrue(report.is_valid)
        self.assertEqual(report.error_count, 0)
        self.assertEqual(report.warning_count, 0)
        self.assertEqual(report.info_count, 0)
        self.assertEqual(report.summary(), "Validation passed with no issues.")

    def test_mixed_report(self) -> None:
        err = ValidationIssue(Severity.ERROR, "E1", "Err", "Rule")
        warn = ValidationIssue(Severity.WARNING, "W1", "Warn", "Rule")
        info = ValidationIssue(Severity.INFO, "I1", "Info", "Rule")

        report = ValidationReport(issues=(err, warn, info))
        self.assertFalse(report.is_valid)
        self.assertEqual(report.error_count, 1)
        self.assertEqual(report.warning_count, 1)
        self.assertEqual(report.info_count, 1)
        self.assertEqual(
            report.summary(),
            "Validation completed: 1 error(s), 1 warning(s), 1 info.",
        )


class TestRuleManager(unittest.TestCase):
    """Test cases for RuleManager class."""

    def setUp(self) -> None:
        self.rule1 = MockRule("Rule1", "MOCK_E1", Severity.ERROR)
        self.rule2 = MockRule("Rule2", "MOCK_W2", Severity.WARNING)
        self.manager = RuleManager(rules=(self.rule1, self.rule2))

    def test_rules_property(self) -> None:
        self.assertEqual(self.manager.rules, (self.rule1, self.rule2))

    def test_register_rule(self) -> None:
        rule3 = MockRule("Rule3", "MOCK_I3", Severity.INFO)
        self.manager.register_rule(rule3)
        self.assertEqual(self.manager.rules, (self.rule1, self.rule2, rule3))

    def test_run_success(self) -> None:
        target = SimpleNamespace(fail=False)
        results = self.manager.run(target)
        self.assertEqual(len(results), 2)
        self.assertTrue(results[0].passed)
        self.assertTrue(results[1].passed)

    def test_run_failure(self) -> None:
        target = SimpleNamespace(fail=True)
        results = self.manager.run(target)
        self.assertEqual(len(results), 2)
        self.assertFalse(results[0].passed)
        self.assertEqual(results[0].issues[0].code, "MOCK_E1")
        self.assertFalse(results[1].passed)
        self.assertEqual(results[1].issues[0].code, "MOCK_W2")

    def test_validate(self) -> None:
        target = SimpleNamespace(fail=True)
        report = self.manager.validate(target)
        self.assertEqual(len(report.issues), 2)
        self.assertEqual(report.error_count, 1)
        self.assertEqual(report.warning_count, 1)


class TestFacades(unittest.TestCase):
    """Test cases for RigValidator and validate_armature_object facades."""

    def test_rig_validator_custom_rules(self) -> None:
        rule = MockRule("Custom", "C1", Severity.ERROR)
        validator = RigValidator(rules=(rule,))
        target = SimpleNamespace(fail=True)
        report = validator.validate(target)
        self.assertEqual(len(report.issues), 1)
        self.assertEqual(report.issues[0].code, "C1")

    def test_validate_armature_object_default_rules(self) -> None:
        # Since it uses default rules, passing target=None should fail with TARGET_MISSING
        report = validate_armature_object(None)
        self.assertEqual(len(report.issues), 1)
        self.assertEqual(report.issues[0].code, "TARGET_MISSING")


if __name__ == "__main__":
    unittest.main()
