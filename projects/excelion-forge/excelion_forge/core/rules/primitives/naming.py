"""Reusable naming primitives for validation rules."""

from __future__ import annotations

import re
from string import Formatter
from typing import Iterable


DEFAULT_UNIQUE_NAME_PATTERN = "{base}_{n}"
REQUIRED_PATTERN_KEYS = {"base", "n"}
ALLOWED_NAME_PATTERN = re.compile(r"^[A-Za-z0-9_.\- ]+$")
INVALID_NAME_CHARACTER_PATTERN = re.compile(r"[^A-Za-z0-9_.\- ]+")


class InvalidNamingPatternError(ValueError):
    """Raised when a naming pattern is missing required formatting keys."""


def validate_unique_name_pattern(pattern: str) -> None:
    """Validate that the pattern contains required formatting fields."""
    fields = {
        field_name
        for _, field_name, _, _ in Formatter().parse(pattern)
        if field_name
    }

    missing = REQUIRED_PATTERN_KEYS - fields
    if missing:
        raise InvalidNamingPatternError(
            f"Naming pattern must include {sorted(REQUIRED_PATTERN_KEYS)}."
        )


def make_unique_name(
    name: str,
    existing: Iterable[str],
    pattern: str = DEFAULT_UNIQUE_NAME_PATTERN,
    start: int = 2,
) -> str:
    """Return a unique name by appending the lowest available numeric suffix.

    The suffix pattern can be customized to support Blender-style naming.
    """
    validate_unique_name_pattern(pattern)

    base = str(name).strip()
    if not base:
        return base

    existing_set = set(existing)
    if base not in existing_set:
        return base

    index = start
    candidate = pattern.format(base=base, n=index)
    while candidate in existing_set:
        index += 1
        candidate = pattern.format(base=base, n=index)

    return candidate


def sanitize_name(name: str, replacement: str = "_") -> str:
    """Replace invalid characters in a name with a safe replacement."""
    raw_name = str(name)
    sanitized = INVALID_NAME_CHARACTER_PATTERN.sub(replacement, raw_name)
    if replacement:
        sanitized = re.sub(rf"{re.escape(replacement)}+", replacement, sanitized)
        sanitized = sanitized.strip(replacement + " ")
    return sanitized or "Unnamed"
