"""API layer for duplicate bone name rule package."""

from __future__ import annotations

from .autofix import apply_duplicate_bone_name_fixes
from .metadata import METADATA
from .validator import DuplicateBoneNameRule


def validate(target: object) -> list[dict[str, object]]:
    from ....adapters import BlenderArmatureAdapter
    from ...models import ArmatureModel
    
    if isinstance(target, ArmatureModel):
        return DuplicateBoneNameRule().validate(target)
    
    # Try to convert Blender object or mock to ArmatureModel
    try:
        armature = BlenderArmatureAdapter.extract(target)
        return DuplicateBoneNameRule().validate(armature)
    except (ValueError, AttributeError, TypeError):
        raise TypeError(
            f"validate() expects ArmatureModel or Blender object, got {type(target).__name__}"
        )


def autofix(target: object) -> list[dict[str, object]]:
    from ....adapters import BlenderArmatureAdapter
    from ...models import ArmatureModel
    
    if isinstance(target, ArmatureModel):
        return apply_duplicate_bone_name_fixes(target)
    
    # Try to convert Blender object or mock to ArmatureModel
    try:
        armature = BlenderArmatureAdapter.extract(target)
        return apply_duplicate_bone_name_fixes(armature)
    except (ValueError, AttributeError, TypeError):
        raise TypeError(
            f"autofix() expects ArmatureModel or Blender object, got {type(target).__name__}"
        )

__all__ = ["METADATA", "validate", "autofix"]
