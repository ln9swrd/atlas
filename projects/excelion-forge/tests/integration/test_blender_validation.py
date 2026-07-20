"""Blender headless integration tests for Excelion Forge.

이 스크립트는 Blender Python 환경에서 실행됩니다.

단일 샘플 실행:
    blender --background tests/blend_samples/valid_rig.blend \\
            --python tests/integration/test_blender_validation.py

전체 샘플 일괄 실행:
    python tests/integration/run_all.py

CI 연동 (GitHub Actions 예시):
    - name: Install Blender
      run: |
        wget -q https://download.blender.org/release/Blender5.0/blender-5.0.0-linux-x64.tar.xz
        tar -xf blender-5.0.0-linux-x64.tar.xz
        echo "${{ github.workspace }}/blender-5.0.0-linux-x64" >> $GITHUB_PATH

    - name: Generate regression samples
      run: blender --background --python tests/blend_samples/generate_samples.py

    - name: Run Integration Tests
      run: python tests/integration/run_all.py

요구사항:
    - Blender 5.x
    - excelion_forge addon이 sys.path에 포함되어야 함 (저장소 루트)
"""

from __future__ import annotations

import json
import sys
import tempfile
import traceback
from pathlib import Path
from typing import Any
from excelion_forge.core.pipeline import ValidationSessionProtocol


class FakeContext:
    mode: str = "OBJECT"
    active_object: Any = None


# ---------------------------------------------------------------------------
# bpy import guard — skip when running under regular pytest/unittest
# ---------------------------------------------------------------------------
try:
    import bpy
    _HAS_BPY = True
except ImportError:
    _HAS_BPY = False

_REPO_ROOT = Path(__file__).resolve().parent.parent.parent
_SAMPLES_DIR = _REPO_ROOT / "tests" / "blend_samples"

# blend filename → validation expectations
SAMPLE_CASES: dict[str, dict] = {
    "valid_rig.blend": {
        "armature": "Armature_Valid",
        "required_codes": [],
        "forbidden_codes": [],
        "max_issues": 0,
    },
    "invalid_transform.blend": {
        "armature": "Armature_BadTransform",
        "required_codes": ["ARMATURE_TRANSFORM_NOT_APPLIED"],
        "forbidden_codes": [],
    },
    "invalid_duplicate_bone.blend": {
        "armature": "Armature_DupBone",
        "required_codes": ["MULTIPLE_ROOT_BONES"],
        "forbidden_codes": [],
    },
    "invalid_empty_bone.blend": {
        "armature": "Armature_EmptyBone",
        "required_codes": ["BONE_NAME_EMPTY"],
        "forbidden_codes": [],
    },
    "invalid_multi_issue.blend": {
        "armature": "Armature_MultiIssue",
        "required_codes": [
            "MULTIPLE_ROOT_BONES",
            "ARMATURE_TRANSFORM_NOT_APPLIED",
        ],
        "forbidden_codes": [],
        "run_ux_tests": True,
    },
}


if not _HAS_BPY:
    import unittest

    class BlenderIntegrationSkipped(unittest.TestCase):
        """Placeholder that skips all Blender integration tests in non-bpy environments."""

        @unittest.skip("Blender (bpy) not available — run via 'blender --background --python'")
        def test_placeholder(self) -> None:
            pass

