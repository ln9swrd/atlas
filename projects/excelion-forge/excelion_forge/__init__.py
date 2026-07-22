"""Blender addon entry point for Excelion Forge."""

from __future__ import annotations

bl_info = {
    "name": "Excelion Forge",
    "author": "EXCELION",
    "version": (1, 0, 0),
    "blender": (5, 0, 0),
    "location": "View3D > Sidebar > Excelion",
    "description": "Rig validation and production utilities for Excelion assets.",
    "category": "Rigging",
}


def register() -> None:
    """Register all Excelion Forge Blender classes."""
    from . import properties
    from . import operators
    from . import ui

    properties.register()
    operators.register()
    ui.register()


def unregister() -> None:
    """Unregister all Excelion Forge Blender classes."""
    from . import properties
    from . import operators
    from . import ui

    ui.unregister()
    operators.unregister()
    properties.unregister()
