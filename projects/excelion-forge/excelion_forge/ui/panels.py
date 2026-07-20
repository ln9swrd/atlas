"""3D View UI panels for Excelion Forge."""

from __future__ import annotations

import bpy  # type: ignore

from excelion_forge.utils import get_active_target


class EFORGE_PT_rig_tools(bpy.types.Panel):
    """Display rigging tools in the 3D View sidebar."""

    bl_label = "Excelion Forge"
    bl_idname = "EFORGE_PT_rig_tools"
    bl_space_type = "VIEW_3D"
    bl_region_type = "UI"
    bl_category = "Excelion"

    def draw(self, context: bpy.types.Context) -> None:
        """Draw the rigging tools panel."""
        layout = self.layout
        target = get_active_target(context)
        session = context.window_manager.excelion_forge_session

        _ensure_session_rules(session)

        # 1. Target Information Box
        box = layout.box()
        box.label(text="Validation Target", icon="OBJECT_DATA")
        if target is None:
            box.label(text="No active object selected", icon="INFO")
        else:
            icon = "OUTLINER_OB_ARMATURE" if target.type == "ARMATURE" else "OBJECT_DATAMODE"
            box.label(text=f"Active Object: {target.name}", icon=icon)

        # 2. Rules Configuration Section
        col = layout.column(align=True)
        col.label(text="Rules Configuration:")

        rules_box = col.box()
        for rule_state in session.rules:
            row = rules_box.row()
            row.prop(rule_state, "enabled", text=rule_state.name)

        # 3. Validation Action Button
        layout.separator()
        layout.operator(
            "excelion_forge.validate_active_rig",
            text="Validate Active Rig",
            icon="CHECKMARK",
        )

        # 4. Results Section
        if not session.has_run:
            return

        layout.separator()
        results_box = layout.box()
        results_box.label(text="Validation Results", icon="REPORT")

        # 4a. Summary row
        summary_row = results_box.row(align=True)
        summary_row.label(
            text=f"Errors: {session.error_count}",
            icon="CANCEL" if session.error_count else "CHECKMARK",
        )
        summary_row.label(
            text=f"Warnings: {session.warning_count}",
            icon="ERROR" if session.warning_count else "CHECKMARK",
        )
        summary_row.label(text=f"Infos: {session.info_count}", icon="INFO")

        if not session.issues:
            results_box.label(text="All checks passed successfully!", icon="SOLO_ON")
            # Export buttons even when all pass
            _draw_export_row(results_box)
            return

        # 4b. Severity filter
        filter_row = results_box.row(align=True)
        filter_row.prop(session, "severity_filter", expand=True)

        # 4c. Search box
        search_row = results_box.row(align=True)
        search_row.prop(session, "search_query", text="", icon="VIEWZOOM")

        # 4c'. Sort by
        sort_row = results_box.row(align=True)
        sort_row.label(text="Sort:", icon="SORTALPHA")
        sort_row.prop(session, "sort_by", expand=True)

        # 4d. Fix All button (only when fixable issues exist)
        has_any_fix = any(issue.has_fix for issue in session.issues)
        if has_any_fix:
            fix_row = results_box.row()
            fix_row.operator(
                "excelion_forge.fix_all_issues",
                text="Auto Fix All",
                icon="TOOL",
            )

        # 4d'. Export buttons (always shown after validation run)
        _draw_export_row(results_box)

        results_box.separator()

        # 4e. Issue list ??from display_issues cache (no filtering in draw)
        display_count = len(session.display_issues)
        total_count = len(session.issues)

        if display_count == 0:
            results_box.label(text="No results match the current filter.", icon="INFO")
            return

        if display_count < total_count:
            results_box.label(
                text=f"Showing {display_count} of {total_count} issues",
                icon="FILTER",
            )

        for issue in session.display_issues:
            issue_box = results_box.box()

            # Row 1: severity icon + message + select button
            icon_name = (
                "CANCEL" if issue.severity == "ERROR"
                else ("ERROR" if issue.severity == "WARNING" else "INFO")
            )
            row1 = issue_box.row(align=True)
            row1.label(text=f"[{issue.code}] {issue.message}", icon=icon_name)

            if issue.location_type != "none":
                op = row1.operator(
                    "excelion_forge.select_result_target",
                    text="",
                    icon="RESTRICT_SELECT_OFF",
                )
                op.location_type = issue.location_type
                op.object_name = issue.object_name
                op.bone_name = issue.bone_name

            # Row 2: suggestion if available
            if issue.suggestion:
                row2 = issue_box.row()
                row2.label(text=f"Suggest: {issue.suggestion}")

            # Row 3: Auto Fix button if supported
            if issue.has_fix:
                row3 = issue_box.row()
                row3.alignment = "RIGHT"
                op = row3.operator(
                    "excelion_forge.fix_issue",
                    text="Auto Fix",
                    icon="TOOL",
                )
                op.action_code = issue.fix_action_code
                op.params_json = issue.fix_params_json


def _ensure_session_rules(session: object) -> None:
    """Populate default rules in session rules collection if not present."""
    rules_col = getattr(session, "rules", None)
    if rules_col is None or len(rules_col) > 0:
        return
    from excelion_forge.core import DEFAULT_RULES
    for rule in DEFAULT_RULES:
        item = rules_col.add()
        item.rule_id = rule.__class__.__name__
        item.name = rule.name
        item.description = rule.description
        item.enabled = True


def _draw_export_row(layout: bpy.types.UILayout) -> None:
    """Draw the JSON and HTML export operator buttons side by side."""
    row = layout.row(align=True)
    row.operator(
        "excelion_forge.export_json",
        text="Export JSON",
        icon="FILE_TEXT",
    )
    row.operator(
        "excelion_forge.export_html",
        text="Export HTML",
        icon="FILE",
    )

