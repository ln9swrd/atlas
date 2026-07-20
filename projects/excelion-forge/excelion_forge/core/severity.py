"""Validation severity levels."""

from __future__ import annotations

from enum import Enum


class Severity(Enum):
    """Severity assigned to a validation issue."""

    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
