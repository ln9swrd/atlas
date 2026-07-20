"""Validation result data models."""

from __future__ import annotations

from dataclasses import dataclass

from .issue import ValidationIssue
from .severity import Severity


@dataclass(frozen=True)
class ValidationResult:
    """Immutable result produced by a single validation rule."""

    rule_name: str
    issues: tuple[ValidationIssue, ...]

    @property
    def has_errors(self) -> bool:
        """Return whether this rule produced any error issues."""
        return any(issue.severity is Severity.ERROR for issue in self.issues)

    @property
    def passed(self) -> bool:
        """Return whether this rule completed without any issues."""
        return not self.issues
