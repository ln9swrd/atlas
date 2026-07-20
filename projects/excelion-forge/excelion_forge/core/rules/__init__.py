"""Built-in validation rules."""

from __future__ import annotations

from .base import ValidationRule
from .bone_name_rule import BoneNameRule
from .metadata import RuleMetadata
from .object_rule import ArmatureHasBonesRule
from .object_rule import EmptyArmatureRule
from .object_rule import SingleRootBoneRule
from .object_rule import TargetIsArmatureRule
from .registry import RuleRegistry
from .transform_rule import ArmatureTransformRule

DEFAULT_RULES: tuple[ValidationRule, ...] = (
    TargetIsArmatureRule(
        metadata=RuleMetadata(rule_id="EF301", category="Hierarchy")
    ),
    EmptyArmatureRule(
        metadata=RuleMetadata(rule_id="EF302", category="Hierarchy")
    ),
    ArmatureHasBonesRule(
        metadata=RuleMetadata(rule_id="EF303", category="Hierarchy")
    ),
    SingleRootBoneRule(
        metadata=RuleMetadata(rule_id="EF304", category="Hierarchy")
    ),
    ArmatureTransformRule(
        metadata=RuleMetadata(rule_id="EF201", category="Transform")
    ),
    BoneNameRule(
        metadata=RuleMetadata(rule_id="EF101", category="Bone")
    ),
)

DEFAULT_REGISTRY = RuleRegistry(DEFAULT_RULES)

__all__ = [
    "ArmatureHasBonesRule",
    "ArmatureTransformRule",
    "BoneNameRule",
    "DEFAULT_REGISTRY",
    "DEFAULT_RULES",
    "EmptyArmatureRule",
    "RuleMetadata",
    "RuleRegistry",
    "SingleRootBoneRule",
    "TargetIsArmatureRule",
    "ValidationRule",
]
