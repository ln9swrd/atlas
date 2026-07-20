"""Registry for validation rules."""

from __future__ import annotations

from typing import Iterable

from .base import ValidationRule
from .metadata import RULE_ID_PATTERN
from .metadata import RuleCategory
from .metadata import normalize_category


class DuplicateRuleError(ValueError):
    """Raised when a duplicate rule identifier is registered."""


class InvalidRuleIdError(ValueError):
    """Raised when a rule id does not match the expected format."""


class RuleCategoryMismatchError(ValueError):
    """Raised when a rule id falls outside the allowed range for its category."""


class RuleRegistry:
    """Register and query validation rules in deterministic order."""


    def __init__(self, rules: Iterable[ValidationRule] = ()) -> None:
        self._rules: list[ValidationRule] = []
        for rule in rules:
            self.register(rule)

    def __len__(self) -> int:
        return len(self._rules)

    def register(self, rule: ValidationRule) -> None:
        """Register a rule with a unique rule identifier."""
        rule_id = getattr(rule, "metadata", None)
        if rule_id is not None:
            rule_id_value = getattr(rule_id, "rule_id", None)
        else:
            rule_id_value = None

        if rule_id_value is None:
            raise ValueError("Rule metadata must provide a rule_id")

        from .metadata import parse_rule_number

        if not RULE_ID_PATTERN.fullmatch(rule_id_value):
            raise InvalidRuleIdError(
                f"Invalid rule id '{rule_id_value}'. Expected format EF###"
            )

        number = parse_rule_number(rule_id_value)
        category = getattr(getattr(rule, "metadata", None), "category", None)
        if category is None:
            raise ValueError("Rule metadata must provide a category")

        normalized_category = normalize_category(category)
        allowed_range = normalized_category.id_range
        if number not in allowed_range:
            raise RuleCategoryMismatchError(
                f"Rule id '{rule_id_value}' does not match category '{category}'."
            )

        if self.get(rule_id_value) is not None:
            raise DuplicateRuleError(f"Duplicate rule id: {rule_id_value}")

        self._rules.append(rule)

    def get(self, rule_id: str) -> ValidationRule | None:
        """Return a registered rule by id, if any."""
        for rule in self._rules:
            metadata = getattr(rule, "metadata", None)
            if metadata is not None and getattr(metadata, "rule_id", None) == rule_id:
                return rule
        return None

    def get_all(self) -> tuple[ValidationRule, ...]:
        """Return all registered rules in insertion order."""
        return tuple(self._rules)

    def get_by_category(self, category: str | RuleCategory) -> tuple[ValidationRule, ...]:
        """Return rules for a specific category."""
        normalized_category = normalize_category(category)
        return tuple(
            rule
            for rule in self._rules
            if getattr(getattr(rule, "metadata", None), "category", None)
            == normalized_category
        )

    def get_by_severity(self, severity: object) -> tuple[ValidationRule, ...]:
        """Return rules for a specific severity."""
        return tuple(
            rule
            for rule in self._rules
            if getattr(getattr(rule, "metadata", None), "severity", None) == severity
        )
