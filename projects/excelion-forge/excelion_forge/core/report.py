"""Validation report data model."""

from __future__ import annotations

from dataclasses import dataclass

from .issue import ValidationIssue
from .severity import Severity


@dataclass(frozen=True)
class ValidationReport:
    """Immutable collection of validation issues."""

    issues: tuple[ValidationIssue, ...]

    @property
    def error_count(self) -> int:
        """Return the number of error issues."""
        return self._count_by_severity(Severity.ERROR)

    @property
    def warning_count(self) -> int:
        """Return the number of warning issues."""
        return self._count_by_severity(Severity.WARNING)

    @property
    def info_count(self) -> int:
        """Return the number of informational issues."""
        return self._count_by_severity(Severity.INFO)

    @property
    def is_valid(self) -> bool:
        """Return whether the report contains no errors."""
        return self.error_count == 0

    def summary(self) -> str:
        """Return a compact human-readable validation summary."""
        if not self.issues:
            return "Validation passed with no issues."

        return (
            "Validation completed: "
            f"{self.error_count} error(s), "
            f"{self.warning_count} warning(s), "
            f"{self.info_count} info."
        )

    def _count_by_severity(self, severity: Severity) -> int:
        """Count issues matching the given severity."""
        return sum(1 for issue in self.issues if issue.severity is severity)
