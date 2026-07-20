"""Blender PropertyGroups for Excelion Forge validation session and UI configuration."""

from __future__ import annotations

import bpy  # type: ignore


class EFORGE_PG_validation_issue(bpy.types.PropertyGroup):
    """Represent a cached validation issue for UI rendering."""

    severity: bpy.props.StringProperty(name="Severity")  # type: ignore
    code: bpy.props.StringProperty(name="Code")  # type: ignore
    message: bpy.props.StringProperty(name="Message")  # type: ignore
    rule_name: bpy.props.StringProperty(name="Rule Name")  # type: ignore
    location_type: bpy.props.StringProperty(name="Location Type", default="none")  # type: ignore
    object_name: bpy.props.StringProperty(name="Object Name")  # type: ignore
    bone_name: bpy.props.StringProperty(name="Bone Name")  # type: ignore
    suggestion: bpy.props.StringProperty(name="Suggestion")  # type: ignore
    has_fix: bpy.props.BoolProperty(name="Has Fix", default=False)  # type: ignore
    fix_action_code: bpy.props.StringProperty(name="Fix Action Code")  # type: ignore
    fix_params_json: bpy.props.StringProperty(name="Fix Params JSON")  # type: ignore


class EFORGE_PG_validation_rule_state(bpy.types.PropertyGroup):
    """Represent the enable/disable state of a validation rule in the UI."""

    rule_id: bpy.props.StringProperty(name="Rule ID")  # type: ignore
    name: bpy.props.StringProperty(name="Name")  # type: ignore
    description: bpy.props.StringProperty(name="Description")  # type: ignore
    enabled: bpy.props.BoolProperty(name="Enabled", default=True)  # type: ignore


def _on_filter_update(self: "EFORGE_PG_validation_session", _context: object) -> None:
    """Rebuild display_issues when severity filter, search, or sort changes."""
    rebuild_display_issues(self)


class EFORGE_PG_validation_session(bpy.types.PropertyGroup):
    """Store the session validation results and rule configurations on WindowManager."""

    rules: bpy.props.CollectionProperty(type=EFORGE_PG_validation_rule_state)  # type: ignore
    issues: bpy.props.CollectionProperty(type=EFORGE_PG_validation_issue)  # type: ignore
    display_issues: bpy.props.CollectionProperty(type=EFORGE_PG_validation_issue)  # type: ignore
    has_run: bpy.props.BoolProperty(name="Has Run", default=False)  # type: ignore
    error_count: bpy.props.IntProperty(name="Error Count", default=0)  # type: ignore
    warning_count: bpy.props.IntProperty(name="Warning Count", default=0)  # type: ignore
    info_count: bpy.props.IntProperty(name="Info Count", default=0)  # type: ignore
    severity_filter: bpy.props.EnumProperty(  # type: ignore
        name="Severity Filter",
        items=[
            ("ALL", "All", "Show all results"),
            ("ERROR", "Error", "Show errors only"),
            ("WARNING", "Warning", "Show warnings only"),
            ("INFO", "Info", "Show info only"),
        ],
        default="ALL",
        update=_on_filter_update,  # type: ignore[name-defined]
    )
    search_query: bpy.props.StringProperty(  # type: ignore
        name="Search",
        description="Filter results by code or message",
        default="",
        update=_on_filter_update,  # type: ignore[name-defined]
    )
    sort_by: bpy.props.EnumProperty(  # type: ignore
        name="Sort By",
        items=[
            ("SEVERITY", "Severity", "Sort by severity level: ERROR first"),
            ("RULE_NAME", "Rule", "Sort by rule name alphabetically"),
            ("LOCATION", "Location", "Sort by object or bone name"),
        ],
        default="SEVERITY",
        update=_on_filter_update,  # type: ignore[name-defined]
    )


# ---------------------------------------------------------------------------
# Severity ordering for sorting
# ---------------------------------------------------------------------------

_SEVERITY_ORDER: dict[str, int] = {"ERROR": 0, "WARNING": 1, "INFO": 2}


def rebuild_display_issues(session: EFORGE_PG_validation_session) -> None:
    """Rebuild display_issues applying filter, sort, and search — no bpy.context access."""
    query = session.search_query.strip().lower()
    severity_filter = session.severity_filter
    sort_by = session.sort_by

    # 1. Filter from master list into a plain Python list
    filtered = [
        issue for issue in session.issues
        if _passes_filter(issue, severity_filter, query)
    ]

    # 2. Sort in-place (stable sort preserves insertion order for equal keys)
    filtered.sort(key=_make_sort_key(sort_by))

    # 3. Copy sorted results to display_issues cache
    session.display_issues.clear()
    for issue in filtered:
        _copy_issue_item(session.display_issues.add(), issue)


def _passes_filter(issue: object, severity_filter: str, query: str) -> bool:
    """Return True if the issue matches the active filter and search criteria."""
    if severity_filter != "ALL" and getattr(issue, "severity", "") != severity_filter:
        return False
    if query:
        msg = getattr(issue, "message", "").lower()
        code = getattr(issue, "code", "").lower()
        if query not in msg and query not in code:
            return False
    return True


def _make_sort_key(sort_by: str):
    """Return a sort key function for the given sort_by value."""
    def key(issue: object) -> tuple:
        sev = _SEVERITY_ORDER.get(getattr(issue, "severity", ""), 3)
        if sort_by == "RULE_NAME":
            return (getattr(issue, "rule_name", "").lower(), sev)
        if sort_by == "LOCATION":
            loc = (
                getattr(issue, "object_name", "")
                or getattr(issue, "bone_name", "")
                or ""
            ).lower()
            return (loc, sev)
        # Default: SEVERITY
        return (sev, getattr(issue, "code", ""))
    return key


def _copy_issue_item(
    dest: "EFORGE_PG_validation_issue",
    src: "EFORGE_PG_validation_issue",
) -> None:
    """Copy all fields from src issue to dest issue PropertyGroup item."""
    dest.severity = src.severity
    dest.code = src.code
    dest.message = src.message
    dest.rule_name = src.rule_name
    dest.location_type = src.location_type
    dest.object_name = src.object_name
    dest.bone_name = src.bone_name
    dest.suggestion = src.suggestion
    dest.has_fix = src.has_fix
    dest.fix_action_code = src.fix_action_code
    dest.fix_params_json = src.fix_params_json


CLASSES = (
    EFORGE_PG_validation_issue,
    EFORGE_PG_validation_rule_state,
    EFORGE_PG_validation_session,
)


def register() -> None:
    """Register all validation PropertyGroups and bind them to WindowManager."""
    for blender_class in CLASSES:
        bpy.utils.register_class(blender_class)

    bpy.types.WindowManager.excelion_forge_session = bpy.props.PointerProperty(
        type=EFORGE_PG_validation_session
    )


def unregister() -> None:
    """Unregister PropertyGroups and remove PointerProperty from WindowManager."""
    if hasattr(bpy.types.WindowManager, "excelion_forge_session"):
        del bpy.types.WindowManager.excelion_forge_session

    for blender_class in reversed(CLASSES):
        bpy.utils.unregister_class(blender_class)
