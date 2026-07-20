"""Base classes for validation rules."""

from __future__ import annotations

from abc import ABC
from abc import abstractmethod

from excelion_forge.core.issue import ValidationIssue

from .metadata import RuleCategory
from .metadata import RuleMetadata
from .metadata import rule_id_for


class ValidationRule(ABC):
    """Base class for plug-and-play validation rules."""

    name: str
    description: str
    metadata: RuleMetadata

    def __init__(self, metadata: RuleMetadata | None = None) -> None:
        self.metadata = metadata or RuleMetadata(
            rule_id=rule_id_for(RuleCategory.INTERNAL, 0),
            category=RuleCategory.INTERNAL,
        )

    @abstractmethod
    def validate(self, target: object) -> list[ValidationIssue]:
        """Validate an object and return any issues."""
