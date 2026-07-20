"""Metadata contracts for validation rules."""

from __future__ import annotations

import re
from dataclasses import dataclass
from dataclasses import replace
from enum import Enum

from excelion_forge.core.severity import Severity


RULE_ID_PATTERN = re.compile(r"^EF(\d+)$")


class RuleCategory(str, Enum):
    """Domain-oriented rule categories."""

    BONE = ("Bone", 100)
    TRANSFORM = ("Transform", 200)
    HIERARCHY = ("Hierarchy", 300)
    WEIGHT = ("Weight", 400)
    CONSTRAINT = ("Constraint", 500)
    EXPORT = ("Export", 600)
    INTERNAL = ("Internal", 900)

    def __new__(cls, value: str, base: int):
        obj = str.__new__(cls, value)
        obj._value_ = value
        obj._base = base
        return obj

    @property
    def base(self) -> int:
        return self._base

    @property
    def id_range(self) -> range:
        return range(self.base, self.base + 100)


CATEGORY_BASE = {category: category.base for category in RuleCategory}


class InvalidRuleCategoryError(ValueError):
    """Raised when a rule category is not supported by the ID generator."""


class InvalidRuleMetadataError(ValueError):
    """Raised when rule metadata is invalid."""


def normalize_category(category: RuleCategory | str) -> RuleCategory:
    """Normalize a category value to the canonical RuleCategory enum."""
    if isinstance(category, RuleCategory):
        return category

    if isinstance(category, str):
        normalized = category.strip().casefold()
        for member in RuleCategory:
            if member.value.casefold() == normalized:
                return member

    raise InvalidRuleCategoryError(f"Unknown category: {category}")


def parse_rule_number(rule_id: str) -> int:
    """Return the numeric portion of an EF rule id and validate its range."""
    if not isinstance(rule_id, str):
        raise InvalidRuleMetadataError(
            f"Invalid rule id '{rule_id}'. Expected a string."
        )

    normalized = rule_id.strip()
    match = RULE_ID_PATTERN.fullmatch(normalized)
    if match is None:
        raise InvalidRuleMetadataError(
            f"Invalid rule id '{rule_id}'. Expected format EF###"
        )

    value = int(match.group(1))
    if value < 100 or value > 999:
        raise InvalidRuleMetadataError(
            f"Invalid rule id '{rule_id}'. Expected EF### with a three-digit number."
        )

    return value


def rule_id_for(category: RuleCategory | str, number: int) -> str:
    """Return a stable EF### rule id for a category and numeric slot."""
    category_value = normalize_category(category)
    if number < 0:
        raise ValueError("number must be >= 0")

    value = category_value.base + number
    if value >= category_value.base + 100:
        raise ValueError(f"{category_value.value} range exhausted")

    return f"EF{value:03d}"


@dataclass(frozen=True)
class RuleMetadata:
    """Immutable metadata describing a validation rule."""

    rule_id: str
    category: RuleCategory | str = RuleCategory.INTERNAL
    severity: Severity = Severity.ERROR

    def __post_init__(self) -> None:
        parse_rule_number(self.rule_id)

        try:
            object.__setattr__(self, "category", normalize_category(self.category))
        except InvalidRuleCategoryError as exc:
            raise InvalidRuleMetadataError(
                f"Unknown category: {self.category}"
            ) from exc

    def with_severity(self, severity: Severity) -> "RuleMetadata":
        """Return a copy with a different severity."""
        return replace(self, severity=severity)

    @property
    def rule_number(self) -> int:
        """Return the numeric portion of the rule identifier."""
        return parse_rule_number(self.rule_id)
