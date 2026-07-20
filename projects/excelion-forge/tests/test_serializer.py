"""Unit tests for core/serializer.py and core/html_report.py.

These tests are Blender-independent (no bpy required).
"""

from __future__ import annotations

import json
import os
import tempfile
import unittest
from typing import Any, cast


# ---------------------------------------------------------------------------
# Fake/Stub classes that mimic EFORGE_PG_validation_issue & session
# ---------------------------------------------------------------------------

class FakeIssue:
    """Fake representation of a validation issue."""

    def __init__(
        self,
        severity: str = "ERROR",
        code: str = "TEST_CODE",
        rule_name: str = "Test Rule",
        message: str = "Test message.",
        location_type: str = "none",
        object_name: str = "",
        bone_name: str = "",
        suggestion: str = "",
        has_fix: bool = False,
        fix_action_code: str = "",
        fix_params_json: str = "",
    ) -> None:
        self.severity = severity
        self.code = code
        self.rule_name = rule_name
        self.message = message
        self.location_type = location_type
        self.object_name = object_name
        self.bone_name = bone_name
        self.suggestion = suggestion
        self.has_fix = has_fix
        self.fix_action_code = fix_action_code
        self.fix_params_json = fix_params_json


class FakeSession:
    """Fake representation of a validation session conforming to ValidationSessionProtocol."""

    def __init__(
        self,
        issues: Any = None,
        error_count: int = 0,
        warning_count: int = 0,
        info_count: int = 0,
        has_run: bool = True,
        id: str = "test",
        active: bool = True,
        display_issues: Any = None,
        severity_filter: str = "ALL",
        search_query: str = "",
        sort_by: str = "SEVERITY",
    ) -> None:
        self.id = id
        self.active = active
        self.issues = issues or []
        self.error_count = error_count
        self.warning_count = warning_count
        self.info_count = info_count
        self.has_run = has_run
        self.display_issues = display_issues
        self.severity_filter = severity_filter
        self.search_query = search_query
        self.sort_by = sort_by

    def add_issue(self, issue: Any) -> None:
        self.issues.append(issue)

    def commit(self) -> None:
        pass

    def rollback(self) -> None:
        pass


def _make_issue(
    severity: str = "ERROR",
    code: str = "TEST_CODE",
    rule_name: str = "Test Rule",
    message: str = "Test message.",
    location_type: str = "none",
    object_name: str = "",
    bone_name: str = "",
    suggestion: str = "",
    has_fix: bool = False,
    fix_action_code: str = "",
    fix_params_json: str = "",
) -> FakeIssue:
    """Return a FakeIssue that mirrors EFORGE_PG_validation_issue fields."""
    return FakeIssue(
        severity=severity,
        code=code,
        rule_name=rule_name,
        message=message,
        location_type=location_type,
        object_name=object_name,
        bone_name=bone_name,
        suggestion=suggestion,
        has_fix=has_fix,
        fix_action_code=fix_action_code,
        fix_params_json=fix_params_json,
    )


def _make_session(
    issues: list | None = None,
    error_count: int = 0,
    warning_count: int = 0,
    info_count: int = 0,
    has_run: bool = True,
) -> FakeSession:
    """Return a FakeSession that mirrors EFORGE_PG_validation_session."""
    return FakeSession(
        issues=issues,
        error_count=error_count,
        warning_count=warning_count,
        info_count=info_count,
        has_run=has_run,
    )


# ---------------------------------------------------------------------------
# serializer tests
# ---------------------------------------------------------------------------

