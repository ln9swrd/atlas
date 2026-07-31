"""Unit tests for tools.domain_policy (P2-1 Phase A)."""
from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
TOOLS = REPO_ROOT / "tools"
sys.path.insert(0, str(TOOLS))

from domain_policy import (  # noqa: E402
    assert_path_allowed,
    get_active_domain,
    path_is_allowed,
    path_is_blacklisted,
)


class DomainPolicyPhaseATests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.ws = Path(self.tmp.name)
        (self.ws / "state").mkdir()
        (self.ws / "tools").mkdir()
        (self.ws / "docs").mkdir()
        (self.ws / "core").mkdir()
        (self.ws / "projects" / "excelion-forge").mkdir(parents=True)
        (self.ws / "archive").mkdir()
        (self.ws / "state" / "CURRENT_STATE.md").write_text(
            "ACTIVE_TARGET: platform P2\n",
            encoding="utf-8",
        )
        (self.ws / "tools" / "x.py").write_text("#\n", encoding="utf-8")
        (self.ws / "projects" / "excelion-forge" / "a.py").write_text("#\n", encoding="utf-8")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def test_blacklist_archive(self) -> None:
        self.assertTrue(path_is_blacklisted("archive/x", workspace=self.ws))

    def test_platform_allows_system(self) -> None:
        self.assertTrue(path_is_allowed("state/CURRENT_STATE.md", workspace=self.ws, active=None))
        self.assertTrue(path_is_allowed("tools/x.py", workspace=self.ws, active=None))
        self.assertTrue(path_is_allowed("core/y.py", workspace=self.ws, active=None))

    def test_platform_denies_product(self) -> None:
        self.assertFalse(
            path_is_allowed("projects/excelion-forge/a.py", workspace=self.ws, active=None)
        )

    def test_active_allows_product(self) -> None:
        self.assertTrue(
            path_is_allowed(
                "projects/excelion-forge/a.py", workspace=self.ws, active="excelion-forge"
            )
        )

    def test_active_denies_other_product(self) -> None:
        self.assertFalse(
            path_is_allowed("projects/other/a.py", workspace=self.ws, active="excelion-forge")
        )

    def test_get_active_domain_from_state(self) -> None:
        self.assertIsNone(get_active_domain(workspace=self.ws))
        (self.ws / "state" / "CURRENT_STATE.md").write_text(
            "ACTIVE_TARGET: projects/excelion-forge\n",
            encoding="utf-8",
        )
        self.assertEqual(get_active_domain(workspace=self.ws), "excelion-forge")

    def test_assert_path_allowed_raises(self) -> None:
        with self.assertRaises(PermissionError):
            assert_path_allowed(
                "projects/excelion-forge/a.py", workspace=self.ws, active=None
            )

    def test_assert_path_allowed_system_ok(self) -> None:
        assert_path_allowed("tools/x.py", workspace=self.ws, active=None)


if __name__ == "__main__":
    unittest.main()
