"""Validation rule for missing armature data."""

from __future__ import annotations

from typing import Literal

from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.rules.base import ValidationRule
from excelion_forge.core.rules.metadata import RuleMetadata

from .common import create_error
from .common import is_armature


class EmptyArmatureRule(ValidationRule):
    """Validate that an armature has an armature data block."""

    name = "Empty Armature"
    description = "Checks that the armature data block exists."

    def validate(self, target: object) -> list[ValidationIssue]:
        """Validate armature data presence."""
        if not is_armature(target):
            return []

        if getattr(target, "data", None) is None:
            return [
                self._error(
                    code="ARMATURE_DATA_MISSING",
                    message="Armature data is missing.",
                    suggestion="Recreate or relink the armature data block.",
                )
            ]

        return []

    def _error(
        self,
        code: str,
        message: str,
        location_type: Literal["object", "bone", "none"] = "none",
        object_name: str | None = None,
        bone_name: str | None = None,
        suggestion: str | None = None,
    ) -> ValidationIssue:
        """Create an error issue owned by this rule."""
        return create_error(
            rule_name=self.name,
            code=code,
            message=message,
            location_type=location_type,
            object_name=object_name,
            bone_name=bone_name,
            suggestion=suggestion,
        )