class TestSessionToDict(unittest.TestCase):
    """Test the session_to_dict conversion function."""

    def setUp(self) -> None:
        from excelion_forge.core.serializer import session_to_dict
        self.session_to_dict = session_to_dict

    def test_empty_session(self) -> None:
        session = _make_session()
        result = self.session_to_dict(session, target_name="Armature")
        self.assertEqual(result["target_object"], "Armature")
        self.assertEqual(result["summary"]["total"], 0)
        self.assertEqual(result["issues"], [])
        self.assertIn("exported_at", result)
        self.assertIn("excelion_forge_version", result)

    def test_session_with_issues(self) -> None:
        issues = [
            _make_issue(severity="ERROR", code="DUPLICATE_BONE_NAME",
                        rule_name="Bone Name", location_type="bone",
                        bone_name="Root", has_fix=True,
                        fix_action_code="RENAME_DUPLICATE_BONE"),
            _make_issue(severity="WARNING", code="ARMATURE_TRANSFORM_NOT_APPLIED",
                        rule_name="Armature Transform", location_type="object",
                        object_name="Armature"),
        ]
        session = _make_session(issues=issues, error_count=1, warning_count=1)
        result = self.session_to_dict(session, target_name="Armature")
        self.assertEqual(result["summary"]["total"], 2)
        self.assertEqual(result["summary"]["errors"], 1)
        self.assertEqual(result["summary"]["warnings"], 1)
        self.assertEqual(len(result["issues"]), 2)

    def test_issue_fields_mapping(self) -> None:
        issue = _make_issue(
            severity="ERROR",
            code="DUPLICATE_BONE_NAME",
            rule_name="Bone Name",
            message="Armature has duplicate bone name: 'Root'.",
            location_type="bone",
            bone_name="Root",
            suggestion="Use unique names.",
            has_fix=True,
            fix_action_code="RENAME_DUPLICATE_BONE",
        )
        session = _make_session(issues=[issue], error_count=1)
        result = self.session_to_dict(session)
        i = result["issues"][0]
        self.assertEqual(i["severity"], "ERROR")
        self.assertEqual(i["code"], "DUPLICATE_BONE_NAME")
        self.assertEqual(i["location_type"], "bone")
        self.assertEqual(i["bone_name"], "Root")
        self.assertTrue(i["has_fix"])
        self.assertEqual(i["fix_action_code"], "RENAME_DUPLICATE_BONE")

    def test_no_fix_action_code_when_no_fix(self) -> None:
        issue = _make_issue(has_fix=False, fix_action_code="SHOULD_NOT_APPEAR")
        session = _make_session(issues=[issue])
        result = self.session_to_dict(session)
        self.assertEqual(result["issues"][0]["fix_action_code"], "")

    def test_default_target_name_empty(self) -> None:
        session = _make_session()
        result = self.session_to_dict(session)
        self.assertEqual(result["target_object"], "")


class TestExportJson(unittest.TestCase):
    """Test JSON file writing."""

    def setUp(self) -> None:
        from excelion_forge.core.serializer import export_json
        self.export_json = export_json

    def test_writes_valid_json_file(self) -> None:
        session = _make_session(
            issues=[_make_issue(severity="ERROR", code="TEST")],
            error_count=1,
        )
        with tempfile.NamedTemporaryFile(
            suffix=".json", delete=False, mode="w", encoding="utf-8"
        ) as tmp:
            tmp_path = tmp.name

        try:
            self.export_json(session, tmp_path, target_name="Armature")
            with open(tmp_path, encoding="utf-8") as fp:
                data = json.load(fp)
            self.assertEqual(len(data["issues"]), 1)
            self.assertEqual(data["target_object"], "Armature")
        finally:
            os.unlink(tmp_path)

    def test_utf8_encoding(self) -> None:
        session = _make_session(
            issues=[_make_issue(message="한글 메시지 테스트")]
        )
        with tempfile.NamedTemporaryFile(
            suffix=".json", delete=False, mode="w", encoding="utf-8"
        ) as tmp:
            tmp_path = tmp.name

        try:
            self.export_json(session, tmp_path)
            with open(tmp_path, encoding="utf-8") as fp:
                data = json.load(fp)
            self.assertIn("한글", data["issues"][0]["message"])
        finally:
            os.unlink(tmp_path)


