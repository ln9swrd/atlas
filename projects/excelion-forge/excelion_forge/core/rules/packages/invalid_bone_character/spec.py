"""Package specification for the invalid bone character rule."""

from __future__ import annotations

from excelion_forge.core.rules.spec import RulePackageSpec

from .api import autofix, validate
from .metadata import METADATA


SPEC = RulePackageSpec(metadata=METADATA, validate=validate, autofix=autofix)
