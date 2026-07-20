"""Compatibility exports for object-level validation rules."""

from .object import ArmatureHasBonesRule
from .object import EmptyArmatureRule
from .object import SingleRootBoneRule
from .object import TargetIsArmatureRule

__all__ = [
    "ArmatureHasBonesRule",
    "EmptyArmatureRule",
    "SingleRootBoneRule",
    "TargetIsArmatureRule",
]