# ---------------------------------------------------------------------------
# html_report tests
# ---------------------------------------------------------------------------

class TestGenerateHtml(unittest.TestCase):
    """Test HTML report generation."""

    def setUp(self) -> None:
        from excelion_forge.core.serializer import session_to_dict
        from excelion_forge.core.html_report import generate_html
        self.session_to_dict = session_to_dict
        self.generate_html = generate_html

    def test_returns_string(self) -> None:
        session = _make_session()
        data = self.session_to_dict(session)
        html = self.generate_html(data)
        self.assertIsInstance(html, str)

    def test_html_structure(self) -> None:
        session = _make_session()
        data = self.session_to_dict(session, target_name="TestArmature")
        html = self.generate_html(data)
        self.assertIn("<!DOCTYPE html>", html)
        self.assertIn("Excelion Forge", html)
        self.assertIn("TestArmature", html)

    def test_severity_colors_present(self) -> None:
        issues = [
            _make_issue(severity="ERROR", code="E1"),
            _make_issue(severity="WARNING", code="W1"),
            _make_issue(severity="INFO", code="I1"),
        ]
        session = _make_session(issues=issues)
        data = self.session_to_dict(session)
        html = self.generate_html(data)
        self.assertIn("sev-ERROR", html)
        self.assertIn("sev-WARNING", html)
        self.assertIn("sev-INFO", html)

    def test_html_escaping(self) -> None:
        issue = _make_issue(message="a < b & c > d")
        session = _make_session(issues=[issue])
        data = self.session_to_dict(session)
        html = self.generate_html(data)
        self.assertIn("&lt;", html)
        self.assertIn("&gt;", html)
        self.assertIn("&amp;", html)
        self.assertNotIn("a < b", html)

    def test_no_issues_message(self) -> None:
        session = _make_session(issues=[])
        data = self.session_to_dict(session)
        html = self.generate_html(data)
        self.assertIn("All validation checks passed", html)

    def test_fix_available_shown(self) -> None:
        issue = _make_issue(has_fix=True, fix_action_code="APPLY_TRANSFORMS")
        session = _make_session(issues=[issue])
        data = self.session_to_dict(session)
        html = self.generate_html(data)
        self.assertIn("fix-yes", html)

    def test_location_bone_shown(self) -> None:
        issue = _make_issue(
            location_type="bone", bone_name="Root", object_name=""
        )
        session = _make_session(issues=[issue])
        data = self.session_to_dict(session)
        html = self.generate_html(data)
        self.assertIn("Bone: Root", html)

    def test_location_object_shown(self) -> None:
        issue = _make_issue(
            location_type="object", object_name="Armature", bone_name=""
        )
        session = _make_session(issues=[issue])
        data = self.session_to_dict(session)
        html = self.generate_html(data)
        self.assertIn("Object: Armature", html)


# ---------------------------------------------------------------------------
# properties module tests (no bpy — tests pure helper functions)
# ---------------------------------------------------------------------------

