"""Operators for rig validation workflows."""

from __future__ import annotations

import bpy  # type: ignore

from excelion_forge.core import RuleManager
from excelion_forge.utils import get_active_target


class EFORGE_OT_validate_active_rig(bpy.types.Operator):
    """Validate the active target and report the result."""

    bl_idname = "excelion_forge.validate_active_rig"
    bl_label = "Validate Active Rig"
    bl_description = "Validate the selected armature for basic readiness"
    bl_options = {"REGISTER"}

    @classmethod
    def poll(cls, context: bpy.types.Context) -> bool:
        """Return whether Blender supplied an execution context."""
        return context is not None

    def execute(self, context: bpy.types.Context) -> set[str]:
        """Run validation for the active target and cache results."""
        import json
        from excelion_forge.core import DEFAULT_RULES

        target = get_active_target(context)
        session = context.window_manager.excelion_forge_session

        _ensure_session_rules(session)

        # Filter rules by their enabled status in the session
        enabled_rule_ids = {r.rule_id for r in session.rules if r.enabled}
        active_rules = tuple(
            rule for rule in DEFAULT_RULES
            if rule.__class__.__name__ in enabled_rule_ids
        )

        report = RuleManager(rules=active_rules).validate(target)
        target_name = _get_target_name(target)

        # Update session cache
        session.issues.clear()
        errors_cnt = 0
        warnings_cnt = 0
        infos_cnt = 0

        for issue in report.issues:
            item = session.issues.add()
            item.severity = issue.severity.value
            item.code = issue.code
            item.message = issue.message
            item.rule_name = issue.rule_name
            item.location_type = issue.location_type
            item.object_name = issue.object_name or ""
            item.bone_name = issue.bone_name or ""
            item.suggestion = issue.suggestion or ""
            if issue.fix_suggestion:
                item.has_fix = True
                item.fix_action_code = issue.fix_suggestion.action_code
                item.fix_params_json = json.dumps(issue.fix_suggestion.params)
            else:
                item.has_fix = False
                item.fix_action_code = ""
                item.fix_params_json = ""

            if issue.severity.value == "ERROR":
                errors_cnt += 1
            elif issue.severity.value == "WARNING":
                warnings_cnt += 1
            elif issue.severity.value == "INFO":
                infos_cnt += 1

        session.error_count = errors_cnt
        session.warning_count = warnings_cnt
        session.info_count = infos_cnt
        session.has_run = True

        from excelion_forge.properties import rebuild_display_issues
        rebuild_display_issues(session)

        if not report.issues:
            self.report(
                {"INFO"},
                f"Target '{target_name}' passed validation.",
            )
        else:
            self.report(
                {"WARNING"},
                f"Target '{target_name}' needs attention. Check panel for details.",
            )
        return {"FINISHED"}


def _get_target_name(target: object) -> str:
    """Return a safe display name for an optional validation target."""
    return str(getattr(target, "name", "No Target"))


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
