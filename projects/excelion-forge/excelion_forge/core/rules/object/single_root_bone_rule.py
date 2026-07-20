"""Validation rule for root bone count."""

from __future__ import annotations

from typing import Literal

from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.rules.base import ValidationRule
from excelion_forge.core.rules.metadata import RuleMetadata

from .common import create_error
from .common import get_root_bones
from .common import has_bones


class SingleRootBoneRule(ValidationRule):
    """Validate that an armature has exactly one root bone."""

    name = "Single Root Bone"
    description = "Checks that exactly one bone has no parent."

    def validate(self, target: object) -> list[ValidationIssue]:
        """Validate root bone count."""
        if not has_bones(target):
            return []

        root_bones = get_root_bones(target)
        root_count = len(root_bones)

        if root_count == 0:
            return [
                self._error(
                    code="ROOT_BONE_MISSING",
                    message="Armature has no root bone.",
                    suggestion="Ensure exactly one bone has no parent.",
                )
            ]

        if root_count > 1:
            root_names = [
                str(getattr(bone, "name", "Unnamed Bone"))
                for bone in root_bones
            ]
            first_bone = root_names[0]
            all_names = ", ".join(root_names)
            return [
                self._error(
                    code="MULTIPLE_ROOT_BONES",
                    message=f"Armature has multiple root bones: {all_names}.",
                    location_type="bone",
                    bone_name=first_bone,
                    suggestion=(
                        "Parent secondary root bones under a single main root."
                    ),
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
