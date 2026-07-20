"""Blender operators for Excelion Forge."""

from __future__ import annotations

import bpy  # type: ignore

from .export import EFORGE_OT_export_html
from .export import EFORGE_OT_export_json
from .fix_manager import EFORGE_OT_fix_all_issues
from .fix_manager import EFORGE_OT_fix_issue
from .result_actions import EFORGE_OT_select_result_target
from .rig_validation import EFORGE_OT_validate_active_rig
from .pose_mirror import EFORGE_OT_mirror_pose

CLASSES: tuple[type[bpy.types.Operator], ...] = (
    EFORGE_OT_validate_active_rig,
    EFORGE_OT_fix_issue,
    EFORGE_OT_fix_all_issues,
    EFORGE_OT_select_result_target,
    EFORGE_OT_export_json,
    EFORGE_OT_export_html,
    EFORGE_OT_mirror_pose,
)

__all__ = [
    "EFORGE_OT_validate_active_rig",
    "EFORGE_OT_fix_issue",
    "EFORGE_OT_fix_all_issues",
    "EFORGE_OT_select_result_target",
    "EFORGE_OT_export_json",
    "EFORGE_OT_export_html",
    "EFORGE_OT_mirror_pose",
]


def register() -> None:
    """Register Excelion Forge operators."""
    for blender_class in CLASSES:
        bpy.utils.register_class(blender_class)


def unregister() -> None:
    """Unregister Excelion Forge operators."""
    for blender_class in reversed(CLASSES):
        bpy.utils.unregister_class(blender_class)
