"""Validation rule for target armature type."""

from __future__ import annotations

from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.rules.base import ValidationRule
from excelion_forge.core.rules.metadata import RuleMetadata
from typing import Literal

from .common import create_error


class TargetIsArmatureRule(ValidationRule):
    """Validate that the target exists and is an armature."""

    name = "Target Is Armature"
    description = "Checks that the validation target is an armature object."

    def validate(self, target: object) -> list[ValidationIssue]:
        """Validate target existence and object type."""
        if target is None:
            return [
                self._error(
                    code="TARGET_MISSING",
                    message="No validation target is selected.",
                    suggestion="Select an object before running validation.",
                )
            ]

        if getattr(target, "type", None) != "ARMATURE":
            return [
                self._error(
                    code="TARGET_NOT_ARMATURE",
                    message="Selected target is not an armature.",
                    location_type="object",
                    object_name=str(getattr(target, "name", "Unknown Target")),
                    suggestion="Select an armature object before validating.",
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