class TestPassesFilter(unittest.TestCase):
    """Test _passes_filter without bpy dependency."""

    def _import(self):
        # Import only the pure helper — bpy PropertyGroup classes won't be used
        import sys
        # Provide a minimal bpy mock so the module can be imported
        if "bpy" not in sys.modules:
            import types
            bpy_mock = types.ModuleType("bpy")
            bpy_mock.types = types.SimpleNamespace(PropertyGroup=object)  # type: ignore[attr-defined]
            bpy_mock.props = types.SimpleNamespace(  # type: ignore[attr-defined]
                StringProperty=lambda **kw: None,
                BoolProperty=lambda **kw: None,
                IntProperty=lambda **kw: None,
                CollectionProperty=lambda **kw: None,
                EnumProperty=lambda **kw: None,
                PointerProperty=lambda **kw: None,
            )
            bpy_mock.utils = types.SimpleNamespace(  # type: ignore[attr-defined]
                register_class=lambda c: None,
                unregister_class=lambda c: None,
            )
            sys.modules["bpy"] = bpy_mock
        from excelion_forge.properties import _passes_filter
        return _passes_filter

    def test_all_filter_passes_everything(self) -> None:
        _passes_filter = self._import()
        issue = FakeIssue(severity="ERROR", message="foo", code="BAR")
        self.assertTrue(_passes_filter(issue, "ALL", ""))

    def test_severity_filter_blocks_wrong_severity(self) -> None:
        _passes_filter = self._import()
        issue = FakeIssue(severity="WARNING", message="foo", code="BAR")
        self.assertFalse(_passes_filter(issue, "ERROR", ""))

    def test_query_matches_message(self) -> None:
        _passes_filter = self._import()
        issue = FakeIssue(severity="ERROR", message="duplicate bone name", code="X")
        self.assertTrue(_passes_filter(issue, "ALL", "duplicate"))

    def test_query_matches_code(self) -> None:
        _passes_filter = self._import()
        issue = FakeIssue(severity="ERROR", message="msg", code="DUPLICATE_BONE_NAME")
        self.assertTrue(_passes_filter(issue, "ALL", "duplicate_bone"))

    def test_query_no_match(self) -> None:
        _passes_filter = self._import()
        issue = FakeIssue(severity="ERROR", message="msg", code="CODE")
        self.assertFalse(_passes_filter(issue, "ALL", "xyz_not_present"))


class TestMakeSortKey(unittest.TestCase):
    """Test _make_sort_key without bpy dependency."""

    def _import(self):
        import sys
        if "bpy" not in sys.modules:
            import types
            bpy_mock = types.ModuleType("bpy")
            bpy_mock.types = types.SimpleNamespace(PropertyGroup=object)  # type: ignore[attr-defined]
            bpy_mock.props = types.SimpleNamespace(  # type: ignore[attr-defined]
                StringProperty=lambda **kw: None,
                BoolProperty=lambda **kw: None,
                IntProperty=lambda **kw: None,
                CollectionProperty=lambda **kw: None,
                EnumProperty=lambda **kw: None,
                PointerProperty=lambda **kw: None,
            )
            bpy_mock.utils = types.SimpleNamespace(  # type: ignore[attr-defined]
                register_class=lambda c: None,
                unregister_class=lambda c: None,
            )
            sys.modules["bpy"] = bpy_mock
        from excelion_forge.properties import _make_sort_key
        return _make_sort_key

    def test_severity_sort_error_first(self) -> None:
        _make_sort_key = self._import()
        issues = [
            FakeIssue(severity="INFO", code="I", rule_name="", object_name="", bone_name=""),
            FakeIssue(severity="WARNING", code="W", rule_name="", object_name="", bone_name=""),
            FakeIssue(severity="ERROR", code="E", rule_name="", object_name="", bone_name=""),
        ]
        sorted_issues = sorted(issues, key=_make_sort_key("SEVERITY"))
        self.assertEqual(sorted_issues[0].severity, "ERROR")
        self.assertEqual(sorted_issues[1].severity, "WARNING")
        self.assertEqual(sorted_issues[2].severity, "INFO")

    def test_rule_name_sort(self) -> None:
        _make_sort_key = self._import()
        issues = [
            FakeIssue(severity="ERROR", code="Z", rule_name="Zzz Rule", object_name="", bone_name=""),
            FakeIssue(severity="ERROR", code="A", rule_name="Aaa Rule", object_name="", bone_name=""),
        ]
        sorted_issues = sorted(issues, key=_make_sort_key("RULE_NAME"))
        self.assertEqual(sorted_issues[0].rule_name, "Aaa Rule")

    def test_location_sort(self) -> None:
        _make_sort_key = self._import()
        issues = [
            FakeIssue(severity="ERROR", code="X", rule_name="", object_name="ZArmature", bone_name=""),
            FakeIssue(severity="ERROR", code="Y", rule_name="", object_name="AArmature", bone_name=""),
        ]
        sorted_issues = sorted(issues, key=_make_sort_key("LOCATION"))
        self.assertEqual(sorted_issues[0].object_name, "AArmature")


