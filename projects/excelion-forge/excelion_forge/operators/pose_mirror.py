"""Blender operators for pose mirroring workflows."""

from __future__ import annotations

import bpy  # type: ignore

from excelion_forge.core import mirror_pose
from excelion_forge.utils import get_active_target


class EFORGE_OT_mirror_pose(bpy.types.Operator):
    """Mirror the active armature's pose."""

    bl_idname = "excelion_forge.mirror_pose"
    bl_label = "Mirror Pose"
    bl_description = (
        "Mirror the active armature's pose (swaps L/R bone transforms and self-mirrors Center bones)"
    )
    bl_options = {"REGISTER", "UNDO"}

    selected_only: bpy.props.BoolProperty(
        name="Selected Only",
        description="Mirror only the selected pose bones",
        default=False,
    )

    @classmethod
    def poll(cls, context: bpy.types.Context) -> bool:
        """Only allow execution when there is an active armature in Pose Mode."""
        if context is None:
            return False
        target = get_active_target(context)
        if target is None:
            return False
        # To edit pose transforms, target needs to be an Armature
        return getattr(target, "type", None) == "ARMATURE"

    def execute(self, context: bpy.types.Context) -> set[str]:
        """Perform pose mirroring operations."""
        target = get_active_target(context)
        if target is None:
            self.report({"WARNING"}, "No validation target selected.")
            return {"CANCELLED"}

        if getattr(target, "type", None) != "ARMATURE":
            self.report({"WARNING"}, "Selected target is not an armature.")
            return {"CANCELLED"}

        modified_count = mirror_pose(target, selected_only=self.selected_only)

        if modified_count > 0:
            scope = "selected" if self.selected_only else "all"
            self.report(
                {"INFO"},
                f"Successfully mirrored pose for {modified_count} {scope} bone(s).",
            )
        else:
            self.report(
                {"INFO"},
                "No bones were modified during pose mirroring.",
            )

        return {"FINISHED"}
