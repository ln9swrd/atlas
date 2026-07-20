"""Validator for the invalid bone character rule."""

from __future__ import annotations

import re

from excelion_forge.core.issue import FixSuggestion
from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.models import ArmatureModel
from excelion_forge.core.severity import Severity

from ...base import ValidationRule
from ...metadata import RuleMetadata


ALLOWED_BONE_NAME_PATTERN = re.compile(r"^[A-Za-z0-9_.\- ]+$")


class InvalidBoneCharacterRule(ValidationRule):
    """Report invalid characters in bone names."""

    name = "Invalid Bone Character"
    description = "Checks that bone names do not contain invalid characters."

    def __init__(self, metadata: RuleMetadata | None = None) -> None:
        from .metadata import METADATA

        super().__init__(metadata or METADATA)

    def validate(self, armature: ArmatureModel) -> list[ValidationIssue]:
        """Return issues for invalid bone characters.
        
        Args:
            armature: ArmatureModel domain object (not raw Blender object)
        """
        if not armature.bones:
            return []

        issues: list[ValidationIssue] = []
        for bone in armature.bones:
            if not ALLOWED_BONE_NAME_PATTERN.fullmatch(bone.name):
                issues.append(
                    ValidationIssue(
                        severity=Severity.ERROR,
                        code="INVALID_BONE_CHARACTER",
                        message=f"Bone name '{bone.name}' contains invalid characters.",
                        location_type="bone",
                        bone_name=bone.name,
                        suggestion="Remove invalid characters from bone names.",
                        rule_name=self.name,
                        fix_suggestion=FixSuggestion(
                            message="Replace invalid bone characters",
                            action_code="SANITIZE_BONE_NAME",
                            params={"bone_name": name},
                        ),
                    )
                )

        return issues
