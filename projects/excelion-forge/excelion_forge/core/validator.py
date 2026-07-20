"""Rig validator compatibility facade."""

from __future__ import annotations

from .manager import RuleManager
from .report import ValidationReport
from .rules import DEFAULT_RULES
from .rules import ValidationRule


class RigValidator:
    """Validate rigs through the shared rule manager."""

    def __init__(self, rules: tuple[ValidationRule, ...] = DEFAULT_RULES) -> None:
        """Create a validator with an injected rule collection."""
        self._rule_manager = RuleManager(rules)

    def validate(self, armature: object) -> ValidationReport:
        """Run all rules and collect their issues into a report."""
        return self._rule_manager.validate(armature)


def validate_armature_object(armature: object) -> ValidationReport:
    """Validate an armature-like object with the default rule engine."""
    return RigValidator().validate(armature)
