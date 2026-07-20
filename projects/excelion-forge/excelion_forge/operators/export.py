"""Export operators for Excelion Forge validation results."""

from __future__ import annotations

import bpy  # type: ignore

from excelion_forge.core.html_report import default_html_filename
from excelion_forge.core.html_report import export_html
from excelion_forge.core.serializer import default_json_filename
from excelion_forge.core.serializer import export_json
from excelion_forge.utils import get_active_target


class EFORGE_OT_export_json(bpy.types.Operator):
    """Export the current validation session to a JSON file."""

    bl_idname = "excelion_forge.export_json"
    bl_label = "Export JSON"
    bl_description = "Save validation results as a JSON file"

    filepath: bpy.props.StringProperty(subtype="FILE_PATH")  # type: ignore
    filename_ext = ".json"
    filter_glob: bpy.props.StringProperty(default="*.json", options={"HIDDEN"})  # type: ignore

    def invoke(self, context: bpy.types.Context, event: object) -> set[str]:  # noqa: ARG002
        """Open the file selection dialog with a timestamped default filename."""
        self.filepath = default_json_filename()
        context.window_manager.fileselect_add(self)
        return {"RUNNING_MODAL"}

    def execute(self, context: bpy.types.Context) -> set[str]:
        """Write the JSON file to the selected path."""
        session = context.window_manager.excelion_forge_session
        if not session.has_run:
            self.report({"WARNING"}, "No validation results to export. Run validation first.")
            return {"CANCELLED"}

        target = get_active_target(context)
        target_name = str(getattr(target, "name", "")) if target else ""

        try:
            export_json(session, self.filepath, target_name)
        except OSError as exc:
            self.report({"ERROR"}, f"Could not write file: {exc}")
            return {"CANCELLED"}

        self.report({"INFO"}, f"Exported JSON: {self.filepath}")
        return {"FINISHED"}


class EFORGE_OT_export_html(bpy.types.Operator):
    """Export the current validation session to an HTML report."""

    bl_idname = "excelion_forge.export_html"
    bl_label = "Export HTML"
    bl_description = "Save validation results as an HTML report"

    filepath: bpy.props.StringProperty(subtype="FILE_PATH")  # type: ignore
    filename_ext = ".html"
    filter_glob: bpy.props.StringProperty(default="*.html", options={"HIDDEN"})  # type: ignore

    def invoke(self, context: bpy.types.Context, event: object) -> set[str]:  # noqa: ARG002
        """Open the file selection dialog with a timestamped default filename."""
        self.filepath = default_html_filename()
        context.window_manager.fileselect_add(self)
        return {"RUNNING_MODAL"}

    def execute(self, context: bpy.types.Context) -> set[str]:
        """Write the HTML report to the selected path."""
        session = context.window_manager.excelion_forge_session
        if not session.has_run:
            self.report({"WARNING"}, "No validation results to export. Run validation first.")
            return {"CANCELLED"}

        target = get_active_target(context)
        target_name = str(getattr(target, "name", "")) if target else ""

        try:
            export_html(session, self.filepath, target_name)
        except OSError as exc:
            self.report({"ERROR"}, f"Could not write file: {exc}")
            return {"CANCELLED"}

        self.report({"INFO"}, f"Exported HTML: {self.filepath}")
        return {"FINISHED"}


CLASSES = (EFORGE_OT_export_json, EFORGE_OT_export_html)


def register() -> None:
    """Register export operators."""
    for blender_class in CLASSES:
        bpy.utils.register_class(blender_class)


def unregister() -> None:
    """Unregister export operators."""
    for blender_class in reversed(CLASSES):
        bpy.utils.unregister_class(blender_class)
