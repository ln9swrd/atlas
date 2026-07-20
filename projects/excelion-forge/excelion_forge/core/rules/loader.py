"""Loader for rule package plugins."""

from __future__ import annotations

import importlib
import pkgutil
from functools import lru_cache
from typing import Iterable

from .package_registry import RulePackageRegistry
from .registry_index import RULE_PACKAGE_INDEX
from .spec import RulePackageSpec


class RulePackageLoadError(Exception):
    """Raised when a rule package cannot be loaded or validated."""


_DEFAULT_PACKAGE_REGISTRY = RulePackageRegistry(RULE_PACKAGE_INDEX)


def _load_package_spec(package_name: str) -> RulePackageSpec:
    try:
        package_module = importlib.import_module(package_name)
    except Exception as exc:
        raise RulePackageLoadError(f"Failed to import rule package '{package_name}'") from exc

    if not hasattr(package_module, "SPEC"):
        raise RulePackageLoadError(
            f"Rule package '{package_name}' must expose SPEC"
        )

    spec = getattr(package_module, "SPEC")
    if not isinstance(spec, RulePackageSpec):
        raise RulePackageLoadError(
            f"SPEC in package '{package_name}' must be a RulePackageSpec"
        )

    return spec


@lru_cache(maxsize=None)
def load_rule_spec(rule_id: str, registry: RulePackageRegistry | None = None) -> RulePackageSpec:
    registry = registry or _DEFAULT_PACKAGE_REGISTRY
    package_name = registry.get(rule_id)
    if package_name is None:
        raise RulePackageLoadError(f"Unknown rule id '{rule_id}'")

    spec = _load_package_spec(package_name)
    if spec.metadata.rule_id != rule_id:
        raise RulePackageLoadError(
            f"Spec for package '{package_name}' declares rule id '{spec.metadata.rule_id}', expected '{rule_id}'"
        )

    return spec


def iter_registered_rule_ids(registry: RulePackageRegistry | None = None) -> Iterable[str]:
    registry = registry or _DEFAULT_PACKAGE_REGISTRY
    for rule_id, _package_name in registry.get_all():
        yield rule_id


def iter_rule_package_specs(registry: RulePackageRegistry | None = None) -> Iterable[RulePackageSpec]:
    registry = registry or _DEFAULT_PACKAGE_REGISTRY
    for rule_id in iter_registered_rule_ids(registry):
        yield load_rule_spec(rule_id, registry)


def iter_rule_packages(package_root: str) -> Iterable[RulePackageSpec]:
    package = importlib.import_module(package_root)
    for finder, name, ispkg in pkgutil.iter_modules(package.__path__, package.__name__ + "."):
        if not ispkg:
            continue

        yield _load_package_spec(name)
