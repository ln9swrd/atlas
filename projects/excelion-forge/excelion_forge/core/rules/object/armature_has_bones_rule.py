"""Validation rule for empty armature bone collections."""

from __future__ import annotations

from typing import Literal

from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.rules.base import ValidationRule
from excelion_forge.core.rules.metadata import RuleMetadata

from .common import create_error
from .common import get_bone_count
from .common import has_armature_data


class ArmatureHasBonesRule(ValidationRule):
    """Validate that an armature contains at least one bone."""

    name = "Armature Has Bones"
    description = "Checks that the armature contains at least one bone."

    def validate(self, target: object) -> list[ValidationIssue]:
        """Validate that the armature has bones."""
        if not has_armature_data(target):
            return []

        if get_bone_count(target) == 0:
            return [
                self._error(
                    code="ARMATURE_HAS_NO_BONES",
                    message="Armature has no bones.",
                    suggestion="Add at least one bone to the armature.",
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