class _MockIssueCollection:
    """Minimal CollectionProperty stand-in for rebuild_display_issues tests."""

    def __init__(self, items: list | None = None) -> None:
        self._items: list = list(items or [])

    def clear(self) -> None:
        self._items.clear()

    def add(self) -> FakeIssue:
        item = FakeIssue(
            severity="",
            code="",
            message="",
            rule_name="",
            location_type="none",
            object_name="",
            bone_name="",
            suggestion="",
            has_fix=False,
            fix_action_code="",
            fix_params_json="",
        )
        self._items.append(item)
        return item

    def __iter__(self):
        return iter(self._items)

    def __len__(self) -> int:
        return len(self._items)


class TestRebuildDisplayIssues(unittest.TestCase):
    """Test rebuild_display_issues end-to-end with mock session objects."""

    def _import(self):
        import sys
        if "bpy" not in sys.modules:
            import types
            bpy_mock = types.ModuleType("bpy")
            bpy_mock.types = types.SimpleNamespace(PropertyGroup=object)  # type: ignore[attr-defined]
            bpy_mock.props = types.SimpleNamespace(  # type: ignore[attr-defined]
                StringProperty=lambda **kw: None,
                BoolProperty=lambda **kw: None,
                IntProperty=lambda **kw: None,
                CollectionProperty=lambda **kw: None,
                EnumProperty=lambda **kw: None,
                PointerProperty=lambda **kw: None,
            )
            bpy_mock.utils = types.SimpleNamespace(  # type: ignore[attr-defined]
                register_class=lambda c: None,
                unregister_class=lambda c: None,
            )
            sys.modules["bpy"] = bpy_mock
        from excelion_forge.properties import rebuild_display_issues
        return rebuild_display_issues

    def test_filter_and_sort_by_severity(self) -> None:
        rebuild_display_issues = self._import()
        issues = _MockIssueCollection([
            _make_issue(severity="INFO", code="I1"),
            _make_issue(severity="ERROR", code="E1"),
            _make_issue(severity="WARNING", code="W1"),
        ])
        session = FakeSession(
            issues=issues,
            display_issues=_MockIssueCollection(),
            severity_filter="ALL",
            search_query="",
            sort_by="SEVERITY",
        )
        rebuild_display_issues(cast(Any, session))
        self.assertEqual(len(session.display_issues), 3)
        severities = [i.severity for i in session.display_issues]
        self.assertEqual(severities, ["ERROR", "WARNING", "INFO"])

    def test_severity_filter_applied(self) -> None:
        rebuild_display_issues = self._import()
        issues = _MockIssueCollection([
            _make_issue(severity="ERROR", code="E1"),
            _make_issue(severity="WARNING", code="W1"),
        ])
        session = FakeSession(
            issues=issues,
            display_issues=_MockIssueCollection(),
            severity_filter="ERROR",
            search_query="",
            sort_by="SEVERITY",
        )
        rebuild_display_issues(cast(Any, session))
        self.assertEqual(len(session.display_issues), 1)
        self.assertEqual(session.display_issues._items[0].severity, "ERROR")

    def test_search_query_applied(self) -> None:
        rebuild_display_issues = self._import()
        issues = _MockIssueCollection([
            _make_issue(severity="ERROR", code="DUPLICATE_BONE_NAME", message="dup"),
            _make_issue(severity="ERROR", code="OTHER", message="other"),
        ])
        session = FakeSession(
            issues=issues,
            display_issues=_MockIssueCollection(),
            severity_filter="ALL",
            search_query="duplicate",
            sort_by="SEVERITY",
        )
        rebuild_display_issues(cast(Any, session))
        self.assertEqual(len(session.display_issues), 1)
        self.assertEqual(session.display_issues._items[0].code, "DUPLICATE_BONE_NAME")

    def test_sort_by_rule_name(self) -> None:
        rebuild_display_issues = self._import()
        issues = _MockIssueCollection([
            _make_issue(severity="ERROR", code="Z", rule_name="Zzz Rule"),
            _make_issue(severity="ERROR", code="A", rule_name="Aaa Rule"),
        ])
        session = FakeSession(
            issues=issues,
            display_issues=_MockIssueCollection(),
            severity_filter="ALL",
            search_query="",
            sort_by="RULE_NAME",
        )
        rebuild_display_issues(cast(Any, session))
        rule_names = [i.rule_name for i in session.display_issues]
        self.assertEqual(rule_names, ["Aaa Rule", "Zzz Rule"])

    def test_copies_all_fields_to_display_cache(self) -> None:
        rebuild_display_issues = self._import()
        source = _make_issue(
            severity="ERROR",
            code="TEST",
            rule_name="Rule",
            message="msg",
            location_type="bone",
            object_name="Arm",
            bone_name="Root",
            suggestion="fix it",
            has_fix=True,
            fix_action_code="APPLY",
            fix_params_json='{"x": 1}',
        )
        issues = _MockIssueCollection([source])
        session = FakeSession(
            issues=issues,
            display_issues=_MockIssueCollection(),
            severity_filter="ALL",
            search_query="",
            sort_by="SEVERITY",
        )
        rebuild_display_issues(cast(Any, session))
        displayed = session.display_issues._items[0]
        self.assertEqual(displayed.code, "TEST")
        self.assertEqual(displayed.bone_name, "Root")
        self.assertTrue(displayed.has_fix)
        self.assertEqual(displayed.fix_params_json, '{"x": 1}')


