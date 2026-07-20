"""Object-level validation rules."""

from .armature_has_bones_rule import ArmatureHasBonesRule
from .empty_armature_rule import EmptyArmatureRule
from .single_root_bone_rule import SingleRootBoneRule
from .target_is_armature_rule import TargetIsArmatureRule

__all__ = [
    "ArmatureHasBonesRule",
    "EmptyArmatureRule",
    "SingleRootBoneRule",
    "TargetIsArmatureRule",
]
