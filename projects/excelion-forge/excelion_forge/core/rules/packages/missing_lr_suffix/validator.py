"""Validator for the missing .L/.R suffix rule."""

from __future__ import annotations

from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.models import ArmatureModel
from excelion_forge.core.severity import Severity

from ...base import ValidationRule
from ...metadata import RuleMetadata


class MissingLRSuffixRule(ValidationRule):
    """Report bones that likely need .L/.R suffixes."""

    name = "Missing .L/.R Suffix"
    description = "Checks that symmetric bones have a left/right suffix."

    def __init__(self, metadata: RuleMetadata | None = None) -> None:
        from .metadata import METADATA

        super().__init__(metadata or METADATA)

    def validate(self, armature: ArmatureModel) -> list[ValidationIssue]:
        """Return issues for missing .L/.R suffixes.
        
        Args:
            armature: ArmatureModel domain object (not raw Blender object)
        """
        if not armature.bones:
            return []

        issues: list[ValidationIssue] = []
        for bone in armature.bones:
            if _is_missing_lr_suffix(bone.name):
                issues.append(
                    ValidationIssue(
                        severity=Severity.WARNING,
                        code="MISSING_LR_SUFFIX",
                        message=(
                            f"Bone name '{bone.name}' is missing a .L or .R suffix."
                        ),
                        location_type="bone",
                        bone_name=bone.name,
                        suggestion="Consider adding .L or .R if this bone is part of mirrored skeleton symmetry.",
                        rule_name=self.name,
                    )
                )

        return issues


def _is_missing_lr_suffix(name: str) -> bool:
    from ...primitives.sidedness import BoneSide, detect_side

    side = detect_side(name)
    if side != BoneSide.UNKNOWN:
        return False

    return _is_likely_symmetric_name(name)


def _is_likely_symmetric_name(name: str) -> bool:
    normalized = name.lower()
    return any(
        token in normalized
        for token in (
            "arm",
            "leg",
            "hand",
            "foot",
            "thigh",
            "shin",
            "shoulder",
            "elbow",
            "wrist",
            "thumb",
            "index",
            "middle",
            "ring",
            "pinky",
            "hip",
            "knee",
        )
    )
