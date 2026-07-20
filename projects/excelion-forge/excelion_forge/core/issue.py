"""Validation issue data model."""

from __future__ import annotations

from dataclasses import dataclass
from dataclasses import field
from typing import Literal

from .severity import Severity


@dataclass(frozen=True)
class FixSuggestion:
    """Immutable suggestion on how to fix a validation issue."""

    message: str
    action_code: str
    params: dict[str, str] = field(default_factory=dict)


@dataclass(frozen=True)
class ValidationIssue:
    """Single immutable issue found during validation."""

    severity: Severity
    code: str
    message: str
    rule_name: str
    location_type: Literal["object", "bone", "none"] = "none"
    object_name: str | None = None
    bone_name: str | None = None
    suggestion: str | None = None
    fix_suggestion: FixSuggestion | None = None
