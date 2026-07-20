"""Shared helpers for object validation rules."""

from __future__ import annotations

from typing import Literal
from typing import Sequence

from excelion_forge.core.issue import ValidationIssue
from excelion_forge.core.severity import Severity


def is_armature(target: object) -> bool:
    """Return whether the target is an armature-like object."""
    return target is not None and getattr(target, "type", None) == "ARMATURE"


def has_armature_data(target: object) -> bool:
    """Return whether the target is an armature with data."""
    return is_armature(target) and getattr(target, "data", None) is not None


def get_bones(target: object) -> Sequence[object]:
    """Return target bones or an empty tuple."""
    armature_data = getattr(target, "data", None)
    return getattr(armature_data, "bones", ()) or ()


def get_bone_count(target: object) -> int:
    """Return the number of bones on the target."""
    return len(get_bones(target)) if has_armature_data(target) else 0


def has_bones(target: object) -> bool:
    """Return whether the target has at least one bone."""
    return get_bone_count(target) > 0


def get_root_bones(target: object) -> list[object]:
    """Return bones that do not have a parent."""
    return [
        bone for bone in get_bones(target)
        if getattr(bone, "parent", None) is None
    ]


def create_error(
    rule_name: str,
    code: str,
    message: str,
    location_type: Literal["object", "bone", "none"] = "none",
    object_name: str | None = None,
    bone_name: str | None = None,
    suggestion: str | None = None,
) -> ValidationIssue:
    """Create an error issue for an object validation rule."""
    return ValidationIssue(
        severity=Severity.ERROR,
        code=code,
        message=message,
        location_type=location_type,
        object_name=object_name,
        bone_name=bone_name,
        suggestion=suggestion,
        rule_name=rule_name,
    )
