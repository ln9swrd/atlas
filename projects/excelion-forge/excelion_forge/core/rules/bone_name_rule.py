"""Bone naming validation rules."""

from __future__ import annotations

from collections import Counter
from typing import Literal

from excelion_forge.core.issue import FixSuggestion
from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.severity import Severity

from .base import ValidationRule
from .metadata import RuleMetadata


class BoneNameRule(ValidationRule):
    """Validate that bones use non-empty, unique names."""

    name = "Bone Name"
    description = "Checks that bone names are readable and unique."

    def validate(self, target: object) -> list[ValidationIssue]:
        """Validate bone names on an armature target."""
        if getattr(target, "type", None) != "ARMATURE":
            return []

        bones = _get_bones(target)
        if not bones:
            return []

        issues: list[ValidationIssue] = []
        issues.extend(self._find_empty_name_issues(bones))
        issues.extend(self._find_duplicate_name_issues(bones))
        return issues

    def _find_empty_name_issues(
        self,
        bones: tuple[object, ...],
    ) -> list[ValidationIssue]:
        """Return issues for bones with empty names."""
        return [
            ValidationIssue(
                severity=Severity.ERROR,
                code="BONE_NAME_EMPTY",
                message="Bone has an empty name.",
                location_type="none",
                suggestion="Rename every bone before export.",
                rule_name=self.name,
                fix_suggestion=FixSuggestion(
                    message="Rename empty bones to default names",
                    action_code="RENAME_EMPTY_BONE",
                ),
            )
            for bone in bones
            if not str(getattr(bone, "name", "")).strip()
        ]

    def _find_duplicate_name_issues(
        self,
        bones: tuple[object, ...],
    ) -> list[ValidationIssue]:
        """Return issues for duplicate bone names."""
        normalized_names = [
            str(getattr(bone, "name", "")).strip()
            for bone in bones
            if str(getattr(bone, "name", "")).strip()
        ]
        duplicate_names = sorted(
            name for name, count in Counter(normalized_names).items()
            if count > 1
        )

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
            for name in duplicate_names
        ]


def _get_bones(target: object) -> tuple[object, ...]:
    """Return armature bones as a tuple."""
    armature_data = getattr(target, "data", None)
    bones = getattr(armature_data, "bones", ()) or ()
    return tuple(bones)
