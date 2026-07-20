"""Package specification for the missing .L/.R suffix rule."""

from __future__ import annotations

from excelion_forge.core.rules.spec import RulePackageSpec

from .api import validate
from .metadata import METADATA


SPEC = RulePackageSpec(metadata=METADATA, validate=validate)
