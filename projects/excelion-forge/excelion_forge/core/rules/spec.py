"""Rule package specification for validation plugins."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Optional, Protocol

from .metadata import RuleMetadata

if TYPE_CHECKING:
    from ..models import ArmatureModel


class ValidatorFn(Protocol):
    """Callable protocol for rule validation functions."""

    def __call__(self, armature: ArmatureModel) -> list[object]:
        ...


class AutofixFn(Protocol):
    """Callable protocol for rule autofix functions."""

    def __call__(self, armature: ArmatureModel) -> list[object]:
        ...


@dataclass(frozen=True)
class RulePackageSpec:
    """Declarative ABI for a rule package."""

    metadata: RuleMetadata
    validate: ValidatorFn
    autofix: Optional[AutofixFn] = None

    def __post_init__(self) -> None:
        if not callable(self.validate):
            raise TypeError("validate must be callable")

        if self.autofix is not None and not callable(self.autofix):
            raise TypeError("autofix must be callable or None")
