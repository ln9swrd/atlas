"""User interface panels for Excelion Forge."""

from __future__ import annotations

import bpy  # type: ignore

from .panels import EFORGE_PT_rig_tools

CLASSES: tuple[type[bpy.types.Panel], ...] = (
    EFORGE_PT_rig_tools,
)


def register() -> None:
    """Register Excelion Forge UI panels."""
    for blender_class in CLASSES:
        bpy.utils.register_class(blender_class)


def unregister() -> None:
    """Unregister Excelion Forge UI panels."""
    for blender_class in reversed(CLASSES):
        bpy.utils.unregister_class(blender_class)