class TestExportHtml(unittest.TestCase):
    """Test HTML file writing."""

    def setUp(self) -> None:
        from excelion_forge.core.html_report import export_html
        self.export_html = export_html

    def test_writes_valid_html_file(self) -> None:
        session = _make_session(
            issues=[_make_issue(severity="ERROR", code="TEST")],
            error_count=1,
        )
        with tempfile.NamedTemporaryFile(
            suffix=".html", delete=False, mode="w", encoding="utf-8"
        ) as tmp:
            tmp_path = tmp.name

        try:
            self.export_html(session, tmp_path, target_name="Armature")
            with open(tmp_path, encoding="utf-8") as fp:
                html = fp.read()
            self.assertIn("<!DOCTYPE html>", html)
            self.assertIn("Armature", html)
            self.assertIn("TEST", html)
        finally:
            os.unlink(tmp_path)

    def test_utf8_encoding(self) -> None:
        session = _make_session(
            issues=[_make_issue(message="한글 HTML 테스트")]
        )
        with tempfile.NamedTemporaryFile(
            suffix=".html", delete=False, mode="w", encoding="utf-8"
        ) as tmp:
            tmp_path = tmp.name

        try:
            self.export_html(session, tmp_path)
            with open(tmp_path, encoding="utf-8") as fp:
                html = fp.read()
            self.assertIn("한글", html)
        finally:
            os.unlink(tmp_path)


class TestDefaultFilenames(unittest.TestCase):
    """Test timestamped default export filenames."""

    def test_default_json_filename_format(self) -> None:
        from excelion_forge.core.serializer import default_json_filename
        name = default_json_filename()
        self.assertTrue(name.startswith("forge_validation_"))
        self.assertTrue(name.endswith(".json"))
        self.assertEqual(len(name), len("forge_validation_YYYYMMDD_HHMMSS.json"))

    def test_default_html_filename_format(self) -> None:
        from excelion_forge.core.html_report import default_html_filename
        name = default_html_filename()
        self.assertTrue(name.startswith("forge_validation_"))
        self.assertTrue(name.endswith(".html"))


if __name__ == "__main__":
    unittest.main()
