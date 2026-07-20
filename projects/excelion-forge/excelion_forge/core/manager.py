"""Rule manager for validation framework execution."""

from __future__ import annotations

from .report import ValidationReport
from .result import ValidationResult
from .rules import DEFAULT_RULES
from .rules import ValidationRule


class RuleManager:
    """Register and run validation rules in deterministic order."""

    def __init__(self, rules: tuple[ValidationRule, ...] = DEFAULT_RULES) -> None:
        """Create a manager with an optional initial rule collection."""
        self._rules: list[ValidationRule] = list(rules)

    @property
    def rules(self) -> tuple[ValidationRule, ...]:
        """Return the registered validation rules."""
        return tuple(self._rules)

    def register_rule(self, rule: ValidationRule) -> None:
        """Register a validation rule at the end of the execution order."""
        self._rules.append(rule)

    def run(self, target: object) -> tuple[ValidationResult, ...]:
        """Run registered rules sequentially and return per-rule results."""
        results: list[ValidationResult] = []

        for rule in self._rules:
            issues = tuple(rule.validate(target))
            results.append(
                ValidationResult(
                    rule_name=rule.name,
                    issues=issues,
                )
            )

        return tuple(results)

    def validate(self, target: object) -> ValidationReport:
        """Run registered rules and collect all issues into one report."""
        issues = [
            issue
            for result in self.run(target)
            for issue in result.issues
        ]
        return ValidationReport(issues=tuple(issues))
