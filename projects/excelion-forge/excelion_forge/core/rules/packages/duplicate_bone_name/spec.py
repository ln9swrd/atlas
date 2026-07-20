"""Package specification for the duplicate bone name rule."""

from __future__ import annotations

from excelion_forge.core.rules.spec import RulePackageSpec

from .api import autofix, validate
from .metadata import METADATA


SPEC = RulePackageSpec(metadata=METADATA, validate=validate, autofix=autofix)
