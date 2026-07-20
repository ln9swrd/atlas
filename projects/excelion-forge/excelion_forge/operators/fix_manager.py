"""Fix manager for executing automatic validation fixes in Blender."""

from __future__ import annotations

import json
import bpy  # type: ignore


class FixManager:
    """Implement logic for auto-fixing validation issues in Blender."""

    FIX_HANDLERS = {
        "APPLY_TRANSFORMS": "_apply_transforms",
        "RENAME_EMPTY_BONE": "_rename_empty_bones",
        "RENAME_DUPLICATE_BONE": "_rename_duplicate_bones",
    }

    @classmethod
    def fix_issue(
        cls,
        context: "Any",
        action_code: str,
        params: dict[str, str],
    ) -> bool:
        """Dispatch execution to the appropriate fix implementation."""
        method_name = cls.FIX_HANDLERS.get(action_code)
        if method_name:
            handler = getattr(cls, method_name)
            return handler(context, params)
        return False

    @classmethod
    def _apply_transforms(
        cls,
        context: "Any",
        params: dict[str, str],
    ) -> bool:
        """Apply location, rotation, and scale transforms on the active object."""
        target = getattr(context, "active_object", None)
        if target is None or target.type != "ARMATURE":
            return False

        original_mode = context.mode

        # Ensure we are in object mode to apply transforms
        if original_mode != "OBJECT":
            # best-effort: try runtime operator or fall back to bpy
            try:
                runtime = getattr(context, "runtime", None) or (
                    context.get_runtime() if hasattr(context, "get_runtime") else None
                )
            except Exception:
                runtime = None

            if runtime is None:
                if bpy.ops.object.mode_set.poll():
                    bpy.ops.object.mode_set(mode="OBJECT")
            else:
                runtime.run_operator("object.mode_set", mode="OBJECT")

        # Select target to ensure transform_apply operates on it
        original_selected = target.select_get()
        target.select_set(True)

        try:
            # Use runtime if available
            try:
                runtime = getattr(context, "runtime", None) or (
                    context.get_runtime() if hasattr(context, "get_runtime") else None
                )
            except Exception:
                runtime = None

            if runtime is not None:
                runtime.run_operator("object.transform_apply", location=True, rotation=True, scale=True)
                success = True
            else:
                bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
                success = True
        except RuntimeError:
            success = False

        target.select_set(original_selected)

        # Restore original mode
        if context.mode != original_mode:
            try:
                runtime = getattr(context, "runtime", None) or (
                    context.get_runtime() if hasattr(context, "get_runtime") else None
                )
            except Exception:
                runtime = None

            if runtime is None:
                if bpy.ops.object.mode_set.poll():
                    bpy.ops.object.mode_set(mode=original_mode)
            else:
                runtime.run_operator("object.mode_set", mode=original_mode)

        return success

    @classmethod
    def _rename_empty_bones(
        cls,
        context: "Any",
        params: dict[str, str],
    ) -> bool:
        """Rename all bones with empty or whitespace-only names."""
        target = getattr(context, "active_object", None)
        if target is None or target.type != "ARMATURE":
            return False

        armature_data = getattr(target, "data", None)
        if armature_data is None:
            return False

        bones = getattr(armature_data, "bones", [])
        renamed_any = False
        for i, bone in enumerate(bones):
            if not bone.name.strip():
                bone.name = f"Bone_{i:03d}"
                renamed_any = True

        return renamed_any

    @classmethod
    def _rename_duplicate_bones(
        cls,
        context: "Any",
        params: dict[str, str],
    ) -> bool:
        """Rename duplicate bone names that normalize to the same value."""
        target = getattr(context, "active_object", None)
        if target is None or target.type != "ARMATURE":
            return False

        old_name = params.get("old_name")
        if not old_name:
            return False

        armature_data = getattr(target, "data", None)
        if armature_data is None:
            return False

        bones = getattr(armature_data, "bones", [])
        found_first = False
        renamed_any = False

        for bone in bones:
            normalized = bone.name.strip()
            if normalized == old_name:
                if not found_first:
                    found_first = True
                    # Let's clean the first one's trailing spaces if any
                    if bone.name != normalized:
                        bone.name = normalized
                        renamed_any = True
                else:
                    # Rename subsequent duplicate bones
                    bone.name = f"{normalized}_fixed"
                    renamed_any = True

        return renamed_any


class EFORGE_OT_fix_issue(bpy.types.Operator):
    """Auto fix an active validation issue."""

    bl_idname = "excelion_forge.fix_issue"
    bl_label = "Fix Validation Issue"
    bl_description = "Automatically fix the selected validation issue"
    bl_options = {"REGISTER", "UNDO"}

    action_code: bpy.props.StringProperty()  # type: ignore
    params_json: bpy.props.StringProperty()  # type: ignore

    def execute(self, context: bpy.types.Context) -> set[str]:
        """Execute the fix logic and rerun validation to update the UI."""
        params = {}
        if self.params_json:
            try:
                params = json.loads(self.params_json)
            except json.JSONDecodeError:
                self.report({"WARNING"}, "Invalid JSON parameters in fix request.")

        success = FixManager.fix_issue(context, self.action_code, params)

        if success:
            self.report({"INFO"}, "Validation issue fixed successfully.")
            # Automatically rerun validation to update the session cache
            # Try runtime integration if present on the context
            try:
                runtime = getattr(context, "runtime", None) or (
                    context.get_runtime() if hasattr(context, "get_runtime") else None
                )
            except Exception:
                runtime = None

            if runtime is not None:
                runtime.run_operator("excelion_forge.validate_active_rig")
            else:
                bpy.ops.excelion_forge.validate_active_rig()
        else:
            self.report({"WARNING"}, f"Could not fix issue: {self.action_code}")

        return {"FINISHED"}


class EFORGE_OT_fix_all_issues(bpy.types.Operator):
    """Apply all available auto fixes from the current validation session."""

    bl_idname = "excelion_forge.fix_all_issues"
    bl_label = "Auto Fix All"
    bl_description = "Automatically fix all issues that have a fix available"
    bl_options = {"REGISTER", "UNDO"}

    def execute(self, context: bpy.types.Context) -> set[str]:
        """Iterate session issues and apply every available fix."""
        session = context.window_manager.excelion_forge_session
        fixed = 0

        for issue in session.issues:
            if not issue.has_fix:
                continue
            params: dict[str, str] = {}
            if issue.fix_params_json:
                try:
                    import json as _json
                    params = _json.loads(issue.fix_params_json)
                except Exception:
                    pass
            if FixManager.fix_issue(context, issue.fix_action_code, params):
                fixed += 1

        if fixed:
            bpy.ops.excelion_forge.validate_active_rig()
            self.report({"INFO"}, f"Fixed {fixed} issue(s) automatically.")
        else:
            self.report({"INFO"}, "No fixable issues found.")

        return {"FINISHED"}


CLASSES = (EFORGE_OT_fix_issue, EFORGE_OT_fix_all_issues)


def register() -> None:
    """Register operators for fixing issues."""
    for blender_class in CLASSES:
        bpy.utils.register_class(blender_class)


def unregister() -> None:
    """Unregister operators for fixing issues."""
    for blender_class in reversed(CLASSES):
        bpy.utils.unregister_class(blender_class)
