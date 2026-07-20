"""Executor for rule package plugins."""

from __future__ import annotations

from typing import TYPE_CHECKING, Iterable

from .spec import RulePackageSpec

if TYPE_CHECKING:
    from ..models import ArmatureModel


def _to_armature_model(target: object) -> ArmatureModel:
    """Convert target to ArmatureModel.
    
    If target is already ArmatureModel, return as-is.
    If target is Blender armature object, convert via adapter.
    Otherwise raise TypeError.
    """
    from ..models import ArmatureModel
    from ...adapters import BlenderArmatureAdapter
    
    if isinstance(target, ArmatureModel):
        return target
    
    # Try Blender adapter
    if hasattr(target, "type") and hasattr(target, "data"):
        return BlenderArmatureAdapter.extract(target)
    
    raise TypeError(
        f"run_validation/run_autofix expects ArmatureModel or Blender object, got {type(target).__name__}"
    )


def run_validation(rule_specs: Iterable[RulePackageSpec], target: object) -> list[dict[str, object]]:
    armature = _to_armature_model(target)
    issues: list[dict[str, object]] = []
    for spec in rule_specs:
        raw_issues = spec.validate(armature)
        issues.extend(raw_issues)
    return issues


def run_autofix(rule_specs: Iterable[RulePackageSpec], target: object) -> list[dict[str, object]]:
    armature = _to_armature_model(target)
    operations: list[dict[str, object]] = []
    for spec in rule_specs:
        if spec.autofix is None:
            continue
        raw_operations = spec.autofix(armature)
        operations.extend(raw_operations)
    return operations
