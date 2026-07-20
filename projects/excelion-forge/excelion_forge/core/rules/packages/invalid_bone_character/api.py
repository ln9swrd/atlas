"""API layer for invalid bone character rule package."""

from __future__ import annotations

from .autofix import apply_invalid_bone_character_fixes
from .metadata import METADATA
from .validator import InvalidBoneCharacterRule


def validate(target: object) -> list[dict[str, object]]:
    from ....adapters import BlenderArmatureAdapter
    from ...models import ArmatureModel
    
    if isinstance(target, ArmatureModel):
        return InvalidBoneCharacterRule().validate(target)
    
    # Try to convert Blender object or mock to ArmatureModel
    try:
        armature = BlenderArmatureAdapter.extract(target)
        return InvalidBoneCharacterRule().validate(armature)
    except (ValueError, AttributeError, TypeError):
        raise TypeError(
            f"validate() expects ArmatureModel or Blender object, got {type(target).__name__}"
        )


def autofix(target: object) -> list[dict[str, object]]:
    from ....adapters import BlenderArmatureAdapter
    from ...models import ArmatureModel
    
    if isinstance(target, ArmatureModel):
        return apply_invalid_bone_character_fixes(target)
    
    # Try to convert Blender object or mock to ArmatureModel
    try:
        armature = BlenderArmatureAdapter.extract(target)
        return apply_invalid_bone_character_fixes(armature)
    except (ValueError, AttributeError, TypeError):
        raise TypeError(
            f"autofix() expects ArmatureModel or Blender object, got {type(target).__name__}"
        )

__all__ = ["METADATA", "validate", "autofix"]
