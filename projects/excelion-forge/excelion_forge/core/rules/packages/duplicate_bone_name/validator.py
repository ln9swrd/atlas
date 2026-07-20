"""Validator for duplicate bone name rule package."""

from __future__ import annotations

from __future__ import annotations

from collections import Counter

from excelion_forge.core.issue import FixSuggestion
from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.models import ArmatureModel
from excelion_forge.core.severity import Severity

from ...base import ValidationRule
from ...metadata import RuleCategory
from ...metadata import RuleMetadata


class DuplicateBoneNameRule(ValidationRule):
    """Report duplicate bone names on an armature target."""

    name = "Duplicate Bone Name"
    description = "Checks that bone names are unique within an armature."

    def __init__(self, metadata: RuleMetadata | None = None) -> None:
        from .metadata import METADATA

        super().__init__(metadata or METADATA)

    def validate(self, armature: ArmatureModel) -> list[ValidationIssue]:
        """Return issues for duplicate bone names.
        
        Args:
            armature: ArmatureModel domain object (not raw Blender object)
        """
        if not armature.bones:
            return []

        normalized_names = [bone.name.strip() for bone in armature.bones]
        counts = Counter(name for name in normalized_names if name)
        duplicates = sorted(name for name, count in counts.items() if count > 1)

        return [
            ValidationIssue(
                severity=Severity.ERROR,
                code="DUPLICATE_BONE_NAME",
                message=f"Armature has duplicate bone name: '{name}'.",
                location_type="bone",
                bone_name=name,
                suggestion="Use a unique name for each bone.",
                rule_name=self.name,
                fix_suggestion=FixSuggestion(
                    message=f"Rename duplicate bone '{name}' to make it unique",
                    action_code="RENAME_DUPLICATE_BONE",
                    params={"old_name": name},
                ),
            )
            for name in duplicates
        ]