else:
    def _ensure_addon_path() -> None:
        """Add the repository root to sys.path so excelion_forge is importable."""
        addon_root = str(_REPO_ROOT)
        if addon_root not in sys.path:
            sys.path.insert(0, addon_root)

    def _assert(condition: bool, message: str) -> None:
        """Minimal assertion with traceback-safe output."""
        if not condition:
            raise AssertionError(message)

    def _register_addon() -> None:
        """Register Excelion Forge if not already registered."""
        from excelion_forge import register as forge_register
        try:
            forge_register()
        except Exception:
            pass

    def _run_validation(armature_name: str) -> ValidationSessionProtocol:
        """Set active object, run validation, return session."""
        obj = bpy.data.objects.get(armature_name)
        if obj is None:
            available = [o.name for o in bpy.data.objects]
            raise RuntimeError(
                f"Object '{armature_name}' not found. Available: {available}"
            )

        bpy.context.view_layer.objects.active = obj
        bpy.ops.excelion_forge.validate_active_rig()
        return bpy.context.window_manager.excelion_forge_session

    def _current_sample_name() -> str:
        """Return the basename of the currently loaded .blend file."""
        filepath = bpy.data.filepath
        if not filepath:
            raise RuntimeError(
                "No .blend file loaded. Run via "
                "'blender --background <sample.blend> --python ...'"
            )
        return Path(filepath).name

    def _get_case() -> tuple[str, dict]:
        """Resolve the active sample case from the loaded blend file."""
        sample_name = _current_sample_name()
        case = SAMPLE_CASES.get(sample_name)
        if case is None:
            known = ", ".join(sorted(SAMPLE_CASES))
            raise RuntimeError(
                f"Unknown sample '{sample_name}'. Known samples: {known}"
            )
        return sample_name, case

    def test_validate_sample() -> None:
        """Validate the loaded sample and assert expected issue codes."""
        _ensure_addon_path()
        _register_addon()
        sample_name, case = _get_case()
        session = _run_validation(case["armature"])

        _assert(session.has_run, "session.has_run should be True after validation")
        codes = [issue.code for issue in session.issues]

        max_issues = case.get("max_issues")
        if max_issues is not None:
            _assert(
                len(session.issues) == max_issues,
                f"[{sample_name}] Expected {max_issues} issues, got {len(codes)}: {codes}",
            )

        for code in case.get("required_codes", []):
            _assert(
                code in codes,
                f"[{sample_name}] Missing required code '{code}'. Got: {codes}",
            )

        for code in case.get("forbidden_codes", []):
            _assert(
                code not in codes,
                f"[{sample_name}] Unexpected forbidden code '{code}'. Got: {codes}",
            )

        print(f"  PASS: test_validate_sample ({sample_name})")

    def test_json_export() -> None:
        """JSON export produces a valid UTF-8 JSON file."""
        _ensure_addon_path()
        from excelion_forge.core.serializer import export_json

        session = bpy.context.window_manager.excelion_forge_session
        _assert(session.has_run, "Run validation before export test")

        with tempfile.NamedTemporaryFile(
            suffix=".json", delete=False, mode="w", encoding="utf-8"
        ) as tmp:
            tmp_path = tmp.name

        try:
            sample_name, case = _get_case()
            export_json(session, tmp_path, target_name=case["armature"])
            with open(tmp_path, encoding="utf-8") as fp:
                data = json.load(fp)
            _assert("issues" in data, "Exported JSON missing 'issues' key")
            _assert("summary" in data, "Exported JSON missing 'summary' key")
            _assert(
                data["excelion_forge_version"] == "0.2",
                f"Unexpected version: {data.get('excelion_forge_version')}",
            )
            print(f"  PASS: test_json_export ({sample_name})")
        finally:
            Path(tmp_path).unlink(missing_ok=True)

    def test_html_export() -> None:
        """HTML export produces a valid standalone report."""
        _ensure_addon_path()
        from excelion_forge.core.html_report import export_html

        session = bpy.context.window_manager.excelion_forge_session
        _assert(session.has_run, "Run validation before export test")

        with tempfile.NamedTemporaryFile(
            suffix=".html", delete=False, mode="w", encoding="utf-8"
        ) as tmp:
            tmp_path = tmp.name

        try:
            sample_name, case = _get_case()
            export_html(session, tmp_path, target_name=case["armature"])
            html = Path(tmp_path).read_text(encoding="utf-8")
            _assert("<!DOCTYPE html>" in html, "HTML missing doctype")
            _assert("Excelion Forge" in html, "HTML missing title")
            _assert("badge-error" in html, "HTML missing severity summary")
            print(f"  PASS: test_html_export ({sample_name})")
        finally:
            Path(tmp_path).unlink(missing_ok=True)

    def test_severity_filter_and_sort() -> None:
        """display_issues cache respects severity filter and sort order."""
        _ensure_addon_path()
        from excelion_forge.properties import rebuild_display_issues

        session = bpy.context.window_manager.excelion_forge_session
        _assert(session.has_run, "Run validation before filter/sort test")
        _assert(len(session.issues) > 0, "Filter/sort test requires at least one issue")

        session.severity_filter = "ERROR"
        rebuild_display_issues(session)
        for issue in session.display_issues:
            _assert(
                issue.severity == "ERROR",
                f"Unexpected severity in filtered display_issues: {issue.severity}",
            )

        session.severity_filter = "ALL"
        session.sort_by = "RULE_NAME"
        rebuild_display_issues(session)
        rule_names = [issue.rule_name.lower() for issue in session.display_issues]
        _assert(
            rule_names == sorted(rule_names),
            f"display_issues not sorted by rule name: {rule_names}",
        )

        session.sort_by = "SEVERITY"
        rebuild_display_issues(session)
        sample_name, _ = _get_case()
        print(f"  PASS: test_severity_filter_and_sort ({sample_name})")

    def _main() -> None:
        _ensure_addon_path()
        _register_addon()
        sample_name, case = _get_case()

        tests = [test_validate_sample, test_json_export, test_html_export]
        if case.get("run_ux_tests") or len(case.get("required_codes", [])) > 1:
            tests.append(test_severity_filter_and_sort)

        passed = 0
        failed = 0
        for test_fn in tests:
            try:
                test_fn()
                passed += 1
            except Exception as exc:
                print(f"  FAIL: {test_fn.__name__} [{sample_name}]: {exc}")
                traceback.print_exc()
                failed += 1

        print(f"\nIntegration Tests [{sample_name}]: {passed} passed, {failed} failed.")
        sys.exit(1 if failed else 0)

    _main()
