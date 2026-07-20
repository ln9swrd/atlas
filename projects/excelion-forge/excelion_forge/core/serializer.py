"""JSON serialization for Excelion Forge validation results.

This module is Blender-independent: it only accesses Python attributes via
getattr, so it can be unit-tested without a running Blender instance.
"""

from __future__ import annotations

import json
from datetime import datetime


_VERSION = "0.2"


def session_to_dict(session: object, target_name: str = "") -> dict:
    """Convert a session PropertyGroup (or any duck-typed object) to a dict.

    Args:
        session: EFORGE_PG_validation_session or compatible object.
        target_name: Name of the armature object being validated.

    Returns:
        A JSON-serialisable dictionary representing the full validation result.
    """
    issues = getattr(session, "issues", [])
    return {
        "excelion_forge_version": _VERSION,
        "exported_at": datetime.now().isoformat(timespec="seconds"),
        "target_object": target_name,
        "summary": {
            "total": len(issues),
            "errors": int(getattr(session, "error_count", 0)),
            "warnings": int(getattr(session, "warning_count", 0)),
            "infos": int(getattr(session, "info_count", 0)),
        },
        "issues": [_issue_to_dict(i) for i in issues],
    }


def _issue_to_dict(issue: object) -> dict:
    """Convert a single issue PropertyGroup item to a plain dict."""
    return {
        "severity": str(getattr(issue, "severity", "")),
        "code": str(getattr(issue, "code", "")),
        "rule_name": str(getattr(issue, "rule_name", "")),
        "message": str(getattr(issue, "message", "")),
        "location_type": str(getattr(issue, "location_type", "none")),
        "object_name": str(getattr(issue, "object_name", "")),
        "bone_name": str(getattr(issue, "bone_name", "")),
        "suggestion": str(getattr(issue, "suggestion", "")),
        "has_fix": bool(getattr(issue, "has_fix", False)),
        "fix_action_code": str(getattr(issue, "fix_action_code", "")) if getattr(issue, "has_fix", False) else "",
        "fix_params_json": str(getattr(issue, "fix_params_json", "")) if getattr(issue, "has_fix", False) else "",
    }


def export_json(session: object, filepath: str, target_name: str = "") -> None:
    """Serialize the session and write it as UTF-8 JSON to filepath.

    Args:
        session: EFORGE_PG_validation_session or compatible object.
        filepath: Absolute path for the output file.
        target_name: Name of the armature object being validated.
    """
    data = session_to_dict(session, target_name)
    with open(filepath, "w", encoding="utf-8") as fp:
        json.dump(data, fp, ensure_ascii=False, indent=2)


def default_json_filename() -> str:
    """Return a timestamped default filename for JSON export."""
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    return f"forge_validation_{ts}.json"
