"""Static index of available rule package identifiers."""

from __future__ import annotations

RULE_PACKAGE_INDEX: dict[str, str] = {
    "EF101": "excelion_forge.core.rules.packages.duplicate_bone_name",
    "EF102": "excelion_forge.core.rules.packages.invalid_bone_character",
    "EF103": "excelion_forge.core.rules.packages.missing_lr_suffix",
}
