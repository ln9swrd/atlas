"""Operators for interacting with validation result items."""

from __future__ import annotations

import bpy  # type: ignore


class EFORGE_OT_select_result_target(bpy.types.Operator):
    """Select the object or bone referenced by a validation result."""

    bl_idname = "excelion_forge.select_result_target"
    bl_label = "Select Target"
    bl_description = "Select the object or bone associated with this issue"
    bl_options = {"REGISTER", "UNDO"}

    location_type: bpy.props.StringProperty()  # type: ignore
    object_name: bpy.props.StringProperty()  # type: ignore
    bone_name: bpy.props.StringProperty()  # type: ignore

    def execute(self, context: bpy.types.Context) -> set[str]:
        """Select the referenced object or bone in the viewport."""
        if self.location_type == "object":
            return self._select_object(context)
        if self.location_type == "bone":
            return self._select_bone(context)
        self.report({"INFO"}, "This issue has no selectable target.")
        return {"CANCELLED"}

    def _select_object(self, context: bpy.types.Context) -> set[str]:
        """Deselect all and select the named object."""
        obj = bpy.data.objects.get(self.object_name)
        if obj is None:
            self.report({"WARNING"}, f"Object '{self.object_name}' not found.")
            return {"CANCELLED"}

        if bpy.ops.object.mode_set.poll():
            bpy.ops.object.mode_set(mode="OBJECT")

        bpy.ops.object.select_all(action="DESELECT")
        obj.select_set(True)
        context.view_layer.objects.active = obj
        return {"FINISHED"}

    def _select_bone(self, context: bpy.types.Context) -> set[str]:
        """Select the named bone on the active armature in Pose Mode."""
        armature_obj = context.active_object
        if armature_obj is None or armature_obj.type != "ARMATURE":
            self.report({"WARNING"}, "No active armature to select bone on.")
            return {"CANCELLED"}

        armature_data = armature_obj.data
        if self.bone_name not in armature_data.bones:
            self.report({"WARNING"}, f"Bone '{self.bone_name}' not found.")
            return {"CANCELLED"}

        if context.mode != "POSE":
            bpy.ops.object.mode_set(mode="POSE")

        bpy.ops.pose.select_all(action="DESELECT")
        pose_bone = armature_obj.pose.bones.get(self.bone_name)
        if pose_bone:
            pose_bone.bone.select = True
            armature_data.bones.active = armature_data.bones[self.bone_name]

        return {"FINISHED"}


CLASSES = (EFORGE_OT_select_result_target,)


def register() -> None:
    """Register result action operators."""
    for blender_class in CLASSES:
        bpy.utils.register_class(blender_class)


def unregister() -> None:
    """Unregister result action operators."""
    for blender_class in reversed(CLASSES):
        bpy.utils.unregister_class(blender_class)
