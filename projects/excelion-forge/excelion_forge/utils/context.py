"""Context helpers for Blender operators and panels."""

from __future__ import annotations

import bpy  # type: ignore


def get_active_target(
    context: bpy.types.Context,
) -> bpy.types.Object | None:
    """Return the active object selected for validation."""
    return getattr(context, "active_object", None)
