"""API layer for missing .L/.R suffix rule package."""

from __future__ import annotations

from .metadata import METADATA
from .validator import MissingLRSuffixRule


def validate(target: object) -> list[dict[str, object]]:
    from ....adapters import BlenderArmatureAdapter
    from ...models import ArmatureModel
    
    if isinstance(target, ArmatureModel):
        return MissingLRSuffixRule().validate(target)
    
    # Try to convert Blender object or mock to ArmatureModel
    try:
        armature = BlenderArmatureAdapter.extract(target)
        return MissingLRSuffixRule().validate(armature)
    except (ValueError, AttributeError, TypeError):
        raise TypeError(
            f"validate() expects ArmatureModel or Blender object, got {type(target).__name__}"
        )

__all__ = ["METADATA", "validate"]
