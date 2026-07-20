"""Index-only registry for rule package plugins."""

from __future__ import annotations


class DuplicateRulePackageError(ValueError):
    """Raised when a duplicate rule package identifier is registered."""


class RulePackageRegistry:
    """Index rule package identifiers to package paths."""

    def __init__(self, index: dict[str, str] | None = None) -> None:
        self._index: dict[str, str] = dict(index or {})

    def __len__(self) -> int:
        return len(self._index)

    def register(self, rule_id: str, package_name: str) -> None:
        if rule_id in self._index:
            raise DuplicateRulePackageError(f"Duplicate rule package id: {rule_id}")
        self._index[rule_id] = package_name

    def get(self, rule_id: str) -> str | None:
        return self._index.get(rule_id)

    def get_all(self) -> tuple[tuple[str, str], ...]:
        return tuple(self._index.items())
