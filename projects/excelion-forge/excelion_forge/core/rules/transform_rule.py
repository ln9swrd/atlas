"""Transform validation rules for rig objects."""

from __future__ import annotations

from typing import Iterable

from excelion_forge.core.issue import FixSuggestion
from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.severity import Severity

from .base import ValidationRule
from .metadata import RuleMetadata

_EPSILON = 0.0001


class ArmatureTransformRule(ValidationRule):
    """Validate that an armature object has export-ready transforms."""

    name = "Armature Transform"
    description = "Checks that object transforms are applied before export."

    def validate(self, target: object) -> list[ValidationIssue]:
        """Validate location, rotation, and scale values on the armature."""
        if getattr(target, "type", None) != "ARMATURE":
            return []

        failed_fields = _get_failed_transform_fields(target)
        if not failed_fields:
            return []

        obj_name = str(getattr(target, "name", "Unknown"))
        fields_str = ", ".join(failed_fields)

        return [
            ValidationIssue(
                severity=Severity.WARNING,
                code="ARMATURE_TRANSFORM_NOT_APPLIED",
                message=f"Armature has unapplied transforms: {fields_str}.",
                location_type="object",
                object_name=obj_name,
                suggestion="Apply location, rotation, and scale before export.",
                rule_name=self.name,
                fix_suggestion=FixSuggestion(
                    message="Apply object transforms (location, rotation, scale)",
                    action_code="APPLY_TRANSFORMS",
                ),
            )
        ]


def _get_failed_transform_fields(target: object) -> list[str]:
    """Return transform field names that differ from export defaults."""
    failed_fields: list[str] = []

    location = getattr(target, "location", None)
    rotation = getattr(target, "rotation_euler", None)
    scale = getattr(target, "scale", None)

    if location is not None and not _values_match(location, 0.0):
        failed_fields.append("location")

    if rotation is not None and not _values_match(rotation, 0.0):
        failed_fields.append("rotation_euler")

    if scale is not None and not _values_match(scale, 1.0):
        failed_fields.append("scale")

    return failed_fields


def _values_match(values: Iterable[object], expected: float) -> bool:
    """Return whether all numeric values match the expected value."""
    try:
        return all(abs(float(value) - expected) <= _EPSILON for value in values)  # type: ignore[arg-type]
    except TypeError:
        return False
    except ValueError:
        return False
